--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local GetQualityColor = ns.GetQualityColor

--[[
    A sub-option toggle carries a short caption, so it takes a unit width with
    room to spare rather than an exact fit — see ns.OptionsSubRow on why an exact
    fit is the one thing these must not do. The prose under them is sized against
    the pane instead (ns.OPTIONS_SUB_TEXT_REL_WIDTH), since a unit width wraps a
    sentence well short of the room it actually has.
]]
local SUB_TOGGLE_WIDTH = 2.0

--------------------------------------------------------------------------------
-- Shared Rows
--------------------------------------------------------------------------------

--[[
    Rows drawn on this panel and again in the master looter pop-up
    (Options-Master-Looter-Popup.lua) are built once here and added to whichever
    args table asks for them: the pop-up toggle, the leader note, loot method,
    loot threshold, and Send All Loot To. The pop-up's remaining shared row, the
    destination-messages toggle, is built in Options-Announcements.lua, which
    owns that setting. Every builder takes (args, order) and returns the next
    free order.
]]

local function BuildLootTypeValues()
	return {
		["freeforall"] = L["LOOT_METHOD_FREE_FOR_ALL"],
		["roundrobin"] = L["LOOT_METHOD_ROUND_ROBIN"],
		["master"] = L["LOOT_METHOD_MASTER"],
		["group"] = L["LOOT_METHOD_GROUP"],
		["needbeforegreed"] = L["LOOT_METHOD_NEED_BEFORE_GREED"],
	}
end

--[[
    The loot-threshold floor is client-specific: Classic Era allows all the
    way down to Poor (gray), while TBC and later stop at Uncommon (green).
    SetLootThreshold accepts the lower Era values (confirmed by the
    LootThresholdCommon reference add-on).
]]
local function BuildThresholdValues()
	local values = {
		[4] = GetQualityColor(4) .. L["QUALITY_EPIC"] .. "|r",
		[3] = GetQualityColor(3) .. L["QUALITY_RARE"] .. "|r",
		[2] = GetQualityColor(2) .. L["QUALITY_UNCOMMON"] .. "|r",
	}
	if ns.isClassicEra then
		values[1] = GetQualityColor(1) .. L["QUALITY_COMMON"] .. "|r"
		values[0] = GetQualityColor(0) .. L["QUALITY_POOR"] .. "|r"
	end
	return values
end

--[[
    Only the group leader can change the loot method and threshold, so the two
    dropdowns are editable for the leader and disabled for everyone else. Who
    does control them is named once by the leader note row above the pair, not on
    the labels themselves.
]]
local function IsNotLeader()
	return not ns:IsGroupLeader()
end

--[[
    Automated Master Looting's master switch really is the master switch:
    ns:WillAutoMasterLoot returns false outright when autoMasterLoot is off, so
    nothing below it on this panel changes anything until it is on. That is why
    the sweep below hides the lot rather than greying it — a control that is
    never drawn has no use for a disabled state.
]]
local function IsAutomationOff()
	return not ns.db.profile.autoMasterLoot
end

--[[
    The whole panel below the master switch hides while it is off, the way the
    Automated Rolls panel does behind its own. A player who has turned the
    feature off is not choosing destinations or curating an ignore list, and a
    page of greyed controls says that at far greater length.

    Composed rather than assigned: several of these already answer to something
    else — a threshold row that hides under Free for All, a tier row below the
    loot threshold, a leader note that only appears for a non-leader — and the
    master switch has to be an additional reason to hide, never a replacement
    for theirs. Only the panel does this; the pop-up draws several of the same
    shared rows and gates none of them.
]]
---@param entry table
---@return table # the same entry, hidden while the master switch is off
local function HideWhenAutomationOff(entry)
	local ownCheck = entry.hidden
	if ownCheck == nil then
		entry.hidden = IsAutomationOff
		return entry
	end

	entry.hidden = function()
		if IsAutomationOff() then
			return true
		end
		if type(ownCheck) == "function" then
			return ownCheck()
		end
		return ownCheck
	end
	return entry
end

--[[
    The switch itself, and the description leading to it. Everything else on the
    panel goes when it is off.
]]
local PANEL_ALWAYS_SHOWN = {
	autoDesc = true,
	spacerAfterAutoDesc = true,
	autoMasterLoot = true,
}

--[[
    Two methods have no threshold to apply: Free for All opens every drop to the
    whole group, and Round Robin hands whole drops out in turn. Neither consults
    quality, so the row is hidden outright instead of left showing a value that
    changes nothing. Callers hide the spacer that pairs with the row so its
    absence does not leave a double gap.
]]
local THRESHOLDLESS_LOOT_METHODS = {
	freeforall = true,
	roundrobin = true,
}

