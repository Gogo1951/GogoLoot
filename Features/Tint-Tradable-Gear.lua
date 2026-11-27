--------------------------------------------------------------------------------
-- GogoLoot Tradable Gear Tint
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

local GetContainerItemInfo = C_Container.GetContainerItemInfo
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local min = math.min

--[[
    Purely visual, and answers to its own switch, not Automated Master Looting.
    The verdict is the item's trade clock line, read only for Bind on Pickup
    items at or above ns.TRADABLE_MIN_QUALITY: a handful of buttons, never the
    whole bag. Each bag window gets an adapter (TINT_ADAPTERS); Magic Eraser's
    Junk Item Tint keeps the long notes on each bag add-on's hooks.
]]
local paintedButtons = setmetatable({}, { __mode = "k" })

-- [bag:slot:link] = the server time its trade clock runs out, or false for not tradable.
local verdicts = {}

---@return number
local function Now()
	return GetServerTime and GetServerTime() or time()
end

local function IsTintOn()
	return ns.db and ns.db.profile.tradableTintEnabled
end

local function IsCarriedBag(bag)
	return type(bag) == "number" and bag >= 0 and bag <= NUM_BAG_SLOTS
end

---@param bag number
---@param slot number
---@param link string
---@return boolean
local function IsTradableGear(bag, slot, link)
	local key = bag .. ":" .. slot .. ":" .. link
	local expiresAt = verdicts[key]
	if expiresAt == nil then
		local info = ns:SafeGetItemInfo(link)
		if not info then
			return false -- not loaded yet; asked again on the next paint
		end
		expiresAt = false
		if (info.quality or 0) >= ns.TRADABLE_MIN_QUALITY and info.bindType == ns.BIND_ON_PICKUP then
			local seconds = ns.GetBagSlotTradeSeconds(bag, slot)
			expiresAt = seconds and (Now() + seconds) or false
		end
		verdicts[key] = expiresAt
	end
	return expiresAt and expiresAt > Now() or false
end

local function FindIcon(button)
	local name = button:GetName()
	return button.icon or button.Icon or button.IconTexture or (name and _G[name .. "IconTexture"])
end

-- One sublevel above the icon, in its layer: covers the picture, stays under the count and quality border.
local function CreateTint(button)
	local icon = FindIcon(button)
	local layer, subLevel = "BORDER", 0
	if icon and icon.GetDrawLayer then
		layer, subLevel = icon:GetDrawLayer()
	end
	local tint = button:CreateTexture(nil, layer, nil, min((subLevel or 0) + 1, 7))
	tint:SetAllPoints(icon or button)
	tint:Hide()
	return tint
end

-- A window whose shownItemId isn't the live slot's item gets no tint. A nil bag clears the button.
local function PaintButton(button, bag, slot, shownItemId)
	if not button then
		return
	end
	local record = paintedButtons[button]
	if not record then
		record = {}
		paintedButtons[button] = record
	end

	--[[
	    What the window asked for is kept as asked, so a repaint asks the same:
	    the default bags name no item, and a window that does still has to match.
	]]
	record.bag, record.slot, record.shownItemId = bag, slot, shownItemId

	-- Switched off, nothing is read: the switch turning on repaints (ns:RefreshTradableTints).
	if not IsTintOn() then
		if record.tint then
			record.tint:Hide()
		end
		return
	end

	local itemId, link, canQualify
	if bag and slot and IsCarriedBag(bag) then
		local info = GetContainerItemInfo(bag, slot)
		itemId, link = info and info.itemID, info and info.hyperlink
		if shownItemId and shownItemId ~= itemId then
			itemId = nil
		end
		-- The slot already rules out an unbound item or one below the quality floor, so the item cache isn't asked.
		canQualify = info and info.isBound ~= false and not (info.quality and info.quality < ns.TRADABLE_MIN_QUALITY)
	end

	if itemId and link and canQualify and IsTradableGear(bag, slot, link) then
		if not record.tint then
			record.tint = CreateTint(button)
		end
		local color = ns.db.profile.tradableTintColor
		record.tint:SetColorTexture(color.r, color.g, color.b, color.a)
		record.tint:Show()
	elseif record.tint then
		record.tint:Hide()
	end
end

local function ClearButton(button)
	PaintButton(button, nil, nil)
end

local function ItemIdFromLink(link)
	return link and C_Item.GetItemInfoInstant(link) or nil
end

--------------------------------------------------------------------------------
-- Default Bags
--------------------------------------------------------------------------------

--[[
    Classic Era and TBC redraw through the global ContainerFrame_Update; WoW
    Forever through each frame's own UpdateItems, the combined backpack included.
]]
local function PaintClassicContainer(frame)
	local bag, name = frame:GetID(), frame:GetName()
	for index = 1, frame.size or 0 do
		local button = _G[name .. "Item" .. index]
		if button then
			PaintButton(button, bag, button:GetID())
		end
	end
end

local function PaintModernContainer(frame)
	for _, button in frame:EnumerateValidItems() do
		PaintButton(button, button:GetBagID(), button:GetID())
	end
end

