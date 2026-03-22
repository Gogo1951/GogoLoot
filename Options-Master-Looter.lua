-------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
-------------------------------------------------------------------------------
local ACR = LibStub("AceConfigRegistry-3.0")

-------------------------------------------------------------------------------
-- API Wrappers (Classic Compatibility)
-------------------------------------------------------------------------------
local function SafeGetLootMethod()
    if type(GetLootMethod) == "function" then
        return GetLootMethod()
    elseif C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
        local method = C_PartyInfo.GetLootMethod()
        if Enum and Enum.LootMethod then
            if method == Enum.LootMethod.FreeForAll then return "freeforall" end
            if method == Enum.LootMethod.RoundRobin then return "roundrobin" end
            if method == Enum.LootMethod.MasterLoot then return "master" end
            if method == Enum.LootMethod.GroupLoot then return "group" end
            if method == Enum.LootMethod.NeedBeforeGreed then return "needbeforegreed" end
        end
        if method == 0 then return "freeforall" end
        if method == 1 then return "roundrobin" end
        if method == 2 then return "master" end
        if method == 3 then return "group" end
        if method == 4 then return "needbeforegreed" end
    end
    return "group"
end

local function SafeGetLootThreshold()
    if type(GetLootThreshold) == "function" then return GetLootThreshold() end
    if C_PartyInfo and type(C_PartyInfo.GetLootThreshold) == "function" then
        return C_PartyInfo.GetLootThreshold()
    end
    return 2
end

-------------------------------------------------------------------------------
-- Destination Management
-------------------------------------------------------------------------------
local function GetGroupMemberNames()
    local memberNames = { ["self"] = "Self" }
    local playerName = GogoLoot:GetLowercaseUnitName("player")

    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = GogoLoot:GetLowercaseUnitName(unitIdentifier)
        if memberName and memberName ~= playerName then
            memberNames[memberName] = GogoLoot:CapitalizeFirstLetter(memberName)
        end
    end

    return memberNames
end

local function IsNonSelfDestination(targetPlayerName)
    if not targetPlayerName then return false end
    local targetLower = strlower(targetPlayerName)
    return targetLower ~= "self" and targetLower ~= "player"
end

local function AnnounceDestinationSet(targetPlayerName, qualityKey)
    if not IsInGroup() then return end
    local displayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
    local message = string.format(GogoLoot.MESSAGE_DESTINATION_SET, displayName, qualityLabel)
    SendChatMessage(message, GogoLoot:GetGroupChatChannel())
end

local function ResetAllDestinations()
    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            GogoLoot_Configuration.destinations[qualityKey] = "self"
        end
    end
end

local function GetCurrentGroupMemberLookup()
    local groupMembers = {}
    local myName = GogoLoot:GetLowercaseUnitName("player")
    if myName then groupMembers[myName] = true end
    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = GogoLoot:GetLowercaseUnitName(unitIdentifier)
        if memberName then groupMembers[memberName] = true end
    end
    return groupMembers
end

local function CheckDestinationsForLeavers()
    if not IsInGroup() then return end
    if not GogoLoot:AreWeMasterLooter() then return end

    local groupMembers = GetCurrentGroupMemberLookup()
    local myName = GogoLoot:GetCleanUnitName("player")
    local mlDisplayName = GogoLoot:CapitalizeFirstLetter(myName)
    local chatChannel = GogoLoot:GetGroupChatChannel()

    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            local targetPlayerName = GogoLoot_Configuration.destinations[qualityKey]
            if IsNonSelfDestination(targetPlayerName) then
                local targetLower = strlower(targetPlayerName)
                if not groupMembers[targetLower] then
                    local leaverDisplayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
                    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
                    GogoLoot_Configuration.destinations[qualityKey] = "self"
                    local message = string.format(GogoLoot.MESSAGE_DESTINATION_LEFT, leaverDisplayName, mlDisplayName, qualityLabel)
                    SendChatMessage(message, chatChannel)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Item Input Parsing