local function IsLootThresholdIrrelevant()
	return THRESHOLDLESS_LOOT_METHODS[ns:SafeGetLootMethod()] == true
end

ns.IsLootThresholdIrrelevant = IsLootThresholdIrrelevant

--[[
    Who controls the two dropdowns, said once above them rather than repeated
    around them. It names the leader whoever that is, the player included, so the
    line reads as a statement about whose group it is rather than as a complaint
    about a control being greyed out.

    Hidden only while solo, where there is no leader to name.
]]
local function LeaderNoteHidden()
	return ns:GetGroupLeaderName() == nil
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLeaderNoteRow(args, order)
	args.leaderNote = {
		type = "description",
		name = function()
			return GetColor("INFO")
				.. string.format(L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"], ns:GetGroupLeaderName() or "")
				.. "|r"
		end,
		fontSize = "medium",
		order = order,
		hidden = LeaderNoteHidden,
	}
	args.spacerAfterLeaderNote = {
		type = "description",
		name = " ",
		order = order + 1,
		hidden = LeaderNoteHidden,
	}
	return order + 2
end

--[[
    These three rows sit under a checkbox on both surfaces that draw them, so
    each leads with the checkbox inset and pays for it out of its own label —
    the labels then start on the gold square above rather than a few pixels
    left of it, and the dropdowns still share the panel's control column.
]]
local CHECKBOX_ALIGNED_LABEL_WIDTH = ns.OptionsSubLabelWidth(ns.OPTIONS_CHECKBOX_INSET_WIDTH)

--[[
    A tier row aligns with the checkbox of the toggle that reveals it, so it
    spends that toggle's own indent plus the same inset a label owes a box.
]]
local TIER_ROW_INDENT = ns.OPTIONS_SUB_INDENT_WIDTH + ns.OPTIONS_CHECKBOX_INSET_WIDTH

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootMethodRow(args, order)
	args.lootTypeRow = ns.OptionsSubRow(order, nil, {
		ns.OptionsRowLabel(L["MASTER_LOOTER_LOOT_METHOD"], 0, CHECKBOX_ALIGNED_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = BuildLootTypeValues,
			disabled = IsNotLeader,
			get = function()
				return ns:SafeGetLootMethod()
			end,
			set = function(_, value)
				ns:SafeSetLootMethod(value)
				ns:RefreshMasterLooterPanels()
			end,
		},
	}, ns.OPTIONS_CHECKBOX_INSET_WIDTH)
	return order + 1
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootThresholdRow(args, order)
	args.lootThresholdRow = ns.OptionsSubRow(order, IsLootThresholdIrrelevant, {
		ns.OptionsRowLabel(L["MASTER_LOOTER_LOOT_THRESHOLD"], 0, CHECKBOX_ALIGNED_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = BuildThresholdValues,
			disabled = IsNotLeader,
			get = function()
				return ns:SafeGetLootThreshold()
			end,
			set = function(_, value)
				ns:SafeSetLootThreshold(value)
				ns:RefreshMasterLooterPanels()
			end,
		},
	}, ns.OPTIONS_CHECKBOX_INSET_WIDTH)
	return order + 1
end

--[[
    Sets every quality tier at once. It reads back as the shared destination
    only when all tiers already agree, so a mixed set of per-tier choices shows
    blank rather than misreporting one tier's player as the answer for all.
]]
---@param args table
---@param order number
---@param hidden? function # hides both the label and the dropdown when it returns true
---@return number # the next free order
function ns.AddSendAllDestinationRow(args, order, hidden)
	args.sendAllRow = ns.OptionsSubRow(order, hidden, {
		ns.OptionsRowLabel(L["MASTER_LOOTER_SEND_ALL"], 0, CHECKBOX_ALIGNED_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			desc = L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"],
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = function()
				return ns:GetGroupMemberNames()
			end,
			sorting = function()
				return ns:GetGroupMemberSorting()
			end,
			get = function()
				return ns:GetSharedDestination()
			end,
			set = function(_, value)
				ns:SetAllDestinations(value)
				ns:RefreshMasterLooterPanels()
			end,
		},
	}, ns.OPTIONS_CHECKBOX_INSET_WIDTH)
	return order + 1
end

--[[
    The pop-up's own on/off switch, on the panel and again inside the pop-up
    itself — the window you would most want to turn it off from is the one that
    just opened uninvited, and hunting through Options to do it is the wrong
    answer. Built here like the other shared rows so the two can never drift, and
    it refreshes both surfaces so a change made in one is reflected in the other.
]]
---@param args table
---@param order number
---@return number # the next free order
function ns.AddPopupToggleRow(args, order)
	args.masterLooterPopup = {
		type = "toggle",
		name = L["MASTER_LOOTER_POPUP_ENABLE"],
		desc = L["MASTER_LOOTER_POPUP_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.masterLooterPopup
		end,
		set = function(_, value)
			ns.db.profile.masterLooterPopup = value
			ns:RefreshMasterLooterPanels()
		end,
	}
	return order + 1
end

--[[
    A suffix on the toggle that collapsed the tier rows, and only for the one
    state the Send All Loot To dropdown above it cannot express.

    That dropdown reads blank in two very different situations: nothing is set
    up at all, and the tiers disagree. Blank is honest for the first and silent
    about the second, so with the rows collapsed a per-tier setup would be
    invisible. Everything else is left unsaid — a shared destination is already
    named in the dropdown, and saying it twice is noise.

    ns:GetSharedDestination answers nil for both of those situations, so the
    assigned tiers are counted here rather than inferred from it.
]]
local function SummarizeDestinations()
	local assignedCount = 0
	for quality = 0, 4 do
		local qualityKey = ns.rarityToConfigurationKey[quality]
		local destination = qualityKey and ns.db.profile.destinations[qualityKey]
		if destination and destination ~= "" then
			assignedCount = assignedCount + 1
		end
	end

	if assignedCount == 0 then
		return ""
	end

	local sharedDestination = ns:GetSharedDestination()
	if sharedDestination and sharedDestination ~= "" then
		return ""
	end

	-- Hyphen, not an em-dash: the client's fonts render em-dashes badly.
	return "  " .. GetColor("INFO") .. "- " .. L["MASTER_LOOTER_TIERS_SUMMARY_MIXED"] .. "|r"
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildMasterLooterOptions()
	local ignoreListArgs = ns:BuildItemListOptions({
		getSourceTable = function()
			return ns.db.profile.ignoredItemsMaster
		end,
		onRestore = function()
			ns.db.profile.ignoredItemsMaster = ns:BuildDefaultIgnoreListMaster()
		end,
		onAdd = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = true
		end,
		onRemove = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = nil
		end,
		notifyKey = ns.OPTIONS_REGISTRY.MasterLooter,
		labels = {
			restore = L["MASTER_LOOTER_IGNORE_RESTORE"],
			restoreConfirm = L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"],
			addDesc = L["ITEM_LIST_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			removeDesc = L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"],
		},
	})

	local args = {}
	local order = 1

	--[[
	    Automated Master Looting opens the panel, and does so with no header of
	    its own: the tab is already titled Master Looter, and this is the block
	    that title describes. Every other panel opens the same way.
	]]
	args.autoDesc =
		ns.OptionsDesc(L["MASTER_LOOTER_AUTO_DESCRIPTION"] .. " " .. L["SAFETY_SKIP_NOTE_MASTER_LOOTER"], order)
	order = order + 1
	args.spacerAfterAutoDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.autoMasterLoot = {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_ENABLE"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.autoMasterLoot
		end,
		set = function(_, value)
			ns.db.profile.autoMasterLoot = value
			if value and not ns:AreWeMasterLooter() then
				ns:PrintMessage(L["MESSAGE_NOT_MASTER_LOOTER"])
			end
		end,
	}
	order = order + 1
	args.spacerBetweenAutoToggles = ns.OptionsSpacer(order)
	order = order + 1
	args.outsideInstancesRow = ns.OptionsSubRow(order, nil, {
		{
			type = "toggle",
			name = ns.OptionsSubLabel(L["MASTER_LOOTER_AUTO_OUTSIDE"]),
			width = SUB_TOGGLE_WIDTH,
			get = function()
				return ns.db.profile.autoMasterLootOutsideInstances
			end,
			set = function(_, value)
				ns.db.profile.autoMasterLootOutsideInstances = value
			end,
		},
	})
	order = order + 1
	--[[
	    Blue rather than red: nothing here is an error or a risk to your loot,
	    it is a fact about world bosses that makes the option a poor idea.
	]]
	args.outsideInstancesCaution = ns.OptionsSubRow(order, nil, {
		{
			type = "description",
			name = GetColor("INFO") .. L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] .. "|r",
			fontSize = "medium",
			width = "relative",
			relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
		},
	}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
	order = order + 1
	args.spacerBeforeQuestItems = ns.OptionsSpacer(order)
	order = order + 1
	args.questItemsRow = ns.OptionsSubRow(order, nil, {
		{
			type = "toggle",
			name = ns.OptionsSubLabel(L["MASTER_LOOTER_AUTO_QUEST_ITEMS"]),
			desc = L["MASTER_LOOTER_AUTO_QUEST_ITEMS_DESCRIPTION"],
			width = SUB_TOGGLE_WIDTH,
			get = function()
				return ns.db.profile.autoMasterLootQuestItems
			end,
			set = function(_, value)
				ns.db.profile.autoMasterLootQuestItems = value
			end,
		},
	})
	order = order + 1
	--[[
	    Two notes, styled exactly like the caution above them and always on show
	    rather than appearing once the toggle is on. Both answer the question
	    somebody asks BEFORE ticking it — whether their threshold can even reach a
	    quest item, and whether this is the right feature for the group they are
	    in — so hiding them until the answer no longer matters is backwards.
	]]
	args.questItemsNote = ns.OptionsSubRow(order, nil, {
		{
			type = "description",
			name = GetColor("INFO") .. L["MASTER_LOOTER_AUTO_QUEST_ITEMS_NOTE"] .. "|r",
			fontSize = "medium",
			width = "relative",
			relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
		},
	}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
	order = order + 1
	args.spacerBetweenQuestItemNotes = ns.OptionsSpacer(order)
	order = order + 1
	args.questItemsCaution = ns.OptionsSubRow(order, nil, {
		{
			type = "description",
			name = GetColor("INFO") .. L["MASTER_LOOTER_AUTO_QUEST_ITEMS_CAUTION"] .. "|r",
			fontSize = "medium",
			width = "relative",
			relWidth = ns.OPTIONS_SUB_TEXT_REL_WIDTH,
		},
	}, ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH)
	order = order + 1
	args.spacerBeforePopupToggle = ns.OptionsSpacer(order)
	order = order + 1
	--[[
	    Below the sub-options rather than among them: the pop-up is a way in to
	    master-loot setup and runs whether or not anything is automated, so it is
	    a peer of the switch above and neither indents nor greys out with it.
	]]
	order = ns.AddPopupToggleRow(args, order)

	--[[
	    The group's own loot settings, which GogoLoot reads rather than owns —
	    hence a section of their own below the add-on's behaviour rather than
	    above it.
	]]
	args.spacerBeforeCurrentLoot = ns.OptionsSpacer(order)
	order = order + 1
	args.currentLootHeader = ns.OptionsHeader(L["MASTER_LOOTER_CURRENT_LOOT_HEADER"], order)
	order = order + 1
	args.spacerAfterCurrentLootHeader = ns.OptionsSpacer(order)
	order = order + 1
	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = ns.OptionsSpacer(order)
	args.spacerAfterLootType.hidden = ns.IsLootThresholdIrrelevant
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)

	args.spacerBeforeDest = ns.OptionsSpacer(order)
	order = order + 1
	args.destHeader = ns.OptionsHeader(L["MASTER_LOOTER_DESTINATION_HEADER"], order)
	order = order + 1
	args.spacerAfterDestHeader = ns.OptionsSpacer(order)
	order = order + 1
	args.destDesc = ns.OptionsDesc(L["MASTER_LOOTER_DESTINATION_DESCRIPTION"], order)
	order = order + 1
	args.spacerAfterDestDesc = ns.OptionsSpacer(order)
	order = order + 1

	-- Sits above the per-tier rows: set every tier at once, then adjust individually.
	order = ns.AddSendAllDestinationRow(args, order)
	args.spacerAfterSendAll = ns.OptionsSpacer(order)
	order = order + 1

	--[[
	    A sub-option of Send All Loot To rather than a peer: it changes how that
	    one destination is expressed, into five rows or back out of them. Sitting
	    it flush would put its checkbox a couple of pixels right of the label
	    above — the checkbox art is inset inside its own widget — which reads as a
	    near-miss rather than a decision. Indenting it properly makes it one.
	]]
	args.setTiersIndividually = ns.OptionsSubRow(order, nil, {
		{
			type = "toggle",
			name = function()
				--[[
                    The summary rides on the label only while the rows are
                    collapsed. Open, the rows below say it themselves, and a
                    suffix repeating them would be noise. It carries its own
                    leading space and is empty in every state the dropdown above
                    already covers, so the plain label is what most setups read.
                ]]
				if ns.db.global.showDestinationTiers then
					return ns.OptionsSubLabel(L["MASTER_LOOTER_TIERS_INDIVIDUAL"])
				end
				return ns.OptionsSubLabel(L["MASTER_LOOTER_TIERS_INDIVIDUAL"]) .. SummarizeDestinations()
			end,
			desc = L["MASTER_LOOTER_TIERS_INDIVIDUAL_DESCRIPTION"],
			width = SUB_TOGGLE_WIDTH,
			get = function()
				return ns.db.global.showDestinationTiers
			end,
			set = function(_, value)
				ns.db.global.showDestinationTiers = value
			end,
		},
	})
	order = order + 1
	--[[
        Always shown: with the rows collapsed this is the only thing separating
        the toggle from the Ignore List header below.
    ]]
	args.spacerAfterTiersToggle = ns.OptionsSpacer(order)
	order = order + 1

	--[[
        Destination rows — one per quality tier at or above loot threshold,
        drawn only while the toggle above is on. Each row is colored quality
        text on the left with an unlabeled dropdown flowing next to it on the
        same line, the shared label-beside-control shape (ns.OptionsRowLabel);
        all three entries (text, dropdown, trailing spacer) share one hidden
        check so neither a collapsed section nor a tier below the threshold
        strands a blank line.
    ]]
	local destinationRarities = {
		{ quality = 4, key = "epic", label = L["QUALITY_EPIC"] },
		{ quality = 3, key = "rare", label = L["QUALITY_RARE"] },
		{ quality = 2, key = "uncommon", label = L["QUALITY_UNCOMMON"] },
		{ quality = 1, key = "common", label = L["QUALITY_COMMON"] },
		{ quality = 0, key = "poor", label = L["QUALITY_POOR"] },
	}

	for _, entry in ipairs(destinationRarities) do
		local qualityKey = entry.key
		local function HiddenTierRow()
			if not ns.db.global.showDestinationTiers then
				return true
			end
			return entry.quality < ns:SafeGetLootThreshold()
		end

		--[[
            The order passed to the label is a placeholder: ns.OptionsSubRow
            numbers its controls itself, after the indent cell it leads with.
        ]]
		local destinationLabel = ns.OptionsRowLabel(
			GetQualityColor(entry.quality) .. entry.label .. "|r",
			0,
			ns.OptionsSubLabelWidth(TIER_ROW_INDENT)
		)

		args["destRow_" .. qualityKey] = ns.OptionsSubRow(order, HiddenTierRow, {
			destinationLabel,
			{
				type = "select",
				name = "",
				desc = string.format(L["MASTER_LOOTER_DESTINATION_CHOOSE"], entry.label),
				style = "dropdown",
				width = ns.OPTIONS_CONTROL_WIDTH,
				values = function()
					return ns:GetGroupMemberNames()
				end,
				get = function()
					return ns.db.profile.destinations[qualityKey]
				end,
				--[[
                    Announce every change, including switching back to yourself:
                    the group has already been told somebody else is holding this
                    tier, so staying quiet would leave that standing.
                ]]
				set = function(_, value)
					ns.db.profile.destinations[qualityKey] = value
					ns:AnnounceDestinationSet(value, qualityKey)
				end,
			},
		}, TIER_ROW_INDENT)
		order = order + 1
		args["spacer_dest_" .. qualityKey] = {
			type = "description",
			name = " ",
			order = order,
			hidden = HiddenTierRow,
		}
		order = order + 1
	end

	args.ignoreHeader = ns.OptionsHeader(L["MASTER_LOOTER_IGNORE_HEADER"], order)
	order = order + 1
	args.spacerAfterIgnoreHeader = ns.OptionsSpacer(order)
	order = order + 1
	args.ignoreDesc = ns.OptionsDesc(L["MASTER_LOOTER_IGNORE_DESCRIPTION"], order)
	order = order + 1
	args.spacerAfterIgnoreDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.ignoreList = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = ignoreListArgs,
	}

	--[[
	    Applied in one sweep at the end rather than per row: the panel is built
	    from shared row builders the pop-up also calls, so the gate cannot live
	    inside them, and stamping it here means anything added later is covered
	    without having to remember.
	]]
	for key, entry in pairs(args) do
		if not PANEL_ALWAYS_SHOWN[key] then
			HideWhenAutomationOff(entry)
		end
	end

	return {
		type = "group",
		name = L["TAB_MASTER_LOOTER"],
		args = args,
	}
end
