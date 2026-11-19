--------------------------------------------------------------------------------
-- GogoLoot Opening Notices
--------------------------------------------------------------------------------

--[[
    What the player is told about a container they just looted, on behalf of
    Automated Opening (Features/Automated-Opening.lua): a lockbox that will open
    itself once picked, or an item it will leave alone.
]]
local _, ns = ...
local L = ns.L

local function IsAutomatedOpeningOn()
	return ns.db ~= nil and ns.db.profile.autoOpen and true or false
end

local function LockboxNotificationsEnabled()
	return ns.db.profile.lockboxNotifications and ns.LockboxScopeAllows(ns.db.profile.lockboxNotificationsScope)
end

--[[
    The notice for an ignored container, by the reason its default gives: a raid
    boss drop and one that may hold a unique item say so, and anything else,
    whether ignored by default or by the player, gets the plain notice.
]]
local IGNORED_NOTICES = {
	[ns.OPENING_IGNORE_RAID] = "MESSAGE_ITEM_IGNORED_RAID",
	[ns.OPENING_IGNORE_UNIQUE] = "MESSAGE_ITEM_IGNORED_UNIQUE",
}

--[[
    What the player is told about a container they just looted: a lockbox set to
    Open that will open itself once its lock is picked, or an item set to Ignore
    that Automated Opening will leave alone. Both speak for Automated Opening,
    so both need it on, as well as their own toggles: the Lockboxes panel's,
    and the Ignore notice's on the Automated Opening panel.
]]
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
