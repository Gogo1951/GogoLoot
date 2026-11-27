--------------------------------------------------------------------------------
-- GogoLoot Character Rule Stats
--------------------------------------------------------------------------------

local _, ns = ...

-- So the panel, the stat reader and the roll check see one list; a rule saved for an unoffered stat is never read.
local function KeepOfferedStats()
	local offered, groupsInUse = {}, {}
	for _, statKey in ipairs(ns.CHARACTER_RULE_STAT_KEYS) do
		offered[statKey] = true
	end
	for index = #ns.CHARACTER_RULE_STATS, 1, -1 do
		local stat = ns.CHARACTER_RULE_STATS[index]
		if offered[stat.key] then
			groupsInUse[stat.group] = true
		else
			table.remove(ns.CHARACTER_RULE_STATS, index)
		end
	end
	for index = #ns.CHARACTER_RULE_GROUPS, 1, -1 do
		if not groupsInUse[ns.CHARACTER_RULE_GROUPS[index].key] then
			table.remove(ns.CHARACTER_RULE_GROUPS, index)
		end
	end
end
KeepOfferedStats()

---@param found table
---@param statKey string
---@param source string
---@return nil
local function AddStatSource(found, statKey, source)
	local sources = found[statKey]
	if not sources then
		sources = {}
		found[statKey] = sources
	end
	sources[#sources + 1] = source
end

---@param itemLink string
---@return number|nil
function ns.GetLinkRandomSuffix(itemLink)
	-- item:id:enchant:gem1:gem2:gem3:gem4:suffix
	local suffix = itemLink:match("item:%-?%d+:%-?%d*:%-?%d*:%-?%d*:%-?%d*:%-?%d*:(%-?%d+)")
	suffix = tonumber(suffix)
	if suffix == 0 then
		return nil
	end
	return suffix
end

--[[
    Built from the full ITEM_MOD_* formats the tooltip prints, never the _SHORT
    labels: several locales word the line apart from the label ("지능 +15").
]]
local statLinePatterns

---@param format string
---@return string
local function BuildStatLinePattern(format)
	local pattern = format:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	-- deDE on Classic Era and TBC numbers its arguments ("%1$c%2$d Stärke").
	pattern = pattern:gsub("%%%d+%%%$([csd])", "%%%1")
	-- Only a gain counts: gear that lowers a stat doesn't carry it, as GetItemStats' positive values agree.
	pattern = pattern:gsub("%%c", "%%+")
	pattern = pattern:gsub("%%[sd]", "%%d+")
	return "^%s*" .. pattern .. "%s*$"
end

---@return table[] # { { pattern = string, statKeys = { statKey, ... } }, ... }
local function StatLinePatterns()
	if statLinePatterns then
		return statLinePatterns
	end
	statLinePatterns = {}
	local entriesByFormat = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		for _, itemMod in ipairs(stat.itemMods) do
			local format = _G[(itemMod:gsub("_SHORT$", ""))]
			if type(format) == "string" and format ~= "" then
				local entry = entriesByFormat[format]
				if not entry then
					entry = { pattern = BuildStatLinePattern(format), statKeys = {} }
					entriesByFormat[format] = entry
					statLinePatterns[#statLinePatterns + 1] = entry
				end
				entry.statKeys[#entry.statKeys + 1] = stat.key
			end
		end
	end
	return statLinePatterns
end

--[[
    Classic Era, SoD and TBC carry secondary stats as "Equip:" item spells, which
    GetItemStats doesn't report. Each pattern is built from the spell's own
    description in the player's language, so no locale needs patterns of its
    own. An unloaded description is requested and built on a later read.
]]
local equipLinePatterns, equipLineEntries, equipSpellsRead = {}, {}, {}

local function EscapePattern(text)
	return (text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

---@param description string
---@return string
local function BuildEquipLinePattern(description)
	local trigger = type(ITEM_SPELL_TRIGGER_ONEQUIP) == "string" and ITEM_SPELL_TRIGGER_ONEQUIP or ""
	local body = description:match("^%s*(.-)%s*$"):gsub("%d+[%.,]?%d*", "\1")
	body = EscapePattern(body):gsub("\1", "[%%d%%.,]+")
	return "^%s*" .. EscapePattern(trigger) .. "%s*" .. body .. "%s*$"
end

local function EquipLinePatterns()
	local spells = ns.CHARACTER_RULE_EQUIP_SPELLS
	if type(C_Spell) ~= "table" or type(C_Spell.GetSpellDescription) ~= "function" then
		return equipLinePatterns
	end
	for spellIdentifier, statKeys in pairs(spells) do
		if not equipSpellsRead[spellIdentifier] then
			local description = C_Spell.GetSpellDescription(spellIdentifier)
			if type(description) == "string" and description:find("%S") then
				equipSpellsRead[spellIdentifier] = true
				local pattern = BuildEquipLinePattern(description)
				local entry = equipLineEntries[pattern]
				if not entry then
					entry = { pattern = pattern, statKeys = {} }
					equipLineEntries[pattern] = entry
					equipLinePatterns[#equipLinePatterns + 1] = entry
				end
				for _, statKey in ipairs(statKeys) do
					local listed = false
					for _, known in ipairs(entry.statKeys) do
						listed = listed or known == statKey
					end
					if not listed then
						entry.statKeys[#entry.statKeys + 1] = statKey
					end
				end
			elseif type(C_Spell.RequestLoadSpellData) == "function" then
				pcall(C_Spell.RequestLoadSpellData, spellIdentifier)
			end
		end
	end
	return equipLinePatterns
end

local function AddMatchingStats(text, patterns, found, source)
	for _, entry in ipairs(patterns) do
		if text:find(entry.pattern) then
			for _, statKey in ipairs(entry.statKeys) do
				AddStatSource(found, statKey, source)
			end
		end
	end
end

---@param itemLink string
---@param found table # { [statKey] = { source, ... } }, added to
---@return nil
local function AddTooltipStats(itemLink, found)
	local statPatterns, equipPatterns = StatLinePatterns(), EquipLinePatterns()
	for _, line in ipairs(ns.GetItemLinkTooltipLines(itemLink)) do
		local text = line:gsub("[\r\n]", " ")
		AddMatchingStats(text, statPatterns, found, "TOOLTIP")
		AddMatchingStats(text, equipPatterns, found, "EQUIP")
	end
end

--[[
    { [statKey] = { source, ... } }; sources are kept for Diagnostics. Three
    sources, because none sees every stat: GetItemStats (base item only on the
    Classic clients; WoW Forever also reads the random suffix), the tooltip's
    stat lines (random suffixes), and its Equip lines.
]]
---@param itemLink string
---@return table
function ns.ReadCharacterRuleStats(itemLink)
	local itemStats = ns.GetItemStats and ns.GetItemStats(itemLink)
	if type(itemStats) ~= "table" then
		itemStats = {}
	end

	local found = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		for _, itemMod in ipairs(stat.itemMods) do
			local value = itemStats[itemMod]
			if type(value) == "number" and value > 0 then
				AddStatSource(found, stat.key, "ITEM")
				break
			end
		end
	end
	AddTooltipStats(itemLink, found)
	return found
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnPlayerLogin()
	EquipLinePatterns() -- asks the client for every Equip spell's description, ahead of the first roll
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
