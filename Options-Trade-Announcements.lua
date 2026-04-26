--------------------------------------------------------------------------------
-- GogoLoot Options — Trade Announcements
--------------------------------------------------------------------------------
local L = GogoLoot.L

function GogoLoot.BuildTradeAnnouncementOptions()
    return {
        type = "group",
        name = "Trade Announcements",
        args = {
            description = GogoLoot:OptionsDesc(L["TRADE_DESC"], 2),
            spacerAfterDesc = GogoLoot:OptionsSpacer(3),
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
            spacerAfterToggle = GogoLoot:OptionsSpacer(5),
            announceTradeCondition = {
                type = "select",
                name = L["TRADE_CONDITION"],
                desc = L["TRADE_CONDITION_DESC"],
                style = "dropdown",
                order = 6,
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
            spacerBetweenDropdowns = GogoLoot:OptionsSpacer(7),
            announceTradeOutput = {
                type = "select",
                name = L["TRADE_OUTPUT"],
                desc = L["TRADE_OUTPUT_DESC"],
                style = "dropdown",
                order = 8,
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
            spacerBeforeExample = GogoLoot:OptionsSpacer(9),
            exampleText = GogoLoot:OptionsDesc(GogoLoot:GetColor("MUTED") .. L["TRADE_EXAMPLE"] .. "|r", 10)
        }
    }
end