local _, ns = ...

--------------------------------------------------------------------------------
-- Diagnostic Tools
--------------------------------------------------------------------------------

--[[
    Environment probing and state capture for bug reports, not unit tests. WoW's
    sandboxed Lua has no assertion runner, so everything here is read-only and
    side-effect free. The one exception is the explicit Taint Log button, which
    sets the taintLog CVar. Reports build only on a button press, never on load
    or panel open.
]]

--------------------------------------------------------------------------------
-- Runtime State
--------------------------------------------------------------------------------

--[[
    Runtime-only state. NOT a SavedVariable. File-scope init is correct here --
    the "initialize on PLAYER_LOGIN" rule applies only to SavedVariables, which
    don't exist until the client loads them. This is a plain namespace table, so
    it starts false at every login and is never persisted.

    outputs holds each report tab's one output box (settings, code, data),
    status each report's last run state, and running the tab whose run is in
    flight, or nil.
]]
ns.diagnostics = ns.diagnostics
	or {
		enabled = false,
		logging = false,
		log = nil,
		outputs = {},
		status = {},
		running = nil,
	}

--------------------------------------------------------------------------------
-- Strings
--------------------------------------------------------------------------------

--[[
    Diagnostics strings are intentionally NOT localized. They are
    developer-facing troubleshooting text; translating them is wasted effort for
    zero player value. Every diagnostics string lives here as plain English, in
    the diagnostics files only -- never in Locales/. The one exception is the
    add-on's own display name (ns.L["ADDON_TITLE"]), which is the add-on's
    identity, not a diagnostics string.
]]
local TITLE = ns.L["ADDON_TITLE"]

