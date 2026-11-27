--------------------------------------------------------------------------------
-- GogoLoot Utilities: Bags
--------------------------------------------------------------------------------

local _, ns = ...

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

--[[
    Only general-purpose bags count: specialty bags can't hold what a container
    opens into. Speedy Loot keeps its own model, which counts them.
]]
---@return number
function ns.CountFreeBagSlots()
	local totalFree = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		local freeInBag, bagFamily = C_Container.GetContainerNumFreeSlots(bagIndex)
		if freeInBag and (bagFamily == 0 or bagFamily == nil) then
			totalFree = totalFree + freeInBag
		end
	end
	return totalFree
end

-- The ID call can come back empty for an uncached item while the slot's link already carries it.
---@param bagIndex number
---@param slotIndex number
---@return number|nil
function ns.GetBagItemIdentifier(bagIndex, slotIndex)
	local itemIdentifier = C_Container.GetContainerItemID(bagIndex, slotIndex)
	if itemIdentifier then
		return itemIdentifier
	end
	local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
	return itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
end

-- GetItemInfoInstant has no cold-cache nil, so the icon is there on first draw.
---@param itemIdentifier number|nil
---@return number|string|nil
function ns.GetItemIconByID(itemIdentifier)
	if not itemIdentifier then
		return nil
	end
	local _, _, _, _, icon = C_Item.GetItemInfoInstant(itemIdentifier)
	return icon
end

--------------------------------------------------------------------------------
-- Bag-Full Error
--------------------------------------------------------------------------------

--[[
    The only inventory-full test: Automated Opening and the Diagnostics event
    log both classify through it, so they can't disagree. Never add a
    message-text match beside it.
]]
---@param errorIdentifier any
---@return boolean
function ns.IsBagFullErrorID(errorIdentifier)
	return errorIdentifier == LE_GAME_ERR_INV_FULL
end

-- Full bags, or a unique item already carried.
---@param errorIdentifier any
---@return boolean
function ns.IsLootBounceErrorID(errorIdentifier)
	return ns.IsBagFullErrorID(errorIdentifier)
		or (LE_GAME_ERR_ITEM_MAX_COUNT ~= nil and errorIdentifier == LE_GAME_ERR_ITEM_MAX_COUNT)
end

---@return nil
function ns.PlayBagFullSound()
	local _, raceFile = UnitRace("player")
	local sex = UnitSex("player")
	local raceSounds = raceFile and ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE[raceFile]
	if raceSounds and raceSounds[sex] then
		PlaySound(raceSounds[sex], "Master")
	else
		PlaySound(ns.SOUND_KIT_IDS.BAG_FULL_FALLBACK, "Master")
	end
end

--[[
    Automated Opening and Speedy Loot can both hear the same refusal, so one
    warning per ns.BAG_FULL_COOLDOWN, whoever raises it.
]]
local lastBagFullWarningAt = nil

---@return boolean
function ns.ClaimBagFullWarning()
	local now = GetTime()
	if lastBagFullWarningAt and (now - lastBagFullWarningAt) <= ns.BAG_FULL_COOLDOWN then
		return false
	end
	lastBagFullWarningAt = now
	return true
end
