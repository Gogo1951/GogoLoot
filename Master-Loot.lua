-------------------------------------------------------------------------------
-- GogoLoot MasterLoot Module
-------------------------------------------------------------------------------
local parsedItemLinkCache = {}    
local itemInformationLookupCache = {}    

local announcementQueue = {}
local isAnnouncing = false
local isProcessingLoot = false
local isAutomatedGiveMasterLoot = false
local retryCounter = 0
local activeLootTimer = nil

-- Pending announcements keyed by loot slot index, fired on LOOT_SLOT_CLEARED
local pendingSlotAnnouncements = {}

-- Error messages we watch for during automated master looting
local WATCHED_ERROR_MESSAGES = {}

local function BuildWatchedErrors()
    local errorStrings = {
        ERR_INV_FULL,
        ERR_ALREADY_HAS_ITEM,
        ERR_ITEM_MAX_COUNT,
        ERR_LOOT_PLAYER_NOT_FOUND,
        LOOT_ERR_BAG_FULL,
    }
    for _, errorString in ipairs(errorStrings) do
        if errorString then
            WATCHED_ERROR_MESSAGES[errorString] = true
        end
    end
end

local function ProcessAnnouncementQueue()
    if #announcementQueue > 0 then
        local msg = table.remove(announcementQueue, 1)
        SendChatMessage(msg, GogoLoot:GetGroupChatChannel())
        C_Timer.After(0.1, ProcessAnnouncementQueue) 
    else
        isAnnouncing = false
    end
end

local function QueueAnnouncement(msg)
    table.insert(announcementQueue, msg)
    if not isAnnouncing then
        isAnnouncing = true
        ProcessAnnouncementQueue()
    end
end

function GogoLoot:HideLootFrame()
    if InCombatLockdown() then return false end
    if LootFrame and LootFrame:IsShown() then LootFrame:SetAlpha(0) end
    if ElvLootFrame and ElvLootFrame:IsShown() then ElvLootFrame:SetAlpha(0) end
    return true
end

function GogoLoot:ShowLootFrame()
    if LootFrame then LootFrame:SetAlpha(1) end
    if ElvLootFrame then ElvLootFrame:SetAlpha(1) end
end

local function GetCachedParsedItemLink(itemLink)
    if not parsedItemLinkCache[itemLink] then parsedItemLinkCache[itemLink] = GogoLoot:ParseItemLink(itemLink) end
    return parsedItemLinkCache[itemLink]
end

local function GetCachedItemInformation(itemLink)
    if not itemInformationLookupCache[itemLink] then
        local info = GogoLoot:SafeGetItemInfo(itemLink)
        if not info then
            local parsedItemLink = GetCachedParsedItemLink(itemLink)
            if parsedItemLink and parsedItemLink.itemIdentifier then
                info = GogoLoot:SafeGetItemInfo(parsedItemLink.itemIdentifier)
            end
        end
        if info then
            itemInformationLookupCache[itemLink] = info
        end
    end
    return itemInformationLookupCache[itemLink]
end

local function ShouldMasterLootItem(itemLink, itemIdentifier)
    if not itemLink or not itemIdentifier then return false end
    if GogoLoot:IsItemOnIgnoreList(itemIdentifier, true, false) then return false end

    local itemInformation = GetCachedItemInformation(itemLink)
    if not itemInformation then return false end

    if itemInformation.bindType == GogoLoot.BIND_QUEST_ITEM then return false end
    if GogoLoot:ShouldSkipItemByType(itemInformation) then return false end
    
    if itemInformation.bindType == GogoLoot.BIND_ON_PICKUP then
        if not GogoLoot_Configuration.autoMasterLootOutsideInstances and not GogoLoot:IsInBindOnPickupTradeInstance() then
            return false
        end
    end

    return true
end

