--------------------------------------------------------------------------------
-- GogoLoot Options — Announcements
--------------------------------------------------------------------------------

--[[
    This panel hosts BOTH trade announcements and master looter announcements
    under a single "Announcements" tab, so all chat-output controls live in
    one place. The AceConfig registry key is ns.OPTIONS_REGISTRY.Announcements
    — a stable identifier referenced by NotifyChange calls across modules
    (see Options.lua's Initialization & Registration).

    Schema (ns.DATABASE_DEFAULTS.profile in Default-Settings.lua):
      announceTrade, announceTradeCondition, announceTradeOutput
        - trade announcement settings (Announcements-Trade.lua)
      announceDestinations
        - gates MESSAGE_DESTINATION_SET / MESSAGE_DESTINATION_LEFT
      announceMasterLootAuto + announceMasterLootAutoThreshold
        - gates the announce inside Master-Looter-Distribution.lua's
          TryDistributeSlot (items handed out by the auto path)

    The auto path is threshold-gated (default Blue+) so routine auto-loot
    doesn't spam chat. Manual hand-outs via the standard ML candidate dropdown
    have no setting at all: they are deliberate, so every one is always
    announced (see the GiveMasterLoot hook in Master-Looter-Distribution.lua).
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local GetQualityColor = ns.GetQualityColor
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
    Shared with the master looter pop-up (Options-Master-Looter-Popup.lua), which
    carries it second: the destination the player is about to pick in that window
    is exactly what this decides whether to announce, so the answer belongs
    beside the question rather than a panel away. Built once here so the two can
    never drift, and it repaints both surfaces because they can be open at once.
]]
---@param args table
---@param order number
---@return number # the next free order
function ns.AddDestinationMessagesRow(args, order)
	args.announceDestinations = {
		type = "toggle",
		name = L["MASTER_LOOTER_ANNOUNCE_DESTINATION"],
		width = "full",
		order = order,
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

--[[
    Every control on this panel except the three toggles belongs to one of them:
    a threshold that only applies while its toggle is on, an example of what that
    toggle posts, a note qualifying what it covers. They are drawn as sub-options
    (ns.OptionsSubRow) so the panel shows that ownership rather than listing nine
    peers.

    A dropdown goes with its toggle: it configures something that is not
    happening, so it hides rather than greying out. The EXAMPLES stay whatever
    the toggle says, because they are what somebody reads to decide whether to
    turn it on — a feature that shows you nothing until you enable it cannot be
    judged before you do.
]]
local function AutoAnnouncementsOff()
	return not ns.db.profile.announceMasterLootAuto
end

local function TradeAnnouncementsOff()
	return not ns.db.profile.announceTrade
end

---@param entry table
---@return table # the same entry, hidden with the toggle it belongs to
local function HideWhenAutoOff(entry)
	entry.hidden = AutoAnnouncementsOff
	return entry
end

---@param entry table
---@return table # the same entry, hidden with the toggle it belongs to
local function HideWhenTradeOff(entry)
	entry.hidden = TradeAnnouncementsOff
	return entry
end

--[[
    These dropdowns hold short fixed labels — a quality tier, "Always", "Whisper"
    — rather than the player names the Master Looter dropdowns carry, so they
    take less than the shared control width and stop well short of the panel's
    right edge. Their left edges still line up with each other, because a row
    pays for its indent out of its label and not out of its control.
]]
local ANNOUNCEMENT_DROPDOWN_WIDTH = 1.0

--------------------------------------------------------------------------------
-- Announcement Threshold Dropdown
--------------------------------------------------------------------------------

--[[
    Always offers Common+ through Epic+ regardless of the game's current loot
    threshold. ML distribution can only happen at-or-above the loot threshold,
    so options below it have no functional effect — but pinning the menu at
    Common+ keeps the user's chosen "announce everything" / "announce blue+"
    intent stable across loot-threshold changes, instead of silently bumping
    their saved selection upward each time.

    Poor (0) is intentionally excluded: ML doesn't distribute Poor items.
]]

local function BuildAnnouncementThresholdOptions()
	local options = {}
	for quality = 1, 4 do
		local rarityKey = ns.rarityToConfigurationKey[quality]
		local localizedName = ns.QUALITY_DISPLAY_NAMES[rarityKey] or ns:CapitalizeFirstLetter(rarityKey)
		options[quality] = GetQualityColor(quality) .. localizedName .. "+|r"
	end
	return options
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildAnnouncementOptions()
	local thresholdOptions = BuildAnnouncementThresholdOptions()

	local args = {
		----------------------------------------------------------------
		-- Master Looter Announcements
		----------------------------------------------------------------

		--[[
		    The panel title already reads "Announcements", so the first section
		    opens straight on its description with no header of its own, matching
		    the other panels.
		]]
		mlDesc = ns.OptionsDesc(L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"], 13),
		spacerAfterMLDesc = ns.OptionsSpacer(14),

		spacerAfterDestToggle = ns.OptionsSpacer(16),
		destExample = ns.OptionsSubRow(17, nil, {
			{
				type = "description",
				name = GetColor("HELP") .. L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] .. "|r",
				fontSize = "medium",
				width = "relative",
				relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),

		-- Auto distribution toggle + threshold
		spacerBeforeAuto = ns.OptionsSpacer(18),
		announceMasterLootAuto = {
			type = "toggle",
			name = L["MASTER_LOOTER_ANNOUNCE_AUTO"],
			width = "full",
			order = 19,
			get = function()
				return ns.db.profile.announceMasterLootAuto
			end,
			set = function(_, value)
				ns.db.profile.announceMasterLootAuto = value
			end,
		},
		spacerAfterAutoToggle = ns.OptionsSpacer(20),
		autoThresholdRow = ns.OptionsSubRow(21, AutoAnnouncementsOff, {
			ns.OptionsRowLabel(
				ns.OptionsSubLabel(L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"]),
				0,
				ns.OptionsSubLabelWidth(ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
			),
			{
				type = "select",
				name = "",
				style = "dropdown",
				width = ANNOUNCEMENT_DROPDOWN_WIDTH,
				values = thresholdOptions,
				get = function()
					return ns.db.profile.announceMasterLootAutoThreshold
				end,
				set = function(_, value)
					ns.db.profile.announceMasterLootAutoThreshold = value
				end,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),
		spacerBeforeAutoExample = HideWhenAutoOff(ns.OptionsSpacer(22)),
		autoExample = ns.OptionsSubRow(23, nil, {
			{
				type = "description",
				name = GetColor("HELP") .. L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] .. "|r",
				fontSize = "medium",
				width = "relative",
				relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),

		--[[
		    Indented with the rest of the block even though manual hand-outs have
		    no toggle of their own. It answers the question the threshold above it
		    raises — "so blues and below go unannounced?" — so it is part of that
		    block by subject, and the one flush line in an otherwise indented block
		    reads as the section having ended early rather than as a deliberate
		    exception.
		]]
		spacerBeforeManual = ns.OptionsSpacer(24),
		manualNote = ns.OptionsSubRow(25, nil, {
			{
				type = "description",
				name = GetColor("INFO") .. L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] .. "|r",
				fontSize = "medium",
				width = "relative",
				relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),

		----------------------------------------------------------------
		-- Trade Announcements
		----------------------------------------------------------------
		spacerBeforeTrade = ns.OptionsSpacer(40),
		tradeHeader = ns.OptionsHeader(L["TRADE_HEADER"], 41),
		spacerAfterTradeHeader = ns.OptionsSpacer(42),
		tradeDesc = ns.OptionsDesc(L["TRADE_DESCRIPTION"], 43),
		spacerAfterTradeDesc = ns.OptionsSpacer(44),
		announceTrade = {
			type = "toggle",
			name = L["TRADE_ENABLE"],
			width = "full",
			order = 45,
			get = function()
				return ns.db.profile.announceTrade
			end,
			set = function(_, value)
				ns.db.profile.announceTrade = value
				ns:SyncTradeCheckbox()
			end,
		},
		spacerAfterTradeToggle = ns.OptionsSpacer(46),
		tradeConditionRow = ns.OptionsSubRow(47, TradeAnnouncementsOff, {
			ns.OptionsRowLabel(
				ns.OptionsSubLabel(L["TRADE_CONDITION"]),
				0,
				ns.OptionsSubLabelWidth(ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
			),
			{
				type = "select",
				name = "",
				style = "dropdown",
				width = ANNOUNCEMENT_DROPDOWN_WIDTH,
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
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),
		spacerBetweenTradeDropdowns = HideWhenTradeOff(ns.OptionsSpacer(48)),
		tradeOutputRow = ns.OptionsSubRow(49, TradeAnnouncementsOff, {
			ns.OptionsRowLabel(
				ns.OptionsSubLabel(L["TRADE_OUTPUT"]),
				0,
				ns.OptionsSubLabelWidth(ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
			),
			{
				type = "select",
				name = "",
				style = "dropdown",
				width = ANNOUNCEMENT_DROPDOWN_WIDTH,
				values = ns.TRADE_OUTPUT_LABELS,
				sorting = { "whisper", "group" },
				get = function()
					return ns.db.profile.announceTradeOutput
				end,
				set = function(_, value)
					ns.db.profile.announceTradeOutput = value
				end,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),
		spacerBeforeTradeExample = HideWhenTradeOff(ns.OptionsSpacer(50)),
		tradeExample = ns.OptionsSubRow(51, nil, {
			{
				type = "description",
				name = GetColor("HELP") .. L["TRADE_EXAMPLE"] .. "|r",
				fontSize = "medium",
				width = "relative",
				relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
			},
		}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH),
	}

	-- Shared with the pop-up, so it is added rather than written inline.
	ns.AddDestinationMessagesRow(args, 15)

	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
		args = args,
	}
end
