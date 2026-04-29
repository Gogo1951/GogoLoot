--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

function GogoLoot.BuildMasterLooterOptions()
    local currentLootMethod = GogoLoot:SafeGetLootMethod() or "group"
    local currentThreshold = GogoLoot:SafeGetLootThreshold()

    local lootTypeValues = {
        ["freeforall"] = L["LOOT_METHOD_FFA"],
        ["roundrobin"] = L["LOOT_METHOD_ROUND_ROBIN"],
        ["master"] = L["LOOT_METHOD_MASTER"],
        ["group"] = L["LOOT_METHOD_GROUP"],
        ["needbeforegreed"] = L["LOOT_METHOD_NBG"]
    }

    local thresholdValues = {
        [4] = GogoLoot:GetQualityColor(4) .. L["QUALITY_EPIC"] .. "|r",
        [3] = GogoLoot:GetQualityColor(3) .. L["QUALITY_RARE"] .. "|r",
        [2] = GogoLoot:GetQualityColor(2) .. L["QUALITY_UNCOMMON"] .. "|r",
        [1] = GogoLoot:GetQualityColor(1) .. L["QUALITY_COMMON"] .. "|r",
        [0] = GogoLoot:GetQualityColor(0) .. L["QUALITY_POOR"] .. "|r"
    }

    if GogoLoot.isBurningCrusadeClassic then
        thresholdValues[1] = nil
        thresholdValues[0] = nil
    end

    local ignoreListArgs =
        GogoLoot:BuildItemListOptions(
        {
            getSourceTable = function()
                return GogoLootDB.ignoredItemsMaster
            end,
            onRestore = function()
                GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
            end,
            onAdd = function(itemIdentifier)
                GogoLootDB.ignoredItemsMaster[itemIdentifier] = true
            end,
            onRemove = function(itemIdentifier)
                GogoLootDB.ignoredItemsMaster[itemIdentifier] = nil
            end,
            notifyKey = "GogoLoot_MasterLooter",
            labels = {
                restore = L["ML_IGNORE_RESTORE"],
                restoreConfirm = L["ML_IGNORE_RESTORE_CONFIRM"],
                addDesc = L["ML_IGNORE_ADD_DESC"],
                addName = L["ML_IGNORE_ADD"],
                addTooltip = L["ML_IGNORE_ADD_TOOLTIP"],
                removeName = L["ML_IGNORE_REMOVE"],
                removeDesc = L["ML_IGNORE_REMOVE_DESC"]
            }
        }
    )

    local args = {}
    local order = 1

    args.lootType = {
        type = "select",
        name = L["ML_LOOT_TYPE"],
        style = "dropdown",
        values = lootTypeValues,
        order = order,
        disabled = true,
        get = function()
            return currentLootMethod
        end,
        set = function()
        end
    }
    order = order + 1
    args.spacerAfterLootType = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.lootThreshold = {
        type = "select",
        name = L["ML_LOOT_THRESHOLD"],
        style = "dropdown",
        values = thresholdValues,
        order = order,
        disabled = true,
        get = function()
            return currentThreshold
        end,
        set = function()
        end
    }
    order = order + 1
    args.spacerBeforeAuto = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.autoHeader = GogoLoot.OptionsHeader(L["ML_AUTO_HEADER"], order)
    order = order + 1
    args.autoDesc = GogoLoot.OptionsDesc(L["ML_AUTO_DESC"], order)
    order = order + 1
    args.spacerAfterAutoDesc = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.autoMasterLoot = {
        type = "toggle",
        name = L["ML_AUTO_ENABLE"],
        desc = L["ML_AUTO_ENABLE_DESC"],
        width = "full",
        order = order,
        get = function()
            return GogoLootDB.autoMasterLoot
        end,
        set = function(_, value)
            GogoLootDB.autoMasterLoot = value
            if value and not GogoLoot:AreWeMasterLooter() then
                GogoLoot:PrintMessage(L["MSG_NOT_MASTER_LOOTER"])
            end
        end
    }
    order = order + 1
    args.spacerAfterAutoToggle = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.autoMasterLootOutsideInstances = {
        type = "toggle",
        name = L["ML_AUTO_OUTSIDE"],
        width = "full",
        order = order,
        get = function()
            return GogoLootDB.autoMasterLootOutsideInstances
        end,
        set = function(_, value)
            GogoLootDB.autoMasterLootOutsideInstances = value
        end
    }
    order = order + 1
    args.outsideInstancesCaution =
        GogoLoot.OptionsDesc(GogoLoot:GetColor("DISABLED") .. L["ML_AUTO_OUTSIDE_CAUTION"] .. "|r", order)
    order = order + 1
    args.spacerBeforeDest = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.destSubHeader = GogoLoot.OptionsSubHeader(L["ML_DEST_HEADER"], order)
    order = order + 1
    args.destDesc = GogoLoot.OptionsDesc(L["ML_DEST_DESC"], order)
    order = order + 1
    args.spacerAfterDestDesc = GogoLoot.OptionsSpacer(order)
    order = order + 1

    -- Destination dropdowns — one per quality tier at or above loot threshold
    local destinationRarities = {
        {quality = 4, key = "epic", label = L["QUALITY_EPIC"]},
        {quality = 3, key = "rare", label = L["QUALITY_RARE"]},
        {quality = 2, key = "uncommon", label = L["QUALITY_UNCOMMON"]},
        {quality = 1, key = "common", label = L["QUALITY_COMMON"]},
        {quality = 0, key = "poor", label = L["QUALITY_POOR"]}
    }

    for _, entry in ipairs(destinationRarities) do
        local qualityKey = entry.key

        args["dest_" .. qualityKey] = {
            type = "select",
            name = GogoLoot:GetQualityColor(entry.quality) .. entry.label .. "|r",
            desc = string.format(L["ML_DEST_CHOOSE"], entry.label),
            style = "dropdown",
            values = function()
                return GogoLoot:GetGroupMemberNames()
            end,
            order = order,
            hidden = function()
                return entry.quality < currentThreshold
            end,
            get = function()
                return GogoLootDB.destinations[qualityKey]
            end,
            set = function(_, value)
                GogoLootDB.destinations[qualityKey] = value
                if GogoLoot:IsNonSelfDestination(value) and IsInGroup() then
                    GogoLoot:AnnounceDestinationSet(value, qualityKey)
                end
            end
        }
        order = order + 1
        args["spacer_dest_" .. qualityKey] = GogoLoot.OptionsSpacer(order)
        order = order + 1
    end

    args.spacerBeforeIgnore = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.ignoreHeader = GogoLoot.OptionsHeader(L["ML_IGNORE_HEADER"], order)
    order = order + 1
    args.ignoreDesc = GogoLoot.OptionsDesc(L["ML_IGNORE_DESC"], order)
    order = order + 1
    args.spacerAfterIgnoreDesc = GogoLoot.OptionsSpacer(order)
    order = order + 1
    args.ignoreList = {
        type = "group",
        name = "",
        inline = true,
        order = order,
        args = ignoreListArgs
    }

    return {
        type = "group",
        name = L["TAB_MASTER_LOOTER"],
        args = args
    }
end