local function BuildCandidateIndex()
    local candidatesBySlot = {}
    for slotIndex = 1, GetNumLootItems() do
        for memberIndex = 1, GetNumGroupMembers() do
            local candidateName = GetMasterLootCandidate(slotIndex, memberIndex)
            if candidateName then
                candidatesBySlot[slotIndex] = candidatesBySlot[slotIndex] or {}
                candidatesBySlot[slotIndex][strlower(candidateName)] = memberIndex
            end
        end
    end
    return candidatesBySlot
end

local function FormatItemText(itemLink, itemQuantity)
    if itemQuantity and itemQuantity > 1 then
        return itemLink .. " x" .. itemQuantity
    end
    return itemLink
end

local function RegisterPendingAnnouncement(slotIndex, message)
    pendingSlotAnnouncements[slotIndex] = message
end

-------------------------------------------------------------------------------
-- GiveMasterLoot Hook for Manual Distribution Announcements
-------------------------------------------------------------------------------
local originalGiveMasterLoot = GiveMasterLoot

GiveMasterLoot = function(slotIndex, candidateIndex)
    if not isAutomatedGiveMasterLoot
        and GogoLoot_Configuration.announceMasterLoot
        and GogoLoot:AreWeMasterLooter()
    then
        local lootLink = GetLootSlotLink(slotIndex)
        local candidateName = GetMasterLootCandidate(slotIndex, candidateIndex)
        if lootLink and candidateName then
            local _, _, itemQuantity = GetLootSlotInfo(slotIndex)
            local dashPosition = string.find(candidateName, "-")
            if dashPosition then
                candidateName = string.sub(candidateName, 1, dashPosition - 1)
            end
            local printName = GogoLoot:CapitalizeFirstLetter(candidateName)
            local itemText = FormatItemText(lootLink, itemQuantity)
            RegisterPendingAnnouncement(slotIndex, string.format(GogoLoot.MESSAGE_LOOT_ANNOUNCE, itemText, printName))
        end
    end
    originalGiveMasterLoot(slotIndex, candidateIndex)
end

-------------------------------------------------------------------------------
-- Event: LOOT_SLOT_CLEARED - item confirmed removed from corpse
-------------------------------------------------------------------------------
local function HandleLootSlotCleared(eventName, slotIndex)
    if pendingSlotAnnouncements[slotIndex] then
        QueueAnnouncement(pendingSlotAnnouncements[slotIndex])
        pendingSlotAnnouncements[slotIndex] = nil
    end
end

-------------------------------------------------------------------------------
-- Error Handling During Automated Looting
-------------------------------------------------------------------------------
local function HandleUIErrorMessage(eventName, errorType, errorMessage)
    if not isProcessingLoot then return end
    if not errorMessage then return end

    if WATCHED_ERROR_MESSAGES[errorMessage] then
        GogoLoot:PrintMessage(errorMessage)
        GogoLoot:ShowLootFrame()
    end
end

