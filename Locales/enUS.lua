local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "enUS", true)
if not L then
	return
end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names or the %s / %d
    placeholders: code and other locales rely on them. Chat Messages print as
    "GogoLoot // <message>", so each ends with its own punctuation. Chat
    Announcement Templates and the ERROR_ keys are sent as
    "{rt4} <message> // GogoLoot", with the marker and name added by code, so
    they take no closing period or other end punctuation.
]]

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

-- Brands every printed line, sent message, options panel, and report. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > GogoLoot. Enjoying the add-on? Tell a friend about it! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] = "Turned on the game's %s setting, which Speedy Loot and Automated Opening need."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "You are not currently the %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "Automated Opening is paused until you have at least %d free bag slots."
L["MESSAGE_OPENING_RESUMED"] = "Automated Opening has resumed."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s will open automatically once it is unlocked."
L["MESSAGE_ITEM_IGNORED"] = "%s is set to Ignore, so Automated Opening will leave it alone."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s comes from a raid or world boss, so Automated Opening will leave it unopened for you to trade or sell."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] = "%s may hold a unique item, so Automated Opening will leave it for you to open."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s was left in the loot window for you to loot yourself."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s would be equipped rather than opened, so it can't join the Openables List."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "You rolled %s on %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "You passed on %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s won %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s won %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "You won %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "You won %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Gave %s to %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Gave %s to %s, received %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Received %s from %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Gave %s to %s"
L["MESSAGE_DESTINATION_SET"] = "%s will be holding %s items for the group"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s will be holding all loot for the group"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s has left the group. %s will now be holding %s items for the group"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s has left the group. %s will now be holding all loot for the group"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Gave %s to %s, received %s"
L["MESSAGE_TRADE_RECEIVED"] = "Received %s from %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s's bags are full: %s"
L["ERROR_MAX_COUNT"] = "%s already has too many of: %s"
L["ERROR_OUT_OF_RANGE"] = "%s is out of range: %s"
L["ERROR_NOT_IN_GROUP"] = "%s is no longer in the party or raid: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Couldn't give loot to %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Automated Rolls"
L["TAB_ITEM_OVERRIDES"] = "Item Overrides"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Character Rules"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Announcements"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Trade Announcements"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Master Looter Announcements"
L["TAB_LOOT_TOASTS"] = "Loot Toasts"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filters"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Loot Sounds"
L["TAB_AUTOMATED_OPENING"] = "Automated Opening"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Lockboxes"
L["TAB_OPENABLE_ITEMS"] = "Openables List"
L["TAB_MASTER_LOOTER"] = "Master Looter"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Loot Destinations"
L["TAB_IGNORE_LIST"] = "Ignore List"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "Paused"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rolls for you on eligible items up to the quality you pick."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "Opens clams, crates, coin purses, and picked lockboxes in your bags."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "Posts trade summaries and master loot hand-outs to chat."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "Hands out loot to the players you picked for each quality."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Left-Click"
L["MINIMAP_RIGHT_CLICK"] = "Right-Click"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + Left-Click"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + Right-Click"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Automated Master Looting"
L["MINIMAP_TOGGLE"] = "Toggle"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Locked Items"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s Only"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s & Lower"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Add Item"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Enter an item ID or drag an item here to add it to the list."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Drop item here, or type item ID"
L["ITEM_LIST_ADD_BUTTON"] = "Add"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filter items..."
L["ITEM_LIST_FILTER_DESCRIPTION"] = "Shows only the items whose name, item ID, setting, or tag contains what you type."
L["ITEM_LIST_NO_MATCHES"] = "No items match your filter."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "New"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Show All Kinds of Items"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Shows every item on the list, or only the items of one kind."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Add from Bags"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Adds an item you carry to the list."
L["ITEM_LIST_BAGS_EMPTY"] = "Nothing in your bags to add"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Every item you carry is already on the list."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Restore Defaults"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Loading... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"It never rolls on recipes, books, mounts, pets, or legendaries, and rolls on Bind on Pickup or quest items only when they're on Item Overrides."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Recipes, books, mounts, pets, and legendaries are always left for you."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Example: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Version %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Speedy auto loot empties corpses without the loot window, auto rolls Need, Greed, or Pass by quality, and master looting hands out drops for you. Clams, containers, and unlocked lockboxes open on their own. Loot faster, pull sooner."
L["WELCOME_MESSAGE"] = "Enable Welcome Message"
L["WELCOME_MESSAGE_DESCRIPTION"] = "Shows GogoLoot's version and where to find these settings each time you log in."
L["MINIMAP_BUTTON_ENABLE"] = "Enable Mini-map Button"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Shows the GogoLoot button on the mini-map. Left-Click toggles Automated Rolls, Right-Click Automated Opening, Shift + Left-Click Announcements, and Shift + Right-Click Automated Master Looting."

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Features"

