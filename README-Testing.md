# GogoLoot — Manual Test Plan

This is the manual test plan for GogoLoot — the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/GogoLoot/blob/main/README-Technical.md).

## How to run this plan

Run the whole list on Classic Era, then again on TBC Anniversary. Do a `/reload` before starting each flavor.

Work top to bottom. Every step tells you exactly what to do, what you should see, and what failure looks like — if a step doesn't match its expected result, it failed. Steps are numbered continuously from 1 to 115 across the whole document, so a bug report only needs "failed on step N."

Some steps behave differently on the two clients and say so in the step itself. Those are not optional on either flavor — the client a step warns about is precisely the one where that step earns its keep. **A run on only one flavor is not a completed run.**

## Before you start

Gather these once so you aren't caught short mid-run:

- **Both flavors installed** — Classic Era and TBC Anniversary. The add-on ships for both, and both must be tested. Make sure both folders are the **same build** before you start; testing an old copy on one flavor proves nothing about the release.
- **A second player you can group and trade with.** This is the single most important fixture. Master looting, trade announcements, and every group-chat message need a real second character; nearly a third of this plan is unreachable solo. A second WoW account, a trusted guildmate, or a friend all work.
- **A character on that second account whose bags you can fill.** One step needs a loot recipient with **zero free general-purpose bag slots** — buy vendor trash, or empty their bags into the bank and stuff them with a stack-splitting item until nothing fits.
- **A level 60 character who can get into Zul'Gurub or Ahn'Qiraj (20).** This release's headline fix is the war-effort tokens — Hakkari bijous, Zandalar coins, Silithus scarabs, the AQ idols — so steps 4 to 8 need one of those actually dropping in a party. Both raids are reachable on **both** flavors. Read steps 4 and 5 before you set out; there is a cheaper substitute on Classic Era only, and it is spelled out there.
- **A dungeon you can both zone into and clear a boss in.** Master loot only auto-distributes inside instances by default, and BoP items are only redistributable there. Any low-level dungeon works — you want a boss that drops **three or more items at once**, so Ragefire Chasm, Deadmines, or Wailing Caverns bosses are all fine.
- **Open-world mobs that drop greens**, for Automated Rolls in a party under Group Loot.
- **A stack of tradable items** — six or more distinct items, plus a couple of stacks of five or more, to fill a trade window and force the long-trade split.
- **Some gold on both characters**, for the money line in a trade summary.
- **A rogue, or an enchanter** — optional, for the trade enchant-slot step. Skip that one step if you have neither.
- **Your own bags fillable to zero free slots**, for the Speedy Loot no-space step.
- **A second character on your own account**, for the account-wide settings steps.
- **A profile you have not logged into since installing this build**, if you have one. Step 2 checks that an established profile picks up the new token entries without losing choices you made yourself; a brand-new profile can't show that.
- **A non-English client.** Normally optional; **for this release it is required** — every locale file was rewritten. See steps 112–115, and read the note at the top of the localization group below.

GogoLoot has no class-specific behavior, so any classes will do. Unless a step says otherwise, be **out of combat**.

## Verify this release's changes

This release carries four sets of changes, all in the same untagged build: the war-effort token rolls, a localization and message-template pass, and three earlier behavior fixes. Steps 1–27 are what turn "we changed it" into "we watched it work" — run them first, and run every one of them on **both** flavors.

### War-effort token rolls

The Ahn'Qiraj and Zul'Gurub war-effort tokens are quest-class items, and until this build every path that could have rolled on them threw them away — the Custom Roll List had the right item ids and the right saved action, and no roll ever went out. Two things changed: an explicit list entry is now honoured **ahead of** the quest-item skip, and a roll whose item the client hasn't cached yet is retried until the item resolves instead of being abandoned after five seconds. The default list also grew, and an existing profile is migrated into the new entries.

**1.** Open Options → AddOns → GogoLoot → **Automated Rolls** and read the **Custom Roll List**. These must all be present, and the action beside each must read as listed:

- **Need** — the eight Silithus scarabs (Bone, Stone, Clay, Crystal, Gold, Silver, Bronze, Ivory), the eight AQ20 idols (Azure, Onyx, Lambent, Amber, Jasper, Obsidian, Vermillion, Alabaster), the eight AQ40 idols (Idol of the Sun, of Night, of Death, of the Sage, of Rebirth, of Life, of Strife, of War), the nine Hakkari bijous, the nine Zandalar coins, **Scarab Bag**, **Scarab Coffer Key** and **Greater Scarab Coffer Key**.
- **Manual** — the four **Wartorn** scraps (Cloth, Leather, Chain, Plate). These are deliberately left to you; an automatic Need on one in a pug reads as ninja-ing.

Failure is any of those rows missing, or an idol or scarab sitting on **Manual** when the list above says Need. **Run this on both flavors** — these are Vanilla-era items and they must appear on TBC Anniversary too.

**2.** Prove the migration didn't trample your own choices. Set **Idol of the Sun** to **Pass**, then **remove** the **Scarab Bag** row with its remove icon. Type `/reload` and reopen the panel. Idol of the Sun must still read **Pass**, and Scarab Bag must still be **gone**. Failure is either one snapping back to the shipped default — that means the migration is re-running on every login instead of once per profile, and no player could ever keep a choice about these items.

**3.** Click **Restore Default Custom Roll List** and approve the confirmation. Everything from step 1 must come back, at the actions step 1 lists — including the Scarab Bag you removed, and with Idol of the Sun back on **Need**. Failure is a partial restore, or the tokens returning on Manual.

**4.** The headline fix. In a party of two with the loot method set to **Group Loot**, **Enable Automated Rolls** ticked and **Enable Custom Roll List** ticked, go and make a war-effort token drop — Zul'Gurub trash for a bijou or a coin, Ahn'Qiraj (20) for a scarab. When the roll window opens, **GogoLoot must press Need for you and the window must close on its own.** Failure is the roll window simply sitting there until it expires: that is the exact old behavior — right item id, right saved action, no roll, no error.

*On Classic Era only, there is a cheaper substitute if you can't reach either raid:* have your leader set the group's loot threshold to **Poor**, kill low-level mobs until an ordinary **quest item** drops and opens a roll, and add that item's id to the Custom Roll List with an action of **Greed**. It must be greeded. This substitute does **not** exist on TBC Anniversary — the threshold there stops at Uncommon — so the Anniversary run needs a real token.

**5.** Now the timing half, and it only works on the token's **first appearance of the session**. Log out and log back in (a `/reload` is not enough — the client keeps its item cache across one), then go straight back and take another token roll without opening the Custom Roll List first. The roll must still be made — often a beat later than usual, up to a second or two after the window opens — and it must land well inside the roll's own timer. Failure is no roll at all on the first drop of the night while a second drop minutes later works fine: that is the item-cache race, and it is the one this step exists to catch.

