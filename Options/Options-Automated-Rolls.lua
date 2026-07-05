--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

function ns.BuildAutomatedRollOptions()
    local greedThresholdValues = {
        [0] = GetQualityColor(0) .. L["THRESHOLD_POOR_ONLY"] .. "|r",
        [1] = GetQualityColor(1) .. L["THRESHOLD_COMMON_LOWER"] .. "|r",
        [2] = GetQualityColor(2) .. L["THRESHOLD_UNCOMMON_LOWER"] .. "|r",
        [3] = GetQualityColor(3) .. L["THRESHOLD_RARE_LOWER"] .. "|r",
        [4] = GetQualityColor(4) .. L["THRESHOLD_EPIC_LOWER"] .. "|r"
    }

    local customListArgs =
        ns:BuildItemListOptions(
        {
            getSourceTable = function()
                return ns.db.profile.ignoredItemsSolo
            end,
            onRestore = function()
                ns.db.profile.ignoredItemsSolo = ns:BuildDefaultIgnoreListSolo()
            end,
            onAdd = function(itemIdentifier)
                ns.db.profile.ignoredItemsSolo[itemIdentifier] = ns.MANUAL
            end,
            onRemove = function(itemIdentifier)
                ns.db.profile.ignoredItemsSolo[itemIdentifier] = nil
            end,
            notifyKey = ns.OPTIONS_REGISTRY.AutomatedRolls,
            labels = {
                restore = L["ROLLS_RESTORE_DEFAULTS"],
                restoreConfirm = L["ROLLS_RESTORE_CONFIRM"],
                addDesc = L["ROLLS_ADD_ITEM_DESCRIPTION"],
                addName = L["ROLLS_ADD_ITEM"],
                removeName = L["ROLLS_REMOVE"],
                removeDesc = L["ROLLS_REMOVE_DESCRIPTION"]
            },
            actionColumn = {
                desc = L["ROLLS_CHOOSE_ACTION"],
                values = ns.ROLL_OVERRIDE_LABELS,
                get = function(itemIdentifier)
                    return ns.db.profile.ignoredItemsSolo[itemIdentifier]
                end,
                set = function(itemIdentifier, value)
                    ns.db.profile.ignoredItemsSolo[itemIdentifier] = value
                end
            }
        }
    )

    return {
        type = "group",
        name = L["TAB_AUTOMATED_ROLLS"],
        args = {
            description = ns.OptionsDesc(L["ROLLS_DESCRIPTION"], 2),
            spacerAfterDesc = ns.OptionsSpacer(3),
            autoGreed = {
                type = "toggle",
                name = L["ROLLS_ENABLE"],
                width = "full",
                order = 4,
                get = function()
                    return ns.db.profile.autoGreed
                end,
                set = function(_, value)
                    ns.db.profile.autoGreed = value
                    if ns.UpdateMinimapIcon then
                        ns:UpdateMinimapIcon()
                    end
                end
            },
            spacerAfterToggle = ns.OptionsSpacer(5),
            autoGreedThreshold = {
                type = "select",
                name = L["ROLLS_THRESHOLD"],
                style = "dropdown",
                width = "double",
                values = greedThresholdValues,
                order = 6,
                get = function()
                    return ns.db.profile.autoGreedThreshold
                end,
                set = function(_, value)
                    ns.db.profile.autoGreedThreshold = value
                end
            },
            spacerBeforeCustom = ns.OptionsSpacer(9),
            customListHeader = ns.OptionsHeader(L["ROLLS_CUSTOM_LIST"], 10),
            spacerAfterCustomHeader = ns.OptionsSpacer(11),
            customListDesc = ns.OptionsDesc(L["ROLLS_CUSTOM_LIST_DESCRIPTION"], 12),
            spacerAfterCustomDesc = ns.OptionsSpacer(13),
            customListEnable = {
                type = "toggle",
                name = L["ROLLS_CUSTOM_LIST_ENABLE"],
                width = "full",
                order = 14,
                get = function()
                    return ns.db.profile.customRollList
                end,
                set = function(_, value)
                    ns.db.profile.customRollList = value
                end
            },
            customList = {
                type = "group",
                name = "",
                inline = true,
                order = 15,
                args = customListArgs
            }
        }
    }
end