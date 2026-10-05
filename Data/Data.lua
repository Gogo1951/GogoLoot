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
    Prefer the client's own symbol, fall back to the numeric value, which is
    correct on every flavor we target. Reading the symbol first means a future
    renumbering doesn't silently reclassify items.
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

--[[
    Class 1 is the client's "Container", which is a BAG, the thing loot goes in,
    not the lockbox Automated Opening opens; those are ns.OPENABLE_ITEMS, matched
    by id, never by class. Quivers and ammo pouches are their own class rather
    than bags, so each gets a Filters row of its own on the Loot Toasts panel.
]]
ns.ITEM_CLASS_BAG = LE_ITEM_CLASS_CONTAINER or (Enum and Enum.ItemClass and Enum.ItemClass.Container) or 1
ns.ITEM_CLASS_QUIVER = LE_ITEM_CLASS_QUIVER or (Enum and Enum.ItemClass and Enum.ItemClass.Quiver) or 11
ns.ITEM_CLASS_KEY = LE_ITEM_CLASS_KEY or (Enum and Enum.ItemClass and Enum.ItemClass.Key) or 13
ns.ITEM_CLASS_CONSUMABLE = LE_ITEM_CLASS_CONSUMABLE or (Enum and Enum.ItemClass and Enum.ItemClass.Consumable) or 0
ns.ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON or (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or 2
ns.ITEM_CLASS_GEM = LE_ITEM_CLASS_GEM or (Enum and Enum.ItemClass and Enum.ItemClass.Gem) or 3
ns.ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR or (Enum and Enum.ItemClass and Enum.ItemClass.Armor) or 4
ns.ITEM_CLASS_REAGENT = LE_ITEM_CLASS_REAGENT or (Enum and Enum.ItemClass and Enum.ItemClass.Reagent) or 5
ns.ITEM_CLASS_PROJECTILE = LE_ITEM_CLASS_PROJECTILE or (Enum and Enum.ItemClass and Enum.ItemClass.Projectile) or 6
ns.ITEM_CLASS_TRADE_GOODS = LE_ITEM_CLASS_TRADEGOODS or (Enum and Enum.ItemClass and Enum.ItemClass.Tradegoods) or 7

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
    Announcements.lua), on every flavor. WoW Forever blocks raid markers only
    in /say and public channels such as General, which GogoLoot never sends
    to. One marker per add-on, chosen so GogoLoot's messages stay visually
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

--[[
    Display order for every roll-action dropdown, passed to AceConfig as
    `sorting`. Without it the dropdown sorts by key (greed, manual, need,
    pass); this keeps the four actions in one fixed, least-to-most aggressive
    order everywhere they appear.
]]
ns.ROLL_OVERRIDE_ORDER = { ns.MANUAL, ns.PASS, ns.GREED, ns.NEED }

--[[
    Character Rules: the stats whose gear each character leaves to the player.
    Two choices per stat (maintainer, 2026-10-05): Standard Automated Roll,
    saved as no rule at all, and Manual.
]]
ns.CHARACTER_RULE_STANDARD = "standard"

ns.CHARACTER_RULE_LABELS = {
	[ns.CHARACTER_RULE_STANDARD] = ns.L["CHARACTER_RULES_STANDARD"],
	[ns.MANUAL] = ns.L["ROLL_MANUAL"],
}

ns.CHARACTER_RULE_ORDER = { ns.CHARACTER_RULE_STANDARD, ns.MANUAL }

