# GogoLoot // Technical Reference

> Code map for working on GogoLoot: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/GogoLoot/blob/main/README.md).

## File Map

```
GogoLoot/
├── .github/
│   ├── ISSUE_TEMPLATE/config.yml                   New issue page links; per add-on, not CI-checked
│   ├── ISSUE_TEMPLATE/defect.yml                   Copied from Common-Core; CI fails on drift
│   ├── ISSUE_TEMPLATE/request.yml                  Copied from Common-Core; CI fails on drift
│   ├── workflows/ci.yml                            Calls Common-Core: shared-file and kit drift, .pkgmeta library parity, luac, luacheck, StyLua, Tests
│   ├── workflows/issue-labels.yml                  Calls Common-Core: fills a new issue's missing Area, Priority or Type label
│   └── workflows/package.yml                       Calls Common-Core: refreshes Includes/Libraries from .pkgmeta, CurseForge and Wago release on a tag
├── .gitattributes
├── .gitignore
├── .luacheckrc                                     Lua 5.1 std, the explicit WoW read_globals list, the add-on's only writable globals
├── .pkgmeta                                        Library externals; ignore list strips dev files, Tests, Data/Wrath and Data/Mainline
├── GogoLoot_Vanilla.toc                            Classic Era and Season of Discovery
├── GogoLoot_TBC.toc                                TBC Anniversary
├── GogoLoot_Camelot.toc                            WoW Forever
├── GogoLoot_Mists.toc                              MoP Classic
├── Data/
│   ├── Flavor.lua                                  Common-Core canonical copy: ns.FLAVOR from X-Flavor, ns.EXPANSION, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── Data.lua                                    Binds ns.L; constants, enums, palette, Character Rules stat and gear rows, ns.OPTIONS_REGISTRY
│   ├── {Folder}/                                   Vanilla, Discovery, TBC, Camelot, Wrath, Mists, Mainline; same seven files in each
│   │   ├── Character-Rule-Stats-{Folder}.lua       Offered stat keys; Equip spell rows only in Vanilla, Discovery, TBC
│   │   ├── Character-Rule-Gear-Types-{Folder}.lua  Armor and weapon rows, class starters, Sanity Check drops; empty in Wrath, Mainline
│   │   ├── Default-Item-Lists-{Folder}.lua         Seed rows for Item Overrides and the Ignore List
│   │   ├── Game-IDs-{Folder}.lua                   Lockpicking skill line, bind-probe and sample items, sound kit IDs
│   │   ├── Lockbox-Skill-Levels-{Folder}.lua       Lockpicking skill each lockbox needs
│   │   ├── Openable-Items-{Folder}.lua             Every openable with its default and reason, plus required levels
│   │   └── Spells-{Folder}.lua                     Pick Lock, Pick Pocket, Shadowmeld spell IDs
│   └── Default-Settings.lua                        AceDB defaults, ns.DATABASE_DEFAULTS: profile, global, char
├── Diagnostics/                                    Diagnostic Tools; GogoLoot's own part is Manifests.lua: API checks, probes, name lookups, data manifest
├── Features/
│   ├── Core.lua                                    Version, AceDB init, prune, list seeding, migrations, ApplyProfile, dispatcher, ns.EVENT_NAMES
│   ├── Utilities.lua                               API shims, colors, player names, item and link helpers, loot window lookup
│   ├── Utilities-Timers.lua                        Named timers: ns:After, ns:CancelTimer, ns:IsTimerPending
│   ├── Utilities-Bags.lua                          Free general-purpose slots, slot item ID, icons, inventory-full warning
│   ├── Utilities-Scan-Tooltip.lua                  The one hidden scan tooltip: locks, quest starters, trade clock, Validate Data lines
│   ├── Utilities-Chat-Lines.lua                    Client format strings as patterns: loot, roll and trade-clock lines, link quality
│   ├── Announcements.lua                           PrintMessage, Announce, AnnounceParts, status channel and its quiet window, welcome
│   ├── Announcements-Trade.lua                     Trade snapshot and summary
│   ├── Announcements-Trade-Checkbox.lua            Trade-window checkbox mirroring Enable Trade Announcements
│   ├── Auto-Loot.lua                               Enforces the autoLootDefault CVar for Speedy Loot and Automated Opening
│   ├── Openable-Items.lua                          Open or Ignore per item: data defaults plus the player's saved changes
│   ├── Loot-Sounds.lua                             Rare-loot chime, Pick Pocket sound
│   ├── Speedy-Loot.lua                             The slot-emptying LOOT_READY handler, loot window held hidden
│   ├── Automated-Opening.lua                       Scan, queue, open; safety gates and hold-offs
│   ├── Opening-Notices.lua                         Chat notices about a container just looted
│   ├── Lockbox-Tooltips.lua                        Lockpicking line on lockbox tooltips; not in the Mists TOC
│   ├── Loot-Toasts-Winning-Rolls.lua               Winning roll per item from roll lines; feeds toasts and the winner summary
│   ├── Loot-Toasts-Filters.lua                     Mine and Group filter verdict per item
│   ├── Loot-Toasts.lua                             Toast stack: rows, pool, samples
│   ├── Loot-Toasts-Handle.lua                      Toast anchor, drag handle, per-profile introduction
│   ├── Loot-Toasts-Money.lua                       Coin and currency toasts
│   ├── Standard-Loot-Messages.lua                  Takes Item and Money Loot off General while toasts stand in
│   ├── Blizzard-Roll-Won-Window.lua                WoW Forever's own roll-won alert, held back while toasts stand in
│   ├── Master-Looter.lua                           Loot-method wrappers, WillAutoMasterLoot, destinations, pop-up trigger
│   ├── Master-Looter-Distribution.lua              Distribution engine, GiveMasterLoot hook, Pending Hand-out Registry
│   ├── Character-Rules.lua                         Per-character gear verdict for Automated Rolls; its two migrations
│   ├── Character-Rule-Stats.lua                    Offered stats, and an item's stats from GetItemStats plus tooltip
│   ├── Roll-Messages.lua                           Hide Roll Messages chat filter, winner summary
│   ├── Automated-Rolls.lua                         Roll decision, cold-item retry, Safety Warning, on-by-default notice
│   ├── Roll-Macro.lua                              Keeps the General Roll Macro; combat-deferred
│   ├── Raid-Roll-Winner.lua                        Names a raid roll's winner; add-on message claims pick one poster
│   ├── Tint-Tradable-Gear.lua                      Tints still-tradable BoP gear through per-bag-add-on adapters
│   ├── Menu-Kit.lua                                Generic menu plates and rows the mini-map menu draws on
│   ├── Minimap-Menu.lua                            Mini-map hover menu, flyouts, button click table
│   ├── Minimap-Button.lua                          LDB launcher, LibDBIcon on ns.db.profile.minimap, icon state
│   ├── Roll-Calls.lua                              Parked: roll engine for the loot windows
│   ├── Loot-Master.lua                             Parked: Roll List, Floor Loot, Roll All, trade fill
│   ├── Drops-By-Boss.lua                           Parked: drops per boss for the Loot Tracker
│   ├── Loot-Windows.lua                            Parked: shared loot-window kit
│   ├── Loot-Master-Window.lua                      Parked: Loot Master window
│   └── Loot-Tracker-Window.lua                     Parked: Loot Tracker window
├── Includes/
│   ├── Images/GogoLoot.tga                         Add-on list icon
│   ├── Images/Menu-Plate.tga                       Mini-map menu plate
│   ├── Images/Toast-Icon-Art-Mask.tga              Rounds a toast icon's art
│   ├── Images/Toast-Icon-Border-Mask.tga           Rounds a toast icon's quality frame
│   ├── Sounds/Loot-Threshold-Warning.ogg           Automated Rolls Safety Warning
│   ├── Sounds/item-pick-up.ogg                     Rare-loot chime
│   └── Libraries/                                  Vendored; release rebuilds from .pkgmeta externals; never hand-edited
├── Locales/                                        AceLocale, eleven locales; enUS.lua is the source
├── Options/
│   ├── Options-Kit.lua                             Common-Core kit, CI byte-checked: grid, rows, RegisterPanel, OpenOptionsPanel, RefreshSettings
│   ├── Options-Utilities.lua                       Feature records (ns.FEATURES), Kit.SetText strings, feature-off line, samples
│   ├── Options-Utilities-Dropdown-Watch.lua        Closes a dropdown list scrolled out of view
│   ├── Options-Utilities-Item-Cache.lua            Item cache warming, on-demand GET_ITEM_INFO_RECEIVED watcher
│   ├── Options-Utilities-Item-List-Filter.lua      Item kind sections, New section, text and kind filters
│   ├── Options-Utilities-Item-Lists.lua            Shared item-list builder: Add from Bags, rows
│   ├── Options-Utilities-Item-List-Widgets.lua     Custom AceGUI filter and add widgets
│   ├── Options-General.lua                         Root panel: welcome, Features section, commands
│   ├── Options-Speedy-Loot.lua
│   ├── Options-Automated-Rolls.lua
│   ├── Options-Item-Overrides.lua                  Child of Automated Rolls: per-item roll actions
│   ├── Options-Character-Rules.lua                 Child of Automated Rolls: per-character tree of type and stat boxes
│   ├── Options-Master-Looter.lua                   Automated Master Looting; rows shared with the pop-up
│   ├── Options-Master-Looter-Ignore-List.lua       Child of Master Looter: items left to the player
│   ├── Options-Master-Looter-Popup.lua             Quick Settings window on becoming master looter; never in the tree
│   ├── Options-Roll-Macro.lua                      Roll Macro and Raid Roll Winner
│   ├── Options-Sanity-Check.lua                    Child of Automated Rolls: sample drops and their verdicts
│   ├── Options-Automated-Opening.lua
│   ├── Options-Openable-Items.lua                  Child of Automated Opening: the Openables List
│   ├── Options-Lockboxes.lua                       Child of Automated Opening: lockbox tooltips and notices
│   ├── Options-Loot-Toasts.lua
│   ├── Options-Loot-Toast-Filters.lua              Child of Loot Toasts: Mine and Group grid
│   ├── Options-Loot-Sounds.lua
│   ├── Options-Announcements.lua                   Loot Announcements; destination toggle shared with the pop-up
│   ├── Options-Profiles.lua                        Stock AceDBOptions table, returned unmodified
│   ├── Options-Feedback-Support.lua                Links and version
│   ├── Options.lua                                 FEATURE_PANELS tree order, registration at ADDON_LOADED, /gogo
│   └── Options-Loot-Master.lua                     Parked: Loot Master panel
├── Tests/                                          Offline suite, run on Lua 5.1; in no TOC, stripped from the zip
│   ├── Fakes/WoW.lua                               WoW and Ace surface the suite runs against
│   └── Run.lua                                     FILES load list, PARKED_FILES, assertions, every test
├── LICENSE
├── README.md                                       Player-facing
├── README-Notes.md                                 Recorded Style Guide exceptions
├── README-Technical.md                             This map
└── README-Testing.md                               Manual in-game test plan
```

- **Load order** (every TOC): Includes, Locales, Data, Features, Diagnostics, Options. Load-bearing: files capture namespace members at file scope (`local Kit = ns.OptionsKit`, `local GetColor = ns.GetColor`, `ns.BuildFormatPattern(...)` patterns, `ns.L` bound at the top of `Data/Data.lua`), so a file loads after whatever defines what it captures.
- **Data block**: `Data/Flavor.lua` first (folder files branch on `ns.IS_DISCOVERY`), `Data/Default-Settings.lua` last (its defaults read `ns.GREED` and friends from `Data/Data.lua`).
- **Out-of-block file**: `Diagnostics/Options-Diagnostics.lua` loads in the Options block, just before `Options/Options.lua`, because it captures `ns.OptionsKit` at load.
- **Libraries**: `AceConfigCmd-3.0` loads before `AceConfig-3.0.lua`, which `LibStub`s it at file scope.
- **TOC differences**: the four TOCs match line for line except `## Interface`, `## X-Flavor` and the data-folder lines. The Vanilla TOC lists both `Data/Vanilla/` and `Data/Discovery/`; each file returns early on the wrong `ns.IS_DISCOVERY`. The Mists TOC leaves out `Features/Lockbox-Tooltips.lua` (no Lockpicking skill line). A test holds all of this, `leftOut` included.
- **Folders in no TOC**: `Data/Wrath/` and `Data/Mainline/` (also stripped by `.pkgmeta`). The seven parked files are in no TOC but ship in the zip (README-Notes exception).
- **Globals**: `GogoLootDB`, `SLASH_GOGOLOOT1`, `SlashCmdList.GOGOLOOT`, plus five named frames: `GogoLootEventFrame`, `GogoLootTradeAnnounceCheckbox`, `GogoLootLootToastAnchor`, `GogoLootScanTooltip` and `GogoLootMenu` (reasons under Scan Tooltip and Mini-map Button and Menu). Parked files add `GogoLootLootMasterFrame`, `GogoLootLootTrackerFrame`, `GogoLootDropsCopyFrame`, `GogoLootDisqualifyDialog` and `StaticPopupDialogs.GOGOLOOT_VOID_ROLLS`. Everything else lives on `ns`. LibDBIcon names the mini-map button frame itself.

## Architecture

### Event Loop

