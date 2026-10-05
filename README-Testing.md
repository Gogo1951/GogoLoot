# GogoLoot // Manual Test Plan

This is the manual test plan for GogoLoot, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/GogoLoot/blob/main/README-Technical.md).

## Before you start

**Run the whole list on each flavor in turn: Classic Era, Season of Discovery on the Classic Era client, TBC Anniversary, WoW Forever, MoP Classic and Retail.** Steps are numbered continuously so you can report "failed on step N."

Gather these once so you aren't caught short mid-run:

- **Characters.** A **Rogue**, for the lockbox and Pick Pocket steps. A **Warrior**, for Character Rules. A second character on the same account, for the account-wide checks.
- **A second player** you can group and trade with. Group Loot rolls, master looting and trades all need one. Their bags must be fillable to zero free slots for step 21.
- **Items.** A container that opens with no key, such as a clam; a locked lockbox, such as a Battered Junkbox; a container whose tooltip asks for a level above yours, such as a Lesser Darkmoon Prize (level 30) mailed to a low-level character; six or more tradable items, a couple of them in stacks; some gold.
- **Places.** Open-world mobs that drop greens, and a dungeon boss that drops three or more items at once.
- **State.** Out of combat unless a step says otherwise. Open Sesame disabled: GogoLoot now does its job.
- **A non-English client**, ruRU for preference, for the optional last step and for step 23.

On a client that offers no Group Loot or Master Looter loot method, mark the steps that need one as skipped in your report rather than failed.

This plan deliberately skips panel-by-panel layout reads, Profiles copy and delete, the Master Looter pop-up, the trade window's Announce checkbox, the Loot Toasts Filters grid and display settings, and every Diagnostics report beyond its gate and the ones a step asks for.

## Verify this release's changes

**One TOC per flavor** (the single TOC became one per client, each with its own data folder)

**1.** At character select, open **AddOns**: GogoLoot must be listed, enabled, and not marked out of date. Log in, open Options → AddOns → GogoLoot → **Diagnostic Tools**, tick **Enable Diagnostic Tools**, open the **Settings** tab and click **Run** beside **Loot Method**. The first line of the output must name this client's flavor and data folder: `Flavor Vanilla // Data Vanilla` on Classic Era, `Flavor Vanilla (Season of Discovery) // Data Discovery` on a Season of Discovery realm, then `TBC`, `Camelot` on WoW Forever, `Mists` and `Mainline`. Failure is GogoLoot missing from the list, an out-of-date warning, or a flavor or data folder that isn't this client's.

**The options tree** (the Open Sesame merge and the options rework)

**2.** Read the category list under **GogoLoot**. It must hold, in this order: **Automated Rolls**, with **Item Overrides** and **Character Rules** under it; **Master Looter**, with **Ignore List** under it; **Automated Opening**, with **Openables List** and **Lockboxes** under it; **Loot Toasts**, with **Filters** under it; **Loot Sounds**; **Announcements**; **Profiles**; **Diagnostic Tools**. Click each: every one opens on its own content, never a blank page. On the main panel, the **Features** section must carry six switches: **Enable Speedy Loot**, **Enable Automated Rolls**, **Enable Automated Master Looting**, **Enable Automated Opening**, **Enable Loot Toasts** and **Enable Announcements**. Untick **Enable Automated Rolls** there, then open **Item Overrides**: a red line must read **These settings aren't being used while Automated Rolls is off.** with the list still there. Tick it back on. Failure is a missing or blank entry, an entry under the wrong parent, or the red line missing. A client that can't show a third level must instead show each child right after its parent, titled like **Automated Rolls: Item Overrides**.

**New defaults** (Loot Toasts and Automated Master Looting now ship off; Speedy Loot became account-wide)

**3.** Untick **Enable Speedy Loot** on the main panel. On **Profiles**, create a new profile named `Test`. On it, **Enable Loot Toasts** and **Enable Automated Master Looting** must read unticked; **Enable Automated Opening**, **Print Item in Chat** and **Hide Roll Messages** must read ticked; and **Enable Speedy Loot** must still be unticked, because it belongs to the account, not the profile. Click **Reset Profile**: Speedy Loot stays unticked and the mini-map button stays where it was. Switch back to your old profile, delete `Test`, and tick Speedy Loot back on. Failure is a default that doesn't match, or Speedy Loot changing with the profile.

