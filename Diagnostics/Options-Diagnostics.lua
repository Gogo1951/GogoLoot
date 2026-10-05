local _, ns = ...

local D = ns.DiagnosticsStrings
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Diagnostic Tools Panel
--------------------------------------------------------------------------------

--[[
    A single runtime toggle gates the whole panel. When off, only the warning
    text and the enable toggle are there; the four tabs below are left out of
    the table rather than grayed out. Left out, not hidden: AceConfigDialog
    decides whether to draw a tab frame by reading hidden as inherited from the
    parent rather than from each tab, so four hidden tabs still get an empty
    bordered frame. The panel is registered as this builder, so every repaint
    rebuilds it and the toggle takes effect on the next one.

    Run Tests holds the live tools: the Event Log, the Taint Log, and pointers
    to the game's own tools and Funkeh's. Settings, Code and Data each have a
    Run All, a row per report, and one box that shows whatever ran last on that
    tab. The runner lives in Diagnostics/Report-Runner.lua; everything here reads
    ns.diagnostics as it draws, and the runner repaints the panel as it goes.
]]

local function DiagnosticsOn()
	return ns.diagnostics and ns.diagnostics.enabled == true
end

local function Refresh()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

local function Running()
	return ns.diagnostics.running ~= nil
end

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

--[[
    Row budgets. AceGUI's TabGroup insets its pane 60px narrower than a plain
    panel's, and a titled box (an inline group with a name) insets another
    20px, so rows here spend less than ns.OPTIONS_ROW_WIDTH. Each budget keeps a
    little slack under what fits, since a row summing exactly to the pane sits
    on the wrap boundary and can drop its last control onto a line of its own.
]]
local TAB_ROW_WIDTH = ns.OPTIONS_ROW_WIDTH - 0.4
local BOX_ROW_WIDTH = TAB_ROW_WIDTH - 0.15
local ROW_SLACK = 0.05

local REPORT_BUTTON_WIDTH = 0.7
local LOG_BUTTON_WIDTH = 0.5
local TAINT_BUTTON_WIDTH = 0.6
local COPY_LABEL_WIDTH = 0.75

local function Desc(text, order, hidden, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width,
		order = order,
		hidden = hidden,
	}
end

local function HelpDesc(text, order, hidden)
	return Desc(GetColor("HELP") .. text .. "|r", order, hidden)
end

local function SectionHeader(text, order)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order }
end

local function Box(name, order, args)
	return { type = "group", name = name, inline = true, order = order, args = args }
end

--[[
    One line of cells in an unnamed inline group, so it pins its own row (see
    ns.OptionsRow): a label on the left, its controls on the right. Each
    cell's order is set here.
]]
local function Row(order, cells)
	local args = {}
	for index, cell in ipairs(cells) do
		cell.order = index
		args["cell" .. index] = cell
	end
	return { type = "group", name = "", inline = true, order = order, args = args }
end

local function Button(name, desc, width, func, disabled)
	return { type = "execute", name = name, desc = desc, width = width, func = func, disabled = disabled }
end

-- A read-only box beside its label: typing into it changes nothing, so it is there to copy from.
local function CopyRow(label, desc, value, order)
	return Row(order, {
		Desc(GetColor("TEXT") .. label .. "|r", nil, nil, COPY_LABEL_WIDTH),
		{
			type = "input",
			name = "",
			desc = desc,
			width = BOX_ROW_WIDTH - COPY_LABEL_WIDTH - ROW_SLACK,
			get = function()
				return value
			end,
			set = function() end,
		},
	})
end

local function ReportOutput(getText, order, lines, hidden)
	return {
		type = "input",
		name = "",
		multiline = lines,
		width = "full",
		order = order,
		hidden = hidden,
		get = function()
			return getText() or ""
		end,
		set = function() end,
	}
end

--------------------------------------------------------------------------------
-- Run Tests Tab
--------------------------------------------------------------------------------

