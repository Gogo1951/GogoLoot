# GogoLoot — Manual Test Plan

This is the manual test plan for GogoLoot — the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/GogoLoot/blob/main/README-Technical.md).

## How to run this plan

Run the whole list on Classic Era, then again on TBC Anniversary. Do a `/reload` before starting each flavor.

Work top to bottom. Every step tells you exactly what to do, what you should see, and what failure looks like — if a step doesn't match its expected result, it failed. Steps are numbered continuously from 1 to 106 across the whole document, so a bug report only needs "failed on step N."

Some steps behave differently on the two clients and say so in the step itself. Those are not optional on either flavor — the client a step warns about is precisely the one where that step earns its keep. **A run on only one flavor is not a completed run.**

## Before you start

Gather these once so you aren't caught short mid-run:

- **Both flavors installed** — Classic Era and TBC Anniversary. The add-on ships for both, and both must be tested. Make sure both folders are the **same build** before you start; testing an old copy on one flavor proves nothing about the release.
- **A second player you can group and trade with.** This is the single most important fixture. Master looting, trade announcements, and every group-chat message need a real second character; nearly a third of this plan is unreachable solo. A second WoW account, a trusted guildmate, or a friend all work.
- **A character on that second account whose bags you can fill.** One step needs a loot recipient with **zero free general-purpose bag slots** — buy vendor trash, or empty their bags into the bank and stuff them with a stack-splitting item until nothing fits.
- **A dungeon you can both zone into and clear a boss in.** Master loot only auto-distributes inside instances by default, and BoP items are only redistributable there. Any low-level dungeon works — you want a boss that drops **three or more items at once**, so Ragefire Chasm, Deadmines, or Wailing Caverns bosses are all fine.
- **Open-world mobs that drop greens**, for Automated Rolls in a party under Group Loot.
- **A stack of tradable items** — six or more distinct items, plus a couple of stacks of five or more, to fill a trade window and force the long-trade split.
- **Some gold on both characters**, for the money line in a trade summary.
- **A rogue, or an enchanter** — optional, for the trade enchant-slot step. Skip that one step if you have neither.
- **Your own bags fillable to zero free slots**, for the Speedy Loot no-space step.
- **A second character on your own account**, for the account-wide settings steps.
- **A non-English client.** Normally optional; **for this release it is required** — every locale file was rewritten. See steps 103–106, and read the note at the top of the localization group below.

GogoLoot has no class-specific behavior, so any classes will do. Unless a step says otherwise, be **out of combat**.

## Verify this release's changes

This release is a **localization and message-template pass** sitting on top of three behavior fixes made earlier in the same untagged build. Steps 1–19 are what turn "we changed it" into "we watched it work" — run them first, and run every one of them on **both** flavors.

### Localized text and the shared hand-out template

All eleven locales were rewritten this pass. At the same time the two separate hand-out sentences — one for master loot, one for trades — were merged into a **single shared template**, `Gave %s to %s.`, and several option labels were renamed or reworded. One sentence now has to read correctly in two completely different situations, in eleven languages, and a label whose key changed will show as a raw key in any locale that wasn't updated with it.

Because every string moved, the **localization spot-check in steps 103–106 is not optional for this release.** Run it on at least one non-English client, ruRU for preference.

**1.** Log in and open every GogoLoot panel in turn: **GogoLoot**, **Master Looter**, **Automated Rolls**, **Announcements**, **Profiles**, **Diagnostic Tools**. Every label, description, dropdown entry and button must read as words — a sentence or a caption — in your client's language. Failure is a raw key showing through: text like `MASTER_LOOTER_LOOT_METHOD`, `SPEEDY_LOOT_HEADER` or `TRADE_CONDITION_ALWAYS` on screen instead of words, which is exactly what a key renamed in the code but not in a locale file looks like. **The Diagnostic Tools panel is deliberately English on every client — that is intended and not a failure.**

**2.** Now prove the shared sentence on its **master loot** side. As master looter, hand an item out **by hand** through the standard master-loot candidate dropdown. The group must see one line reading:

> `{rt4} GogoLoot // Gave [Item] to Playername.`

The item link must be clickable and the name must be the player you picked. Failure is `nil` or a stray `%s` in the sentence, the item and the player appearing in the wrong slots, or no line at all.

**3.** Prove the same sentence on its **trade** side. With **Enable Trade Announcements** on and **Message Output** set to **Whisper**, complete a trade where **you hand over two or more items and receive nothing back**. The whisper must read:

> `{rt4} GogoLoot // Gave [Item A] x2, [Item B] to Partnername.`

This is the same template as step 2 doing a different job — a list of items where step 2 had one, a trade partner where step 2 had a loot recipient. Both must be grammatical. Failure is either sentence reading as though it were written for the other case: a plural list jammed into a singular phrasing, or a sentence that only makes sense about loot appearing on a trade.

**4.** Complete a **two-sided** trade — items from you and items from them. One message must read `Gave [items] to Partnername, received [items].` Then complete a trade where **only they give** and you hand over nothing: it must read `Received [items] from Partnername.` Failure is either shape coming out as two half-sentences, one side going missing, or a `nil` where a name or an item should be.

