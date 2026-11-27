--------------------------------------------------------------------------------
-- GogoLoot Data
--------------------------------------------------------------------------------

local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
-- Identity
--------------------------------------------------------------------------------

ns.SAVED_VARIABLES_NAME = "GogoLootDB"

--------------------------------------------------------------------------------
-- Item Constants
--------------------------------------------------------------------------------

--[[
    The client's own symbol first (Enum, then the legacy LE_* global), the
    number last, so a future renumbering can't silently reclassify items.
]]

ns.BIND_ON_PICKUP = (Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire) or 1
ns.BIND_ON_EQUIP = (Enum and Enum.ItemBind and Enum.ItemBind.OnEquip) or 2
ns.BIND_ON_USE = (Enum and Enum.ItemBind and Enum.ItemBind.OnUse) or 3
ns.BIND_QUEST_ITEM = (Enum and Enum.ItemBind and Enum.ItemBind.Quest) or 4

ns.ITEM_CLASS_RECIPE = (Enum and Enum.ItemClass and Enum.ItemClass.Recipe) or LE_ITEM_CLASS_RECIPE or 9
ns.ITEM_CLASS_QUEST = (Enum and Enum.ItemClass and Enum.ItemClass.Questitem) or LE_ITEM_CLASS_QUESTITEM or 12
ns.ITEM_CLASS_MISCELLANEOUS = (Enum and Enum.ItemClass and Enum.ItemClass.Miscellaneous)
	or LE_ITEM_CLASS_MISCELLANEOUS
	or 15
ns.ITEM_SUBCLASS_COMPANION_PET = (
	Enum
	and Enum.ItemMiscellaneousSubclass
	and Enum.ItemMiscellaneousSubclass.CompanionPet
) or 2
ns.ITEM_SUBCLASS_MOUNT = (Enum and Enum.ItemMiscellaneousSubclass and Enum.ItemMiscellaneousSubclass.Mount) or 5

--[[
    Class 1 "Container" is a bag, not a lockbox: openables are matched by id
    (ns.OPENABLE_ITEMS), never by class. Quivers and ammo pouches are their
    own class, not bags.
]]
ns.ITEM_CLASS_BAG = (Enum and Enum.ItemClass and Enum.ItemClass.Container) or LE_ITEM_CLASS_CONTAINER or 1
ns.ITEM_CLASS_QUIVER = (Enum and Enum.ItemClass and Enum.ItemClass.Quiver) or LE_ITEM_CLASS_QUIVER or 11
ns.ITEM_CLASS_KEY = (Enum and Enum.ItemClass and Enum.ItemClass.Key) or LE_ITEM_CLASS_KEY or 13
ns.ITEM_CLASS_CONSUMABLE = (Enum and Enum.ItemClass and Enum.ItemClass.Consumable) or LE_ITEM_CLASS_CONSUMABLE or 0
ns.ITEM_CLASS_WEAPON = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or LE_ITEM_CLASS_WEAPON or 2
ns.ITEM_SUBCLASS_FISHING_POLE = (Enum and Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole)
	or LE_ITEM_WEAPON_FISHINGPOLE
	or 20
ns.INVENTORY_SLOT_MAIN_HAND = INVSLOT_MAINHAND or 16
ns.ITEM_CLASS_GEM = (Enum and Enum.ItemClass and Enum.ItemClass.Gem) or LE_ITEM_CLASS_GEM or 3
ns.ITEM_CLASS_ARMOR = (Enum and Enum.ItemClass and Enum.ItemClass.Armor) or LE_ITEM_CLASS_ARMOR or 4
ns.ITEM_CLASS_REAGENT = (Enum and Enum.ItemClass and Enum.ItemClass.Reagent) or LE_ITEM_CLASS_REAGENT or 5
ns.ITEM_CLASS_PROJECTILE = (Enum and Enum.ItemClass and Enum.ItemClass.Projectile) or LE_ITEM_CLASS_PROJECTILE or 6
ns.ITEM_CLASS_TRADE_GOODS = (Enum and Enum.ItemClass and Enum.ItemClass.Tradegoods) or LE_ITEM_CLASS_TRADEGOODS or 7

ns.TRADE_ENCHANT_SLOT = 7
ns.TRADE_ITEM_SLOT_COUNT = 6

--------------------------------------------------------------------------------
-- UI Colors
--------------------------------------------------------------------------------

-- Plain RRGGBB, never |cff-prefixed: Utilities.lua builds ns.COLORS / ns.COLORS_RGB from these.

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

-- Class colors through Wrath, so every flavor draws a class in the same color.
ns.CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

