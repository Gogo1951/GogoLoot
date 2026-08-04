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

--[[
    Prefer the client's own symbol, fall back to the numeric value. The numbers
    are correct on every flavor we target and are what actually resolves on
    Classic Era, where the Enum tables are largely absent — but reading the
    symbol first means a future renumbering doesn't silently reclassify items.
]]

ns.BIND_ON_PICKUP = (Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire) or 1
ns.BIND_ON_EQUIP = (Enum and Enum.ItemBind and Enum.ItemBind.OnEquip) or 2
ns.BIND_ON_USE = (Enum and Enum.ItemBind and Enum.ItemBind.OnUse) or 3
ns.BIND_QUEST_ITEM = (Enum and Enum.ItemBind and Enum.ItemBind.Quest) or 4

ns.ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE or (Enum and Enum.ItemClass and Enum.ItemClass.Recipe) or 9
ns.ITEM_CLASS_QUEST = LE_ITEM_CLASS_QUESTITEM or (Enum and Enum.ItemClass and Enum.ItemClass.Questitem) or 12
ns.ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS
	or (Enum and Enum.ItemClass and Enum.ItemClass.Miscellaneous)
	or 15
ns.ITEM_SUBCLASS_COMPANION_PET = (
	Enum
	and Enum.ItemMiscellaneousSubclass
	and Enum.ItemMiscellaneousSubclass.CompanionPet
) or 2
ns.ITEM_SUBCLASS_MOUNT = (Enum and Enum.ItemMiscellaneousSubclass and Enum.ItemMiscellaneousSubclass.Mount) or 5

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

ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names, Field Titles
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
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
	[ns.ROLL_INDEX_PASS] = ns.PASS,
}

ns.ROLL_OVERRIDE_LABELS = {
	[ns.MANUAL] = ns.L["ROLL_MANUAL"],
	[ns.GREED] = ns.L["ROLL_GREED"],
	[ns.NEED] = ns.L["ROLL_NEED"],
	[ns.PASS] = ns.L["ROLL_PASS"],
}

--[[
    Display order for every roll-action dropdown, passed to AceConfig as
    `sorting`. Without it AceConfigDialog sorts the labels alphabetically,
    which reorders itself per locale; this keeps the four actions in one
    fixed, least-to-most aggressive order everywhere they appear.
]]
ns.ROLL_OVERRIDE_ORDER = { ns.MANUAL, ns.PASS, ns.GREED, ns.NEED }

--------------------------------------------------------------------------------
-- Options Layout Widths
--------------------------------------------------------------------------------

--[[
    AceConfig draws a control's own `name` above it, which spends a line per
    setting. Every labeled control in the add-on instead pairs an unlabeled
    control with a description cell beside it (ns.OptionsRowLabel), so the label
    sits to its left and the setting is one line.

    Every such row — a plain label + control, an item row, a Thresholds row —
    spends OPTIONS_ROW_WIDTH in total, so all of them share a right edge no
    matter which panel they are on. Tune these here and nowhere else.
]]

ns.OPTIONS_ROW_WIDTH = 2.6
ns.OPTIONS_LABEL_WIDTH = 1.3
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH

-- Roll-action dropdowns: the Thresholds rows and the Custom Roll List column.
ns.ROLL_ACTION_DROPDOWN_WIDTH = 0.7

-- The item lists' remove column, sized to its icon rather than a caption.
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25

--------------------------------------------------------------------------------
-- Quality Constants
--------------------------------------------------------------------------------

--[[
    Plain RRGGBB hex strings, matching the format used by PALETTE /
    COLORS. For inline-color strings ("|cffRRGGBB"), use
    ns.GetQualityColor(quality).
]]
ns.QUALITY_COLORS = {
	[0] = "9D9D9D", -- Poor (Gray)
	[1] = "FFFFFF", -- Common (White)
	[2] = "1EFF00", -- Uncommon (Green)
	[3] = "0070DD", -- Rare (Blue)
	[4] = "A335EE", -- Epic (Purple)
}

ns.rarityToConfigurationKey = {
	[0] = "poor",
	[1] = "common",
	[2] = "uncommon",
	[3] = "rare",
	[4] = "epic",
}

ns.QUALITY_DISPLAY_NAMES = {
	["poor"] = ns.L["QUALITY_POOR"],
	["common"] = ns.L["QUALITY_COMMON"],
	["uncommon"] = ns.L["QUALITY_UNCOMMON"],
	["rare"] = ns.L["QUALITY_RARE"],
	["epic"] = ns.L["QUALITY_EPIC"],
}

--------------------------------------------------------------------------------
-- Trade Output Labels
--------------------------------------------------------------------------------

-- Maps the announceTradeOutput setting values to their display labels.
ns.TRADE_OUTPUT_LABELS = {
	["whisper"] = ns.L["TRADE_OUTPUT_WHISPER"],
	["group"] = ns.L["TRADE_OUTPUT_GROUP"],
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
	-- Registered but never added to the Blizzard tree: it opens as its own window.
	MasterLooterPopup = ADDON_NAME .. "_MasterLooterPopup",
	AutomatedRolls = ADDON_NAME .. "_AutomatedRolls",
	Announcements = ADDON_NAME .. "_Announcements",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

ns.ITEM_LINK_WIDGET_TYPE = ADDON_NAME .. "_ItemLink"

--------------------------------------------------------------------------------
-- URL Constants
--------------------------------------------------------------------------------

ns.URL_CURSEFORGE = "https://www.curseforge.com/wow/addons/gogoloot"
ns.URL_GITHUB = "https://github.com/Gogo1951/GogoLoot"
ns.URL_DISCORD = "https://discord.gg/eh8hKq992Q"
ns.URL_WAGO = "https://addons.wago.io/addons/gogoloot"

--------------------------------------------------------------------------------
-- Minimap
--------------------------------------------------------------------------------

ns.MINIMAP_ICONS = {
	on = 134467, -- Automated Rolls On
	off = 134468, -- Automated Rolls Off
}
