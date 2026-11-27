--------------------------------------------------------------------------------
-- GogoLoot Automated Opening
--------------------------------------------------------------------------------

--[[
    Scan, queue, open: one container every ns.OPEN_TICK_INTERVAL while every
    safety gate holds. Auto Loot is enforced while this is on, since a container
    opened into a loot window nobody empties would stall the queue.
]]
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local isPaused = false
-- What the player was last told, so a held status line goes out once the window closes.
local announcedPaused = false
-- Only StartOpenTick sets it and only OpenTick clears it, so two chains never run.
local openTimerLive = false
local worldReady = false
local scanPending = false
local scanDueAt = 0
local toldFishingPoleHold = false

--[[
    Refused opens. Only a shrinking stack proves an open used the container: a
    loot session doesn't, since a refused loot (a unique item already carried)
    leaves the container in its slot and closes the window. After
    ns.OPEN_REFUSAL_LIMIT refusals in a row the item is left alone until the
    next level-up or login, rather than tried every tick into the same error.
]]
local pendingOpenItem, pendingOpenAt = nil, 0
-- { bagIndex, slotIndex, stackBefore }
local pendingOpenSlot
-- The open the loot window now up answered, until that window closes.
local answeredOpen
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
    WoW Forever makes aura reads secret during encounters and PvP matches, out
    of combat too, and a secret can't be compared: while Shadowmeld's aura would
    read secret it can't be ruled out, so it counts as present.
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
    Loot opened into any of these would get in the player's way; each one's
    closing event rescans. Each client has only its own auction frame:
    AuctionFrame on Era and TBC, AuctionHouseFrame on WoW Forever.
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

-- GetItemInfoInstant needs no cached item data, so a pole reads as one before its data loads.
---@return boolean
function ns.IsFishingPoleEquipped()
	local itemLink = GetInventoryItemLink("player", ns.INVENTORY_SLOT_MAIN_HAND)
	if not itemLink then
		return false
	end
	local _, _, _, _, _, classIdentifier, subclassIdentifier = C_Item.GetItemInfoInstant(itemLink)
	return classIdentifier == ns.ITEM_CLASS_WEAPON and subclassIdentifier == ns.ITEM_SUBCLASS_FISHING_POLE
end

local function IsHeldByFishingPole()
	return not ns.db.profile.autoOpenWithFishingPole and ns.IsFishingPoleEquipped()
end

-- No event reports the end of these, so the tick waits them out rather than stopping.
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
    Where and Group keep bag space free for drops; GROUP_ROSTER_UPDATE and a
    zone change rescan, so leaving either state resumes opening without a bag
    event. The mini-map menu reads this to say why opening is paused.
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
	-- A cast doesn't stop opening here: no event reports one ending, so OpenTick waits it out.

	return ns.CountFreeBagSlots() >= ns.MIN_FREE_SLOTS
end

