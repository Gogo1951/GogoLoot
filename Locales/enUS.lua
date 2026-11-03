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
	"Version %s. Settings (including the option to disable this message) are under Options > AddOns > GogoLoot. Enjoying this add-on? Tell a friend, Favorite it on CurseForge, or Star it on GitHub. (="
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
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] = "Turned off %s and %s in your %s chat tab while Loot Toasts is on."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "Turned %s and %s back on in your %s chat tab."

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Speedy Loot"
L["TAB_AUTOMATED_ROLLS"] = "Automated Rolls"
L["TAB_ITEM_OVERRIDES"] = "Item Overrides"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Character Rules"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Loot Announcements"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Trade Announcements"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Master Looter Announcements"
L["TAB_LOOT_TOASTS"] = "Loot Toasts"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filters"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Loot Sounds"
L["TAB_AUTOMATED_OPENING"] = "Automated Opening"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Lockboxes"
L["TAB_OPENABLE_ITEMS"] = "Openables List"
-- The last feature panel, named for its switch, Enable Automated Master Looting.
L["TAB_MASTER_LOOTER"] = "Automated Master Looting"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Loot Destinations"
L["TAB_IGNORE_LIST"] = "Ignore List"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Roll Macro"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Loot Master"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rolls for you on eligible items up to the quality you pick."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "Opens clams, crates, coin purses, and unlocked lockboxes in your bags."
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
L["MINIMAP_TOGGLE"] = "Toggle"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Locked Items"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Tradable Loot"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "%d more"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Loot Master & Loot Tracker"
L["MINIMAP_TO_HAND_OUT"] = "%d to hand out"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Hand out what you can still trade by roll, and follow every roll."
L["MINIMAP_MIDDLE_CLICK"] = "Middle-Click"
L["MINIMAP_OPEN"] = "Open"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s Only"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s & Lower"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

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

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Speedy auto loot empties corpses without the loot window, auto rolls Need, Greed, or Pass by quality, and master looting hands out drops for you. Clams, containers, and unlocked lockboxes open on their own. Loot faster, pull sooner."
L["WELCOME_MESSAGE"] = "Enable Welcome Message"
L["WELCOME_MESSAGE_DESCRIPTION"] = "Shows GogoLoot's version and where to find these settings each time you log in."
L["MINIMAP_BUTTON_ENABLE"] = "Enable Mini-map Button"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Shows the GogoLoot button on the mini-map. Left-Click toggles Automated Rolls, Right-Click Automated Opening, Shift + Left-Click Loot Announcements, and Shift + Right-Click Automated Master Looting."

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Features"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Takes everything from a corpse the moment you open it, so you never wait on the loot window."
L["SPEEDY_LOOT_ENABLE"] = "Enable Speedy Loot"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Empties each corpse the moment you open it, without showing the loot window. Hold Shift as you loot to see the window instead. Turns on the game's %s setting, and stands down while you're %s."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Adds a macro named %s, with a gold coins icon, to your General Macros, so every character on your account can drag it to an action bar."
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Roll 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Roll 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Raid Roll"
L["ROLL_MACRO_ENABLE"] = "Enable Roll Macro"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"A raid roll hands an item to someone at random. It rolls from 1 to the number of players in your group, so each number stands for one player: count down your raid or party list to the number rolled to find the winner. On your own, it rolls 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Keeps the %s macro in your General Macros: Left-Click rolls 1-100, Right-Click 1-99, Middle-Click a raid roll. Switching this off deletes it."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "The %s macro is in your General Macros. Type %s and drag it to an action bar."
L["ROLL_MACRO_REMOVED"] = "The %s macro has been deleted."
L["ROLL_MACRO_FULL"] =
	"Couldn't add the %s macro: your General Macros are full. Delete one, and it's added the next time you log in."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Help GogoLoot Level Up"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"This add-on was built by players who love this game and want to make it as fun as possible for everyone. We'll never ask for donations. The real satisfaction comes from knowing our work makes the game a little better for you. If it does, we'd love to hear about it!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Here are a few ways you can help us reach more players."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Share Feedback: Found a bug or have an idea? Let us know on Discord. Your feedback helps us improve the add-on, and pull requests are always welcome."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Tell a Friend: Know someone who might enjoy this add-on? Tell them about it. Word of mouth helps more players discover great add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorite on CurseForge: Open the CurseForge link below, sign in, and click the star beneath the Download button. Favorites help more players discover the add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star on GitHub: Open the GitHub link below, sign in, and click Star in the top right. Stars help the project qualify for more free developer tools."
