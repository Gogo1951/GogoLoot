local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Settings have been reset for this update. Use /gl to review your options."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "All settings have been reset to defaults."
L["MSG_CONFLICT_DETECTED"] = "Conflicting loot addons detected."
L["MSG_CONFLICT_ADDON"] = "Conflicting addon: %s"
L["MSG_AUTO_LOOT_ENABLED"] = "Auto Loot is required for GogoLoot to function properly. Auto Loot has been enabled."
L["MSG_NOT_MASTER_LOOTER"] = "You are not currently the Master Looter."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "Auto-Greed"
L["MINIMAP_AUTO_GREED_DESC"] = "Automatically rolls Greed on eligible items at or below the selected quality threshold."
L["MINIMAP_SPEEDY_LOOT"] = "Speedy Loot"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "Instantly picks up loot without showing the loot window."

L["MINIMAP_LEFT_CLICK"] = "Left-Click"
L["MINIMAP_RIGHT_CLICK"] = "Right-Click"
L["MINIMAP_TOGGLE"] = "Toggle"
L["MINIMAP_HINT"] = "Additional settings can be found under Options > AddOns > GogoLoot."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Poor"
L["QUALITY_COMMON"] = "Common"
L["QUALITY_UNCOMMON"] = "Uncommon"
L["QUALITY_RARE"] = "Rare"
L["QUALITY_EPIC"] = "Epic"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Manual Roll"
L["ROLL_GREED"] = "Greed"
L["ROLL_NEED"] = "Need"
L["ROLL_PASS"] = "Pass"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Free for All"
L["LOOT_METHOD_ROUND_ROBIN"] = "Round Robin"
L["LOOT_METHOD_MASTER"] = "Master Looter"
L["LOOT_METHOD_GROUP"] = "Group Loot"
L["LOOT_METHOD_NBG"] = "Need Before Greed"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Poor Only"
L["THRESHOLD_COMMON_LOWER"] = "Common & Lower"
L["THRESHOLD_UNCOMMON_LOWER"] = "Uncommon & Lower"
L["THRESHOLD_RARE_LOWER"] = "Rare & Lower"
L["THRESHOLD_EPIC_LOWER"] = "Epic & Lower"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "General"
L["GENERAL_DESC"] = "Core settings that apply whenever GogoLoot is active."
L["SPEEDY_LOOT"] = "Enable Speedy Loot"
L["SPEEDY_LOOT_DESC"] = "Instantly picks up loot without showing the loot window, saving time between kills."

L["COMMANDS"] = "/Commands"
L["COMMANDS_DESC_GL"] = "Opens the GogoLoot options interface."
L["COMMANDS_DESC_GOGOLOOT"] = "Opens the GogoLoot options interface."

L["RESET"] = "Reset"
L["RESET_DESC"] = "Clears all GogoLoot settings and restores every option to its default value."
L["RESET_ALL"] = "Reset All GogoLoot Options"
L["RESET_CONFIRM"] = "This will reset ALL GogoLoot settings to their defaults. This cannot be undone. Continue?"

L["FEEDBACK_SUPPORT"] = "Feedback & Support"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Loading... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "Automatically posts a summary of completed trades to chat, including items, enchants, and gold exchanged."
L["TRADE_ENABLE"] = "Enable Trade Announcements"
L["TRADE_ENABLE_DESC"] = "Posts a trade summary when a trade completes."
L["TRADE_CONDITION"] = "When in Group"
L["TRADE_CONDITION_DESC"] = "Controls when trade announcements are active."
L["TRADE_CONDITION_ALWAYS"] = "Always"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Only in Party or Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "Only in Raid"
L["TRADE_OUTPUT"] = "Message Output"
L["TRADE_OUTPUT_DESC"] = "Where the trade summary is sent."
L["TRADE_OUTPUT_WHISPER"] = "Whisper"
L["TRADE_OUTPUT_GROUP"] = "Party Chat"
L["TRADE_OUTPUT_RAID"] = "Raid Chat"
L["TRADE_EXAMPLE"] = "Example: {rt4} Gave [Item X] x2, [Item Y] to Fathom. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Trade Announcements"
L["TRADE_TOOLTIP_DESC"] = "Posts a trade summary to chat when this trade completes."
L["TRADE_TOOLTIP_OUTPUT"] = "Current Output"
L["TRADE_CHECKBOX_LABEL"] = "Announce"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Automatically rolls Greed on non-BoP items at or below the selected quality. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped. BoP items are never auto-greeded by the threshold, but can be automated via the Custom Roll List below."
L["ROLLS_ENABLE"] = "Enable Automated Rolls"
L["ROLLS_ENABLE_DESC"] = "Automatically rolls Greed on eligible items at or below the threshold."
L["ROLLS_THRESHOLD"] = "Automated Greed Threshold"
L["ROLLS_THRESHOLD_DESC"] = "Items at or below this quality will be automatically greeded."

