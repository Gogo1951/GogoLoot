--------------------------------------------------------------------------------
-- GogoLoot Options — General
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildGeneralOptions()
	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = {
			description = Kit.Desc(L["OPTIONS_DESCRIPTION"], 2),
			spacerAfterDesc = Kit.Spacer(3),
			welcomeMessage = {
				type = "toggle",
				name = L["WELCOME_MESSAGE"],
				desc = L["WELCOME_MESSAGE_DESCRIPTION"],
				width = "full",
				order = 4,
				get = Kit.Get("global", "showWelcome"),
				set = Kit.Set("global", "showWelcome"),
			},
			minimapButton = {
				type = "toggle",
				name = L["MINIMAP_BUTTON_ENABLE"],
				desc = L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"],
				width = "full",
				order = 5,
				get = function()
					return not ns.db.profile.minimap.hide
				end,
				set = function(_, value)
					ns.db.profile.minimap.hide = not value
					ns:ApplyMinimapButton()
					ns.RefreshSettings()
				end,
			},
			spacerFeaturesSection = Kit.Spacer(20),
			featuresHeader = Kit.Header(L["OPTIONS_FEATURES_HEADER"], 21),
			spacerAfterFeaturesHeader = Kit.Spacer(22),
			features = ns.FeatureSwitches(23),
			spacerCommands0 = Kit.Spacer(80),
			headerCommands = Kit.Header(L["OPTIONS_COMMANDS_HEADER"], 81),
			spacerCommands1 = Kit.Spacer(82),
			descCommands = Kit.Desc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				83
			),
		},
	}
end
