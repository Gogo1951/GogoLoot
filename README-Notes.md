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
