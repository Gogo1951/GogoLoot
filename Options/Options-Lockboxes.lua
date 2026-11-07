--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Lockboxes
--------------------------------------------------------------------------------

--[[
    A child panel of Automated Opening: what a lockbox needs, and when the
    player is told one is waiting. It sits under Automated Opening because a
    picked lockbox is one more thing that opens, but it isn't part of opening:
    the tooltips work whether or not anything opens on its own, so nothing here
    hides behind that switch. The notices speak for Automated Opening, so a red
    line under their row says so while it is off. Both features
    carry a scope on their toggle's line rather than only an on/off, since a
    non-Rogue can't pick a lock and has little use for either; the scope leaves
    the line while its toggle is off (ns.OptionsToggleRow). The scope rule both
    apply lives in Features/Utilities.lua.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

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

-- What Enable Lockbox Notifications prints, drawn as printed (Message Examples in Options-Utilities.lua).
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
			notificationsExampleRow = ns.OptionsExampleRow(6, LockboxNotificationExample),
			notificationsOffNote = {
				type = "description",
				name = GetColor("OFF") .. L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] .. "|r",
				fontSize = "medium",
				order = 7,
				hidden = function()
					return ns.db.profile.autoOpen or not ns.db.profile.lockboxNotifications
				end,
			},
		},
	}
end
