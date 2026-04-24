--------------------------------------------------------------------------------
-- GogoLoot Core & Utilities
--------------------------------------------------------------------------------
local ADDON_NAME = "GogoLoot"
local L = GogoLoot.L
local GetItemInfo = GogoLoot.GetItemInfo

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
    local version =
        C_AddOns and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or GetAddOnMetadata(ADDON_NAME, "Version")
    if not version or version:find("@") then
        return "Dev"
    end
    return version
end

GogoLoot.Version = GetVersion()

--------------------------------------------------------------------------------
-- Default Ignore List Builders
--------------------------------------------------------------------------------

function GogoLoot:BuildDefaultIgnoreListSolo()
    local list = {}
    for identifier, data in pairs(GogoLoot.DEFAULT_IGNORE_LIST_SOLO) do
        if data[1] <= GogoLoot.currentExpansion then
            list[identifier] = GogoLoot.ROLL_OVERRIDE_FROM_INDEX[data[2]] or GogoLoot.MANUAL
        end
    end
    return list
end

function GogoLoot:BuildDefaultIgnoreListMaster()
    local list = {}
    for identifier, data in pairs(GogoLoot.DEFAULT_IGNORE_LIST_MASTER) do
        if data[1] <= GogoLoot.currentExpansion then
            list[identifier] = true
        end
    end
    return list
end

--------------------------------------------------------------------------------
-- Default Application Helper
-- Copies one default value (including tables) onto a target DB table.
--------------------------------------------------------------------------------

local function CopyDefault(target, key, defaultValue)
    if type(defaultValue) == "table" then
        target[key] = {}
        for subKey, subValue in pairs(defaultValue) do
            target[key][subKey] = subValue
        end
    else
        target[key] = defaultValue
    end
end

--------------------------------------------------------------------------------
-- Reset Helper
-- Wipes GogoLootDB in place and reapplies all defaults + default item lists.
-- Called from InitializeSavedVariables (on config version mismatch) and from
-- the Reset All button in Options.lua.
--------------------------------------------------------------------------------

function GogoLoot:ResetAllSettings()
    for existingKey in pairs(GogoLootDB) do
        GogoLootDB[existingKey] = nil
    end

    for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
        CopyDefault(GogoLootDB, configurationKey, defaultValue)
    end

    GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
    GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
    GogoLootDB.configVersion = GogoLoot.CONFIG_VERSION
end

--------------------------------------------------------------------------------
-- Item Input Parsing
-- Accepts a numeric item ID string or a full item link; returns the numeric
-- item ID or nil. Shared by the Options panels that let users add items.
--------------------------------------------------------------------------------

function GogoLoot:ParseItemInput(rawInput)
    if not rawInput or rawInput == "" then
        return nil
    end

    local numericIdentifier = tonumber(rawInput)
    if numericIdentifier then
        return numericIdentifier
    end

    local fromLink = string.match(rawInput, "item:(%d+)")
    if fromLink then
        return tonumber(fromLink)
    end

    return nil
end

--------------------------------------------------------------------------------
-- Item Identifier Sort
-- Sorts in place by rarity (highest first), then alphabetically by name.
-- Items whose info hasn't been cached yet fall to the bottom.
--------------------------------------------------------------------------------

function GogoLoot:SortItemIdentifiersByRarity(identifiers)
    table.sort(
        identifiers,
        function(a, b)
            local infoA = GogoLoot:SafeGetItemInfo(a)
            local infoB = GogoLoot:SafeGetItemInfo(b)
            local qualityA = infoA and infoA.quality or -1
            local qualityB = infoB and infoB.quality or -1
            if qualityA ~= qualityB then
                return qualityA > qualityB
            end
            local nameA = infoA and infoA.name or ""
            local nameB = infoB and infoB.name or ""
            if nameA == "" and nameB == "" then
                return a < b
            end
            if nameA == "" then
                return false
            end
            if nameB == "" then
                return true
            end
            return nameA < nameB
        end
    )
end

--------------------------------------------------------------------------------
-- Initialization & Addon Setup
--------------------------------------------------------------------------------

local function MigrateIgnoreLists()
    if GogoLootDB.ignoredItemsSolo then
        for identifier, value in pairs(GogoLootDB.ignoredItemsSolo) do
            if value == true then
                GogoLootDB.ignoredItemsSolo[identifier] = GogoLoot.MANUAL
            end
        end
    end
end

