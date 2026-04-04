--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
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
-- Master Ignore List — Dynamic AceConfig Args
--------------------------------------------------------------------------------

local function BuildMasterIgnoreListArgs()
    local args = {}
    local order = 1

    args.restoreDefaults = {
        type = "execute",
        name = L["ML_IGNORE_RESTORE"],
        width = "double",
        order = order,
        confirm = true,
        confirmText = L["ML_IGNORE_RESTORE_CONFIRM"],
        func = function()
            GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
            ACR:NotifyChange("GogoLoot_MasterLooter")
        end
    }
    order = order + 1

    args.spacerAfterRestore = GogoLoot:OptionsSpacer(order)
    order = order + 1

    args.addItemDesc = GogoLoot:OptionsDesc(L["ML_IGNORE_ADD_DESC"], order)
    order = order + 1

    args.addItemInput = {
        type = "input",
        name = L["ML_IGNORE_ADD"],
        desc = L["ML_IGNORE_ADD_TOOLTIP"],
        order = order,
        get = function()
            return ""
        end,
        set = function(_, value)
            local itemIdentifier = ParseItemInput(value)
            if not itemIdentifier then
                return
            end
            GogoLootDB.ignoredItemsMaster[itemIdentifier] = true
            GogoLoot.GetItemInfo(itemIdentifier)
            ACR:NotifyChange("GogoLoot_MasterLooter")
        end
    }
    order = order + 1

    args.spacerBeforeItems = GogoLoot:OptionsSpacer(order)
    order = order + 1

    -- Sort by rarity (highest first), then alphabetically by name
    local sortedIdentifiers = {}
    for itemIdentifier in pairs(GogoLootDB.ignoredItemsMaster) do
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
                    width = 2.0,
                    order = 1,
                    get = function()
                        return tostring(itemIdentifier)
                    end,
                    set = function()
                    end
                },
                remove = {
                    type = "execute",
                    name = L["ML_IGNORE_REMOVE"],
                    desc = L["ML_IGNORE_REMOVE_DESC"],
                    width = 0.6,
                    order = 2,
                    func = function()
                        GogoLootDB.ignoredItemsMaster[itemIdentifier] = nil
                        ACR:NotifyChange("GogoLoot_MasterLooter")
                    end
                }
            }
        }
        order = order + 1
    end

    return args
end

--------------------------------------------------------------------------------
-- Filtered Threshold Dropdown (respects current loot threshold)
--------------------------------------------------------------------------------

local function BuildFilteredThresholdOptions(minimumQuality)
    local filteredOptions = {}
    for quality = minimumQuality, 4 do
        local colorHex = GogoLoot.QUALITY_COLORS[quality]
        local rarityKey = GogoLoot.rarityToConfigurationKey[quality]
        local displayName = GogoLoot:CapitalizeFirstLetter(rarityKey) .. "+"
        filteredOptions[quality] = "|c" .. colorHex .. displayName .. "|r"
    end
    return filteredOptions
