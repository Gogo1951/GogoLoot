--------------------------------------------------------------------------------
-- GogoLoot Automated Rolls Module
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

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
    canceling the timer is the real teardown. The timer identifier carries the
    roll id, so ns:IsTimerPending is the duplicate-ticker guard — no hand-rolled
    flag doubling as a self-cancel token.

    The attempt cap only backstops a cancel that never arrives, so it is sized
    past the 60-second roll window and must never become the give-up point: a
    war-effort token's first drop of the night can keep its item query in
    flight past any short cap while the roll still has most of its minute left,
    and giving up there means no roll and no error.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."
local ROLL_RETRY_INTERVAL = 0.5
local ROLL_RETRY_MAX_ATTEMPTS = 150

--[[
    Print Item in Chat: the roll window closes the moment GogoLoot rolls, so
    without this line the player never sees what came up or what was picked.
    It names the roll actually made, so a Need that fell back to Greed reads
    as Greed. The game's own word for each roll, as the dropdowns use.
]]
local ROLL_ACTION_WORDS = {
	[ns.ROLL_ACTION_NEED] = NEED,
	[ns.ROLL_ACTION_GREED] = GREED,
}

local function PrintRoll(rollAction, rollItemLink)
	if not ns.db.profile.printRolledItems then
		return
	end
	if rollAction == ns.ROLL_ACTION_PASS then
		ns:PrintMessage(L["MESSAGE_ROLL_PASS_PRINT"]:format(rollItemLink))
	else
		ns:PrintMessage(L["MESSAGE_ROLL_PRINT"]:format(ROLL_ACTION_WORDS[rollAction], rollItemLink))
	end
end

local function ExecuteTrackedRoll(rollIdentifier, rollAction, rollItemLink)
	rollsInitiatedByAddon[rollIdentifier] = true
	RollOnLoot(rollIdentifier, rollAction)
	PrintRoll(rollAction, rollItemLink)
end

--[[
    The threshold path is configured per group context: raids read the raid
    settings, everything else (party, and the rare ungrouped roll) reads the
    party settings: the roll, its Up to Quality, and Include Bind on Pickup.
    Nothing here looks at the loot method — GogoLoot acts on every
    START_LOOT_ROLL the client raises, so a roll that opens during a
    master-loot session is automated exactly like one from Group Loot or Need
    Before Greed.
]]
-- A group context's Include Bind on Pickup: the raid's in a raid, the party's anywhere else.
---@param inRaid boolean
---@return boolean
function ns.RollsBindOnPickup(inRaid)
	local profile = ns.db.profile
	if inRaid then
		return profile.rollBindOnPickupRaid and true or false
	end
	return profile.rollBindOnPickupParty and true or false
end

---@param inRaid boolean|nil # the group context to read; nil reads the group the player is in
local function GetContextRollSettings(inRaid)
	if inRaid == nil then
		inRaid = IsInRaid()
	end
	if inRaid then
		return ns.db.profile.autoRollActionRaid, ns.db.profile.autoRollThresholdRaid, ns.RollsBindOnPickup(inRaid)
	end
	return ns.db.profile.autoRollActionParty, ns.db.profile.autoRollThresholdParty, ns.RollsBindOnPickup(inRaid)
end

local function ExecuteRollOverride(rollIdentifier, rollItemLink, rollOverride, rollGreedAllowed, rollNeedAllowed)
	if rollOverride == ns.NEED then
		if rollNeedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_NEED, rollItemLink)
		elseif rollGreedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_GREED, rollItemLink)
		end
	elseif rollOverride == ns.GREED then
		if rollGreedAllowed then
			ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_GREED, rollItemLink)
		end
	elseif rollOverride == ns.PASS then
		ExecuteTrackedRoll(rollIdentifier, ns.ROLL_ACTION_PASS, rollItemLink)
	end
end

--------------------------------------------------------------------------------
-- Roll Evaluation
--------------------------------------------------------------------------------

