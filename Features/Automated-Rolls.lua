--------------------------------------------------------------------------------
-- GogoLoot Automated Rolls Module
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Addon-Initiated Roll Tracking
--------------------------------------------------------------------------------

--[[
    Every RollOnLoot this module issues is recorded here first, so the
    CONFIRM_LOOT_ROLL handler auto-confirms bind dialogs only for rolls
    GogoLoot started. Player-initiated rolls keep Blizzard's confirmation
    dialog. CANCEL_LOOT_ROLL clears entries so finished or expired rolls
    leave no stale state behind.
]]

local rollsInitiatedByAddon = {}

--[[
    Rolls whose item info wasn't cached when START_LOOT_ROLL fired are polled by
    a named timer until the info resolves, the roll expires, or the attempt cap
    is reached. The timer identifier carries the roll id, so ns:IsTimerPending
    is the duplicate-ticker guard and CANCEL_LOOT_ROLL cancels outright — no
    hand-rolled flag doubling as a self-cancel token.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."
local ROLL_RETRY_INTERVAL = 0.5
local ROLL_RETRY_MAX_ATTEMPTS = 10

local function ExecuteTrackedRoll(rollIdentifier, rollAction)
	rollsInitiatedByAddon[rollIdentifier] = true
	RollOnLoot(rollIdentifier, rollAction)
end

--[[
    The threshold path is configured per group context: raids read the raid
    pair, everything else (party, and the rare ungrouped roll) reads the party
    pair. Nothing here looks at the loot method — GogoLoot acts on every
    START_LOOT_ROLL the client raises, so a roll that opens during a master-loot
    session is automated exactly like one from Group Loot or Need Before Greed.
]]
local function GetContextRollSettings()
	if IsInRaid() then
		return ns.db.profile.autoRollActionRaid, ns.db.profile.autoRollThresholdRaid
	end
	return ns.db.profile.autoRollActionParty, ns.db.profile.autoRollThresholdParty
end

local function ExecuteRollOverride(rollIdentifier, rollOverride, rollGreedAllowed, rollNeedAllowed)
	if rollOverride == ns.NEED then
		if rollNeedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_NEED)
		elseif rollGreedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_GREED)
		end
	elseif rollOverride == ns.GREED then
		if rollGreedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_GREED)
		end
	elseif rollOverride == ns.PASS then
		ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_PASS)
	end
end

--------------------------------------------------------------------------------
-- START_LOOT_ROLL
--------------------------------------------------------------------------------

--[[
    Evaluates a roll and takes the configured automated action. Re-reads all
    roll data fresh, so it behaves identically whether called from
    START_LOOT_ROLL or from a later retry tick.

    Returns true when the decision was reached — whether or not it produced a
    roll, and including the cases where the roll is no longer live or the item
    is skipped — meaning no retry is needed. Returns false only when the item's
    full info isn't cached yet, so the caller should retry: the class/subclass
    hard skips need the full item info, so the roll is never decided from
    GetLootRollItemInfo's quality/BoP arguments alone.
]]
local function EvaluateRoll(rollIdentifier)
	if not ns.db then
		return true
	end

	--[[
        GetLootRollItemInfo returns: texture, name, count, quality,
        bindOnPickUp, canNeed, canGreed, canDisenchant, ...
    ]]
	local _, _, _, rollQuality, _, rollNeedAllowed, rollGreedAllowed = GetLootRollItemInfo(rollIdentifier)
	local rollItemLink = GetLootRollItemLink(rollIdentifier)
	if not rollItemLink then
		return true
	end

	local parsedItemLink = ns:ParseItemLink(rollItemLink)
	if not parsedItemLink or not parsedItemLink.itemIdentifier then
		return true
	end

	local itemInformation = ns:SafeGetItemInfo(parsedItemLink.itemIdentifier)
	if not itemInformation then
		return false
	end

	-- Hard safety: legendaries, quest items, recipes/books, mounts, pets are never automated
	if ns:ShouldSkipItemByType(itemInformation) then
		return true
	end

	--[[
        Master switch: when Automated Rolls is off, nothing rolls
        automatically, Custom Roll List included.
    ]]
	if not ns.db.profile.autoGreed then
		return true
	end

	-- Custom List: per-item overrides bypass threshold AND allow BoP items
	if ns.db.profile.customRollList then
		local rollOverride = ns:GetItemRollOverride(parsedItemLink.itemIdentifier)
		if rollOverride then
			if rollOverride == ns.MANUAL then
				return true
			end
			ExecuteRollOverride(rollIdentifier, rollOverride, rollGreedAllowed, rollNeedAllowed)
			return true
		end
	end

	-- The threshold path NEVER touches BoP items
	if itemInformation.bindType == ns.BIND_ON_PICKUP then
		return true
	end

	local contextRollAction, contextRollThreshold = GetContextRollSettings()
	if contextRollAction == ns.MANUAL then
		return true
	end

	if rollQuality <= contextRollThreshold then
		ExecuteRollOverride(rollIdentifier, contextRollAction, rollGreedAllowed, rollNeedAllowed)
	end

	return true
end

--[[
    Polls a roll whose item info wasn't cached at START_LOOT_ROLL time. Runs
    every ROLL_RETRY_INTERVAL up to ROLL_RETRY_MAX_ATTEMPTS, bailing early once
    the roll is no longer live. Each tick re-arms the same named timer, so
    CANCEL_LOOT_ROLL cancelling that name is all it takes to tear the poll down.
]]
---@param rollIdentifier number
---@return nil
local function ScheduleRollRetry(rollIdentifier)
	local timerIdentifier = ROLL_RETRY_TIMER_PREFIX .. rollIdentifier
	if ns:IsTimerPending(timerIdentifier) then
		return
	end

	local attempts = 0
	local function Retry()
		if not GetLootRollItemLink(rollIdentifier) then
			return
		end
		attempts = attempts + 1
		if EvaluateRoll(rollIdentifier) or attempts >= ROLL_RETRY_MAX_ATTEMPTS then
			return
		end
		ns:After(timerIdentifier, ROLL_RETRY_INTERVAL, Retry)
	end

	ns:After(timerIdentifier, ROLL_RETRY_INTERVAL, Retry)
end

local function HandleStartLootRoll(rollIdentifier)
	if not EvaluateRoll(rollIdentifier) then
		ScheduleRollRetry(rollIdentifier)
	end
end

ns:RegisterModuleEvent("START_LOOT_ROLL", HandleStartLootRoll)

--------------------------------------------------------------------------------
-- CONFIRM_LOOT_ROLL & CANCEL_LOOT_ROLL
--------------------------------------------------------------------------------

ns:RegisterModuleEvent("CONFIRM_LOOT_ROLL", function(rollIdentifier, rollAction)
	if not rollsInitiatedByAddon[rollIdentifier] then
		return
	end
	rollsInitiatedByAddon[rollIdentifier] = nil
	ConfirmLootRoll(rollIdentifier, rollAction)
end)

ns:RegisterModuleEvent("CANCEL_LOOT_ROLL", function(rollIdentifier)
	rollsInitiatedByAddon[rollIdentifier] = nil
	ns:CancelTimer(ROLL_RETRY_TIMER_PREFIX .. rollIdentifier)
end)
