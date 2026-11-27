--------------------------------------------------------------------------------
-- GogoLoot Opening Notices
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L

local function IsAutomatedOpeningOn()
	return ns.db ~= nil and ns.db.profile.autoOpen and true or false
end

local function LockboxNotificationsEnabled()
	return ns.db.profile.lockboxNotifications and ns.LockboxScopeAllows(ns.db.profile.lockboxNotificationsScope)
end

-- Anything else, player-set Ignore included, gets the plain notice.
local IGNORED_NOTICES = {
	[ns.OPENING_IGNORE_RAID] = "MESSAGE_ITEM_IGNORED_RAID",
	[ns.OPENING_IGNORE_UNIQUE] = "MESSAGE_ITEM_IGNORED_UNIQUE",
}

-- Both notices speak for Automated Opening, so both need it on as well as their own toggle.
local function AnnounceLootedContainer(itemIdentifier, itemLink)
	local action = ns:GetOpeningAction(itemIdentifier)
	local default = ns:GetOpeningDefault(itemIdentifier)
	if action == ns.OPENING_OPEN then
		if default == ns.OPENING_UNLOCKED and IsAutomatedOpeningOn() and LockboxNotificationsEnabled() then
			ns:PrintMessage(L["MESSAGE_ITEM_WILL_AUTO_OPEN"]:format(itemLink))
		end
	elseif action == ns.OPENING_IGNORE and IsAutomatedOpeningOn() and ns.db.profile.openingIgnoreNotifications then
		ns:AnnounceItemOnce(IGNORED_NOTICES[default] or "MESSAGE_ITEM_IGNORED", itemIdentifier, itemLink)
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnChatMsgLoot(message)
	local itemLink = ns.ParseOwnLootMessage(message)
	if itemLink then
		AnnounceLootedContainer(tonumber(string.match(itemLink, "item:(%d+)")), itemLink)
	end
end

ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMsgLoot)
