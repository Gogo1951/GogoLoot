--------------------------------------------------------------------------------
-- GogoLoot Automated Rolls Module
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Add-on-Initiated Roll Tracking
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
    a named timer until the info resolves or the roll ends — CANCEL_LOOT_ROLL
    cancelling the timer is the real teardown. The timer identifier carries the
    roll id, so ns:IsTimerPending is the duplicate-ticker guard — no hand-rolled
    flag doubling as a self-cancel token.

    The attempt cap only backstops a cancel that never arrives, so it is sized
    past the 60-second roll window rather than acting as the give-up point. It
    used to be the give-up point — 10 attempts, five seconds — and that was a
    live bug: a war-effort token's first drop of the night can keep its item
    query in flight past any short cap while the roll still has most of its
    minute left, and the give-up meant no roll, no error.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."
local ROLL_RETRY_INTERVAL = 0.5
local ROLL_RETRY_MAX_ATTEMPTS = 150

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
    roll, and including the case where the item is skipped — meaning no retry
    is needed. Returns false while the item is still unresolved, so the caller
    should retry: an uncached item reads as a nil GetLootRollItemLink and a nil
    GetItemInfo until the client's item query answers, and the class/subclass
    hard skips need the full item info, so the roll is never decided from
    GetLootRollItemInfo's quality/BoP arguments alone.
]]
---@param itemIdentifier number
---@return string|nil
function ns:GetItemRollOverride(itemIdentifier)
	if not itemIdentifier then
		return nil
	end
	local override = ns.db.profile.ignoredItemsSolo[itemIdentifier]
	if not override then
		return nil
	end
	return override
end

local function EvaluateRoll(rollIdentifier)
	if not ns.db then
		return true
	end

	--[[
        GetLootRollItemInfo returns: texture, name, count, quality,
        bindOnPickUp, canNeed, canGreed, canDisenchant, ...
    ]]
	local _, _, _, rollQuality, _, rollNeedAllowed, rollGreedAllowed = GetLootRollItemInfo(rollIdentifier)

	--[[
        A nil link is an unresolved item, not a dead roll. The client returns
        nil here until its item query answers — Blizzard's own
        GroupLootFrame_OnShow reads nil item info in the same state and bails —
        which is the normal condition of a war-effort token's first drop of the
        session. Treating it as "roll no longer live" is exactly what silently
        dropped Custom Roll List tokens whose drop raced the item cache: no
        retry was scheduled, no roll went out, no error. Dead rolls don't reach
        this read, because CANCEL_LOOT_ROLL cancels the retry timer outright.
    ]]
	local rollItemLink = GetLootRollItemLink(rollIdentifier)
	if not rollItemLink then
		return false
	end

	local parsedItemLink = ns:ParseItemLink(rollItemLink)
	if not parsedItemLink or not parsedItemLink.itemIdentifier then
		return true
	end

	local itemInformation = ns:SafeGetItemInfo(parsedItemLink.itemIdentifier)
	if not itemInformation then
		return false
	end

	-- Hard safety: legendaries, recipes/books, mounts, pets are never automated
	if ns:IsNeverAutomatedItem(itemInformation) then
		return true
	end

	--[[
        Master switch: when Automated Rolls is off, nothing rolls
        automatically, Custom Roll List included.
    ]]
	if not ns.db.profile.autoGreed then
		return true
	end

	--[[
        Custom List: a per-item override is an explicit instruction, so it
        bypasses the threshold, the BoP guard, and the quest-class skip below.
        It runs ahead of that skip deliberately — the AQ and ZG tokens the
        default list exists to roll on are all quest-class (see
        ns:IsQuestClassItem), so checking the skip first would make the whole
        feature a no-op for them.
    ]]
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

	-- Unlisted quest items are never picked up by the threshold path on their own
	if ns:IsQuestClassItem(itemInformation) then
		return true
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
    every ROLL_RETRY_INTERVAL until the info resolves and the roll is decided.
    Each tick re-arms the same named timer, so CANCEL_LOOT_ROLL cancelling that
    name is all it takes to tear the poll down when the roll ends; the attempt
    cap only bounds a cancel that never arrives. There is deliberately no
    "still live?" probe inside the tick — the one read that could answer it,
    GetLootRollItemLink, is nil for unresolved items too, and bailing on it is
    the bug the retry exists to fix.
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
