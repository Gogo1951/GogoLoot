--------------------------------------------------------------------------------
-- GogoLoot Options — General
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDBIcon = LibStub("LibDBIcon-1.0")

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

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
                    return ns.db.profile.showWelcome
                end,
                set = function(_, value)
                    ns.db.profile.showWelcome = value
                end
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
                end
            },
            spacerCommands0 = ns.OptionsSpacer(6),
            headerCommands = ns.OptionsHeader(L["COMMANDS"], 7),
            spacerCommands1 = ns.OptionsSpacer(8),
            descCommandGl = ns.OptionsDesc(GetColor("INFO") .. "/gl|r" .. "  " .. L["COMMANDS_DESCRIPTION"], 9),
            spacerBetweenCommands = ns.OptionsSpacer(10),
            descCommandGogoloot = ns.OptionsDesc(GetColor("INFO") .. "/gogoloot|r" .. "  " .. L["COMMANDS_DESCRIPTION"], 11),
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
                    return ns.db.profile.speedyLoot
                end,
                set = function(_, value)
                    ns.db.profile.speedyLoot = value
                end
            },
            spacerFeedbackSection = ns.OptionsSpacer(89),
            feedbackHeader = ns.OptionsHeader(L["FEEDBACK_SUPPORT"], 90),
            spacerAfterFeedback = ns.OptionsSpacer(91),
            curseforgeLabel = ns.OptionsDesc(GetColor("TITLE") .. L["CURSEFORGE"] .. "|r", 92),
            curseforgeUrl = {
                type = "input",
                name = "",
                order = 93,
                width = "double",
                get = function()
                    return ns.URL_CURSEFORGE
                end,
                set = function()
                end
            },
            spacerBetweenLinks1 = ns.OptionsSpacer(94),
            githubLabel = ns.OptionsDesc(GetColor("TITLE") .. L["GITHUB"] .. "|r", 95),
            githubUrl = {
                type = "input",
                name = "",
                order = 96,
                width = "double",
                get = function()
                    return ns.URL_GITHUB
                end,
                set = function()
                end
            },
            spacerBetweenLinks2 = ns.OptionsSpacer(97),
            discordLabel = ns.OptionsDesc(GetColor("TITLE") .. L["DISCORD"] .. "|r", 98),
            discordUrl = {
                type = "input",
                name = "",
                order = 99,
                width = "double",
                get = function()
                    return ns.URL_DISCORD
                end,
                set = function()
                end
            },
            spaceVersion0 = {
                type = "description",
                name = " ",
                width = "full",
                order = 998
            },
            versionLine = {
                type = "description",
                name = GetColor("MUTED") .. L["VERSION_LABEL"] .. " " .. ns.Version .. "|r",
                fontSize = "medium",
                order = 999
            }
        }
    }
end
