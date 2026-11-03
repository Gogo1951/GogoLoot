--------------------------------------------------------------------------------
-- GogoLoot Options — Announcements
--------------------------------------------------------------------------------

--[[
    One panel for everything GogoLoot tells other players: trade summaries and
    master loot. What it shows and plays for the player alone lives on the Loot
    Toasts and Loot Sounds panels. Enable Loot Announcements is the panel's
    master switch, and everything below it leaves the panel while it is off:
    Trade Announcements, then Master Looter Announcements, each under its own
    header. The saved key is lootNotifications.

    Schema (ns.DATABASE_DEFAULTS.profile in Default-Settings.lua):
      lootNotifications
        - the master switch: ns:Announce (Announcements.lua) sends nothing
          while it is off
      announceTrade, announceTradeCondition, announceTradeOutput
        - read by Announcements-Trade.lua; the checkbox on the trade window
          writes announceTrade too, and repaints this panel when it does
      announceDestinations
        - gates MESSAGE_DESTINATION_SET / MESSAGE_DESTINATION_LEFT
      announceMasterLootAuto + announceMasterLootAutoThreshold
        - gates the announce inside Master-Looter-Distribution.lua's
          TryDistributeSlot (items handed out by the auto path)
      announceMasterLootManual
        - gates the announce for items handed out by hand (the GiveMasterLoot
          hook in Master-Looter-Distribution.lua)

    The auto path is threshold-gated (default Blue+) so routine auto-loot
    doesn't spam chat. Manual hand-outs via the standard ML candidate dropdown
    are deliberate, so they take no threshold: every one is announced while
    its own switch and the master switch are on.
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local function LootNotificationsOff()
	return not ns.db.profile.lootNotifications
end

local function TradeAnnouncementsOff()
	return not ns.db.profile.announceTrade
end

--[[
    Shared with the master looter pop-up (Options-Master-Looter-Popup.lua), which
    carries it third, after its own switch and Enable Automated Master Looting:
    the destination the player is about to pick in that window is exactly what
    this decides whether to announce, so the answer belongs beside the question
    rather than a panel away. Built once here so the two can
    never drift, and it repaints both surfaces because they can be open at once.
    It leaves both with the master switch, since nothing it decides can be
    posted while that is off.
]]
---@param args table
---@param order number
---@return number # the next free order
function ns.AddDestinationMessagesRow(args, order)
	args.announceDestinations = {
		type = "toggle",
		name = L["MASTER_LOOTER_ANNOUNCE_DESTINATION"],
		desc = L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"],
		width = "full",
		order = order,
		hidden = LootNotificationsOff,
		get = function()
			return ns.db.profile.announceDestinations
		end,
		set = function(_, value)
			ns.db.profile.announceDestinations = value
			ns:RefreshMasterLooterPanels()
			AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Announcements)
		end,
	}
	return order + 1
end

--------------------------------------------------------------------------------
-- Examples
--------------------------------------------------------------------------------

--[[
    What each announcement posts, drawn by ns.OptionsExampleRow (Message
    Examples in Options-Utilities.lua) from the template and decoration the
    real one uses, ns:BuildAnnounceMessage, as party chat. The trade example
    follows Send Trade Summary To: a whisper as Aero receives it, party chat,
    or for Me Only the printed line from the _PRINT template. Each leaves with
    the master switch, like everything else below it.
]]
local EXAMPLE_PLAYER_CLASS = "DRUID"
-- Two of one item for 5 gold: a trade that shows a count and money both.
local EXAMPLE_TRADE_COUNT = 2
local EXAMPLE_TRADE_COPPER = 50000
local EXAMPLE_TRADE_QUALITY = 2

local function TradeExample()
	local gave = ns.FormatTradeSummary({
		{ link = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[EXAMPLE_TRADE_QUALITY]), count = EXAMPLE_TRADE_COUNT },
	}, nil, 0)
	local received = ns.FormatTradeSummary({}, nil, EXAMPLE_TRADE_COPPER)
	local output = ns.db.profile.announceTradeOutput
	if output == "self" then
		local partner = ns.OptionsExampleOther(EXAMPLE_PLAYER_CLASS)
		return ns.OptionsPrintedLine(L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"]:format(gave, partner, received))
	end
	local partner = ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS]
	local message = ns:BuildAnnounceMessage("MESSAGE_TRADE_GAVE_RECEIVED", gave, partner, received)
	return ns.OptionsSentLine(output == "whisper" and "WHISPER" or "PARTY", message)
