--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Automated Rolls, drawn on this panel and again in the Features
    section of the General panel. Built once here so the two can never drift;
    each caller sets its own order and width.
]]
---@return table
function ns.AutomatedRollsSwitch()
	return {
		type = "toggle",
		name = L["ROLLS_ENABLE"],
		desc = L["ROLLS_ENABLE_DESCRIPTION"],
		get = function()
			return ns.db.profile.autoGreed
		end,
		set = function(_, value)
			ns.db.profile.autoGreed = value
			if ns.UpdateMinimapIcon then
				ns:UpdateMinimapIcon()
			end
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    autoGreed is the master switch for every automated roll, Item Overrides
    included, so with it off nothing below it on this panel changes anything.
    The rest of the panel therefore hides rather than sitting there inert: a
    player who has turned the feature off is not choosing a threshold, and
    greying out a page of controls says the same thing at far greater length.
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
    What Print Item in Chat prints, drawn by ns.OptionsExampleRow (Message
    Examples in Options-Utilities.lua): a Greed, the default roll, run through
    its real template and laid out as printed.
]]
local EXAMPLE_ITEM_QUALITY = 2

local function PrintItemExample()
	return ns.OptionsPrintedExample(L["MESSAGE_ROLL_PRINT"]:format(GREED, ns.OptionsExampleItem(EXAMPLE_ITEM_QUALITY)))
end

--[[
    What Print Winner Summary prints for a group member's win, the roll worded
    as the toasts word it and the winner in a class color, as in chat. The
    silver after the name keeps the rest of the example line silver.
]]
local EXAMPLE_PLAYER = "Aero"
local EXAMPLE_PLAYER_CLASS = "WARRIOR"
local EXAMPLE_ROLL = 95

local function WinnerSummaryExample()
	local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[EXAMPLE_PLAYER_CLASS]
	local winner = EXAMPLE_PLAYER
	if type(classColor) == "table" and type(classColor.colorStr) == "string" then
		winner = "|c" .. classColor.colorStr .. EXAMPLE_PLAYER .. ns.GetColor("HELP")
	end
	local rollText = L["LOOT_TOASTS_ROLL_RESULT"]:format(GREED, EXAMPLE_ROLL)
	return ns.OptionsPrintedExample(
		L["MESSAGE_ROLL_WON_PRINT"]:format(winner, ns.OptionsExampleItem(EXAMPLE_ITEM_QUALITY), rollText)
	)
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
		ns.OptionsDesc(L["ROLLS_PANEL_DESCRIPTION"]:format(NEED, GREED, PASS) .. " " .. L["SAFETY_SKIP_NOTE"], order)
	order = order + 1
	args.spacerAfterDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.autoGreed = ns.AutomatedRollsSwitch()
	args.autoGreed.width = "full"
	args.autoGreed.order = order
	order = order + 1
	args.spacerAfterToggle = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.lootThresholdsHeader = ns.OptionsHeader(L["ROLLS_LOOT_THRESHOLDS_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterLootThresholdsHeader = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1

	--[[
        Each group context is a label-beside-control row, its caption at the
        panel's own level with the roll beside it, and the quality ceiling that
        roll applies to on an indented sub-row under it. Manual turns automation
        off for that context alone, so Automated Rolls can run in raids but not
        parties (or the reverse) without touching the master switch, and the
        quality row leaves with it, having nothing left to limit.
    ]]
	local rollContexts = {
		{ configurationSuffix = "Party", label = L["ROLLS_IN_PARTY"] },
		{ configurationSuffix = "Raid", label = L["ROLLS_IN_RAID"] },
	}

	for index, entry in ipairs(rollContexts) do
		local thresholdKey = "autoRollThreshold" .. entry.configurationSuffix
		local actionKey = "autoRollAction" .. entry.configurationSuffix
		local function QualityRowHidden()
			return RollsOff() or ns.db.profile[actionKey] == ns.MANUAL
		end

		if index > 1 then
			args["spacerBeforeRollRow" .. entry.configurationSuffix] = HideWhenRollsOff(ns.OptionsSpacer(order))
			order = order + 1
		end
		args["rollRow" .. entry.configurationSuffix] = ns.OptionsSelectRow(order, RollsOff, entry.label, {
			type = "select",
			desc = string.format(L["ROLLS_ACTION_CHOOSE"], entry.label),
			style = "dropdown",
			values = ns.ROLL_OVERRIDE_LABELS,
			sorting = ns.ROLL_OVERRIDE_ORDER,
			get = function()
				return ns.db.profile[actionKey]
			end,
			set = function(_, value)
				ns.db.profile[actionKey] = value
			end,
		})
		order = order + 1
		args["qualityRow" .. entry.configurationSuffix] =
			ns.OptionsSubSelectRow(order, QualityRowHidden, L["ROLLS_UP_TO_QUALITY"], {
				type = "select",
				desc = string.format(L["ROLLS_THRESHOLD_CHOOSE"], entry.label),
				style = "dropdown",
				values = rollThresholdValues,
				get = function()
					return ns.db.profile[thresholdKey]
				end,
				set = function(_, value)
					ns.db.profile[thresholdKey] = value
				end,
			})
		order = order + 1
	end

	--[[
        Roll Messages: what GogoLoot prints for its own rolls, and the game's
        roll lines it keeps out of chat. Both are part of Automated Rolls, so
        they leave with the switch, and neither does anything while it is off.
    ]]
	args.spacerBeforeRollMessages = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.rollMessagesHeader = ns.OptionsHeader(L["ROLLS_MESSAGES_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterRollMessagesHeader = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.printRolledItems = HideWhenRollsOff({
		type = "toggle",
		name = L["ROLLS_PRINT_ITEM"],
		desc = L["ROLLS_PRINT_ITEM_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.printRolledItems
		end,
		set = function(_, value)
			ns.db.profile.printRolledItems = value
		end,
	})
	order = order + 1
	args.printRolledItemsExampleRow = HideWhenRollsOff(ns.OptionsExampleRow(order, PrintItemExample))
	order = order + 1
	args.spacerAfterPrintRolledItems = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	--[[
        Hide Roll Messages with the winner summary beside it, which leaves the
        line while the toggle is off (ns.OptionsToggleRow): with the game's
        roll lines showing, its won line says who won already.
    ]]
	args.hideRollMessagesRow = HideWhenRollsOff(ns.OptionsToggleRow(order, {
		type = "toggle",
		name = L["ROLLS_HIDE_MESSAGES"],
		desc = L["ROLLS_HIDE_MESSAGES_TOOLTIP"]:format(NEED, GREED, PASS),
		get = function()
			return ns.db.profile.hideRollMessages
		end,
		set = function(_, value)
			ns.db.profile.hideRollMessages = value
		end,
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
			get = function()
				return ns.db.profile.winnerSummary
			end,
			set = function(_, value)
				ns.db.profile.winnerSummary = value
			end,
		},
	}))
	order = order + 1
	args.winnerSummaryExampleRow = HideWhenRollsOff(ns.OptionsExampleRow(order, WinnerSummaryExample))

	return {
		type = "group",
		name = L["TAB_AUTOMATED_ROLLS"],
		args = args,
	}
end