**5.** Open the **Announcements** panel and read the three grey example lines — the trade example, the loot-destination example, and the automated-announce example. Each must match the sentence the add-on actually sends, word for word apart from the sample names and items. Compare the trade example against what you saw in step 3, and the automated-announce example against step 2. Failure is an example that still shows the old wording while the real message shows the new — a translated example that drifted from its template misleads every player who reads the panel.

**6.** In the **Master Looter** panel, read the two rows at the top: **Loot Method** and **Loot Threshold**. Both must read as labels in your language — the Loot Method key was renamed this pass, so a stale locale shows a raw key right here. Have your partner open the same panel while you lead: their labels must carry the **(Set by Yourname)** suffix and still read as words. Then find **Enable Master Looter Pop-up** in the same panel — spelled with the hyphen — and tick it; the window it opens must be titled **GogoLoot // Quick Settings**. Failure is a raw key in either row, a suffix that swallows the label, or the toggle missing entirely.

### Speedy Loot and the Auto Loot setting

GogoLoot only touches the game's Auto Loot setting on behalf of Speedy Loot, only when the setting is actually off, and it always says so. With Speedy Loot off it must leave the setting completely alone.

**7.** Open the GogoLoot options (`/gl`) and **untick Enable Speedy Loot**. Then open the game's own settings and **untick Auto Loot** (Esc → Options → Interface → Controls on Era; Esc → Options → Controls on Anniversary). Type `/reload` and **wait a full ten seconds** watching your chat frame. No GogoLoot line about Auto Loot may print, and when you reopen the game settings **Auto Loot must still be unticked**. Failure is either the message appearing or the Auto Loot box ticking itself back on — GogoLoot has no business changing a setting for a feature you turned off.

**8.** With Speedy Loot still off and Auto Loot still off, log out fully and log back in on a **different character**. Wait ten more seconds. Again: **no message, and Auto Loot stays off.** Speedy Loot is an account-wide setting, so it is still off on this character; this step catches an enforcement path that fires at login rather than on the toggle. Failure is the message appearing on a character you never enabled Speedy Loot on.

**9.** Now open the GogoLoot options and **tick Enable Speedy Loot**, with Auto Loot still off. A line must print immediately in your chat frame reading:

> `GogoLoot // Auto Loot has been enabled. Speedy Loot requires it to function.`

The message must **name Speedy Loot** — that is what tells the player which of their own choices caused the change. Reopen the game settings: **Auto Loot must now be ticked.** Failure is no message, a message that doesn't say why the setting changed, or Auto Loot staying off while Speedy Loot claims to be on.

**10.** Leave Speedy Loot on and Auto Loot on, and type `/reload`. Wait ten seconds. **No message this time.** The write only ever fires when the setting is genuinely off, so a reload with everything already correct must be silent. Failure is the line printing on every reload, which trains players to ignore it.

**11.** Untick Auto Loot again, then **right-click the minimap button twice** — once to turn Speedy Loot off, once to turn it back on. The same message from step 9 must print on the second click, and Auto Loot must tick back on. Failure is the minimap path staying silent or not enforcing the setting, which would mean only the options panel is wired up.

### Trade result detection

Trade completion and cancellation are read from a numeric message id, and **the ids are different on every flavor**. A pass on Era proves nothing at all about Anniversary — this is the single most flavor-sensitive behavior in the add-on, and it is why the Anniversary run exists.

**12.** Open Options → AddOns → GogoLoot → **Diagnostic Tools**, tick **Enable Diagnostic Tools**, then click **Test Loot Method API**. Scroll to the two id blocks at the end of the output — *Loot error message ids (constant -> id on this client)* and *Trade result message ids (constant -> id on this client)*. Every constant in **both** blocks must show a **number**, not `NOT FOUND`, and the closing line must report a non-zero count of scanned game messages. The trade block is what this step exists for: `ERR_TRADE_COMPLETE` and `ERR_TRADE_CANCELLED` are the ids the trade watcher matches on, they are different numbers on Era and Anniversary, and this is the whole per-flavor check in one button press. **Write both numbers down next to this step for this flavor** — comparing the Era pair against the Anniversary pair is how you confirm both clients were genuinely exercised. Failure is `GetGameMessageInfo not available`, a scan count of 0, or every constant reading `NOT FOUND`; any of those means neither trade results nor loot errors can be detected on this flavor. A single trade constant reading `NOT FOUND` is a narrower but real failure: that one result drops to comparing translated text, the fragile path the id matching exists to avoid — record it and run step 13.

**13.** *Fallback — run this when step 12 showed `NOT FOUND` for either trade constant, or when a trade step below misbehaves.* Still in Diagnostic Tools, click **Start Event Log**. Trade your partner one item and **complete** the trade. Come back and click **Show Captured Events**. Find the line reading `UI_INFO_MESSAGE(<number>, ...)` fired at the moment the trade closed: that number is the id this client actually raised, read from the live event rather than from the message table. Compare it against the trade block from step 12 — they must be the same number. A `NOT FOUND` in step 12 alongside a number here means this client raises the result under a constant name GogoLoot doesn't resolve, and both outputs belong in the bug report. Failure is no `UI_INFO_MESSAGE` line in the log at all for a trade that plainly completed.

