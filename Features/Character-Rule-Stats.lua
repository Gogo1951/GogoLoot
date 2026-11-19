--------------------------------------------------------------------------------
-- GogoLoot Character Rule Stats
--------------------------------------------------------------------------------

--[[
    The stat reader Character Rules judges gear by (Features/Character-Rules.lua):
    which stats this client offers, and which of them an item carries, from
    GetItemStats and the tooltip's own stat and Equip lines.
]]
local _, ns = ...

--[[
    Only the stats this client's flavor folder offers
    (ns.CHARACTER_RULE_STAT_KEYS, Data/{Folder}/Character-Rule-Stats-{Folder}.lua),
    and only the sections left holding one, so the panel, the stat reader and
    the roll check all see the same list. A rule saved for a stat the client
    doesn't offer is simply never read.
]]
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

-- The random suffix id an item link carries, nil for none, for Diagnostics' Gear Stats report.
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
    One whole-line pattern per stat line the tooltip can print, to the rule
    keys it counts for. Built on first use from the FULL ITEM_MOD_* formats
    ("%c%s Stamina"), which are what the tooltip prints, never from the
    ITEM_MOD_*_SHORT labels the dropdowns are captioned with: several locales
    word the line apart from the label ("+15 p. de intelecto", "지능 +15").
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
    "Equip:" lines (Classic Era, Season of Discovery and TBC). There spell
    power, healing, attack power, crit, hit and mana per 5 are item spells,
    which GetItemStats doesn't report. Each flavor folder lists one spell for
    every way the game words such a line (ns.CHARACTER_RULE_EQUIP_SPELLS), and
    each line's pattern is built from that spell's own description, as the
    client words it in the player's language, numbers made wildcards, behind
    the game's ITEM_SPELL_TRIGGER_ONEQUIP. So no locale needs patterns of its
    own. A description that hasn't loaded yet is asked for and built on a
    later read; PLAYER_LOGIN asks for them all.
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
    Which of ns.CHARACTER_RULE_STATS an item carries, as { [statKey] =
    { source, ... } }, naming every source that saw the stat for Diagnostics'
    Gear Stats report. Three sources, because none sees every stat:
      * GetItemStats, for the item's own stats. On WoW Forever and later
        clients that includes spell power, attack power and crit. On WoW
        Forever it reads the random suffix in the link too: Lupine Cord of
        the Tiger reports the Strength and Agility its suffix rolled.
      * The tooltip's "+15 Intellect" lines, matched against the game's own
        stat-line formats, so in any language: a second look at the primary
        attributes, random suffix included, for a client whose GetItemStats
        sees only the base item. Play It Forward reads its stats the same way.
      * The tooltip's "Equip:" lines (EquipLinePatterns, above), for the
        secondary stats Classic Era, Season of Discovery and TBC carry as item
        spells.
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