-- The options panels' Example names, by class token. Proper names, never translated.
ns.SAMPLE_NAMES = {
	HUNTER = "Spek",
	PRIEST = "Katz",
	ROGUE = "Fathom",
	DRUID = "Aero",
	WARRIOR = "Prima",
	WARLOCK = "Greasy",
	PALADIN = "Aiek",
	MAGE = "Portalrico",
	SHAMAN = "Moondragon",
}

--------------------------------------------------------------------------------
-- Target Marker
--------------------------------------------------------------------------------

--[[
    Leads every message sent to other players. WoW Forever blocks raid markers
    only in /say and public channels, which GogoLoot never sends to. Each
    Gogo1951 add-on has its own marker, so their messages stay distinct.
]]

--[[
    {rt1} Star, {rt2} Circle, {rt3} Diamond, {rt4} Triangle,
    {rt5} Moon, {rt6} Square, {rt7} Cross, {rt8} Skull
]]
ns.TARGET_MARKER = "{rt4}" -- Triangle

--------------------------------------------------------------------------------
-- Chat Message Limit
--------------------------------------------------------------------------------

-- SendChatMessage rejects messages over 255 bytes (see ns:AnnounceParts in Announcements.lua).
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

ns.ROLL_OVERRIDE_LABELS = {
	[ns.MANUAL] = ns.L["ROLL_MANUAL"],
	[ns.GREED] = GREED,
	[ns.NEED] = NEED,
	[ns.PASS] = PASS,
}

-- Every roll-action dropdown's `sorting`, least to most aggressive; without it AceConfig sorts by key.
ns.ROLL_OVERRIDE_ORDER = { ns.MANUAL, ns.PASS, ns.GREED, ns.NEED }

-- The roll window's own button art for each roll, as the mini-map menu shows it; Manual has none.
ns.ROLL_ICONS = {
	[ns.PASS] = "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
	[ns.GREED] = "Interface\\Buttons\\UI-GroupLoot-Coin-Up",
	[ns.NEED] = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
}

--[[
    Character Rules: gear of a ticked type carrying a ticked stat is left to
    the player; other armor and weapons roll as the Everything Else row says.
    Every character starts on its class's list and saves only the boxes the
    player changes (maintainer, 2026-11-07).
]]

-- Captioned by the game's labelGlobal where the client has it (WoW Forever and later), else the locale caption.
ns.CHARACTER_RULE_GROUPS = {
	{ key = "PRIMARY", caption = "CHARACTER_RULES_PRIMARY", labelGlobal = "STAT_CATEGORY_PRIMARY_ATTRIBUTES" },
	{
		key = "SECONDARY",
		caption = "CHARACTER_RULES_SECONDARY",
		labelGlobal = "STAT_CATEGORY_SECONDARY_ATTRIBUTES",
		sortByLabel = true,
	},
}

--[[
    Primary stats keep this order; secondary ones sort A to Z by label as the
    panel builds. `itemMods` are the GetItemStats keys that carry the stat;
    Spell Power counts for both the damage and healing rules. `everyClass`
    stats start ticked for every class; the rest come from the class starter
    list, and Stamina is on none (maintainer, 2026-11-07).
]]
ns.CHARACTER_RULE_STATS = {
	{
		key = "STRENGTH",
		group = "PRIMARY",
		label = ITEM_MOD_STRENGTH_SHORT,
		itemMods = { "ITEM_MOD_STRENGTH_SHORT" },
	},
	{
		key = "AGILITY",
		group = "PRIMARY",
		label = ITEM_MOD_AGILITY_SHORT,
		itemMods = { "ITEM_MOD_AGILITY_SHORT" },
	},
	{
		key = "STAMINA",
		group = "PRIMARY",
		label = ITEM_MOD_STAMINA_SHORT,
		itemMods = { "ITEM_MOD_STAMINA_SHORT" },
	},
	{
		key = "INTELLECT",
		group = "PRIMARY",
		label = ITEM_MOD_INTELLECT_SHORT,
		itemMods = { "ITEM_MOD_INTELLECT_SHORT" },
	},
	{
		key = "SPIRIT",
		group = "PRIMARY",
		label = ITEM_MOD_SPIRIT_SHORT,
		itemMods = { "ITEM_MOD_SPIRIT_SHORT" },
	},
	{
		key = "SPELL_POWER",
		group = "SECONDARY",
		label = ITEM_MOD_SPELL_POWER_SHORT,
		itemMods = { "ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT" },
	},
	{
		key = "HEALING_POWER",
		group = "SECONDARY",
		label = ITEM_MOD_SPELL_HEALING_DONE_SHORT,
		itemMods = { "ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_SPELL_HEALING_DONE_SHORT" },
	},
	{
		key = "ATTACK_POWER",
		group = "SECONDARY",
		label = ITEM_MOD_ATTACK_POWER_SHORT,
		itemMods = { "ITEM_MOD_ATTACK_POWER_SHORT" },
	},
	{
		key = "CRIT",
		everyClass = true,
		group = "SECONDARY",
		label = ITEM_MOD_CRIT_RATING_SHORT,
		itemMods = {
			"ITEM_MOD_CRIT_RATING_SHORT",
			"ITEM_MOD_CRIT_MELEE_RATING_SHORT",
			"ITEM_MOD_CRIT_RANGED_RATING_SHORT",
			"ITEM_MOD_CRIT_SPELL_RATING_SHORT",
		},
	},
	{
		key = "HIT",
		everyClass = true,
		group = "SECONDARY",
		label = ITEM_MOD_HIT_RATING_SHORT,
		itemMods = {
			"ITEM_MOD_HIT_RATING_SHORT",
			"ITEM_MOD_HIT_MELEE_RATING_SHORT",
			"ITEM_MOD_HIT_RANGED_RATING_SHORT",
			"ITEM_MOD_HIT_SPELL_RATING_SHORT",
		},
	},
	{
		key = "MP5",
		group = "SECONDARY",
		label = ITEM_MOD_POWER_REGEN0_SHORT,
		itemMods = { "ITEM_MOD_MANA_REGENERATION_SHORT", "ITEM_MOD_POWER_REGEN0_SHORT" },
	},
}