-------------------------------------------------------------------------------
local function ParseItemInput(rawInput)
    if not rawInput or rawInput == "" then return nil end

    local numericIdentifier = tonumber(rawInput)
    if numericIdentifier then return numericIdentifier end

    local fromLink = string.match(rawInput, "item:(%d+)")
    if fromLink then return tonumber(fromLink) end

    return nil
end

-------------------------------------------------------------------------------
-- Master Ignore List — Dynamic AceConfig Args
-------------------------------------------------------------------------------
local function BuildMasterIgnoreListArgs()
    local args = {}
    local order = 1

    args.restoreDefaults = {
        type    = "execute",
        name    = "Restore Default Ignore List",
        width   = "double",
        order   = order,
        confirm = true,
        confirmText = "This will replace your master loot ignore list with the default items for your expansion. Continue?",
        func    = function()
            GogoLoot_Configuration.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
            ACR:NotifyChange("GogoLoot_MasterLooter")
        end,
    }
    order = order + 1

    args.spacerAfterRestore = GogoLoot:OptionsSpacer(order)
    order = order + 1

    args.addItemDesc = GogoLoot:OptionsDesc(
        "Enter an Item ID or paste an item link to add it to the ignore list.",
        order
    )
    order = order + 1

    args.addItemInput = {
        type  = "input",
        name  = "Add Item",
        desc  = "Enter Item ID or drag an item link here.",
        order = order,
        get   = function() return "" end,
        set   = function(_, value)
            local itemIdentifier = ParseItemInput(value)
            if not itemIdentifier then return end
            GogoLoot_Configuration.ignoredItemsMaster[itemIdentifier] = true
            GogoLoot.GetItemInfo(itemIdentifier)
            ACR:NotifyChange("GogoLoot_MasterLooter")
        end,
    }
    order = order + 1

    args.spacerBeforeItems = GogoLoot:OptionsSpacer(order)
    order = order + 1

    -- Sort by rarity (highest first), then alphabetically by name
    local sortedIdentifiers = {}
    for itemIdentifier in pairs(GogoLoot_Configuration.ignoredItemsMaster) do
        table.insert(sortedIdentifiers, itemIdentifier)
    end
    table.sort(sortedIdentifiers, function(a, b)
        local infoA = GogoLoot:SafeGetItemInfo(a)
        local infoB = GogoLoot:SafeGetItemInfo(b)
        local qualityA = infoA and infoA.quality or -1
        local qualityB = infoB and infoB.quality or -1
        if qualityA ~= qualityB then return qualityA > qualityB end
        local nameA = infoA and infoA.name or ""
        local nameB = infoB and infoB.name or ""
        if nameA == "" and nameB == "" then return a < b end
        if nameA == "" then return false end
        if nameB == "" then return true end
        return nameA < nameB
    end)

    for _, itemIdentifier in ipairs(sortedIdentifiers) do
        local groupKey = "item_" .. itemIdentifier

        args[groupKey] = {
            type   = "group",
            name   = "",
            inline = true,
            order  = order,
            args   = {
                label = {
                    type          = "input",
                    dialogControl = "GogoLoot_ItemLink",
                    name          = "",
                    width         = 2.0,
                    order         = 1,
                    get           = function() return tostring(itemIdentifier) end,
                    set           = function() end,
                },
                remove = {
                    type  = "execute",
                    name  = "Remove",
                    desc  = "Remove this item from the ignore list.",
                    width = 0.6,
                    order = 2,
                    func  = function()
                        GogoLoot_Configuration.ignoredItemsMaster[itemIdentifier] = nil
                        ACR:NotifyChange("GogoLoot_MasterLooter")
                    end,
                },
            },
        }
        order = order + 1
    end

    return args
end

