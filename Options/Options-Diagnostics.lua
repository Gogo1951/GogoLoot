--------------------------------------------------------------------------------
-- GogoLoot Options — Diagnostic Tools
--------------------------------------------------------------------------------

--[[
    A single runtime toggle gates the whole panel. When off, only the warning
    text and the enable toggle are visible; everything below is hidden. The
    toggle state lives on ns.diagnostics (runtime-only, never in GogoLootDB), so
    it always starts off and persists nothing.

    Every gated section hides on that one condition, so the local SectionHeader
    builder bakes it in rather than passing ns.OptionsHeader's `hidden` argument
    at each site. ns.OptionsSpacer takes no `hidden`, so a gated spacer is
    inlined as its own description widget.
]]
local _, ns = ...
local D = ns.DiagnosticsStrings
local GetColor = ns.GetColor
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local function DiagnosticsOn()
	return ns.diagnostics and ns.diagnostics.enabled == true
end

local function Hidden()
	return not DiagnosticsOn()
end

local function Refresh()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

local function SectionHeader(text, order)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order, hidden = Hidden }
end

local function ReportOutput(field, order)
	return {
		type = "input",
		name = "",
		multiline = 12,
		width = "full",
		order = order,
		hidden = Hidden,
		get = function()
			return ns.diagnostics[field] or ""
		end,
		set = function() end,
	}
end

---@return table
function ns.BuildDiagnosticsOptions()
	return {
		type = "group",
		name = D.TAB,
		args = {
			descWarning = ns.OptionsDesc(D.WARNING, 1),
			spaceEnable = ns.OptionsSpacer(2),
			toggleEnable = {
				type = "toggle",
				name = D.ENABLE,
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

			-- Event Log
			headerEventLog = SectionHeader(D.EVENT_LOG_TITLE, 5),
			buttonStartLog = {
				type = "execute",
				name = D.EVENT_LOG_START,
				order = 6,
				hidden = Hidden,
				func = function()
					ns:StartEventLog()
					Refresh()
				end,
			},
			buttonStopLog = {
				type = "execute",
				name = D.EVENT_LOG_STOP,
				order = 7,
				hidden = Hidden,
				func = function()
					ns:StopEventLog()
					Refresh()
				end,
			},
			buttonShowLog = {
				type = "execute",
				name = D.EVENT_LOG_SHOW,
				order = 8,
				hidden = Hidden,
				func = function()
					ns.diagnostics.eventLogReport = ns:BuildEventLogReport()
					Refresh()
				end,
			},
			outputEventLog = ReportOutput("eventLogReport", 9),
			descEventLogHint = {
				type = "description",
				name = GetColor("HELP") .. D.EVENT_LOG_HINT .. "|r",
				fontSize = "medium",
				order = 10,
				hidden = Hidden,
			},

			-- Event Registration
			headerEvents = SectionHeader(D.EVENTS_TITLE, 13),
			buttonEvents = {
				type = "execute",
				name = D.EVENTS_BUTTON,
				order = 14,
				hidden = Hidden,
				func = function()
					ns.diagnostics.eventsReport = ns:RunEventChecks()
					Refresh()
				end,
			},
			outputEvents = ReportOutput("eventsReport", 15),

			-- API Endpoints
			headerApi = SectionHeader(D.API_TITLE, 20),
			buttonApi = {
				type = "execute",
				name = D.API_BUTTON,
				order = 21,
				hidden = Hidden,
				func = function()
					ns.diagnostics.apiReport = ns:RunApiChecks()
					Refresh()
				end,
			},
			outputApi = ReportOutput("apiReport", 22),

			-- Loot Method
			headerLoot = SectionHeader(D.LOOT_TITLE, 25),
			buttonLoot = {
				type = "execute",
				name = D.LOOT_BUTTON,
				order = 26,
				hidden = Hidden,
				func = function()
					ns.diagnostics.lootReport = ns:BuildLootMethodReport()
					Refresh()
				end,
			},
			outputLoot = ReportOutput("lootReport", 27),

			-- Other Add-ons
			headerAddons = SectionHeader(D.ADDONS_TITLE, 30),
			buttonAddons = {
				type = "execute",
				name = D.ADDONS_BUTTON,
				order = 31,
				hidden = Hidden,
				func = function()
					ns.diagnostics.addOnReport = ns:BuildAddOnReport()
					Refresh()
				end,
			},
			outputAddons = ReportOutput("addOnReport", 32),

			-- Saved Variables
			headerSaved = SectionHeader(D.SAVED_TITLE, 40),
			buttonSaved = {
				type = "execute",
				name = D.SAVED_BUTTON,
				order = 41,
				hidden = Hidden,
				func = function()
					ns.diagnostics.savedReport = ns:BuildSavedVariablesReport()
					Refresh()
				end,
			},
			outputSaved = ReportOutput("savedReport", 42),

			-- Library Versions
			headerLibs = SectionHeader(D.LIBS_TITLE, 50),
			buttonLibs = {
				type = "execute",
				name = D.LIBS_BUTTON,
				order = 51,
				hidden = Hidden,
				func = function()
					ns.diagnostics.libraryReport = ns:BuildLibraryReport()
					Refresh()
				end,
			},
			outputLibs = ReportOutput("libraryReport", 52),

			-- Taint Log
			headerTaint = SectionHeader(D.TAINT_TITLE, 60),
			descTaintState = {
				type = "description",
				name = function()
					return GetColor("BODY") .. string.format(D.TAINT_STATE, ns:GetTaintLogState()) .. "|r"
				end,
				fontSize = "medium",
				order = 61,
				hidden = Hidden,
			},
			buttonTaintOn = {
				type = "execute",
				name = D.TAINT_ON,
				order = 62,
				hidden = Hidden,
				func = function()
					ns:SetTaintLog(true)
					Refresh()
				end,
			},
			buttonTaintOff = {
				type = "execute",
				name = D.TAINT_OFF,
				order = 63,
				hidden = Hidden,
				func = function()
					ns:SetTaintLog(false)
					Refresh()
				end,
			},
			descTaintHint = {
				type = "description",
				name = GetColor("HELP") .. D.TAINT_HINT .. "|r",
				fontSize = "medium",
				order = 64,
				hidden = Hidden,
			},

			-- External Tools (point at mature tools rather than reimplement them)
			headerTools = SectionHeader(D.TOOLS_TITLE, 70),
			descToolsErrors = {
				type = "description",
				name = GetColor("BODY") .. string.format(
					D.TOOLS_ERRORS,
					GetColor("INFO") .. "/console scriptErrors 1|r" .. GetColor("BODY")
				) .. "|r",
				fontSize = "medium",
				order = 71,
				hidden = Hidden,
			},
			descToolsEtrace = {
				type = "description",
				name = GetColor("BODY")
					.. string.format(D.TOOLS_ETRACE, GetColor("INFO") .. "/etrace|r" .. GetColor("BODY"))
					.. "|r",
				fontSize = "medium",
				order = 72,
				hidden = Hidden,
			},
		},
	}
end