- **Files**: `Features/Core.lua` (dispatcher, `ns.EVENT_NAMES`), `Diagnostics/Code-Reports.lua` (Event Registration probe), `Diagnostics/Event-Log.lua` (tap target).
- **One frame**: `GogoLootEventFrame`. `ns.eventHandlers[event]` lists handlers in registration order, which is TOC order. Modules never call `frame:RegisterEvent`.
- **`ns:RegisterModuleEvent(event, handler, unit?)`**: registers the event the first time it is asked for, appends the handler every time.
- **Drift guard**: an event missing from `ns.EVENT_NAMES` prints a developer warning once, before the validity check (so a client-missing event warns too). `ns.EVENT_NAMES` is alphabetical and is what the Event Registration probe and the Event Log privacy check (`LogsChat` in `Diagnostics/Options-Diagnostics.lua`) read, so they see on-demand registrations absent from the live table.
- **Invalid events**: `C_EventUtils.IsEventValid` false drops event and handler silently, because `RegisterEvent` would throw and stop the asking file mid-load. Only the Diagnostics probe reports it.
- **Unit filters**: `unit` registers through `RegisterUnitEvent`. One filter per event: the first registration's unit wins; a different unit later warns once (`eventUnits`, `warnedUnitConflicts`). Both `UNIT_SPELLCAST_SUCCEEDED` users ask for `"player"`.
- **Fan-out**: each handler runs through `securecallfunction`; an error reaches the error handler and later handlers still run.
- **Diagnostics tap**: `OnEvent` reads `ns.diagnostics.logging` (`Diagnostics/Diagnostics-Core.lua`) unguarded, so Diagnostics-Core loads on every flavor.
- **Early warnings**: `PrintDeveloperWarning` falls back to `print`; `ns:PrintMessage` doesn't exist until `Features/Announcements.lua` loads.
- **`ns:UnregisterModuleEvent`**: removes from the live list `OnEvent` walks with `ipairs`. Its only caller, `Options/Options-Utilities-Item-Cache.lua`, unregisters from a named-timer callback, never inside the handler.
- **`LOOT_READY` order**: Speedy Loot's handler empties the slots; see Speedy Loot.
- **Probe isolation**: the Event Registration probe registers each `ns.EVENT_NAMES` entry on a separate, handler-less frame, never the dispatcher.
- **Parked events**: `ns.EVENT_NAMES` also lists events only parked files register: `ENCOUNTER_END`, `CHAT_MSG_RAID_WARNING`, `CHAT_MSG_PARTY*`, `CHAT_MSG_RAID*`, `CHAT_MSG_INSTANCE_CHAT*`. `CHAT_MSG_SYSTEM` and `CHAT_MSG_ADDON` are live (Raid Roll Winner).
- **Who listens** (live files, registration order within each):
  - `Features/Core.lua`: `ADDON_LOADED`, name-guarded (see Saved Variables → Migration Chain for what it runs).
  - `Features/Announcements.lua`: `LOADING_SCREEN_ENABLED`/`_DISABLED` (status channel quiet window), `PLAYER_LOGIN` (welcome).
  - `Features/Announcements-Trade.lua`: `TRADE_ACCEPT_UPDATE`, `TRADE_REQUEST_CANCEL`, `UI_INFO_MESSAGE`, `TRADE_SHOW`.
  - `Features/Announcements-Trade-Checkbox.lua`: `TRADE_SHOW`, `TRADE_CLOSED`.
  - `Features/Auto-Loot.lua`: `PLAYER_ENTERING_WORLD`.
  - `Features/Loot-Sounds.lua`: `UNIT_SPELLCAST_SUCCEEDED` (player), `LOOT_OPENED`, `LOOT_CLOSED`, `CHAT_MSG_LOOT`.
  - `Features/Speedy-Loot.lua`: `LOOT_READY`, `LOOT_CLOSED`, `UI_ERROR_MESSAGE`, plus loot-window hooks (see Speedy Loot).
  - `Features/Automated-Opening.lua`: its scan triggers, `UNIT_SPELLCAST_SUCCEEDED` (player), `UI_ERROR_MESSAGE`, `LOOT_READY`/`LOOT_OPENED`; see Automated Opening.
  - `Features/Opening-Notices.lua`, `Features/Loot-Toasts-Winning-Rolls.lua`: `CHAT_MSG_LOOT`.
  - `Features/Lockbox-Tooltips.lua`, `Features/Loot-Toasts-Handle.lua`, `Features/Character-Rule-Stats.lua`: `PLAYER_LOGIN`.
  - `Features/Loot-Toasts.lua`: `CHAT_MSG_LOOT`, `BAG_UPDATE_DELAYED`.
  - `Features/Loot-Toasts-Money.lua`: `CHAT_MSG_MONEY`, `CHAT_MSG_CURRENCY`.
  - `Features/Standard-Loot-Messages.lua`: `PLAYER_ENTERING_WORLD`, `UPDATE_CHAT_WINDOWS`.
  - `Features/Blizzard-Roll-Won-Window.lua`: `PLAYER_ENTERING_WORLD`.
  - `Features/Master-Looter.lua`: `PARTY_LOOT_METHOD_CHANGED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, `ZONE_CHANGED_NEW_AREA`.
  - `Features/Master-Looter-Distribution.lua`: `LOOT_OPENED`, `LOOT_CLOSED`, `LOOT_SLOT_CLEARED`, `UI_ERROR_MESSAGE`, plus `hooksecurefunc("GiveMasterLoot")`.
  - `Features/Automated-Rolls.lua`: `START_LOOT_ROLL`, `CONFIRM_LOOT_ROLL`, `CANCEL_LOOT_ROLL`, `PLAYER_ENTERING_WORLD`, `PLAYER_LOGIN`.
  - `Features/Roll-Messages.lua`: no event; a `CHAT_MSG_LOOT` chat filter.
  - `Features/Roll-Macro.lua`: `PLAYER_ENTERING_WORLD`, `PLAYER_REGEN_ENABLED`.
  - `Features/Raid-Roll-Winner.lua`: `PLAYER_LOGIN`, `CHAT_MSG_SYSTEM`, `CHAT_MSG_ADDON`.
  - `Features/Tint-Tradable-Gear.lua`: `ADDON_LOADED` (every add-on's), `PLAYER_LOGIN`, `BAG_UPDATE_DELAYED`.
  - `Options/Options-Utilities-Item-Cache.lua`: `GET_ITEM_INFO_RECEIVED`, on demand, self-unregistering.

### Combat Lockdown

- **Files**: `Features/Automated-Opening.lua`, `Features/Roll-Macro.lua`, `Options/Options-Kit.lua`. Nothing else outside Diagnostics' read-only probes tests combat.
- **Refuses**: `ns:OpenOptionsPanel` in `Options/Options-Kit.lua`, the kit's standard guard (string from `Kit.SetText` in `Options/Options-Utilities.lua`). Every opener (slash, mini-map) goes through it.
- **Automated Opening defers**: `UnitAffectingCombat("player")` holds `IsSafeToOpen`, the scan's bag walk and `OpenTick`. `OpenTick` does not re-arm, so nothing polls through a fight or battleground. `OnPlayerRegenEnabled` forces a scan (`ns.ScheduleOpeningScan(true)`); `OnUpdateStealth` does the same on leaving stealth (ignored in combat). On WoW Forever, `C_Secrets.ShouldUnitSpellCastingBeSecret("player")` also holds the tick until the next scan, because a secret cast can't be compared.
- **Roll Macro defers**: `RunOutOfCombat` stores the add or delete in `pendingAction` with its announce flag (last request wins) and replays it on `PLAYER_REGEN_ENABLED`.
- **No guard by design**: the master looter pop-up (AceConfigDialog window outside the Blizzard tree); the loot, roll and hand-out paths (raids use them in combat); `Features/Blizzard-Roll-Won-Window.lua` (`AlertFrame` isn't protected).
- **Combat secrets (WoW Forever)**: a unit name can read secret in combat; `ns.IsSecretValue` (`Features/Utilities.lua`) is the test. See Loot Destinations for the roster sweep.

### Item Data Caching

- Item info comes from `C_Item.GetItemInfo` (via `ns:SafeGetItemInfo`), nil while uncached; callers treat nil as "retry later". Live retry paths: the distribution ticker (Master Loot Distribution) and the roll retry (Roll Execution and Cold-Item Retry). The Options side lives in `Options/Options-Utilities-Item-Cache.lua`:
  - `ns.IsItemOnClient`: `C_Item.DoesItemExistByID` and not in `unavailableItems` (IDs the server answered `success = false`; WoW Forever reports some later-expansion items as existing but never serves them). Session-only.
  - `ns.IsItemOutstanding`: on the client and still uncached. A refused or missing ID never holds the watcher open.
  - Watcher: `ns.EnsureItemRefreshWatcher` registers `GET_ITEM_INFO_RECEIVED` on demand. Each answer calls `RefreshOptionsAfterDelay`, which throttles one `ns.RefreshSettings()` through named timer `ITEM_CACHE_REFRESH_TIMER` and unregisters from inside that timer once nothing watched is outstanding.
  - Two watch tables. `watchedItemLists` lasts the session: `ns:WarmItemCache` at login adds Item Overrides (`profile.ignoredItemsSolo`), the Ignore List (`profile.ignoredItemsMaster`) and the Example items (`ns.SAMPLE_ITEM_IDS`, `ns.ExampleIgnoredContainer`, `ns.ExampleLockedContainer`; `exampleItems`). `panelItemLists` is filled by `ns.WatchItemList` while a list panel builds and wiped by `ns.ForgetPanelItemLists` on `SettingsPanel` OnHide, so the Openables List's IDs are requested only when someone looks. Sanity Check joins the same way.
  - `ns:GetItemDisplayName`: icon and link, or a loading line, for Add from Bags.
- Session caches, never invalidated within a session: `knownItemNames` (`Options-Utilities-Item-Lists.lua`), `knownKindHeadings` (`Options-Utilities-Item-List-Filter.lua`), `startsQuestByItem` (Scan Tooltip), `unavailableItems`.
- The kit's `Kit.WarmItems` is deliberately unused: it can't see `success = false`.

### Master Looter Detection

- Files: `Features/Utilities.lua` (accessors, `ns:AreWeMasterLooter`), `Features/Master-Looter.lua` (`Safe*` wrappers).
- Accessors resolve once at load, per function, `C_PartyInfo` first: `ns.GetLootMethod`, `ns.GetLootThreshold`, `ns.SetLootMethod`, `ns.SetLootThreshold`; nil if neither exists. `ns.SET_LOOT_METHOD_TAKES_ENUM` records whether the `C_PartyInfo` setter won (takes `Enum.LootMethod`; legacy takes a string).
- Client facts (Classic Era 1.15.9, from code comments):
  - Legacy `GetLootMethod`/`SetLootMethod` globals are absent while `GetLootThreshold`/`SetLootThreshold` exist. The split is per function; never infer one from the other. `ns:SafeSetLootMethod` needs the `C_PartyInfo` branch for the loot-method dropdown to work.
  - `C_PartyInfo.GetLootMethod()` returns `(method, masterLooterPartyIndex, masterLooterRaidIndex)`, like the legacy global; party index is `0` when the player is ML. `method` is an `Enum.LootMethod` number there, a string only from the legacy global.
  - `Enum.LootMethod` spellings are Blizzard's: `Freeforall`, `Roundrobin`, `Masterlooter`, `Group`, `Needbeforegreed` (`FreeForAll`/`MasterLoot` read nil). `Personal` exists on MoP Classic only.
- `ns:AreWeMasterLooter()`: nil method → false; master if `method == "master"` or `Enum.LootMethod.Masterlooter`, and party index `== 0`. Raid index is not consulted.
- `ns:SafeCallLootMethod()` returns the raw triple (nil when unreadable). `ns:SafeGetLootMethod()` maps through `LOOT_METHOD_BY_ENUM` and **maps nil to `"group"`**; `ns:SafeGetLootThreshold()` falls back to Uncommon. `LOOT_METHOD_TO_ENUM` is the setter's inverse.
- `ns:SafeSetLootMethod("master")` passes `ns:GetCleanUnitName("player")` as ML (the leader who made the change; reassign from the stock ML UI).
- `ns:IsGroupLeader` / `ns:GetGroupLeaderName` check `"player"` first, since party unit ids never include the player.
- Other consumers: Speedy Loot stands down on `ns:AreWeMasterLooter()`; the mini-map menu; the `autoMasterLoot` `ns.FEATURES` record prints `MESSAGE_NOT_CURRENT_MASTER_LOOTER` when turned on while not ML.

### Master Loot Distribution

- Files: `Features/Master-Looter-Distribution.lua` (engine, manual hook, registry, error correlation); `Features/Master-Looter.lua` (API wrappers, eligibility, destinations, pop-up trigger; loads immediately before the engine). Neither calls `SendChatMessage`; group output goes through `ns:Announce`.
- **Gate**: `LOOT_OPENED` → `OnLootOpened` flushes manual entries, `ClearDistributionState`, sets `lootIsOpen`, then runs only if `ns:WillAutoMasterLoot()` (`ns:AreWeMasterLooter()` + `autoMasterLoot` + inside a `raid`/`party` instance unless `autoMasterLootOutsideInstances`).
- **Scan**: `RunDistributionPass` builds `BuildCandidateMap` fresh each pass, walks slots last to first, calls `TryDistributeSlot` on each not in `distributedSlots`.
  - Candidate map: exact lowercased candidate name, plus a `ns:NormalizePlayerName` alias only when exactly one candidate normalizes to it and no exact key holds it. `Bob` + `Bob-OtherRealm`: no alias; destination `bob` reaches the same-realm key, the cross-realm one is unreachable by a saved destination (left for manual).
  - `ResolveDestinationCandidate`: `"self"` → `ns:GetLowercaseUnitName("player")`; looks up the normalized key, then raw lowercase (realm-suffixed saved values still match).
  - WoW Forever: candidates read `First Last`, and destinations are stored that way via `ns:GetCleanUnitName`.
- **Distribute**: `TryDistributeSlot` gate order: no link (gold/empty) → no item id → item info cold (*waiting*) → `ShouldSkipItemForMasterLoot` → `ignoredItemsMaster[itemId]` → `ns.BIND_ON_PICKUP` outside `IsInBindOnPickupTradeInstance` → quality has no `ns.RARITY_TO_CONFIGURATION_KEY` entry → `ns:IsQualityReachable` false → no candidate map (*waiting*) → no saved destination → destination not a candidate yet (*waiting*). Then marks `distributedSlots[slot]`, calls `GiveMasterLoot(slot, candidateIndex, true)`, registers a pending hand-out.
  - Third arg `true`: the client ignores it; the manual hook reads it and returns, or every automated give would also register as manual.
  - The slot is marked before the give resolves: a refused give is reported (registry) but never retried; the item stays in the window.
  - A destination that never becomes a candidate (range, left group, ambiguous cross-realm) is never re-routed.
- **Retry ticker** (`StartDistributionTicker`): `C_Timer.NewTicker` at `DISTRIBUTION_RETRY_INTERVAL`, capped at `DISTRIBUTION_MAX_RETRIES`, stops on window close or `DISTRIBUTION_QUIET_TICKS` consecutive quiet passes. Quiet = nothing handed out **and** no slot waiting; only the three *waiting* gates count, so ignored/skipped/unassigned slots never hold it open, while an absent destination keeps it running to the cap. Covers `GetMasterLootCandidate` returning nil for the first frames after `LOOT_OPENED` and cold item info.
- **Manual hook**: registered only if `GiveMasterLoot` is a function; requires `ns.db`, `ns:AreWeMasterLooter()`, `IsInGroup()`, a slot link and a candidate name. Registers with `isManual = true`, `silentSuccess = not announceMasterLootManual`. Announced whatever the quality.
- Diagnostics mirrors the gate order: `MasterLootSlotVerdict` and its own candidate builder in `Diagnostics/Manifests.lua`.

### Item-Type Skips

- Files: halves in `Features/Utilities.lua`; composite `ShouldSkipItemForMasterLoot` local to `Features/Master-Looter-Distribution.lua`. Constants (`ns.ITEM_CLASS_RECIPE`, `ns.ITEM_CLASS_QUEST`, `ns.ITEM_SUBCLASS_*`, `ns.BIND_QUEST_ITEM`) in `Data/Data.lua`.
- `ns:IsNeverAutomatedItem`: legendary quality (bare literal), `ns.ITEM_CLASS_RECIPE`, misc-class mounts and companion pets. Absolute; no list opts back in. Nil info → true.
- `ns:IsQuestClassItem`: `ns.ITEM_CLASS_QUEST` or `ns.BIND_QUEST_ITEM`. Nil info → true.
- **Why two halves**: the AQ/ZG war-effort tokens the default Item Overrides list exists for report the quest class. The roll path runs never-automated, then Item Overrides, then quest-class (Roll Decision); one combined skip ahead of the list would make those entries unreachable.
- **Why a composite**: distribution has no per-item instruction, so it asks one question: never-automated always, quest-class unless `autoMasterLootQuestItems` (reaches nothing else, not the roll path).
- `autoMasterLootQuestItems` is for boosting a character the same player controls; ships off. A quest item still has to clear the loot threshold (tooltip `MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION` says so); where the threshold list floors at Uncommon (`ns.EXPANSION >= 2`, `BuildThresholdValues`), few reach it.

### Pending Hand-out Registry

- Files: `Features/Master-Looter-Distribution.lua`.
- `GiveMasterLoot` returns at once; success shows only as `LOOT_SLOT_CLEARED`, failure as a later `UI_ERROR_MESSAGE` that names no item. Each give registers its own entry (`RegisterPendingLootAnnouncement`: id, `order` from `handoutSequence`, slot, link, item id, display name, `isManual`, `silentSuccess`) and arms fallback timer `HANDOUT_TIMER_PREFIX..id` for `HANDOUT_FALLBACK_DELAY`.
- Errors go to the **oldest** pending entry (`ResolveOldestHandout`): the server answers in order.
- Outcomes:
  - Success: `OnLootSlotCleared` → `ResolveHandoutForSlot` → `EmitLootAnnouncement` (`MESSAGE_GAVE`) unless `silentSuccess` or not grouped. Slot clears with no entry (player looted it) are ignored.
  - Known failure: mapped error id → oldest entry → `ReportLootError`.
  - Silent failure: `ResolveSilentHandout` reports `ERROR_DISTRIBUTION_FAILED` only if the window is open and the slot still holds the same item id; anything else is ambiguous and stays quiet.
  - Aborted: `LOOT_CLOSED` / next `LOOT_OPENED` → `FlushPendingManualAnnouncements`, then `ClearDistributionState` drops the rest.
- **Confirm-only for automated success, flush for manual**: an unasked-for false "Gave X to Y" is worse than a missed line; a manual give is owed a record, and `LOOT_CLOSED` is local while confirmation is a round trip (last item, Escape, range). Entries are removed as they emit, so no double announce.
- **Failure reporting ignores the success toggles**: both paths always register; automated sets `silentSuccess` from `announceMasterLootAuto` and `announceMasterLootAutoThreshold`, manual from `announceMasterLootManual`.
- **Batching** (`ReportLootError` / `FlushLootError`): keyed by display name + locale key, debounced `ERROR_BATCH_DELAY` on `ERROR_TIMER_PREFIX..key`, one list via `ns:AnnounceParts`. Items reported once stay in `batch.reported` for the loot session so ticker retries stay quiet. `ClearDistributionState` flushes pending batches first. When not grouped or `lootNotifications` is off, `FlushLootError` **prints the list to the ML** via `ns:PrintMessage` (the manual tooltip promises a failure is reported either way). `ERROR_*` templates take two args: player, item list.
- **Error ids**: `ERROR_CONSTANT_TO_LOCALE_KEY` maps `ERR_*` constant names to `ERROR_*` locale keys, resolved lazily through Game Message IDs; exported as `ns.LOOT_ERROR_CONSTANTS`.
  - Every mapped constant describes the **recipient**. Deliberately absent: `ERR_INV_FULL`, `ERR_LOOT_BAG_FULL`, `ERR_ITEM_MAX_COUNT` (ML's own bags) and `ERR_TOO_FAR_TO_INTERACT` (ML's own clicks). Range is `ERR_LOOT_TOO_FAR`. `ERR_LOOT_MASTER_OTHER` maps to the vague `ERROR_DISTRIBUTION_FAILED`.
  - Unmapped id, or a mapped id with an empty registry: ignored (some other red error).
  - `ExtractErrorId` takes the first numeric argument, not argument one.

### Loot Destinations

- Files: state and logic in `Features/Master-Looter.lua`; rows in `Options/Options-Master-Looter.lua`; `ns.DESTINATION_LOOT_WINDOW`, `ns.RARITY_TO_CONFIGURATION_KEY`, `ns.QUALITY_DISPLAY_NAMES` in `Data/Data.lua`.
- `ns.db.profile.destinations`: quality key → `"self"` or a normalized player name. **Empty by default**: unset = nobody picked = stays in the loot window. A seeded `"self"` would be re-applied by AceDB each login and read as a choice nobody made.
- **Loot Window** (`ns.DESTINATION_LOOT_WINDOW`) leads every dropdown and is never saved: `ns:GetDestinationChoice` reads unset as it; a quality row's `set` clears on it (no announce); `ns:SetAllDestinations` clears every quality and returns before announcing. Distribution reads only the saved table.
- Dropdown values/order: `ns:GetGroupMemberNames` / `ns:GetGroupMemberSorting` (Loot Window, Self, then members A-Z; the dropdown otherwise sorts by key).
- `ns:GetSharedDestination` (Send All Loot To readback): compares only reachable qualities, nil when they disagree; tracks *whether a quality was seen*, since unset is a value. `ns:GetSharedDestinationChoice` returns Loot Window while no reachable quality has anybody. `ns:SetAllDestinations` writes only reachable qualities.
- Announcements: `ns:AnnounceDestinationSet` (`MESSAGE_DESTINATION_SET`) on every per-quality pick, back to self included; `MESSAGE_DESTINATION_SET_ALL` from Send All; both need grouped + `announceDestinations`. `GetDestinationDisplayName` resolves `"self"` to the player's name, so the group never reads "Self".
- **Scope resets** (one master-loot setup):
  - Loot method changed: `ClearDestinationsOnLootMethodChange` compares against `lastObservedLootMethod`, refreshed from both `PARTY_LOOT_METHOD_CHANGED` and `GROUP_ROSTER_UPDATE` (the method event is the leader's action, may not reach every member, and may beat the API). Tracking the method, not the event, keeps an ML reassignment from wiping a setup. Starts nil so the first reading records instead of resetting.
  - Left group (`OnGroupRosterUpdate`): `ResetAllDestinations` (to unset, never Self), forget the observed method, `wasMasterLooter = false`, return early.
  - Named destination left (`CheckDestinationsForLeavers`, only while readable, grouped and ML): reachable qualities they held → `"self"`, one line per leaver (`MESSAGE_DESTINATION_LEFT`, or `_LEFT_ALL` when they held every reachable quality) if `announceDestinations`; unreachable qualities they held → unset silently (lowering the threshold later must not reveal a Self nobody chose).
  - `GetCurrentGroupMemberLookup` returns nil (sweep skipped) when any existing unit can't be named (secret on WoW Forever, or not loaded), so an unnameable member never reads as a leaver.
- **Settle window / `IsLootStateUnreadable()`**: true while `isZoneChangeSettling` or `ns:SafeCallLootMethod()` is nil. Method reset, leaver sweep and pop-up skip such readings and **do not record them**. `BeginZoneChangeSettle` (armed by `PLAYER_ENTERING_WORLD` except login/reload, and `ZONE_CHANGED_NEW_AREA`) holds `ZONE_SETTLE_SECONDS` on `ZONE_SETTLE_TIMER`, then calls `OnGroupRosterUpdate` so everything frozen is re-read against pre-zone state.
- **Panel repaint**: `GROUP_ROSTER_UPDATE` repaints (`ns.RefreshSettings`) only when `PanelSignature` (sorted names, leader, method, threshold) changes, and only while `IsRosterOnScreen` (an options panel or the pop-up); off screen the signature is marked stale. `PARTY_LOOT_METHOD_CHANGED` always refreshes.
- **Panel layout** (`ns.BuildMasterLooterOptions`): description + `ns.FeatureSwitch("autoMasterLoot")`, its sub-toggles (Also Outside Instances, Include Quest Items), Loot Destinations (no-destination note, Send All Loot To, `DESTINATION_QUALITIES` rows Epic down via `Kit.SubLabelRow` captioned in quality color), Group Loot Settings (leader note, method, threshold, pop-up toggle), Tradable Gear Tint.
  - What tunes automation hides while the switch is off (`WillAutoMasterLoot` ignores it then). `HideWhenAutomationOff` composes with a row's own `hidden`; quality rows hide via `HiddenQualityRow` (off or below threshold); `MASTER_LOOTER_NO_DESTINATIONS_NOTE` shows only while no reachable quality has anybody (`NoDestinationNoteHidden`).
  - Group Loot Settings never hides with the switch: method/threshold are the group's, and the pop-up opens regardless of automation. Dropdowns disabled unless `ns:IsGroupLeader()`; `ns.AddLeaderNoteRow` names the leader once (solo: `MASTER_LOOTER_SOLO_NOTE`).
  - Threshold row (and its spacer) hides under `THRESHOLDLESS_LOOT_METHODS` (`ns.IsLootThresholdIrrelevant`). `BuildThresholdValues` offers down to Poor only below `ns.EXPANSION` 2 (WoW Forever counts as 1). Loot method values add Personal only where the client names it.
- Ignore List: child panel `Options/Options-Master-Looter-Ignore-List.lua`, `ignoredItemsMaster`, seeded from the flavor's `ns.DEFAULT_IGNORE_LIST_MASTER` via `ns:BuildDefaultIgnoreListMaster` (refills when empty). Uses `ns.AddFeatureOffLine` rather than hiding.

### Master Looter Pop-up

- Files: trigger `CheckMasterLooterPopup` in `Features/Master-Looter.lua`; window `Options/Options-Master-Looter-Popup.lua`; registered (never `AddToBlizOptions`) in `Options/Options.lua` as `ns.OPTIONS_REGISTRY.MasterLooterPopup`.
- Opens on every false→true of `ns:AreWeMasterLooter()` while `masterLooterPopup` is on. `wasMasterLooter` starts false, so already-ML at login/reload counts. Fed by both `PARTY_LOOT_METHOD_CHANGED` (leader names you) and `GROUP_ROSTER_UPDATE` (role falls to you when the holder leaves; no method event accompanies that).
- Zoning reads as demote-then-promote; guarded by `IsLootStateUnreadable()`.
- AceConfigDialog standalone window: Ace widget styling, outside the Blizzard tree, unprotected.
- Rows come from shared builders so panel and pop-up can't drift: `ns.AddPopupToggleRow`, `ns.FeatureSwitch("autoMasterLoot")`, `ns.AddDestinationMessagesRow` (`Options/Options-Announcements.lua`, hides with `lootNotifications`), `ns.AddLeaderNoteRow`, `ns.AddLootMethodRow`, `ns.AddLootThresholdRow`, `ns.AddSendAllDestinationRow`. Every setter ends in `ns.RefreshSettings()`, so both surfaces repaint.
- Send All Loot To hides in the pop-up unless method is `"master"` and automation is on (the panel hides it only on automation off).
- Fixed size: `POPUP_WIDTH`/`POPUP_HEIGHT` via `SetDefaultSize`, `EnableResize(false)` after `Open`. AceConfigDialog sizes from its status table, not content, so hidden rows don't shrink it; height is hand-measured for the fullest state. `ns.IsMasterLooterPopupShown` reads `AceConfigDialog.OpenFrames`.

### Roll Decision

- `ns.DecideRoll(itemIdentifier, itemInformation, itemLink, quality, rules, classFile, level, inRaid)` in `Features/Automated-Rolls.lua`. Pure: reads profile settings but no character state; the caller passes rules, class, level. Returns the roll (`ns.NEED`/`ns.GREED`/`ns.PASS`, nil = leave the roll window up) and a reason string (`OFF`, `NEVER`, `OVERRIDE`, `QUEST`, `LOW_LEVEL`, `WANTED`, `EVERYTHING_ELSE`, `BIND_ON_PICKUP`, `MANUAL`, `QUALITY`, `ABOVE_QUALITY`).
- Three callers, one decision: `EvaluateRoll` (live roll), `Decide` in `Options/Options-Sanity-Check.lua` (passes `inRaid`), `RollVerdict` in `Diagnostics/Manifests.lua` (Open Rolls, Roll Verdicts). `inRaid == nil` means the group the player is in (`IsInRaid()`).
- Gate order is the design:
  1. `autoGreed` master switch. Off means off, Item Overrides included.
  2. `ns:IsNeverAutomatedItem` (Item-Type Skips). No list entry gets past it.
  3. Item Overrides (`customRollList` on, entry in `profile.ignoredItemsSolo`). `ns.MANUAL` returns nil; anything else returns its roll. Bypasses quest skip, Character Rules, BoP guard and threshold.
  4. `ns:IsQuestClassItem`. Unlisted quest items never roll.
  5. Character Rules (`ns.CharacterRuleVerdict`; only gear it judges):
     - Low-Level Gear first: any judged verdict (wanted too) Greeds when `ns.IsLowLevelGear` and quality <= context threshold, BoP allowed by the context, context action not `ns.MANUAL`.
     - `WANTED` returns nil at any quality.
     - `UNWANTED` (context not Manual): Everything Else `ns.MANUAL` returns nil; else rolls the Everything Else action if BoP-ok and quality <= context threshold. Past the threshold falls through.
  6. BoP guard: `bindType == ns.BIND_ON_PICKUP` with the context's Include Bind on Pickup off returns nil.
  7. Context action `ns.MANUAL` returns nil.
  8. Threshold: `quality <= threshold` rolls the context action.
- Why 3 before 4 and why 2 and 4 are separate functions: Item-Type Skips.
- Context settings: local `GetContextRollSettings(inRaid)` returns action, threshold and `ns.RollsBindOnPickup(inRaid)`: `autoRollAction{Party,Raid}`, `autoRollThreshold{Party,Raid}`, `rollBindOnPickup{Party,Raid}`. The Party set also covers the ungrouped roll. Everything Else shares the context's Up to Quality; it has no cap of its own.
- No loot-method check: GogoLoot answers every `START_LOOT_ROLL`; master loot just raises fewer roll windows.

### Roll Execution and Cold-Item Retry

- `Features/Automated-Rolls.lua`. `START_LOOT_ROLL` → `EvaluateRoll(rollId)`, which re-reads everything each call so a retry tick behaves exactly like the event.
- `EvaluateRoll` returns true = decided (rolled or not), false = item unresolved: nil `GetLootRollItemLink` or nil `ns:SafeGetItemInfo`. A nil link is a cold item, not a dead roll (Blizzard's `GroupLootFrame_OnShow` bails the same way); it is the normal state of a token's first drop of the session.
- Quality passed to `DecideRoll` is `GetLootRollItemInfo`'s, but a roll is never decided without full item info (the class/subclass skips need it).
- `ScheduleRollRetry`: named timer `ROLL_RETRY_TIMER_PREFIX .. rollId`, re-armed each `ROLL_RETRY_INTERVAL`; `ns:IsTimerPending` is the duplicate guard. `CANCEL_LOOT_ROLL` cancelling that name is the teardown. `ROLL_RETRY_MAX_ATTEMPTS` only bounds a cancel that never arrives (sized past the roll window), never a give-up point. No liveness probe in the tick: the only read that could answer is the same nil link.
- `ExecuteRollOverride` maps roll to `RollOnLoot`: Need → Need if `canNeed`, else Greed if `canGreed`, else nothing; Greed only if `canGreed`; Pass always. Threshold rolls and overrides share it.
- `ExecuteTrackedRoll` records the id in `rollsInitiatedByAddon` first, so `CONFIRM_LOOT_ROLL` auto-confirms bind dialogs only for GogoLoot's rolls. Confirm and cancel clear the entry.
- Print Item in Chat (`printRolledItems`): `PrintRoll` prints `MESSAGE_ROLL_PRINT` / `MESSAGE_ROLL_PASS_PRINT` with the roll actually made (fallback Greed reads as Greed), because the roll window closes the moment GogoLoot rolls. A roll left alone prints nothing.
- Default-on notice: `autoGreed` defaults on, so every player who never set it has it on; `OnPlayerLogin` prints `MESSAGE_AUTOMATED_ROLLS_ON` once per account (`global.automatedRollsOnNoticeShown`).
- Panel `Options/Options-Automated-Rolls.lua`: everything under the switch hides while `autoGreed` is off (`HideWhenRollsOff`), headers included. Per context: `rollRow*` label row, then indented `qualityRow*` (`ns.ROLL_THRESHOLD_LABELS`, also read by the mini-map menu) and `bindOnPickupRow*`, both hidden while the action is `ns.MANUAL`. Roll dropdowns pass `sorting = ns.ROLL_OVERRIDE_ORDER`.

### Item Overrides

- `Options/Options-Item-Overrides.lua`; decided in Roll Decision step 3. The saved table keeps the name `profile.ignoredItemsSolo`; the file, `ns.OPTIONS_REGISTRY.ItemOverrides` and `ITEM_OVERRIDES_*` keys follow the panel name.
- Own switch `customRollList`, nested under `autoGreed`. The panel shows `ns.AddFeatureOffLine(args, 3, "autoGreed")` instead of hiding; same on Character Rules and the Sanity Check.
- Built on `ns:BuildItemListOptions`; a hidden list builds no rows. Add saves `ns.MANUAL`; Restore Defaults rebuilds from `ns:BuildDefaultIgnoreListSolo()`; `refillsWhenEmpty`.

### Character Rules

- Files: `Features/Character-Rules.lua` (verdict, starters, saved-value reads), `Features/Character-Rule-Stats.lua` (stat reader), `Data/Data.lua` (shared tables), per-flavor `Character-Rule-Gear-Types-{Folder}.lua` (rows, `CLASS_*_STARTER`, Sanity Check pools) and `Character-Rule-Stats-{Folder}.lua` (`CHARACTER_RULE_STAT_KEYS`, `CHARACTER_RULE_EQUIP_SPELLS`). Read only from `ns.DecideRoll` (plus Sanity Check tag lines and Diagnostics); distribution never reads it.
- Verdict, `ns.CharacterRuleVerdict(itemInformation, itemLink, rules, classFile)` → `ns.CHARACTER_RULE_WANTED` / `_UNWANTED` / nil, plus group and row (for Diagnostics):
  - `ns.GetCharacterRuleGearRow` by class/subclass/equip slot, never localized text. Not armor/weapon, or a `ns.CHARACTER_RULE_SKIPPED_SLOTS` slot (shirt, tabard): nil. `ns.CHARACTER_RULE_TYPELESS_SLOTS` (cloak, ring, neck, trinket): `"TYPELESS"`, stats alone decide (a cloak is cloth by subclass). `ns.CHARACTER_RULE_GEAR_SLOT_ROWS` maps `INVTYPE_HOLDABLE` to row `"HELD"` (shares armor subclass 0 with rings). Anything unlisted lands on the `catchAll` Other group's `"GEAR"` row.
  - Type not ticked: UNWANTED, no stat read (the stat read scans a tooltip, so it runs only after the type passes).
  - Stats: any found stat ticked → WANTED; found stats, none ticked → UNWANTED; no stat found → WANTED.
- Low-level: `ns.IsLowLevelGear(rules, requiredLevel, level)`; levels-below from `unwanted.lowLevelGear` (0 = off). Required level 0 counts as low-level; an unreadable level never does.
- Starters, computed live (no migration when lists change): `ns.CharacterRuleGearStarter` (catchAll always ticked), `ns.CharacterRuleStatStarter` (`everyClass` stats, crit and hit, for all; else `ns.CLASS_STAT_STARTER`). No class saved or class unlisted: only Other, crit, hit.
- Saved shape, `ns.db.char.characterRules`: `wanted[key] = true|false` only where it differs from the starter; keys from `ns.CharacterRuleGearKey` (`"ARMOR_<row>"`, `"WEAPON_<row>"`, `"OTHER_GEAR"`) and `ns.CharacterRuleStatKey` (`"STAT_<key>"`). `unwanted.action` / `unwanted.lowLevelGear` only where they differ from `ns.CHARACTER_RULE_UNWANTED_DEFAULTS` (read via `ns.CharacterRuleUnwanted`). Emptied tables are dropped. Reset to Class Defaults nils the whole `characterRules` (no confirm, README-Notes).
- Per character, not per profile (every character shares `"Default"`). The panel edits other characters through `ns.db.sv.char[key]` (the same tables AceDB serves as `ns.db.char`). `RecordCharacterClass` (`Features/Core.lua`) saves `char.classFile` at every load, for class colors/starters on other characters and so a rule-less character keeps a char section (AceDB drops empty ones). `PruneOtherClientCharacters` limits the list to this client's key style.

#### Offered stats and gear, per flavor

- `Data/Data.lua` declares every stat (`ns.CHARACTER_RULE_STATS`: `key`, `group`, `label`, `itemMods`, `everyClass`), sections (`ns.CHARACTER_RULE_GROUPS`), gear groups (`ns.CHARACTER_RULE_GEAR_GROUPS`: `types`/`starter` name tables on `ns` the flavor file fills), and Other (`ns.CHARACTER_RULE_OTHER_TYPES`, so it exists on every flavor).
- Load-time pruning, in place: `KeepOfferedStats` (`Character-Rule-Stats.lua`) drops stats not in the flavor's `CHARACTER_RULE_STAT_KEYS` and empty stat sections; `KeepOfferedGearGroups` (`Character-Rules.lua`) drops gear groups whose row table is empty (parked Wrath and Mainline folders). Panel, verdict and Gear Stats report see one list; a saved box for an unoffered stat is never read.
- MoP Classic offers no `HEALING_POWER` or `MP5` (no Mana Per 5 label on that client).

#### Stat reading

- `ns.ReadCharacterRuleStats(itemLink)` → `{ [statKey] = { source, ... } }`; sources kept for the Gear Stats report. No one source sees every stat:
  - `ITEM`: `ns.GetItemStats` (positive values on any of a stat's `itemMods`). Base item only on the Classic clients; WoW Forever also reads the random suffix and secondaries.
  - `TOOLTIP`: lines from `ns.GetItemLinkTooltipLines` matched by `StatLinePatterns`, built once from the full `ITEM_MOD_*` formats (the `_SHORT` name with the suffix stripped), never the `_SHORT` labels (several locales word the line differently). `BuildStatLinePattern` strips deDE's `%1$` and turns `%c` into a literal `+`, so a penalty never counts. Catches random suffixes `GetItemStats` can't.
  - `EQUIP`: "Equip:" lines (Classic Era, SoD, TBC carry secondaries as item spells). `EquipLinePatterns` builds one whole-line pattern per `ns.CHARACTER_RULE_EQUIP_SPELLS` spell from `C_Spell.GetSpellDescription` (player's language, numbers wildcarded) behind `ITEM_SPELL_TRIGGER_ONEQUIP`, so no per-locale patterns. Unloaded descriptions are requested (`C_Spell.RequestLoadSpellData`) and built on a later read; `PLAYER_LOGIN` requests all. Spell IDs word differently per client, so each folder keeps its own list; folders with nothing to match declare `{}`.
- The verdict reads the live roll link (suffix included); Sanity Check reads the base link from `C_Item.GetItemInfo(id)`.

#### Panel

- `Options/Options-Character-Rules.lua`, a builder (rebuilt each open, so new characters appear). `childGroups = "tree"`, one node per character keyed by its AceDB char key. `Options/Options.lua` calls `Kit.PrepareTree("CharacterRules", ...)` so the tree opens on the current character, reset on every hide.
- Page order: class line (`CHARACTER_RULES_CLASS`), Low-Level Gear row (`ns.CHARACTER_RULE_LOW_LEVEL_ORDER` / `_LABELS`), gear groups (armor in listed order, weapons by client name via `sortByLabel`; Other as one full-width toggle with `CHARACTER_RULES_OTHER_GEAR_NOTE`, since a multiselect truncates names), stat groups (secondary sorted by label), Everything Else (`ns.CHARACTER_RULE_UNWANTED_ORDER`), Reset.
- Each list is a `multiselect` keyed `"01"`, `"02"`, ...; `CHECKBOX_WIDTH` fits two per tree row.
- Captions: `labelGlobal` (game's own) when the client has it, else the locale `caption` (`GroupCaption`).

### Loot Roll Sanity Check

- `Options/Options-Sanity-Check.lua`, child panel of Automated Rolls; the mini-map menu links it.
- `SECTIONS` (Trash and Dungeon Bosses with `inRaid = false`; Raid Bosses `inRaid = true`), each drawing `DROPS_PER_SECTION` from `ns.SANITY_CHECK_TRASH` / `_DUNGEON_BOSSES` / `_RAID_BOSSES` (flavor Gear-Types file). Rows are `{ itemId, kind }`, kind `UNCOMMON`/`RARE`/`EPIC_BOE`/`EPIC`/`OTHER`.
- `DrawFrom`: skips items not on the client (`ns.IsItemOnClient`), takes each section's `minimum` per kind first (`KIND_ORDER`), fills from the rest, shuffles. Sorts leftovers first so a seeded `math.random` draws reproducibly. `ns.DrawSanityCheckDrops` (Pick New Drops, or first build) replaces the draw until then or a reload. Drawn items are watched (`ns.WatchItemList`); a row the server refuses hides.
- Outcome via the real `ns.DecideRoll` with the current character's rules/class/level and the item's own quality. Reason text from `REASONS` (reason → locale key); `QUEST` shows the client's `ITEM_BIND_QUEST`. Tag line: binding label plus stats `ns.ReadCharacterRuleStats` finds.

### Safety Warnings

- `Features/Automated-Rolls.lua`, `CheckRollSafety`. `PLAYER_ENTERING_WORLD` (skipped on `isReloadingUi`) arms `SAFETY_WARNING_TIMER` after `SAFETY_WARNING_DELAY`, so a burst of loading screens checks once and the line lands below zone-in chatter.
- Warns when `autoGreed` and `rollSafetyWarning` are on, instance type is in `SAFETY_WARNING_INSTANCE_TYPES`, and the context action (`GetContextRollSettings()`) is in `SAFETY_WARNING_ACTIONS` (Need or Pass: both give loot away unasked).
- Repeat suppression: same instance key (`GetInstanceInfo` instance ID, else name) and action within `SAFETY_WARNING_REPEAT_SECONDS` stays quiet (corpse runs). Session memory only.
- `ns.BuildRollSafetyWarning(action, threshold)` → `MESSAGE_ROLL_SAFETY_WARNING`; `ns.PlayRollSafetyWarning` plays `ns.ROLL_SAFETY_WARNING_SOUND_FILE` on Master (heard with effects off) when `rollSafetyWarningSound`; the panel's speaker and example reuse both.

### Roll Messages

- `Features/Roll-Messages.lua`. One `CHAT_MSG_LOOT` filter at file scope (`ChatFrameUtil.AddMessageEventFilter`, else legacy `ChatFrame_AddMessageEventFilter`). A filter changes only drawing; every `CHAT_MSG_LOOT` handler still hears hidden lines.
- `HidingRollMessages()` = `autoGreed` and `hideRollMessages`: hides nothing while the master switch is off.
- Hides `ns.IsRollChatterMessage` lines. Won lines (`ns.ParseRollWonMessage`) hide only while the winner summary prints (`ns.PrintingWinnerSummary`, also the panel example's visibility). Loot lines never.
- Winner summary: `winnerSummary` (`ns.WINNER_SUMMARY_PRINT` / `_NONE`). `ns.OnRollWon(winnerName|nil, itemLink, rollText|nil)` prints `MESSAGE_ROLL_WON_PRINT`, `MESSAGE_ROLL_YOU_WON_PRINT` or their `_NO_ROLL_` forms; name class-colored via `ns:GetGroupMemberClassColor`, plain once the roster no longer holds them. Fed by `ns.RecordRollLine` (see Loot Toasts → Winning rolls), so it depends on `Features/Loot-Toasts-Winning-Rolls.lua` loading.

### Roll Macro

- `Features/Roll-Macro.lua`. One General (account-wide) macro while `ns.db.global.rollMacro` (global because the macro is). `ns.ROLL_MACRO_NAME`, `ns.ROLL_MACRO_ICON` (a file ID, since `GetMacroInfo` returns one), `ns.ROLL_MACRO_BODY` (`Data/Data.lua`): one `/run` choosing `RandomRoll`'s top by `GetMouseButtonClicked()`.
- `AddRollMacro`: exists → `EditMacro` only if icon or body differ (body compared with trailing whitespace stripped; the client may add a newline). Missing → `CreateMacro` under `pcall` (throws on a full General tab). Failure prints `ROLL_MACRO_FULL_LOADING` on every switch-on and once a session for load attempts (`warnedMacrosFull`).
- Kept, not just made: `PLAYER_ENTERING_WORLD` re-adds/repairs while on. Deleted only by switching off (`ns.ApplyRollMacro`, from the `rollMacro` `ns.FEATURES` record). Combat: see Combat Lockdown.
- Panel `Options/Options-Roll-Macro.lua`: switch, three click rows (`MENU_CLICK_*` captions in a column measured by `ns.MeasureCaptionPixels` plus `CLICK_COLUMN_PADDING_PIXELS`), then the Raid Rolls section (shown regardless of the macro switch).

### Raid Roll Winner

- `Features/Raid-Roll-Winner.lua`. On `CHAT_MSG_SYSTEM` only (anyone can type a roll's words in chat), `ns.ParseRandomRollMessage`; counts a roll when `raidRollWinner` is on, grouped with at least two members, range exactly 1..`GetNumGroupMembers()`, roller in the roster.
- Winner by roster place (`ns.GetRaidRollPlayer`): raid → `GetRaidRosterInfo(place)`; party → player first, then party1-4 (party-frame order). Name read when the roll is read, so a roster change during the wait can't move it.
- `raidRollOutput`: `ns.RAID_ROLL_OUTPUT_SELF` prints `ns.BuildRaidRollPrint`; `ns.RAID_ROLL_OUTPUT_GROUP` posts `MESSAGE_RAID_ROLL` via `ns:Announce`, but prints while `lootNotifications` is off.
- Dedup across GogoLoot users: `PostWhenUnclaimed` sends a `RAIDROLL:<place>:<key>` add-on message, waits `ns.RAID_ROLL_CLAIM_WAIT`, posts only if no earlier place claimed. A claim with no place counts as place 0 and holds everyone back. Own echoes ignored. Claims forgotten after `CLAIM_MEMORY_SECONDS`.
- Registers `ns.ADDON_MESSAGE_PREFIX` at `PLAYER_LOGIN` itself, because parked Roll Calls (which also registers it) isn't loaded.

### Speedy Loot

- `Features/Speedy-Loot.lua`; panel `Options/Options-Speedy-Loot.lua` (one `ns.FeatureSwitch("speedyLoot")`). Setting `ns.db.global.speedyLoot`.
- Owns the add-on's one slot-emptying `LOOT_READY` handler, `OnLootReady`: `HookReplacementLootWindows` → `ns.StampWorldLoot` → `ns.PlayPickPocketSound` → `RunSpeedyLoot`. Anything that reads loot slots on `LOOT_READY` goes in here before the pass; other modules hear `LOOT_READY` only for the fact it fired (Automated Opening's open confirmation).
- `RunSpeedyLoot` gates, in order: switch; `ns:AreWeMasterLooter()` (stands down for the whole master-loot session, wider than `WillAutoMasterLoot`: `LootSlot` would vacuum threshold loot into the ML's bags or pop `MasterLooterFrame_Show`, which errors on some clients); Auto Loot CVar XOR `IsModifiedClick("AUTOLOOTTOGGLE")`; throttle `LOOT_THROTTLE_SECONDS`.
- Loots bottom-up (mirrors client auto loot, no index shift). Locked slot (6th return of `GetLootSlotInfo`) is still being rolled for: skipped. Non-item slots (`GetLootSlotType ~= ns.LOOT_SLOT_TYPE_ITEM`) take no space and are always taken.
- Bag model, per pass: `ReadBagSpace` once (general slots, each specialty bag with its family, keyring as `KEY_FAMILY` where `HasKeyring`: `C_ActionBar.ShouldShowKeyring` first, `IsKeyRingEnabled` fallback, since MoP defines `KEYRING_CONTAINER` with no keyring). `TakeSpaceFor` spends per item, cheapest first: a carried stack (room counted as if every stack but the last were full; `space.incoming` counts what this corpse already sent), then a family-matching specialty bag, then a general slot. A looted bag/quiver never goes in a specialty bag. Uncached item → general slot. Separate from `ns.CountFreeBagSlots` (general only).
- Window suppression: `suppressLootWindow = not leftBehind and not bagsTight`. `leftBehind` = an item with no room, or bind type BoP or nil (uncached). BoP items are still `LootSlot`ed so the client asks `LOOT_BIND`, which works only while the loot session is open. `bagsTight` = took an item and left fewer than `ns.MIN_FREE_SLOTS` general slots (hiding closes the loot before the server answers any `LootSlot`). `leftBehind` also forces `ns.GetLootWindow():Show()`. `LOOT_CLOSED` clears the flag.
- Three loot windows, one hook each: old `LootFrame` (Era, Anniversary, MoP) and ElvUI/Tukui replacements (`ns.LOOT_WINDOW_REPLACEMENTS`) get `HookScript("OnShow", HideFromOnShow)`; WoW Forever's Retail `LootFrameMixin` gets `hooksecurefunc(LootFrame, "Open", ...)` calling `Close`, `StopAllAnimations`, `HideUIPanel`. Told apart by `rawget(LootFrame, "Open")` (mixin method on the table vs widget methods behind the metatable). Replacements are hooked lazily on first `LOOT_READY`, once per frame (`hookedReplacements`).
- Refused pickup after the pass closed the loot: `closedPassAt` stamps a suppressed pass that took an item; `UI_ERROR_MESSAGE` within `ns.LOOT_BOUNCE_WINDOW` matching `ns.IsLootBounceErrorID` prints `MESSAGE_LOOT_LEFT_ON_CORPSE` with the client's reason via `ns:StatusPrint`, and plays `ns.PlayBagFullSound` for full bags only, under `ns.ClaimBagFullWarning`. Never reopens the loot.
- Openables List Ignore does not affect Speedy Loot (deliberate).

### Auto Loot CVar

- `Features/Auto-Loot.lua`. `ns:IsAutoLootNeeded()` = `global.speedyLoot or profile.autoOpen`. `ns.EnsureAutoLoot` writes `autoLootDefault` = 1 only when `ns:IsAutoLootCVarEnabled()` reads off; prints nothing (disclosed in both switch descriptions via `AUTO_LOOT_DEFAULT_TEXT`).
- Callers: first `PLAYER_ENTERING_WORLD` that needs it, after a fixed delay in `OnPlayerEnteringWorld` (`hasCheckedAutoLoot` set when scheduled); the `apply` of the `autoOpen` and `speedyLoot` `ns.FEATURES` records when turned on; `ns:ApplyProfile` while needed.
- No saved setting of its own: the two feature switches are the opt-out. Rolls, master loot and trade announcements never touch the CVar.

### Automated Opening

- `Features/Automated-Opening.lua`; panel `Options/Options-Automated-Opening.lua`. Profile keys: `autoOpen`, `autoOpenWhere` (`"ALWAYS"`/`"OUTSIDE_INSTANCES"`), `autoOpenGroup` (`"ALWAYS"`/`"SOLO_ONLY"`), `autoOpenWithFishingPole`. Hold-off rows are `Kit.SubToggleRow`s over those strings; each setter forces a scan. Timing constants in `Data/Data.lua` → Automated Opening (`ns.OPEN_TICK_INTERVAL`, `ns.SCAN_DEBOUNCE`, `ns.WORLD_LOAD_DELAY`, `ns.OPEN_RECHECK_DELAY`, `ns.OPEN_ANSWER_TIMEOUT`, `ns.OPEN_REFUSAL_LIMIT`, `ns.PICK_LOCK_RESCAN_DELAY`, `ns.STATUS_FLUSH_DELAY`).
- **Scan.** `ns.ScheduleOpeningScan(force)` returns silently until `worldReady` (`ns.WORLD_LOAD_DELAY` after an initial login/reload `PLAYER_ENTERING_WORLD`). Unforced: debounced `ns.SCAN_DEBOUNCE`, later requests absorbed (`scanPending`/`scanDueAt`).
  - Forced: setting changes, world load, `PLAYER_REGEN_ENABLED`, `UPDATE_STEALTH` (leaving stealth), Pick Lock settle (`ns.RescanAfterUnlock`, also on `TRADE_CLOSED` for boxes another Rogue unlocked), interaction close (`BANKFRAME_CLOSED`, `GOSSIP_CLOSED`, `MAIL_CLOSED`, `MERCHANT_CLOSED`, `QUEST_FINISHED`, `PLAYER_INTERACTION_MANAGER_FRAME_HIDE`, `TRADE_CLOSED`), and `LOOT_CLOSED` of a window one of our opens produced (`lootWindowFromOpen`).
  - Debounced: `BAG_UPDATE_DELAYED`, `BAG_NEW_ITEMS_UPDATED`, own `CHAT_MSG_LOOT`, other `LOOT_CLOSED`, zone change (non-initial `PLAYER_ENTERING_WORLD`), solo↔grouped flip only (`GROUP_ROSTER_UPDATE`, `wasGrouped`), main-hand `PLAYER_EQUIPMENT_CHANGED`, `PLAYER_LEVEL_UP`.
- `RunScan`: recount free slots → set `isPaused` → `AnnounceStatus`; stop if off or in combat; stop under hold `BAGS`/`INSTANCE`/`GROUP` (each lifts through a rescan); `FISHING` still builds the queue (its notice is owed only when something waits); `BuildQueue`; start tick if safe; `AnnounceFishingPoleHold`. `RunScan` and `OnScanDebounceElapsed` are file locals so a bag event allocates no closures.
- **Queue.** Flat `(bag, slot, itemId)` triple array with head/tail cursors, wiped when drained. `ShouldOpen`: `ns:GetOpeningAction == ns.OPENING_OPEN`, not in `refusedItems`, level ≤ `UnitLevel` (`ns.OPENABLE_ITEM_LEVELS` first, else 5th return of `C_Item.GetItemInfo`; uncached = tried), and not `ns.IsItemLocked` (every Open item is lock-checked, not just lockboxes).
- **Open.** `OpenTick` (`openTimerLive`: only `StartOpenTick` sets it, only `OpenTick` clears it, so one chain): combat or secret cast → return without re-arming; cast/channel → re-arm; `IsSafeToOpen` false or empty queue → stop; `IsWaitingOnPlayer` → re-arm; last open unanswered within `ns.OPEN_ANSWER_TIMEOUT` → re-arm; else `CountRefusedOpen`, pop, `C_Container.UseContainerItem` only if the same item still sits there, `RecheckSlot` after `ns.OPEN_RECHECK_DELAY` (re-queues a stack or an untaken open).
- **Refused opens** (holiday-gated items on WoW Forever, uncached level, rules no API reports): an open counts as taken on `LOOT_READY`/`LOOT_OPENED` (`OnLootAnswer` → `ConfirmOpen`) or when `RecheckSlot` sees the stack shrink (a Speedy-Loot-emptied session can close before either event reaches us). `ConfirmOpen(openedAt)` ties a recheck to its own open. Unanswered past timeout counts; `ns.OPEN_REFUSAL_LIMIT` in a row puts the ID in file-local `refusedItems` until level-up (wiped) or reload.
- **Safety gates.** `IsSafeToOpen` (stops the tick until next scan): switch; any `ns:GetAutomatedOpeningHold()` (`"BAGS"`, `"FISHING"` via `ns.IsFishingPoleEquipped` using `GetItemInfoInstant` class/subclass, `"INSTANCE"`, `"GROUP"`; also read by the mini-map menu); combat; `IsInteractionActive` (merchant, mail, trade, bank, guild bank, `AuctionFrame`/`AuctionHouseFrame`, gossip, quest, `ns.IsLootWindowShown`); `IsPlayerStealthed` (stealth, or Shadowmeld aura, treated as present while `C_Secrets.ShouldSpellAuraBeSecret` says it would read secret); `C_Secrets.ShouldUnitSpellCastingBeSecret`; `ns.CountFreeBagSlots() >= ns.MIN_FREE_SLOTS`. `IsWaitingOnPlayer` (tick waits, since no event ends these): `StaticPopup1`, `SpellIsTargeting`, `CursorHasItem`, item in `GameTooltip`.
- **Pause/resume** on `ns.MIN_FREE_SLOTS` (also Speedy Loot's bags-tight line). `AnnounceStatus` holds while an interaction window is open; `OnInteractionClosed` flushes after `ns.STATUS_FLUSH_DELAY`; a line `ns:StatusPrint` refuses stays owed (`announcedPaused` unchanged). A full-bag `UI_ERROR_MESSAGE` (`ns.IsBagFullErrorID`) pauses at once only while our open is pending; the warning (`ERR_INV_FULL` + `ns.PlayBagFullSound`) plays only if `ns.ClaimBagFullWarning`.
- Fishing pole notice: `MESSAGE_OPENING_FISHING_POLE` once a session (`toldFishingPoleHold`), only when something is queued; retried if the quiet window drops it.

### Openable Items

- `Features/Openable-Items.lua`; panel `Options/Options-Openable-Items.lua` (child of Automated Opening). Data: `ns.OPENABLE_ITEMS` (`{ [itemId] = default }`) and `ns.OPENABLE_ITEM_LEVELS` (`{ [itemId] = requiredLevel }`) in `Data/{Folder}/Openable-Items-{Folder}.lua`.
- Five defaults (`Data/Data.lua`): `ns.OPENING_OPEN`, `OPENING_UNLOCKED` (lockbox), `OPENING_IGNORE` (may hold BoP), `OPENING_IGNORE_RAID`, `OPENING_IGNORE_UNIQUE`. `DEFAULT_ACTIONS` maps each to Open/Ignore. Only `OPENING_OPEN`/`OPENING_IGNORE` are saved or offered (`VALID_ACTIONS`, `ns.OPENING_ACTION_ORDER`); the reason is data.
- API: `ns:GetOpeningDefault` (raw default, nil if unlisted), `ns:GetDefaultOpeningAction`, `ns:GetOpeningAction` (player choice else default; nil for unlisted or removed, so only listed items open; Loot Toasts' Openables row keys off it), `ns:GetOpenableItemList`, `ns:SetOpeningAction` (no-op for unlisted; setting back to default deletes the entry), `ns:AddOpeningItem` (removed listed item → its default; new item → Open), `ns:RemoveOpeningItem` (listed → `ns.OPENING_REMOVED` sentinel; added → nil), `ns:RestoreDefaultOpeningActions` (wipe), `ns:AreOpeningActionsDefault`. Every change → forced scan + `ns.RefreshSettings`.
- Saved: `ns.db.global.openingActions`, differences only, so new data and defaults reach every player with no migration.
- `ns:CanAddOpeningItem`: `C_Item.DoesItemExistByID` and no equip slot (`""`, nil or Retail's `INVTYPE_NON_EQUIP_IGNORE`), since using gear equips/binds it. The panel's `AddItem` prints `MESSAGE_ITEM_NOT_OPENABLE` for an existing item refused; nonexistent IDs drop silently.
- Reason tags/notes come from the default, never the action: `ns:GetOpeningTag` (`DEFAULT_TAGS`: client `LOCKED`, `OPENING_TAG_SEALED` for both sell-sealed reasons, `OPENING_TAG_UNIQUE`), `ns:GetOpeningNote` (`DEFAULT_NOTES`; no item names, the client's tooltip sits above).
- Bag rows (`CollectBagRows`, on demand, never cached): `ns.GetLockedBoxes` (Open + reads Locked; mini-map Locked Items, Diagnostics), `ns.GetSealedContainers` (Ignore, with tag/note; mini-map Automated Opening block).
- Panel: `ns:BuildItemListOptions` with `tagFor` (silver reason tag) and an Open/Ignore `actionColumn`; feature-off line via `ns.AddFeatureOffLine(args, 3, "autoOpen")`; Enable Ignore Notifications (`profile.openingIgnoreNotifications`) never hides, its `Kit.Example` hides while opening is off; example item `ns.ExampleIgnoredContainer` (lowest plain-`OPENING_IGNORE` ID in this flavor's data).
- Data invariants the code relies on: every `OPENABLE_ITEMS` value is one of the five defaults; every `LOCKBOX_SKILL_LEVELS` key is an `OPENING_UNLOCKED` row.

### Opening Notices

- `Features/Opening-Notices.lua`, own `CHAT_MSG_LOOT` via `ns.ParseOwnLootMessage`. Both notices need `autoOpen`.
- Open + default `OPENING_UNLOCKED` + `profile.lockboxNotifications` + `ns.LockboxScopeAllows(lockboxNotificationsScope)` → `MESSAGE_ITEM_WILL_AUTO_OPEN` via plain `ns:PrintMessage` (no cooldown).
- Ignore + `openingIgnoreNotifications` → `ns:AnnounceItemOnce` with `IGNORED_NOTICES[default]` (`MESSAGE_ITEM_IGNORED_RAID`, `_UNIQUE`) else `MESSAGE_ITEM_IGNORED` (also for player-set Ignore).

### Lockbox Tooltips

- `Features/Lockbox-Tooltips.lua` (not in the Mists TOC); panel `Options/Options-Lockboxes.lua` (child of Automated Opening, status line while opening is off). Data `ns.LOCKBOX_SKILL_LEVELS` in `Data/{Folder}/Lockbox-Skill-Levels-{Folder}.lua`. Profile keys `lockboxTooltips`/`lockboxTooltipsScope`, `lockboxNotifications`/`lockboxNotificationsScope`; scope `"ROGUES"`/`"ALL"` through `ns.LockboxScopeAllows` (`Features/Utilities.lua`).
- Skill name from the skill line, `C_TradeSkillUI.GetTradeSkillDisplayName(ns.SKILL_LINE_IDS.LOCKPICKING)` (`ns.GetLockpickingSkillName`, cached once read): never from the tooltip (circular) or the Lockpicking spell (different record, differs in esMX). Rank via `ns.GetSkillLineRankByName`, Rogue only; nil on WoW Forever. Mists' `ns.SKILL_LINE_IDS` is empty; `BuildLockboxOptions` drops the tooltip row when `ns.GetLockpickingSkillName` is nil.
- `AddLockboxLine`: one `ScanTooltipLines` pass finds our block (title `ADDON_SHORT_NAME` as substring = already added) and the client's own requirement line (pattern from `ITEM_MIN_SKILL` via `ns.BuildFormatPattern`). Two shapes: client states the requirement → add only the player's rank (none if unreadable); otherwise `ITEM_REQ_SKILL` with the required skill, green/red when rank is known.
- Hooks installed at `PLAYER_LOGIN` (behind add-ons that hooked at load): `GameTooltip:SetBagItem`, `SetInventoryItem` (bank slots where bank is container -1), and where present `SetLootItem`, `SetTradePlayerItem`, `SetTradeTargetItem`, `ItemRefTooltip:SetHyperlink` (`LINK_HOOKS`). Adds synchronously inside the build.

### Loot Sounds

- `Features/Loot-Sounds.lua`; panel `Options/Options-Loot-Sounds.lua`. Profile: `lootSoundsEnabled` (master), `lootSounds` (chime) + `lootSoundThreshold`, `pickPocketSound`. Chime `ns.LOOT_SOUND_FILE`; Pick Pocket `ns.SOUND_KIT_IDS.PICK_POCKET`. Rows carry `Kit.SoundPreview` speakers (README-Notes exception). Chime dropdown starts at Uncommon (`ns.OptionsQualityChoices(2, "+")`).
- Chime only for corpse/chest loot. `CurrentLootSource` reads slot GUID prefixes: `Creature`/`Vehicle`/`GameObject` → `"world"`; only `Item` → `"item"`; nothing → `"unknown"`. `ns.StampWorldLoot`: world opens `worldLootOpen`, item closes it, unknown leaves it. Runs on `LOOT_READY` (inside Speedy Loot's handler) and `LOOT_OPENED`. `LOOT_CLOSED` stamps `worldLootClosedAt`; the chime stays allowed for `ns.LOOT_SOUND_WINDOW` after.
- `ns.PlayLootSound` from own `CHAT_MSG_LOOT`, quality via `ns.GetLinkQuality` ≥ threshold. Group loot, item-made loot and roll wins stay silent.
- Pick Pocket: `UNIT_SPELLCAST_SUCCEEDED` (player, `ns.SPELLS.PICK_POCKET`, after `C_Secrets.ShouldUnitSpellCastingBeSecret`) arms `pickPocketAt`; `ns.PlayPickPocketSound` plays once a non-empty loot window opens within `ns.PICK_POCKET_LOOT_WINDOW`, disarming. Same two call sites as the stamp.

### Loot Toasts

- Files: `Features/Loot-Toasts.lua` (rows, stack, motion, entry points), `Loot-Toasts-Filters.lua` (`ns.IsLootToastWanted`), `Loot-Toasts-Money.lua`, `Loot-Toasts-Winning-Rolls.lua`, `Loot-Toasts-Handle.lua` (anchor, handle, intro, `ns.SetLootToastsEnabled`). Panels `Options/Options-Loot-Toasts.lua`, `Options/Options-Loot-Toast-Filters.lua` (child). All settings profile except `ns.db.global.lootToastPosition`. Switch `profile.lootToasts`, off by default.
- Item pipeline: `CHAT_MSG_LOOT` → skip if switch off or a roll line → own parse first, else group parse → `ns.ShowLootToast(link, qty, looter, ns.ClaimWinningRoll(...))` → `ns.IsLootToastWanted` → strip brackets, add `ITEM_QUANTITY`, looter (`LOOT_TOASTS_LOOTED_BY[_ROLL]`, class color via `ns:GetGroupMemberClassColor` else silver) or `LOOT_TOASTS_YOU_WON_ROLL` → `PushToast` → `EnterToast`. A group item turned down while uncached: `C_Item.RequestLoadItemDataByID` and one retry after `GROUP_ITEM_RETRY_SECONDS`.
- Filters (`ns.LOOT_TOAST_FILTER_ROWS`, `Data/Data.lua`): Mine (`lootToastMine`) / Group (`lootToastGroup`) tables keyed by row; rarity rows (Armor, Weapon, Gem, Trade Goods) add `lootToastMineQuality`/`lootToastGroupQuality`. Subclass rows (Mount, Companion Pet) win over their class row. Check order by cost: no item ID → shown; Openables (any listed item, `ns:GetOpeningAction ~= nil`); type row (+quality; unreadable quality passes); bind type BoP / `ns.BIND_QUEST_ITEM` (Quest row); quest starter last via `ns.ItemStartsQuest` (README-Notes exception). `minimumExpansion` hides a row (Gem, Currency) on older clients. Group defaults: Armor, Weapon, Quest; rows absent from defaults read off.
- Money: `CHAT_MSG_MONEY` → `ns.ParseMoney` (client `GOLD_AMOUNT`/`SILVER_AMOUNT`/`COPPER_AMOUNT`) → `ns.ShowMoneyToast` (Mine `MONEY` only; `ns.MONEY_ICON_*` by magnitude). Currency: `CHAT_MSG_CURRENCY` → `ns.ParseCurrencyMessage` (`CURRENCY_GAINED*`, fallback any currency link = 1) → `ns.ShowCurrencyToast` (Mine `CURRENCY`; icon/quality from `C_CurrencyInfo.GetCurrencyInfo`). No Group boxes: the game reports only own coin/currency.
- Winning rolls (`Loot-Toasts-Winning-Rolls.lua`): reads every `CHAT_MSG_LOOT` regardless of the toast switch, because the winner summary needs it. `ns.RecordRollLine` keeps `openRolls[historyLink or itemLink][player]` until the won line, calls `ns.OnRollWon` on every won line if defined (roll from the no-spam won line or that player's recorded roll), then holds `winningRolls[player\nlink]` for the winner's loot line to claim once (`ns.ClaimWinningRoll`). Pruned after `ROLL_RECORD_SECONDS`. Shown per side by `lootToastWinningRollMine`/`Group`.
- Stack: `active` oldest-first; `Restack` offsets from the end so the newest sits at the anchor; rows pin to a corner of `ns.GetLootToastAnchor()` (`lootToastGrowth` top/bottom × `lootToastAlign` left/right), never center. `MaxVisible` resolves `ns.LOOT_TOAST_UNLIMITED` to `math.huge`; the cap retires the oldest.
- Row: sizes on a grid scaled from `GRID_FONT_SIZE` through `GridSize` (`ROW_UNITS`, `BORDER_UNITS`, `TEXT_GAP_UNITS`, `ROW_SPACING_UNITS`, `BACKDROP_TAIL_UNITS`, `SLIDE_UNITS`); quality-colored frame (`ns.GetQualityColorRGB`), art cropped by `ICON_CROP`, rounded by two mask TGAs (`ICON_BORDER_MASK`, `ICON_ART_MASK`); `Measure` sizes text to the string (`SetWidth(0)`), truncating only past `TEXT_WIDTH_RATIO`. A test pins the default measures.
- Motion: entry staggered by `ns.LOOT_TOAST_ENTRY_INTERVAL` via `pending` + one drain timer (the test loader sets it to 0); slide = two `Translation` animations netting zero; `RestartFades` resets every non-hovered, non-sample row on each new row; Epic+ (`FLASH_MIN_QUALITY`) additive flash. `PlayFade` stamps `lootToastDuration` at play time.
- Hover (`lootToastTooltips`, off by default): `toast.hover` child over icon+text only, motion-only (never clicks), enabled only for item rows with the setting on (`TakesPointer`); tooltip anchored to the hover child; fade paused while hovered. `ns.ApplyLootToastTooltips` re-applies to live rows.
- Bag Count (`lootToastBagCount`): own-loot rows keep `countItem`; text re-read on entry and every `BAG_UPDATE_DELAYED` (the loot line can precede or follow the bag update); shown only when carried > looted.
- Fonts: LibSharedMedia list rebuilt per dropdown open (`ns.GetLootToastFontChoices`); `"DEFAULT"` = `GameFontNormal`'s face; flags carry weight (`"NONE"` → `""`); `ApplyFont` falls back keeping flags.
- Handle (`Loot-Toasts-Handle.lua`): `GogoLootLootToastAnchor`, created on first use, fixed size. Unlocked: drag to move (`ns.SaveLootToastPosition`), right-click locks, Lock Position and Disable buttons; samples (`ns.RefreshLootToastSamples`, one per cap row, `SAMPLE_COUNT_UNLIMITED` on Unlimited, random quality ≥ lowest Mine rarity quality) rebuilt on every appearance change. `ns.SetLootToastsEnabled` raises/lowers the handle and syncs Standard Loot Messages and the roll-won window. Intro: `lootToastsIntroSeen` per profile, shown at `PLAYER_LOGIN` and after `ns.ApplyLootToastSettings` (profile change, which first locks); any of the four ways out dismisses it.
- Options: everything below the switch goes through local `Add` so it hides with the switch; Stack/Text rows through `SettingRow`, which calls `ns.RefreshLootToastSamples` (or `ns.ApplyLootToastLimit` for the cap). The font size dropdown also offers a saved off-step value. Filters panel: three groups (rarity in data order; types A–Z by client name; own rows), then Bag Count and Winning Roll rows in the same columns.

### Standard Loot Messages

- `Features/Standard-Loot-Messages.lua`; dropdown beside Enable Loot Toasts (`profile.standardLootMessages`, `ns.STANDARD_LOOT_MESSAGES_DISABLE` default).
- Wanted hidden = `lootToasts` and dropdown on Disable. `ns.SyncStandardLootMessages` acts only when that differs from `ns.db.char.standardLootMessagesHidden`; hiding removes shown `LOOT`/`MONEY` groups from `ChatFrame1` and records them in `char.lootGroupsHiddenByGogoLoot`; showing restores only recorded ones. Uses `ContainsMessageGroup`/`AddMessageGroup`/`RemoveMessageGroup` (the client persists them). Waits for `ChatFrame1.isInitialized == 1`.
- Callers: `ns.SetLootToastsEnabled`, the dropdown setter, `ns:ApplyProfile`, and `ns:After(STANDARD_LOOT_SYNC_TIMER, STANDARD_LOOT_SYNC_DELAY, ...)` on `PLAYER_ENTERING_WORLD`/`UPDATE_CHAT_WINDOWS`. Prints nothing. Toasts and `print` are unaffected.

### Blizzard Roll-Won Window

- `Features/Blizzard-Roll-Won-Window.lua`. WoW Forever's `AlertFrame` answers `LOOT_ITEM_ROLL_WON` with a "You Won" alert. With `lootToasts` on and `profile.lootToastBlizzardRollWon` off, `ns.SyncBlizzardRollWonWindow` unregisters that one event from `AlertFrame`; otherwise re-registers. `SHOW_LOOT_TOAST` and other add-ons' registrations are untouched; no taint.
- `ns.HasBlizzardRollWonWindow` caches `IsEventRegistered` on first call, before any touch; Classic clients answer false, so GogoLoot never registers it there and the panel row (plus spacer) hides.
- Callers: `ns.SetLootToastsEnabled`, the option, `ns:ApplyProfile`, `PLAYER_ENTERING_WORLD`.

### Tint Tradable Gear

- `Features/Tint-Tradable-Gear.lua`; row on the Automated Master Looting panel (`BuildTradableTintRow` in `Options/Options-Master-Looter.lua`) but answers only to `profile.tradableTintEnabled` / `tradableTintColor`, independent of automation.
- Carried bags only. `PaintButton` pre-filters from `C_Container.GetContainerItemInfo` (bound, quality ≥ `ns.TRADABLE_MIN_QUALITY`), then `IsTradableGear` (`ns:SafeGetItemInfo` BoP check, then `ns.GetBagSlotTradeSeconds`). Verdicts cached as expiry time keyed `bag:slot:link`, wiped on `BAG_UPDATE_DELAYED`; `C_Timer.NewTicker(ns.TRADABLE_TINT_CHECK_SECONDS)` repaints when a kept clock runs out. `shownItemId` mismatch (window drawing something other than the live slot) → no tint.
- `TINT_ADAPTERS`: default bags (`ContainerFrame_Update` on Era/TBC, per-frame `UpdateItems` + `EnumerateValidItems` on WoW Forever), Baganator (corner widget whose `onUpdate` returns false; marker `OnHide` clears), Bagnon/Bagnonium, AdiBags, BetterBags (tint on the decoration button), ArkInventory, ElvUI. Uninstalled adapters retry on every `ADDON_LOADED` and one frame after `PLAYER_LOGIN`. `ns:RefreshTradableTints` repaints known buttons and asks redraw-capable windows (`adapter[4]`) to redraw; called from the row and `ns:ApplyProfile`. `ns:GetTradableTintAdapterNames` for Diagnostics.

### Parked Loot Windows

- In no TOC: `Features/Roll-Calls.lua`, `Loot-Master.lua`, `Drops-By-Boss.lua`, `Loot-Windows.lua`, `Loot-Master-Window.lua`, `Loot-Tracker-Window.lua`, `Options/Options-Loot-Master.lua` (README-Notes exception "Unfinished features ship parked"). `Features/Roll-Calls.lua` is the roll engine for the Loot Master/Tracker windows; `ns.ROLL_LENGTHS` / `ROLL_*_SECONDS` / `ROLL_REJECT_*` in `Data/Data.lua` are its, not Automated Rolls'.
- Guards in loaded code (keep them): `profile.lootMaster` defaults `false`; `ns.LootWindowsLoaded()` (`Features/Minimap-Menu.lua`) needs `lootMaster` and `ns.GetRollListEntries`; `/gogo master|tracker|drops` run only if `ns.ShowLootMaster` exists (`Options/Options.lua`); `Announcements-Trade.lua` calls `ns.OnLootMasterTradeCompleted` only if defined; `FEATURE_PANELS` skips the `LootMaster` row while `ns.BuildLootMasterOptions` is nil; `ns.OPTIONS_REGISTRY.LootMaster` stays defined.
- Tests load them (`FILES` in `Tests/Run.lua`); `PARKED_FILES` only lets the TOC-match test drop them. Their events stay in `ns.EVENT_NAMES`, their strings in every locale, their saved keys in `Data/Default-Settings.lua`.
- Loaded helpers they call: `ns.ParseOwnLootMessage`/`ParseGroupLootMessage` (Loot-Master, Drops-By-Boss), `ns.ParseRandomRollMessage` (Roll-Calls), `ns.GetBagSlotTradeSeconds`/`ns.GetBagItemTooltipLines` and `ns.TRADABLE_MIN_QUALITY` (Loot-Master).

### Shared Utilities

- `Features/Utilities.lua`: the one home for API differences between engines. Each accessor resolves once at load and picks by **availability, never by truthy result**. Namespaced APIs every target client ships (`C_Item`, `C_Container`, `C_AddOns`, `C_CVar`) are called directly (`ns:IsAutoLootCVarEnabled`).
  - Loot method/threshold accessors and `ns:AreWeMasterLooter`: see Master Looter Detection.
  - `ns.LOOT_SLOT_TYPE_ITEM` (`Enum.LootSlotType.Item` on WoW Forever's Retail engine, else `LOOT_SLOT_ITEM`), `ns.GetItemStats`, `ns.IsSecretValue` (`issecretvalue` or always-false).
  - `ns.GetSkillLineRankByName`: always nil on Camelot, even when another add-on (Questie) defines `GetSkillLineInfo`. A non-number skill count reads as unknown on every client.
- Colors: `ns.COLORS` / `ns.COLORS_RGB` built from `ns.PALETTE` at load. Accessors (`ns.GetColor`, `ns.GetColorRGB`, `ns.GetQualityColor[RGB]`, `ns.GetClassColor`, `ns.GetMoneyColor`) are dot functions each file aliases to a local.
- Names: `ns:NormalizePlayerName` (realm cut, lowercased) is the one comparison key. `ns:GetCleanUnitName` rejoins WoW Forever's `First Last` (`UnitName` returns the last name in the realm slot) and returns nil for a secret name. `ns:FormatPlayerName` capitalizes each word and drops the realm for chat. `ns:GetGroupMemberClassColor` scans the roster.
- `ns.MeasureCaptionPixels`: a hidden `GameFontHighlight` font string; sizes the item lists' Add button and Roll Macro's click column. Checkbox width in options units is the kit's `Kit.ToggleWidth`.
- `ns:SafeGetItemInfo` returns a table or nil (cold cache). The two skip halves: see Item-Type Skips.
- `ns.GetLootWindow`: ElvUI's or Tukui's replacement (`ns.LOOT_WINDOW_REPLACEMENTS`), else `LootFrame`; asked at loot time, never cached, because those UIs build their frames at login, after GogoLoot loads.
- `ns.LockboxScopeAllows`: the `"ROGUES"` / `"ALL"` rule both lockbox features share.

### Timers

- `Features/Utilities-Timers.lua`: `ns:After(identifier, seconds, callback)`, `ns:CancelTimer`, `ns:IsTimerPending`. Scheduling a pending identifier replaces it. A superseded or cancelled `C_Timer.After` still fires and no-ops on a generation check.
- Generations are **globally** unique, not per identifier: cancelling forgets the identifier, so a per-identifier counter would restart, let the cancelled callback match its replacement's generation, run it and swallow the replacement.
- Two uses: replace-on-schedule is a trailing debounce (item-list filter, `FILTER_TIMER_PREFIX`); `if ns:IsTimerPending(...) then return end` is a leading throttle (`RefreshOptionsAfterDelay`).

### Bags and the Inventory-Full Error

- `Features/Utilities-Bags.lua`.
- `ns.CountFreeBagSlots` counts general-purpose bags only (family 0 or nil), since specialty bags can't hold what a container opens into. Automated Opening pauses on it; Speedy Loot keeps its own model.
- `ns.GetBagItemIdentifier` falls back to the slot's link when the ID call is empty for an unloaded item. `ns.GetItemIconByID` uses `GetItemInfoInstant`, which never returns a cold nil.
- `ns.IsBagFullErrorID` (`LE_GAME_ERR_INV_FULL`) is the **only** inventory-full test; Automated Opening and Diagnostics' event-log filter both classify through it. `ns.IsLootBounceErrorID` adds `LE_GAME_ERR_ITEM_MAX_COUNT`, nil-safe. Both compare globals directly, no message-id walk.
- `ns.ClaimBagFullWarning`: one warning per `ns.BAG_FULL_COOLDOWN` for all callers combined (Automated Opening and Speedy Loot hear the same refusal). `ns.PlayBagFullSound` plays the race and sex voice line from `ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE`, fallback `BAG_FULL_FALLBACK`.

### Scan Tooltip

- `Features/Utilities-Scan-Tooltip.lua`: one hidden `GameTooltipTemplate` named `GogoLootScanTooltip`, created on first use. The name is required: the template's line font strings are reachable only as `<name>TextLeftN`.
- `PrepareScanTooltip` sets the owner **on every call** (hiding drops the owner; an unowned tooltip reads nothing). Hidden after every read, so it never renders.
- Readers:
  - `ns.IsItemLocked(bag, slot)` returns locked and the line count (zero lines = read nothing, what Diagnostics' Locked Boxes looks for). Matches `LOCKED` against the **whole line**.
  - `ns.ItemStartsQuest(itemId)` reads by hyperlink, since loot may never reach the bags. Cached in `startsQuestByItem` only once the item is loaded (a cold tooltip lacks the line).
  - `ns.GetBagItemTooltipLines`, then `ns.GetBagSlotTradeSeconds` through `ns.ParseTradeTimeLine`: the trade clock (Tint Tradable Gear, parked Loot Master).
  - `ns.GetTooltipLines(kind, id)` for Validate Data, chosen at load: `C_TooltipInfo` when both `GetItemByID` and `GetSpellByID` exist (WoW Forever), else the scan tooltip. `ns.GetItemLinkTooltipLines(link)` reads the whole link so a random suffix's stats show (Character Rules), via `C_TooltipInfo.GetHyperlink` where present.

### Chat Lines

- `Features/Utilities-Chat-Lines.lua`: the client's own format strings read as patterns, so every locale works without shipped translations. Every reader rejects non-strings and `ns.IsSecretValue` lines (WoW Forever) before its memo.
- `ns.BuildFormatPattern(format)` → Lua pattern + `argumentOrder` (numbered `%2$s`). `PlaceholdersToCaptures` routes through stand-in bytes so a capture already written is never re-read as a placeholder. Used for loot, money, currency, lockbox requirement, trade clock and roll lines.
- Memo: each parser and matcher list keeps its last message and answer, because one `CHAT_MSG_LOOT` reaches sounds, opening, notices, toasts and roll readers. Roll matcher answers are one shared table: read only.
- **Loot lines**: `ns.ParseOwnLootMessage` → link, quantity (`OWN_LOOT_FORMATS`: `LOOT_ITEM_SELF_MULTIPLE`, `LOOT_ITEM_PUSHED_SELF_MULTIPLE`, `LOOT_ITEM_SELF`, `LOOT_ITEM_PUSHED_SELF`); `ns.ParseGroupLootMessage` → looter, link, quantity (`GROUP_LOOT_FORMATS`). Counted forms first, whole-line anchored, so `x2` isn't swallowed into the item. Own before group: the zhCN own line also matches the group format. `FindItemLink` accepts a hex or named (`|cnIQ`) link color.
- **Roll lines** (from `LOOT_ROLL_*` formats):
  - Most open on a hidden `|HlootHistory:…|h[Loot]|h: ` link with its own number. `BuildRollMatcher` strips `LEADING_HISTORY_LINK` from the format and `FindRollLine` from the message, leaving the roll as the only number; `HISTORY_LINK_CAPTURE` returns the link as the roll's key (5th return of `ns.ParseRollResultMessage`, 6th of `ns.ParseRollWonMessage`), so two copies rolled at once stay two rolls.
  - Captures read by content, not position (translations reorder): item-link capture is the item, `%d` the roll, other text the player.
  - Matcher lists: `rollResultMatchers` (`LOOT_ROLL_ROLLED_*`, role-bonus Need first), `rollWonMatchers` (`*_WON_NO_SPAM_*` first, since the plain won format also matches them and would lose the roll), `rollChatterMatchers` (picks/passes/lost plus the result matchers). A format the client lacks is skipped.
  - `ns.IsRollChatterMessage` recognises `LOOT_ROLL_STARTED` (bare `%s`) by shape: history link then an item link alone.
  - `ns.ParseRandomRollMessage` (from `RANDOM_ROLL_RESULT`) reads `/roll` lines; trust it only on `CHAT_MSG_SYSTEM`.
- `ns.ParseTradeTimeLine` expands `|4a:b;` plural forms (`ExpandPluralForms`), longest form first; right to the minute.
- `ns.GetLinkQuality`: link hex via `ns.QUALITY_COLORS`, Retail named color `|cnIQn:`, then `C_Item.GetItemInfo`; nil = unknown, caller decides.

### Game Message IDs

- `ns.GetGameMessageInfo` and `ns:ResolveGameMessageIds(names)` in `Features/Utilities.lua`. One walk maps this client's numeric ids back to whichever requested constant names resolved; the second return (scan count) separates "resolved nothing" from "no message table". Ids differ per flavor, and several `ERR_*` globals aren't bound as strings on 1.15.9, so everything matches on the number.
- Callers, each resolving lazily on first use into a runtime table never saved:
  - master-loot errors (`ERROR_CONSTANT_TO_LOCALE_KEY` → `ns.LOOT_ERROR_CONSTANTS`, `Features/Master-Looter-Distribution.lua`)
  - trade results (`TRADE_RESULT_BY_CONSTANT` → `ns.TRADE_RESULT_CONSTANTS`), the only caller with a text fallback (`ERR_TRADE_*`) for a client where neither constant resolved
  - Diagnostics' event-log allowlist (`Diagnostics/Event-Log.lua`, union of both tables) and the Loot Method report (see Diagnostics Manifest)

### Outbound Messages

- `Features/Announcements.lua`.
- `ns.BuildPrintMessage(text)` / `ns:PrintMessage` print `GogoLoot // body` in branded colors; printed bodies carry their own end punctuation. Options Examples reuse `ns.BuildPrintMessage`.
- `ns:BuildAnnounceMessage(formatKey, ...)` builds `ns.TARGET_MARKER .. " " .. body .. " // " .. L["ADDON_SHORT_NAME"]`, the same on every channel; sent templates carry no end punctuation. Returns nil for a missing locale key. Pipes are never stripped (bodies carry item links).
- `ns:Announce(channel, target, formatKey, ...)` is the only sender (`C_ChatInfo.SendChatMessage`). It no-ops on a nil channel **and while `profile.lootNotifications` is off**, so Enable Loot Announcements is the master switch for everything sent to chat: trades, destinations, hand-outs. Two paths print to the player instead of going silent: master-loot failure lists (`FlushLootError`, also when ungrouped; see Pending Hand-out Registry) and Raid Roll Winner's group output. The trade `self` print checks `lootNotifications` itself.
- `ns:GetGroupChatChannel()`: `INSTANCE_CHAT`, `RAID` or `PARTY`; nil solo.
- `ns:AnnounceParts(channel, target, formatKey, parts, formatArguments)` packs parts joined by `", "` into messages of at most `ns.CHAT_MESSAGE_MAX_LENGTH` bytes. Measures the decorated message, splits only at part boundaries, repeats the template. `formatArguments(joined)` returns the template's arguments, since templates place the list differently. A single part over the limit is sent anyway.
- Status channel: `ns:StatusPrint` and `ns:SetQuiet` carry Automated Opening's pause/resume and Speedy Loot's left-on-corpse lines. The quiet window is set by `LOADING_SCREEN_ENABLED`/`_DISABLED` (fixed delays in their handlers). An identical line within `ns.STATUS_REPEAT_COOLDOWN` prints once. `StatusPrint` returns false only when the quiet window held the line back; the caller still owes it.
- `ns:AnnounceItemOnce`: one print per item per `ns.ITEM_ANNOUNCE_COOLDOWN`; both Ignore notices share the stamp on purpose.
- Welcome line on `PLAYER_LOGIN` while `global.showWelcome`.

