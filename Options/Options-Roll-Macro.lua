--------------------------------------------------------------------------------
-- GogoLoot Options — Roll Macro
--------------------------------------------------------------------------------

--[[
    The panel after Automated Master Looting: Enable Roll Macro, then what the
    macro does with each mouse button, then what a raid roll is.

    Schema (ns.DATABASE_DEFAULTS.global in Default-Settings.lua):
      rollMacro
        - account-wide, like the General macro it keeps; read by Roll-Macro.lua
]]
local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Click Rows
--------------------------------------------------------------------------------

-- Each mouse button's name, in the mini-map tooltip's blue, beside what it rolls.
local CLICK_ROWS = {
	{ click = "MINIMAP_LEFT_CLICK", action = "ROLL_MACRO_LEFT_CLICK" },
	{ click = "MINIMAP_RIGHT_CLICK", action = "ROLL_MACRO_RIGHT_CLICK" },
	{ click = "MINIMAP_MIDDLE_CLICK", action = "ROLL_MACRO_MIDDLE_CLICK" },
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
	local clickWidth = (widestPixels + CLICK_COLUMN_PADDING_PIXELS) / ns.OPTIONS_PIXELS_PER_WIDTH_UNIT

	for index, row in ipairs(CLICK_ROWS) do
		args["clickRow" .. index] = ns.OptionsRow(firstOrder + index - 1, nil, {
			ns.OptionsRowLabel(GetColor("INFO") .. L[row.click] .. "|r", 0, clickWidth),
			ns.OptionsRowLabel(GetColor("TEXT") .. L[row.action] .. "|r", 0, ns.OPTIONS_ROW_WIDTH - clickWidth),
		})
	end
end

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Roll Macro, drawn on this panel and again in the Features section of
    the General panel. Built once here so the two can never drift; each caller
    sets its own order and width.
]]
---@return table
function ns.RollMacroSwitch()
	return {
		type = "toggle",
		name = L["ROLL_MACRO_ENABLE"],
		desc = L["ROLL_MACRO_SWITCH_DESCRIPTION"]:format(ns.ROLL_MACRO_NAME),
		get = function()
			return ns.db.global.rollMacro
		end,
		set = function(_, value)
			ns.db.global.rollMacro = value
			ns.ApplyRollMacro()
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildRollMacroOptions()
	local rollMacro = ns.RollMacroSwitch()
	rollMacro.width = "full"
	rollMacro.order = 3

	local args = {
		description = ns.OptionsDesc(L["ROLL_MACRO_DESCRIPTION"]:format(ns.ROLL_MACRO_NAME), 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
		rollMacro = rollMacro,
		spacerAfterSwitch = ns.OptionsSpacer(4),
		spacerAfterClicks = ns.OptionsSpacer(8),
		raidRollNote = ns.OptionsDesc(GetColor("HELP") .. L["ROLL_MACRO_RAID_ROLL_NOTE"] .. "|r", 9),
	}
	AddClickRows(5, args)

	return {
		type = "group",
		name = L["TAB_ROLL_MACRO"],
		args = args,
	}
end
