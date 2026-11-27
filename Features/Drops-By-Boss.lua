--------------------------------------------------------------------------------
-- GogoLoot Drops by Boss
--------------------------------------------------------------------------------

--[[
    What dropped in each raid, boss by boss. The first corpse looted within
    ns.BOSS_LOOT_WINDOW of ENCOUNTER_END is taken as the boss's; any other
    goes under Trash. Whoever opens the boss sends its drops to the group's
    other GogoLoot users, so a raider who never opens it still sees them.
]]
local _, ns = ...
local L = ns.L

local function Changed()
	if ns.RefreshLootWindows then
		ns.RefreshLootWindows()
	end
end

---@return number
local function Now()
	return GetServerTime and GetServerTime() or time()
end

-- The trash heading's own key, so a boss named the same in some language can't be mistaken for it.
local TRASH_KEY = "\1trash"

--------------------------------------------------------------------------------
-- Records
--------------------------------------------------------------------------------

---@return string|nil
local function CurrentInstanceName()
	local instanceName, instanceType = GetInstanceInfo()
	if instanceType == "raid" or instanceType == "party" then
		return instanceName
	end
	return nil
end

-- Re-entering the same instance within this carries on its record, so a wipe and run back don't split the night.
local SAME_VISIT_SECONDS = 12 * 3600

---@return table|nil
local function CurrentRaid()
	local instanceName = CurrentInstanceName()
	if not instanceName then
		return nil
	end
	local raids = ns.db.char.dropRaids
	local latest = raids[1]
	if latest and latest.name == instanceName and Now() - latest.startedAt < SAME_VISIT_SECONDS then
		return latest
	end
	table.insert(raids, 1, { name = instanceName, startedAt = Now(), bosses = {} })
	while #raids > ns.db.profile.dropsKeepRaids do
		table.remove(raids)
	end
	return raids[1]
end

---@param raid table
---@param bossKey string
---@return table
local function BossRecord(raid, bossKey)
	for _, boss in ipairs(raid.bosses) do
		if boss.key == bossKey then
			return boss
		end
	end
	local boss = { key = bossKey, name = bossKey ~= TRASH_KEY and bossKey or nil, at = Now(), items = {} }
	-- Trash stays last, under the bosses, whatever order they fell in.
	local position = #raid.bosses + 1
	if bossKey ~= TRASH_KEY then
		for index, existing in ipairs(raid.bosses) do
			if existing.key == TRASH_KEY then
				position = index
				break
			end
		end
	end
	table.insert(raid.bosses, position, boss)
	return boss
end

-- Once per corpse slot: a corpse reopened, or the same drop sent by two raiders, is the same drop.
---@param bossKey string
---@param sourceKey string
---@param itemLink string
---@param count number
---@return boolean
local function RecordDrop(bossKey, sourceKey, itemLink, count)
	local raid = CurrentRaid()
	if not raid then
		return false
	end
	local boss = BossRecord(raid, bossKey)
	for _, item in ipairs(boss.items) do
		if item.source == sourceKey then
			return false
		end
	end
	table.insert(boss.items, { link = itemLink, count = count, source = sourceKey })
	Changed()
	return true
end

--------------------------------------------------------------------------------
-- Watching the Raid
--------------------------------------------------------------------------------

-- The last kill: its name, when, and once a corpse is looted, which corpse was the boss.
local lastKill = nil

local function OnEncounterEnd(_, encounterName, _, _, success)
	if not ns.db or not ns.db.profile.lootMaster or success ~= 1 or not encounterName then
		return
	end
	lastKill = { name = encounterName, at = GetTime(), source = nil }
	local raid = CurrentRaid()
	if raid then
		BossRecord(raid, encounterName)
		Changed()
	end
end

local function OnLootOpened()
	if not ns.db or not ns.db.profile.lootMaster or not CurrentInstanceName() then
		return
	end
	for slotIndex = 1, GetNumLootItems() do
		local itemLink = GetLootSlotLink(slotIndex)
		local source = GetLootSourceInfo and GetLootSourceInfo(slotIndex)
		local quality = itemLink and ns.GetLinkQuality(itemLink)
		if itemLink and source and quality then
			local isBoss = lastKill
				and GetTime() - lastKill.at <= ns.BOSS_LOOT_WINDOW
				and (lastKill.source == nil or lastKill.source == source)
			if isBoss and quality >= ns.DROPS_BOSS_MIN_QUALITY then
				lastKill.source = source
				local _, _, count = GetLootSlotInfo(slotIndex)
				local sourceKey = source .. ":" .. slotIndex
				if RecordDrop(lastKill.name, sourceKey, itemLink, count or 1) then
					ns.BroadcastLootMessage("DROP", lastKill.name, sourceKey, count or 1, itemLink)
				end
			elseif not isBoss and quality >= ns.DROPS_TRASH_MIN_QUALITY then
				local _, _, count = GetLootSlotInfo(slotIndex)
				RecordDrop(TRASH_KEY, source .. ":" .. slotIndex, itemLink, count or 1)
			end
		end
	end
end

-- A drop another GogoLoot user recorded.
function ns.OnLootAddonMessage(kind, _, fields)
	if kind == "DROP" and ns.db and ns.db.profile.lootMaster then
		local bossName, sourceKey, count, itemLink = fields[1], fields[2], tonumber(fields[3]), fields[4]
		if bossName and sourceKey and itemLink then
			RecordDrop(bossName, sourceKey, itemLink, count or 1)
		end
	end
end

---@param itemLink string
---@return number|nil
local function ItemId(itemLink)
	return itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
end

