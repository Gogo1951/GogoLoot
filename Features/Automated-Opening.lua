--------------------------------------------------------------------------------
-- GogoLoot Automated Opening
--------------------------------------------------------------------------------

--[[
    Opens clams, containers and unlocked lockboxes in the bags, one every
    ns.OPEN_TICK_INTERVAL, whenever it is safe to. Which items it opens, and
    whether one waits for its lock, is Features/Openable-Items.lua's answer;
    what the player is told about a container they loot is
    Features/Opening-Notices.lua's.

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
-- True while a tick is scheduled; only StartOpenTick sets it and only OpenTick clears it, so two chains never run.
local openTimerLive = false
-- False until ns.WORLD_LOAD_DELAY has passed after a login or reload: no scan runs before it.
local worldReady = false
local scanPending = false
local scanDueAt = 0
-- True once the player has been told, this session, that a fishing pole is holding opening back.
local toldFishingPoleHold = false

--[[
    Opens the game refused. An open the game takes answers with a loot session
    (LOOT_READY or LOOT_OPENED) or, failing that, leaves fewer of the item in
    its slot, so one still unanswered ns.OPEN_ANSWER_TIMEOUT later was refused:
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
		or ns.IsLootWindowShown()
		or false
end

--[[
    A fishing pole in the main hand. GetItemInfoInstant answers from the
    client's own database, so a pole equipped before its item data loads still
    reads as one.
]]
---@return boolean
function ns.IsFishingPoleEquipped()
	local itemLink = GetInventoryItemLink("player", ns.INVENTORY_SLOT_MAIN_HAND)
	if not itemLink then
		return false
	end
	local _, _, _, _, _, classIdentifier, subclassIdentifier = C_Item.GetItemInfoInstant(itemLink)
	return classIdentifier == ns.ITEM_CLASS_WEAPON and subclassIdentifier == ns.ITEM_SUBCLASS_FISHING_POLE
end

-- The Fishing Pole hold-off: on unless the player chose to keep opening while they fish.
local function IsHeldByFishingPole()
	return not ns.db.profile.autoOpenWithFishingPole and ns.IsFishingPoleEquipped()
end

--[[
    The player is busy with something no event reports the end of: an item
    under the cursor or held on it, a spell waiting for its target, or an open
    confirmation pop-up. The tick waits these out itself rather than stopping,
    since nothing would start it again.
]]
local function IsWaitingOnPlayer()
	if StaticPopup1 and StaticPopup1:IsShown() then
		return true
	end
	-- A held spell would land on the container, and a held item would be dropped into its slot.
	if SpellIsTargeting() or CursorHasItem() then
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

--[[
    What is holding Automated Opening back, if anything: "BAGS" while it waits
    for free bag slots, then the player's own hold-offs. Where and Group keep bag
    space free for drops while in an instance or a group, and the containers open
    once the player is back on their own time; GROUP_ROSTER_UPDATE and a zone
    change both rescan, so leaving either state resumes opening without waiting
    on a bag event. Opening a clam mid-cast would break the fishing rhythm, and
    swapping the pole off rescans. The mini-map menu reads this to say Paused and
    why (Features/Minimap-Menu.lua).
]]
---@return string|nil # "BAGS", "FISHING", "INSTANCE", "GROUP", or nil
function ns:GetAutomatedOpeningHold()
	if isPaused then
		return "BAGS"
	end
	if IsHeldByFishingPole() then
		return "FISHING"
	end
	if ns.db.profile.autoOpenWhere == "OUTSIDE_INSTANCES" and IsInInstance() then
		return "INSTANCE"
	end
	if ns.db.profile.autoOpenGroup == "SOLO_ONLY" and IsInGroup() then
		return "GROUP"
	end
	return nil
end

local function IsSafeToOpen()
	if not IsAutomatedOpeningOn() or ns:GetAutomatedOpeningHold() then
		return false
	end

	if UnitAffectingCombat("player") or IsInteractionActive() or IsPlayerStealthed() then
		return false
	end
	-- A cast that would read secret (WoW Forever) can't be ruled out, so opening waits for the next scan.
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return false
	end
	--[[
        A cast doesn't stop opening here: no event reports an ordinary cast
        ending or being interrupted, so the tick starts anyway and waits the
        cast out itself (OpenTick).
    ]]

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
	local told
	if isPaused then
		told = ns:StatusPrint(L["MESSAGE_OPENING_PAUSED"]:format(ns.MIN_FREE_SLOTS))
	else
		told = ns:StatusPrint(L["MESSAGE_OPENING_RESUMED"])
	end
	-- A line the quiet window held back is still owed, and goes out on a later scan.
	if told then
		announcedPaused = isPaused
	end
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
    same way. The level comes from the flavor folder (ns.OPENABLE_ITEM_LEVELS),
    so a cold cache doesn't hide it; an item the folder doesn't list asks the
    item cache, and one not yet cached there reads no level, and a refusal
    then sets it aside.
]]
---@param bagIndex number
---@param slotIndex number
---@param itemIdentifier number
---@return boolean
local function ShouldOpen(bagIndex, slotIndex, itemIdentifier)
	if ns:GetOpeningAction(itemIdentifier) ~= ns.OPENING_OPEN or refusedItems[itemIdentifier] then
		return false
	end
	local requiredLevel = ns.OPENABLE_ITEM_LEVELS[itemIdentifier] or select(5, C_Item.GetItemInfo(itemIdentifier))
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

--[[
    The game took the open, so its item's refusal streak ends. openedAt, when
    given, ties the answer to one open: a late signal from an earlier open of
    the same item can't claim a newer one.
]]
local function ConfirmOpen(openedAt)
	if not pendingOpenItem or (openedAt and openedAt ~= pendingOpenAt) then
		return false
	end
	refusedOpenCounts[pendingOpenItem] = nil
	pendingOpenItem = nil
	return true
end

-- How many of the item the slot holds; 0 for an empty slot.
local function GetSlotStackCount(bagIndex, slotIndex)
	local itemInfo = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
	return itemInfo and itemInfo.stackCount or 0
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

    Fewer of the item in the slot than before the open means the game took it,
    whatever the loot events did: a loot session Speedy Loot empties can close
    before LOOT_OPENED, or even LOOT_READY, reaches the add-on.
]]
local function RecheckSlot(bagIndex, slotIndex, itemIdentifier, stackBefore, openedAt)
	C_Timer.After(ns.OPEN_RECHECK_DELAY, function()
		local stillThere = ns.GetBagItemIdentifier(bagIndex, slotIndex)
		local stackNow = stillThere == itemIdentifier and GetSlotStackCount(bagIndex, slotIndex) or 0
		if stackNow < stackBefore and pendingOpenItem == itemIdentifier then
			ConfirmOpen(openedAt)
		end
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
		local stackBefore = GetSlotStackCount(bagIndex, slotIndex)
		pendingOpenItem, pendingOpenAt = queuedIdentifier, GetTime()
		C_Container.UseContainerItem(bagIndex, slotIndex)
		RecheckSlot(bagIndex, slotIndex, queuedIdentifier, stackBefore, pendingOpenAt)
	end
	if queueHead <= queueTail then
		StartOpenTick()
	end
end

--------------------------------------------------------------------------------
-- Scan
--------------------------------------------------------------------------------

--[[
    The Fishing Pole hold-off is on by default, so every player with With
    Fishing Pole Equipped off is told once a session, the first time it actually
    holds something back, where to turn it off. A line the quiet window drops is retried on a later scan.
]]
local function AnnounceFishingPoleHold()
	if toldFishingPoleHold or queueHead > queueTail or not IsHeldByFishingPole() then
		return
	end
	if ns:StatusPrint(L["MESSAGE_OPENING_FISHING_POLE"]) then
		toldFishingPoleHold = true
	end
end

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
		end
		AnnounceStatus()
	end
	-- Nothing below runs while switched off or in combat: skip the bag walk and the tick.
	if not IsAutomatedOpeningOn() or UnitAffectingCombat("player") then
		return
	end
	--[[
        Nor under a hold that rescans when it lifts: the free-slot recount at the
        top of every scan, the zone change's rescan, and the roster change's.
        The fishing-pole hold still builds the queue, since its notice is only
        owed when something is waiting.
    ]]
	local hold = ns:GetAutomatedOpeningHold()
	if hold == "BAGS" or hold == "INSTANCE" or hold == "GROUP" then
		return
	end
	BuildQueue()
	if IsSafeToOpen() and not openTimerLive and queueHead <= queueTail then
		StartOpenTick()
	end
	AnnounceFishingPoleHold()
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
	if not worldReady then
		return
	end
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
	worldReady = true
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
		-- No quiet window of its own: Announcements.lua keeps one around every loading screen.
		ns.ScheduleOpeningScan()
	end
end

local function OnPlayerRegenEnabled()
	if IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan(true)
	end
end

local function OnUpdateStealth()
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
	--[[
	    Opening always pauses. Only the warning answers to the cooldown, which
	    Speedy Loot's refused-pickup warning shares (ns.ClaimBagFullWarning), so
	    a warning it just gave can't keep opening running into full bags.
	]]
	isPaused = true
	announcedPaused = true
	if ns.ClaimBagFullWarning() then
		ns:StatusPrint(ERR_INV_FULL)
		ns.PlayBagFullSound()
	end
end

local function OnChatMessageLoot(message)
	-- Only the player's own loot reaches their bags; a raid's loot lines would otherwise rescan on every pickup.
	if ns.ParseOwnLootMessage(message) then
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

-- Whether the loot window now open answers one of GogoLoot's own opens.
local lootWindowFromOpen = false

--[[
    A loot session answers the last open, so the game took it. Speedy Loot
    empties the window on LOOT_READY, and the session can close before
    LOOT_OPENED ever fires, so either event claims the open. Only a pending
    open is claimed, and only a claim sets the flag: LOOT_READY can fire more
    than once per session, and LOOT_OPENED can still follow it, so a later
    event must not clear what the first one set. LOOT_CLOSED clears it.
]]
local function OnLootAnswer()
	if ConfirmOpen() then
		lootWindowFromOpen = true
	end
end

--[[
    Closing the window an open brought up rescans at once, so the next
    container follows without a pause. A corpse or chest window only schedules
    the debounced scan: its loot's bag events land in the same burst.
]]
local function OnLootClosed()
	if lootWindowFromOpen then
		lootWindowFromOpen = false
		OnInteractionClosed()
		return
	end
	ns.ScheduleOpeningScan()
	C_Timer.After(ns.STATUS_FLUSH_DELAY, AnnounceStatus)
end

-- Taking the pole off lifts the Fishing Pole hold-off, and equipping one brings it.
local function OnPlayerEquipmentChanged(slot)
	if slot == ns.INVENTORY_SLOT_MAIN_HAND and IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan()
	end
end

-- A level-up can lift a level requirement, so every item set aside gets another try.
local function OnPlayerLevelUp()
	wipe(refusedItems)
	wipe(refusedOpenCounts)
	if IsAutomatedOpeningOn() then
		ns.ScheduleOpeningScan()
	end
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)
ns:RegisterModuleEvent("UPDATE_STEALTH", OnUpdateStealth)
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
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)
ns:RegisterModuleEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", OnInteractionClosed)
ns:RegisterModuleEvent("TRADE_CLOSED", OnTradeClosed)
ns:RegisterModuleEvent("LOOT_READY", OnLootAnswer)
ns:RegisterModuleEvent("LOOT_OPENED", OnLootAnswer)
ns:RegisterModuleEvent("PLAYER_LEVEL_UP", OnPlayerLevelUp)
ns:RegisterModuleEvent("PLAYER_EQUIPMENT_CHANGED", OnPlayerEquipmentChanged)
