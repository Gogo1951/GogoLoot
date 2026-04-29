--------------------------------------------------------------------------------
-- GogoLoot Data
--------------------------------------------------------------------------------
GogoLoot = GogoLoot or {}

local _, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale("GogoLoot")

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant

GogoLoot.GetItemInfo = GetItemInfo
GogoLoot.GetItemInfoInstant = GetItemInfoInstant

GogoLoot.isClassicEra = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
GogoLoot.isBurningCrusadeClassic = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

--------------------------------------------------------------------------------
-- Expansion Constants
--------------------------------------------------------------------------------

GogoLoot.VANILLA = 1
GogoLoot.TBC = 2
GogoLoot.WRATH = 3

if GogoLoot.isClassicEra then
    GogoLoot.currentExpansion = GogoLoot.VANILLA
elseif GogoLoot.isBurningCrusadeClassic then
    GogoLoot.currentExpansion = GogoLoot.TBC
else
    GogoLoot.currentExpansion = GogoLoot.WRATH
end

--------------------------------------------------------------------------------
-- Item Constants
--------------------------------------------------------------------------------

GogoLoot.BIND_ON_PICKUP = 1
GogoLoot.BIND_ON_EQUIP = 2
GogoLoot.BIND_ON_USE = 3
GogoLoot.BIND_QUEST_ITEM = 4

GogoLoot.ITEM_CLASS_RECIPE = 9
GogoLoot.ITEM_CLASS_QUEST = 12
GogoLoot.ITEM_CLASS_MISCELLANEOUS = 15
GogoLoot.ITEM_SUBCLASS_COMPANION_PET = 2
GogoLoot.ITEM_SUBCLASS_MOUNT = 5

GogoLoot.TRADE_ENCHANT_SLOT = 7
GogoLoot.TRADE_ITEM_SLOT_COUNT = 6

--------------------------------------------------------------------------------
-- UI Colors
-- Single source of truth: each color is defined once as a 6-char hex string,
-- then exposed in two forms:
--   * GogoLoot.COLORS[key]     -> "|cffRRGGBB"  (for inline chat/string use)
--   * GogoLoot.COLORS_RGB[key] -> {r, g, b}     (for tooltip/texture APIs)
-- Consumers should prefer GogoLoot:GetColor(key) / GogoLoot:GetColorRGB(key)
-- over indexing the tables directly.
--------------------------------------------------------------------------------

local RAW_UI_COLORS = {
    TITLE = "FFD100",
    INFO = "00BBFF",
    DESC = "CCCCCC",
    TEXT = "FFFFFF",
    SUCCESS = "33CC33",
    DISABLED = "CC3333",
    SEP = "AAAAAA",
    MUTED = "808080"
}

local function HexToNormalizedRGB(hex)
    local r = tonumber(string.sub(hex, 1, 2), 16) / 255
    local g = tonumber(string.sub(hex, 3, 4), 16) / 255
    local b = tonumber(string.sub(hex, 5, 6), 16) / 255
    return r, g, b
end

GogoLoot.COLORS = {}
GogoLoot.COLORS_RGB = {}

for colorKey, hexValue in pairs(RAW_UI_COLORS) do
    GogoLoot.COLORS[colorKey] = "|cff" .. hexValue
    local r, g, b = HexToNormalizedRGB(hexValue)
    GogoLoot.COLORS_RGB[colorKey] = {r = r, g = g, b = b}
end

function GogoLoot:GetColor(key)
    return GogoLoot.COLORS[key] or GogoLoot.COLORS.TEXT
end

function GogoLoot:GetColorRGB(key)
    local rgb = GogoLoot.COLORS_RGB[key] or GogoLoot.COLORS_RGB.TEXT
    return rgb.r, rgb.g, rgb.b
end

--------------------------------------------------------------------------------
-- Roll Constants
--------------------------------------------------------------------------------

GogoLoot.ROLL_ACTION_NEED = 1
GogoLoot.ROLL_ACTION_GREED = 2
GogoLoot.ROLL_ACTION_PASS = 0

GogoLoot.MANUAL = "manual"
GogoLoot.GREED = "greed"
GogoLoot.NEED = "need"
GogoLoot.PASS = "pass"

GogoLoot.R_MANUAL = 1
GogoLoot.R_GREED = 2
GogoLoot.R_NEED = 3
GogoLoot.R_PASS = 4

GogoLoot.ROLL_OVERRIDE_FROM_INDEX = {
    [GogoLoot.R_MANUAL] = GogoLoot.MANUAL,
    [GogoLoot.R_GREED] = GogoLoot.GREED,
    [GogoLoot.R_NEED] = GogoLoot.NEED,
    [GogoLoot.R_PASS] = GogoLoot.PASS
}

