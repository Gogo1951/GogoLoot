# GogoLoot // Technical Reference

This document combines architecture notes and contribution guidance for developers working on GogoLoot. For end-user documentation, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md).

## File Map

```
GogoLoot/
├── .github/workflows/package.yml                CurseForge + Wago release, library vendoring (repo only)
├── .gitattributes                               LF normalization (repo only)
├── .gitignore                                   Dev-clutter ignore list (repo only)
├── .luacheckrc                                  Lint settings and the WoW globals the add-on reads (repo only)
├── .pkgmeta                                     Externals and ignore list; externals check out into Includes/Libraries/ (repo only)
├── GogoLoot_Vanilla.toc                         Classic Era, Season of Discovery included
├── GogoLoot_TBC.toc                             TBC Anniversary
├── GogoLoot_Camelot.toc                         WoW Forever
├── GogoLoot_Mists.toc                           MoP Classic
├── GogoLoot_Mainline.toc                        Retail
├── Data/
│   ├── Flavor.lua                               Canonical copy, never edited: ns.FLAVOR, ns.EXPANSION, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── Data.lua                                 Constants only: enums, colors, target marker, options widths, registry names, toast rows, Character Rules stats
│   ├── {Folder}/                                One per flavor (Vanilla, Discovery, TBC, Camelot, Wrath, Mists, Mainline); Wrath ships in no TOC yet
│   │   ├── Default-Item-Lists-{Folder}.lua      The default Item Overrides and Master Looter Ignore List
│   │   ├── Game-IDs-{Folder}.lua                The Lockpicking skill line, the Diagnostics probe item, the sound kit IDs
│   │   ├── Item-Stats-{Folder}.lua              Equip-spell and random-suffix stats for Character Rules; empty from WoW Forever on
│   │   ├── Lockbox-Skill-Levels-{Folder}.lua    The Lockpicking skill each lockbox needs
│   │   ├── Openable-Items-{Folder}.lua          Every container the client flags Openable, with its default action
│   │   └── Spells-{Folder}.lua                  Pick Lock, Pick Pocket and Shadowmeld spell IDs
│   └── Default-Settings.lua                     The AceDB defaults table, ns.DATABASE_DEFAULTS
├── Diagnostics/                                 Diagnostic Tools, Magic Eraser's framework; runtime-only state
│   ├── Diagnostics-Core.lua                     Runtime state, the enable gate, every diagnostics string, the report header
│   ├── Manifests.lua                            GogoLoot's own surface: API checks, the context probes, the data-file manifest
│   ├── Event-Log.lua                            The event buffer, the message-id filter, the Taint Log CVar
│   ├── Code-Reports.lua                         Event Registration, API Endpoints, Library Versions
│   ├── Settings-Reports.lua                     Display Context, Other Add-ons, Saved Variables
│   ├── Validate-Data.lua                        The batched per-file validator and its TSV export
│   ├── Report-Runner.lua                        The report and tab manifests, and the one-at-a-time runner
│   └── Options-Diagnostics.lua                  The Diagnostic Tools panel: warning, enable toggle, four tabs
├── Features/
│   ├── Core.lua                                 Version, saved-variable lifecycle and migrations, the event dispatcher, ns.EVENT_NAMES
│   ├── Utilities.lua                            API accessors, the scan tooltip, message ids, named timers, colors, name and loot-line parsing
│   ├── Announcements.lua                        PrintMessage, Announce, BuildAnnounceMessage, AnnounceParts, the status channel, welcome
│   ├── Announcements-Trade.lua                  Trade snapshot, summary building and chunking, trade result, the trade-window checkbox
│   ├── Auto-Loot.lua                            The Auto Loot CVar enforcement Speedy Loot and Automated Opening depend on
│   ├── Openable-Items.lua                       What Automated Opening does with each item: data defaults plus the player's changes
│   ├── Loot-Sounds.lua                          The corpse-and-chest loot window, the rare-loot chime, the Pick Pocket sound
│   ├── Speedy-Loot.lua                          The one LOOT_READY handler: loot sounds first, then fast looting with the window held down
│   ├── Automated-Opening.lua                    Scan, queue, open; the safety gates, pause and resume, refused opens, Locked Items
│   ├── Lockbox-Tooltips.lua                     The Lockpicking block on a lockbox's bag tooltip
│   ├── Loot-Toasts-Winning-Rolls.lua            The roll each item was won with, read off the roll lines
│   ├── Loot-Toasts.lua                          The on-screen loot readout: anchor and handle, filters, rows, pool, samples, coin
│   ├── Standard-Loot-Messages.lua               The General tab's Item Loot and Money Loot lines, taken off while toasts stand in
│   ├── Master-Looter.lua                        Loot-method wrappers, WillAutoMasterLoot, destination lifecycle, the pop-up trigger
│   ├── Master-Looter-Distribution.lua           The distribution engine, the manual-hand-out hook, the Pending Hand-out Registry
│   ├── Character-Rules.lua                      The stats an item carries and whether this character's rules leave it to the player
│   ├── Roll-Messages.lua                        Hide Roll Messages' chat filter and the winner summary
│   ├── Automated-Rolls.lua                      START_LOOT_ROLL: threshold and Item Overrides rolls, the cold-item retry, the roll print
│   └── Minimap-Button.lua                       LibDataBroker launcher, mini-map icon state, clicks, tooltip
├── Includes/
│   ├── Images/GogoLoot.tga                      Add-on-list icon (## IconTexture)
│   ├── Sounds/item-pick-up.ogg                  The rare-loot chime
│   └── Libraries/                               Vendored libraries, never edited by hand; LibSharedMedia-3.0 for the toast fonts
├── Locales/                                     AceLocale files, 11 locales; enUS.lua is the source of truth
├── Options/
│   ├── Options-Utilities.lua                    Widget helpers, toggle rows and caption measuring, the feature-off note, message examples
│   ├── Options-Utilities-Item-Cache.lua         Which IDs this client has, the GET_ITEM_INFO_RECEIVED watcher, cache warming
│   ├── Options-Utilities-Item-List-Filter.lua   Item kind sections, the New section, the text filter and the kind filter
│   ├── Options-Utilities-Item-Lists.lua         The shared item-list builder: input parsing, the name sort, Add from Bags, rows
│   ├── Options-Utilities-Item-List-Widgets.lua  The GogoLoot_ItemLink, GogoLoot_ItemListFilter and GogoLoot_ItemListAdd widgets
│   ├── Options-General.lua                      Root panel: welcome, mini-map, the Features section, /Commands, links, version
│   ├── Options-Automated-Rolls.lua              Automated Rolls: switch, Loot Thresholds, Roll Messages; the shared switch builder
│   ├── Options-Item-Overrides.lua               Automated Rolls' Item Overrides: per-item roll actions
│   ├── Options-Character-Rules.lua              Automated Rolls' Character Rules: every character, a Manual dropdown per stat
│   ├── Options-Master-Looter.lua                Master Looter: switch, Loot Destinations, Group Loot Settings; the shared row builders
│   ├── Options-Master-Looter-Ignore-List.lua    Items automated master looting leaves for the player to hand out
│   ├── Options-Master-Looter-Popup.lua          The window that opens on becoming master looter, outside the Blizzard tree
│   ├── Options-Automated-Opening.lua            Automated Opening: switch and hold-offs, the Ignore notice
│   ├── Options-Openable-Items.lua               The Openables List: every openable item with its reason tag and Open or Ignore
│   ├── Options-Lockboxes.lua                    Lockboxes: tooltips and notifications, each with its scope
│   ├── Options-Loot-Toasts.lua                  Loot Toasts: position buttons, Stack, Text; the shared toast switch builder
│   ├── Options-Loot-Toast-Filters.lua           Loot Toasts' Filters: a Mine and a Group box per item type, Bag Count, Winning Roll
│   ├── Options-Loot-Sounds.lua                  Loot Sounds: the chime with its quality and the Pick Pocket sound, each with a speaker
│   ├── Options-Announcements.lua                Announcements: switch, Trade and Master Looter Announcements, each with its example
│   ├── Options-Profiles.lua                     Stock AceDBOptions panel, returned unmodified
│   └── Options.lua                              AceConfig registration (the panel tree), Blizzard panel wiring, the opener, slash command
├── Tests/                                       Dev-only suite, absent from the TOC and the zip (repo only)
│   ├── Fakes/WoW.lua                            The WoW and Ace surface the suite runs against
│   └── Run.lua                                  Loader, assertions and every test
├── LICENSE                                      MIT (repo only)
├── README.md                                    End-user documentation
├── README-Notes.md                              The maintainer's settled rulings and Style Guide exceptions
├── README-Technical.md                          This document
└── README-Testing.md                            Manual test plan
```