### Trade Announcements

- `Features/Announcements-Trade.lua`.
- `TRADE_SHOW` starts the trade: `tradeState` is wiped in place. Records the partner's display name, class and whisper target (`Name-Realm` cross-realm, or `First Last` on Camelot through `ns:GetCleanUnitName`).
- **Snapshot**: every `TRADE_ACCEPT_UPDATE` with either side at 1 re-reads both sides, both enchant slots and the money. Any change clears both acceptances, so the last accept reads the final window. The per-slot change events are deliberately unregistered: WoW Forever empties our side as the trade executes, just before the result. `TRADE_REQUEST_CANCEL` resets.
- **Result**: `UI_INFO_MESSAGE`, read only while a trade is open (`tradeState.player`), because every quest update lands on that event. The id maps through `GetTradeResult`: complete → announce, call `ns.OnLootMasterTradeCompleted` if loaded, reset; cancelled → reset.
- **Enchant slot asymmetry** (`ns.TRADE_ENCHANT_SLOT`): `GetTradePlayerItemInfo` puts the service text at return 5 (6 is `canLoseTransmog`); `GetTradeTargetItemInfo` puts it at 6 (5 is `isUsable`). `SafeGetTradeEnchantName(fn, slot, index)` takes the position from its caller (`TRADE_ENCHANT_RETURN_PLAYER`, `TRADE_ENCHANT_RETURN_TARGET`). Attribution is crossed: an item in **our** slot means **they** performed the service (`theirEnchantDescription`, listed on the received side), and vice versa.
- Summary: `BuildTradeSummaryParts` lists item links (merged by link, with `L["ITEM_QUANTITY"]`), then the enchant, then money in coin symbols. `ns.FormatTradeSummary` gives one line, for the panel Example.
- Routing (`AnnounceTradeComplete`): `announceTradeCondition` (always, `party_or_raid`, `raid_only`); `announceTradeOutput`: `self` prints through `PrintTradeSummary` (`_PRINT` templates, partner in class color, no byte limit); `whisper` whispers the partner; `group` uses the group channel and falls back to a whisper when solo. A two-sided summary goes out as one `MESSAGE_TRADE_GAVE_RECEIVED` if it fits, else splits into `MESSAGE_GAVE` (shared with the master-loot hand-out) and `MESSAGE_TRADE_RECEIVED` through `AnnounceParts`.
- `Features/Announcements-Trade-Checkbox.lua`: `GogoLootTradeAnnounceCheckbox`. Created at the first `TRADE_SHOW` where `TradeFrame` exists; parented to UIParent, only anchored to `TradeFrame`, so nothing is written into Blizzard's frame. `ns:SyncTradeCheckbox` shows it only while a trade is open **and** `lootNotifications` is on, re-reading `TradeFrame`'s strata and level each time. Clicking writes `profile.announceTrade` and calls `ns.RefreshSettings()`. Its tooltip lists When before Channel, because a ticked box under When in Raid stays silent in a party.

