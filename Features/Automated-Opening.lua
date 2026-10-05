--------------------------------------------------------------------------------
-- GogoLoot Automated Opening
--------------------------------------------------------------------------------

--[[
    Opens clams, containers and unlocked lockboxes in the bags, one every
    ns.OPEN_TICK_INTERVAL, whenever it is safe to. Which items it opens, and
    whether one waits for its lock, is Features/Openable-Items.lua's answer.

    The pipeline is scan, queue, open. A burst of bag events becomes one scan
    (ScheduleOpeningScan); the scan checks free space, pauses or resumes, and
    rebuilds the queue of bag slots worth opening; the open tick then works
    through the queue while every safety gate holds.

    Gated by ns.db.profile.autoOpen. Auto Loot is enforced while it is on
    (Features/Auto-Loot.lua), since a container opened into a loot window nobody
    empties would stall the queue.
]]
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local isPaused = false
-- What the player was last told, so a held status message prints once the window closes.
local announcedPaused = false
local openTimerLive = false
local scanPending = false
local scanDueAt = 0
local lastBagFullAt = nil

--[[
    Opens the game refused. An open the game takes always answers with a loot
    window, so one still unanswered ns.OPEN_ANSWER_TIMEOUT later was refused:
    a holiday, or another rule no API reports, rules it out for this character.
    After ns.OPEN_REFUSAL_LIMIT refusals in a row the item is left alone until
    the next level-up or login, rather than tried every tick into the same red
    error.
]]
local pendingOpenItem, pendingOpenAt = nil, 0
local refusedOpenCounts = {}
local refusedItems = {}

---@return boolean
local function IsAutomatedOpeningOn()
	return ns.db ~= nil and ns.db.profile.autoOpen and true or false
end

---@return boolean
function ns:IsAutomatedOpeningPaused()
	return isPaused
end

--------------------------------------------------------------------------------
-- Safety Checks
--------------------------------------------------------------------------------

-- The character's own "inventory is full" voice line, by race and by sex as UnitSex returns it.
local function PlayBagFullSound()
	local _, raceFile = UnitRace("player")
	local sex = UnitSex("player")
	local raceSounds = raceFile and ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE[raceFile]
	if raceSounds and raceSounds[sex] then
		PlaySound(raceSounds[sex], "Master")
	else
		PlaySound(ns.SOUND_KIT_IDS.BAG_FULL_FALLBACK, "Master")
	end
end

--[[
    Stealth, or Shadowmeld's aura. WoW Forever makes aura reads secret during
    encounters and PvP matches, out of combat too, and a secret can't be
    compared, so C_Secrets is asked first: while Shadowmeld's aura would read
    secret it can't be ruled out, and opening waits for the next scan.
]]
local function IsPlayerStealthed()
	if IsStealthed() then
		return true
	end
	if C_Secrets.ShouldSpellAuraBeSecret(ns.SPELLS.SHADOWMELD) then
		return true
	end
	return C_UnitAuras.GetPlayerAuraBySpellID(ns.SPELLS.SHADOWMELD) ~= nil
end

--[[
    A vendor, mailbox, trade, bank, auction house, quest giver or loot window.
    Opening a container into any of them would put its loot in the way of what
    the player is doing, so opening waits for the window to close, and its
    closing event rescans. The auction house is AuctionFrame on Era and TBC and
    AuctionHouseFrame on WoW Forever; each client has only its own.
]]
local function IsInteractionActive()
	return (MerchantFrame and MerchantFrame:IsShown())
		or (MailFrame and MailFrame:IsShown())
		or (TradeFrame and TradeFrame:IsShown())
		or (BankFrame and BankFrame:IsShown())
		or (GuildBankFrame and GuildBankFrame:IsShown())
		or (AuctionFrame and AuctionFrame:IsShown())
		or (AuctionHouseFrame and AuctionHouseFrame:IsShown())
		or (GossipFrame and GossipFrame:IsShown())
		or (QuestFrame and QuestFrame:IsShown())
		or (LootFrame and LootFrame:IsShown())
		or false
end

--[[
    The player is busy with something no event reports the end of: an item
    under the cursor, or an open confirmation pop-up. The tick waits these out
    itself rather than stopping, since nothing would start it again.
]]
local function IsWaitingOnPlayer()
	if StaticPopup1 and StaticPopup1:IsShown() then
		return true
	end
	-- The player is looking at an item; opening under the cursor would move it.
	if GameTooltip:IsShown() then
		local itemName, itemLink = GameTooltip:GetItem()
		if itemName or itemLink then
			return true
		end
	end
	return false