GogoLoot.ROLL_OVERRIDE_LABELS = {
    [GogoLoot.MANUAL] = ns.L["ROLL_MANUAL"],
    [GogoLoot.GREED] = ns.L["ROLL_GREED"],
    [GogoLoot.NEED] = ns.L["ROLL_NEED"],
    [GogoLoot.PASS] = ns.L["ROLL_PASS"]
}

--------------------------------------------------------------------------------
-- Quality Constants
--------------------------------------------------------------------------------

-- Plain RRGGBB hex strings, matching the format used by RAW_UI_COLORS / COLORS.
-- For inline-color strings ("|cffRRGGBB"), use GogoLoot:GetQualityColor(quality).
GogoLoot.QUALITY_COLORS = {
    [0] = "9D9D9D", -- Poor (Gray)
    [1] = "FFFFFF", -- Common (White)
    [2] = "1EFF00", -- Uncommon (Green)
    [3] = "0070DD", -- Rare (Blue)
    [4] = "A335EE" -- Epic (Purple)
}

function GogoLoot:GetQualityColor(quality)
    local hex = GogoLoot.QUALITY_COLORS[quality] or GogoLoot.QUALITY_COLORS[1]
    return "|cff" .. hex
end

GogoLoot.rarityToConfigurationKey = {
    [0] = "poor",
    [1] = "common",
    [2] = "uncommon",
    [3] = "rare",
    [4] = "epic"
}

GogoLoot.QUALITY_DISPLAY_NAMES = {
    ["poor"] = ns.L["QUALITY_POOR"],
    ["common"] = ns.L["QUALITY_COMMON"],
    ["uncommon"] = ns.L["QUALITY_UNCOMMON"],
    ["rare"] = ns.L["QUALITY_RARE"],
    ["epic"] = ns.L["QUALITY_EPIC"]
}

--------------------------------------------------------------------------------
-- URL Constants
--------------------------------------------------------------------------------

GogoLoot.URL_CURSEFORGE = "https://www.curseforge.com/wow/addons/gogoloot"
GogoLoot.URL_GITHUB = "https://github.com/Gogo1951/GogoLoot"
GogoLoot.URL_DISCORD = "https://discord.gg/eh8hKq992Q"

--------------------------------------------------------------------------------
-- Default Custom Roll / Ignore Lists
-- Format: [itemId] = {expansion, rollOverride}
-- Expansion: VANILLA=1, TBC=2, WRATH=3
-- Roll Override (solo only): R_MANUAL=1, R_GREED=2, R_NEED=3, R_PASS=4
--------------------------------------------------------------------------------

-- NOTE: Large arrays (20+ entries). Existing data preserved as-is per style guide.

