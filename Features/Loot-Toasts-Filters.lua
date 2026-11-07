--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Filters
--------------------------------------------------------------------------------

-- Which loot gets a toast, by the Filters panel's Mine and Group boxes (ns.LOOT_TOAST_FILTER_ROWS).
local _, ns = ...

--[[
    The Filters row an item falls under, by the type the client files it under.
    A subclass row (Mount, Companion Pets) wins over its class's row, which is
    how Miscellaneous leaves them out. C_Item.GetItemInfoInstant answers from
    the client's own database, so the row is known the moment the item drops.
]]
local FILTER_ROWS_BY_CLASS, FILTER_ROWS_BY_SUBCLASS = {}, {}
for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
	if row.subclassIdentifier then
		FILTER_ROWS_BY_SUBCLASS[row.classIdentifier .. ":" .. row.subclassIdentifier] = row
	elseif row.classIdentifier then
		FILTER_ROWS_BY_CLASS[row.classIdentifier] = row
	end
end

---@param itemIdentifier number
---@return table|nil
local function FilterRowFor(itemIdentifier)
	local _, _, _, _, _, classIdentifier, subclassIdentifier = C_Item.GetItemInfoInstant(itemIdentifier)
	if not classIdentifier then
		return nil
	end
	return FILTER_ROWS_BY_SUBCLASS[classIdentifier .. ":" .. tostring(subclassIdentifier)]
		or FILTER_ROWS_BY_CLASS[classIdentifier]
end

--[[
    Whether an item gets a toast, by the Mine boxes for the player's own loot
    and the Group boxes for anyone else's. An item counts when its type's box is
    ticked and, on a rarity row, it reaches the quality beside the box. Three
    rows reach across types: Openables (an item on the Openables List, whatever
    it is set to, since the toast is the player's cue that the add-on may be
    about to act), Bind on Pickup, and Quest, which also takes an item the game
    binds as a quest item whatever its class (Soft-shelled Clam is a Key), and
    a quest STARTER, as often an ordinary trinket or blade as a quest item.

    ORDER HERE IS BY COST. The list lookup and the type are free, Bind on Pickup
    needs the full C_Item.GetItemInfo, which can answer nil on a cold cache;
    that reads as "not Bind on Pickup". The player's own loot is cached the
    moment it is looted; another member's may not be, so ns.ShowLootToast asks
    for an uncached one it turned down and judges it once more. The quest
    starter costs a tooltip, so it is last. A quality nobody can read passes a
    rarity row: a toast is a display, and silently swallowing something that
    was looted is the worse failure.
]]
---@param quality number|nil
---@param itemIdentifier number|nil
---@param looterName string|nil # nil for the player's own loot
---@return boolean
function ns.IsLootToastWanted(quality, itemIdentifier, looterName)
	if not itemIdentifier then
		return true
	end
	local profile = ns.db.profile
	local shown = looterName and profile.lootToastGroup or profile.lootToastMine
	local qualities = looterName and profile.lootToastGroupQuality or profile.lootToastMineQuality
	if shown.OPENABLES and ns:GetOpeningAction(itemIdentifier) ~= nil then
		return true
	end
	local row = FilterRowFor(itemIdentifier)
	if row and shown[row.key] then
		if not row.rarity or not quality or quality >= (qualities[row.key] or 0) then
			return true
		end
	end
	local bindType = select(14, C_Item.GetItemInfo(itemIdentifier))
	if shown.BIND_ON_PICKUP and bindType == ns.BIND_ON_PICKUP then
		return true
	end
	if shown.QUEST and bindType == ns.BIND_QUEST_ITEM then
		return true
	end
	return shown.QUEST and not (row and row.key == "QUEST") and ns.ItemStartsQuest(itemIdentifier) or false
end
