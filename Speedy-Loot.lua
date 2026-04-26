--------------------------------------------------------------------------------
-- GogoLoot Speedy Loot Module
--
-- Watches LOOT_READY and rapidly loots every available slot, bypassing the
-- loot window for faster pickup.
--
-- Speedy Loot is gated only by the GogoLootDB.speedyLoot toggle — it runs in
-- solo, party, raid, and Master Looter contexts alike whenever the user has
-- it enabled in Options. There are intentionally no group / instance / ML
-- conditions on top of the user's preference.
--------------------------------------------------------------------------------

local LOOT_THROTTLE_SECONDS = 0.3
local lastLootAttemptTime = 0

--------------------------------------------------------------------------------
-- Bag API Compatibility
-- C_Container.GetContainerNumFreeSlots on modern clients, falls back to the
-- legacy global on older Classic builds.
--------------------------------------------------------------------------------

local GetContainerNumFreeSlotsCompat =
    (C_Container and C_Container.GetContainerNumFreeSlots) or GetContainerNumFreeSlots

local function CountFreeBagSlots()
    local totalFree = 0
    for bagIndex = 0, NUM_BAG_SLOTS do
        local freeInBag = GetContainerNumFreeSlotsCompat(bagIndex)
        if freeInBag then
            totalFree = totalFree + freeInBag
        end
    end
    return totalFree
end

--------------------------------------------------------------------------------
-- LOOT_READY Handler
--------------------------------------------------------------------------------

local function HandleLootReady()
    if not GogoLootDB or not GogoLootDB.speedyLoot then
        return
    end

    -- Respect the user's Auto Loot CVar plus the modifier-key inversion, so
    -- holding the auto-loot modifier still flips behavior as expected.
    local autoLootEnabled =
        (C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool("autoLootDefault")) or
        (GetCVar("autoLootDefault") == "1")
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

    if LootFrame then
        LootFrame:Hide()
    end

    -- Iterate from the bottom of the loot list upward to mirror default
    -- WoW auto-loot behavior and avoid index shifts as slots empty.
    for slotIndex = lootSlotCount, 1, -1 do
        if CountFreeBagSlots() > 0 then
            LootSlot(slotIndex)
        end
    end

    lastLootAttemptTime = currentTime
end

GogoLoot:RegisterModuleEvent("LOOT_READY", HandleLootReady)
