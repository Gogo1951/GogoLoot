# GogoLoot // Notes

> Where GogoLoot departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

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

### Loot Toasts settings sit at panel level

- **Departs from:** Build Reference → Sub-Option Rows, controls that mean something only while a toggle is on.
- **Instead:** Below Enable Loot Toasts come the position buttons, then Stack and Text sections, every row at the panel's own level with a white caption, leaving while the toggle is off.
- **Why:** The rows answer separate questions (where the toasts sit, how they stack, how their text looks), so they read as sections, not as one toggle's sub-options.

## Decisions

- **Open Sesame lives on inside GogoLoot.** Automated Opening, Lockboxes, Loot Sounds and Loot Toasts came over from Open Sesame, and its Speedy Loot replaced GogoLoot's. There is no `/os` command, and GogoLoot neither detects Open Sesame nor imports its settings, and its README carries no switch-over note: telling Open Sesame players to disable it is Open Sesame's job (maintainer, 2026-10-05). Every new feature ships on, as it did in Open Sesame.
- **The options are a tree** (maintainer, 2026-09-28). The features that act on loot come first, in the order loot meets them, then the two that report it: Automated Rolls, with Item Overrides under it (renamed from Ignore List, since each row picks a roll rather than ignoring the item); Master Looter, holding Loot Destinations as a section, with the Ignore List under it; Automated Opening, holding the Ignore notice's switch, with the Openables List and Lockboxes under it (Lockboxes a panel of its own since 2026-10-05: it works with nothing opening, so it isn't part of the switch's panel); Loot Toasts, what the player sees, with Filters under it (a panel of its own since 2026-10-04: which loot gets a toast, and what it says); Loot Sounds, what they hear (a panel of its own since 2026-10-04, at the same level as Loot Toasts); and Announcements, what the group is told (renamed back from Loot Notifications once the sounds left it), holding Trade Announcements and Master Looter Announcements as sections, with trade's Channel (Whisper or Group Chat) a dropdown under its toggle. Speedy Loot has no panel of its own: its switch lives in the main panel's Features section. Where a client's Settings panel won't show a third level, `ns.OPTIONS_NESTED_PANELS` turns the children into siblings right after their parent, titled "Parent: Child".
- **One pattern for every panel** (maintainer, 2026-09-28). A feature panel opens on its title, a one- or two-sentence description, then its master switch, "Enable" plus the feature's name. A description starts with a verb and says what the feature does for the player; a second sentence only says what the panel can't show (a safety rule, a requirement), and options lists, legends and tips go in tooltips. What the switch tunes leaves with it; a section that works without it stays (Master Looter's Group Loot Settings and pop-up switch). Automated Opening hides everything below its switch, the Ignore notice included, though Speedy Loot gives that notice too (maintainer, 2026-10-05). A child panel never hides behind its parent's switch, and says in one red line while it is off. Per-quality rows are captioned in their quality's own color. In panel text GogoLoot says hand out, quality, Bind on Pickup, container and lockbox, and Ignore only ever means "GogoLoot leaves this one for you".
- **The main panel's Features section carries every feature's switch** (maintainer, 2026-09-28): Speedy Loot, Automated Rolls, Automated Master Looting, Automated Opening, Loot Toasts and Announcements, two to a line while every caption fits. Each is the same setting as the switch on its own panel, built by the same function, so the front page shows at a glance what GogoLoot is doing.
- **Master Looter keeps its setup on one page** (maintainer, 2026-09-28). Loot Destinations is a section under the switch, a row for every quality the loot threshold reaches, always shown, with no toggle to collapse them; while nobody is picked, a silver line says all loot waits in the loot window.
- **Every destination dropdown leads with Loot Window** (maintainer, 2026-10-04). It sends a quality back to the loot window for the master looter to hand out: an unset quality reads as it, picking it clears the quality, and Send All Loot To on it clears them all. Neither is announced, since nobody is holding anything for the group.
- **The Master Looter pop-up carries Enable Automated Master Looting** (maintainer, 2026-10-04), under its own switch, and Send All Loot To leaves with it, as on the panel: a destination picked with the automation off hands nothing out.
- **Solo, Group Loot Settings says why its dropdowns are greyed out** (maintainer, 2026-10-04): a silver line in the leader note's place reads "Join a group to change these. Only the group leader can."
- **The Openables List is the whole list, with Add Item, a remove column and Restore Defaults.** Every container the client's data lists appears with its own dropdown of two choices, Open or Ignore (maintainer, 2026-09-28: Open when Unlocked opened exactly as Open does, and the three Ignores only changed the reason printed). A row's default follows the maintainer's rules, first match wins, and carries its reason as the row's tag: Ignore, tagged Sell Sealed, for a container that drops only from raid or world bosses; Open, tagged Locked, for a locked one; Ignore, tagged May Hold Unique, for one that can hold a Unique item; Ignore, tagged Sell Sealed, for one that can hold a Bind on Pickup item while it can itself be traded (a Bind on Pickup container just opens); the rest on Open, untagged. The tag belongs to the item, so it stays whatever the player picks, and a looted container's notice gives the reason. Two readings are mine, pending the maintainer's word: a lockbox stays on Open even though its random table reaches Unique and Bind on Pickup items, and Unique gear (the rare world-drop rings and trinkets) doesn't count as a unique item. The player can add an item the data lacks, which joins on Open (gear and bags are refused, since using one equips it), or remove a listed one, which GogoLoot then treats as an ordinary item. Only the changes are saved, account-wide, so new data reaches every player, and Restore Defaults clears them all.
- **Each flavor's openable items come from that client's own tables** on wago.tools, every item flagged Openable, rather than from a private-server database or Wowhead listings. Season of Discovery's items stay out of the Classic Era and WoW Forever lists, though both clients know the IDs, and clams stay out of Wrath, Mists and Retail, which open them through a spell no add-on can cast. What a container holds and where it drops, which no client table records, come from the CMaNGOS world databases instead (README-Technical, Openable Items Data).
- **The "Level N" gear and supply boxes are never on the Openables List** (maintainer, 2026-10-04). WoW Forever's client data flags them openable (Level 23, 38, 57 and 60 Cloth, Leather, Mail and Plate Gear, and Cloth, Enchanting, Herbalism, Hunter, Mining, Skinning and Tradeskill Supplies, items 274559–278066), and the online databases list them, but no player can get one. All 39 rows were removed from `Data/Camelot/`, and a regenerated list must leave them out on every flavor.
- **Ignore also keeps Speedy Loot from taking an item.** An item set to Ignore is left in the loot window for the player, as Open Sesame's Ignore List did.
- **GogoLoot ships a TOC for every flavor Come & Get It does:** Classic Era with Season of Discovery, TBC Anniversary, WoW Forever, MoP Classic and Retail. Wrath keeps a data folder and waits for a live client before it gets a TOC.
- **Every item set to Open is checked for a lock before it is used**, lockbox or not, instead of being tried every tick into "Item is locked" errors. A looted lockbox (tagged Locked) set to Open is announced as one that will open once picked, and every waiting box is listed under Locked Items.
- **Lockbox Tooltips on WoW Forever show the requirement without the player's rank**, because Forever has no skill-line API.
- **Loot Toasts lays its settings out in sections, not sub-options** (maintainer, 2026-09-28; the Filters rows, 2026-10-04). Below Enable Loot Toasts, which carries no setting of its own, come the position buttons (maintainer, 2026-10-04: where the toasts sit is the first thing set), then a **Stack** header (Maximum Toasts, Seconds on Screen, Grow Direction, Align Items) and a **Text** header (Font, Font Size, Font Outline), every row at the panel's own level with a white caption (maintainer, 2026-10-04: one Display section mixed three questions in nine rows). Font Size is a dropdown in steps of two, so every row in those sections is one height. The rows still leave the panel when the toggle is off. Loot Sounds, which doesn't answer to it, is a panel of its own after it (maintainer, 2026-10-04). This departs from the toggle-row layout above, which would indent them all. **Filters** is a child panel of Loot Toasts (maintainer, 2026-10-04, to keep the Loot Toasts panel on the stack and its text): its description, a red line while Loot Toasts is off, then a row per item type with a Mine and a Group box, as the exception above describes. The item-type rows take the client's own names: the rarity rows (Armor, Weapon, Trade Goods, and Gem from TBC on) first, then the other types A to Z, then GogoLoot's own Bind on Pickup, Openables and Money, then Bag Count and Winning Roll. Openables is GogoLoot's word because the game's own Container means bags. Money has no Group box: the game reports no other player's coin.
- **The loot toasts ship showing everything of the player's own, and the group's quest items and Uncommon-or-better weapons and armor** (maintainer, 2026-10-04). That is what a group member picks up that the player might be waiting on or rolling for, and none of their cloth and greys.
- **A won item's toast says how it was won** (maintainer, 2026-10-04): "(Aero, Need 87)" after a group member's item, "(Need 87)" after the player's, in the game's own word for the roll. The Winning Roll row in Filters turns it off for either side. It is read from the game's own roll lines, or, with the roll spam turned down, from the won line alone.
- **Hide Roll Messages ships on** (maintainer, 2026-10-04). Hide Roll Messages keeps every pick and every number out of chat, never who won or what they received. It is part of Automated Rolls (maintainer, 2026-10-04): it leaves the panel with the master switch and hides nothing while it is off, keeping its saved choice for when the switch comes back.
- **Print Item in Chat is back, on by default** (maintainer, 2026-10-05, reversing the 2026-10-04 removal of Report Each Roll). The roll window closes the moment GogoLoot rolls, so without a line the player never sees what came up or what was picked. It prints "GogoLoot // You rolled Greed on [Item]." ("You passed on [Item]." for a Pass), naming the roll actually made, for threshold and Item Overrides rolls alike.
- **Character Rules leaves gear with the stats a character doesn't want to roll on to the player** (maintainer, 2026-10-05: "I don't care about of the Owl gear when I'm on my warrior"). A child panel of Automated Rolls, laid out like MagicEraser's list panels: every character down the left in its class color, and on the right a dropdown per stat under two captions (maintainer, 2026-10-05): **Primary Attributes** in the character sheet's order, then **Secondary Attributes** A to Z in the client's own words (Strength, Agility, Intellect, Spirit, Stamina, Spell Power, healing, Attack Power, Critical Strike, and, added the same day, Hit and Mana Per 5; Hit and Critical Strike each cover melee, ranged and spell) of two choices, **Standard Automated Roll** and **Manual** (maintainer, 2026-10-05: no Greed or Need). Gear with any stat set to Manual keeps its roll window; everything else rolls as the quality settings say. Rules are per character (AceDB char sections), not per profile, and come after Item Overrides. Classic Era and TBC carry spell power, healing, attack power and crit as Equip: spells and every random suffix as an enchantment, which GetItemStats can't see, so those come from tables generated from the client's own data (`Data/{Folder}/Item-Stats-{Folder}.lua`); WoW Forever and later read them off the item, plus the tooltip's "+15 Intellect" lines in the game's own words, as Play It Forward does.
- **Automated Rolls has two sections under its switch** (maintainer, 2026-10-05): **Loot Thresholds** (In Party, In Raid) and **Roll Messages** (Print Item in Chat with its example, a blank line, Hide Roll Messages with the winner summary dropdown beside it and its example under it).
- **Hide Roll Messages carries a winner summary** (maintainer, 2026-10-05). A dropdown beside it, Print Winner Summary (the default) or Don't Print Winner Summary, leaving with the toggle. Print Winner Summary hides the game's won line too and prints "GogoLoot // Aero won [Item], Greed 95." in its place ("You won [Item], Greed 95." for the player; without the roll when none was seen), the winner in their class color while the roster holds them (maintainer, 2026-10-05: a print uses class colors for names). It reads the toasts' winning-roll tracking, so it works with the toasts off. Don't Print leaves the game's won line, as before.
- **Enable Automated Master Looting ships off** (maintainer, 2026-10-05). Only the default changed, with no migration, so a profile that never set it reads off after updating.
- **Loot Toasts ships off** (maintainer, 2026-10-05): the toasts aren't polished yet, so players turn them on to try them and give feedback. The Filters defaults below are what a player gets once they do.
- **Standard Loot Messages is a dropdown beside Enable Loot Toasts, and the toasts turn the game's loot lines off** (maintainer, 2026-10-05; it sat under Automated Rolls' Roll Messages for an afternoon first). Its two choices, Disable Standard Loot Messages (the default) and Enable Standard Loot Messages, flip the General tab's own Item Loot and Money Loot checkboxes (Chat Settings → Other), the two kinds of line the toasts stand in for, so GogoLoot saves no copy of them and other tabs keep theirs. With the toasts on and the dropdown on Disable, GogoLoot takes those lines off General; turning the toasts off, or picking Enable, gives back only what GogoLoot took. GogoLoot acts only when that wanted state changes (a character's first sync counts), never on an ordinary login, so ticking Item Loot back in Blizzard's window sticks. Currency stays: the toasts don't show it.
- **Automated Rolls lays out each group context as a roll beside its caption, with Up to Quality under it** (maintainer, 2026-10-04). The quality row leaves while the roll is Manual, where it limits nothing. No captions sit over the dropdowns.
- **The loot sounds answer to their own switches alone** (maintainer, 2026-09-28). Enable Announcements silences what GogoLoot tells other players and nothing else.
- **The mini-map button carries four features, in the order of their clicks** (maintainer, 2026-09-28; four, 2026-10-04). Left-click toggles Automated Rolls, right-click Automated Opening, Shift + Left-Click Announcements and Shift + Right-Click Automated Master Looting, and the tooltip lists their blocks in that order; Shift + Middle-Click still opens the options, and a plain middle-click does nothing. Speedy Loot simply stays on, so it has neither a click nor a tooltip block, and its switch is in the main panel's Features section.
- **The Lockboxes scopes read "For Rogues" / "For All Characters"**, by the maintainer's copy choice, not "Rogues Only / All Characters". They sit on their toggles' lines, which made the old "Show for" caption redundant.
- **Soft Reserves is a separate follow-up**, not part of the merge.
- **Speedy Loot's switch is account-wide** (maintainer, 2026-10-05): it changes how the client's loot window behaves rather than loot policy, so a profile switch or Reset Profile leaves it alone.
- **Character Rules' two captions use the client's own labels where it has them** (maintainer, 2026-10-05): WoW Forever's STAT_CATEGORY_PRIMARY_ATTRIBUTES and STAT_CATEGORY_SECONDARY_ATTRIBUTES; Classic Era and TBC, which have no such labels, keep GogoLoot's own words.
- **The loot chime is for corpse and chest loot only** (maintainer, 2026-10-05): an item won on a roll doesn't chime.
- **GogoLoot's inventory-full warning answers only to its own opens** (maintainer, 2026-10-05): it prints and plays its sound only while an Automated Opening open is pending or queued; every other full-bag error is left to the game.
- **The README thanks no one by name** (maintainer, 2026-10-05): Appreciation & History carries the Open Sesame history alone, with no Special Thanks.