**Automated Opening** (came over from Open Sesame)

**4.** With 4 or more free bag slots, put a clam (or any container the **Openables List** shows on **Open**) in your bags. Within about a second it must open, its contents must land in your bags, and no loot window may be left open. Now fill your bags until 3 slots are free: chat must print `GogoLoot // Automated Opening is paused until you have at least 4 free bag slots.` and the next container stays shut. Free a slot: `GogoLoot // Automated Opening has resumed.` prints and the container opens. Failure is nothing opening, a loot window left hanging, or opening into bags that tight.

**5.** With a clam in your bags, start each of these and watch it stay shut until it ends, then open: combat; a cast (start your hearthstone, then cancel it); stealth or Shadowmeld; a vendor or bank window. **On WoW Forever, run the combat part in a dungeon boss fight or a battleground**, where the Retail engine hides cast and aura reads: the clam must stay shut and no Lua error may appear. Failure is an open during any of them, or an error naming GogoLoot.

**6.** On your Rogue, hover a locked lockbox: below the item's own lines must be **GogoLoot** and **Requires Lockpicking** with the number, green if your skill clears it and red if not. **On WoW Forever the requirement shows without your rank, in white; that is correct there.** Loot one: chat must print `GogoLoot // [Battered Junkbox] will open automatically once it is unlocked.`, the box must not be tried, and the mini-map tooltip must list it under **Locked Items**. Pick the lock: within about a second the box opens by itself. Failure is red "Item is locked" errors while it waits, no Locked Items list, or the box sitting in your bags after it's picked.

**7.** Open **Automated Opening → Openables List** and set a clam to **Ignore**. Loot one: it must stay shut, and chat must print `GogoLoot // [clam] is set to Ignore, so Automated Opening will leave it alone.` once. With Speedy Loot on, loot an ignored clam from a corpse: everything else is taken, the clam stays in the open loot window, and `GogoLoot // [clam] was left in the loot window for you to loot yourself.` prints. Set it back to **Open**. While you're on the list: TBC Anniversary must list an **Aldor Supplies Package**, and Classic Era and WoW Forever must not list a Season of Discovery container such as **Twilight Boots, Legs, and Shoulders Set**. Failure is an ignored container opening or being looted, or a container from another flavor.

**Refused containers** (Data Validation, 2026-10-05)

**8.** On a character below level 30, with Automated Opening on and 4 or more free slots, receive a **Lesser Darkmoon Prize** by mail and take it into your bags. It must never be tried: not one red "You must reach level 30" error. Put a clam in the same bags: it still opens. Failure is a stream of red errors, or other containers stopping.

**Loot Toasts and Loot Sounds** (came over from Open Sesame; Standard Loot Messages, 2026-10-05)

**9.** Tick **Enable Loot Toasts**. A dark handle must appear above the center of the screen reading **GogoLoot Loot Toasts**, and a dropdown beside the switch must read **Disable Standard Loot Messages**. Right-click the handle to put it away. Loot a mob that drops items and coin: each item and the coin must appear as a toast where the handle was, and your General chat tab must show no "You receive loot" or coin lines. **On WoW Forever, items must toast, not only coin**: a coin-only stack there is the known open bug this step exists to catch. Pick **Enable Standard Loot Messages**: the chat lines come back with the toasts still on. Pick **Disable** again, then untick **Enable Loot Toasts**: the chat lines come back. Failure is no handle, a missing toast, chat lines hidden with the toasts off, or chat lines still showing with the toasts on and the dropdown on Disable.

**10.** On **Loot Sounds**, with **Enable Loot Sound** at **Uncommon+**, loot a green from a corpse: a chime must play. Loot a white: no chime. Win a green on a roll: no chime. On your Rogue, with **Enable Pick Pocket Sound** on, pick a pocket that holds something: a bag sound plays once; pick an empty one: silence. Failure is a chime on a white or a won roll, none on the corpse green, or a bag sound on an empty pocket.

**Roll messages** (Print Item in Chat, Hide Roll Messages and the winner summary, 2026-10-04 and 2026-10-05)