--[[
    Pause and resume share ns.MIN_FREE_SLOTS, so the message names the count
    that resumes opening. It is held while an interaction window is open, or
    "Resumed" is lost in the player's vendoring; the window's close flushes it.
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

-- Flat (bag, slot, itemId) triples with head and tail cursors, so a scan allocates nothing per slot.
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
    Every Open item is lock-checked, lockbox or not, rather than tried every
    tick into "Item is locked". The flavor folder's level comes first so a cold
    cache doesn't hide it; an unlisted, uncached item reads no level, and a
    refusal then sets it aside.
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

---@param itemIdentifier number
local function CountRefusal(itemIdentifier)
	local count = (refusedOpenCounts[itemIdentifier] or 0) + 1
	refusedOpenCounts[itemIdentifier] = count
	if count >= ns.OPEN_REFUSAL_LIMIT then
		refusedItems[itemIdentifier] = true
	end
end

-- The pending open went unanswered past its timeout.
local function CountRefusedOpen()
	if not pendingOpenItem then
		return
	end
	CountRefusal(pendingOpenItem)
	pendingOpenItem, pendingOpenSlot = nil, nil
end

-- openedAt ties the answer to one open, so a late signal from an earlier open can't claim a newer one.
---@param itemIdentifier number
---@param openedAt number
local function ConfirmOpen(itemIdentifier, openedAt)
	refusedOpenCounts[itemIdentifier] = nil
	if pendingOpenItem == itemIdentifier and openedAt == pendingOpenAt then
		pendingOpenItem, pendingOpenSlot = nil, nil
	end
end

-- Ends the wait only (true if an open was pending); whether it used the container is settled once its window closes.
---@return boolean
local function AnswerOpen()
	if not pendingOpenItem then
		return false
	end
	answeredOpen = pendingOpenSlot
		and {
			itemIdentifier = pendingOpenItem,
			bagIndex = pendingOpenSlot.bagIndex,
			slotIndex = pendingOpenSlot.slotIndex,
			stackBefore = pendingOpenSlot.stackBefore,
		}
	pendingOpenItem, pendingOpenSlot = nil, nil
	return true
end

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
    Re-queues a stack or an open the server didn't take. A shrunk stack means
    the game took it, whatever the loot events did: a session Speedy Loot
    empties can close before LOOT_OPENED, or even LOOT_READY, reaches us.
]]
local function RecheckSlot(bagIndex, slotIndex, itemIdentifier, stackBefore, openedAt)
	C_Timer.After(ns.OPEN_RECHECK_DELAY, function()
		local stillThere = ns.GetBagItemIdentifier(bagIndex, slotIndex)
		local stackNow = stillThere == itemIdentifier and GetSlotStackCount(bagIndex, slotIndex) or 0
		if stackNow < stackBefore then
			ConfirmOpen(itemIdentifier, openedAt)
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
		pendingOpenSlot = { bagIndex = bagIndex, slotIndex = slotIndex, stackBefore = stackBefore }
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
    The hold-off is on by default, so the player is told once a session, the
    first time it holds something back; a line the quiet window drops is retried.
]]
local function AnnounceFishingPoleHold()
	if toldFishingPoleHold or queueHead > queueTail or not IsHeldByFishingPole() then
		return
	end
	if ns:StatusPrint(L["MESSAGE_OPENING_FISHING_POLE"]) then
		toldFishingPoleHold = true
	end
end

-- File locals, not closures in ScheduleOpeningScan, so a bag event allocates nothing.
local function RunScan()
	scanPending = false
	if IsAutomatedOpeningOn() then
		local shouldPause = ns.CountFreeBagSlots() < ns.MIN_FREE_SLOTS
		if shouldPause ~= isPaused then
			isPaused = shouldPause
		end
		AnnounceStatus()
	end
	if not IsAutomatedOpeningOn() or UnitAffectingCombat("player") then
		return
	end
	-- These holds rescan when they lift; the fishing-pole notice is owed only when something waits.
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

-- An unforced call debounces and absorbs later requests, so a burst of bag events costs one scan.
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

-- A login or reload lets the bags settle first; a later loading screen is a zone change, which can lift Where.
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
    A picked lock hasn't settled client-side when the cast lands. A closing
    trade runs this too, for boxes another rogue unlocked: their cast fires no
    event on our side.
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
	-- Opening always pauses; only the warning shares Speedy Loot's cooldown, so its warning can't keep opening running.
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

local lootWindowFromOpen = false

--[[
    Speedy Loot can close the session before LOOT_OPENED fires, so either event
    claims the open. LOOT_READY can fire more than once and LOOT_OPENED can
    follow it, so only a claim sets the flag, and only LOOT_CLOSED clears it.
]]
local function OnLootAnswer()
	if AnswerOpen() then
		lootWindowFromOpen = true
	end
end

-- The same container still at its old stack counts as a refusal, so one whose loot keeps being refused is set aside.
local function SettleAnsweredOpen()
	local open = answeredOpen
	answeredOpen = nil
	if not open then
		return
	end
	C_Timer.After(ns.OPEN_ANSWER_TIMEOUT, function()
		local stillThere = ns.GetBagItemIdentifier(open.bagIndex, open.slotIndex) == open.itemIdentifier
		if stillThere and GetSlotStackCount(open.bagIndex, open.slotIndex) >= open.stackBefore then
			CountRefusal(open.itemIdentifier)
		else
			refusedOpenCounts[open.itemIdentifier] = nil
		end
	end)
end

-- A corpse or chest window only debounces: its loot's bag events land in the same burst.
local function OnLootClosed()
	if lootWindowFromOpen then
		lootWindowFromOpen = false
		SettleAnsweredOpen()
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
