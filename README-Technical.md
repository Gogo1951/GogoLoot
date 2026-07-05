# GogoLoot — Technical Reference

This document combines architecture notes and contribution guidance for developers working on GogoLoot. For end-user documentation, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md).

## File Map

```
GogoLoot/
├── .pkgmeta                        — CurseForge packager manifest; externals check out into Includes/Libraries/
├── GogoLoot.toc                    — load order: Includes → Locales → Data → Features → Options
├── README.md                       — end-user documentation
├── README-Technical.md             — this document
├── Data/
│   ├── Data.lua                    — constants only (expansion, item/roll/quality, colors, target marker, registry names, label maps); no logic beyond WOW_PROJECT_ID
│   └── Default-Settings.lua        — ns.DATABASE_DEFAULTS plus the default custom-roll and ML-ignore item lists
├── Features/
│   ├── Core.lua                    — version, saved-variable lifecycle + migrations, the event dispatcher, and ns.EVENT_NAMES
│   ├── Utilities.lua               — stateless shared helpers: item API shims, colors, tooltips, name/item parsing, game-state predicates
│   ├── Announcements.lua           — PrintMessage / Announce / BuildAnnounceMessage, group-channel resolution, welcome message
│   ├── Announcements-Trade.lua     — trade snapshotting, summary building and chunking, trade-window checkbox
│   ├── Speedy-Loot.lua             — LOOT_READY fast-looting with a free-bag-slot budget
│   ├── Master-Looter.lua           — ML API wrappers, eligibility check (WillAutoMasterLoot), and destination management
│   ├── Master-Looter-Distribution.lua — manual-distribution hook, the LOOT_OPENED distribution engine, and the Pending Announcement Registry
│   ├── Automated-Rolls.lua         — START_LOOT_ROLL auto-greed threshold + custom roll list, with async retry for cold item info
│   ├── Diagnostics.lua             — read-only environment probes and report builders for bug reports (runtime-only state, never a SavedVariable)
│   └── Minimap-Button.lua          — LibDataBroker launcher, minimap icon state, tooltip
├── Includes/
│   ├── Images/                     — GogoLoot.tga (addon-list icon)
│   └── Libraries/                  — bundled libraries (packager externals; never edit by hand)
├── Locales/                        — enUS.lua is the source of truth; other locales are translated separately
└── Options/
    ├── Options-Utilities.lua       — widget helper constructors, item-cache warming, shared item-list builder, GogoLoot_ItemLink widget
    ├── Options-General.lua         — root General panel (welcome, minimap toggle, Speedy Loot, links)
    ├── Options-Master-Looter.lua   — Master Looter panel (loot method/threshold, destinations, ignore list)
    ├── Options-Automated-Rolls.lua — Automated Rolls panel (threshold + custom roll list)
    ├── Options-Announcements.lua   — Announcements panel (master looter + trade sections)
    ├── Options-Profiles.lua        — stock AceDBOptions panel plus the Reset All Profiles button
    ├── Options-Diagnostics.lua     — Diagnostic Tools panel (single runtime toggle gates the whole panel)
    └── Options.lua                 — AceConfig registration, Blizzard panel wiring, slash commands
```

Everything lives on the addon namespace table (`local ADDON_NAME, ns = ...`); the only globals are `GogoLootDB` (SavedVariables), the slash commands (`SLASH_GOGOLOOT1/2`, `SlashCmdList["GOGOLOOT"]`), and two named frames (`GogoLootEventFrame`, `GogoLootTradeAnnounceCheckbox`). The minimap button's frame is created inside LibDBIcon, not by GogoLoot.

## Architecture

### Event Loop

`Features/Core.lua` owns a single named event frame (`GogoLootEventFrame`) and a dispatcher. Modules never call `frame:RegisterEvent` directly — they call `ns:RegisterModuleEvent(event, handler)`, which registers the event with the frame once and appends the handler to `ns.eventHandlers[event]`. On fire, `OnEvent` fans out to every handler for that event in registration order.