--[[
    `types` and `starter` name the ns tables each flavor's
    Character-Rule-Gear-Types-{Folder}.lua fills; a section with no rows is
    dropped at load. Armor keeps its listed order, lightest first.
]]
ns.CHARACTER_RULE_GEAR_GROUPS = {
	{
		key = "ARMOR",
		caption = "CHARACTER_RULES_ARMOR",
		classIdentifier = ns.ITEM_CLASS_ARMOR,
		types = "CHARACTER_RULE_ARMOR_TYPES",
		starter = "CLASS_ARMOR_STARTER",
	},
	{
		key = "WEAPON",
		caption = "CHARACTER_RULES_WEAPONS",
		classIdentifier = ns.ITEM_CLASS_WEAPON,
		types = "CHARACTER_RULE_WEAPON_TYPES",
		starter = "CLASS_WEAPON_STARTER",
		sortByLabel = true,
	},
	-- Catch-all for gear no row above names (a fishing pole, an unlisted subclass); every class starts with it ticked.
	{
		key = "OTHER",
		labelGlobal = "OTHER",
		caption = "CHARACTER_RULES_OTHER_GEAR",
		catchAll = true,
		types = "CHARACTER_RULE_OTHER_TYPES",
	},
}

ns.CHARACTER_RULE_OTHER_TYPES = { "GEAR" }

-- Rows no item subclass names: held off-hands go by slot (they share armor subclass 0 with rings), and Other.
ns.CHARACTER_RULE_GEAR_ROW_LABELS = {
	HELD = INVTYPE_HOLDABLE,
	GEAR = ns.L["CHARACTER_RULES_OTHER_GEAR"],
}

-- [equipLocation] = row, for a row an item's slot names rather than its subclass.
ns.CHARACTER_RULE_GEAR_SLOT_ROWS = {
	INVTYPE_HOLDABLE = "HELD",
}

-- Slots any class wears, so stats alone decide: a cloak is cloth by subclass, the rest armor subclass 0.
ns.CHARACTER_RULE_TYPELESS_SLOTS = {
	INVTYPE_CLOAK = true,
	INVTYPE_FINGER = true,
	INVTYPE_NECK = true,
	INVTYPE_TRINKET = true,
}

-- Slots Character Rules never judges: shirts and tabards carry no stats and are no one's upgrade.
ns.CHARACTER_RULE_SKIPPED_SLOTS = {
	INVTYPE_BODY = true,
	INVTYPE_TABARD = true,
}

-- The Everything Else row, for gear the character doesn't want; a field is saved only once changed from these.
ns.CHARACTER_RULE_UNWANTED_DEFAULTS = {
	action = ns.GREED,
	-- Greeds gear this many levels below the character whatever it matches; 0 is off (maintainer, 2026-11-07).
	lowLevelGear = 5,
}

-- Automatically Greed on Low-Level Gear's choices: Off, then Your Level - 1 to - 5.
ns.CHARACTER_RULE_LOW_LEVEL_ORDER = { 0, 1, 2, 3, 4, 5 }
ns.CHARACTER_RULE_LOW_LEVEL_LABELS = { [0] = ns.L["CHARACTER_RULES_LOW_LEVEL_OFF"] }
for levelsBelow = 1, 5 do
	ns.CHARACTER_RULE_LOW_LEVEL_LABELS[levelsBelow] = ns.L["CHARACTER_RULES_LOW_LEVEL_BELOW"]:format(levelsBelow)
