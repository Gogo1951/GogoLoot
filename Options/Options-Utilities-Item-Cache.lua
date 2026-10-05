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
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    GetItemInfo returns nil for items the client hasn't cached; querying it
    triggers a server request and GET_ITEM_INFO_RECEIVED fires when the data
    arrives. A debounced NotifyChange repaints the item lists as answers
    stream in. The watcher is registered on demand — at login when a saved
    list contains uncached items, or when the user adds an uncached item ID
    — and unregisters itself once every list item has resolved or turned out
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
    (ns:WarmItemCache), so they warm before anyone opens a panel. Any other list joins the first time its panel is built, which
    keeps the Openables List, hundreds of rows, from being requested from
    the server until the player actually looks at it.
]]
local watchedItemLists = {}

--[[
    Queries every watched entry (re-requesting uncached ones) and reports
    whether anything is still missing from the client cache.
]]
local function QueryListItemsAndFindMissing()
	local hasMissing = false
	for _, getSource in pairs(watchedItemLists) do
		for itemIdentifier in pairs(getSource() or {}) do
			if IsItemOutstanding(itemIdentifier) then
				hasMissing = true
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
		for registryName in pairs(watchedItemLists) do
			AceConfigRegistry:NotifyChange(registryName)
		end
		if itemRefreshWatcherRegistered and not QueryListItemsAndFindMissing() then
			itemRefreshWatcherRegistered = false
			ns:UnregisterModuleEvent("GET_ITEM_INFO_RECEIVED", OnGetItemInfoReceived)
		end
	end)
end

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
	watchedItemLists[registryName] = getSource
end

---@return nil
function ns:WarmItemCache()
	watchedItemLists[ns.OPTIONS_REGISTRY.ItemOverrides] = function()
		return ns.db.profile.ignoredItemsSolo
	end
	watchedItemLists[ns.OPTIONS_REGISTRY.MasterLooterIgnoreList] = function()
		return ns.db.profile.ignoredItemsMaster
	end
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
    Used by the GogoLoot_ItemLink AceGUI widget
    (Options-Utilities-Item-List-Widgets.lua) to render the row label. The builder
    (Options-Utilities-Item-Lists.lua) never makes a row for an item
    this client doesn't have; one refused while its row is on screen reads blank
    until the repaint drops it, and is never asked for again.
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
		return "|T" .. icon .. ":16|t " .. GetColor("MUTED") .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
	end

	return GetColor("MUTED") .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
end
