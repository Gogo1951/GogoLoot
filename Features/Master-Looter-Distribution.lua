--------------------------------------------------------------------------------
-- GogoLoot Master Loot Distribution Engine
--
-- On LOOT_OPENED in ML mode, walks the loot list and uses GiveMasterLoot
-- to assign each at-or-above-threshold item to the player configured in
-- GogoLootDB.destinations for its quality tier.
--
-- Skipped items (legendaries, quest items, recipes, mounts, pets, anything
-- in the ignore list, BoP outside trade-eligible instances) are left in
-- the standard loot frame for manual handling.
--
-- Initial pass + retry ticker: GetMasterLootCandidate occasionally returns
-- nil for the first frame or two after LOOT_OPENED while the server is
-- populating candidate data, and SafeGetItemInfo returns nil until the
-- client caches the item. The ticker re-runs the pass until either
-- everything resolves or DISTRIBUTION_QUIET_TICKS consecutive ticks pass
-- with no progress (meaning the rest is genuinely unhandleable here and
-- belongs in the standard window).
--
-- Announcement timing: GiveMasterLoot returns immediately; success or
-- failure is reported asynchronously by the server. Announcing inline
-- with the call would post "Gave X to Y" before the server confirms,
-- so a failed delivery (bag full, out of range, retried with a different
-- player) would still produce the message and could even be sent twice
-- if the user retried after the failure. Instead, both the auto path
-- (TryDistributeSlot) and the manual path (the GiveMasterLoot hook in
-- Master-Looter.lua, via RegisterPendingLootAnnouncement) record a
-- pending announcement keyed by slot, and only the LOOT_SLOT_CLEARED
-- handler emits MSG_LOOT_ANNOUNCE — which fires only on confirmed
-- successful distribution. Failures never clear the slot, so they
-- never announce. LOOT_CLOSED wipes any remaining pending entries so
-- nothing leaks into the next loot session.
--
-- Error correlation: GiveMasterLoot can fail silently from the API
-- caller's perspective — the failure surfaces as a UI_ERROR_MESSAGE on a
-- subsequent frame. We correlate the error string to the pending
-- distribution and, if it matches a known failure mode, post the
-- corresponding ERR_* announcement (with the item link and target name
-- substituted in) so the group sees which delivery failed and why.
-- Unknown errors are left alone; we don't want to spam chat for unrelated
-- UI errors that happen to fire during the correlation window.
--
-- Dependencies: GogoLoot:WillAutoMasterLoot is defined in Master-Looter.lua,
-- which loads first. The call happens at LOOT_OPENED time so file load
-- order is not strictly required, but the convention is dependency-first.
--------------------------------------------------------------------------------

local DISTRIBUTION_RETRY_INTERVAL = 0.1
local DISTRIBUTION_MAX_RETRIES = 20
local DISTRIBUTION_QUIET_TICKS = 3
local PENDING_ERROR_WINDOW = 1.0

local lootDistributionTicker = nil
local distributedSlots = {}
local pendingDistribution = nil
local pendingAnnouncements = {}
local lootIsOpen = false
local quietTickCount = 0

--------------------------------------------------------------------------------
-- Pending Announcement Registry
-- Keyed by loot slot index. Both the auto path (TryDistributeSlot) and the
-- manual path (the GiveMasterLoot hook in Master-Looter.lua) call
-- RegisterPendingLootAnnouncement after issuing GiveMasterLoot. The
-- LOOT_SLOT_CLEARED handler below consumes the entry and emits the
-- announcement only when the server has actually cleared the slot.
--
-- A retry on the same slot (e.g., user picked a new candidate after the
-- first failed) overwrites the prior entry, so the announcement always
-- reflects the recipient of the successful delivery.
--------------------------------------------------------------------------------

function GogoLoot:RegisterPendingLootAnnouncement(slotIndex, itemLink, displayName)
    if not slotIndex or not itemLink or not displayName then
        return
    end
    pendingAnnouncements[slotIndex] = {
        itemLink = itemLink,
        displayName = displayName
    }