local function EventLogState()
	if ns.diagnostics.logging then
		return GetColor("TITLE") .. D.EVENT_LOG_CAPTURING .. "|r"
	end
	if ns.diagnostics.log then
		return GetColor("HELP") .. string.format(D.EVENT_LOG_STOPPED, ns:FormatCommaNumber(#ns.diagnostics.log)) .. "|r"
	end
	return GetColor("HELP") .. D.EVENT_LOG_IDLE .. "|r"
end

local function NoEventLogReport()
	return ns.diagnostics.eventLogReport == nil
end

local function BuildEventLogBox(order)
	return Box(D.EVENT_LOG_TITLE, order, {
		descIntro = HelpDesc(
			D.EVENT_LOG_EXAMPLES and (D.EVENT_LOG_INTRO .. " " .. D.EVENT_LOG_EXAMPLES) or D.EVENT_LOG_INTRO,
			1
		),
		rowControls = Row(2, {
			Desc(EventLogState, nil, nil, BOX_ROW_WIDTH - 3 * LOG_BUTTON_WIDTH - ROW_SLACK),
			Button(D.EVENT_LOG_START, D.EVENT_LOG_START_DESCRIPTION, LOG_BUTTON_WIDTH, function()
				ns:StartEventLog()
				Refresh()
			end, function()
				return ns.diagnostics.logging
			end),
			Button(D.EVENT_LOG_STOP, D.EVENT_LOG_STOP_DESCRIPTION, LOG_BUTTON_WIDTH, function()
				ns:StopEventLog()
				Refresh()
			end, function()
				return not ns.diagnostics.logging
			end),
			Button(D.EVENT_LOG_SHOW, D.EVENT_LOG_SHOW_DESCRIPTION, LOG_BUTTON_WIDTH, function()
				ns.diagnostics.eventLogReport = ns:BuildEventLogReport()
				Refresh()
			end),
		}),
		outputEventLog = ReportOutput(function()
			return ns.diagnostics.eventLogReport
		end, 3, 8, NoEventLogReport),
		descCopy = HelpDesc(D.COPY_HINT, 4, NoEventLogReport),
	})
end

local function TaintState()
	local level = ns:GetTaintLogState()
	return GetColor(level > 0 and "TITLE" or "HELP") .. string.format(D.TAINT_STATE, level) .. "|r"
end

local function BuildTaintBox(order)
	return Box(D.TAINT_TITLE, order, {
		descIntro = HelpDesc(D.TAINT_INTRO, 1),
		rowControls = Row(2, {
			Desc(TaintState, nil, nil, BOX_ROW_WIDTH - 2 * TAINT_BUTTON_WIDTH - ROW_SLACK),
			Button(D.TAINT_ON, D.TAINT_ON_DESCRIPTION, TAINT_BUTTON_WIDTH, function()
				ns:SetTaintLog(true)
				Refresh()
			end, function()
				return ns:GetTaintLogState() > 0
			end),
			Button(D.TAINT_OFF, D.TAINT_OFF_DESCRIPTION, TAINT_BUTTON_WIDTH, function()
				ns:SetTaintLog(false)
				Refresh()
			end, function()
				return ns:GetTaintLogState() == 0
			end),
		}),
		descHint = HelpDesc(D.TAINT_HINT, 3),
	})
end

local function BuildGameToolsBox(order)
	return Box(D.GAME_TOOLS_TITLE, order, {
		descIntro = HelpDesc(D.GAME_TOOLS_INTRO, 1),
		rowEtrace = CopyRow(D.ETRACE_NAME, D.ETRACE_DESCRIPTION, D.ETRACE_COMMAND, 2),
		rowScriptErrors = CopyRow(D.SCRIPT_ERRORS_NAME, D.SCRIPT_ERRORS_DESCRIPTION, D.SCRIPT_ERRORS_COMMAND, 3),
	})
end

local function BuildExternalToolsBox(order)
	return Box(D.TOOLS_TITLE, order, {
		descIntro = HelpDesc(D.TOOLS_INTRO, 1),
		rowBugGrabber = CopyRow(D.BUG_GRABBER_NAME, D.BUG_GRABBER_DESCRIPTION, D.BUG_GRABBER_URL, 2),
		rowBugSack = CopyRow(D.BUG_SACK_NAME, D.BUG_SACK_DESCRIPTION, D.BUG_SACK_URL, 3),
		descHint = HelpDesc(D.LINK_HINT, 4),
	})
end

local function BuildRunTestsGroup(order)
	return {
		type = "group",
		name = D.TAB_RUN_TESTS,
		order = order,
		args = {
			descIntro = ns.OptionsDesc(D.RUN_TESTS_INTRO, 1),
			boxEventLog = BuildEventLogBox(2),
			boxTaint = BuildTaintBox(3),
			boxGameTools = BuildGameToolsBox(4),
			boxExternalTools = BuildExternalToolsBox(5),
		},
	}
end

--------------------------------------------------------------------------------
-- Report Tabs
--------------------------------------------------------------------------------

local SECTION_TEXT = {
	settings = { tab = D.TAB_SETTINGS, intro = D.SETTINGS_INTRO, runAll = D.SETTINGS_RUN_ALL },
	code = { tab = D.TAB_CODE, intro = D.CODE_INTRO, runAll = D.CODE_RUN_ALL },
	data = { tab = D.TAB_DATA, intro = D.DATA_INTRO, runAll = D.DATA_RUN_ALL, hint = D.VALIDATE_HINT },
}

local STATE_COLORS = {
	waiting = "MUTED",
	running = "TITLE",
	done = "ON",
	stopped = "MUTED",
}

-- A report's last state in its color, then its note in silver, or nil before it has run.
local function StatusText(id)
	local state, note = ns:GetDiagnosticReportStatus(id)
	if not state then
		return nil
	end
	local text = GetColor(STATE_COLORS[state]) .. ns:GetDiagnosticStatusLabel(state) .. "|r"
	if note then
		text = text .. GetColor("HELP") .. ": " .. note .. "|r"
	end
	return text
end

--[[
    A report row's label: its name in white with its last state beside it,
    then what it covers in silver. A data report goes by its manifest label and
    names its file underneath, since the file differs by client.
]]
local function ReportLabel(id)
	local report = ns.DIAGNOSTIC_REPORTS[id]
	local title, about = report.title, report.description
	if report.dataIndex then
		local entry = ns.DIAGNOSTIC_DATA_SOURCES[report.dataIndex]
		title, about = entry.label, ns.DataSourceFileName(entry)
	end
	local status = StatusText(id)
	return GetColor("TEXT")
		.. title
		.. "|r"
		.. (status and ("    " .. status) or "")
		.. "\n"
		.. GetColor("HELP")
		.. about
		.. "|r"
end

local function ReportRow(section, id, order)
	local report = ns.DIAGNOSTIC_REPORTS[id]
	return Row(order, {
		Desc(function()
			return ReportLabel(id)
		end, nil, nil, TAB_ROW_WIDTH - REPORT_BUTTON_WIDTH - ROW_SLACK),
		Button(
			report.dataIndex and D.REPORT_VALIDATE or D.REPORT_RUN,
			report.description,
			REPORT_BUTTON_WIDTH,
			function()
				ns:RunDiagnosticReport(section.key, id)
			end,
			Running
		),
	})
end

local function BuildSectionGroup(section, order)
	local text = SECTION_TEXT[section.key]
	local titles = {}
	for _, id in ipairs(section.reports) do
		titles[#titles + 1] = ns:GetDiagnosticReportTitle(id)
	end

	local args = {
		descIntro = ns.OptionsDesc(text.intro, 1),
		spaceRunAll = ns.OptionsSpacer(2),
		buttonRunAll = Button(
			text.runAll,
			string.format(D.RUN_ALL_DESCRIPTION, table.concat(titles, ", ")),
			"double",
			function()
				ns:RunDiagnosticSection(section.key)
			end,
			Running
		),
		buttonStop = {
			type = "execute",
			name = D.STOP,
			desc = D.STOP_DESCRIPTION,
			hidden = function()
				return ns.diagnostics.running ~= section.key
			end,
			func = function()
				ns:StopDiagnosticRun()
			end,
		},
		descProgress = Desc(
			function()
				local progress = ns.diagnostics.progress
				return GetColor("HELP") .. (progress and progress.text or "") .. "|r"
			end,
			nil,
			function()
				local progress = ns.diagnostics.progress
				return not (progress and progress.target == section.key)
			end,
			"full"
		),
		spaceRows = ns.OptionsSpacer(6),
		headerOutput = SectionHeader(D.OUTPUT_TITLE, 50),
		output = ReportOutput(function()
			return ns.diagnostics.outputs[section.key]
		end, 51, 12),
		descCopy = HelpDesc(D.COPY_HINT, 52),
	}
	args.buttonRunAll.order = 3
	args.buttonStop.order = 4
	args.descProgress.order = 5

	for index, id in ipairs(section.reports) do
		args["row" .. index] = ReportRow(section, id, 6 + index)
	end
	if text.hint then
		args.descHint = HelpDesc(text.hint, 53)
	end

	return { type = "group", name = text.tab, order = order, args = args }
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

function ns.BuildDiagnosticsOptions()
	local args = {
		descWarning = ns.OptionsDesc(D.WARNING, 1),
		spaceEnable = ns.OptionsSpacer(2),
		toggleEnable = {
			type = "toggle",
			name = D.ENABLE,
			desc = D.ENABLE_DESCRIPTION,
			width = "full",
			order = 3,
			get = function()
				return DiagnosticsOn()
			end,
			set = function(_, value)
				ns:SetDiagnosticsEnabled(value)
				Refresh()
			end,
		},
	}

	if DiagnosticsOn() then
		args.runTests = BuildRunTestsGroup(10)
		for index, section in ipairs(ns.DIAGNOSTIC_SECTIONS) do
			args[section.key] = BuildSectionGroup(section, 10 + index)
		end
	end

	return {
		type = "group",
		name = D.TAB,
		childGroups = "tab",
		args = args,
	}
end
