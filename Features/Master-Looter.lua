--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--
-- Master Loot configuration plumbing:
--   * API wrappers for GetLootMethod / GetLootThreshold across Classic and
--     modern clients.
--   * Eligibility check (WillAutoMasterLoot) shared with Speedy-Loot.lua so
--     Speedy Loot defers when this module owns the session.
--   * Destination tracking — group roster cleanup when a destination player
--     leaves, and the loot type / threshold readout used by the Options panel.
--   * Manual distribution hook — GiveMasterLoot from the candidate dropdown
--     is announced regardless of the announcement threshold.
--
-- The automated LOOT_OPENED → GiveMasterLoot distribution engine and its
-- UI_ERROR_MESSAGE correlation live in Master-Looter-Distribution.lua.
--
-- All chat output to the group routes through GogoLoot:Announce, which
-- pulls the body template from L[] and wraps it in the localized
-- MSG_PREFIX / MSG_SUFFIX. This module never calls SendChatMessage
-- directly.
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
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
-- Distribution Eligibility
-- Single shared check used by Master-Looter-Distribution.lua (to decide
-- whether to run the LOOT_OPENED distribution pass) and by Speedy-Loot.lua
-- (to decide whether to defer). Returns true when GogoLoot will own the
-- next loot session.
--------------------------------------------------------------------------------

function GogoLoot:WillAutoMasterLoot()
    if not GogoLoot:AreWeMasterLooter() then
        return false
    end
    if not GogoLootDB or not GogoLootDB.autoMasterLoot then
        return false
    end

    local _, instanceType = GetInstanceInfo()
    local isInsideInstance = (instanceType == "raid" or instanceType == "party")

    if isInsideInstance then
        return true
    end
    return GogoLootDB.autoMasterLootOutsideInstances == true
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
    if not GogoLootDB.announceDestinations then
        return
    end
    local displayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
    GogoLoot:Announce(GogoLoot:GetGroupChatChannel(), nil, "MSG_DESTINATION_SET", displayName, qualityLabel)
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
    local masterLooterDisplayName = GogoLoot:CapitalizeFirstLetter(myName)
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
                    if GogoLootDB.announceDestinations then
                        GogoLoot:Announce(
                            chatChannel,
                            nil,
                            "MSG_DESTINATION_LEFT",
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
-- Manual Distribution Hook
-- Items distributed manually via the standard ML candidate dropdown announce
-- only when announceMasterLootManual is on AND the item meets the manual
-- threshold. Manual is intentionally separated from auto (see
-- Options-Announcements.lua) so the user can keep a low manual threshold
-- for transparency without spamming chat with every auto-routed green.
-- The automated path in Master-Looter-Distribution.lua passes `true` as the
-- third argument to GiveMasterLoot so this hook can tell them apart and
-- skip — automated announcements are registered by TryDistributeSlot.
--
-- Announce timing: GiveMasterLoot returns immediately, but the server only
-- confirms success on a subsequent frame (slot clears) or surfaces a
-- failure via UI_ERROR_MESSAGE. Announcing inline here would produce a
-- "Gave X to Y" line before the delivery succeeded, and a retry after a
-- failure would announce twice. Instead we register a pending entry keyed
-- by slot; Master-Looter-Distribution.lua's LOOT_SLOT_CLEARED handler
-- emits MSG_LOOT_ANNOUNCE only when the server has actually cleared the
-- slot. A retry on the same slot overwrites the prior entry so the
-- announcement always reflects the recipient of the successful delivery.
--
-- If item info hasn't been cached yet (rare on a manual click but possible),
-- we fail open and register the pending announcement anyway — the user
-- clicked the dropdown deliberately, so silence is the worse failure mode.
--------------------------------------------------------------------------------

if type(GiveMasterLoot) == "function" then
    hooksecurefunc(
        "GiveMasterLoot",
        function(slotIndex, candidateIndex, isAutomated)
            if isAutomated then
                return
            end
            if not GogoLootDB or not GogoLootDB.announceMasterLootManual then
                return
            end
            if not GogoLoot:AreWeMasterLooter() then
                return
            end
            if not IsInGroup() then
                return
            end

            local lootLink = GetLootSlotLink(slotIndex)
            if not lootLink then
                return
            end

            -- Manual threshold filter
            local parsedLink = GogoLoot:ParseItemLink(lootLink)
            if parsedLink and parsedLink.itemIdentifier then
                local itemInfo = GogoLoot:SafeGetItemInfo(parsedLink.itemIdentifier)
                if itemInfo and itemInfo.quality < GogoLootDB.announceMasterLootManualThreshold then
                    return
                end
            end

            local candidateName = GetMasterLootCandidate(slotIndex, candidateIndex)
            if not candidateName then
                return
            end

            local displayName = GogoLoot:CapitalizeFirstLetter(strlower(candidateName))
            GogoLoot:RegisterPendingLootAnnouncement(slotIndex, lootLink, displayName)
        end
    )
end

--------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
--------------------------------------------------------------------------------

local wasInGroup = IsInGroup()

local function RefreshMasterLooterPanel()
    ACR:NotifyChange("GogoLoot_MasterLooter")
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

GogoLoot:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", RefreshMasterLooterPanel)
GogoLoot:RegisterModuleEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