end

ns.CHARACTER_RULE_UNWANTED_LABELS = {
	[ns.GREED] = GREED,
	[ns.MANUAL] = ns.L["ROLL_MANUAL"],
	[ns.PASS] = PASS,
}

ns.CHARACTER_RULE_UNWANTED_ORDER = { ns.GREED, ns.MANUAL, ns.PASS }

-- The highest quality a group context's automated roll reaches, as the Up to Quality rows and the mini-map tooltip name it.
ns.ROLL_THRESHOLD_LABELS = {
	[0] = ns.L["THRESHOLD_ONLY"]:format(ITEM_QUALITY0_DESC),
	[1] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY1_DESC),
	[2] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY2_DESC),
	[3] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY3_DESC),
	[4] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY4_DESC),
}

-- The roll kind ns.ParseRollResultMessage reads off a roll line; Disenchant only where the client offers it.
ns.ROLL_KIND_NEED = "NEED"
ns.ROLL_KIND_GREED = "GREED"
ns.ROLL_KIND_DISENCHANT = "DISENCHANT"

--------------------------------------------------------------------------------
-- Master Loot Destinations
--------------------------------------------------------------------------------

-- Nobody picked, so the quality waits in the loot window. Never saved: picking it clears the destination.
ns.DESTINATION_LOOT_WINDOW = "lootwindow"

--------------------------------------------------------------------------------
-- Options Layout Widths
--------------------------------------------------------------------------------

--[[
    The panel grid (ns.OPTIONS_*) is Options-Kit's and loads after this file,
    so nothing here may read it; widths built from it sit in
    Options/Options-Utilities.lua.
]]

-- The action column of the Item Overrides and Openables lists.
ns.ROLL_ACTION_DROPDOWN_WIDTH = 0.7

-- The Openables List's reason column (Locked, Sell Sealed, May Hold Unique), taken from the item's share of the row.
ns.OPTIONS_ITEM_TAG_WIDTH = 0.65

-- Restore Defaults, at the foot of an item list, right-aligned: wide enough for its caption and no wider.
ns.OPTIONS_RESTORE_BUTTON_WIDTH = 1

-- The Loot Toasts Filters rows' caption column; Mine and Group columns share one width so every Group box lines up.
ns.OPTIONS_FILTER_LABEL_WIDTH = 1
ns.OPTIONS_FILTER_BOX_WIDTH = 0.45

--------------------------------------------------------------------------------
-- Quality Constants
--------------------------------------------------------------------------------

-- Plain RRGGBB like ns.PALETTE; ns.GetQualityColor(quality) gives the |cff form.
ns.QUALITY_COLORS = {
	[0] = "9D9D9D", -- Poor (Gray)
	[1] = "FFFFFF", -- Common (White)
	[2] = "1EFF00", -- Uncommon (Green)
	[3] = "0070DD", -- Rare (Blue)
	[4] = "A335EE", -- Epic (Purple)
	[5] = "FF8000", -- Legendary (Orange)
	[6] = "E6CC80", -- Artifact (Tan)
}

ns.RARITY_TO_CONFIGURATION_KEY = {
	[0] = "poor",
	[1] = "common",
	[2] = "uncommon",
	[3] = "rare",
	[4] = "epic",
}

ns.QUALITY_DISPLAY_NAMES = {
	["poor"] = ITEM_QUALITY0_DESC,
	["common"] = ITEM_QUALITY1_DESC,
	["uncommon"] = ITEM_QUALITY2_DESC,
	["rare"] = ITEM_QUALITY3_DESC,
	["epic"] = ITEM_QUALITY4_DESC,
}

--------------------------------------------------------------------------------
-- Loot Toast Filters
--------------------------------------------------------------------------------