L["SPEEDY_LOOT_ENABLE"] = "Enable Speedy Loot"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Empties each corpse the moment you open it, without showing the loot window. Hold Shift as you loot to see the window instead. Turns on the game's %s setting, and stands down while you're %s."

L["FEEDBACK_SUPPORT"] = "Feedback & Support"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Group Loot Settings"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Sets how your group's loot is handed out. Only the group leader can change it."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Sets the lowest item quality the loot method applies to. Only the group leader can change it."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "These settings are controlled by %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Join a group to change these. Only the group leader can."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Hands each drop to the player you picked for its quality the moment you open the loot window, while you're %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Enable Automated Master Looting"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Turns automated hand-outs on or off. It works only inside dungeons and raids unless Also Outside Instances is on."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Also Outside Instances"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Also hands loot out in the open world. World boss loot isn't tradable, so this isn't advised."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Include Quest Items"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Hands out quest items too, for boosting a character you play yourself. Only works at a Common or lower loot threshold, and only for quest items that drop once for the whole group. Not advised in raids."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Quick Settings"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Opens these settings in a window whenever you become %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Enable Master Looter Pop-up"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Pick who gets each quality. A quality with nobody picked stays in the loot window for you."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Self"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Loot Window"
L["MASTER_LOOTER_SEND_ALL"] = "Send All Loot To"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Sets every quality below to one player."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Sets who receives %s items."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] = "Nobody is picked yet, so all loot waits in the loot window for you."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Items on this list are never handed out automatically. They wait in the loot window for you to hand out yourself."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] = "These settings aren't being used while Automated Master Looting is off."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] = "Replaces the Ignore List with the default items for your expansion."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"This will replace your Ignore List with the default items for your expansion. Continue?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Removes this item from the Ignore List."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Rolls %s, %s, or %s for you on group loot, up to the quality you pick, with separate settings for parties and raids."
L["ROLLS_ENABLE"] = "Enable Automated Rolls"
L["ROLLS_ENABLE_DESCRIPTION"] = "Turns automated rolling on or off, Item Overrides and Character Rules included."
L["ROLLS_IN_PARTY"] = "In Party"
L["ROLLS_IN_RAID"] = "In Raid"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Up to Quality"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: the highest quality GogoLoot rolls on."
L["ROLLS_ACTION_CHOOSE"] = "%s: the roll GogoLoot makes. Manual leaves the roll to you."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Loot Thresholds"
L["ROLLS_MESSAGES_HEADER"] = "Roll Messages"
L["ROLLS_PRINT_ITEM"] = "Print Item in Chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Prints each item GogoLoot rolls on, and the roll it made, in your chat. The roll window closes as soon as GogoLoot rolls, so this is your record of what came up."
L["ROLLS_HIDE_MESSAGES"] = "Hide Roll Messages"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Hides the game's chat lines for each roll: who picked %s, %s, or %s, and every number rolled. What each winner received stays in chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Print Winner Summary"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Don't Print Winner Summary"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Print Winner Summary puts one line in chat for each win, naming the winner, the item, and the winning roll, in place of the game's own line. Don't Print Winner Summary leaves the game's line saying who won."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Sets the roll for specific items, ahead of the quality settings. It's the only way GogoLoot will roll on a Bind on Pickup or quest item."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "These settings aren't being used while Automated Rolls is off."
L["ITEM_OVERRIDES_ENABLE"] = "Enable Item Overrides"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Uses the rolls set below. With it off, these items follow the quality settings like any other."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "Replaces your Item Overrides with the default items for your expansion."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"This will replace your Item Overrides with the default items for your expansion. Continue?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Sets the automatic roll for this item."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Removes this item from Item Overrides."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Remove this item and its roll action from Item Overrides?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Leaves gear with the stats you pick to you, character by character: set %s to Manual on your %s, and %s gear keeps its roll window while everything else rolls as usual. Item Overrides still come first."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Primary Attributes"
L["CHARACTER_RULES_SECONDARY"] = "Secondary Attributes"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Standard Automated Roll"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manual leaves gear with it to you on this character, roll window and all. Standard Automated Roll rolls it like any other item."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Posts trade summaries and master loot hand-outs to chat, so everyone knows where the loot went."
L["ANNOUNCEMENTS_ENABLE"] = "Enable Announcements"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Turns every announcement on or off. While it's off, GogoLoot sends nothing to your group or trade partners, not even items you hand out yourself."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Posts a summary of each completed trade: items, enchants, and gold."
L["TRADE_ENABLE"] = "Enable Trade Announcements"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Posts a summary when a trade completes. The Announce box on the trade window is this same switch."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Chooses when trade summaries are posted: always, when in a party or raid, or when in a raid."
L["TRADE_CONDITION_ALWAYS"] = "Always"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "When in Party or Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "When in Raid"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Channel"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s sends each summary to your trade partner. Group Chat posts it to your party or raid, and whispers it anyway outside a group. Me Only prints it in your own chat and sends it to nobody."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Group Chat"
L["TRADE_OUTPUT_SELF"] = "Me Only"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Posts a trade summary to chat when this trade completes."
L["TRADE_CHECKBOX_LABEL"] = "Announce"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Tells your group who's holding each quality and what you've handed out."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Enable Destination Announcements"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Tells the group who is holding each quality whenever you set a destination."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Enable Automated Hand-out Announcements"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Announces each item GogoLoot hands out automatically, at or above the quality you pick."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] = "Automated hand-outs below this quality go unannounced."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Enable Manual Hand-out Announcements"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Announces each item you hand out yourself from the %s menu, whatever its quality, worded like an automated hand-out. A hand-out that fails is reported either way."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Shows each item and coin you loot on screen for a few seconds, so nothing slips past while Speedy Loot hides the loot window. While they're on, the game's own loot lines can leave your %s chat tab."
L["LOOT_TOASTS_ENABLE"] = "Enable Loot Toasts"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = "Shows a toast for the loot you pick under Filters, yours and your group's."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Disable Standard Loot Messages"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Enable Standard Loot Messages"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Disable turns off %s and %s in your %s chat tab while Loot Toasts is on, and turning Loot Toasts off brings them back. It's the same setting as in that tab's Settings, and other tabs keep their own."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Stack"
L["LOOT_TOASTS_TEXT_HEADER"] = "Text"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "These settings aren't being used while Loot Toasts is off."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Pick what gets a toast, and what it says, for your own loot and your group's. Your group's loot shows the looter's name beside it."
L["LOOT_TOASTS_FILTER_MINE"] = "Mine"
L["LOOT_TOASTS_FILTER_GROUP"] = "Group"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Shows the %s items you loot."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Shows the %s items anyone in your party or raid loots, with the looter's name."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] = "Shows the %s items you loot, at or above the quality beside it."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Shows the %s items anyone in your party or raid loots, at or above the quality beside it, with the looter's name."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] = "The lowest quality of %s items you loot that gets a toast."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] = "The lowest quality of %s items your group loots that gets a toast."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Bind on Pickup"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Shows every Bind on Pickup item you loot, whatever its type or quality."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Shows every Bind on Pickup item your group loots, whatever its type or quality."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Openables"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Shows the containers you loot that GogoLoot can open, lockboxes included, whatever their quality."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Shows the containers your group loots that GogoLoot can open, lockboxes included, whatever their quality."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Shows a toast for the coins you loot. The game doesn't report other players' coin, so there is no Group box."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Winning Roll"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "Adds the roll you won an item with to its toast, like (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Adds the roll a group member won an item with to their toast, like (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Bag Count"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Adds how many you now carry to the toasts for your own loot, like x3 (27), once you carry more than the toast's own count."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Maximum Toasts"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] = "The most toasts on screen at once; the oldest one leaves to make room."
L["LOOT_TOASTS_UNLIMITED"] = "Unlimited"
L["LOOT_TOASTS_DURATION"] = "Seconds on Screen"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "How many seconds each toast stays before it fades."
L["LOOT_TOASTS_GROWTH"] = "Grow Direction"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "Whether older toasts move up or down, away from the newest one."
L["LOOT_TOASTS_GROW_UP"] = "Grow Up"
L["LOOT_TOASTS_GROW_DOWN"] = "Grow Down"
L["LOOT_TOASTS_ALIGN"] = "Align Items"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "Which side of the handle the toasts line up on."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Left"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Right"