local function InstallDefaultBags()
	local isHooked = false

	if type(ContainerFrame_Update) == "function" then
		hooksecurefunc("ContainerFrame_Update", PaintClassicContainer)
		isHooked = true
	end

	local frames = { ContainerFrameCombinedBags }
	for index = 1, tonumber(NUM_CONTAINER_FRAMES) or 0 do
		frames[#frames + 1] = _G["ContainerFrame" .. index]
	end
	for _, frame in pairs(frames) do
		if
			type(frame) == "table"
			and type(frame.UpdateItems) == "function"
			and type(frame.EnumerateValidItems) == "function"
		then
			hooksecurefunc(frame, "UpdateItems", PaintModernContainer)
			isHooked = true
		end
	end

	return isHooked
end

--------------------------------------------------------------------------------
-- Baganator
--------------------------------------------------------------------------------

--[[
    Baganator's corner-widget route: an invisible marker that never claims its
    corner (onUpdate returns false), with the tint on the button. Baganator
    hides every widget before it redraws a button, so the marker's OnHide
    clears the tint and the onUpdate that follows puts it back.
]]
local BAGANATOR_WIDGET_ID = "gogoloot_tint_tradable_gear"

local baganatorButtons = setmetatable({}, { __mode = "k" })

local function OnBaganatorMarkerHide(marker)
	if not marker:IsShown() then
		ClearButton(baganatorButtons[marker])
	end
end

local function InitBaganatorMarker(itemButton)
	local marker = CreateFrame("Frame", nil, itemButton)
	marker:SetSize(1, 1)
	marker:SetScript("OnHide", OnBaganatorMarkerHide)
	baganatorButtons[marker] = itemButton
	return marker
end

local function UpdateBaganatorMarker(marker, details)
	local location = details and details.itemLocation
	if location then
		PaintButton(baganatorButtons[marker], location.bagID, location.slotIndex, details.itemID)
		marker:Show()
	end
	return false
end

local function InstallBaganator()
	local api = Baganator and Baganator.API
	if
		not (api and type(api.RegisterCornerWidget) == "function" and type(api.RequestItemButtonsRefresh) == "function")
	then
		return false
	end
	api.RegisterCornerWidget(
		L["TRADABLE_TINT_BAGANATOR_WIDGET_LABEL"],
		BAGANATOR_WIDGET_ID,
		UpdateBaganatorMarker,
		InitBaganatorMarker,
		{ corner = "top_left", priority = 1 },
		true
	)
	return true
end

local function RefreshBaganator()
	local reasons = Baganator.Constants and Baganator.Constants.RefreshReason
	Baganator.API.RequestItemButtonsRefresh(reasons and { reasons.ItemWidgets } or nil)
end

--------------------------------------------------------------------------------
-- Bagnon
--------------------------------------------------------------------------------

-- Bagnon and Bagnonium each carry their own BagBrother core under a global named after the add-on.
local BAGNON_OTHER_WINDOWS = { guild = true, vault = true }

local function PaintBagnonItem(button)
	local window = button.frame
	if (window and BAGNON_OTHER_WINDOWS[window.id]) or (button.IsCached and button:IsCached()) then
		ClearButton(button)
		return
	end
	local info = button.info
	PaintButton(button, button:GetBag(), button:GetID(), info and info.itemID)
end

local function InstallBagnon(folder)
	local addon = _G[folder]
	local item = type(addon) == "table" and addon.Item
	if not (item and type(item.Update) == "function") then
		return false
	end
	hooksecurefunc(item, "Update", PaintBagnonItem)
	return true
end

--------------------------------------------------------------------------------
-- AdiBags and BetterBags
--------------------------------------------------------------------------------

local function GetAceAddon(name)
	local found, aceAddon = pcall(LibStub, "AceAddon-3.0", true)
	if not found then
		return nil
	end
	return aceAddon and aceAddon:GetAddon(name, true)
end

local function PaintAdiBagsButton(button)
	PaintButton(button, button.bag, button.slot, button.itemId)
end

local function InstallAdiBags()
	local addon = GetAceAddon("AdiBags")
	local class = addon and addon.GetClass and addon:GetClass("ItemButton")
	local prototype = class and class.prototype
	if not (prototype and type(prototype.Update) == "function") then
		return false
	end
	hooksecurefunc(prototype, "Update", PaintAdiBagsButton)
	return true
end

-- BetterBags draws each item on a decoration button under the one that takes the clicks; the tint goes on the decoration.
local function PaintBetterBagsItem(_, item, decoration)
	local data = item and item.currentData
	if not (decoration and data) or data.isItemEmpty then
		if decoration then
			ClearButton(decoration)
		end
		return
	end
	local itemInfo = data.itemInfo
	PaintButton(decoration, data.bagid, data.slotid, itemInfo and itemInfo.itemID)
end

local function ClearBetterBagsItem(_, _, decoration)
	if decoration then
		ClearButton(decoration)
	end
end

local function InstallBetterBags()
	local addon = GetAceAddon("BetterBags")
	local events = addon and addon.GetModule and addon:GetModule("Events", true)
	if not (events and type(events.RegisterMessage) == "function") then
		return false
	end
	events:RegisterMessage("item/Updated", PaintBetterBagsItem)
	events:RegisterMessage("item/Clearing", ClearBetterBagsItem)
	return true
end

--------------------------------------------------------------------------------
-- ArkInventory
--------------------------------------------------------------------------------

local function PaintArkInventoryItem(frame, locationId)
	local api = ArkInventory.API
	local data = frame.ARK_Data
	if not data or api.LocationIsOffline(locationId) then
		ClearButton(frame)
		return
	end
	local item = api.ItemFrameItemTableGet(frame)
	PaintButton(frame, data.blizzard_id, data.slot_id, ItemIdFromLink(item and item.h))
end

local function InstallArkInventory()
	local api = ArkInventory and ArkInventory.API
	if
		not (
			api
			and type(api.ItemFrameUpdated) == "function"
			and type(api.LocationIsOffline) == "function"
			and type(api.ItemFrameItemTableGet) == "function"
		)
	then
		return false
	end
	hooksecurefunc(api, "ItemFrameUpdated", PaintArkInventoryItem)
	return true
end

--------------------------------------------------------------------------------
-- ElvUI
--------------------------------------------------------------------------------

local function PaintElvUISlot(_, frame, bag, slot)
	local bagSlots = frame and frame.Bags and frame.Bags[bag]
	local button = bagSlots and bagSlots[slot]
	if button then
		PaintButton(button, bag, slot, button.itemID)
	end
end

local function InstallElvUI()
	local engine = ElvUI and ElvUI[1]
	local bags = engine and engine.Bags
	if not (bags and bags.Initialized and type(bags.UpdateSlot) == "function") then
		return false
	end
	hooksecurefunc(bags, "UpdateSlot", PaintElvUISlot)
	return true
end

--------------------------------------------------------------------------------
-- Setup and Refresh
--------------------------------------------------------------------------------

--[[
    { name, add-on folder (nil for the default bags), install, redraw }. One
    that didn't hook is tried again on every later ADDON_LOADED, which catches
    a bag add-on loaded on demand; one that sets itself up during its own
    PLAYER_LOGIN is caught by the one-frame delay after ours.
]]
local TINT_ADAPTERS = {
	{ "Default Bags", nil, InstallDefaultBags },
	{ "Baganator", "Baganator", InstallBaganator, RefreshBaganator },
	{ "Bagnon", "Bagnon", InstallBagnon },
	{ "Bagnonium", "Bagnonium", InstallBagnon },
	{ "AdiBags", "AdiBags", InstallAdiBags },
	{ "BetterBags", "BetterBags", InstallBetterBags },
	{ "ArkInventory", "ArkInventory", InstallArkInventory },
	{ "ElvUI", "ElvUI", InstallElvUI },
}

local installedAdapters = {}

local function SetupTintHooks()
	for _, adapter in ipairs(TINT_ADAPTERS) do
		local name, folder, install = adapter[1], adapter[2], adapter[3]
		if not installedAdapters[name] and (not folder or IsAddOnLoaded(folder)) and install(folder) then
			installedAdapters[name] = adapter
		end
	end
end

function ns:GetTradableTintAdapterNames()
	local names = {}
	for _, adapter in ipairs(TINT_ADAPTERS) do
		if installedAdapters[adapter[1]] then
			names[#names + 1] = adapter[1]
		end
	end
	return names
end

-- Only windows whose buttons can show a new slot without drawing it again need asking.
local function RedrawTintWindows()
	if not IsTintOn() then
		return
	end
	for _, adapter in pairs(installedAdapters) do
		if adapter[4] then
			adapter[4]()
		end
	end
end

-- For a change that moves no item: a new color, the switch, a profile change, a clock running out.
function ns:RefreshTradableTints()
	for button, record in pairs(paintedButtons) do
		if record.bag then
			PaintButton(button, record.bag, record.slot, record.shownItemId)
		end
	end
	RedrawTintWindows()
end

local function AnyClockRanOut()
	local now = Now()
	for _, expiresAt in pairs(verdicts) do
		if expiresAt and expiresAt <= now then
			return true
		end
	end
	return false
end

-- A clock that ran out is settled as not tradable once its tint is gone, so the check repaints for it only once.
local function OnClockCheck()
	if not (IsTintOn() and AnyClockRanOut()) then
		return
	end
	ns:RefreshTradableTints()
	local now = Now()
	for key, expiresAt in pairs(verdicts) do
		if expiresAt and expiresAt <= now then
			verdicts[key] = false
		end
	end
end

local function OnBagsChanged()
	verdicts = {}
	ns:RefreshTradableTints()
end

local function OnAddonLoaded()
	SetupTintHooks()
end

local function OnPlayerLogin()
	SetupTintHooks()
	C_Timer.After(0, SetupTintHooks)
	C_Timer.NewTicker(ns.TRADABLE_TINT_CHECK_SECONDS, OnClockCheck)
end

ns:RegisterModuleEvent("ADDON_LOADED", OnAddonLoaded)
ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
ns:RegisterModuleEvent("BAG_UPDATE_DELAYED", OnBagsChanged)
