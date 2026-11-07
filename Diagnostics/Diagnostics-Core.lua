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

    outputs holds each report tab's one output box (settings, code, data,
    localization),
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
	TAB_LOCALIZATION = "Localization",
	SECTION_SETTINGS = "Settings & Configuration",
	SECTION_CODE = "Code",
	SECTION_DATA = "Data",
	SECTION_LOCALIZATION = "Localization",

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
	EVENT_LOG_PRIVACY = "The log includes the text of chat messages it catches, whispers too. Read it through before you paste it anywhere.",
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
	LOCALIZATION_INTRO = "Playing in a language other than English and a name or prompt reads wrong? These show what your client calls everything "
		.. TITLE
		.. " names.",
	LOCALIZATION_RUN_ALL = "Run All Localization Reports",
	RUN_ALL_DESCRIPTION = "Runs %s, one after another.",

	EVENTS_TITLE = "Event Registration",
	EVENTS_DESCRIPTION = "Checks that every event " .. TITLE .. " listens to exists on this client.",
	EVENTS_ALL_PASS = "all register",
	EVENTS_SOME_FAIL = "%d failed to register",
	API_TITLE = "API Endpoints",
	API_DESCRIPTION = "Checks that every game function " .. TITLE .. " calls exists on this client.",
	LOOT_TITLE = "Loot Method",
	LOOT_DESCRIPTION = "Shows what the game reports for your group's loot method and threshold, how "
		.. TITLE
		.. " reads it, the Automated Master Looting settings and destinations, why each slot in an open loot window would or wouldn't be handed out, and which message IDs resolved.",
	LOOTING_TITLE = "Speedy Loot Context",
	LOOTING_DESCRIPTION = "Shows whether Speedy Loot can take loot right now: its switch, the game's Auto Loot setting and modifier key, the master looter stand-down, free space in each bag and the keyring, which loot window it hides, and what it reads on each slot of an open one. Then what the Loot Sounds read: their switches, where the open loot came from, and the game's sound settings.",
	OPENING_TITLE = "Automated Opening Context",
	OPENING_DESCRIPTION = "Shows every check that can hold Automated Opening back right now: its switch and hold-offs, combat, stealth, open windows, casting, free bag space, the Openables List, the lockbox switches, and whether Open Sesame is running too.",
	LOCKED_TITLE = "Locked Boxes",
	LOCKED_DESCRIPTION = "Lists every openable item and lockbox in your bags with its action, the level it needs, whether "
		.. TITLE
		.. " reads it as locked, whether it would open, and the Lockpicking it needs. LOCKED false with 0 TOOLTIP_LINES means the tooltip read nothing.",
	ROLLS_TITLE = "Automated Rolls Context",
	ROLLS_DESCRIPTION = "Shows the Automated Rolls switch, which group's roll setting applies right now, the Item Overrides list, the roll print and Hide Roll Messages settings, this character's Character Rules with the stats this client offers, and any roll open now.",
	VERDICTS_TITLE = "Roll Verdicts",
	VERDICTS_DESCRIPTION = "Lists each item in your bags with what Automated Rolls would do if it dropped now, under your group's roll setting, and the check that decides it. Nothing rolls.",
	GEAR_TITLE = "Gear Stats",
	GEAR_DESCRIPTION = "Lists the armor and weapons in your bags and on your character with the stats Character Rules reads on each, where each came from (ITEM, TOOLTIP or EQUIP), and whether this character wants each (Character Rules' verdict).",
	TOASTS_TITLE = "Loot Toasts Context",
	TOASTS_DESCRIPTION = "Shows the Loot Toasts switch and look, every Filters row for Mine and Group, and whether the General chat tab still shows the game's own loot and money lines.",
	LINES_TITLE = "Loot Line Reading",
	LINES_DESCRIPTION = "Builds the game's own loot, money and roll lines with an item from your bags and shows whether "
		.. TITLE
		.. " reads each one back, which every toast, loot sound, opening, winning roll and hidden roll message depends on. Nothing is sent.",
	ANNOUNCE_TITLE = "Loot Announcements Context",
	ANNOUNCE_DESCRIPTION = "Shows the Enable Loot Announcements switch, the trade and master loot announcement settings, and the chat channel "
		.. TITLE
		.. " would send to right now, and the welcome message switch.",
	MACRO_TITLE = "Roll Macro Context",
	MACRO_DESCRIPTION = "Shows the Enable Roll Macro switch, whether the macro is in your General Macros as "
		.. TITLE
		.. " writes it, how full that tab is, combat, and what each mouse button would roll right now.",
	PLAYER_TITLE = "Player & Spells",
	PLAYER_DESCRIPTION = "Shows your class, race, level and the Rogue spells " .. TITLE .. " watches.",
	VALIDATE_TITLE = "Validate Data: %s",
	VALIDATE_DESCRIPTION = "Checks every id in this data file against this client and exports the results as tab-separated text.",
	VALIDATE_PROGRESS = "%s / %s IDs",
	DISPLAY_TITLE = "Display Context",
	DISPLAY_DESCRIPTION = "Shows your screen size, UI scale, the mini-map button's saved position and the loot toast anchor.",
	ADDONS_TITLE = "Other Add-ons",
	ADDONS_DESCRIPTION = "Lists every installed add-on with its version, and whether it is loadable or disabled.",
	SAVED_TITLE = "Saved Variables",
	SAVED_DESCRIPTION = "Prints " .. TITLE .. "'s saved settings and lists as readable text.",
	LIBS_TITLE = "Library Versions",
	LIBS_DESCRIPTION = "Lists the version of every library " .. TITLE .. " loaded.",
	LOCALE_TITLE = "Locale Context",
	LOCALE_DESCRIPTION = "Shows your client's language, its text and audio language settings, and how many of "
		.. TITLE
		.. "'s own strings loaded.",
	NAMES_TITLE = "Game Names",
	NAMES_DESCRIPTION = "Shows the name your client gives every game string " .. TITLE .. " shows or matches.",
	NAMES_ALL_FOUND = "all found",
	NAMES_SOME_NIL = "%d NIL",
	MESSAGES_TITLE = "Message Length",
	MESSAGES_DESCRIPTION = "Builds each message "
		.. TITLE
		.. " can send to the group or a trade partner, with the longest item link in your bags and the longest name in your group, and the Roll Macro's text, and shows each one's length against its limit. Nothing is sent and no macro is written.",

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
