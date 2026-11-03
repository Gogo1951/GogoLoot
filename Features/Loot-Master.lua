--------------------------------------------------------------------------------
-- GogoLoot Loot Master
--------------------------------------------------------------------------------

--[[
    What the Loot Master window shows and does, without the window: the Roll
    List, the Floor Loot list, what was handed out, Roll All, and filling the
    trade window for a winner.

    The Roll List fills itself with every Bind on Pickup item in the bags that
    can still be traded, each with its trade clock read off the item's tooltip
    (BIND_TRADE_TIME_REMAINING, so every locale works), and keyed by item GUID
    so an entry survives the item moving between bags. Floor Loot entries and
    a Master Looter's corpse items join it on the player's say-so.

    Everything is kept per character in ns.db.char, so a /reload mid-raid
    loses nothing but the rolls themselves.
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
-- Reading the Trade Clock
--------------------------------------------------------------------------------

--[[
    A duration format's plural forms spelled out: "%d |4hour:hrs;" becomes
    "%d hour" and "%d hrs". ruRU's three forms come out as three.
]]
---@param format string
---@return string[]
local function ExpandPluralForms(format)
	local before, forms, after = string.match(format, "^(.-)|4([^;]*);(.*)$")
	if not before then
		return { format }
	end
	local expanded = {}
	for form in string.gmatch(forms .. ":", "([^:]*):") do
		for _, rest in ipairs(ExpandPluralForms(after)) do
			expanded[#expanded + 1] = before .. form .. rest
		end
	end
	return expanded
end

-- Each unit's patterns with its length in seconds, longest form first so "hours" is tried before "hour".
local DURATION_UNITS = {}
for _, unit in ipairs({
	{ format = INT_SPELL_DURATION_HOURS, seconds = 3600 },
	{ format = INT_SPELL_DURATION_MIN, seconds = 60 },
	{ format = INT_SPELL_DURATION_SEC, seconds = 1 },
}) do
	if type(unit.format) == "string" then
		local patterns = {}
		for _, form in ipairs(ExpandPluralForms(unit.format)) do
			patterns[#patterns + 1] = (ns.BuildFormatPattern(form))
		end
		table.sort(patterns, function(a, b)
			return #a > #b
		end)
		DURATION_UNITS[#DURATION_UNITS + 1] = { patterns = patterns, seconds = unit.seconds }
	end
end

local tradeLinePattern = ns.BuildFormatPattern(BIND_TRADE_TIME_REMAINING)
if tradeLinePattern then
	tradeLinePattern = "^" .. tradeLinePattern .. "$"
end

--[[
    The seconds a tooltip line says an item can still be traded for, or nil
    for any other line. The tooltip counts in whole minutes, so this is right
    to within a minute.
]]
---@param line any
---@return number|nil
function ns.ParseTradeTimeLine(line)
	if not tradeLinePattern or type(line) ~= "string" then
		return nil
	end
	local duration = string.match(line, tradeLinePattern)
	if not duration then
		return nil
	end
	local seconds, matched = 0, false
	for _, unit in ipairs(DURATION_UNITS) do
		for _, pattern in ipairs(unit.patterns) do
			local amount = tonumber(string.match(duration, pattern))
			if amount then
				seconds = seconds + amount * unit.seconds
				matched = true
				break
			end
		end
	end
	return matched and seconds or nil
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

-- The Roll List as the window shows it: in the player's order, without what was taken off.
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

-- Seconds left on an entry's trade clock, or nil for an entry without one.
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

-- Takes an entry off the Roll List. A bag item stays hidden until it's added back, so a rescan doesn't return it.
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

-- Moves an entry one place up (-1) or down (1) among the shown ones.
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

--[[
    What was handed out, newest first: what it was, who got it, and the roll it
    was won with. An entry leaves the Roll List as it lands here.
]]
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

--[[
    The item's GUID, which follows it from bag to bag, or a key from where it
    sits on a client without one.
]]
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

--[[
    Every tradable Bind on Pickup item in the bags: key, link, bag, slot and
    seconds left, plus the keys of the bound ones whose clock ran out. Skips
    cheaply what can't be one (below ns.TRADABLE_MIN_QUALITY, or not Bind on
    Pickup) before reading a tooltip.
]]
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
				local seconds
				for _, line in ipairs(ns.GetBagItemTooltipLines(bagIndex, slotIndex)) do
					seconds = ns.ParseTradeTimeLine(line)
					if seconds then
						break
					end
				end
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

--[[
    Brings the Roll List in line with the bags: a new tradable item joins at
    the end, a clock that drifted is set again, an item whose clock ran out
    reads as Soulbound now, and one no longer carried leaves (a trade the Loot
    Master saw has already moved it to Awarded).
]]
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

--[[
    Once a second: the low-time warning, once per item, and an item whose
    clock runs out turning Soulbound now, without waiting for a bag event.
    The slow safety scan rides on it too.
]]
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

--[[
    A roll doesn't survive a /reload, so an entry saved mid-roll goes back to
    waiting rather than reading Rolling for good.
]]
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

--[[
    Roll All works down the Roll List in the player's order, one item at a
    time, waiting the panel's pause between items. Pause holds the roll in
    progress and stops the next from starting; Stop lets the roll in progress
    finish and starts nothing more.
]]
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
	--[[
	    A roll of the player's in progress decides it: Pause holds that roll,
	    Resume lets it go, and Roll All, while it runs, follows. With none,
	    Pause only holds Roll All between items.
	]]
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

--[[
    From the roll engine: a roll ended. Drops by boss takes any roll's winner;
    a roll of the player's also settles its Roll List entry and moves Roll All
    on.
]]
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

--[[
    Loot with no trade clock the player wants to roll off: mats, recipes, Bind
    on Equip gear. It starts empty and holds only what the player adds, by
    item ID; the count is what the bags hold now. Add from Bags lists what was
    picked up in the current instance first.
]]
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

-- The Roll List entry a Floor Loot item has while it waits or is rolled for, if any.
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

--[[
    What Add from Bags offers: every tradable item in the bags not already on
    the list, one row per item ID with what the bags hold, the ones picked up
    in this instance first, each half by name.
]]
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

--[[
    What the add box takes: an item ID, an item link, or part of a name, which
    matches the first tradable item in the bags carrying it.
]]
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

--[[
    Picked up in this instance: the player's own loot lines while inside one,
    forgotten when a different instance starts.
]]
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
    While the Master Looter has a loot window open, the items at or above the
    loot threshold that are still on the corpse join the Roll List tagged On
    Corpse, a moment after the window opens so Automated Master Looting's
    hand-outs have left first. The winner gets theirs straight from the corpse.
    They leave when the window closes, apart from one already won or being
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

-- Gives a won corpse item to its winner, while the loot window holds it.
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

--[[
    A trade opened with a winner gets what they won put in for them: the item
    itself for a bag entry, the stack's slots for Floor Loot, as far as the
    six slots go. The game won't let an add-on accept the trade, so the player
    still presses Trade.
]]
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
--[[
    The trade window shows an item a moment after it goes in, so the slots
    this fill has already used are remembered rather than read back.
]]
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

--[[
    From the trade announcer, once a trade completes: what the player gave and
    to whom. Every won entry of that winner whose item went over moves to
    Awarded.
]]
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

--[[
    Alt-Click on an item in the bags puts it on the Roll List: a tradable Bind
    on Pickup item taken off earlier comes back, and anything else that can be
    traded joins as one roll for everything of it the bags hold. Hooked after
    the game's own handling, which uses Shift and Ctrl, never Alt alone.
]]
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

--[[
    The bag tooltip of an item on the Roll List says where it came from and
    where it stands, under the game's own trade line.
]]
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
