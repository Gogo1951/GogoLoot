-------------------------------------------------------------------------------
-- GogoLoot Options — Trade Announcements
-------------------------------------------------------------------------------

function GogoLoot.BuildTradeAnnouncementOptions()
    return {
        type = "group",
        name = "Trade Announcements",
        args = {
            description = GogoLoot:OptionsDesc(
                "Automatically posts a summary of completed trades to chat, including items, enchants, and gold exchanged.",
                2
            ),
            spacerAfterDesc = GogoLoot:OptionsSpacer(3),

            announceTrade = {
                type  = "toggle",
                name  = "Enable Trade Announcements",
                desc  = "Posts a trade summary when a trade completes.",
                width = "full",
                order = 4,
                get   = function() return GogoLoot_Configuration.announceTrade end,
                set   = function(_, value)
                    GogoLoot_Configuration.announceTrade = value
                    GogoLoot:SyncTradeCheckbox()
                end,
            },

            spacerAfterToggle = GogoLoot:OptionsSpacer(5),

            announceTradeCondition = {
                type   = "select",
                name   = "When in Group",
                desc   = "Controls when trade announcements are active.",
                style  = "dropdown",
                order  = 6,
                values = {
                    ["always"]        = "Always",
                    ["party_or_raid"] = "Only in Party or Raid",
                    ["raid_only"]     = "Only in Raid",
                },
                sorting = { "always", "party_or_raid", "raid_only" },
                get = function() return GogoLoot_Configuration.announceTradeCondition end,
                set = function(_, value) GogoLoot_Configuration.announceTradeCondition = value end,
            },

            spacerBetweenDropdowns = GogoLoot:OptionsSpacer(7),

            announceTradeOutput = {
                type   = "select",
                name   = "Message Output",
                desc   = "Where the trade summary is sent.",
                style  = "dropdown",
                order  = 8,
                values = {
                    ["whisper"] = "Whisper",
                    ["group"]   = "Party Chat",
                    ["raid"]    = "Raid Chat",
                },
                sorting = { "whisper", "group", "raid" },
                get = function() return GogoLoot_Configuration.announceTradeOutput end,
                set = function(_, value) GogoLoot_Configuration.announceTradeOutput = value end,
            },

            spacerBeforeExample = GogoLoot:OptionsSpacer(9),
            exampleText = GogoLoot:OptionsDesc(
                GogoLoot:GetColor("MUTED") .. "Example: {rt4} Gave [Item X] x2, [Item Y] to Fathom. // GogoLoot|r",
                10
            ),
        },
    }
end