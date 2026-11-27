--------------------------------------------------------------------------------
-- GogoLoot Master Loot Distribution Engine
--------------------------------------------------------------------------------

local _, ns = ...

local RegisterPendingLootAnnouncement
local ResolveSilentHandout

--------------------------------------------------------------------------------
-- Manual Distribution Hook
--------------------------------------------------------------------------------

--[[
    The automated path passes `true` as GiveMasterLoot's third argument (the
    client ignores it) so this hook can skip it. Never announce inline here:
    register a pending entry.
]]
if type(GiveMasterLoot) == "function" then
	hooksecurefunc("GiveMasterLoot", function(slotIndex, candidateIndex, isAutomated)
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

		local displayName = ns:FormatPlayerName(candidateName)
		RegisterPendingLootAnnouncement(
			slotIndex,
			lootLink,
			displayName,
			true,
			not ns.db.profile.announceMasterLootManual
		)
	end)
end

--------------------------------------------------------------------------------
-- Distribution Engine
--------------------------------------------------------------------------------

--[[
    The retry ticker covers GetMasterLootCandidate returning nil for the first
    frames after LOOT_OPENED, and item info not yet cached.
]]
local DISTRIBUTION_RETRY_INTERVAL = 0.1
local DISTRIBUTION_MAX_RETRIES = 20
local DISTRIBUTION_QUIET_TICKS = 3

local HANDOUT_FALLBACK_DELAY = 1.5
local ERROR_BATCH_DELAY = 0.5
local HANDOUT_TIMER_PREFIX = "GogoLoot.Handout."
local ERROR_TIMER_PREFIX = "GogoLoot.LootError."

local lootDistributionTicker = nil
local distributedSlots = {}
local lootIsOpen = false
local quietTickCount = 0

--------------------------------------------------------------------------------
-- Pending Hand-out Registry
--------------------------------------------------------------------------------

--[[
    GiveMasterLoot returns at once; success shows only as a later
    LOOT_SLOT_CLEARED, failure as a UI_ERROR_MESSAGE that names no item. So
    every give registers its OWN entry, and an error goes to the oldest one.

      * success        LOOT_SLOT_CLEARED for that slot -> announce
      * known failure  a mapped UI_ERROR_MESSAGE      -> resolve oldest, report
      * silent failure the fallback fires and the slot STILL holds the item
      * aborted        LOOT_CLOSED -> flush manual entries, drop the rest

    Manual entries are flushed on close: LOOT_CLOSED is local while the
    confirmation is a round trip, and a deliberate hand-out is owed its line.
    The automated path stays confirm-only: an unasked-for false "Gave X to Y"
    is worse than a missed line.
]]

local pendingHandouts = {}
local handoutSequence = 0

-- silentSuccess silences only the success line: the entry is what detects a failure.
---@param slotIndex number
---@param itemLink string
---@param displayName string
---@param isManual? boolean
---@param silentSuccess? boolean
---@return nil
function RegisterPendingLootAnnouncement(slotIndex, itemLink, displayName, isManual, silentSuccess)
	if not slotIndex or not itemLink or not displayName then
		return
	end

	handoutSequence = handoutSequence + 1
	local handoutId = tostring(handoutSequence)
	local parsedLink = ns:ParseItemLink(itemLink)

	pendingHandouts[handoutId] = {
		handoutId = handoutId,
		order = handoutSequence,
		slotIndex = slotIndex,
		itemLink = itemLink,
		itemIdentifier = parsedLink and parsedLink.itemIdentifier or nil,
		displayName = displayName,
		isManual = isManual,
		silentSuccess = silentSuccess,
	}

	ns:After(HANDOUT_TIMER_PREFIX .. handoutId, HANDOUT_FALLBACK_DELAY, function()
		ResolveSilentHandout(handoutId)
	end)
end

---@param handoutId string
---@return table|nil # the removed entry, or nil when it was already resolved
local function ResolveHandout(handoutId)
	local handout = pendingHandouts[handoutId]
	if not handout then
		return nil
	end
	pendingHandouts[handoutId] = nil
	ns:CancelTimer(HANDOUT_TIMER_PREFIX .. handoutId)
	return handout
end

---@param slotIndex number
---@return table|nil
local function ResolveHandoutForSlot(slotIndex)
	for handoutId, handout in pairs(pendingHandouts) do
		if handout.slotIndex == slotIndex then
			return ResolveHandout(handoutId)
		end
	end
	return nil
