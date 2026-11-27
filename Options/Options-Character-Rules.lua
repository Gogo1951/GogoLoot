--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Character Rules
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Characters
--------------------------------------------------------------------------------

-- Read from AceDB's char sections, not profiles: characters share a profile, so profile names say nothing about who exists.
---@return string[]
local function GetCharacterKeys()
	local keys, seen = {}, {}
	local current = ns.db and ns.db.keys and ns.db.keys.char
	if current then
		keys[1] = current
		seen[current] = true
	end
	for characterKey in pairs((ns.db and ns.db.sv and ns.db.sv.char) or {}) do
		if not seen[characterKey] then
			seen[characterKey] = true
			keys[#keys + 1] = characterKey
		end
	end
	table.sort(keys)
	return keys
end

---@param characterKey string
---@return table
local function GetCharacterData(characterKey)
	if characterKey == ns.db.keys.char then
		return ns.db.char
	end
	local characters = ns.db.sv.char
	if not characters then
		characters = {}
		ns.db.sv.char = characters
	end
	characters[characterKey] = characters[characterKey] or {}
	return characters[characterKey]
end

-- The class saved at the character's last login; nil for one not logged in since that was recorded.
---@param characterKey string
---@return string|nil
local function GetCharacterClassFile(characterKey)
	if characterKey == ns.db.keys.char then
		local _, playerClassFile = UnitClass("player")
		return playerClassFile
	end
	local characters = ns.db.sv.char
	local data = characters and characters[characterKey]
	return type(data) == "table" and data.classFile or nil
end

---@param characterKey string
---@return string
local function GetCharacterDisplayName(characterKey)
	local classColor = ns.GetClassColor(GetCharacterClassFile(characterKey))
	if classColor then
		return classColor .. characterKey .. "|r"
	end
	return characterKey
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@param group table # a ns.CHARACTER_RULE_GROUPS or ns.CHARACTER_RULE_GEAR_GROUPS row
---@return string
local function GroupCaption(group)
	local label = _G[group.labelGlobal]
	if type(label) == "string" and label ~= "" then
		return label
	end
	return L[group.caption]
end

-- Two to a line, as wide as fits for long type names; a full half overflows the list's inset and drops to one column.
local CHECKBOX_WIDTH = Kit.TREE_ROW_WIDTH * 0.44

---@param characterKey string
---@return table
local function BuildCharacterArgs(characterKey)
	local function Rules()
		return GetCharacterData(characterKey).characterRules
	end

	local function ClassFile()
		return GetCharacterClassFile(characterKey)
	end

	-- Drops empty tables as it goes, so a character back on its class defaults saves nothing.
	local function Save(section, field, value)
		local data = GetCharacterData(characterKey)
		data.characterRules = data.characterRules or {}
		data.characterRules[section] = data.characterRules[section] or {}
		data.characterRules[section][field] = value
		if next(data.characterRules[section]) == nil then
			data.characterRules[section] = nil
		end
		if next(data.characterRules) == nil then
			data.characterRules = nil
		end
	end

	-- Saved only where it differs from the class's starter list.
	local function SaveTicked(key, ticked, starter)
		if ticked == starter then
			Save("wanted", key, nil)
		else
			Save("wanted", key, ticked)
		end
	end

	-- AceConfig sorts a list's boxes by key, so each is keyed by its place ("01", "02", ...).
	local function CheckboxList(order, entries, IsTicked, SetTicked)
		local values, byPlace = {}, {}
		for index, entry in ipairs(entries) do
			local place = string.format("%02d", index)
			values[place] = entry.label
			byPlace[place] = entry
		end
		return {
			type = "multiselect",
			name = "",
			order = order,
			width = CHECKBOX_WIDTH,
			values = values,
			get = function(_, place)
				return IsTicked(byPlace[place])
			end,
			set = function(_, place, ticked)
				SetTicked(byPlace[place], ticked)
				ns.RefreshSettings()
			end,
		}
	end

	local args = {}
	local order = 1

	local classFile = ClassFile()
	local className = classFile and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]
	if className then
		args.classLine =
			Kit.Header(L["CHARACTER_RULES_CLASS"]:format((ns.GetClassColor(classFile) or "") .. className .. "|r"), 0)
	end
	args.spacerAfterClassLine = Kit.Spacer(0.25)
	args.lowLevelGear = Kit.Row(0.5, nil, {
		Kit.Label(L["CHARACTER_RULES_LOW_LEVEL"], 0, Kit.TREE_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			desc = L["CHARACTER_RULES_LOW_LEVEL_DESCRIPTION"],
			style = "dropdown",
			width = Kit.CONTROL_WIDTH,
			values = ns.CHARACTER_RULE_LOW_LEVEL_LABELS,
			sorting = ns.CHARACTER_RULE_LOW_LEVEL_ORDER,
			get = function()
				return ns.CharacterRuleUnwanted(Rules(), "lowLevelGear")
			end,
			set = function(_, value)
				if value == ns.CHARACTER_RULE_UNWANTED_DEFAULTS.lowLevelGear then
					value = nil
				end
				Save("unwanted", "lowLevelGear", value)
				ns.RefreshSettings()
			end,
		},
	})
	local function AddHeader(key, caption)
		args["spacerBefore" .. key] = Kit.Spacer(order)
		args["header" .. key] = Kit.Header(caption, order + 1)
		order = order + 2
	end

	for _, group in ipairs(ns.CHARACTER_RULE_GEAR_GROUPS) do
		local rows = {}
		for _, rowIdentifier in ipairs(ns[group.types]) do
			rows[#rows + 1] = {
				identifier = rowIdentifier,
				label = ns.CHARACTER_RULE_GEAR_ROW_LABELS[rowIdentifier]
					or C_Item.GetItemSubClassInfo(group.classIdentifier, rowIdentifier)
					or tostring(rowIdentifier),
			}
		end
		if group.sortByLabel then
			table.sort(rows, function(left, right)
				return left.label < right.label
			end)
		end
		local function IsTicked(row)
			return ns.CharacterRuleWantsGear(Rules(), ClassFile(), group, row.identifier)
		end
		local function SetTicked(row, ticked)
			SaveTicked(
				ns.CharacterRuleGearKey(group, row.identifier),
				ticked,
				ns.CharacterRuleGearStarter(ClassFile(), group, row.identifier)
			)
		end
		AddHeader(group.key, GroupCaption(group))
		if group.catchAll then
			-- A full-width toggle: a box in a list truncates its name, and the tooltip says what lands there.
			local row = rows[1]
			args["toggle" .. group.key] = {
				type = "toggle",
				name = row.label,
				desc = L["CHARACTER_RULES_OTHER_GEAR_NOTE"],
				width = "full",
				order = order,
				get = function()
					return IsTicked(row)
				end,
				set = function(_, ticked)
					SetTicked(row, ticked)
					ns.RefreshSettings()
				end,
			}
			order = order + 1
		else
			args["list" .. group.key] = CheckboxList(order, rows, IsTicked, SetTicked)
			order = order + 1
		end
	end

	for _, group in ipairs(ns.CHARACTER_RULE_GROUPS) do
		local stats = {}
		for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
			if stat.group == group.key then
				stats[#stats + 1] = stat
			end
		end
		if group.sortByLabel then
			table.sort(stats, function(left, right)
				return tostring(left.label) < tostring(right.label)
			end)
		end
		AddHeader(group.key, GroupCaption(group))
		args["list" .. group.key] = CheckboxList(order, stats, function(stat)
			return ns.CharacterRuleWantsStat(Rules(), ClassFile(), stat.key)
		end, function(stat, ticked)
			SaveTicked(ns.CharacterRuleStatKey(stat.key), ticked, ns.CharacterRuleStatStarter(ClassFile(), stat.key))
		end)
		order = order + 1
	end

	local function UnwantedGet(field)
		return function()
			return ns.CharacterRuleUnwanted(Rules(), field)
		end
	end
	local function UnwantedSet(field)
		return function(_, value)
			if value == ns.CHARACTER_RULE_UNWANTED_DEFAULTS[field] then
				value = nil
			end
			Save("unwanted", field, value)
			ns.RefreshSettings()
		end
	end

	AddHeader("UNWANTED", L["CHARACTER_RULES_EVERYTHING_ELSE"])
	args.unwantedAction = Kit.Row(order, nil, {
		Kit.Label(
			L["CHARACTER_RULES_UNWANTED_ACTION"],
			0,
			Kit.TREE_LABEL_WIDTH,
			L["CHARACTER_RULES_UNWANTED_ACTION_DESCRIPTION"]
		),
		{
			type = "select",
			name = "",
			desc = L["CHARACTER_RULES_UNWANTED_ACTION_DESCRIPTION"],
			style = "dropdown",
			width = Kit.CONTROL_WIDTH,
			values = ns.CHARACTER_RULE_UNWANTED_LABELS,
			sorting = ns.CHARACTER_RULE_UNWANTED_ORDER,
			get = UnwantedGet("action"),
			set = UnwantedSet("action"),
		},
	})
	args.spacerBeforeReset = Kit.Spacer(order + 1)
	-- Asks nothing (README-Notes): every box it puts back is one click to tick again.
	args.reset = Kit.ResetRow(
		order + 2,
		nil,
		L["CHARACTER_RULES_RESET"],
		L["CHARACTER_RULES_RESET_DESCRIPTION"],
		function()
			return GetCharacterData(characterKey).characterRules == nil
		end,
		function()
			GetCharacterData(characterKey).characterRules = nil
		end
	)
	-- A tree pane is narrower than a panel: the caption gives up the difference, so the button keeps the column.
	args.reset.args.cell1.width = Kit.TREE_LABEL_WIDTH

	return args
end

-- The copy sits on the root group, which a tree draws once above the whole panel rather than in every pane.
---@return table
function ns.BuildCharacterRulesOptions()
	local args = {
		description = Kit.Desc(
			L["CHARACTER_RULES_PANEL_INTRO"]:format(
				ITEM_MOD_STRENGTH_SHORT,
				LOCALIZED_CLASS_NAMES_MALE.WARRIOR,
				ITEM_MOD_STRENGTH_SHORT
			),
			1
		),
		spacerAfterDesc = Kit.Spacer(2),
	}
	ns.AddFeatureOffLine(args, 3, "autoGreed")

	-- Keyed by character, not position: the tree remembers the picked node by key.
	if ns.db then
		for index, characterKey in ipairs(GetCharacterKeys()) do
			args[characterKey] = {
				type = "group",
				name = GetCharacterDisplayName(characterKey),
				order = 10 + index,
				args = BuildCharacterArgs(characterKey),
			}
		end
	end

	return {
		type = "group",
		name = L["TAB_CHARACTER_RULES"],
		childGroups = "tree",
		args = args,
	}
end