**11.** In a party under **Group Loot**, set **In Party** to **Greed** at **Uncommon & Lower**, and kill mobs until a green opens a roll. The roll window must close at once, and chat must print `GogoLoot // You rolled Greed on [Item].` with a clickable link. The game's pick and number lines ("Aero has selected Greed for", "Greed Roll - 95 for [Item] by Aero") must not appear. When your partner wins, chat must print `GogoLoot // Aero won [Item], Greed 95.`, the name in their class color and the number matching the roll, with no game "won" line beside it; "Aero receives loot: [Item]" still shows. When you win one, it reads `GogoLoot // You won [Item], Need 87.` or with your own roll. Failure is a missing or doubled line, the wrong roll or number, a white name for a group member, or both the game's won line and GogoLoot's.

**Character Rules** (2026-10-05)

**12.** On your Warrior, open **Automated Rolls → Character Rules**. Your characters must be listed down the left in their class colors, with the one you're playing picked. Set **Intellect** to **Manual**. In a party, with **In Party** on **Greed** at **Uncommon & Lower**, roll on an **of the Owl** green: the roll window must stay for you and nothing prints. Roll on an **of the Bear** green: GogoLoot Greeds it and prints as in step 11. **On Classic Era and TBC Anniversary**, also set **Spell Power** to **Manual** and roll on a green whose spell damage is an **Equip:** line: the window must stay. If any of these rolls anyway, put the item in your bags and paste the **Gear Stats** report (Diagnostic Tools → Settings) with your result. Failure is a roll on gear with a Manual stat, or gear without one left alone.

**Loot Window destination** (2026-10-04)

**13.** As master looter in a dungeon, tick **Enable Automated Master Looting**. Under **Loot Destinations**, every quality row and **Send All Loot To** must read **Loot Window**, with a silver line reading **Nobody is picked yet, so all loot waits in the loot window for you.** Open a row's dropdown: **Loot Window** first, then **Self**, then your group. Pick your partner for **Epic**, then pick **Loot Window** again: nothing may be announced, and an Epic drop must wait in the loot window. Failure is Loot Window missing, an announcement for it, or loot handed out after picking it.

**Item lists** (add line, Add from Bags, New, filters, 2026-10-04)

**14.** Open **Automated Rolls → Item Overrides**. Pick an item from the **Add from Bags** dropdown: it must join the list at the top under a **New** header and leave the dropdown. Type `12662` into the box reading **Drop item here, or type item ID** and click **Add**: Demonic Rune joins under New. Type `need` into the filter box: only rows set to Need remain. Clear it, then pick a kind from the dropdown reading **Show All Kinds of Items**: only that header and its rows remain. Pick Show All Kinds of Items again, click a row's red remove icon (the row goes at once), then click **Restore Defaults** at the foot and approve: every default row returns. Failure is an item that won't add, a filter that misses a match, or a restore with no confirmation.

When steps 1-14 pass on every flavor, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**15.** Log in with GogoLoot enabled. No Lua error may appear, and chat must print one welcome line in the shape `GogoLoot // Version Dev. Settings (including the option to disable this message) can be found under Options > AddOns > GogoLoot. ...` (a packaged build shows its dated version instead of Dev). Type `/reload`: again no error. Failure is any error naming GogoLoot, no welcome line, or a line containing `nil` or a stray `%s`.

**16.** Type `/gogo`, GogoLoot's only slash command. The settings must appear **docked inside the Blizzard Options window**, with GogoLoot selected in the category list on the left. Close it and **Shift + Middle-Click** the mini-map button: the same docked panel. Close it, open the game's Options yourself and click **GogoLoot** under AddOns: the same panel. A plain middle-click must do nothing. Failure is a standalone window floating free of the Options frame, or nothing happening. **TBC Anniversary is the flavor where the panel has historically floated free**, so a run on Classic Era alone has not finished this step.

**17.** Pull a mob and, while still in combat, type `/gogo`, then **Shift + Middle-Click** the mini-map button. Each must print `GogoLoot // As a safety precaution, the Options Interface cannot be opened during combat.` and the panel must not open. Leave combat and wait five seconds: the panel must not open by itself. Failure is the panel opening, silence, or a red `ADDON_ACTION_BLOCKED` error.

