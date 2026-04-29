local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages (printed to local chat frame via PrintMessage)
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Settings have been reset for this update. Use /gl to review your options."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "All settings have been reset to defaults."
L["MSG_AUTO_LOOT_ENABLED"] = "Auto Loot is required for GogoLoot to function properly. Auto Loot has been enabled."
L["MSG_NOT_MASTER_LOOTER"] = "You are not currently the Master Looter."

--------------------------------------------------------------------------------
-- Chat Announcement Templates (sent to other players via GogoLoot:Announce)
-- These are wrapped with MSG_PREFIX/MSG_SUFFIX by the Announce helper before
-- being passed to SendChatMessage. Format placeholders (%s) are filled with
-- the relevant arguments at call time.
--------------------------------------------------------------------------------

L["MSG_PREFIX"] = "{rt4} "
L["MSG_SUFFIX"] = " // GogoLoot"

L["MSG_LOOT_ANNOUNCE"] = "Gave %s to %s."
L["MSG_DESTINATION_SET"] = "%s will be receiving all the %s items."
L["MSG_DESTINATION_LEFT"] = "%s has left the group. %s will now be receiving all the %s items."

L["MSG_TRADE_GAVE_RECEIVED"] = "Gave %s to %s, received %s."
L["MSG_TRADE_GAVE"] = "Gave %s to %s."
L["MSG_TRADE_RECEIVED"] = "Received %s from %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors (sent to group via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["ERR_BAG_FULL"] = "The player you selected to receive that item has no space in their bags."
L["ERR_MAX_COUNT"] = "The player you selected to receive that item has too many of that item already."
L["ERR_OUT_OF_RANGE"] = "The player you selected to receive that item is not in range."
L["ERR_NOT_IN_GROUP"] = "The player you selected to receive that item is no longer in the party or raid."

--------------------------------------------------------------------------------
-- Options Panel Tab Names
--------------------------------------------------------------------------------

L["TAB_GENERAL"] = "GogoLoot"
L["TAB_AUTOMATED_ROLLS"] = "Automated Rolls"
L["TAB_MASTER_LOOTER"] = "Master Looter"
L["TAB_TRADE_ANNOUNCEMENTS"] = "Announcements"

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
L["COMMANDS_DESC"] = "Opens the GogoLoot options interface."

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
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements

L["TRADE_HEADER"] = "Trade Announcements"
L["TRADE_DESC"] = "Automatically posts a summary of completed trades to chat, including items, enchants, and gold exchanged."
L["TRADE_ENABLE"] = "Enable Trade Announcements"
L["TRADE_ENABLE_DESC"] = "Posts a trade summary when a trade completes."
L["TRADE_CONDITION"] = "When"
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

-- Master Looter Announcements

L["ML_ANNOUNCE_HEADER"] = "Master Looter Announcements"
L["ML_ANNOUNCE_DESC"] = "Posts master loot activity to group chat for transparency. Configure separate thresholds for automated and manual distributions so routine auto-loot doesn't spam chat while manual deviations stay visible."

L["ML_ANNOUNCE_DESTINATION"] = "Enable Messages when Master Looter is Set"
L["ML_ANNOUNCE_DESTINATION_DESC"] = "Announces when loot destinations are configured, and when a destination player leaves the group."
L["ML_ANNOUNCE_DESTINATION_EXAMPLE"] = "Example: {rt4} Aevala will be receiving all the Epic items. // GogoLoot"

L["ML_ANNOUNCE_AUTO"] = "Enable Automated Master Looting Announcements"
L["ML_ANNOUNCE_AUTO_DESC"] = "Announces items distributed automatically by GogoLoot."
L["ML_ANNOUNCE_AUTO_THRESHOLD"] = "Auto Announce Threshold"
L["ML_ANNOUNCE_AUTO_THRESHOLD_DESC"] = "Only announce automated distributions at or above this quality."

L["ML_ANNOUNCE_MANUAL"] = "Enable Manual Master Looting Announcements"
L["ML_ANNOUNCE_MANUAL_DESC"] = "Announces items distributed manually via the candidate dropdown. Defaulted lower than auto so deviations from the configured rules are visible to the group."
L["ML_ANNOUNCE_MANUAL_THRESHOLD"] = "Manual Announce Threshold"
L["ML_ANNOUNCE_MANUAL_THRESHOLD_DESC"] = "Only announce manual distributions at or above this quality."

L["ML_ANNOUNCE_EXAMPLE"] = "Example: {rt4} Gave [Item X] to Gogowarrior. // GogoLoot"

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

L["ML_IGNORE_HEADER"] = "Ignore List"
L["ML_IGNORE_DESC"] = "Items on this list will not be automatically distributed and will appear in a standard loot window for manual assignment."
L["ML_IGNORE_RESTORE"] = "Restore Default Ignore List"
L["ML_IGNORE_RESTORE_CONFIRM"] = "This will replace your master loot ignore list with the default items for your expansion. Continue?"
L["ML_IGNORE_ADD_DESC"] = "Enter an Item ID or paste an item link to add it to the ignore list."
L["ML_IGNORE_ADD"] = "Add Item"
L["ML_IGNORE_ADD_TOOLTIP"] = "Enter Item ID or drag an item here to add it to the list."
L["ML_IGNORE_REMOVE"] = "Remove"
L["ML_IGNORE_REMOVE_DESC"] = "Remove this item from the ignore list."