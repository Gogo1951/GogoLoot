--------------------------------------------------------------------------------
-- GogoLoot Diagnostic Tools
--------------------------------------------------------------------------------

--[[
    Environment probing and state capture for bug reports, not unit tests. WoW's
    sandboxed Lua has no assertion runner, so everything here is read-only and
    side-effect free. The one exception is the explicit Taint Log button, which
    sets the taintLog CVar. Reports build only on a button press, never on load
    or panel open.
]]
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Runtime State
--------------------------------------------------------------------------------

--[[
    Runtime-only state. NOT a SavedVariable. File-scope init is correct here —
    the "initialize on PLAYER_LOGIN" rule applies only to SavedVariables, which
    don't exist until the client loads them. This is a plain namespace table, so
    diagnostics always starts off and leaves nothing persisted at logout.
]]
ns.diagnostics = ns.diagnostics or {enabled = false, logging = false, log = nil}

--------------------------------------------------------------------------------
-- Strings
--------------------------------------------------------------------------------

--[[
    Diagnostics strings are intentionally NOT localized. They are
    developer-facing troubleshooting text; translating them is wasted effort for
    zero player value. Every diagnostics string lives here as plain English, in
    the diagnostics files only — never in Locales/. The one exception is the
    add-on's own display name, read from ns.L["ADDON_TITLE"], which is the
    add-on's identity, not a diagnostics string.
]]
ns.DiagnosticsStrings = {
    TAB = "Diagnostic Tools",
    WARNING = "These tools help diagnose problems and are meant for developers. They won't change how the add-on works, but their output includes technical details about your client and installed add-ons. Leave this off unless you're troubleshooting with someone.",
    ENABLE = "Enable Diagnostic Tools",
    EVENT_LOG_TITLE = "Event Log",
    EVENT_LOG_START = "Start Event Log",
    EVENT_LOG_STOP = "Stop Event Log",
    EVENT_LOG_SHOW = "Show Captured Events",
    EVENT_LOG_HINT = "Captures events the add-on registered for, with arguments, in order fired. May include loot chat text — review before sharing.",
    EVENTS_TITLE = "Event Registration",
    EVENTS_BUTTON = "Test Event Registration",
    API_TITLE = "API Endpoints",
    API_BUTTON = "Test WoW API Endpoints",
    LOOT_TITLE = "Loot Method",
    LOOT_BUTTON = "Test Loot Method API",
    ADDONS_TITLE = "Other Add-ons",
    ADDONS_BUTTON = "List Installed Add-ons",
    SAVED_TITLE = "Saved Variables",
    SAVED_BUTTON = "Dump Saved Variables",
    LIBS_TITLE = "Library Versions",
    LIBS_BUTTON = "List Library Versions",
    TAINT_TITLE = "Taint Log",
    TAINT_STATE = "Taint logging is currently set to level %d (0 = off, 2 = verbose).",
    TAINT_ON = "Turn On Taint Log",
    TAINT_OFF = "Turn Off Taint Log",
    TAINT_HINT = "Writes to Logs\\taint.log. The setting persists until turned off; reload your UI to capture taint from login onward.",
    TOOLS_TITLE = "External Tools",
    TOOLS_ERRORS = "Lua errors: install BugSack and !BugGrabber, or enable %s to surface them.",
    TOOLS_ETRACE = "Live event tracing: use %s."
}

--------------------------------------------------------------------------------
-- Enable Gate
--------------------------------------------------------------------------------

function ns:SetDiagnosticsEnabled(value)
    ns.diagnostics.enabled = value and true or false
    if not ns.diagnostics.enabled then
        ns:StopEventLog()
    end
end

--------------------------------------------------------------------------------
-- Report Header
--------------------------------------------------------------------------------

local function GetClientHeader()
    local version, build, _, tocVersion = GetBuildInfo()
    return string.format(
        "%s %s // Client %s // Build %s // TOC %s // Locale %s // Project %s",
        L["ADDON_TITLE"], ns.Version, version, build, tocVersion,
        GetLocale(), tostring(WOW_PROJECT_ID)
    )
end

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8

