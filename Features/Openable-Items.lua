--------------------------------------------------------------------------------
-- GogoLoot Openable Items
--------------------------------------------------------------------------------

--[[
    Open or Ignore per item: the data's default, which may carry a reason, plus
    the player's changes. Only changes are saved, so a new release's data and
    defaults reach everyone who hasn't set that item. The reason belongs to the
    item, not the setting, so its tag stays whatever the player picks.

    Ignore only keeps the item sealed: Speedy Loot still takes it, since loot
    left in the window can be lost for good, a fishing catch above all
    (maintainer, 2026-11-07).
]]
local _, ns = ...
local L = ns.L

-- Two choices, Open and Ignore (maintainer, 2026-09-28); why a row starts where it does is a tag, not a choice.
local VALID_ACTIONS = {
	[ns.OPENING_OPEN] = true,
	[ns.OPENING_IGNORE] = true,
}

local DEFAULT_ACTIONS = {
	[ns.OPENING_OPEN] = ns.OPENING_OPEN,
	[ns.OPENING_UNLOCKED] = ns.OPENING_OPEN,
	[ns.OPENING_IGNORE] = ns.OPENING_IGNORE,
	[ns.OPENING_IGNORE_RAID] = ns.OPENING_IGNORE,
	[ns.OPENING_IGNORE_UNIQUE] = ns.OPENING_IGNORE,
}

--[[
    Both sell-sealed reasons share a tag, since the advice is the same. Item
    names stay out of the notes: the client's localized tooltip sits right
    above, and naming the loot would ship English item names into every locale.
]]
local DEFAULT_TAGS = {
	[ns.OPENING_UNLOCKED] = LOCKED,
	[ns.OPENING_IGNORE_RAID] = L["OPENING_TAG_SEALED"],
	[ns.OPENING_IGNORE] = L["OPENING_TAG_SEALED"],
	[ns.OPENING_IGNORE_UNIQUE] = L["OPENING_TAG_UNIQUE"],
}

local DEFAULT_NOTES = {
	[ns.OPENING_UNLOCKED] = L["OPENING_REASON_LOCKED_CLASS"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE or ""),
	[ns.OPENING_IGNORE_RAID] = L["OPENING_REASON_RAID"],
	[ns.OPENING_IGNORE] = L["OPENING_REASON_BIND_ON_PICKUP"],
	[ns.OPENING_IGNORE_UNIQUE] = L["OPENING_REASON_UNIQUE"],
}

-- The raw default, reason and all (ns.OPENING_UNLOCKED, ns.OPENING_IGNORE_RAID, ...), not just Open or Ignore.
---@param itemIdentifier number|nil
---@return string|nil
function ns:GetOpeningDefault(itemIdentifier)
	local default = itemIdentifier and ns.OPENABLE_ITEMS[itemIdentifier]
	if DEFAULT_ACTIONS[default] then
		return default
	end
	return nil
end

---@param itemIdentifier number|nil
---@return string|nil
function ns:GetDefaultOpeningAction(itemIdentifier)
	return DEFAULT_ACTIONS[ns:GetOpeningDefault(itemIdentifier)]
end

-- Nil for an item off the list, never listed or removed: only a listed item is ever opened.
---@param itemIdentifier number|nil
---@return string|nil
function ns:GetOpeningAction(itemIdentifier)
	if not itemIdentifier then
		return nil
	end
	local chosenAction = ns.db.global.openingActions[itemIdentifier]
	if chosenAction == ns.OPENING_REMOVED then
		return nil
	end
	if VALID_ACTIONS[chosenAction] then
		return chosenAction
	end
	return ns:GetDefaultOpeningAction(itemIdentifier)
end

-- { [itemId] = true }: data rows the player hasn't removed, plus items the player added.
---@return table
function ns:GetOpenableItemList()
	local listed = {}
	for itemIdentifier in pairs(ns.OPENABLE_ITEMS) do
		if ns:GetOpeningAction(itemIdentifier) then
			listed[itemIdentifier] = true
		end
	end
	for itemIdentifier in pairs(ns.db.global.openingActions) do
		if ns:GetOpeningAction(itemIdentifier) then
			listed[itemIdentifier] = true
		end
	end
	return listed
end

local function AfterOpeningActionsChanged()
	if ns.ScheduleOpeningScan then
		ns.ScheduleOpeningScan(true)
	end
	ns.RefreshSettings()
end

---@param itemIdentifier number
---@param action string
---@return nil
function ns:SetOpeningAction(itemIdentifier, action)
	if not VALID_ACTIONS[action] or not ns:GetOpeningAction(itemIdentifier) then
		return
	end
	if action == ns:GetDefaultOpeningAction(itemIdentifier) then
		ns.db.global.openingActions[itemIdentifier] = nil
	else
		ns.db.global.openingActions[itemIdentifier] = action
	end
	AfterOpeningActionsChanged()
