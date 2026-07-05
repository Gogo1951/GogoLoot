--------------------------------------------------------------------------------
-- GogoLoot Core & Utilities
--------------------------------------------------------------------------------
local ADDON_NAME = "GogoLoot"
local _, ns = ...
local L = ns.L
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
--
-- LibDBIcon stores its minimap position inside GogoLootDB.minimap; we preserve
-- that table across resets so the user's minimap button doesn't jump back to
-- its default angle every time they reset settings (or upgrade).
--------------------------------------------------------------------------------

function GogoLoot:ResetAllSettings()
    local preservedMinimap = GogoLootDB and GogoLootDB.minimap

    for existingKey in pairs(GogoLootDB) do
        GogoLootDB[existingKey] = nil
    end

    for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
        CopyDefault(GogoLootDB, configurationKey, defaultValue)
    end

    GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
    GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
    GogoLootDB.configVersion = GogoLoot.CONFIG_VERSION

    if preservedMinimap then
        GogoLootDB.minimap = preservedMinimap
    end
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

local function InitializeSavedVariables()
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
                handlerFunction(...)
            end
        end
    end
)

local function OnAddonLoaded(loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then
        return
    end
    InitializeSavedVariables()
    if GogoLoot.InitMinimap then
        GogoLoot:InitMinimap()
    end
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

--------------------------------------------------------------------------------
-- Messaging
-- PrintMessage and Announce are siblings:
--   * PrintMessage writes to the player's local chat frame (informational).
--   * Announce sends a chat message to other players via SendChatMessage,
--     pulling the body template from L[formatKey] and wrapping it in the
--     localized MSG_PREFIX / MSG_SUFFIX. All cross-player chat output should
--     route through Announce so prefix/suffix and locale are handled in one
--     place. Locales can override MSG_PREFIX (e.g. the {rt4} raid target
--     marker) and MSG_SUFFIX without touching every call site.
--
-- Announce signature:
--   channel    - "PARTY", "RAID", "SAY", "WHISPER", etc.
--   target     - whisper target name (or nil for non-whisper channels)
--   formatKey  - L[] key for the format string (e.g. "MSG_LOOT_ANNOUNCE")
--   ...        - format arguments substituted via string.format
--------------------------------------------------------------------------------

function GogoLoot:PrintMessage(text)
    print(
        GogoLoot:GetColor("INFO") ..
            "GogoLoot" ..
                "|r " .. GogoLoot:GetColor("SEP") .. "//" .. "|r " .. GogoLoot:GetColor("TEXT") .. text .. "|r"
    )
end

function GogoLoot:Announce(channel, target, formatKey, ...)
    if not channel then
        return
    end
    local template = L[formatKey]
    if not template then
        return
    end
    local body = string.format(template, ...)
    local message = L["MSG_PREFIX"] .. body .. L["MSG_SUFFIX"]
    SendChatMessage(message, channel, nil, target)
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
    local itemIdentifier, itemName = string.match(itemLink, "item:(%d+).-%[([^%]]+)%]")
    if not itemIdentifier then
        return nil
    end
    return {
        itemIdentifier = tonumber(itemIdentifier),
        itemName = itemName
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
