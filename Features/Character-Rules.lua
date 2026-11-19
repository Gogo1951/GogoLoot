--------------------------------------------------------------------------------
-- GogoLoot Character Rules
--------------------------------------------------------------------------------

--[[
    What each character wants: the class starter lists, and the verdict
    Automated Rolls asks for before it rolls on gear. The stat reader it judges
    by is Features/Character-Rule-Stats.lua.
]]
local _, ns = ...

--[[
    Only the armor and weapon sections this client's flavor folder lists rows
    for (Data/{Folder}/Character-Rule-Gear-Types-{Folder}.lua). A folder whose
    tables are empty offers neither.
]]
local function KeepOfferedGearGroups()
	for index = #ns.CHARACTER_RULE_GEAR_GROUPS, 1, -1 do
		local rows = ns[ns.CHARACTER_RULE_GEAR_GROUPS[index].types]
		if #rows == 0 then
			table.remove(ns.CHARACTER_RULE_GEAR_GROUPS, index)
		end
	end
end
KeepOfferedGearGroups()

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
---@param field string # "action" or "lowLevelGear"
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
    below the character's. Gear with no level requirement (0) counts as
    low-level. Off (0), or a level or required level nobody can read, is never
    low-level.
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
    Character Rules reads at all. The stat read scans a tooltip, so it runs
    only once the type has passed. Also returns the gear row, for Diagnostics.
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
			if next(rules) == nil then
				data.characterRules = nil
			end
		end
	end
end

--[[
    MIGRATION (remove after 2026-12-16): Include Bind on Pickup moved to the
    Automated Rolls panel, for every character at once, and the max-level box
    became Automatically Greed on Low-Level Gear. Everything Else's own Up to
    Quality went too: it fought the In Party and In Raid quality, which now
    caps Character Rules as well (maintainer, 2026-11-15). Every character's
    retired keys go.
]]
function ns.DropRetiredCharacterRuleKeys()
	for _, data in pairs((ns.db and ns.db.sv and ns.db.sv.char) or {}) do
		local rules = type(data) == "table" and data.characterRules
		if type(rules) == "table" and type(rules.unwanted) == "table" then
			rules.unwanted.bindOnPickup = nil
			rules.unwanted.greedBindOnEquipAtMaxLevel = nil
			rules.unwanted.threshold = nil
			if next(rules.unwanted) == nil then
				rules.unwanted = nil
			end
			if next(rules) == nil then
				data.characterRules = nil
			end
		end
	end
end