end

-- The server answers in order, so an unattributed error belongs to the oldest hand-out.
---@return table|nil
local function ResolveOldestHandout()
	local oldestId, oldestOrder
	for handoutId, handout in pairs(pendingHandouts) do
		if not oldestOrder or handout.order < oldestOrder then
			oldestId, oldestOrder = handoutId, handout.order
		end
	end
	if not oldestId then
		return nil
	end
	return ResolveHandout(oldestId)
end

---@param handout table
---@return nil
local function EmitLootAnnouncement(handout)
	if handout.silentSuccess or not IsInGroup() then
		return
	end
	ns:Announce(ns:GetGroupChatChannel(), nil, "MESSAGE_GAVE", handout.itemLink, handout.displayName)
end

-- Call before anything wipes the registry. Entries are removed as they emit, so nothing announces twice.
---@return nil
local function FlushPendingManualAnnouncements()
	for handoutId, handout in pairs(pendingHandouts) do
		if handout.isManual then
			ResolveHandout(handoutId)
			EmitLootAnnouncement(handout)
		end
	end
end

--------------------------------------------------------------------------------
-- Batched Failure Reporting
--------------------------------------------------------------------------------

--[[
    One report per player per reason, not per item or retry pass. Items already
    reported stay remembered for the loot session, so a later pass stays quiet.
]]
local lootErrors = {}

---@param batchKey string
---@return nil
local function FlushLootError(batchKey)
	local batch = lootErrors[batchKey]
	if not batch or #batch.itemLinks == 0 then
		return
	end

	local itemLinks = batch.itemLinks
	for _, itemLink in ipairs(itemLinks) do
		batch.reported[itemLink] = true
	end
	batch.itemLinks = {}

	if IsInGroup() and ns.db.profile.lootNotifications then
		ns:AnnounceParts(ns:GetGroupChatChannel(), nil, batch.localeKey, itemLinks, function(itemList)
			return batch.displayName, itemList
		end)
	else
		-- Never silent, as the Manual Hand-out tooltip promises: the master looter still hears it.
		ns:PrintMessage(ns.L[batch.localeKey]:format(batch.displayName, table.concat(itemLinks, ", ")) .. ".")
	end
end

---@param displayName string
---@param localeKey string
---@param itemLink string
---@return nil
local function ReportLootError(displayName, localeKey, itemLink)
	if not displayName or not localeKey or not itemLink then
		return
	end

	local batchKey = displayName .. "\0" .. localeKey
	local batch = lootErrors[batchKey]
	if not batch then
		batch = { displayName = displayName, localeKey = localeKey, itemLinks = {}, reported = {} }
		lootErrors[batchKey] = batch
	end

	if batch.reported[itemLink] then
		return
	end
	for _, existingLink in ipairs(batch.itemLinks) do
		if existingLink == itemLink then
			return
		end
	end

	if #batch.itemLinks == 0 then
		ns:After(ERROR_TIMER_PREFIX .. batchKey, ERROR_BATCH_DELAY, function()
			FlushLootError(batchKey)
		end)
	end

	table.insert(batch.itemLinks, itemLink)
end

-- Only a slot still holding the same item is a failure; anything else is ambiguous and stays quiet.
---@param handoutId string
---@return nil
function ResolveSilentHandout(handoutId)
	local handout = pendingHandouts[handoutId]
	if not handout then
		return
	end
	ResolveHandout(handoutId)

	if not lootIsOpen or not handout.itemIdentifier then
		return
	end

	local currentLink = GetLootSlotLink(handout.slotIndex)
	local currentParsed = currentLink and ns:ParseItemLink(currentLink)
	if not currentParsed or currentParsed.itemIdentifier ~= handout.itemIdentifier then
		return
	end

	ReportLootError(handout.displayName, "ERROR_DISTRIBUTION_FAILED", handout.itemLink)
end

--------------------------------------------------------------------------------
-- Distribution State
--------------------------------------------------------------------------------

---@return nil
local function ClearDistributionState()
	for handoutId in pairs(pendingHandouts) do
		ns:CancelTimer(HANDOUT_TIMER_PREFIX .. handoutId)
	end
	for batchKey in pairs(lootErrors) do
		FlushLootError(batchKey)
		ns:CancelTimer(ERROR_TIMER_PREFIX .. batchKey)
	end

	wipe(pendingHandouts)
	wipe(lootErrors)
	wipe(distributedSlots)
	quietTickCount = 0
	if lootDistributionTicker then
		lootDistributionTicker:Cancel()
		lootDistributionTicker = nil
	end
