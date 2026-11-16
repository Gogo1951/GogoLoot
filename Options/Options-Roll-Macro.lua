--------------------------------------------------------------------------------
-- GogoLoot Options — Roll Macro
--------------------------------------------------------------------------------

--[[
    The panel after Automated Master Looting: Enable Roll Macro, then what the
    macro does with each mouse button, then Raid Rolls: what a raid roll is and
    Enable Raid Roll Winner (Raid-Roll-Winner.lua) with where it says the
    winner. Raid Rolls shows whether or not the macro is on, since it reads
    anyone's raid roll.

    Schema (ns.DATABASE_DEFAULTS in Default-Settings.lua):
      global.rollMacro
        - account-wide, like the General macro it keeps; read by Roll-Macro.lua
      profile.raidRollWinner, profile.raidRollOutput
        - read by Raid-Roll-Winner.lua
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Click Rows
--------------------------------------------------------------------------------

-- Each mouse button's name, in the mini-map menu's blue, beside what it rolls.
local CLICK_ROWS = {
	{ click = "MENU_CLICK_LEFT", action = "ROLL_MACRO_LEFT_CLICK" },
	{ click = "MENU_CLICK_RIGHT", action = "ROLL_MACRO_RIGHT_CLICK" },
	{ click = "MENU_CLICK_MIDDLE", action = "ROLL_MACRO_MIDDLE_CLICK" },
}

-- Room after the longest button name, so the rolls never sit against it.
local CLICK_COLUMN_PADDING_PIXELS = 24

--[[
    One row per button, every name in a column as wide as the longest one
    measured in this client's language, plus padding, so the three rolls line
    up. A description's medium font is the font MeasureCaptionPixels reads.
]]
---@param firstOrder number
---@param args table # the panel's args; the rows are added to it
---@return nil
local function AddClickRows(firstOrder, args)
	local widestPixels = 0
	for _, row in ipairs(CLICK_ROWS) do
		widestPixels = math.max(widestPixels, ns.MeasureCaptionPixels(L[row.click]))
	end
	local clickWidth = (widestPixels + CLICK_COLUMN_PADDING_PIXELS) / Kit.UNIT_POINTS

	for index, row in ipairs(CLICK_ROWS) do
		args["clickRow" .. index] = Kit.Row(firstOrder + index - 1, nil, {
			Kit.Label(GetColor("INFO") .. L[row.click] .. "|r", 0, clickWidth),
			Kit.Label(GetColor("TEXT") .. L[row.action] .. "|r", 0, Kit.ROW_WIDTH - clickWidth),
		})
	end
end

--------------------------------------------------------------------------------
-- Raid Rolls
--------------------------------------------------------------------------------

local RAID_ROLL_OUTPUT_VALUES = {
	[ns.RAID_ROLL_OUTPUT_SELF] = L["CHANNEL_ME_ONLY"],
	[ns.RAID_ROLL_OUTPUT_GROUP] = L["CHANNEL_GROUP_CHAT"],
}
local RAID_ROLL_OUTPUT_SORTING = { ns.RAID_ROLL_OUTPUT_SELF, ns.RAID_ROLL_OUTPUT_GROUP }

-- The example's roll: a Rogue rolls 7 in a group of 10, which lands on a Priest.
local EXAMPLE_ROLLER, EXAMPLE_ROLLER_CLASS = "Fathom", "ROGUE"
local EXAMPLE_WINNER, EXAMPLE_WINNER_CLASS = "Katz", "PRIEST"
local EXAMPLE_ROLL, EXAMPLE_GROUP_SIZE = 7, 10

local function RaidRollWinnerOff()
	return not ns.db.profile.raidRollWinner
end

-- The line the current Me Only or Group Chat choice gives, as the player's chat shows it.
local function RaidRollExampleLine()
	if ns.db.profile.raidRollOutput == ns.RAID_ROLL_OUTPUT_GROUP then
		return Kit.SentLine(
			"PARTY",
			ns:BuildAnnounceMessage(
				"MESSAGE_RAID_ROLL",
				EXAMPLE_ROLLER,
				EXAMPLE_ROLL,
				EXAMPLE_GROUP_SIZE,
				EXAMPLE_WINNER
			)
		)
	end
	return ns.OptionsPrintedLine(
		ns.BuildRaidRollPrint(
			EXAMPLE_ROLLER,
			EXAMPLE_ROLLER_CLASS,
			EXAMPLE_ROLL,
			EXAMPLE_GROUP_SIZE,
			EXAMPLE_WINNER,
			EXAMPLE_WINNER_CLASS
		)
	)
end

---@param firstOrder number
---@param args table # the panel's args; the section is added to it
---@return nil
local function AddRaidRolls(firstOrder, args)
	local order = Kit.Section(args, "raidRoll", firstOrder, L["RAID_ROLL_HEADER"])
	args.raidRollNote = Kit.Desc(GetColor("HELP") .. L["ROLL_MACRO_RAID_ROLL_NOTE"] .. "|r", order)
	args.spacerAfterRaidRollNote = Kit.Spacer(order + 1)
	args.raidRollWinnerRow = Kit.ToggleRow(order + 2, {
		type = "toggle",
		name = L["RAID_ROLL_WINNER_ENABLE"],
		desc = L["RAID_ROLL_WINNER_ENABLE_DESCRIPTION"],
		get = Kit.Get("profile", "raidRollWinner"),
		set = Kit.Set("profile", "raidRollWinner"),
	}, {
		control = {
			type = "select",
			desc = L["RAID_ROLL_OUTPUT_DESCRIPTION"],
			style = "dropdown",
			values = RAID_ROLL_OUTPUT_VALUES,
			sorting = RAID_ROLL_OUTPUT_SORTING,
			get = Kit.GetChoice("profile", "raidRollOutput", RAID_ROLL_OUTPUT_VALUES, ns.RAID_ROLL_OUTPUT_SELF),
			set = Kit.Set("profile", "raidRollOutput"),
		},
	})
	args.raidRollExample = Kit.Example(order + 3, RaidRollWinnerOff, RaidRollExampleLine)
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildRollMacroOptions()
	local args = {
		description = Kit.Desc(L["ROLL_MACRO_DESCRIPTION"]:format(ns.ROLL_MACRO_NAME), 1),
		spacerAfterDesc = Kit.Spacer(2),
		rollMacro = ns.FeatureSwitch("rollMacro", 3),
		spacerAfterSwitch = Kit.Spacer(4),
	}
	AddClickRows(5, args)
	AddRaidRolls(8, args)

	return {
		type = "group",
		name = L["TAB_ROLL_MACRO"],
		args = args,
	}
end
