local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "enUS", true)
if not L then
	return
end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > GogoLoot. Enjoying the add-on? Tell a friend about it! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "Auto Loot has been enabled. Speedy Loot requires it to function."
L["MESSAGE_NOT_MASTER_LOOTER"] = "You are not currently the Master Looter."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Gave %s to %s."
L["MESSAGE_DESTINATION_SET"] = "%s will be holding %s items for the group."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s will be holding all loot for the group."
L["MESSAGE_DESTINATION_LEFT"] = "%s has left the group. %s will now be holding %s items for the group."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Gave %s to %s, received %s."
L["MESSAGE_TRADE_RECEIVED"] = "Received %s from %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s's bags are full: %s"
L["ERROR_MAX_COUNT"] = "%s already has too many of: %s"
L["ERROR_OUT_OF_RANGE"] = "%s is out of range: %s"
L["ERROR_NOT_IN_GROUP"] = "%s is no longer in the party or raid: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Couldn't give %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Master Looter"
L["TAB_AUTOMATED_ROLLS"] = "Automated Rolls"
L["TAB_ANNOUNCEMENTS"] = "Announcements"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rolls for you on eligible items up to your chosen quality."

L["MINIMAP_LEFT_CLICK"] = "Left-Click"
L["MINIMAP_RIGHT_CLICK"] = "Right-Click"
L["MINIMAP_TOGGLE"] = "Toggle"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Poor"
L["QUALITY_COMMON"] = "Common"
L["QUALITY_UNCOMMON"] = "Uncommon"
L["QUALITY_RARE"] = "Rare"
L["QUALITY_EPIC"] = "Epic"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Manual"
L["ROLL_GREED"] = "Greed"
L["ROLL_NEED"] = "Need"
L["ROLL_PASS"] = "Pass"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Free for All"
L["LOOT_METHOD_ROUND_ROBIN"] = "Round Robin"
L["LOOT_METHOD_MASTER"] = "Master Looter"
L["LOOT_METHOD_GROUP"] = "Group Loot"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Need Before Greed"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Poor Only"
L["THRESHOLD_COMMON_LOWER"] = "Common & Lower"
L["THRESHOLD_UNCOMMON_LOWER"] = "Uncommon & Lower"
L["THRESHOLD_RARE_LOWER"] = "Rare & Lower"
L["THRESHOLD_EPIC_LOWER"] = "Epic & Lower"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Add Item"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Enter Item ID or drag an item here to add it to the list."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Loading... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Version"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Vacuum up gear with Automated Master Looting, Automated Rolls, and transparent Distribution Announcements. Quest items, recipes, mounts, pets, and legendaries stay safe. Don't let loot slow down your zug!"
L["WELCOME_MESSAGE"] = "Enable Welcome Message"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Mini-map Button"

L["COMMANDS"] = "/Commands"
L["COMMANDS_DESCRIPTION"] = "Opens the GogoLoot options interface."

L["SPEEDY_LOOT_HEADER"] = "Speedy Loot"
L["SPEEDY_LOOT_DESCRIPTION"] = "Hides the loot window for near-instant looting."
L["SPEEDY_LOOT_ENABLE"] = "Enable Speedy Loot"

L["FEEDBACK_SUPPORT"] = "Feedback & Support"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Your group's current loot method and loot threshold."
L["MASTER_LOOTER_LOOT_METHOD"] = "Loot Method"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Loot Threshold"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "Automated Master Looting"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"Distributes loot to your designated players while you're Master Looter. Quest items, recipes, books, mounts, pets, and legendaries are always skipped."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Enable Automated Master Looting in Instances"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Enable Automated Master Looting Outside of Instances"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Caution: world boss loot isn't tradable, so this isn't advised."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Quick Settings"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] = "Opens a window to set up loot whenever you become Master Looter."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Enable Master Looter Pop-up"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Loot Destinations"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Assign a group member to receive items of each quality tier."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Self"
L["MASTER_LOOTER_SEND_ALL"] = "Send All Loot To"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Send every quality tier to one player. Set individual tiers below to override."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Choose who receives %s items."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Ignore List"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Listed items skip auto-distribution and are left for manual assignment."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restore Default Ignore List"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"This will replace your master loot ignore list with the default items for your expansion. Continue?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Remove this item from the ignore list."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Rolls for you on non-BoP items up to your chosen quality, in parties and raids alike. Quest items, recipes, books, mounts, pets, and legendaries are always skipped."
L["ROLLS_ENABLE"] = "Enable Automated Rolls"
L["ROLLS_THRESHOLD_HEADER"] = "Thresholds"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Set the quality ceiling and the roll GogoLoot makes for you, separately for parties and raids."
L["ROLLS_IN_PARTY"] = "In Party"
L["ROLLS_IN_RAID"] = "In Raid"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: auto-roll on items of this quality and lower."
L["ROLLS_ACTION_CHOOSE"] = "%s: which roll GogoLoot makes for you, or whether it leaves the roll to you."

L["ROLLS_CUSTOM_LIST"] = "Custom Roll List"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Give specific items their own roll action, overriding the threshold."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Enable Custom Roll List"
L["ROLLS_RESTORE_DEFAULTS"] = "Restore Default Custom Roll List"
L["ROLLS_RESTORE_CONFIRM"] =
	"This will replace your custom roll list with the default items for your expansion. Continue?"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE_DESCRIPTION"] = "Remove this item from the custom roll list."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Trade Announcements"
L["TRADE_DESCRIPTION"] = "Posts a summary of each completed trade: items, enchants, and gold."
L["TRADE_ENABLE"] = "Enable Trade Announcements"
L["TRADE_CONDITION"] = "When"
L["TRADE_CONDITION_ALWAYS"] = "Always"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Only in Party or Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "Only in Raid"
L["TRADE_OUTPUT"] = "Message Output"
L["TRADE_OUTPUT_WHISPER"] = "Whisper"
L["TRADE_OUTPUT_GROUP"] = "Group Chat"
L["TRADE_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] x2, [Item Y] to Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Posts a trade summary to chat when this trade completes."
L["TRADE_TOOLTIP_OUTPUT"] = "Current Output"
L["TRADE_CHECKBOX_LABEL"] = "Announce"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Posts master loot activity to group chat. Automated distributions use a quality threshold to avoid spam; manual distributions are always announced."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Enable Loot Destination Messages"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"Example: {rt4} GogoLoot // Aevala will be holding Epic items for the group."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Enable Automated Master Looting Announcements"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Auto Announce Threshold"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Note: Every item distributed manually is always announced, regardless of quality."
