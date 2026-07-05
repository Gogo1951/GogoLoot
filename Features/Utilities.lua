--------------------------------------------------------------------------------
-- GogoLoot Utilities
--------------------------------------------------------------------------------

--[[
    Stateless shared utilities used across feature modules and the options
    panels: derived color tables and accessors, tooltip line helpers,
    player-name and item-link parsing, item lookups, and small game-state
    predicates.
]]
local _, ns = ...

--------------------------------------------------------------------------------
-- Item API Compatibility
--------------------------------------------------------------------------------

--[[
    C_Item on modern clients, falling back to the legacy globals on older
    Classic builds. Exposed on the namespace for item lookups everywhere
    (the options panels' item lists and the item display helper).
]]

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant

ns.GetItemInfo = GetItemInfo
ns.GetItemInfoInstant = GetItemInfoInstant

--------------------------------------------------------------------------------
-- UI Colors
--------------------------------------------------------------------------------

--[[
    Built from the raw hex palettes in Data.lua and exposed in two forms:
      * ns.COLORS[key] -> "|cffRRGGBB" (for inline chat/string use)
      * ns.COLORS_RGB[key] -> {r, g, b} (for tooltip/texture APIs)
    Consumers should prefer ns.GetColor(key) / ns.GetColorRGB(key)
    over indexing the tables directly. These are dot functions (no self),
    so every file aliases them once — local GetColor = ns.GetColor — and
    calls GetColor("KEY"); see the guide's GetColor Accessor section.
]]

local function HexToNormalizedRGB(hex)
    local r = tonumber(string.sub(hex, 1, 2), 16) / 255
    local g = tonumber(string.sub(hex, 3, 4), 16) / 255
    local b = tonumber(string.sub(hex, 5, 6), 16) / 255
    return r, g, b
end

ns.COLORS = {}
-- COLORS_RGB extends the guide's string-only COLORS form: tooltip/texture APIs take r, g, b numbers.
ns.COLORS_RGB = {}

for colorKey, hexValue in pairs(ns.RAW_UI_COLORS) do
    ns.COLORS[colorKey] = "|cff" .. hexValue
    local r, g, b = HexToNormalizedRGB(hexValue)
    ns.COLORS_RGB[colorKey] = {r = r, g = g, b = b}
end

function ns.GetColor(key)
    return ns.COLORS[key] or ns.COLORS.TEXT
end

function ns.GetColorRGB(key)
    local rgb = ns.COLORS_RGB[key] or ns.COLORS_RGB.TEXT
    return rgb.r, rgb.g, rgb.b
end

function ns.GetQualityColor(quality)
    local hex = ns.QUALITY_COLORS[quality] or ns.QUALITY_COLORS[1]
    return "|cff" .. hex
end

local GetColorRGB = ns.GetColorRGB

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

--[[
    Accepts a numeric item ID string or a full item link; returns the numeric
    item ID or nil. Shared by the Options panels that let users add items.
]]

function ns:ParseItemInput(rawInput)
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
--------------------------------------------------------------------------------

--[[
    Sorts in place by rarity (highest first), then alphabetically by name.
    Items whose info hasn't been cached yet fall to the bottom.
]]

function ns:SortItemIdentifiersByRarity(identifiers)
    table.sort(
        identifiers,
        function(a, b)
            local infoA = ns:SafeGetItemInfo(a)
            local infoB = ns:SafeGetItemInfo(b)
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

--[[
    Pick the API by availability, not by truthy result: a
    `(modern call) or (legacy call)` chain falls through to the legacy
    check whenever the modern API returns false (auto-loot disabled),
    silently reading the wrong source. Shared with Speedy-Loot.lua.
]]
function ns:IsAutoLootCVarEnabled()
    if C_CVar and C_CVar.GetCVarBool then
        return C_CVar.GetCVarBool("autoLootDefault")
    end
    return GetCVar("autoLootDefault") == "1"
end

--------------------------------------------------------------------------------
-- Tooltip Helpers
--------------------------------------------------------------------------------

--[[
    Thin wrappers around GameTooltip:AddLine / AddDoubleLine that accept color
    keys from ns.COLORS_RGB, so tooltip code doesn't repeat RGB literals.
    Pass nil for colorKey to use the default text color.
]]

function ns:AddTooltipLine(tooltip, text, colorKey, wrap)
    local r, g, b = GetColorRGB(colorKey or "TEXT")
    tooltip:AddLine(text, r, g, b, wrap)
end

function ns:AddTooltipDoubleLine(tooltip, leftText, rightText, leftColorKey, rightColorKey)
    local leftRed, leftGreen, leftBlue = GetColorRGB(leftColorKey or "TEXT")
    local rightRed, rightGreen, rightBlue = GetColorRGB(rightColorKey or "TEXT")
    tooltip:AddDoubleLine(leftText, rightText, leftRed, leftGreen, leftBlue, rightRed, rightGreen, rightBlue)
end

--------------------------------------------------------------------------------
-- Name / Text Helpers
--------------------------------------------------------------------------------

--[[
    Canonical key for player-name comparisons: realm suffix stripped, then
    lowercased. Cross-realm members appear as "Name-Realm" in some APIs
    (GetMasterLootCandidate) and as plain "Name" in others (UnitName), so
    destinations, candidate-map lookups, and group-member lookups must all
    pass through this one helper to compare equal.
]]
local function StripRealmSuffix(fullName)
    if not fullName then
        return nil
    end
    local dashPosition = string.find(fullName, "-")
    if dashPosition then
        return string.sub(fullName, 1, dashPosition - 1)
    end
    return fullName
end

function ns:NormalizePlayerName(playerName)
    if not playerName or playerName == "" then
        return nil
    end
    return strlower(StripRealmSuffix(playerName))
end

function ns:GetCleanUnitName(unitIdentifier)
    return StripRealmSuffix((UnitName(unitIdentifier)))
end

function ns:GetLowercaseUnitName(unitIdentifier)
    return self:NormalizePlayerName((UnitName(unitIdentifier)))
end

function ns:CapitalizeFirstLetter(text)
    if not text or text == "" then
        return text
    end
    return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

function ns:ParseItemLink(itemLink)
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

function ns:SafeGetItemInfo(itemIdentifierOrLink)
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

function ns:AreWeMasterLooter()
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

function ns:IsInBindOnPickupTradeInstance()
    local _, instanceType = GetInstanceInfo()
    return (instanceType == "raid" or instanceType == "party")
end

function ns:GetItemRollOverride(itemIdentifier)
    if not itemIdentifier then
        return nil
    end
    local override = ns.db.profile.ignoredItemsSolo[itemIdentifier]
    if not override then
        return nil
    end
    return override
end

function ns:ShouldSkipItemByType(itemInformation)
    if not itemInformation then
        return true
    end

    -- Legendaries
    if itemInformation.quality == 5 then
        return true
    end
    -- Quest Items
    if itemInformation.classId == ns.ITEM_CLASS_QUEST or itemInformation.bindType == ns.BIND_QUEST_ITEM then
        return true
    end
    -- Recipes, Books, Patterns, Plans, Schematics, Formulas (all classId 9)
    if itemInformation.classId == ns.ITEM_CLASS_RECIPE then
        return true
    end
    -- Mounts and Companion Pets
    if
        itemInformation.classId == ns.ITEM_CLASS_MISCELLANEOUS and
            (itemInformation.subclassId == ns.ITEM_SUBCLASS_COMPANION_PET or
                itemInformation.subclassId == ns.ITEM_SUBCLASS_MOUNT)
     then
        return true
    end

    return false
end