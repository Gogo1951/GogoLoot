--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

-- With autoGreed off nothing here does anything, so the rest of the panel hides rather than sitting grayed out.
local function RollsOff()
	return not ns.db.profile.autoGreed
end

---@param entry table
---@return table # the same entry, hidden while the master switch is off
local function HideWhenRollsOff(entry)
	entry.hidden = RollsOff
	return entry
end

-- Greed, the default roll.
local EXAMPLE_ITEM_QUALITY = 2

local function PrintItemExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[EXAMPLE_ITEM_QUALITY])
	return ns.OptionsPrintedLine(L["MESSAGE_ROLL_PRINT"]:format(GREED, item))
end

-- Shown only while that line prints: Hide Roll Messages on, and Print beside it.
local EXAMPLE_PLAYER_CLASS = "DRUID"
local EXAMPLE_ROLL = 95

local function WinnerSummaryExample()
	local winner = ns.OptionsExampleOther(EXAMPLE_PLAYER_CLASS)
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[EXAMPLE_ITEM_QUALITY])
	local rollText = L["LOOT_TOASTS_ROLL_RESULT"]:format(GREED, EXAMPLE_ROLL)
	return ns.OptionsPrintedLine(L["MESSAGE_ROLL_WON_PRINT"]:format(winner, item, rollText))
end

local function WinnerSummaryExampleHidden()
	return RollsOff() or not ns.PrintingWinnerSummary()
end

-- Need on Uncommon and lower, the shipped quality ceiling.
local function SafetyWarningExample()
	return ns.OptionsPrintedLine(ns.BuildRollSafetyWarning(ns.NEED, EXAMPLE_ITEM_QUALITY))
end

local function SafetyWarningOff()
	return RollsOff() or not ns.db.profile.rollSafetyWarning
end