Every TOC lists the same files in the same order (Includes, Locales, Data, Features, Diagnostics, Options) except its own `## Interface`, `## X-Flavor` and data-folder lines. Everything lives on the add-on namespace table (`local ADDON_NAME, ns = ...`). The only globals are `GogoLootDB` (SavedVariables), the slash command (`SLASH_GOGOLOOT1`, `SlashCmdList["GOGOLOOT"]`), and four named frames: `GogoLootEventFrame`, `GogoLootTradeAnnounceCheckbox`, `GogoLootLootToastAnchor` (the toast stack's drag handle) and `GogoLootScanTooltip`, the one hidden tooltip that reads whether a box is locked, whether an item starts a quest, an item's stat lines for Character Rules, and an item's or spell's lines for Validate Data where a client lacks `C_TooltipInfo`'s two getters. The scan tooltip needs its name because its template's line font strings are reachable only by name. The mini-map button's frame is created inside LibDBIcon, not by GogoLoot.

## Architecture

### Event Loop

`Features/Core.lua` owns a single named event frame (`GogoLootEventFrame`) and a dispatcher. Modules never call `frame:RegisterEvent` directly; they call `ns:RegisterModuleEvent(event, handler, unit)`, which registers the event with the frame once and appends the handler to `ns.eventHandlers[event]`. On fire, `OnEvent` fans out to every handler for that event in registration order, which is TOC order. Each handler runs through `securecallfunction`, so its error goes to the client's error handler (BugSack still shows it) and the handlers after it still run: one feature's bug can't silence the others on the same event.

A `unit` registers through `RegisterUnitEvent`, so the frame wakes only for that unit: `UNIT_SPELLCAST_SUCCEEDED` fires for every caster in range and only the player's own Pick Lock and Pick Pocket matter. One frame carries one filter per event, so every handler on it shares the first registration's unit, and asking for a different one warns once. An event the client doesn't have (`C_EventUtils.IsEventValid` false) is never registered, because `RegisterEvent` errors on an unknown name and would stop the file that asked mid-load; its handler is dropped and the Event Registration probe reports it.

Two things wrap the fan-out:

- **Drift guard.** `ns.EVENT_NAMES` (Core.lua, kept sorted alphabetically) is the exported single source of truth for every event the add-on registers. `RegisterModuleEvent` prints a one-time developer warning if handed an event missing from that list. The list exists so the Diagnostics Event Registration probe can enumerate events without reading the live handler table, which would miss on-demand, self-unregistering registrations like the item lists' `GET_ITEM_INFO_RECEIVED` watcher.
- **Diagnostics tap.** When `ns.diagnostics.logging` is true, `OnEvent` hands each event to `ns:LogEvent` before dispatching. Boolean checks gate it, so it costs nothing when logging is off.

`ns:UnregisterModuleEvent` exists but is **not** safe to call from inside an event handler, because `OnEvent` iterates the live handler list. Defer to a timer or user-driven path: the item-cache watcher is the only caller, and it unregisters from inside its debounced repaint timer rather than from the `GET_ITEM_INFO_RECEIVED` handler itself. The roll retry never unregisters anything; it is a named timer, torn down with `ns:CancelTimer`.

Who listens to what:

- `Features/Core.lua`: `ADDON_LOADED` (saved-variable init, mini-map and options bootstrap).
- `Features/Announcements.lua`: `PLAYER_LOGIN` (welcome message), `LOADING_SCREEN_ENABLED` / `LOADING_SCREEN_DISABLED` (the status channel's quiet window).
- `Features/Announcements-Trade.lua`: `TRADE_SHOW` (one `OnTradeShow`: state reset, then checkbox create and sync), `TRADE_ACCEPT_UPDATE`, `TRADE_REQUEST_CANCEL`, `UI_INFO_MESSAGE` (trade complete or cancelled).
- `Features/Auto-Loot.lua`: `PLAYER_ENTERING_WORLD` (one-shot Auto Loot CVar enforcement, delayed 3 s).
- `Features/Loot-Sounds.lua`: `LOOT_OPENED` (the world-loot window, the Pick Pocket sound), `LOOT_CLOSED` (starts the chime's grace period), `CHAT_MSG_LOOT` (the chime), `UNIT_SPELLCAST_SUCCEEDED` for the player (arms the Pick Pocket sound).
- `Features/Speedy-Loot.lua`: `LOOT_READY` (the only handler: the world-loot stamp and Pick Pocket sound, then the Speedy Loot pass, throttled to one per 0.3 s), `LOOT_CLOSED` (clears the window suppression).
- `Features/Automated-Opening.lua`: `PLAYER_ENTERING_WORLD` (the first scan, 8 s after a login or reload), `BAG_UPDATE_DELAYED`, `BAG_NEW_ITEMS_UPDATED`, `GROUP_ROSTER_UPDATE`, `CHAT_MSG_LOOT` (debounced scans and the looted-container notices), `LOOT_OPENED` (an open answered), `PLAYER_LEVEL_UP`, `PLAYER_REGEN_ENABLED`, `UPDATE_STEALTH`, `UNIT_SPELLCAST_SUCCEEDED` for the player (Pick Lock), `UI_ERROR_MESSAGE` (inventory full), and the window-closed events (`BANKFRAME_CLOSED`, `GOSSIP_CLOSED`, `LOOT_CLOSED`, `MAIL_CLOSED`, `MERCHANT_CLOSED`, `QUEST_FINISHED`, `PLAYER_INTERACTION_MANAGER_FRAME_HIDE`, `TRADE_CLOSED`).
- `Features/Lockbox-Tooltips.lua`: `PLAYER_LOGIN` (hooks `GameTooltip:SetBagItem`, late on purpose; see Lockbox Tooltips).
- `Features/Loot-Toasts.lua`: `PLAYER_LOGIN` (anchor position, the first-login introduction), `CHAT_MSG_LOOT`, `CHAT_MSG_MONEY`, `BAG_UPDATE_DELAYED` (Bag Count).
- `Features/Standard-Loot-Messages.lua`: `PLAYER_ENTERING_WORLD`, `UPDATE_CHAT_WINDOWS` (the deferred sync).
- `Features/Master-Looter.lua`: `GROUP_ROSTER_UPDATE`, `PARTY_LOOT_METHOD_CHANGED`, `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA` (the pop-up's zone settle window).
- `Features/Master-Looter-Distribution.lua`: `LOOT_OPENED`, `LOOT_CLOSED`, `LOOT_SLOT_CLEARED`, `UI_ERROR_MESSAGE`; plus a `hooksecurefunc` on `GiveMasterLoot` for manual distributions.
- `Features/Automated-Rolls.lua`: `START_LOOT_ROLL`, `CONFIRM_LOOT_ROLL`, `CANCEL_LOOT_ROLL`.
- `Features/Roll-Messages.lua`: no event; a `CHAT_MSG_LOOT` chat filter (see Hide Roll Messages).
- `Options/Options-Utilities-Item-Cache.lua`: `GET_ITEM_INFO_RECEIVED`, registered on demand and self-unregistering (see Item Data Caching).
- `Diagnostics/Code-Reports.lua`: none at runtime. Its Event Registration probe registers then immediately unregisters each `ns.EVENT_NAMES` entry on a **separate** frame, with no handler attached, so probing never disturbs the live dispatcher.

### Combat Lockdown

`ns:OpenOptionsPanel` (`Options/Options.lua`) **refuses outright rather than deferring**: `InCombatLockdown()` is the first thing the function does, it prints `CHAT_OPTIONS_IN_COMBAT` through `ns:PrintMessage`, and it returns. Nothing is queued, because Blizzard's Settings panel is protected in combat and a queued open would land at a moment the player never asked for. The gate sits at the single entry point, in front of the whole routing chain, so the slash command and the mini-map button's Shift + Middle-Click answer identically on every flavor.

**Automated Opening defers.** It never opens a container while the player is in combat (`UnitAffectingCombat`): a scan skips the bag walk, the open tick returns without re-arming, and `PLAYER_REGEN_ENABLED` forces a fresh scan, so opening picks up the moment combat ends without polling through a fight or a battleground. Leaving stealth works the same way through `UPDATE_STEALTH`. On WoW Forever a cast that would read secret (`C_Secrets.ShouldUnitSpellCastingBeSecret`) also holds the tick until the next scan, because a secret value can't be compared.

Nothing else needs a guard. The loot, roll and trade paths call no protected APIs: `GiveMasterLoot`, `RollOnLoot` and `LootSlot` are all callable in combat, which is exactly where a raid uses them. The master looter pop-up is an AceConfigDialog window rather than part of the Blizzard settings tree, so it is unprotected and safe to open mid-fight.

### Master Loot Pipeline

The distribution engine in `Features/Master-Looter-Distribution.lua` runs Scan, Resolve, Distribute, Confirm:

1. **Scan.** `LOOT_OPENED` fires `RunDistributionPass` when `ns:WillAutoMasterLoot()` is true (master looter plus `autoMasterLoot`, inside a raid or party instance unless `autoMasterLootOutsideInstances`).
2. **Resolve.** `BuildCandidateMap` maps lowercased candidate names per slot, adding a realm-stripped alias only when exactly one candidate normalizes to it; ambiguous duplicates (`Bob` and `Bob-OtherRealm`) create no alias and fall back to manual handling rather than guessing. WoW Forever names are `First Last`: candidates read `Aero Bramblefoot`, and `ns:GetCleanUnitName` rejoins the two halves `UnitName` returns there (the last name comes back where other flavors put the realm, the player's own included), so a destination picked from the roster matches the candidate exactly.
3. **Distribute.** `TryDistributeSlot` gates each slot (`ShouldSkipItemForMasterLoot`, the ignore list, BoP outside trade-eligible instances, the quality-to-destination mapping) and calls `GiveMasterLoot(slot, candidate, true)`; the `true` lets the manual hook tell automated calls apart. Distribution takes the never-automated set unconditionally and the quest-class skip unless `autoMasterLootQuestItems` is on: it has no per-item instruction to honour, so the panel toggle is the only thing that can weigh against the skip (see Item-Type Skips).
4. **Confirm.** Announcements are never sent inline; see Pending Hand-out Registry. A 0.1 s retry ticker (`DISTRIBUTION_RETRY_INTERVAL`) re-runs the pass up to 20 times (`DISTRIBUTION_MAX_RETRIES`) until nothing is left or `DISTRIBUTION_QUIET_TICKS` consecutive ticks make no progress, covering late candidate data and cold item caches.

### Detecting the Master Looter (verified on Classic Era 1.15.9)

`ns:AreWeMasterLooter()` (`Features/Utilities.lua`) gates the whole pipeline, and every branch it takes has been confirmed against a live 1.15.9 client rather than assumed:

- **The legacy `GetLootMethod` global is gone** on 1.15.9, while `GetLootThreshold` survives. The split is per function, so don't infer one from the other. The `C_PartyInfo.GetLootMethod` branch is the live path, not a fallback. `SetLootMethod` follows `GetLootMethod` off the client while `SetLootThreshold` survives, so `ns:SafeSetLootMethod` needs its `C_PartyInfo` branch for the dropdown to work at all. Each of the four resolves once at load in `Features/Utilities.lua` (`ns.GetLootMethod`, `ns.GetLootThreshold`, `ns.SetLootMethod`, `ns.SetLootThreshold`), `C_PartyInfo` first; `ns.SET_LOOT_METHOD_TAKES_ENUM` records whether the setter that won takes the numeric enum. The `Safe*` wrappers in `Features/Master-Looter.lua` only map strings to enums and back.
- **`C_PartyInfo.GetLootMethod()` returns `(method, masterLooterPartyIndex, masterLooterRaidIndex)`**, the same shape as the legacy global. Verified in a master-loot party as `(2, 0, nil)`: the party index really does report `0` for "the player is the master looter", which is what the `== 0` test depends on. Under Group Loot it returns `(3, nil, nil)`, so a probe taken outside a master-loot group can't tell you anything about this.
- **`Enum.LootMethod` exists on every client with a TOC**, with Blizzard's spellings: `Freeforall`, `Roundrobin`, `Masterlooter`, `Group` and `Needbeforegreed`, 0 to 4. Blizzard's own loot menus use them on Era, TBC and WoW Forever. A probe that looks the fields up as `FreeForAll` or `MasterLoot` reads `nil` for every one and mistakes that for the enum being absent. `LOOT_METHOD_BY_ENUM` in `Features/Master-Looter.lua` and the test in `ns:AreWeMasterLooter` key off the real names; the Loot Method report prints them.

The raid case is not yet verified: `masterLooterRaidIndex` was `nil` in the party test, and the `== 0` party check carries the decision. If master looting ever misbehaves in a 40-player raid, re-run the Loot Method probe there first.

### Item-Type Skips

The skip rule is **two halves plus a composite**: the halves in `Features/Utilities.lua`, the composite local to `Features/Master-Looter-Distribution.lua`, and which one a caller takes is the whole reason Item Overrides work:

- `ns:IsNeverAutomatedItem`: legendaries (quality 5), recipes, books and patterns (`classId` 9), mounts and companion pets. Absolute; no list entry can opt back in.
- `ns:IsQuestClassItem`: `classId == ns.ITEM_CLASS_QUEST` (12) or `bindType == ns.BIND_QUEST_ITEM`. Skipped by every path that picks items **on its own**, and only those.
- `ShouldSkipItemForMasterLoot` (`Features/Master-Looter-Distribution.lua`): the composite master-loot distribution takes, the never-automated half always, plus the quest-class half unless `autoMasterLootQuestItems` says otherwise. The opt-in reaches nothing else; the roll path's own quest-class skip is untouched by it.

The split is load-bearing rather than tidy. **The AQ and ZG war-effort tokens the default roll list exists to roll on all report `classId` 12**: the scarabs (20858-20865), AQ20 idols (20866-20873), AQ40 idols (20874-20882), ZG coins (19698-19706), ZG bijous (19707-19715), and the Wartorn scraps (22373-22376). A single quest-class test run ahead of the list makes every one of those default entries unreachable: correct ids, correct saved action, and no roll ever goes out. So the roll path calls the two halves separately and sits the list between them; distribution, having no per-item instruction to weigh, keeps the composite.

Quest items are the one skip a player can turn off, and only for distribution. The case it exists for is boosting a character the same player controls, where handing the drop to the "wrong" character is the point; it ships off, because a quest item given to somebody not on the quest is wasted. A quest item still has to clear the loot threshold to reach master loot at all, which is why the toggle's tooltip says to lower it. On TBC Anniversary, where the threshold floor is Uncommon, most quest items stay out of reach entirely.

### Item Data Caching

Item info comes straight from `C_Item.GetItemInfo`, which every target client ships. `ns:SafeGetItemInfo` (`Features/Utilities.lua`) returns nil for uncached items; callers treat nil as "retry later", not an error:

- The distribution engine's retry ticker re-attempts slots whose item info was cold.
- `Features/Automated-Rolls.lua` returns `false` from `EvaluateRoll` while the item is unresolved, a nil `GetLootRollItemLink` included. That is how an uncached item reads until the client's query answers, and it is the normal state of a war-effort token's first drop of the session. The roll is polled every 0.5 s (`ScheduleRollRetry`, which re-arms a single named timer keyed by roll id, so `ns:IsTimerPending` is the duplicate-ticker guard) until the info resolves or `CANCEL_LOOT_ROLL` cancels that timer. The attempt cap (150 ticks, 75 s, past the 60 s roll window) only backstops a cancel that never arrives; it is never a give-up point. There is deliberately no "is this roll still live?" probe inside the tick: the one read that could answer it, `GetLootRollItemLink`, is nil for unresolved items too. The class and subclass skips need full item info, so a roll is never decided from `GetLootRollItemInfo`'s arguments alone.
- The options item lists render a `Loading... (ID: %d)` row, and a `GET_ITEM_INFO_RECEIVED` watcher (`Options/Options-Utilities-Item-Cache.lua`) repaints them through a debounced 0.3 s `NotifyChange` and unregisters itself once every watched item has resolved. The two saved lists, Item Overrides and the Master Looter Ignore List, join the watch at login (`ns:WarmItemCache`), so they are warm before anyone opens a panel; the Openables List, hundreds of rows, joins only the first time its panel is built, so the server is never asked for all of it until the player looks. An ID the client lacks reads `Not on this client (ID: %d)` and never holds the watcher open: either `C_Item.DoesItemExistByID` says so, or the server answers the item query with `success = false`. WoW Forever needs the second test, because it reports later-expansion items as existing but never serves them. A refused ID is never asked for again that session: the name sort, the row and the hover tooltip all skip it. The sort also reads each name once, up front, rather than inside its comparator, because reading an uncached item is a server request and the lists repaint often.
- Uncached items also have no name to sort on, so `SortItemIdentifiersByName` (`Options/Options-Utilities-Item-Lists.lua`) drops them to the bottom of their item kind's section and they re-sort into place as answers arrive. It tie-breaks equal names on item ID; without that the nine identically named Punctured Voodoo Dolls in the default roll list compare equal and reshuffle on every repaint.

### Resolving Game Message IDs

Two subsystems correlate a client message to an outcome: master-loot failures (`UI_ERROR_MESSAGE`) and trade results (`UI_INFO_MESSAGE`). Both match on the **numeric message id, never on a localized string**.

`ns:ResolveGameMessageIds(names)` (`Features/Utilities.lua`) is the one walk both use. `GetGameMessageInfo(index)` returns the *constant name* behind an id, so the walk maps this client's ids back to whichever of the requested constant names resolved. It returns the resolved table plus the number of messages scanned. The count is the only thing separating "this client resolved nothing" from "this client has no message table to resolve against", a distinction the Diagnostics report has to draw.

Maps are built lazily on first use and kept in runtime tables, never persisted: a client patch that renumbers ids can't be read back from stale saved data.

## Outbound Messages

All cross-player chat flows through `ns:Announce(channel, target, formatKey, ...)` in `Features/Announcements.lua`. Locale strings are clean bodies; the helper applies the same decoration to every sent channel:

```
PrintMessage (local only):                     GogoLoot // <body>          (branded colors)
Announce -> WHISPER/PARTY/RAID/INSTANCE_CHAT:  {rt4} <body> // GogoLoot
```

A print leads with the add-on name (`L["ADDON_TITLE"]`) and ends on its body, so the printed strings (the Chat Messages block of `enUS.lua`) close with their own punctuation. A sent message ends on the add-on name, so its templates (the Chat Announcement Templates and `ERROR_` keys) carry none, or it would read `... for the group. // GogoLoot`.

`{rt4}` (Triangle) is `ns.TARGET_MARKER` in `Data/Data.lua`. It leads every sent message on every flavor: WoW Forever blocks raid markers only in `/say` and public channels such as General, which GogoLoot never sends to (a recorded exception; see README-Notes). `ns:GetGroupChatChannel()` resolves the right group channel (`INSTANCE_CHAT`, `RAID` or `PARTY`) and returns nil when solo; `Announce` no-ops on a nil channel, and the trade path falls back to whispering the partner.

`Announce` does **not** strip pipe characters: GogoLoot bodies legitimately carry item links (`|Hitem...`), which survive outbound chat, and stripping would break them.

**Enable Announcements (`lootNotifications`, a key that keeps the panel's earlier name) is read in `Announce` itself**, so with the master switch off nothing reaches chat, whoever asks: trade summaries, destination announcements, automated and manual hand-outs, and the master-loot failure reports alike. A Me Only trade summary (`announceTradeOutput` = `self`) is printed rather than sent, so `PrintTradeSummary` reads the switch itself; it prints through `ns:PrintMessage` in the `_PRINT` templates, which end on their own punctuation, and a print has no 255-byte limit to split at. While the switch is off the trade window's Announce checkbox and the master looter pop-up's destination toggle leave with it. The loot sounds are the player's alone and answer only to their own toggles (`Features/Loot-Sounds.lua`).

**The Announcements panel shows each announcement as posted**, on a silver Example line under its toggle. It runs the real template through `ns:BuildAnnounceMessage` with stand-ins, a made-up player and an "Example Item" in its quality color (the trade example through `ns.FormatTradeSummary`, the trade module's own summary), and draws the marker as its icon, so an example can't drift from its message in any language. The automated hand-out's item takes the threshold's color. The Automated Opening panel does the same under Enable Ignore Notifications, with the plain notice (`MESSAGE_ITEM_IGNORED`) laid out as printed, add-on name first, as the Me Only trade example is. Every panel builds its examples from the Message Examples helpers in `Options/Options-Utilities.lua`: `ns.OptionsExampleRow`, `ns.OptionsExampleItem` and `ns.OptionsPrintedExample`. A recorded exception; see README-Notes.

`SendChatMessage` rejects messages over 255 bytes (`ns.CHAT_MESSAGE_MAX_LENGTH`). Trade summaries and master-loot failure reports can exceed that with a few item links, so each builds its list as parts and `ns:AnnounceParts` (`Features/Announcements.lua`) greedily packs parts into as many messages as fit: it measures the final decorated message through `ns:BuildAnnounceMessage`, splits only at part boundaries (a link broken mid-escape is rejected by the client), and repeats the same template so every message reads complete. A two-sided trade that overflows decomposes into the one-sided `MESSAGE_GAVE` and `MESSAGE_TRADE_RECEIVED` templates (`MESSAGE_GAVE` is shared with the master-loot hand-out announcement). A single part longer than the limit on its own is sent anyway; it can't be shortened without destroying the link.

## The Trade Snapshot

The trade summary is the window as it stood when a player accepted: every `TRADE_ACCEPT_UPDATE` with either player at `1` re-reads both sides, the enchant slot and the money. Any change to the window clears both acceptances, so the last accept before the trade goes through always reads the final contents. The per-slot `TRADE_PLAYER_ITEM_CHANGED` and `TRADE_TARGET_ITEM_CHANGED` events are deliberately not registered. As the trade executes, WoW Forever empties our side of the window (`TRADE_PLAYER_ITEM_CHANGED`, about 0.1 s before `Trade complete.`), and following it would drop everything we gave from the summary.

## The Trade Enchant Slot

Slot 7 (`ns.TRADE_ENCHANT_SLOT`) is the trade window's "will not be traded" slot, where an item goes to have a *service* performed on it rather than change hands: an enchant, or a rogue's Pick Lock on a lockbox. Whichever side's slot holds the item is the side receiving the service, which is why the snapshot reads both.

**The two trade-info functions return the service description in different positions**, which is the one genuinely non-obvious thing in this file:

```
GetTradePlayerItemInfo -> name, texture, numItems, quality, ENCHANTMENT (5), canLoseTransmog (6)
GetTradeTargetItemInfo -> name, texture, quantity, quality, isUsable (5),    ENCHANT (6)
```

Reading a fixed sixth return for both works for their side and silently fails for ours: position 6 on our side is `canLoseTransmog`, a boolean, so the string check rejects it and every service performed on *our* item vanishes from the summary, including the lockbox trade and every enchant somebody puts on our own gear. `SafeGetTradeEnchantName` therefore takes the position as an argument, and each caller passes the one matching the function it reads (`TRADE_ENCHANT_RETURN_PLAYER` = 5, `TRADE_ENCHANT_RETURN_TARGET` = 6). Never share one index between the two.

Wowpedia's two API pages document the asymmetry independently. Lockboxes need no special case of their own: Pick Lock rides the enchant field like any other service, so reading the right position is the whole answer.

## Pending Hand-out Registry

`GiveMasterLoot` returns immediately; the server confirms success only when the loot slot clears, and surfaces failure as a later `UI_ERROR_MESSAGE`. Announcing inline would post "Gave X to Y" for failed deliveries, twice after a retry. Instead **every call registers its own entry** under a unique id (`RegisterPendingLootAnnouncement`) carrying the slot, item, recipient, and an ordering counter.

**Why per hand-out and not one "most recent attempt" value.** `UI_ERROR_MESSAGE` names no item, so on a six-item boss kill a single pending value can only guess. The registry attributes an error to the **oldest hand-out still waiting**: the server answers in order, so anything newer hasn't been ruled on yet.

Four outcomes, all handled:

| Outcome | Signal | Result |
|---|---|---|
| Success | `LOOT_SLOT_CLEARED` for that slot | announce `MESSAGE_GAVE` |
| Known failure | a mapped `UI_ERROR_MESSAGE` | resolve oldest, report the reason |
| **Silent failure** | fallback timer fires and the slot **still holds the item** | report `ERROR_DISTRIBUTION_FAILED` |
| Aborted | `LOOT_CLOSED` | flush manual entries, drop the rest |

The silent-failure fallback (`HANDOUT_FALLBACK_DELAY`, 1.5 s) catches a hand-out the server never answered at all. It decides from the loot window itself: a slot still holding the same item means the hand-out didn't happen; anything else is ambiguous and stays quiet rather than guessing.

**Failures are batched, not one line per item per retry.** `ReportLootError` keys by player *and* reason, debounces `ERROR_BATCH_DELAY` (0.5 s), and emits one grouped report, "Bob's bags are full: itemA, itemB, itemC", split across messages by `ns:AnnounceParts` when the links overflow the chat limit. Every item already reported for that player and reason is remembered for the rest of the loot session, so the distribution ticker's retry passes stay quiet about it. The `ERROR_*` locale strings therefore take **two** placeholders: player, then the item list.

**Manual entries carry `isManual` and survive the window closing.** The confirmation is a server round trip while `LOOT_CLOSED` is local and immediate, so anything that shuts the window inside that gap (handing out the last item, pressing Escape, being moved out of range mid-fight) would drop the entry and lose the announcement silently. `LOOT_CLOSED` and `LOOT_OPENED` call `FlushPendingManualAnnouncements` before the registry is cleared. Entries are removed as they emit, so a confirmation that lands first has already taken its entry out and nothing announces twice.

The automated path deliberately keeps confirm-only semantics for *success*. It fires without the player asking, so a "Gave X to Y" for a delivery that never happened is worse there than a missed line; a manual hand-out is a deliberate act the group is owed a record of, so it biases the other way. **Failure reporting is not gated either way**: both paths always register their hand-out (the registry is what detects failure at all) and record `silentSuccess` when the success line isn't wanted, the auto path when its toggle or threshold says so and the manual hook when `announceMasterLootManual` is off. A below-threshold or unannounced item still reports its error while staying quiet on the happy path.

Known errors additionally post a generic `ERROR_*` explanation to the group, **matched on the numeric error id** resolved through `ns:ResolveGameMessageIds` (see Resolving Game Message IDs). `BuildErrorIdMap` resolves `ERROR_CONSTANT_TO_LOCALE_KEY`'s constant names to this client's ids, and the correlation is then an integer lookup. That removes a whole class of problem string matching can't solve:

- **No locale dependency.** Nothing compares against translated text, so there is no exact-versus-substring tradeoff and no drift when Blizzard rewords a message.
- **No dependence on a global being bound.** Several `ERR_*` globals are simply absent as strings on 1.15.9, which would silently disable every case relying on them. Name-to-id resolution doesn't care.
- **The right constants.** Out of range is `ERR_LOOT_TOO_FAR`, *not* `ERR_LOOT_PLAYER_NOT_PRESENT`, which is unbound on Era, and not `ERR_TOO_FAR_TO_INTERACT`, which the master looter's own out-of-reach clicks raise. `ERR_ITEM_MAX_COUNT` is left out for the same reason as `ERR_INV_FULL`: it is about the master looter's own bags.

Every constant in the table describes the **recipient**. `ERR_INV_FULL` and `ERR_LOOT_BAG_FULL` are deliberately absent: they are about the local player's own bags, so auto-looting into full bags mid-hand-out would blame the recipient. `ERR_LOOT_MASTER_OTHER` maps to a deliberately vague `ERROR_DISTRIBUTION_FAILED` ("Couldn't give loot to %s: %s") rather than guessing a cause. An unmapped id is ignored: nothing announces, nothing is cleared. With the registry empty, a mapped id is ignored too, because `UI_ERROR_MESSAGE` carries every red error the client raises, so with no hand-out in flight it is somebody else's error.

`ExtractErrorId` scans the event's arguments for the first number rather than reading argument one, so a build that reorders or omits arguments doesn't break the correlation.

The trade watcher resolves ids the same way (`Features/Announcements-Trade.lua` matches `UI_INFO_MESSAGE` against `ERR_TRADE_COMPLETE` / `ERR_TRADE_CANCELLED`, exported as `ns.TRADE_RESULT_CONSTANTS` alongside `ns.LOOT_ERROR_CONSTANTS`), and keeps a comparison against the `ERR_*` globals as a fallback for a client where neither constant resolved to an id. The Diagnostics Loot Method report prints both tables' resolved ids from a single shared walk, since an existence check can't show whether a name resolved, and the ids are per flavor, so a table that resolves on Era can come back empty on Anniversary with nothing else to show for it.

## Master Loot Destinations

`ns.db.profile.destinations` maps a quality key (`poor` to `epic`) to `"self"` or a normalized player name. It is deliberately **empty by default**: an absent quality means "nobody chosen yet", which auto-distributes nothing. Seeding every quality with `"self"` would make AceDB re-apply it at each login, so a cleared setup could never survive a reload, and a destination nobody picked would look like one they had.

Destinations are scoped to **one master-loot setup**, and `Features/Master-Looter.lua` ends that scope on three signals:

- **The group's loot type changed**: every quality resets. Carrying destinations across would leave a stale "everything goes to Bob" armed and invisible, ready to route the next session's loot at whoever was named for the last one. The comparison is against the last method GogoLoot *observed*, refreshed by both `PARTY_LOOT_METHOD_CHANGED` and `GROUP_ROSTER_UPDATE`. The method event alone isn't enough: it is the leader's action and need not reach every member, and where it does fire the loot API hasn't necessarily caught up by the time the handler runs. Tracking the method rather than resetting on every fire keeps a master-looter reassignment, which changes no method, from wiping a setup mid-run.
- **The player left the group**: every quality resets and the observed method is forgotten.
- **A named destination left the group**: that quality alone falls back to `"self"` and, if `announceDestinations` is on, says so.

`ns:GetSharedDestination` backs the Send All Loot To dropdown and returns nil when the qualities disagree, so the control shows blank rather than picking one quality's answer to stand for all five. It tracks *whether a quality has been seen* rather than whether the running answer is still nil: an explicit "no destination" is a value in its own right, and without that an unset quality followed by an assigned one would report the assigned player as the answer for all five.

### The quality rows

Loot Destinations is a section of the Master Looter panel: Send All Loot To, then one row per quality the loot threshold lets master loot reach, Epic down (`DESTINATION_QUALITIES` in `Options/Options-Master-Looter.lua`). A quality below the threshold never passes through master loot, so its row hides rather than offering a choice that does nothing; with an Uncommon threshold that leaves three rows, few enough to show always (a recorded decision; see README-Notes). Each row is a sub-option of the switch (`ns.OptionsSubSelectRow`): one indent, the caption in its quality's own color paying for it out of the label column, and the dropdown in the same column as Send All Loot To.

While automation is on and no quality the threshold reaches has anybody picked, automation hands nothing out, so `MASTER_LOOTER_NO_DESTINATIONS_NOTE` says every drop waits in the loot window. One picked quality drops it, since the rows speak for the rest.

The whole section leaves with the Automated Master Looting switch, which is what it tunes.

Every destination dropdown leads with **Loot Window** (`ns.DESTINATION_LOOT_WINDOW`), a choice that is never saved: `ns:GetDestinationChoice` reads an unset quality as it, a quality row's `set` clears the quality when it is picked, and `ns:SetAllDestinations` clears every quality and returns before announcing. Send All Loot To reads Loot Window while no quality has anybody (`ns:GetSharedDestinationChoice`), and blank while the qualities disagree. Distribution reads only the saved table, where an unset quality means "leave it in the loot window".

`ns:GetDestinationDisplayName` resolves the stored `"self"` literal to the player's own name before announcing. Announcing it verbatim would tell the group that "Self" is holding the loot, and resolving it is also what makes switching *back* to yourself announceable at all: the group has already been told somebody else is holding loot, and silence would leave that standing.

### Master Looter panel order

Top to bottom: **Automated Master Looting** with its two on/off choices, then **Loot Destinations**, then **Group Loot Settings**: what GogoLoot *does*, and who it hands loot to, before the group state it merely *reads*. The Ignore List is a child panel of its own. The opening block carries no header of its own, because the panel is already titled Master Looter and that block is what the title describes; every other panel opens the same way.

The two on/off choices and Loot Destinations leave with the switch (`HideWhenAutomationOff`, composed with any reason a row already had to hide). Group Loot Settings stays: the loot method and threshold are the group's, and the pop-up opens whenever the player becomes master looter, automation or not, so `Enable Master Looter Pop-up` closes that section, beside the settings the pop-up shows, and has to be there to turn the window off.

Group Loot Settings opens on `ns.AddLeaderNoteRow`, one line naming whoever leads the group, the player included, since the leader controls the loot method and threshold. One line says it once, where a warning plus a suffix on both labels would crowd the labels and read as an error rather than as whose group it is. Solo, where there is nobody to name and both dropdowns are greyed out, the same row reads `MASTER_LOOTER_SOLO_NOTE` in silver instead, saying why and how to change them. The pop-up carries it too, since it draws the same two dropdowns.

### The Master Looter Pop-up

`Options/Options-Master-Looter-Popup.lua` opens on every false-to-true transition of `ns:AreWeMasterLooter()`, gated by the `masterLooterPopup` setting. The flag starts at `false`, so logging in already master looter counts as becoming one, and repeat fires of the same state are a no-op.

Both events feeding that transition are load-bearing, because there is more than one way to be handed the role. `PARTY_LOOT_METHOD_CHANGED` covers the leader naming you master looter; `GROUP_ROSTER_UPDATE` covers the role *falling* to you because whoever held it left, which no loot-method event accompanies. Narrowing the trigger to the loot-method event drops that second case silently.

**Changing zones is not one of those ways, but reads like one.** A loading screen re-syncs the party's loot state, so the loot API answers with the default for a moment before the real method lands: a zoning master looter reads as "not the master looter" and then as one again, a false-to-true transition indistinguishable from a promotion, arriving on the `GROUP_ROSTER_UPDATE`s that fire freely throughout. Two guards close it, both in `CheckMasterLooterPopup`:

- **A zone-change settle window** (`ZONE_SETTLE_SECONDS`, armed from `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA`). Readings taken inside it are ignored outright and deliberately **not recorded** either. Freezing rather than updating keeps a genuine promotion that lands mid-loading-screen: the first reading after the window still compares against the state from before it, so the window opens a beat late instead of never. `PLAYER_ENTERING_WORLD`'s own `(isInitialLogin, isReloadingUi)` arguments exempt login and `/reload`, the two loading screens the pop-up *is* meant to answer from a standing start.
- **An unreadable loot method is not a demotion.** When `ns:SafeCallLootMethod()` returns nil the client can't answer yet; clearing the flag on that reading turns the next good one into a promotion that never happened. This applies outside zoning too, wherever the API has no answer.

It is an AceConfigDialog standalone window, not a hand-built frame: registered with AceConfigRegistry like any other panel but never passed to `AddToBlizOptions`, so it inherits the add-on's widget styling and stays out of the Blizzard settings tree. Nothing in it is protected, so opening it during combat is safe.

Every row in it is built by a shared builder, so the panel and the pop-up can never drift: its own on/off toggle, Enable Automated Master Looting (`ns.AutomatedMasterLootingSwitch`, the panel's own switch) and the destination-message toggle (`ns.AddPopupToggleRow`, `ns.AddDestinationMessagesRow`), the leader note (`ns.AddLeaderNoteRow`), then loot method, loot threshold and Send All Loot To (`ns.AddLootMethodRow`, `ns.AddLootThresholdRow`, `ns.AddSendAllDestinationRow`). The toggles are there because this is the window you would most want them from: it opened on its own, a destination picked with the automation off hands nothing out (so Send All Loot To leaves with the switch, as on the panel), and the destination you are about to pick is exactly what the last one decides whether to announce. `ns:RefreshMasterLooterPanels` notifies both registry names together for the same reason. Rows that don't apply to the current loot method hide rather than shrink the window: AceConfigDialog takes the frame size from its status table, never from how much content is on show.

## Item Overrides vs. the Automated Rolls Toggle

The `autoGreed` toggle is the **master switch** for every automated roll: when Automated Rolls is off, nothing rolls automatically, Item Overrides included. The list also has its own `customRollList` toggle (default on), nested under the master: with rolls on and the list off, only the threshold path runs.

Item Overrides' saved table keeps its old name, `ignoredItemsSolo`, since renaming saved data needs a migration; its file (`Options/Options-Item-Overrides.lua`), builder, registry name (`ns.OPTIONS_REGISTRY.ItemOverrides`) and `ITEM_OVERRIDES_*` locale keys follow the panel.

`EvaluateRoll` in `Features/Automated-Rolls.lua` applies its gates in a fixed order, and **the order is the design**:

1. `autoGreed`: the master switch, first of all, ahead even of the wait for item info, so a roll with Automated Rolls off never schedules a retry.
2. `ns:IsNeverAutomatedItem`: legendaries, recipes, mounts, pets. Nothing gets past this, list entry or not.
3. **Item Overrides.** A per-item override is an explicit instruction from the player, so it bypasses the threshold, the BoP guard, *and* the quest-class skip below. `ns.MANUAL` means "leave it to me" and returns without rolling; anything else rolls its configured Need, Greed or Pass (Need falls back to Greed when the client doesn't offer Need).
4. `ns:IsQuestClassItem`: unlisted quest items are never picked up by the threshold path on its own.
5. BoP: the threshold path never touches a bind-on-pickup item. The list is the only way to automate one.
6. Threshold, per group context: rolls when `quality <= threshold`, unless Character Rules leave the item to the player (see Character Rules). That is the last check before rolling, since its tooltip read is the costliest and a rule can only leave a roll alone.

Step 3 sitting ahead of step 4 is the load-bearing bit: the tokens the default list ships for are quest-class (see Item-Type Skips), so checking the skip first makes the whole feature a no-op for them. Steps 2 and 3 are also why the two skip halves exist separately at all.

The threshold path is configured **per group context**: `GetContextRollSettings` reads the raid pair (`autoRollActionRaid` / `autoRollThresholdRaid`) when `IsInRaid()` is true and the party pair otherwise, and both paths share `ExecuteRollOverride`, so a threshold roll honors the Need-to-Greed fallback exactly like a list entry. An action of `ns.MANUAL` disables automation for that context alone, so Automated Rolls can run in raids but not parties without touching the master toggle.

Nothing in the module inspects the loot method. GogoLoot acts on every `START_LOOT_ROLL` the client raises, so a roll that opens during a master-loot session is automated identically to one from Group Loot or Need Before Greed. Master loot suppresses most roll windows client-side (at-or-above-threshold items are assigned through the master looter's window and never roll), so what changes with master loot is how often the event fires, not whether GogoLoot answers it.

Only rolls this module issues are recorded in `rollsInitiatedByAddon`, so the `CONFIRM_LOOT_ROLL` handler auto-confirms bind dialogs for GogoLoot's rolls only; player-initiated rolls keep Blizzard's confirmation. With `printRolledItems` on (the default), each roll it makes prints one line naming the item and the roll actually made (`MESSAGE_ROLL_PRINT`, or `MESSAGE_ROLL_PASS_PRINT` for a Pass), because the roll window closes the moment GogoLoot rolls; a Need that fell back to Greed reads as Greed. A roll GogoLoot leaves alone prints nothing. The result reaches the player on the winner's toast (Loot Toasts, Winning rolls) and in the winner summary.

On the panel, below the switch, a **Loot Thresholds** header leads the context rows and a **Roll Messages** header leads Print Item in Chat (with its example row), then Hide Roll Messages with the winner summary dropdown beside it and its example under it; both headers leave with the switch. Each group context is a label-beside-control row (`rollRowParty`, `rollRowRaid`) with its roll, and an indented `Up to Quality` sub-row (`qualityRowParty`, `qualityRowRaid`) that leaves while the roll is `ns.MANUAL`. The quality labels are `ns.ROLL_THRESHOLD_LABELS`, which the mini-map tooltip reads too.

### Hide Roll Messages

`hideRollMessages` (on by default) adds one chat filter for `CHAT_MSG_LOOT` through `ChatFrameUtil.AddMessageEventFilter`, which all three clients ship, at file scope in `Features/Roll-Messages.lua`. It hides a line when `ns.IsRollChatterMessage` says it only reports a pick or a number: the client's `LOOT_ROLL_NEED` / `_GREED` / `_DISENCHANT` (and their `_SELF` forms), `LOOT_ROLL_PASSED` and its automatic forms, `LOOT_ROLL_LOST_ROLL`, the `LOOT_ROLL_ROLLED_*` lines, and the line opening a roll (`LOOT_ROLL_STARTED`, which as a format is only `%s`, so it is recognised by its shape, a history link then an item link alone, and never by a pattern that would match every line with a link). What players received never matches, and who won (`ns.ParseRollWonMessage`) is hidden only while the winner summary is on. A chat filter changes only what the frames draw, so every `CHAT_MSG_LOOT` handler still hears the line, the toasts' roll tracking included. It is part of Automated Rolls: the filter hides nothing while `autoGreed` is off, and the toggle leaves the panel with the master switch, keeping its saved value for when the switch comes back.

The dropdown beside the toggle (`winnerSummary`: `ns.WINNER_SUMMARY_PRINT` by default, or `ns.WINNER_SUMMARY_NONE`) leaves the line with it. On Print, GogoLoot prints one line per win from `ns.OnRollWon`, which `ns.RecordRollLine` (`Features/Loot-Toasts-Winning-Rolls.lua`) calls on every won line with the winner (nil for the player), the item and the winning roll as the toasts word it (`LOOT_TOASTS_ROLL_RESULT`), read from the spam-free won line or from that player's recorded roll line. The roll tracking runs on every `CHAT_MSG_LOOT` whether or not the toasts are on. The four templates are `MESSAGE_ROLL_WON_PRINT`, `MESSAGE_ROLL_YOU_WON_PRINT` and their `_NO_ROLL_` forms for a win whose roll wasn't seen. The winner's name takes their class color from `ns:GetGroupMemberClassColor` (`Features/Utilities.lua`, shared with the toasts' looter names), plain once the roster no longer holds them. The panel's example names Aero in the Warrior color.

### Roll lines

`Features/Utilities.lua` reads the roll lines the way it reads the loot lines, from the client's own formats. Most of them open on a hidden `|HlootHistory:%d|h[Loot]|h: ` link carrying a number of its own, so `BuildRollMatcher` drops that link from the format and `MatchRollLine` from the message, leaving the roll as the only number. Captures are read by what they hold rather than by position, because a translation may reorder its arguments (and the matcher accepts `%1$s` positional forms): the one carrying an item link is the item, the number is the roll, and the other text is the player. `ns.ParseRollResultMessage` reads a roll line; `ns.ParseRollWonMessage` reads who won, trying the `LOOT_ROLL_*_WON_NO_SPAM_*` forms first, which the client prints with its roll spam turned down and which carry the winning roll themselves. A format a client lacks is skipped.

## Character Rules

Character Rules let each character leave gear with stats it doesn't want to the player: a rule sets a stat to **Manual**, and any threshold roll on an item carrying that stat keeps its roll window. The only other choice, **Standard Automated Roll** (`ns.CHARACTER_RULE_STANDARD`), saves nothing. It is read in one place, `ns.CharacterRulesLeaveToPlayer` (`Features/Character-Rules.lua`), from step 6 of `EvaluateRoll`, after Item Overrides, which name one item and so always win. Master-loot distribution never reads it.

**The rules are per character, not per profile.** Under the Simple model every character shares the `"Default"` profile, so a rule kept there would apply to the warrior and the mage alike. Rules live in each character's AceDB char section (`ns.db.char.characterRules`, stat key to `"manual"`), and a character left with no Manual stat drops the table, so `CharacterRulesLeaveToPlayer` returns before reading any stats for a character with no rules. The panel (`Options/Options-Character-Rules.lua`) edits other characters' rules through `ns.db.sv.char`, the same tables AceDB keeps under each `"Name - Realm"` key. `Features/Core.lua` records the character's class (`ns.db.char.classFile`) at every login, so the panel can draw another character's name in its class color, and so a character with no rules still has a char section, since AceDB drops an empty one at logout.

**No single source sees every stat on every client**, so `ns.ReadCharacterRuleStats` asks four and keeps which ones answered, for the Gear Stats report:

- `ITEM`: `ns.GetItemStats` (`C_Item.GetItemStats`, or the legacy global where only that exists). On WoW Forever and later it includes spell power, attack power and crit. It reads the base item only, never the link's random suffix.
- `EQUIP_TABLE`: `ns.ITEM_STAT_FLAGS`, for Classic Era and TBC gear whose spell power, healing, attack power, crit, hit or mana regeneration is an "Equip:" spell, which `GetItemStats` doesn't report.
- `SUFFIX_TABLE`: `ns.RANDOM_SUFFIX_STAT_FLAGS`, keyed by the suffix id in the link (`ns.GetLinkRandomSuffix`), because on those clients every stat a random suffix such as "of the Owl" gives is an enchantment rather than an item stat.
- `TOOLTIP`: the tooltip's "+15 Intellect" lines, matched against the game's own stat-line formats, so in any language. This is what a random suffix rolled on a client with no suffix table (WoW Forever ships none). Play It Forward reads its stats the same way.

The two tables are generated per client (`Data/{Folder}/Item-Stats-{Folder}.lua`, each value a sum of `ns.CHARACTER_RULE_STATS` bits) and declared empty where the item reports everything itself. A stat's `bit` is baked into those generated tables, so it never changes once shipped.

**The tooltip patterns come from the full `ITEM_MOD_*` formats** (`"%c%s Stamina"`), which are what the tooltip prints, never from the `ITEM_MOD_*_SHORT` labels the dropdowns are captioned with: several locales word the line apart from the label (`"+15 p. de intelecto"`, `"지능 +15"`). deDE on Classic Era and TBC numbers its arguments (`"%1$c%2$d Stärke"`), so `BuildStatLinePattern` strips the numbering first. Patterns are built once, on first use.

The panel is a tree (`childGroups = "tree"`), laid out like Magic Eraser's list panels: every character on the account down the left, keyed by its `"Name - Realm"` so the tree's remembered selection can't drift onto someone else as characters come and go, and the picked character's dropdowns on the right under two captions, the game's own `STAT_CATEGORY_PRIMARY_ATTRIBUTES` / `STAT_CATEGORY_SECONDARY_ATTRIBUTES` where the client has them and GogoLoot's own words where it doesn't (`ns.CHARACTER_RULE_GROUPS`). Primary attributes keep the character sheet's order; secondary ones sort A to Z by their name in the player's language. It is registered as a builder function, so a character logged in since shows up, and `ns.OnCharacterRulesRegistered` points the tree at the character being played at registration and every time the panel hides. Like Item Overrides it never hides behind Automated Rolls' switch: `ROLLS_OFF_NOTE` says nothing here rolls while it is off.

## Speedy Loot

`Features/Speedy-Loot.lua` owns the one `LOOT_READY` handler, and its order is load-bearing: `ns.StampWorldLoot` and `ns.PlayPickPocketSound` (`Features/Loot-Sounds.lua`) read the loot slots, so they run before the Speedy Loot pass empties them. A test pins the order.

The pass stands down for the **entire loot session** whenever `ns:AreWeMasterLooter()` is true, not merely when GogoLoot will auto-distribute. Master loot is a managed flow (at-or-above-threshold items are assigned through the master looter's window; sub-threshold items go out by the group method), and a `LootSlot` call here would either vacuum that loot into the master looter's own bags before it can be assigned, or pop `MasterLooterFrame_Show` on a threshold item, which errors on some clients. `AreWeMasterLooter()` is the superset of `WillAutoMasterLoot()`, so this still covers the auto-distribute case, including outside instances where auto-distribution is off by default.

Otherwise it respects the Auto Loot CVar (and its modifier-key inversion), throttles to one pass per 0.3 s, and loots bottom-up, mirroring default auto-loot and avoiding index shifts, spending a free-bag-slot count (`ns.CountFreeBagSlots`) one slot per item. Only general-purpose bags count (bagFamily 0 or nil); specialty bags can't hold arbitrary loot. Money and currency (anything but `ns.LOOT_SLOT_TYPE_ITEM`, which reads `Enum.LootSlotType.Item` on Forever's Retail engine and `LOOT_SLOT_ITEM` elsewhere) are always looted. With zero free slots and item slots present, it loots nothing and leaves the window up rather than stranding loot.

**The window never flashes.** A plain `LootFrame:Hide()` on `LOOT_READY` is a no-op, since the default UI shows the frame afterwards on `LOOT_OPENED`, which is the half-second flash. Instead a one-time `HookScript("OnShow", ...)` re-hides the frame the instant it shows, but only while `suppressLootWindow` is set, and that flag is `not leftBehind and not bagsTight`: true only when the pass took everything with room to spare. Anything left behind keeps the window up through an explicit `LootFrame:Show()`: an item set to Ignore on the Openables List (with the throttled `MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW` notice when Ignore notifications are on), loot the bags ran out of room for, or a Bind on Pickup item. That one is still passed to `LootSlot`, so the client asks its "will bind it to you" question (`LOOT_BIND`) as its own Auto Loot does, but the question only works while the loot session is open, and Blizzard's loot frame drops it whenever the window closes, so hiding the window would cancel it and leave the item on the corpse. The bind type comes from `C_Item.GetItemInfo`; an uncached item reads as not Bind on Pickup. **Bags getting tight also keeps it up:** hiding the window closes the loot before the server has answered a single `LootSlot`, so once a pass leaves fewer than `ns.MIN_FREE_SLOTS` free, a pickup that bounces off full bags stays in the window instead of on a corpse the player can't see. `LOOT_CLOSED` clears the flag, so a throttled `LOOT_READY` can't carry one corpse's verdict onto the next.

## Automated Opening

`Features/Automated-Opening.lua` opens what `Features/Openable-Items.lua` says to, one item every `ns.OPEN_TICK_INTERVAL` (0.25 s), gated by `ns.db.profile.autoOpen`.

1. **Scan.** `ns.ScheduleOpeningScan(force)` absorbs bag churn: an unforced call waits `ns.SCAN_DEBOUNCE` (0.5 s) and every request before it runs is absorbed into it. Forced calls run at once: a setting change, the world load (8 s after a login or reload), combat ending, leaving stealth, a picked lock settling (0.5 s after Pick Lock, and after every trade, for boxes another Rogue unlocked in the trade window), and a vendor, mail, bank, gossip, quest, trade or loot window closing. Each run checks free space, pauses or resumes, and, out of combat, rebuilds the queue and starts the tick. `RunScan` and its debounce callback are file locals, so a bag event allocates nothing before a scan is needed.
2. **Queue.** `BuildQueue` walks bags 0 to `NUM_BAG_SLOTS` and queues every slot whose item is set to Open, **doesn't read Locked**, isn't above the player's level and hasn't been set aside as refused (below). Every item set to Open is lock-checked, lockbox or not: the game can't open a locked box, so it waits for its lock instead of being tried every tick into "Item is locked" errors. The level is the fifth return of `C_Item.GetItemInfo`, against `UnitLevel`; an item not yet cached reads no level and is tried, and `PLAYER_LEVEL_UP` rescans. The queue is a flat array of `(bag, slot, itemId)` triples with head and tail cursors.
3. **Open.** `OpenTick` pops a slot, opens it with `C_Container.UseContainerItem` only if the same item is still there, and rechecks the slot after `ns.OPEN_RECHECK_DELAY`: a stack still holds more, and an open the server didn't take leaves the item in place, so it goes back on the queue if it still should be opened.
4. **Refused opens.** The game also refuses an open for reasons no API reports, such as a holiday on WoW Forever ("Requires Love is in the Air" on the Gifts and Pledges of Friendship and Box of Chocolates), or a level the item info hadn't loaded yet. Left alone, the recheck above would try such an item twice a second into a red error for as long as it sat in the bags. An open the game takes always answers with a loot window (`LOOT_OPENED`), so the tick holds the next open until the last one is answered or `ns.OPEN_ANSWER_TIMEOUT` (1 s) passes, and an unanswered one counts as refused. After `ns.OPEN_REFUSAL_LIMIT` (3) in a row the item ID is set aside until the next level-up or login; an answered open clears its count. Waiting for the answer, rather than reading the stack a moment after the open, keeps a slow connection from setting aside a stack the game is still opening.

**The safety gates** (`IsSafeToOpen`, checked before every open): the switch and the pause; the player's two hold-offs (Only Outside Instances, `autoOpenWhere` = `OUTSIDE_INSTANCES`, inside an instance; Only While Solo, `autoOpenGroup` = `SOLO_ONLY`, in a group; a zone change and `GROUP_ROSTER_UPDATE` both rescan, so leaving either state resumes opening without a bag event); combat; a vendor, mailbox, trade, bank, guild bank, auction house (`AuctionFrame` on Era and TBC, `AuctionHouseFrame` on WoW Forever), gossip, quest, loot or confirmation window, the loot window so a container never opens while the player is still looking at loot, such as an item Speedy Loot left for them; stealth or Shadowmeld (`C_UnitAuras.GetPlayerAuraBySpellID`, asked only once `C_Secrets.ShouldSpellAuraBeSecret` says the aura won't read secret: WoW Forever makes aura reads secret during encounters and PvP matches, out of combat too, and while it would, Shadowmeld can't be ruled out, so opening waits); a cast or channel (the tick waits for it); an item under the player's cursor in the game tooltip; and fewer than `ns.MIN_FREE_SLOTS` (4) free general-purpose slots.

**Pause and resume** share that one line: opening pauses below it and resumes on reaching it, so `MESSAGE_OPENING_PAUSED` names the count that actually resumes opening. An inventory-full error (`ns.IsBagFullErrorID`, the numeric `LE_GAME_ERR_INV_FULL`) pauses at once, but only while one of GogoLoot's own opens is waiting on its answer: every other full-bag error is the game's to report (a recorded decision; see README-Notes). It fires once per `ns.BAG_FULL_COOLDOWN` (10 s), with the client's own `ERR_INV_FULL` line and the character's own race and sex voice line (`ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE`, in `Data/{Folder}/Game-IDs-{Folder}.lua`). Status lines go through `ns:StatusPrint` (`Features/Announcements.lua`), which holds them for a quiet window across loading screens and drops an identical line inside `ns.STATUS_REPEAT_COOLDOWN`; a pause or resume that lands while a vendor or similar window is open is held until it closes, or "Resumed" is lost in the player's vendoring.

**Looted-container notices** come from `CHAT_MSG_LOOT`, read through `ns.ParseOwnLootMessage`: a lockbox (its data default `ns.OPENING_UNLOCKED`) set to Open prints `MESSAGE_ITEM_WILL_AUTO_OPEN`, which needs Automated Opening on as well as the notifications toggle on the Lockboxes panel and its scope, because the line promises an opening; an item set to Ignore prints its notice under Enable Ignore Notifications, by the reason its default gives (`MESSAGE_ITEM_IGNORED_RAID` for a raid boss drop, `MESSAGE_ITEM_IGNORED_UNIQUE` for one that may hold a unique item, and `MESSAGE_ITEM_IGNORED` for anything else, whether ignored by default or by the player). `ns:AnnounceItemOnce` allows one notice per item per `ns.ITEM_ANNOUNCE_COOLDOWN` (5 s), shared with Speedy Loot's left-behind notice on purpose.

**Locked Items.** `ns.GetLockedBoxes` lists the boxes still waiting: anything set to Open that reads Locked, one row per item with a count, sorted by name, the name taken from the item's own link. The mini-map tooltip leads with it, and Diagnostics' Locked Boxes report shows the same verdict with the tooltip's line count. It is worked out on demand and never cached.

## Openables List

`Features/Openable-Items.lua` answers what Automated Opening does with an item: Open, or Ignore, which leaves it alone. Every row of `ns.OPENABLE_ITEMS` carries its item's default, one of five, and four of them also carry a reason: `ns.OPENING_OPEN`; `ns.OPENING_UNLOCKED`, a lockbox (Open, tagged Locked); `ns.OPENING_IGNORE_RAID`, a raid boss drop, and `ns.OPENING_IGNORE`, a tradeable container that can hold Bind on Pickup loot (both Ignore, tagged Sell Sealed); and `ns.OPENING_IGNORE_UNIQUE`, one that may hold a unique item (Ignore, tagged May Hold Unique). `ns:GetOpeningDefault` returns the default, reason and all, `ns:GetDefaultOpeningAction` the action it takes, and `ns:GetOpeningAction` the player's choice where there is one and the default's action otherwise, and nil for an item that isn't on the list.

**The reason belongs to the item, not to the setting.** `ns:GetOpeningTag` and `ns:GetOpeningNote` read it from the data default, so a row keeps its tag and its tooltip line whatever the player sets it to, and the looted-container notices take it from there too. Only Open and Ignore are ever saved or offered: a reason is data, and it changes neither what opens nor what is left alone.

**Only the player's changes are saved**, in the account-wide `ns.db.global.openingActions` (`itemId` to action): a listed item set away from its default, an item the player added (`ns:AddOpeningItem`, which joins it on Open), and `ns.OPENING_REMOVED` for a listed item the player took off (`ns:RemoveOpeningItem`). `ns:SetOpeningAction` removes a choice set back to its default rather than storing it, and only acts on an item that is on the list. Keeping defaults out of the saved table is what lets new data reach every player without a migration: an item added to a folder, or given a new default, takes effect for everyone who hasn't set that item. Restore Defaults (`ns:RestoreDefaultOpeningActions`) wipes the table, so every choice, addition and removal goes at once. Every change forces a rescan and repaints the panel.

**Gear and bags can't be added.** Opening an item is using it, and using an item with an equip slot equips it, binding a Bind on Equip item for good. `ns:AddOpeningItem` refuses any item whose `C_Item.GetItemInfoInstant` slot is set, and the panel says why in chat. Retail-engine clients report an unequippable item's slot as `INVTYPE_NON_EQUIP_IGNORE` rather than an empty string, so both count as no slot.

**A removed item is no container to GogoLoot.** It is never opened, Speedy Loot takes it like any other item, and Loot Toasts no longer count it as an Openable. **Ignore reaches Speedy Loot too:** `ns:IsOpeningIgnored` is what leaves an item in the loot window.

The panel (`Options/Options-Openable-Items.lua`) builds through `ns:BuildItemListOptions` over `ns:GetOpenableItemList` (the data's rows less the removed ones, plus the added ones): the add line with Add from Bags, offering only what `ns:CanAddOpeningItem` takes, then the filter and the kind filter, then one row per item under its item kind header (Item Kind Sections), with its silver reason tag, its Open / Ignore dropdown (`ns.OPENING_ACTION_ORDER`) and a remove icon, which confirms since the row carries a setting, and Restore Defaults at the foot. Rows for items this client doesn't have are left out. A row whose default carries a reason explains it under the item tooltip (`ns:GetOpeningNote`: `OPENING_REASON_LOCKED_CLASS`, which names the class through `LOCALIZED_CLASS_NAMES_MALE`, `OPENING_REASON_RAID`, `OPENING_REASON_BIND_ON_PICKUP` or `OPENING_REASON_UNIQUE`, never an item name, since the client's own tooltip sits directly above). The Ignore notice's switch sits on the Automated Opening panel and hides with its switch, and while Automated Opening is off the list says so (`OPENABLE_ITEMS_OFF_NOTE`), since Ignore still reaches Speedy Loot.

### Openable Items Data

Each flavor folder's `Openable-Items-{Folder}.lua` and `Lockbox-Skill-Levels-{Folder}.lua` come from that client's own tables on wago.tools (`https://wago.tools/db2/{Table}/csv?build={build}`), and each file's source block names the build:

| Folder | Client | Build |
|---|---|---|
| Vanilla, Discovery | Classic Era | 1.15.9.69722 |
| Camelot | WoW Forever | 1.60.1.70009 |
| TBC | TBC Anniversary | 2.5.6.69795 |
| Wrath | Wrath Classic | 3.4.4.61581 |
| Mists | MoP Classic | 5.5.4.69934 |
| Mainline | Retail | 12.1.0.69933 |

1. **Rows.** Every `ItemSparse` row flagged Openable (`Flags_0 & 0x4`, the flag behind "<Right Click to Open>"), less bags and equippable items (`InventoryType` set; Zigris' Footlocker 22233 is flagged Openable but is a 16 slot bag), less placeholders named `Test`, `QATest`, `[DNT]`, `[PH]`, `[NYI]`, `(TEMP)` or `Deprecated`.
2. **Season of Discovery.** The Classic Era tables carry SoD's items too. Vanilla leaves out every id first seen after build 1.14.4.51829, the last before SoD launched; Discovery keeps them.
3. **WoW Forever.** Forever's `ItemSparse` ships without most of its rows, which the server streams in, so only Forever's own `ItemSparse` rows and its wago.tools hotfix rows count. Filling the missing rows from Classic Era brings in items Forever's server doesn't know (Validate Data on build 70205 flagged every one of them), so no Forever row may rest on Classic Era's alone. SoD's items are left out as for Vanilla, Forever's own new containers stay in, and the unobtainable "Level N" gear and supply boxes stay out (a recorded decision; see README-Notes).
4. **Clams on Wrath and later.** Those clients open clams through a use spell flagged player-cast (`Flags_0 & 0x40`) rather than the loot flag, and an add-on can't cast a spell for the player, so the clams leave those lists by the rule above.
5. **Lockpicking.** A row whose `LockID` is set gets its `Lockbox-Skill-Levels` row from that `Lock` row's pick-lock entry (Type 2, Index 1). A lock asking for a key or another profession (Floral Foundations and Strange Envelope need Inscription) gets no skill row.

**Defaults** follow the maintainer's rules, first match wins:

1. **`OPENING_IGNORE_RAID`** (Ignore, tagged Sell Sealed) for a container that drops only from raid bosses. A raid boss is a rank 3 creature not spawned in a 5-player dungeon, so world bosses (Azuregos, Lord Kazzak, the Emerald dragons) count. Any other source (trash, fishing, a vendor, a quest, another container, a spell) rules it out.
2. **`OPENING_UNLOCKED`** (Open, tagged Locked) for a container with a lock. A lockbox's random table reaches rare Unique gear, Bind on Pickup recipes and quest items, which would otherwise put every lockbox on an Ignore.
3. **`OPENING_IGNORE_UNIQUE`** (Ignore, tagged May Hold Unique) for a container that can hold a Unique item (`MaxCount` 1) that isn't gear. Opening one while you carry that item fails, and Automated Opening would keep retrying it. Weapons and armor are left out: rare world-drop rings and trinkets are Unique too, and counting them would put most random-loot containers on Ignore.
4. **`OPENING_IGNORE`** (Ignore, tagged Sell Sealed) for a container that can hold a Bind on Pickup item while it can itself be traded (Bind on Equip, Bind on Use or unbound). A soulbound or quest container opens: keeping it sealed saves nothing.
5. **`OPENING_OPEN`** for the rest.

No client table records what a container holds or where it drops, so contents and sources come from the CMaNGOS world DB dumps (`github.com/cmangos/{classic,tbc,wotlk}-db`, `Full_DB`), resolving loot references all the way down, while the bind type and `MaxCount` of each item come from that flavor's own client tables. Vanilla, Discovery and Camelot read the Classic DB, TBC the TBC DB, and Wrath the Wrath DB; Mists and Mainline have no open DB and take Wrath's verdict for the items Wrath has, a later item's default resting on its lock alone. A chest inside a raid, or with no fixed spawn, may be a boss's loot chest or a key-opened one, so a container known only from such chests (Alchemist's Cache from Freya's Gift), or one the DB lacks (Season of Discovery's, Forever's own, the re-added 191060 Black Sack of Gems), keeps the maintainer's earlier call. Where the DB contradicts an earlier hand call, the DB wins: Box of Chocolates holds only candy, Heavy Crate is also fished up, the Ulduar spoils sacks are Bind on Pickup quest rewards, Wrath's Gifts and Pledges of Adoration hold no Bind on Pickup item, and Classic Era's fishing trunks predate the Weather-Beaten Journal.

Regenerating a folder: rebuild the rows from the new build's tables and rerun the rules, then carry over by item ID any action the maintainer set by hand. A test holds every folder to the shape: every row's value is one of the five defaults, and every skill row is an `OPENING_UNLOCKED` row.

## Lockbox Tooltips

`Features/Lockbox-Tooltips.lua` adds a block to a lockbox's bag tooltip: the add-on's title, then the Lockpicking the box needs (`ns.LOCKBOX_SKILL_LEVELS`) or, when the client already prints its own requirement line (matched through the `ITEM_MIN_SKILL` format, never the skill's name), the player's own rank. On a Rogue whose rank can be read, the number is green or red by whether it clears the box. The rank is found by the skill line's localized name, `C_TradeSkillUI.GetTradeSkillDisplayName(ns.SKILL_LINE_IDS.LOCKPICKING)` (`ns.GetLockpickingSkillName`), which also captions the block; never from the tooltip, which would be circular, and never from the Lockpicking spell's name, a different record that differs from the skill line in esES and esMX ("Forzar cerraduras" against "Ganzúa"). Skill line 633 carries no Horde name in any locale on Era or TBC (wago.tools `SkillLine`, 2026-10-04). WoW Forever has no skill-line API, so there the requirement shows without a rank (a recorded decision; see README-Notes). Both lockbox features carry a scope (`ns.LockboxScopeAllows`): Rogues only by default.

**The block goes last by being late in the frame, never by being late to it.** The `GameTooltip:SetBagItem` post-hook is installed at `PLAYER_LOGIN`, so it runs behind every add-on that hooked while loading. Deferring the add with `C_Timer.After(0)` would put it under everything, and flickers badly: a hovered bag button re-runs `SetBagItem` every frame. The title doubles as the already-added mark, since a tooltip can be re-processed without being cleared.

## Loot Sounds

`Features/Loot-Sounds.lua` plays the rare-loot chime (`ns.LOOT_SOUND_FILE`) for loot at or above `lootSoundThreshold` (Uncommon by default), and only for loot from a corpse or chest. A loot window alone can't say where loot came from: disenchants, prospecting, container opens and the white-into-green merge arrive through the same window and loot line. They differ only in the slots' source GUIDs, so `ns.StampWorldLoot` reads them on `LOOT_READY` (inside Speedy Loot's handler) and `LOOT_OPENED`, since the GUIDs can arrive on either and Speedy Loot may empty the slots between them. Three answers:

- **A `Creature`, `Vehicle` or `GameObject` source** opens the chime's window, which stays open as long as that loot window does, so a Bind on Pickup item confirmed or an item looted by hand seconds later still chimes, and for `ns.LOOT_SOUND_WINDOW` (1 s) after `LOOT_CLOSED`, for loot lines that land just after.
- **Only `Item` sources** close it outright, so a disenchant or merge just after a real corpse can't reuse its window.
- **Nothing to go on yet** (an empty window, GUIDs not arrived) leaves it alone. Kept apart from "item" on purpose: a corpse not yet populated must not be taken for item loot, and a window just opened for this corpse must survive an empty re-read.

`CHAT_MSG_LOOT` then chimes only while that window is open. Item-made loot never opens it, so it stays silent, and so does a roll win (a recorded decision; see README-Notes). Each sound answers to its own toggle alone, on the Loot Sounds panel (`Options/Options-Loot-Sounds.lua`).

The Pick Pocket sound is armed by the cast (`UNIT_SPELLCAST_SUCCEEDED`, the player only, asked only once `C_Secrets.ShouldUnitSpellCastingBeSecret` says the cast won't read secret) and plays only when a loot window with something in it opens within `ns.PICK_POCKET_LOOT_WINDOW`, disarming as it plays: the cast succeeds against empty pockets too.

Quality comes from `ns.GetLinkQuality`: the link's own hex color read back through `ns.QUALITY_COLORS`, a Retail-engine named quality color (`|cnIQ4:`), or `C_Item.GetItemInfo` as a last resort.

## Loot Toasts

`Features/Loot-Toasts.lua` is the on-screen readout Speedy Loot's hidden window would otherwise cost: icon, colored link without its brackets, and the quantity from the loot message. The stack reads like a chat log: the newest row sits at the anchor and age carries rows away from it, up or down (`lootToastGrowth`), hung from the anchor's left or right end (`lootToastAlign`). Rows pin to a corner of the anchor, never its center, so a wider row or a font change can't walk the stack across the screen.

- **What shows.** The Filters rows, `ns.LOOT_TOAST_FILTER_ROWS` in `Data/Data.lua`: one per item type the client files loot under (a class, or for Mount and Companion Pets a Miscellaneous subclass, which wins over the class's row), plus GogoLoot's own Bind on Pickup, Openables and Money. Each has a Mine box (`lootToastMine`, keyed by the row's key) for the player's own loot and a Group box (`lootToastGroup`) for the rest of the group's, and the rarity rows (Armor, Weapon, Trade Goods, Gem) take a minimum quality per side (`lootToastMineQuality`, `lootToastGroupQuality`). An item shows when its type's box is ticked and, on a rarity row, it reaches that quality, or when Openables (an item on the Openables List, whatever it is set to), Bind on Pickup, or Quest claims it: an item bound as a quest item whatever its class (Soft-shelled Clam is a Key), or a quest starter, as often a trinket or a blade as a quest item. They are tested by cost: a table lookup, then `C_Item.GetItemInfoInstant`, then `C_Item.GetItemInfo`'s bind type, and last a scan-tooltip read for "This Item Begins a Quest" (a recorded exception; see README-Notes). A quality nobody can read passes a rarity row. Coin (`CHAT_MSG_MONEY`, read back through the client's own `GOLD_AMOUNT` / `SILVER_AMOUNT` / `COPPER_AMOUNT` formats) answers to Money's Mine box; it has no Group box, since the game reports no other player's coin.
- **Whose loot.** A `CHAT_MSG_LOOT` line that isn't the player's own is read through `ns.ParseGroupLootMessage` (the client's `LOOT_ITEM`, `LOOT_ITEM_MULTIPLE`, `LOOT_ITEM_PUSHED` and `LOOT_ITEM_PUSHED_MULTIPLE`; every locale names the looter first) and answers to the Group boxes. The looter's name follows the item (`LOOT_TOASTS_LOOTED_BY`): in their class color while the roster holds them, silver otherwise. The own-loot parse always goes first, because in zhCN the player's own line also reads as a looter called 你 under the group format. The client prints loot lines only for the player's own party or raid, so nothing else needs filtering out.
- **Winning rolls.** An item won on a roll says how, in silver: `LOOT_TOASTS_LOOTED_BY_ROLL` after a group member's name, `LOOT_TOASTS_WON_ROLL` after the player's own item, the roll itself `LOOT_TOASTS_ROLL_RESULT` over the game's own `NEED` / `GREED` / `ROLL_DISENCHANT`. While a roll is open the client prints each player's roll, then who won, then the winner's loot line; with its roll spam turned down, only a won line carrying the winning roll, then the loot line. `ns.RecordRollLine` (`Features/Loot-Toasts-Winning-Rolls.lua`) keeps each roll by item link and player (`openRolls`) until the won line names the winner, whose roll then waits under player and link (`winningRolls`) for that player's loot line to claim it through `ns.ClaimWinningRoll`. Anything never claimed ages out after `ROLL_RECORD_SECONDS`. The Winning Roll row turns it off per side (`lootToastWinningRollMine`, `lootToastWinningRollGroup`).
- **The cap retires the oldest row**, and Unlimited is stored as `ns.LOOT_TOAST_UNLIMITED` (0), which resolves to `math.huge`: a literal cap of zero would retire every row on sight.
- **Fonts** come from LibSharedMedia-3.0, which GogoLoot ships, so the list is never empty and is masked to faces the client's locale can draw. "Default" follows `GameFontNormal`. The outline flag carries the weight, since the client has no bold.
- **Bag Count** (`lootToastBagCount`, off by default) adds how many the player now carries to their own loot's toasts, as `x3 (27)`, and only when it says more than the toast's own count. `C_Item.GetItemCount` is read as the toast goes up and again on every `BAG_UPDATE_DELAYED` while it is on screen, because the client can print the loot line before the bags take the item or after; reading live lands on the true count in either order, where a single read would sometimes be one loot behind.
- **The anchor** (`GogoLootLootToastAnchor`) is made on first use; its position is account-wide in `ns.db.global.lootToastPosition`. Unlocked, it shows a handle with the two gestures (drag to move, right-click to lock), a Disable button, and one sample row per row the cap allows in random qualities at or above the lowest quality ticked on a Mine rarity row, re-rolled on every appearance change.
- **The introduction.** Turning the toasts on unlocks the stack, and a profile with them on that has never put the handle away is shown it at login (`lootToastsIntroSeen`, per profile, so a new or reset profile meets it too). Right-clicking the handle, its Disable button and the panel's Lock button all count as having met it.
- **Releasing a row always makes progress.** Callers loop until a list shrinks, so `ns.ReleaseLootToast` always removes the frame from `samples` and `active`; only the pooling is guarded, because stopping a fade can fire its own finish handler and release the same frame again.

### Standard Loot Messages

The dropdown beside Enable Loot Toasts (`standardLootMessages`, `ns.STANDARD_LOOT_MESSAGES_DISABLE` by default, or `_ENABLE`) decides whether the toasts take the game's own loot lines out of the General chat tab (`ChatFrame1`): the `LOOT` and `MONEY` message groups, Chat Settings' Item Loot and Money Loot, the two kinds of line the toasts stand in for. `ns.SyncStandardLootMessages` (`Features/Standard-Loot-Messages.lua`) flips them with `ContainsMessageGroup` / `AddMessageGroup` / `RemoveMessageGroup`, as Blizzard's `ToggleChatMessageGroup` does; those methods call `AddChatWindowMessages` / `RemoveChatWindowMessages`, so the client saves the change itself and GogoLoot keeps no copy of the chat settings. Every client ships the same methods (Gethe/wow-ui-source, `Blizzard_ChatFrameBase/Shared/ChatFrame.lua`, checked on the Era, Anniversary and Forever branches), and nothing is touched until the tab reports `isInitialized == 1`, which `FloatingChatFrameMixin` sets on `UPDATE_CHAT_WINDOWS`.

Chat settings are per character, so its marks live in `ns.db.char`: `standardLootMessagesHidden`, the wanted state as last synced, and `lootGroupsHiddenByGogoLoot`, the groups GogoLoot took. **It acts only when the wanted state (toasts on and the dropdown on Disable) differs from the mark.** Hiding takes each group the tab shows and records it; showing gives back only recorded groups, so a player who already kept loot out of General keeps it out. It runs from `ns.SetLootToastsEnabled` (the panel's switch and General's Features section), the dropdown's setter, `ns:ApplyProfile`, and a deferred timer on `PLAYER_ENTERING_WORLD` and `UPDATE_CHAT_WINDOWS`, which only matters on a character's first sync. An ordinary login finds nothing changed, so a box ticked back in Blizzard's window sticks. Prints are unaffected because `print` writes to the frame directly, and the toasts hear `CHAT_MSG_LOOT` and `CHAT_MSG_MONEY` on their own frame.

## The Mini-map Button

Left-click toggles Automated Rolls, right-click Automated Opening (which enforces Auto Loot, forces a scan and repaints its panel), and with Shift held the same clicks toggle Announcements and Automated Master Looting (`CLICK_TOGGLES`, `SHIFT_CLICK_TOGGLES`); Shift + Middle-Click opens the options, checked first, and a plain middle-click does nothing. Each toggle does what its panel switch does and repaints every panel carrying it: its own, the General panel's Features section, and for the last two the master looter pop-up. The tooltip leads with Locked Items while any box waits (a recorded exception; see README-Notes), then the four feature blocks in the order of their clicks (`AddFeatureBlock`): Automated Rolls, with a silver line per group context under its description reading back what it rolls (`MINIMAP_ROLLS_SETTING`, named with the game's own `PARTY` and `RAID`, set in by two spaces; also a recorded exception), Automated Opening (Enabled, Paused or Disabled), Announcements and Automated Master Looting, each with a `MINIMAP_*_DESCRIPTION` of its own, two lines at most, since the panels' descriptions are too long for a tooltip; then the options line. Speedy Loot has no click and no block: it simply stays on, and its switch is in the General panel's Features section (a recorded decision; see README-Notes). The icon reflects Automated Rolls.

## The Features Section

The General panel's Features section gathers every feature's master switch (Speedy Loot, Automated Rolls, Automated Master Looting, Automated Opening, Loot Toasts, Announcements), so the front page shows at a glance what GogoLoot is doing. Each switch is the one on its feature's panel, built by the same function in that panel's file (`ns.AutomatedRollsSwitch`, `ns.AutomatedMasterLootingSwitch`, `ns.AutomatedOpeningSwitch`, `ns.LootToastsSwitch`, `ns.AnnouncementsSwitch`), the way the master looter pop-up shares its rows, so the two can never drift; each caller sets its own order and width. Speedy Loot has no panel, so its switch is built in `Options/Options-General.lua`. `FEATURE_SWITCHES` there lists them in order, keyed by the saved setting each reads, and skips any whose file a flavor's TOC leaves out. Because the same tooltip shows in both places, a switch's `desc` names no position on either panel ("everything below" would be wrong on the General panel).

The switches sit two to a line (`ns.OPTIONS_ROW_WIDTH / 2` each) while every caption fits half a row by `ns.OptionsToggleWidth`, and one to a line when any doesn't, as a longer translation may not. Anything outside the options that flips a switch (the mini-map clicks, the toast handle's Disable button through `ns.SetLootToastsEnabled`) repaints the General panel too.

## The Item List Filter

Every list `ns:BuildItemListOptions` draws (Item Overrides, the Master Looter Ignore List and the Openables List) carries its tools above its items, the parts of Connoisseur's Restocker's line, each line a bare inline group so it keeps its line: adding first (`args.addRow`), then a blank line (`args.spacerAfterAddRow`), then finding (`args.filterRow`). A recorded exception; see README-Notes.

- **The add line**, for a list with `onAdd`, holds the add box: a box reading "Drop item here, or type item ID" (`ITEM_LIST_ADD_PLACEHOLDER`) with an Add button bolted to its right, drawn by `GogoLoot_ItemListAdd` (`ns.ITEM_LIST_ADD_WIDGET_TYPE`). The button, Enter, and an item dropped on the box all fire `OnEnterPressed` with what to add, which AceConfigDialog hands to the entry's `set`, so adding never depends on knowing to press Enter. The add box's entry is named `ITEM_LIST_ADD` for its tooltip's title and draws no label. Beside it sits **Add from Bags**, a dropdown of what the player carries that the list doesn't hold yet (`GetAddableBagItems`): one choice per distinct item, A to Z by name, each with its icon, link and the count across every slot, read afresh on every repaint. The list's `canAdd`, where it has one (the Openables List's `ns:CanAddOpeningItem`), leaves out what it would refuse. It rests on its own first choice, a silver caption that adds nothing when picked; with nothing to offer, that caption reads `ITEM_LIST_BAGS_EMPTY` and the dropdown greys out.
- **New.** What the player adds through either, while it is on the list, leads it under a New header (`ITEM_LIST_NEW`), newest first, taken out of its kind's section (`newListItems`, per list and per session). Filtering that list, by text (`SetListFilter`) or by kind, ends it, and so does closing the Options window: `Options.lua` hooks `SettingsPanel`'s OnHide, which all three clients ship, to `ns.ForgetNewListItems`. The kind filter's choices are read before New is pulled out, so they still name every kind on the list.
- **The filter line** holds the filter, a magnifying glass and a box reading "Filter items..." (`ITEM_LIST_FILTER_PLACEHOLDER`) drawn by the `GogoLoot_ItemListFilter` AceGUI widget (`ns.ITEM_LIST_FILTER_WIDGET_TYPE`), and beside it the kind filter.

Both boxes take `ns.OPTIONS_ITEM_LIST_TOOL_WIDTH` (the label column), and the add box starts where the filter's box does, clear of the magnifying glass (`FILTER_BOX_LEFT`), so the two stack in one column; the two dropdowns take the control column (`ns.OPTIONS_CONTROL_WIDTH`), where every panel's dropdowns sit. Restore Defaults closes the list, right-aligned at `ns.OPTIONS_RESTORE_BUTTON_WIDTH` below the last row, one shared label (`ITEM_LIST_RESTORE`) with each list's own tooltip and confirmation. Both hints are `GameFontDisableSmall`, anchored at both ends and kept to one line, so a translation that outgrows its box ends inside it. A list built through the shared builder has the lines with nothing to opt into.

- **What matches.** A row shows when the typed text, trimmed, appears in its item name, its item ID, or its setting as the dropdown reads it, so "need" or "ignore" finds those rows. Matching is case-insensitive through `ns.FoldCase` (`Options/Options-Utilities-Item-List-Filter.lua`), which folds Latin-1 and Cyrillic capitals as well as ASCII, since `string.lower` knows ASCII only and a ruRU player types in lower case. With nothing matching, the list says so (`ITEM_LIST_NO_MATCHES`).
- **The text is per list and per session**, kept in `listFilters` by registry name and never saved.
- **The kind filter** narrows the rows to one kind of item: Show All Kinds of Items (`ITEM_LIST_KIND_ALL`, whose words say it is a filter), then every header the list carries (Item Kind Sections) in the same A to Z order, and picking one shows that section alone, header and all. The choices are built with the list and keyed by the header's text, so they need no translating and follow the list as items come and go. Per list and per session like the filter text (`listKindFilters`), and it works alongside it. A kind that leaves the list, its last row removed or restored away, puts the list back on Show All Kinds of Items and is forgotten, so an item of that kind added later doesn't narrow the list unasked. A picked kind always has rows, so only the filter's text brings up the no-match line.
- **It filters as the player types.** A stock AceGUI EditBox only reports Enter, so the widget writes the list's filter itself and asks for a redraw once typing pauses (`FILTER_REFRESH_DELAY`, 0.3 s); Enter applies at once through the entry's `set`, and the clear button empties it at once.
- **The keyboard survives the redraw.** A redraw replaces every widget on the panel, the box included. A box that loses the keyboard while its frame is hidden (a release, not the player leaving) opens a one-second handover (`FILTER_FOCUS_HANDOVER_SECONDS`), and the box the redraw builds for the same list takes the keyboard and the cursor back when it shows. AceConfigDialog passes the entry's `arg` (`{ registryName }`) to the widget's `SetCustomData` after `SetText`, which is how the new box knows it is the same list's. The handover also covers a redraw somebody else asked for, such as the item cache filling in names mid-word.

## Item Kind Sections

The same three lists group their rows under the kind of item, as plain headers (`ns.OptionsHeader`) rather than bordered boxes, so a row keeps its full width. A recorded exception; see README-Notes. The header is the item's class from `C_Item.GetItemInfoInstant` ("Miscellaneous", "Container", "Quest"), never its subclass, which rarely helps and splits a few rows into headers of their own. An item bound as a quest item (`C_Item.GetItemInfo`'s bind type `ns.BIND_QUEST_ITEM`, the tooltip's "Quest Item") sits under the client's own Quest class name whatever its class, as Soft-shelled Clam (class Key) does; until the item loads it sits under its class and moves on the repaint that follows. The client names it in the player's language, so there is nothing to translate. Headers run A to Z by that text, and the rows keep their name order under each.

- **No server question.** The instant call reads the client's own item table, so a row whose name is still `Loading...` already sits under its kind. The rare row the client can't type goes above the first header, under none.
- **The filter works per section.** A section left with no matching rows loses its header too, and the no-match line only shows when every section is empty.
- **Spacing is the panels' usual.** Each header gets a spacer above and below, as on every other panel, except that the first header needs none above: `spacerBeforeItems` is already there.
- **Every row is one line.** The item-link widget sets `SetWordWrap(false)`, so a name too long for its column ends in "..." beside its icon. Wrapped, the icon would stay on the first line and the whole link drop to the second. The hover tooltip shows the full name.

## Diagnostics

The `Diagnostics/` folder is environment probing and state capture for bug reports, not a test runner. Its framework (the runner, the panel, the event buffer, every builder) is copied from Magic Eraser's `Diagnostics/` folder, per the Style Guide; what is GogoLoot's own is `Manifests.lua`, the Settings tab's report list in `Report-Runner.lua`, its probes' strings in `Diagnostics-Core.lua`, the message-id allowlist in `Event-Log.lua`, the toast anchor in Display Context, the loaded flag in Other Add-ons, and Validate Data's `spell` and `other` kinds, which the reference lacks. It is built to be safe by construction:

- **Runtime-only state.** `ns.diagnostics` is a plain namespace table, never a SavedVariable. It starts off every session and persists nothing at logout. A single Enable toggle gates the whole panel. While it is off the four tabs are left out of the options table rather than hidden (a hidden tab still draws an empty bordered frame), so the panel is registered as its builder function and rebuilds on every repaint. Turning it off stops the event log and any run, and clears every report.
- **Read-only, on demand.** Reports build only on a button press, never on load or panel open. Every probe is an existence or shape check or a live read with no side effects. The one exception is the Taint Log button, which sets the `taintLog` CVar (`ns:SetTaintLog`).
- **Not localized.** Diagnostics strings live in `ns.DiagnosticsStrings` as plain English, in the diagnostics files only. The one exception is the add-on's own display name, read from `L["ADDON_TITLE"]`.
- **Four tabs.** **Run Tests** holds the live tools: the Event Log, the Taint Log, and boxes pointing at the game's own tools (`/etrace`, `/console scriptErrors 1`) and Funkeh's Bug Grabber and Bug Sack. **Settings** (Loot Method, Locked Boxes, Gear Stats, Player & Spells, Relevant CVars, Saved Variables, Display Context, Other Add-ons), **Code** (Event Registration, API Endpoints, Library Versions) and **Data** (one Validate Data row per data file) each have a Run All, a row per report with its last state, and one output box: the report header once, then a `---- Title ----` block per report. Reports and tabs come from `ns.DIAGNOSTIC_REPORTS` and `ns.DIAGNOSTIC_SECTIONS`. The runner runs one report at a time, a frame apart, and one run at a time; Stop keeps what finished, and a report that throws is written into the box as an error while the run goes on.
- **Report header** opens every report with the client, build, locale, `ns.FLAVOR` (marked Season of Discovery where it applies) and `ns.DATA_FOLDER`, never `WOW_PROJECT_ID`, which reads the same on Forever and Retail.
- **Event Registration** reads `ns.EVENT_NAMES` (Core's exported list), so it can never drift from the events the add-on actually uses. It registers then immediately unregisters each event on its own probe frame with no handler, and reports both `C_EventUtils.IsEventValid` and whether `RegisterEvent` succeeds.
- **API Endpoints** (`ns.DIAGNOSTIC_API_CHECKS`) lists every modern and legacy API GogoLoot guards against, separately, so a report shows exactly what a given client provides. Keep it aligned with the guards in the feature files. Validate Data adds a row for each extra reader its kinds call.
- **Loot Method** prints the raw returns of both loot-method APIs, the `Enum.LootMethod` table, GogoLoot's own interpretation (`SafeGetLootMethod`, `SafeGetLootThreshold`, `AreWeMasterLooter`, `WillAutoMasterLoot`), and closes with two `constant -> id on this client` blocks, master-loot errors and then trade results, resolved in a single `ns:ResolveGameMessageIds` walk over both exported tables. It is the only output that shows whether a constant resolved on this flavor: `NOT FOUND` there *is* the failure, and the shared scan count is what separates "resolved nothing" from "no message table to resolve against."
- **Gear Stats** lists the armor and weapons in the bags and on the character with every stat `ns.ReadCharacterRuleStats` finds, the source that saw each (`ITEM`, `EQUIP_TABLE`, `SUFFIX_TABLE`, `TOOLTIP`), and whether this character's rules leave it to the player. It is the report for "Character Rules rolled on something it shouldn't have."
- **Locked Boxes, Player & Spells, Relevant CVars, Display Context, Other Add-ons.** Locked Boxes lists every openable item in the bags with its data default, its action (nil for one the player removed), the `ns.IsItemLocked` verdict and the scan tooltip's line count: "not locked" with zero lines means the tooltip read nothing. Player & Spells lists class and level, each spell in `ns.DIAGNOSTIC_SPELLS` with its name and `IsPlayerSpell`, the Lockpicking skill line's name, and the Lockpicking rank as the tooltip reads it (always unavailable on Forever). The CVars report reads `autoLootDefault` raw and as GogoLoot reads it, plus `taintLog`. Display Context gives the screen size, UI scale, the mini-map button's saved position, and the saved and live loot-toast anchor, reading the anchor through `ns.GetLootToastAnchorFrame`, which never creates it. Other Add-ons shows whether each add-on is loaded, which spots Open Sesame still running alongside.
- **Validate Data** builds one Data-tab row per entry in `ns.DIAGNOSTIC_DATA_SOURCES`, one per flavor-folder file (`Default-Item-Lists`, `Lockbox-Skill-Levels`, `Openable-Items`, `Game-IDs`, `Item-Stats`, `Spells`), titled by the file this client loaded (`ns.DataSourceFileName`). Each source names its table by its key on `ns`, with its kind (`item`, `spell` or `other`), a `rowId(key, row)` that reaches the ID over the table's pairs (the tables come in several shapes: rows of `{ itemId, ... }`, maps keyed by item ID, and maps keyed by name), and `dataColumns` carrying the shipped row's own values as `DATA_*` columns. The export is TSV, one block per kind. An item row carries every `C_Item.GetItemInfo` and `C_Item.GetItemInfoInstant` return, every item reader the clients ship, the item's spell with its readers and tooltip, the level, class and stat reads, and the whole tooltip in one cell (through `ns.GetTooltipLines`); a spell row carries `C_Spell.GetSpellInfo`'s fields, its description, the spell readers, `IsPlayerSpell`, `IsSpellKnown` and its tooltip. A `STATUS` column opens every row: `OK`, `NOT ON CLIENT`, `INCOMPLETE`, `ERROR` or `TABLE MISSING`. Ids run in batches of 100, polled until each settles, and stragglers settle as flagged rows rather than waiting forever; the row's note shows the tallies (`Done: 1,207 OK, 15 INCOMPLETE`). Run it on each client with a TOC: a `NOT ON CLIENT` row is a row in the wrong flavor folder.
- **Saved Variables** prints every row of `GogoLootDB` (named by `ns.SAVED_VARIABLES_NAME`), item lists included: the per-item roll overrides and ignore entries *are* the configuration a loot bug report needs.

Stop halts the event log and keeps the buffer, so start, reproduce, stop, show returns a real report; Start replaces it. The event log (`ns:LogEvent`) snapshots arguments to strings immediately (never retaining frame or table references), caps 8 args at 255 bytes each, and escapes pipes (`|` to `||`) **after** the length cut, so a loot line shows its item link verbatim in the report box instead of rendering as a clickable swatch or collapsing to a stray `[Sc`. `ns.DIAGNOSTIC_EVENT_EXCLUDE` is deliberately empty: whole-event drops are the wrong tool for events that are ever signal, and the dispatcher only ever hands the log events GogoLoot itself registered. The two genuine firehoses, `UI_ERROR_MESSAGE` and `UI_INFO_MESSAGE`, are named in `ns.MESSAGE_ID_FILTERED_EVENTS` and filtered by **message id** instead: the client raises them for every red combat error and yellow info line, which would bury the 500-entry buffer in "Ability is not ready yet." and evict the loot signal. Ids the add-on correlates (the loot-error and trade-result sets, resolved through `ns:ResolveGameMessageIds` exactly like the live handlers, and the inventory-full id through `ns.IsBagFullErrorID`, Automated Opening's own test) log as normal lines; everything else is counted per id and rendered as a `Suppressed uncorrelated traffic` block at the bottom of the report (event, id, first-seen text and count, biggest offender first), so the report still shows what was spamming without listing it. An event carrying no numeric id at all logs verbatim: unclassifiable is signal. The log can hold loot and money chat lines, so its intro tells the player to review it before sharing.

## Tests

```
lua Tests/Run.lua
```

Run from the add-on folder, with the system Lua: no WoW client, no libraries. **`Tests/` is deliberately absent from the TOC and the zip**: per the Style Guide, real logic tests live in the dev toolchain, never in the shipped Diagnostics panel, so these files never load in game. For what a human has to verify in the client, see [README-Testing.md](https://github.com/Gogo1951/GogoLoot/blob/main/README-Testing.md).

`Tests/Fakes/WoW.lua` stubs the WoW and Ace surface: `GiveMasterLoot` (recording every call and firing the `hooksecurefunc` hook), loot slots with their types and sources, master-loot candidates, `GetGameMessageInfo`, chat output and chat frames, bags (items, links, a lock per slot) and `UseContainerItem`, a `GameTooltipTemplate` tooltip whose lines are published by name and whose `SetBagItem` runs method post-hooks, `LootFrame` with its `OnShow` hook, the interaction windows, sounds, the client's loot, roll and money format strings, LibSharedMedia, and an AceDB fake that copies defaults the way the real library does, keeps `char` sections, and keeps its profile callbacks so a test can fire them.

Two deliberate choices in the fake:

- **Namespaced APIs are concrete, not catch-all stubs.** A permissive stub returns a table where the client returns a string or nil, which manufactures type errors the real client never raises. A false failure costs more than the unstubbed global it saves. Frames answer unknown **method** names (PascalCase) with a no-op and any other key with nil, as a real widget does, so a plain field like a pooled flag never reads as set.
- **Timers are collected, not run.** `Fake.advance(env, seconds)` moves a virtual clock and fires what is due, so the suite asserts on timer-driven behaviour (the silent-failure fallback, the batch flush) without sleeping and without flaking. A callback which schedules another timer needs a second `advance`: the fallback arms the batch flush, so a silent-failure test advances twice.

`Tests/Run.lua` loads the add-on's files in `GogoLoot_Vanilla.toc` order (the fake reports the Vanilla flavor), fires `ADDON_LOADED`, and runs every test in one file, grouped by feature under the same section dividers the code uses: load and saved variables, the migrations, master-loot hand-outs and destinations, every options panel's order and gating, rolls and the cold-item race, Character Rules, the merged Open Sesame features, Loot Toasts and Standard Loot Messages, the roll and loot line parsers, Diagnostics, every data folder's tables and invariants, and every flavor TOC matching the Vanilla TOC but for its own fields and data folder. A `nil`-call regression in `OnAddonLoaded`, the kind that takes the whole add-on down, fails at the first test.

## Saved Variables

`GogoLootDB` is the add-on's one SavedVariables table: an AceDB-3.0 database (`ns.db`) created in `Features/Core.lua` on a name-guarded `ADDON_LOADED`. AceDB keeps every profile in `GogoLootDB.profiles`, each character's profile choice in `profileKeys`, account-wide state in `global`, and one section per character in `char`.

GogoLoot uses the **Simple** saved-variables model (Style Guide → SAVED VARIABLES → The Two Models): `AceDB:New`'s third argument is `true`, so every character lands on the one shared `"Default"` profile. **Reset Profile therefore clears the loot policy back to install defaults** and leaves `global` and every character's `char` section untouched. Profiles are managed on the Profiles options panel (AceDBOptions-3.0), letting a player keep separate loot rules per context (guild raid vs. PUG) and switch at will.

The scope a setting belongs in is decided by what it is about:

| Scope | Holds | Why it lives there |
|---|---|---|
| `profile` | Loot policy: every feature's switch and settings, the item lists, Loot Destinations, the toast filters and look | It is what a second profile is for |
| `global` | Presentation and client state (`showWelcome`, `speedyLoot`, `minimap`) and two records the player built (`openingActions`, `lootToastPosition`) | A profile switch, copy, reset or delete must never move the button, re-enable Speedy Loot, bring the welcome back, or undo a hand-built list |
| `char` | State about the character: `characterRules` and `classFile` (Character Rules), and the chat-tab marks `standardLootMessagesHidden` and `lootGroupsHiddenByGogoLoot` (Standard Loot Messages) | Characters share the one profile, so per-character state can't live there; chat settings are per character in the client too |

A new setting belongs in `profile` unless it is presentation or client state (`global`) or about the character itself (`char`). The full key list is `ns.DATABASE_DEFAULTS` in `Data/Default-Settings.lua`; `characterRules` and `classFile` have no defaults, since an absent rules table is "no rules" and the class is written at every login. A few keys don't say what they hold, because renaming saved data needs a migration:

- `autoGreed` is the Automated Rolls master switch, from before Pass and Need were configurable.
- `lootNotifications` is Enable Announcements, from the panel's earlier name.
- `ignoredItemsSolo` is Item Overrides (item ID to roll action); `ignoredItemsMaster` is the Master Looter Ignore List (item ID to `true`).
- `destinations` maps a quality key to `"self"` or a normalized (realm-stripped, lowercased) player name, the whole `first last` name on WoW Forever.
- `openingActions` holds only the player's changes to the Openables List, never a default.
- `lootToastMaxVisible` stores Unlimited as 0.
- `autoOpenWhere` and `autoOpenGroup` keep the strings (`OUTSIDE_INSTANCES`, `SOLO_ONLY`) the dropdowns they replaced wrote, so the sub-toggles needed no migration.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed, and explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables.

Empty item lists are deliberately re-seeded from this client's defaults (`RebuildEmptyItemLists` in `Features/Core.lua`) on load and on every profile change, copy or reset: an empty list is treated as "never configured". The default rows (`ns.DEFAULT_IGNORE_LIST_SOLO`, `ns.DEFAULT_IGNORE_LIST_MASTER`) live in `Data/{Folder}/Default-Item-Lists-{Folder}.lua`, and a row whose item this client lacks (`C_Item.DoesItemExistByID`) is never seeded. This is the only place the add-on re-seeds saved values, and it only fills empty item lists; it never overrides explicit user values. The Openables List needs no seeding at all: its defaults are read from the data on every lookup.

### Migration Chain

Each migration runs in `OnAddonLoaded`, right after `AceDB:New`, and is tagged `MIGRATION (remove after YYYY-MM-DD)`. The two touch disjoint keys, so their order doesn't matter.

1. `MigrateOptionsRework` (remove after 2026-10-28): nils `global.showDestinationTiers`, and maps the Openables List's retired choices (`UNLOCKED`, `IGNORE_RAID`, `IGNORE_UNIQUE`) onto Open and Ignore, dropping any that land on the item's default.
2. `MigrateLootToastProfiles` (remove after 2026-11-03): walks every saved profile and turns the old toast filters (one minimum quality, the Always Show kinds, Whose Loot's Whole Group) into the Mine and Group rows, then nils the retired keys and `autoRollReport`.

### Applying a Profile

`ns:ApplyProfile` is wired to `OnProfileChanged`, `OnProfileCopied` and `OnProfileReset`. The new profile's tables replace the old ones wholesale, so everything that caches or displays profile state is repainted there: the item lists re-seed if empty, Auto Loot is enforced if the new profile opens containers, the opening queue is rebuilt under the new profile's rules, the toasts take the new profile's look and its introduction if it is owed one, the mini-map icon re-reads `autoGreed`, the General tab's loot lines follow a changed Loot Toasts setting, the trade checkbox re-reads `announceTrade`, and every panel in `ns.OPTIONS_REGISTRY` gets a `NotifyChange`.

Auto Loot is deliberately *not* a saved setting of its own. `ns.EnsureAutoLoot` (`Features/Auto-Loot.lua`) enforces the `autoLootDefault` CVar while Speedy Loot or Automated Opening is enabled (`ns:IsAutoLootNeeded`), because neither can function without it; their two toggles are therefore the opt-out the Style Guide requires for an enforced CVar write. It writes only when the CVar is actually off, always announces itself through `PrintMessage` (`MESSAGE_AUTO_LOOT_REQUIRED`), and runs at login when either is on, whenever either is switched on (panel or mini-map), and on a profile switch that brings Automated Opening with it. The rolls, master-loot and trade-announcement paths never touch the CVar.

## Adding a New Announcement

1. Add a `MESSAGE_*` key to `Locales/enUS.lua`: a clean body with `%s` placeholders, no marker or add-on name.
2. Call `ns:Announce(channel, whisperTarget, "MESSAGE_YOUR_KEY", ...)`. Use `ns:GetGroupChatChannel()` for group output and handle its nil return when solo.
3. If the body can carry multiple item links, build it as a parts list and send it through `ns:AnnounceParts` in `Features/Announcements.lua`, since a single message caps at 255 **bytes** (Style Guide → MESSAGES → Message Length).
4. Check the rendered length in the widest-encoding locale. The ceiling is measured in bytes, so the overflow canary is ruRU (Cyrillic encodes two bytes per character), not German.

## Adding a New Options Panel

1. Create `Options/Options-<Name>.lua` exposing `ns.Build<Name>Options()` that returns an AceConfig group table, using the `ns.OptionsHeader` / `OptionsDesc` / `OptionsSpacer` / `OptionsRowLabel` helpers and a `TAB_*` locale key for its `name`.
2. Add a registry name to `ns.OPTIONS_REGISTRY` in `Data/Data.lua`, derived from `ADDON_NAME`, never localized; cross-module `NotifyChange` callers reference it by exact string.
3. Add a row to `FEATURE_PANELS` in `Options/Options.lua`, in the place the panel should appear: `{ key, builder, title }`, plus `parent = "<key>"` for a panel that belongs under another, and `onRegistered` for a hook that needs the registered frame (Character Rules uses it). The registrar registers the builder function (never a built table, so `NotifyChange` can redraw rows that didn't exist at login) and calls `AddToBlizOptions` in table order, which is the order of the settings tree. A first-level panel passes `L["ADDON_TITLE"]` as its parent; a child passes its parent's **captured category ID**, never a title, since nothing keeps titles unique. A parent is always listed before its children. With `ns.OPTIONS_NESTED_PANELS` off, a child registers under the add-on instead, right after its parent, titled `L["TAB_NESTED_FORMAT"]` ("Parent: Child"). Profiles and Diagnostic Tools stay last.
4. Add the file to every flavor TOC (`GogoLoot_Vanilla.toc`, `GogoLoot_TBC.toc`, `GogoLoot_Camelot.toc`, `GogoLoot_Mists.toc`, `GogoLoot_Mainline.toc`) after `Options/Options-General.lua` and before `Options/Options-Profiles.lua`, in panel order.
5. Lay controls out as label-beside-control rows: an `ns.OptionsRowLabel` at `ns.OPTIONS_LABEL_WIDTH` followed by a control with `name = ""` at `ns.OPTIONS_CONTROL_WIDTH`, so every row on every panel shares one right edge (`ns.OPTIONS_ROW_WIDTH`). `ns.OptionsSelectRow(order, hidden, caption, control)` builds one inside a row group of its own (`ns.OptionsRow`), which always takes a line to itself.
6. Give a toggle what belongs to it through the toggle-row helpers (see Toggle Rows below): its one setting, or a sound's speaker, on its own line through `ns.OptionsToggleRow`; an on/off choice under it through `ns.OptionsSubToggleRow`; a captioned setting under it through `ns.OptionsSubSelectRow`. Hide every sub-row, and every spacer between them, on the parent's state.
7. A child panel keeps only its own gates: never hide its content behind its parent's switch, or it opens onto a blank page. Give it `ns.AddFeatureOffNote` instead, so it says when its parent is off.
8. Open the panel on its description and then its master switch. Build the switch with a shared function (like `ns.AutomatedRollsSwitch`) and add it to `FEATURE_SWITCHES` in `Options/Options-General.lua`, so the Features section carries it too.
9. Write the description to the house pattern: start with a verb and say what the feature does for the player; a second sentence only for what the panel can't show (a safety rule, a requirement, a limit). Options lists, legends and tips go in tooltips.

### Toggle Rows

A toggle carries what belongs to it the way Connoisseur's panels do (a recorded exception; see README-Notes), and the two add-ons should stay in step, except for the speaker, which follows Control Freak:

- **One setting of its own rides on the toggle's line**, in the control column: `ns.OptionsToggleRow(order, toggle, { control = ... })`. The setting has no caption, since the toggle names it, and leaves the line while the toggle is off (its `hidden` reads the toggle's own `get`). The toggle takes the label column, so the line ends on the shared right edge. Examples: the announce threshold, trade's When, the loot sound's minimum quality, Loot Toasts' Standard Loot Messages, and each lockbox feature's scope.
- **A sound toggle carries a speaker after its setting, past the end of the row** (`extras.preview`, built by `ns.OptionsSoundPreview`): an `execute` with an 18-pixel image, which AceGUI draws as a bare icon, with its label in the tooltip, `ns.OPTIONS_SPEAKER_WIDTH` (0.15) wide. It sits in the right margin, the one cell allowed past `ns.OPTIONS_ROW_WIDTH`: taking its room out of the label would push the sound's dropdown out of the column every other dropdown lines up in. A sound with no setting (Pick Pocket) gets a blank cell of `ns.OPTIONS_CONTROL_WIDTH` in the setting's place, so its speaker lands in the same column. The speaker leaves with the setting while the toggle is off.
- **Anything else it owns sits on an indented sub-row under it** and leaves the panel while it is off: an on/off choice through `ns.OptionsSubToggleRow(order, hidden, toggle)`, a captioned setting through `ns.OptionsSubSelectRow`, anything else through `ns.OptionsSubRow`.

**A caption and its setting share the line only while the caption fits.** AceGUI draws a checkbox caption on one 18-pixel line and cuts a longer one short with "...", and a German or French caption can run half as long again as the English. `ns.OptionsToggleWidth` measures the caption as the panel is built, on a hidden `GameFontHighlight` font string: the 24-pixel box, the text and 12 pixels of slack, over `ns.OPTIONS_PIXELS_PER_WIDTH_UNIT` (170). A caption that won't fit takes the whole line, and its setting drops into a nameless inline group of its own below it, behind a label-column filler, so it still lands in the control column. The group matters: a group always starts a new line, where a filler left to wrap on its own could stay beside a long caption on a wide panel and push the control to the left edge.

### Sub-options

`ns.OptionsSubRow(order, hidden, controls)` wraps a row in a nameless inline group and leads it with a blank description cell of `ns.OPTIONS_SUB_INDENT_WIDTH`. **The indent must be a cell, not padding on the caption**: AceConfig pins a checkbox at the left edge of its own widget, so a padded label moves the words and leaves the box lined up with its parent's. One indent everywhere: a sub-option's box starts where its parent's box visually ends.

A sub-option row still owes the panel its shared right edge, so an indented label-beside-control row **narrows its label to pay for its indent** rather than pushing everything right. That is `ns.OPTIONS_SUB_LABEL_WIDTH` (`ns.OPTIONS_LABEL_WIDTH` minus the indent), and `ns.OptionsSubSelectRow(order, hidden, caption, control)` builds the common case: a silver caption and a dropdown (or slider) at `ns.OPTIONS_CONTROL_WIDTH`, so every dropdown on every panel, sub-option or not, sits in one column. A sub-option checkbox takes `ns.OPTIONS_SUB_TOGGLE_WIDTH`, one label column, with room to spare. A row with a third cell pays for it out of its label, sub-option or not: the Automated Rolls rows give their captions up for the action dropdown, and the Loot Toasts position row splits the control column and part of the label column between its two buttons.

Sub-toggles stack directly under their parent; a spacer separates a block of dropdown rows, as for the Master Looter panel's quality rows and in the Loot Toasts Stack and Text sections.

**Sections instead of sub-options.** Loot Toasts owns too many rows to indent under its toggle, so they sit at the panel's own level: the position buttons in an `ns.OptionsRow` straight under the switch, then two headers, Stack and Text, over `ns.OptionsSelectRow` dropdowns with ordinary white captions (Font Size among them, its steps `ns.LOOT_TOAST_FONT_SIZES` plus any size saved between them). The Filters grid is a child panel of its own (`Options/Options-Loot-Toast-Filters.lua`: `FilterRow`, then `ToastTextRow` for Bag Count and Winning Roll in the same columns), which says in red while Loot Toasts is off (`LOOT_TOASTS_OFF_NOTE`) and never hides behind it. The headers carry the grouping the indent would have. Every row still belongs to the toggle and leaves the panel with it (next section). A recorded decision; see README-Notes.

**Nothing that belongs to a toggle stays behind while it is off.** A setting configures something that is not happening, so it hides rather than greying out, and so does every spacer between the toggle's rows, or the panel trails a column of blank lines. Explanations never sit on the panel as extra rows: each control carries its label and one `desc` tooltip (Style Guide → OPTIONS PANEL → Helper Text Lives in the Tooltip), so the manual-distribution rule and the quest-item caveats live in the tooltip of the control they belong to. The one exception is the message examples, on the Announcements panel, under Automated Rolls' Roll Messages and under Enable Ignore Notifications, which sit under their toggles and stay there while a toggle is off, because they are what a player reads to decide whether to turn it on (a recorded exception; see README-Notes).

### Hiding a panel behind its master switch

Every feature panel opens the same way: its title, a one- or two-sentence description, then its master switch. What the switch tunes hides while it is off, spacers included; a section that works without it stays. In each case the switch really is a master switch (`ns:WillAutoMasterLoot` returns false outright without `autoMasterLoot`, `autoGreed` gates every roll including Item Overrides, and `ns:Announce` sends nothing without `lootNotifications`), so what is below it changes nothing, and a page of greyed controls says that at far greater length than an absence. It also means a hidden control has no use for a `disabled` state, and carrying one would be dead logic.

| Panel | Leaves with the switch | Stays |
|---|---|---|
| Automated Rolls | the Loot Thresholds and Roll Messages headers, the In Party and In Raid rows with their quality rows, Print Item in Chat with its example, Hide Roll Messages with the winner summary dropdown and its example | |
| Master Looter | its two on/off choices, Loot Destinations | Group Loot Settings and the pop-up switch: the group's settings, and a pop-up that opens with automation off too |
| Automated Opening | its two hold-offs, Enable Ignore Notifications with its example | |
| Loot Toasts | the Standard Loot Messages dropdown, the position buttons, Stack and Text | |
| Announcements | everything | |

Loot Toasts and Announcements get the guarantee through one `Add` in the builder, which hands out the next order and the switch's gate together (on top of any gate the row has of its own), so no row, header or spacer can be added without it. Loot Sounds, which plays with no toast on screen, is a panel of its own after Loot Toasts. The Master Looter panel hides its automation rows through `HideWhenAutomationOff`, which **composes** with whatever a row already answered to rather than replacing it (a quality row below the loot threshold, a threshold row under Free for All), so the master switch is an additional reason to hide, never a substitute for theirs.

**A child panel never hides behind its parent's switch**, or it would open onto a blank page. It says so instead: `ns.AddFeatureOffNote` puts one line under its description, in the Off red, while the parent is off (`ROLLS_OFF_NOTE` on Item Overrides and Character Rules, `MASTER_LOOTER_OFF_NOTE` on the Ignore List, `OPENABLE_ITEMS_OFF_NOTE` on the Openables List, which also says Ignore still reaches Speedy Loot, and `LOOT_TOASTS_OFF_NOTE` on Filters). The whole line takes the one color so each sentence stays one string in every locale.

The group wrapper is load-bearing. Laid out flat, an indent cell and its control are just two more widgets in the panel's flow, held together only by their widths happening to fill the line; the next pair then packs into whatever is left and its indent stops indenting anything. A fill-width group always takes a line of its own, so one group pins one row. For the same reason the controls inside need slack rather than an exact fit: a row summing to the full pane width sits on the wrap boundary, where a measuring pass can tip the control onto its own line and strand the indent above it. Put `hidden` on the group, never on the control inside it, or the indent cell stays behind as a blank line.

`ns.OptionsSubLabel` colors the caption `HELP` silver against the parent's white, so the row reads as subordinate rather than merely shifted, and stays clear of the dimmer gray AceGUI paints a genuinely disabled label. Magic Eraser sizes its Auto-Vend sub-options the same way; the two add-ons should stay in step.

## Adding a New Registered Event

1. Register the handler with `ns:RegisterModuleEvent(eventName, handler)` from the owning module, never `frame:RegisterEvent` directly. A unit event takes the unit as a third argument, and every handler on that event must ask for the same one.
2. Add the event name to `ns.EVENT_NAMES` in `Features/Core.lua`, keeping the list alphabetical. Skipping this prints a one-time developer warning and leaves the event out of the Diagnostics Event Registration probe. An event some client lacks needs no guard of its own: the dispatcher skips it there.
3. If the handler must ever unregister, do it from a timer or user path, because `ns:UnregisterModuleEvent` is unsafe to call while `OnEvent` is iterating handlers. Prefer a named timer (`ns:After` / `ns:CancelTimer`) over a guard flag: rescheduling an identifier replaces the pending timer, so the call site needs no self-cancel token of its own.

## Adding a New Default List Item

1. Add the row to `ns.DEFAULT_IGNORE_LIST_SOLO` as `{ itemId, rollAction }` (`ns.MANUAL` / `ns.GREED` / `ns.NEED` / `ns.PASS`), or to `ns.DEFAULT_IGNORE_LIST_MASTER` as `{ itemId }`, in `Data/{Folder}/Default-Item-Lists-{Folder}.lua` for every flavor folder where the item exists, with a trailing comment naming the item.
2. Report which folders you changed, which you left, and why (Style Guide → DATA → Flavor Folders). Run Diagnostic Tools → Validate Data on each client with a TOC to confirm the rows exist there.
3. Existing users do **not** receive new defaults automatically: saved lists are rebuilt only when empty (`RebuildEmptyItemLists`) or through the Restore Defaults button. Mention new defaults in release notes.
4. If an established profile genuinely has to pick the entry up, that needs a one-off migration, not a change to the seeding rule: a marker key absent from the defaults table, separate added-versus-repointed lists so a choice the player already made is never overwritten, target actions read back out of the default list, and it runs after `RebuildEmptyItemLists`. Tag it `MIGRATION (remove after YYYY-MM-DD)`, 30 days past the release that ships it (Style Guide → SAVED VARIABLES → Migration Windows).

### Openable Items and Lockboxes

1. A container goes in `ns.OPENABLE_ITEMS` as `[itemId] = ns.OPENING_OPEN, -- Name`, in `Data/{Folder}/Openable-Items-{Folder}.lua` for every folder whose client flags it Openable (see Openable Items Data). Its value is the row's default, reason included: `ns.OPENING_UNLOCKED` for an item with a lock, `ns.OPENING_IGNORE_RAID`, `ns.OPENING_IGNORE_UNIQUE` or `ns.OPENING_IGNORE` for a container worth keeping sealed, `ns.OPENING_OPEN` otherwise. Changing a row's status is changing that one value.
2. A lockbox also gets `[itemId] = skill` in `Lockbox-Skill-Levels-{Folder}.lua`, from the client's `Lock` table. **Every skill row must be an `OPENING_UNLOCKED` row**; a test holds every folder to it.
3. Unlike Item Overrides and the Master Looter Ignore List, these defaults **do** reach existing players: only a player's changes are saved, so a new row, or a row moved to Ignore, applies to everyone who hasn't set that item. Still mention it in the release notes.
4. Each data file explains its table in a `How We Got the Data` block at the end of the file (Style Guide → DATA → Data File Layout), which only the Data Validation & Cleanup pass edits.

## Adding a New Character Rules Stat

1. Add a row to `ns.CHARACTER_RULE_STATS` in `Data/Data.lua`: its `key`, its `group` (`PRIMARY` or `SECONDARY`), a `bit` no other stat has ever used, its `label` from the client's `ITEM_MOD_*_SHORT` global, and the `itemMods` keys `GetItemStats` reports it under. A primary stat's place in the list is its place on the panel; secondary stats sort themselves.
2. The tooltip reader picks the stat up through the full `ITEM_MOD_*` format behind each `itemMods` key, with nothing else to add.
3. Where Classic Era or TBC carries the stat as an "Equip:" spell or a random-suffix enchantment, the generated `Item-Stats` tables need regenerating to set its bit; that belongs to the Data Validation & Cleanup pass, since those files are generated, never hand-edited.
4. Run Diagnostic Tools → Gear Stats on each client with a TOC, wearing or carrying gear with the stat, and check every source that should see it does.

## Localization

Every user-facing string goes through `L["KEY"]`. `ns.L` is bound once at the top of `Data/Data.lua` (`LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)`) and every other file reads it from the namespace.

- **`enUS.lua` is the source of truth** and the only file that passes the `true` default-fallback flag to `NewLocale("GogoLoot", "enUS", true)`. All eleven WoW locales ship, and every other locale translates the `enUS` key set. Those files belong to the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`); never hand-edit them during ordinary work. When a key is renamed, rename it in `enUS.lua` and at every call site together, and never reuse a retired key name: the other locales keep the old key until the next Localization pass, and AceLocale falls back to English only for a key a locale doesn't define, so a stale translation would silently win. `Tests/Run.lua` checks key parity across all eleven files.
- **Placeholders.** `%s`/`%d` count, type and order must match `enUS` per key in every locale, or the string crashes at runtime. The `ERROR_*` keys take two (player, then the item list); `MESSAGE_TRADE_GAVE_RECEIVED` takes three; `MESSAGE_OPENING_PAUSED` and `AUTOMATED_OPENING_DESCRIPTION` take a `%d` (the free-slot count); `MESSAGE_ITEM_WILL_AUTO_OPEN`, `MESSAGE_ITEM_IGNORED` and `MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW` take the item link; `CHARACTER_RULES_PANEL_DESCRIPTION` takes three game names (a stat, a class, the stat again).
- **Game names never go in `Locales/`.** Spells, items, skills, classes, stats and Blizzard labels are stored as IDs or tokens and named by the client:
  - `ns.SKILL_LINE_IDS.LOCKPICKING` (skill line 633), named through `C_TradeSkillUI.GetTradeSkillDisplayName` (`ns.GetLockpickingSkillName`).
  - `ns.SPELLS` (Pick Lock, Pick Pocket, Shadowmeld), compared by ID in the cast events and named through `C_Spell.GetSpellName` in Diagnostics.
  - Items by ID through `C_Item.GetItemInfo`, which can be nil until `GET_ITEM_INFO_RECEIVED`; an item's kind through `C_Item.GetItemInfoInstant`'s class name.
  - Classes by token (`"WARRIOR"`), named through `LOCALIZED_CLASS_NAMES_MALE` and colored through `RAID_CLASS_COLORS`.
  - Stats through the `ITEM_MOD_*_SHORT` labels and the full `ITEM_MOD_*` line formats, and Character Rules' captions through `STAT_CATEGORY_PRIMARY_ATTRIBUTES` / `STAT_CATEGORY_SECONDARY_ATTRIBUTES` where the client has them.
  - Roll words, contexts and loot lines through the client's own globals: `NEED`, `GREED`, `ROLL_DISENCHANT`, `PARTY`, `RAID`, the `LOOT_ITEM*` and `LOOT_ROLL_*` formats, `GOLD_AMOUNT` / `SILVER_AMOUNT` / `COPPER_AMOUNT`, `ERR_INV_FULL`, and the chat settings' own `GENERAL`, `ITEM_LOOT` and `MONEY_LOOT`.
- **Carried from Open Sesame.** The merge brought over Open Sesame's translations for every string whose English GogoLoot kept, under GogoLoot's key names (a recorded exception; see README-Notes).
- **Diagnostics strings are not localized.** They live in `ns.DiagnosticsStrings` (`Diagnostics/Diagnostics-Core.lua`) as plain English. Keep them out of `Locales/` entirely.

Everything else (the Spanish file pairing, the overflow canary, the output ceilings) is per Style Guide → LOCALIZATION and MESSAGES → Message Length. Options labels have no byte ceiling but do have a column width: check a long-word locale (deDE) against `ns.OPTIONS_LABEL_WIDTH` when adding a row.

## Common Pitfalls

- **Stripping pipes in `Announce`**: destroys item links, which GogoLoot's bodies carry. Leave the bodies unstripped.
- **Sending chat messages over 255 bytes**: the client rejects them silently. Measure with `ns:BuildAnnounceMessage` against `ns.CHAT_MESSAGE_MAX_LENGTH` and split at part boundaries through `ns:AnnounceParts`, never mid-link.
- **Announcing inline with `GiveMasterLoot`**: posts "Gave X to Y" for deliveries that then fail. Always register through the Pending Hand-out Registry and let `LOOT_SLOT_CLEARED` emit.
- **Wiping the hand-out registry without flushing**: `LOOT_CLOSED` and `LOOT_OPENED` both clear it, and the confirmation they race is a server round trip. Any new code path that clears it must call `FlushPendingManualAnnouncements` first, or manual hand-outs go silent exactly when the window closes fastest.
- **Using raw `C_Timer.After` for anything cancellable**: use `ns:After(identifier, seconds, callback)`. Scheduling the same identifier replaces the pending one and `ns:CancelTimer` kills it, so no call site needs a hand-rolled guard flag doubling as a self-cancel token.
- **Adding an API guard outside Utilities' accessor block**: every modern-versus-legacy decision belongs in one place, and a namespaced API every target client ships (`C_Item`, `C_Container`, `C_AddOns`) is called directly, with no legacy fallback.
- **Letting Item Overrides bypass `autoGreed`**: the toggle is the master switch for every automated roll. The override check must stay behind the `autoGreed` gate; the options copy promises that off means off.
- **Moving the quest-class skip ahead of Item Overrides**: the AQ and ZG war-effort tokens the default list ships for are all `classId` 12, so a skip that runs first makes the entire feature a no-op for them: correct ids, correct saved action, no roll, no error. Call the two halves separately (`ns:IsNeverAutomatedItem`, then the list, then `ns:IsQuestClassItem`) and keep `ShouldSkipItemForMasterLoot` for distribution, whose only override is the panel toggle.
- **Treating a nil `GetLootRollItemLink` as a dead roll**: it also reads nil while the client's item query is still in flight, which is the normal state of a token's first drop of the session. Return `false` from `EvaluateRoll` and let the retry timer poll; `CANCEL_LOOT_ROLL` is what tears a genuinely dead roll down.
- **Sizing the roll retry cap as a give-up point**: it isn't one. The cap exists only to bound a cancel that never arrives, so it sits past the 60 s roll window. A cap of a few seconds drops rolls whose item query simply takes longer.
- **Gating automated rolls on the loot method**: the roll module answers `START_LOOT_ROLL` and nothing else. Adding a `GetLootMethod` check would silently stop the rolls that *do* open during a master-loot session.
- **Keeping Character Rules in the profile**: every character shares the `"Default"` profile, so a rule there would apply to the whole account. Rules live in `ns.db.char`.
- **Trusting `GetItemStats` alone for Character Rules**: on Classic Era and TBC spell power, healing, attack power, crit, hit and mana regeneration are "Equip:" spells and every random-suffix stat is an enchantment, all invisible to it. `ns.ReadCharacterRuleStats` adds the generated tables and the tooltip.
- **Matching tooltip stat lines with the `ITEM_MOD_*_SHORT` labels**: several locales word the tooltip line apart from the label. Build the pattern from the full `ITEM_MOD_*` format, and strip deDE's `%1$` argument numbering first.
- **Reusing or renumbering a Character Rules `bit`**: the bits are baked into the generated `Item-Stats` tables, so a changed bit silently reads another stat.
- **Resetting destinations on every `PARTY_LOOT_METHOD_CHANGED`**: that wipes a live setup when the master looter is merely reassigned. Compare against the last *observed* method instead, and refresh that observation from `GROUP_ROSTER_UPDATE` too; the method event is the leader's action and need not reach every member.
- **Seeding `destinations` with `"self"` for every quality**: AceDB would re-apply it at each login, so a cleared setup could never survive a reload. An absent quality is the correct "nobody chosen yet".
- **Giving the item-row remove column a text caption**: AceConfig renders an `execute` carrying an `image` as an AceGUI Icon and one without as a Button, and Button insets its font string 15px from each edge, so a caption in a column this narrow clips to a sliver. Keep `name = ""` and let the label ride in `desc` as the hover tooltip.
- **Adding a roll-action dropdown without `sorting`**: the dropdown orders `values` by key, so the four actions read greed, manual, need, pass. Pass `ns.ROLL_OVERRIDE_ORDER` (Manual, Pass, Greed, Need) every time.
- **Registering an event without adding it to `ns.EVENT_NAMES`**: `RegisterModuleEvent` warns, and the Diagnostics Event Registration probe silently misses it. Add the name (alphabetically) in Core.lua.
- **Calling `UnregisterModuleEvent` from inside an event handler**: the dispatcher iterates the live handler list. Defer to a timer or user-driven path.
- **Speedy-looting while master looter**: Speedy Loot stands down for the whole master-loot session through `ns:AreWeMasterLooter()`, not just `WillAutoMasterLoot()`; a `LootSlot` on a threshold item pops `MasterLooterFrame_Show` and errors on some clients.
- **Registering a second `LOOT_READY` handler for the loot sounds**: the world-loot stamp and the Pick Pocket sound read the slots Speedy Loot empties, so they run inside Speedy Loot's one handler, first. A separate handler would depend on TOC order.
- **Taking an empty source read for item loot**: a corpse's source GUIDs can arrive after the window opens, so `ns.StampWorldLoot` leaves the chime's window alone when it has nothing to go on. Closing it there silences a real corpse.
- **Hiding the loot window on `LOOT_READY`**: a no-op, since the default UI shows it afterwards. Suppression runs through the `OnShow` hook.
- **Setting the scan tooltip's owner once**: hiding a tooltip drops its owner, and an unowned tooltip takes `SetBagItem` without complaint and reads nothing, so every box looks unlocked. The owner is set on every call.
- **Skipping the lock check for items set to Open**: a locked box would be tried every tick into "Item is locked" errors. Every openable item is lock-checked.
- **Reacting to every inventory-full error in Automated Opening**: the game raises it for loot, trades and mail too. GogoLoot pauses and warns only while one of its own opens is waiting on an answer.
- **Saving an Openables List default**: store only what differs from the default, or a later data change never reaches the player.
- **Syncing Standard Loot Messages on every login**: it would undo a box the player ticked back in Blizzard's chat settings. Act only when the wanted state differs from the `ns.db.char` mark, and give back only the groups GogoLoot took.
- **Letting the toast cap reach zero**: Unlimited is stored as 0 and must resolve to `math.huge` before any comparison, or every row retires the moment it is drawn.
- **A release that can remove nothing**: callers of `ns.ReleaseLootToast` loop until a list shrinks. The list removals always run; only the pooling is guarded.
- **Deferring the lockbox tooltip block to the next frame**: it strobes, because a hovered bag button re-runs `SetBagItem` every frame. Add inside the build.
- **Filtering on Enter only, or redrawing on every keystroke**: a stock EditBox reports Enter alone, and a redraw per keystroke rebuilds hundreds of rows and drops the keyboard each time. The filter box writes its own filter, redraws once typing pauses, and hands the keyboard back across the redraw.
- **Lower-casing a filter with `string.lower` alone**: it misses Cyrillic and accented capitals. Use `ns.FoldCase`.
- **Reading the player's own loot by a message prefix**: in zhCN and zhTW the loot line ends with its own full stop, so a prefix built by deleting `%s` never matches. `ns.ParseOwnLootMessage` matches the client's whole formats, counted forms first.
- **Comparing player names raw**: cross-realm members appear as `Name-Realm` in some APIs and `Name` in others. Every comparison goes through `ns:NormalizePlayerName`.
- **Reading a unit's name with `UnitName` alone, or cutting a name at its space**: on WoW Forever the realm slot holds the last name and the name is `First Last`. Roster names come from `ns:GetCleanUnitName` / `ns:GetLowercaseUnitName`, which rejoin the halves there, and `ns:FormatPlayerName` capitalizes each word.
- **Picking compatibility APIs by truthy result**: `(C_CVar.GetCVarBool(...)) or GetCVar(...)` falls through to the legacy read whenever the value is false. Check API availability, then call exactly one (`ns.GetItemTooltipLines` in `Features/Utilities.lua` is the pattern), and call an API every target client ships directly, with no fallback at all (`ns:IsAutoLootCVarEnabled`).
- **Confusing `ERR_*` Blizzard globals with `ERROR_*` locale keys**: the error mapper keys off unquoted globals (`ERR_LOOT_MASTER_INV_FULL`) and returns quoted GogoLoot keys (`"ERROR_BAG_FULL"`). They are different namespaces.
- **Mutating the table returned by `AceDBOptions-3.0:GetOptionsTable`**: its `args` sub-table is one shared table serving every Ace3 database on the client, so anything written into it appears inside every other add-on's Profiles panel. `Options-Profiles.lua` returns the stock table unmodified; any future extension must live in a wrapper table of its own.
- **Following the trade window's per-slot events to the end of a trade**: the window empties itself as the trade executes, before the result arrives. Record at acceptance (see The Trade Snapshot).
- **Assuming `GetTradePlayerItemInfo` and `GetTradeTargetItemInfo` return the same shape**: they swap the enchant description and the following field. See The Trade Enchant Slot.
- **Matching loot errors on their message text**: `UI_ERROR_MESSAGE` carries a numeric error id; match that, resolved from the constant name through `GetGameMessageInfo`. Any string comparison reintroduces the locale dependency, and a substring one announces combat noise to the raid as a loot failure.
- **Reordering the TOC includes**: `AceConfigCmd-3.0` must load before `AceConfig-3.0.lua`, which hard-requires it at load.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/Gogo1951/GogoLoot/issues).
- **Bug reports**: include game version + locale, class + level, group context (solo, party or raid, and the loot method), repro steps, and the relevant chat output or error text. The Diagnostic Tools panel builds a client-tagged report you can paste in.
- **Discord**: [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q).
- **PR guidelines**: keep PRs scoped to one change; match the conventions in this codebase (namespace `ns`, locale keys for every user-facing string, no abbreviations in names); verify the 255-byte limit for any change to outbound messages (Style Guide → MESSAGES → Message Length) and check labels in the longer locales; ship every change to saved data with its own migration, tagged `MIGRATION (remove after YYYY-MM-DD)`, 30 days past the release that ships it; keep `ns.EVENT_NAMES` and the diagnostics probes in sync with any new events or API guards; run `lua Tests/Run.lua`; update this document if the architecture or file map changes.
- **Commit and PR descriptions require a User Story.** Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why:

   **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

   **Example:** *As a master looter handing out a six-item boss kill, I wanted the trade announcement to arrive instead of silently failing so the raid could see what was distributed. This change splits oversized summaries across multiple messages at item-link boundaries.*
