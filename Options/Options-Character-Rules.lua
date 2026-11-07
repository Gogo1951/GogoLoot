--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Character Rules
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

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

local function AutomatedRollsOn()
	return ns.db.profile.autoGreed
end

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

--------------------------------------------------------------------------------
-- Sanity Check
--------------------------------------------------------------------------------

--[[
    The Sanity Check's items, watched for this panel (Options-Utilities-Item-
    Cache.lua), so a link still loading when the panel opens fills in on its
    own.
]]
local sampleItems = {}

local function WatchSampleItems()
	local outstanding = false
	for _, itemIdentifier in ipairs(ns.CHARACTER_RULE_SAMPLE_ITEMS or {}) do
		sampleItems[itemIdentifier] = true
		if ns.IsItemOutstanding(itemIdentifier) then
			outstanding = true
		end
	end
	ns.WatchItemList(ns.OPTIONS_REGISTRY.CharacterRules, function()
		return sampleItems
	end)
	if outstanding then
		ns.EnsureItemRefreshWatcher()
	end
end

-- The level a character had at its last login (Features/Character-Rules.lua), or the player's own.
---@param characterKey string
---@return number|nil
local function CharacterLevel(characterKey)
	if characterKey == ns.db.keys.char then
		return UnitLevel("player")
	end
	local characters = ns.db.sv.char
	local data = characters and characters[characterKey]
	return type(data) == "table" and data.level or nil
end

