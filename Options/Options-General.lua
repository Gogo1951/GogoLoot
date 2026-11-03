--------------------------------------------------------------------------------
-- GogoLoot Options — General
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDBIcon = LibStub("LibDBIcon-1.0")

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    The Features section: every feature's own switch, gathered so the front page
    shows at a glance what GogoLoot is doing. Each is the same setting as the
    switch on its feature's panel, built by that panel's file so the two can
    never drift. A feature whose file this flavor's TOC leaves out is left out
    here too. The keys are the saved settings each switch reads, listed in the
    order of the feature panels in the Settings tree (FEATURE_PANELS in
    Options.lua), reading across each line.
]]
local FEATURE_SWITCHES = {
	{ key = "speedyLoot", builder = "SpeedyLootSwitch" },
	{ key = "autoGreed", builder = "AutomatedRollsSwitch" },
	{ key = "autoOpen", builder = "AutomatedOpeningSwitch" },
	{ key = "lootToasts", builder = "LootToastsSwitch" },
	{ key = "lootSoundsEnabled", builder = "LootSoundsSwitch" },
	{ key = "lootNotifications", builder = "AnnouncementsSwitch" },
	{ key = "autoMasterLoot", builder = "AutomatedMasterLootingSwitch" },
	{ key = "rollMacro", builder = "RollMacroSwitch" },
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
		local build = ns[entry.builder]
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
		},
	}
end
