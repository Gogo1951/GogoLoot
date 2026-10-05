local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local GetClientHeader = ns.GetDiagnosticClientHeader
local STATUS_OK = ns.DIAGNOSTIC_STATUS_OK

--------------------------------------------------------------------------------
-- Report Runner
--------------------------------------------------------------------------------

--[[
    Every report the panel runs, by id, and the three tabs that group them.
    Each tab's Run All runs its reports in this order, and each report's own
    button runs just that one. The Event Log and the Taint Log are live tools
    rather than reports, so neither is here. Data gets one report per entry in
    ns.DIAGNOSTIC_DATA_SOURCES, so a new data file reaches every list by its
    manifest row alone.

    note, where a report has one, turns its text into the few words its status
    row shows. API Endpoints has none on purpose: a [FAIL] on one half of a
    modern/legacy pair is the report working, so counting them would cry wolf.
]]
local D = ns.DiagnosticsStrings

local function EventsNote(text)
	local _, failures = string.gsub(text, "%[FAIL%]", "")
	if failures == 0 then
		return D.EVENTS_ALL_PASS
	end
	return string.format(D.EVENTS_SOME_FAIL, failures)
end

ns.DIAGNOSTIC_REPORTS = {
	loot = {
		title = D.LOOT_TITLE,
		description = D.LOOT_DESCRIPTION,
		build = function()
			return ns:BuildLootMethodReport()
		end,
	},
	locked = {
		title = D.LOCKED_TITLE,
		description = D.LOCKED_DESCRIPTION,
		build = function()
			return ns:BuildLockedBoxesReport()
		end,
	},
	gear = {
		title = D.GEAR_TITLE,
		description = D.GEAR_DESCRIPTION,
		build = function()
			return ns:BuildGearStatsReport()
		end,
	},
	player = {
		title = D.PLAYER_TITLE,
		description = D.PLAYER_DESCRIPTION,
		build = function()
			return ns:BuildPlayerReport()
		end,
	},
	cvars = {
		title = D.CVARS_TITLE,
		description = D.CVARS_DESCRIPTION,
		build = function()
			return ns:BuildCVarReport()
		end,
	},
	saved = {
		title = D.SAVED_TITLE,
		description = D.SAVED_DESCRIPTION,
		build = function()
			return ns:BuildSavedVariablesReport()
		end,
	},
	display = {
		title = D.DISPLAY_TITLE,
		description = D.DISPLAY_DESCRIPTION,
		build = function()
			return ns:BuildDisplayContextReport()
		end,
	},
	addons = {
		title = D.ADDONS_TITLE,
		description = D.ADDONS_DESCRIPTION,
		build = function()
			return ns:BuildAddOnReport()
		end,
	},
	events = {
		title = D.EVENTS_TITLE,
		description = D.EVENTS_DESCRIPTION,
		build = function()
			return ns:RunEventChecks()
		end,
		note = EventsNote,
	},
	api = {
		title = D.API_TITLE,
		description = D.API_DESCRIPTION,
		build = function()
			return ns:RunApiChecks()
		end,
	},
	libs = {
		title = D.LIBS_TITLE,
		description = D.LIBS_DESCRIPTION,
		build = function()
			return ns:BuildLibraryReport()
		end,
	},
}

ns.DIAGNOSTIC_SECTIONS = {
	{
		key = "settings",
		label = D.SECTION_SETTINGS,
		reports = { "loot", "locked", "gear", "player", "cvars", "saved", "display", "addons" },
	},
	{ key = "code", label = D.SECTION_CODE, reports = { "events", "api", "libs" } },
	{ key = "data", label = D.SECTION_DATA, reports = {} },
}

for index in ipairs(ns.DIAGNOSTIC_DATA_SOURCES) do
	local id = "data" .. index
	ns.DIAGNOSTIC_REPORTS[id] = { dataIndex = index, description = D.VALIDATE_DESCRIPTION }
	table.insert(ns.DIAGNOSTIC_SECTIONS[3].reports, id)
end

function ns:GetDiagnosticSection(key)
	for _, section in ipairs(ns.DIAGNOSTIC_SECTIONS) do
		if section.key == key then
			return section
		end
	end
	return nil
end

-- A data report is titled by the file it checks, which depends on the folder this client loaded.
function ns:GetDiagnosticReportTitle(id)
	local report = ns.DIAGNOSTIC_REPORTS[id]
	if report.dataIndex then
		local entry = ns.DIAGNOSTIC_DATA_SOURCES[report.dataIndex]
		return string.format(D.VALIDATE_TITLE, ns.DataSourceFileName(entry))
	end
	return report.title
end

--[[
    A report's last state (waiting, running, done or stopped) and its note, or
    nil before it has ever run. A data report that is running reports its live
    id count instead, which is why the panel repaints on every validation poll.
]]
function ns:GetDiagnosticReportStatus(id)
	local status = ns.diagnostics.status[id]
	if not status then
		return nil
	end
	local report = ns.DIAGNOSTIC_REPORTS[id]
	if status.state == "running" and report.dataIndex then
		local resolved, total = ns:GetDataValidationProgress(report.dataIndex)
		if resolved then
			return status.state,
				string.format(D.VALIDATE_PROGRESS, ns:FormatCommaNumber(resolved), ns:FormatCommaNumber(total))
		end
	end
	return status.state, status.note
end

local function SetStatus(id, state, note)
	ns.diagnostics.status[id] = { state = state, note = note }
end

local STATUS_LABELS = {
	waiting = D.STATUS_WAITING,
	running = D.STATUS_RUNNING,
	done = D.STATUS_DONE,
	stopped = D.STATUS_STOPPED,
}