-- Migrate old combined trade condition values into the new two-key system
local function MigrateTradeAnnounceConfig()
    local oldCondition = GogoLootDB.announceTradeCondition
    if oldCondition == "group" or oldCondition == "group_ml" then
        GogoLootDB.announceTradeCondition = "party_or_raid"
        if not GogoLootDB.announceTradeOutput then
            GogoLootDB.announceTradeOutput = "group"
        end
    end
end

local function InitializeSavedVariables()
    -- Migration from legacy SavedVariables name
    if GogoLoot_Configuration and not GogoLootDB then
        GogoLootDB = GogoLoot_Configuration
    end
    GogoLoot_Configuration = nil

    if not GogoLootDB then
        GogoLootDB = {}
    end

    -- Force a full reset when the config version is outdated or missing
    local savedVersion = GogoLootDB.configVersion
    if savedVersion ~= GogoLoot.CONFIG_VERSION then
        local isUpgrade = (next(GogoLootDB) ~= nil)
        GogoLoot:ResetAllSettings()

        if isUpgrade then
            C_Timer.After(
                5,
                function()
                    GogoLoot:PrintMessage(L["MSG_SETTINGS_RESET_UPDATE"])
                end
            )
        end

        return
    end

    -- Legacy cleanup: globalEnable was removed in a prior version.
    GogoLootDB.globalEnable = nil

    -- Additive merge: apply any defaults missing from the saved table
    -- (happens when new options ship within the same config version).
    for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
        if GogoLootDB[configurationKey] == nil then
            CopyDefault(GogoLootDB, configurationKey, defaultValue)
        end
    end

    if next(GogoLootDB.ignoredItemsMaster) == nil then
        GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
    end
    if next(GogoLootDB.ignoredItemsSolo) == nil then
        GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
    end

    MigrateIgnoreLists()
    MigrateTradeAnnounceConfig()
end

local function CheckForConflictingAddons()
    local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    for _, addonName in ipairs(GogoLoot.conflictingAddonNames) do
        if IsAddOnLoaded(addonName) then
            C_Timer.After(
                5,
                function()
                    GogoLoot:PrintMessage(L["MSG_CONFLICT_DETECTED"])
                    GogoLoot:PrintMessage(string.format(L["MSG_CONFLICT_ADDON"], addonName))
                end
            )
            return
        end
    end
end

local function CheckAutoLootEnabled()
    local autoLootEnabled = GetCVar("autoLootDefault")
    if autoLootEnabled ~= "1" then
        SetCVar("autoLootDefault", "1")
        GogoLoot:PrintMessage(L["MSG_AUTO_LOOT_ENABLED"])
    end
end

--------------------------------------------------------------------------------
-- Event Dispatcher
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame", "GogoLootEventFrame", UIParent)
GogoLoot.eventHandlers = {}

function GogoLoot:RegisterModuleEvent(eventName, handlerFunction)
    if not GogoLoot.eventHandlers[eventName] then
        GogoLoot.eventHandlers[eventName] = {}
        eventFrame:RegisterEvent(eventName)
    end
    table.insert(GogoLoot.eventHandlers[eventName], handlerFunction)
end

eventFrame:SetScript(
    "OnEvent",
    function(self, eventName, ...)
        local handlers = GogoLoot.eventHandlers[eventName]
        if handlers then
            for _, handlerFunction in ipairs(handlers) do
                handlerFunction(eventName, ...)
            end
        end
    end
)