**14.** With **Enable Trade Announcements** on and **Message Output** set to **Whisper**, complete a trade in which you hand over two or more items and some gold, and receive at least one item back. A whisper must go to your trade partner in this shape:

> `{rt4} GogoLoot // Gave [Item A], [Item B] x3, 5g 20s to Partnername, received [Item C].`

Every item link must be clickable, the counts must match what actually changed hands, and the gold must read as gold/silver/copper. Failure is no whisper, a whisper naming items that weren't in the trade, `nil` anywhere, or a message that arrives before the trade finishes.

**15.** Open a trade window, put two items in from each side, then **cancel** it — press Escape or click Cancel. **No announcement may be sent, to anyone, on any channel.** Failure is a summary going out for a trade that never happened, which tells your group you handed over items you still have.

**16.** Immediately after that cancelled trade, open a new trade with the same partner, put in **one different item**, and complete it. The announcement must name **only that one item**. Failure is the cancelled trade's items appearing in this summary — that means the cancel path didn't clear its snapshot, and on this flavor the cancel id isn't being recognised.

### Master loot with a full-bagged recipient

One recipient's bags being full must not stop the rest of the kill from going out, and the group must be told once — not once per item, and not once per retry.

**17.** Set up a party of two, set the loot method to **Master Looter** with yourself as master looter, and set the loot threshold low enough that most drops qualify (Uncommon works). In the GogoLoot Master Looter panel, use **Send All Loot To** to point every tier at your partner. Have your partner **fill their bags completely** — zero free slots. Now kill a dungeon boss that drops **three or more items at once**.

**18.** Read your group chat. You must see **one** line naming your partner and listing the items that couldn't be delivered:

> `{rt4} GogoLoot // Partnername's bags are full: [Item A], [Item B], [Item C]`

One message, one player, one reason, all the items in a single list. Failure is one message per item, the same message repeating as the engine retries, or no message at all leaving the group to guess why loot stopped.

**19.** Now the part that matters most: while their bags are still full, change **one** quality tier's destination to **Self**, and kill another multi-item boss. The items for that tier must be **handed to you and announced normally**, while the items still routed at your full-bagged partner produce the bag-full message. **One recipient failing must not stop the others.** Failure is the whole distribution stalling after the first error, or the successful hand-outs going unannounced. Anything left undelivered must still be sitting in the loot window for you to assign by hand — failure is loot vanishing.

When steps 1–19 pass on both flavors, this release's changes are verified — run the rest of the plan, and when it passes on both flavors too, proceed to `4 - Pre-Launch Review Prompt.md`.

## Loading, commands, and the options panel

**20.** Log in with GogoLoot enabled. No Lua error window may appear and no red error text may print. Failure is any error popup naming GogoLoot, or the add-on missing from the AddOns list entirely.

**21.** Watch your chat frame at login. A coloured welcome line must print in the shape *"GogoLoot // Version …"*, pointing you at Options > AddOns > GogoLoot. Failure is no message, an uncoloured line, or a line containing `nil` or a stray `%s`.

**22.** Type `/gl`. The settings must appear **docked inside the Blizzard Options window**, with GogoLoot selected in the category list on the left. Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame. **This step is flavor-sensitive — TBC Anniversary is the client where the panel has historically floated free, so run it there and not just on Era.**

**23.** Close the Options window and type `/gogoloot`. It must open the same panel, docked the same way. Failure is the second command doing nothing or opening something different.

**24.** With GogoLoot selected, read the category list. Six entries must be present, in this order, and each must open without error: **GogoLoot**, **Master Looter**, **Automated Rolls**, **Announcements**, **Profiles**, **Diagnostic Tools**. Failure is a missing entry, an entry that opens blank, or an entry nested under the wrong parent.

**25.** Read the main GogoLoot panel top to bottom. You must see, in order: an intro paragraph, **Enable Welcome Message**, **Enable Mini-map Button**, a **/Commands** header listing `/gl` and `/gogoloot`, a **Speedy Loot** header with its description and **Enable Speedy Loot**, a **Feedback & Support** header with four link boxes, and a version line. Every one must read as a sentence or a label in your language. Failure is a raw key showing through — text like `SPEEDY_LOOT_HEADER` or `COMMANDS_DESCRIPTION` on screen instead of words.

**26.** Read the last line of the main panel. It must show a version. In an unpackaged working copy it correctly reads **"Version Dev"**; in a packaged release build it must read a real dated version. Failure is a literal `@project-version@` on screen in a release build.

**27.** Find the four boxes under **Feedback & Support**, labelled **Discord**, **GitHub**, **CurseForge**, and **Wago**. Each must display a complete, readable URL that points at GogoLoot. Click into one, select all, copy — the copied address must be the full link, not a fragment. Now type junk into a box, press Enter, click to another panel and back: the box must show its original URL again. Failure is an empty box, a truncated URL, a link to a different add-on, or your typed text sticking.

**28.** Untick **Enable Welcome Message**, `/reload`, and reopen the panel. The box must still be unticked, and no welcome line may print. Re-tick it and `/reload` — the line must print again. Failure is the setting reverting, or the toggle only working in one direction.

**29.** With the welcome message disabled, log out fully and log in on a **different character on the same account**. It must still be disabled — this setting is account-wide by design. Failure is the second character printing the welcome line, which means the setting is stored per profile instead of account-wide.