end

--------------------------------------------------------------------------------
-- Distribution State
--------------------------------------------------------------------------------

local function ClearDistributionState()
    distributedSlots = {}
    pendingDistribution = nil
    pendingAnnouncements = {}
    quietTickCount = 0
    if lootDistributionTicker then
        lootDistributionTicker:Cancel()
        lootDistributionTicker = nil
    end
end

local function BuildCandidateMap()
    local map = {}
    local numItems = GetNumLootItems()
    local groupSize = GetNumGroupMembers()
    for slotIndex = 1, numItems do
        map[slotIndex] = {}
        for groupIndex = 1, groupSize do
            local candidateName = GetMasterLootCandidate(slotIndex, groupIndex)
            if candidateName then
                map[slotIndex][strlower(candidateName)] = groupIndex
            end
        end
    end
    return map
end

local function ResolveDestinationCandidate(qualityKey, slotCandidates)
    local destinationName = GogoLootDB.destinations[qualityKey]
    if not destinationName or destinationName == "" then
        return nil, nil
    end

    local resolvedName = destinationName
    if destinationName == "self" then
        resolvedName = GogoLoot:GetLowercaseUnitName("player")
    end
    if not resolvedName then
        return nil, nil
    end

    local lookupKey = strlower(resolvedName)
    local candidateIndex = slotCandidates[lookupKey]
    return resolvedName, candidateIndex
end

--------------------------------------------------------------------------------
-- Distribution Pass
--------------------------------------------------------------------------------

local function TryDistributeSlot(slotIndex, candidateMap)
    if distributedSlots[slotIndex] then
        return false
    end

    local lootLink = GetLootSlotLink(slotIndex)
    if not lootLink then
        -- Gold or empty slot — let standard auto-loot handle it
        return false
    end

    local parsedLink = GogoLoot:ParseItemLink(lootLink)
    if not parsedLink or not parsedLink.itemIdentifier then
        return false
    end

    local itemId = parsedLink.itemIdentifier
    local itemInfo = GogoLoot:SafeGetItemInfo(itemId)
    if not itemInfo then
        -- Item info not yet cached — the retry ticker will pick this up
        return false
    end

    -- Hard skip: legendaries, quest items, recipes, mounts, pets
    if GogoLoot:ShouldSkipItemByType(itemInfo) then
        return false
    end

    -- User-configured ignore list
    if GogoLootDB.ignoredItemsMaster[itemId] then
        return false
    end

    -- BoP items can only be redistributed inside trade-eligible instances
    if itemInfo.bindType == GogoLoot.BIND_ON_PICKUP and not GogoLoot:IsInBindOnPickupTradeInstance() then
        return false
    end

    local qualityKey = GogoLoot.rarityToConfigurationKey[itemInfo.quality]
    if not qualityKey then
        return false
    end

    local slotCandidates = candidateMap[slotIndex]
    if not slotCandidates then
        return false
    end

    local resolvedName, candidateIndex = ResolveDestinationCandidate(qualityKey, slotCandidates)
    if not candidateIndex then
        -- Destination isn't a valid candidate for this slot (out of range,
        -- different sub-group, no longer in group, etc.). Leave it for
        -- manual handling rather than silently re-routing.
        return false
    end

    local displayName = GogoLoot:CapitalizeFirstLetter(resolvedName)

    -- Record context for the UI_ERROR_MESSAGE handler before the call —
    -- the error fires on a subsequent frame and needs to know what we tried.
    pendingDistribution = {
        slotIndex = slotIndex,
        targetName = displayName,
        itemLink = lootLink,
        itemQuality = itemInfo.quality,
        timestamp = GetTime()
    }

    distributedSlots[slotIndex] = true
    GiveMasterLoot(slotIndex, candidateIndex, true)

    -- Defer the announcement until LOOT_SLOT_CLEARED confirms a successful
    -- distribution. The auto toggle / threshold gate fires here at register
    -- time so we don't accumulate pending entries for items the user didn't
    -- want announced. Manual distributions go through the GiveMasterLoot
    -- hook in Master-Looter.lua and use a separate toggle + threshold.
    if
        GogoLootDB.announceMasterLootAuto and itemInfo.quality >= GogoLootDB.announceMasterLootAutoThreshold and
            IsInGroup()
     then
        GogoLoot:RegisterPendingLootAnnouncement(slotIndex, lootLink, displayName)
    end

    return true
