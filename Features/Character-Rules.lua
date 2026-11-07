--------------------------------------------------------------------------------
-- GogoLoot Character Rules
--------------------------------------------------------------------------------

--[[
    What each character wants: the reader that finds an item's stats, the
    class starter lists, and the verdict Automated Rolls asks for before it
    rolls on gear.
]]
local _, ns = ...
local L = ns.L

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

--[[
    Only the armor and weapon sections this client's flavor folder lists rows
    for (Data/{Folder}/Character-Rule-Gear-Types-{Folder}.lua). A folder with
    no such file, such as the parked ones, offers neither.
]]
local function KeepOfferedGearGroups()
	for index = #ns.CHARACTER_RULE_GEAR_GROUPS, 1, -1 do
		local rows = ns[ns.CHARACTER_RULE_GEAR_GROUPS[index].types]
		if type(rows) ~= "table" or #rows == 0 then
			table.remove(ns.CHARACTER_RULE_GEAR_GROUPS, index)
		end
	end
end
KeepOfferedGearGroups()

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
	if type(spells) ~= "table" or type(C_Spell) ~= "table" or type(C_Spell.GetSpellDescription) ~= "function" then
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
-- What a Character Wants
--------------------------------------------------------------------------------

--[[
    One box's key in a character's saved choices: "ARMOR_4" is plate,
    "WEAPON_15" daggers, "ARMOR_HELD" held off-hands, "OTHER_GEAR" the
    catch-all, "STAT_STRENGTH" Strength. A row is an item subclass ID, or a
    name for a row no subclass names.
]]
---@param group table # a ns.CHARACTER_RULE_GEAR_GROUPS row
---@param row number|string
---@return string
function ns.CharacterRuleGearKey(group, row)
	return group.key .. "_" .. row
end

---@param statKey string
---@return string
function ns.CharacterRuleStatKey(statKey)
	return "STAT_" .. statKey
end

---@param list table|nil
---@param value number|string
---@return boolean
local function ListHas(list, value)
	for _, entry in ipairs(list or {}) do
		if entry == value then
			return true
		end
	end
	return false
end

-- Whether a class's starter list ticks a box: a table on ns named by `starterTable`, keyed by class.
---@param starterTable string|nil
---@param classFile string|nil
---@param value number|string
---@return boolean
local function StarterHas(starterTable, classFile, value)
	local byClass = starterTable and ns[starterTable]
	return classFile ~= nil and type(byClass) == "table" and ListHas(byClass[classFile], value)
end

--[[
    Whether a box starts ticked for a class. A class the folder doesn't list,
    or nil (a character that hasn't logged in since its class was recorded),
    starts with every box clear, but for Other, which starts ticked for
    everyone (maintainer, 2026-11-07): what the add-on can't name keeps its
    roll window until the player says otherwise.
]]
---@param classFile string|nil
---@param group table
---@param row number|string
---@return boolean
function ns.CharacterRuleGearStarter(classFile, group, row)
	if group.catchAll then
		return true
	end
	return StarterHas(group.starter, classFile, row)
end

---@param classFile string|nil
---@param statKey string
---@return boolean
function ns.CharacterRuleStatStarter(classFile, statKey)
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if stat.key == statKey and stat.everyClass then
			return true
		end
	end
	return StarterHas("CLASS_STAT_STARTER", classFile, statKey)
end

--[[
    Whether one box is ticked for a character: what it saved, or its class's
    starter list. Only a box that differs from the starter list is saved
    (rules.wanted[key] = true or false), so a character whose boxes were never
    touched saves nothing and follows any later change to the list.
]]
---@param rules table|nil # the character's characterRules
---@param key string
---@param starter boolean
---@return boolean
local function Ticked(rules, key, starter)
	local saved
	if rules and type(rules.wanted) == "table" then
		saved = rules.wanted[key]
	end
	if saved == nil then
		return starter
	end
	return saved == true
end

---@param rules table|nil
---@param classFile string|nil
---@param group table
---@param row number|string
---@return boolean
function ns.CharacterRuleWantsGear(rules, classFile, group, row)
	return Ticked(rules, ns.CharacterRuleGearKey(group, row), ns.CharacterRuleGearStarter(classFile, group, row))
end

---@param rules table|nil
---@param classFile string|nil
---@param statKey string
---@return boolean
function ns.CharacterRuleWantsStat(rules, classFile, statKey)
	return Ticked(rules, ns.CharacterRuleStatKey(statKey), ns.CharacterRuleStatStarter(classFile, statKey))
end

-- One Everything Else field for a character: what it saved, or ns.CHARACTER_RULE_UNWANTED_DEFAULTS.
---@param rules table|nil
---@param field string # "action", "threshold" or "lowLevelGear"
---@return any
function ns.CharacterRuleUnwanted(rules, field)
	local saved
	if rules and type(rules.unwanted) == "table" then
		saved = rules.unwanted[field]
	end
	if saved == nil then
		return ns.CHARACTER_RULE_UNWANTED_DEFAULTS[field]
	end
	return saved
end

--[[
    Whether an item is low-level gear for a character under Automatically
    Greed on Low-Level Gear: its required level is at least that many levels
    below the character's. Off (0), or a level or required level nobody can
    read, is never low-level.
]]
---@param rules table|nil
---@param requiredLevel number|nil
---@param level number|nil
---@return boolean
function ns.IsLowLevelGear(rules, requiredLevel, level)
	local levelsBelow = ns.CharacterRuleUnwanted(rules, "lowLevelGear")
	if type(levelsBelow) ~= "number" or levelsBelow <= 0 then
		return false
	end
	if type(requiredLevel) ~= "number" or type(level) ~= "number" then
		return false
	end
	return requiredLevel <= level - levelsBelow
end

--[[
    The row an armor or weapon item falls under: its item class, subclass and
    slot, never its localized type text. Returns "TYPELESS" for a cloak, ring,
    neck or trinket, which every class wears, so stats alone decide it, and
    nil for anything Character Rules doesn't judge (not gear, a shirt, a
    tabard). A held off-hand goes by its slot, since it shares armor subclass
    0 with rings. Anything else no row names falls to Other.
]]
---@param itemInformation table # ns:SafeGetItemInfo's
---@return table|string|nil group
---@return number|string|nil row
function ns.GetCharacterRuleGearRow(itemInformation)
	if not itemInformation then
		return nil
	end
	local classIdentifier = itemInformation.classId
	if classIdentifier ~= ns.ITEM_CLASS_ARMOR and classIdentifier ~= ns.ITEM_CLASS_WEAPON then
		return nil
	end
	local slot = itemInformation.equipLocation or ""
	if ns.CHARACTER_RULE_SKIPPED_SLOTS[slot] then
		return nil
	end
	if ns.CHARACTER_RULE_TYPELESS_SLOTS[slot] then
		return "TYPELESS"
	end

	local slotRow = ns.CHARACTER_RULE_GEAR_SLOT_ROWS[slot]
	local catchAll
	for _, group in ipairs(ns.CHARACTER_RULE_GEAR_GROUPS) do
		if group.catchAll then
			catchAll = group
		elseif classIdentifier == group.classIdentifier then
			local rows = ns[group.types]
			if slotRow and ListHas(rows, slotRow) then
				return group, slotRow
			end
			if ListHas(rows, itemInformation.subclassId) then
				return group, itemInformation.subclassId
			end
		end
	end
	if catchAll then
		return catchAll, ns[catchAll.types][1]
	end
	return nil