**30.** Untick **Enable Mini-map Button**. The minimap icon must disappear immediately, with no reload. Re-tick it — it must come straight back, in the same place on the minimap ring. Failure is the icon lingering, not returning, or jumping to a different position.

## Minimap button

**31.** Hover the minimap button without clicking. The tooltip must show, in order: **GogoLoot** with the version beside it; an **Automated Rolls** row with **Enabled** in green or **Disabled** in red, a one-line description, and a **Left-Click / Toggle** hint; a **Speedy Loot** row with the same shape and a **Right-Click / Toggle** hint; and finally **GogoLoot Options** with **Shift + Middle-Click** under it. Failure is a missing row, a status that doesn't match the panel, or raw keys instead of words.

**32.** With the tooltip still showing, **left-click**. The Automated Rolls status in the tooltip must flip on the spot without you moving the mouse away, and the **minimap icon artwork must change** to reflect the new state. Open the Automated Rolls panel — **Enable Automated Rolls** must match what the tooltip now says. Failure is the tooltip going stale, the icon not swapping, or the panel disagreeing with the button.

**33.** **Right-click** the button. The Speedy Loot status must flip in the tooltip, and the main GogoLoot panel's **Enable Speedy Loot** must match. Failure is either surface disagreeing with the other.

**34.** **Shift + Middle-click** the button. The options panel must open, docked, exactly as `/gl` opens it. Failure is nothing happening, or a plain middle-click (no Shift) opening it — the modifier is part of the binding.

**35.** Drag the minimap button to a different spot on the ring, `/reload`, and check it. It must still be where you put it. Now go to **Profiles**, click **Reset Profile**, and look again: the button must **not** move — its position is account-wide, not part of a loot profile. Failure is the button snapping back to a default position on either the reload or the profile reset.

## Speedy Loot

**36.** With **Enable Speedy Loot** on, Auto Loot on, and plenty of free bag space, kill an open-world mob and loot it. The loot window must **not** appear, and every item plus the coin must land in your bags. Failure is the standard loot window opening and staying open, or items being left behind.

**37.** Untick **Enable Speedy Loot** and loot another mob. The standard loot window must appear and behave exactly as the game normally does. Failure is looting still being bypassed, which means the toggle isn't gating anything.

**38.** Turn Speedy Loot back on, then **fill your bags to zero free slots** and kill a mob that drops at least one item. The loot window must **stay visible** and the items must **stay in it**, reachable once you make room. Coin, which takes no bag space, may still be picked up. Failure is the window being hidden with the loot stranded inside it, or the client spamming inventory-full errors.

**39.** Make one bag slot free, with Speedy Loot on, and loot a mob dropping several items. GogoLoot must take what fits and leave the rest **visible in the loot window**. Failure is loot disappearing, or the window closing on items you never received.

