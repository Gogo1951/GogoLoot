--------------------------------------------------------------------------------
-- GogoLoot Loot Master
--------------------------------------------------------------------------------

--[[
    The Loot Master's state without its window. The Roll List fills itself
    with every still-tradable Bind on Pickup item in the bags, keyed by item
    GUID so an entry survives moving between bags. Kept in ns.db.char, so a
    /reload mid-raid loses only the rolls themselves.
]]
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Change Notification
--------------------------------------------------------------------------------

local function Changed()
	if ns.RefreshLootWindows then
		ns.RefreshLootWindows()
	end
end

--------------------------------------------------------------------------------
-- Entries
--------------------------------------------------------------------------------

---@return number
local function Now()
	return GetServerTime and GetServerTime() or time()
end

---@return table[]
local function Entries()
	return ns.db.char.rollList
end

---@param key string
---@return table|nil
function ns:GetRollListEntry(key)
	for _, entry in ipairs(Entries()) do
		if entry.key == key then
			return entry
		end
	end
	return nil
end

---@return table[]
function ns:GetRollListEntries()
	local shown = {}
	for _, entry in ipairs(Entries()) do
		if not entry.removed then
			shown[#shown + 1] = entry
		end
	end
	return shown
end

---@param entry table
---@return number|nil
function ns:GetEntrySecondsLeft(entry)
	if not entry.expiresAt then
		return nil
	end
	return math.max(0, entry.expiresAt - Now())
end

---@param entry table
---@return table|nil
function ns:GetEntryRoll(entry)
	local session = ns:GetRollSession(entry.sessionId)
	if session and session.entryKey == entry.key then
		return session
	end
	return nil
end

---@param fields table
---@return table
local function AddEntry(fields)
	fields.status = fields.status or ns.ENTRY_WAITING
	fields.addedAt = Now()
	table.insert(Entries(), fields)
	return fields
end

---@param entry table
---@return nil
local function DropEntry(entry)
	for index, kept in ipairs(Entries()) do
		if kept == entry then
			table.remove(Entries(), index)
			return
		end
	end
end

-- A bag item stays hidden until it's added back, so a rescan doesn't return it.
---@param entry table
---@return nil
function ns:RemoveRollListEntry(entry)
	if entry.source == ns.LOOT_SOURCE_BAGS then
		entry.removed = true
	else
		DropEntry(entry)
	end
	Changed()
end

-- -1 up, 1 down, skipping hidden entries.
---@param entry table
---@param direction number
---@return nil
function ns:MoveRollListEntry(entry, direction)
	local list = Entries()
	local from
	for index, kept in ipairs(list) do
		if kept == entry then
			from = index
			break
		end
	end
	if not from then
		return
	end
	local to = from + direction
	while list[to] and list[to].removed do
		to = to + direction
	end
	if not list[to] then
		return
	end
	list[from], list[to] = list[to], list[from]
	Changed()
end

---@param itemLink string
---@return number|nil
local function ItemIdFromLink(itemLink)
	return itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
end

---@param entry table
---@return string
function ns:GetEntryLinkText(entry)
	if entry.count and entry.count > 1 then
		return L["ITEM_QUANTITY_LINK"]:format(entry.link, entry.count)
	end
	return entry.link
end

--------------------------------------------------------------------------------
-- Awarded
--------------------------------------------------------------------------------

---@param entry table
---@return nil
local function Award(entry)
	table.insert(ns.db.char.awarded, 1, {
		link = entry.link,
		count = entry.count,
		winner = entry.winner,
		value = entry.winValue,
		at = Now(),
	})
	DropEntry(entry)
	Changed()
end

-- Mark Handed Out: a winner given their item some other way (the mail, a later trade the Loot Master missed).
---@param entry table
---@return nil
function ns:MarkEntryHandedOut(entry)
	Award(entry)
end

---@return table[]
function ns:GetAwarded()
	return ns.db.char.awarded
end

---@return nil
function ns:ClearAwarded()
	wipe(ns.db.char.awarded)
	Changed()
end

--------------------------------------------------------------------------------
-- Bag Scan
--------------------------------------------------------------------------------

-- The GUID follows the item between bags; the slot key is for a client without one.
---@param bagIndex number
---@param slotIndex number
---@param itemLink string
---@return string
local function BagItemKey(bagIndex, slotIndex, itemLink)
	if ItemLocation and C_Item.GetItemGUID then
		local location = ItemLocation:CreateFromBagAndSlot(bagIndex, slotIndex)
		local ok, guid = pcall(C_Item.GetItemGUID, location)
		if ok and guid then
			return "bag:" .. guid
		end
	end
	return "bag:" .. itemLink .. "@" .. bagIndex .. ":" .. slotIndex
end

-- Quality and bind type rule an item out before the costlier tooltip read.
---@return table[] tradable
---@return table bound # [key] = true
---@return boolean complete # false when an item's info wasn't loaded yet, so the bags couldn't all be read
local function ScanBags()
	local tradable, bound, complete = {}, {}, true
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
			local info = itemLink and ns:SafeGetItemInfo(itemLink)
			if itemLink and not info then
				complete = false
			end
			if info and (info.quality or 0) >= ns.TRADABLE_MIN_QUALITY and info.bindType == ns.BIND_ON_PICKUP then
				local key = BagItemKey(bagIndex, slotIndex, itemLink)
				local seconds = ns.GetBagSlotTradeSeconds(bagIndex, slotIndex)
				if seconds then
					tradable[#tradable + 1] =
						{ key = key, link = itemLink, bag = bagIndex, slot = slotIndex, seconds = seconds }
				else
					bound[key] = true
				end
			end
		end
	end
	return tradable, bound, complete
end

---@param key string
---@return number|nil bagIndex
---@return number|nil slotIndex
local function FindBagItem(key)
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
			if itemLink and BagItemKey(bagIndex, slotIndex, itemLink) == key then
				return bagIndex, slotIndex
			end
		end
	end
	return nil
end

-- An item no longer carried just leaves: a trade the Loot Master saw has already moved it to Awarded.
---@return nil
function ns:ScanTradableLoot()
	if not ns.db or not ns.db.profile.lootMaster then
		return
	end
	local tradable, bound, complete = ScanBags()
	local seen, added = {}, false
	for _, found in ipairs(tradable) do
		seen[found.key] = true
		local entry = ns:GetRollListEntry(found.key)
		local expiresAt = Now() + found.seconds
		if not entry then
			AddEntry({
				key = found.key,
				link = found.link,
				itemId = ItemIdFromLink(found.link),
				count = 1,
				source = ns.LOOT_SOURCE_BAGS,
				expiresAt = expiresAt,
				boss = ns.GetDropBossForItem and ns:GetDropBossForItem(found.link) or nil,
			})
			added = true
		elseif math.abs((entry.expiresAt or 0) - expiresAt) > ns.TRADE_RESYNC_SECONDS then
			entry.expiresAt = expiresAt
		end
	end
	local list = Entries()
	for index = #list, 1, -1 do
		local entry = list[index]
		-- An item whose info hadn't loaded can't be told from one that left, so nothing leaves on such a scan.
		if entry.source == ns.LOOT_SOURCE_BAGS and not seen[entry.key] and (complete or bound[entry.key]) then
			if bound[entry.key] then
				entry.status = entry.status == ns.ENTRY_ROLLING and entry.status or ns.ENTRY_EXPIRED
				entry.expiresAt = nil
			else
				table.remove(list, index)
			end
		end
	end
	if added and ns.db.profile.lootMasterOpenOnTradable and IsInGroup() and ns.ShowLootMaster then
		ns:ShowLootMaster()
	end
	Changed()
end

local function ScheduleScan()
	ns:After("lootMasterScan", ns.TRADE_SCAN_DEBOUNCE, function()
		ns:ScanTradableLoot()
		if ns.db.profile.floorLootDropWhenGone and ns.PruneFloorLoot then
			ns:PruneFloorLoot()
		end
	end)
end

--------------------------------------------------------------------------------
-- The Clock
--------------------------------------------------------------------------------

-- A clock running out fires no bag event, so the tick marks it; the slow safety scan rides on it too.
local secondsSinceScan = 0

local function OnClockTick()
	if not ns.db or not ns.db.profile.lootMaster then
		return
	end
	local profile = ns.db.profile
	local warnAt = profile.tradeWarnMinutes * 60
	for _, entry in ipairs(Entries()) do
		local left = ns:GetEntrySecondsLeft(entry)
		if left and not entry.removed then
			if profile.tradeWarnLow and left <= warnAt and left > 0 and not entry.warned then
				entry.warned = true
				ns:PrintMessage(L["LOOT_MASTER_TRADE_TIME_LOW"]:format(entry.link, math.ceil(left / 60)))
			end
			if left <= 0 and entry.status ~= ns.ENTRY_EXPIRED then
				entry.status = entry.status == ns.ENTRY_ROLLING and entry.status or ns.ENTRY_EXPIRED
				entry.expiresAt = nil
				ns:PrintMessage(L["LOOT_MASTER_TRADE_TIME_OVER"]:format(entry.link))
				Changed()
			end
		end
	end
	secondsSinceScan = secondsSinceScan + ns.WINDOW_TICK_SECONDS
	if secondsSinceScan >= ns.TRADE_SAFETY_SCAN then
		secondsSinceScan = 0
		ScheduleScan()
	end
end

-- A roll doesn't survive a /reload, so an entry saved mid-roll goes back to waiting.
local function OnPlayerLogin()
	for _, entry in ipairs(Entries()) do
		if entry.status == ns.ENTRY_ROLLING and not ns:GetRollSession(entry.sessionId) then
			entry.status = ns.ENTRY_WAITING
			entry.sessionId = nil
		end
	end
	C_Timer.NewTicker(ns.WINDOW_TICK_SECONDS, OnClockTick)
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
ns:RegisterModuleEvent("BAG_UPDATE_DELAYED", ScheduleScan)
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", ScheduleScan)

--------------------------------------------------------------------------------
-- Rolling an Entry
--------------------------------------------------------------------------------

---@param entry table
---@return boolean
function ns:CanRollEntry(entry)
	return not ns:IsOwnRollOpen() and entry.status ~= ns.ENTRY_EXPIRED and entry.status ~= ns.ENTRY_WON
end

---@param entry table
---@return table|nil
function ns:RollEntry(entry)
	if not ns:CanRollEntry(entry) then
		return nil
	end
	local session = ns:StartRoll(ns:GetEntryLinkText(entry), entry.key)
	if session then
		entry.sessionId = session.id
		entry.status = ns.ENTRY_ROLLING
		entry.winner, entry.winnerKey, entry.winValue = nil, nil, nil
		Changed()
	end
	return session
end

-- Roll All: Pause holds the roll in progress and the next; Stop lets it finish and starts nothing more.
ns.rollAll = { running = false, paused = false }

---@return table|nil
local function NextWaitingEntry()
	for _, entry in ipairs(ns:GetRollListEntries()) do
		if entry.status == ns.ENTRY_WAITING then
			return entry
		end
	end
	return nil
end

local function RollNext()
	local rollAll = ns.rollAll
	if not rollAll.running or rollAll.paused or ns:IsOwnRollOpen() then
		return
	end
	local entry = NextWaitingEntry()
	if not entry then
		rollAll.running = false
		ns:PrintMessage(L["LOOT_MASTER_ROLL_ALL_DONE"])
		Changed()
		return
	end
	ns:RollEntry(entry)
end

---@param seconds number
---@return nil
local function ScheduleNext(seconds)
	ns:After("lootMasterRollAll", seconds, RollNext)
end

---@return nil
function ns:StartRollAll()
	local waiting = {}
	for _, entry in ipairs(ns:GetRollListEntries()) do
		if entry.status == ns.ENTRY_WAITING then
			waiting[#waiting + 1] = ns:GetEntryLinkText(entry)
		end
	end
	if #waiting == 0 then
		return
	end
	ns.rollAll.running, ns.rollAll.paused = true, false
	ns:SendRollParts(ns:GetRollResultChannel(), "ROLL_CALL_ROLL_ALL", waiting, function(list)
		return list
	end)
	ScheduleNext(ns.ROLL_WARNING_SECONDS)
	Changed()
end

---@return nil
function ns:TogglePauseRollAll()
	local rollAll, session = ns.rollAll, ns.currentRoll
	-- With a roll of the player's open, Pause acts on it and Roll All follows; otherwise only between items.
	if session and session.open and session.isMine then
		if session.pausedLeft then
			ns:ResumeRoll(session)
			rollAll.paused = false
		else
			ns:PauseRoll(session)
			rollAll.paused = rollAll.running
		end
	elseif rollAll.running then
		rollAll.paused = not rollAll.paused
		ns:PrintMessage(rollAll.paused and L["LOOT_MASTER_ROLL_ALL_PAUSED"] or L["LOOT_MASTER_ROLL_ALL_RESUMED"])
		if not rollAll.paused then
			ScheduleNext(ns.db.profile.rollAllPause)
		end
	end
	Changed()
end

---@return nil
function ns:StopRollAll()
	ns.rollAll.running, ns.rollAll.paused = false, false
	ns:CancelTimer("lootMasterRollAll")
	local session = ns.currentRoll
	if session and session.open and session.isMine and session.pausedLeft then
		ns:ResumeRoll(session)
	end
	ns:PrintMessage(L["LOOT_MASTER_ROLL_ALL_STOPPED"])
	Changed()
end

-- Drops by Boss takes any roll's winner; only the player's own rolls settle an entry.
function ns.OnRollFinished(session)
	if not ns.db then
		return
	end
	if ns.OnDropRollFinished and not session.canceled then
		ns.OnDropRollFinished(session)
	end
	if not session.isMine then
		return
	end
	local entry = session.entryKey and ns:GetRollListEntry(session.entryKey)
	if entry then
		if session.canceled then
			entry.status = ns.ENTRY_WAITING
			entry.sessionId = nil
		else
			entry.status = session.status
			entry.sessionId = session.id
			entry.winner = session.winner and session.winner.name
			entry.winnerKey = session.winner and session.winner.key
			entry.winValue = session.winner and session.winner.value
		end
	end
	if ns.rollAll.running then
		if session.canceled then
			-- A roll canceled during Roll All would only be called again next, so Roll All waits for Resume.
			ns.rollAll.paused = true
		else
			ScheduleNext(ns.db.profile.rollAllPause)
		end
	end
end

-- A voided roll starts a new one for the same entry, which the entry follows.
function ns.OnRollStarted(session)
	if not session.isMine or not session.entryKey or not ns.db then
		return
	end
	local entry = ns:GetRollListEntry(session.entryKey)
	if entry then
		entry.sessionId = session.id
		entry.status = ns.ENTRY_ROLLING
	end
end

---@return nil
function ns:ListRollListInRaid()
	local parts = {}
	for _, entry in ipairs(ns:GetRollListEntries()) do
		if entry.status == ns.ENTRY_WAITING or entry.status == ns.ENTRY_NOBODY then
			parts[#parts + 1] = ns:GetEntryLinkText(entry)
		end
	end
	if #parts > 0 then
		ns:SendRollParts(ns:GetRollResultChannel(), "ROLL_CALL_UP_FOR_ROLL", parts, function(list)
			return list
		end)
	end
end

--------------------------------------------------------------------------------
-- Floor Loot
--------------------------------------------------------------------------------

-- Floor Loot: items with no trade clock, by item ID, only what the player adds; the count is read live.
---@return number[]
function ns:GetFloorLoot()
	return ns.db.char.floorLoot
end

---@param itemId number
---@return boolean
function ns:IsOnFloorLoot(itemId)
	for _, kept in ipairs(ns.db.char.floorLoot) do
		if kept == itemId then
			return true
		end
	end
	return false
end

---@param itemId number
---@return boolean
function ns:AddFloorLoot(itemId)
	if not itemId or ns:IsOnFloorLoot(itemId) then
		return false
	end
	table.insert(ns.db.char.floorLoot, itemId)
	Changed()
	return true
end

---@param itemId number
---@return nil
function ns:RemoveFloorLoot(itemId)
	local list = ns.db.char.floorLoot
	for index = #list, 1, -1 do
		if list[index] == itemId then
			table.remove(list, index)
		end
	end
	Changed()
end

---@return nil
function ns:PruneFloorLoot()
	local list = ns.db.char.floorLoot
	local pruned = false
	for index = #list, 1, -1 do
		if C_Item.GetItemCount(list[index]) == 0 then
			table.remove(list, index)
			pruned = true
		end
	end
	if pruned then
		Changed()
	end
end

---@param itemId number
---@return table|nil
function ns:GetFloorLootEntry(itemId)
	return ns:GetRollListEntry("floor:" .. itemId)
end

---@param itemId number
---@return table|nil
function ns:AddFloorLootToRollList(itemId)
	if ns:GetFloorLootEntry(itemId) then
		return nil
	end
	local count = C_Item.GetItemCount(itemId)
	local _, itemLink = C_Item.GetItemInfo(itemId)
	if not itemLink or count == 0 then
		return nil
	end
	local entry = AddEntry({
		key = "floor:" .. itemId,
		link = itemLink,
		itemId = itemId,
		count = count,
		source = ns.LOOT_SOURCE_FLOOR,
	})
	Changed()
	return entry
end

---@return number
function ns:AddAllFloorLootToRollList()
	local added = 0
	for _, itemId in ipairs(ns.db.char.floorLoot) do
		if ns:AddFloorLootToRollList(itemId) then
			added = added + 1
		end
	end
	if added > 0 then
		ns:PrintMessage(L["LOOT_MASTER_FLOOR_ADDED"]:format(added))
	end
	return added
end

---@return nil
function ns:ListFloorLootInRaid()
	local parts = {}
	for _, itemId in ipairs(ns.db.char.floorLoot) do
		local _, itemLink = C_Item.GetItemInfo(itemId)
		local count = C_Item.GetItemCount(itemId)
		if itemLink and count > 0 then
			parts[#parts + 1] = count > 1 and L["ITEM_QUANTITY_LINK"]:format(itemLink, count) or itemLink
		end
	end
	if #parts > 0 then
		ns:SendRollParts(ns:GetRollResultChannel(), "ROLL_CALL_FLOOR_LOOT", parts, function(list)
			return list
		end)
	end
end

---@return table[] # { itemId, link, count, pickedUp }
function ns:GetFloorLootChoices()
	local byItem, choices = {}, {}
	local pickedUp = ns.db.char.pickedUp
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
			local itemId = ItemIdFromLink(itemLink)
			if itemId and not byItem[itemId] and not ns:IsOnFloorLoot(itemId) then
				local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
				local itemInformation = ns:SafeGetItemInfo(itemLink)
				local isBound = info and info.isBound
				if isBound == nil then
					isBound = itemInformation and itemInformation.bindType == ns.BIND_ON_PICKUP
				end
				if not isBound and not ns:IsQuestClassItem(itemInformation) then
					byItem[itemId] = true
					choices[#choices + 1] = {
						itemId = itemId,
						link = itemLink,
						name = itemInformation and itemInformation.name or itemLink,
						count = C_Item.GetItemCount(itemId),
						pickedUp = pickedUp[itemId] == true,
					}
				end
			end
		end
	end
	table.sort(choices, function(a, b)
		if a.pickedUp ~= b.pickedUp then
			return a.pickedUp
		end
		return a.name < b.name
	end)
	return choices
end

-- An item ID, an item link, or part of a tradable bag item's name.
---@param text string
---@return number|nil
function ns:ResolveFloorLootInput(text)
	text = string.match(text or "", "^%s*(.-)%s*$")
	if text == "" then
		return nil
	end
	local fromLink = ItemIdFromLink(text)
	if fromLink then
		return fromLink
	end
	local asNumber = tonumber(text)
	if asNumber then
		return asNumber
	end
	local needle = string.lower(text)
	for _, choice in ipairs(ns:GetFloorLootChoices()) do
		if string.find(string.lower(choice.name), needle, 1, true) then
			return choice.itemId
		end
	end
	return nil
end

-- Picked up in this instance: forgotten when a different instance starts.
local function CurrentInstanceName()
	local instanceName, instanceType = GetInstanceInfo()
	if instanceType == "raid" or instanceType == "party" then
		return instanceName
	end
	return nil
end

local function OnLootMessage(message)
	if not ns.db or not ns.db.profile.lootMaster then
		return
	end
	local instanceName = CurrentInstanceName()
	if not instanceName then
		return
	end
	local itemLink = ns.ParseOwnLootMessage(message)
	local itemId = ItemIdFromLink(itemLink)
	if itemId then
		if ns.db.char.pickedUpInstance ~= instanceName then
			ns.db.char.pickedUpInstance = instanceName
			wipe(ns.db.char.pickedUp)
		end
		ns.db.char.pickedUp[itemId] = true
	end
end

ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnLootMessage)

-- Empty Floor Loot When I Leave the Raid.
local wasInRaid = false

local function OnRosterUpdate()
	if not ns.db then
		return
	end
	local inRaid = IsInRaid()
	if wasInRaid and not inRaid and ns.db.profile.floorLootClearOnLeave then
		wipe(ns.db.char.floorLoot)
		Changed()
	end
	wasInRaid = inRaid
end

ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", OnRosterUpdate)

--------------------------------------------------------------------------------
-- Master Looter: Items Still on the Corpse
--------------------------------------------------------------------------------

--[[
    Added a moment after the loot window opens, so Automated Master Looting's
    hand-outs have left first. On close they leave, except one won or being
    rolled for, which waits for the window to open again.
]]
local function CorpseKey(itemLink, slotIndex)
	return "corpse:" .. itemLink .. "@" .. slotIndex
end

local function AddCorpseItems()
	if not ns.db.profile.lootMaster or not ns:AreWeMasterLooter() then
		return
	end
	local threshold = (ns.GetLootThreshold and ns.GetLootThreshold()) or 2
	for slotIndex = 1, GetNumLootItems() do
		local itemLink = GetLootSlotLink(slotIndex)
		local quality = itemLink and ns.GetLinkQuality(itemLink)
		if itemLink and quality and quality >= threshold then
			local key = CorpseKey(itemLink, slotIndex)
			local entry = ns:GetRollListEntry(key)
			if entry then
				entry.lootSlot = slotIndex
				entry.onCorpse = true
			else
				AddEntry({
					key = key,
					link = itemLink,
					itemId = ItemIdFromLink(itemLink),
					count = 1,
					source = ns.LOOT_SOURCE_CORPSE,
					lootSlot = slotIndex,
					onCorpse = true,
					boss = ns.GetDropBossForItem and ns:GetDropBossForItem(itemLink) or nil,
				})
			end
		end
	end
	Changed()
end

local function OnLootOpened()
	ns:After("lootMasterCorpse", ns.TRADE_FILL_DELAY * 2, AddCorpseItems)
end

local function OnLootClosed()
	ns:CancelTimer("lootMasterCorpse")
	local list = Entries()
	for index = #list, 1, -1 do
		local entry = list[index]
		if entry.source == ns.LOOT_SOURCE_CORPSE then
			entry.onCorpse = false
			if entry.status == ns.ENTRY_WAITING or entry.status == ns.ENTRY_NOBODY then
				table.remove(list, index)
			end
		end
	end
	Changed()
end

-- A corpse slot emptied: a won item given to its winner goes to Awarded, anything else just leaves.
local function OnLootSlotCleared(slotIndex)
	for _, entry in ipairs(Entries()) do
		if entry.source == ns.LOOT_SOURCE_CORPSE and entry.onCorpse and entry.lootSlot == slotIndex then
			if entry.status == ns.ENTRY_WON and entry.givenTo then
				Award(entry)
			elseif entry.status ~= ns.ENTRY_ROLLING then
				DropEntry(entry)
				Changed()
			end
			return
		end
	end
end

ns:RegisterModuleEvent("LOOT_OPENED", OnLootOpened)
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)
ns:RegisterModuleEvent("LOOT_SLOT_CLEARED", OnLootSlotCleared)

---@param entry table
---@return boolean
function ns:GiveCorpseEntry(entry)
	if not entry.onCorpse or not entry.lootSlot or not entry.winnerKey then
		return false
	end
	for candidateIndex = 1, 40 do
		local candidate = GetMasterLootCandidate(entry.lootSlot, candidateIndex)
		if candidate and ns:NormalizePlayerName(candidate) == entry.winnerKey then
			entry.givenTo = entry.winner
			GiveMasterLoot(entry.lootSlot, candidateIndex)
			return true
		end
	end
	ns:PrintMessage(L["LOOT_MASTER_NOT_A_CANDIDATE"]:format(ns:ColorRollName(entry.winner), entry.link))
	return false
end

--------------------------------------------------------------------------------
-- Trading a Winner
--------------------------------------------------------------------------------

-- The game won't let an add-on accept a trade, so the player still presses Trade.
---@param partnerKey string
---@return table[]
local function EntriesWonBy(partnerKey)
	local won = {}
	for _, entry in ipairs(ns:GetRollListEntries()) do
		if entry.status == ns.ENTRY_WON and entry.winnerKey == partnerKey and entry.source ~= ns.LOOT_SOURCE_CORPSE then
			won[#won + 1] = entry
		end
	end
	return won
end

---@return number|nil
-- The trade window shows an item a moment after it goes in, so used slots are remembered, not read back.
local claimedTradeSlots = {}

---@return number|nil
local function FreeTradeSlot()
	for tradeSlot = 1, ns.TRADE_ITEM_SLOT_COUNT do
		if not claimedTradeSlots[tradeSlot] and not GetTradePlayerItemLink(tradeSlot) then
			return tradeSlot
		end
	end
	return nil
end

---@param bagIndex number
---@param slotIndex number
---@return boolean
local function PutInTrade(bagIndex, slotIndex)
	local tradeSlot = FreeTradeSlot()
	if not tradeSlot or CursorHasItem() then
		return false
	end
	claimedTradeSlots[tradeSlot] = true
	C_Container.PickupContainerItem(bagIndex, slotIndex)
	ClickTradeButton(tradeSlot)
	return true
end

---@param entry table
---@return boolean
local function PutEntryInTrade(entry)
	if entry.source == ns.LOOT_SOURCE_BAGS then
		local bagIndex, slotIndex = FindBagItem(entry.key)
		return bagIndex ~= nil and PutInTrade(bagIndex, slotIndex)
	end
	local placed = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			if placed < entry.count and C_Container.GetContainerItemID(bagIndex, slotIndex) == entry.itemId then
				local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
				if not PutInTrade(bagIndex, slotIndex) then
					return placed > 0
				end
				placed = placed + (info and info.stackCount or 1)
			end
		end
	end
	return placed > 0
end

local function FillTradeWindow()
	if not ns.db.profile.lootMaster or not ns.db.profile.tradeAutoFill then
		return
	end
	local partnerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("npc"))
	if not partnerKey then
		return
	end
	wipe(claimedTradeSlots)
	for _, entry in ipairs(EntriesWonBy(partnerKey)) do
		if PutEntryInTrade(entry) then
			ns:PrintMessage(
				L["LOOT_MASTER_TRADE_FILLED"]:format(
					ns:GetEntryLinkText(entry),
					ns:ColorRollName(entry.winner),
					entry.winValue or 0
				)
			)
		end
	end
end

local function OnTradeShow()
	ns:After("lootMasterTradeFill", ns.TRADE_FILL_DELAY, FillTradeWindow)
end

ns:RegisterModuleEvent("TRADE_SHOW", OnTradeShow)

-- Called by the trade announcer once a trade completes.
---@param partnerName string|nil
---@param givenItems table # [tradeSlot] = { link, count }
---@return nil
function ns.OnLootMasterTradeCompleted(partnerName, givenItems)
	local partnerKey = ns:NormalizePlayerName(partnerName)
	if not partnerKey or not ns.db then
		return
	end
	local givenIds = {}
	for _, given in pairs(givenItems) do
		local itemId = ItemIdFromLink(given.link)
		if itemId then
			givenIds[itemId] = true
		end
	end
	for _, entry in ipairs(EntriesWonBy(partnerKey)) do
		if givenIds[entry.itemId] then
			Award(entry)
		end
	end
end

--------------------------------------------------------------------------------
-- Alt-Click and the Bag Tooltip
--------------------------------------------------------------------------------

-- Alt-Click: hooked after the game's own handling, which uses Shift and Ctrl, never Alt alone.
---@param itemLink string
---@return nil
function ns:AddItemToRollList(itemLink)
	local itemId = ItemIdFromLink(itemLink)
	if not itemId then
		return
	end
	for _, entry in ipairs(Entries()) do
		if entry.source == ns.LOOT_SOURCE_BAGS and entry.itemId == itemId and entry.removed then
			entry.removed = nil
			ns:PrintMessage(L["LOOT_MASTER_ADDED"]:format(entry.link))
			Changed()
			return
		end
	end
	if ns:GetRollListEntry("floor:" .. itemId) then
		return
	end
	for _, choice in ipairs(ns:GetFloorLootChoices()) do
		if choice.itemId == itemId then
			local entry = ns:AddFloorLootToRollList(itemId)
			if entry then
				ns:PrintMessage(L["LOOT_MASTER_ADDED"]:format(ns:GetEntryLinkText(entry)))
			end
			return
		end
	end
	ns:PrintMessage(L["LOOT_MASTER_NOT_TRADABLE"]:format(itemLink))
end

if HandleModifiedItemClick then
	hooksecurefunc("HandleModifiedItemClick", function(itemLink)
		if
			ns.db
			and ns.db.profile.lootMaster
			and IsAltKeyDown()
			and not IsShiftKeyDown()
			and not IsControlKeyDown()
			and type(itemLink) == "string"
			and string.find(itemLink, "|Hitem:", 1, true)
			-- Only an item the player carries: an Alt-Click on a chat link or the character pane isn't one.
			and C_Item.GetItemCount(tonumber(string.match(itemLink, "item:(%d+)")) or 0) > 0
		then
			ns:AddItemToRollList(itemLink)
			if ns.ShowLootMaster then
				ns:ShowLootMaster()
			end
		end
	end)
end

---@param tooltip table
---@param bagIndex number
---@param slotIndex number
---@return nil
local function AddBagTooltipLines(tooltip, bagIndex, slotIndex)
	if not ns.db or not ns.db.profile.lootMaster then
		return
	end
	local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
	if not itemLink then
		return
	end
	local entry = ns:GetRollListEntry(BagItemKey(bagIndex, slotIndex, itemLink))
	if not entry or entry.removed then
		return
	end
	tooltip:AddLine(" ")
	ns:AddTooltipLine(tooltip, L["ADDON_TITLE"], "TITLE")
	if entry.boss then
		ns:AddTooltipLine(tooltip, L["LOOT_MASTER_LOOTED_FROM"]:format(entry.boss), "HELP", true)
	end
	if entry.status == ns.ENTRY_WON and entry.winner then
		ns:AddTooltipLine(
			tooltip,
			L["LOOT_MASTER_TOOLTIP_WON_BY"]:format(entry.winner, entry.winValue or 0),
			"HELP",
			true
		)
	else
		ns:AddTooltipLine(tooltip, L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"], "HELP", true)
	end
	tooltip:Show()
end

hooksecurefunc(GameTooltip, "SetBagItem", AddBagTooltipLines)