end

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
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. L["QUALITY_EPIC"] .. "|r",
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. L["QUALITY_RARE"] .. "|r",
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. L["QUALITY_UNCOMMON"] .. "|r",
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. L["QUALITY_COMMON"] .. "|r",
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. L["QUALITY_POOR"] .. "|r"
    }

    if GogoLoot.isBurningCrusadeClassic then
        thresholdValues[1] = nil
        thresholdValues[0] = nil
    end

    -- Clamp announce threshold to the game's current loot threshold
    local announceThreshold = GogoLootDB.announceMasterLootThreshold
    if announceThreshold < currentThreshold then
        GogoLootDB.announceMasterLootThreshold = currentThreshold
    end

    local announceThresholdOptions = BuildFilteredThresholdOptions(currentThreshold)

    local args = {
        lootType = {
            type = "select",
            name = L["ML_LOOT_TYPE"],
            style = "dropdown",
            values = lootTypeValues,
            order = 1,
            disabled = true,
            get = function()
                return currentLootMethod
            end,
            set = function()
            end
        },
        spacerAfterLootType = GogoLoot:OptionsSpacer(2),
        lootThreshold = {
            type = "select",
            name = L["ML_LOOT_THRESHOLD"],
            style = "dropdown",
            values = thresholdValues,
            order = 3,
            disabled = true,
            get = function()
                return currentThreshold
            end,
            set = function()
            end
        },
        spacerBeforeAuto = GogoLoot:OptionsSpacer(4),
        autoHeader = GogoLoot:OptionsHeader(L["ML_AUTO_HEADER"], 5),
        autoDesc = GogoLoot:OptionsDesc(L["ML_AUTO_DESC"], 6),
        spacerAfterAutoDesc = GogoLoot:OptionsSpacer(7),
        autoMasterLoot = {
            type = "toggle",
            name = L["ML_AUTO_ENABLE"],
            desc = L["ML_AUTO_ENABLE_DESC"],
            width = "full",
            order = 8,
            get = function()
                return GogoLootDB.autoMasterLoot
            end,
            set = function(_, value)
                GogoLootDB.autoMasterLoot = value
                if value and not GogoLoot:AreWeMasterLooter() then
                    GogoLoot:PrintMessage(L["MSG_NOT_MASTER_LOOTER"])
                end
            end
        },
        spacerAfterAutoToggle = GogoLoot:OptionsSpacer(9),
        autoMasterLootOutsideInstances = {
            type = "toggle",
            name = L["ML_AUTO_OUTSIDE"],
            width = "full",
            order = 10,
            get = function()
                return GogoLootDB.autoMasterLootOutsideInstances
            end,
            set = function(_, value)
                GogoLootDB.autoMasterLootOutsideInstances = value
            end
        },
        outsideInstancesCaution = GogoLoot:OptionsDesc(
            GogoLoot:GetColor("DISABLED") .. L["ML_AUTO_OUTSIDE_CAUTION"] .. "|r",
            11
        ),
        spacerBeforeDest = GogoLoot:OptionsSpacer(19),
        destSubHeader = GogoLoot:OptionsSubHeader(L["ML_DEST_HEADER"], 20),
        destDesc = GogoLoot:OptionsDesc(L["ML_DEST_DESC"], 21),
        spacerAfterDestDesc = GogoLoot:OptionsSpacer(22),
        spacerBeforeAnnounce = GogoLoot:OptionsSpacer(39),
        announceHeader = GogoLoot:OptionsHeader(L["ML_ANNOUNCE_HEADER"], 40),
        announceDesc = GogoLoot:OptionsDesc(L["ML_ANNOUNCE_DESC"], 41),
        spacerAfterAnnounceDesc = GogoLoot:OptionsSpacer(42),
        announceMasterLoot = {
            type = "toggle",
            name = L["ML_ANNOUNCE_ENABLE"],
            desc = L["ML_ANNOUNCE_ENABLE_DESC"],
            width = "full",
            order = 43,
            get = function()
                return GogoLootDB.announceMasterLoot
            end,
            set = function(_, value)
                GogoLootDB.announceMasterLoot = value
            end
        },
        spacerAfterAnnounceToggle = GogoLoot:OptionsSpacer(44),
        announceMasterLootThreshold = {
            type = "select",
            name = L["ML_ANNOUNCE_THRESHOLD"],
            desc = L["ML_ANNOUNCE_THRESHOLD_DESC"],
            style = "dropdown",
            values = announceThresholdOptions,
            order = 45,
            get = function()
                return GogoLootDB.announceMasterLootThreshold
            end,
            set = function(_, value)
                GogoLootDB.announceMasterLootThreshold = value
            end
        },
        spacerAfterAnnounceThreshold = GogoLoot:OptionsSpacer(46),
        announceExample = GogoLoot:OptionsDesc(GogoLoot:GetColor("MUTED") .. L["ML_ANNOUNCE_EXAMPLE"] .. "|r", 47),
        spacerBeforeIgnore = GogoLoot:OptionsSpacer(49),
        ignoreHeader = GogoLoot:OptionsHeader(L["ML_IGNORE_HEADER"], 50),
        ignoreDesc = GogoLoot:OptionsDesc(L["ML_IGNORE_DESC"], 51),
        spacerAfterIgnoreDesc = GogoLoot:OptionsSpacer(52),
        ignoreList = {
            type = "group",
            name = "",
            inline = true,
            order = 53,
            args = BuildMasterIgnoreListArgs()
        }
    }

    -- Destination dropdowns — one per quality tier at or above loot threshold
    local destinationRarities = {
        {quality = 4, key = "epic", label = L["QUALITY_EPIC"], order = 23},
        {quality = 3, key = "rare", label = L["QUALITY_RARE"], order = 25},
        {quality = 2, key = "uncommon", label = L["QUALITY_UNCOMMON"], order = 27},
        {quality = 1, key = "common", label = L["QUALITY_COMMON"], order = 29},
        {quality = 0, key = "poor", label = L["QUALITY_POOR"], order = 31}
    }

    for _, entry in ipairs(destinationRarities) do
        local qualityKey = entry.key
        local colorHex = GogoLoot.QUALITY_COLORS[entry.quality]

        args["dest_" .. qualityKey] = {
            type = "select",
            name = "|c" .. colorHex .. entry.label .. "|r",
            desc = string.format(L["ML_DEST_CHOOSE"], entry.label),
            style = "dropdown",
            values = function()
                return GogoLoot:GetGroupMemberNames()
            end,
            order = entry.order,
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
        args["spacer_dest_" .. qualityKey] = GogoLoot:OptionsSpacer(entry.order + 1)
    end

    return {
        type = "group",
        name = "Master Looter",
        args = args
    }
end