function ns:GetDiagnosticStatusLabel(state)
	return STATUS_LABELS[state]
end

-- A data report's status note: OK first, then every other STATUS alphabetically, each with its count.
local function DataNote(counts)
	local parts = {}
	if counts[STATUS_OK] then
		parts[1] = ns:FormatCommaNumber(counts[STATUS_OK]) .. " " .. STATUS_OK
	end
	local others = {}
	for status in pairs(counts) do
		if status ~= STATUS_OK then
			others[#others + 1] = status
		end
	end
	table.sort(others)
	for _, status in ipairs(others) do
		parts[#parts + 1] = ns:FormatCommaNumber(counts[status]) .. " " .. tostring(status)
	end
	return parts[1] and table.concat(parts, ", ") or nil
end

--[[
    Every report opens with the client header; a tab's box prints it once at
    the top and drops each report's own copy.
]]
local function StripHeader(text)
	local header = GetClientHeader()
	if string.sub(text, 1, #header) == header then
		return (string.gsub(string.sub(text, #header + 1), "^\n+", ""))
	end
	return text
end

local function AppendReportBlock(lines, run, id)
	local part = run.parts[id]
	if not part then
		return
	end
	lines[#lines + 1] = "---- " .. ns:GetDiagnosticReportTitle(id) .. " ----"
	lines[#lines + 1] = part.text
	lines[#lines + 1] = ""
end

-- A tab's box: the client header once, then one block per report that has finished.
local function Compose(run)
	local lines = { GetClientHeader(), "" }
	for _, id in ipairs(run.ids) do
		AppendReportBlock(lines, run, id)
	end
	return lines
end

local function NotifyPanel()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

local function Publish(run)
	local lines = Compose(run)
	if run.stopped then
		lines[#lines + 1] = D.REPORT_STOPPED
	end
	ns.diagnostics.outputs[run.target] = table.concat(lines, "\n")
	NotifyPanel()
end

local function SetProgress(run, text)
	ns.diagnostics.progress = { target = run.target, text = text }
end

--[[
    One report at a time, a frame apart, so the panel repaints between them and
    a long run never stalls one frame. A data report hands over to the batched
    validation and resumes the chain from its callback. Every step checks the
    run's generation, so Stop, or the panel being switched off, ends the chain.
    A report that throws is written into the box as an error and the run goes
    on, so one broken report never costs the rest.
]]
local currentRun
local runGeneration = 0
local RunNext

local function Complete(run, id, text, note)
	run.parts[id] = { text = StripHeader(text) }
	SetStatus(id, "done", note)
	run.index = run.index + 1
	Publish(run)
	C_Timer.After(0, function()
		if run.generation == runGeneration then
			RunNext(run)
		end
	end)
end

function RunNext(run)
	local id = run.ids[run.index]
	if not id then
		currentRun = nil
		ns.diagnostics.running = nil
		SetProgress(run, #run.ids == 1 and D.PROGRESS_DONE_ONE or string.format(D.PROGRESS_DONE, #run.ids))
		Publish(run)
		return
	end

	SetStatus(id, "running")
	SetProgress(run, string.format(D.PROGRESS_RUNNING, run.index, #run.ids, ns:GetDiagnosticReportTitle(id)))
	NotifyPanel()

	local report = ns.DIAGNOSTIC_REPORTS[id]
	if report.dataIndex then
		local answered = false
		local function OnData(text, counts, problem)
			if answered or run.generation ~= runGeneration then
				return
			end
			answered = true
			if problem then
				Complete(run, id, string.format(D.REPORT_ERROR, problem), D.REPORT_ERROR_NOTE)
			else
				Complete(run, id, text, DataNote(counts))
			end
		end
		local ok, problem = pcall(ns.StartDataValidation, ns, report.dataIndex, OnData)
		if not ok then
			ns:StopDataValidation()
			OnData(nil, nil, tostring(problem))
		end
		return
	end

	C_Timer.After(0, function()
		if run.generation ~= runGeneration then
			return
		end
		local ok, text = pcall(report.build)
		if not ok then
			Complete(run, id, string.format(D.REPORT_ERROR, tostring(text)), D.REPORT_ERROR_NOTE)
			return
		end
		Complete(run, id, text, report.note and report.note(text) or nil)
	end)
end

--[[
    target names the tab whose box the run writes to. One run at a time; the
    panel disables every run button while one is going.
]]
local function StartRun(target, ids)
	if currentRun or #ids == 0 then
		return
	end
	runGeneration = runGeneration + 1
	local run = { target = target, ids = ids, index = 1, parts = {}, generation = runGeneration }
	for _, id in ipairs(ids) do
		SetStatus(id, "waiting")
	end
	currentRun = run
	ns.diagnostics.running = target
	Publish(run)
	RunNext(run)
end

function ns:RunDiagnosticSection(key)
	local section = ns:GetDiagnosticSection(key)
	if section then
		StartRun(key, section.reports)
	end
end

function ns:RunDiagnosticReport(key, id)
	StartRun(key, { id })
end

-- Keeps every report that finished, marks the rest stopped, and says so at the foot of the box.
function ns:StopDiagnosticRun()
	local run = currentRun
	if not run then
		return
	end
	runGeneration = runGeneration + 1
	ns:StopDataValidation()
	currentRun = nil
	ns.diagnostics.running = nil
	for _, id in ipairs(run.ids) do
		local status = ns.diagnostics.status[id]
		if status and (status.state == "waiting" or status.state == "running") then
			SetStatus(id, "stopped")
		end
	end
	run.stopped = true
	SetProgress(run, D.PROGRESS_STOPPED)
	Publish(run)
end