L["ROLLS_CUSTOM_LIST"] = "Custom Roll List"
L["ROLLS_CUSTOM_LIST_DESC"] = "Items on this list have their own roll rule that overrides the threshold. This is the only way to automate BoP items like Scourgestones or Demonic Runes. Set each item to Manual Roll, Greed, Need, or Pass. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped regardless of setting."
L["ROLLS_RESTORE_DEFAULTS"] = "Restore Default Custom Roll List"
L["ROLLS_RESTORE_CONFIRM"] = "This will replace your custom roll list with the default items for your expansion. Continue?"
L["ROLLS_ADD_ITEM_DESC"] = "Enter Item ID or drag an item here to add it to the list."
L["ROLLS_ADD_ITEM"] = "Add Item"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Enter Item ID or drag an item link here."
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "Remove"
L["ROLLS_REMOVE_DESC"] = "Remove this item from the custom roll list."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Loot Type (read-only, change via Game Menu)"
L["ML_LOOT_THRESHOLD"] = "Loot Threshold (read-only, change via Game Menu)"

L["ML_AUTO_HEADER"] = "Automated Master Looting"
L["ML_AUTO_DESC"] = "Automatically distributes loot to designated players when you are the Master Looter. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped and will appear in a standard loot window."
L["ML_AUTO_ENABLE"] = "Enable Automated Master Looting In Instances"
L["ML_AUTO_ENABLE_DESC"] = "Distributes loot to configured destinations automatically."
L["ML_AUTO_OUTSIDE"] = "Enable Automated Master Looting Outside of Instances"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Caution : Due to world boss loot not being tradable, this is not advised!"

L["ML_DEST_HEADER"] = "Loot Destinations"
L["ML_DEST_DESC"] = "Assign a group member to receive items of each quality tier."
L["ML_DEST_SELF"] = "Self"
L["ML_DEST_CHOOSE"] = "Choose who receives %s items."

L["ML_ANNOUNCE_HEADER"] = "Loot Announcements"
L["ML_ANNOUNCE_DESC"] = "Posts a message to group chat when items are distributed via Master Loot. Manual distributions are always announced regardless of threshold."
L["ML_ANNOUNCE_ENABLE"] = "Enable Loot Announcements"
L["ML_ANNOUNCE_ENABLE_DESC"] = "Announces item distributions to group chat."
L["ML_ANNOUNCE_THRESHOLD"] = "Announce Threshold"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "Only announce items at or above this quality."
L["ML_ANNOUNCE_EXAMPLE"] = "Example: {rt4} Gave [Item X] to Gogowarrior. // GogoLoot"

L["ML_IGNORE_HEADER"] = "Ignore List"
L["ML_IGNORE_DESC"] = "Items on this list will not be automatically distributed and will appear in a standard loot window for manual assignment."
L["ML_IGNORE_RESTORE"] = "Restore Default Ignore List"
L["ML_IGNORE_RESTORE_CONFIRM"] = "This will replace your master loot ignore list with the default items for your expansion. Continue?"
L["ML_IGNORE_ADD_DESC"] = "Enter an Item ID or paste an item link to add it to the ignore list."
L["ML_IGNORE_ADD"] = "Add Item"
L["ML_IGNORE_ADD_TOOLTIP"] = "Enter Item ID or drag an item here to add it to the list."
L["ML_IGNORE_REMOVE"] = "Remove"
L["ML_IGNORE_REMOVE_DESC"] = "Remove this item from the ignore list."