-------------------------------------------------------------------------------
-- Filtered Threshold Dropdown (respects current loot threshold)
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Options Table Builder
-------------------------------------------------------------------------------
function GogoLoot.BuildMasterLooterOptions()
    local currentLootMethod = SafeGetLootMethod() or "group"
    local currentThreshold = SafeGetLootThreshold()

    local lootTypeValues = {
        ["freeforall"]     = "Free for All",
        ["roundrobin"]     = "Round Robin",
        ["master"]         = "Master Looter",
        ["group"]          = "Group Loot",
        ["needbeforegreed"] = "Need Before Greed",
    }

    local thresholdValues = {
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. "Epic|r",
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. "Rare|r",
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. "Uncommon|r",
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. "Common|r",
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. "Poor|r",
    }

    if GogoLoot.isBurningCrusadeClassic then
        thresholdValues[1] = nil
        thresholdValues[0] = nil
    end

    -- Clamp announce threshold to the game's current loot threshold
    local announceThreshold = GogoLoot_Configuration.announceMasterLootThreshold
    if announceThreshold < currentThreshold then
        GogoLoot_Configuration.announceMasterLootThreshold = currentThreshold
    end

    local announceThresholdOptions = BuildFilteredThresholdOptions(currentThreshold)

    local args = {
        lootType = {
            type     = "select",
            name     = "Loot Type (read-only, change via Game Menu)",
            style    = "dropdown",
            values   = lootTypeValues,
            order    = 1,
            disabled = true,
            get      = function() return currentLootMethod end,
            set      = function() end,
        },
        spacerAfterLootType = GogoLoot:OptionsSpacer(2),

        lootThreshold = {
            type     = "select",
            name     = "Loot Threshold (read-only, change via Game Menu)",
            style    = "dropdown",
            values   = thresholdValues,
            order    = 3,
            disabled = true,
            get      = function() return currentThreshold end,
            set      = function() end,
        },

        spacerBeforeAuto = GogoLoot:OptionsSpacer(4),
        autoHeader = GogoLoot:OptionsHeader("Automated Master Looting", 5),
        autoDesc = GogoLoot:OptionsDesc(
            "Automatically distributes loot to designated players when you are the Master Looter. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped and will appear in a standard loot window.",
            6
        ),
        spacerAfterAutoDesc = GogoLoot:OptionsSpacer(7),

        autoMasterLoot = {
            type  = "toggle",
            name  = "Enable Automated Master Looting In Instances",
            desc  = "Distributes loot to configured destinations automatically.",
            width = "full",
            order = 8,
            get   = function() return GogoLoot_Configuration.autoMasterLoot end,
            set   = function(_, value)
                GogoLoot_Configuration.autoMasterLoot = value
                if value and not GogoLoot:AreWeMasterLooter() then
                    GogoLoot:PrintMessage("You are not currently the Master Looter.")
                end
            end,
        },
        spacerAfterAutoToggle = GogoLoot:OptionsSpacer(9),

        autoMasterLootOutsideInstances = {
            type  = "toggle",
            name  = "Enable Automated Master Looting Outside of Instances",
            width = "full",
            order = 10,
            get   = function() return GogoLoot_Configuration.autoMasterLootOutsideInstances end,
            set   = function(_, value) GogoLoot_Configuration.autoMasterLootOutsideInstances = value end,
        },
        outsideInstancesCaution = GogoLoot:OptionsDesc(
            GogoLoot:GetColor("DISABLED") .. "Caution : Due to world boss loot not being tradable, this is not advised!|r",
            11
        ),

        spacerBeforeDest = GogoLoot:OptionsSpacer(19),
        destSubHeader = GogoLoot:OptionsSubHeader("Loot Destinations", 20),
        destDesc = GogoLoot:OptionsDesc(
            "Assign a group member to receive items of each quality tier.",
            21
        ),
        spacerAfterDestDesc = GogoLoot:OptionsSpacer(22),

        spacerBeforeAnnounce = GogoLoot:OptionsSpacer(39),
        announceHeader = GogoLoot:OptionsHeader("Loot Announcements", 40),
        announceDesc = GogoLoot:OptionsDesc(
            "Posts a message to group chat when items are distributed via Master Loot. Manual distributions are always announced regardless of threshold.",
            41
        ),
        spacerAfterAnnounceDesc = GogoLoot:OptionsSpacer(42),

        announceMasterLoot = {
            type  = "toggle",
            name  = "Enable Loot Announcements",
            desc  = "Announces item distributions to group chat.",
            width = "full",
            order = 43,
            get   = function() return GogoLoot_Configuration.announceMasterLoot end,
            set   = function(_, value) GogoLoot_Configuration.announceMasterLoot = value end,
        },
        spacerAfterAnnounceToggle = GogoLoot:OptionsSpacer(44),

        announceMasterLootThreshold = {
            type   = "select",
            name   = "Announce Threshold",
            desc   = "Only announce items at or above this quality.",
            style  = "dropdown",
            values = announceThresholdOptions,
            order  = 45,
            get    = function() return GogoLoot_Configuration.announceMasterLootThreshold end,
            set    = function(_, value) GogoLoot_Configuration.announceMasterLootThreshold = value end,
        },
        spacerAfterAnnounceThreshold = GogoLoot:OptionsSpacer(46),

        announceExample = GogoLoot:OptionsDesc(
            GogoLoot:GetColor("MUTED") .. "Example: {rt4} Gave [Item X] to Gogowarrior. // GogoLoot|r",
            47
        ),

        spacerBeforeIgnore = GogoLoot:OptionsSpacer(49),
        ignoreHeader = GogoLoot:OptionsHeader("Ignore List", 50),
        ignoreDesc = GogoLoot:OptionsDesc(
            "Items on this list will not be automatically distributed and will appear in a standard loot window for manual assignment.",
            51
        ),
        spacerAfterIgnoreDesc = GogoLoot:OptionsSpacer(52),

        ignoreList = {
            type   = "group",
            name   = "",
            inline = true,
            order  = 53,
            args   = BuildMasterIgnoreListArgs(),
        },
    }

    -- Destination dropdowns — one per quality tier at or above loot threshold
    local destinationRarities = {
        { quality = 4, key = "epic",     label = "Epic",     order = 23 },
        { quality = 3, key = "rare",     label = "Rare",     order = 25 },
        { quality = 2, key = "uncommon", label = "Uncommon", order = 27 },
        { quality = 1, key = "common",   label = "Common",   order = 29 },
        { quality = 0, key = "poor",     label = "Poor",     order = 31 },
    }

    for _, entry in ipairs(destinationRarities) do
        local qualityKey = entry.key
        local colorHex = GogoLoot.QUALITY_COLORS[entry.quality]

        args["dest_" .. qualityKey] = {
            type   = "select",
            name   = "|c" .. colorHex .. entry.label .. "|r",
            desc   = "Choose who receives " .. entry.label .. " items.",
            style  = "dropdown",
            values = function() return GetGroupMemberNames() end,
            order  = entry.order,
            hidden = function() return entry.quality < currentThreshold end,
            get    = function() return GogoLoot_Configuration.destinations[qualityKey] end,
            set    = function(_, value)
                GogoLoot_Configuration.destinations[qualityKey] = value
                if IsNonSelfDestination(value) and IsInGroup() then
                    AnnounceDestinationSet(value, qualityKey)
                end
            end,
        }
        args["spacer_dest_" .. qualityKey] = GogoLoot:OptionsSpacer(entry.order + 1)
    end

    return {
        type = "group",
        name = "Master Looter",
        args = args,
    }
end

-------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
-------------------------------------------------------------------------------
local wasMasterLooter = false
local wasInGroup = IsInGroup() or false

local function RefreshMasterLooterPanel()
    ACR:NotifyChange("GogoLoot_MasterLooter")
end

local function CheckMasterLooterStatus()
    local isMasterLooter = GogoLoot:AreWeMasterLooter()
    if isMasterLooter and not wasMasterLooter then
        GogoLoot:OpenOptionsPanel("masterlooter")
    end
    wasMasterLooter = isMasterLooter
    RefreshMasterLooterPanel()
end

local function HandleGroupRosterUpdate()
    local isCurrentlyInGroup = IsInGroup()

    -- Reset all destinations when leaving a group
    if wasInGroup and not isCurrentlyInGroup then
        ResetAllDestinations()
        wasMasterLooter = false
        RefreshMasterLooterPanel()
        wasInGroup = false
        return
    end

    wasInGroup = isCurrentlyInGroup

    CheckDestinationsForLeavers()
    RefreshMasterLooterPanel()
end

GogoLoot:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", CheckMasterLooterStatus)
GogoLoot:RegisterModuleEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)