Two things wrap the fan-out:

- **Drift guard.** `ns.EVENT_NAMES` (Core.lua, kept sorted alphabetically) is the exported single source of truth for every event the add-on registers. `RegisterModuleEvent` prints a one-time developer warning if handed an event missing from that list. The list exists so the Diagnostics Event Registration probe can enumerate events without reading the live handler table — which would miss on-demand, self-unregistering registrations like Options-Utilities' `GET_ITEM_INFO_RECEIVED` watcher.
- **Diagnostics tap.** When `ns.diagnostics.logging` is true, `OnEvent` hands each event to `ns:LogEvent` before dispatching. Boolean checks gate it, so it costs nothing when logging is off.

`ns:UnregisterModuleEvent` exists but is **not** safe to call from inside an event handler — `OnEvent` iterates the live handler list. Defer to a timer or user-driven path; the roll retry ticker and the item-cache watcher both self-cancel via a flag rather than unregistering mid-dispatch.

Who listens to what:

- `Features/Core.lua` — `ADDON_LOADED` (saved-variable init, migrations, minimap + options bootstrap), `PLAYER_ENTERING_WORLD` (one-shot auto-loot CVar enforcement, delayed 3 s).
- `Features/Announcements.lua` — `PLAYER_LOGIN` (welcome message).
- `Features/Announcements-Trade.lua` — `TRADE_SHOW`, `TRADE_ACCEPT_UPDATE`, `TRADE_PLAYER_ITEM_CHANGED`, `TRADE_TARGET_ITEM_CHANGED`, `TRADE_REQUEST_CANCEL`, `UI_INFO_MESSAGE` (trade complete/cancel).
- `Features/Speedy-Loot.lua` — `LOOT_READY`, throttled to one pass per 0.3 s (`LOOT_THROTTLE_SECONDS`) to absorb double-fires.
- `Features/Master-Looter.lua` — `GROUP_ROSTER_UPDATE`, `PARTY_LOOT_METHOD_CHANGED`.
- `Features/Master-Looter-Distribution.lua` — `LOOT_OPENED`, `LOOT_CLOSED`, `LOOT_SLOT_CLEARED`, `UI_ERROR_MESSAGE`; plus a `hooksecurefunc` on `GiveMasterLoot` for manual distributions.
- `Features/Automated-Rolls.lua` — `START_LOOT_ROLL`, `CONFIRM_LOOT_ROLL`, `CANCEL_LOOT_ROLL`.
- `Options/Options-Utilities.lua` — `GET_ITEM_INFO_RECEIVED`, registered on demand and self-unregistering (see Item Data Caching).
- `Features/Diagnostics.lua` — none at runtime; its Event Registration probe registers then immediately unregisters each `ns.EVENT_NAMES` entry on a **separate** frame, with no handler attached, so probing never disturbs the live dispatcher.

### Master Loot Pipeline

The distribution engine in `Features/Master-Looter-Distribution.lua` runs Scan → Resolve → Distribute → Confirm:

1. **Scan** — `LOOT_OPENED` fires `RunDistributionPass` when `ns:WillAutoMasterLoot()` is true (master looter + `autoMasterLoot`, inside a raid/party instance unless `autoMasterLootOutsideInstances`).
2. **Resolve** — `BuildCandidateMap` maps lowercased candidate names per slot, adding a realm-stripped alias only when exactly one candidate normalizes to it; ambiguous duplicates (e.g. `Bob` and `Bob-OtherRealm`) create no alias and fall back to manual handling rather than guessing.
3. **Distribute** — `TryDistributeSlot` gates each slot (hard item-type skips, ignore list, BoP outside trade-eligible instances, quality→destination mapping) and calls `GiveMasterLoot(slot, candidate, true)` — the `true` lets the manual hook distinguish automated calls.
4. **Confirm** — announcements are never sent inline; see the Pending Announcement Registry deep-dive. A 0.1 s retry ticker (`DISTRIBUTION_RETRY_INTERVAL`) re-runs the pass up to 20 times (`DISTRIBUTION_MAX_RETRIES`) until nothing is left or `DISTRIBUTION_QUIET_TICKS` consecutive ticks make no progress, covering late candidate data and cold item caches.