end

--[[
    Cross-realm candidates read "Name-Realm" while destinations are stored
    realm-stripped, so a normalized alias is added, but only when exactly one
    candidate normalizes to it. With "Bob" and "Bob-OtherRealm", "bob" reaches
    the same-realm one and the cross-realm one is left for manual handling.
]]
local function BuildCandidateMap()
	local map = {}
	local lootSlotCount = GetNumLootItems()
	local groupSize = GetNumGroupMembers()
	for slotIndex = 1, lootSlotCount do
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

	-- Normalized, so a value saved with a realm suffix still matches the alias keys.
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

---@return boolean
local function IsInBindOnPickupTradeInstance()
	local _, instanceType = GetInstanceInfo()
	return (instanceType == "raid" or instanceType == "party")
end

--[[
    One combined question: distribution has no per-item instruction to weigh,
    unlike the roll path, where Item Overrides sits between the two halves.
]]
---@param itemInformation table
---@return boolean
local function ShouldSkipItemForMasterLoot(itemInformation)
	if not itemInformation then
		return true
	end

	if ns:IsNeverAutomatedItem(itemInformation) then
		return true
	end

	if ns.db.profile.autoMasterLootQuestItems then
		return false
	end

	return ns:IsQuestClassItem(itemInformation)
end

---@return boolean distributed
---@return boolean waiting
local function TryDistributeSlot(slotIndex, candidateMap)
	if distributedSlots[slotIndex] then
		return false
	end

	local lootLink = GetLootSlotLink(slotIndex)
	if not lootLink then
		return false
	end

	local parsedLink = ns:ParseItemLink(lootLink)
	if not parsedLink or not parsedLink.itemIdentifier then
		return false
	end

	local itemId = parsedLink.itemIdentifier
	local itemInformation = ns:SafeGetItemInfo(itemId)
	if not itemInformation then
		return false, true
	end

	if ShouldSkipItemForMasterLoot(itemInformation) then
		return false
	end

	if ns.db.profile.ignoredItemsMaster[itemId] then
		return false
	end

	if itemInformation.bindType == ns.BIND_ON_PICKUP and not IsInBindOnPickupTradeInstance() then
		return false
	end

	local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[itemInformation.quality]
	if not qualityKey then
		return false
	end

	-- Below the threshold the master looter never hands it out, so a hidden tier's player isn't waited on.
	if not ns:IsQualityReachable(itemInformation.quality) then
		return false
	end

	local slotCandidates = candidateMap[slotIndex]
	if not slotCandidates then
		return false, true
	end

	local resolvedName, candidateIndex = ResolveDestinationCandidate(qualityKey, slotCandidates)
	if not resolvedName then
		return false
	end
	if not candidateIndex then
		-- The candidate list can lag LOOT_OPENED. One that never arrives is left for manual handling, not re-routed.
		return false, true
	end

	local displayName = ns:FormatPlayerName(resolvedName)

	distributedSlots[slotIndex] = true
	GiveMasterLoot(slotIndex, candidateIndex, true)

	local wantsAnnounce = ns.db.profile.announceMasterLootAuto
		and itemInformation.quality >= ns.db.profile.announceMasterLootAutoThreshold

	RegisterPendingLootAnnouncement(slotIndex, lootLink, displayName, false, not wantsAnnounce)

	return true
end

---@return boolean distributedAny
---@return boolean stillWaiting
local function RunDistributionPass()
	if not lootIsOpen then
		return false, false
	end

	local candidateMap = BuildCandidateMap()
	local lootSlotCount = GetNumLootItems()
	local distributedAny, stillWaiting = false, false

	for slotIndex = lootSlotCount, 1, -1 do
		if not distributedSlots[slotIndex] then
			local distributed, waiting = TryDistributeSlot(slotIndex, candidateMap)
			if distributed then
				distributedAny = true
			elseif waiting then
				stillWaiting = true
			end
		end
	end

	return distributedAny, stillWaiting
end

