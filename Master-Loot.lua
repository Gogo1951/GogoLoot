--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--------------------------------------------------------------------------------
local L = GogoLoot.L
local ACR = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- API Wrappers (Classic Compatibility)
--------------------------------------------------------------------------------

function GogoLoot:SafeGetLootMethod()
    if type(GetLootMethod) == "function" then
        return GetLootMethod()
    elseif C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
        local method = C_PartyInfo.GetLootMethod()
        if Enum and Enum.LootMethod then
            if method == Enum.LootMethod.FreeForAll then
                return "freeforall"
            end
            if method == Enum.LootMethod.RoundRobin then
                return "roundrobin"
            end
            if method == Enum.LootMethod.MasterLoot then
                return "master"
            end
            if method == Enum.LootMethod.GroupLoot then
                return "group"
            end
            if method == Enum.LootMethod.NeedBeforeGreed then
                return "needbeforegreed"
            end
        end
        if method == 0 then
            return "freeforall"
        end
        if method == 1 then
            return "roundrobin"
        end
        if method == 2 then
            return "master"
        end
        if method == 3 then
            return "group"
        end
        if method == 4 then
            return "needbeforegreed"
        end
    end
    return "group"
end

function GogoLoot:SafeGetLootThreshold()
    if type(GetLootThreshold) == "function" then
        return GetLootThreshold()
    end
    if C_PartyInfo and type(C_PartyInfo.GetLootThreshold) == "function" then
        return C_PartyInfo.GetLootThreshold()
    end
    return 2
end

--------------------------------------------------------------------------------
-- Destination Management
--------------------------------------------------------------------------------

function GogoLoot:GetGroupMemberNames()
    local memberNames = {["self"] = L["ML_DEST_SELF"]}
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

function GogoLoot:IsNonSelfDestination(targetPlayerName)
    if not targetPlayerName then
        return false
    end
    local targetLower = strlower(targetPlayerName)
    return targetLower ~= "self" and targetLower ~= "player"
end

function GogoLoot:AnnounceDestinationSet(targetPlayerName, qualityKey)
    if not IsInGroup() then
        return
    end
    local displayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
    local message = string.format(GogoLoot.MESSAGE_DESTINATION_SET, displayName, qualityLabel)
    SendChatMessage(message, GogoLoot:GetGroupChatChannel())
end

local function ResetAllDestinations()
    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            GogoLootDB.destinations[qualityKey] = "self"
        end
    end
end

local function GetCurrentGroupMemberLookup()
    local groupMembers = {}
    local myName = GogoLoot:GetLowercaseUnitName("player")
    if myName then
        groupMembers[myName] = true
    end
    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = GogoLoot:GetLowercaseUnitName(unitIdentifier)
        if memberName then
            groupMembers[memberName] = true
        end
    end
    return groupMembers
end

local function CheckDestinationsForLeavers()
    if not IsInGroup() then
        return
    end
    if not GogoLoot:AreWeMasterLooter() then
        return
    end

    local groupMembers = GetCurrentGroupMemberLookup()
    local myName = GogoLoot:GetCleanUnitName("player")
    local mlDisplayName = GogoLoot:CapitalizeFirstLetter(myName)
    local chatChannel = GogoLoot:GetGroupChatChannel()

    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            local targetPlayerName = GogoLootDB.destinations[qualityKey]
            if GogoLoot:IsNonSelfDestination(targetPlayerName) then
                local targetLower = strlower(targetPlayerName)
                if not groupMembers[targetLower] then
                    local leaverDisplayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
                    local qualityLabel =
                        GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
                    GogoLootDB.destinations[qualityKey] = "self"
                    local message =
                        string.format(GogoLoot.MESSAGE_DESTINATION_LEFT, leaverDisplayName, mlDisplayName, qualityLabel)
                    SendChatMessage(message, chatChannel)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
--------------------------------------------------------------------------------

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