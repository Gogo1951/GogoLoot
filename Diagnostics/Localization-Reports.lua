local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys
local D = ns.DiagnosticsStrings

--------------------------------------------------------------------------------
-- Locale Context
--------------------------------------------------------------------------------

function ns:BuildLocaleContextReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format("GetLocale: %s", tostring(GetLocale()))
	lines[#lines + 1] = string.format("textLocale CVar: %s", tostring(GetCVar("textLocale")))
	lines[#lines + 1] = string.format("audioLocale CVar: %s", tostring(GetCVar("audioLocale")))
	lines[#lines + 1] = string.format("Locale keys (ns.L): %d", CountKeys(ns.L))
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    One line per ns.DIAGNOSTIC_NAME_LOOKUPS row: the name this client returns
    through the row's own lookup, or NIL. A row with a request function names
    something that loads late, so the report asks for it and polls with
    Validate Data's cadence before settling it as NIL. Every timer carries the
    run's generation, so Stop retires the chain.
]]
local NAME_POLL_SECONDS = 0.5
local NAME_REASK_POLLS = 3
local NAME_MAX_IDLE_POLLS = 12

local nameRun = { generation = 0 }

-- The row's name, or nil and the message when its lookup throws.
local function ReadName(row)
	local ok, name = pcall(row.lookup)
	if not ok then
		return nil, tostring(name)
	end
	if name == nil or tostring(name) == "" then
		return nil, nil
	end
	return tostring(name), nil
end

-- Line breaks shown as a literal \n, and pipes escaped so links paste as text.
local function ShownText(text)
	local shown = text:gsub("\r?\n", "\\n")
	shown = shown:gsub("|", "||")
	return shown
end

local function PendingRows()
	local pending = {}
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		if row.request and not ReadName(row) then
			pending[#pending + 1] = row
		end
	end
	return pending
end

local function RequestRows(rows)
	for _, row in ipairs(rows) do
		pcall(row.request)
	end
end

local function FinishNames(run)
	local lines = { GetClientHeader(), "" }
	local missing = 0
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		local name, problem = ReadName(row)
		if not name then
			missing = missing + 1
		end
		lines[#lines + 1] = string.format(
			"[%s] %s (%s %s): %s",
			name and "OK" or "NIL",
			row.constant,
			row.kind,
			tostring(row.id),
			ShownText(name or problem or "")
		)
	end
	local onFinish = run.onFinish
	run.onFinish = nil
	if onFinish then
		onFinish(
			table.concat(lines, "\n"),
			missing == 0 and D.NAMES_ALL_FOUND or string.format(D.NAMES_SOME_NIL, missing)
		)
	end
end

local function ScheduleNames(run, delay, step)
	local generation = run.generation
	C_Timer.After(delay, function()
		if run.generation ~= generation then
			return
		end
		local ok, problem = pcall(step, run)
		if not ok then
			local onFinish = run.onFinish
			run.onFinish = nil
			run.generation = run.generation + 1
			if onFinish then
				onFinish(nil, nil, tostring(problem))
			end
		end
	end)
end

local function PollNames(run)
	local pending = PendingRows()
	if #pending == 0 then
		FinishNames(run)
		return
	end
	if #pending < run.pendingCount then
		run.pendingCount = #pending
		run.idlePolls = 0
	else
		run.idlePolls = run.idlePolls + 1
	end
	if run.idlePolls >= NAME_MAX_IDLE_POLLS then
		FinishNames(run)
		return
	end
	if run.idlePolls > 0 and run.idlePolls % NAME_REASK_POLLS == 0 then
		RequestRows(pending)
	end
	ScheduleNames(run, NAME_POLL_SECONDS, PollNames)
end

--[[
    onFinish(text, note) receives the finished report and its status note, or
    onFinish(nil, nil, problem) when a step threw. A stopped run never calls it.
]]
function ns:StartNameLookupReport(onFinish)
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = onFinish
	nameRun.idlePolls = 0
	local pending = PendingRows()
	nameRun.pendingCount = #pending
	if #pending == 0 then
		ScheduleNames(nameRun, 0, FinishNames)
		return
	end
	RequestRows(pending)
	ScheduleNames(nameRun, NAME_POLL_SECONDS, PollNames)
end

function ns:StopNameLookupReport()
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = nil
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- The stack size each traded item is counted at, and the coin on each side: 999g 99s 99c.
local EXAMPLE_STACK = 20
local EXAMPLE_MONEY = 9999999

-- The longest distinct item links in the bags, longest first, up to count.
local function LongestBagLinks(count)
	local links, seen = {}, {}
	for _, link in ipairs(ns.DiagnosticBagItemLinks()) do
		if not seen[link] then
			seen[link] = true
			links[#links + 1] = link
		end
	end
	table.sort(links, function(a, b)
		return #a > #b
	end)
	for index = #links, count + 1, -1 do
		links[index] = nil
	end
	return links
end

-- The longest name in the group as GogoLoot writes it in chat, the player's own included.
local function LongestGroupName()
	local longest = ns:FormatPlayerName(ns:GetCleanUnitName("player"))
	local unitPrefix = IsInRaid() and "raid" or "party"
	for memberIndex = 1, GetNumGroupMembers() do
		local name = ns:GetCleanUnitName(unitPrefix .. memberIndex)
		local shown = name and ns:FormatPlayerName(name)
		if shown and #shown > #longest then
			longest = shown
		end
	end
	return longest
end

-- The quality labels the destination lines name, longest first, and all of them as a leaver's line lists them.
local function QualityLabels()
	local longest, all = "", {}
	for quality = 0, 4 do
		local label = ns.QUALITY_DISPLAY_NAMES[ns.RARITY_TO_CONFIGURATION_KEY[quality]] or ""
		all[#all + 1] = label
		if #label > #longest then
			longest = label
		end
	end
	return longest, table.concat(all, ", ")
end

-- The master-loot failure reports, by locale key, in key order.
local function LootErrorKeys()
	local keys, seen = {}, {}
	for _, localeKey in pairs(ns.LOOT_ERROR_CONSTANTS) do
		if not seen[localeKey] then
			seen[localeKey] = true
			keys[#keys + 1] = localeKey
		end
	end
	table.sort(keys)
	return keys
end

-- One message against the chat limit: OVER past it, or the given status for a message that is split instead.
local function AppendMessage(lines, key, message, note, overStatus)
	if not message then
		lines[#lines + 1] = string.format("[MISSING] %s: no template", key)
		return
	end
	local over = #message > ns.CHAT_MESSAGE_MAX_LENGTH
	lines[#lines + 1] = string.format(
		"[%s] %s: %d bytes%s",
		over and (overStatus or "OVER") or "OK",
		key,
		#message,
		note and (", " .. note) or ""
	)
	lines[#lines + 1] = "    " .. ShownText(message)
end

--[[
    Every message ns:Announce sends (Features/Announcements.lua), built through
    ns:BuildAnnounceMessage and the trade summary's own builder with the longest
    item links in the bags and the longest name in the group, and measured
    against the chat limit. A trade summary that won't fit in one message is
    sent as two item lists instead, SPLIT here. The lists and the failure
    reports split at item boundaries, so only one item too long on its own can
    go OVER, which is what their lines measure. Builds strings only.
]]
function ns:BuildMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	local links = LongestBagLinks(ns.TRADE_ITEM_SLOT_COUNT)
	if #links == 0 then
		lines[#lines + 1] = "No items in the bags: put something in them to measure with."
		return table.concat(lines, "\n")
	end
	local link, name = links[1], LongestGroupName()
	local longestLabel, allLabels = QualityLabels()
	lines[#lines + 1] = string.format("Longest item link in your bags: %d bytes", #link)
	lines[#lines + 1] = string.format("Longest name in your group: %s (%d bytes)", name, #name)
	lines[#lines + 1] = string.format("Chat limit: %d bytes", ns.CHAT_MESSAGE_MAX_LENGTH)
	lines[#lines + 1] = ""

	AppendMessage(lines, "MESSAGE_GAVE", ns:BuildAnnounceMessage("MESSAGE_GAVE", link, name), "a master loot hand-out")
	AppendMessage(
		lines,
		"MESSAGE_DESTINATION_SET",
		ns:BuildAnnounceMessage("MESSAGE_DESTINATION_SET", name, longestLabel)
	)
	AppendMessage(lines, "MESSAGE_DESTINATION_SET_ALL", ns:BuildAnnounceMessage("MESSAGE_DESTINATION_SET_ALL", name))
	AppendMessage(
		lines,
		"MESSAGE_DESTINATION_LEFT",
		ns:BuildAnnounceMessage("MESSAGE_DESTINATION_LEFT", name, name, allLabels),
		"every quality named"
	)
	AppendMessage(
		lines,
		"MESSAGE_DESTINATION_LEFT_ALL",
		ns:BuildAnnounceMessage("MESSAGE_DESTINATION_LEFT_ALL", name, name)
	)

	lines[#lines + 1] = ""
	local tradeItems = {}
	for slotIndex, tradeLink in ipairs(links) do
		tradeItems[slotIndex] = { link = tradeLink, count = EXAMPLE_STACK }
	end
	local summary = ns.FormatTradeSummary(tradeItems, nil, EXAMPLE_MONEY)
	AppendMessage(
		lines,
		"MESSAGE_TRADE_GAVE_RECEIVED",
		ns:BuildAnnounceMessage("MESSAGE_TRADE_GAVE_RECEIVED", summary, name, summary),
		string.format("%d items and coin each way", #links),
		"SPLIT"
	)
	local onePart = ns.FormatTradeSummary({ { link = link, count = EXAMPLE_STACK } }, nil, 0)
	AppendMessage(
		lines,
		"MESSAGE_GAVE",
		ns:BuildAnnounceMessage("MESSAGE_GAVE", onePart, name),
		"one traded item, the longest a split list's message gets"
	)
	AppendMessage(
		lines,
		"MESSAGE_TRADE_RECEIVED",
		ns:BuildAnnounceMessage("MESSAGE_TRADE_RECEIVED", onePart, name),
		"one traded item"
	)

	lines[#lines + 1] = ""
	for _, localeKey in ipairs(LootErrorKeys()) do
		AppendMessage(lines, localeKey, ns:BuildAnnounceMessage(localeKey, name, link), "one item")
	end
	return table.concat(lines, "\n")
end