--[[
    The panel's two sections, in order. Each is captioned with the game's own
    label (labelGlobal) on a client that has it, WoW Forever and later, and with
    its locale key (caption) on one that doesn't.
]]
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
    The stats a rule can name. `group` is the panel section a stat sits in:
    the primary attributes in the character sheet's order, as listed here, and
    the secondary ones A to Z by their name in the player's language, which
    the panel sorts as it builds. `bit` is the stat's flag in the
    generated Data/{Folder}/Item-Stats-{Folder}.lua tables, so it never changes
    once shipped. `itemMods` are the GetItemStats keys that carry the stat, and
    `label` is the game's own name for it, already in the player's language.
    Spell Power on later clients is damage and healing in one stat, so it
    counts for both rules, as the Classic gear that says "damage and healing"
    does.
]]
ns.CHARACTER_RULE_STATS = {
	{
		key = "STRENGTH",
		group = "PRIMARY",
		bit = 1,
		label = ITEM_MOD_STRENGTH_SHORT,
		itemMods = { "ITEM_MOD_STRENGTH_SHORT" },
	},
	{
		key = "AGILITY",
		group = "PRIMARY",
		bit = 2,
		label = ITEM_MOD_AGILITY_SHORT,
		itemMods = { "ITEM_MOD_AGILITY_SHORT" },
	},
	{
		key = "STAMINA",
		group = "PRIMARY",
		bit = 16,
		label = ITEM_MOD_STAMINA_SHORT,
		itemMods = { "ITEM_MOD_STAMINA_SHORT" },
	},
	{
		key = "INTELLECT",
		group = "PRIMARY",
		bit = 4,
		label = ITEM_MOD_INTELLECT_SHORT,
		itemMods = { "ITEM_MOD_INTELLECT_SHORT" },
	},
	{
		key = "SPIRIT",
		group = "PRIMARY",
		bit = 8,
		label = ITEM_MOD_SPIRIT_SHORT,
		itemMods = { "ITEM_MOD_SPIRIT_SHORT" },
	},
	{
		key = "SPELL_POWER",
		group = "SECONDARY",
		bit = 32,
		label = ITEM_MOD_SPELL_POWER_SHORT,
		itemMods = { "ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT" },
	},
	{
		key = "HEALING_POWER",
		group = "SECONDARY",
		bit = 64,
		label = ITEM_MOD_SPELL_HEALING_DONE_SHORT,
		itemMods = { "ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_SPELL_HEALING_DONE_SHORT" },
	},
	{
		key = "ATTACK_POWER",
		group = "SECONDARY",
		bit = 128,
		label = ITEM_MOD_ATTACK_POWER_SHORT,
		itemMods = { "ITEM_MOD_ATTACK_POWER_SHORT" },
	},
	{
		key = "CRIT",
		group = "SECONDARY",
		bit = 256,
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
		group = "SECONDARY",
		bit = 512,
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
		bit = 1024,
		label = ITEM_MOD_POWER_REGEN0_SHORT,
		itemMods = { "ITEM_MOD_MANA_REGENERATION_SHORT", "ITEM_MOD_POWER_REGEN0_SHORT" },
	},
}

-- The highest quality a group context's automated roll reaches, as the Up to Quality rows and the mini-map tooltip name it.
ns.ROLL_THRESHOLD_LABELS = {
	[0] = ns.L["THRESHOLD_ONLY"]:format(ITEM_QUALITY0_DESC),
	[1] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY1_DESC),
	[2] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY2_DESC),
	[3] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY3_DESC),
	[4] = ns.L["THRESHOLD_AND_LOWER"]:format(ITEM_QUALITY4_DESC),
}

--[[
    The game's own word for each kind of winning roll, as the client reads the
    roll lines it prints (ns.ParseRollResultMessage): what a toast shows beside
    its number. Disenchant exists only where the client offers it.
]]
ns.ROLL_KIND_NEED = "NEED"
ns.ROLL_KIND_GREED = "GREED"
ns.ROLL_KIND_DISENCHANT = "DISENCHANT"

--------------------------------------------------------------------------------
-- Master Loot Destinations
--------------------------------------------------------------------------------

--[[
    The destination dropdowns' first choice: nobody picked, so that quality
    waits in the loot window. Never saved; picking it clears the quality's
    destination, and an unset quality reads back as it.
]]
ns.DESTINATION_LOOT_WINDOW = "lootwindow"

--------------------------------------------------------------------------------
-- Options Layout Widths
--------------------------------------------------------------------------------

--[[
    AceConfig draws a control's own `name` above it, which spends a line per
    setting. Every labeled control in the add-on instead pairs an unlabeled
    control with a description cell beside it (ns.OptionsRowLabel), so the label
    sits to its left and the setting is one line.

    Every such row — a plain label + control, an item row, a Filters row —
    spends OPTIONS_ROW_WIDTH in total, so all of them share a right edge no
    matter which panel they are on. Tune these here and nowhere else.
]]

ns.OPTIONS_ROW_WIDTH = 3.4
ns.OPTIONS_LABEL_WIDTH = 2.1
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH

