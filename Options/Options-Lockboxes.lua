--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Lockboxes
--------------------------------------------------------------------------------

--[[
    The tooltips work whether or not anything opens, so nothing here hides
    behind Automated Opening's switch. Both rows carry a scope, since a
    non-Rogue can't pick a lock and has little use for either.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

-- The lowest ID this flavor's data sets to open once unlocked.
local exampleLockedContainer = nil

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

-- Lockbox Tooltips is left out of the MoP Classic TOC (no Lockpicking skill line), and its rows leave with it.
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
			-- Hidden whenever the notice couldn't print: opening off, or a scope this character is outside.
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
