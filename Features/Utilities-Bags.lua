--------------------------------------------------------------------------------
-- GogoLoot Utilities: Bags
--------------------------------------------------------------------------------

--[[
    Shared bag helpers: free general-purpose bag slots, a bag slot's item ID,
    an item's icon, and the inventory-full error, voice line and warning.
]]
local _, ns = ...

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

--[[
    C_Container.GetContainerNumFreeSlots returns freeSlots, bagFamily.

    Only general-purpose bags (bagFamily 0 or nil) count: specialty bags (soul
    bags, quivers, ammo pouches, profession bags) can't hold what a container
    opens into, so their free slots are useless to Automated Opening, which
    pauses on this count (Diagnostics reports it too). Speedy Loot keeps its own
    bag-space model, which does count specialty bags for the loot they take.
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

--[[
    A bag slot's item ID. The ID call can come back empty for an item whose data
    the client has not loaded yet, while the slot's link already carries it.
]]
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

--[[
    C_Item.GetItemInfoInstant answers from the client's own database, with no
    cold-cache nil, so the icon is there the first time an item is drawn.
]]
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
    Every client GogoLoot ships for carries the inventory-full message id as the
    LE_GAME_ERR_INV_FULL global, which the API Endpoints report proves on each.
    That global is a number, so comparing anything else against it is already
    false. This is the only inventory-full test in the add-on: Automated
    Opening's handler and Diagnostics' event-log filter both classify
    UI_ERROR_MESSAGE through it, so a firing can never pause opening while the
    log files it away as noise. Never add a message-text match beside it; the
    two would disagree exactly when a bug report needs the log line.
]]
---@param errorIdentifier any
---@return boolean
function ns.IsBagFullErrorID(errorIdentifier)
	return errorIdentifier == LE_GAME_ERR_INV_FULL
end

--[[
    A pickup the bags refused: full bags, or a unique item already carried.
    Numeric like the test above; the max-count global is nil-safe, since a
    client without it simply never matches.
]]
---@param errorIdentifier any
---@return boolean
function ns.IsLootBounceErrorID(errorIdentifier)
	return ns.IsBagFullErrorID(errorIdentifier)
		or (LE_GAME_ERR_ITEM_MAX_COUNT ~= nil and errorIdentifier == LE_GAME_ERR_ITEM_MAX_COUNT)
end

-- The character's own "inventory is full" voice line, by race and by sex as UnitSex returns it.
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
    One inventory-full warning per ns.BAG_FULL_COOLDOWN, whoever raises it.
    Automated Opening and Speedy Loot can both hear the same refusal (a
    container opened into a loot window Speedy Loot then empties), and the
    player only needs telling once. True claims the warning and stamps it.
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