end

local function RunDistributionPass()
    if not lootIsOpen then
        return false
    end

    local candidateMap = BuildCandidateMap()
    local numItems = GetNumLootItems()
    local distributedAny = false

    -- Iterate from the bottom upward so that as slots are consumed, the
    -- remaining indices we still care about don't shift.
    for slotIndex = numItems, 1, -1 do
        if not distributedSlots[slotIndex] then
            if TryDistributeSlot(slotIndex, candidateMap) then
                distributedAny = true
            end
        end
    end

    return distributedAny
end

local function StartDistributionTicker()
    if lootDistributionTicker then
        return
    end

    local retries = 0
    quietTickCount = 0

    lootDistributionTicker =
        C_Timer.NewTicker(
        DISTRIBUTION_RETRY_INTERVAL,
        function(tickerHandle)
            retries = retries + 1
            if not lootIsOpen or retries > DISTRIBUTION_MAX_RETRIES then
                tickerHandle:Cancel()
                lootDistributionTicker = nil
                return
            end

            local distributedAny = RunDistributionPass()
            if distributedAny then
                quietTickCount = 0
            else
                quietTickCount = quietTickCount + 1
                if quietTickCount >= DISTRIBUTION_QUIET_TICKS then
                    tickerHandle:Cancel()
                    lootDistributionTicker = nil
                end
            end
        end
    )
end

--------------------------------------------------------------------------------
-- Loot Window Lifecycle
--------------------------------------------------------------------------------

local function HandleLootOpened()
    lootIsOpen = true
    distributedSlots = {}
    pendingDistribution = nil
    pendingAnnouncements = {}
    quietTickCount = 0

    if not GogoLoot:WillAutoMasterLoot() then
        return
    end

    -- Initial pass — handles items whose info is already cached
    RunDistributionPass()

    -- Retry ticker for cache misses or candidate-map fill-ins
    StartDistributionTicker()
end

local function HandleLootClosed()
    lootIsOpen = false
    ClearDistributionState()
end

--------------------------------------------------------------------------------
-- Distribution Error Handling
--------------------------------------------------------------------------------

local function MapErrorMessageToLocaleKey(errorString)
    if not errorString or errorString == "" then
        return nil
    end

    -- Compare against globalized strings first; these vary by client locale
    -- but are reliable when bound. Some globals don't exist on every WoW
    -- build, so the comparison is safe even when the global is nil.
    if errorString == ERR_INV_FULL or errorString == ERR_LOOT_BAG_FULL then
        return "ERR_BAG_FULL"
    end
    if errorString == ERR_ITEM_MAX_COUNT then
        return "ERR_MAX_COUNT"
    end
    if errorString == ERR_LOOT_PLAYER_NOT_PRESENT or errorString == LOOT_PLAYER_NOT_PRESENT then
        return "ERR_OUT_OF_RANGE"
    end
    if errorString == ERR_NOT_IN_GROUP or errorString == ERR_NOT_IN_RAID then
        return "ERR_NOT_IN_GROUP"
    end

    -- Substring fallbacks for builds where the global isn't bound. Plain
    -- text matches only — no patterns, so locale-specific punctuation
    -- doesn't break things.
    local lowerMessage = string.lower(errorString)
    if string.find(lowerMessage, "bag is full", 1, true) or string.find(lowerMessage, "inventory is full", 1, true) then
        return "ERR_BAG_FULL"
    end
    if string.find(lowerMessage, "more of that item", 1, true) or string.find(lowerMessage, "max count", 1, true) then
        return "ERR_MAX_COUNT"
    end
    if string.find(lowerMessage, "not in range", 1, true) or string.find(lowerMessage, "too far away", 1, true) then
        return "ERR_OUT_OF_RANGE"
    end
    if
        string.find(lowerMessage, "not in your party", 1, true) or
            string.find(lowerMessage, "not in your raid", 1, true)
     then
        return "ERR_NOT_IN_GROUP"
    end

    return nil
