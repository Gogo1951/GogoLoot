# GogoLoot // Notes

> The maintainer's settled rulings for GogoLoot, kept so no review raises them again: exceptions to the Gogo1951 add-on Style Guide, and decisions it leaves open.

## Exceptions

### Target marker on WoW Forever

- **Departs from:** MESSAGES → Target Marker, the marker left off on WoW Forever.
- **Instead:** Sent lines lead with the target marker on WoW Forever too.
- **Why:** Forever blocks raid markers only in /say and public channels such as General, which GogoLoot never sends to.

### Locked Items leads the mini-map tooltip

- **Departs from:** MINIMAP BUTTON → Tooltip Structure, the feature blocks directly under the title.
- **Instead:** While lockboxes wait on a lock, a Locked Items list sits directly under the title, above the feature blocks.
- **Why:** It is the one part of the tooltip that reflects the bags rather than a setting, so it is what the player opens the tooltip to check.

### Loot Toasts scan a tooltip for quest starters

- **Departs from:** DATA, "feature code never scans a tooltip" for item flags.
- **Instead:** The Filters Quest row reads `ITEM_STARTS_QUEST` from a scan tooltip, only for loot the Filters rows would otherwise hide, while that side's Quest box is ticked.
- **Why:** No API flags a quest starter, and its item class doesn't give it away.

### Sound toggles carry a speaker

- **Departs from:** Build Reference → Sub-Option Rows, a switch with exactly one setting beside it.
- **Instead:** A sound toggle's speaker sits after its dropdown, past the row's shared right edge, and leaves while the toggle is off; a sound with no dropdown keeps its speaker in the same column. A caption too long for the label column takes the whole line and sends its setting and speaker to the line below.
- **Why:** The speaker previews the sound the row picks, as on Control Freak, and German and French captions can outgrow the label column.

### Item lists open with an add line and a filter line

- **Departs from:** Build Reference → Item Lists, the Add from Bags and Add item rows.
- **Instead:** Above the rows, an add line holds a "Drop item here, or type item ID" box with an Add button and, in the control column, Add from Bags (offering nothing the list would refuse); after a blank line, a filter line holds a filter box (by name, item ID, setting or tag) as wide as the add box, with the rows' red remove icon as its clear button, and a Show All Kinds of Items filter. What the player just added leads the list under a **New** header, newest first, until they filter the list or close Options.
- **Why:** The long lists (Openable Items runs to hundreds of rows) need a filter, adding must not depend on pressing Enter, and an added row must not land out of sight.

### Restore Defaults closes an item list

- **Departs from:** Build Reference → Item Lists, Restore defaults first at double width.
- **Instead:** It sits under the last row, right-aligned at its caption's width, reads Restore Defaults on every list, and still confirms.
- **Why:** The top of a list is for finding and adding, and a reset used once in a while shouldn't be its biggest button.

### Openables List rows carry a reason tag

- **Departs from:** Build Reference → Item Lists, a row's cells.
- **Instead:** Between the item and its dropdown, a silver tag gives the reason for the item's default (Locked, Sell Sealed or May Hold Unique), blank for the rest so the dropdowns keep one column.
- **Why:** The reason is what tells a player why a container starts on Ignore.

### Item lists group rows by item class

- **Departs from:** Build Reference → Item Lists, rows sorted by name.
- **Instead:** All three lists put their rows under plain headers naming the client's own item class (never the subclass), A to Z, with rows A to Z by name under each. An item whose tooltip reads Quest Item sits under Quest whatever its class, and the Loot Toasts Quest row takes it too.
- **Why:** The client's classes need no upkeep and come translated, and players read the tooltip, not the class.

### Loot Toasts Filters grid

- **Departs from:** Build Reference → Label-Beside-Control Rows, one control per caption.
- **Instead:** Each item type's row is its caption, then a Mine column and a Group column, each a box and, on Armor, Weapon, Trade Goods and Gem, a quality dropdown while the box is ticked (a blank cell of its width while clear, so every Group box lines up). Bag Count (Mine only) and Winning Roll close the grid in the same columns.
- **Why:** Whose loot a row covers is the point of the panel, and one row per type and side would double an eighteen-row list.

### Mini-map tooltip reads back Automated Rolls

