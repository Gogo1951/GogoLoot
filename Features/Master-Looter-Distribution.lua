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
        retry ticker, and the Pending Hand-out Registry.
      * UI_ERROR_MESSAGE correlation and the LOOT_SLOT_CLEARED success path.

    Eligibility (ns:WillAutoMasterLoot) and the destination table it reads live
    in Master-Looter.lua; everything shared crosses via ns methods, so this file
    needs only the namespace. All chat output routes through ns:Announce, which
    pulls the body template from L[] and applies the marker and add-on name —
    this module never calls SendChatMessage directly.
]]
local _, ns = ...

local RegisterPendingLootAnnouncement
local ResolveSilentHandout

--------------------------------------------------------------------------------
-- Manual Distribution Hook
--------------------------------------------------------------------------------

--[[
    Items distributed manually via the standard ML candidate dropdown are
    announced whatever their quality, since a manual hand-out is a deliberate
    act the group is owed a record of; announceMasterLootManual turns the
    success line off, and a failure is still reported. The automated path
    (TryDistributeSlot below) passes `true` as the third argument to
    GiveMasterLoot so this hook can tell them apart and skip.

    Never announce inline here — register a pending entry instead; the
    Pending Hand-out Registry below documents the timing rules.
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
    On LOOT_OPENED in ML mode, walks the loot list and uses GiveMasterLoot
    to assign each at-or-above-threshold item to the player configured in
    ns.db.profile.destinations for its quality tier. Skipped items
    (legendaries, recipes, mounts, pets, quest items unless the player opted
    into those, anything in the ignore list, BoP outside trade-eligible
    instances) are left in the standard loot frame for manual handling.

    Initial pass + retry ticker: GetMasterLootCandidate can return nil for
    the first frame or two after LOOT_OPENED, and SafeGetItemInfo returns
    nil until the client caches the item. The ticker re-runs the pass and
    stops after DISTRIBUTION_QUIET_TICKS consecutive passes with nothing
    handed out and nothing left waiting, or at DISTRIBUTION_MAX_RETRIES.

    Announcements are never sent inline with GiveMasterLoot — see the Pending
    Hand-out Registry below for the timing rules and the four outcomes.

    Error correlation: a failed GiveMasterLoot surfaces only as a
    UI_ERROR_MESSAGE on a later frame, and that event names no item. Errors are
    matched on their numeric id and attributed to the oldest hand-out still
    waiting; unmapped ids are ignored rather than announcing unrelated UI errors
    to the group.
]]

local DISTRIBUTION_RETRY_INTERVAL = 0.1
local DISTRIBUTION_MAX_RETRIES = 20
local DISTRIBUTION_QUIET_TICKS = 3

--[[
    How long a hand-out waits for the server to say anything at all before the
    fallback treats it as a silent failure, and how long failures collect before
    one grouped message goes out.
]]
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
    Why announcements are deferred: GiveMasterLoot returns immediately, and the
    server confirms success only on a later frame (the slot clears) or surfaces
    failure via UI_ERROR_MESSAGE. Announcing inline would post "Gave X to Y" for
    deliveries that then fail, and twice after a retry.

    Every call therefore registers its OWN entry under a unique id, carrying the
    slot, item and recipient, plus an ordering counter. A single "most recent
    attempt" value cannot work: UI_ERROR_MESSAGE names no item, so on a six-item
    boss kill an error has to be attributed to the oldest hand-out still waiting
    rather than whichever call happened to be last.

    Four outcomes, all handled:
      * success        LOOT_SLOT_CLEARED for that slot -> announce the hand-out
      * known failure  a mapped UI_ERROR_MESSAGE      -> resolve oldest, report
      * silent failure the fallback timer fires and the slot STILL holds the
                       item -> report it; the server said nothing at all
      * aborted        LOOT_CLOSED -> flush manual entries, drop the rest

    Manual entries additionally survive the window closing. The confirmation is
    a server round trip while LOOT_CLOSED is local and immediate, so anything
    that shuts the window inside that gap (handing out the last item, pressing
    Escape, being moved out of range mid-fight) would otherwise lose the
    announcement silently. A hand-out the master looter clicked deliberately
    must always reach the group, so those are flushed before the registry is
    cleared. The automated path keeps confirm-only semantics: it fires without
    the player asking, so a false positive there is worse than a missed line.
]]

