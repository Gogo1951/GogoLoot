--------------------------------------------------------------------------------
-- GogoLoot Options — Item Cache
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    GET_ITEM_INFO_RECEIVED is registered only while a watched item is cold, and
    unregisters once every one has loaded or proved missing from this client.
]]
local ITEM_CACHE_REFRESH_TIMER = "GogoLoot.ItemCacheRefresh"
local itemRefreshWatcherRegistered = false
local OnGetItemInfoReceived

--[[
    IDs the server answered with success = false. WoW Forever reports some
    later-expansion items as existing yet never serves them. Session-only, so
    a patch that adds one loads it next session.
]]
local unavailableItems = {}

---@param itemIdentifier number
---@return boolean
local function IsItemOnClient(itemIdentifier)
	return C_Item.DoesItemExistByID(itemIdentifier) and not unavailableItems[itemIdentifier]
end
ns.IsItemOnClient = IsItemOnClient

-- Asking requests the item. An ID not on the client can never load, so it never holds the watcher open.
---@param itemIdentifier number
---@return boolean
local function IsItemOutstanding(itemIdentifier)
	return IsItemOnClient(itemIdentifier) and not C_Item.GetItemInfo(itemIdentifier)
end
ns.IsItemOutstanding = IsItemOutstanding

--[[
    Registry name -> function returning the list's source table.
    watchedItemLists warms at login and lasts the session. panelItemLists holds
    list panels only while Options is open, so the Openables List's hundreds of
    IDs are requested only when someone looks.
]]
local watchedItemLists = {}
local panelItemLists = {}

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

-- success == false marks an item the server will never send; Kit.WarmItems can't see it, hence this watcher.
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

---@param registryName string
---@param getSource function # returns the list's source table
---@return nil
function ns.WatchItemList(registryName, getSource)
	panelItemLists[registryName] = getSource
end

---@return nil
function ns.ForgetPanelItemLists()
	wipe(panelItemLists)
end

-- The items the Example lines link, watched so a link still loading fills in on its own.
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

-- Icon and link as one caption, for Add from Bags. An item not on this client reads blank.
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
