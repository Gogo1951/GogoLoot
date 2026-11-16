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

--[[
    autoGreed is the master switch for every automated roll, Item Overrides
    included, so with it off nothing below it on this panel changes anything.
    The rest of the panel therefore hides rather than sitting there inert: a
    player who has turned the feature off is not choosing a threshold, and
    graying out a page of controls says the same thing at far greater length.
    Item Overrides keeps its own panel and its own switch.
]]
local function RollsOff()
	return not ns.db.profile.autoGreed
end

---@param entry table
---@return table # the same entry, hidden while the master switch is off
local function HideWhenRollsOff(entry)
	entry.hidden = RollsOff
	return entry
end

--[[
    What Print Item in Chat prints, drawn by Kit.Example: a Greed, the default
    roll, run through its real template and drawn as printed. It leaves while
    Print Item in Chat is off.
]]
local EXAMPLE_ITEM_QUALITY = 2

local function PrintItemExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[EXAMPLE_ITEM_QUALITY])
	return ns.OptionsPrintedLine(L["MESSAGE_ROLL_PRINT"]:format(GREED, item))
end

--[[
    What Print Winner Summary prints for a group member's win, the roll worded
    as the toasts word it and the winner in a class color, as in chat. Shown
    only while that line prints: Hide Roll Messages on, and Print beside it.
]]
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

--[[
    What the Safety Warning prints on entering a dungeon set to Need on
    Uncommon and lower, the shipped quality ceiling. Its Play Sound row and
    this Example leave while the warning is off.
]]
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
        Each group context is a label-beside-control row, its caption at the
        panel's own level with the roll beside it, then on indented sub-rows the
        quality ceiling that roll applies to and its Include Bind on Pickup.
        Include Bind on Pickup is off by default, since Bind on Pickup gear is
        usually worth rolling on yourself; on, that context's roll and
        Character Overrides' Everything Else roll on it too. Manual turns
        automation off for that context alone, so Automated Rolls can run in
        raids but not parties (or the reverse) without touching the master
        switch, and both sub-rows leave with it, having nothing left to limit.
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

	--[[
        Roll Messages: what GogoLoot prints for its own rolls, and the game's
        roll lines it keeps out of chat. Both are part of Automated Rolls, so
        they leave with the switch, and neither does anything while it is off.
    ]]
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
	--[[
        Hide Roll Messages with the winner summary beside it, which leaves the
        line while the toggle is off (Kit.ToggleRow): with the game's
        roll lines showing, its won line says who won already.
    ]]
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

	--[[
        Safety Warnings: the reminder on entering a dungeon or raid whose roll
        is Need or Pass, its Play Sound on an indented row with the speaker
        where every other speaker on the panels sits, and its Example. Part of
        Automated Rolls, so it leaves with the switch.
    ]]
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
