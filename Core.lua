-------------------------------------------------------------------------------
-- GogoLoot Core & Utilities
-------------------------------------------------------------------------------
local ADDON_NAME = "GogoLoot"
local GetItemInfo = GogoLoot.GetItemInfo

-------------------------------------------------------------------------------
-- Initialization & Addon Setup
-------------------------------------------------------------------------------
local function MigrateIgnoreLists()
    if GogoLoot_Configuration.ignoredItemsSolo then
        for identifier, value in pairs(GogoLoot_Configuration.ignoredItemsSolo) do
            if value == true then
                GogoLoot_Configuration.ignoredItemsSolo[identifier] = GogoLoot.MANUAL
            end
        end
    end
end

-- Migrate old combined trade condition values into the new two-key system
local function MigrateTradeAnnounceConfig()
    local oldCondition = GogoLoot_Configuration.announceTradeCondition
    if oldCondition == "group" or oldCondition == "group_ml" then
        GogoLoot_Configuration.announceTradeCondition = "party_or_raid"
        if not GogoLoot_Configuration.announceTradeOutput then
            GogoLoot_Configuration.announceTradeOutput = "group"
        end
    end
end

local function InitializeSavedVariables()
    if not GogoLoot_Configuration then
        GogoLoot_Configuration = {}
    end

    -- Force a full reset when the config version is outdated or missing
    local savedVersion = GogoLoot_Configuration.configVersion
    if savedVersion ~= GogoLoot.CONFIG_VERSION then
        -- Existing users have keys in their config; fresh installs have an empty table
        local isUpgrade = (next(GogoLoot_Configuration) ~= nil)
        GogoLoot_Configuration = {}

        for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
            if type(defaultValue) == "table" then
                GogoLoot_Configuration[configurationKey] = {}
                for key, value in pairs(defaultValue) do
                    GogoLoot_Configuration[configurationKey][key] = value
                end
            else
                GogoLoot_Configuration[configurationKey] = defaultValue
            end
        end

        GogoLoot_Configuration.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
        GogoLoot_Configuration.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
        GogoLoot_Configuration.configVersion = GogoLoot.CONFIG_VERSION

        if isUpgrade then
            C_Timer.After(5, function()
                GogoLoot:PrintMessage("Settings have been reset for this update. Use /gl to review your options.")
            end)
        end

        return
    end

    GogoLoot_Configuration.globalEnable = nil

    for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
        if GogoLoot_Configuration[configurationKey] == nil then
            if type(defaultValue) == "table" then
                GogoLoot_Configuration[configurationKey] = {}
                for key, value in pairs(defaultValue) do
                    GogoLoot_Configuration[configurationKey][key] = value
                end
            else
                GogoLoot_Configuration[configurationKey] = defaultValue
            end
        end
    end

    if next(GogoLoot_Configuration.ignoredItemsMaster) == nil then
        GogoLoot_Configuration.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
    end
    if next(GogoLoot_Configuration.ignoredItemsSolo) == nil then
        GogoLoot_Configuration.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
    end

    MigrateIgnoreLists()
    MigrateTradeAnnounceConfig()
end

local function CheckForConflictingAddons()
    local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    for _, addonName in ipairs(GogoLoot.conflictingAddonNames) do
        if IsAddOnLoaded(addonName) then
            C_Timer.After(5, function()
                GogoLoot:PrintMessage("Conflicting loot addons detected.")
                GogoLoot:PrintMessage("|cFFFF6666Conflicting addon:|r " .. addonName)
            end)
            return
        end
    end
end

local function CheckAutoLootEnabled()
    local autoLootEnabled = GetCVar("autoLootDefault")
    if autoLootEnabled ~= "1" then
        SetCVar("autoLootDefault", "1")
        GogoLoot:PrintMessage("Auto Loot is required for GogoLoot to function properly. Auto Loot has been enabled.")
    end
end

-------------------------------------------------------------------------------
-- Event Dispatcher
-------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "GogoLootEventFrame", UIParent)
GogoLoot.eventHandlers = {}

function GogoLoot:RegisterModuleEvent(eventName, handlerFunction)
    if not GogoLoot.eventHandlers[eventName] then
        GogoLoot.eventHandlers[eventName] = {}
        eventFrame:RegisterEvent(eventName)
    end
    table.insert(GogoLoot.eventHandlers[eventName], handlerFunction)
end

eventFrame:SetScript("OnEvent", function(self, eventName, ...)
    local handlers = GogoLoot.eventHandlers[eventName]
    if handlers then
        for _, handlerFunction in ipairs(handlers) do
            handlerFunction(eventName, ...)
        end
    end
end)

