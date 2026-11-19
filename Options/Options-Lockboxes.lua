--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Lockboxes
--------------------------------------------------------------------------------

--[[
    A child panel of Automated Opening: what a lockbox needs, and when the
    player is told one is waiting. It sits under Automated Opening because a
    picked lockbox is one more thing that opens, but it isn't part of opening:
    the tooltips work whether or not anything opens on its own, so nothing here
    hides behind that switch. The notices speak for Automated Opening, so a
    silver status line under the page's description says so while it is off,
    naming the feature and the page its switch is on. Both features
    carry a scope on their toggle's line rather than only an on/off, since a
    non-Rogue can't pick a lock and has little use for either; the scope leaves
    the line while its toggle is off (Kit.ToggleRow). The scope rule both
    apply lives in Features/Utilities.lua.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--[[
    The example the Enable Lockbox Notifications row names: the lowest item ID
    this flavor's data sets to open once it is unlocked.
]]
local exampleLockedContainer = nil

-- Also warmed at login with the other example items (ns:WarmItemCache).
---@return number|nil
function ns.ExampleLockedContainer()
	if not exampleLockedContainer then
		for itemIdentifier, default in pairs(ns.OPENABLE_ITEMS) do
			if
				default == ns.OPENING_UNLOCKED
				and (not exampleLockedContainer or itemIdentifier < exampleLockedContainer)
			then
				exampleLockedContainer = itemIdentifier
			end
		end
	end
	return exampleLockedContainer
end

-- What Enable Lockbox Notifications prints, drawn as printed by Kit.Example while it could print.
local function LockboxNotificationExample()
	local item = ns.OptionsExampleLink(ns.ExampleLockedContainer() or ns.SAMPLE_ITEM_IDS[2])
	return ns.OptionsPrintedLine(L["MESSAGE_ITEM_WILL_AUTO_OPEN"]:format(item))
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

--[[
    Lockbox Tooltips is left out of the TOC where the client has no Lockpicking
    skill line (MoP Classic), and its rows leave with it.
]]
---@return table
function ns.BuildLockboxOptions()
	local hasTooltips = ns.GetLockpickingSkillName ~= nil
	local skillName = hasTooltips and ns.GetLockpickingSkillName() or ""
	local options = {
		type = "group",
		name = L["TAB_LOCKBOXES"],
		args = {
			description = Kit.Desc(
				L["LOCKBOXES_SECTION_DESCRIPTION"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE or "", skillName),
				1
			),
			spacerAfterDesc = Kit.Spacer(2),
			notificationsOffNote = Kit.StatusLine(function()
				if ns.db.profile.autoOpen then
					return nil
				end
				local name = L["TAB_AUTOMATED_OPENING"]
				return L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"]:format(Kit.Color("TITLE", name), name)
			end, 3),
			spacerAfterNotificationsOffNote = Kit.Spacer(4, function()
				return ns.db.profile.autoOpen
			end),
			tooltipsRow = Kit.ToggleRow(5, {
				type = "toggle",
				name = L["LOCKBOXES_TOOLTIPS_ENABLE"],
				desc = L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"]:format(skillName),
				get = Kit.Get("profile", "lockboxTooltips"),
				set = Kit.Set("profile", "lockboxTooltips"),
			}, {
				control = ScopeControl(
					L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"],
					Kit.Get("profile", "lockboxTooltipsScope"),
					Kit.Set("profile", "lockboxTooltipsScope")
				),
			}),
			spacerBeforeNotifications = Kit.Spacer(6),
			notificationsRow = Kit.ToggleRow(7, {
				type = "toggle",
				name = L["LOCKBOXES_NOTIFICATIONS_ENABLE"],
				desc = L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"],
				get = Kit.Get("profile", "lockboxNotifications"),
				set = Kit.Set("profile", "lockboxNotifications"),
			}, {
				control = ScopeControl(
					L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"],
					Kit.Get("profile", "lockboxNotificationsScope"),
					Kit.Set("profile", "lockboxNotificationsScope")
				),
			}),
			-- Leaves whenever the notice couldn't print: opening off, or a scope this character is outside.
			notificationsExampleRow = Kit.Example(8, function()
				local profile = ns.db.profile
				return not (
					profile.autoOpen
					and profile.lockboxNotifications
					and ns.LockboxScopeAllows(profile.lockboxNotificationsScope)
				)
			end, LockboxNotificationExample),
		},
	}
	if not hasTooltips then
		options.args.tooltipsRow = nil
		options.args.spacerBeforeNotifications = nil
	end
	return options
end