end

local function IsSafeToOpen()
	if not IsAutomatedOpeningOn() or isPaused then
		return false
	end

	--[[
        Where and Group are the player's own hold-offs: bag space stays free for
        drops while in an instance or a group, and the containers open once the
        player is back on their own time. GROUP_ROSTER_UPDATE and a zone change
        both rescan, so leaving either state resumes opening without waiting on a
        bag event.
    ]]
	if ns.db.profile.autoOpenWhere == "OUTSIDE_INSTANCES" and IsInInstance() then
		return false
	end
	if ns.db.profile.autoOpenGroup == "SOLO_ONLY" and IsInGroup() then
		return false
	end

	if UnitAffectingCombat("player") or IsInteractionActive() or IsPlayerStealthed() then
		return false
	end
	-- A cast that would read secret (WoW Forever) can't be ruled out, so opening waits for the next scan.
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return false
	end
	if UnitCastingInfo("player") or UnitChannelInfo("player") then
		return false
	end

	return ns.CountFreeBagSlots() >= ns.MIN_FREE_SLOTS
end

--[[
    Pause and resume share one line, ns.MIN_FREE_SLOTS: opening pauses below it
    and resumes on reaching it, so the message names the count that actually
    resumes opening.

    The message is held while a vendor, mailbox, bank or similar window is open,
    or "Resumed" is lost in the player's vendoring; the window's close flushes it.
]]
local function AnnounceStatus()
	if IsInteractionActive() or isPaused == announcedPaused then
		return
	end
	if isPaused then
		ns:StatusPrint(L["MESSAGE_OPENING_PAUSED"]:format(ns.MIN_FREE_SLOTS))
	else
		ns:StatusPrint(L["MESSAGE_OPENING_RESUMED"])
	end
	announcedPaused = isPaused
end

--------------------------------------------------------------------------------
-- Queue
--------------------------------------------------------------------------------

--[[
    A flat array of (bag, slot, itemId) triples with head and tail cursors, wiped
    and reset when drained, so a scan allocates nothing per slot.
]]
local queue, queueHead, queueTail = {}, 1, 0

local function QueuePush(bagIndex, slotIndex, itemIdentifier)
	queueTail = queueTail + 3
	queue[queueTail - 2], queue[queueTail - 1], queue[queueTail] = bagIndex, slotIndex, itemIdentifier
end

local function QueuePop()
	if queueHead > queueTail then
		return nil
	end
	local bagIndex, slotIndex, itemIdentifier = queue[queueHead], queue[queueHead + 1], queue[queueHead + 2]
	queueHead = queueHead + 3
	if queueHead > queueTail then
		wipe(queue)
		queueHead, queueTail = 1, 0
	end
	return bagIndex, slotIndex, itemIdentifier
end

--[[
    Whether a bag slot's item should be opened now. Every item set to Open is
    checked for a lock, lockbox or not: the game can't open a locked box, so it
    waits for its lock rather than being tried again every tick into "Item is
    locked" errors. An item above the player's level waits for the level the
    same way; one not yet cached reads no level, and a refusal then sets it aside.
]]
---@param bagIndex number
---@param slotIndex number
---@param itemIdentifier number
---@return boolean
local function ShouldOpen(bagIndex, slotIndex, itemIdentifier)
	if ns:GetOpeningAction(itemIdentifier) ~= ns.OPENING_OPEN or refusedItems[itemIdentifier] then
		return false
	end
	local requiredLevel = select(5, C_Item.GetItemInfo(itemIdentifier))
	if requiredLevel and requiredLevel > UnitLevel("player") then
		return false
	end
	return not ns.IsItemLocked(bagIndex, slotIndex)
end

-- The last open went unanswered past its timeout, so it counts toward setting its item aside.
local function CountRefusedOpen()
	if not pendingOpenItem then
		return
	end
	local count = (refusedOpenCounts[pendingOpenItem] or 0) + 1
	refusedOpenCounts[pendingOpenItem] = count
	if count >= ns.OPEN_REFUSAL_LIMIT then
		refusedItems[pendingOpenItem] = true
	end
	pendingOpenItem = nil
end

local function BuildQueue()
	wipe(queue)
	queueHead, queueTail = 1, 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			if itemIdentifier and ShouldOpen(bagIndex, slotIndex, itemIdentifier) then
				QueuePush(bagIndex, slotIndex, itemIdentifier)
			end
		end
	end
