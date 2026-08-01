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
        - gates the announce inside Master-Looter.lua's
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

	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
		args = {
			----------------------------------------------------------------
			-- Master Looter Announcements
			----------------------------------------------------------------

			--[[
			    The panel title already reads "Announcements", so the first
			    section opens straight on its description with no header of its
			    own, matching the other panels.
			]]
			mlDesc = ns.OptionsDesc(L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"], 13),
			spacerAfterMLDesc = ns.OptionsSpacer(14),

			-- Destinations toggle (gates MESSAGE_DESTINATION_SET / MESSAGE_DESTINATION_LEFT)
			announceDestinations = {
				type = "toggle",
				name = L["MASTER_LOOTER_ANNOUNCE_DESTINATION"],
				width = "full",
				order = 15,
				get = function()
					return ns.db.profile.announceDestinations
				end,
				set = function(_, value)
					ns.db.profile.announceDestinations = value
				end,
			},
			spacerAfterDestToggle = ns.OptionsSpacer(16),
			destExample = ns.OptionsDesc(
				GetColor("MUTED") .. L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] .. "|r",
				17
			),

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
			autoThresholdLabel = ns.OptionsRowLabel(L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"], 21),
			announceMasterLootAutoThreshold = {
				type = "select",
				name = "",
				style = "dropdown",
				width = ns.OPTIONS_CONTROL_WIDTH,
				values = thresholdOptions,
				order = 22,
				disabled = function()
					return not ns.db.profile.announceMasterLootAuto
				end,
				get = function()
					return ns.db.profile.announceMasterLootAutoThreshold
				end,
				set = function(_, value)
					ns.db.profile.announceMasterLootAutoThreshold = value
				end,
			},
			spacerBeforeAutoExample = ns.OptionsSpacer(23),
			autoExample = ns.OptionsDesc(GetColor("MUTED") .. L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] .. "|r", 24),

			-- Manual distributions have no toggle — they're always announced (see note).
			spacerBeforeManual = ns.OptionsSpacer(25),
			manualNote = ns.OptionsDesc(L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"], 26),

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
			tradeConditionLabel = ns.OptionsRowLabel(L["TRADE_CONDITION"], 47),
			announceTradeCondition = {
				type = "select",
				name = "",
				style = "dropdown",
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 48,
				disabled = function()
					return not ns.db.profile.announceTrade
				end,
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
			spacerBetweenTradeDropdowns = ns.OptionsSpacer(49),
			tradeOutputLabel = ns.OptionsRowLabel(L["TRADE_OUTPUT"], 50),
			announceTradeOutput = {
				type = "select",
				name = "",
				style = "dropdown",
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 51,
				disabled = function()
					return not ns.db.profile.announceTrade
				end,
				values = ns.TRADE_OUTPUT_LABELS,
				sorting = { "whisper", "group" },
				get = function()
					return ns.db.profile.announceTradeOutput
				end,
				set = function(_, value)
					ns.db.profile.announceTradeOutput = value
				end,
			},
			spacerBeforeTradeExample = ns.OptionsSpacer(52),
			tradeExample = ns.OptionsDesc(GetColor("MUTED") .. L["TRADE_EXAMPLE"] .. "|r", 53),
		},
	}
end