**6.** Trigger a token roll and immediately press **Pass** (or **Need**) **yourself**, by hand, before GogoLoot acts. Your click must stand, and nothing may happen afterwards — no second roll, no delayed action on the next roll window that opens. Failure is a stray roll arriving seconds later on an unrelated item, which means the retry poll outlived the roll it belonged to.

**7.** Untick **Enable Custom Roll List** and take another token roll with **Enable Automated Rolls** still on and the threshold set high enough to cover the item. GogoLoot must do **nothing at all** — with no explicit list entry, a quest-class item is never picked up by the threshold path. Then untick **Enable Automated Rolls**, re-tick the Custom Roll List, and take another: again **nothing**. Failure in either case is a roll going out; the list is the only thing that may roll these items, and the master switch outranks it.

**8.** Prove master looting is unaffected. As **Master Looter** inside a dungeon, with Automated Master Looting on and destinations set, make a war-effort token drop. It must be **left in the loot window** for you to assign by hand, never auto-distributed — the Custom Roll List is an instruction about *rolls* and has no say over master loot. Failure is a token being handed out automatically.

### Localized text and the shared hand-out template

All eleven locales were rewritten this pass. At the same time the two separate hand-out sentences — one for master loot, one for trades — were merged into a **single shared template**, `Gave %s to %s.`, and several option labels were renamed or reworded. One sentence now has to read correctly in two completely different situations, in eleven languages, and a label whose key changed will show as a raw key in any locale that wasn't updated with it.

Because every string moved, the **localization spot-check in steps 112–115 is not optional for this release.** Run it on at least one non-English client, ruRU for preference.

**9.** Log in and open every GogoLoot panel in turn: **GogoLoot**, **Master Looter**, **Automated Rolls**, **Announcements**, **Profiles**, **Diagnostic Tools**. Every label, description, dropdown entry and button must read as words — a sentence or a caption — in your client's language. Failure is a raw key showing through: text like `MASTER_LOOTER_LOOT_METHOD`, `SPEEDY_LOOT_HEADER` or `TRADE_CONDITION_ALWAYS` on screen instead of words, which is exactly what a key renamed in the code but not in a locale file looks like. **The Diagnostic Tools panel is deliberately English on every client — that is intended and not a failure.**

**10.** Now prove the shared sentence on its **master loot** side. As master looter, hand an item out **by hand** through the standard master-loot candidate dropdown. The group must see one line reading:

> `{rt4} GogoLoot // Gave [Item] to Playername.`

The item link must be clickable and the name must be the player you picked. Failure is `nil` or a stray `%s` in the sentence, the item and the player appearing in the wrong slots, or no line at all.

**11.** Prove the same sentence on its **trade** side. With **Enable Trade Announcements** on and **Message Output** set to **Whisper**, complete a trade where **you hand over two or more items and receive nothing back**. The whisper must read:

> `{rt4} GogoLoot // Gave [Item A] x2, [Item B] to Partnername.`

This is the same template as step 10 doing a different job — a list of items where step 10 had one, a trade partner where step 10 had a loot recipient. Both must be grammatical. Failure is either sentence reading as though it were written for the other case: a plural list jammed into a singular phrasing, or a sentence that only makes sense about loot appearing on a trade.

**12.** Complete a **two-sided** trade — items from you and items from them. One message must read `Gave [items] to Partnername, received [items].` Then complete a trade where **only they give** and you hand over nothing: it must read `Received [items] from Partnername.` Failure is either shape coming out as two half-sentences, one side going missing, or a `nil` where a name or an item should be.

**13.** Open the **Announcements** panel and read the three grey example lines — the trade example, the loot-destination example, and the automated-announce example. Each must match the sentence the add-on actually sends, word for word apart from the sample names and items. Compare the trade example against what you saw in step 11, and the automated-announce example against step 10. Failure is an example that still shows the old wording while the real message shows the new — a translated example that drifted from its template misleads every player who reads the panel.

**14.** In the **Master Looter** panel, find the **Current Loot Settings** section and read its two dropdown rows: **Loot Method** and **Loot Threshold**. Both must read as labels in your language — the Loot Method key was renamed this pass, so a stale locale shows a raw key right here. Have your partner open the same panel while you lead: above their two dropdowns a blue line must read **These settings are set by Yourname.**, naming you, and their labels must stay plain. Then find **Enable Master Looter Pop-up** — spelled with the hyphen, sitting below the Automated Master Looting sub-options — and tick it; the window it opens must be titled **GogoLoot // Quick Settings**. Failure is a raw key in either row, a leader line naming the wrong player, or the toggle missing entirely.

### Speedy Loot and the Auto Loot setting

GogoLoot only touches the game's Auto Loot setting on behalf of Speedy Loot, only when the setting is actually off, and it always says so. With Speedy Loot off it must leave the setting completely alone.

**15.** Open the GogoLoot options (`/gl`) and **untick Enable Speedy Loot**. Then open the game's own settings and **untick Auto Loot** (Esc → Options → Interface → Controls on Era; Esc → Options → Controls on Anniversary). Type `/reload` and **wait a full ten seconds** watching your chat frame. No GogoLoot line about Auto Loot may print, and when you reopen the game settings **Auto Loot must still be unticked**. Failure is either the message appearing or the Auto Loot box ticking itself back on — GogoLoot has no business changing a setting for a feature you turned off.

**16.** With Speedy Loot still off and Auto Loot still off, log out fully and log back in on a **different character**. Wait ten more seconds. Again: **no message, and Auto Loot stays off.** Speedy Loot is an account-wide setting, so it is still off on this character; this step catches an enforcement path that fires at login rather than on the toggle. Failure is the message appearing on a character you never enabled Speedy Loot on.

**17.** Now open the GogoLoot options and **tick Enable Speedy Loot**, with Auto Loot still off. A line must print immediately in your chat frame reading:

> `GogoLoot // Auto Loot has been enabled. Speedy Loot requires it to function.`

The message must **name Speedy Loot** — that is what tells the player which of their own choices caused the change. Reopen the game settings: **Auto Loot must now be ticked.** Failure is no message, a message that doesn't say why the setting changed, or Auto Loot staying off while Speedy Loot claims to be on.

**18.** Leave Speedy Loot on and Auto Loot on, and type `/reload`. Wait ten seconds. **No message this time.** The write only ever fires when the setting is genuinely off, so a reload with everything already correct must be silent. Failure is the line printing on every reload, which trains players to ignore it.

**19.** Untick Auto Loot again, then **right-click the minimap button twice** — once to turn Speedy Loot off, once to turn it back on. The same message from step 17 must print on the second click, and Auto Loot must tick back on. Failure is the minimap path staying silent or not enforcing the setting, which would mean only the options panel is wired up.

### Trade result detection

Trade completion and cancellation are read from a numeric message id, and **the ids are different on every flavor**. A pass on Era proves nothing at all about Anniversary — this is the single most flavor-sensitive behavior in the add-on, and it is why the Anniversary run exists.