--[[
    `key` keys lootToastMine / lootToastGroup. A row with a subclass is that
    subclass alone, which its class row then leaves out. `rarity` adds a
    quality dropdown (lootToastMineQuality / lootToastGroupQuality).
    `mineOnly`: the game reports no other player's coin or currency. The
    type rows after the rarity ones sort by client name as the panel builds.
]]
ns.LOOT_TOAST_FILTER_ROWS = {
	{ key = "ARMOR", classIdentifier = ns.ITEM_CLASS_ARMOR, rarity = true },
	{ key = "WEAPON", classIdentifier = ns.ITEM_CLASS_WEAPON, rarity = true },
	{ key = "GEM", classIdentifier = ns.ITEM_CLASS_GEM, rarity = true, minimumExpansion = 2 },
	{ key = "TRADE_GOODS", classIdentifier = ns.ITEM_CLASS_TRADE_GOODS, rarity = true },
	{
		key = "COMPANION_PET",
		classIdentifier = ns.ITEM_CLASS_MISCELLANEOUS,
		subclassIdentifier = ns.ITEM_SUBCLASS_COMPANION_PET,
	},
	{ key = "CONSUMABLE", classIdentifier = ns.ITEM_CLASS_CONSUMABLE },
	{ key = "CONTAINER", classIdentifier = ns.ITEM_CLASS_BAG },
	{ key = "KEY", classIdentifier = ns.ITEM_CLASS_KEY },
	{ key = "MISCELLANEOUS", classIdentifier = ns.ITEM_CLASS_MISCELLANEOUS },
	{ key = "MOUNT", classIdentifier = ns.ITEM_CLASS_MISCELLANEOUS, subclassIdentifier = ns.ITEM_SUBCLASS_MOUNT },
	{ key = "PROJECTILE", classIdentifier = ns.ITEM_CLASS_PROJECTILE },
	{ key = "QUEST", classIdentifier = ns.ITEM_CLASS_QUEST },
	{ key = "QUIVER", classIdentifier = ns.ITEM_CLASS_QUIVER },
	{ key = "REAGENT", classIdentifier = ns.ITEM_CLASS_REAGENT },
	{ key = "RECIPE", classIdentifier = ns.ITEM_CLASS_RECIPE },
	{ key = "BIND_ON_PICKUP", labelKey = "LOOT_TOASTS_FILTER_BIND_ON_PICKUP" },
	{ key = "OPENABLES", labelKey = "LOOT_TOASTS_FILTER_OPENABLES" },
	{ key = "MONEY", label = MONEY, mineOnly = true },
	-- Currency loot lines (CHAT_MSG_CURRENCY) arrived with Cataclysm, so of the clients with a TOC only MoP Classic has them.
	{ key = "CURRENCY", label = CURRENCY, mineOnly = true, minimumExpansion = 4 },
}

--------------------------------------------------------------------------------
-- Automated Opening
--------------------------------------------------------------------------------

-- Free general bag slots below which opening pauses and Speedy Loot keeps the window up: one line for both.
ns.MIN_FREE_SLOTS = 4

-- The loot windows ElvUI and Tukui put in place of the game's (see ns.GetLootWindow).
ns.LOOT_WINDOW_REPLACEMENTS = { "ElvLootFrame", "TukuiLootFrame" }

-- Seconds after a Speedy Loot pass closes the loot in which a refused pickup still counts as that pass's.
ns.LOOT_BOUNCE_WINDOW = 2

ns.WORLD_LOAD_DELAY = 8 -- Seconds after a login or reload before the first scan
ns.SCAN_DEBOUNCE = 0.5 -- Seconds a burst of bag events waits to become one scan
ns.OPEN_TICK_INTERVAL = 0.25 -- Seconds between opens
ns.OPEN_RECHECK_DELAY = 0.25 -- Seconds before re-checking a slot after opening from it
ns.OPEN_ANSWER_TIMEOUT = 1 -- Seconds an open waits for its loot window before it counts as refused
ns.OPEN_REFUSAL_LIMIT = 3 -- Refused opens in a row before an item is left alone until the next level-up
ns.PICK_LOCK_RESCAN_DELAY = 0.5 -- Seconds for a picked lock to settle before rescanning
ns.STATUS_FLUSH_DELAY = 0.25 -- Seconds after a window closes before a held status message prints
ns.BAG_FULL_COOLDOWN = 10 -- Seconds between inventory-full warnings
ns.ITEM_ANNOUNCE_COOLDOWN = 5 -- Seconds before the same item may be announced again
ns.STATUS_REPEAT_COOLDOWN = 5 -- Seconds before an identical status message may print again

--[[
    The Openables List dropdown's two values. OPENING_REMOVED is saved for a
    listed item the player took off, and is never a dropdown value.
]]
ns.OPENING_OPEN = "OPEN"
ns.OPENING_IGNORE = "IGNORE"
ns.OPENING_REMOVED = "REMOVED"

--[[
    The other data defaults: UNLOCKED, a lockbox, opened once picked;
    IGNORE_RAID, a raid boss drop; IGNORE_UNIQUE, may hold a unique item;
    and OPENING_IGNORE, may hold Bind on Pickup loot. The Ignores go only to
    a container that can itself be traded, but for Gnarlpine Necklace (8049),
    set to Ignore by hand in every folder. A reason shows as the row's tag
    whatever the player sets.
]]
ns.OPENING_UNLOCKED = "UNLOCKED"
ns.OPENING_IGNORE_RAID = "IGNORE_RAID"
ns.OPENING_IGNORE_UNIQUE = "IGNORE_UNIQUE"

