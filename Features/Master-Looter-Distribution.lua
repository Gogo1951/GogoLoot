--------------------------------------------------------------------------------
-- GogoLoot Master Loot Distribution Engine
--------------------------------------------------------------------------------

--[[
    The automated loot-distribution half of Master Looting, split out from
    Master-Looter.lua (which keeps the API wrappers, eligibility check, and
    destination management):
      * Manual distribution hook — GiveMasterLoot from the candidate dropdown
        is announced regardless of the announcement threshold.
      * The LOOT_OPENED -> GiveMasterLoot automated distribution engine, its
        retry ticker, and the Pending Announcement Registry.
      * UI_ERROR_MESSAGE correlation and the LOOT_SLOT_CLEARED success path.

    Eligibility (ns:WillAutoMasterLoot) and the destination table it reads live
    in Master-Looter.lua; everything shared crosses via ns methods, so this file
    needs only the namespace. All chat output routes through ns:Announce, which
    pulls the body template from L[] and applies the marker and add-on name —
    this module never calls SendChatMessage directly.
]]
local _, ns = ...

--------------------------------------------------------------------------------
-- Manual Distribution Hook
--------------------------------------------------------------------------------

--[[
    Items distributed manually via the standard ML candidate dropdown are
    always announced — no toggle, no quality threshold — since a manual
    hand-out is a deliberate act the group should always see. The automated
    path (TryDistributeSlot below) passes `true` as the third argument to
    GiveMasterLoot so this hook can tell them apart and skip.

    Never announce inline here — register a pending entry instead; the
    Pending Announcement Registry below documents the timing rules.
]]

if type(GiveMasterLoot) == "function" then
    hooksecurefunc(
        "GiveMasterLoot",
        function(slotIndex, candidateIndex, isAutomated)
            if isAutomated then
                return
            end
            if not ns.db then
                return
            end
            if not ns:AreWeMasterLooter() then
                return
            end
            if not IsInGroup() then
                return
            end

            local lootLink = GetLootSlotLink(slotIndex)
            if not lootLink then
                return
            end

            local candidateName = GetMasterLootCandidate(slotIndex, candidateIndex)
            if not candidateName then
                return
            end

            local displayName = ns:CapitalizeFirstLetter(ns:NormalizePlayerName(candidateName))
            ns:RegisterPendingLootAnnouncement(slotIndex, lootLink, displayName)
        end
    )
end

--------------------------------------------------------------------------------
-- Distribution Engine
--------------------------------------------------------------------------------

--[[
    On LOOT_OPENED in ML mode, walks the loot list and uses GiveMasterLoot
    to assign each at-or-above-threshold item to the player configured in
    ns.db.profile.destinations for its quality tier. Skipped items
    (legendaries, quest items, recipes, mounts, pets, anything in the
    ignore list, BoP outside trade-eligible instances) are left in the
    standard loot frame for manual handling.

    Initial pass + retry ticker: GetMasterLootCandidate can return nil for
    the first frame or two after LOOT_OPENED, and SafeGetItemInfo returns
    nil until the client caches the item. The ticker re-runs the pass until
    everything resolves or DISTRIBUTION_QUIET_TICKS consecutive ticks make
    no progress.

    Announcements are never sent inline with GiveMasterLoot — see the
    Pending Announcement Registry below for the timing rules.

    Error correlation: a failed GiveMasterLoot surfaces only as a
    UI_ERROR_MESSAGE on a later frame. Known failure strings post a generic
    ERROR_* announcement; unknown errors are ignored rather than spamming
    chat for unrelated UI errors. pendingDistribution is a single value, so
    an error arriving while several calls are in flight is attributed to
    the most recent one — acceptable, since the announcement names no item
    or player.
]]

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
--------------------------------------------------------------------------------

--[[
    Why announcements are deferred: GiveMasterLoot returns immediately, and
    the server confirms success only on a later frame (the slot clears) or
    surfaces failure via UI_ERROR_MESSAGE. Announcing inline would post
    "Gave X to Y" for deliveries that then fail — and twice after a retry.

    So both the auto path (TryDistributeSlot) and the manual hook above
    register a pending entry keyed by loot slot, and only the
    LOOT_SLOT_CLEARED handler emits MESSAGE_LOOT_ANNOUNCE — failures never
    clear the slot, so they never announce. A retry on the same slot
    overwrites the entry, so the announcement names the recipient of the
    successful delivery. LOOT_CLOSED wipes leftovers so nothing leaks into
    the next loot session.
]]

