--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening
--------------------------------------------------------------------------------

--[[
    The switch, then its two hold-offs as on/off choices indented under it,
    leaving the panel while it is off (see Toggle Rows in Options-Utilities.lua).
    Each keeps the saved string Features/Automated-Opening.lua reads:
    autoOpenWhere is "ALWAYS" or "OUTSIDE_INSTANCES", autoOpenGroup "ALWAYS" or
    "SOLO_ONLY".

    Enable Ignore Notifications follows as a peer of the switch, neither
    indented under it nor leaving with it, the way the pop-up switch sits on the
    Master Looter panel: an item set to Ignore is also one Speedy Loot leaves in
    the loot window, and that notice matters with opening off. It lives here
    rather than on the Openables List, whose first checkbox would otherwise read
    as the list's own switch. An example of the notice sits under it and stays
    on show with it, the way the announcements' examples do.

    Lockboxes follows as a section under its own header: what a lockbox needs,
    and when the player is told one is waiting. It stays on show with the
    switch off, because the tooltips work whether or not anything opens on its
    own. Both lockbox features carry a scope on their toggle's line rather than
    only an on/off, since a non-Rogue can't pick a lock and has little use for
    either; the scope leaves the line while its toggle is off
    (ns.OptionsToggleRow). The scope rule both apply lives in
    Features/Utilities.lua.
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

--[[
    What Enable Ignore Notifications prints, drawn by ns.OptionsExampleRow
    (Message Examples in Options-Utilities.lua): the plain notice, the one a
    container the player sets to Ignore gets, run through its real template and
    laid out as printed. The stand-in is green so it stands out from the silver
    line the way a link does in chat.
]]
local EXAMPLE_CONTAINER_QUALITY = 2

local function IgnoreNotificationExample()
	return ns.OptionsPrintedExample(L["MESSAGE_ITEM_IGNORED"]:format(ns.OptionsExampleItem(EXAMPLE_CONTAINER_QUALITY)))
end

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
			spacerBeforeIgnoreNotifications = ns.OptionsSpacer(6),
			ignoreNotifications = {
				type = "toggle",
				name = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"],
				desc = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"],
				width = "full",
				order = 7,
				get = function()
					return ns.db.profile.openingIgnoreNotifications
				end,
				set = function(_, value)
					ns.db.profile.openingIgnoreNotifications = value
				end,
			},
			ignoreNotificationsExampleRow = ns.OptionsExampleRow(8, IgnoreNotificationExample),

			-- Lockboxes
			spacerBeforeLockboxes = ns.OptionsSpacer(10),
			lockboxesHeader = ns.OptionsHeader(L["TAB_LOCKBOXES"], 11),
			spacerAfterLockboxesHeader = ns.OptionsSpacer(12),
			lockboxesDesc = ns.OptionsDesc(
				L["LOCKBOXES_SECTION_DESCRIPTION"]:format(
					LOCALIZED_CLASS_NAMES_MALE.ROGUE or "",
					ns.GetLockpickingSkillName() or ""
				),
				13
			),
			spacerAfterLockboxesDesc = ns.OptionsSpacer(14),
			tooltipsRow = ns.OptionsToggleRow(15, {
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
			spacerBeforeNotifications = ns.OptionsSpacer(16),
			notificationsRow = ns.OptionsToggleRow(17, {
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