### Item Data Caching

`Features/Utilities.lua` exposes `ns.GetItemInfo` / `ns.GetItemInfoInstant` (C_Item on modern clients, legacy globals otherwise). `ns:SafeGetItemInfo` returns nil for uncached items; callers treat nil as "retry later", not an error:

- The distribution engine's retry ticker re-attempts slots whose item info was cold.
- `Features/Automated-Rolls.lua` returns `false` from `EvaluateRoll` when item info is uncached and polls the roll every 0.5 s (`ScheduleRollRetry`) until it resolves, the roll expires, or the attempt cap is hit — the class/subclass hard skips need full item info, so a roll is never decided from `GetLootRollItemInfo`'s arguments alone.
- The options item lists render a `Loading... (ID: %d)` row, and `ns:WarmItemCache` (`Options/Options-Utilities.lua`) queries every listed item, registering a `GET_ITEM_INFO_RECEIVED` watcher that repaints via a debounced 0.3 s `NotifyChange` and unregisters itself once every item has resolved.

## Outbound Messages

All cross-player chat flows through `ns:Announce(channel, target, formatKey, ...)` in `Features/Announcements.lua`. Locale strings are clean bodies; the helper applies the same decoration to every sent channel:

```
PrintMessage (local only):                 GogoLoot // <body>          (branded colors)
Announce -> WHISPER/PARTY/RAID/INSTANCE_CHAT:  {rt4} GogoLoot // <body>
```

`{rt4}` (Triangle) is `ns.TARGET_MARKER` in `Data/Data.lua`, chosen to stay visually distinct from other Gogo1951 addons. `ns:GetGroupChatChannel()` resolves the right group channel (`INSTANCE_CHAT` / `RAID` / `PARTY`) and returns nil when solo — the trade path falls back to whispering the partner.

`Announce` deliberately does **not** strip pipe characters the way the style guide's reference helpers do: GogoLoot bodies legitimately carry item links (`|Hitem...`), which are legal in outbound chat.

`SendChatMessage` rejects messages over 255 bytes (`ns.CHAT_MESSAGE_MAX_LENGTH`). Trade summaries can exceed that with 4+ item links, so `Features/Announcements-Trade.lua` builds the summary as a parts list and `AnnounceSummaryParts` greedily packs parts into as many messages as fit — measuring the final decorated message via `ns:BuildAnnounceMessage`, splitting only at part boundaries (a link broken mid-escape is rejected by the client), and repeating the same template so every message reads complete. A two-sided trade that overflows decomposes into the one-sided `MESSAGE_TRADE_GAVE` and `MESSAGE_TRADE_RECEIVED` templates.

## Pending Announcement Registry

`GiveMasterLoot` returns immediately; the server confirms success only when the loot slot clears, and surfaces failure as a later `UI_ERROR_MESSAGE`. Announcing inline would post "Gave X to Y" for failed deliveries — twice after a retry. Instead both the automated path (`TryDistributeSlot`) and the manual dropdown hook register a pending entry keyed by slot (`ns:RegisterPendingLootAnnouncement`), and only the `LOOT_SLOT_CLEARED` handler emits `MESSAGE_LOOT_ANNOUNCE`. Failures never clear the slot, so they never announce; a retry overwrites the entry so the announcement names the actual recipient; `LOOT_CLOSED` wipes leftovers.

The auto path gates the announce toggle and threshold **at register time**, so pending entries exist only for items the user wants announced. Manual hand-outs through the ML candidate dropdown carry no toggle and no threshold — every one is announced, since a manual hand-out is a deliberate act the group should always see.

