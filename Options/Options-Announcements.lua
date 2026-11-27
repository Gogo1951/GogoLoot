--------------------------------------------------------------------------------
-- GogoLoot Options — Announcements
--------------------------------------------------------------------------------

--[[
    Automated hand-outs are threshold-gated so routine loot doesn't spam chat.
    Manual hand-outs are deliberate, so they take no threshold.
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
    Shared with the master looter pop-up, beside the destination it announces.
    Hides with the master switch on both, since nothing it decides can post.
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
    Common+ whatever the loot threshold, so a saved choice stays put when the
    threshold changes. Poor is left off, so a Poor hand-out is never announced.
]]
local ANNOUNCE_THRESHOLD_VALUES, ANNOUNCE_THRESHOLD_SORTING = ns.OptionsQualityChoices(1, "+")

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildAnnouncementOptions()
	local args = {
		description = Kit.Desc(L["ANNOUNCEMENTS_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
		lootNotifications = ns.FeatureSwitch("lootNotifications", 3),
	}

	-- Add hides every entry with the switch, on top of its own condition, so nothing is left on a switched-off panel.
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
	-- Its own example, since this toggle posts to the whole group too (maintainer, 2026-11-03).
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