**40.** With Speedy Loot on and Auto Loot on, **hold the auto-loot modifier key** (the one bound in the game's settings, Shift by default) while looting a mob. The behavior must **invert**: the standard loot window opens instead of instant looting. Failure is the modifier being ignored, which takes away the player's manual override.

**41.** In a party with the loot method set to **Master Looter** and **you as master looter**, kill something with Speedy Loot on. Speedy Loot must **stand down completely** — the loot window opens normally so the master-loot flow can run. Failure is items being vacuumed into your own bags before they can be assigned, or the master-loot candidate dropdown popping up on its own.

## Automated Rolls

Run this section in a party of two with the loot method set to **Group Loot** and a threshold that lets greens roll.

**42.** Read the Automated Rolls panel top to bottom: a description, **Enable Automated Rolls**, a **Thresholds** header with its description, an **In Party** row and an **In Raid** row — each a label, a quality dropdown and an action dropdown on one line — then a **Custom Roll List** header, its description, **Enable Custom Roll List**, a **Restore Default Custom Roll List** button, an **Add Item** row, and the list of items. Failure is a missing control, a control stacked under its own duplicated label, or a raw key on screen.

**43.** Untick **Enable Automated Rolls** and kill mobs until a roll window opens. GogoLoot must do **nothing** — the roll window sits there waiting for you. Failure is a roll being cast with the master switch off.

**44.** Tick it back on. Set **In Party** to **Uncommon & Lower** and **Greed**, and kill mobs until a green drops. GogoLoot must press **Greed** for you and the roll window must close on its own. Failure is nothing happening, or the wrong button being pressed.

**45.** Change the **In Party** action to **Pass** and trigger another roll on a green. It must pass. Change it to **Need** and trigger another — it must need, or fall back to Greed on an item you can't need on. Failure is the action dropdown not being obeyed.

**46.** Set the **In Party** action to **Manual** and trigger another roll. GogoLoot must leave the roll entirely alone. Failure is a roll still being made, which means Manual isn't honoured.

**47.** Set **In Party** to **Common & Lower** and trigger a roll on a **green**. GogoLoot must **not** roll — the item is above the ceiling. Failure is the threshold being ignored.

**48.** Form a **raid** with your partner and confirm the **In Raid** row is the one being read: set In Raid to **Pass** and In Party to **Need**, then trigger a roll in the raid. It must pass. Failure is the party settings being applied in a raid, which would make the two rows pointless.

**49.** Trigger a roll on a **Bind on Pickup** item that isn't in your Custom Roll List, with the threshold set high enough to cover it. GogoLoot must **not** roll — the threshold path never touches BoP items. Failure is an automatic roll on a BoP item, which can bind something to you permanently without your say-so.

**50.** Trigger rolls on a **quest item**, a **recipe or book**, a **mount**, a **pet**, or a **legendary** (whichever you can reach). GogoLoot must never roll on any of them, at any threshold, with any action. Failure is any automatic roll on one of these — this is the add-on's core safety promise.

**51.** Open the **Custom Roll List** and confirm it is populated with items appropriate to this client. On Classic Era you should see Vanilla entries (Demonic Rune, Dark Rune, the Hakkari Bijous, the Silithus scarabs). **On TBC Anniversary you must additionally see TBC entries** — Primal Nether, Nether Vortex, the TBC gems. Failure is TBC items missing on Anniversary, or Vanilla-only lists appearing identical on both flavors, which means the expansion filter isn't reading the client.

**52.** With **Enable Custom Roll List** ticked, find a BoP item on the list (a **Demonic Rune** or **Dark Rune**), set its action dropdown to **Greed**, and trigger a roll on it. GogoLoot must greed it — a Custom Roll List entry deliberately overrides both the threshold **and** the BoP rule. Failure is nothing happening, which means the list isn't being consulted.

**53.** Set that same item's action to **Manual** and trigger another roll on it. GogoLoot must leave it alone. Failure is a roll still being made.

**54.** Untick **Enable Custom Roll List** and trigger a roll on that same BoP item. GogoLoot must now do nothing at all — with the list off, the threshold path takes over and it never touches BoP. Failure is the list still being applied while switched off.

**55.** In the **Add Item** box, type an item ID (`12662` for Demonic Rune) and press Enter. A new row must appear with that item's icon, link, an action dropdown and a remove icon. Now paste an **item link** into the same box — that must work too. Hover a row's label: the full item tooltip must appear. Failure is nothing being added, a row reading `Loading...` forever, or an item ID being accepted as literal text.

**56.** Click the **remove icon** on a row. That row must vanish immediately. Failure is the row staying, or the wrong item being removed.

**57.** Click **Restore Default Custom Roll List**. A confirmation must appear first; approve it, and the list must return to the defaults for this client, including anything you removed. Failure is the button acting with no confirmation, or the list not being restored.

**58.** Empty the Custom Roll List completely — remove every row — then `/reload`. The default list must be **re-seeded**. An empty list is treated as "never configured" on purpose. Failure is the list staying empty, or duplicating itself.

**59.** When GogoLoot rolls **Need** on an item that would bind to you, the game's bind-confirmation dialog must be answered automatically. Then roll **Need yourself, by hand**, on another such item: the confirmation dialog must appear and **wait for you**. Failure is your own manual rolls being auto-confirmed, which takes a decision out of your hands.

## Master Looter

Run this section in a party of two, mostly inside a dungeon.

**60.** As **group leader**, open the Master Looter panel. The **Loot Method** and **Loot Threshold** dropdowns must be editable, and no red warning may show. Change the loot method to **Master Looter** — the group's loot method must actually change, and the panel must repaint to match. Failure is a dropdown that won't change, or one that changes on screen while the group's real method stays put.

**61.** Have your **partner** open their Master Looter panel while you lead. Both dropdowns must be **disabled** for them, a red line must read that only the group leader can change these, and the labels must be suffixed **(Set by Yourname)**. Failure is a non-leader being able to change the group's loot rules, or the suffix naming the wrong player.

**62.** Set the loot method to **Free for All**, then **Round Robin**. In both cases the **Loot Threshold** row must **disappear entirely** — neither method uses a threshold — and no blank gap may be left behind. Set it back to Master Looter: the row must return. Failure is an inert threshold dropdown left on screen, or a double gap where the row was.

**63.** Open the **Loot Threshold** dropdown and read the entries. **On Classic Era it must offer five: Poor, Common, Uncommon, Rare, Epic. On TBC Anniversary it must offer only three: Uncommon, Rare, Epic** — the lower two do not exist on that client. **Run this on both flavors; it is the clearest per-client difference in the panel.** Failure is Era missing Poor and Common, or Anniversary offering them.

**64.** Set the loot threshold to **Rare**. In the **Loot Destinations** section, the rows below Rare (**Uncommon**, **Common**, **Poor**) must **disappear**, leaving Rare and Epic. Lower the threshold again and they must come back. Failure is destination rows for tiers that can never be master-looted.

**65.** Use **Send All Loot To** and pick your partner. Every visible per-tier destination dropdown must immediately show your partner. Now change **one** tier to somebody else: the **Send All Loot To** box must go **blank**, because the tiers no longer agree. Failure is Send All reporting one tier's answer as if it applied to all of them.

**66.** With **Enable Loot Destination Messages** on, change a single tier's destination. Exactly one group-chat line must go out:

> `{rt4} GogoLoot // Partnername will be holding Epic items for the group.`

Then use **Send All Loot To**: exactly **one** line must go out saying they'll be holding **all** loot — not one line per tier. Failure is five messages for one action, or no message at all.

**67.** Set a tier's destination to your partner, then have them **leave the group**. A line must announce that they left and that the tier now falls back to you, and that tier's dropdown must read **Self**. Failure is loot staying routed at somebody who isn't in the group any more.

**68.** With destinations set, **change the group's loot method** to anything else and back. Every destination must be **cleared to blank** — not to Self. A destination setup belongs to one master-loot session. Failure is a stale "everything goes to Bob" surviving into the next run invisibly.

**69.** With destinations set, **leave the group entirely**. The destinations must clear. Failure is them still being set when you next group up.

**70.** With **Enable Master Looter Pop-up** ticked, have your leader set the loot method to Master Looter with **you** as master looter. A **GogoLoot // Quick Settings** window must pop up, carrying **Loot Method**, **Loot Threshold** and **Send All Loot To**, and it must not be resizable. Changing a value in it must be reflected in the full Master Looter panel, and vice versa. Failure is no popup, a popup missing a row, or the two surfaces disagreeing.

**71.** In that popup, set the loot method to anything other than Master Looter. The **Send All Loot To** row must hide outright — a destination means nothing without master loot. Failure is the row sitting there inert.

**72.** Untick **Enable Master Looter Pop-up**, drop and re-form master loot. No popup may appear. Failure is the toggle being ignored.

**73.** Tick **Enable Automated Master Looting in Instances** while **not** the master looter. A line must print in your own chat frame — *"You are not currently the Master Looter."* — and nobody else may see it. Failure is silence (leaving you to wonder why nothing distributes), or the notice being sent to the group.

**74.** As master looter **inside a dungeon**, with Automated Master Looting on and destinations set, kill a boss. Qualifying items must be handed to their destinations automatically, and the loot window must close out. Failure is items sitting undistributed, or being assigned to the wrong player.

**75.** As master looter in the **open world**, with **Enable Automated Master Looting Outside of Instances** unticked, kill something that drops a qualifying item. GogoLoot must **not** auto-distribute — the item stays in the loot window for you. Tick the outside-instances toggle and repeat: now it must distribute. Failure is either the toggle being ignored, or open-world loot being handed out while it's off.

**76.** As master looter, kill something dropping an item from the **Ignore List** (a Demonic Rune, Dark Rune, or a bag). It must be **left in the loot window** for you to assign by hand. Failure is an ignore-listed item being auto-distributed.

**77.** Do the same for a **quest item, recipe, book, mount, pet, or legendary**. Every one must be left for manual handling, regardless of destinations or thresholds. Failure is any of them being auto-distributed — the same safety promise as step 50.

**78.** Open the **Ignore List**, add an item by ID and by dragged link, remove one with the remove icon, then click **Restore Default Ignore List** and approve the confirmation. Each must behave exactly as the Custom Roll List did in steps 55–57. **On TBC Anniversary the restored list must include the TBC entries** — Primal Nether, Nether Vortex, Heart of Darkness, Sunmote, the two TBC bags. Failure is any of those missing on Anniversary.

**79.** As master looter, assign an item **by hand** through the standard master-loot candidate dropdown. It must be announced to the group as *"Gave [Item] to Playername."* — **always**, with no toggle and no quality threshold gating it. Failure is a manual hand-out going unannounced.

**80.** Hand out an item by hand and, **before the announcement lands**, close the loot window (press Escape or loot the last item). The announcement must still reach the group. Failure is a deliberate hand-out vanishing because the window shut a fraction too early.

**81.** As master looter, move **out of range** of your destination player and let the automated pass try to hand them something. A group line must report them as out of range, naming the item. The item must still be in the loot window. Failure is a silent failure with no explanation, or an unrelated red error being read out to the group.

## Announcements

**82.** Read the Announcements panel top to bottom: a master-loot description, **Enable Loot Destination Messages** with a grey example, **Enable Automated Master Looting Announcements** with an **Auto Announce Threshold** dropdown and a grey example, a note that manual distributions are always announced, then a **Trade Announcements** header with a description, **Enable Trade Announcements**, a **When** dropdown, a **Message Output** dropdown, and a grey example. Failure is a missing control or a raw key on screen.

**83.** Untick **Enable Automated Master Looting Announcements**. The **Auto Announce Threshold** dropdown must grey out. Tick it back on — it must become usable again. Failure is a dropdown that stays live while the feature it configures is off.

**84.** Open the **Auto Announce Threshold** dropdown. It must offer exactly four entries — **Common+**, **Uncommon+**, **Rare+**, **Epic+** — each in its quality colour, regardless of what the group's loot threshold currently is. Failure is Poor appearing, or the list shrinking when the loot threshold changes.

**85.** Set the threshold to **Epic+** and let the automated pass hand out a **green** item. It must be delivered, and it must go **unannounced**. Now let it hand out an **epic**: that must be announced. Failure is either the threshold being ignored, or a below-threshold item failing to be delivered because it wasn't announceable.

**86.** Untick **Enable Loot Destination Messages** and change a destination. **No** group line may go out. Failure is destination chatter continuing after you switched it off.

**87.** Set **Message Output** to **Group Chat** and complete a trade while in a **party**. The summary must go to party chat, not as a whisper. Repeat in a **raid** — it must go to raid chat. Now complete a trade while **ungrouped** with the same setting: it must fall back to **whispering your trade partner** rather than being silently dropped. Failure is a summary vanishing, or being sent to a channel you aren't in.

**88.** Set **When** to **Only in Party or Raid** and complete a trade while **ungrouped**. No announcement may go out. Group up and repeat — it must announce. Then set **When** to **Only in Raid** and complete a trade in a **party**: no announcement. In a raid: announcement. Failure is any condition being ignored.

**89.** Open a trade window and look at its **bottom-left corner**. A checkbox labelled **Announce** must be there, ticked to match **Enable Trade Announcements**. Untick it: the panel's toggle must follow. Change the panel's toggle: the trade checkbox must follow the next time the window opens. Hover the checkbox — the tooltip must show **GogoLoot**, **Trade Announcements**, a description, and your **Current Output**. Failure is the checkbox missing, out of sync, or overlapping the trade window's own controls.

**90.** Fill a trade with **six distinct items, several of them in stacks**, plus gold on both sides, and complete it. The summary must arrive as **one or more complete sentences**, each starting with `{rt4} GogoLoot //`. No item link may be cut in half, no message may be silently dropped, and stacked items must read as `[Item] x5`. Failure is a broken link, a missing item, or a message that never arrives because it was too long to send.

**91.** With a **rogue or enchanter** partner, put an item in the trade's **enchant slot** — a lockbox for them to pick, or a piece of your gear for them to enchant — and complete the trade. The service must appear **by name** in the summary. Repeat with the roles reversed, so the item sits in **their** enchant slot and you perform the service: that must appear too. Failure is the service missing from one side or both. *(Skip this step if you have neither class available, and note it as skipped.)*

**92.** Complete a trade with a partner **on another realm** (in a battleground, if you can arrange it) with **Message Output** set to **Whisper**. The whisper must actually reach them. The summary text itself correctly shows just their character name without the realm — that's intended. Failure is the whisper bouncing back undelivered. *(Skip if unavailable, and note it as skipped.)*

## Profiles

**93.** Open Options → AddOns → GogoLoot → **Profiles**. The panel must load with a current profile shown — normally **Default**. Failure is a blank panel or a Lua error on opening it.

**94.** Change some loot settings (Automated Rolls thresholds, an ignore-list entry, the trade output), then create a new profile called `Test`. On `Test`, those settings must read as **defaults** again. Switch back to **Default** — your changes must be intact. Both panels must repaint the moment you switch, with **no `/reload` needed**. Failure is one profile's settings leaking into the other, or values frozen from whichever profile was active when you opened the window.

**95.** With `Test` active, use **Copy From** and copy from `Default`. `Test` must take on Default's settings immediately. Then `/reload`: `Test` must still be the active profile with its settings intact. Failure is the profile snapping back to Default across the reload.

**96.** With `Test` active, empty the Custom Roll List completely, then switch profiles away and back. The default list must be re-seeded, exactly as it was in step 58. Failure is an empty list persisting.

**97.** This is the one that catches the most damage: with any profile active, **untick Enable Welcome Message**, **untick Enable Speedy Loot**, and **move the minimap button**. Now click **Reset Profile**. All three must be **untouched** — the welcome message still off, Speedy Loot still off, the button still where you put it — while your loot settings return to defaults. These three are account-wide on purpose, so a profile reset must never turn Speedy Loot back on or move your button. Failure is any of the three reverting.

**98.** Switch back to **Default** and delete `Test`. The deletion must succeed with no error, and `Test` must be gone from the list and stay gone after a `/reload`. Failure is an error, or the profile reappearing.

## Diagnostic Tools

**99.** Log in fresh and open Options → AddOns → GogoLoot → **Diagnostic Tools**. Only two things may be visible: the warning paragraph and the **Enable Diagnostic Tools** toggle, which must be **off**. Failure is the toggle being on by default, or any report button visible before you enable anything.

**100.** Tick **Enable Diagnostic Tools**. Nine sections must appear below it without reopening the panel: **Event Log**, **Event Registration**, **API Endpoints**, **Loot Method**, **Other Add-ons**, **Saved Variables**, **Library Versions**, **Taint Log**, and **External Tools** — the last being two hint lines mentioning `/console scriptErrors 1` and `/etrace`. Then untick the toggle: everything below must vanish immediately, and any running event log must stop. Tick it back on, `/reload`, and reopen: the toggle must be **off** again — diagnostics is session-only and never persists. Failure is a missing section, a panel needing a reopen, or diagnostics surviving a reload.

**101.** Click **Show Captured Events** before starting a log — it must read **(no events captured)** under a header naming the add-on, its version and your client. Click **Start Event Log**, go loot a mob and complete a trade, then **Show Captured Events**: the output must list timestamped entries including `LOOT_READY`, `LOOT_OPENED` and `UI_INFO_MESSAGE`. Item links must appear as readable text (`|Hitem:…`), not as clickable icons that hide the data. Click **Stop Event Log** and show again — back to **(no events captured)**. Failure is an empty log after events plainly fired, or links rendering as swatches.

**102.** Click **Test Event Registration**, **Test WoW API Endpoints**, **Test Loot Method API**, **List Installed Add-ons**, **Dump Saved Variables**, and **List Library Versions** in turn, then read the Taint Log state line, click **Turn On Taint Log** (it must read level 2) and **Turn Off Taint Log** (back to level 0). Every report must fill its box with readable text. In **Test Event Registration**, all twenty events must read `[PASS]` and the summary must say they all register — `IsEventValid: n/a` is **not** a failure. In **Test WoW API Endpoints**, a `[FAIL]` on one half of a modern/legacy pair while its partner passes is **expected and correct**; only a pair failing on **both** halves is real. In **Dump Saved Variables**, `speedyLoot` and `showWelcome` must appear under `global` — not under a profile — and must match the panel. Failure is any button producing nothing, any `[FAIL]` in Event Registration, both halves of an API pair failing, or the taint level not moving. **Leave taint logging off when you're done.**

## Flavor differences to watch

Do not skim these. Each behaves differently on the two clients, and a plan run on only the forgiving flavor will pass while the add-on is broken for half its users.

- **Trade result detection (steps 12–16)** — the highest-risk difference in the add-on. Trade completion and cancellation are read from numeric message ids, and **the ids differ per flavor**. Era passing proves nothing whatsoever about Anniversary. Step 12's trade block prints the ids this client resolved; run it on both and compare the numbers, and fall back to step 13's event log when a constant reads `NOT FOUND`.
- **Options panel docking (step 22)** — correct on Classic Era; **TBC Anniversary is the client where the panel has historically floated free** of the Options window instead of docking inside it.
- **Loot threshold floor (step 63)** — Classic Era allows the threshold all the way down to **Poor**; TBC and later stop at **Uncommon**. The dropdown must show five entries on Era and three on Anniversary.
- **Expansion-filtered default item lists (steps 51 and 78)** — the Custom Roll List and the Ignore List are filtered to the client's expansion. Anniversary must show the TBC entries on top of the Vanilla ones; Era must not.
- **Master-loot error id resolution (step 12)** — the same failure carries a different id on every flavor, and a constant that resolves to nothing is a failure class that client can never report. Read the Loot Method report's loot error block on both.
- **API Endpoints report (step 102)** — expect roughly half of each modern/legacy pair to read `[FAIL]` on any given client. That is the report doing its job. Only a pair failing on **both** halves is a defect.

## Localization spot-check

**Required for this release, not optional.** Every locale file was rewritten this pass and two message templates were merged into one, so this is exactly where breakage will show. GogoLoot ships eleven locales and every chat message is assembled from translated text with item links substituted in.

**103.** Log in on a non-English client and open every GogoLoot panel. Labels, descriptions, notes and dropdown entries must all render in that language. Pay particular attention to the **Loot Method** row in the Master Looter panel and the **Enable Mini-map Button** toggle on the main panel — both were touched this pass, and the minimap toggle was previously left untranslated on ruRU. Failure is a raw key showing through — text like `MASTER_LOOTER_LOOT_METHOD` or `TRADE_CONDITION_ALWAYS` on screen instead of a sentence — or an English label sitting in the middle of a translated panel. **The Diagnostic Tools panel is deliberately English on every client** — that is intentional and not a failure.

**104.** Trigger one of each announcement: a trade summary, a master-loot hand-out, a destination change, and a distribution failure. Each must read as one complete, grammatical sentence with the item links, player names and quality names all present and in sensible places. The trade summary and the master-loot hand-out now come from the **same translated sentence** — read them side by side and confirm the one wording works for both: a list of traded items and a single assigned item must both fit it. Failure is `nil` anywhere, a stray `%s`, a value appearing twice, a player name and an item swapped, or a sentence that only makes sense for one of the two uses.

**105.** Run this on **ruRU** specifically — Cyrillic costs about twice the bytes per character, so it overflows the 255-byte chat limit long before German or French do. Complete a trade with six or more items in it. The summary must arrive as **several complete messages**, each one a whole readable sentence, splitting only between items — never mid-link. Failure is a truncated message, a broken character at a split point, an item link rendered as garbage, or a message that plainly never sent.

**106.** Read the translated sentences alongside the English ones, and the panel's grey examples alongside the messages they describe. Some languages reorder the sentence so the item, the player, or the quality name land in a different position — this is **intentional and correct**, and a translator should not "fix" it. Failure is only when the sentence is genuinely ungrammatical, a value is attached to the wrong part of it, or a grey example no longer matches the message its own locale now sends.

## Sign-off

Manual testing is complete when **every step passes on both Classic Era and TBC Anniversary**. A single flavor is half a run — and for this release in particular, the trade-result steps (12–16) are the ones only the Anniversary run can prove, while the localization steps (103–106) are the ones only a non-English client can prove. Once both rows below are filled in and passing, the add-on is ready for `4 - Pre-Launch Review Prompt.md`.

| Flavor | Tester | Date | Result | Failed steps |
| --- | --- | --- | --- | --- |
| Classic Era | | | ☐ Pass ☐ Fail | |
| TBC Anniversary | | | ☐ Pass ☐ Fail | |

Localization spot-check (steps 103–106) run on locale: ____________  ☐ Pass ☐ Fail

---
