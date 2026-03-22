-------------------------------------------------------------------------------
-- GogoLoot AutomaticRoll Module
-------------------------------------------------------------------------------

-- Items that are NEVER automated, even from the Custom List
local function ShouldAlwaysSkipItem(itemInformation)
    if not itemInformation then return true end
    -- Legendaries
    if itemInformation.quality == 5 then return true end
    -- Quest Items
    if itemInformation.classId == GogoLoot.ITEM_CLASS_QUEST or itemInformation.bindType == GogoLoot.BIND_QUEST_ITEM then return true end
    -- Recipes, Books, Patterns, Plans, Schematics, Formulas (all classId 9)
    if itemInformation.classId == GogoLoot.ITEM_CLASS_RECIPE then return true end
    -- Mounts and Companion Pets
    if itemInformation.classId == GogoLoot.ITEM_CLASS_MISCELLANEOUS and (itemInformation.subclassId == GogoLoot.ITEM_SUBCLASS_COMPANION_PET or itemInformation.subclassId == GogoLoot.ITEM_SUBCLASS_MOUNT) then
        return true
    end
    return false
end

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

local function HandleStartLootRoll(eventName, rollIdentifier)
    local _, _, _, rollQuality, _, _, rollGreedAllowed, rollNeedAllowed = GetLootRollItemInfo(rollIdentifier)
    local rollItemLink = GetLootRollItemLink(rollIdentifier)
    if not rollItemLink then return end

    local parsedItemLink = GogoLoot:ParseItemLink(rollItemLink)
    if not parsedItemLink or not parsedItemLink.itemIdentifier then return end

    local itemInformation = GogoLoot:SafeGetItemInfo(parsedItemLink.itemIdentifier)

    -- Hard safety: legendaries, quest items, recipes/books, mounts, pets are never automated
    if ShouldAlwaysSkipItem(itemInformation) then return end

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
    if not GogoLoot_Configuration.autoGreed then return end

    -- Threshold auto-greed NEVER touches BoP items
    if itemInformation and itemInformation.bindType == GogoLoot.BIND_ON_PICKUP then return end

    if rollQuality <= GogoLoot_Configuration.autoGreedThreshold then
        if rollGreedAllowed then
            RollOnLoot(rollIdentifier, GogoLoot.ROLL_ACTION_GREED)
        end
    end
end

GogoLoot:RegisterModuleEvent("START_LOOT_ROLL", HandleStartLootRoll)
GogoLoot:RegisterModuleEvent("CONFIRM_LOOT_ROLL", function(_, rollIdentifier, rollAction) ConfirmLootRoll(rollIdentifier, rollAction) end)