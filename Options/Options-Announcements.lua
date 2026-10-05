--------------------------------------------------------------------------------
-- GogoLoot Options — Announcements
--------------------------------------------------------------------------------

--[[
    One panel for everything GogoLoot tells other players: trade summaries and
    master loot. What it shows and plays for the player alone lives on the Loot
    Toasts and Loot Sounds panels. Enable Announcements is the panel's master switch,
    and everything below it leaves the panel while it is off: Trade
    Announcements, then Master Looter Announcements, each under its own header.
    The saved key, lootNotifications, and the locale keys keep the panel's
    earlier name, Loot Notifications.

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
local GetColor = ns.GetColor
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
    real one uses, ns:BuildAnnounceMessage. The one exception is the Me Only
    trade example, a printed line, which ns.OptionsPrintedExample lays out from
    the _PRINT template. Each leaves with the master switch, like everything
    else below it.
]]
local EXAMPLE_PLAYER = "Aero"
-- The printed example names Aero in a class color, as Automated Rolls' winner summary example does.
local EXAMPLE_PLAYER_CLASS = "WARRIOR"
-- Two of one item for 5 gold: a trade that shows a count and money both.
local EXAMPLE_TRADE_COUNT = 2
local EXAMPLE_TRADE_COPPER = 50000
local EXAMPLE_TRADE_QUALITY = 2

-- Me Only prints the summary rather than sending it, so its example is the printed line, name first.
local function TradeExample()
	local gave = ns.FormatTradeSummary(
		{ { link = ns.OptionsExampleItem(EXAMPLE_TRADE_QUALITY), count = EXAMPLE_TRADE_COUNT } },
		nil,
		0
	)
	local received = ns.FormatTradeSummary({}, nil, EXAMPLE_TRADE_COPPER)
	if ns.db.profile.announceTradeOutput == "self" then
		local partner = EXAMPLE_PLAYER
		local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[EXAMPLE_PLAYER_CLASS]
		if type(classColor) == "table" and type(classColor.colorStr) == "string" then
			-- The silver after the name keeps the rest of the example line silver.
			partner = "|c" .. classColor.colorStr .. EXAMPLE_PLAYER .. GetColor("HELP")
		end
		return ns.OptionsPrintedExample(L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"]:format(gave, partner, received))
	end
	return ns:BuildAnnounceMessage("MESSAGE_TRADE_GAVE_RECEIVED", gave, EXAMPLE_PLAYER, received)
end

local function DestinationExample()
	return ns:BuildAnnounceMessage("MESSAGE_DESTINATION_SET", EXAMPLE_PLAYER, ns.QUALITY_DISPLAY_NAMES.epic)
end

-- The item takes the threshold's color, so the example answers the dropdown beside its toggle.
local function AutomatedHandOutExample()
	local item = ns.OptionsExampleItem(ns.db.profile.announceMasterLootAutoThreshold)
	return ns:BuildAnnounceMessage("MESSAGE_GAVE", item, EXAMPLE_PLAYER)
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
				values = {
					["always"] = L["TRADE_CONDITION_ALWAYS"],
					["party_or_raid"] = L["TRADE_CONDITION_PARTY_OR_RAID"],
					["raid_only"] = L["TRADE_CONDITION_RAID_ONLY"],
				},
				sorting = { "always", "party_or_raid", "raid_only" },
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
	    Items handed out by hand post the same line as the automated ones, so
	    the example above serves both, and they take no threshold: each one was
	    a deliberate choice.
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

	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
		args = args,
	}
end