--[[
    A row inside a tree panel's pane (Character Rules): the character list on
    the left takes its share of the panel first. The control keeps the shared
    control width, so the dropdowns match every other panel's, and the label
    gives up the difference. MagicEraser's list panels use the same width.
]]
ns.OPTIONS_TREE_ROW_WIDTH = 2.5
ns.OPTIONS_TREE_LABEL_WIDTH = ns.OPTIONS_TREE_ROW_WIDTH - ns.OPTIONS_CONTROL_WIDTH

-- The action column of the Item Overrides and Openables lists.
ns.ROLL_ACTION_DROPDOWN_WIDTH = 0.7

-- The item lists' remove column, sized to its icon rather than a caption.
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25

-- The Openables List's reason column (Locked, Sell Sealed, May Hold Unique), taken from the item's share of the row.
ns.OPTIONS_ITEM_TAG_WIDTH = 0.65

-- Restore Defaults, at the foot of an item list, right-aligned: wide enough for its caption and no wider.
ns.OPTIONS_RESTORE_BUTTON_WIDTH = 1

--[[
    An item list's add box and its filter each take a line above the rows, in
    the label column: the add box first, sharing its line with Add from Bags in
    the control column, then the filter, sharing its line with the kind filter.
    The one width for both boxes stacks them in one column and keeps either from
    reading as the more important.
]]
ns.OPTIONS_ITEM_LIST_TOOL_WIDTH = ns.OPTIONS_LABEL_WIDTH

--[[
    The Loot Toasts Filters rows: a narrow caption column for the item type,
    then a Mine column and a Group column of one width each, so every Group box
    lines up whatever sits in the Mine column. A column holds its box, and on a
    rarity row the quality dropdown beside it.
]]
ns.OPTIONS_FILTER_LABEL_WIDTH = 1
ns.OPTIONS_FILTER_COLUMN_WIDTH = (ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_FILTER_LABEL_WIDTH) / 2
ns.OPTIONS_FILTER_BOX_WIDTH = 0.45
ns.OPTIONS_FILTER_QUALITY_WIDTH = ns.OPTIONS_FILTER_COLUMN_WIDTH - ns.OPTIONS_FILTER_BOX_WIDTH

--[[
    The blank cell a sub-option row leads with. AceConfig pins a checkbox at the
    left edge of its own widget, so padding the label indents the caption and
    leaves the box behind, lined up with its parent's; leading the row with this
    cell instead moves the box itself.

    Sized so the sub-option's box starts where its parent's box visually ends.
    That lands short of a full checkbox: AceGUI's checkbox is a 24px texture
    anchored flush left and the flow layout adds no gap between widgets, but
    UI-CheckBox-Up carries transparent padding, so the gold square the player
    actually sees is inset a couple of pixels inside that footprint. Matching the
    footprint (0.14) therefore reads as a step too far; this matches the square.
    Nudge here if the two edges drift apart on a different UI scale. Shared with
    MagicEraser, which sizes its Auto-Vend sub-options the same way.
]]
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115

-- The caption beside a sub-option's dropdown: one label column, less the indent it pays for.
ns.OPTIONS_SUB_LABEL_WIDTH = ns.OPTIONS_LABEL_WIDTH - ns.OPTIONS_SUB_INDENT_WIDTH

--[[
    A sub-option checkbox carries a short caption, so it takes one label column,
    which leaves room to spare rather than an exact fit: see ns.OptionsSubRow on
    why an exact fit is the one thing these must not do.
]]
ns.OPTIONS_SUB_TOGGLE_WIDTH = ns.OPTIONS_LABEL_WIDTH

-- AceConfigDialog draws one width unit as this many pixels: how a measured caption becomes a width, and a row the pop-up's.
ns.OPTIONS_PIXELS_PER_WIDTH_UNIT = 170

--[[
    The sound-preview speaker, sized to its icon, as Control Freak sizes its
    own. A sound row runs one speaker wider than the rest, because the speaker
    sits after its dropdown rather than inside the label. That is the one place
    a row is allowed past OPTIONS_ROW_WIDTH: an icon in the right margin costs
    nothing, where taking the room out of the label would push the sound
    dropdown out of the column every other dropdown lines up in.
]]
ns.OPTIONS_SPEAKER_WIDTH = 0.15

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
    The Loot Toasts panel's Filters rows, in panel order, each with a
    Mine box and a Group box (the saved lootToastMine and lootToastGroup
    tables, keyed by `key`). A row with `classIdentifier` is one of the game's
    item types and takes the client's own name for it; one with a subclass too
    is that subclass alone (Mount, Companion Pets), which the Miscellaneous row
    then leaves out. A `rarity` row carries a quality dropdown beside each
    ticked box (lootToastMineQuality, lootToastGroupQuality); every other row
    shows its items whatever their quality. `minimumExpansion` keeps a type off
    a client that has none of it. The last three are GogoLoot's own groupings,
    captioned from the locale (`labelKey`) or, for Money, with the client's own
    word (`label`), and Money has no Group box: the game reports no other
    player's coin. The item-type rows after the rarity ones are sorted by
    their client name as the panel is built.
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
}