local pendingHandouts = {}
local handoutSequence = 0

--[[
    silentSuccess records that the player doesn't want the success line for this
    hand-out; the entry is registered all the same, since the registry is what
    detects a failure, and a failure is reported either way.
]]
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

--[[
    The oldest outstanding hand-out is the one an unattributed error belongs to:
    the server answers in order, so anything newer has not been ruled on yet.
]]
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

--[[
    Called before anything wipes the registry. Entries are removed as they are
    emitted, so a LOOT_SLOT_CLEARED that lands first has already taken its entry
    out and nothing announces twice.
]]
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
    One report per player per failure reason, not one per item and not one per
    retry pass. A raider with full bags on a six-item kill would otherwise get
    six identical lines, and the distribution ticker's retries would repeat them.

    Items collect for ERROR_BATCH_DELAY and go out as one list, split across as
    many messages as the chat limit needs (ns:AnnounceParts); every item already
    reported for that player and reason is remembered for the rest of the loot
    session so a later pass stays quiet about it.
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

	if IsInGroup() then
		ns:AnnounceParts(ns:GetGroupChatChannel(), nil, batch.localeKey, itemLinks, function(itemList)
			return batch.displayName, itemList
		end)
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

	-- Arm one debounced flush as the batch goes from empty to non-empty.
	if #batch.itemLinks == 0 then
		ns:After(ERROR_TIMER_PREFIX .. batchKey, ERROR_BATCH_DELAY, function()
			FlushLootError(batchKey)
		end)
	end

	table.insert(batch.itemLinks, itemLink)
end

--[[
    The fallback: the server never answered, so decide from the loot window
    itself. A slot that still holds the same item means the hand-out did not
    happen; anything else is ambiguous and stays quiet rather than guessing.
]]
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
	-- A failure still in its batch window is sent now; closing the window must not swallow it.
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
    Candidate names come back as "Name" for same-realm members but
    "Name-Realm" for cross-realm members, while destinations are stored
    realm-stripped (ns:NormalizePlayerName). Each slot's map therefore
    holds two kinds of keys: the exact lowercased full name, plus a
    normalized alias — but the alias only when exactly one candidate
    normalizes to it. When two members share a base name ("Bob" and
    "Bob-OtherRealm"), no alias is created and a realm-stripped destination
    matches nothing, so the item falls back to manual handling rather than
    guessing a recipient.

    On WoW Forever a candidate reads "Aero Bramblefoot", which is also how
    a destination is stored there (ns:GetCleanUnitName), so the exact key
    matches.
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

---@return boolean
local function IsInBindOnPickupTradeInstance()
	local _, instanceType = GetInstanceInfo()
	return (instanceType == "raid" or instanceType == "party")
end

