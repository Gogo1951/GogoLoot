--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Character Rules
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

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
---@return string
local function GetCharacterDisplayName(characterKey)
	local classFile
	if characterKey == ns.db.keys.char then
		local _, playerClassFile = UnitClass("player")
		classFile = playerClassFile
	else
		local characters = ns.db.sv.char
		local data = characters and characters[characterKey]
		classFile = type(data) == "table" and data.classFile or nil
	end
	local classColor = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
	if type(classColor) == "table" and type(classColor.colorStr) == "string" then
		return "|c" .. classColor.colorStr .. characterKey .. "|r"
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
---@param group table # a ns.CHARACTER_RULE_GROUPS row
---@return string
local function GroupCaption(group)
	local label = _G[group.labelGlobal]
	if type(label) == "string" and label ~= "" then
		return label
	end
	return L[group.caption]
end

--[[
    One character's rules: a dropdown per stat. Each closes over its
    character's key, so the pane always edits the character the player picked,
    another character's included.
]]
---@param characterKey string
---@return table
local function BuildCharacterArgs(characterKey)
	local function Rules()
		return GetCharacterData(characterKey).characterRules
	end

	--[[
        One row per stat, its caption beside its dropdown. Standard Automated
        Roll saves no rule, and a character left with none drops its rules
        table.
    ]]
	local function StatRow(order, stat)
		return ns.OptionsRow(order, nil, {
			ns.OptionsRowLabel(stat.label, 0, ns.OPTIONS_TREE_LABEL_WIDTH),
			{
				type = "select",
				name = "",
				desc = L["CHARACTER_RULES_ACTION_DESCRIPTION"]:format(stat.label),
				style = "dropdown",
				width = ns.OPTIONS_CONTROL_WIDTH,
				values = ns.CHARACTER_RULE_LABELS,
				sorting = ns.CHARACTER_RULE_ORDER,
				get = function()
					local rules = Rules()
					return rules and rules[stat.key] == ns.MANUAL and ns.MANUAL or ns.CHARACTER_RULE_STANDARD
				end,
				set = function(_, value)
					local data = GetCharacterData(characterKey)
					if value == ns.CHARACTER_RULE_STANDARD then
						if data.characterRules then
							data.characterRules[stat.key] = nil
							if next(data.characterRules) == nil then
								data.characterRules = nil
							end
						end
						return
					end
					data.characterRules = data.characterRules or {}
					data.characterRules[stat.key] = value
				end,
			},
		})
	end

	--[[
        Primary Attributes in the character sheet's order, then Secondary
        Attributes A to Z in the player's language, each under a gold caption,
        with a blank line between the two.
    ]]
	local args = {}
	local order = 1
	for groupIndex, group in ipairs(ns.CHARACTER_RULE_GROUPS) do
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

		if groupIndex > 1 then
			args["spacerBefore" .. group.key] = ns.OptionsSpacer(order)
			order = order + 1
		end
		args["caption" .. group.key] = {
			type = "description",
			name = GetColor("TITLE") .. GroupCaption(group) .. "|r",
			fontSize = "medium",
			order = order,
		}
		order = order + 1
		for _, stat in ipairs(stats) do
			args["rule" .. stat.key] = StatRow(order, stat)
			order = order + 1
		end
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
			L["CHARACTER_RULES_PANEL_DESCRIPTION"]:format(
				ITEM_MOD_INTELLECT_SHORT,
				LOCALIZED_CLASS_NAMES_MALE.WARRIOR,
				ITEM_MOD_INTELLECT_SHORT
			),
			1
		),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	ns.AddFeatureOffNote(args, 3, L["ROLLS_OFF_NOTE"], AutomatedRollsOn)

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