end

local function ExtractErrorString(...)
    -- UI_ERROR_MESSAGE signature varies between clients — modern is
    -- (errorType, message); some Classic builds pass (message). Find
    -- the first string argument and use it.
    for argIndex = 1, select("#", ...) do
        local argValue = select(argIndex, ...)
        if type(argValue) == "string" then
            return argValue
        end
    end
    return nil
end

local function HandleUIErrorMessage(...)
    if not pendingDistribution then
        return
    end

    if (GetTime() - pendingDistribution.timestamp) > PENDING_ERROR_WINDOW then
        pendingDistribution = nil
        return
    end

    local errorString = ExtractErrorString(...)
    if not errorString then
        return
    end

    local errorLocaleKey = MapErrorMessageToLocaleKey(errorString)
    if not errorLocaleKey then
        return
    end

    if IsInGroup() then
        GogoLoot:Announce(
            GogoLoot:GetGroupChatChannel(),
            nil,
            errorLocaleKey,
            pendingDistribution.itemLink,
            pendingDistribution.targetName
        )
    end

    -- Drop the success announcement for this slot. The slot didn't clear,
    -- so LOOT_SLOT_CLEARED won't fire for the failed attempt anyway, but
    -- if the user retries this slot with a different candidate the manual
    -- hook will overwrite the entry — clearing it here keeps the state
    -- tidy and removes any chance of a stale pending entry surviving.
    pendingAnnouncements[pendingDistribution.slotIndex] = nil

    -- Cancel the retry ticker — re-attempting a bag-full or max-count
    -- error will just produce the same failure on the next pass.
    if lootDistributionTicker then
        lootDistributionTicker:Cancel()
        lootDistributionTicker = nil
    end

    pendingDistribution = nil
end

--------------------------------------------------------------------------------
-- Successful Distribution Confirmation
-- LOOT_SLOT_CLEARED fires only when the server has actually emptied the
-- slot, which for a master-loot session means the GiveMasterLoot call
-- succeeded. This is the only place MSG_LOOT_ANNOUNCE is emitted —
-- failures (bag full, out of range, target left group) never reach here
-- because the slot stays populated, so a failed click cannot produce a
-- "Gave X to Y" line.
--
-- The same slot index can fire LOOT_SLOT_CLEARED for non-ML reasons too
-- (the player picked up the item themselves, etc.). We only act if a
-- pending entry exists for that slot, so unrelated clears are no-ops.
--------------------------------------------------------------------------------

local function HandleLootSlotCleared(slotIndex)
    if not slotIndex then
        return
    end

    local pending = pendingAnnouncements[slotIndex]
    if not pending then
        return
    end
    pendingAnnouncements[slotIndex] = nil

    if not IsInGroup() then
        return
    end

    GogoLoot:Announce(
        GogoLoot:GetGroupChatChannel(),
        nil,
        "MSG_LOOT_ANNOUNCE",
        pending.itemLink,
        pending.displayName
    )
end

--------------------------------------------------------------------------------
-- Event Registrations
--------------------------------------------------------------------------------

GogoLoot:RegisterModuleEvent("LOOT_OPENED", HandleLootOpened)
GogoLoot:RegisterModuleEvent("LOOT_CLOSED", HandleLootClosed)
GogoLoot:RegisterModuleEvent("LOOT_SLOT_CLEARED", HandleLootSlotCleared)
GogoLoot:RegisterModuleEvent("UI_ERROR_MESSAGE", HandleUIErrorMessage)
