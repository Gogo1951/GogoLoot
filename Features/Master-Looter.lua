--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--------------------------------------------------------------------------------

--[[
    Master Loot configuration plumbing:
      * API wrappers for GetLootMethod / GetLootThreshold across Classic and
        modern clients.
      * Eligibility check (WillAutoMasterLoot) shared with Speedy-Loot.lua so
        Speedy Loot defers when this module owns the session.
      * Destination tracking — group roster cleanup when a destination player
        leaves, and the loot type / threshold readout used by the Options
        panel.

    The manual distribution hook and the automated LOOT_OPENED → GiveMasterLoot
    distribution engine (with its UI_ERROR_MESSAGE correlation and Pending
    Announcement Registry) live in Master-Looter-Distribution.lua, which loads
    immediately after this file.

    All chat output to the group routes through ns:Announce, which
    pulls the body template from L[] and applies the target marker and
    add-on name for the channel. This module never calls SendChatMessage
    directly.
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- API Wrappers (Classic Compatibility)
--------------------------------------------------------------------------------

function ns:SafeGetLootMethod()
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

function ns:SafeGetLootThreshold()
    if type(GetLootThreshold) == "function" then
        return GetLootThreshold()
    end
    if C_PartyInfo and type(C_PartyInfo.GetLootThreshold) == "function" then
        return C_PartyInfo.GetLootThreshold()
    end
    return 2
end

--[[
    Only the group leader may change the loot method and threshold, so the
    options dropdowns are editable only for them. UnitIsGroupLeader is the
    Classic surface; guard it in case a build lacks it.
]]
function ns:IsGroupLeader()
    if not IsInGroup() then
        return false
    end
    if type(UnitIsGroupLeader) == "function" then
        return UnitIsGroupLeader("player") and true or false
    end
    return false
end

-- Display name of the group leader, or nil when solo or when the player leads.
function ns:GetGroupLeaderName()
    if not IsInGroup() or type(UnitIsGroupLeader) ~= "function" then
        return nil
    end
    local memberCount = GetNumGroupMembers()
    if IsInRaid() then
        for memberIndex = 1, memberCount do
            local unitIdentifier = "raid" .. memberIndex
            if UnitIsGroupLeader(unitIdentifier) then
                return ns:CapitalizeFirstLetter(ns:GetCleanUnitName(unitIdentifier))
            end
        end
        return nil
    end
    for memberIndex = 1, memberCount - 1 do
        local unitIdentifier = "party" .. memberIndex
        if UnitIsGroupLeader(unitIdentifier) then
            return ns:CapitalizeFirstLetter(ns:GetCleanUnitName(unitIdentifier))
        end
    end
    return nil
end

--[[
    Setters, group-leader only (the game ignores the call otherwise). Selecting
    Master Loot needs a master looter, so default it to the leader who made the
    change; they can reassign from the standard ML window. Classic/TBC expose
    the legacy globals; guard in case a build lacks them.
]]
function ns:SafeSetLootMethod(method)
    if type(SetLootMethod) ~= "function" then
        return
    end
    if method == "master" then
        SetLootMethod("master", UnitName("player"))
    else
        SetLootMethod(method)
    end
end

function ns:SafeSetLootThreshold(threshold)
    if type(SetLootThreshold) == "function" then
        SetLootThreshold(threshold)
    end
end

--------------------------------------------------------------------------------
-- Distribution Eligibility
--------------------------------------------------------------------------------

--[[
    Single shared check used by the distribution engine below (to decide
    whether to run the LOOT_OPENED distribution pass) and by Speedy-Loot.lua
    (to decide whether to defer). Returns true when GogoLoot will own the
    next loot session.
]]

function ns:WillAutoMasterLoot()
    if not ns:AreWeMasterLooter() then
        return false
    end
    if not ns.db or not ns.db.profile.autoMasterLoot then
        return false
    end

    local _, instanceType = GetInstanceInfo()
    local isInsideInstance = (instanceType == "raid" or instanceType == "party")

    if isInsideInstance then
        return true
    end
    return ns.db.profile.autoMasterLootOutsideInstances == true
end

--------------------------------------------------------------------------------
-- Destination Management
--------------------------------------------------------------------------------

function ns:GetGroupMemberNames()
    local memberNames = {["self"] = L["MASTER_LOOTER_DESTINATION_SELF"]}
    local playerName = ns:GetLowercaseUnitName("player")

    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = ns:GetLowercaseUnitName(unitIdentifier)
        if memberName and memberName ~= playerName then
            memberNames[memberName] = ns:CapitalizeFirstLetter(memberName)
        end
    end

    return memberNames
end

function ns:IsNonSelfDestination(targetPlayerName)
    if not targetPlayerName then
        return false
    end
    local targetLower = strlower(targetPlayerName)
    return targetLower ~= "self" and targetLower ~= "player"
end

function ns:AnnounceDestinationSet(targetPlayerName, qualityKey)
    if not IsInGroup() then
        return
    end
    if not ns.db.profile.announceDestinations then
        return
    end
    local displayName = ns:CapitalizeFirstLetter(targetPlayerName)
    local qualityLabel = ns.QUALITY_DISPLAY_NAMES[qualityKey] or ns:CapitalizeFirstLetter(qualityKey)
    ns:Announce(ns:GetGroupChatChannel(), nil, "MESSAGE_DESTINATION_SET", displayName, qualityLabel)
end

local function ResetAllDestinations()
    for quality = 0, 4 do
        local qualityKey = ns.rarityToConfigurationKey[quality]
        if qualityKey then
            ns.db.profile.destinations[qualityKey] = "self"
        end
    end
end

local function GetCurrentGroupMemberLookup()
    local groupMembers = {}
    local myName = ns:GetLowercaseUnitName("player")
    if myName then
        groupMembers[myName] = true
    end
    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = ns:GetLowercaseUnitName(unitIdentifier)
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
    if not ns:AreWeMasterLooter() then
        return
    end

    local groupMembers = GetCurrentGroupMemberLookup()
    local myName = ns:GetCleanUnitName("player")
    local masterLooterDisplayName = ns:CapitalizeFirstLetter(myName)
    local chatChannel = ns:GetGroupChatChannel()

    for quality = 0, 4 do
        local qualityKey = ns.rarityToConfigurationKey[quality]
        if qualityKey then
            local targetPlayerName = ns.db.profile.destinations[qualityKey]
            if ns:IsNonSelfDestination(targetPlayerName) then
                local targetLower = strlower(targetPlayerName)
                if not groupMembers[targetLower] then
                    local leaverDisplayName = ns:CapitalizeFirstLetter(targetPlayerName)
                    local qualityLabel =
                        ns.QUALITY_DISPLAY_NAMES[qualityKey] or ns:CapitalizeFirstLetter(qualityKey)
                    ns.db.profile.destinations[qualityKey] = "self"
                    if ns.db.profile.announceDestinations then
                        ns:Announce(
                            chatChannel,
                            nil,
                            "MESSAGE_DESTINATION_LEFT",
                            leaverDisplayName,
                            masterLooterDisplayName,
                            qualityLabel
                        )
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
--------------------------------------------------------------------------------

local wasInGroup = IsInGroup()

local function RefreshMasterLooterPanel()
    AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.MasterLooter)
end

local function HandleGroupRosterUpdate()
    local isCurrentlyInGroup = IsInGroup()

    -- Reset all destinations when leaving a group
    if wasInGroup and not isCurrentlyInGroup then
        ResetAllDestinations()
        RefreshMasterLooterPanel()
        wasInGroup = false
        return
    end

    wasInGroup = isCurrentlyInGroup

    CheckDestinationsForLeavers()
    RefreshMasterLooterPanel()
end

ns:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", RefreshMasterLooterPanel)
ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
