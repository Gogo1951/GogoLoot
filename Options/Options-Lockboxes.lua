--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Lockboxes
--------------------------------------------------------------------------------

--[[
    A child panel of Automated Opening: what a lockbox needs, and when the
    player is told one is waiting. It sits under Automated Opening because a
    picked lockbox is one more thing that opens, but it isn't part of opening:
    the tooltips work whether or not anything opens on its own, so nothing here
    hides behind that switch, and no red line says it is off. Both features
    carry a scope on their toggle's line rather than only an on/off, since a
    non-Rogue can't pick a lock and has little use for either; the scope leaves
    the line while its toggle is off (ns.OptionsToggleRow). The scope rule both
    apply lives in Features/Utilities.lua.
]]
local _, ns = ...
local L = ns.L

local function ScopeControl(desc, getScope, setScope)
	return {
		type = "select",
		desc = desc,
		values = {
			ROGUES = L["LOCKBOXES_FOR_ROGUES"],
			ALL = L["LOCKBOXES_FOR_ALL_CHARACTERS"],
		},
		sorting = { "ROGUES", "ALL" },
		get = getScope,
		set = setScope,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLockboxOptions()
	return {
		type = "group",
		name = L["TAB_LOCKBOXES"],
		args = {
			description = ns.OptionsDesc(
				L["LOCKBOXES_SECTION_DESCRIPTION"]:format(
					LOCALIZED_CLASS_NAMES_MALE.ROGUE or "",
					ns.GetLockpickingSkillName() or ""
				),
				1
			),
			spacerAfterDesc = ns.OptionsSpacer(2),
			tooltipsRow = ns.OptionsToggleRow(3, {
				type = "toggle",
				name = L["LOCKBOXES_TOOLTIPS_ENABLE"],
				desc = L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"]:format(ns.GetLockpickingSkillName() or ""),
				get = function()
					return ns.db.profile.lockboxTooltips
				end,
				set = function(_, value)
					ns.db.profile.lockboxTooltips = value
				end,
			}, {
				control = ScopeControl(L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"], function()
					return ns.db.profile.lockboxTooltipsScope
				end, function(_, value)
					ns.db.profile.lockboxTooltipsScope = value
				end),
			}),
			spacerBeforeNotifications = ns.OptionsSpacer(4),
			notificationsRow = ns.OptionsToggleRow(5, {
				type = "toggle",
				name = L["LOCKBOXES_NOTIFICATIONS_ENABLE"],
				desc = L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"],
				get = function()
					return ns.db.profile.lockboxNotifications
				end,
				set = function(_, value)
					ns.db.profile.lockboxNotifications = value
				end,
			}, {
				control = ScopeControl(L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"], function()
					return ns.db.profile.lockboxNotificationsScope
				end, function(_, value)
					ns.db.profile.lockboxNotificationsScope = value
				end),
			}),
		},
	}
end
