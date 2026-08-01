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
    to select and copy. The label takes 0.6 so the box lands on exactly 2.0 —
    the guide's double width for a read-only URL input — without the row
    outgrowing every other row on the panel.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildGeneralOptions()
	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = {
			description = ns.OptionsDesc(L["GENERAL_DESCRIPTION"], 2),
			spacerAfterDesc = ns.OptionsSpacer(3),
			welcomeMessage = {
				type = "toggle",
				name = L["WELCOME_MESSAGE"],
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
				width = "full",
				order = 5,
				get = function()
					return not ns.db.global.minimap.hide
				end,
				set = function(_, value)
					ns.db.global.minimap.hide = not value
					if value then
						LibDBIcon:Show(ADDON_NAME)
					else
						LibDBIcon:Hide(ADDON_NAME)
					end
				end,
			},
			spacerCommands0 = ns.OptionsSpacer(6),
			headerCommands = ns.OptionsHeader(L["COMMANDS"], 7),
			spacerCommands1 = ns.OptionsSpacer(8),
			descCommandGl = ns.OptionsDesc(GetColor("INFO") .. "/gl|r" .. "  " .. L["COMMANDS_DESCRIPTION"], 9),
			spacerBetweenCommands = ns.OptionsSpacer(10),
			descCommandGogoloot = ns.OptionsDesc(
				GetColor("INFO") .. "/gogoloot|r" .. "  " .. L["COMMANDS_DESCRIPTION"],
				11
			),
			spacerSpeedyLootSection = ns.OptionsSpacer(20),
			speedyLootHeader = ns.OptionsHeader(L["SPEEDY_LOOT_HEADER"], 21),
			spacerAfterSpeedyLootHeader = ns.OptionsSpacer(22),
			speedyLootDesc = ns.OptionsDesc(L["SPEEDY_LOOT_DESCRIPTION"], 23),
			spacerAfterSpeedyLootDesc = ns.OptionsSpacer(24),
			speedyLoot = {
				type = "toggle",
				name = L["SPEEDY_LOOT_ENABLE"],
				width = "full",
				order = 25,
				get = function()
					return ns.db.global.speedyLoot
				end,
				set = function(_, value)
					ns.db.global.speedyLoot = value
					if value then
						ns.EnsureAutoLoot()
					end
				end,
			},
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
				name = GetColor("MUTED") .. L["VERSION_LABEL"] .. " " .. ns.Version .. "|r",
				fontSize = "medium",
				order = 999,
			},
		},
	}
end
