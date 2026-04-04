--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local ACR = LibStub("AceConfigRegistry-3.0")
local L = GogoLoot.L

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

local function ParseItemInput(rawInput)
    if not rawInput or rawInput == "" then
        return nil
    end

    local numericIdentifier = tonumber(rawInput)
    if numericIdentifier then
        return numericIdentifier
    end

    local fromLink = string.match(rawInput, "item:(%d+)")
    if fromLink then
        return tonumber(fromLink)
    end

    return nil
end

--------------------------------------------------------------------------------
-- Custom Roll List — Dynamic AceConfig Args
--------------------------------------------------------------------------------

local function BuildCustomRollListArgs()
    local args = {}
    local order = 1

    args.restoreDefaults = {
        type = "execute",
        name = L["ROLLS_RESTORE_DEFAULTS"],
        width = "double",
        order = order,
        confirm = true,
        confirmText = L["ROLLS_RESTORE_CONFIRM"],
        func = function()
            GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
            ACR:NotifyChange("GogoLoot_AutomaticRolls")
        end
    }
    order = order + 1

    args.spacerAfterRestore = GogoLoot:OptionsSpacer(order)
    order = order + 1

    args.addItemDesc = GogoLoot:OptionsDesc(L["ROLLS_ADD_ITEM_DESC"], order)
    order = order + 1

    args.addItemInput = {
        type = "input",
        name = L["ROLLS_ADD_ITEM"],
        desc = L["ROLLS_ADD_ITEM_TOOLTIP"],
        order = order,
        get = function()
            return ""
        end,
        set = function(_, value)
            local itemIdentifier = ParseItemInput(value)
            if not itemIdentifier then
                return
            end
            GogoLootDB.ignoredItemsSolo[itemIdentifier] = GogoLoot.MANUAL
            GogoLoot.GetItemInfo(itemIdentifier)
            ACR:NotifyChange("GogoLoot_AutomaticRolls")
        end
    }
    order = order + 1

    args.spacerBeforeItems = GogoLoot:OptionsSpacer(order)
    order = order + 1

    -- Sort by rarity (highest first), then alphabetically by name
    local sortedIdentifiers = {}
    for itemIdentifier in pairs(GogoLootDB.ignoredItemsSolo) do
        table.insert(sortedIdentifiers, itemIdentifier)
    end
    table.sort(
        sortedIdentifiers,
        function(a, b)
            local infoA = GogoLoot:SafeGetItemInfo(a)
            local infoB = GogoLoot:SafeGetItemInfo(b)
            local qualityA = infoA and infoA.quality or -1
            local qualityB = infoB and infoB.quality or -1
            if qualityA ~= qualityB then
                return qualityA > qualityB
            end
            local nameA = infoA and infoA.name or ""
            local nameB = infoB and infoB.name or ""
            if nameA == "" and nameB == "" then
                return a < b
            end
            if nameA == "" then
                return false
            end
            if nameB == "" then
                return true
            end
            return nameA < nameB
        end
    )

    for _, itemIdentifier in ipairs(sortedIdentifiers) do
        local groupKey = "item_" .. itemIdentifier

        args[groupKey] = {
            type = "group",
            name = "",
            inline = true,
            order = order,
            args = {
                label = {
                    type = "input",
                    dialogControl = "GogoLoot_ItemLink",
                    name = "",
                    width = 1.3,
                    order = 1,
                    get = function()
                        return tostring(itemIdentifier)
                    end,
                    set = function()
                    end
                },
                action = {
                    type = "select",
                    name = "",
                    desc = L["ROLLS_CHOOSE_ACTION"],
                    values = GogoLoot.ROLL_OVERRIDE_LABELS,
                    width = 0.7,
                    order = 2,
                    get = function()
                        return GogoLootDB.ignoredItemsSolo[itemIdentifier]
                    end,
                    set = function(_, value)
                        GogoLootDB.ignoredItemsSolo[itemIdentifier] = value
                    end
                },
                remove = {
                    type = "execute",
                    name = L["ROLLS_REMOVE"],
                    desc = L["ROLLS_REMOVE_DESC"],
                    width = 0.6,
                    order = 3,
                    func = function()
                        GogoLootDB.ignoredItemsSolo[itemIdentifier] = nil
                        ACR:NotifyChange("GogoLoot_AutomaticRolls")
                    end
                }
            }
        }
        order = order + 1
    end

    return args
end

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
                args = BuildCustomRollListArgs()
            }
        }
    }
end