--[[
    What Automated Rolls does with one item, for a character's rules and
    class: the roll to make (ns.NEED, ns.GREED or ns.PASS), or nil to leave
    the roll window to the player, then why ("OFF", "NEVER", "OVERRIDE",
    "QUEST", "LOW_LEVEL", "WANTED", "EVERYTHING_ELSE", "BIND_ON_PICKUP",
    "MANUAL", "QUALITY" or "ABOVE_QUALITY"). EvaluateRoll makes the roll it
    returns; the Loot Roll Sanity Check shows it, passing inRaid to read the In
    Party or In Raid settings whatever group the player is in. The gates run
    in a fixed order, and the order is the design (README-Technical.md, Item
    Overrides vs. the Automated Rolls Toggle).
]]
---@param itemIdentifier number
---@param itemInformation table
---@param itemLink string
---@param quality number
---@param rules table|nil
---@param classFile string|nil
---@param level number|nil
---@param inRaid boolean|nil # nil reads the group the player is in
---@return string|nil rollAction
---@return string reason
function ns.DecideRoll(itemIdentifier, itemInformation, itemLink, quality, rules, classFile, level, inRaid)
	if not ns.db.profile.autoGreed then
		return nil, "OFF"
	end

	-- Hard safety: legendaries, recipes/books, mounts, pets are never automated
	if ns:IsNeverAutomatedItem(itemInformation) then
		return nil, "NEVER"
	end

	--[[
        Item Overrides: a per-item override is an explicit instruction, so it
        bypasses the threshold, the BoP guard, and the quest-class skip below.
        It runs ahead of that skip deliberately — the AQ and ZG tokens the
        default list exists to roll on are all quest-class (see
        ns:IsQuestClassItem), so checking the skip first would make the whole
        feature a no-op for them.
    ]]
	if ns.db.profile.customRollList then
		local rollOverride = ns.db.profile.ignoredItemsSolo[itemIdentifier]
		if rollOverride then
			if rollOverride == ns.MANUAL then
				return nil, "OVERRIDE"
			end
			return rollOverride, "OVERRIDE"
		end
	end

	-- Unlisted quest items are never picked up by the threshold path on their own
	if ns:IsQuestClassItem(itemInformation) then
		return nil, "QUEST"
	end

	local contextRollAction, contextRollThreshold, contextBindOnPickup = GetContextRollSettings(inRaid)

	--[[
        Character Rules: gear this character wants (a ticked type carrying a
        ticked stat) keeps its roll window, whatever the quality settings
        say. Gear it doesn't want rolls the way its Everything Else row says
        (Greed by default), up to the group context's Up to Quality, Bind on
        Pickup only while Include Bind on Pickup is on, unless the group
        context is set to Manual. Gear past that quality falls through to the
        threshold path below.
    ]]
	local verdict = ns.CharacterRuleVerdict(itemInformation, itemLink, rules, classFile)
	local bindOk = itemInformation.bindType ~= ns.BIND_ON_PICKUP or contextBindOnPickup

	--[[
        Automatically Greed on Low-Level Gear: gear whose required level is
        far enough below the character's (Your Level - 5 by default) Greeds,
        matching or not, up to the group context's Up to Quality, so a leveling
        character never waits on gear it has outgrown. Bind on Pickup only
        while Include Bind on Pickup is on, and never while the group context
        is set to Manual.
    ]]
	if
		verdict
		and bindOk
		and contextRollAction ~= ns.MANUAL
		and ns.IsLowLevelGear(rules, itemInformation.requiredLevel, level)
		and quality <= contextRollThreshold
	then
		return ns.GREED, "LOW_LEVEL"
	end

	if verdict == ns.CHARACTER_RULE_WANTED then
		return nil, "WANTED"
	end
	if verdict == ns.CHARACTER_RULE_UNWANTED and contextRollAction ~= ns.MANUAL then
		-- Manual: gear that doesn't match keeps its roll window, whatever the quality settings say.
		if ns.CharacterRuleUnwanted(rules, "action") == ns.MANUAL then
			return nil, "EVERYTHING_ELSE"
		end
		if bindOk and quality <= contextRollThreshold then
			return ns.CharacterRuleUnwanted(rules, "action"), "EVERYTHING_ELSE"
		end
	end

	-- The threshold path touches BoP items only while Include Bind on Pickup is on
	if itemInformation.bindType == ns.BIND_ON_PICKUP and not contextBindOnPickup then
		return nil, "BIND_ON_PICKUP"
	end

	if contextRollAction == ns.MANUAL then
		return nil, "MANUAL"
	end

	if quality <= contextRollThreshold then
		return contextRollAction, "QUALITY"
	end
	return nil, "ABOVE_QUALITY"
end

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
local function EvaluateRoll(rollIdentifier)
	if not ns.db then
		return true
	end

	--[[
        Master switch: when Automated Rolls is off, nothing rolls
        automatically, Item Overrides included.
    ]]
	if not ns.db.profile.autoGreed then
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
        session. Treating it as "roll no longer live" silently drops Item
        Overrides tokens whose drop races the item cache: no retry, no roll, no
        error. Dead rolls don't reach this read, because CANCEL_LOOT_ROLL
        cancels the retry timer outright.
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

	local _, playerClassFile = UnitClass("player")
	local rollAction = ns.DecideRoll(
		parsedItemLink.itemIdentifier,
		itemInformation,
		rollItemLink,
		rollQuality,
		ns.db.char.characterRules,
		playerClassFile,
		UnitLevel("player")
	)
	if rollAction then
		ExecuteRollOverride(rollIdentifier, rollItemLink, rollAction, rollGreedAllowed, rollNeedAllowed)
	end
	return true
end