local function OnAddonLoaded(eventName, loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then return end
    InitializeSavedVariables()
    CheckForConflictingAddons()
    if GogoLoot.InitializeOptions then GogoLoot:InitializeOptions() end
end

GogoLoot:RegisterModuleEvent("ADDON_LOADED", OnAddonLoaded)

local hasCheckedAutoLoot = false
GogoLoot:RegisterModuleEvent("PLAYER_ENTERING_WORLD", function()
    if not hasCheckedAutoLoot then
        hasCheckedAutoLoot = true
        C_Timer.After(3, CheckAutoLootEnabled)
    end
end)

SLASH_GOGOLOOT1 = "/gl"
SLASH_GOGOLOOT2 = "/gogoloot"
SlashCmdList["GOGOLOOT"] = function(inputText)
    GogoLoot:HandleSlashCommand(inputText)
end

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------
function GogoLoot:PrintMessage(text)
    print("|c" .. GogoLoot.PRINT_COLOR .. "GogoLoot //|r " .. "|c" .. GogoLoot.PRINT_COLOR .. text .. "|r")
end

function GogoLoot:DebugPrint(...)
    if GogoLoot_Configuration and GogoLoot_Configuration.debugMode then
        print("|cFFAAFFAA[GogoLoot Debug]|r", ...)
    end
end

function GogoLoot:GetCleanUnitName(unitIdentifier)
    local fullName = UnitName(unitIdentifier)
    if not fullName then return nil end
    local dashPosition = string.find(fullName, "-")
    if dashPosition then fullName = string.sub(fullName, 1, dashPosition - 1) end
    return fullName
end

function GogoLoot:GetLowercaseUnitName(unitIdentifier)
    local cleanName = self:GetCleanUnitName(unitIdentifier)
    return cleanName and strlower(cleanName) or nil
end

function GogoLoot:CapitalizeFirstLetter(text)
    if not text or text == "" then return text end
    return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

function GogoLoot:ParseItemLink(itemLink)
    if not itemLink then return nil end
    local matchResults = { string.find(itemLink, GogoLoot.ITEM_LINK_PATTERN) }
    if not matchResults[1] then return nil end

    return {
        itemIdentifier = tonumber(matchResults[5]),
        itemName = matchResults[16],
    }
end

function GogoLoot:SafeGetItemInfo(itemIdentifierOrLink)
    if not itemIdentifierOrLink then return nil end
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLocation, itemTexture, sellPrice, classId, subclassId, bindType = GetItemInfo(itemIdentifierOrLink)
    if not itemName then return nil end

    return {
        name = itemName,
        link = itemLink,
        quality = itemQuality,
        classId = classId,
        subclassId = subclassId,
        bindType = bindType,
    }
end

function GogoLoot:GetGroupChatChannel()
    if UnitInRaid("player") then return "RAID"
    elseif IsInGroup() then return "PARTY"
    else return "SAY" end
end

function GogoLoot:GetGroupOrWhisperChannel(targetPlayerName)
    if IsInGroup() then return GogoLoot:GetGroupChatChannel(), nil
    else return "WHISPER", targetPlayerName end
end

function GogoLoot:AreWeMasterLooter()
    local lootMethod, masterLooterPartyIndex
    
    if type(GetLootMethod) == "function" then
        lootMethod, masterLooterPartyIndex = GetLootMethod()
    elseif C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
        local methodEnum, partyIndex = C_PartyInfo.GetLootMethod()
        masterLooterPartyIndex = partyIndex
        
        if Enum and Enum.LootMethod and methodEnum == Enum.LootMethod.MasterLoot then
            lootMethod = "master"
        elseif methodEnum == 2 then
            lootMethod = "master"
        end
    end
    
    return lootMethod == "master" and masterLooterPartyIndex == 0
end

function GogoLoot:IsInBindOnPickupTradeInstance()
    local _, instanceType = GetInstanceInfo()
    return (instanceType == "raid" or instanceType == "party")
end

function GogoLoot:IsItemOnIgnoreList(itemIdentifier, checkMasterList, checkSoloList)
    if not itemIdentifier then return true end
    if checkMasterList and GogoLoot_Configuration.ignoredItemsMaster[itemIdentifier] then return true end
    if checkSoloList and GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier] then return true end
    return false
end

function GogoLoot:GetItemRollOverride(itemIdentifier)
    if not itemIdentifier then return nil end
    local override = GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier]
    if not override then return nil end
    return override
end

function GogoLoot:ShouldSkipItemByType(itemInformation)
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

function GogoLoot:MirrorServerNames(playerList)
    local mirroredList = {}
    for playerName, candidateIndex in pairs(playerList) do
        mirroredList[playerName] = candidateIndex
        local dashPosition = string.find(playerName, "-")
        if dashPosition then
            mirroredList[string.sub(playerName, 1, dashPosition - 1)] = candidateIndex
        end
    end
    return mirroredList
end