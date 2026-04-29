--------------------------------------------------------------------------------
-- GogoLoot Options — Announcements
--
-- Filename retains "Trade-Announcements" for git/.toc continuity, but this
-- panel now hosts BOTH trade announcements and master looter announcements
-- under a single "Announcements" tab. Master Looter announcement settings
-- moved here from Options-Master-Looter.lua so all chat-output controls
-- live in one place.
--
-- Schema (DEFAULT_CONFIGURATION in Data.lua):
--   announceTrade, announceTradeCondition, announceTradeOutput
--     - existing trade settings, unchanged in behavior
--   announceDestinations
--     - gates MSG_DESTINATION_SET / MSG_DESTINATION_LEFT
--   announceMasterLootAuto + announceMasterLootAutoThreshold
--     - gates the announce inside Master-Looter-Distribution.lua's
--       TryDistributeSlot (items handed out by the auto path)
--   announceMasterLootManual + announceMasterLootManualThreshold
--     - gates the GiveMasterLoot hooksecurefunc in Master-Looter.lua
--       (items handed out via the standard ML candidate dropdown)
--
-- Defaults: auto=Blue+, manual=White+. Manual defaults lower because manual
-- distributions represent deviations from the configured rules and the user
-- generally wants the group to see them; auto defaults higher to avoid
-- spamming chat with every green that gets routed through the auto path.
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Announcement Threshold Dropdown
-- Always offers Common+ through Epic+ regardless of the game's current loot
-- threshold. ML distribution can only happen at-or-above the loot threshold,
-- so options below it have no functional effect — but pinning the menu at
-- Common+ keeps the user's chosen "announce everything" / "announce blue+"
-- intent stable across loot-threshold changes, instead of silently bumping
-- their saved selection upward each time.
--
-- Poor (0) is intentionally excluded: ML doesn't distribute Poor items.
--------------------------------------------------------------------------------

local function BuildAnnouncementThresholdOptions()
    local options = {}
    for quality = 1, 4 do
        local rarityKey = GogoLoot.rarityToConfigurationKey[quality]
        local localizedName = GogoLoot.QUALITY_DISPLAY_NAMES[rarityKey] or GogoLoot:CapitalizeFirstLetter(rarityKey)
        options[quality] = GogoLoot:GetQualityColor(quality) .. localizedName .. "+|r"
    end
    return options
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

