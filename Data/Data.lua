--------------------------------------------------------------------------------
-- GogoLoot Data
--------------------------------------------------------------------------------

local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

ns.isClassicEra = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
ns.isBurningCrusadeClassic = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

--------------------------------------------------------------------------------
-- Expansion Constants
--------------------------------------------------------------------------------

ns.VANILLA = 1
ns.TBC = 2
ns.WRATH = 3

if ns.isClassicEra then
    ns.currentExpansion = ns.VANILLA
elseif ns.isBurningCrusadeClassic then
    ns.currentExpansion = ns.TBC
else
    ns.currentExpansion = ns.WRATH
end

--------------------------------------------------------------------------------
-- Item Constants
--------------------------------------------------------------------------------

ns.BIND_ON_PICKUP = 1
ns.BIND_ON_EQUIP = 2
ns.BIND_ON_USE = 3
ns.BIND_QUEST_ITEM = 4

ns.ITEM_CLASS_RECIPE = 9
ns.ITEM_CLASS_QUEST = 12
ns.ITEM_CLASS_MISCELLANEOUS = 15
ns.ITEM_SUBCLASS_COMPANION_PET = 2
ns.ITEM_SUBCLASS_MOUNT = 5

ns.TRADE_ENCHANT_SLOT = 7
ns.TRADE_ITEM_SLOT_COUNT = 6

--------------------------------------------------------------------------------
-- UI Colors
--------------------------------------------------------------------------------

--[[
    Raw palette only: plain 6-char hex strings, never prefixed with |cff —
    the display prefix is prepended where the derived tables are built. The
    derived COLORS / COLORS_RGB tables and the GetColor / GetColorRGB /
    GetQualityColor accessors live in Utilities.lua.
]]

ns.RAW_UI_COLORS = {
    TITLE = "FFD100", -- Gold: Titles, Headers, Section Names
    INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
    BODY = "CCCCCC", -- Silver: Descriptions, Help Text
    TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
    ON = "33CC33", -- Green: On
    OFF = "CC3333", -- Red: Off
    SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
    MUTED = "808080" -- Dark Gray: Meta-data, Version Numbers
}

--------------------------------------------------------------------------------
-- Target Marker
--------------------------------------------------------------------------------

--[[
    Leads every message sent to other players (see Announce in
    Announcements.lua).
    One marker per add-on, chosen so GogoLoot's messages stay visually
    distinct from other Gogo1951 add-ons the player may be running.
]]

--[[
    {rt1} Star, {rt2} Circle, {rt3} Diamond, {rt4} Triangle,
    {rt5} Moon, {rt6} Square, {rt7} Cross, {rt8} Skull
]]
ns.TARGET_MARKER = "{rt4}" -- Triangle

--------------------------------------------------------------------------------
-- Chat Message Limit
--------------------------------------------------------------------------------

-- SendChatMessage rejects messages over 255 bytes (see Announcements-Trade.lua).
ns.CHAT_MESSAGE_MAX_LENGTH = 255

--------------------------------------------------------------------------------
-- Roll Constants
--------------------------------------------------------------------------------

ns.ROLL_ACTION_NEED = 1
ns.ROLL_ACTION_GREED = 2
ns.ROLL_ACTION_PASS = 0

ns.MANUAL = "manual"
ns.GREED = "greed"
ns.NEED = "need"
ns.PASS = "pass"

ns.ROLL_INDEX_MANUAL = 1
ns.ROLL_INDEX_GREED = 2
ns.ROLL_INDEX_NEED = 3
ns.ROLL_INDEX_PASS = 4

ns.ROLL_OVERRIDE_FROM_INDEX = {
    [ns.ROLL_INDEX_MANUAL] = ns.MANUAL,
    [ns.ROLL_INDEX_GREED] = ns.GREED,
    [ns.ROLL_INDEX_NEED] = ns.NEED,
    [ns.ROLL_INDEX_PASS] = ns.PASS
}

ns.ROLL_OVERRIDE_LABELS = {
    [ns.MANUAL] = ns.L["ROLL_MANUAL"],
    [ns.GREED] = ns.L["ROLL_GREED"],
    [ns.NEED] = ns.L["ROLL_NEED"],
    [ns.PASS] = ns.L["ROLL_PASS"]
}

--------------------------------------------------------------------------------
-- Quality Constants
--------------------------------------------------------------------------------

--[[
    Plain RRGGBB hex strings, matching the format used by RAW_UI_COLORS /
    COLORS. For inline-color strings ("|cffRRGGBB"), use
    ns.GetQualityColor(quality).
]]
ns.QUALITY_COLORS = {
    [0] = "9D9D9D", -- Poor (Gray)
    [1] = "FFFFFF", -- Common (White)
    [2] = "1EFF00", -- Uncommon (Green)
    [3] = "0070DD", -- Rare (Blue)
    [4] = "A335EE" -- Epic (Purple)
}

ns.rarityToConfigurationKey = {
    [0] = "poor",
    [1] = "common",
    [2] = "uncommon",
    [3] = "rare",
    [4] = "epic"
}

ns.QUALITY_DISPLAY_NAMES = {
    ["poor"] = ns.L["QUALITY_POOR"],
    ["common"] = ns.L["QUALITY_COMMON"],
    ["uncommon"] = ns.L["QUALITY_UNCOMMON"],
    ["rare"] = ns.L["QUALITY_RARE"],
    ["epic"] = ns.L["QUALITY_EPIC"]
}

--------------------------------------------------------------------------------
-- Trade Output Labels
--------------------------------------------------------------------------------

-- Maps the announceTradeOutput setting values to their display labels.
ns.TRADE_OUTPUT_LABELS = {
    ["whisper"] = ns.L["TRADE_OUTPUT_WHISPER"],
    ["group"] = ns.L["TRADE_OUTPUT_GROUP"]
}

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

--[[
    Stable identifiers for RegisterOptionsTable / NotifyChange /
    AddToBlizOptions and the custom AceGUI widget type. Never localized —
    cross-module NotifyChange calls and the Blizzard options tree reference
    them by exact string.
]]

ns.OPTIONS_REGISTRY = {
    General = ADDON_NAME,
    MasterLooter = ADDON_NAME .. "_MasterLooter",
    AutomatedRolls = ADDON_NAME .. "_AutomatedRolls",
    Announcements = ADDON_NAME .. "_Announcements",
    Profiles = ADDON_NAME .. "_Profiles",
    Diagnostics = ADDON_NAME .. "_Diagnostics"
}

ns.ITEM_LINK_WIDGET_TYPE = ADDON_NAME .. "_ItemLink"

--------------------------------------------------------------------------------
-- URL Constants
--------------------------------------------------------------------------------

ns.URL_CURSEFORGE = "https://www.curseforge.com/wow/addons/gogoloot"
ns.URL_GITHUB = "https://github.com/Gogo1951/GogoLoot"
ns.URL_DISCORD = "https://discord.gg/eh8hKq992Q"

--------------------------------------------------------------------------------
-- Minimap
--------------------------------------------------------------------------------

ns.MINIMAP_ICONS = {
    on = 134467, -- Auto-Greed On
    off = 134468 -- Auto-Greed Off
}