---@return table
function ns.BuildAutomatedRollOptions()
	local rollThresholdValues = {}
	for quality, label in pairs(ns.ROLL_THRESHOLD_LABELS) do
		rollThresholdValues[quality] = GetQualityColor(quality) .. label .. "|r"
	end

	local args = {}
	local order = 1

	args.description =
		Kit.Desc(L["ROLLS_PANEL_DESCRIPTION"]:format(NEED, GREED, PASS) .. " " .. L["SAFETY_SKIP_NOTE"], order)
	order = order + 1
	args.spacerAfterDesc = Kit.Spacer(order)
	order = order + 1
	args.autoGreed = ns.FeatureSwitch("autoGreed", order)
	order = order + 1
	args.spacerAfterToggle = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	args.partyAndRaidHeader = Kit.Header(L["ROLLS_PARTY_AND_RAID_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterPartyAndRaidHeader = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1

	--[[
        Manual turns automation off for one context alone, without the master
        switch; its sub-rows leave with it, having nothing left to limit.
    ]]
	local rollContexts = {
		{ configurationSuffix = "Party", label = L["ROLLS_IN_PARTY"] },
		{ configurationSuffix = "Raid", label = L["ROLLS_IN_RAID"] },
	}

	for index, entry in ipairs(rollContexts) do
		local thresholdKey = "autoRollThreshold" .. entry.configurationSuffix
		local bindOnPickupKey = "rollBindOnPickup" .. entry.configurationSuffix
		local actionKey = "autoRollAction" .. entry.configurationSuffix
		local function QualityRowHidden()
			return RollsOff() or ns.db.profile[actionKey] == ns.MANUAL
		end

		if index > 1 then
			args["spacerBeforeRollRow" .. entry.configurationSuffix] = HideWhenRollsOff(Kit.Spacer(order))
			order = order + 1
		end
		args["rollRow" .. entry.configurationSuffix] = Kit.LabelRow(order, RollsOff, entry.label, {
			type = "select",
			desc = string.format(L["ROLLS_ACTION_CHOOSE"], entry.label),
			style = "dropdown",
			values = ns.ROLL_OVERRIDE_LABELS,
			sorting = ns.ROLL_OVERRIDE_ORDER,
			get = Kit.Get("profile", actionKey),
			set = Kit.Set("profile", actionKey),
		})
		order = order + 1
		args["qualityRow" .. entry.configurationSuffix] =
			Kit.SubLabelRow(order, QualityRowHidden, L["ROLLS_UP_TO_QUALITY"], {
				type = "select",
				desc = string.format(L["ROLLS_THRESHOLD_CHOOSE"], entry.label),
				style = "dropdown",
				values = rollThresholdValues,
				get = Kit.Get("profile", thresholdKey),
				set = Kit.Set("profile", thresholdKey),
			})
		order = order + 1
		args["bindOnPickupRow" .. entry.configurationSuffix] = Kit.SubToggleRow(order, QualityRowHidden, {
			type = "toggle",
			name = L["ROLLS_INCLUDE_BIND_ON_PICKUP"],
			desc = L["ROLLS_INCLUDE_BIND_ON_PICKUP_DESCRIPTION"],
			get = Kit.Get("profile", bindOnPickupKey),
			set = Kit.Set("profile", bindOnPickupKey),
		})
		order = order + 1
	end

	args.spacerBeforeRollMessages = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	args.rollMessagesHeader = Kit.Header(L["ROLLS_MESSAGES_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterRollMessagesHeader = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	args.printRolledItems = HideWhenRollsOff({
		type = "toggle",
		name = L["ROLLS_PRINT_ITEM"],
		desc = L["ROLLS_PRINT_ITEM_DESCRIPTION"],
		width = "full",
		order = order,
		get = Kit.Get("profile", "printRolledItems"),
		set = Kit.Set("profile", "printRolledItems"),
	})
	order = order + 1
	args.printRolledItemsExampleRow = Kit.Example(order, function()
		return RollsOff() or not ns.db.profile.printRolledItems
	end, PrintItemExample)
	order = order + 1
	args.spacerAfterPrintRolledItems = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	-- The winner summary hides with the toggle off: the game's own won line then says who won.
	args.hideRollMessagesRow = HideWhenRollsOff(Kit.ToggleRow(order, {
		type = "toggle",
		name = L["ROLLS_HIDE_MESSAGES"],
		desc = L["ROLLS_HIDE_MESSAGES_TOOLTIP"]:format(NEED, GREED, PASS),
		get = Kit.Get("profile", "hideRollMessages"),
		set = Kit.Set("profile", "hideRollMessages"),
	}, {
		control = {
			type = "select",
			desc = L["ROLLS_WINNER_SUMMARY_DESCRIPTION"],
			style = "dropdown",
			values = {
				[ns.WINNER_SUMMARY_PRINT] = L["ROLLS_WINNER_SUMMARY_PRINT"],
				[ns.WINNER_SUMMARY_NONE] = L["ROLLS_WINNER_SUMMARY_NONE"],
			},
			sorting = { ns.WINNER_SUMMARY_PRINT, ns.WINNER_SUMMARY_NONE },
			get = Kit.Get("profile", "winnerSummary"),
			set = Kit.Set("profile", "winnerSummary"),
		},
	}))
	order = order + 1
	args.winnerSummaryExampleRow = Kit.Example(order, WinnerSummaryExampleHidden, WinnerSummaryExample)
	order = order + 1

	args.spacerBeforeSafetyWarnings = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	args.safetyWarningsHeader = Kit.Header(L["ROLLS_SAFETY_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterSafetyWarningsHeader = HideWhenRollsOff(Kit.Spacer(order))
	order = order + 1
	args.rollSafetyWarning = HideWhenRollsOff({
		type = "toggle",
		name = L["ROLLS_SAFETY_WARNING"]:format(NEED, PASS),
		desc = L["ROLLS_SAFETY_WARNING_DESCRIPTION"]:format(NEED, PASS),
		width = "full",
		order = order,
		get = Kit.Get("profile", "rollSafetyWarning"),
		set = Kit.Set("profile", "rollSafetyWarning"),
	})
	order = order + 1
	args.rollSafetyWarningSoundRow = Kit.SubRow(order, SafetyWarningOff, {
		{
			type = "toggle",
			name = Kit.SubLabel(L["ROLLS_SAFETY_WARNING_SOUND"]),
			desc = L["ROLLS_SAFETY_WARNING_SOUND_DESCRIPTION"],
			width = Kit.SUB_LABEL_WIDTH,
			get = Kit.Get("profile", "rollSafetyWarningSound"),
			set = Kit.Set("profile", "rollSafetyWarningSound"),
		},
		{ type = "description", name = " ", width = Kit.CONTROL_WIDTH },
		Kit.SoundPreview(ns.PlayRollSafetyWarning),
	})
	order = order + 1
	args.rollSafetyWarningExampleRow = Kit.Example(order, SafetyWarningOff, SafetyWarningExample)

	return {
		type = "group",
		name = L["TAB_AUTOMATED_ROLLS"],
		args = args,
	}
end