function GogoLoot.BuildTradeAnnouncementOptions()
    local thresholdOptions = BuildAnnouncementThresholdOptions()

    return {
        type = "group",
        name = L["TAB_TRADE_ANNOUNCEMENTS"],
        args = {
            ----------------------------------------------------------------
            -- Trade Announcements
            ----------------------------------------------------------------
            tradeHeader = GogoLoot.OptionsHeader(L["TRADE_HEADER"], 1),
            tradeDesc = GogoLoot.OptionsDesc(L["TRADE_DESC"], 2),
            spacerAfterTradeDesc = GogoLoot.OptionsSpacer(3),
            announceTrade = {
                type = "toggle",
                name = L["TRADE_ENABLE"],
                desc = L["TRADE_ENABLE_DESC"],
                width = "full",
                order = 4,
                get = function()
                    return GogoLootDB.announceTrade
                end,
                set = function(_, value)
                    GogoLootDB.announceTrade = value
                    GogoLoot:SyncTradeCheckbox()
                end
            },
            spacerAfterTradeToggle = GogoLoot.OptionsSpacer(5),
            announceTradeCondition = {
                type = "select",
                name = L["TRADE_CONDITION"],
                desc = L["TRADE_CONDITION_DESC"],
                style = "dropdown",
                order = 6,
                disabled = function()
                    return not GogoLootDB.announceTrade
                end,
                values = {
                    ["always"] = L["TRADE_CONDITION_ALWAYS"],
                    ["party_or_raid"] = L["TRADE_CONDITION_PARTY_OR_RAID"],
                    ["raid_only"] = L["TRADE_CONDITION_RAID_ONLY"]
                },
                sorting = {"always", "party_or_raid", "raid_only"},
                get = function()
                    return GogoLootDB.announceTradeCondition
                end,
                set = function(_, value)
                    GogoLootDB.announceTradeCondition = value
                end
            },
            spacerBetweenTradeDropdowns = GogoLoot.OptionsSpacer(7),
            announceTradeOutput = {
                type = "select",
                name = L["TRADE_OUTPUT"],
                desc = L["TRADE_OUTPUT_DESC"],
                style = "dropdown",
                order = 8,
                disabled = function()
                    return not GogoLootDB.announceTrade
                end,
                values = {
                    ["whisper"] = L["TRADE_OUTPUT_WHISPER"],
                    ["group"] = L["TRADE_OUTPUT_GROUP"],
                    ["raid"] = L["TRADE_OUTPUT_RAID"]
                },
                sorting = {"whisper", "group", "raid"},
                get = function()
                    return GogoLootDB.announceTradeOutput
                end,
                set = function(_, value)
                    GogoLootDB.announceTradeOutput = value
                end
            },
            spacerBeforeTradeExample = GogoLoot.OptionsSpacer(9),
            tradeExample = GogoLoot.OptionsDesc(GogoLoot:GetColor("MUTED") .. L["TRADE_EXAMPLE"] .. "|r", 10),

            ----------------------------------------------------------------
            -- Master Looter Announcements
            ----------------------------------------------------------------
            spacerBeforeML = GogoLoot.OptionsSpacer(20),
            mlHeader = GogoLoot.OptionsHeader(L["ML_ANNOUNCE_HEADER"], 21),
            mlDesc = GogoLoot.OptionsDesc(L["ML_ANNOUNCE_DESC"], 22),
            spacerAfterMLDesc = GogoLoot.OptionsSpacer(23),

            -- Destinations toggle (gates MSG_DESTINATION_SET / MSG_DESTINATION_LEFT)
            announceDestinations = {
                type = "toggle",
                name = L["ML_ANNOUNCE_DESTINATION"],
                desc = L["ML_ANNOUNCE_DESTINATION_DESC"],
                width = "full",
                order = 24,
                get = function()
                    return GogoLootDB.announceDestinations
                end,
                set = function(_, value)
                    GogoLootDB.announceDestinations = value
                end
            },
            spacerAfterDestToggle = GogoLoot.OptionsSpacer(25),
            destExample = GogoLoot.OptionsDesc(
                GogoLoot:GetColor("MUTED") .. L["ML_ANNOUNCE_DESTINATION_EXAMPLE"] .. "|r",
                26
            ),

            -- Auto distribution toggle + threshold
            spacerBeforeAuto = GogoLoot.OptionsSpacer(27),
            announceMasterLootAuto = {
                type = "toggle",
                name = L["ML_ANNOUNCE_AUTO"],
                desc = L["ML_ANNOUNCE_AUTO_DESC"],
                width = "full",
                order = 28,
                get = function()
                    return GogoLootDB.announceMasterLootAuto
                end,
                set = function(_, value)
                    GogoLootDB.announceMasterLootAuto = value
                end
            },
            spacerAfterAutoToggle = GogoLoot.OptionsSpacer(29),
            announceMasterLootAutoThreshold = {
                type = "select",
                name = L["ML_ANNOUNCE_AUTO_THRESHOLD"],
                desc = L["ML_ANNOUNCE_AUTO_THRESHOLD_DESC"],
                style = "dropdown",
                values = thresholdOptions,
                order = 30,
                disabled = function()
                    return not GogoLootDB.announceMasterLootAuto
                end,
                get = function()
                    return GogoLootDB.announceMasterLootAutoThreshold
                end,
                set = function(_, value)
                    GogoLootDB.announceMasterLootAutoThreshold = value
                end
            },

            -- Manual distribution toggle + threshold
            spacerBeforeManual = GogoLoot.OptionsSpacer(31),
            announceMasterLootManual = {
                type = "toggle",
                name = L["ML_ANNOUNCE_MANUAL"],
                desc = L["ML_ANNOUNCE_MANUAL_DESC"],
                width = "full",
                order = 32,
                get = function()
                    return GogoLootDB.announceMasterLootManual
                end,
                set = function(_, value)
                    GogoLootDB.announceMasterLootManual = value
                end
            },
            spacerAfterManualToggle = GogoLoot.OptionsSpacer(33),
            announceMasterLootManualThreshold = {
                type = "select",
                name = L["ML_ANNOUNCE_MANUAL_THRESHOLD"],
                desc = L["ML_ANNOUNCE_MANUAL_THRESHOLD_DESC"],
                style = "dropdown",
                values = thresholdOptions,
                order = 34,
                disabled = function()
                    return not GogoLootDB.announceMasterLootManual
                end,
                get = function()
                    return GogoLootDB.announceMasterLootManualThreshold
                end,
                set = function(_, value)
                    GogoLootDB.announceMasterLootManualThreshold = value
                end
            },

            spacerBeforeMLExample = GogoLoot.OptionsSpacer(35),
            mlExample = GogoLoot.OptionsDesc(GogoLoot:GetColor("MUTED") .. L["ML_ANNOUNCE_EXAMPLE"] .. "|r", 36)
        }
    }
end