ns.DiagnosticsStrings = {
	TAB = "Diagnostic Tools",
	WARNING = "These tools help diagnose problems and are meant for developers. They won't change how the add-on works, but their output includes technical details about your client and installed add-ons. Leave this off unless you're troubleshooting with someone.",
	ENABLE = "Enable Diagnostic Tools",
	ENABLE_DESCRIPTION = "Shows the tools below for this session only. Turning it off stops the event log and clears every report.",

	TAB_RUN_TESTS = "Run Tests",
	TAB_SETTINGS = "Settings",
	TAB_CODE = "Code",
	TAB_DATA = "Data",
	SECTION_SETTINGS = "Settings & Configuration",
	SECTION_CODE = "Code",
	SECTION_DATA = "Data",

	RUN_TESTS_INTRO = "Live tools for catching a problem as it happens. Turn on what you need, reproduce the problem, then copy what they caught.",
	EVENT_LOG_TITLE = "Event Log",
	EVENT_LOG_INTRO = "Records the events "
		.. TITLE
		.. " listens to, in the order they fired, showing whether an event never fired, or fired and nothing happened.",
	EVENT_LOG_IDLE = "Not capturing.",
	EVENT_LOG_CAPTURING = "Capturing. Reproduce the problem, then press Stop.",
	EVENT_LOG_STOPPED = "Stopped: %s events captured.",
	EVENT_LOG_START = "Start",
	EVENT_LOG_START_DESCRIPTION = "Starts capturing " .. TITLE .. "'s events, replacing anything captured before.",
	EVENT_LOG_STOP = "Stop",
	EVENT_LOG_STOP_DESCRIPTION = "Stops capturing and keeps what was captured, ready to show.",
	EVENT_LOG_SHOW = "Show",
	EVENT_LOG_SHOW_DESCRIPTION = "Prints the captured events in the box below, ready to copy.",
	TAINT_TITLE = "Taint Log",
	TAINT_INTRO = 'Seeing "action blocked" or "interface action failed" errors? Turn this on and the game records the cause to a file. Send the file along with your bug report.',
	TAINT_STATE = "Taint logging is currently set to level %d (0 = off, 2 = verbose).",
	TAINT_ON = "Turn On",
	TAINT_ON_DESCRIPTION = "Sets taint logging to verbose, so the game writes taint to Logs\\taint.log. It stays on until you turn it off; reload your UI to capture taint from login onward.",
	TAINT_OFF = "Turn Off",
	TAINT_OFF_DESCRIPTION = "Turns taint logging off.",
	TAINT_HINT = "Find the file in your World of Warcraft folder under Logs\\taint.log.",
	GAME_TOOLS_TITLE = "In-Game Tools",
	GAME_TOOLS_INTRO = "WoW has some powerful tools built in! Type these into chat.",
	ETRACE_NAME = "Event Trace",
	ETRACE_DESCRIPTION = "Opens a live window listing every event the game fires, as it fires.",
	ETRACE_COMMAND = "/etrace",
	SCRIPT_ERRORS_NAME = "Console Errors",
	SCRIPT_ERRORS_DESCRIPTION = "Has the game pop up Lua errors as they happen. Type it again with 0 to turn it off.",
	SCRIPT_ERRORS_COMMAND = "/console scriptErrors 1",
	TOOLS_TITLE = "External Tools",
	TOOLS_INTRO = "Funkeh made a pair of add-ons that add-on developers rely on. Bug Grabber catches every Lua error with its full stack, and Bug Sack lets you read them and copy them into a bug report. Install both.",
	BUG_GRABBER_NAME = "Bug Grabber",
	BUG_GRABBER_DESCRIPTION = "Catches every Lua error the game throws.",
	BUG_GRABBER_URL = "https://www.curseforge.com/wow/addons/bug-grabber",
	BUG_SACK_NAME = "Bug Sack",
	BUG_SACK_DESCRIPTION = "Lets you browse caught errors and copy them out.",
	BUG_SACK_URL = "https://www.curseforge.com/wow/addons/bugsack",
	LINK_HINT = "Click in a box, press Ctrl+A, then Ctrl+C to copy it.",

	STOP = "Stop",
	STOP_DESCRIPTION = "Stops the run. Reports that finished stay in the box.",
	COPY_HINT = "Click in the box, press Ctrl+A to select it all, then Ctrl+C to copy.",
	OUTPUT_TITLE = "Output",

	SETTINGS_INTRO = "How " .. TITLE .. " is set up on this character, and what else is installed around it.",
	SETTINGS_RUN_ALL = "Run All Settings Reports",
	CODE_INTRO = "Whether every game event, game function and library "
		.. TITLE
		.. " relies on is present on this client.",
	CODE_RUN_ALL = "Run All Code Reports",
	DATA_INTRO = "Checks every item and spell the add-on ships against this client. Paste a result into a spreadsheet and sort by STATUS to find what needs pruning.",
	DATA_RUN_ALL = "Validate All Data Files",
	RUN_ALL_DESCRIPTION = "Runs %s, one after another.",

	EVENTS_TITLE = "Event Registration",
	EVENTS_DESCRIPTION = "Checks that every event " .. TITLE .. " listens to exists on this client.",
	EVENTS_ALL_PASS = "all register",
	EVENTS_SOME_FAIL = "%d failed to register",
	API_TITLE = "API Endpoints",
	API_DESCRIPTION = "Checks that every game function " .. TITLE .. " calls exists on this client.",
	LOOT_TITLE = "Loot Method",
	LOOT_DESCRIPTION = "Shows what the game reports for your group's loot method, how GogoLoot reads it, and which message IDs resolved.",
	CVARS_TITLE = "Relevant CVars",
	CVARS_DESCRIPTION = "Shows the game settings " .. TITLE .. " reads.",
	PLAYER_TITLE = "Player & Spells",
	PLAYER_DESCRIPTION = "Shows your class, level and the Rogue spells " .. TITLE .. " watches.",
	LOCKED_TITLE = "Locked Boxes",
	LOCKED_DESCRIPTION = "Lists every openable item in your bags with its action and whether "
		.. TITLE
		.. " reads it as locked. LOCKED false with 0 TOOLTIP_LINES means the tooltip read nothing.",
	GEAR_TITLE = "Gear Stats",
	GEAR_DESCRIPTION = "Lists the armor and weapons in your bags and on your character with the stats Character Rules reads on each, where each came from (ITEM, EQUIP_TABLE, SUFFIX_TABLE or TOOLTIP), and whether this character's rules leave it to you.",
	VALIDATE_TITLE = "Validate Data: %s",
	VALIDATE_DESCRIPTION = "Checks every id in this data file against this client and exports the results as tab-separated text.",
	VALIDATE_PROGRESS = "%s / %s IDs",
	VALIDATE_HINT = "Checks every item and spell id a data file ships against this client and exports what the client knows about each one as tab-separated text, ready to paste into a spreadsheet. Item rows carry every item API return, the file's own values in the DATA columns so you can sort for mismatches, everything the client knows about the item's spell including its tooltip in SPELL_TOOLTIP, and the whole item tooltip in one TOOLTIP cell, its lines joined by // and a right-hand text after >>. Spell rows carry every spell API return the client has, the same way. STATUS reads OK, NOT ON CLIENT for an id this client does not have or never answers for, INCOMPLETE when an id loaded but its tooltip or spell text never did, ERROR with the message in the name cell when a read throws, or TABLE MISSING when this client's folder never built a table. Spell ids follow in a block of their own.",
	DISPLAY_TITLE = "Display Context",
	DISPLAY_DESCRIPTION = "Shows your screen size, UI scale, the mini-map button's saved position and the loot toast anchor.",
	ADDONS_TITLE = "Other Add-ons",
	ADDONS_DESCRIPTION = "Lists every installed add-on with its version, and whether it is loadable or disabled.",
	SAVED_TITLE = "Saved Variables",
	SAVED_DESCRIPTION = "Prints " .. TITLE .. "'s saved settings and lists as readable text.",
	LIBS_TITLE = "Library Versions",
	LIBS_DESCRIPTION = "Lists the version of every library " .. TITLE .. " loaded.",

	STATUS_WAITING = "Waiting",
	STATUS_RUNNING = "Running",
	STATUS_DONE = "Done",
	STATUS_STOPPED = "Stopped",
	PROGRESS_RUNNING = "Running %d of %d: %s",
	PROGRESS_DONE = "Finished %d reports.",
	PROGRESS_DONE_ONE = "Finished 1 report.",
	PROGRESS_STOPPED = "Stopped.",
	REPORT_RUN = "Run",
	REPORT_VALIDATE = "Validate",
	REPORT_ERROR = "ERROR: %s",
	REPORT_ERROR_NOTE = "threw an error, see below",
	REPORT_STOPPED = "(stopped before finishing)",
}