--[[
    The master-loot distribution skip: never-automated types always, plus
    quest-class items unless the player opted into handing those out
    (autoMasterLootQuestItems, for boosting a character they also control).

    Distribution asks this one question because it has no per-item instruction
    to weigh — unlike the roll path, which calls the two halves separately so
    Item Overrides can sit between them.
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

--[[
    The second return marks a slot the ticker should keep waiting on: its item
    info hasn't loaded, or its destination isn't a candidate yet. A slot skipped
    for good (ignored, never automated, no destination) returns false, false.
]]
---@return boolean distributed
---@return boolean waiting
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
	local itemInformation = ns:SafeGetItemInfo(itemId)
	if not itemInformation then
		return false, true
	end

	-- Hard skip: legendaries, recipes, mounts, pets — and quest items unless opted in
	if ShouldSkipItemForMasterLoot(itemInformation) then
		return false
	end

	-- User-configured ignore list
	if ns.db.profile.ignoredItemsMaster[itemId] then
		return false
	end

	-- BoP items can only be redistributed inside trade-eligible instances
	if itemInformation.bindType == ns.BIND_ON_PICKUP and not IsInBindOnPickupTradeInstance() then
		return false
	end

	local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[itemInformation.quality]
	if not qualityKey then
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
		--[[
            Destination isn't a candidate for this slot yet: the candidate list
            can lag LOOT_OPENED, so the ticker keeps waiting until its ceiling.
            One that never becomes a candidate (out of range, different
            sub-group, no longer in group, or an ambiguous duplicate base name
            across realms) is left for manual handling rather than re-routed.
        ]]
		return false, true
	end

	local displayName = ns:FormatPlayerName(resolvedName)

	distributedSlots[slotIndex] = true
	GiveMasterLoot(slotIndex, candidateIndex, true)

	--[[
        Always register the hand-out: the registry is what detects failure, and
        a failure has to be reportable whether or not the user wanted the
        success line. The announce toggle and threshold are recorded on the
        entry and checked when the success announcement is emitted, so a
        below-threshold item still gets its error reported but stays quiet on
        the happy path.
    ]]
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

	--[[
        Iterate from the bottom upward so that as slots are consumed, the
        remaining indices we still care about don't shift.
    ]]
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
	--[[
        A fresh loot window replaces the whole registry, so anything a manual
        hand-out is still waiting on has to go out first — looting the next
        corpse must not swallow the previous one's announcement.
    ]]
	FlushPendingManualAnnouncements()

	ClearDistributionState()
	lootIsOpen = true

	if not ns:WillAutoMasterLoot() then
		return
	end

	-- Initial pass — handles items whose info is already cached
	RunDistributionPass()

	-- Retry ticker for cache misses or candidate-map fill-ins
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
    UI_ERROR_MESSAGE's first argument is a NUMERIC error id, and the same error
    carries a different id on every flavor. GetGameMessageInfo(id) returns the
    constant NAME behind an id, so one pass over that table resolves the
    constants below to this client's ids and the correlation becomes a numeric
    comparison.

    Matching numerically keeps this off localized strings entirely: no
    exact-versus-substring tradeoff, no locale drift, and no dependence on
    whether a given ERR_* global is bound as a string (several are not on
    1.15.9).

    Every constant here describes the RECIPIENT of a hand-out, which is what the
    ERROR_* announcements say. Deliberately absent: ERR_INV_FULL,
    ERR_LOOT_BAG_FULL and ERR_ITEM_MAX_COUNT, which are about the local
    player's own bags, so auto-looting into full bags mid-hand-out would blame
    the recipient; and ERR_TOO_FAR_TO_INTERACT, which the master looter's own
    out-of-reach clicks raise.
]]
local ERROR_CONSTANT_TO_LOCALE_KEY = {
	ERR_LOOT_MASTER_INV_FULL = "ERROR_BAG_FULL",
	ERR_LOOT_MASTER_UNIQUE_ITEM = "ERROR_MAX_COUNT",
	ERR_LOOT_TOO_FAR = "ERROR_OUT_OF_RANGE",
	ERR_LOOT_PLAYER_NOT_FOUND = "ERROR_NOT_IN_GROUP",
	ERR_LOOT_MASTER_OTHER = "ERROR_DISTRIBUTION_FAILED",
}

--[[
    Built once on first use, not at load: GetGameMessageInfo is a full table walk
    and nothing needs the map until an error actually fires. Resolved ids are
    kept in a runtime table, never persisted, so a client patch that renumbers
    them can never be read back from stale saved data.
]]
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

-- Diagnostics reads this to report which constants resolved on this client.
ns.LOOT_ERROR_CONSTANTS = ERROR_CONSTANT_TO_LOCALE_KEY

--[[
    UI_ERROR_MESSAGE is (errorType, message) where errorType is the numeric id.
    Scanning for the first number rather than reading argument one keeps this
    working on any build that reorders or omits arguments.
]]
local function ExtractErrorId(...)
	for argumentIndex = 1, select("#", ...) do
		local argumentValue = select(argumentIndex, ...)
		if type(argumentValue) == "number" then
			return argumentValue
		end
	end
	return nil
end

--[[
    A mapped error resolves the oldest hand-out still waiting. Nothing is
    attributed when the registry is empty: UI_ERROR_MESSAGE carries every red
    error the client raises, so with no hand-out in flight it is somebody else's
    error and must not be announced.
]]
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

--[[
    LOOT_SLOT_CLEARED fires only when the server actually empties the slot
    — in an ML session, that means GiveMasterLoot succeeded — so this is the
    normal path to MESSAGE_GAVE, and the only one the automated path
    ever takes. Slots also clear for non-ML reasons (the player looted the
    item), so only act when a pending entry exists for that slot.
]]

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
