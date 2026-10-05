--------------------------------------------------------------------------------
-- GogoLoot Openable Items
--------------------------------------------------------------------------------

--[[
    What Automated Opening does with each item it knows how to open: Open, or
    Ignore, which leaves it alone. Every row of ns.OPENABLE_ITEMS carries its
    item's default (see Data/Data.lua, Automated Opening), and the player can set
    any item otherwise, add an item the data lacks, or remove one, on the
    Openables List.

    A default can also carry a reason: a lockbox waits for a Rogue, and a
    container ignored by default drops from a raid boss, may hold a unique item,
    or may hold Bind on Pickup loot. The reason belongs to the item, not to the
    setting, so it stays on the item's row as a tag whatever the player picks,
    and a looted container's notice gives it.

    Only the player's changes are saved, in ns.db.global.openingActions: an
    action for a listed item set away from its default, an action for an item
    the player added, and ns.OPENING_REMOVED for a listed item the player took
    off the list. A choice set back to its default is removed rather than
    stored, and Restore Defaults wipes the table. Keeping the defaults out of it
    is what lets a new release's data reach every player: an item added to the
    data, or given a new default, takes effect for everyone who hasn't set that
    item themselves.

    Ignore also keeps Speedy Loot from taking the item
    (Features/Speedy-Loot.lua): it stays in the loot window for the player to
    take by hand. A removed item is no container to GogoLoot at all: it is never
    opened and loots like any other item.
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local VALID_ACTIONS = {
	[ns.OPENING_OPEN] = true,
	[ns.OPENING_IGNORE] = true,
}

-- Each data default, as the action it takes.
local DEFAULT_ACTIONS = {
	[ns.OPENING_OPEN] = ns.OPENING_OPEN,
	[ns.OPENING_UNLOCKED] = ns.OPENING_OPEN,
	[ns.OPENING_IGNORE] = ns.OPENING_IGNORE,
	[ns.OPENING_IGNORE_RAID] = ns.OPENING_IGNORE,
	[ns.OPENING_IGNORE_UNIQUE] = ns.OPENING_IGNORE,
}

--[[
    Each reason's tag on the Openables List, and the line under the item's
    tooltip explaining it. Both sell-sealed reasons share a tag, since the
    advice is the same; the line says which one it is. The item names stay out
    of the lines on purpose: the client draws its own localized tooltip
    directly above, so naming the loot again would ship English item names into
    every locale.
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

--[[
    The data's default for an item, reason and all (ns.OPENING_UNLOCKED,
    ns.OPENING_IGNORE_RAID, and so on). Nil for anything this client's data
    doesn't list as openable.
]]
---@param itemIdentifier number|nil
---@return string|nil
function ns:GetOpeningDefault(itemIdentifier)
	local default = itemIdentifier and ns.OPENABLE_ITEMS[itemIdentifier]
	if DEFAULT_ACTIONS[default] then
		return default
	end
	return nil
end

--[[
    The action an item's default takes, Open or Ignore. Nil for anything this
    client's data doesn't list as openable.
]]
---@param itemIdentifier number|nil
---@return string|nil
function ns:GetDefaultOpeningAction(itemIdentifier)
	return DEFAULT_ACTIONS[ns:GetOpeningDefault(itemIdentifier)]
end

--[[
    The action Automated Opening takes for an item: the player's choice where
    there is one, otherwise the data's default. Nil for an item that isn't on
    the list, whether the data never had it or the player removed it: only a
    listed item is ever opened.
]]
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

---@param itemIdentifier number|nil
---@return boolean
function ns:IsOpeningIgnored(itemIdentifier)
	return ns:GetOpeningAction(itemIdentifier) == ns.OPENING_IGNORE
end

--[[
    Every item on the list, as { [itemId] = true }: the data's rows the player
    hasn't removed, and the items the player added.
]]
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
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.OpenableItems)
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
    Opening an item is using it, and using gear or a bag equips it, binding a
    Bind on Equip item for good, so nothing with a slot to go in joins the list.
    Retail-engine clients report an unequippable item's slot as
    INVTYPE_NON_EQUIP_IGNORE rather than an empty string. The Openables List's
    Add from Bags offers only what passes.
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

--[[
    A listed item the player removed comes back with its default. Any other item
    joins set to Open, the reason to add one; an item already on the list is
    left as it is. False when the item can't join the list at all.
]]
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

--[[
    Clears every change at once: each listed item's action goes back to its
    default, removed items return, and added items leave the list.
]]
---@return nil
function ns:RestoreDefaultOpeningActions()
	wipe(ns.db.global.openingActions)
	AfterOpeningActionsChanged()
end

--[[
    The reason an item's default carries, as its row's tag and as the line
    under its tooltip; nil for an item whose default gives none, and for one the
    player added.
]]
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