--[[
    Per-argument byte cap. 255 holds a full loot line with its item link
    (|cff...|Hitem:...|h[Name]|h|r plus the "You receive loot:" prefix runs past
    80 bytes, so a smaller cap slices the link mid-name and the entry collapses
    to a sliver like "[Sc") while still bounding a runaway argument.
]]
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent drops before recording — deliberately empty. GogoLoot
    registers no sustained firehose; every event it uses is potential signal in
    a bug report. GET_ITEM_INFO_RECEIVED is the one candidate to add here if a
    cache-warm burst (many items resolving at once when an options list opens)
    ever buries the signal. Generic offenders (COMBAT_LOG_EVENT_UNFILTERED,
    UNIT_AURA, ...) never reach the log — the dispatcher only hands LogEvent the
    events GogoLoot actually registers.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {}

function ns:StartEventLog()
    ns.diagnostics.log = {}
    ns.diagnostics.logging = true
end

function ns:StopEventLog()
    ns.diagnostics.logging = false
    ns.diagnostics.log = nil
end

--[[
    Called by Core's dispatcher for every event while logging is active.
    Snapshots arguments to strings immediately — never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and string length so a single entry can't run away.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox. WoW treats |c colour codes and |Hitem links
    as display escapes, so an unescaped loot line renders as a clickable item
    swatch — hiding the link data we want — and a cut mid-link would otherwise
    collapse to a stray "[Sc". Escaping last also means the cut can never leave a
    dangling pipe that would eat the following ", " separator.
]]
function ns:LogEvent(event, ...)
    if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
        return
    end
    local parts = {}
    for index = 1, select("#", ...) do
        if index > EVENT_LOG_MAX_ARGS then
            break
        end
        local raw = string.sub(tostring((select(index, ...))), 1, EVENT_LOG_MAX_ARG_LENGTH)
        parts[index] = (raw:gsub("|", "||"))
    end
    local log = ns.diagnostics.log
    log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
    if #log > EVENT_LOG_SIZE then
        table.remove(log, 1)
    end
end