-------------------------------------------------------------------------------
-- Automated Master Loot Processing
-------------------------------------------------------------------------------
local function ProcessMasterLoot()
    activeLootTimer = nil
    local numItems = GetNumLootItems()
    if numItems == 0 then 
        isProcessingLoot = false
        return 
    end
    
    local allItemsCached = true
    local itemsToProcess = {}
    
    for slotIndex = numItems, 1, -1 do
        local lootIcon, _, itemQuantity = GetLootSlotInfo(slotIndex)
        local lootLink = GetLootSlotLink(slotIndex)
        
        if not lootLink and lootIcon then
            table.insert(itemsToProcess, { isItem = false, slot = slotIndex })
        elseif lootLink then
            local itemInfo = GetCachedItemInformation(lootLink)
            if not itemInfo then
                allItemsCached = false
                local parsedItemLink = GetCachedParsedItemLink(lootLink)
                if parsedItemLink and parsedItemLink.itemIdentifier and C_Item and C_Item.RequestLoadItemDataByID then
                    pcall(function() C_Item.RequestLoadItemDataByID(parsedItemLink.itemIdentifier) end)
                end
            end
            table.insert(itemsToProcess, { 
                isItem = true, 
                slot = slotIndex, 
                link = lootLink,
                quantity = itemQuantity,
            })
        end
    end
    
    if not allItemsCached then
        retryCounter = retryCounter + 1
        if retryCounter < 15 then
            activeLootTimer = C_Timer.NewTimer(0.2, ProcessMasterLoot)
            return 
        end
    end
    
    local candidatesBySlot = BuildCandidateIndex()
    local myName = GogoLoot:GetLowercaseUnitName("player")
    local announceThreshold = GogoLoot_Configuration.announceMasterLootThreshold

    for _, data in ipairs(itemsToProcess) do
        if not data.isItem then
            LootSlot(data.slot)
        else
            local parsedData = GetCachedParsedItemLink(data.link)
            if parsedData and parsedData.itemIdentifier then
                local cachedItemInformation = GetCachedItemInformation(data.link)
                local itemQuality = cachedItemInformation and cachedItemInformation.quality or 0
                local rarityKey = GogoLoot.rarityToConfigurationKey[itemQuality]
                local targetPlayerName = rarityKey and GogoLoot_Configuration.destinations[rarityKey] or "self"
                targetPlayerName = strlower(targetPlayerName)
                
                local isSelf = (targetPlayerName == "self" or targetPlayerName == "player" or targetPlayerName == myName)

                if ShouldMasterLootItem(data.link, parsedData.itemIdentifier) then
                    local candidateIndex = nil
                    if candidatesBySlot[data.slot] then
                        local mirroredCandidates = GogoLoot:MirrorServerNames(candidatesBySlot[data.slot])
                        candidateIndex = isSelf and mirroredCandidates[myName] or mirroredCandidates[targetPlayerName]
                    end
                    
                    if candidateIndex then
                        -- Prepare the announcement but don't fire it yet
                        if GogoLoot_Configuration.announceMasterLoot and itemQuality >= announceThreshold then
                            local printName = isSelf and GogoLoot:CapitalizeFirstLetter(myName) or GogoLoot:CapitalizeFirstLetter(targetPlayerName)
                            local itemText = FormatItemText(data.link, data.quantity)
                            RegisterPendingAnnouncement(data.slot, string.format(GogoLoot.MESSAGE_LOOT_ANNOUNCE, itemText, printName))
                        end
                        isAutomatedGiveMasterLoot = true
                        GiveMasterLoot(data.slot, candidateIndex)
                        isAutomatedGiveMasterLoot = false
                    elseif isSelf then
                        LootSlot(data.slot)
                    end
                end
            end
        end
    end
    
    activeLootTimer = C_Timer.NewTimer(0.3, function() isProcessingLoot = false end)
end

local function HandleLootOpened()
    if IsShiftKeyDown() then return end
    if isProcessingLoot then return end

    if GogoLoot_Configuration.autoMasterLoot and GogoLoot:AreWeMasterLooter() then
        isProcessingLoot = true
        GogoLoot:HideLootFrame()
        retryCounter = 0
        ProcessMasterLoot()
    end
end

local function HandleLootClosed()
    if activeLootTimer then activeLootTimer:Cancel() end
    isProcessingLoot = false
    parsedItemLinkCache, itemInformationLookupCache = {}, {}
    pendingSlotAnnouncements = {}
    GogoLoot:ShowLootFrame()
end

BuildWatchedErrors()

GogoLoot:RegisterModuleEvent("LOOT_READY", HandleLootOpened)
GogoLoot:RegisterModuleEvent("LOOT_OPENED", HandleLootOpened)
GogoLoot:RegisterModuleEvent("LOOT_CLOSED", HandleLootClosed)
GogoLoot:RegisterModuleEvent("LOOT_SLOT_CLEARED", HandleLootSlotCleared)
GogoLoot:RegisterModuleEvent("UI_ERROR_MESSAGE", HandleUIErrorMessage)
GogoLoot:RegisterModuleEvent("PLAYER_ENTERING_WORLD", function() 
    isProcessingLoot = false
    parsedItemLinkCache, itemInformationLookupCache = {}, {}
    pendingSlotAnnouncements = {}
end)