**18.** Hover the mini-map button. The tooltip must show **GogoLoot** and the version, then an **Automated Rolls** row (with two silver lines under its description reading back your In Party and In Raid rolls) and a **Left-Click** hint, **Automated Opening** with **Right-Click**, **Announcements** with **Shift + Left-Click**, **Automated Master Looting** with **Shift + Right-Click**, and last **GogoLoot Options** with **Shift + Middle-Click**. With the tooltip up, do each click: its row must flip between **Enabled** and **Disabled** on the spot, the matching switch in the main panel's Features section must agree, and a left-click must also swap the icon's artwork. Put each back. Failure is a click toggling the wrong feature, a tooltip that goes stale, or a panel that disagrees.

**19.** With **Enable Speedy Loot** on, untick the game's own **Auto Loot** setting and `/reload`: chat must print `GogoLoot // Turned on the game's Auto Loot setting, which Speedy Loot and Automated Opening need.` and the setting must be back on. Loot a mob: no loot window may flash, and every item and the coin must land in your bags. Hold **Shift** while looting the next: the loot window opens as usual. Fill your bags to zero free slots and loot an item: the window must stay up with the item in it. Failure is a flash of the window, items left behind with room to spare, a silent Auto Loot change, or loot stranded in a hidden window.

**20.** In a party under **Group Loot**, with **In Party** on **Greed** at **Uncommon & Lower**: a green must be Greeded (step 11 shows the print). Set **In Party** to **Manual**: the next roll window stays for you. Set it back to Greed and roll on a **Bind on Pickup** item that isn't on Item Overrides: nothing may happen. Add a recipe, mount, pet or legendary to Item Overrides on **Greed** and roll on it: nothing may happen; those are never rolled. Failure is any roll on a Bind on Pickup item outside Item Overrides, on a recipe, mount, pet or legendary, or with the action on Manual.

**21.** As master looter in a dungeon with **Enable Automated Master Looting** on, open **Loot Threshold** on the Master Looter panel. **On Classic Era, Season of Discovery and WoW Forever it must offer five entries, Poor to Epic; on TBC Anniversary and later only three, Uncommon to Epic.** Set it to Uncommon and use **Send All Loot To** to pick your partner: one group line must read `{rt4} Aero will be holding all loot for the group // GogoLoot`. Have your partner fill their bags to zero free slots, then kill a boss that drops three or more items: one group line must read `{rt4} Aero's bags are full: [Item A], [Item B], [Item C] // GogoLoot`, and the items must still be in the loot window for you. Free their bags and kill the next boss: the items go to your partner, and anything Rare or better is announced as `{rt4} Gave [Item] to Aero // GogoLoot`. Failure is one bag-full line per item, loot vanishing, or a threshold list that doesn't match the flavor.

**22.** With **Enable Trade Announcements** on and **Channel** on **Whisper**, trade your partner two items and some gold and take one item back. They must get one whisper: `{rt4} Gave [Item A], [Item B] x3, 5g 20s to Aero, received [Item C] // GogoLoot`, with clickable links and the right counts. Then open a trade, put items in on both sides, and **cancel** it: nothing may be sent to anyone. **Trade completion and cancellation are told apart by message numbers that differ on every flavor, so a pass on Classic Era proves nothing about the others.** Failure is no whisper, a whisper before the trade finishes, `nil` in it, or any message for a cancelled trade.

**23.** Trade your partner six or more distinct items, several in stacks, and complete it. The whisper must arrive as one or more complete messages, each starting with `{rt4}` and ending with `// GogoLoot`, split only between items. Run this on **ruRU** if you can: Cyrillic overflows the chat limit first. Failure is a link cut in half, a missing item, garbled characters at a split, or a message that never arrives.

**24.** Log in fresh and open **Diagnostic Tools**: only the warning and **Enable Diagnostic Tools** may show, and it must be unticked. Tick it: four tabs appear, **Run Tests**, **Settings**, **Code** and **Data**. Untick it: they vanish at once, with no empty frame left. Tick it and `/reload`: it reads unticked again. Failure is the gate ticked by default, a missing tab, or the gate surviving a reload.

**25.** *Optional.* On a non-English client, open every GogoLoot panel: every label, description and dropdown entry must read as words in that language (Diagnostic Tools stays English by design). Trigger step 11's roll line and step 22's trade whisper: each must read as one sentence with the item and the player in sensible places. Failure is a raw key such as `ROLLS_PRINT_ITEM` on screen, or `nil`, `%s` or `%d` in a message.

When every step passes on each flavor GogoLoot ships a TOC for, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
