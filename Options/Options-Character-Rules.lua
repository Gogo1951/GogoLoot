--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Character Rules
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Characters
--------------------------------------------------------------------------------

--[[
    Every character on the account with saved per-character data, plus the one
    being played, as AceDB's "Name - Realm" keys sorted as plain strings, for
    Character Rules' list. Characters live in AceDB's char sections, not in
    profiles: characters can share a profile, so profile names say nothing
    about who is on the account.
]]
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

--[[
    A character's saved section, made when first written: the one being played
    reads ns.db.char, which is the same table AceDB keeps under its key.
]]
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

--[[
    A character key in its class color: the class the character saved at its
    last login (Features/Core.lua), or the player's own. One that hasn't logged in since
    that was recorded keeps the tree's default color.
]]
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

-- A section's caption: the game's own label where this client has one, GogoLoot's words where it doesn't.
---@param group table # a ns.CHARACTER_RULE_GROUPS or ns.CHARACTER_RULE_GEAR_GROUPS row
---@return string
local function GroupCaption(group)
	local label = _G[group.labelGlobal]
	if type(label) == "string" and label ~= "" then
		return label
	end
	return L[group.caption]
end

--[[
    Two checkboxes to a line, each as wide as fits, so long type names
    ("Two-Handed Swords", "Zweihandschwerter") show whole. A full half of the
    row overflows the list's inset by a few pixels and drops to one column.
]]
local CHECKBOX_WIDTH = Kit.TREE_ROW_WIDTH * 0.44

--[[
    One character's rules: a checkbox list per section, then the Everything
    Else rows and Reset to Class Defaults. Each closes over its character's
    key, so the pane always edits the character the player picked, another
    character's included.
]]
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

	--[[
        A box saves only when it differs from the class's starter list, so
        ticking it back to the starter drops the saved choice.
    ]]
	local function SaveTicked(key, ticked, starter)
		if ticked == starter then
			Save("wanted", key, nil)
		else
			Save("wanted", key, ticked)
		end
	end

	--[[
        AceConfig sorts a list's boxes by key, so each box is keyed by its
        place ("01", "02", ...) and the list maps the place back to its row.
    ]]
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

	-- Whose rules these are, by class, named and colored by the game: "Class: Druid".
	local classFile = ClassFile()
	local className = classFile and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]
	if className then
		args.classLine =
			Kit.Header(L["CHARACTER_RULES_CLASS"]:format((ns.GetClassColor(classFile) or "") .. className .. "|r"), 0)
	end
	args.spacerAfterClassLine = Kit.Spacer(0.25)
	-- Automatically Greed on Low-Level Gear: Off, or Your Level - 1 to - 5; saved only once it differs from the default.
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

	--[[
        Armor Types lightest first, Weapon Types A to Z in the player's
        language, Other, then Primary Attributes in the character sheet's
        order and Secondary Attributes A to Z.
    ]]
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
			--[[
                The catch-all is one full-width toggle, since a box in a list
                truncates its name, and its tooltip says what lands there,
                which the name alone doesn't.
            ]]
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

	--[[
        Everything Else: what happens to gear that doesn't match. Each field
        saves only once it differs from ns.CHARACTER_RULE_UNWANTED_DEFAULTS.
    ]]
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

--[[
    Every character on the account down the left, as on MagicEraser's list
    panels: childGroups = "tree" splits the panel, and the picked character's
    rules fill the pane on the right. Registered as a builder function
    (Options.lua), so AceConfig rebuilds it on every open and a character
    logged in since shows up. The copy sits on the root group, which a tree
    draws once above the whole panel rather than in every pane.

    The panel answers to Automated Rolls' switch the way Item Overrides does:
    nothing hides, but a line says nothing here rolls while it's off.
]]
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

	--[[
        Keyed by character, not by position: the tree remembers the picked node
        by its key, so a key that shifted as characters came and went would
        quietly pick someone else.
    ]]
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