function ns:BuildEventLogReport()
    local lines = {GetClientHeader(), ""}
    local log = ns.diagnostics.log
    if not log or #log == 0 then
        lines[#lines + 1] = "(no events captured)"
    else
        for _, entry in ipairs(log) do
            lines[#lines + 1] = entry
        end
    end
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Event Registration
--------------------------------------------------------------------------------

--[[
    For every event GogoLoot registers (ns.EVENT_NAMES, exported by Core.lua),
    report whether it is valid on this client (C_EventUtils.IsEventValid) and
    whether RegisterEvent succeeds. The probe frame registers then immediately
    unregisters each event with no handler attached, so nothing is ever
    processed; it is a separate frame from Core.lua's dispatcher, so probing
    never disturbs live event handling. The list is sourced from Core, so it can
    never drift from the events the add-on actually uses — including on-demand,
    self-unregistering ones like Options-Utilities' GET_ITEM_INFO_RECEIVED
    watcher, which ns.EVENT_NAMES lists whether or not it is currently registered.
]]

local probeFrame

local function GetProbeFrame()
    if not probeFrame then
        probeFrame = CreateFrame("Frame")
    end
    return probeFrame
end

function ns:RunEventChecks()
    local lines = {GetClientHeader(), ""}
    local hasIsEventValid = type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
    local probe = GetProbeFrame()
    local failures = 0
    for _, event in ipairs(ns.EVENT_NAMES or {}) do
        local valid = "n/a"
        if hasIsEventValid then
            valid = C_EventUtils.IsEventValid(event) and "valid" or "INVALID"
        end
        local ok = pcall(probe.RegisterEvent, probe, event)
        if ok then
            probe:UnregisterEvent(event)
        else
            failures = failures + 1
        end
        lines[#lines + 1] = string.format("[%s] %s (IsEventValid: %s)", ok and "PASS" or "FAIL", event, valid)
    end
    lines[#lines + 1] = ""
    if failures == 0 then
        lines[#lines + 1] = "All events register on this client."
    else
        lines[#lines + 1] = string.format("%d event(s) failed to register.", failures)
    end
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. Kept aligned with the API guards in Features/Utilities.lua,
    Features/Core.lua, Features/Speedy-Loot.lua, Features/Master-Looter.lua,
    Features/Automated-Rolls.lua, and Features/Announcements-Trade.lua. Modern
    and legacy fallbacks are listed separately so the report shows exactly what
    each client provides. The error-string globals are looked up by Master
    Looter's UI_ERROR_MESSAGE correlation; a FAIL there just means this client
    doesn't bind that string and the substring fallback covers it.
]]
ns.DIAGNOSTIC_API_CHECKS = {
    -- { label, testFunction }

    -- Add-on metadata — Core.lua version lookup
    {"C_AddOns.GetAddOnMetadata", function() return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function" end},
    {"GetAddOnMetadata (legacy)", function() return type(GetAddOnMetadata) == "function" end},

    -- Item info — Utilities.lua (SafeGetItemInfo, item parsing, list sorting)
    {"C_Item.GetItemInfo", function() return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" end},
    {"GetItemInfo (legacy)", function() return type(GetItemInfo) == "function" end},
    {"C_Item.GetItemInfoInstant", function() return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function" end},
    {"GetItemInfoInstant (legacy)", function() return type(GetItemInfoInstant) == "function" end},

    -- Bag space — Speedy-Loot.lua free-slot budget
    {"C_Container.GetContainerNumFreeSlots", function() return type(C_Container) == "table" and type(C_Container.GetContainerNumFreeSlots) == "function" end},
    {"GetContainerNumFreeSlots (legacy)", function() return type(GetContainerNumFreeSlots) == "function" end},
    {"NUM_BAG_SLOTS", function() return NUM_BAG_SLOTS ~= nil end},

    -- Loot window — Speedy-Loot.lua / Master-Looter.lua
    {"GetNumLootItems", function() return type(GetNumLootItems) == "function" end},
    {"GetLootSlotType", function() return type(GetLootSlotType) == "function" end},
    {"LOOT_SLOT_ITEM", function() return LOOT_SLOT_ITEM ~= nil end},
    {"GetLootSlotLink", function() return type(GetLootSlotLink) == "function" end},
    {"LootSlot", function() return type(LootSlot) == "function" end},
    {"IsModifiedClick", function() return type(IsModifiedClick) == "function" end},

    -- Loot method & threshold — Utilities.lua / Master-Looter.lua master-loot guards
    {"GetLootMethod (legacy)", function() return type(GetLootMethod) == "function" end},
    {"C_PartyInfo.GetLootMethod", function() return type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootMethod) == "function" end},
    {"GetLootThreshold (legacy)", function() return type(GetLootThreshold) == "function" end},
    {"C_PartyInfo.GetLootThreshold", function() return type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootThreshold) == "function" end},
    {"Enum.LootMethod.MasterLoot", function() return type(Enum) == "table" and type(Enum.LootMethod) == "table" and Enum.LootMethod.MasterLoot ~= nil end},

    -- Master loot distribution — Master-Looter.lua
    {"GetMasterLootCandidate", function() return type(GetMasterLootCandidate) == "function" end},
    {"GiveMasterLoot", function() return type(GiveMasterLoot) == "function" end},
    {"hooksecurefunc", function() return type(hooksecurefunc) == "function" end},

    -- Need / Greed rolls — Automated-Rolls.lua
    {"GetLootRollItemInfo", function() return type(GetLootRollItemInfo) == "function" end},
    {"GetLootRollItemLink", function() return type(GetLootRollItemLink) == "function" end},
    {"RollOnLoot", function() return type(RollOnLoot) == "function" end},
    {"ConfirmLootRoll", function() return type(ConfirmLootRoll) == "function" end},

    -- Trade — Announcements-Trade.lua
    {"GetTradePlayerItemLink", function() return type(GetTradePlayerItemLink) == "function" end},
    {"GetTradeTargetItemLink", function() return type(GetTradeTargetItemLink) == "function" end},
    {"GetTradePlayerItemInfo", function() return type(GetTradePlayerItemInfo) == "function" end},
    {"GetTradeTargetItemInfo", function() return type(GetTradeTargetItemInfo) == "function" end},
    {"GetPlayerTradeMoney", function() return type(GetPlayerTradeMoney) == "function" end},
    {"GetTargetTradeMoney", function() return type(GetTargetTradeMoney) == "function" end},

    -- Group & instance state — multiple modules
    {"IsInGroup", function() return type(IsInGroup) == "function" end},
    {"IsInRaid", function() return type(IsInRaid) == "function" end},
    {"UnitInRaid", function() return type(UnitInRaid) == "function" end},
    {"GetNumGroupMembers", function() return type(GetNumGroupMembers) == "function" end},
    {"GetInstanceInfo", function() return type(GetInstanceInfo) == "function" end},

    -- Auto-loot CVar — Core.lua / Utilities.lua
    {"C_CVar.GetCVarBool", function() return type(C_CVar) == "table" and type(C_CVar.GetCVarBool) == "function" end},
    {"SetCVar", function() return type(SetCVar) == "function" end},
    {"GetCVar (legacy)", function() return type(GetCVar) == "function" end},

    -- Chat — Announcements.lua
    {"SendChatMessage", function() return type(SendChatMessage) == "function" end},

    -- Timers & events — Core.lua / Master-Looter.lua / diagnostics
    {"C_Timer.After", function() return type(C_Timer) == "table" and type(C_Timer.After) == "function" end},
    {"C_Timer.NewTicker", function() return type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" end},
    {"C_EventUtils.IsEventValid", function() return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function" end},

    -- Master-loot error-string globals — Master-Looter.lua UI_ERROR_MESSAGE correlation
    {"ERR_INV_FULL", function() return ERR_INV_FULL ~= nil end},
    {"ERR_LOOT_BAG_FULL", function() return ERR_LOOT_BAG_FULL ~= nil end},
    {"ERR_ITEM_MAX_COUNT", function() return ERR_ITEM_MAX_COUNT ~= nil end},
    {"ERR_LOOT_PLAYER_NOT_PRESENT", function() return ERR_LOOT_PLAYER_NOT_PRESENT ~= nil end},
    {"LOOT_PLAYER_NOT_PRESENT", function() return LOOT_PLAYER_NOT_PRESENT ~= nil end},
    {"ERR_NOT_IN_GROUP", function() return ERR_NOT_IN_GROUP ~= nil end},
    {"ERR_NOT_IN_RAID", function() return ERR_NOT_IN_RAID ~= nil end},

    -- Trade result globals — Announcements-Trade.lua
    {"ERR_TRADE_COMPLETE", function() return ERR_TRADE_COMPLETE ~= nil end},
    {"ERR_TRADE_CANCELLED", function() return ERR_TRADE_CANCELLED ~= nil end}
}

function ns:RunApiChecks()
    local lines = {GetClientHeader(), ""}
    for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
        local ok, result = pcall(check[2])
        lines[#lines + 1] = ((ok and result) and "[PASS] " or "[FAIL] ") .. check[1]
    end
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Loot Method
--------------------------------------------------------------------------------

--[[
    Live read of the loot-method APIs the master-looter path depends on. An
    existence check can't prove the APIs return the shapes GogoLoot's guards
    expect, so this prints the actual return values, the Enum.LootMethod
    constants the modern API is mapped onto (Master-Looter.lua SafeGetLootMethod),
    and how GogoLoot ultimately interprets them via AreWeMasterLooter and
    WillAutoMasterLoot. All calls are read-only.
]]

local function PackReturns(...)
    return select("#", ...), {...}
end

function ns:BuildLootMethodReport()
    local lines = {GetClientHeader(), ""}

    -- Raw API returns — legacy first, then modern, so the report shows what each client exposes.
    if type(GetLootMethod) == "function" then
        local count, values = PackReturns(GetLootMethod())
        lines[#lines + 1] = string.format("GetLootMethod() [legacy] -> %d value(s):", count)
        for index = 1, count do
            lines[#lines + 1] = string.format("  [%d] (%s) %s", index, type(values[index]), tostring(values[index]))
        end
    else
        lines[#lines + 1] = "GetLootMethod [legacy]: not available"
    end

    lines[#lines + 1] = ""
    if type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootMethod) == "function" then
        local count, values = PackReturns(C_PartyInfo.GetLootMethod())
        lines[#lines + 1] = string.format("C_PartyInfo.GetLootMethod() -> %d value(s):", count)
        for index = 1, count do
            lines[#lines + 1] = string.format("  [%d] (%s) %s", index, type(values[index]), tostring(values[index]))
        end
    else
        lines[#lines + 1] = "C_PartyInfo.GetLootMethod: not available"
    end

    -- Enum.LootMethod values the modern API is mapped onto.
    lines[#lines + 1] = ""
    if type(Enum) == "table" and type(Enum.LootMethod) == "table" then
        lines[#lines + 1] = "Enum.LootMethod:"
        for _, key in ipairs({"FreeForAll", "RoundRobin", "MasterLoot", "GroupLoot", "NeedBeforeGreed"}) do
            lines[#lines + 1] = string.format("  %s = %s", key, tostring(Enum.LootMethod[key]))
        end
    else
        lines[#lines + 1] = "Enum.LootMethod: not available (legacy string API in use)"
    end

    -- How GogoLoot interprets the above. WillAutoMasterLoot additionally depends
    -- on the Automated Master Looting setting and, outside instances, its override.
    lines[#lines + 1] = ""
    lines[#lines + 1] = "GogoLoot interpretation:"
    lines[#lines + 1] = string.format("  SafeGetLootMethod() = %s", tostring(ns.SafeGetLootMethod and ns:SafeGetLootMethod()))
    lines[#lines + 1] = string.format("  SafeGetLootThreshold() = %s (the game's Master Loot quality threshold)", tostring(ns.SafeGetLootThreshold and ns:SafeGetLootThreshold()))
    lines[#lines + 1] = string.format("  AreWeMasterLooter() = %s", tostring(ns.AreWeMasterLooter and ns:AreWeMasterLooter()))
    lines[#lines + 1] = string.format("  WillAutoMasterLoot() = %s (true = GogoLoot auto-distributes the next loot session; requires an instance or the outside-instances setting)", tostring(ns.WillAutoMasterLoot and ns:WillAutoMasterLoot()))

    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
    local lines = {GetClientHeader(), ""}
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
    local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local count = (C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns()) or GetNumAddOns()
    for index = 1, count do
        local name, _, _, loadable = getInfo(index)
        local version = getMeta(index, "Version") or "?"
        lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
    end
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
    if depth > 8 then
        lines[#lines + 1] = indent .. "<max depth>"
        return
    end
    local keys = {}
    for key in pairs(value) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, key in ipairs(keys) do
        local entry = value[key]
        if type(entry) == "table" then
            lines[#lines + 1] = indent .. tostring(key) .. " = {"
            DumpTable(entry, indent .. "    ", depth + 1, lines)
            lines[#lines + 1] = indent .. "}"
        else
            lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
        end
    end
end

--[[
    Prints every row of GogoLootDB, item lists included, rather than summarizing
    long lists by length: GogoLoot's per-item roll overrides and ignore entries
    ARE the configuration a loot bug report needs, so the full dump is a
    deliberate, sanctioned deviation from the guide's large-array advice.
]]
function ns:BuildSavedVariablesReport()
    local lines = {GetClientHeader(), "", "GogoLootDB = {"}
    DumpTable(GogoLootDB or {}, "    ", 1, lines)
    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

function ns:BuildLibraryReport()
    local lines = {GetClientHeader(), ""}
    local names = {}
    for name in LibStub:IterateLibraries() do
        names[#names + 1] = name
    end
    table.sort(names)
    for _, name in ipairs(names) do
        lines[#lines + 1] = string.format("%s (minor %s)", name, tostring(LibStub.minors[name]))
    end
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
    The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
    both blocked actions and accesses to tainted globals; 0 is off. This is the
    only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
    return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
    SetCVar("taintLog", enabled and 2 or 0)
end