**20.** Open Options → AddOns → GogoLoot → **Diagnostic Tools**, tick **Enable Diagnostic Tools**, then click **Test Loot Method API**. Scroll to the two id blocks at the end of the output — *Loot error message ids (constant -> id on this client)* and *Trade result message ids (constant -> id on this client)*. Every constant in **both** blocks must show a **number**, not `NOT FOUND`, and the closing line must report a non-zero count of scanned game messages. The trade block is what this step exists for: `ERR_TRADE_COMPLETE` and `ERR_TRADE_CANCELLED` are the ids the trade watcher matches on, they are different numbers on Era and Anniversary, and this is the whole per-flavor check in one button press. **Write both numbers down next to this step for this flavor** — comparing the Era pair against the Anniversary pair is how you confirm both clients were genuinely exercised. Failure is `GetGameMessageInfo not available`, a scan count of 0, or every constant reading `NOT FOUND`; any of those means neither trade results nor loot errors can be detected on this flavor. A single trade constant reading `NOT FOUND` is a narrower but real failure: that one result drops to comparing translated text, the fragile path the id matching exists to avoid — record it and run step 21.

**21.** *Fallback — run this when step 20 showed `NOT FOUND` for either trade constant, or when a trade step below misbehaves.* Still in Diagnostic Tools, click **Start Event Log**. Trade your partner one item and **complete** the trade. Come back and click **Show Captured Events**. Find the `UI_INFO_MESSAGE(<number>, ...)` entry for the moment the trade closed — an id GogoLoot correlates shows as a timestamped line, and an id it doesn't (which is exactly the `NOT FOUND` case this fallback exists for) shows in the **Suppressed** block at the bottom of the report, with its text and a count. Either way, that number is the id this client actually raised, read from the live event rather than from the message table. Compare it against the trade block from step 20 — they must be the same number. A `NOT FOUND` in step 20 alongside a number here means this client raises the result under a constant name GogoLoot doesn't resolve, and both outputs belong in the bug report. Failure is no `UI_INFO_MESSAGE` entry anywhere in the report — timeline or Suppressed block — for a trade that plainly completed.

**22.** With **Enable Trade Announcements** on and **Message Output** set to **Whisper**, complete a trade in which you hand over two or more items and some gold, and receive at least one item back. A whisper must go to your trade partner in this shape:

> `{rt4} GogoLoot // Gave [Item A], [Item B] x3, 5g 20s to Partnername, received [Item C].`

Every item link must be clickable, the counts must match what actually changed hands, and the gold must read as gold/silver/copper. Failure is no whisper, a whisper naming items that weren't in the trade, `nil` anywhere, or a message that arrives before the trade finishes.

**23.** Open a trade window, put two items in from each side, then **cancel** it — press Escape or click Cancel. **No announcement may be sent, to anyone, on any channel.** Failure is a summary going out for a trade that never happened, which tells your group you handed over items you still have.

**24.** Immediately after that cancelled trade, open a new trade with the same partner, put in **one different item**, and complete it. The announcement must name **only that one item**. Failure is the cancelled trade's items appearing in this summary — that means the cancel path didn't clear its snapshot, and on this flavor the cancel id isn't being recognised.

### Master loot with a full-bagged recipient

One recipient's bags being full must not stop the rest of the kill from going out, and the group must be told once — not once per item, and not once per retry.

**25.** Set up a party of two, set the loot method to **Master Looter** with yourself as master looter, and set the loot threshold low enough that most drops qualify (Uncommon works). In the GogoLoot Master Looter panel, use **Send All Loot To** to point every tier at your partner. Have your partner **fill their bags completely** — zero free slots. Now kill a dungeon boss that drops **three or more items at once**.

**26.** Read your group chat. You must see **one** line naming your partner and listing the items that couldn't be delivered:

> `{rt4} GogoLoot // Partnername's bags are full: [Item A], [Item B], [Item C]`

One message, one player, one reason, all the items in a single list. Failure is one message per item, the same message repeating as the engine retries, or no message at all leaving the group to guess why loot stopped.

**27.** Now the part that matters most: while their bags are still full, change **one** quality tier's destination to **Self**, and kill another multi-item boss. The items for that tier must be **handed to you and announced normally**, while the items still routed at your full-bagged partner produce the bag-full message. **One recipient failing must not stop the others.** Failure is the whole distribution stalling after the first error, or the successful hand-outs going unannounced. Anything left undelivered must still be sitting in the loot window for you to assign by hand — failure is loot vanishing.

When steps 1–27 pass on both flavors, this release's changes are verified — run the rest of the plan, and when it passes on both flavors too, proceed to `4 - Pre-Launch Review Prompt.md`.

## Loading, commands, and the options panel

**28.** Log in with GogoLoot enabled. No Lua error window may appear and no red error text may print. Failure is any error popup naming GogoLoot, or the add-on missing from the AddOns list entirely.

**29.** Watch your chat frame at login. A coloured welcome line must print in the shape *"GogoLoot // Version …"*, pointing you at Options > AddOns > GogoLoot. Failure is no message, an uncoloured line, or a line containing `nil` or a stray `%s`.

**30.** Type `/gl`. The settings must appear **docked inside the Blizzard Options window**, with GogoLoot selected in the category list on the left. Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame. **This step is flavor-sensitive — TBC Anniversary is the client where the panel has historically floated free, so run it there and not just on Era.**

**31.** Close the Options window and type `/gogoloot`. It must open the same panel, docked the same way. Failure is the second command doing nothing or opening something different.

**32.** Get into combat — pull an open-world mob — and while still in combat type `/gl`, then **Shift + Middle-click** the minimap button. Both must print, in your own chat frame only:

> `GogoLoot // As a safety precaution, the Options Interface cannot be opened during combat.`

The panel must **not** open. Kill the mob and leave combat, then watch for five seconds: the panel must **not** open by itself now either. Failure is the panel opening during combat, silence with nothing explaining why, a red `ADDON_ACTION_BLOCKED` error, or the panel popping open on its own the moment combat ends.

**33.** With GogoLoot selected, read the category list. Six entries must be present, in this order, and each must open without error: **GogoLoot**, **Master Looter**, **Automated Rolls**, **Announcements**, **Profiles**, **Diagnostic Tools**. Failure is a missing entry, an entry that opens blank, or an entry nested under the wrong parent.

**34.** Read the main GogoLoot panel top to bottom. You must see, in order: an intro paragraph, **Enable Welcome Message**, **Enable Mini-map Button**, a **/Commands** header listing `/gl` and `/gogoloot`, a **Speedy Loot** header with its description and **Enable Speedy Loot**, a **Feedback & Support** header with four link boxes, and a version line. Every one must read as a sentence or a label in your language. Failure is a raw key showing through — text like `SPEEDY_LOOT_HEADER` or `COMMANDS_DESCRIPTION` on screen instead of words.