ns.OPENING_ACTION_LABELS = {
	[ns.OPENING_OPEN] = ns.L["OPENING_ACTION_OPEN"],
	[ns.OPENING_IGNORE] = ns.L["OPENING_ACTION_IGNORE"],
}

-- The Openables List dropdowns' `sorting`; by key, Ignore would come first.
ns.OPENING_ACTION_ORDER = {
	ns.OPENING_OPEN,
	ns.OPENING_IGNORE,
}

--------------------------------------------------------------------------------
-- Loot Sounds
--------------------------------------------------------------------------------

-- The rare-loot chime; play with PlaySoundFile.
ns.LOOT_SOUND_FILE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Sounds\\item-pick-up.ogg"

-- Automated Rolls' Safety Warning alert, played on entering a dungeon or raid set to Need or Pass.
ns.ROLL_SAFETY_WARNING_SOUND_FILE = "Interface\\AddOns\\"
	.. ADDON_NAME
	.. "\\Includes\\Sounds\\Loot-Threshold-Warning.ogg"

-- Seconds after a corpse or chest's loot window closes during which a loot message may still play the chime.
ns.LOOT_SOUND_WINDOW = 1

-- Seconds a loot window may follow a Pick Pocket cast and still count as its haul.
ns.PICK_POCKET_LOOT_WINDOW = 1

--------------------------------------------------------------------------------
-- Loot Toasts
--------------------------------------------------------------------------------

-- Seconds the fade itself takes, once the chosen time on screen has passed.
ns.LOOT_TOAST_FADE_DURATION = 0.5
-- Seconds between rows entering, so a burst of loot arrives one row at a time (Features/Loot-Toasts.lua).
ns.LOOT_TOAST_ENTRY_INTERVAL = 0.15

-- Seconds a toast stays up. Offered as a dropdown, so the steps widen as they grow.
ns.LOOT_TOAST_DURATIONS = { 1, 2, 3, 5, 8, 13, 21 }

--[[
    Most rows on screen at once. Unlimited is stored as 0, a sentinel the cap
    code must special-case: a literal cap of zero would retire every row.
]]
ns.LOOT_TOAST_COUNTS = { 1, 2, 3, 5, 8, 13, 21 }
ns.LOOT_TOAST_UNLIMITED = 0

-- The dropdown beside Hide Roll Messages: GogoLoot's winner summary in place of the game's won line, or neither.
ns.WINNER_SUMMARY_PRINT = "PRINT"
ns.WINNER_SUMMARY_NONE = "NONE"

-- The dropdown beside Enable Loot Toasts: the game's own loot lines in General, off or kept (Standard Loot Messages).
ns.STANDARD_LOOT_MESSAGES_DISABLE = "DISABLE"
ns.STANDARD_LOOT_MESSAGES_ENABLE = "ENABLE"

-- Font faces come from LibSharedMedia. A size saved between these steps is offered too, so it still reads back.
ns.LOOT_TOAST_FONT_SIZE_MIN = 8
ns.LOOT_TOAST_FONT_SIZES = { 8, 10, 12, 14, 16, 18, 20, 22, 24 }

-- SetFont flag strings in dropdown order. "NONE" is ours, for the empty string SetFont wants.
ns.LOOT_TOAST_FONT_FLAGS = { "NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROMEOUTLINE" }

--[[
    The position preview's sample toasts, a potion colored to each quality.
    { [quality] = iconPath }
]]
ns.LOOT_TOAST_SAMPLE_ICONS = {
	[0] = "Interface\\Icons\\inv_potion_132", -- Poor (gray)
	[1] = "Interface\\Icons\\inv_potion_133", -- Common (white)
	[2] = "Interface\\Icons\\inv_potion_138", -- Uncommon (green)
	[3] = "Interface\\Icons\\inv_potion_137", -- Rare (blue)
	[4] = "Interface\\Icons\\inv_potion_134", -- Epic (purple)
	[5] = "Interface\\Icons\\inv_potion_135", -- Legendary (orange)
}

-- The money toast's icon, one coin pile per magnitude.
ns.MONEY_ICON_GOLD = "Interface\\Icons\\INV_Misc_Coin_02"
ns.MONEY_ICON_SILVER = "Interface\\Icons\\INV_Misc_Coin_04"
ns.MONEY_ICON_COPPER = "Interface\\Icons\\INV_Misc_Coin_06"

-- Stands in for any icon the client can't supply: a currency it can't describe, an item it hasn't loaded.
ns.QUESTION_MARK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

