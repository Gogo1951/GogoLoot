--------------------------------------------------------------------------------
-- GogoLoot Automatic Roll Module
--------------------------------------------------------------------------------

local function ExecuteRollOverride(rollIdentifier, rollOverride, rollGreedAllowed, rollNeedAllowed)
    if rollOverride == GogoLoot.NEED then
        if rollNeedAllowed then
            RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_NEED)
        elseif rollGreedAllowed then
            RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_GREED)
        end
    elseif rollOverride == GogoLoot.GREED then
        if rollGreedAllowed then
            RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_GREED)
        end
    elseif rollOverride == GogoLoot.PASS then
        RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_PASS)
    end
end

--------------------------------------------------------------------------------
-- START_LOOT_ROLL
--------------------------------------------------------------------------------

local function HandleStartLootRoll(rollIdentifier)
    -- GetLootRollItemInfo returns: texture, name, count, quality,
    -- bindOnPickUp, canNeed, canGreed, canDisenchant, ...
    local _, _, _, rollQuality, _, rollNeedAllowed, rollGreedAllowed = GetLootRollItemInfo(rollIdentifier)
    local rollItemLink = GetLootRollItemLink(rollIdentifier)
    if not rollItemLink then
        return
    end

    local parsedItemLink = GogoLoot:ParseItemLink(rollItemLink)
    if not parsedItemLink or not parsedItemLink.itemIdentifier then
        return
    end

    local itemInformation = GogoLoot:SafeGetItemInfo(parsedItemLink.itemIdentifier)

    -- Hard safety: legendaries, quest items, recipes/books, mounts, pets are never automated
    if GogoLoot:ShouldSkipItemByType(itemInformation) then
        return
    end

    -- Custom List: per-item overrides bypass threshold AND allow BoP items
    local rollOverride = GogoLoot:GetItemRollOverride(parsedItemLink.itemIdentifier)
    if rollOverride then
        if rollOverride == GogoLoot.MANUAL then
            return
        end
        ExecuteRollOverride(rollIdentifier, rollOverride, rollGreedAllowed, rollNeedAllowed)
        return
    end

    -- Threshold-based auto greed: only if enabled
    if not GogoLootDB.autoGreed then
        return
    end

    -- Threshold auto-greed NEVER touches BoP items
    if itemInformation and itemInformation.bindType == GogoLoot.BIND_ON_PICKUP then
        return
    end

    if rollQuality <= GogoLootDB.autoGreedThreshold then
        if rollGreedAllowed then
            RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_GREED)
        end
    end
end

GogoLoot:RegisterModuleEvent("START_LOOT_ROLL", HandleStartLootRoll)

--------------------------------------------------------------------------------
-- CONFIRM_LOOT_ROLL
--------------------------------------------------------------------------------

GogoLoot:RegisterModuleEvent(
    "CONFIRM_LOOT_ROLL",
    function(rollIdentifier, rollAction)
        ConfirmLootRoll(rollIdentifier, rollAction)
    end
)