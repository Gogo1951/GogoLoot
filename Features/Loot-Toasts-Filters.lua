--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Filters
--------------------------------------------------------------------------------

local _, ns = ...

-- A subclass row (Mount, Companion Pets) wins over its class's row, which is how Miscellaneous leaves them out.
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
    ORDER IS BY COST: list and type are free, Bind on Pickup needs the full
    item info (a cold nil reads "not Bind on Pickup"), the quest starter costs a
    tooltip. An unreadable quality passes a rarity row: swallowing real loot is
    the worse failure.
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