--------------------------------------------------------------------------------
-- Enable Gate
--------------------------------------------------------------------------------

-- Off releases the log, stops any run, and clears every report already shown.
function ns:SetDiagnosticsEnabled(value)
	ns.diagnostics.enabled = value and true or false
	if not ns.diagnostics.enabled then
		ns:StopEventLog()
		ns.diagnostics.log = nil
		ns.diagnostics.suppressed = nil
		ns.diagnostics.eventLogReport = nil
		ns:StopDiagnosticRun()
		ns.diagnostics.outputs = {}
		ns.diagnostics.status = {}
		ns.diagnostics.progress = nil
	end
end

--------------------------------------------------------------------------------
-- Report Header
--------------------------------------------------------------------------------

local function GetClientHeader()
	local version, build, _, tocVersion = GetBuildInfo()
	local flavor = (ns.FLAVOR or "?") .. (ns.IS_DISCOVERY and " (Season of Discovery)" or "")
	return string.format(
		"%s %s // Client %s // Build %s // TOC %s // Locale %s // Flavor %s // Data %s",
		TITLE,
		ns.Version,
		version,
		build,
		tocVersion,
		GetLocale(),
		flavor,
		tostring(ns.DATA_FOLDER)
	)
end

local function CountKeys(value)
	local count = 0
	if type(value) == "table" then
		for _ in pairs(value) do
			count = count + 1
		end
	end
	return count
end

ns.GetDiagnosticClientHeader = GetClientHeader
ns.CountDiagnosticKeys = CountKeys

--------------------------------------------------------------------------------
-- Tooltip Lines
--------------------------------------------------------------------------------

--[[
    An item's or spell's tooltip lines through ns.GetTooltipLines, protected,
    because one id the client chokes on must not end a run of a thousand. A
    throw comes back as its message, so the caller can report it.
]]
local function TooltipLines(kind, id)
	local ok, lines = pcall(ns.GetTooltipLines, kind, id)
	if ok then
		return lines, nil
	end
	return {}, tostring(lines)
end

ns.DiagnosticTooltipLines = TooltipLines
