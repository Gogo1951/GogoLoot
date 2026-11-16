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
    beside the Ignore settings it reports on. Lockboxes, whose tooltips work with nothing opening, is a child
    panel of its own (Options-Lockboxes.lua).
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local function AutomatedOpeningOff()
	return not ns.db.profile.autoOpen
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildAutomatedOpeningOptions()
	return {
		type = "group",
		name = L["TAB_AUTOMATED_OPENING"],
		args = {
			description = Kit.Desc(L["AUTOMATED_OPENING_DESCRIPTION"]:format(ns.MIN_FREE_SLOTS), 1),
			spacerAfterDesc = Kit.Spacer(2),
			autoOpen = ns.FeatureSwitch("autoOpen", 3),
			outsideInstancesRow = Kit.SubToggleRow(4, AutomatedOpeningOff, {
				type = "toggle",
				name = L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"],
				desc = L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"],
				get = function()
					return ns.db.profile.autoOpenWhere == "OUTSIDE_INSTANCES"
				end,
				set = function(_, value)
					ns.db.profile.autoOpenWhere = value and "OUTSIDE_INSTANCES" or "ALWAYS"
					ns.ScheduleOpeningScan(true)
					ns.RefreshSettings()
				end,
			}),
			soloOnlyRow = Kit.SubToggleRow(5, AutomatedOpeningOff, {
				type = "toggle",
				name = L["AUTOMATED_OPENING_ONLY_SOLO"],
				desc = L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"],
				get = function()
					return ns.db.profile.autoOpenGroup == "SOLO_ONLY"
				end,
				set = function(_, value)
					ns.db.profile.autoOpenGroup = value and "SOLO_ONLY" or "ALWAYS"
					ns.ScheduleOpeningScan(true)
					ns.RefreshSettings()
				end,
			}),
		},
	}
end