--[[
    The Roll Macro: left-click 1-100, right-click 1-99 (off-spec),
    middle-click 1 to the group's size (raid roll). Coins, since no dice icon
    exists on every client; a file ID, since GetMacroInfo answers with one.
]]
ns.ROLL_MACRO_NAME = "- Roll"
ns.ROLL_MACRO_ICON = 133784 -- Interface\Icons\INV_Misc_Coin_01
ns.ROLL_MACRO_BODY =
	'/run local b,n=GetMouseButtonClicked(),GetNumGroupMembers() RandomRoll(1,b=="MiddleButton" and n>0 and n or b=="RightButton" and 99 or 100)'

--[[
    Raid Roll Winner's raidRollOutput values, and the wait per roster place
    before posting, so the first GogoLoot user posts and the rest hear its
    claim and stay quiet.
]]
ns.RAID_ROLL_OUTPUT_SELF = "SELF"
ns.RAID_ROLL_OUTPUT_GROUP = "GROUP"
ns.RAID_ROLL_CLAIM_WAIT = 1 -- seconds

ns.COPPER_PER_SILVER = 100
ns.COPPER_PER_GOLD = 10000

-- The g/s/c suffix colors: the game's money conventions, so kept apart from ns.PALETTE.
ns.MONEY_PALETTE = {
	GOLD = "FFD700",
	SILVER = "C7C7CF",
	COPPER = "EDA55F",
}

--------------------------------------------------------------------------------
-- Trade Output Labels
--------------------------------------------------------------------------------

ns.TRADE_OUTPUT_LABELS = {
	["whisper"] = WHISPER,
	["group"] = ns.L["CHANNEL_GROUP_CHAT"],
	["self"] = ns.L["CHANNEL_ME_ONLY"],
}

ns.TRADE_CONDITION_LABELS = {
	["always"] = ns.L["TRADE_CONDITION_ALWAYS"],
	["party_or_raid"] = ns.L["TRADE_CONDITION_PARTY_OR_RAID"],
	["raid_only"] = ns.L["TRADE_CONDITION_RAID_ONLY"],
}
ns.TRADE_CONDITION_ORDER = { "always", "party_or_raid", "raid_only" }

--------------------------------------------------------------------------------
-- Loot Master & Loot Tracker
--------------------------------------------------------------------------------

-- The add-on message prefix the loot master's rolls travel under, so raiders' Loot Trackers follow them.
ns.ADDON_MESSAGE_PREFIX = "GogoLoot"

-- The only roll that counts: a plain /roll.
ns.ROLL_LOW = 1
ns.ROLL_HIGH = 100

-- Roll Length, in seconds.
ns.ROLL_LENGTHS = { 10, 15, 20, 30, 45, 60 }
-- Pause Between Items in Roll All, in seconds.
ns.ROLL_ALL_PAUSES = { 0, 3, 5, 10, 15 }
-- Warn Me When Trade Time Runs Low, in minutes.
ns.TRADE_WARN_MINUTES = { 5, 10, 15, 20, 30 }
-- Keep Drops by Boss For, in raids.
ns.DROPS_KEEP_RAIDS = { 1, 3, 5, 10 }

-- Announce In: where calls for rolls, ties and pauses go. Winners always go to group chat.
ns.ROLL_CHANNEL_RAID_WARNING = "RAID_WARNING"
ns.ROLL_CHANNEL_GROUP = "GROUP"

--[[
    Grace after a roll closes in which a roll still counts, for lag. Rolls
    within EARLY / LATE seconds outside the window show as not counted, so the
    raid can see why.
]]
ns.ROLL_GRACE_SECONDS = 1
ns.ROLL_EARLY_SECONDS = 5
ns.ROLL_LATE_SECONDS = 5
-- When the last-call warning goes out, and how much a late roll stretches the timer.
ns.ROLL_WARNING_SECONDS = 5
ns.ROLL_STRETCH_SECONDS = 5
-- What +10 Seconds adds.
ns.ROLL_EXTEND_SECONDS = 10
-- How often a live roll and the windows' clocks are checked.
ns.ROLL_TICK_SECONDS = 0.25
ns.WINDOW_TICK_SECONDS = 1

-- Why a roll doesn't count. The automatic ones; a disqualification by hand is ROLL_REJECT_MANUAL.
ns.ROLL_REJECT_EARLY = "EARLY"
ns.ROLL_REJECT_LATE = "LATE"
ns.ROLL_REJECT_REPEAT = "REPEAT"
ns.ROLL_REJECT_RANGE = "RANGE"
ns.ROLL_REJECT_NOT_TIED = "NOT_TIED"
ns.ROLL_REJECT_MANUAL = "MANUAL"

-- The reasons offered when the loot master disqualifies a roll, in the order offered.
ns.ROLL_DISQUALIFY_REASONS = { "NOT_ELIGIBLE", "ALREADY_WON", "FOR_SOMEONE_ELSE", "NONE" }