### Options Panel Architecture

- `Options/Options-Kit.lua`: copied Common-Core kit, CI byte-checked, never edited here. Reads `ns.PALETTE`, `ns.L`, `ns.db`, `ns.OPTIONS_REGISTRY`, `ns.FEATURES`, `ns:PrintMessage`, plus `ns.RefreshMenu`, `ns.UpdateMinimapIcon` and `ns.CLASS_COLORS` where they exist. Publishes its grid as `ns.OPTIONS_*` (`ROW_WIDTH`, `LABEL_WIDTH`, `CONTROL_WIDTH`, `SUB_INDENT_WIDTH`, ...). `Data/Data.lua` defines only GogoLoot's own widths (`ns.ROLL_ACTION_DROPDOWN_WIDTH`, `ns.OPTIONS_ITEM_TAG_WIDTH`, `ns.OPTIONS_RESTORE_BUTTON_WIDTH`, the filter-grid widths). `Options/Options-Utilities.lua` hands it its strings once (`Kit.SetText`).
- What GogoLoot relies on from the kit:
  - **One refresh**: `ns.RefreshSettings()` calls `NotifyChange` on **every** `ns.OPTIONS_REGISTRY` entry (pop-up and Diagnostics included), then `ns.RefreshMenu`, then `ns.UpdateMinimapIcon`. Every writer ends there. `Kit.Set(store, path, onSet)` writes, runs `onSet`, refreshes; hand-written setters call `ns.RefreshSettings()` themselves. Settings resolve through `ns.db[store]` on every read (`Resolve`), since a profile switch replaces `ns.db.profile`.
  - Rows: `Kit.Row` (one unnamed inline group per line; `hidden` goes on the group), `Kit.SubRow` (a real indent cell, since AceConfig pins a checkbox to its widget's left edge), `Kit.LabelRow` / `Kit.SubLabelRow`, `Kit.SubToggleRow`, `Kit.ToggleRow(order, toggle, { control, preview, helper })` (the toggle's one setting or speaker rides its line and hides while it's off; a caption wider than the label column by `Kit.ToggleWidth` takes the whole line), `Kit.Pairs` (two to a line at `Kit.PAIR_WIDTH`), `Kit.Section`, `Kit.FieldSets`, `Kit.Helper`, `Kit.StatusLine`, `Kit.WarningLine`, `Kit.ResetRow`, `Kit.SoundPreview`.
  - Examples: `Kit.Example(order, hidden, getLines)`, `Kit.SentLine("PARTY"|"WHISPER", msg)` (draws `{rtN}` as icons, in the channel color), `Kit.PrintedLine`, `Kit.You`.
  - Items: `Kit.ParseItem` (bare ID or link, must pass `DoesItemExistByID`), `Kit.SortItems` (by name, uncached last, ties by ID), `Kit.ItemName`, `Kit.ITEM_LINK_WIDGET` (the row's item cell; hover tooltip uses bare `item:id` so a loading row still gets one).
  - Panels: `Kit.RegisterPanel(key, builder, displayName, parentKey)` registers the **builder function**, so every repaint rebuilds it; a child nests by the parent's captured category ID; `Kit.SubPanelTitle` gives "Parent > Child". Also `Kit.PrepareTree`, `ns:OpenOptionsPanel(key)` (the combat guard, routing by category ID) and `ns.IsOptionsPanelOpen`.
  - Unused here: `Kit.ItemList`, `Kit.WarmItems`, `Kit.HideAllExcept`.
- `Options/Options.lua`: `FEATURE_PANELS` lists `{ key, builder, title, parent? }` in tree order; a row is skipped when its builder is missing or its parent didn't register (how the parked Loot Master row stays harmless). The pop-up is registered in AceConfigRegistry only. On `SettingsPanel` OnHide it calls `ns.ForgetNewListItems` and `ns.ForgetPanelItemLists`; it starts `ns.WatchScrolledDropdowns` and `ns:WarmItemCache`.
- **`ns.FEATURES`** (`Options/Options-Utilities.lua`): the one list of master switches, in mini-map menu order: blocks first (`block = true`: Automated Rolls, Automated Opening, Loot Announcements), then the More Features switches.
  - Fields: `store`, `setting`, `name`, `caption`, `desc`, optional `descArgs`, `apply`, `click`.
  - `apply` writes the value plus side effects: Auto Loot enforcement and an opening scan, the trade checkbox sync, the not-master-looter print, `ns.SetLootToastsEnabled`, `ns.ApplyRollMacro`.
  - Three surfaces build from these records: each panel's switch (`ns.FeatureSwitch(setting, order)`), the General panel's Features section (`ns.FeatureSwitches(order)`, two to a line) and the menu (`ns.FlipFeature`, More Features).
  - `descArgs` is GogoLoot's own field: values for a description's `%s` slots naming game settings (`AUTO_LOOT_DEFAULT_TEXT`, `MASTER_LOOTER`, `ns.ROLL_MACRO_NAME`), filled by `ns.FeatureDescription` through the `ns.` wrappers; `Kit.FeatureSwitch` would not.
  - `click` is documentation only; the menu's `CLICKS` table is the truth.
- **Hidden-when-off**: a panel opens on its description, then its switch; what the switch tunes hides with it, spacers included, with no `disabled` state.
  - Announcements and Loot Toasts use a local `Add(key, entry)` that hands out the next order and composes the switch's gate with the entry's own `hidden`. The Filters child panel's `Add` only hands out the order.
  - A row shared with the pop-up carries its own gate (`ns.AddDestinationMessagesRow`).
  - A child panel never hides behind its parent (it would open blank). `ns.AddFeatureOffLine(args, order, setting)` adds a silver `OPTIONS_FEATURE_OFF_STATUS` line naming the parent feature in gold, plus a spacer, shown only while the parent is off; returns the next order.
- **Examples** hide with their own toggle (and the master switch through `Add`), built through the feature's real builder on every draw: `ns:BuildAnnounceMessage`, `ns.FormatTradeSummary`, `ns.OptionsPrintedLine` (`Kit.PrintedLine(ns.BuildPrintMessage(text))`). Stand-ins from `ns.SAMPLE_NAMES` via `ns.OptionsExampleOther(classFile)` and real items via `ns.OptionsExampleLink(id)` (a loading line until cached). The trade Example follows `announceTradeOutput`; the automated hand-out Example takes the threshold's quality.
- `ns.OptionsQualityChoices(lowest, suffix)`: values plus sorting in quality colors. Announcements starts at Common, so a Poor hand-out is never announced.
- `Options/Options-Utilities-Dropdown-Watch.lua`: an AceGUI dropdown list is parented to UIParent and rides out of the window when its scroll area moves; `ns.WatchScrolledDropdowns` closes it (`AceGUI:ClearFocus`) when the open dropdown's offset changes, only while `SettingsPanel` is shown.
- `Options/Options-General.lua`: welcome toggle (`global.showWelcome`), Enable Mini-map Button (`profile.minimap.hide` inverted, then `ns:ApplyMinimapButton`), the Features section, the `/gogo` line. `Options/Options-Feedback-Support.lua`: link boxes (inputs with a no-op `set`, so the URL can be selected) from `ns.LINKS`, and the version line.

### Item Lists

- `Options/Options-Utilities-Item-Lists.lua`: `ns:BuildItemListOptions(spec)` draws Item Overrides, the Ignore List and the Openables List. Its own builder rather than `Kit.ItemList`, for kind sections, filter, New section, tags and refused-ID handling.
  - Spec fields: `getSourceTable`, `onRestore`, `isDefault` (`ns.ItemListsMatch` against a freshly built default), `onAdd`, `canAdd`, `onRemove`, `notifyKey` (registry name; keys the filter, New and the watch), `labels`, `actionColumn`, `tagFor`, `refillsWhenEmpty`, `startOrder`, `rowWidth`.
  - Layout: add line (`args.addRow`, only with `onAdd`), `spacerAfterAddRow`, filter line (`args.filterRow`), `spacerBeforeItems`, sections, the no-match or refills note, Restore Defaults right-aligned at `ns.OPTIONS_RESTORE_BUTTON_WIDTH` (always confirms; gray while `isDefault`).
  - Row: an inline group of the item cell (`Kit.ITEM_LINK_WIDGET`), optional silver tag column (`ns.OPTIONS_ITEM_TAG_WIDTH`, blank when untagged so dropdowns stay in one column), optional action dropdown (`ns.ROLL_ACTION_DROPDOWN_WIDTH`), and the remove icon (`ns.ITEM_LIST_REMOVE_ICON`, `name = ""`, label in `desc`). Remove confirms only with an action column.
  - IDs not on the client (`ns.IsItemOnClient`) get no row and no request, but stay saved.
  - Names read once through `ReadItemNames` into `knownItemNames`. Rows sort inline in `Kit.SortItems` order from the names in hand, so the comparator never queries. Building arms the watcher if any row is cold.
  - Add (`AddItem` in `AddAddRow`) silently drops an ID `DoesItemExistByID` rejects. Re-adding a listed item keeps its setting and moves it to New.
  - Add from Bags (`GetAddableBagItems`): each distinct carried item the list lacks and `canAdd` accepts, A to Z, summed counts; rests on first choice `BAGS_CAPTION` (`ITEM_LIST_ADD_FROM_BAGS`, or `ITEM_LIST_BAGS_EMPTY` disabled); read afresh every repaint.
- `Options/Options-Utilities-Item-List-Filter.lua`: per-list, per-session state keyed by registry name, never saved.
  - Kind sections: `GetItemKindHeading` uses the class name from `GetItemInfoInstant` (no server question), never the subclass. A non-quest-class item with bind type `ns.BIND_QUEST_ITEM` goes under `C_Item.GetItemClassInfo(ns.ITEM_CLASS_QUEST)` once loaded. Headings cached in `knownKindHeadings` only for loaded items. `GroupByItemKind` sorts headers A to Z; untyped rows (`""`) go above the first header.
  - New (`newListItems`, newest first) is pulled out of the kind sections by `WithNewSection` and skips both filters. It ends when the list is filtered by text (`SetListFilter`) or kind, and when Options closes (`ns.ForgetNewListItems`). Kind choices are read before New is pulled out.
  - Text filter (`listFilters`): trimmed and case-folded by `FoldCase` (ASCII plus two-byte Latin-1 and Cyrillic capitals); matches item ID, name, the setting as its dropdown reads, or the tag. Typing redraws after `FILTER_REFRESH_DELAY`; Enter or clear applies at once.
  - Kind filter (`listKindFilters`, `ns.ITEM_LIST_ALL_KINDS`): choices keyed by header text, so no translation. A picked kind that leaves the list is forgotten in `BuildItemListOptions`.
- `Options/Options-Utilities-Item-List-Widgets.lua`: two AceGUI widgets (`ns.ITEM_LIST_FILTER_WIDGET_TYPE`, `ns.ITEM_LIST_ADD_WIDGET_TYPE`).
  - Filter box: magnifier, placeholder, clear button (the remove icon); writes the list's filter itself on user typing. **Focus handover**: losing focus while its frame is hidden means a redraw released it, which opens `FILTER_FOCUS_HANDOVER_SECONDS`; the rebuilt box for the same list (identified through the entry's `arg = { registryName }`, which AceConfigDialog hands to `SetCustomData` after `SetText`) takes keyboard and cursor back on show.
  - Add box: the button, Enter, a drag-drop and a click-with-cursor-item all fire `OnEnterPressed`, reaching the entry's `set`. Button sized by `ns.MeasureCaptionPixels` (at least `ADD_BUTTON_MIN_WIDTH`). The box starts at `FILTER_BOX_LEFT`, so add and filter boxes stack in one column.

### Mini-map Button and Menu

- `Features/Minimap-Button.lua`: LDB launcher and LibDBIcon button.
  - The icon follows Automated Rolls (`ns.MINIMAP_ICONS` on/off) through `ns.UpdateMinimapIcon`, which `ns.RefreshSettings` calls.
  - Position and hide live on `profile.minimap`. `ns:ApplyMinimapButton` is `LibDBIcon:Refresh`, called again after a profile switch.
  - `OnEnter` opens the menu (`ns.ShowMenu(frame, nil, "hover")`); `OnClick` goes to `ns.RunButtonClick`.
  - On Camelot and Mainline the icon is masked round, resized and nudged by hand to sit in LibDBIcon's off-center Retail ring. Set directly, not through `SetButtonIcon`, whose `ResetButtonIcon` errors when another add-on has replaced the icon.
- `Features/Menu-Kit.lua`: generic copied plate-and-rows kit (`ns.MenuKit`). Entries are tables keyed by `kind`. The cursor test reads the cursor position rather than `IsMouseOver`, so a controller cursor works.
- `Features/Minimap-Menu.lua`: menu panel `GogoLootMenu` (named so it can join `UISpecialFrames`, which makes Escape close it) and one flyout.
  - **`CLICKS`** (`ns.MENU_CLICKS`) is read both ways: the button's OnClick looks the click up, and each Toggle row names its click. Left: Automated Rolls. Right: Automated Opening. Shift+Left: Loot Announcements. Middle: the loot windows, only while `ns.LootWindowsLoaded()` (a no-op while they are parked). Shift+Middle: hides the menu, opens the options. Shift+Right: no entry. Before `ns.db` exists, only the options click runs.
  - Order in `ns.BuildMenuEntries`: header; Locked Items (`ns.GetLockedBoxes`, at most `LIST_MAX` rows plus a count note, then the Rogue or non-Rogue hint; the Rogue hint waits for Pick Lock's spell name); three feature blocks through `AddFeature` (title with state, description, optional note and rows, blue Toggle `ClickRow`); More Features (flyout of the non-block `ns.FEATURES`, On/Off count via `ns.CountMoreFeatures`); separator, Options.
  - Automated Rolls' block: a row per `ROLL_CONTEXTS` entry (Party or Raid, the game's word) reads back `ns.MenuRollSetting` and opens `RollContextFlyout` with action and threshold choice rows, the Bind on Pickup toggle, an overrides note and links to Item Overrides (marked Off while `customRollList` is off), Character Rules and Sanity Check.
  - Automated Opening's block: On, Paused (`ns:GetAutomatedOpeningHold` reason, with a note) or Off, plus the sealed containers (`ns.GetSealedContainers`) while on.
  - Every change runs `ns.FlipFeature` (the feature's `apply`, or a plain write), then `ns.RefreshSettings()`, which redraws the open menu, every panel and the icon. A choice row hides the menu **before** refreshing so it isn't redrawn on its way out; a toggle keeps the menu open.
  - Placement: opens away from the screen edges by the anchor's quadrant; the flyout opens on the same side. An `OnUpdate` closes it after `HOVER_CLOSE_DELAY` (or `CLICK_CLOSE_DELAY` after a click) once the cursor is off button, menu and flyout.

### Diagnostics Manifest

- `Diagnostics/`: copied framework (runner, panel, event log, validator, builders). `Diagnostics/Manifests.lua` is GogoLoot's own:
  - `ns.DIAGNOSTIC_API_CHECKS`: `{ label, test }` rows for every API GogoLoot calls or guards. Modern and legacy listed separately, so a FAIL on one half shows which branch the client took. `Validate-Data.lua` appends its own readers.
  - Context probes, `ns:Build*Report` (LootMethod, SpeedyLootContext, OpeningContext, LockedBoxes, RollsContext, RollVerdicts, GearStats, LootToastsContext, LootLine, AnnouncementsContext, RollMacroContext, Player). They read state through the feature files' exported accessors, so a report shows the values the features act on; where a gate is private, they print its inputs. `Report-Runner.lua` maps them to tabs.
  - Loot Method resolves `ns.LOOT_ERROR_CONSTANTS` and `ns.TRADE_RESULT_CONSTANTS` in **one** `ns:ResolveGameMessageIds` walk and prints `constant = id` or `NOT FOUND`, plus the scan count: the only output that shows a per-flavor id failure.
  - `ns.DIAGNOSTIC_NAME_LOOKUPS`, built at load from `UI_LABELS` (every client format and label GogoLoot reads or shows) plus loops over Data tables (Character Rules groups, gear subclasses, stats, `ITEM_MOD_*` formats, class names, spells, the Lockpicking skill line where present, `ns.LOOT_TOAST_FILTER_ROWS`). A new data row appears in Game Names with no edit here.
  - `ns.DIAGNOSTIC_SPELLS`, `ns.DIAGNOSTIC_SAVED_SUMMARY_KEYS` (tables printed as a row count), `ns.DiagnosticBagItemLinks`, `ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES`.
  - `ns.DIAGNOSTIC_DATA_SOURCES`: one entry per flavor-folder file. `label` is the file stem (`ns.DataSourceFileName` names this client's file from it). `table` is a **name string**, so a table this folder never built still gets a row. `kind` is `item`, `spell` or `other` (row count only). `rowId(key, row)` copes with the three table shapes; `dataColumns` carry the shipped values.
- `RollVerdict` is declared `local` ahead of `AppendOpenRolls` and defined later with `function RollVerdict(...)`, which assigns the upvalue, not a global.

## Files That Change Together

- **New registered event**: `ns:RegisterModuleEvent` in the owning file (same unit as any existing handler on that event); `ns.EVENT_NAMES` in `Features/Core.lua`, alphabetical (a test fails on an unsorted list or any developer-warning print); a red/yellow message firehose also goes in `ns.MESSAGE_ID_FILTERED_EVENTS` (`Diagnostics/Event-Log.lua`).
- **New setting**: key in `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`) in the scope Saved Variables decides; control in its `Options/Options-*.lua` panel via `Kit.Get`/`Kit.Set`; reader in the feature, reading `ns.db.<scope>` at use time; a repaint in `ns:ApplyProfile` (`Features/Core.lua`) if the feature caches or shows profile state; locale keys in `Locales/enUS.lua`. Renaming a saved key needs a migration.
- **New master switch**: an `ns.FEATURES` record (`Options/Options-Utilities.lua`) and `ns.FeatureSwitch(setting, ...)` on its panel; a menu block also needs `block = true`, a `CLICKS` entry and an `AddFeature` call (`Features/Minimap-Menu.lua`) plus `MENU_CLICK_*` / `MINIMAP_*_DESCRIPTION` strings. The General section and More Features follow on their own.
- **New options panel**: `Options/Options-<Name>.lua` defining `ns.Build<Name>Options`; a key in `ns.OPTIONS_REGISTRY` (`Data/Data.lua`); a `FEATURE_PANELS` row in `Options/Options.lua` (parent listed first); a `TAB_*` key in `Locales/enUS.lua`; the file in all four TOCs' Options block at the same position; `FILES` in `Tests/Run.lua` at the same place; the `expected` list in the test "the settings tree nests each child panel under its parent".
- **New item list panel**: everything for a new options panel, plus `ns:BuildItemListOptions` with `notifyKey = ns.OPTIONS_REGISTRY.X`, and a `watchedItemLists` entry in `ns:WarmItemCache` if the saved list should warm at login.
- **New Options utility or widget file**: all four TOCs' Options block (after `Options/Options-Kit.lua`, before the files that capture its exports) and `FILES` in `Tests/Run.lua`.
- **New feature file**: all four TOCs at the same position and `FILES` in `Tests/Run.lua`; a flavor that can't run it leaves it out of its TOC and adds it to `leftOut` in the test "every flavor TOC loads the Vanilla TOC's files, with its own data folder".
- **New announcement**: a `MESSAGE_*` key in `Locales/enUS.lua`; the send through `ns:Announce`, or `ns:AnnounceParts` for multi-link bodies; a line in `ns:BuildMessageLengthReport` (`Diagnostics/Localization-Reports.lua`, which lists messages by hand); a `Kit.Example` on its panel; `ns:BuildAnnouncementsContextReport` (`Diagnostics/Manifests.lua`) if it adds a setting.
- **New correlated game message**: the constant table in its feature file, exported as `ns.*_CONSTANTS`, added to the event-log allowlist union (`Diagnostics/Event-Log.lua`) and the Loot Method walk (`Diagnostics/Manifests.lua`).
- **New mapped loot error**: `ERROR_CONSTANT_TO_LOCALE_KEY` (`Features/Master-Looter-Distribution.lua`) and a two-arg `ERROR_*` locale key (the Localization report walks `ns.LOOT_ERROR_CONSTANTS`).
- **New distribution skip or gate**: `TryDistributeSlot` (or `ShouldSkipItemForMasterLoot`) in `Features/Master-Looter-Distribution.lua`, `MasterLootSlotVerdict` in `Diagnostics/Manifests.lua`, the `SAFETY_SKIP_NOTE_MASTER_LOOTER` / panel copy in `Locales/`.
- **New shared pop-up/panel row**: builder in `Options/Options-Master-Looter.lua` (or `Options-Announcements.lua`), both `ns.BuildMasterLooterOptions` and `ns.BuildMasterLooterPopupOptions`, and a re-measured `POPUP_HEIGHT`.
- **New loot method (enum)**: `LOOT_METHOD_BY_ENUM` in `Features/Master-Looter.lua`; `BuildLootTypeValues` and `THRESHOLDLESS_LOOT_METHODS` in `Options/Options-Master-Looter.lua`.
- **New `ns.DecideRoll` reason**: `Features/Automated-Rolls.lua`; `REASONS` in `Options/Options-Sanity-Check.lua` plus its locale key; `ROLL_REASON_LABELS` (and `RULE_REASONS` if rule-derived) in `Diagnostics/Manifests.lua`.
- **New per-context roll setting**: `Data/Default-Settings.lua`; `GetContextRollSettings` / `ns.RollsBindOnPickup`; the context loop in `Options/Options-Automated-Rolls.lua`; readback rows in `Features/Minimap-Menu.lua`; rolls and safety lines in `Diagnostics/Manifests.lua`.
- **New Character Rules stat**: a row in `ns.CHARACTER_RULE_STATS` (`Data/Data.lua`: `key`, `group`, `label` from an `ITEM_MOD_*_SHORT` global, `itemMods`); that global in `read_globals` (`.luacheckrc`); the key in each folder's `CHARACTER_RULE_STAT_KEYS`; `CHARACTER_RULE_EQUIP_SPELLS` rows in Vanilla, Discovery and TBC where the stat is an item spell (a test requires Discovery's two stat tables to match Vanilla's); `ns.CLASS_STAT_STARTER` or `everyClass = true`; the pinned stat counts in the `Tests/Run.lua` flavor tests.
- **New gear row**: the flavor's `CHARACTER_RULE_ARMOR_TYPES`/`_WEAPON_TYPES` and starters; a slot-named row also needs `ns.CHARACTER_RULE_GEAR_SLOT_ROWS` and `ns.CHARACTER_RULE_GEAR_ROW_LABELS`.
- **Roll Macro body or icon**: `Data/Data.lua`, the `Tests/Run.lua` macro assertions, the Message Length report (`Diagnostics/Localization-Reports.lua`).
- **New default list item**: a row in `ns.DEFAULT_IGNORE_LIST_SOLO` (`{ itemId, action }`) or `ns.DEFAULT_IGNORE_LIST_MASTER` (`{ itemId }`) in each `Data/{Folder}/Default-Item-Lists-{Folder}.lua` whose client has the item. Existing profiles get it only through an empty list or Restore Defaults.
- **New openable or lockbox row**: `ns.OPENABLE_ITEMS[itemId] = ns.OPENING_*` in `Data/{Folder}/Openable-Items-{Folder}.lua`; `ns.OPENABLE_ITEM_LEVELS[itemId]` there when the required level is above 1; a lockbox also gets `ns.LOCKBOX_SKILL_LEVELS[itemId]` and must be `ns.OPENING_UNLOCKED`. Tests hold all three invariants per folder.
- **New Openables default reason**: constant in `Data/Data.lua`; `DEFAULT_ACTIONS`/`DEFAULT_TAGS`/`DEFAULT_NOTES` in `Features/Openable-Items.lua`; `IGNORED_NOTICES` in `Features/Opening-Notices.lua`; locale tag/note/notice keys; data folders' `Openable-Items-*.lua`; the data-invariant test.
- **New Automated Opening hold-off**: `ns:GetAutomatedOpeningHold`, `RunScan`'s skip list, a rescan event for when it lifts (plus `ns.EVENT_NAMES`), the mini-map menu's Paused reason, a row in `Options/Options-Automated-Opening.lua`, a default in `Data/Default-Settings.lua`.
- **New window that should block opening**: `IsInteractionActive`, its close event registered to `OnInteractionClosed`, `ns.EVENT_NAMES`.
- **New loot-window replacement UI**: `ns.LOOT_WINDOW_REPLACEMENTS` only (Speedy Loot hooks and Automated Opening's gate follow `ns.GetLootWindow`).
- **New bag add-on for the tint**: one `TINT_ADAPTERS` entry (plus a redraw function if its buttons can show a new slot without redrawing).
- **New Loot Toasts filter row**: `ns.LOOT_TOAST_FILTER_ROWS` (`Data/Data.lua`); `lootToastMine`/`lootToastGroup` (+ `*Quality` for rarity) in `Data/Default-Settings.lua`; caption/desc keys (and `OWN_ROW_DESCRIPTIONS` for an own row) in `Options/Options-Loot-Toast-Filters.lua`; logic in `ns.IsLootToastWanted` if it isn't a plain class/subclass row.
- **Anything keyed on `lootToasts`**: `ns.SetLootToastsEnabled` (Handle) and `ns:ApplyProfile` both re-sync it, as they do Standard Loot Messages and the roll-won window.
- **New Example item**: `ns.SAMPLE_ITEM_IDS` (flavor `Game-IDs`) or an `ns.Example*Container` helper, plus `exampleItems` and a `watchedItemLists` entry for the panel's registry in `ns:WarmItemCache`.
- **New data table in an existing flavor file**: declare it in all seven folders, Wrath and Mainline included; its name in the key list of the test "every data folder declares every table"; a source row under the file's label in `ns.DIAGNOSTIC_DATA_SOURCES` (`Diagnostics/Manifests.lua`).
- **New data file**: everything for a new data table, plus a new `ns.DIAGNOSTIC_DATA_SOURCES` entry (label = the file's table-name part); each TOC's data block (Vanilla: its own line and the Discovery line, each file guarded on `ns.IS_DISCOVERY`); the Vanilla and Discovery lines in `FILES`; the `LoadDataFolder` list in `Tests/Run.lua`.
- **New locale key**: `Locales/enUS.lua` with an argument comment; the test "every locale carries the same keys as enUS" fails until all ten other locales carry it. Placeholder parity is checked by hand only.
- **New WoW API or global**: a shim in the accessor block of `Features/Utilities.lua` if clients differ; `read_globals` in `.luacheckrc`; a row in `ns.DIAGNOSTIC_API_CHECKS` (`Diagnostics/Manifests.lua`); a concrete fake in `Tests/Fakes/WoW.lua` (plus `absentGlobals` if a test needs it missing); an `ns.DIAGNOSTIC_NAME_LOOKUPS` row for a game name it supplies.
- **New migration**: the function in `Features/Core.lua` (or the owning feature, exported on `ns`); a call in `OnAddonLoaded` after the existing migrations, tagged `-- MIGRATION (remove after YYYY-MM-DD)`; a test in `Tests/Run.lua` with the same tag; any Diagnostics line checking whether it ran leaves with it.
- **New vendored library**: `.pkgmeta` externals (CI checks folder parity with `Includes/Libraries/`), the Includes block of all four TOCs in dependency order, the committed folder.
- **Un-parking a file**: all four TOCs; remove it from `PARKED_FILES` (`Tests/Run.lua`); flip the `lootMaster` default (`Data/Default-Settings.lua`) for the loot windows. The `/gogo` subcommands, the `LootMaster` `FEATURE_PANELS` row and the parked events in `ns.EVENT_NAMES` are already in place.

## Saved Variables

- **Table**: `GogoLootDB`, the only SavedVariables table; an AceDB-3.0 database, `ns.db`, created in `OnAddonLoaded` (`Features/Core.lua`). `ns.SAVED_VARIABLES_NAME` (`Data/Data.lua`) names it for Diagnostics; `AceDB:New` receives the literal.
- **Model**: Simple. `AceDB:New("GogoLootDB", ns.DATABASE_DEFAULTS, true)` puts every character on the one shared `"Default"` profile. Profiles exist for a player who wants separate loot rules (stock Profiles panel).
- **Profile scope**: all loot policy, the item lists, `destinations`, the mini-map button (`minimap`, handed straight to LibDBIcon), the toasts' look and Filters, `lootToastsIntroSeen`, and the parked Loot Master settings.
- **Global scope** (a profile switch, copy, reset or delete never moves these):
  - `showWelcome` and `automatedRollsOnNoticeShown`: notices shown per account.
  - `speedyLoot`: changes the client's loot window, not loot policy.
  - `rollMacro`: the macro is a General macro shared by every character.
  - `openingActions`: a decision about items; storing only changes lets new data reach everyone.
  - `lootToastPosition`: a decision about the screen; parked `lootWindowPositions` likewise.
- **Char scope** (characters share the one profile; README-Notes "Character Rules save per character"):
  - `characterRules` and `classFile` (see Character Rules).
  - Chat marks `lootGroupsHiddenByGogoLoot` and `standardLootMessagesHidden` (chat settings are per character in the client too).
  - Parked Loot Master lists (`rollList`, `floorLoot`, `awarded`, `dropRaids`, `pickedUp`, `pickedUpInstance`).
- **Keys without defaults**: `characterRules`, `classFile`, `standardLootMessagesHidden`.
- **Reset Profile therefore**: clears every profile key (loot policy to install defaults, mini-map button to its default spot and shown); empties the item lists, which `ns:ApplyProfile` re-seeds at once; resets `lootToastsIntroSeen`, so the toast intro is owed again; leaves `global` and every `char` section untouched.
- **Defaults**: AceDB applies `ns.DATABASE_DEFAULTS`; nothing else reads it, so no hand-rolled merge and no migration debt. Scalar and table defaults are `rawset` into the live table when a scope is first touched and stripped at logout; only `*` and `**` defaults stay behind metatables (`copyDefaults` in AceDB-3.0).
- **Default-list seeding**: `RebuildEmptyItemLists` (`Features/Core.lua`) runs on load and in `ns:ApplyProfile`. An empty `ignoredItemsSolo` or `ignoredItemsMaster` means "never configured" and is rebuilt from this client's `Default-Item-Lists` rows via `ns:BuildDefaultIgnoreListSolo` / `ns:BuildDefaultIgnoreListMaster`; `BuildListFromRows` skips rows whose item fails `C_Item.DoesItemExistByID`. Never overrides a non-empty list. The Openables List needs none: defaults are read from the data on every lookup.
- **Other-client prune**: `PruneOtherClientCharacters` runs right after `AceDB:New`, silently. AceDB keys characters `"Name - Realm"` on realm clients and `"First Last"` on WoW Forever; a `char` or `profileKeys` key shaped the other way from `ns.db.keys.char` came from a copied WTF folder and is dropped. A profile named after a dropped character goes too, unless a this-client character (or the active profile) still uses it. Namespaces get the same prune (GogoLoot registers none). Era and Anniversary realm keys can't be told apart, so those stay.
- **Profile apply**: `ns:ApplyProfile` is registered for `OnProfileChanged`, `OnProfileReset` and `OnProfileCopied`. It runs `RebuildEmptyItemLists`, `ns.EnsureAutoLoot` (when `ns:IsAutoLootNeeded`), `ns.ScheduleOpeningScan(true)`, `ns.ApplyLootToastSettings`, `ns:ApplyMinimapButton`, `ns.SyncStandardLootMessages`, `ns.SyncBlizzardRollWonWindow`, `ns:SyncTradeCheckbox` and `ns:RefreshTradableTints`, then `ns.RefreshSettings`. Each feature hook is nil-guarded, so a file a flavor's TOC leaves out drops its repaint.

### Migration Chain

Run in `OnAddonLoaded` after `AceDB:New`, `PruneOtherClientCharacters`, `RebuildEmptyItemLists` and `RecordCharacterClass`, before the profile callbacks, `ns:InitMinimap` and `ns.RegisterOptionsPanels`. Each walks raw `sv.char` / `sv.profiles`.

1. `ns.DropOldCharacterRules` (`Features/Character-Rules.lua`, remove after 2026-12-07): in every `sv.char`, drops `characterRules` keys other than `wanted` and `unwanted`, and the table if that empties it.
2. `ns.DropRetiredCharacterRuleKeys` (`Features/Character-Rules.lua`, remove after 2026-12-16): drops `unwanted.bindOnPickup`, `unwanted.greedBindOnEquipAtMaxLevel` and `unwanted.threshold`, then any table left empty.
3. `MoveMinimapPositionToProfile` (`Features/Core.lua`, remove after 2026-12-16): copies `sv.global.minimap` into the active profile if its `minimap` is empty, and into every saved profile with no `minimap`, then drops it. `Diagnostics/Settings-Reports.lua` prints whether `global.minimap` is still present (leaves with it).
4. `SplitBindOnPickupByContext` (`Features/Core.lua`, remove after 2026-12-16): copies `rollBindOnPickup` into `rollBindOnPickupParty` and `rollBindOnPickupRaid` where `rawget` finds them nil, then drops the old key. On the active profile the new keys already hold AceDB defaults; see Pitfalls & Why.

Migrations 1 and 2 have tests tagged `-- MIGRATION (remove after …)`; the tests for 3 ("the mini-map button's position moves from the account to every profile, once") and 4 ("a saved Include Bind on Pickup carries into both group contexts") are untagged, so remove them by name.

## Pitfalls & Why

### Core, Load Order and Saved Data

- **Unlisted event**: `ns:RegisterModuleEvent` warns, and the test "every registered event is listed for diagnostics, and the list is sorted" fails on any developer-warning print. The harness loads parked files too, so their events stay in `ns.EVENT_NAMES`.
- **`ns:UnregisterModuleEvent` inside a handler**: shifts the live list, so the next handler on that event is skipped for that firing. Unregister from a named timer or user path (as the item cache does).
- **A second unit on a unit event**: the first registration's filter wins for every handler; asking for `"target"` on `UNIT_SPELLCAST_- **`rawget(profile, key) == nil` as "never set" in a migration**: by the time migrations run, AceDB has `rawset` every scalar default into the active profile (`RebuildEmptyItemLists` touches `ns.db.profile` first), so the test only works on non-active profiles. A migration that must not overwrite a player's choice tests the old key's presence instead, and its test seeds the active profile too.st seeds only non-active profiles.
- **Capturing `ns.db.profile` in an upvalue**: a profile switch replaces the table. Read it at use time.
- **Toast anchor in global, mini-map position in profile**: looks inconsistent, deliberate. The mini-map follows the Simple-model mini-map rule; the toast position is "a decision about the screen" (`Data/Default-Settings.lua`).
- **Per-character state in the profile**: every character shares `"Default"`, so it applies account-wide. Character Rules, class and chat marks live in `ns.db.char`.
- **Changing a default reaches existing players**: AceDB saves only diffs, so everyone who never set the key gets the new value with no migration; `autoGreed` ships on with its one-time notice for this reason.
- **Mutating `AceDBOptions-3.0:GetOptionsTable`'s result**: its `args` is shared by every Ace3 database on the client. `Options/Options-Profiles.lua` returns it untouched; extend only through a wrapper.
- **Working out the flavor from the client**: `ns.FLAVOR` comes from the TOC's `X-Flavor`; `WOW_PROJECT_ID` isn't stable on WoW Forever. Season of Discovery is `ns.IS_DISCOVERY` on the Vanilla TOC.
- **Dropping `Diagnostics/Diagnostics-Core.lua` from a TOC**: `OnEvent` reads `ns.diagnostics.logging` unguarded, so every event errors.
- **Reordering TOC lines**: file-scope captures (`ns.OptionsKit`, `ns.GetColor`, `ns.L`, `ns.BuildFormatPattern`) break, and `AceConfigCmd-3.0` must precede `AceConfig-3.0.lua`. The TOC tests compare every flavor TOC to Vanilla's line by line, and `FILES` to the Vanilla TOC minus `PARKED_FILES`.
- **Un-parking through the TOCs alone**: the TOC test fails on `PARKED_FILES`, and `lootMaster` still defaults off.
- **Adding an enUS key alone**: the locale-parity test fails until all ten other locales carry it. A renamed key must be a new name: AceLocale falls back to English only for an undefined key, so a stale translation under a reused name wins. No test compares `%s`/`%d` placeholders.
- **Localizing Diagnostics text**: it lives in `ns.DiagnosticsStrings` (`Diagnostics/Diagnostics-Core.lua`) as plain English, outside `Locales/`.
- **Running the suite from another folder**: `ROOT` comes from `arg[0]`, but the Discovery-equals-Vanilla stat check (`statFileBody`) opens `Data/...` relative to the working directory. Run `lua5.1 Tests/Run.lua` from the add-on root.
- **Trusting the fake for client gaps**: `C_EventUtils.IsEventValid` always answers true and an undefined global resolves to a permissive stub. Client absence is tested only through `absentGlobals` or a `loadAddon(nil, beforeFiles)` override.
- **Handler errors in tests**: the fake `securecallfunction` swallows them like the client; `test()` turns each into a failure via `env.__state.handlerErrors`. The helper `fire()` calls handlers directly.
- **A vendored library missing from `.pkgmeta` externals, or listed but not committed**: CI fails, and the release would never update it.
- **Renaming legacy saved keys**: `profile.lootNotifications` (Enable Loot Announcements), `profile.ignoredItemsSolo` (Item Overrides) and `profile.ignoredItemsMaster` (Ignore List) keep their names on purpose; renaming saved data needs a migration.

### Master Looting

- **Announcing inline with `GiveMasterLoot`**: posts "Gave X to Y" for gives that then fail, twice after a retry. Register a pending hand-out; `LOOT_SLOT_CLEARED` emits.
- **Clearing the registry without flushing manual entries**: any new path that wipes `pendingHandouts` calls `FlushPendingManualAnnouncements` first, as `OnLootOpened`/`OnLootClosed` do.
- **Dropping the `true` third arg to `GiveMasterLoot`**: the manual hook registers every automated give a second time.
- **Retrying a refused give**: `distributedSlots` is set before the give resolves on purpose; the registry reports the failure and the ML hands it out by hand.
- **One "last attempt" value for error attribution**: `UI_ERROR_MESSAGE` names no item; attribute to the oldest pending entry.
- **Matching loot errors on text, or mapping an ML-side error**: match numeric ids; `ERR_INV_FULL`/`ERR_LOOT_BAG_FULL`/`ERR_ITEM_MAX_COUNT`/`ERR_TOO_FAR_TO_INTERACT` are the ML's own and would blame the recipient.
- **Confusing `ERR_*` globals with `ERROR_*` locale keys**: `ERROR_CONSTANT_TO_LOCALE_KEY` maps unquoted Blizzard constant names to GogoLoot locale keys; different namespaces.
- **Gating failure reports on the success toggles**: always register; `silentSuccess` silences only the success line.
- **Expecting Loot Announcements off to silence failures**: `FlushLootError` prints them to the ML instead; deliberate.
- **Changing the distribution gate order without Diagnostics**: `MasterLootSlotVerdict` restates `TryDistributeSlot`'s order and candidate-map logic.
- **Testing unreadable loot state with `ns:SafeGetLootMethod()`**: it maps nil to `"group"`, so a loading screen reads as a method change and wipes destinations. Use `ns:SafeCallLootMethod() == nil` (as `IsLootStateUnreadable` does).
- **Recording readings taken during the settle window**: freeze instead, so a real change mid-loading-screen is caught when `BeginZoneChangeSettle` replays `OnGroupRosterUpdate`.
- **Resetting destinations on every `PARTY_LOOT_METHOD_CHANGED`**: wipes a live setup on ML reassignment. Compare against `lastObservedLootMethod`, refreshed from roster updates too.
- **Narrowing the pop-up trigger to the loot-method event**: misses the role falling to you when the ML leaves.
- **Refreshing on every `GROUP_ROSTER_UPDATE`**: closes any open dropdown mid-raid. Keep the `PanelSignature` + on-screen gate.
- **Treating an unnameable roster unit as gone**: secret or unloaded names would read as leavers; `GetCurrentGroupMemberLookup` aborts the sweep instead.
- **Resetting or falling back to `"self"`**: setup resets go to unset; only a reachable quality whose named player left becomes `"self"`.
- **Seeding `destinations` or saving Loot Window**: unset is the only "nobody picked"; a seeded value is re-applied by AceDB every login and a saved one reads as a real destination.
- **Adding a pop-up row without re-measuring `POPUP_HEIGHT`**: the window is fixed-size, so the fullest state scrolls.

### Automated Rolls and Character Rules

- **Letting Item Overrides bypass `autoGreed`**: the switch gates everything; `DecideRoll` and `EvaluateRoll` both check it first (the latter so an off switch never schedules a retry).
- **Moving `ns:IsQuestClassItem` ahead of Item Overrides, or merging it into `ns:IsNeverAutomatedItem`**: the default list's war-effort tokens are quest-class, so the list silently stops rolling them (right IDs, right action, no roll, no error). `ShouldSkipItemForMasterLoot` is the combined form, for distribution only.
- **Treating a nil `GetLootRollItemLink` as a dead roll, or adding a liveness probe to the retry tick**: it is nil for cold items too. Return false and let `CANCEL_LOOT_ROLL` tear down.
- **Shrinking `ROLL_RETRY_MAX_ATTEMPTS` into a give-up point**: slow item queries then drop rolls with no error. It must outlast the roll window.
- **Gating rolls on the loot method**: silently stops rolls that do open during a master-loot session.
- **Low-Level Gear Greeds gear the character wants**: deliberate; it runs before the `WANTED` check. Required level 0 counts as low-level, so a no-requirement wanted ring within the context's quality Greeds unless the row is Off.
- **Expecting Everything Else to have its own quality cap**: it uses the context's Up to Quality.
- **Reading `ns.CHARACTER_RULE_STATS` / `_GROUPS` / `_GEAR_GROUPS` at file scope before the prune**: `KeepOfferedStats` and `KeepOfferedGearGroups` mutate them at load; such code loads after `Features/Character-Rule-Stats.lua` (as `Diagnostics/Manifests.lua` does).
- **A flavor folder without `ns.CHARACTER_RULE_EQUIP_SPELLS`**: `EquipLinePatterns` calls `pairs()` on it with no nil guard. Every folder declares it (`{}` when empty); only Diagnostics nil-guards.
- **Trusting `GetItemStats` alone**: base item only on the Classic clients, and secondaries are Equip spells there. `ns.ReadCharacterRuleStats` adds tooltip and Equip lines.
- **Building tooltip patterns from `ITEM_MOD_*_SHORT`**: several locales word the line apart from the label; use the full format and strip deDE's `%1$`.
- **Reusing an Equip spell ID across folders**: the same ID words different stats per client.
- **Keying a Character Rules multiselect by label**: AceConfigDialog sorts by key, so keys are zero-padded places mapped back to rows.
- **Keying the character tree by position**: the tree remembers selection by key; a shifting index silently opens another character's rules.
- **Expecting the Hide Roll Messages filter to stop other handlers**: chat filters only change drawing.
- **Gating roll-line recording on the toast switch, or dropping `Features/Loot-Toasts-Winning-Rolls.lua`**: the winner summary (`ns.OnRollWon`) is fed from it, toasts on or off.
- **Changing `ROLL_RETRY_TIMER_PREFIX` or the safety-warning conditions**: `Diagnostics/Manifests.lua` keeps its own copy of the prefix and re-derives the warning gate in `AppendRollSafetyLines`.
- **Need with no Need button**: `ExecuteRollOverride` falls back to Greed, and Greed with no Greed button rolls nothing; Diagnostics' NEED verdict may roll Greed.
- **Editing the macro in combat, or calling `CreateMacro` bare**: refused in combat (deferred to `PLAYER_REGEN_ENABLED`); throws on a full General tab (`pcall`).
- **Deleting the Roll Macro at login when the switch is off**: would destroy a same-named player macro. Only the switch deletes.
- **Reading raid rolls from party/raid chat events**: spoofable. Only `CHAT_MSG_SYSTEM`.
- **Dropping Raid Roll Winner's prefix registration as redundant with Roll Calls**: Roll Calls is parked; without it claims never arrive.

### Looting, Opening and Toasts

- **A second `LOOT_READY` handler that reads loot slots**: it runs after Speedy Loot's pass (TOC order) and finds them empty. Put it inside `OnLootReady`, before `RunSpeedyLoot`.
- **Gating Speedy Loot on `WillAutoMasterLoot()`**: too narrow; any `LootSlot` in a master-loot session can steal threshold loot or pop `MasterLooterFrame_Show`. Keep `ns:AreWeMasterLooter()`.
- **Hiding the loot window on `LOOT_READY`**: no-op; the default UI shows it afterwards. Suppress through the `OnShow` hook, or on WoW Forever the `Open` post-hook; a hide from `OnShow` on the mixin frame strands an empty, un-closable "Items" window.
- **Hooking ElvUI/Tukui windows at load, or caching `ns.GetLootWindow()`**: they don't exist until login. Hooked on first `LOOT_READY`, once per frame (`HookScript` stacks).
- **Hiding over an uncached item**: nil bind type may be BoP; hiding cancels its bind question and leaves it on the corpse. Nil counts as possibly BoP.
- **Reopening loot after a refused pickup**: would mean holding every session open invisibly, which strands WoW Forever's close animation. It is reported, not reopened.
- **Skipping Ignore items in Speedy Loot**: Ignore only keeps a container sealed; loot left in the window (a fishing catch) is lost for good.
- **Reacting to every full-bag error in Automated Opening**: loot, trade and mail raise it too. Pause only while our open is pending.
- **Lock-checking only lockboxes**: any Open item can read Locked; unchecked, it is tried every tick into "Item is locked".
- **Confirming an open only on `LOOT_OPENED`**: a session Speedy Loot empties can close before it fires. `LOOT_READY`, `LOOT_OPENED` and a shrunken stack in `RecheckSlot` all confirm.
- **Re-arming `OpenTick` on combat or secret cast**: it would poll through a battleground. It returns; regen and the next scan restart it.
- **Starting a second open chain**: only `StartOpenTick` sets `openTimerLive`, only `OpenTick` clears it.
- **Calling `ns.ScheduleOpeningScan` before the world load**: it returns silently until `worldReady`.
- **Saving an Openables default, or a choice equal to its default**: freezes the row against later data changes. `SetOpeningAction` deletes such entries.
- **Deleting a removed listed item's entry instead of writing `ns.OPENING_REMOVED`**: the data row reappears. Only player-added items are deleted outright.
- **Reading the reason tag from the player's action**: tag and note come from the data default, so a row set to Open still reads Sell Sealed.
- **Letting gear or bags into the Openables List**: using them equips and binds. `ns:CanAddOpeningItem` also treats `INVTYPE_NON_EQUIP_IGNORE` as no slot.
- **Treating an `"unknown"` loot source as item loot**: GUIDs can arrive after the window opens; closing the chime window there silences a real corpse.
- **Playing the Pick Pocket sound on the cast**: the cast succeeds on empty pockets. The cast arms; a non-empty loot window plays.
- **A toast cap of literal zero**: Unlimited is stored as `ns.LOOT_TOAST_UNLIMITED` and resolves to `math.huge` first.
- **A `ns.ReleaseLootToast` that can remove nothing**: callers loop until a list shrinks; list removals always run, only pooling is guarded.
- **Stopping a toast fade without `restarting`**: `Stop` can fire `OnFinished`, which releases the row.
- **Mouse-enabling the toast row frame**: it is `RowWidth()` wide, an invisible strip over the world. Only the hover child, motion only, only with tooltips on.
- **Calling `SetJustifyH` before `SetFont`**: `SetFont` resets justification; `Measure` sets the font first.
- **Anchoring toast rows or the tooltip to row center/width**: font or width changes walk the stack; rows pin to an anchor corner, the tooltip to the hover child.
- **Deriving the handle's size from the font**: it marks where rows start; a drifting size moves the stack.
- **Syncing Standard Loot Messages on every login**: undoes a box the player re-ticked. Act only on a change of wanted state; give back only groups GogoLoot took.
- **Registering `LOOT_ITEM_ROLL_WON` on `AlertFrame` unconditionally**: Classic `AlertFrame` never listened. `ns.HasBlizzardRollWonWindow` caches the original state before any touch.
- **Deferring the lockbox tooltip block with `C_Timer.After(0)`**: strobes, since a hovered bag button re-runs `SetBagItem` every frame. Add inside the build; hook at `PLAYER_LOGIN`.
- **Learning the Lockpicking name from the tooltip or spell**: circular, or wrong in esMX. Skill line only.
- **Assuming `ns.GetLockpickingSkillName` exists**: Lockbox Tooltips is out of the Mists TOC; callers check the function (as `BuildLockboxOptions` does).
- **Relying on a constant defined in a parked file**: `CurrencyLook` (`Loot-Toasts-Money.lua`) falls back to `ns.LOOT_WINDOW_QUESTION_ICON`, defined only in parked `Loot-Windows.lua`, so in game an undescribable currency gets a nil icon. Tests load parked files and miss this class of bug.

### Shared Code, Options and Messages

- **A new sender that skips `ns:Announce`**: it escapes the Enable Loot Announcements switch. Route through `Announce` / `AnnounceParts`, and give any print-instead path its own `lootNotifications` check, as `PrintTradeSummary` does.
- **Stripping pipes in `Announce` / `BuildAnnounceMessage`**: destroys the item links the bodies carry.
- **Splitting a long message anywhere but a part boundary**: a link cut mid-escape is rejected. Build a parts list for `ns:AnnounceParts`, which measures bytes (ruRU is the overflow canary).
- **A missing locale key in `Announce`**: `BuildAnnounceMessage` returns nil and the send is silently dropped.
- **Reading the trade enchant slot at one fixed return**: player 5, target 6; pass the position per function or every service on our item drops, Pick Lock included. Attribution is crossed: our slot means they did the service.
- **Following `TRADE_PLAYER_ITEM_CHANGED` to the end of a trade**: WoW Forever empties our side before the result. Record at acceptance.
- **Treating `group` trade output as silent when solo**: it falls back to whispering the partner.
- **Matching a game message on its text**: only the trade path keeps an `ERR_TRADE_*` text fallback, for a client where no id resolved. Match numeric ids, resolve lazily, never save them.
- **A second inventory-full test beside `ns.IsBagFullErrorID`**: Automated Opening and the event log would disagree exactly when a bug report needs the line.
- **Raw `C_Timer.After` for anything cancellable**: use `ns:After` with a named identifier, and keep its global generation counter (see Timers).
- **Setting the scan tooltip's owner once, or testing `LOCKED` as a substring**: every box reads unlocked, or another add-on's line reads as locked.
- **Caching `ns.ItemStartsQuest` for a cold item**: the tooltip lacks the line yet, so the cache would hold a permanent "no".
- **Asking `ns.ParseGroupLootMessage` before `ns.ParseOwnLootMessage`**: in zhCN the player's own line parses as a looter named 你.
- **Matching uncounted loot/currency formats first**: `"%s."` swallows `x2` into the link. Counted forms first, whole-line anchored.
- **Mutating a roll parser's answer table**: the matchers memoize and return one shared table per list.
- **Putting plain won formats before `*_NO_SPAM_*`**: the plain form matches the no-spam lines too and loses the winning roll.
- **Matching `LOOT_ROLL_STARTED` as a pattern**: it is bare `%s` and would hide any line with a link. Recognise it by shape.
- **Picking a compatibility API by truthy result** (`modern() or legacy()`): a legitimate false falls through to the legacy read. Decide by availability, once, in `Features/Utilities.lua`, and add an `ns.DIAGNOSTIC_API_CHECKS` row.
- **Comparing names raw, or with `UnitName` alone**: use `ns:NormalizePlayerName` and `ns:GetCleanUnitName` (WoW Forever's realm slot holds the last name; secret → nil).
- **Calling `ns.RefreshSettings()` from a frequent event**: it calls `NotifyChange` on every panel, and each closes any open dropdown. Repaint only on a real change (the master looter's roster signature is the precedent).
- **Expensive work in a panel builder**: panels rebuild on every refresh. Building an item list queries every item and arms the watcher, so Item Overrides builds no list while its switch is off.
- **Migrating the item lists to `Kit.ItemList` / `Kit.WarmItems`**: loses refused-ID handling (`success = false`), kind sections, filter, New and tags.
- **Editing `Options/Options-Kit.lua`, `Data/Flavor.lua` or `Features/Menu-Kit.lua` here**: Options-Kit is byte-checked against Common-Core by CI and `Data/Flavor.lua` is Common-Core's canonical file; change upstream and sync. Put add-on behavior in `Options/Options-Utilities.lua` / `Features/Minimap-Menu.lua`.
- **Calling `Kit.FeatureSwitch` directly for a feature with `descArgs`**: the tooltip shows a raw `%s`. Use `ns.FeatureSwitch` / `ns.FeatureSwitches`; the latter reaches into `Kit.Pairs`' `pairN` / `cellN` keys, so a kit rename of those breaks it silently.
- **Expecting `ns.FEATURES[].click` to change a mini-map click**: nothing reads it. Edit `CLICKS` in `Features/Minimap-Menu.lua`.
- **Putting `hidden` on a cell instead of its row group**: the line stays as a blank. Gate the `Kit.Row` / `Kit.SubRow` group.
- **Hiding a child panel behind its parent's switch**: it opens blank. Use `ns.AddFeatureOffLine`.
- **A text caption on the item-row remove column**: an `execute` with no `image` renders as a Button whose insets clip the text. Keep `name = ""` and the label in `desc`.
- **Filtering on Enter only, or redrawing per keystroke**: the stock EditBox reports Enter alone, and a redraw per key rebuilds hundreds of rows and drops focus. The filter widget writes its own filter, redraws after `FILTER_REFRESH_DELAY` and hands focus back via the entry's `arg = { registryName }`.
- **Lower-casing a filter with `string.lower` alone**: misses Cyrillic and accented capitals. Use `FoldCase`.
- **Reordering the Options block of the TOC**: `Options/Options-Kit.lua` loads first (its grid is read at load), and `Options/Options-Utilities-Item-List-Widgets.lua` captures `ns.SetItemListFilter`, `ns.ITEM_LIST_REMOVE_ICON` and `ns.MeasureCaptionPixels` at load, so the filter and list files load before it.