**35.** Read the last line of the main panel. It must show a version. In an unpackaged working copy it correctly reads **"Version Dev"**; in a packaged release build it must read a real dated version. Failure is a release build still reading **"Version Dev"** — that means packaging never substituted the real version — or any version string with an `@` in it.

**36.** Find the four boxes under **Feedback & Support**, labelled **Discord**, **GitHub**, **CurseForge**, and **Wago**. Each must display a complete, readable URL that points at GogoLoot. Click into one, select all, copy — the copied address must be the full link, not a fragment. Now type junk into a box, press Enter, click to another panel and back: the box must show its original URL again. Failure is an empty box, a truncated URL, a link to a different add-on, or your typed text sticking.

**37.** Untick **Enable Welcome Message**, `/reload`, and reopen the panel. The box must still be unticked, and no welcome line may print. Re-tick it and `/reload` — the line must print again. Failure is the setting reverting, or the toggle only working in one direction.

**38.** With the welcome message disabled, log out fully and log in on a **different character on the same account**. It must still be disabled — this setting is account-wide by design. Failure is the second character printing the welcome line, which means the setting is stored per profile instead of account-wide.

**39.** Untick **Enable Mini-map Button**. The minimap icon must disappear immediately, with no reload. Re-tick it — it must come straight back, in the same place on the minimap ring. Failure is the icon lingering, not returning, or jumping to a different position.

## Minimap button

**40.** Hover the minimap button without clicking. The tooltip must show, in order: **GogoLoot** with the version beside it; an **Automated Rolls** row with **Enabled** in green or **Disabled** in red, a one-line description, and a **Left-Click / Toggle** hint; a **Speedy Loot** row with the same shape and a **Right-Click / Toggle** hint; and finally **GogoLoot Options** with **Shift + Middle-Click** under it. Failure is a missing row, a status that doesn't match the panel, or raw keys instead of words.

**41.** With the tooltip still showing, **left-click**. The Automated Rolls status in the tooltip must flip on the spot without you moving the mouse away, and the **minimap icon artwork must change** to reflect the new state. Open the Automated Rolls panel — **Enable Automated Rolls** must match what the tooltip now says. Failure is the tooltip going stale, the icon not swapping, or the panel disagreeing with the button.

**42.** **Right-click** the button. The Speedy Loot status must flip in the tooltip, and the main GogoLoot panel's **Enable Speedy Loot** must match. Failure is either surface disagreeing with the other.

**43.** **Shift + Middle-click** the button. The options panel must open, docked, exactly as `/gl` opens it. Failure is nothing happening, or a plain middle-click (no Shift) opening it — the modifier is part of the binding.

**44.** Drag the minimap button to a different spot on the ring, `/reload`, and check it. It must still be where you put it. Now go to **Profiles**, click **Reset Profile**, and look again: the button must **not** move — its position is account-wide, not part of a loot profile. Failure is the button snapping back to a default position on either the reload or the profile reset.

## Speedy Loot

**45.** With **Enable Speedy Loot** on, Auto Loot on, and plenty of free bag space, kill an open-world mob and loot it. The loot window must **not** appear, and every item plus the coin must land in your bags. Failure is the standard loot window opening and staying open, or items being left behind.

**46.** Untick **Enable Speedy Loot** and loot another mob. The standard loot window must appear and behave exactly as the game normally does. Failure is looting still being bypassed, which means the toggle isn't gating anything.

**47.** Turn Speedy Loot back on, then **fill your bags to zero free slots** and kill a mob that drops at least one item. The loot window must **stay visible** and the items must **stay in it**, reachable once you make room. Coin, which takes no bag space, may still be picked up. Failure is the window being hidden with the loot stranded inside it, or the client spamming inventory-full errors.

**48.** Make one bag slot free, with Speedy Loot on, and loot a mob dropping several items. GogoLoot must take what fits and leave the rest **visible in the loot window**. Failure is loot disappearing, or the window closing on items you never received.

