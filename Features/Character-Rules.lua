--------------------------------------------------------------------------------
-- GogoLoot Character Rules
--------------------------------------------------------------------------------

--[[
    Which stats each character leaves to the player: the reader that finds an
    item's stats, and the check Automated Rolls asks before it rolls.
]]
local _, ns = ...

--[[
    Which of ns.CHARACTER_RULE_STATS an item carries, as { [statKey] =
    { source, ... } }, naming every source that saw the stat for Diagnostics'
    Gear Stats report. Two sources, because neither sees every stat:
      * GetItemStats, for the item's own stats. On WoW Forever and later
        clients that includes spell power, attack power and crit. It reads
        the base item only, never the random suffix in the link.
      * The tooltip's "+15 Intellect" lines, matched against the game's own
        stat-line formats, so in any language: what a random suffix such as
        "of the Owl" rolled. Play It Forward reads its stats the same way.
    Classic Era and TBC offer only the primary attributes (Data/Data.lua),
    since their secondary stats are "Equip:" spells neither source reads.
]]
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

---@param itemLink string
---@param found table # { [statKey] = { source, ... } }, added to
---@return nil
local function AddTooltipStats(itemLink, found)
	local patterns = StatLinePatterns()
	for _, line in ipairs(ns.GetItemLinkTooltipLines(itemLink)) do
		local text = line:gsub("[\r\n]", " ")
		for _, entry in ipairs(patterns) do
			if text:find(entry.pattern) then
				for _, statKey in ipairs(entry.statKeys) do
					AddStatSource(found, statKey, "TOOLTIP")
				end
			end
		end
	end
end

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

--[[
    Whether this character's rules leave an item to the player: one of the
    item's stats is set to Manual. Standard Automated Roll saves no rule, so
    a character without a Manual stat never pays for the stat read.
]]
---@param itemLink string
---@return boolean
function ns.CharacterRulesLeaveToPlayer(itemLink)
	local rules = ns.db.char.characterRules
	if not rules or next(rules) == nil then
		return false
	end

	local itemStats = ns.ReadCharacterRuleStats(itemLink)
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if itemStats[stat.key] and rules[stat.key] == ns.MANUAL then
			return true
		end
	end
	return false
end
