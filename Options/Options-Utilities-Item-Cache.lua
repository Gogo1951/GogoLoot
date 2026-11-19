--------------------------------------------------------------------------------
-- GogoLoot Options — Item Cache
--------------------------------------------------------------------------------

--[[
    The client item cache behind every item list: which IDs this client has,
    the GET_ITEM_INFO_RECEIVED watcher that repaints the lists as answers
    arrive, and how a row's item is drawn while it loads.
]]
local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    GetItemInfo returns nil for items the client hasn't cached; querying it
    triggers a server request and GET_ITEM_INFO_RECEIVED fires when the data
    arrives. A debounced NotifyChange repaints the item lists as answers
    stream in. The watcher is registered on demand — at login when a saved
    list contains uncached items, when a list panel is built with an uncached
    row, or when the user adds an uncached item ID — and unregisters itself once every list item has resolved or turned out
    not to exist on this client, so it does not keep running for the rest of
    the session.
]]

local ITEM_CACHE_REFRESH_TIMER = "GogoLoot.ItemCacheRefresh"
local itemRefreshWatcherRegistered = false
local OnGetItemInfoReceived

--[[
    IDs whose item query the server answered with success = false. WoW Forever
    reports some later-expansion items as existing (C_Item.DoesItemExistByID)
    yet never serves them, so the server's answer is what settles it.
    Session-only, never saved: a patch that adds the item loads it next session.
]]
local unavailableItems = {}

---@param itemIdentifier number
---@return boolean
local function IsItemOnClient(itemIdentifier)
	return C_Item.DoesItemExistByID(itemIdentifier) and not unavailableItems[itemIdentifier]
end
ns.IsItemOnClient = IsItemOnClient

--[[
    An item is outstanding while the client has it but hasn't cached it yet;
    asking requests it. An ID this client doesn't have can never load, so it is
    never outstanding and never holds the watcher open.
]]
---@param itemIdentifier number
---@return boolean
local function IsItemOutstanding(itemIdentifier)
	return IsItemOnClient(itemIdentifier) and not C_Item.GetItemInfo(itemIdentifier)
end
ns.IsItemOutstanding = IsItemOutstanding

--[[
    The item lists being watched, by the registry name of the panel that draws
    each, with a function returning the list's source table. The two saved
    lists, Item Overrides and the Master Looter Ignore List, join at login
    (ns:WarmItemCache) with the Example lines' items, so they warm before
    anyone opens a panel. Every list panel also joins panelItemLists while it
    is built, and leaves when the Options window closes, which keeps the
    Openables List, hundreds of rows, from being requested from the server
    unless the player is looking at it.
]]
local watchedItemLists = {}
local panelItemLists = {}

--[[
    Queries every watched entry (re-requesting uncached ones) and reports
    whether anything is still missing from the client cache.
]]
local function QueryListItemsAndFindMissing()
	local hasMissing = false
	for _, lists in ipairs({ watchedItemLists, panelItemLists }) do
		for _, getSource in pairs(lists) do
			for itemIdentifier in pairs(getSource() or {}) do
				if IsItemOutstanding(itemIdentifier) then
					hasMissing = true
				end
			end
		end
	end
	return hasMissing
end

local function RefreshOptionsAfterDelay()
	if ns:IsTimerPending(ITEM_CACHE_REFRESH_TIMER) then
		return
	end
	ns:After(ITEM_CACHE_REFRESH_TIMER, 0.3, function()
		ns.RefreshSettings()
		if itemRefreshWatcherRegistered and not QueryListItemsAndFindMissing() then
			itemRefreshWatcherRegistered = false
			ns:UnregisterModuleEvent("GET_ITEM_INFO_RECEIVED", OnGetItemInfoReceived)
		end
	end)
end

--[[
    The server's success == false answer marks an item it will never send, which
    is why GogoLoot keeps its own watcher rather than Kit.WarmItems.
]]
OnGetItemInfoReceived = function(itemIdentifier, success)
	if itemIdentifier and success == false then
		unavailableItems[itemIdentifier] = true
	end
	RefreshOptionsAfterDelay()
end

---@return nil
function ns.EnsureItemRefreshWatcher()
	if itemRefreshWatcherRegistered then
		return
	end
	itemRefreshWatcherRegistered = true
	ns:RegisterModuleEvent("GET_ITEM_INFO_RECEIVED", OnGetItemInfoReceived)
end

-- A list panel's rows are on screen, so their answers repaint it as they arrive.
---@param registryName string
---@param getSource function # returns the list's source table
---@return nil
function ns.WatchItemList(registryName, getSource)
	panelItemLists[registryName] = getSource
end

-- The Options window closed: no list panel is on screen, so none of their items is waited on any more.
---@return nil
function ns.ForgetPanelItemLists()
	wipe(panelItemLists)
end

--[[
    The items the Example lines link (Message Examples in Options-Utilities.lua),
    watched for the panels that draw them, so a link that was still loading
    fills in on its own.
]]
local exampleItems = {}

local function GetExampleItems()
	return exampleItems
end

---@return nil
function ns:WarmItemCache()
	watchedItemLists[ns.OPTIONS_REGISTRY.ItemOverrides] = function()
		return ns.db.profile.ignoredItemsSolo
	end
	watchedItemLists[ns.OPTIONS_REGISTRY.MasterLooterIgnoreList] = function()
		return ns.db.profile.ignoredItemsMaster
	end
	for _, itemIdentifier in pairs(ns.SAMPLE_ITEM_IDS) do
		exampleItems[itemIdentifier] = true
	end
	for _, container in ipairs({ ns.ExampleIgnoredContainer() or false, ns.ExampleLockedContainer() or false }) do
		if container then
			exampleItems[container] = true
		end
	end
	watchedItemLists[ns.OPTIONS_REGISTRY.Announcements] = GetExampleItems
	watchedItemLists[ns.OPTIONS_REGISTRY.AutomatedRolls] = GetExampleItems
	watchedItemLists[ns.OPTIONS_REGISTRY.OpenableItems] = GetExampleItems
	watchedItemLists[ns.OPTIONS_REGISTRY.Lockboxes] = GetExampleItems
	if not QueryListItemsAndFindMissing() then
		return
	end

	C_Timer.After(1, RefreshOptionsAfterDelay)
	ns.EnsureItemRefreshWatcher()
end

--------------------------------------------------------------------------------
-- Item Display Helper
--------------------------------------------------------------------------------

--[[
    An item's icon and link as one caption, for Add from Bags' choices
    (Options-Utilities-Item-Lists.lua). An item this client doesn't have reads
    blank.
]]

---@param itemIdentifier number
---@return string
function ns:GetItemDisplayName(itemIdentifier)
	if not IsItemOnClient(itemIdentifier) then
		return ""
	end
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	local _, _, _, _, icon = C_Item.GetItemInfoInstant(itemIdentifier)

	if itemLink and icon then
		return "|T" .. icon .. ":16|t " .. itemLink
	elseif itemLink then
		return itemLink
	elseif icon then
		return "|T" .. icon .. ":16|t " .. GetColor("MUTED") .. string.format(L["LOADING_ITEM"], itemIdentifier) .. "|r"
	end

	return GetColor("MUTED") .. string.format(L["LOADING_ITEM"], itemIdentifier) .. "|r"
end
