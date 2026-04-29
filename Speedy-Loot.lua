--------------------------------------------------------------------------------
-- GogoLoot Speedy Loot Module
--
-- Watches LOOT_READY and rapidly loots every available slot, bypassing the
-- loot window for faster pickup.
--
-- Speedy Loot is gated by GogoLootDB.speedyLoot (the user's toggle) and
-- defers to Master-Loot.lua when GogoLoot:WillAutoMasterLoot() is true —
-- otherwise our LootSlot calls would race the distribution path and pop
-- the ML candidate dropdown for at-or-above-threshold items the Master
-- Loot module would have placed automatically. Outside the ML path it
-- runs in solo, party, raid, etc. as before.
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
-- Auto-Loot CVar Compatibility
-- Picks the API by availability, not by truthy result. The previous
-- `(modern call) or (legacy call)` pattern fell through to the legacy
-- check whenever the modern API returned false (auto-loot disabled),
-- which happened to give the right answer here but is a brittle pattern.
--------------------------------------------------------------------------------

local function IsAutoLootCVarEnabled()
    if C_CVar and C_CVar.GetCVarBool then
        return C_CVar.GetCVarBool("autoLootDefault")
    end
    return GetCVar("autoLootDefault") == "1"
end

--------------------------------------------------------------------------------
-- LOOT_READY Handler
--------------------------------------------------------------------------------

local function HandleLootReady()
    if not GogoLootDB or not GogoLootDB.speedyLoot then
        return
    end

    -- Defer to Master-Loot.lua when it will own this loot session.
    -- Calling LootSlot in ML mode for at-or-above-threshold items pops
    -- the candidate dropdown, which races our automated distribution.
    if GogoLoot.WillAutoMasterLoot and GogoLoot:WillAutoMasterLoot() then
        return
    end

    -- Respect the user's Auto Loot CVar plus the modifier-key inversion, so
    -- holding the auto-loot modifier still flips behavior as expected.
    local autoLootEnabled = IsAutoLootCVarEnabled()
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
    -- Cache the free-slot count once and decrement as we loot. Items can
    -- stack into existing slots so this is conservative — we may stop a
    -- slot or two early on a stackable run, but anything left in the loot
    -- window is still recoverable normally and this avoids an O(N*bags)
    -- scan inside the loop.
    local availableBagSlots = CountFreeBagSlots()
    for slotIndex = lootSlotCount, 1, -1 do
        if availableBagSlots <= 0 then
            break
        end
        LootSlot(slotIndex)
        availableBagSlots = availableBagSlots - 1
    end

    lastLootAttemptTime = currentTime
end

GogoLoot:RegisterModuleEvent("LOOT_READY", HandleLootReady)