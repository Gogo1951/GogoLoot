--------------------------------------------------------------------------------
-- GogoLoot Options — General
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDBIcon = LibStub("LibDBIcon-1.0")

local GetColor = ns.GetColor

--[[
    The four link rows split ns.OPTIONS_ROW_WIDTH unevenly: their labels are one
    short word, while the box beside them holds a full URL the player is meant
    to select and copy, so the label takes 0.6 and the box the rest of the row.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    Speedy Loot has no panel of its own, so its switch is built here, where it
    lives: in the Features section with every other feature's.
]]
---@return table
local function SpeedyLootSwitch()
	return {
		type = "toggle",
		name = L["SPEEDY_LOOT_ENABLE"],
		desc = L["SPEEDY_LOOT_SWITCH_DESCRIPTION"]:format(AUTO_LOOT_DEFAULT_TEXT, MASTER_LOOTER),
		get = function()
			return ns.db.global.speedyLoot
		end,
		set = function(_, value)
			ns.db.global.speedyLoot = value
			if value then
				ns.EnsureAutoLoot()
			end
		end,
	}
end

--[[
    The Features section: every feature's own switch, gathered so the front page
    shows at a glance what GogoLoot is doing. Each is the same setting as the
    switch on its feature's panel, built by that panel's file so the two can
    never drift. A feature whose file this flavor's TOC leaves out is left out
    here too. The keys are the saved settings each switch reads.
]]
local FEATURE_SWITCHES = {
	{ key = "speedyLoot", build = SpeedyLootSwitch },
	{ key = "autoGreed", builder = "AutomatedRollsSwitch" },
	{ key = "autoMasterLoot", builder = "AutomatedMasterLootingSwitch" },
	{ key = "autoOpen", builder = "AutomatedOpeningSwitch" },
	{ key = "lootToasts", builder = "LootToastsSwitch" },
	{ key = "lootNotifications", builder = "AnnouncementsSwitch" },
}

--[[
    Two to a line while every caption fits half a row, and one to a line when
    one doesn't, as a German or French caption may not: AceGUI cuts a checkbox
    caption that runs past its width short with "...". One unnamed inline
    group, so the switches keep a block of their own.
]]
---@param order number
---@return table
local function BuildFeatureSwitches(order)
	local switches = {}
	for _, entry in ipairs(FEATURE_SWITCHES) do
		local build = entry.build or ns[entry.builder]
		if build then
			switches[#switches + 1] = { key = entry.key, toggle = build() }
		end
	end

	local width = ns.OPTIONS_ROW_WIDTH / 2
	for _, switch in ipairs(switches) do
		if ns.OptionsToggleWidth(switch.toggle.name) > width then
			width = "full"
			break
		end
	end

	local args = {}
	for index, switch in ipairs(switches) do
		switch.toggle.order = index
		switch.toggle.width = width
		args[switch.key] = switch.toggle
	end
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildGeneralOptions()
	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = {
			description = ns.OptionsDesc(L["OPTIONS_DESCRIPTION"], 2),
			spacerAfterDesc = ns.OptionsSpacer(3),
			welcomeMessage = {
				type = "toggle",
				name = L["WELCOME_MESSAGE"],
				desc = L["WELCOME_MESSAGE_DESCRIPTION"],
				width = "full",
				order = 4,
				get = function()
					return ns.db.global.showWelcome
				end,
				set = function(_, value)
					ns.db.global.showWelcome = value
				end,
			},
			minimapButton = {
				type = "toggle",
				name = L["MINIMAP_BUTTON_ENABLE"],
				desc = L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"],
				width = "full",
				order = 5,
				get = function()
					return not ns.db.global.minimap.hide
				end,
				set = function(_, value)
					ns.db.global.minimap.hide = not value
					LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
				end,
			},
			spacerFeaturesSection = ns.OptionsSpacer(20),
			featuresHeader = ns.OptionsHeader(L["OPTIONS_FEATURES_HEADER"], 21),
			spacerAfterFeaturesHeader = ns.OptionsSpacer(22),
			features = BuildFeatureSwitches(23),
			spacerCommands0 = ns.OptionsSpacer(80),
			headerCommands = ns.OptionsHeader(L["OPTIONS_COMMANDS_HEADER"], 81),
			spacerCommands1 = ns.OptionsSpacer(82),
			descCommands = ns.OptionsDesc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				83
			),
			spacerFeedbackSection = ns.OptionsSpacer(89),
			feedbackHeader = ns.OptionsHeader(L["FEEDBACK_SUPPORT"], 90),
			spacerAfterFeedback = ns.OptionsSpacer(91),
			discordLabel = ns.OptionsRowLabel(GetColor("TITLE") .. L["DISCORD"] .. "|r", 92, LINK_LABEL_WIDTH),
			discordUrl = {
				type = "input",
				name = "",
				order = 93,
				width = LINK_URL_WIDTH,
				get = function()
					return ns.URL_DISCORD
				end,
				set = function() end,
			},
			spacerBetweenLinks1 = ns.OptionsSpacer(94),
			githubLabel = ns.OptionsRowLabel(GetColor("TITLE") .. L["GITHUB"] .. "|r", 95, LINK_LABEL_WIDTH),
			githubUrl = {
				type = "input",
				name = "",
				order = 96,
				width = LINK_URL_WIDTH,
				get = function()
					return ns.URL_GITHUB
				end,
				set = function() end,
			},
			spacerBetweenLinks2 = ns.OptionsSpacer(97),
			curseforgeLabel = ns.OptionsRowLabel(GetColor("TITLE") .. L["CURSEFORGE"] .. "|r", 98, LINK_LABEL_WIDTH),
			curseforgeUrl = {
				type = "input",
				name = "",
				order = 99,
				width = LINK_URL_WIDTH,
				get = function()
					return ns.URL_CURSEFORGE
				end,
				set = function() end,
			},
			spacerBetweenLinks3 = ns.OptionsSpacer(100),
			wagoLabel = ns.OptionsRowLabel(GetColor("TITLE") .. L["WAGO"] .. "|r", 101, LINK_LABEL_WIDTH),
			wagoUrl = {
				type = "input",
				name = "",
				order = 102,
				width = LINK_URL_WIDTH,
				get = function()
					return ns.URL_WAGO
				end,
				set = function() end,
			},
			spaceVersion0 = {
				type = "description",
				name = " ",
				width = "full",
				order = 998,
			},
			versionLine = {
				type = "description",
				name = GetColor("MUTED") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
				fontSize = "medium",
				order = 999,
			},
		},
	}
end