--------------------------------------------------------------------------------
-- Automated Opening
--------------------------------------------------------------------------------

--[[
    Opening pauses below this many free general-purpose bag slots and resumes on
    reaching it, and Speedy Loot keeps the loot window up once a pass leaves
    fewer than this, so the two features share one line.
]]
ns.MIN_FREE_SLOTS = 4

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
    What Automated Opening does with each openable item, the two values of the
    Openables List dropdowns: Open, or Ignore, which leaves it alone.

    The player's choices are saved only where they differ from an item's
    default (see Features/Openable-Items.lua). OPENING_REMOVED is saved for a
    listed item the player took off the list, and is never a dropdown value.
]]
ns.OPENING_OPEN = "OPEN"
ns.OPENING_IGNORE = "IGNORE"
ns.OPENING_REMOVED = "REMOVED"

--[[
    Each flavor folder's ns.OPENABLE_ITEMS rows give an item's default, one of
    five: OPENING_OPEN; OPENING_UNLOCKED, a lockbox, opened once it is picked;
    OPENING_IGNORE_RAID, a raid boss drop; OPENING_IGNORE_UNIQUE, which may hold
    a unique item; or OPENING_IGNORE, which may hold Bind on Pickup loot. The
    last four carry a reason, which the Openables List shows as a tag on the
    row, whatever the player sets it to, and a looted container's notice gives.
]]
ns.OPENING_UNLOCKED = "UNLOCKED"
ns.OPENING_IGNORE_RAID = "IGNORE_RAID"
ns.OPENING_IGNORE_UNIQUE = "IGNORE_UNIQUE"

ns.OPENING_ACTION_LABELS = {
	[ns.OPENING_OPEN] = ns.L["OPENING_ACTION_OPEN"],
	[ns.OPENING_IGNORE] = ns.L["OPENING_ACTION_IGNORE"],
}

--[[
    Display order for the Openables List dropdowns, passed to AceConfig as
    `sorting`: without it the dropdown sorts by key, which puts Ignore first.
]]
ns.OPENING_ACTION_ORDER = {
	ns.OPENING_OPEN,
	ns.OPENING_IGNORE,
}

--------------------------------------------------------------------------------
-- Loot Sounds
--------------------------------------------------------------------------------

-- The rare-loot chime; play with PlaySoundFile.
ns.LOOT_SOUND_FILE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Sounds\\item-pick-up.ogg"

-- Seconds after a corpse or chest's loot window closes during which a loot message may still play the chime.
ns.LOOT_SOUND_WINDOW = 1

--[[
    Seconds a loot window may follow a Pick Pocket cast and still count as its
    haul. Pick Pocket's window opens at once, so this only has to span the
    cast-to-loot gap.
]]
ns.PICK_POCKET_LOOT_WINDOW = 1

--------------------------------------------------------------------------------
-- Loot Toasts
--------------------------------------------------------------------------------

-- Seconds the fade itself takes, once the chosen time on screen has passed.
ns.LOOT_TOAST_FADE_DURATION = 0.5

-- Seconds a toast stays up. Offered as a dropdown, so the steps widen as they grow.
ns.LOOT_TOAST_DURATIONS = { 1, 2, 3, 5, 8, 13, 21 }

--[[
    Most rows on screen at once, in the same widening steps so the two dropdowns
    read as a pair. Unlimited is stored as 0, a sentinel rather than a count, and
    the one value the cap code has to special-case: a literal cap of zero would
    retire every row on sight.
]]
ns.LOOT_TOAST_COUNTS = { 1, 2, 3, 5, 8, 13, 21 }
ns.LOOT_TOAST_UNLIMITED = 0

-- The dropdown beside Hide Roll Messages: GogoLoot's winner summary in place of the game's won line, or neither.
ns.WINNER_SUMMARY_PRINT = "PRINT"
ns.WINNER_SUMMARY_NONE = "NONE"