end

--[[
    The boxes in the bags still waiting on a lock: anything Automated Opening
    would open that still reads Locked. One row per distinct item with a stack
    count, sorted by name, for the mini-map tooltip's Locked Items list and
    Diagnostics.

    Worked out on demand and deliberately not cached: it runs once per tooltip
    render, and a cache would need clearing on every bag, trade and pick-lock
    event. The name comes from the container's own item link, already localized
    and quality-colored, with no C_Item.GetItemInfo round trip.
]]
---@return table[]
function ns.GetLockedBoxes()
	local rowsByIdentifier, rows = {}, {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			if
				itemIdentifier
				and ns:GetOpeningAction(itemIdentifier) == ns.OPENING_OPEN
				and ns.IsItemLocked(bagIndex, slotIndex)
			then
				local row = rowsByIdentifier[itemIdentifier]
				if row then
					row.count = row.count + 1
				else
					local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
					row = {
						itemIdentifier = itemIdentifier,
						count = 1,
						icon = ns.GetItemIconByID(itemIdentifier),
						name = itemLink and string.match(itemLink, "|h%[(.-)%]|h"),
						link = itemLink,
					}
					rowsByIdentifier[itemIdentifier] = row
					rows[#rows + 1] = row
				end
			end
		end
	end
	table.sort(rows, function(a, b)
		if (a.name ~= nil) ~= (b.name ~= nil) then
			return a.name ~= nil
		end
		if a.name and b.name and a.name ~= b.name then
			return a.name < b.name
		end
		return a.itemIdentifier < b.itemIdentifier
	end)
	return rows
end

--------------------------------------------------------------------------------
-- Open Tick
--------------------------------------------------------------------------------

local OpenTick

local function StartOpenTick()
	openTimerLive = true
	C_Timer.After(ns.OPEN_TICK_INTERVAL, OpenTick)
end

--[[
    After an open, the slot is looked at again: a stack still holds more of the
    same item, and an open the server didn't take leaves the item where it was.
    Either way it goes back on the queue if it still should be opened.
]]
local function RecheckSlot(bagIndex, slotIndex, itemIdentifier)
	C_Timer.After(ns.OPEN_RECHECK_DELAY, function()
		local stillThere = ns.GetBagItemIdentifier(bagIndex, slotIndex)
		if stillThere == itemIdentifier and ShouldOpen(bagIndex, slotIndex, stillThere) then
			QueuePush(bagIndex, slotIndex, stillThere)
		end
		if IsSafeToOpen() and not openTimerLive and queueHead <= queueTail then
			StartOpenTick()
		end
	end)
end

OpenTick = function()
	openTimerLive = false
	-- Neither re-arms: combat ending and the next scan restart the tick, so nothing polls through a battleground.
	if UnitAffectingCombat("player") or C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return
	end
	-- A cast in progress would be interrupted; try again once it has had a moment.
	if UnitCastingInfo("player") or UnitChannelInfo("player") then
		StartOpenTick()
		return
	end
	if not IsSafeToOpen() or queueHead > queueTail then
		return
	end
	if IsWaitingOnPlayer() then
		StartOpenTick()
		return
	end
	-- The last open's loot may still be on its way; the next one waits for it or for its timeout.
	if pendingOpenItem and GetTime() - pendingOpenAt < ns.OPEN_ANSWER_TIMEOUT then
		StartOpenTick()
		return
	end
	CountRefusedOpen()

	local bagIndex, slotIndex, queuedIdentifier = QueuePop()

	-- The bags may have moved since the scan; only open what is still where it was.
	if ns.GetBagItemIdentifier(bagIndex, slotIndex) == queuedIdentifier and not refusedItems[queuedIdentifier] then
		pendingOpenItem, pendingOpenAt = queuedIdentifier, GetTime()
		C_Container.UseContainerItem(bagIndex, slotIndex)
		RecheckSlot(bagIndex, slotIndex, queuedIdentifier)
	end
	if queueHead <= queueTail then
		StartOpenTick()
	end
end

--------------------------------------------------------------------------------
-- Scan
--------------------------------------------------------------------------------

--[[
    RunScan and the debounce callback are file locals rather than closures built
    inside ScheduleOpeningScan: every bag or loot event would otherwise allocate
    two throwaway functions before deciding whether a scan is even needed.
]]
local function RunScan()
	scanPending = false
	if IsAutomatedOpeningOn() then
		local shouldPause = ns.CountFreeBagSlots() < ns.MIN_FREE_SLOTS
		if shouldPause ~= isPaused then
			isPaused = shouldPause
			if shouldPause then
				openTimerLive = false
			end
		end
		AnnounceStatus()
	end
	-- Nothing below runs while switched off or in combat: skip the bag walk and the tick.
	if not IsAutomatedOpeningOn() or UnitAffectingCombat("player") then
		return
	end
	BuildQueue()
	if IsSafeToOpen() and not openTimerLive and queueHead <= queueTail then
		StartOpenTick()
	end
end

local function OnScanDebounceElapsed()
	if GetTime() >= scanDueAt then
		RunScan()
	end
end

--[[
    An unforced call waits ns.SCAN_DEBOUNCE, and every request before it runs is
    absorbed into it, so a burst of bag events costs one scan. A forced call runs
    now: a setting change, the world load, combat ending, leaving stealth, a
    picked lock settling, a window closing.
]]
---@param force? boolean
---@return nil
function ns.ScheduleOpeningScan(force)
	if force then
		RunScan()
		return
	end
	local wantAt = GetTime() + ns.SCAN_DEBOUNCE
	if scanPending and wantAt >= scanDueAt then
		return
	end
	scanPending, scanDueAt = true, wantAt
	C_Timer.After(ns.SCAN_DEBOUNCE, OnScanDebounceElapsed)
end

--------------------------------------------------------------------------------
-- Event Responses
--------------------------------------------------------------------------------

local function OnWorldLoaded()
	if IsAutomatedOpeningOn() then
		isPaused = ns.CountFreeBagSlots() < ns.MIN_FREE_SLOTS
		announcedPaused = isPaused
		ns.ScheduleOpeningScan(true)
	end
end

--[[
    A login or reload waits ns.WORLD_LOAD_DELAY for the bags and the rest of the
    world to settle before the first scan. Any later loading screen is a zone
    change, which can lift the Where hold-off, so it rescans behind a short
    quiet window.
]]
local function OnPlayerEnteringWorld(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		C_Timer.After(ns.WORLD_LOAD_DELAY, OnWorldLoaded)
	else
		ns:SetQuiet(2)
		ns.ScheduleOpeningScan()
	end
end

local function OnCombatEnded()
	if IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan(true)
	end
end

local function OnStealthChanged()
	if UnitAffectingCombat("player") then
		return
	end
	if not IsPlayerStealthed() and IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan(true)
	end
end

--[[
    A lock just picked hasn't settled client-side the moment the cast lands, so
    the rescan waits ns.PICK_LOCK_RESCAN_DELAY. A closing trade runs it too, for
    boxes another rogue unlocked in the trade window: there is no event on our
    side for their cast.
]]
---@return nil
function ns.RescanAfterUnlock()
	C_Timer.After(ns.PICK_LOCK_RESCAN_DELAY, function()
		ns.ScheduleOpeningScan(true)
	end)
end

local function OnSpellcastSucceeded(unitIdentifier, _, spellIdentifier)
	-- WoW Forever can make the cast's spell secret, which can't be compared, so ask C_Secrets first.
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return
	end
	if unitIdentifier == "player" and spellIdentifier == ns.SPELLS.PICK_LOCK then
		ns.RescanAfterUnlock()
	end
end

-- Only a full-bag error raised by GogoLoot's own open in flight; every other one is the game's to report.
local function OnUiErrorMessage(errorIdentifier)
	if not IsAutomatedOpeningOn() or not ns.IsBagFullErrorID(errorIdentifier) then
		return
	end
	if not pendingOpenItem or GetTime() - pendingOpenAt >= ns.OPEN_ANSWER_TIMEOUT then
		return
	end
	local now = GetTime()
	if lastBagFullAt and (now - lastBagFullAt) <= ns.BAG_FULL_COOLDOWN then
		return
	end
	lastBagFullAt = now
	isPaused = true
	announcedPaused = true
	openTimerLive = false
	ns:StatusPrint(ERR_INV_FULL)
	PlayBagFullSound()
end

local function LockboxNotificationsEnabled()
	return ns.db.profile.lockboxNotifications and ns.LockboxScopeAllows(ns.db.profile.lockboxNotificationsScope)
end

--[[
    The notice for an ignored container, by the reason its default gives: a raid
    boss drop and one that may hold a unique item say so, and anything else,
    whether ignored by default or by the player, gets the plain notice.
]]
local IGNORED_NOTICES = {
	[ns.OPENING_IGNORE_RAID] = "MESSAGE_ITEM_IGNORED_RAID",
	[ns.OPENING_IGNORE_UNIQUE] = "MESSAGE_ITEM_IGNORED_UNIQUE",
}

--[[
    What the player is told about a container they just looted: a lockbox set to
    Open that will open itself once its lock is picked, or an item set to Ignore
    that Automated Opening will leave alone. The first promises automatic
    opening, so it needs Automated Opening on as well as its own toggle in the
    panel's Lockboxes section.
]]
local function AnnounceLootedContainer(itemIdentifier, itemLink)
	local action = ns:GetOpeningAction(itemIdentifier)
	local default = ns:GetOpeningDefault(itemIdentifier)
	if action == ns.OPENING_OPEN then
		if default == ns.OPENING_UNLOCKED and IsAutomatedOpeningOn() and LockboxNotificationsEnabled() then
			ns:PrintMessage(L["MESSAGE_ITEM_WILL_AUTO_OPEN"]:format(itemLink))
		end
	elseif action == ns.OPENING_IGNORE and ns.db.profile.openingIgnoreNotifications then
		ns:AnnounceItemOnce(IGNORED_NOTICES[default] or "MESSAGE_ITEM_IGNORED", itemIdentifier, itemLink)
	end
end

local function OnChatMessageLoot(message)
	local itemLink = ns.ParseOwnLootMessage(message)
	-- Only the player's own loot reaches their bags; a raid's loot lines would otherwise rescan on every pickup.
	if itemLink then
		AnnounceLootedContainer(tonumber(string.match(itemLink, "item:(%d+)")), itemLink)
		ns.ScheduleOpeningScan()
	end
end

local function OnScanRequest()
	ns.ScheduleOpeningScan()
end

-- Whether the player was in a group at the last roster update; nil before the first.
local wasGrouped = nil

-- The Group hold-off reads only whether the player is grouped, so a roster update rescans only when that changes.
local function OnGroupRosterUpdate()
	local isGrouped = IsInGroup()
	if isGrouped ~= wasGrouped then
		wasGrouped = isGrouped
		ns.ScheduleOpeningScan()
	end
end

local function OnInteractionClosed()
	ns.ScheduleOpeningScan(true)
	C_Timer.After(ns.STATUS_FLUSH_DELAY, AnnounceStatus)
end

local function OnTradeClosed()
	OnInteractionClosed()
	ns.RescanAfterUnlock()
end

-- A loot window answers the last open, so the game took it.
local function OnLootOpened()
	if pendingOpenItem then
		refusedOpenCounts[pendingOpenItem] = nil
		pendingOpenItem = nil
	end
end

-- A level-up can lift a level requirement, so every item set aside gets another try.
local function OnLevelUp()
	wipe(refusedItems)
	wipe(refusedOpenCounts)
	if IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan()
	end
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("PLAYER_REGEN_ENABLED", OnCombatEnded)
ns:RegisterModuleEvent("UPDATE_STEALTH", OnStealthChanged)
ns:RegisterModuleEvent("UNIT_SPELLCAST_SUCCEEDED", OnSpellcastSucceeded, "player")
ns:RegisterModuleEvent("UI_ERROR_MESSAGE", OnUiErrorMessage)
ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMessageLoot)
ns:RegisterModuleEvent("BAG_UPDATE_DELAYED", OnScanRequest)
ns:RegisterModuleEvent("BAG_NEW_ITEMS_UPDATED", OnScanRequest)
-- Joining or leaving a group can lift or bring the Group hold-off.
ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
ns:RegisterModuleEvent("BANKFRAME_CLOSED", OnInteractionClosed)
ns:RegisterModuleEvent("GOSSIP_CLOSED", OnInteractionClosed)
ns:RegisterModuleEvent("MAIL_CLOSED", OnInteractionClosed)
ns:RegisterModuleEvent("MERCHANT_CLOSED", OnInteractionClosed)
ns:RegisterModuleEvent("QUEST_FINISHED", OnInteractionClosed)
ns:RegisterModuleEvent("LOOT_CLOSED", OnInteractionClosed)
ns:RegisterModuleEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", OnInteractionClosed)
ns:RegisterModuleEvent("TRADE_CLOSED", OnTradeClosed)
ns:RegisterModuleEvent("LOOT_OPENED", OnLootOpened)
ns:RegisterModuleEvent("PLAYER_LEVEL_UP", OnLevelUp)
