--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening
--------------------------------------------------------------------------------

--[[
    The switch, then its two hold-offs as on/off choices indented under it
    (see Toggle Rows in Options-Utilities.lua). Each keeps the saved string
    Features/Automated-Opening.lua reads: autoOpenWhere is "ALWAYS" or
    "OUTSIDE_INSTANCES", autoOpenGroup "ALWAYS" or "SOLO_ONLY".

    Everything below the switch leaves the panel while it is off. Enable Ignore
    Notifications lives on the Openables List (Options-Openable-Items.lua),
    since Speedy Loot gives that notice with opening off too (maintainer,
    2026-11-03). Lockboxes, whose tooltips work with nothing opening, is a child
    panel of its own (Options-Lockboxes.lua).
]]
local _, ns = ...
local L = ns.L

local function AutomatedOpeningOff()
	return not ns.db.profile.autoOpen
end

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Automated Opening, drawn on this panel and again in the Features
    section of the General panel. Built once here so the two can never drift;
    each caller sets its own order and width.
]]
---@return table
function ns.AutomatedOpeningSwitch()
	return {
		type = "toggle",
		name = L["AUTOMATED_OPENING_ENABLE"],
		desc = L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"]:format(AUTO_LOOT_DEFAULT_TEXT),
		get = function()
			return ns.db.profile.autoOpen
		end,
		set = function(_, value)
			ns.db.profile.autoOpen = value
			if value then
				ns.EnsureAutoLoot()
			end
			ns.ScheduleOpeningScan(true)
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildAutomatedOpeningOptions()
	local autoOpen = ns.AutomatedOpeningSwitch()
	autoOpen.width = "full"
	autoOpen.order = 3
	return {
		type = "group",
		name = L["TAB_AUTOMATED_OPENING"],
		args = {
			description = ns.OptionsDesc(L["AUTOMATED_OPENING_DESCRIPTION"]:format(ns.MIN_FREE_SLOTS), 1),
			spacerAfterDesc = ns.OptionsSpacer(2),
			autoOpen = autoOpen,
			outsideInstancesRow = ns.OptionsSubToggleRow(4, AutomatedOpeningOff, {
				type = "toggle",
				name = L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"],
				desc = L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"],
				get = function()
					return ns.db.profile.autoOpenWhere == "OUTSIDE_INSTANCES"
				end,
				set = function(_, value)
					ns.db.profile.autoOpenWhere = value and "OUTSIDE_INSTANCES" or "ALWAYS"
					ns.ScheduleOpeningScan(true)
				end,
			}),
			soloOnlyRow = ns.OptionsSubToggleRow(5, AutomatedOpeningOff, {
				type = "toggle",
				name = L["AUTOMATED_OPENING_ONLY_SOLO"],
				desc = L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"],
				get = function()
					return ns.db.profile.autoOpenGroup == "SOLO_ONLY"
				end,
				set = function(_, value)
					ns.db.profile.autoOpenGroup = value and "SOLO_ONLY" or "ALWAYS"
					ns.ScheduleOpeningScan(true)
				end,
			}),
		},
	}
end