-- The dropdown beside Enable Loot Toasts: the game's own loot lines in General, off or kept (Standard Loot Messages).
ns.STANDARD_LOOT_MESSAGES_DISABLE = "DISABLE"
ns.STANDARD_LOOT_MESSAGES_ENABLE = "ENABLE"

--[[
    The face list comes from LibSharedMedia; only the sizes are ours, offered as
    a dropdown in steps of two, so the Text section's rows share one height. A
    size saved between the steps is offered too, so it still reads back.
]]
ns.LOOT_TOAST_FONT_SIZE_MIN = 8
ns.LOOT_TOAST_FONT_SIZES = { 8, 10, 12, 14, 16, 18, 20, 22, 24 }

--[[
    The client's own SetFont flag strings, in the order the dropdown offers them:
    the weight ladder first, then the two monochrome variants. "NONE" is ours,
    standing for the empty flag string SetFont wants instead of a name.
]]
ns.LOOT_TOAST_FONT_FLAGS = { "NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROMEOUTLINE" }

--[[
    One potion icon per item quality, color-matched to the quality it stands
    for, so a sample toast reads as that quality at a glance. Used only by the
    position preview; a real toast draws the looted item's own icon.
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

--[[
    Coin piles for the money toast, one per magnitude, so the icon says roughly
    how much before the digits are read.
]]
ns.MONEY_ICON_GOLD = "Interface\\Icons\\INV_Misc_Coin_02"
ns.MONEY_ICON_SILVER = "Interface\\Icons\\INV_Misc_Coin_04"
ns.MONEY_ICON_COPPER = "Interface\\Icons\\INV_Misc_Coin_06"

ns.COPPER_PER_SILVER = 100
ns.COPPER_PER_GOLD = 10000

--[[
    One color per coin, for the g/s/c suffixes while the numbers stay body white.
    These are the client's conventions rather than the add-on's, which is why
    they sit apart from ns.PALETTE: gold, silver and copper look the way they
    look in every money display in the game.
]]
ns.MONEY_PALETTE = {
	GOLD = "FFD700",
	SILVER = "C7C7CF",
	COPPER = "EDA55F",
}

--------------------------------------------------------------------------------
-- Trade Output Labels
--------------------------------------------------------------------------------

-- Maps the announceTradeOutput setting values to their display labels.
ns.TRADE_OUTPUT_LABELS = {
	["whisper"] = WHISPER,
	["group"] = ns.L["TRADE_OUTPUT_GROUP"],
	["self"] = ns.L["TRADE_OUTPUT_SELF"],
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
	AutomatedRolls = ADDON_NAME .. "_AutomatedRolls",
	ItemOverrides = ADDON_NAME .. "_ItemOverrides",
	CharacterRules = ADDON_NAME .. "_CharacterRules",
	MasterLooter = ADDON_NAME .. "_MasterLooter",
	MasterLooterIgnoreList = ADDON_NAME .. "_MasterLooterIgnoreList",
	AutomatedOpening = ADDON_NAME .. "_AutomatedOpening",
	OpenableItems = ADDON_NAME .. "_OpenableItems",
	LootToasts = ADDON_NAME .. "_LootToasts",
	LootToastFilters = ADDON_NAME .. "_LootToastFilters",
	LootSounds = ADDON_NAME .. "_LootSounds",
	Announcements = ADDON_NAME .. "_Announcements",
	-- Registered but never added to the Blizzard tree: it opens as its own window.
	MasterLooterPopup = ADDON_NAME .. "_MasterLooterPopup",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--[[
    Whether a panel's child panels nest beneath it in the Settings tree, a third
    level down, or sit as siblings right after it under the add-on, titled
    "Parent: Child" (TAB_NESTED_FORMAT). AceConfigDialog documents one child
    level only, so the nested form holds only where a client's Settings panel
    shows a third level; Options.lua registers either form from one table.
]]
ns.OPTIONS_NESTED_PANELS = true

ns.ITEM_LINK_WIDGET_TYPE = ADDON_NAME .. "_ItemLink"
ns.ITEM_LIST_FILTER_WIDGET_TYPE = ADDON_NAME .. "_ItemListFilter"
ns.ITEM_LIST_ADD_WIDGET_TYPE = ADDON_NAME .. "_ItemListAdd"

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
