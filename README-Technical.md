# GogoLoot — Technical Reference

This document combines architecture notes and contribution guidance for developers working on GogoLoot. For end-user documentation, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md).

## File Map

```
GogoLoot/
├── .github/workflows/package.yml        CurseForge + Wago release, library vendoring (repo only)
├── .gitattributes                       LF normalization (repo only)
├── .pkgmeta                             Externals and ignore list; externals check out into Includes/Libraries/ (repo only)
├── LICENSE                              MIT (repo only)
├── GogoLoot.toc                         Load order: Includes → Locales → Data → Features → Options
├── Data/
│   ├── Data.lua                         Constants only (expansion, item class/bind, roll, quality, colors, target marker, options widths, registry names, label maps); no logic beyond WOW_PROJECT_ID
│   └── Default-Settings.lua             ns.DATABASE_DEFAULTS plus the default custom-roll and ML-ignore item lists
├── Features/
│   ├── Core.lua                         Version, saved-variable lifecycle + migrations, the event dispatcher, ns.EVENT_NAMES, the Auto Loot CVar enforcement
│   ├── Utilities.lua                    API compatibility shims, game-message id resolution, named timers, colors, tooltips, name/item parsing, the item-skip predicates, game-state predicates
│   ├── Announcements.lua                PrintMessage / Announce / BuildAnnounceMessage, group-channel resolution, welcome message
│   ├── Announcements-Trade.lua          Trade snapshotting, summary building and chunking, trade-result detection, trade-window checkbox
│   ├── Speedy-Loot.lua                  LOOT_READY fast-looting with a free-bag-slot budget
│   ├── Master-Looter.lua                ML API wrappers, eligibility check (WillAutoMasterLoot), destination lifecycle, pop-up trigger
│   ├── Master-Looter-Distribution.lua   Manual-distribution hook, the LOOT_OPENED distribution engine, and the Pending Hand-out Registry
│   ├── Automated-Rolls.lua              START_LOOT_ROLL threshold + custom roll list, with a named-timer retry for cold item info
│   ├── Diagnostics.lua                  Read-only environment probes and report builders for bug reports (runtime-only state, never a SavedVariable)
│   └── Minimap-Button.lua               LibDataBroker launcher, minimap icon state, tooltip
├── Includes/
│   ├── Images/GogoLoot.tga              Add-on-list icon (## IconTexture)
│   └── Libraries/                       Bundled libraries (packager externals; never edit by hand)
├── Locales/                             AceLocale files, 11 locales; enUS.lua is the source of truth
├── Options/
│   ├── Options-Utilities.lua            Widget helper constructors, item-cache warming, shared item-list builder, GogoLoot_ItemLink widget
│   ├── Options-General.lua              Root General panel (welcome, minimap toggle, Speedy Loot, links)
│   ├── Options-Master-Looter.lua        Master Looter panel + the shared loot method/threshold/Send All row builders
│   ├── Options-Master-Looter-Popup.lua  The window that opens on becoming master looter (registered, never added to the Blizzard tree)
│   ├── Options-Automated-Rolls.lua      Automated Rolls panel (per-context thresholds + custom roll list)
│   ├── Options-Announcements.lua        Announcements panel (master looter + trade sections)
│   ├── Options-Profiles.lua             Stock AceDBOptions panel, returned unmodified
│   ├── Options-Diagnostics.lua          Diagnostic Tools panel (single runtime toggle gates the whole panel)
│   └── Options.lua                      AceConfig registration, Blizzard panel wiring, slash commands
├── Tests/                               Dev-only suite, absent from the TOC; `lua Tests/Run.lua`
│   ├── Fakes/WoW.lua                    The WoW and Ace surface the suite runs against
│   └── Run.lua                          Loader and assertions
├── README.md                            End-user documentation
├── README-Technical.md                  This document
└── README-Testing.md                    Manual test plan, run before a release is tagged
```

Everything lives on the addon namespace table (`local ADDON_NAME, ns = ...`); the only globals are `GogoLootDB` (SavedVariables), the slash commands (`SLASH_GOGOLOOT1/2`, `SlashCmdList["GOGOLOOT"]`), and two named frames (`GogoLootEventFrame`, `GogoLootTradeAnnounceCheckbox`). The minimap button's frame is created inside LibDBIcon, not by GogoLoot.

## Architecture

### Event Loop

`Features/Core.lua` owns a single named event frame (`GogoLootEventFrame`) and a dispatcher. Modules never call `frame:RegisterEvent` directly — they call `ns:RegisterModuleEvent(event, handler)`, which registers the event with the frame once and appends the handler to `ns.eventHandlers[event]`. On fire, `OnEvent` fans out to every handler for that event in registration order.

Two things wrap the fan-out:

- **Drift guard.** `ns.EVENT_NAMES` (Core.lua, kept sorted alphabetically) is the exported single source of truth for every event the add-on registers. `RegisterModuleEvent` prints a one-time developer warning if handed an event missing from that list. The list exists so the Diagnostics Event Registration probe can enumerate events without reading the live handler table — which would miss on-demand, self-unregistering registrations like Options-Utilities' `GET_ITEM_INFO_RECEIVED` watcher.
- **Diagnostics tap.** When `ns.diagnostics.logging` is true, `OnEvent` hands each event to `ns:LogEvent` before dispatching. Boolean checks gate it, so it costs nothing when logging is off.

`ns:UnregisterModuleEvent` exists but is **not** safe to call from inside an event handler — `OnEvent` iterates the live handler list. Defer to a timer or user-driven path: the item-cache watcher is the only caller, and it unregisters from inside its debounced repaint timer rather than from the `GET_ITEM_INFO_RECEIVED` handler itself. The roll retry never unregisters anything — it is a named timer, torn down with `ns:CancelTimer`.

Who listens to what:

- `Features/Core.lua` — `ADDON_LOADED` (saved-variable init, migrations, minimap + options bootstrap), `PLAYER_ENTERING_WORLD` (one-shot auto-loot CVar enforcement, delayed 3 s).
- `Features/Announcements.lua` — `PLAYER_LOGIN` (welcome message).
- `Features/Announcements-Trade.lua` — `TRADE_SHOW` (twice: state reset, and checkbox create/sync), `TRADE_ACCEPT_UPDATE`, `TRADE_PLAYER_ITEM_CHANGED`, `TRADE_TARGET_ITEM_CHANGED`, `TRADE_REQUEST_CANCEL`, `UI_INFO_MESSAGE` (trade complete/cancel).
- `Features/Speedy-Loot.lua` — `LOOT_READY`, throttled to one pass per 0.3 s (`LOOT_THROTTLE_SECONDS`) to absorb double-fires.
- `Features/Master-Looter.lua` — `GROUP_ROSTER_UPDATE`, `PARTY_LOOT_METHOD_CHANGED`.
- `Features/Master-Looter-Distribution.lua` — `LOOT_OPENED`, `LOOT_CLOSED`, `LOOT_SLOT_CLEARED`, `UI_ERROR_MESSAGE`; plus a `hooksecurefunc` on `GiveMasterLoot` for manual distributions.
- `Features/Automated-Rolls.lua` — `START_LOOT_ROLL`, `CONFIRM_LOOT_ROLL`, `CANCEL_LOOT_ROLL`.
- `Options/Options-Utilities.lua` — `GET_ITEM_INFO_RECEIVED`, registered on demand and self-unregistering (see Item Data Caching).
- `Features/Diagnostics.lua` — none at runtime; its Event Registration probe registers then immediately unregisters each `ns.EVENT_NAMES` entry on a **separate** frame, with no handler attached, so probing never disturbs the live dispatcher.

### Combat Lockdown

`ns:OpenOptionsPanel` (`Options/Options.lua`) is the one combat guard in the add-on, and it **refuses outright rather than deferring**: `InCombatLockdown()` is the first thing the function does, it prints `CHAT_OPTIONS_IN_COMBAT` through `ns:PrintMessage`, and it returns. Nothing is queued for later — Blizzard's Settings panel is protected in combat, and a queued open would land at a moment the player never asked for. Because the gate sits at the single entry point, in front of the whole routing chain, the slash commands and the mini-map button's Shift + Middle-Click all answer identically on every flavor.

Nothing else in GogoLoot needs a guard. The loot, roll, and trade paths call no protected APIs — `GiveMasterLoot`, `RollOnLoot`, and `LootSlot` are all callable in combat, which is exactly where a raid uses them. The master looter pop-up is an AceConfigDialog window rather than part of the Blizzard settings tree, so it is unprotected and safe to open mid-fight.

### Master Loot Pipeline

The distribution engine in `Features/Master-Looter-Distribution.lua` runs Scan → Resolve → Distribute → Confirm:

1. **Scan** — `LOOT_OPENED` fires `RunDistributionPass` when `ns:WillAutoMasterLoot()` is true (master looter + `autoMasterLoot`, inside a raid/party instance unless `autoMasterLootOutsideInstances`).
2. **Resolve** — `BuildCandidateMap` maps lowercased candidate names per slot, adding a realm-stripped alias only when exactly one candidate normalizes to it; ambiguous duplicates (e.g. `Bob` and `Bob-OtherRealm`) create no alias and fall back to manual handling rather than guessing.
3. **Distribute** — `TryDistributeSlot` gates each slot (`ns:ShouldSkipItemForMasterLoot`, ignore list, BoP outside trade-eligible instances, quality→destination mapping) and calls `GiveMasterLoot(slot, candidate, true)` — the `true` lets the manual hook distinguish automated calls. Distribution takes the never-automated set unconditionally and the quest-class skip unless `autoMasterLootQuestItems` is on: it has no per-item instruction to honour, so the panel toggle is the only thing that can weigh against the skip (see Item-Type Skips).
4. **Confirm** — announcements are never sent inline; see the Pending Hand-out Registry deep-dive. A 0.1 s retry ticker (`DISTRIBUTION_RETRY_INTERVAL`) re-runs the pass up to 20 times (`DISTRIBUTION_MAX_RETRIES`) until nothing is left or `DISTRIBUTION_QUIET_TICKS` consecutive ticks make no progress, covering late candidate data and cold item caches.

### Detecting the Master Looter (verified on Classic Era 1.15.9)

`ns:AreWeMasterLooter()` (`Features/Utilities.lua`) gates the whole pipeline, and every branch it takes has been confirmed against a live 1.15.9 client rather than assumed:

- **The legacy `GetLootMethod` global is gone** on 1.15.9 (`GetLootThreshold` survives — the split is per-function, so don't infer one from the other). The `C_PartyInfo.GetLootMethod` branch is the live path, not a fallback. `SetLootMethod` follows `GetLootMethod` off the client while `SetLootThreshold` survives, so `ns:SafeSetLootMethod` needs its `C_PartyInfo` branch for the dropdown to work at all.
- **`C_PartyInfo.GetLootMethod()` returns `(method, masterLooterPartyIndex, masterLooterRaidIndex)`** — the same shape as the legacy global. Verified in a master-loot party as `(2, 0, nil)`: the party index really does report `0` for "the player is the master looter", which is what the `== 0` test depends on. Under Group Loot it returns `(3, nil, nil)`, so a probe taken outside a master-loot group cannot tell you anything about this.
- **`Enum.LootMethod` does not exist on Era** — every field reads `nil`. The numeric comparisons (`methodEnum == 2` in `AreWeMasterLooter`, the `0`–`4` mapping in `SafeGetLootMethod`, and the reverse mapping `SafeSetLootMethod` sends) are therefore the **only live path on this flavor**, not defensive redundancy behind the `Enum` branch. Replacing those literals with `Enum.LootMethod.*` constants silently disables master-loot detection on Era.

The raid case is not yet verified: `masterLooterRaidIndex` was `nil` in the party test, and the `== 0` party check is what carries the decision. If master looting ever misbehaves in a 40-player raid, re-run the Loot Method probe there first.

### Item-Type Skips

`Features/Utilities.lua` exposes the skip rule as **two halves plus a composite**, and which one a caller takes is the whole reason the Custom Roll List works:

- `ns:IsNeverAutomatedItem` — legendaries (quality 5), recipes/books/patterns (`classId` 9), mounts and companion pets. Absolute. No list entry can opt back in.
- `ns:IsQuestClassItem` — `classId == ns.ITEM_CLASS_QUEST` (12) or `bindType == ns.BIND_QUEST_ITEM`. Skipped by every path that picks items **on its own**, and only those.
- `ns:ShouldSkipItemForMasterLoot` — the composite master-loot distribution takes: the never-automated half always, plus the quest-class half unless `autoMasterLootQuestItems` says otherwise. The opt-in reaches nothing else; the roll path's own quest-class skip is untouched by it.

The split is load-bearing rather than tidy. **The AQ and ZG war-effort tokens the default roll list exists to roll on all report `classId` 12**: the scarabs (20858–20865), AQ20 idols (20866–20873), AQ40 idols (20874–20882), ZG coins (19698–19706), ZG bijous (19707–19715), and the Wartorn scraps (22373–22376). While a single quest-class test ran ahead of the list, every one of those default entries was unreachable — correct ids, correct saved action, and no roll ever went out. So the roll path calls the two halves separately and sits the list between them; distribution, having no per-item instruction to weigh, keeps the composite.

Quest items are the one skip a player can turn off, and only for distribution. The case it exists for is boosting a character the same player controls, where handing the drop to the "wrong" character is the point; it ships off, because a quest item given to somebody not on the quest is wasted. A quest item still has to clear the loot threshold to reach master loot at all, which is why the panel pairs the toggle with a note about lowering it — on TBC Anniversary, where the threshold floor is Uncommon, most quest items stay out of reach entirely.

### Item Data Caching

`Features/Utilities.lua` exposes `ns.GetItemInfo` / `ns.GetItemInfoInstant` (C_Item on modern clients, legacy globals otherwise). `ns:SafeGetItemInfo` returns nil for uncached items; callers treat nil as "retry later", not an error:

- The distribution engine's retry ticker re-attempts slots whose item info was cold.
- `Features/Automated-Rolls.lua` returns `false` from `EvaluateRoll` while the item is unresolved — a nil `GetLootRollItemLink` included, which is how an uncached item reads until the client's query answers, and is the normal state of a war-effort token's first drop of the session — and polls the roll every 0.5 s (`ScheduleRollRetry`, which re-arms a single named timer keyed by roll id, so `ns:IsTimerPending` is the duplicate-ticker guard) until the info resolves or `CANCEL_LOOT_ROLL` cancels that timer. The attempt cap (150 ticks, 75 s — past the 60 s roll window) only backstops a cancel that never arrives; it was the give-up point once, at five seconds, and that was the bug. There is deliberately no "is this roll still live?" probe inside the tick: the one read that could answer it, `GetLootRollItemLink`, is nil for unresolved items too. The class/subclass skips need full item info, so a roll is never decided from `GetLootRollItemInfo`'s arguments alone.
- The options item lists render a `Loading... (ID: %d)` row, and `ns:WarmItemCache` (`Options/Options-Utilities.lua`) queries every listed item, registering a `GET_ITEM_INFO_RECEIVED` watcher that repaints via a debounced 0.3 s `NotifyChange` and unregisters itself once every item has resolved.
- Uncached items also have no name to sort on, so `ns:SortItemIdentifiersByName` drops them to the bottom of the list and they re-sort into place as answers arrive. It tie-breaks equal names on item ID — without that the nine identically-named Punctured Voodoo Dolls in the default roll list compare equal and reshuffle on every repaint.

### Resolving Game Message IDs

Two subsystems correlate a client message to an outcome: master-loot failures (`UI_ERROR_MESSAGE`) and trade results (`UI_INFO_MESSAGE`). Both match on the **numeric message id, never on a localized string**.

`ns:ResolveGameMessageIds(names)` (`Features/Utilities.lua`) is the one walk both use. `GetGameMessageInfo(index)` returns the *constant name* behind an id, so the walk maps this client's ids back to whichever of the requested constant names resolved. It returns the resolved table plus the number of messages scanned — the count is the only thing separating "this client resolved nothing" from "this client has no message table to resolve against", a distinction the Diagnostics report has to draw.

Maps are built lazily on first use and kept in runtime tables, never persisted: a client patch that renumbers ids can't be read back from stale saved data.

## Outbound Messages

All cross-player chat flows through `ns:Announce(channel, target, formatKey, ...)` in `Features/Announcements.lua`. Locale strings are clean bodies; the helper applies the same decoration to every sent channel:

```
PrintMessage (local only):                     GogoLoot // <body>          (branded colors)
Announce -> WHISPER/PARTY/RAID/INSTANCE_CHAT:  {rt4} GogoLoot // <body>
```

`{rt4}` (Triangle) is `ns.TARGET_MARKER` in `Data/Data.lua`, chosen to stay visually distinct from other Gogo1951 addons. `ns:GetGroupChatChannel()` resolves the right group channel (`INSTANCE_CHAT` / `RAID` / `PARTY`) and returns nil when solo — `Announce` no-ops on a nil channel, and the trade path falls back to whispering the partner.

`Announce` deliberately does **not** strip pipe characters the way the style guide's reference helpers do: GogoLoot bodies legitimately carry item links (`|Hitem...`), which are legal in outbound chat.

`SendChatMessage` rejects messages over 255 bytes (`ns.CHAT_MESSAGE_MAX_LENGTH`). Trade summaries can exceed that with 4+ item links, so `Features/Announcements-Trade.lua` builds the summary as a parts list and `AnnounceSummaryParts` greedily packs parts into as many messages as fit — measuring the final decorated message via `ns:BuildAnnounceMessage`, splitting only at part boundaries (a link broken mid-escape is rejected by the client), and repeating the same template so every message reads complete. A two-sided trade that overflows decomposes into the one-sided `MESSAGE_GAVE` and `MESSAGE_TRADE_RECEIVED` templates (`MESSAGE_GAVE` is shared with the master-loot hand-out announcement). A single part longer than the limit on its own is sent anyway — it cannot be shortened without destroying the link.

## The Trade Enchant Slot

Slot 7 (`ns.TRADE_ENCHANT_SLOT`) is the trade window's "will not be traded" slot, where an item goes to have a *service* performed on it rather than change hands — an enchant, or a rogue's Pick Lock on a lockbox. Whichever side's slot holds the item is the side receiving the service, which is why the snapshot reads both.

**The two trade-info functions return the service description in different positions**, which is the one genuinely non-obvious thing in this file:

```
GetTradePlayerItemInfo -> name, texture, numItems, quality, ENCHANTMENT (5), canLoseTransmog (6)
GetTradeTargetItemInfo -> name, texture, quantity, quality, isUsable (5),    ENCHANT (6)
```

Reading a fixed sixth return for both worked for their side and silently failed for ours: position 6 on our side is `canLoseTransmog`, a boolean, so the string check rejected it and every service performed on *our* item vanished from the summary — the lockbox trade reporting only the tip, and every enchant somebody put on our own gear. `SafeGetTradeEnchantName` therefore takes the position as an argument, and each caller passes the one matching the function it reads (`TRADE_ENCHANT_RETURN_PLAYER` = 5, `TRADE_ENCHANT_RETURN_TARGET` = 6). Never share one index between the two.

Wowpedia's two API pages document the asymmetry independently. Lockboxes need no special case of their own: Pick Lock rides the enchant field like any other service, so reading the right position is the whole fix.

## Pending Hand-out Registry

`GiveMasterLoot` returns immediately; the server confirms success only when the loot slot clears, and surfaces failure as a later `UI_ERROR_MESSAGE`. Announcing inline would post "Gave X to Y" for failed deliveries — twice after a retry. Instead **every call registers its own entry** under a unique id (`ns:RegisterPendingLootAnnouncement`) carrying the slot, item, recipient, and an ordering counter.

**Why per-hand-out and not one "most recent attempt" value.** `UI_ERROR_MESSAGE` names no item, so on a six-item boss kill a single pending value can only guess. The registry attributes an error to the **oldest hand-out still waiting** — the server answers in order, so anything newer has not been ruled on yet.

Four outcomes, all handled:

| Outcome | Signal | Result |
|---|---|---|
| Success | `LOOT_SLOT_CLEARED` for that slot | announce `MESSAGE_GAVE` |
| Known failure | a mapped `UI_ERROR_MESSAGE` | resolve oldest, report the reason |
| **Silent failure** | fallback timer fires and the slot **still holds the item** | report `ERROR_DISTRIBUTION_FAILED` |
| Aborted | `LOOT_CLOSED` | flush manual entries, drop the rest |

The silent-failure fallback (`HANDOUT_FALLBACK_DELAY`, 1.5 s) is what catches a hand-out the server never answered at all — before it existed those simply vanished. It decides from the loot window itself: a slot still holding the same item means the hand-out did not happen; anything else is ambiguous and stays quiet rather than guessing.

**Failures are batched, not one line per item per retry.** `ReportLootError` keys by player *and* reason, debounces `ERROR_BATCH_DELAY` (0.5 s), and emits one grouped message — "Bob's bags are full: itemA, itemB, itemC". Every item already reported for that player and reason is remembered for the rest of the loot session, so the distribution ticker's retry passes stay quiet about it. The `ERROR_*` locale strings therefore take **two** placeholders: player, then the item list.

**Manual entries carry `isManual` and survive the window closing.** The confirmation is a server round trip while `LOOT_CLOSED` is local and immediate, so anything that shuts the window inside that gap — handing out the last item, pressing Escape, being moved out of range mid-fight — dropped the entry and lost the announcement silently. `LOOT_CLOSED` and `LOOT_OPENED` call `FlushPendingManualAnnouncements` before the registry is cleared. Entries are removed as they emit, so a confirmation that lands first has already taken its entry out and nothing announces twice.

The automated path deliberately keeps confirm-only semantics for *success*. It fires without the player asking, so a "Gave X to Y" for a delivery that never happened is worse there than a missed line; a manual hand-out is a deliberate act the group is owed a record of, so it biases the other way. **Failure reporting is not gated either way**: the auto path always registers its hand-out (the registry is what detects failure at all) and records `silentSuccess` when the announce toggle or threshold says the success line isn't wanted — so a below-threshold item still reports its error while staying quiet on the happy path.

Known errors additionally post a generic `ERROR_*` explanation to the group, **matched on the numeric error id** resolved through `ns:ResolveGameMessageIds` (see Resolving Game Message IDs). `BuildErrorIdMap` resolves `ERROR_CONSTANT_TO_LOCALE_KEY`'s constant names to this client's ids and the correlation is then an integer lookup. That removes an entire class of problem the previous string matching could not solve:

- **No locale dependency.** Nothing compares against translated text, so there is no exact-versus-substring tradeoff and no drift when Blizzard rewords a message.
- **No dependence on a global being bound.** Several `ERR_*` globals are simply absent as strings on 1.15.9, which silently disabled every case that relied on them. Name-to-id resolution does not care.
- **The right constants.** Out of range is `ERR_LOOT_TOO_FAR` / `ERR_TOO_FAR_TO_INTERACT` — *not* `ERR_LOOT_PLAYER_NOT_PRESENT`, which was the wrong constant and is unbound on Era anyway.

Every constant in the table describes the **recipient**. `ERR_INV_FULL` and `ERR_LOOT_BAG_FULL` are deliberately absent: they are about the local player's own bags, so auto-looting into full bags mid-hand-out would have blamed the recipient. `ERR_LOOT_MASTER_OTHER` maps to a deliberately vague `ERROR_DISTRIBUTION_FAILED` ("Couldn't give %s: %s") rather than guessing a cause. An unmapped id is ignored: nothing announces, nothing is cleared. With the registry empty, a mapped id is ignored too — `UI_ERROR_MESSAGE` carries every red error the client raises, so with no hand-out in flight it is somebody else's error.

`ExtractErrorId` scans the event's arguments for the first number rather than reading argument one, so a build that reorders or omits arguments doesn't break the correlation.

The trade watcher resolves ids the same way (`Features/Announcements-Trade.lua` matches `UI_INFO_MESSAGE` against `ERR_TRADE_COMPLETE` / `ERR_TRADE_CANCELLED`, exported as `ns.TRADE_RESULT_CONSTANTS` alongside `ns.LOOT_ERROR_CONSTANTS`), and keeps a comparison against the `ERR_*` globals as a fallback for a client where neither constant resolved to an id. The Diagnostics Loot Method report prints both tables' resolved ids from a single shared walk, since an existence check cannot show whether a name resolved — and because the ids are per-flavor, a table that resolves on Era can come back empty on Anniversary with nothing else to show for it.

## Master Loot Destinations

`ns.db.profile.destinations` maps a quality key (`poor`…`epic`) to `"self"` or a normalized player name. It is deliberately **empty by default**: an absent tier means "nobody chosen yet", which auto-distributes nothing and shows an empty dropdown. Seeding every tier with `"self"` would make AceDB re-apply it at each login, so a cleared setup could never survive a reload, and a destination nobody picked would look like one they had.

Destinations are scoped to **one master-loot setup**, and `Features/Master-Looter.lua` ends that scope on three signals:

- **The group's loot type changed** — every tier resets. Carrying destinations across would leave a stale "everything goes to Bob" armed and invisible, ready to route the next session's loot at whoever was named for the last one. The comparison is against the last method GogoLoot *observed*, refreshed by both `PARTY_LOOT_METHOD_CHANGED` and `GROUP_ROSTER_UPDATE` — hanging the reset off the method event alone was not enough in practice, since it is the leader's action and need not reach every member, and where it does fire the loot API has not necessarily caught up by the time the handler runs. Tracking the method rather than resetting on every fire is what keeps a master-looter reassignment — which changes no method — from wiping a setup mid-run.
- **The player left the group** — every tier resets and the observed method is forgotten.
- **A named destination left the group** — that tier alone falls back to `"self"` and, if `announceDestinations` is on, says so.

`ns:GetSharedDestination` backs the Send All Loot To dropdown and returns nil when the tiers disagree, so the control shows blank rather than picking one tier's answer to stand for all five. It tracks *whether a tier has been seen* rather than whether the running answer is still nil — an explicit "no destination" is a value in its own right, and without that an unset tier followed by an assigned one would report the assigned player as the answer for all five.

### Collapsing the tier rows

The five per-tier rows are hidden behind the Set Quality Tiers Individually toggle (`showDestinationTiers`), because one destination is what most setups use and six dropdowns to express it is most of the panel. The toggle gates display only — it writes no destination, so collapsing the rows can never change where loot goes.

It is drawn as a sub-option of Send All Loot To (`ns.OptionsSubRow`), which is both true — it decides whether that one destination is expressed as itself or as five rows — and the only way it lines up with anything. Flush, its checkbox lands a couple of pixels right of the Label above it, because AceGUI's checkbox art is inset inside its own widget; that reads as a near-miss rather than a decision, and the indent cell makes it deliberate. The five tier rows it reveals sit one step deeper again, at `ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH`, so they read as belonging to the toggle rather than as its peers.

That leaves one state the panel could otherwise hide. Send All Loot To reads *blank* in two very different situations — nothing set up at all, and tiers that disagree — so it is honest about the first and silent about the second. While the rows are collapsed the toggle's label therefore carries `MASTER_LOOTER_TIERS_SUMMARY_MIXED` in `INFO` blue, and **only** for the divergent case: a shared destination is already named in the dropdown, and nothing set is already a blank dropdown, so saying either again is bloat. Expanded, the suffix goes away entirely — the rows say it themselves.

`SummarizeDestinations` counts the assigned tiers itself rather than reading `ns:GetSharedDestination`, which answers nil for both "they disagree" and "none of them is set" — two states that need different copy.

`ns:GetDestinationDisplayName` resolves the stored `"self"` literal to the player's own name before announcing. Announcing it verbatim would tell the group that "Self" is holding the loot, and resolving it is also what makes switching *back* to yourself announceable at all — the group has already been told somebody else is holding loot, and silence would leave that standing.

### Master Looter panel order

Top to bottom: **Automated Master Looting**, **Current Loot Settings**, **Loot Destinations**, **Ignore List** — what GogoLoot *does* before the group state it merely *reads*. The opening block carries no header of its own, because the tab is already titled Master Looter and that block is what the title describes; every other panel opens the same way.

`Enable Master Looter Pop-up` sits below the Automated Master Looting sub-options but is **not** one of them: the pop-up runs whether or not anything is automated, so it neither indents nor greys out with `autoMasterLoot`.

Current Loot Settings opens on `ns.AddLeaderNoteRow` — one line naming whoever controls the loot method and threshold, shown only while somebody else does. It replaced a red "only the group leader can change these" warning *plus* a `(Set by Spek)` suffix appended to both labels: the same fact three times, crowding the labels and reading as an error rather than as whose group it is. The line hides while solo or while the player leads, which is exactly when the dropdowns are live — its whole job is explaining why they are not. The pop-up carries it too, since it draws the same two dropdowns.

### The Master Looter Pop-up

`Options/Options-Master-Looter-Popup.lua` opens on every false-to-true transition of `ns:AreWeMasterLooter()`, gated by the `masterLooterPopup` setting. The flag starts at `false`, so logging in already master looter counts as becoming one, and repeat fires of the same state are a no-op.

Both events feeding that transition are load-bearing, because there is more than one way to be handed the role. `PARTY_LOOT_METHOD_CHANGED` covers the leader naming you master looter; `GROUP_ROSTER_UPDATE` covers the role *falling* to you because whoever held it left, which no loot-method event accompanies. Narrowing the trigger to the loot-method event drops that second case silently.

**Changing zones is not one of those ways, and used to read as one.** A loading screen re-syncs the party's loot state, so the loot API answers with the default for a moment before the real method lands: a zoning master looter reads as "not the master looter" and then as one again — a false-to-true transition indistinguishable from a promotion, arriving on the `GROUP_ROSTER_UPDATE`s that fire freely throughout. Two guards close it, both in `CheckMasterLooterPopup`:

- **A zone-change settle window** (`ZONE_SETTLE_SECONDS`, armed from `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA`). Readings taken inside it are ignored outright and deliberately **not recorded** either. Freezing rather than updating is what keeps a genuine promotion that lands mid-loading-screen: the first reading after the window still compares against the state from before it, so the window opens a beat late instead of never. `PLAYER_ENTERING_WORLD`'s own `(isInitialLogin, isReloadingUi)` arguments exempt login and `/reload` — those are the two loading screens the pop-up *is* meant to answer from a standing start.
- **An unreadable loot method is not a demotion.** When `ns:SafeCallLootMethod()` returns nil the client cannot answer yet; clearing the flag on that reading is what turns the next good one into a promotion that never happened. This one applies outside zoning too, wherever the API has no answer.

It is an AceConfigDialog standalone window, not a hand-built frame: registered with AceConfigRegistry like any other panel but never passed to `AddToBlizOptions`, so it inherits the add-on's widget styling and stays out of the Blizzard settings tree. Nothing in it is protected, so opening it during combat is safe.

Every row in it is built by a shared builder, so the panel and the pop-up can never drift: its own on/off toggle and the destination-message toggle (`ns.AddPopupToggleRow`, `ns.AddDestinationMessagesRow`), the leader note (`ns.AddLeaderNoteRow`), then loot method, loot threshold and Send All Loot To (`ns.AddLootMethodRow`, `ns.AddLootThresholdRow`, `ns.AddSendAllDestinationRow`). The two toggles are there because this is the window you would most want them from — it opened on its own, and the destination you are about to pick below is exactly what the second one decides whether to announce. `ns:RefreshMasterLooterPanels` notifies both registry names together for the same reason. Rows that don't apply to the current loot method hide rather than shrink the window: AceConfigDialog takes the frame size from its status table, never from how much content is on show.

## Custom Roll List vs. the Automated Rolls Toggle

The `autoGreed` toggle is the **master switch** for every automated roll: when Automated Rolls is off, nothing rolls automatically — the Custom Roll List included. The list also has its own `customRollList` toggle (default on), nested under the master: with rolls on and the list off, only the threshold path runs.

`EvaluateRoll` in `Features/Automated-Rolls.lua` applies its gates in a fixed order, and **the order is the design**:

1. `ns:IsNeverAutomatedItem` — legendaries, recipes, mounts, pets. Nothing gets past this, list entry or not.
2. `autoGreed` — the master switch, ahead of the per-item override check.
3. **Custom Roll List** — a per-item override is an explicit instruction from the player, so it bypasses the threshold, the BoP guard, *and* the quest-class skip below. `ns.MANUAL` means "leave it to me" and returns without rolling; anything else rolls its configured Need/Greed/Pass (Need falls back to Greed when the client doesn't offer Need).
4. `ns:IsQuestClassItem` — unlisted quest items are never picked up by the threshold path on its own.
5. BoP — the threshold path never touches a bind-on-pickup item. The list is the only way to automate one.
6. Threshold — per group context; rolls when `quality <= threshold`.

Step 3 sitting ahead of step 4 is the load-bearing bit: the tokens the default list ships for are quest-class (see Item-Type Skips), so checking the skip first makes the whole feature a no-op for them. Steps 1 and 3 are also why the two skip halves exist separately at all.

The threshold path is configured **per group context**: `GetContextRollSettings` reads the raid pair (`autoRollActionRaid` / `autoRollThresholdRaid`) when `IsInRaid()` is true and the party pair otherwise, and both paths share `ExecuteRollOverride`, so a threshold roll honors Need→Greed fallback exactly like a list entry. An action of `ns.MANUAL` disables automation for that context alone — Automated Rolls can run in raids but not parties without touching the master toggle.

Nothing in the module inspects the loot method. GogoLoot acts on every `START_LOOT_ROLL` the client raises, so a roll that opens during a master-loot session is automated identically to one from Group Loot or Need Before Greed. (Master loot suppresses most roll windows client-side — at-or-above-threshold items are assigned through the ML window and never roll — so what changes with master loot is how often the event fires, not whether GogoLoot answers it.)

Only rolls this module issues are recorded in `rollsInitiatedByAddon`, so the `CONFIRM_LOOT_ROLL` handler auto-confirms bind dialogs for GogoLoot's rolls only — player-initiated rolls keep Blizzard's confirmation.

## Speedy Loot Bag Budget

`Features/Speedy-Loot.lua` stands down for the **entire loot session** whenever `ns:AreWeMasterLooter()` is true — not merely when GogoLoot will auto-distribute. Master loot is a managed flow (at-or-above-threshold items are assigned through the ML window; sub-threshold items go out by the group method), and a `LootSlot` call here would either vacuum that loot into the master looter's own bags before it can be assigned, or pop `MasterLooterFrame_Show` on a threshold item — which errors on some clients. `AreWeMasterLooter()` is the superset of `WillAutoMasterLoot()`, so this still covers the auto-distribute case, including outside instances where auto-distribution is off by default.

Otherwise it respects the Auto Loot CVar (and its modifier-key inversion, so holding the auto-loot modifier still flips behavior), hides the loot frame, and loots bottom-up — mirroring default auto-loot and avoiding index shifts — spending a cached free-bag-slot budget per item slot. Only general-purpose bags count toward the budget (bagFamily 0, or the nil the backpack/legacy API returns); specialty bags — quivers, soul bags, profession bags — can't hold arbitrary loot, so counting their slots would overstate usable space. Money and currency are always looted (they take no bag space, detected via `GetLootSlotType`; when that API is unavailable every slot is treated as an item, which degrades to the conservative budget). With zero free slots and item slots present, it loots nothing and leaves the standard window visible rather than stranding loot.

## Diagnostics

`Features/Diagnostics.lua` is environment probing and state capture for bug reports, not a test runner. It is surfaced through the Diagnostic Tools options panel and is built to be safe by construction:

- **Runtime-only state.** `ns.diagnostics` is a plain namespace table (`{enabled, logging, log}`), never a SavedVariable. It starts off every session and persists nothing at logout. A single Enable toggle gates the whole panel; when off, every section below it is `hidden`.
- **Read-only, on demand.** Reports build only on a button press, never on load or panel open. Every probe is existence/shape checks or live reads with no side effects — the one exception is the Taint Log button, which sets the `taintLog` CVar (`ns:SetTaintLog`).
- **Not localized.** Diagnostics strings live in `ns.DiagnosticsStrings` as plain English, in this file only — they are developer-facing troubleshooting text, so translating them is wasted effort. The one exception is the add-on's own display name, read from `L["ADDON_TITLE"]`.
- **Event Registration probe** reads `ns.EVENT_NAMES` (Core's exported list), so it can never drift from the events the add-on actually uses. It registers then immediately unregisters each event on its own probe frame with no handler, and reports both `C_EventUtils.IsEventValid` and whether `RegisterEvent` succeeds.
- **API Endpoints probe** (`ns.DIAGNOSTIC_API_CHECKS`) lists every modern and legacy API GogoLoot guards against, separately, so a report shows exactly what a given client provides. Keep it aligned with the guards in the feature files.
- **Loot Method report** prints the raw returns of both loot-method APIs, the `Enum.LootMethod` table, GogoLoot's own interpretation (`SafeGetLootMethod`, `SafeGetLootThreshold`, `AreWeMasterLooter`, `WillAutoMasterLoot`), and closes with two `constant -> id on this client` blocks — master-loot errors, then trade results — resolved in a single `ns:ResolveGameMessageIds` walk over both exported tables. It is the only output that shows whether a constant resolved on this flavor: `NOT FOUND` there *is* the failure, and the shared scan count is what separates "resolved nothing" from "no message table to resolve against."
- **Saved Variables dump** prints every row of `GogoLootDB`, item lists included — the per-item roll overrides and ignore entries *are* the configuration a loot bug report needs, so the full dump is a sanctioned deviation from the guide's summarize-large-arrays advice.

The event log (`ns:LogEvent`) snapshots arguments to strings immediately (never retaining frame/table references), caps 8 args at 255 bytes each, and escapes pipes (`|` → `||`) **after** the length cut so a loot line shows its item link verbatim in the report editbox instead of rendering as a clickable swatch or collapsing to a stray `[Sc`. `ns.DIAGNOSTIC_EVENT_EXCLUDE` is deliberately empty — whole-event drops are the wrong tool for events that are ever signal, and the dispatcher only ever hands the log events GogoLoot itself registered. The two genuine firehoses, `UI_ERROR_MESSAGE` and `UI_INFO_MESSAGE`, are filtered by **message id** instead: the client raises them for every red combat error and yellow info line, which used to bury the 500-entry ring buffer in "Ability is not ready yet." and evict the loot signal. Ids the add-on correlates (the loot-error and trade-result sets, resolved through `ns:ResolveGameMessageIds` exactly like the live handlers) log as normal lines; everything else is counted per id and rendered as a `Suppressed` block at the bottom of the report — id, first-seen text, and count, biggest offender first — so the report still shows what was spamming without listing it. An event carrying no numeric id at all logs verbatim: unclassifiable is signal.

## Saved Variables

`GogoLootDB` is an AceDB-3.0 database (`ns.db`, created in `Features/Core.lua` on a name-guarded `ADDON_LOADED`). Profiles are stored account-wide in `GogoLootDB.profiles`, each character's active profile choice in `GogoLootDB.profileKeys`, and account-wide profile-independent state in `GogoLootDB.global`.

GogoLoot uses the **Simple** saved-variables model (Style Guide → SAVED VARIABLES → The Two Models): `AceDB:New`'s third argument is `true`, so every character lands on the one shared `"Default"` profile. **Reset Profile therefore clears all of the loot policy below back to install defaults**, while the three presentation keys on `ns.db.global` — the welcome toggle, Speedy Loot, and the mini-map position — survive untouched. Those three are a recorded per-add-on exception (`References/Exceptions.md` → *GogoLoot — account-wide presentation keys under the Simple model*); the Simple model otherwise leaves `global` unused. Profiles are managed on the Profiles options panel (AceDBOptions-3.0), letting a player keep separate loot rules per context (guild raid vs. PUG) and switch at will.

The split is by kind, not by convenience: **`global` holds how GogoLoot presents itself and what it does to the client, `profile` holds loot policy.** A player who wants different rules per context adds a profile, and nothing in that switch should move their button, re-enable Speedy Loot, or bring the welcome message back. A new setting belongs in `profile` unless it is presentation or client state.

Per-profile keys (`ns.db.profile`):

- `autoGreed`, `customRollList` — feature toggles. `autoGreed` is the Automated Rolls master switch; the name predates Pass/Need being configurable and is kept to avoid a migration for a key no user ever sees.
- `autoRollActionParty` / `autoRollThresholdParty`, `autoRollActionRaid` / `autoRollThresholdRaid` — the threshold path's quality ceiling (`0`…`4`) and roll action (`"manual"` / `"pass"` / `"greed"` / `"need"`), one pair per group context. Defaults are Greed at Uncommon & Lower for both.
- `autoMasterLoot`, `autoMasterLootOutsideInstances` — distribution engine gates, and **not a symmetrical pair**. `autoMasterLoot` is the master switch: `ns:WillAutoMasterLoot` returns false outright when it is off, so nothing distributes anywhere, inside an instance or out. `autoMasterLootOutsideInstances` only extends it past the instance check. The Options panel says so by nesting — the master switch reads `Enable Automated Master Looting` with no location in it, and both sub-options indent under it and grey out with it.
- `autoMasterLootQuestItems` — opts distribution out of the quest-class skip, for boosting a character the same player controls. Off by default, and read nowhere but `ns:ShouldSkipItemForMasterLoot`.
- `masterLooterPopup` — whether the master looter pop-up window opens on becoming master looter.
- `announceDestinations`, `announceMasterLootAuto`, `announceMasterLootAutoThreshold` — ML announcement toggles. The auto path is threshold-gated (default `3` = Rare+) so routine auto-loot doesn't spam chat; manual hand-outs have no setting and are always announced.
- `announceTrade`, `announceTradeCondition` (`always` / `party_or_raid` / `raid_only`), `announceTradeOutput` (`whisper` / `group`).
- `destinations` — quality key (`poor`…`epic`) → `"self"` or a normalized (realm-stripped, lowercased) player name. Empty by default; see Master Loot Destinations.
- `ignoredItemsSolo` — itemId → `"manual"` / `"greed"` / `"need"` / `"pass"` (the Custom Roll List).
- `ignoredItemsMaster` — itemId → `true` (the ML ignore list).
- `ahnQirajTokenRollDefaultsApplied` — a migration marker, deliberately absent from `ns.DATABASE_DEFAULTS` so `rawget` can tell a stored value from a default. Not a setting; see the Migration Chain.

Account-wide global keys (`ns.db.global`):

- `showWelcome` — the login welcome message toggle.
- `speedyLoot` — Speedy Loot, toggled from the General panel or the mini-map button's right-click.
- `showDestinationTiers` — whether the Master Looter panel draws a row per quality tier or just Send All Loot To. Presentation rather than loot policy: it changes what the panel draws and no destination, so it stays out of the profile.
- `minimap` — LibDBIcon position + `hide` flag, so switching, resetting, or deleting a profile never moves the button.

Defaults come from `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`) and are applied by AceDB-3.0 when a scope is first accessed — explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables. That copying is exactly why the migrations below `rawget` past the metatable to tell a genuinely stored value from a default. There is no manual defaults merge anywhere in the add-on.

Empty item lists are deliberately re-seeded from the expansion-filtered defaults (`RebuildEmptyItemLists` in `Features/Core.lua`) on load and on every profile change, copy, or reset — an empty list is treated as "never configured". The default entries (`ns.DEFAULT_IGNORE_LIST_SOLO`, `ns.DEFAULT_IGNORE_LIST_MASTER`) each carry an expansion tag (`VANILLA`=1, `TBC`=2, `WRATH`=3) and are filtered against `ns.currentExpansion`, so TBC items ship harmlessly to Era clients. This is the only place the add-on re-seeds saved values, and it only fills empty item lists — it never overrides explicit user values.

`HandleProfileChanged` is wired to `OnProfileChanged`, `OnProfileCopied`, and `OnProfileReset`. The new profile's tables replace the old ones wholesale, so everything that caches or displays profile state is repainted there: the migrations below run for the newly-visited profile, the item lists re-seed if empty, the minimap icon re-reads `autoGreed`, the trade checkbox re-reads `announceTrade`, and every panel in `ns.OPTIONS_REGISTRY` gets a `NotifyChange`.

Auto Loot is deliberately *not* a saved setting of its own. `ns.EnsureAutoLoot` (`Features/Core.lua`) enforces the `autoLootDefault` CVar while Speedy Loot is enabled, because Speedy Loot is the one feature that cannot function without it; the Speedy Loot toggle is therefore the opt-out the Style Guide requires for an enforced CVar write. It writes only when the CVar is actually off, always announces itself through `PrintMessage`, and runs at login when Speedy Loot is on and whenever it is switched on. The rolls, master-loot, and trade-announcement paths never touch the CVar.

### Migration Chain

All six run once, in this order, inside `OnAddonLoaded` after `AceDB:New`. Every one is tagged `remove after 2026-08-15` — the Style Guide's single fixed migration cutoff, shared by every migration regardless of when it shipped. Past that date they are deleted on sight; a returning player whose data was never migrated falls back to defaults.

- `MigrateFlatSettingsToProfile` — folds pre-profile flat `GogoLootDB.<key>` values into the active profile, then nils the old flat keys. Its loop walks `ns.DATABASE_DEFAULTS.profile`, so keys that have since left those defaults (`autoGreedThreshold`, `showWelcome`, `speedyLoot`) are carried up by an explicit list after the loop and left for the migrations below to fold into their new homes.
- `MigrateTradeOutputRaidToGroup` — rewrites the retired `"raid"` output value to `"group"` (the two dropdown options are now Whisper and Group Chat).
- `MigrateMinimapToGlobal` — moves the minimap position from `profile.minimap` into `global.minimap`. It `rawget`s past AceDB's defaults metatable so only genuine stored per-profile data migrates, and fills only global keys not already present, so an established global position is never clobbered.
- `MigrateSettingsToGlobal(adoptProfileValue)` — moves the presentation toggles in `ACCOUNT_WIDE_MIGRATED_KEYS` (`showWelcome`, `speedyLoot`) from the profile into `global`. It takes the flag rather than the "fill only when global is unset" test the minimap migration uses: AceDB's `copyDefaults` **rawsets scalar defaults into the saved table**, so those global keys always read as present and that test can never fire for a scalar. Instead the profile active at login passes `true` and donates its values; profiles visited later through `HandleProfileChanged` pass `false` and only drop their stale keys, so an old profile can't overwrite the values already in force.
- `MigrateGreedThresholdToPerContext` — seeds both `autoRollThresholdParty` and `autoRollThresholdRaid` from the retired single `autoGreedThreshold`, then nils it, so an upgrading profile keeps rolling exactly as before. The actions stay at their Greed default, which is all the old code ever did. Also `rawget`s past the defaults metatable.
- `MigrateAhnQirajTokenRollDefaults` — brings an established profile's Custom Roll List up to the shipped defaults: the Ahn'Qiraj war-effort tokens joined that list, and the AQ40 idols moved from Manual to Need. An existing profile sees neither change on its own, because `RebuildEmptyItemLists` re-seeds only a list that is *entirely* empty. Two rules, because the halves mean different things. `ADDED_ITEM_IDENTIFIERS` (the AQ20 idols, Scarab Bag, both coffer keys, and the four Wartorn scraps) are ids the list never carried, so an entry already sitting there can only be one the player typed in and is left alone. `REPOINTED_ITEM_IDENTIFIERS` (the eight AQ40 idols — 20880 is deliberately absent, it is not a live item id) were already listed at Manual, and move **only while they still read Manual**, so a player who had picked Greed, Need, or Pass for an idol keeps that choice. Both read their target action from `ns.DEFAULT_IGNORE_LIST_SOLO` rather than repeating it, so the data file stays the single source of truth and the expansion filter is honoured exactly as the seeding path applies it. It runs once per profile, guarded by the marker key `ahnQirajTokenRollDefaultsApplied` — a profile key deliberately absent from the defaults table, so `rawget` reads only a genuinely stored value, the same idiom the migrations above use — and always runs *after* `RebuildEmptyItemLists`, so a freshly seeded list is never mistaken for a stale one. Deleting this migration leaves the marker key inert in saved variables.

Every one except `MigrateFlatSettingsToProfile` also runs per profile from `HandleProfileChanged`, in that same relative order — `MigrateSettingsToGlobal` passed `false` there, and `MigrateAhnQirajTokenRollDefaults` still last, after the `RebuildEmptyItemLists` re-seed — so a profile the player has not logged into since the change is migrated the moment they switch to it. `MigrateFlatSettingsToProfile` is login-only by nature: the flat pre-profile keys it reads sit on the `GogoLootDB` root rather than inside any profile, and it nils them once it has folded them in.

## Adding a New Announcement

1. Add a `MESSAGE_*` key to `Locales/enUS.lua` — a clean body with `%s` placeholders, no marker or addon name.
2. Call `ns:Announce(channel, whisperTarget, "MESSAGE_YOUR_KEY", ...)`. Use `ns:GetGroupChatChannel()` for group output and handle its nil return when solo.
3. If the body can carry multiple item links, build it as a parts list and send through the `AnnounceSummaryParts` pattern in `Features/Announcements-Trade.lua` — a single message caps at 255 **bytes** (Style Guide → MESSAGES → Message Length).
4. Check the rendered length in the widest-encoding locale. The ceiling is measured in bytes, so the overflow canary is ruRU (Cyrillic encodes two bytes per character), not German.

## Adding a New Options Panel

1. Create `Options/Options-<Name>.lua` exposing `ns.Build<Name>Options()` that returns an AceConfig group table, using the `ns.OptionsHeader` / `OptionsDesc` / `OptionsSpacer` / `OptionsRowLabel` helpers and a `TAB_*` locale key for its `name`.
2. Add a registry name to `ns.OPTIONS_REGISTRY` in `Data/Data.lua`, derived from `ADDON_NAME` — never localized; cross-module `NotifyChange` callers reference it by exact string.
3. Register it in `ns.RegisterOptionsPanels` (`Options/Options.lua`): `RegisterOptionsTable` plus `AddToBlizOptions(registryName, L["TAB_*"], L["ADDON_TITLE"])` — the third argument must match the parent panel's display name exactly, and the order of `AddToBlizOptions` calls is the order panels appear in Blizzard's settings tree.
4. Add the file to `GogoLoot.toc` after `Options/Options-Utilities.lua` and before `Options/Options.lua`.
5. Lay controls out as label-beside-control rows: an `ns.OptionsRowLabel` at `ns.OPTIONS_LABEL_WIDTH` followed by a control with `name = ""` at `ns.OPTIONS_CONTROL_WIDTH`, so every row on every panel shares one right edge (`ns.OPTIONS_ROW_WIDTH`).
6. For a control that only means anything while the toggle above it is on, use `ns.OptionsSubRow` and `ns.OptionsSubLabel`, and `disabled` it on the parent's state.

### Sub-options

`ns.OptionsSubRow(order, hidden, controls, indentWidth)` wraps a row in a nameless inline group and leads it with a blank description cell of `ns.OPTIONS_SUB_INDENT_WIDTH`. **The indent must be a cell, not padding on the caption** — AceConfig pins a checkbox at the left edge of its own widget, so a padded label moves the words and leaves the box lined up with its parent's.

Two depths, and which one a row takes says what it is:

- `ns.OPTIONS_SUB_INDENT_WIDTH` — the row **is** a sub-option. Its box starts where its parent's box visually ends.
- `ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH` — the row **belongs to** a sub-option: its notes, and the rows a sub-option reveals. One indent plus a checkbox, so it aligns under the caption above rather than under its box.

Expressing both in width units rather than leading spaces is what keeps them aligned without anyone guessing at the width of a space in a proportional font.

A row at either depth still owes the panel its shared right edge, so an indented label-beside-control row **narrows its label to pay for its indent** rather than pushing everything right. That is `ns.OPTIONS_SUB_LABEL_WIDTH` (`ns.OPTIONS_LABEL_WIDTH` minus the indent), and it is why the quality-tier dropdowns stay in the same column as Send All Loot To above them, and the Announcements panel's threshold, When and Message Output dropdowns stay in the same column as each other.

The Announcements panel is the clearest case of the pattern: only its three Enable toggles are top level. Every other control belongs to one of them — a threshold that applies only while its toggle is on, an example of what that toggle posts — so each is a sub-option indented under it.

**A dropdown goes with its toggle; an example stays.** A dropdown configures something that is not happening, so it hides rather than greying out, along with the spacer that paired with it or the gaps double up. The examples and the manual-distribution note are what somebody reads to *decide* whether to turn a thing on, so they are shown whatever the toggle says — a feature that shows you nothing until you enable it cannot be judged before you do.

Those dropdowns also take `ANNOUNCEMENT_DROPDOWN_WIDTH` rather than `ns.OPTIONS_CONTROL_WIDTH`: they hold short fixed labels (a quality tier, "Always", "Whisper") rather than the player names the Master Looter dropdowns carry. Their left edges still line up, because a row pays for its indent out of its label and never out of its control.

### Hiding a panel behind its master switch

Both the Master Looter and Automated Rolls panels hide everything below their master switch while it is off. In each case the switch really is a master switch — `ns:WillAutoMasterLoot` returns false outright without `autoMasterLoot`, and `autoGreed` gates every roll including the Custom Roll List — so what is below it changes nothing, and a page of greyed controls says that at far greater length than an absence. It also means a hidden control has no use for a `disabled` state, and carrying one would be dead logic.

The Master Looter panel applies this as a single sweep over `args` at the end of its builder, skipping `PANEL_ALWAYS_SHOWN`. Two reasons it is a sweep rather than a flag per row: the panel is built partly from shared row builders the pop-up also calls, so the gate cannot live inside them; and anything added later is covered without having to remember. The sweep **composes** with whatever a row already answered to rather than replacing it — a threshold row that hides under Free for All, a tier row below the loot threshold, a leader note that only appears for a non-leader — so the master switch is an additional reason to hide, never a substitute for theirs.

The group wrapper is load-bearing. Laid out flat, an indent cell and its control are just two more widgets in the panel's flow, held together only by their widths happening to fill the line; the next pair then packs into whatever is left and its indent stops indenting anything. A fill-width group always takes a line of its own, so one group pins one row. For the same reason the controls inside need slack rather than an exact fit — a row summing to the full pane width sits on the wrap boundary, where a measuring pass can tip the control onto its own line and strand the indent above it. Put `hidden` on the group, never on the control inside it, or the indent cell stays behind as a blank line.

`ns.OptionsSubLabel` colors the caption `HELP` silver against the parent's white, so the row reads as subordinate rather than merely shifted, and stays clear of the dimmer gray AceGUI paints a genuinely disabled label. MagicEraser sizes its Auto-Vend sub-options the same way; the two add-ons should stay in step.

## Adding a New Registered Event

1. Register the handler with `ns:RegisterModuleEvent(eventName, handler)` from the owning module — never `frame:RegisterEvent` directly.
2. Add the event name to `ns.EVENT_NAMES` in `Features/Core.lua`, keeping the list alphabetical. Skipping this prints a one-time developer warning and leaves the event out of the Diagnostics Event Registration probe.
3. If the handler must ever unregister, do it from a timer or user path — `ns:UnregisterModuleEvent` is unsafe to call while `OnEvent` is iterating handlers. Prefer a named timer (`ns:After` / `ns:CancelTimer`) over a guard flag: rescheduling an identifier replaces the pending timer, so the call site needs no self-cancel token of its own.

## Adding a New Default List Item

1. Add the entry in `Data/Default-Settings.lua`: `[itemId] = {expansion, rollOverride}` for `ns.DEFAULT_IGNORE_LIST_SOLO` (expansion `1`–`3`; override `ROLL_INDEX_MANUAL`/`ROLL_INDEX_GREED`/`ROLL_INDEX_NEED`/`ROLL_INDEX_PASS`), or `[itemId] = {expansion}` for `ns.DEFAULT_IGNORE_LIST_MASTER`.
2. Entries gate on `ns.currentExpansion`, so TBC items ship safely to Era clients.
3. Existing users do **not** receive new defaults automatically — saved lists are rebuilt only when empty (`RebuildEmptyItemLists`) or via the Restore Defaults button. Mention new defaults in release notes.
4. If an established profile genuinely has to pick the entry up, that needs a one-off migration, not a change to the seeding rule. `MigrateAhnQirajTokenRollDefaults` is the pattern: a marker key absent from the defaults table, separate added-versus-repointed lists so a choice the player already made is never overwritten, target actions read back out of `ns.DEFAULT_IGNORE_LIST_SOLO`, and it runs after `RebuildEmptyItemLists`. It carries the same migration cutoff as every other one.

## Localization

Every user-facing string goes through `L["KEY"]`. `ns.L` is bound once at the top of `Data/Data.lua` (`LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)`) and every other file reads it from the namespace.

- **Structure.** Locale files live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale("GogoLoot", "<locale>")`. All eleven WoW locales ship. `enUS.lua` is the source of truth and the only file that passes the `true` default-fallback flag; every string originates there and the other locales translate from it. WoW ships a fixed locale set and every supported locale file already exists, so this is maintenance — there is no "add a new locale" step.
- **Keeping locales in sync.** Every non-English file carries a translation of the same key set, and AceLocale falls back to English via `__index` for anything missing at runtime, so a partial translation degrades gracefully rather than erroring. Translating each `enUS.lua` key into every locale and keeping the files aligned is the job of the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`); don't hand-edit the other locales during ordinary work. When a key is renamed, rename it in `enUS.lua` and at every call site together — the old key in the other files becomes a harmless orphan until the next translation pass. `Tests/Run.lua` asserts key parity across all eleven files, so a missed file fails the suite.
- **Placeholders.** `%s`/`%d` count, type, and order must match `enUS` per key in every locale, or the string crashes at runtime. The `ERROR_*` keys take two (`player`, then the item list); `MESSAGE_TRADE_GAVE_RECEIVED` takes three.
- **Spanish.** esES and esMX are two separate, self-contained files; identical strings in both is correct and expected (see Style Guide → LOCALIZATION).
- **Locale overflow.** Sent messages cap at 255 **bytes** (`ns.CHAT_MESSAGE_MAX_LENGTH`), so the canary is the widest-encoding locale — ruRU, not German (Style Guide → MESSAGES → Message Length). Options labels have no byte ceiling but do have a column width: check a long-word locale (deDE) against `ns.OPTIONS_LABEL_WIDTH` when adding a row.
- **Diagnostics strings are not localized.** They live in `ns.DiagnosticsStrings` (`Features/Diagnostics.lua`) as plain English. Keep them out of `Locales/` entirely. The one exception is the add-on's display name, read from `L["ADDON_TITLE"]`.

## Common Pitfalls

- **Stripping pipes in `Announce`**: destroys item links. The missing `gsub("|", "")` is a deliberate deviation from the style guide — don't "fix" it.
- **Sending chat messages over 255 bytes**: the client rejects them silently. Measure with `ns:BuildAnnounceMessage` against `ns.CHAT_MESSAGE_MAX_LENGTH` and split at part boundaries via `AnnounceSummaryParts` — never mid-link.
- **Announcing inline with `GiveMasterLoot`**: posts "Gave X to Y" for deliveries that then fail. Always register through the Pending Hand-out Registry and let `LOOT_SLOT_CLEARED` emit.
- **Wiping the hand-out registry without flushing**: `LOOT_CLOSED` and `LOOT_OPENED` both clear it, and the confirmation they race is a server round trip. Any new code path that clears it must call `FlushPendingManualAnnouncements` first, or manual hand-outs go silent exactly when the window closes fastest.
- **Using raw `C_Timer.After` for anything cancellable**: use `ns:After(identifier, seconds, callback)`. Scheduling the same identifier replaces the pending one and `ns:CancelTimer` kills it, so no call site needs a hand-rolled guard flag doubling as a self-cancel token.
- **Adding an API guard outside Utilities' shim block**: every modern-versus-legacy decision belongs in one place. The single exception is Core's `GetAddOnMetadata`, which runs at file scope before Utilities loads.
- **Letting the Custom Roll List bypass `autoGreed`**: the toggle is the master switch for every automated roll. The override check must stay behind the `autoGreed` gate — the options copy promises that off means off.
- **Moving the quest-class skip ahead of the Custom Roll List**: the AQ and ZG war-effort tokens the default list ships for are all `classId` 12, so a skip that runs first makes the entire feature a no-op for them — correct ids, correct saved action, no roll, no error. Call the two halves separately (`ns:IsNeverAutomatedItem`, then the list, then `ns:IsQuestClassItem`) and keep `ns:ShouldSkipItemForMasterLoot` for distribution, whose only override is the panel toggle.
- **Treating a nil `GetLootRollItemLink` as a dead roll**: it also reads nil while the client's item query is still in flight, which is the normal state of a token's first drop of the session. Return `false` from `EvaluateRoll` and let the retry timer poll; `CANCEL_LOOT_ROLL` is what tears a genuinely dead roll down.
- **Sizing the roll retry cap as a give-up point**: it isn't one. The cap exists only to bound a cancel that never arrives, so it sits past the 60 s roll window. The old ten-attempt, five-second version dropped rolls whose item query simply took longer than that.
- **Gating automated rolls on the loot method**: the roll module answers `START_LOOT_ROLL` and nothing else. Adding a `GetLootMethod` check would silently stop the rolls that *do* open during a master-loot session.
- **Resetting destinations on every `PARTY_LOOT_METHOD_CHANGED`**: that wipes a live setup when the master looter is merely reassigned. Compare against the last *observed* method instead, and refresh that observation from `GROUP_ROSTER_UPDATE` too — the method event is the leader's action and need not reach every member.
- **Seeding `destinations` with `"self"` for every tier**: AceDB would re-apply it at each login, so a cleared setup could never survive a reload. An absent tier is the correct "nobody chosen yet".
- **Giving the item-row remove column a text caption**: AceConfig renders an `execute` carrying an `image` as an AceGUI Icon and one without as a Button, and Button insets its font string 15px from each edge — a caption in a column this narrow clips to a sliver. Keep `name = ""` and let the label ride in `desc` as the hover tooltip.
- **Adding a roll-action dropdown without `sorting`**: AceConfigDialog orders `values` alphabetically, so the four actions reshuffle per locale. Pass `ns.ROLL_OVERRIDE_ORDER` (Manual, Pass, Greed, Need) every time.
- **Registering an event without adding it to `ns.EVENT_NAMES`**: `RegisterModuleEvent` warns, and the Diagnostics Event Registration probe silently misses it. Add the name (alphabetically) in Core.lua.
- **Calling `UnregisterModuleEvent` from inside an event handler**: the dispatcher iterates the live handler list. Defer to a timer or user-driven path.
- **Speedy-looting while master looter**: bypass stands down for the whole ML session via `ns:AreWeMasterLooter()`, not just `WillAutoMasterLoot()` — a `LootSlot` on a threshold item pops `MasterLooterFrame_Show` and errors on some clients.
- **Comparing player names raw**: cross-realm members appear as `Name-Realm` in some APIs and `Name` in others. Every comparison goes through `ns:NormalizePlayerName`.
- **Picking compatibility APIs by truthy result**: `(C_CVar.GetCVarBool(...)) or GetCVar(...)` falls through to the legacy read whenever the value is false. Check API availability, then call exactly one (`ns:IsAutoLootCVarEnabled` is the pattern).
- **Confusing `ERR_*` Blizzard globals with `ERROR_*` locale keys**: the error mapper keys off unquoted globals (`ERR_LOOT_MASTER_INV_FULL`) and returns quoted GogoLoot keys (`"ERROR_BAG_FULL"`). They are different namespaces.
- **Mutating the table returned by `AceDBOptions-3.0:GetOptionsTable`**: its `args` sub-table is one shared table serving every Ace3 database on the client, so anything written into it appears inside every other add-on's Profiles panel. `Options-Profiles.lua` returns the stock table unmodified; any future extension must live in a wrapper table of its own, never be written into the stock one.
- **Assuming `GetTradePlayerItemInfo` and `GetTradeTargetItemInfo` return the same shape**: they swap the enchant description and the following field. See The Trade Enchant Slot above.
- **Matching loot errors on their message text**: don't. `UI_ERROR_MESSAGE` carries a numeric error id; match that, resolved from the constant name via `GetGameMessageInfo`. Any string comparison reintroduces the locale dependency, and a substring one announces combat noise to the raid as a loot failure.
- **Reordering the TOC includes**: `AceConfigCmd-3.0` must load before `AceConfig-3.0.lua`, which hard-requires it at load.
- **Removing the doubled `InterfaceOptionsFrame_OpenToCategory` call**: the duplicate is required for Classic clients to land on the right panel.

## Tests

```
lua Tests/Run.lua
```

Run from the add-on folder, with the system Lua — no WoW client, no libraries. **`Tests/` is deliberately absent from the TOC**: per the Style Guide, real logic tests live in the dev toolchain, never in the shipped Diagnostics panel, so these files never load in game. For what a human has to verify in the client, see [README-Testing.md](https://github.com/Gogo1951/GogoLoot/blob/main/README-Testing.md).

`Tests/Fakes/WoW.lua` stubs the WoW and Ace surface: `GiveMasterLoot` (recording every call and firing the `hooksecurefunc` hook), loot slots, master-loot candidates, `GetGameMessageInfo`, chat output, and an AceDB fake that copies defaults the way the real library does — migrations that `rawget` past the metatable must see what AceDB would actually have written.

Two deliberate choices in the fake:

- **Namespaced APIs are concrete, not catch-all stubs.** A permissive stub returns a table where the client returns a string or nil, which manufactures type errors the real client never raises. A false failure costs more than the unstubbed global it saves.
- **Timers are collected, not run.** `Fake.advance(env, seconds)` moves a virtual clock and fires what is due, so the suite asserts on timer-driven behaviour (the silent-failure fallback, the batch flush) without sleeping and without flaking. Note that a callback which schedules another timer needs a second `advance` — the fallback arms the batch flush, so a silent-failure test advances twice.

`Tests/Run.lua` loads all 22 files in TOC order, fires `ADDON_LOADED`, and runs 41 tests covering:

- **Load and saved variables** — init, scoping of `profile` versus `global`, Auto Loot enforcement.
- **Master-loot hand-outs** — the happy path, error attribution to the *oldest* hand-out, failure batching, unmapped errors being ignored, cold item info not stranding later slots, silent-failure detection, silent success staying quiet, manual flush on close.
- **Destinations** — announcing a switch back to self, clearing on a loot-method change from either event, clearing on leaving the group.
- **Options panels** — the Master Looter panel's row visibility, leader gating, and the pop-up's Send All row hiding off master loot.
- **Rolls** — a quest-class item on the list rolling its saved action, an unlisted quest item staying untouched, a listed legendary and a listed mount still refusing to roll, Manual leaving the roll alone, Need→Greed fallback, the master switch silencing the list, and distribution still taking the whole skip set.
- **The cold-item roll race** — a listed token uncached at `START_LOOT_ROLL` rolling once its info resolves, the retry outliving a query slower than the old five-second cap, and `CANCEL_LOOT_ROLL` killing the poll for good.
- **War-effort defaults and their migration** — every token shipping at its intended action, and an established profile picking up the new ids while keeping choices the player had already made.
- **Plumbing** — trade complete/cancelled resolved from the message id alone, the Loot Method report's resolved-id blocks, the event log's id filtering, named-timer replacement and cancellation, locale key parity.

A `nil`-call regression in `OnAddonLoaded` — the kind that takes the whole add-on down — fails at the first test.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/Gogo1951/GogoLoot/issues).
- **Bug reports**: include game version + locale, group context (solo / party / raid, loot method), repro steps, and the relevant chat output or error text. The Diagnostic Tools panel builds a client-tagged report you can paste in.
- **Discord**: [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q).
- **PR guidelines**: keep PRs scoped to one change; match the conventions in this codebase (namespace `ns`, locale keys for every user-facing string, no abbreviations in names); verify the 255-byte limit for any change to outbound messages (Style Guide → MESSAGES → Message Length) and check labels in the longer locales; keep migrations tagged with the fixed `2026-08-15` cutoff; keep `ns.EVENT_NAMES` and the diagnostics probes in sync with any new events or API guards; run `lua Tests/Run.lua`; update this document if the architecture or file map changes.
- **Commit and PR descriptions require a User Story.** Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why:

   **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

   **Example:** *As a master looter handing out a six-item boss kill, I wanted the trade announcement to arrive instead of silently failing so the raid could see what was distributed. This change splits oversized summaries across multiple messages at item-link boundaries.*
