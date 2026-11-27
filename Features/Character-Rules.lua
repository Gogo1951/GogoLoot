--------------------------------------------------------------------------------
-- GogoLoot Character Rules
--------------------------------------------------------------------------------

local _, ns = ...

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

-- Saved keys: "ARMOR_4" plate, "WEAPON_15" daggers, "ARMOR_HELD", "OTHER_GEAR", "STAT_STRENGTH".
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

-- starterTable names a table on ns, keyed by class.
---@param starterTable string|nil
---@param classFile string|nil
---@param value number|string
---@return boolean
local function StarterHas(starterTable, classFile, value)
	local byClass = starterTable and ns[starterTable]
	return classFile ~= nil and type(byClass) == "table" and ListHas(byClass[classFile], value)
end

--[[
    An unlisted or unrecorded class starts with every box clear, except Other,
    ticked for everyone (maintainer, 2026-11-07): what the add-on can't name
    keeps its roll window until the player says otherwise.
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

-- Only a box that differs from the starter is saved, so an untouched character follows later starter changes.
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

-- Required level 0 counts as low-level; off (0) or an unreadable level never does.
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
    By class, subclass and slot, never localized type text. "TYPELESS" (cloak,
    ring, neck, trinket) leaves it to stats alone; nil means not judged. A held
    off-hand goes by its slot, since it shares armor subclass 0 with rings.
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
    Wanted: a ticked type (or typeless slot) carrying a ticked stat, or no stat
    read at all. The stat read scans a tooltip, so it runs only once the type
    passes. The row is returned for Diagnostics.
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