function ns:RegisterPendingLootAnnouncement(slotIndex, itemLink, displayName)
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

--[[
    Candidate names come back as "Name" for same-realm members but
    "Name-Realm" for cross-realm members, while destinations are stored
    realm-stripped (ns:NormalizePlayerName). Each slot's map therefore
    holds two kinds of keys: the exact lowercased full name, plus a
    normalized alias — but the alias only when exactly one candidate
    normalizes to it. When two members share a base name ("Bob" and
    "Bob-OtherRealm"), no alias is created and a realm-stripped destination
    matches nothing, so the item falls back to manual handling rather than
    guessing a recipient.
]]
local function BuildCandidateMap()
    local map = {}
    local numItems = GetNumLootItems()
    local groupSize = GetNumGroupMembers()
    for slotIndex = 1, numItems do
        local slotCandidates = {}
        local normalizedCounts = {}
        local normalizedIndexes = {}
        for groupIndex = 1, groupSize do
            local candidateName = GetMasterLootCandidate(slotIndex, groupIndex)
            if candidateName then
                slotCandidates[strlower(candidateName)] = groupIndex
                local normalizedName = ns:NormalizePlayerName(candidateName)
                if normalizedName then
                    normalizedCounts[normalizedName] = (normalizedCounts[normalizedName] or 0) + 1
                    normalizedIndexes[normalizedName] = groupIndex
                end
            end
        end
        for normalizedName, nameCount in pairs(normalizedCounts) do
            if nameCount == 1 and slotCandidates[normalizedName] == nil then
                slotCandidates[normalizedName] = normalizedIndexes[normalizedName]
            end
        end
        map[slotIndex] = slotCandidates
    end
    return map
end

local function ResolveDestinationCandidate(qualityKey, slotCandidates)
    local destinationName = ns.db.profile.destinations[qualityKey]
    if not destinationName or destinationName == "" then
        return nil, nil
    end

    local resolvedName = destinationName
    if destinationName == "self" then
        resolvedName = ns:GetLowercaseUnitName("player")
    end
    if not resolvedName then
        return nil, nil
    end

    --[[
        Normalize rather than just lowercase so legacy values that were saved
        with a realm suffix still match the candidate map's alias keys.
    ]]
    local lookupKey = ns:NormalizePlayerName(resolvedName)
    if not lookupKey then
        return nil, nil
    end
    local candidateIndex = slotCandidates[lookupKey] or slotCandidates[strlower(resolvedName)]
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

    local parsedLink = ns:ParseItemLink(lootLink)
    if not parsedLink or not parsedLink.itemIdentifier then
        return false
    end

    local itemId = parsedLink.itemIdentifier
    local itemInfo = ns:SafeGetItemInfo(itemId)
    if not itemInfo then
        -- Item info not yet cached — the retry ticker will pick this up
        return false
    end

    -- Hard skip: legendaries, quest items, recipes, mounts, pets
    if ns:ShouldSkipItemByType(itemInfo) then
        return false
    end

    -- User-configured ignore list
    if ns.db.profile.ignoredItemsMaster[itemId] then
        return false
    end

    -- BoP items can only be redistributed inside trade-eligible instances
    if itemInfo.bindType == ns.BIND_ON_PICKUP and not ns:IsInBindOnPickupTradeInstance() then
        return false
    end

    local qualityKey = ns.rarityToConfigurationKey[itemInfo.quality]
    if not qualityKey then
        return false
    end

    local slotCandidates = candidateMap[slotIndex]
    if not slotCandidates then
        return false
    end

    local resolvedName, candidateIndex = ResolveDestinationCandidate(qualityKey, slotCandidates)
    if not candidateIndex then
        --[[
            Destination isn't a valid candidate for this slot (out of range,
            different sub-group, no longer in group, or an ambiguous duplicate
            base name across realms). Leave it for manual handling rather
            than silently re-routing.
        ]]
        return false
    end

    local displayName = ns:CapitalizeFirstLetter(resolvedName)

    --[[
        Record context for the UI_ERROR_MESSAGE handler before the call —
        the error fires on a subsequent frame and needs to know which slot was
        attempted, who it was meant for (named in the error announcement), and
        when.
    ]]
    pendingDistribution = {
        slotIndex = slotIndex,
        displayName = displayName,
        timestamp = GetTime()
    }

    distributedSlots[slotIndex] = true
    GiveMasterLoot(slotIndex, candidateIndex, true)

    --[[
        Gate the auto announce toggle/threshold at register time so pending
        entries exist only for items the user wants announced (see Pending
        Announcement Registry above).
    ]]
    if
        ns.db.profile.announceMasterLootAuto and itemInfo.quality >= ns.db.profile.announceMasterLootAutoThreshold and
            IsInGroup()
     then
        ns:RegisterPendingLootAnnouncement(slotIndex, lootLink, displayName)
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

    --[[
        Iterate from the bottom upward so that as slots are consumed, the
        remaining indices we still care about don't shift.
    ]]
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

    if not ns:WillAutoMasterLoot() then
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

    --[[
        Compare against globalized strings first; these vary by client locale
        but are reliable when bound. Some globals don't exist on every WoW
        build, so the comparison is safe even when the global is nil.
    ]]
    if errorString == ERR_INV_FULL or errorString == ERR_LOOT_BAG_FULL then
        return "ERROR_BAG_FULL"
    end
    if errorString == ERR_ITEM_MAX_COUNT then
        return "ERROR_MAX_COUNT"
    end
    if errorString == ERR_LOOT_PLAYER_NOT_PRESENT or errorString == LOOT_PLAYER_NOT_PRESENT then
        return "ERROR_OUT_OF_RANGE"
    end
    if errorString == ERR_NOT_IN_GROUP or errorString == ERR_NOT_IN_RAID then
        return "ERROR_NOT_IN_GROUP"
    end

    --[[
        Substring fallbacks for builds where the global isn't bound. Plain
        text matches only — no patterns, so locale-specific punctuation
        doesn't break things.
    ]]
    local lowerMessage = string.lower(errorString)
    if string.find(lowerMessage, "bag is full", 1, true) or string.find(lowerMessage, "inventory is full", 1, true) then
        return "ERROR_BAG_FULL"
    end
    if string.find(lowerMessage, "more of that item", 1, true) or string.find(lowerMessage, "max count", 1, true) then
        return "ERROR_MAX_COUNT"
    end
    if string.find(lowerMessage, "not in range", 1, true) or string.find(lowerMessage, "too far away", 1, true) then
        return "ERROR_OUT_OF_RANGE"
    end
    if
        string.find(lowerMessage, "not in your party", 1, true) or
            string.find(lowerMessage, "not in your raid", 1, true)
     then
        return "ERROR_NOT_IN_GROUP"
    end

    return nil
