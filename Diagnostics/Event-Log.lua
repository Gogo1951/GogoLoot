local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent drops before recording -- deliberately empty. The
    dispatcher only ever hands LogEvent the events GogoLoot registers (Core's
    ns.EVENT_NAMES), and none of those is a sustained firehose worth dropping:
    the add-on listens on the coalesced BAG_UPDATE_DELAYED rather than raw
    BAG_UPDATE, hears UNIT_SPELLCAST_SUCCEEDED for the player alone, and every
    registered event is potential signal in a bug report. GET_ITEM_INFO_RECEIVED
    is the one candidate if a cache-warm burst (many items resolving at once
    when an item list opens) ever buries the signal. The lookup in LogEvent
    stays so a firehose can be excluded here if one is ever registered; one that
    is sometimes signal has its deciding handler write those firings back
    through ns:LogEventNow. Generic offenders (COMBAT_LOG_EVENT_UNFILTERED,
    UNIT_AURA, ...) do not belong here unless registered -- the log never sees
    an event the add-on didn't register.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {}

--[[
    Events that carry a message id, and the argument position it arrives in,
    for ns:SuppressUncorrelatedMessage to classify per firing rather than drop
    wholesale. The client raises UI_ERROR_MESSAGE for every red error and
    UI_INFO_MESSAGE for every yellow info line, combat spam included, so one
    grinding session would otherwise bury the buffer in "Ability is not ready
    yet." and evict the loot signal.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	UI_ERROR_MESSAGE = 1,
	UI_INFO_MESSAGE = 1,
}

--[[
    A secret value (WoW Forever) errors when compared, concatenated or used as
    a table key, so the log never turns one into text. Clients without secret
    values have no issecretvalue, and every value there is plain.
]]
local IsSecretValue = rawget(_G, "issecretvalue")

local function IsPlain(value)
	return not (IsSecretValue and IsSecretValue(value))
end

-- The counter id a secret message id folds into, since a secret can't key a table.
local SECRET_ID = 0

--[[
    Folds one uncorrelated firing into its counter: the first-seen text plus a
    count. Counters are keyed by event, then id, so one id arriving on two
    events stays two rows. A secret id counts under SECRET_ID with the text
    <secret>.
]]
local function CountUncorrelated(event, id, text)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	if not IsPlain(id) then
		id, text = SECRET_ID, "<secret>"
	elseif not IsPlain(text) then
		text = "<secret>"
	end
	local counters = suppressed[event]
	if not counters then
		counters = {}
		suppressed[event] = counters
	end
	local entry = counters[id]
	if entry then
		entry.count = entry.count + 1
		return
	end
	local raw = string.sub(tostring(text or ""), 1, EVENT_LOG_MAX_ARG_LENGTH)
	counters[id] = { text = (raw:gsub("|", "||")), count = 1 }
end

--[[
    The ids GogoLoot acts on, which are the filter's allowlist: the master-loot
    errors and the trade results, resolved through the same one walk the live
    handlers use, and the pickups the bags refused (inventory full, which also
    pauses Automated Opening, and a unique item already carried), through the
    test Speedy Loot's warning uses. Built on first use, not at load, like the
    live handlers' maps:
    the walk scans the client's whole message table, and nothing needs it until
    a message fires while logging.
]]
local correlatedMessageIds

local function IsCorrelatedMessageId(messageID)
	if ns.IsLootBounceErrorID(messageID) then
		return true
	end
	if not correlatedMessageIds then
		local wantedConstants = {}
		for constantName in pairs(ns.LOOT_ERROR_CONSTANTS) do
			wantedConstants[constantName] = true
		end
		for constantName in pairs(ns.TRADE_RESULT_CONSTANTS) do
			wantedConstants[constantName] = true
		end
		correlatedMessageIds = {}
		for resolvedId in pairs(ns:ResolveGameMessageIds(wantedConstants)) do
			correlatedMessageIds[resolvedId] = true
		end
	end
	return correlatedMessageIds[messageID] == true
end

--[[
    Per-firing filter for the events above. A firing whose id the add-on does
    not correlate folds into its counter, rendered as one block at the end of
    the report, so firehose traffic can't evict the entries the log exists to
    carry. A secret id counts too, since it can't be checked against the
    allowlist. A plain firing carrying no numeric id in the filtered position is
    unclassifiable, and unclassifiable is signal: it logs verbatim. The
    counter's text is the argument after the id, or blank when none follows.

    Returns true when the firing was counted and must not reach the buffer.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local idPosition = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	if not idPosition then
		return false
	end
	local messageID = select(idPosition, ...)
	if IsPlain(messageID) and (type(messageID) ~= "number" or IsCorrelatedMessageId(messageID)) then
		return false
	end
	local text
	if select("#", ...) > idPosition then
		text = select(idPosition + 1, ...)
	end
	CountUncorrelated(event, messageID, text)
	return true
end

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
    One entry in the buffer, for ns:LogEvent and ns:LogEventNow below.
    Snapshots arguments to strings immediately -- never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and per-argument byte length so a single entry can't run away.
    A secret argument (WoW Forever) can't be turned into text, so it records as
    <secret>.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox instead of rendering as a clickable item
    swatch. Escaping last also means the cut can never leave a dangling pipe that
    would eat the following ", " separator.
]]
local function AppendEntry(event, ...)
	local log = ns.diagnostics.log
	if not log then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		local value = select(index, ...)
		if IsPlain(value) then
			local raw = string.sub(tostring(value), 1, EVENT_LOG_MAX_ARG_LENGTH)
			parts[index] = (raw:gsub("|", "||"))
		else
			parts[index] = "<secret>"
		end
	end
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

-- Called by Core's central dispatcher for every event while logging is active.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	if ns:SuppressUncorrelatedMessage(event, ...) then
		return
	end
	AppendEntry(event, ...)
end

--[[
    The way back in for an excluded firehose that is sometimes signal: the
    handler that decides a firing mattered calls this with the event and its
    arguments, and it is recorded as the dispatcher would have, past the
    exclude list. Feature code calls it, so it carries the dispatcher's own
    single boolean check before any work.
]]
function ns:LogEventNow(event, ...)
	if not ns.diagnostics.logging then
		return
	end
	AppendEntry(event, ...)
end

--[[
    Renders the suppressed-traffic counters as one compact block, biggest
    offender first. This is also how a tester discovers a message id the add-on
    should be correlating but isn't.
]]
local function AppendSuppressedSummary(lines)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local rows = {}
	for event, counters in pairs(suppressed) do
		for id, entry in pairs(counters) do
			rows[#rows + 1] = { event = event, id = id, entry = entry }
		end
	end
	if #rows == 0 then
		return
	end
	table.sort(rows, function(a, b)
		if a.entry.count ~= b.entry.count then
			return a.entry.count > b.entry.count
		end
		if a.event ~= b.event then
			return a.event < b.event
		end
		return a.id < b.id
	end)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Suppressed uncorrelated traffic:"
	for _, row in ipairs(rows) do
		if row.id == SECRET_ID then
			lines[#lines + 1] = string.format("%s(<secret>) x%d", row.event, row.entry.count)
		else
			lines[#lines + 1] = string.format("%s(%d, %s) x%d", row.event, row.id, row.entry.text, row.entry.count)
		end
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	AppendSuppressedSummary(lines)
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
