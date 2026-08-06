--------------------------------------------------------------------------------
-- GogoLoot Speedy Loot Module
--------------------------------------------------------------------------------

--[[
    Watches LOOT_READY and rapidly loots every available slot, bypassing the
    loot window for faster pickup.

    Gated by ns.db.global.speedyLoot, and stands down for the whole master-loot
    session whenever ns:AreWeMasterLooter() is true — LootSlot calls in an ML
    session race the distribution path and pop the candidate dropdown for items
    the engine would have placed automatically.
]]
local _, ns = ...

local LOOT_THROTTLE_SECONDS = 0.3
local lastLootAttemptTime = 0

--------------------------------------------------------------------------------
-- Free Bag Slots
--------------------------------------------------------------------------------

--[[
    ns.GetContainerNumFreeSlots (Utilities' shim) returns freeSlots, bagFamily.

    Only general-purpose bags (bagFamily 0, or nil from the backpack/legacy API)
    count toward the budget: specialty bags — soul bags, quivers, ammo pouches,
    profession bags — can't hold normal loot, so their free slots are useless to
    us. This is deliberately conservative: loot that could stack into a matching
    specialty bag may be left in the loot window instead, where it stays
    reachable, rather than risk a budget that overcounts usable space.
]]

local function CountFreeBagSlots()
	local totalFree = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		local freeInBag, bagFamily = ns.GetContainerNumFreeSlots(bagIndex)
		if freeInBag and (bagFamily == 0 or bagFamily == nil) then
			totalFree = totalFree + freeInBag
		end
	end
	return totalFree
end

--------------------------------------------------------------------------------
-- Loot Slot Type
--------------------------------------------------------------------------------

--[[
    Money (and currency) slots take no bag space, so only item slots count
    against the free-slot budget. When GetLootSlotType is unavailable, treat
    every slot as an item — that degrades to the conservative budget-for-
    everything behavior instead of risking overfilled bags.
]]

local function IsItemLootSlot(slotIndex)
	if type(GetLootSlotType) ~= "function" then
		return true
	end
	return GetLootSlotType(slotIndex) == (LOOT_SLOT_ITEM or 1)
end

--------------------------------------------------------------------------------
-- LOOT_READY Handler
--------------------------------------------------------------------------------

local function HandleLootReady()
	if not ns.db or not ns.db.global.speedyLoot then
		return
	end

	--[[
        Stand down for the whole loot session whenever we are the master looter,
        not only when GogoLoot will auto-distribute. Master loot is a managed
        flow: at-or-above-threshold items are assigned through the ML window
        (automatically by Master-Looter.lua, or by hand) and sub-threshold items
        are handed out by the group method. LootSlot here would vacuum that loot
        into the master looter's own bags before it can be assigned, and LootSlot
        on a threshold item pops MasterLooterFrame_Show, which errors on some
        clients (the nil colorInfo loot-frame crash). AreWeMasterLooter() is the
        superset of WillAutoMasterLoot(), so this still covers the auto-distribute
        case it replaces — including outside instances, where auto-distribution is
        off by default but we must still not auto-loot a master-loot session.
    ]]
	if ns.AreWeMasterLooter and ns:AreWeMasterLooter() then
		return
	end

	--[[
        Respect the user's Auto Loot CVar plus the modifier-key inversion, so
        holding the auto-loot modifier still flips behavior as expected.
    ]]
	local autoLootEnabled = ns:IsAutoLootCVarEnabled()
	local modifierKeyHeld = IsModifiedClick("AUTOLOOTTOGGLE")
	local shouldAutoLoot = (autoLootEnabled ~= modifierKeyHeld)
	if not shouldAutoLoot then
		return
	end

	-- Throttle to avoid double-firing on closely-spaced LOOT_READY events.
	local currentTime = GetTime()
	if (currentTime - lastLootAttemptTime) < LOOT_THROTTLE_SECONDS then
		return
	end

	local lootSlotCount = GetNumLootItems()
	if lootSlotCount < 1 then
		return
	end

	local availableBagSlots = CountFreeBagSlots()

	--[[
        With no bag space and item slots present, loot nothing and leave the
        standard loot window visible — hiding it would strand the loot.
    ]]
	if availableBagSlots <= 0 then
		for slotIndex = 1, lootSlotCount do
			if IsItemLootSlot(slotIndex) then
				return
			end
		end
	end

	if LootFrame then
		LootFrame:Hide()
	end

	--[[
        Iterate from the bottom of the loot list upward to mirror default
        WoW auto-loot behavior and avoid index shifts as slots empty.
        Money and currency slots are always looted — they take no bag space.
        The free-slot budget is cached once and decremented per item; items
        can stack into existing slots so this is conservative. We may skip a
        slot or two early on a stackable run, but anything left in the loot
        window is still recoverable normally and this avoids an O(N*bags)
        scan inside the loop.
    ]]
	for slotIndex = lootSlotCount, 1, -1 do
		if not IsItemLootSlot(slotIndex) then
			LootSlot(slotIndex)
		elseif availableBagSlots > 0 then
			LootSlot(slotIndex)
			availableBagSlots = availableBagSlots - 1
		end
	end

	lastLootAttemptTime = currentTime
end

ns:RegisterModuleEvent("LOOT_READY", HandleLootReady)