end

ns.CHARACTER_RULE_WANTED = "WANTED"
ns.CHARACTER_RULE_UNWANTED = "UNWANTED"

--[[
    What this character's rules say about an item: WANTED, UNWANTED, or nil
    for an item they don't judge (see ns.GetCharacterRuleGearRow). Wanted is a
    ticked type, or a typeless slot, that carries a ticked stat or no stat
    Character Rules reads at all. The stat read scans a tooltip, so it runs only once the
    type has passed. Also returns the gear row, for Diagnostics.
]]
---@param itemInformation table
---@param itemLink string
---@param rules table|nil
---@param classFile string|nil
---@return string|nil verdict
---@return table|string|nil group
---@return number|string|nil row
function ns.CharacterRuleVerdict(itemInformation, itemLink, rules, classFile)
	local group, row = ns.GetCharacterRuleGearRow(itemInformation)
	if not group then
		return nil
	end
	if group ~= "TYPELESS" and not ns.CharacterRuleWantsGear(rules, classFile, group, row) then
		return ns.CHARACTER_RULE_UNWANTED, group, row
	end

	local found = ns.ReadCharacterRuleStats(itemLink)
	local deciding = false
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if found[stat.key] then
			if ns.CharacterRuleWantsStat(rules, classFile, stat.key) then
				return ns.CHARACTER_RULE_WANTED, group, row
			end
			deciding = true
		end
	end
	return deciding and ns.CHARACTER_RULE_UNWANTED or ns.CHARACTER_RULE_WANTED, group, row
end

--------------------------------------------------------------------------------
-- Saved Rules From Before the Checkbox Lists
--------------------------------------------------------------------------------

--[[
    MIGRATION (remove after 2026-12-07): the per-stat and per-type dropdowns
    saved their picks straight into characterRules ("STRENGTH" = "manual",
    "ARMOR_4" = "greed"). The checkbox lists keep theirs under wanted and
    unwanted, and the old picks don't carry over (maintainer, 2026-11-07), so
    every character's old keys go and it starts on its class defaults.
]]
function ns.DropOldCharacterRules()
	for _, data in pairs((ns.db and ns.db.sv and ns.db.sv.char) or {}) do
		local rules = type(data) == "table" and data.characterRules
		if type(rules) == "table" then
			for key in pairs(rules) do
				if key ~= "wanted" and key ~= "unwanted" then
					rules[key] = nil
				end
			end
			--[[
                Include Bind on Pickup moved to the Automated Rolls panel, for
                every character at once, and the max-level box became
                Automatically Greed on Low-Level Gear.
            ]]
			if type(rules.unwanted) == "table" then
				rules.unwanted.bindOnPickup = nil
				rules.unwanted.greedBindOnEquipAtMaxLevel = nil
				if next(rules.unwanted) == nil then
					rules.unwanted = nil
				end
			end
			if next(rules) == nil then
				data.characterRules = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Automated Rolls On by Default
--------------------------------------------------------------------------------

--[[
    Automated Rolls ships on (maintainer, 2026-11-07), which reaches every
    player who never changed the switch, since AceDB saves only changes. So
    once per account, at a login where it's on, chat says so and where to turn
    it off.
]]
local function OnPlayerLogin()
	EquipLinePatterns() -- asks the client for every Equip spell's description, ahead of the first roll
	-- The level at this login, for another character's Sanity Check on the Character Rules panel.
	if ns.db then
		ns.db.char.level = UnitLevel("player")
	end
	if not ns.db or not ns.db.profile.autoGreed or ns.db.global.automatedRollsOnNoticeShown then
		return
	end
	ns.db.global.automatedRollsOnNoticeShown = true
	ns:PrintMessage(L["MESSAGE_AUTOMATED_ROLLS_ON"])
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
