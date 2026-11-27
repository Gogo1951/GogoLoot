--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening
--------------------------------------------------------------------------------

--[[
    The two hold-offs are toggles over saved strings: autoOpenWhere "ALWAYS" or
    "OUTSIDE_INSTANCES", autoOpenGroup "ALWAYS" or "SOLO_ONLY".
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
			fishingPoleRow = Kit.SubToggleRow(6, AutomatedOpeningOff, {
				type = "toggle",
				name = L["AUTOMATED_OPENING_WITH_FISHING_POLE"],
				desc = L["AUTOMATED_OPENING_WITH_FISHING_POLE_DESCRIPTION"],
				get = function()
					return ns.db.profile.autoOpenWithFishingPole
				end,
				set = function(_, value)
					ns.db.profile.autoOpenWithFishingPole = value and true or false
					ns.ScheduleOpeningScan(true)
					ns.RefreshSettings()
				end,
			}),
		},
	}
end