GogoLoot.DEFAULT_IGNORE_LIST_SOLO = {
    [19706] = {1, 3}, -- Bloodscalp Coin
    [19708] = {1, 3}, -- Blue Hakkari Bijou
    [20864] = {1, 3}, -- Bone Scarab
    [19713] = {1, 3}, -- Bronze Hakkari Bijou
    [20861] = {1, 3}, -- Bronze Scarab
    [20863] = {1, 3}, -- Clay Scarab
    [12843] = {1, 1}, -- Corruptor's Scourgestone
    [20862] = {1, 3}, -- Crystal Scarab
    [20520] = {1, 1}, -- Dark Rune
    [12662] = {1, 1}, -- Demonic Rune
    [22682] = {1, 1}, -- Frozen Rune
    [19715] = {1, 3}, -- Gold Hakkari Bijou
    [20859] = {1, 3}, -- Gold Scarab
    [19711] = {1, 3}, -- Green Hakkari Bijou
    [19701] = {1, 3}, -- Gurubashi Coin
    [19700] = {1, 3}, -- Hakkari Coin
    [20876] = {1, 1}, -- Idol of Death
    [20879] = {1, 1}, -- Idol of Life
    [20875] = {1, 1}, -- Idol of Night
    [20878] = {1, 1}, -- Idol of Rebirth
    [20881] = {1, 1}, -- Idol of Strife
    [20877] = {1, 1}, -- Idol of the Sage
    [20874] = {1, 1}, -- Idol of the Sun
    [20882] = {1, 1}, -- Idol of War
    [20865] = {1, 3}, -- Ivory Scarab
    [11733] = {1, 1}, -- Libram of Constitution
    [18333] = {1, 1}, -- Libram of Focus
    [18334] = {1, 1}, -- Libram of Protection
    [18332] = {1, 1}, -- Libram of Rapidity
    [11736] = {1, 1}, -- Libram of Resilience
    [11732] = {1, 1}, -- Libram of Rumination
    [11734] = {1, 1}, -- Libram of Tenacity
    [11737] = {1, 1}, -- Libram of Voracity
    [28065] = {1, 1}, -- Libram of Wracking
    [19710] = {1, 3}, -- Orange Hakkari Bijou
    [19813] = {1, 1}, -- Punctured Voodoo Doll
    [19819] = {1, 1}, -- Punctured Voodoo Doll
    [19820] = {1, 1}, -- Punctured Voodoo Doll
    [19816] = {1, 1}, -- Punctured Voodoo Doll
    [19818] = {1, 1}, -- Punctured Voodoo Doll
    [19821] = {1, 1}, -- Punctured Voodoo Doll
    [19815] = {1, 1}, -- Punctured Voodoo Doll
    [19814] = {1, 1}, -- Punctured Voodoo Doll
    [19817] = {1, 1}, -- Punctured Voodoo Doll
    [19712] = {1, 3}, -- Purple Hakkari Bijou
    [19699] = {1, 3}, -- Razzashi Coin
    [19707] = {1, 3}, -- Red Hakkari Bijou
    [12811] = {1, 1}, -- Righteous Orb
    [19704] = {1, 3}, -- Sandfury Coin
    [19714] = {1, 3}, -- Silver Hakkari Bijou
    [20860] = {1, 3}, -- Silver Scarab
    [19705] = {1, 3}, -- Skullsplitter Coin
    [20858] = {1, 3}, -- Stone Scarab
    [4500] = {1, 1}, -- Traveler's Backpack
    [19702] = {1, 3}, -- Vilebranch Coin
    [19703] = {1, 3}, -- Witherbark Coin
    [23055] = {1, 1}, -- Word of Thawing
    [19709] = {1, 3}, -- Yellow Hakkari Bijou
    [19698] = {1, 3}, -- Zulian Coin
    [29739] = {2, 1}, -- Arcane Tome
    [32227] = {2, 1}, -- Crimson Spinel
    [23440] = {2, 1}, -- Dawnstone
    [32228] = {2, 1}, -- Empyrean Sapphire
    [29740] = {2, 1}, -- Fel Armament
    [32229] = {2, 1}, -- Lionseye
    [23436] = {2, 1}, -- Living Ruby
    [30183] = {2, 1}, -- Nether Vortex
    [23441] = {2, 1}, -- Nightseye
    [23439] = {2, 1}, -- Noble Topaz
    [22451] = {2, 1}, -- Primal Air
    [22452] = {2, 1}, -- Primal Earth
    [21884] = {2, 1}, -- Primal Fire
    [21886] = {2, 1}, -- Primal Life
    [22457] = {2, 1}, -- Primal Mana
    [23572] = {2, 1}, -- Primal Nether
    [22456] = {2, 1}, -- Primal Shadow
    [21885] = {2, 1}, -- Primal Water
    [32231] = {2, 1}, -- Pyrestone
    [32249] = {2, 1}, -- Seaspray Emerald
    [32230] = {2, 1}, -- Shadowsong Amethyst
    [23438] = {2, 1}, -- Star of Elune
    [23437] = {2, 1} -- Talasite
}

GogoLoot.DEFAULT_IGNORE_LIST_MASTER = {
    -- Vanilla: BoP Crafting Materials
    [12662] = {1}, -- Demonic Rune
    [20520] = {1}, -- Dark Rune
    -- Vanilla: Bags
    [17966] = {1}, -- Onyxia Hide Backpack
    [19914] = {1}, -- Panther Hide Sack
    -- TBC: BoP Crafting Materials
    [23572] = {2}, -- Primal Nether
    [30183] = {2}, -- Nether Vortex
    [32428] = {2}, -- Heart of Darkness
    [34664] = {2}, -- Sunmote
    -- TBC: Bags
    [34845] = {2}, -- Pit Lord's Satchel
    [34846] = {2} -- Black Sack of Gems
}

--------------------------------------------------------------------------------
-- Configuration Version
-- Bump this to force a full reset on next load.
--------------------------------------------------------------------------------
GogoLoot.CONFIG_VERSION = 4

--------------------------------------------------------------------------------
-- Minimap
--------------------------------------------------------------------------------

GogoLoot.MINIMAP_ICONS = {
    on = 134467,  -- Auto-Greed On
    off = 134468  -- Auto-Greed Off
}

--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------

GogoLoot.DEFAULT_CONFIGURATION = {
    speedyLoot = true,
    announceDestinations = true,
    announceMasterLootAuto = true,
    announceMasterLootAutoThreshold = 3,
    announceMasterLootManual = true,
    announceMasterLootManualThreshold = 1,
    announceTrade = true,
    announceTradeCondition = "always",
    announceTradeOutput = "whisper",
    autoGreed = false,
    autoGreedThreshold = 2,
    autoMasterLoot = true,
    autoMasterLootOutsideInstances = false,
    destinations = {
        poor = "self",
        common = "self",
        uncommon = "self",
        rare = "self",
        epic = "self"
    },
    ignoredItemsMaster = {},
    ignoredItemsSolo = {},
    minimap = {}
}