**49.** With Speedy Loot on and Auto Loot on, **hold the auto-loot modifier key** (the one bound in the game's settings, Shift by default) while looting a mob. The behavior must **invert**: the standard loot window opens instead of instant looting. Failure is the modifier being ignored, which takes away the player's manual override.

**50.** In a party with the loot method set to **Master Looter** and **you as master looter**, kill something with Speedy Loot on. Speedy Loot must **stand down completely** — the loot window opens normally so the master-loot flow can run. Failure is items being vacuumed into your own bags before they can be assigned, or the master-loot candidate dropdown popping up on its own.

## Automated Rolls

Run this section in a party of two with the loot method set to **Group Loot** and a threshold that lets greens roll.

**51.** Read the Automated Rolls panel top to bottom: a description, **Enable Automated Rolls**, a **Thresholds** header with its description, an **In Party** row and an **In Raid** row — each a label, a quality dropdown and an action dropdown on one line — then a **Custom Roll List** header, its description, **Enable Custom Roll List**, a **Restore Default Custom Roll List** button, an **Add Item** row, and the list of items. Failure is a missing control, a control stacked under its own duplicated label, or a raw key on screen.

**52.** Untick **Enable Automated Rolls** and kill mobs until a roll window opens. GogoLoot must do **nothing** — the roll window sits there waiting for you. Failure is a roll being cast with the master switch off.

**53.** Tick it back on. Set **In Party** to **Uncommon & Lower** and **Greed**, and kill mobs until a green drops. GogoLoot must press **Greed** for you and the roll window must close on its own. Failure is nothing happening, or the wrong button being pressed.

**54.** Change the **In Party** action to **Pass** and trigger another roll on a green. It must pass. Change it to **Need** and trigger another — it must need, or fall back to Greed on an item you can't need on. Failure is the action dropdown not being obeyed.

**55.** Set the **In Party** action to **Manual** and trigger another roll. GogoLoot must leave the roll entirely alone. Failure is a roll still being made, which means Manual isn't honoured.

**56.** Set **In Party** to **Common & Lower** and trigger a roll on a **green**. GogoLoot must **not** roll — the item is above the ceiling. Failure is the threshold being ignored.

**57.** Form a **raid** with your partner and confirm the **In Raid** row is the one being read: set In Raid to **Pass** and In Party to **Need**, then trigger a roll in the raid. It must pass. Failure is the party settings being applied in a raid, which would make the two rows pointless.

**58.** Trigger a roll on a **Bind on Pickup** item that isn't in your Custom Roll List, with the threshold set high enough to cover it. GogoLoot must **not** roll — the threshold path never touches BoP items. Failure is an automatic roll on a BoP item, which can bind something to you permanently without your say-so.

**59.** The safety promise, and note that it has two halves that behave differently:

- **Absolute, no exceptions** — a **recipe or book**, a **mount**, a **pet**, or a **legendary** is never rolled on, at any threshold, with any action, **even if you put it on the Custom Roll List yourself**. Add one to the list, set it to Greed, trigger a roll: nothing must happen.
- **Skipped unless you asked for it** — a **quest item** is never picked up by the threshold path, but a Custom Roll List entry does roll it. That is the war-effort token feature from steps 1–8, and it is intended. Trigger a roll on a quest item that is **not** on the list: nothing must happen.

Failure is any automatic roll on a recipe, book, mount, pet or legendary; or a roll on an unlisted quest item.

**60.** Read the whole **Custom Roll List** and confirm it is populated with items appropriate to this client. On both flavors you should see the Vanilla entries — the war-effort tokens from step 1, plus Demonic Rune, Dark Rune, the Librams, the Punctured Voodoo Dolls. **On TBC Anniversary you must additionally see TBC entries** — Primal Nether, Nether Vortex, Fel Armament, the TBC gems. Failure is TBC items missing on Anniversary, or the two flavors showing identical lists, which means the expansion filter isn't reading the client.

**61.** With **Enable Custom Roll List** ticked, find a BoP item on the list (a **Demonic Rune** or **Dark Rune**), set its action dropdown to **Greed**, and trigger a roll on it. GogoLoot must greed it — a Custom Roll List entry deliberately overrides both the threshold **and** the BoP rule. Failure is nothing happening, which means the list isn't being consulted.

**62.** Set that same item's action to **Manual** and trigger another roll on it. GogoLoot must leave it alone. Failure is a roll still being made.

**63.** Untick **Enable Custom Roll List** and trigger a roll on that same BoP item. GogoLoot must now do nothing at all — with the list off, the threshold path takes over and it never touches BoP. Failure is the list still being applied while switched off.

**64.** In the **Add Item** box, type an item ID (`12662` for Demonic Rune) and press Enter. A new row must appear with that item's icon, link, an action dropdown and a remove icon. Now paste an **item link** into the same box — that must work too. Hover a row's label: the full item tooltip must appear. Failure is nothing being added, a row reading `Loading...` forever, or an item ID being accepted as literal text.

**65.** Click the **remove icon** on a row. That row must vanish immediately. Failure is the row staying, or the wrong item being removed.

**66.** Click **Restore Default Custom Roll List**. A confirmation must appear first; approve it, and the list must return to the defaults for this client, including anything you removed. Failure is the button acting with no confirmation, or the list not being restored.

**67.** Empty the Custom Roll List completely — remove every row — then `/reload`. The default list must be **re-seeded**. An empty list is treated as "never configured" on purpose. Failure is the list staying empty, or duplicating itself.

**68.** When GogoLoot rolls **Need** on an item that would bind to you, the game's bind-confirmation dialog must be answered automatically. Then roll **Need yourself, by hand**, on another such item: the confirmation dialog must appear and **wait for you**. Failure is your own manual rolls being auto-confirmed, which takes a decision out of your hands.

## Master Looter

Run this section in a party of two, mostly inside a dungeon.

**69.** As **group leader**, open the Master Looter panel. The **Loot Method** and **Loot Threshold** dropdowns must be editable, and no red warning may show. Change the loot method to **Master Looter** — the group's loot method must actually change, and the panel must repaint to match. Failure is a dropdown that won't change, or one that changes on screen while the group's real method stays put.

**70.** Have your **partner** open their Master Looter panel while you lead. In **Current Loot Settings**, both dropdowns must be **disabled** for them, and a single blue line above the pair must read **These settings are set by Yourname.** — one statement, not a warning plus a suffix on each label. Now pass lead to them and have them look again: the line must **disappear** and both dropdowns become usable, with no blank gap left where it was. Check your own panel while solo too — no line there either. Failure is a non-leader being able to change the group's loot rules, a line naming the wrong player, or a line that lingers once the player controls the settings themselves.

**71.** Set the loot method to **Free for All**, then **Round Robin**. In both cases the **Loot Threshold** row must **disappear entirely** — neither method uses a threshold — and no blank gap may be left behind. Set it back to Master Looter: the row must return. Failure is an inert threshold dropdown left on screen, or a double gap where the row was.

**72.** Open the **Loot Threshold** dropdown and read the entries. **On Classic Era it must offer five: Poor, Common, Uncommon, Rare, Epic. On TBC Anniversary it must offer only three: Uncommon, Rare, Epic** — the lower two do not exist on that client. **Run this on both flavors; it is the clearest per-client difference in the panel.** Failure is Era missing Poor and Common, or Anniversary offering them.

**72a.** In **Loot Destinations**, the per-tier rows are collapsed by default — the section must open with just **Send All Loot To** and a **Set Quality Tiers Individually** toggle, and that toggle must read as its plain label with nothing appended. It sits indented under Send All Loot To with a silver caption, the same shape as the sub-options in step 84a: the checkbox itself moves, not just the words. Tick it: five quality rows (subject to the threshold, step 73) must appear. Failure is the rows showing while the toggle is unticked, or a checkbox that lines up with the labels above instead of indenting past them.

**73.** With **Set Quality Tiers Individually** ticked, read the tier rows as a shape first: each quality name must be indented one step **further** than the toggle above it, so they read as belonging to it — while their dropdowns stay in the **same column** as the **Send All Loot To** dropdown, sharing its left and right edges. A tier column that has drifted right of Send All Loot To is a failure. Then set the loot threshold to **Rare**: the rows below Rare (**Uncommon**, **Common**, **Poor**) must **disappear**, leaving Rare and Epic, with no blank gaps where they were. Lower the threshold again and they must come back. Failure is destination rows for tiers that can never be master-looted.

**74.** Use **Send All Loot To** and pick your partner. Every visible per-tier destination dropdown must immediately show your partner, and the **Set Quality Tiers Individually** toggle must carry **no suffix at all** — the dropdown already names them. Now change **one** tier to somebody else: the **Send All Loot To** box must go **blank**, because the tiers no longer agree. Failure is Send All reporting one tier's answer as if it applied to all of them.

**74a.** Leave that one divergent tier in place and untick **Set Quality Tiers Individually**. The rows must collapse and the toggle's label must now read **tiers differ**, in blue. This is the step that matters: with the rows hidden and Send All Loot To blank by design, that label is the only thing on the panel telling you a per-tier setup exists at all. Tick the toggle again — your divergent tier must still be there, unchanged. Failure is a collapsed panel that looks unconfigured, or collapsing the rows altering a destination.

**75.** With **Enable Loot Destination Messages** on, change a single tier's destination. Exactly one group-chat line must go out:

> `{rt4} GogoLoot // Partnername will be holding Epic items for the group.`

Then use **Send All Loot To**: exactly **one** line must go out saying they'll be holding **all** loot — not one line per tier. Failure is five messages for one action, or no message at all.

**76.** Set a tier's destination to your partner, then have them **leave the group**. A line must announce that they left and that the tier now falls back to you, and that tier's dropdown must read **Self**. Failure is loot staying routed at somebody who isn't in the group any more.

**77.** With destinations set, **change the group's loot method** to anything else and back. Every destination must be **cleared to blank** — not to Self. A destination setup belongs to one master-loot session. Failure is a stale "everything goes to Bob" surviving into the next run invisibly.

**78.** With destinations set, **leave the group entirely**. The destinations must clear. Failure is them still being set when you next group up.

**79.** With **Enable Master Looter Pop-up** ticked, have your leader set the loot method to Master Looter with **you** as master looter. A **GogoLoot // Quick Settings** window must pop up, carrying **Loot Method**, **Loot Threshold** and **Send All Loot To**, and it must not be resizable. Changing a value in it must be reflected in the full Master Looter panel, and vice versa. Failure is no popup, a popup missing a row, or the two surfaces disagreeing.

**80.** In that popup, set the loot method to anything other than Master Looter. The **Send All Loot To** row must hide outright — a destination means nothing without master loot. Failure is the row sitting there inert.

**81.** Untick **Enable Master Looter Pop-up**, drop and re-form master loot. No popup may appear. Failure is the toggle being ignored.

**81a.** Re-tick the toggle and, while you are master looter, **change zones repeatedly** — walk across a zone border, take a boat or zeppelin, hearth, and step into and out of an instance. **The popup must not appear once.** Nothing about your loot setup changed, so nothing should open. This is the one that used to fail: a loading screen re-syncs the party's loot state, and the moment where the client reads as "not master looter" looked exactly like being handed the role. Before you start, set **Send All Loot To** to your partner, and check it again after each zone change: **the destinations you set must still be there**, with nobody announced as having left. The same loading-screen gap that opened the popup also read as the leader switching the loot method, which silently cleared the whole setup. Then `/reload` while still master looter — the popup **must** appear there, because a reload is a standing start. Failure is any popup on a zone change, a destination that reverted to blank or to Self, a stray "has left the group" line, or no popup after the reload.

**81b.** Confirm the other way you can be handed the role still opens it. In a three-player group where **somebody else** is master looter, have that player leave, so the role falls to you with no loot-method change behind it. The popup must appear. Failure is silence — this path arrives on the roster update alone, and is the case a narrower trigger would drop.

**82.** Tick **Enable Automated Master Looting** while **not** the master looter. A line must print in your own chat frame — *"You are not currently the Master Looter."* — and nobody else may see it. Failure is silence (leaving you to wonder why nothing distributes), or the notice being sent to the group.

**83.** As master looter **inside a dungeon**, with Automated Master Looting on and destinations set, kill a boss. Qualifying items must be handed to their destinations automatically, and the loot window must close out. Failure is items sitting undistributed, or being assigned to the wrong player.

**84.** As master looter in the **open world**, with **Also Outside Instances** unticked, kill something that drops a qualifying item. GogoLoot must **not** auto-distribute — the item stays in the loot window for you. Tick the outside-instances toggle and repeat: now it must distribute. Failure is either the toggle being ignored, or open-world loot being handed out while it's off.

**84a.** Read the **Automated Master Looting** section as a shape. **Enable Automated Master Looting** sits flush left with no location in its name. Under it, **Also Outside Instances** and **Include Quest Items** are indented — and it is the **checkbox itself** that moves, not just the words: each sub-option's box must start roughly where the master switch's box ends, with its caption in **silver** against the master switch's white. A row where the boxes line up in one column and only the captions are pushed right is a failure, not a near miss. The note under each sub-option indents one step further again, aligning under its caption rather than under its box.

Untick the master switch. **Everything below it must disappear** — the two sub-options, their notes, the pop-up toggle, Current Loot Settings, Loot Destinations and the Ignore List — leaving only the description and the switch itself. GogoLoot distributes nothing anywhere with it off, instance or open world, so none of that is a live setting. Tick it back on and the whole panel must return, with the loot threshold row and the quality tiers respecting their own rules again (steps 72a–73) rather than all of them reappearing regardless. Finally, confirm the world-boss line under **Also Outside Instances** is **blue, not red** — it's a fact about world bosses, not an error. Failure is anything lingering below a switched-off master toggle, a master switch whose label still claims to be instance-only, an indent that moved only the caption, or a row coming back that its own rules say should stay hidden.

**85.** As master looter, kill something dropping an item from the **Ignore List** (a Demonic Rune, Dark Rune, or a bag). It must be **left in the loot window** for you to assign by hand. Failure is an ignore-listed item being auto-distributed.

**86.** Do the same for a **recipe, book, mount, pet, or legendary**. Every one must be left for manual handling, regardless of destinations or thresholds. Then, with **Include Quest Items** left unticked (its default), do it for a **quest item** — **including the war-effort tokens**, which the Custom Roll List rolls on but master loot leaves alone (step 8). Failure is any of them being auto-distributed.

**86a.** Now tick **Include Quest Items** and set the loot threshold as low as your client allows (**Poor** on Classic Era). Two blue lines sit under that toggle whether it is ticked or not — one about the loot threshold and eligibility, one beginning **Caution:** about dual-boxing — since both are what you read to decide whether to tick it at all. Kill something that drops a **quest item** and confirm it is now auto-distributed to the destination for its quality tier. Repeat with a **recipe or legendary** in the same pull: those must still be left for manual handling — the opt-in covers quest items only. Untick it again and confirm quest items go back to being skipped. **On TBC Anniversary the threshold floor is Uncommon**, so most quest items never reach master loot there at all and this step can only be run on Era. Failure is the toggle doing nothing, or opting out of any skip other than quest items.

**86b.** With **Include Quest Items** still ticked, trigger a **roll** on a quest item that is **not** on the Custom Roll List (step 60's setup). GogoLoot must still do **nothing** — the opt-in is master-loot distribution only and must never reach the roll path. Failure is a roll going out.

**87.** Open the **Ignore List**, add an item by ID and by dragged link, remove one with the remove icon, then click **Restore Default Ignore List** and approve the confirmation. Each must behave exactly as the Custom Roll List did in steps 64–66. **On TBC Anniversary the restored list must include the TBC entries** — Primal Nether, Nether Vortex, Heart of Darkness, Sunmote, the two TBC bags. Failure is any of those missing on Anniversary.

**88.** As master looter, assign an item **by hand** through the standard master-loot candidate dropdown. It must be announced to the group as *"Gave [Item] to Playername."* — **always**, with no toggle and no quality threshold gating it. Failure is a manual hand-out going unannounced.

**89.** Hand out an item by hand and, **before the announcement lands**, close the loot window (press Escape or loot the last item). The announcement must still reach the group. Failure is a deliberate hand-out vanishing because the window shut a fraction too early.

**90.** As master looter, move **out of range** of your destination player and let the automated pass try to hand them something. A group line must report them as out of range, naming the item. The item must still be in the loot window. Failure is a silent failure with no explanation, or an unrelated red error being read out to the group.

## Announcements

**91.** Read the Announcements panel top to bottom: a master-loot description, **Enable Loot Destination Messages** with a silver example, **Enable Automated Master Looting Announcements** with an **Auto Announce Threshold** dropdown and a silver example, a blue note that manual distributions are always announced, then a **Trade Announcements** header with a description, **Enable Trade Announcements**, a **When** dropdown, a **Message Output** dropdown, and a silver example. Failure is a missing control or a raw key on screen.

**91a.** Now read it as a shape. Only the three **Enable** toggles sit flush left; everything else belongs to one of them and is **indented** under it — each example, the **Auto Announce Threshold** row, and the **When** and **Message Output** rows, with those three row labels in silver rather than white. Their dropdowns must nonetheless line up in the **same column** as each other and as the dropdowns on the Master Looter panel: indenting a row narrows its label, it does not push the control right. The blue manual-distribution note is the one line that is deliberately **not** indented — manual hand-outs have no toggle for it to belong to. Failure is a dropdown column that steps right where a row is indented, or an example sitting flush with the toggle it illustrates.

**92.** Untick **Enable Automated Master Looting Announcements**. The **Auto Announce Threshold** row must **disappear** — not grey out — and leave no double gap where it was. Its silver example must **stay**, because that example is how you decide whether to turn the thing back on. Tick it back on and the row must return. Then do the same with **Enable Trade Announcements**: **When** and **Message Output** must both go and come back with it, its example staying throughout. Failure is a dropdown that lingers while the feature it configures is off, an example that vanishes with it, or a widening gap each time you toggle.

**93.** Open the **Auto Announce Threshold** dropdown. It must offer exactly four entries — **Common+**, **Uncommon+**, **Rare+**, **Epic+** — each in its quality colour, regardless of what the group's loot threshold currently is. Failure is Poor appearing, or the list shrinking when the loot threshold changes.

**94.** Set the threshold to **Epic+** and let the automated pass hand out a **green** item. It must be delivered, and it must go **unannounced**. Now let it hand out an **epic**: that must be announced. Failure is either the threshold being ignored, or a below-threshold item failing to be delivered because it wasn't announceable.

**95.** Untick **Enable Loot Destination Messages** and change a destination. **No** group line may go out. Failure is destination chatter continuing after you switched it off.

**96.** Set **Message Output** to **Group Chat** and complete a trade while in a **party**. The summary must go to party chat, not as a whisper. Repeat in a **raid** — it must go to raid chat. Now complete a trade while **ungrouped** with the same setting: it must fall back to **whispering your trade partner** rather than being silently dropped. Failure is a summary vanishing, or being sent to a channel you aren't in.

**97.** Set **When** to **Only in Party or Raid** and complete a trade while **ungrouped**. No announcement may go out. Group up and repeat — it must announce. Then set **When** to **Only in Raid** and complete a trade in a **party**: no announcement. In a raid: announcement. Failure is any condition being ignored.

**98.** Open a trade window and look at its **bottom-left corner**. A checkbox labelled **Announce** must be there, ticked to match **Enable Trade Announcements**. Untick it: the panel's toggle must follow. Change the panel's toggle: the trade checkbox must follow the next time the window opens. Hover the checkbox — the tooltip must show **GogoLoot**, **Trade Announcements**, a description, and your **Current Output**. Failure is the checkbox missing, out of sync, or overlapping the trade window's own controls.

**99.** Fill a trade with **six distinct items, several of them in stacks**, plus gold on both sides, and complete it. The summary must arrive as **one or more complete sentences**, each starting with `{rt4} GogoLoot //`. No item link may be cut in half, no message may be silently dropped, and stacked items must read as `[Item] x5`. Failure is a broken link, a missing item, or a message that never arrives because it was too long to send.

**100.** With a **rogue or enchanter** partner, put an item in the trade's **enchant slot** — a lockbox for them to pick, or a piece of your gear for them to enchant — and complete the trade. The service must appear **by name** in the summary. Repeat with the roles reversed, so the item sits in **their** enchant slot and you perform the service: that must appear too. Failure is the service missing from one side or both. *(Skip this step if you have neither class available, and note it as skipped.)*

**101.** Complete a trade with a partner **on another realm** (in a battleground, if you can arrange it) with **Message Output** set to **Whisper**. The whisper must actually reach them. The summary text itself correctly shows just their character name without the realm — that's intended. Failure is the whisper bouncing back undelivered. *(Skip if unavailable, and note it as skipped.)*

## Profiles

**102.** Open Options → AddOns → GogoLoot → **Profiles**. The panel must load with a current profile shown — normally **Default**. Failure is a blank panel or a Lua error on opening it.

**103.** Change some loot settings (Automated Rolls thresholds, an ignore-list entry, the trade output), then create a new profile called `Test`. On `Test`, those settings must read as **defaults** again. Switch back to **Default** — your changes must be intact. Both panels must repaint the moment you switch, with **no `/reload` needed**. Failure is one profile's settings leaking into the other, or values frozen from whichever profile was active when you opened the window.

**104.** With `Test` active, use **Copy From** and copy from `Default`. `Test` must take on Default's settings immediately. Then `/reload`: `Test` must still be the active profile with its settings intact. Failure is the profile snapping back to Default across the reload.

**105.** With `Test` active, empty the Custom Roll List completely, then switch profiles away and back. The default list must be re-seeded, exactly as it was in step 67 — war-effort tokens included, at the actions step 1 lists. Failure is an empty list persisting, or the tokens coming back on Manual.

**106.** This is the one that catches the most damage: with any profile active, **untick Enable Welcome Message**, **untick Enable Speedy Loot**, and **move the minimap button**. Now click **Reset Profile**. All three must be **untouched** — the welcome message still off, Speedy Loot still off, the button still where you put it — while your loot settings return to defaults. These three are account-wide on purpose, so a profile reset must never turn Speedy Loot back on or move your button. Failure is any of the three reverting.

**107.** Switch back to **Default** and delete `Test`. The deletion must succeed with no error, and `Test` must be gone from the list and stay gone after a `/reload`. Failure is an error, or the profile reappearing.

## Diagnostic Tools

**108.** Log in fresh and open Options → AddOns → GogoLoot → **Diagnostic Tools**. Only two things may be visible: the warning paragraph and the **Enable Diagnostic Tools** toggle, which must be **off**. Failure is the toggle being on by default, or any report button visible before you enable anything.

**109.** Tick **Enable Diagnostic Tools**. Nine sections must appear below it without reopening the panel: **Event Log**, **Event Registration**, **API Endpoints**, **Loot Method**, **Other Add-ons**, **Saved Variables**, **Library Versions**, **Taint Log**, and **External Tools** — the last being two hint lines mentioning `/console scriptErrors 1` and `/etrace`. Then untick the toggle: everything below must vanish immediately, and any running event log must stop. Tick it back on, `/reload`, and reopen: the toggle must be **off** again — diagnostics is session-only and never persists. Failure is a missing section, a panel needing a reopen, or diagnostics surviving a reload.

**110.** Click **Show Captured Events** before starting a log — it must read **(no events captured)** under a header naming the add-on, its version and your client. Click **Start Event Log**, go loot a mob and complete a trade, then **Show Captured Events**: the output must list timestamped entries including `LOOT_READY`, `LOOT_OPENED` and `UI_INFO_MESSAGE`. Item links must appear as readable text (`|Hitem:…`), not as clickable icons that hide the data. The combat and UI-message spam GogoLoot doesn't act on is deliberately **not** in the timeline — it is counted in the **Suppressed** block at the end instead, so don't read its absence as a missing log. Click **Stop Event Log** and show again — back to **(no events captured)**. Failure is an empty log after events plainly fired, or links rendering as swatches.

**111.** Click **Test Event Registration**, **Test WoW API Endpoints**, **Test Loot Method API**, **List Installed Add-ons**, **Dump Saved Variables**, and **List Library Versions** in turn, then read the Taint Log state line, click **Turn On Taint Log** (it must read level 2) and **Turn Off Taint Log** (back to level 0). Every report must fill its box with readable text. In **Test Event Registration**, all twenty events must read `[PASS]` and the summary must say they all register — `IsEventValid: n/a` is **not** a failure. In **Test WoW API Endpoints**, a `[FAIL]` on one half of a modern/legacy pair while its partner passes is **expected and correct**; only a pair failing on **both** halves is real. In **Dump Saved Variables**, `speedyLoot` and `showWelcome` must appear under `global` — not under a profile — and must match the panel. Failure is any button producing nothing, any `[FAIL]` in Event Registration, both halves of an API pair failing, or the taint level not moving. **Leave taint logging off when you're done.**

## Flavor differences to watch

Do not skim these. Each behaves differently on the two clients, and a plan run on only the forgiving flavor will pass while the add-on is broken for half its users.

- **Trade result detection (steps 20–24)** — the highest-risk difference in the add-on. Trade completion and cancellation are read from numeric message ids, and **the ids differ per flavor**. Era passing proves nothing whatsoever about Anniversary. Step 20's trade block prints the ids this client resolved; run it on both and compare the numbers, and fall back to step 21's event log when a constant reads `NOT FOUND`.
- **Options panel docking (step 30)** — correct on Classic Era; **TBC Anniversary is the client where the panel has historically floated free** of the Options window instead of docking inside it.
- **Loot threshold floor (step 72)** — Classic Era allows the threshold all the way down to **Poor**; TBC and later stop at **Uncommon**. The dropdown must show five entries on Era and three on Anniversary. This is also why step 4's cheap substitute exists on Era only: with the threshold at Poor, any quest item opens a roll window, and on Anniversary it cannot.
- **Expansion-filtered default item lists (steps 60 and 87)** — the Custom Roll List and the Ignore List are filtered to the client's expansion. Anniversary must show the TBC entries on top of the Vanilla ones; Era must not. The war-effort tokens are Vanilla-era entries and must appear on **both**.
- **Master-loot error id resolution (step 20)** — the same failure carries a different id on every flavor, and a constant that resolves to nothing is a failure class that client can never report. Read the Loot Method report's loot error block on both.
- **API Endpoints report (step 111)** — expect roughly half of each modern/legacy pair to read `[FAIL]` on any given client. That is the report doing its job. Only a pair failing on **both** halves is a defect.

## Localization spot-check

**Required for this release, not optional.** Every locale file was rewritten this pass and two message templates were merged into one, so this is exactly where breakage will show. GogoLoot ships eleven locales and every chat message is assembled from translated text with item links substituted in.

**112.** Log in on a non-English client and open every GogoLoot panel. Labels, descriptions, notes and dropdown entries must all render in that language. Pay particular attention to the **Loot Method** row in the Master Looter panel and the **Enable Mini-map Button** toggle on the main panel — both were touched this pass, and the minimap toggle was previously left untranslated on ruRU. Failure is a raw key showing through — text like `MASTER_LOOTER_LOOT_METHOD` or `TRADE_CONDITION_ALWAYS` on screen instead of a sentence — or an English label sitting in the middle of a translated panel. **The Diagnostic Tools panel is deliberately English on every client** — that is intentional and not a failure.

**113.** Trigger one of each announcement: a trade summary, a master-loot hand-out, a destination change, and a distribution failure. Each must read as one complete, grammatical sentence with the item links, player names and quality names all present and in sensible places. The trade summary and the master-loot hand-out now come from the **same translated sentence** — read them side by side and confirm the one wording works for both: a list of traded items and a single assigned item must both fit it. Failure is `nil` anywhere, a stray `%s`, a value appearing twice, a player name and an item swapped, or a sentence that only makes sense for one of the two uses.

**114.** Run this on **ruRU** specifically — Cyrillic costs about twice the bytes per character, so it overflows the 255-byte chat limit long before German or French do. Complete a trade with six or more items in it. The summary must arrive as **several complete messages**, each one a whole readable sentence, splitting only between items — never mid-link. Failure is a truncated message, a broken character at a split point, an item link rendered as garbage, or a message that plainly never sent.

**115.** Read the translated sentences alongside the English ones, and the panel's grey examples alongside the messages they describe. Some languages reorder the sentence so the item, the player, or the quality name land in a different position — this is **intentional and correct**, and a translator should not "fix" it. Failure is only when the sentence is genuinely ungrammatical, a value is attached to the wrong part of it, or a grey example no longer matches the message its own locale now sends.

## Sign-off

Manual testing is complete when **every step passes on both Classic Era and TBC Anniversary**. A single flavor is half a run — and for this release in particular, the war-effort token steps (1–8) are the ones that need a trip into Zul'Gurub or Ahn'Qiraj, the trade-result steps (20–24) are the ones only the Anniversary run can prove, and the localization steps (112–115) are the ones only a non-English client can prove. Once both rows below are filled in and passing, the add-on is ready for `4 - Pre-Launch Review Prompt.md`.

| Flavor | Tester | Date | Result | Failed steps |
| --- | --- | --- | --- | --- |
| Classic Era | | | ☐ Pass ☐ Fail | |
| TBC Anniversary | | | ☐ Pass ☐ Fail | |

Localization spot-check (steps 112–115) run on locale: ____________  ☐ Pass ☐ Fail

War-effort token steps (1–8) run in: ☐ Zul'Gurub ☐ Ahn'Qiraj (20) ☐ Era substitute (step 4)

---

## Guide Feedback

Generated on 2026-08-04 after performing README-Testing generation on GogoLoot.

Nothing cleared the bar this pass — no item in the guide, the templates, the master list, or the exceptions file would break the add-on, the build, or a future pass if left as it is.