--[[
    The stats Character Rules reads on a Sanity Check item, for the note under
    its tooltip (GogoLoot_ItemLink draws the entry's desc there), or nil while
    the item loads or carries none.
]]
---@param itemIdentifier number
---@return string|nil
local function SanityCheckStatsNote(itemIdentifier)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	if not itemLink then
		return nil
	end
	local found, names = ns.ReadCharacterRuleStats(itemLink), {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if found[stat.key] then
			names[#names + 1] = stat.label
		end
	end
	if #names == 0 then
		return nil
	end
	return L["CHARACTER_RULES_SANITY_STATS"]:format(table.concat(names, ", "))
end

--[[
    Why a roll goes the way it does, by ns.DecideRoll's reason, for the
    outcomes the boxes alone don't explain. Matching and not matching say
    nothing: Roll Window and Automated Roll speak for themselves.
]]
local SANITY_CHECK_REASONS = {
	LOW_LEVEL = "CHARACTER_RULES_SANITY_LOW_LEVEL",
	OVERRIDE = "TAB_ITEM_OVERRIDES",
	OFF = "CHARACTER_RULES_SANITY_ROLLS_OFF",
	QUALITY = "CHARACTER_RULES_SANITY_QUALITY",
	ABOVE_QUALITY = "CHARACTER_RULES_SANITY_QUALITY",
	MANUAL = "CHARACTER_RULES_SANITY_QUALITY",
}

-- A Sanity Check row's outcome: Automated Roll or Roll Window, then why, in silver, where the boxes don't say.
---@param itemIdentifier number
---@param rules table|nil
---@param classFile string|nil
---@param level number|nil
---@return string
local function SanityCheckOutcomeText(itemIdentifier, rules, classFile, level)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	local itemInformation = itemLink and ns:SafeGetItemInfo(itemIdentifier)
	if not itemInformation then
		return ""
	end
	local rollAction, reason =
		ns.DecideRoll(itemIdentifier, itemInformation, itemLink, itemInformation.quality, rules, classFile, level)
	local outcome = rollAction and L["CHARACTER_RULES_SANITY_AUTOMATED_ROLL"]
		or (ns.GetColor("INFO") .. L["CHARACTER_RULES_SANITY_ROLL_WINDOW"] .. "|r")
	local why = SANITY_CHECK_REASONS[reason]
	if not why then
		return outcome
	end
	return outcome .. "  " .. ns.GetColor("HELP") .. "(" .. L[why] .. ")|r"
end

--[[
    Two checkboxes to a line, each as wide as fits, so long type names
    ("Two-Handed Swords", "Zweihandschwerter") show whole. A full half of the
    row overflows the list's inset by a few pixels and drops to one column.
]]
local CHECKBOX_WIDTH = ns.OPTIONS_TREE_ROW_WIDTH * 0.44

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
			end,
		}
	end

	local args = {}
	local order = 1

	-- Whose rules these are, by class, named and colored by the game: "Class: Druid".
	local classFile = ClassFile()
	local className = classFile and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]
	if className then
		args.classLine = {
			type = "description",
			name = L["CHARACTER_RULES_CLASS"]:format((ns.GetClassColor(classFile) or "") .. className .. "|r"),
			fontSize = "large",
			order = 0,
		}
	end
	args.spacerAfterClassLine = ns.OptionsSpacer(0.25)
	-- Automatically Greed on Low-Level Gear: Off, or Your Level - 1 to - 5; saved only once it differs from the default.
	args.lowLevelGear = ns.OptionsRow(0.5, nil, {
		ns.OptionsRowLabel(L["CHARACTER_RULES_LOW_LEVEL"], 0, ns.OPTIONS_TREE_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			desc = L["CHARACTER_RULES_LOW_LEVEL_DESCRIPTION"],
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
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
			end,
		},
	})
	local function AddHeader(key, caption)
		args["spacerBefore" .. key] = ns.OptionsSpacer(order)
		args["header" .. key] = ns.OptionsHeader(caption, order + 1)
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
                The catch-all is one full-width toggle with a line saying what
                lands there, since a box in a list truncates its name
                and the name alone doesn't say what it catches.
            ]]
			local row = rows[1]
			args["toggle" .. group.key] = {
				type = "toggle",
				name = row.label,
				width = "full",
				order = order,
				get = function()
					return IsTicked(row)
				end,
				set = function(_, ticked)
					SetTicked(row, ticked)
				end,
			}
			args["note" .. group.key] =
				ns.OptionsDesc(ns.GetColor("HELP") .. L["CHARACTER_RULES_OTHER_GEAR_NOTE"] .. "|r", order + 1)
			order = order + 2
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
		end
	end

	AddHeader("UNWANTED", L["CHARACTER_RULES_EVERYTHING_ELSE"])
	args.unwantedAction = ns.OptionsRow(order, nil, {
		ns.OptionsRowLabel(L["CHARACTER_RULES_UNWANTED_ACTION"], 0, ns.OPTIONS_TREE_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = ns.CHARACTER_RULE_UNWANTED_LABELS,
			sorting = ns.CHARACTER_RULE_UNWANTED_ORDER,
			get = UnwantedGet("action"),
			set = UnwantedSet("action"),
		},
	})
	-- Up to Quality has nothing to limit while gear that doesn't match is left to the player.
	local function UnwantedIsManual()
		return ns.CharacterRuleUnwanted(Rules(), "action") == ns.MANUAL
	end
	args.spacerBetweenUnwantedRows = ns.OptionsSpacer(order + 1, UnwantedIsManual)
	args.unwantedThreshold = ns.OptionsRow(order + 2, UnwantedIsManual, {
		ns.OptionsRowLabel(L["ROLLS_UP_TO_QUALITY"], 0, ns.OPTIONS_TREE_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = ns.ROLL_THRESHOLD_LABELS,
			get = UnwantedGet("threshold"),
			set = UnwantedSet("threshold"),
		},
	})
	args.spacerBeforeReset = ns.OptionsSpacer(order + 3)
	args.reset = {
		type = "execute",
		name = L["CHARACTER_RULES_RESET"],
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order + 4,
		func = function()
			GetCharacterData(characterKey).characterRules = nil
		end,
	}
	order = order + 5

	--[[
        Sanity Check: ten Bind on Equip greens (ns.CHARACTER_RULE_SAMPLE_ITEMS)
        and what Automated Rolls would do with each for this character, through
        the same ns.DecideRoll a real roll takes, so it follows every box as it
        is ticked. Each row's text is a function, read whenever AceConfig
        repaints.
    ]]
	AddHeader("SANITY_CHECK", L["CHARACTER_RULES_SANITY_CHECK"])
	args.sanityCheckNote = ns.OptionsDesc(ns.GetColor("HELP") .. L["CHARACTER_RULES_SANITY_CHECK_NOTE"] .. "|r", order)
	order = order + 1
	--[[
        Each row: the item through GogoLoot_ItemLink, which shows its tooltip
        on hover with the stats Character Rules reads on it underneath, then
        the outcome, with a spacer between rows.
    ]]
	for index, itemIdentifier in ipairs(ns.CHARACTER_RULE_SAMPLE_ITEMS or {}) do
		local function NotOnClient()
			return not ns.IsItemOnClient(itemIdentifier)
		end
		args["spacerBeforeSanityCheck" .. index] = ns.OptionsSpacer(order, NotOnClient)
		order = order + 1
		args["sanityCheck" .. index] = ns.OptionsRow(order, NotOnClient, {
			{
				type = "input",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				name = "",
				desc = function()
					return SanityCheckStatsNote(itemIdentifier)
				end,
				width = ns.OPTIONS_TREE_LABEL_WIDTH,
				get = function()
					return tostring(itemIdentifier)
				end,
				set = function() end,
			},
			ns.OptionsRowLabel(function()
				return SanityCheckOutcomeText(itemIdentifier, Rules(), ClassFile(), CharacterLevel(characterKey))
			end, 0, ns.OPTIONS_CONTROL_WIDTH),
		})
		order = order + 1
	end

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
		description = ns.OptionsDesc(
			L["CHARACTER_RULES_PANEL_INTRO"]:format(
				ITEM_MOD_STRENGTH_SHORT,
				LOCALIZED_CLASS_NAMES_MALE.WARRIOR,
				ITEM_MOD_STRENGTH_SHORT
			),
			1
		),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	ns.AddFeatureOffNote(args, 3, L["ROLLS_OFF_NOTE"], AutomatedRollsOn)
	WatchSampleItems()

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

--[[
    The panel opens on the character being played. AceConfigDialog keeps the
    tree's picked node in its status table for the panel, and reads it each
    time the panel is shown, so pointing it at the player's key once at
    registration and again each time the panel hides is enough: picking
    another character still sticks while the player stays on the page.
]]
---@param registryName string
---@return nil
local function SelectCurrentCharacter(registryName)
	local status = LibStub("AceConfigDialog-3.0"):GetStatusTable(registryName)
	status.groups = status.groups or {}
	status.groups.selected = ns.db.keys.char
end

---@param panelFrame table # the panel AddToBlizOptions returned
---@param registryName string
---@return nil
function ns.OnCharacterRulesRegistered(panelFrame, registryName)
	SelectCurrentCharacter(registryName)
	if panelFrame and panelFrame.HookScript then
		panelFrame:HookScript("OnHide", function()
			SelectCurrentCharacter(registryName)
		end)
	end
end