local function StartDistributionTicker()
	if lootDistributionTicker then
		return
	end

	local retries = 0
	quietTickCount = 0

	lootDistributionTicker = C_Timer.NewTicker(DISTRIBUTION_RETRY_INTERVAL, function(tickerHandle)
		retries = retries + 1
		if not lootIsOpen or retries > DISTRIBUTION_MAX_RETRIES then
			tickerHandle:Cancel()
			lootDistributionTicker = nil
			return
		end

		local distributedAny, stillWaiting = RunDistributionPass()
		if distributedAny or stillWaiting then
			quietTickCount = 0
		else
			quietTickCount = quietTickCount + 1
			if quietTickCount >= DISTRIBUTION_QUIET_TICKS then
				tickerHandle:Cancel()
				lootDistributionTicker = nil
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- Loot Window Lifecycle
--------------------------------------------------------------------------------

local function OnLootOpened()
	FlushPendingManualAnnouncements()

	ClearDistributionState()
	lootIsOpen = true

	if not ns:WillAutoMasterLoot() then
		return
	end

	RunDistributionPass()
	StartDistributionTicker()
end

local function OnLootClosed()
	lootIsOpen = false
	FlushPendingManualAnnouncements()
	ClearDistributionState()
end

--------------------------------------------------------------------------------
-- Distribution Error Handling
--------------------------------------------------------------------------------

--[[
    Every constant here describes the RECIPIENT. Deliberately absent:
    ERR_INV_FULL, ERR_LOOT_BAG_FULL and ERR_ITEM_MAX_COUNT (the master looter's
    own bags) and ERR_TOO_FAR_TO_INTERACT (the master looter's own clicks).
]]
local ERROR_CONSTANT_TO_LOCALE_KEY = {
	ERR_LOOT_MASTER_INV_FULL = "ERROR_BAG_FULL",
	ERR_LOOT_MASTER_UNIQUE_ITEM = "ERROR_MAX_COUNT",
	ERR_LOOT_TOO_FAR = "ERROR_OUT_OF_RANGE",
	ERR_LOOT_PLAYER_NOT_FOUND = "ERROR_NOT_IN_GROUP",
	ERR_LOOT_MASTER_OTHER = "ERROR_DISTRIBUTION_FAILED",
}

-- Resolved on first use, never saved: a patch may renumber the ids.
local errorIdToLocaleKey

local function BuildErrorIdMap()
	errorIdToLocaleKey = {}
	for errorId, constantName in pairs(ns:ResolveGameMessageIds(ERROR_CONSTANT_TO_LOCALE_KEY)) do
		errorIdToLocaleKey[errorId] = ERROR_CONSTANT_TO_LOCALE_KEY[constantName]
	end
end

local function MapErrorIdToLocaleKey(errorId)
	if not errorId then
		return nil
	end
	if not errorIdToLocaleKey then
		BuildErrorIdMap()
	end
	return errorIdToLocaleKey[errorId]
end

ns.LOOT_ERROR_CONSTANTS = ERROR_CONSTANT_TO_LOCALE_KEY

-- The first number, not argument one, for a build that reorders or omits arguments.
local function ExtractErrorId(...)
	for argumentIndex = 1, select("#", ...) do
		local argumentValue = select(argumentIndex, ...)
		if type(argumentValue) == "number" then
			return argumentValue
		end
	end
	return nil
end

-- With no hand-out in flight, a red error is somebody else's and must not be announced.
local function OnUiErrorMessage(...)
	if not next(pendingHandouts) then
		return
	end

	local errorLocaleKey = MapErrorIdToLocaleKey(ExtractErrorId(...))
	if not errorLocaleKey then
		return
	end

	local handout = ResolveOldestHandout()
	if not handout then
		return
	end

	ReportLootError(handout.displayName, errorLocaleKey, handout.itemLink)
end

--------------------------------------------------------------------------------
-- Successful Distribution Confirmation
--------------------------------------------------------------------------------

-- Slots also clear when the player loots the item, so only a pending entry counts.
local function OnLootSlotCleared(slotIndex)
	if not slotIndex then
		return
	end

	local handout = ResolveHandoutForSlot(slotIndex)
	if not handout then
		return
	end

	EmitLootAnnouncement(handout)
end

--------------------------------------------------------------------------------
-- Distribution Event Registrations
--------------------------------------------------------------------------------

ns:RegisterModuleEvent("LOOT_OPENED", OnLootOpened)
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)
ns:RegisterModuleEvent("LOOT_SLOT_CLEARED", OnLootSlotCleared)
ns:RegisterModuleEvent("UI_ERROR_MESSAGE", OnUiErrorMessage)
