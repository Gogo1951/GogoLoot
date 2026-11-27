--------------------------------------------------------------------------------
-- GogoLoot Automated Rolls Module
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Add-on-Initiated Roll Tracking
--------------------------------------------------------------------------------

-- Only GogoLoot's own rolls get their bind dialog auto-confirmed; the player's keep Blizzard's.
local rollsInitiatedByAddon = {}

--[[
    CANCEL_LOOT_ROLL cancelling the named timer is the teardown. The attempt cap
    only backstops a cancel that never arrives, so it is sized past the 60-second
    roll window and must never become the give-up point: a war-effort token's
    first drop of the night can keep its item query in flight past a short cap,
    and giving up there means no roll and no error.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."
local ROLL_RETRY_INTERVAL = 0.5
local ROLL_RETRY_MAX_ATTEMPTS = 150

--[[
    Print Item in Chat: the roll window closes the moment GogoLoot rolls. The
    line names the roll actually made, so a Need that fell back to Greed reads
    as Greed.
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
    Raids read the raid settings; party and the rare ungrouped roll read the
    party's. No loot-method check: a roll in a master-loot session is automated
    like any other.
]]
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

-- A nil roll leaves the window to the player. The gates run in a fixed order, and the order is the design.
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

	if ns:IsNeverAutomatedItem(itemInformation) then
		return nil, "NEVER"
	end

	--[[
        Item Overrides bypass the threshold, the BoP guard and the quest skip,
        and run ahead of that skip deliberately: the AQ and ZG tokens the default
        list exists for are all quest-class.
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

	if ns:IsQuestClassItem(itemInformation) then
		return nil, "QUEST"
	end

	local contextRollAction, contextRollThreshold, contextBindOnPickup = GetContextRollSettings(inRaid)

	--[[
        Wanted gear keeps its roll window at any quality. Unwanted gear rolls its
        Everything Else action up to the context's quality unless the context is
        Manual; past that quality it falls through to the threshold path.
    ]]
	local verdict = ns.CharacterRuleVerdict(itemInformation, itemLink, rules, classFile)
	local bindOk = itemInformation.bindType ~= ns.BIND_ON_PICKUP or contextBindOnPickup

	-- Low-Level Gear Greeds, wanted or not, so a leveling character never waits on gear it has outgrown.
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
		if ns.CharacterRuleUnwanted(rules, "action") == ns.MANUAL then
			return nil, "EVERYTHING_ELSE"
		end
		if bindOk and quality <= contextRollThreshold then
			return ns.CharacterRuleUnwanted(rules, "action"), "EVERYTHING_ELSE"
		end
	end

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

-- A caller holding the exact link passes it, so Character Rules reads its random suffix's stats.
---@param itemIdentifier number
---@param inRaid boolean
---@param exactLink string|nil
---@return string|nil rollAction
---@return string|nil reason
function ns.DecidePlayerRoll(itemIdentifier, inRaid, exactLink)
	local itemLink = exactLink or select(2, C_Item.GetItemInfo(itemIdentifier))
	local itemInformation = itemLink and ns:SafeGetItemInfo(itemLink)
	if not itemInformation then
		return nil, nil
	end
	local _, classFile = UnitClass("player")
	return ns.DecideRoll(
		itemIdentifier,
		itemInformation,
		itemLink,
		itemInformation.quality,
		ns.db.char.characterRules,
		classFile,
		UnitLevel("player"),
		inRaid
	)
end

--[[
    True once decided, rolled or not; false while the item is unresolved, so the
    caller retries. Re-reads everything, so a retry tick behaves exactly like the
    event. Never decided from GetLootRollItemInfo alone: the class and subclass
    skips need full item info.
]]
local function EvaluateRoll(rollIdentifier)
	if not ns.db then
		return true
	end

	if not ns.db.profile.autoGreed then
		return true
	end

	-- texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, ...
	local _, _, _, rollQuality, _, rollNeedAllowed, rollGreedAllowed = GetLootRollItemInfo(rollIdentifier)

	--[[
        A nil link is an unresolved item, not a dead roll (Blizzard's
        GroupLootFrame_OnShow bails the same way): the normal state of a token's
        first drop of the session. Dead rolls never get here, since
        CANCEL_LOOT_ROLL cancels the retry.
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
    Deliberately no "still live?" probe in the tick: the one read that could
    answer, GetLootRollItemLink, is nil for unresolved items too, and bailing on
    it would drop exactly the rolls the retry exists for.
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
    Need and Pass both give loot away unasked, so entering a dungeon or raid with
    either set warns. It waits so the line lands below the zone-in chatter; the
    same instance and roll within SAFETY_WARNING_REPEAT_SECONDS stays quiet, so
    a corpse run doesn't repeat it.
]]
local SAFETY_WARNING_TIMER = "GogoLoot.RollSafetyWarning"
local SAFETY_WARNING_DELAY = 3
local SAFETY_WARNING_REPEAT_SECONDS = 30 * 60

local SAFETY_WARNING_INSTANCE_TYPES = { party = true, raid = true }
local SAFETY_WARNING_ACTIONS = { [ns.NEED] = NEED, [ns.PASS] = PASS }

local lastSafetyWarning

---@param action string ns.NEED or ns.PASS
---@param threshold number
---@return string
function ns.BuildRollSafetyWarning(action, threshold)
	local qualityName = _G["ITEM_QUALITY" .. threshold .. "_DESC"] or tostring(threshold)
	local quality = ns.GetQualityColor(threshold) .. qualityName .. "|r"
	return L["MESSAGE_ROLL_SAFETY_WARNING"]:format(SAFETY_WARNING_ACTIONS[action] or action, quality)
end

-- Master channel, so it's heard with sound effects off.
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

local function OnPlayerEnteringWorld(_, isReloadingUi)
	if isReloadingUi then
		return
	end
	ns:After(SAFETY_WARNING_TIMER, SAFETY_WARNING_DELAY, CheckRollSafety)
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)

--------------------------------------------------------------------------------
-- Automated Rolls On by Default
--------------------------------------------------------------------------------

-- Ships on (maintainer, 2026-11-07), reaching everyone who never touched the switch, so chat says so once per account.
local function OnPlayerLogin()
	if not ns.db or not ns.db.profile.autoGreed or ns.db.global.automatedRollsOnNoticeShown then
		return
	end
	ns.db.global.automatedRollsOnNoticeShown = true
	ns:PrintMessage(L["MESSAGE_AUTOMATED_ROLLS_ON"])
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