end

--[[
    Using gear or a bag equips it, binding a Bind on Equip item for good, so
    nothing with a slot joins. Retail-engine clients report an unequippable
    item's slot as INVTYPE_NON_EQUIP_IGNORE rather than "".
]]
---@param itemIdentifier number
---@return boolean
function ns:CanAddOpeningItem(itemIdentifier)
	if not C_Item.DoesItemExistByID(itemIdentifier) then
		return false
	end
	local _, _, _, equipLocation = C_Item.GetItemInfoInstant(itemIdentifier)
	return equipLocation == nil or equipLocation == "" or equipLocation == "INVTYPE_NON_EQUIP_IGNORE"
end

-- A removed listed item returns with its default; an unlisted one joins set to Open; a listed one is left as it is.
---@param itemIdentifier number
---@return boolean
function ns:AddOpeningItem(itemIdentifier)
	if not ns:CanAddOpeningItem(itemIdentifier) then
		return false
	end
	local savedActions = ns.db.global.openingActions
	if ns:GetDefaultOpeningAction(itemIdentifier) then
		if savedActions[itemIdentifier] == ns.OPENING_REMOVED then
			savedActions[itemIdentifier] = nil
		end
	elseif not VALID_ACTIONS[savedActions[itemIdentifier]] then
		savedActions[itemIdentifier] = ns.OPENING_OPEN
	end
	AfterOpeningActionsChanged()
	return true
end

---@param itemIdentifier number
---@return nil
function ns:RemoveOpeningItem(itemIdentifier)
	if ns:GetDefaultOpeningAction(itemIdentifier) then
		ns.db.global.openingActions[itemIdentifier] = ns.OPENING_REMOVED
	else
		ns.db.global.openingActions[itemIdentifier] = nil
	end
	AfterOpeningActionsChanged()
end

---@return nil
function ns:RestoreDefaultOpeningActions()
	wipe(ns.db.global.openingActions)
	AfterOpeningActionsChanged()
end

---@return boolean
function ns:AreOpeningActionsDefault()
	for itemIdentifier, action in pairs(ns.db.global.openingActions) do
		if action ~= ns:GetDefaultOpeningAction(itemIdentifier) then
			return false
		end
	end
	return true
end

---@param itemIdentifier number|nil
---@return string|nil
function ns:GetOpeningTag(itemIdentifier)
	return DEFAULT_TAGS[ns:GetOpeningDefault(itemIdentifier)]
end

---@param itemIdentifier number|nil
---@return string|nil
function ns:GetOpeningNote(itemIdentifier)
	return DEFAULT_NOTES[ns:GetOpeningDefault(itemIdentifier)]
end

--------------------------------------------------------------------------------
-- Bag Rows
--------------------------------------------------------------------------------

--[[
    Deliberately uncached: it runs once per menu render, and a cache would need
    clearing on every bag, trade and pick-lock event. The name comes from the
    item's own link, already localized, with no C_Item.GetItemInfo round trip.
]]
---@param matches function # (bagIndex, slotIndex, itemIdentifier) -> boolean
---@return table[]
local function CollectBagRows(matches)
	local rowsByIdentifier, rows = {}, {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			if itemIdentifier and matches(bagIndex, slotIndex, itemIdentifier) then
				local row = rowsByIdentifier[itemIdentifier]
				if row then
					row.count = row.count + 1
				else
					local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
					row = {
						itemIdentifier = itemIdentifier,
						count = 1,
						icon = ns.GetItemIconByID(itemIdentifier),
						name = itemLink and string.match(itemLink, "|h%[(.-)%]|h"),
						link = itemLink,
					}
					rowsByIdentifier[itemIdentifier] = row
					rows[#rows + 1] = row
				end
			end
		end
	end
	table.sort(rows, function(a, b)
		if (a.name ~= nil) ~= (b.name ~= nil) then
			return a.name ~= nil
		end
		if a.name and b.name and a.name ~= b.name then
			return a.name < b.name
		end
		return a.itemIdentifier < b.itemIdentifier
	end)
	return rows
end

---@return table[]
function ns.GetLockedBoxes()
	return CollectBagRows(function(bagIndex, slotIndex, itemIdentifier)
		return ns:GetOpeningAction(itemIdentifier) == ns.OPENING_OPEN and ns.IsItemLocked(bagIndex, slotIndex)
	end)
end

---@return table[]
function ns.GetSealedContainers()
	local rows = CollectBagRows(function(_, _, itemIdentifier)
		return ns:GetOpeningAction(itemIdentifier) == ns.OPENING_IGNORE
	end)
	for _, row in ipairs(rows) do
		row.tag = ns:GetOpeningTag(row.itemIdentifier)
		row.note = ns:GetOpeningNote(row.itemIdentifier)
	end
	return rows
end