-- Where a Roll List entry came from: a tradable item in the bags, Floor Loot, or a corpse's loot window.
ns.LOOT_SOURCE_BAGS = "BAGS"
ns.LOOT_SOURCE_FLOOR = "FLOOR"
ns.LOOT_SOURCE_CORPSE = "CORPSE"

ns.ENTRY_WAITING = "WAITING"
ns.ENTRY_ROLLING = "ROLLING"
ns.ENTRY_TIED = "TIED"
ns.ENTRY_WON = "WON"
ns.ENTRY_NOBODY = "NOBODY"
ns.ENTRY_EXPIRED = "EXPIRED"

-- Trade clock colors (yellow, red) and the two-hour window its bar scales to; a longer clock fills the bar.
ns.TRADE_YELLOW_SECONDS = 1800
ns.TRADE_RED_SECONDS = 600
ns.TRADE_WINDOW_SECONDS = 7200
-- A rescan moves an entry's clock only when the tooltip disagrees by more than this, since it reads whole minutes.
ns.TRADE_RESYNC_SECONDS = 60
-- A burst of bag events waits this long to become one trade-clock scan, and a slow scan runs this often anyway.
ns.TRADE_SCAN_DEBOUNCE = 1
ns.TRADE_SAFETY_SCAN = 60
-- Seconds after TRADE_SHOW before won items go into the window, so the window has drawn.
ns.TRADE_FILL_DELAY = 0.3

-- Roll List rows only offer tradable loot at or above this quality.
ns.TRADABLE_MIN_QUALITY = 2

-- Seconds between Tradable Gear Tint checks for a trade clock that ran out, so the tint leaves as the item binds.
ns.TRADABLE_TINT_CHECK_SECONDS = 30

-- How many finished rolls the Loot Tracker keeps under Earlier tonight.
ns.ROLL_HISTORY_LIMIT = 30

-- A boss's corpse is told apart from trash by being the first corpse looted within this many seconds of the kill.
ns.BOSS_LOOT_WINDOW = 600
-- Drops by boss records trash loot at or above this quality.
ns.DROPS_TRASH_MIN_QUALITY = 3
-- Drops by boss records boss loot at or above this quality.
ns.DROPS_BOSS_MIN_QUALITY = 2

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

-- Never localized: NotifyChange calls and the Blizzard options tree match these by exact string.

ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME,
	SpeedyLoot = ADDON_NAME .. "_SpeedyLoot",
	AutomatedRolls = ADDON_NAME .. "_AutomatedRolls",
	ItemOverrides = ADDON_NAME .. "_ItemOverrides",
	CharacterRules = ADDON_NAME .. "_CharacterRules",
	MasterLooter = ADDON_NAME .. "_MasterLooter",
	MasterLooterIgnoreList = ADDON_NAME .. "_MasterLooterIgnoreList",
	AutomatedOpening = ADDON_NAME .. "_AutomatedOpening",
	OpenableItems = ADDON_NAME .. "_OpenableItems",
	Lockboxes = ADDON_NAME .. "_Lockboxes",
	LootToasts = ADDON_NAME .. "_LootToasts",
	LootToastFilters = ADDON_NAME .. "_LootToastFilters",
	LootSounds = ADDON_NAME .. "_LootSounds",
	Announcements = ADDON_NAME .. "_Announcements",
	RollMacro = ADDON_NAME .. "_RollMacro",
	SanityCheck = ADDON_NAME .. "_SanityCheck",
	LootMaster = ADDON_NAME .. "_LootMaster",
	-- Registered but never added to the Blizzard tree: it opens as its own window.
	MasterLooterPopup = ADDON_NAME .. "_MasterLooterPopup",
	Profiles = ADDON_NAME .. "_Profiles",
	FeedbackSupport = ADDON_NAME .. "_FeedbackSupport",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

ns.ITEM_LIST_FILTER_WIDGET_TYPE = ADDON_NAME .. "_ItemListFilter"
ns.ITEM_LIST_ADD_WIDGET_TYPE = ADDON_NAME .. "_ItemListAdd"

--------------------------------------------------------------------------------
-- URL Constants
--------------------------------------------------------------------------------

ns.LINKS = {
	CURSEFORGE = "https://www.curseforge.com/wow/addons/gogoloot",
	GITHUB = "https://github.com/Gogo1951/GogoLoot",
	DISCORD = "https://discord.gg/eh8hKq992Q",
	WAGO = "https://addons.wago.io/addons/gogoloot",
}

--------------------------------------------------------------------------------
-- Minimap
--------------------------------------------------------------------------------

ns.MINIMAP_ICONS = {
	on = 134467, -- Automated Rolls On
	off = 134468, -- Automated Rolls Off
}