-- Text
L["LOOT_TOASTS_FONT"] = "Font"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "The font toasts are written in."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Default"
L["LOOT_TOASTS_FONT_SIZE"] = "Font Size"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "The size of the toast text; the icons grow and shrink with it."
L["LOOT_TOASTS_OUTLINE"] = "Font Outline"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"The outline drawn around toast text, which keeps it readable over bright scenery."
L["LOOT_TOASTS_OUTLINE_NONE"] = "None"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Outline"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Thick Outline"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monochrome"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Monochrome Outline"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Unlock Position"
L["LOOT_TOASTS_LOCK"] = "Lock Position"
L["LOOT_TOASTS_RESET"] = "Reset Position"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Shows or hides the handle for dragging the toasts to a new spot."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Moves the toasts back to their default spot above the center of the screen."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "GogoLoot Loot Toasts"
L["LOOT_TOASTS_CLICK_DRAG"] = "Click + Drag to Position"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Right-Click to Lock"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Disable Loot Toasts"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Example Item"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Plays a chime for loot at or above the quality you pick, and a bag sound when %s takes something."
L["LOOT_SOUNDS_ENABLE"] = "Enable Loot Sound"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Plays a chime when you loot an item from a corpse or chest at or above the quality you pick."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "The lowest item quality that plays the loot sound."
L["LOOT_SOUNDS_TEST"] = "Plays the loot sound."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Enable %s Sound"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Plays a bag sound when %s actually takes something."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Plays the %s sound."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Opens clams, crates, coin purses, and picked lockboxes in your bags for you, whenever you have at least %d free bag slots."
L["AUTOMATED_OPENING_ENABLE"] = "Enable Automated Opening"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Opens one container at a time, and holds off in combat, mid-cast, in stealth, or while a vendor, bank, mailbox, auction house, or trade window is open. Turns on the game's %s setting while enabled."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Only Outside Instances"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Holds off opening anything while you're in a dungeon, raid, or battleground."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Only While Solo"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "Holds off opening anything while you're in a party or raid."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"A lockbox won't open until a %s picks it. These show the %s skill each one needs, and tell you when one is waiting."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Enable Lockbox Tooltips"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Adds the %s skill each lockbox needs to its tooltip."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Sets whether lockbox tooltips appear only for Rogues or for every character."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Enable Lockbox Notifications"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Tells you in chat when you loot a lockbox that will open once it is unlocked."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Sets whether lockbox notifications appear only for Rogues or for every character."
L["LOCKBOXES_FOR_ROGUES"] = "For Rogues"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "For All Characters"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Your %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Enable Ignore Notifications"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Tells you in chat when GogoLoot leaves a container alone because the Openables List says Ignore, and why."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Every container GogoLoot knows, and what Automated Opening does with it. Ignore keeps a container sealed, and Speedy Loot leaves it in the loot window for you. Your changes apply to all of your characters."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Only Ignore is being used while Automated Opening is off: it still keeps Speedy Loot from taking these."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Puts the list back to its defaults: every item returns to its default setting, removed items come back, and added items leave."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Put the list back to its defaults? Every setting you changed, and every item you added or removed, will be undone."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Enter an item ID or drag an item here to add it to the list, set to Open. Gear and bags can't be added, since using one equips it."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Adds an item you carry to the list, set to Open. Gear and bags aren't offered, since using one equips it."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Removes this item from the list. GogoLoot then treats it as an ordinary item: never opened, and looted like any other."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "Remove this item from the list? Add it again to bring it back."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Sets what Automated Opening does with this container."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Open"
L["OPENING_ACTION_IGNORE"] = "Ignore"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Sell Sealed"
L["OPENING_TAG_UNIQUE"] = "May Hold Unique"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] = "Needs a %s to pick it. Once it's picked, it opens like any other container."
L["OPENING_REASON_RAID"] =
	"Dropped by a raid or world boss. An unopened container can still be traded or sold, often for more than what is inside."
L["OPENING_REASON_BIND_ON_PICKUP"] = "Can hold Bind on Pickup loot. Sealed, it can still be traded or sold."
L["OPENING_REASON_UNIQUE"] = "May hold a unique item. Opening it fails with an error while you already carry one."