- **Departs from:** MINIMAP BUTTON → Tooltip Structure.
- **Instead:** Under Automated Rolls' description, a silver line per group context, set in two spaces and named in the game's own word for it, says what it rolls, such as "Party: Greed, Uncommon & Lower".
- **Why:** Right-click turns rolling on without saying what it rolls; the lines answer that where the click is.

## Decisions

- Open Sesame lives on inside GogoLoot: Automated Opening, Lockboxes, Loot Sounds and Loot Toasts came from it, and its Speedy Loot replaced GogoLoot's. There is no `/os`, no detection of Open Sesame, no settings import and no README switch-over note: telling Open Sesame players to disable it is Open Sesame's job. Features ship on, as in Open Sesame, unless a decision below ships one off.
- The options tree runs in the order loot meets it, then the two features that report it: Automated Rolls (Item Overrides and Character Rules under it), Master Looter (Ignore List under it), Automated Opening (Openables List and Lockboxes under it), Loot Toasts (Filters under it), Loot Sounds, and Announcements (Trade Announcements and Master Looter Announcements as sections). Item Overrides is not called an Ignore List, since each row picks a roll. Speedy Loot has no panel; its switch is in the main panel's Features. Where a client won't show a third level, `ns.OPTIONS_NESTED_PANELS` makes the children siblings titled "Parent: Child".
- Every feature panel opens on its title, a one- or two-sentence description that starts with a verb, then "Enable" plus the feature's name; options lists, legends and tips go in tooltips. What the switch tunes leaves with it, and a section that works without it stays; Automated Opening hides everything below its switch, the Ignore notice included. A child panel never hides behind its parent's switch and says so in one red line while it is off. Per-quality rows are captioned in their quality's color.
- Panel text says hand out, quality, Bind on Pickup, container and lockbox, and Ignore only ever means "GogoLoot leaves this one for you".
- Loot Destinations is a section under Master Looter's switch, a row for every quality the loot threshold reaches, always shown; while nobody is picked, a silver line says all loot waits in the loot window.
- Every destination dropdown leads with Loot Window, which sends that quality back to the loot window; Send All Loot To on it clears every quality, and neither is announced.
- The Master Looter pop-up carries Enable Automated Master Looting, and Send All Loot To leaves with it, since a destination picked with the automation off hands nothing out.
- Solo, Group Loot Settings shows "Join a group to change these. Only the group leader can." in the leader note's place.
- The Openables List lists every container the client's data lists, each Open or Ignore. Defaults, first match wins, each with its tag: Ignore (Sell Sealed) for one that drops only from raid or world bosses; Open (Locked) for a locked one; Ignore (May Hold Unique) for one that can hold a Unique item; Ignore (Sell Sealed) for a tradeable one that can hold a Bind on Pickup item; the rest Open, untagged. A lockbox stays on Open though its table reaches Unique and Bind on Pickup items, and Unique gear doesn't count as a unique item. The tag stays whatever the player picks. An added item joins on Open (gear and bags are refused, since using one equips it); a removed one is treated as an ordinary item. Only changes are saved, account-wide, so new data reaches every player.
- Each flavor's openable items come from that client's own wago.tools tables (every item flagged Openable), never a private-server database or Wowhead. Season of Discovery's items stay out of Classic Era and WoW Forever, and clams stay out of Wrath, Mists and Retail, which open them through a spell no add-on can cast. Contents and drop sources come from the CMaNGOS world databases.
- The "Level N" gear and supply boxes (items 274559–278066) are never on the Openables List on any flavor: WoW Forever's data flags them openable, but no player can get one.
- An item set to Ignore is also left in the loot window by Speedy Loot.
- GogoLoot ships a TOC for every flavor Come & Get It does: Classic Era with Season of Discovery, TBC Anniversary, WoW Forever, MoP Classic and Retail. Wrath keeps a data folder and waits for a live client.
- Every item set to Open is checked for a lock before it is used, rather than retried into "Item is locked" errors; a looted locked box set to Open is announced as opening once picked and listed under Locked Items.
- Lockbox Tooltips on WoW Forever show the requirement without the player's rank, because Forever has no skill-line API.
- Loot Toasts lays its settings out in sections at the panel's own level, not as sub-options: the position buttons first, then **Stack** (Maximum Toasts, Seconds on Screen, Grow Direction, Align Items) and **Text** (Font, Font Size in steps of two, Font Outline), all leaving while the toggle is off.
- Filters lists the rarity rows (Armor, Weapon, Trade Goods, and Gem from TBC on) first, the client's other item types A to Z, then GogoLoot's own Bind on Pickup, Openables and Money, then Bag Count and Winning Roll. Openables is GogoLoot's word because the game's Container means bags. Money has no Group box: the game reports no other player's coin.
- The Filters defaults show everything of the player's own, plus the group's quest items and Uncommon-or-better weapons and armor: what the player might be waiting on or rolling for.
- A won item's toast says how it was won, "(Aero, Need 87)" or "(Need 87)" for the player, in the game's own word for the roll; the Winning Roll row turns it off per side.
- Loot Toasts ships off: the toasts aren't polished yet, so players opt in to try them and give feedback.
- Standard Loot Messages, beside Enable Loot Toasts, offers Disable (the default) or Enable. While the toasts are on and it reads Disable, GogoLoot turns off the General tab's own Item Loot and Money Loot chat settings, and gives back only what it took when either changes. It acts only when that wanted state changes, never on an ordinary login, so a player's own change in Blizzard's window sticks. Currency stays: the toasts don't show it.
- Automated Rolls has two sections under its switch: Loot Thresholds (In Party, In Raid) and Roll Messages. Each group context is a roll dropdown beside its caption with Up to Quality under it, which leaves while the roll is Manual.
- Print Item in Chat ships on, since the roll window closes the moment GogoLoot rolls: "GogoLoot // You rolled Greed on [Item]." ("You passed on [Item]." for a Pass), for threshold and Item Overrides rolls alike.
- Hide Roll Messages ships on and keeps every pick and number out of chat, never who won or what they received. It belongs to Automated Rolls: it leaves with the master switch and hides nothing while that is off.
- Hide Roll Messages carries a winner summary dropdown, Print Winner Summary (the default) or Don't Print. Print hides the game's won line too and prints "GogoLoot // Aero won [Item], Greed 95." ("You won …" for the player; no roll when none was seen), the winner in their class color. It reads the toasts' roll tracking, so it works with the toasts off.
- Enable Automated Master Looting ships off, with no migration: a profile that never set it reads off after updating.
- Character Rules, a child panel of Automated Rolls, leaves gear with stats a character doesn't want to the player. It lists every character in its class color, with a dropdown per stat offering Standard Automated Roll or Manual, never Greed or Need: Primary Attributes in the character sheet's order, then Secondary Attributes A to Z in the client's words (Strength, Agility, Intellect, Spirit, Stamina, Spell Power, healing, Attack Power, Critical Strike, Hit and Mana Per 5; Hit and Critical Strike each cover melee, ranged and spell). Gear with any stat on Manual keeps its roll window. Rules are per character (AceDB char) and apply after Item Overrides.
- Character Rules reads Classic Era and TBC's Equip: and random-suffix stats from tables generated from the client's data (`Data/{Folder}/Item-Stats-{Folder}.lua`), since GetItemStats can't see them; WoW Forever and later read the item and its tooltip stat lines, as Play It Forward does.
- Character Rules' two captions use WoW Forever's own STAT_CATEGORY_PRIMARY_ATTRIBUTES and STAT_CATEGORY_SECONDARY_ATTRIBUTES; Classic Era and TBC, which have none, keep GogoLoot's own words.
- The loot sounds answer to their own switches alone; Enable Announcements silences only what GogoLoot tells other players.
- The mini-map button carries four features in the order of their clicks: Left-Click Automated Rolls, Right-Click Automated Opening, Shift + Left-Click Announcements, Shift + Right-Click Automated Master Looting. A plain middle-click does nothing, and Speedy Loot has neither a click nor a tooltip block.
- The Lockboxes scopes read "For Rogues" / "For All Characters" on their toggles' lines, by the maintainer's copy choice.
- Speedy Loot's switch is account-wide: it changes how the client's loot window behaves rather than loot policy, so a profile switch or reset leaves it alone.
- The loot chime is for corpse and chest loot only; an item won on a roll doesn't chime.
- The inventory-full warning answers only to GogoLoot's own opens: it prints and plays only while an Automated Opening open is pending or queued.
- The README thanks no one by name: Appreciation & History carries the Open Sesame history alone.