end

local function ExtractErrorString(...)
    --[[
        UI_ERROR_MESSAGE signature varies between clients — modern is
        (errorType, message); some Classic builds pass (message). Find
        the first string argument and use it.
    ]]
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
        ns:Announce(ns:GetGroupChatChannel(), nil, errorLocaleKey, pendingDistribution.displayName or "")
    end

    -- Clear the failed slot's pending announcement; a retry re-registers through the manual hook.
    pendingAnnouncements[pendingDistribution.slotIndex] = nil

    --[[
        Cancel the retry ticker — re-attempting a bag-full or max-count
        error will just produce the same failure on the next pass.
    ]]
    if lootDistributionTicker then
        lootDistributionTicker:Cancel()
        lootDistributionTicker = nil
    end

    pendingDistribution = nil
end

--------------------------------------------------------------------------------
-- Successful Distribution Confirmation
--------------------------------------------------------------------------------

--[[
    LOOT_SLOT_CLEARED fires only when the server actually empties the slot
    — in an ML session, that means GiveMasterLoot succeeded — so this is
    the only place MESSAGE_LOOT_ANNOUNCE is emitted. Slots also clear for
    non-ML reasons (the player looted the item), so only act when a pending
    entry exists for that slot.
]]

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

    ns:Announce(
        ns:GetGroupChatChannel(),
        nil,
        "MESSAGE_LOOT_ANNOUNCE",
        pending.itemLink,
        pending.displayName
    )
end

--------------------------------------------------------------------------------
-- Distribution Event Registrations
--------------------------------------------------------------------------------

ns:RegisterModuleEvent("LOOT_OPENED", HandleLootOpened)
ns:RegisterModuleEvent("LOOT_CLOSED", HandleLootClosed)
ns:RegisterModuleEvent("LOOT_SLOT_CLEARED", HandleLootSlotCleared)
ns:RegisterModuleEvent("UI_ERROR_MESSAGE", HandleUIErrorMessage)
