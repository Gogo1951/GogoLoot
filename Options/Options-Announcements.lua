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
local Kit = ns.OptionsKit

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
    never drift, and ns.RefreshSettings() repaints both, since they can be open at once.
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
		get = Kit.Get("profile", "announceDestinations"),
		set = function(_, value)
			ns.db.profile.announceDestinations = value
			ns.RefreshSettings()
		end,
	}
	return order + 1
end

--------------------------------------------------------------------------------
-- Examples
--------------------------------------------------------------------------------

--[[
    What each announcement posts, drawn by Kit.Example from the template and
    decoration the real one uses, ns:BuildAnnounceMessage, as party chat. The
    trade example follows Send Trade Summary To: a whisper as Aero receives
    it, party chat, or for Me Only the printed line from the _PRINT template.
    Each leaves while its own toggle is off, and with the master switch, like
    everything else below it.
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
	return Kit.SentLine(output == "whisper" and "WHISPER" or "PARTY", message)
end

local function DestinationExample()
	local message = ns:BuildAnnounceMessage(
		"MESSAGE_DESTINATION_SET",
		ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS],
		ns.QUALITY_DISPLAY_NAMES.epic
	)
	return Kit.SentLine("PARTY", message)
end

-- The item is the threshold's quality, so the example answers the dropdown beside its toggle.
local function AutomatedHandOutExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[ns.db.profile.announceMasterLootAutoThreshold])
	local message = ns:BuildAnnounceMessage("MESSAGE_GAVE", item, ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS])
	return Kit.SentLine("PARTY", message)
end

-- Hand-outs by hand are announced at any quality, so this example follows no dropdown.
local function ManualHandOutExample()
	local item = ns.OptionsExampleLink(ns.SAMPLE_ITEM_IDS[3])
	local message = ns:BuildAnnounceMessage("MESSAGE_GAVE", item, ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS])
	return Kit.SentLine("PARTY", message)
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
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    Each toggle carries what belongs to it the way every GogoLoot panel does
    (Kit.ToggleRow, Kit.SubLabelRow): a single setting on the toggle's
    own line, which leaves the line while the toggle is off, and a captioned
    setting on an indented row below, which leaves the panel with it.
]]
---@return table
function ns.BuildAnnouncementOptions()
	local args = {
		description = Kit.Desc(L["ANNOUNCEMENTS_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
		lootNotifications = ns.FeatureSwitch("lootNotifications", 3),
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
		Add(key, Kit.Spacer(0))
	end

	-- Trade Announcements
	AddSpacer("spacerBeforeTrade")
	Add("tradeHeader", Kit.Header(L["TAB_TRADE_ANNOUNCEMENTS"], 0))
	AddSpacer("spacerAfterTradeHeader")
	Add("tradeDesc", Kit.Desc(L["TRADE_DESCRIPTION"], 0))
	AddSpacer("spacerAfterTradeDesc")
	Add(
		"tradeRow",
		Kit.ToggleRow(0, {
			type = "toggle",
			name = L["TRADE_ENABLE"],
			desc = L["TRADE_ENABLE_DESCRIPTION"],
			get = Kit.Get("profile", "announceTrade"),
			set = function(_, value)
				ns.db.profile.announceTrade = value
				ns:SyncTradeCheckbox()
				ns.RefreshSettings()
			end,
		}, {
			control = {
				type = "select",
				desc = L["TRADE_CONDITION_DESCRIPTION"],
				style = "dropdown",
				values = ns.TRADE_CONDITION_LABELS,
				sorting = ns.TRADE_CONDITION_ORDER,
				get = Kit.Get("profile", "announceTradeCondition"),
				set = Kit.Set("profile", "announceTradeCondition"),
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
		Kit.SubLabelRow(0, TradeAnnouncementsOff, L["TRADE_CHANNEL"], {
			type = "select",
			desc = L["TRADE_CHANNEL_TOOLTIP"]:format(WHISPER),
			style = "dropdown",
			values = ns.TRADE_OUTPUT_LABELS,
			sorting = { "whisper", "group", "self" },
			get = Kit.Get("profile", "announceTradeOutput"),
			set = Kit.Set("profile", "announceTradeOutput"),
		})
	)
	Add("tradeExampleRow", Kit.Example(0, TradeAnnouncementsOff, TradeExample))

	-- Master Looter Announcements
	AddSpacer("spacerBeforeMasterLooter")
	Add("masterLooterHeader", Kit.Header(L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"], 0))
	AddSpacer("spacerAfterMasterLooterHeader")
	Add("masterLooterDesc", Kit.Desc(L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"], 0))
	AddSpacer("spacerAfterMasterLooterDesc")
	-- Shared with the pop-up, so its own builder adds it, and hides it with the master switch itself.
	order = order + 1
	ns.AddDestinationMessagesRow(args, order)
	Add(
		"destinationExampleRow",
		Kit.Example(0, function()
			return not ns.db.profile.announceDestinations
		end, DestinationExample)
	)
	AddSpacer("spacerBeforeAuto")
	Add(
		"autoAnnounceRow",
		Kit.ToggleRow(0, {
			type = "toggle",
			name = L["MASTER_LOOTER_ANNOUNCE_AUTO"],
			desc = L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"],
			get = Kit.Get("profile", "announceMasterLootAuto"),
			set = Kit.Set("profile", "announceMasterLootAuto"),
		}, {
			control = {
				type = "select",
				desc = L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"],
				style = "dropdown",
				values = ANNOUNCE_THRESHOLD_VALUES,
				sorting = ANNOUNCE_THRESHOLD_SORTING,
				get = Kit.Get("profile", "announceMasterLootAutoThreshold"),
				set = Kit.Set("profile", "announceMasterLootAutoThreshold"),
			},
		})
	)
	Add(
		"autoExampleRow",
		Kit.Example(0, function()
			return not ns.db.profile.announceMasterLootAuto
		end, AutomatedHandOutExample)
	)
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
		get = Kit.Get("profile", "announceMasterLootManual"),
		set = Kit.Set("profile", "announceMasterLootManual"),
	})
	Add(
		"manualExampleRow",
		Kit.Example(0, function()
			return not ns.db.profile.announceMasterLootManual
		end, ManualHandOutExample)
	)

	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
		args = args,
	}
end