L["OPTIONS_LEVEL_UP_THANKS"] = "Thanks for choosing GogoLoot!"

L["OPTIONS_FEEDBACK"] = "Feedback & Support"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Feedback & Support Links"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "To copy a link, click its box, then press Ctrl+A and Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Version %s"

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
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
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
L["ANNOUNCEMENTS_ENABLE"] = "Enable Loot Announcements"
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
	"Shows a toast for the coins you loot. The game doesn't report other players' coins, so there is no Group box."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Winning Roll"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "Adds the roll you won an item with to its toast, like (You Won, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Adds the roll a group member won an item with to their toast, like (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (You Won, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Bag Count"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Adds how many you now carry to the toasts for your own loot, like x3 (27), once you carry more than the toast's own count."
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
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Enable Loot Sounds"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Turns all of GogoLoot's loot sounds on or off."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Enable Loot Chime"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Plays a chime when you loot an item from a corpse or chest at or above the quality you pick."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "The lowest item quality that plays the loot chime."
L["LOOT_SOUNDS_TEST"] = "Plays the loot chime."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Enable %s Sound"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Plays a bag sound when %s actually takes something."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Plays the %s sound."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Opens clams, crates, coin purses, and unlocked lockboxes in your bags for you, whenever you have at least %d free bag slots."
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
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] = "Lockbox notifications aren't being used while Automated Opening is off."
L["LOCKBOXES_FOR_ROGUES"] = "For Rogues"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "For All Characters"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
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
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] = "These settings aren't being used while Automated Opening and Speedy Loot are off."
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

--------------------------------------------------------------------------------
-- Roll Calls: Sent to the Group
--------------------------------------------------------------------------------

--[[
    What the Loot Master sends when it calls a roll, in the sent format: no
    closing period, since the add-on name follows. Item arguments are links.
    Calls, ties and pauses go to Raid Warning where the player can send one;
    results go to group chat.
]]
-- Arguments: the item, then the roll's length in seconds.
L["ROLL_CALL_START"] = "Roll for %s with /roll, %d seconds"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "%d seconds left on %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d more seconds on %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Not counted on %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s's early roll (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s's extra roll (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s's %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s's %d (not in the tie-break)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s tied at %d on %s. %s only, /roll again, %d seconds"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s tied at %d on %s. A tie-break is coming"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s wins %s with %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "%s now wins %s with %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Nobody rolled on %s. It stays on my list for now"
L["ROLL_CALL_NOBODY_LEFT"] = "No roll on %s still counts. It goes back on my list"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "I disqualified %s's roll of %d on %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "I disqualified %s's roll of %d on %s: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "I restored %s's roll of %d on %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "I voided every roll on %s. Roll again with /roll, %d seconds"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Roll for %s canceled. Hold your rolls"
L["ROLL_CALL_PAUSED"] = "Hold your rolls. %s is on pause"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Rolls back on for %s, %d seconds left"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Rolling these off in order: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Up for roll: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Floor loot up for roll: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "You're not in a group, so this went to nobody: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] = "%s won %s. Open a trade with them and GogoLoot puts it in the window."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Rolled before the call"
L["ROLL_TAG_LATE"] = "Rolled after the close"
L["ROLL_TAG_REPEAT"] = "Extra roll, doesn't count"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Wrong range (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Not in the tie-break"
L["ROLL_TAG_DISQUALIFIED"] = "Disqualified"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Disqualified: %s"
L["ROLL_TAG_WINNER"] = "Winner"
L["ROLL_TAG_HIGHEST"] = "Highest so far"
L["ROLL_TAG_TIED"] = "Tied"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Not eligible for this item"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Already won an item tonight"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Rolled for someone else"
L["ROLL_DISQUALIFY_REASON_NONE"] = "No reason given"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Roll List (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Floor Loot (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Awarded (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Soft Reserves"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Roll"
L["LOOT_MASTER_ROLL_AGAIN"] = "Roll Again"
L["LOOT_MASTER_ROLL_ALL"] = "Roll All"
L["LOOT_MASTER_PAUSE"] = "Pause"
L["LOOT_MASTER_RESUME"] = "Resume"
L["LOOT_MASTER_STOP"] = "Stop"
L["LOOT_MASTER_LIST_IN_RAID"] = "List in Raid"
L["LOOT_MASTER_MOVE_UP"] = "Move Up"
L["LOOT_MASTER_MOVE_DOWN"] = "Move Down"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d Seconds"
L["LOOT_MASTER_CLOSE_NOW"] = "Close Now"
L["LOOT_MASTER_VOID"] = "Void All Rolls"
L["LOOT_MASTER_CANCEL_ROLL"] = "Cancel Roll"
L["LOOT_MASTER_TAKE_OFF"] = "Take Off the List"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Give to %s"
L["LOOT_MASTER_TRADE"] = "Trade %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Announce Winner"
L["LOOT_MASTER_HANDED_OUT"] = "Mark Handed Out"
L["LOOT_MASTER_REROLL_TIED"] = "Re-roll Tied"
L["LOOT_MASTER_DISQUALIFY"] = "Disqualify"
L["LOOT_MASTER_RESTORE"] = "Restore"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "On Corpse"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Corpse Closed"
L["LOOT_MASTER_BOUND"] = "Bound"
L["LOOT_MASTER_NO_LIMIT"] = "No Limit"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "Rolling, %d rolls"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Tie-break, %d rolls"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "On hold, %d rolls"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Tied"
L["LOOT_MASTER_STATUS_NOBODY"] = "Nobody rolled"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Soulbound now"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "Up next"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Rolling, %d seconds left."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "On hold with %d seconds left."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Tie-break for %s, %d seconds left."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s won with %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s tied at %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Soulbound now, so it can no longer be traded."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Looted from %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "From Floor Loot."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Tradable for %s more."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Rolls so far"
L["LOOT_MASTER_ROUND_ROLLS"] = "Rolls"
L["LOOT_MASTER_ROUND_FIRST"] = "First roll"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Tie-break"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Hasn't rolled (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Nothing to hand out yet. Tradable loot you pick up lands here on its own; Alt-Click any other bag item to add it."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "Paused."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Roll All: %d to go."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "One roll at a time."
L["LOOT_MASTER_STATE_WAITING"] = "%d waiting for a roll."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d to hand out."
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d to hand out, next trade window closes in %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt-Click a bag item to add it"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Disqualify a Roll"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "Take %s's roll of %d out of the running for %s? You can restore it later."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Reason"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot tells the group:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "Throw out every roll on %s and call for rolls again?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "Roll All is done. Every item on the Roll List has had its roll."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "Roll All paused. Nothing new starts until you press Resume."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Roll All resumed."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Roll All stopped. A roll in progress still finishes."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s can be traded for %d more minutes."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s can no longer be traded."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "Put %s in the trade window for %s, who won it with %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s can't be given %s from this corpse."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s joined the Roll List."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s can't be traded, so it can't go on the Roll List."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Floor Loot items joined the Roll List: %d."
L["LOOT_MASTER_OFF"] = "The Loot Master is off. Turn it on under Options > AddOns > GogoLoot > Loot Master."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "On the Roll List."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Won by %s with %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Loot with no trade clock that you want to roll off: mats, recipes, Bind on Equip gear. It starts empty, so only what you add gets rolled. One roll per stack."
L["LOOT_MASTER_FLOOR_EMPTY"] = "Nothing here yet. Pick from Add from Bags, or drop an item on the box above."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "%d in bags"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "On Roll List"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Takes this item off Floor Loot."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Other"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Add All to Roll List"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Picked up in this instance"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Also in your bags"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Nothing tradable in your bags matches "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] = "Nothing handed out yet. A won item lands here once its winner has it."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Rolled %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Handed out %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Clear"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Paste a soft-reserve string here to see who reserved what. Coming soon: this tab is a placeholder for now."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "Soft-reserve import isn't ready yet."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Import"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Loot Tracker"
L["LOOT_TRACKER_TAB_ROLLS"] = "Rolls"
L["LOOT_TRACKER_TAB_DROPS"] = "Drops"
L["LOOT_TRACKER_NO_ROLL"] = "No roll yet tonight."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Called by %s"
L["LOOT_TRACKER_SPOTTED"] = "Spotted in chat from %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "%ds left"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s isn't running GogoLoot, so these are the rolls seen in chat, checked by the usual rules: 1-100, first roll only. The caller has the final say."
L["LOOT_TRACKER_ON_HOLD"] = "On hold. Wait for the call to roll again."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Tie-break rolls"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s won with %d"
L["LOOT_TRACKER_CLOSED"] = "Closed"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Highest"
L["LOOT_TRACKER_SORT_TIME"] = "As Rolled"
L["LOOT_TRACKER_ROLL"] = "Roll (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "You"
L["LOOT_TRACKER_YOU_ROLLED"] = "You rolled %d."
L["LOOT_TRACKER_YOU_PASSED"] = "You passed."
L["LOOT_TRACKER_NOT_ROLLED"] = "You haven't rolled."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Only the tied players roll now."
L["LOOT_TRACKER_EARLIER"] = "Earlier tonight"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "roll"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Show Who Got What"
L["LOOT_TRACKER_DROPS_EMPTY"] = "No drops seen yet. They show up here as bosses die and corpses are looted."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Nobody with GogoLoot has looted it yet."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Not handed out yet"
L["LOOT_TRACKER_PRINT"] = "Print"
L["LOOT_TRACKER_POST"] = "Post to Raid"
L["LOOT_TRACKER_COPY"] = "Copy"
L["LOOT_TRACKER_COPY_TITLE"] = "Copy with Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Trash"
L["DROPS_NONE"] = "No drops recorded yet."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Drops in %s:"
-- Arguments: the boss, then its drops, joined by commas.
L["DROPS_PRINT_LINE"] = "%s: %s."
-- An item and who got it. Arguments: the item, then the winner (with their roll, below).
L["DROPS_WINNER"] = "%s (%s)"
-- Arguments: the winner, then their winning roll.
L["DROPS_WINNER_ROLL"] = "%s %d"

--------------------------------------------------------------------------------
-- Options: Loot Master
--------------------------------------------------------------------------------

L["LOOT_MASTER_PANEL_DESCRIPTION"] =
	"Hand out what you can still trade by roll, with the trade clock on each item, and follow every roll in the Loot Tracker. Middle-Click the mini-map button, or type /gogo master or /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Enable Loot Master"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Tracks the loot you can still trade and calls for rolls on it. Off, the Loot Master and Loot Tracker never open and no roll is read."
L["LOOT_MASTER_OPEN"] = "Open Loot Master"
L["LOOT_TRACKER_OPEN"] = "Open Loot Tracker"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d Seconds"
L["LOOT_MASTER_MINUTES"] = "%d Minutes"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Calling Rolls"
L["LOOT_MASTER_ROLL_LENGTH"] = "Roll Length"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "How long a roll stays open."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Announce In"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Where calls for rolls, ties and pauses go."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Group Chat"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"Raid Warning falls back to group chat when you aren't leader or assistant. Winners always go to group chat."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Warn at %d Seconds Left"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Tells the group when a roll is about to close."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Add %d Seconds When Someone Rolls Late"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"A roll in the last few seconds keeps the roll open a little longer, so nobody is cut off by lag."
L["LOOT_MASTER_END_EARLY"] = "End Early Once Everyone Has Rolled or Passed"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] = "Closes the roll as soon as every group member has rolled or typed pass."
L["LOOT_MASTER_REROLL_TIES"] = "Re-roll Ties Between the Tied Players"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Calls a tie-break for the tied players straight away. Off, a tie waits for you to press Re-roll Tied."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pause Between Items in Roll All"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] = "How long Roll All waits after a roll before calling the next."

L["LOOT_MASTER_COUNTING_HEADER"] = "Rolls That Count"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"A plain /roll (1-100), each player's first one, from your group, while the roll is open (%d second of grace for lag). Rolls that don't count stay in the list with the reason."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Announce Rolls That Don't Count"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Lists the rolls that didn't count, and why, in one line when the roll closes. A roll you disqualify is always announced."

L["LOOT_MASTER_TRADE_HEADER"] = "Tradable Loot"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Open When I Loot Something Tradable"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Opens the Loot Master when Bind on Pickup loot you can still trade lands in your bags while you're in a group."
L["LOOT_MASTER_TRADE_WARN"] = "Warn Me When Trade Time Runs Low"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Tells you once, in chat, when an item on the Roll List is about to become soulbound."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "How much trade time is left when you're warned."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Put Won Items in the Trade Window"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"When you open a trade with a winner, what they won goes in for you. You still press Trade."

L["LOOT_MASTER_FLOOR_HEADER"] = "Floor Loot"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"Floor Loot starts empty and holds only what you add. Add from Bags lists what you picked up in this instance first."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Take Items Off Once They Leave My Bags"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Drops an item from Floor Loot once you have none of it left: traded, sold or used."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Empty Floor Loot When I Leave the Raid"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Starts every raid with an empty Floor Loot list."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Open When Anyone Calls for Rolls"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Opens the Loot Tracker when someone in your group calls for rolls, with GogoLoot or with a raid warning."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Close Itself After the Roll Ends"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"A Loot Tracker that opened on its own closes 30 seconds after the roll ends, unless your mouse is over it."
L["LOOT_TRACKER_KEEP_DROPS"] = "Raids to Keep in Drops"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "How many raids the Drops tab remembers."
