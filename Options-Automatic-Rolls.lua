--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local L = GogoLoot.L

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

function GogoLoot.BuildAutomaticRollOptions()
    local greedThresholdValues = {
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. L["THRESHOLD_POOR_ONLY"] .. "|r",
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. L["THRESHOLD_COMMON_LOWER"] .. "|r",
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. L["THRESHOLD_UNCOMMON_LOWER"] .. "|r",
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. L["THRESHOLD_RARE_LOWER"] .. "|r",
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. L["THRESHOLD_EPIC_LOWER"] .. "|r"
    }

    local customListArgs =
        GogoLoot:BuildItemListOptions(
        {
            getSourceTable = function()
                return GogoLootDB.ignoredItemsSolo
            end,
            onRestore = function()
                GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
            end,
            onAdd = function(itemIdentifier)
                GogoLootDB.ignoredItemsSolo[itemIdentifier] = GogoLoot.MANUAL
            end,
            onRemove = function(itemIdentifier)
                GogoLootDB.ignoredItemsSolo[itemIdentifier] = nil
            end,
            notifyKey = "GogoLoot_AutomaticRolls",
            labels = {
                restore = L["ROLLS_RESTORE_DEFAULTS"],
                restoreConfirm = L["ROLLS_RESTORE_CONFIRM"],
                addDesc = L["ROLLS_ADD_ITEM_DESC"],
                addName = L["ROLLS_ADD_ITEM"],
                addTooltip = L["ROLLS_ADD_ITEM_TOOLTIP"],
                removeName = L["ROLLS_REMOVE"],
                removeDesc = L["ROLLS_REMOVE_DESC"]
            },
            actionColumn = {
                desc = L["ROLLS_CHOOSE_ACTION"],
                values = GogoLoot.ROLL_OVERRIDE_LABELS,
                get = function(itemIdentifier)
                    return GogoLootDB.ignoredItemsSolo[itemIdentifier]
                end,
                set = function(itemIdentifier, value)
                    GogoLootDB.ignoredItemsSolo[itemIdentifier] = value
                end
            }
        }
    )

    return {
        type = "group",
        name = "Automated Rolls",
        args = {
            description = GogoLoot:OptionsDesc(L["ROLLS_DESC"], 2),
            spacerAfterDesc = GogoLoot:OptionsSpacer(3),
            autoGreed = {
                type = "toggle",
                name = L["ROLLS_ENABLE"],
                desc = L["ROLLS_ENABLE_DESC"],
                width = "full",
                order = 4,
                get = function()
                    return GogoLootDB.autoGreed
                end,
                set = function(_, value)
                    GogoLootDB.autoGreed = value
                    if GogoLoot.UpdateMinimapIcon then
                        GogoLoot:UpdateMinimapIcon()
                    end
                end
            },
            spacerAfterToggle = GogoLoot:OptionsSpacer(5),
            autoGreedThreshold = {
                type = "select",
                name = L["ROLLS_THRESHOLD"],
                desc = L["ROLLS_THRESHOLD_DESC"],
                style = "dropdown",
                values = greedThresholdValues,
                order = 6,
                get = function()
                    return GogoLootDB.autoGreedThreshold
                end,
                set = function(_, value)
                    GogoLootDB.autoGreedThreshold = value
                end
            },
            spacerBeforeCustom = GogoLoot:OptionsSpacer(9),
            customListHeader = GogoLoot:OptionsHeader(L["ROLLS_CUSTOM_LIST"], 10),
            customListDesc = GogoLoot:OptionsDesc(L["ROLLS_CUSTOM_LIST_DESC"], 11),
            spacerAfterCustomDesc = GogoLoot:OptionsSpacer(12),
            customList = {
                type = "group",
                name = "",
                inline = true,
                order = 13,
                args = customListArgs
            }
        }
    }
end