Known `UI_ERROR_MESSAGE` strings additionally post a generic `ERROR_*` explanation to the group (`MapErrorMessageToLocaleKey`), matched against Blizzard `ERR_*` globals first, then plain-text substring fallbacks for builds where the global isn't bound. `pendingDistribution` is a single value with a 1 s window (`PENDING_ERROR_WINDOW`); an error arriving while several calls are in flight is attributed to the most recent, which is acceptable because the announcement names no item or player.

## Custom Roll List vs. the Auto-Greed Toggle

The `autoGreed` toggle is the **master switch** for every automated roll: when Automated Rolls is off, nothing rolls automatically — the Custom Roll List included. The list also has its own `customRollList` toggle (default on), nested under the master: with rolls on and the list off, only the threshold path runs. In `Features/Automated-Rolls.lua`, the `autoGreed` gate runs before the per-item override check; list items then roll their configured Need/Greed/Pass (Need falls back to Greed when Need isn't offered), and only non-listed items reach the threshold-based auto-greed. The list is also the only way to automate BoP items; the threshold path never touches BoP. Legendaries, quest items, recipes/books, mounts, and pets are skipped unconditionally (`ns:ShouldSkipItemByType`) before either path.

Only rolls this module issues are recorded in `rollsInitiatedByAddon`, so the `CONFIRM_LOOT_ROLL` handler auto-confirms bind dialogs for GogoLoot's rolls only — player-initiated rolls keep Blizzard's confirmation.

## Speedy Loot Bag Budget

`Features/Speedy-Loot.lua` stands down for the **entire loot session** whenever `ns:AreWeMasterLooter()` is true — not merely when GogoLoot will auto-distribute. Master loot is a managed flow (at-or-above-threshold items are assigned through the ML window; sub-threshold items go out by the group method), and a `LootSlot` call here would either vacuum that loot into the master looter's own bags before it can be assigned, or pop `MasterLooterFrame_Show` on a threshold item — which errors on some clients. `AreWeMasterLooter()` is the superset of `WillAutoMasterLoot()`, so this still covers the auto-distribute case, including outside instances where auto-distribution is off by default.

Otherwise it respects the Auto Loot CVar (and its modifier-key inversion, so holding the auto-loot modifier still flips behavior), hides the loot frame, and loots bottom-up — mirroring default auto-loot and avoiding index shifts — spending a cached free-bag-slot budget per item slot. Only general-purpose bags count toward the budget (bagFamily 0, or the nil the backpack/legacy API returns); specialty bags — quivers, soul bags, profession bags — can't hold arbitrary loot, so counting their slots would overstate usable space. Money and currency are always looted (they take no bag space, detected via `GetLootSlotType`). With zero free slots and item slots present, it loots nothing and leaves the standard window visible rather than stranding loot.

## Diagnostics

`Features/Diagnostics.lua` is environment probing and state capture for bug reports, not a test runner. It is surfaced through the Diagnostic Tools options panel and is built to be safe by construction:

- **Runtime-only state.** `ns.diagnostics` is a plain namespace table (`{enabled, logging, log, ...}`), never a SavedVariable. It starts off every session and persists nothing at logout. A single Enable toggle gates the whole panel; when off, every section below it is `hidden`.
- **Read-only, on demand.** Reports build only on a button press, never on load or panel open. Every probe is existence/shape checks or live reads with no side effects — the one exception is the Taint Log button, which sets the `taintLog` CVar (`ns:SetTaintLog`).
- **Not localized.** Diagnostics strings live in `ns.DiagnosticsStrings` as plain English, in this file only — they are developer-facing troubleshooting text, so translating them is wasted effort. The one exception is the add-on's own display name, read from `L["ADDON_TITLE"]`.
- **Event Registration probe** reads `ns.EVENT_NAMES` (Core's exported list), so it can never drift from the events the add-on actually uses. It registers then immediately unregisters each event on its own probe frame with no handler, and reports both `C_EventUtils.IsEventValid` and whether `RegisterEvent` succeeds.
- **API Endpoints probe** (`ns.DIAGNOSTIC_API_CHECKS`) lists every modern and legacy API GogoLoot guards against, separately, so a report shows exactly what a given client provides. Keep it aligned with the guards in the feature files.
- **Saved Variables dump** prints every row of `GogoLootDB`, item lists included — the per-item roll overrides and ignore entries *are* the configuration a loot bug report needs, so the full dump is a sanctioned deviation from the guide's summarize-large-arrays advice.

The event log (`ns:LogEvent`) snapshots arguments to strings immediately (never retaining frame/table references), caps 8 args at 255 bytes each, and escapes pipes (`|` → `||`) **after** the length cut so a loot line shows its item link verbatim in the report editbox instead of rendering as a clickable swatch or collapsing to a stray `[Sc`.

## Saved Variables

`GogoLootDB` is an AceDB-3.0 database (`ns.db`, created in `Features/Core.lua` on `ADDON_LOADED`). Profiles are stored account-wide in `GogoLootDB.profiles`, each character's active profile choice in `GogoLootDB.profileKeys`, and account-wide profile-independent state in `GogoLootDB.global`. Most settings live inside the active profile — code reads and writes `ns.db.profile.<key>`. Defaults come from `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`); AceDB applies them via metatables, so there is no manual defaults merge. Profiles are managed on the Profiles options panel (AceDBOptions-3.0), letting a player keep separate loot rules per context (guild raid vs. PUG) and switch at will.

Per-profile keys (`ns.db.profile`):

- `showWelcome`, `speedyLoot`, `autoGreed`, `autoGreedThreshold`, `customRollList` — feature toggles and the auto-greed quality ceiling.
- `autoMasterLoot`, `autoMasterLootOutsideInstances` — distribution engine gates.
- `announceDestinations`, `announceMasterLootAuto`, `announceMasterLootAutoThreshold` — ML announcement toggles. The auto path is threshold-gated (default `3` = Rare+) so routine auto-loot doesn't spam chat; manual hand-outs have no setting and are always announced.
- `announceTrade`, `announceTradeCondition` (`always` / `party_or_raid` / `raid_only`), `announceTradeOutput` (`whisper` / `group`).
- `destinations` — quality key (`poor`…`epic`) → `"self"` or a normalized (realm-stripped, lowercased) player name.
- `ignoredItemsSolo` — itemId → `"manual"` / `"greed"` / `"need"` / `"pass"` (the Custom Roll List).
- `ignoredItemsMaster` — itemId → `true` (the ML ignore list).

Account-wide global keys (`ns.db.global`):

- `minimap` — LibDBIcon position + `hide` flag. Account-wide so switching, resetting, or deleting a profile never moves the button. `ns:ResetAllProfiles` (the Reset All Profiles button) calls `ns.db:ResetDB()`, which wipes everything including this table, so the function snapshots and restores it explicitly.

Empty item lists are deliberately re-seeded from the expansion-filtered defaults (`RebuildEmptyItemLists` in `Features/Core.lua`) on load and on every profile change or reset — an empty list is treated as "never configured". The default entries (`ns.DEFAULT_IGNORE_LIST_SOLO`, `ns.DEFAULT_IGNORE_LIST_MASTER`) each carry an expansion tag (`VANILLA`=1, `TBC`=2, `WRATH`=3) and are filtered against `ns.currentExpansion`, so TBC items ship harmlessly to Era clients.

### Migration Chain

All three run once, in this order, inside `OnAddonLoaded` after `AceDB:New`. Each is tagged to be removed after 2026-10-01.

- `MigrateFlatSettingsToProfile` — folds pre-profile flat `GogoLootDB.<key>` values into the active profile, then nils the old flat keys.
- `announceTradeOutput` collapse — an inline rewrite of the retired `"raid"` output value to `"group"` (the two dropdown options are now Whisper and Group Chat).
- `MigrateMinimapToGlobal` — moves the minimap position from `profile.minimap` into `global.minimap`. It `rawget`s past AceDB's defaults metatable so only genuine stored per-profile data migrates, and fills only global keys not already present, so an established global position is never clobbered. Also runs per profile from `HandleProfileChanged` as each profile is visited.

AceDB supplies defaults lazily via metatables (there is no `EnsureDefaults` pass); the refill-on-empty rule above is the only place the add-on re-seeds saved values, and it only fills empty item lists — it never overrides explicit user values.

## Adding a New Announcement

1. Add a `MESSAGE_*` key to `Locales/enUS.lua` — a clean body with `%s` placeholders, no marker or addon name.
2. Call `ns:Announce(channel, whisperTarget, "MESSAGE_YOUR_KEY", ...)`. Use `ns:GetGroupChatChannel()` for group output and handle its nil return when solo.
3. If the body can carry multiple item links, build it as a parts list and send through the `AnnounceSummaryParts` pattern in `Features/Announcements-Trade.lua` — a single message caps at 255 bytes.
4. Check the rendered length in longer locales; German strings run ~30% longer than English and are the usual overflow canary.

## Adding a New Options Panel

1. Create `Options/Options-<Name>.lua` exposing `ns.Build<Name>Options()` that returns an AceConfig group table, using the `ns.OptionsHeader` / `OptionsDesc` / `OptionsSpacer` helpers and a `TAB_*` locale key for its `name`.
2. Add a registry name to `ns.OPTIONS_REGISTRY` in `Data/Data.lua`, derived from `ADDON_NAME` — never localized; cross-module `NotifyChange` callers reference it by exact string.
3. Register it in `ns:InitializeOptions` (`Options/Options.lua`): `RegisterOptionsTable` plus `AddToBlizOptions(registryName, L["TAB_*"], L["ADDON_TITLE"])` — the third argument must match the parent panel's display name exactly, and the order of `AddToBlizOptions` calls is the order panels appear in Blizzard's settings tree.
4. Add the file to `GogoLoot.toc` after `Options/Options-Utilities.lua` and before `Options/Options.lua`.

## Adding a New Registered Event

1. Register the handler with `ns:RegisterModuleEvent(eventName, handler)` from the owning module — never `frame:RegisterEvent` directly.
2. Add the event name to `ns.EVENT_NAMES` in `Features/Core.lua`, keeping the list alphabetical. Skipping this prints a one-time developer warning and leaves the event out of the Diagnostics Event Registration probe.
3. If the handler must ever unregister, do it from a timer or user path (or self-cancel via a flag) — `ns:UnregisterModuleEvent` is unsafe to call while `OnEvent` is iterating handlers.

## Adding a New Default List Item

1. Add the entry in `Data/Default-Settings.lua`: `[itemId] = {expansion, rollOverride}` for `ns.DEFAULT_IGNORE_LIST_SOLO` (expansion `1`–`3`; override `ROLL_INDEX_MANUAL`/`ROLL_INDEX_GREED`/`ROLL_INDEX_NEED`/`ROLL_INDEX_PASS`), or `[itemId] = {expansion}` for `ns.DEFAULT_IGNORE_LIST_MASTER`.
2. Entries gate on `ns.currentExpansion`, so TBC items ship safely to Era clients.
3. Existing users do **not** receive new defaults automatically — saved lists are rebuilt only when empty or via the Restore Defaults button. Mention new defaults in release notes.

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from `NewLocale("GogoLoot", "<locale>", true)` — that flag marks the default fallback; only `enUS.lua` should set it. Translate every string. Add the file to the `.toc` immediately after `Locales/enUS.lua`.

Missing keys fall back to English via AceLocale, so partial translations degrade gracefully. Spanish ships as two files, `esES.lua` and `esMX.lua`, with identical strings. `enUS.lua` is the source of truth: when keys are renamed there, old keys in other locale files become harmless orphans until the next translation pass. Diagnostics strings are intentionally *not* localized — leave `ns.DiagnosticsStrings` out of `Locales/` entirely.

## Common Pitfalls

- **Stripping pipes in `Announce`**: destroys item links. The missing `gsub("|", "")` is a deliberate deviation from the style guide — don't "fix" it.
- **Sending chat messages over 255 bytes**: the client rejects them silently. Measure with `ns:BuildAnnounceMessage` against `ns.CHAT_MESSAGE_MAX_LENGTH` and split at part boundaries via `AnnounceSummaryParts` — never mid-link.
- **Announcing inline with `GiveMasterLoot`**: posts "Gave X to Y" for deliveries that then fail. Always register through the Pending Announcement Registry and let `LOOT_SLOT_CLEARED` emit.
- **Letting the Custom Roll List bypass `autoGreed`**: the toggle is the master switch for every automated roll. The override check must stay behind the `autoGreed` gate — the options copy promises that off means off.
- **Wiping `ns.db.global.minimap` in `ResetAllProfiles`**: `ResetDB` clears the account-wide table, so the reset snapshots and restores it explicitly, or the user's minimap button jumps back to its default angle.
- **Registering an event without adding it to `ns.EVENT_NAMES`**: `RegisterModuleEvent` warns, and the Diagnostics Event Registration probe silently misses it. Add the name (alphabetically) in Core.lua.
- **Calling `UnregisterModuleEvent` from inside an event handler**: the dispatcher iterates the live handler list. Defer to a timer or user-driven path.
- **Speedy-looting while master looter**: bypass stands down for the whole ML session via `ns:AreWeMasterLooter()`, not just `WillAutoMasterLoot()` — a `LootSlot` on a threshold item pops `MasterLooterFrame_Show` and errors on some clients.
- **Comparing player names raw**: cross-realm members appear as `Name-Realm` in some APIs and `Name` in others. Every comparison goes through `ns:NormalizePlayerName`.
- **Picking compatibility APIs by truthy result**: `(C_CVar.GetCVarBool(...)) or GetCVar(...)` falls through to the legacy read whenever the value is false. Check API availability, then call exactly one (`ns:IsAutoLootCVarEnabled` is the pattern).
- **Confusing `ERR_*` Blizzard globals with `ERROR_*` locale keys**: the error mapper compares unquoted globals (`ERR_INV_FULL`) and returns quoted GogoLoot keys (`"ERROR_BAG_FULL"`). They are different namespaces.
- **Reordering the TOC includes**: `AceConfigCmd-3.0` must load before `AceConfig-3.0.lua`, which hard-requires it at load.
- **Removing the doubled `InterfaceOptionsFrame_OpenToCategory` call**: the duplicate is required for Classic clients to land on the right panel.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/Gogo1951/GogoLoot/issues).
- **Bug reports**: include game version + locale, group context (solo / party / raid, loot method), repro steps, and the relevant chat output or error text. The Diagnostic Tools panel builds a client-tagged report you can paste in.
- **Discord**: [discord.gg/eh8hKq992Q](https://discord.gg/eh8hKq992Q).
- **PR guidelines**: keep PRs scoped to one change; match the conventions in this codebase (namespace `ns`, locale keys for every user-facing string, no abbreviations in names); verify the 255-byte limit for any change to outbound messages; check labels in longer locales; keep `ns.EVENT_NAMES` and the diagnostics probes in sync with any new events or API guards; update this document if the architecture or file map changes.
- **Commit and PR descriptions require a User Story.** Don't just say "I changed X" or "I fixed Y." Frame the change in terms of who it helps and why:

   **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

   **Example:** *As a master looter handing out a six-item boss kill, I wanted the trade announcement to arrive instead of silently failing so the raid could see what was distributed. This change splits oversized summaries across multiple messages at item-link boundaries.*