end

local function DestinationExample()
	local message = ns:BuildAnnounceMessage(
		"MESSAGE_DESTINATION_SET",
		ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS],
		ns.QUALITY_DISPLAY_NAMES.epic
	)
	return ns.OptionsSentLine("PARTY", message)
end

-- The item is the threshold's quality, so the example answers the dropdown beside its toggle.
local function AutomatedHandOutExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[ns.db.profile.announceMasterLootAutoThreshold])
	local message = ns:BuildAnnounceMessage("MESSAGE_GAVE", item, ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS])
	return ns.OptionsSentLine("PARTY", message)
end

-- Hand-outs by hand are announced at any quality, so this example follows no dropdown.
local function ManualHandOutExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[3])
	local message = ns:BuildAnnounceMessage("MESSAGE_GAVE", item, ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS])
	return ns.OptionsSentLine("PARTY", message)
end

--------------------------------------------------------------------------------
-- Quality Dropdowns
--------------------------------------------------------------------------------

--[[
    Always offers Common+ through Epic+ regardless of the game's current loot
    threshold. ML distribution can only happen at-or-above the loot threshold,
    so options below it have no functional effect — but pinning the menu at
    Common+ keeps the user's chosen "announce everything" / "announce blue+"
    intent stable across loot-threshold changes, instead of silently bumping
    their saved selection upward each time.

    Poor (0) is left off, so a Poor hand-out, possible only where the loot
    threshold reaches Poor (Classic Era and WoW Forever), is never announced.
]]
local ANNOUNCE_THRESHOLD_VALUES, ANNOUNCE_THRESHOLD_SORTING = ns.OptionsQualityChoices(1, "+")

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Announcements, drawn on this panel and again in the Features section
    of the General panel. Built once here so the two can never drift; each
    caller sets its own order and width.
]]
---@return table
function ns.AnnouncementsSwitch()
	return {
		type = "toggle",
		name = L["ANNOUNCEMENTS_ENABLE"],
		desc = L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"],
		get = function()
			return ns.db.profile.lootNotifications
		end,
		set = function(_, value)
			ns.db.profile.lootNotifications = value
			-- The trade window's checkbox and the pop-up's destination toggle leave and return with it.
			ns:SyncTradeCheckbox()
			ns:RefreshMasterLooterPanels()
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    Each toggle carries what belongs to it the way every GogoLoot panel does
    (see Toggle Rows in Options-Utilities.lua): a single setting on the toggle's
    own line, which leaves the line while the toggle is off, and a captioned
    setting on an indented row below, which leaves the panel with it.
]]
---@return table
function ns.BuildAnnouncementOptions()
	local lootNotifications = ns.AnnouncementsSwitch()
	lootNotifications.width = "full"
	lootNotifications.order = 3
	local args = {
		description = ns.OptionsDesc(L["ANNOUNCEMENTS_DESCRIPTION"], 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
		lootNotifications = lootNotifications,
	}

	--[[
        Everything below the switch goes through Add, which gives it the next
        order and hides it with the switch, on top of any condition of its own,
        so nothing added later can be left standing on a switched-off panel.
    ]]
	local order = 3
	local function Add(key, entry)
		order = order + 1
		entry.order = order
		local ownHidden = entry.hidden
		if ownHidden then
			entry.hidden = function()
				return LootNotificationsOff() or ownHidden()
			end
		else
			entry.hidden = LootNotificationsOff
		end
		args[key] = entry
	end
	local function AddSpacer(key)
		Add(key, ns.OptionsSpacer(0))
	end

	-- Trade Announcements
	AddSpacer("spacerBeforeTrade")
	Add("tradeHeader", ns.OptionsHeader(L["TAB_TRADE_ANNOUNCEMENTS"], 0))
	AddSpacer("spacerAfterTradeHeader")
	Add("tradeDesc", ns.OptionsDesc(L["TRADE_DESCRIPTION"], 0))
	AddSpacer("spacerAfterTradeDesc")
	Add(
		"tradeRow",
		ns.OptionsToggleRow(0, {
			type = "toggle",
			name = L["TRADE_ENABLE"],
			desc = L["TRADE_ENABLE_DESCRIPTION"],
			get = function()
				return ns.db.profile.announceTrade
			end,
			set = function(_, value)
				ns.db.profile.announceTrade = value
				ns:SyncTradeCheckbox()
			end,
		}, {
			control = {
				type = "select",
				desc = L["TRADE_CONDITION_DESCRIPTION"],
				style = "dropdown",
				values = ns.TRADE_CONDITION_LABELS,
				sorting = ns.TRADE_CONDITION_ORDER,
				get = function()
					return ns.db.profile.announceTradeCondition
				end,
				set = function(_, value)
					ns.db.profile.announceTradeCondition = value
				end,
			},
		})
	)
	--[[
	    Where summaries go, as a captioned dropdown under the toggle: whispered
	    to the trade partner, posted to group chat, or printed to the player
	    alone. It writes the saved announceTradeOutput string ("whisper" |
	    "group" | "self") the trade module and the trade window's tooltip read.
	]]
	Add(
		"tradeOutputRow",
		ns.OptionsSubSelectRow(0, TradeAnnouncementsOff, L["TRADE_CHANNEL"], {
			type = "select",
			desc = L["TRADE_CHANNEL_TOOLTIP"]:format(WHISPER),
			style = "dropdown",
			values = ns.TRADE_OUTPUT_LABELS,
			sorting = { "whisper", "group", "self" },
			get = function()
				return ns.db.profile.announceTradeOutput
			end,
			set = function(_, value)
				ns.db.profile.announceTradeOutput = value
			end,
		})
	)
	Add("tradeExampleRow", ns.OptionsExampleRow(0, TradeExample))

	-- Master Looter Announcements
	AddSpacer("spacerBeforeMasterLooter")
	Add("masterLooterHeader", ns.OptionsHeader(L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"], 0))
	AddSpacer("spacerAfterMasterLooterHeader")
	Add("masterLooterDesc", ns.OptionsDesc(L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"], 0))
	AddSpacer("spacerAfterMasterLooterDesc")
	-- Shared with the pop-up, so its own builder adds it, and hides it with the master switch itself.
	order = order + 1
	ns.AddDestinationMessagesRow(args, order)
	Add("destinationExampleRow", ns.OptionsExampleRow(0, DestinationExample))
	AddSpacer("spacerBeforeAuto")
	Add(
		"autoAnnounceRow",
		ns.OptionsToggleRow(0, {
			type = "toggle",
			name = L["MASTER_LOOTER_ANNOUNCE_AUTO"],
			desc = L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"],
			get = function()
				return ns.db.profile.announceMasterLootAuto
			end,
			set = function(_, value)
				ns.db.profile.announceMasterLootAuto = value
			end,
		}, {
			control = {
				type = "select",
				desc = L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"],
				style = "dropdown",
				values = ANNOUNCE_THRESHOLD_VALUES,
				sorting = ANNOUNCE_THRESHOLD_SORTING,
				get = function()
					return ns.db.profile.announceMasterLootAutoThreshold
				end,
				set = function(_, value)
					ns.db.profile.announceMasterLootAutoThreshold = value
				end,
			},
		})
	)
	Add("autoExampleRow", ns.OptionsExampleRow(0, AutomatedHandOutExample))
	--[[
	    Items handed out by hand post the same line as the automated ones, and
	    take no threshold: each one was a deliberate choice. They still get an
	    example of their own, since this toggle posts to the whole group too
	    (maintainer, 2026-11-03).
	]]
	AddSpacer("spacerBeforeManual")
	Add("manualAnnounce", {
		type = "toggle",
		name = L["MASTER_LOOTER_ANNOUNCE_MANUAL"],
		desc = L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"]:format(MASTER_LOOTER),
		width = "full",
		get = function()
			return ns.db.profile.announceMasterLootManual
		end,
		set = function(_, value)
			ns.db.profile.announceMasterLootManual = value
		end,
	})
	Add("manualExampleRow", ns.OptionsExampleRow(0, ManualHandOutExample))

	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
		args = args,
	}
end