local function OnAddonLoaded(eventName, loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then
        return
    end
    InitializeSavedVariables()
    CheckForConflictingAddons()
    if GogoLoot.InitializeOptions then
        GogoLoot:InitializeOptions()
    end
end

GogoLoot:RegisterModuleEvent("ADDON_LOADED", OnAddonLoaded)

local hasCheckedAutoLoot = false
GogoLoot:RegisterModuleEvent(
    "PLAYER_ENTERING_WORLD",
    function()
        if not hasCheckedAutoLoot then
            hasCheckedAutoLoot = true
            C_Timer.After(3, CheckAutoLootEnabled)
        end
    end
)

SLASH_GOGOLOOT1 = "/gl"
SLASH_GOGOLOOT2 = "/gogoloot"
SlashCmdList["GOGOLOOT"] = function(inputText)
    GogoLoot:HandleSlashCommand(inputText)
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

function GogoLoot:PrintMessage(text)
    print(
        GogoLoot:GetColor("INFO") ..
            "GogoLoot" ..
                "|r " .. GogoLoot:GetColor("SEP") .. "//" .. "|r " .. GogoLoot:GetColor("TEXT") .. text .. "|r"
    )
end

function GogoLoot:DebugPrint(...)
    if GogoLootDB and GogoLootDB.debugMode then
        print(GogoLoot:GetColor("MUTED") .. "[GogoLoot Debug]|r", ...)
    end
end

--------------------------------------------------------------------------------
-- Tooltip Helpers
-- Thin wrappers around GameTooltip:AddLine / AddDoubleLine that accept color
-- keys from GogoLoot.COLORS_RGB, so tooltip code doesn't repeat RGB literals.
-- Pass nil for colorKey to use the default text color.
--------------------------------------------------------------------------------

function GogoLoot:AddTooltipLine(tooltip, text, colorKey, wrap)
    local r, g, b = GogoLoot:GetColorRGB(colorKey or "TEXT")
    tooltip:AddLine(text, r, g, b, wrap)
end

function GogoLoot:AddTooltipDoubleLine(tooltip, leftText, rightText, leftColorKey, rightColorKey)
    local lr, lg, lb = GogoLoot:GetColorRGB(leftColorKey or "TEXT")
    local rr, rg, rb = GogoLoot:GetColorRGB(rightColorKey or "TEXT")
    tooltip:AddDoubleLine(leftText, rightText, lr, lg, lb, rr, rg, rb)
end

--------------------------------------------------------------------------------
-- Name / Text Helpers
--------------------------------------------------------------------------------

function GogoLoot:GetCleanUnitName(unitIdentifier)
    local fullName = UnitName(unitIdentifier)
    if not fullName then
        return nil
    end
    local dashPosition = string.find(fullName, "-")
    if dashPosition then
        fullName = string.sub(fullName, 1, dashPosition - 1)
    end
    return fullName
end

function GogoLoot:GetLowercaseUnitName(unitIdentifier)
    local cleanName = self:GetCleanUnitName(unitIdentifier)
    return cleanName and strlower(cleanName) or nil
end

function GogoLoot:CapitalizeFirstLetter(text)
    if not text or text == "" then
        return text
    end
    return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

function GogoLoot:ParseItemLink(itemLink)
    if not itemLink then
        return nil
    end
    local matchResults = {string.find(itemLink, GogoLoot.ITEM_LINK_PATTERN)}
    if not matchResults[1] then
        return nil
    end

    return {
        itemIdentifier = tonumber(matchResults[5]),
        itemName = matchResults[16]
    }
end

function GogoLoot:SafeGetItemInfo(itemIdentifierOrLink)
    if not itemIdentifierOrLink then
        return nil
    end
    local itemName, itemLink, itemQuality, _, _, _, _, _, _, _, _, classId, subclassId, bindType =
        GetItemInfo(itemIdentifierOrLink)
    if not itemName then
        return nil
    end

    return {
        name = itemName,
        link = itemLink,
        quality = itemQuality,
        classId = classId,
        subclassId = subclassId,
        bindType = bindType
    }
end

function GogoLoot:GetGroupChatChannel()
    if UnitInRaid("player") then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return "SAY"
    end
end

function GogoLoot:GetGroupOrWhisperChannel(targetPlayerName)
    if IsInGroup() then
        return GogoLoot:GetGroupChatChannel(), nil
    else
        return "WHISPER", targetPlayerName
    end
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
    if not itemIdentifier then
        return true
    end
    if checkMasterList and GogoLootDB.ignoredItemsMaster[itemIdentifier] then
        return true
    end
    if checkSoloList and GogoLootDB.ignoredItemsSolo[itemIdentifier] then
        return true
    end
    return false
end

function GogoLoot:GetItemRollOverride(itemIdentifier)
    if not itemIdentifier then
        return nil
    end
    local override = GogoLootDB.ignoredItemsSolo[itemIdentifier]
    if not override then
        return nil
    end
    return override
end

function GogoLoot:ShouldSkipItemByType(itemInformation)
    if not itemInformation then
        return true
    end

    -- Legendaries
    if itemInformation.quality == 5 then
        return true
    end
    -- Quest Items
    if itemInformation.classId == GogoLoot.ITEM_CLASS_QUEST or itemInformation.bindType == GogoLoot.BIND_QUEST_ITEM then
        return true
    end
    -- Recipes, Books, Patterns, Plans, Schematics, Formulas (all classId 9)
    if itemInformation.classId == GogoLoot.ITEM_CLASS_RECIPE then
        return true
    end
    -- Mounts and Companion Pets
    if
        itemInformation.classId == GogoLoot.ITEM_CLASS_MISCELLANEOUS and
            (itemInformation.subclassId == GogoLoot.ITEM_SUBCLASS_COMPANION_PET or
                itemInformation.subclassId == GogoLoot.ITEM_SUBCLASS_MOUNT)
     then
        return true
    end

    return false
end