-- The newest boss's matching drop with no winner yet; trash is never marked.
---@param itemLink string
---@param winnerName string
---@param value number|nil
---@return table|nil # the drop marked
local function MarkWinner(itemLink, winnerName, value)
	local raid = ns.db.char.dropRaids[1]
	local itemId = ItemId(itemLink)
	if not raid or not itemId then
		return nil
	end
	for bossIndex = #raid.bosses, 1, -1 do
		local boss = raid.bosses[bossIndex]
		if boss.key ~= TRASH_KEY then
			for _, item in ipairs(boss.items) do
				if not item.winner and ItemId(item.link) == itemId then
					item.winner, item.value = winnerName, value
					Changed()
					return item
				end
			end
		end
	end
end

--[[
    A roll can finish more than once (its own clock, then the caller's result,
    or a disqualification moving the win); the drop it marked first takes the
    latest result.
]]
function ns.OnDropRollFinished(session)
	local item = session.dropItem
	if item then
		item.winner = session.winner and session.winner.name
		item.value = session.winner and session.winner.value
		Changed()
	elseif session.winner then
		session.dropItem = MarkWinner(session.itemLink, session.winner.name, session.winner.value)
	end
end

-- Someone else's loot line: handed out without a roll here (master loot, or a roll not followed).
local function OnLootMessage(message)
	if not ns.db or not ns.db.profile.lootMaster or not CurrentInstanceName() then
		return
	end
	if ns.ParseOwnLootMessage(message) then
		return
	end
	local looterName, itemLink = ns.ParseGroupLootMessage(message)
	if looterName and itemLink then
		MarkWinner(itemLink, looterName, nil)
	end
end

ns:RegisterModuleEvent("ENCOUNTER_END", OnEncounterEnd)
ns:RegisterModuleEvent("LOOT_OPENED", OnLootOpened)
ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnLootMessage)

---@param itemLink string
---@return string|nil
function ns:GetDropBossForItem(itemLink)
	local raid = ns.db.char.dropRaids[1]
	local itemId = ItemId(itemLink)
	if not raid or not itemId then
		return nil
	end
	for bossIndex = #raid.bosses, 1, -1 do
		local boss = raid.bosses[bossIndex]
		for _, item in ipairs(boss.items) do
			if ItemId(item.link) == itemId then
				return boss.name
			end
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Reading It Back
--------------------------------------------------------------------------------

---@return table[]
function ns:GetDropRaids()
	return ns.db.char.dropRaids
end

---@param boss table
---@return string
function ns:GetDropBossName(boss)
	return boss.name or L["DROPS_TRASH"]
end

---@param item table
---@param withWinner boolean
---@param plain? boolean # no link or color, for the Copy box
---@return string
function ns:FormatDrop(item, withWinner, plain)
	local text = item.link
	if plain then
		text = string.match(item.link, "%[(.-)%]") or item.link
	end
	if item.count and item.count > 1 then
		text = L["ITEM_QUANTITY_LINK"]:format(text, item.count)
	end
	if withWinner and item.winner then
		local winner = plain and item.winner or ns:ColorRollName(item.winner)
		local who = item.value and L["DROPS_WINNER_ROLL"]:format(winner, item.value) or winner
		text = L["DROPS_WINNER"]:format(text, who)
	end
	return text
end

---@param raid table|nil
---@return nil
function ns:PrintDrops(raid)
	raid = raid or ns.db.char.dropRaids[1]
	if not raid or #raid.bosses == 0 then
		ns:PrintMessage(L["DROPS_NONE"])
		return
	end
	ns:PrintMessage(L["DROPS_PRINT_HEADER"]:format(raid.name))
	for _, boss in ipairs(raid.bosses) do
		local parts = {}
		for _, item in ipairs(boss.items) do
			parts[#parts + 1] = ns:FormatDrop(item, true)
		end
		if #parts > 0 then
			ns:PrintMessage(L["DROPS_PRINT_LINE"]:format(ns:GetDropBossName(boss), table.concat(parts, ", ")))
		end
	end
end

-- Names go out plain: chat colors them itself.
---@param raid table|nil
---@param withWinner boolean
---@return nil
function ns:PostDrops(raid, withWinner)
	raid = raid or ns.db.char.dropRaids[1]
	if not raid then
		return
	end
	for _, boss in ipairs(raid.bosses) do
		local parts = {}
		for _, item in ipairs(boss.items) do
			local text = item.count and item.count > 1 and L["ITEM_QUANTITY_LINK"]:format(item.link, item.count)
				or item.link
			if withWinner and item.winner then
				local who = item.value and L["DROPS_WINNER_ROLL"]:format(item.winner, item.value) or item.winner
				text = L["DROPS_WINNER"]:format(text, who)
			end
			parts[#parts + 1] = text
		end
		if #parts > 0 then
			local bossName = ns:GetDropBossName(boss)
			ns:SendRollParts(ns:GetRollResultChannel(), "DROPS_POST_LINE", parts, function(list)
				return bossName, list
			end)
		end
	end
end

-- For the Copy box and Discord.
---@param raid table|nil
---@param withWinner boolean
---@return string
function ns:GetDropsText(raid, withWinner)
	raid = raid or ns.db.char.dropRaids[1]
	if not raid then
		return ""
	end
	local lines = { raid.name }
	for _, boss in ipairs(raid.bosses) do
		local parts = {}
		for _, item in ipairs(boss.items) do
			parts[#parts + 1] = ns:FormatDrop(item, withWinner, true)
		end
		if #parts > 0 then
			lines[#lines + 1] = L["DROPS_PRINT_LINE"]:format(ns:GetDropBossName(boss), table.concat(parts, ", "))
		end
	end
	return table.concat(lines, "\n")
end