--[[
    Polls a roll whose item info wasn't cached at START_LOOT_ROLL time. Runs
    every ROLL_RETRY_INTERVAL until the info resolves and the roll is decided.
    Each tick re-arms the same named timer, so CANCEL_LOOT_ROLL canceling that
    name is all it takes to tear the poll down when the roll ends; the attempt
    cap only bounds a cancel that never arrives. There is deliberately no
    "still live?" probe inside the tick — the one read that could answer it,
    GetLootRollItemLink, is nil for unresolved items too, and bailing on it
    would drop exactly the rolls the retry exists for.
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

local function OnStartLootRoll(rollIdentifier)
	if not EvaluateRoll(rollIdentifier) then
		ScheduleRollRetry(rollIdentifier)
	end
end

ns:RegisterModuleEvent("START_LOOT_ROLL", OnStartLootRoll)

--------------------------------------------------------------------------------
-- CONFIRM_LOOT_ROLL & CANCEL_LOOT_ROLL
--------------------------------------------------------------------------------

local function OnConfirmLootRoll(rollIdentifier, rollAction)
	if not rollsInitiatedByAddon[rollIdentifier] then
		return
	end
	rollsInitiatedByAddon[rollIdentifier] = nil
	ConfirmLootRoll(rollIdentifier, rollAction)
end

local function OnCancelLootRoll(rollIdentifier)
	rollsInitiatedByAddon[rollIdentifier] = nil
	ns:CancelTimer(ROLL_RETRY_TIMER_PREFIX .. rollIdentifier)
end

ns:RegisterModuleEvent("CONFIRM_LOOT_ROLL", OnConfirmLootRoll)
ns:RegisterModuleEvent("CANCEL_LOOT_ROLL", OnCancelLootRoll)

--------------------------------------------------------------------------------
-- Safety Warnings
--------------------------------------------------------------------------------

--[[
    Need and Pass both give loot away without asking: Need takes it from the
    group, Pass leaves it to them. So entering a dungeon or raid while the roll
    GogoLoot will make there is one of those prints a reminder in chat, and,
    with Play Sound on, plays an alert. The roll is the one the rolls
    themselves read (GetContextRollSettings): the raid's in a raid group, the
    party's otherwise. Greed and Manual say nothing.

    It waits a moment after the loading screen so the line lands below the
    zone-in chatter, and checks again then in case the player has already
    left. A /reload inside the instance stays quiet. Coming back into the same
    instance with the same roll inside SAFETY_WARNING_REPEAT_SECONDS stays
    quiet too, so a corpse run doesn't repeat it; a later run warns again.
]]
local SAFETY_WARNING_TIMER = "GogoLoot.RollSafetyWarning"
local SAFETY_WARNING_DELAY = 3
local SAFETY_WARNING_REPEAT_SECONDS = 30 * 60

local SAFETY_WARNING_INSTANCE_TYPES = { party = true, raid = true }
local SAFETY_WARNING_ACTIONS = { [ns.NEED] = NEED, [ns.PASS] = PASS }

local lastSafetyWarning

-- The warning's text: the roll in the game's word, then the quality ceiling in its color.
---@param action string ns.NEED or ns.PASS
---@param threshold number
---@return string
function ns.BuildRollSafetyWarning(action, threshold)
	local qualityName = _G["ITEM_QUALITY" .. threshold .. "_DESC"] or tostring(threshold)
	local quality = ns.GetQualityColor(threshold) .. qualityName .. "|r"
	return L["MESSAGE_ROLL_SAFETY_WARNING"]:format(SAFETY_WARNING_ACTIONS[action] or action, quality)
end

-- The alert, on the Master channel so it's heard with sound effects off; the panel's speaker plays it too.
function ns.PlayRollSafetyWarning()
	PlaySoundFile(ns.ROLL_SAFETY_WARNING_SOUND_FILE, "Master")
end

local function CheckRollSafety()
	local profile = ns.db and ns.db.profile
	if not (profile and profile.autoGreed and profile.rollSafetyWarning) then
		return
	end
	local instanceName, instanceType, _, _, _, _, _, instanceIdentifier = GetInstanceInfo()
	if not SAFETY_WARNING_INSTANCE_TYPES[instanceType] then
		return
	end
	local action, threshold = GetContextRollSettings()
	if not SAFETY_WARNING_ACTIONS[action] then
		return
	end

	local instanceKey = instanceIdentifier or instanceName
	local now = GetTime()
	local last = lastSafetyWarning
	if
		last
		and last.instance == instanceKey
		and last.action == action
		and now - last.at < SAFETY_WARNING_REPEAT_SECONDS
	then
		return
	end
	lastSafetyWarning = { instance = instanceKey, action = action, at = now }

	ns:PrintMessage(ns.BuildRollSafetyWarning(action, threshold))
	if profile.rollSafetyWarningSound then
		ns.PlayRollSafetyWarning()
	end
end

local function OnSafetyWarningEnteringWorld(_, isReloadingUi)
	if isReloadingUi then
		return
	end
	ns:After(SAFETY_WARNING_TIMER, SAFETY_WARNING_DELAY, CheckRollSafety)
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnSafetyWarningEnteringWorld)
