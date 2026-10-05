--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Shared Rows
--------------------------------------------------------------------------------

--[[
    Rows drawn on the Master Looter panel and again in the master looter pop-up
    (Options-Master-Looter-Popup.lua) are built once here and added to whichever
    args table asks for them: the pop-up toggle, the Enable Automated Master
    Looting switch, the leader note, loot method, loot threshold and Send All
    Loot To. The pop-up's remaining shared row, the
    destination-messages toggle, is built in Options-Announcements.lua, which
    owns that setting. Every builder takes (args, order) and returns the next
    free order.
]]

local function BuildLootTypeValues()
	return {
		["freeforall"] = LOOT_FREE_FOR_ALL,
		["roundrobin"] = LOOT_ROUND_ROBIN,
		["master"] = LOOT_MASTER_LOOTER,
		["group"] = LOOT_GROUP_LOOT,
		["needbeforegreed"] = LOOT_NEED_BEFORE_GREED,
	}
end

--[[
    The loot-threshold floor is client-specific: TBC and later stop at Uncommon
    (green), while Classic Era allows all the way down to Poor (gray), and
    SetLootThreshold accepts those lower values there (confirmed by the
    LootThresholdCommon reference add-on). Flavor.lua counts WoW Forever as
    expansion 1, so Forever offers the Era list too.
]]
local function BuildThresholdValues()
	local values = {
		[4] = GetQualityColor(4) .. ITEM_QUALITY4_DESC .. "|r",
		[3] = GetQualityColor(3) .. ITEM_QUALITY3_DESC .. "|r",
		[2] = GetQualityColor(2) .. ITEM_QUALITY2_DESC .. "|r",
	}
	if ns.EXPANSION >= 2 then
		return values
	end
	values[1] = GetQualityColor(1) .. ITEM_QUALITY1_DESC .. "|r"
	values[0] = GetQualityColor(0) .. ITEM_QUALITY0_DESC .. "|r"
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
    nothing that tunes the automation changes anything until it is on. That is
    why those rows hide rather than grey — a control that is never drawn has no
    use for a disabled state.
]]
local function IsAutomationOff()
	return not ns.db.profile.autoMasterLoot
end

--[[
    Composed rather than assigned: some rows already answer to something else —
    a quality row below the loot threshold — and the master switch has to be an
    additional reason to hide, never a replacement for theirs.
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
    about a control being greyed out. Solo, where there is no leader to name, a
    silver line says why both are greyed out and how to change them.
]]
---@param args table
---@param order number
---@return number # the next free order
function ns.AddLeaderNoteRow(args, order)
	args.leaderNote = {
		type = "description",
		name = function()
			local leaderName = ns:GetGroupLeaderName()
			if not leaderName then
				return GetColor("HELP") .. L["MASTER_LOOTER_SOLO_NOTE"] .. "|r"
			end
			return GetColor("INFO") .. string.format(L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"], leaderName) .. "|r"
		end,
		fontSize = "medium",
		order = order,
	}
	args.spacerAfterLeaderNote = ns.OptionsSpacer(order + 1)
	return order + 2
end

--[[
    Loot method, loot threshold and Send All Loot To answer to no toggle, so they
    are label-beside-control rows rather than sub-options: the label cell, then
    the dropdown with no name of its own, ordered straight after it so the two
    flow onto one line at one row's width. The label is `key .. "Label"`. Neither
    half may hide without the other, so a hidden check goes on both.
]]
---@param args table
---@param key string
---@param order number
---@param label string
---@param control table # a select; its name, width and order are set here
---@param hidden? function
---@return number # the next free order
local function AddLabeledRow(args, key, order, label, control, hidden)
	local labelCell = ns.OptionsRowLabel(label, order)
	labelCell.hidden = hidden
	control.name = ""
	control.width = ns.OPTIONS_CONTROL_WIDTH
	control.order = order + 1
	control.hidden = hidden
	args[key .. "Label"] = labelCell
	args[key] = control
	return order + 2
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootMethodRow(args, order)
	return AddLabeledRow(args, "lootMethod", order, LOOT_METHOD, {
		type = "select",
		desc = L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"],
		style = "dropdown",
		values = BuildLootTypeValues,
		disabled = IsNotLeader,
		get = function()
			return ns:SafeGetLootMethod()
		end,
		set = function(_, value)
			ns:SafeSetLootMethod(value)
			ns:RefreshMasterLooterPanels()
		end,
	})
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootThresholdRow(args, order)
	return AddLabeledRow(args, "lootThreshold", order, LOOT_THRESHOLD, {
		type = "select",
		desc = L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"],
		style = "dropdown",
		values = BuildThresholdValues,
		disabled = IsNotLeader,
		get = function()
			return ns:SafeGetLootThreshold()
		end,
		set = function(_, value)
			ns:SafeSetLootThreshold(value)
			ns:RefreshMasterLooterPanels()
		end,
	}, IsLootThresholdIrrelevant)
end

--[[
    Sets every quality at once. It reads back as the shared destination only
    when all qualities already agree, so a mixed set of per-quality choices shows
    blank rather than misreporting one quality's player as the answer for all.
]]
---@param args table
---@param order number
---@param hidden? function # hides both the label and the dropdown when it returns true
---@return number # the next free order
function ns.AddSendAllDestinationRow(args, order, hidden)
	return AddLabeledRow(args, "sendAll", order, L["MASTER_LOOTER_SEND_ALL"], {
		type = "select",
		desc = L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"],
		style = "dropdown",
		values = function()
			return ns:GetGroupMemberNames()
		end,
		sorting = function()
			return ns:GetGroupMemberSorting()
		end,
		get = function()
			return ns:GetSharedDestinationChoice()
		end,
		set = function(_, value)
			ns:SetAllDestinations(value)
			ns:RefreshMasterLooterPanels()
		end,
	}, hidden)
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
		desc = L["MASTER_LOOTER_POPUP_TOOLTIP"]:format(MASTER_LOOTER),
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
    Enable Automated Master Looting, drawn on this panel and again in the
    Features section of the General panel. Built once here so the two can never
    drift; each caller sets its own order and width.
]]
---@return table
function ns.AutomatedMasterLootingSwitch()
	return {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_ENABLE"],
		desc = L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"],
		get = function()
			return ns.db.profile.autoMasterLoot
		end,
		set = function(_, value)
			ns.db.profile.autoMasterLoot = value
			if value and not ns:AreWeMasterLooter() then
				ns:PrintMessage(L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"]:format(MASTER_LOOTER))
			end
			ns:RefreshMasterLooterPanels()
		end,
	}
end

--------------------------------------------------------------------------------
-- Loot Destinations
--------------------------------------------------------------------------------

--[[
    One row per quality the loot threshold lets master loot reach, Epic down,
    each captioned in its own quality's color: the player picks who receives
    that quality. Qualities below the threshold never pass through master loot,
    so their rows are hidden rather than left showing a choice that does
    nothing.
]]
local DESTINATION_QUALITIES = {
	{ quality = 4, key = "epic", label = ITEM_QUALITY4_DESC },
	{ quality = 3, key = "rare", label = ITEM_QUALITY3_DESC },
	{ quality = 2, key = "uncommon", label = ITEM_QUALITY2_DESC },
	{ quality = 1, key = "common", label = ITEM_QUALITY1_DESC },
	{ quality = 0, key = "poor", label = ITEM_QUALITY0_DESC },
}

---@param quality number
---@return boolean
local function IsBelowLootThreshold(quality)
	return quality < ns:SafeGetLootThreshold()
end

--[[
    True while no quality the threshold reaches has anybody picked: then
    automation hands nothing out, and every drop waits in the loot window. A
    partial setup reads fine without a line, since its blank rows say so.
]]
local function NoDestinationPicked()
	for _, entry in ipairs(DESTINATION_QUALITIES) do
		local destination = ns.db.profile.destinations[entry.key]
		if not IsBelowLootThreshold(entry.quality) and destination and destination ~= "" then
			return false
		end
	end
	return true
end

local function NoDestinationNoteHidden()
	return IsAutomationOff() or not NoDestinationPicked()
end

---@param args table
---@param order number
---@return number # the next free order
local function AddDestinationRows(args, order)
	for _, entry in ipairs(DESTINATION_QUALITIES) do
		local qualityKey = entry.key
		local function HiddenQualityRow()
			return IsAutomationOff() or IsBelowLootThreshold(entry.quality)
		end

		local caption = GetQualityColor(entry.quality) .. entry.label .. "|r"
		args["destinationRow_" .. qualityKey] = ns.OptionsSubSelectRow(order, HiddenQualityRow, caption, {
			type = "select",
			desc = string.format(L["MASTER_LOOTER_DESTINATION_CHOOSE"], entry.label),
			style = "dropdown",
			values = function()
				return ns:GetGroupMemberNames()
			end,
			sorting = function()
				return ns:GetGroupMemberSorting()
			end,
			get = function()
				return ns:GetDestinationChoice(qualityKey)
			end,
			--[[
                Announce every pick, including switching back to yourself: the
                group has already been told somebody else is holding this
                quality, so staying quiet would leave that standing. Loot Window
                clears the quality and says nothing, the way Send All Loot To
                does.
            ]]
			set = function(_, value)
				if value == ns.DESTINATION_LOOT_WINDOW then
					ns.db.profile.destinations[qualityKey] = nil
				else
					ns.db.profile.destinations[qualityKey] = value
					ns:AnnounceDestinationSet(value, qualityKey)
				end
				ns:RefreshMasterLooterPanels()
			end,
		})
		order = order + 1
		args["spacer_destination_" .. qualityKey] = ns.OptionsSpacer(order, HiddenQualityRow)
		order = order + 1
	end
	return order
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    Automated Master Looting opens the panel with its switch and the two on/off
    choices under it, then Loot Destinations, who receives each quality: without
    destinations the automation hands nothing out, so they sit beside the
    switch rather than a page away. Both leave while the switch is off.

    Group Loot Settings closes the panel and stays whatever the switch says.
    The loot method and threshold are the group's, which GogoLoot reads rather
    than owns, and the pop-up opens whenever the player becomes Master Looter,
    automation or not, so its switch sits with the settings it shows.
]]
---@return table
function ns.BuildMasterLooterOptions()
	local args = {}
	local order = 1

	args.autoDesc = ns.OptionsDesc(
		L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"]:format(MASTER_LOOTER) .. " " .. L["SAFETY_SKIP_NOTE_MASTER_LOOTER"],
		order
	)
	order = order + 1
	args.spacerAfterAutoDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.autoMasterLoot = ns.AutomatedMasterLootingSwitch()
	args.autoMasterLoot.width = "full"
	args.autoMasterLoot.order = order
	order = order + 1
	args.outsideInstancesRow = ns.OptionsSubToggleRow(order, IsAutomationOff, {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_OUTSIDE"],
		desc = L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"],
		get = function()
			return ns.db.profile.autoMasterLootOutsideInstances
		end,
		set = function(_, value)
			ns.db.profile.autoMasterLootOutsideInstances = value
		end,
	})
	order = order + 1
	args.questItemsRow = ns.OptionsSubToggleRow(order, IsAutomationOff, {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_QUEST_ITEMS"],
		desc = L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"],
		get = function()
			return ns.db.profile.autoMasterLootQuestItems
		end,
		set = function(_, value)
			ns.db.profile.autoMasterLootQuestItems = value
		end,
	})
	order = order + 1

	-- Loot Destinations
	args.spacerBeforeDestinations = HideWhenAutomationOff(ns.OptionsSpacer(order))
	order = order + 1
	args.destinationsHeader = ns.OptionsHeader(L["TAB_LOOT_DESTINATIONS"], order, IsAutomationOff)
	order = order + 1
	args.spacerAfterDestinationsHeader = HideWhenAutomationOff(ns.OptionsSpacer(order))
	order = order + 1
	args.destinationsDesc = HideWhenAutomationOff(ns.OptionsDesc(L["MASTER_LOOTER_DESTINATION_DESCRIPTION"], order))
	order = order + 1
	args.spacerAfterDestinationsDesc = HideWhenAutomationOff(ns.OptionsSpacer(order))
	order = order + 1
	args.noDestinationNote = {
		type = "description",
		name = GetColor("HELP") .. L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] .. "|r",
		fontSize = "medium",
		order = order,
		hidden = NoDestinationNoteHidden,
	}
	order = order + 1
	args.spacerAfterNoDestinationNote = ns.OptionsSpacer(order, NoDestinationNoteHidden)
	order = order + 1
	order = ns.AddSendAllDestinationRow(args, order, IsAutomationOff)
	args.spacerAfterSendAll = HideWhenAutomationOff(ns.OptionsSpacer(order))
	order = order + 1
	order = AddDestinationRows(args, order)

	-- Group Loot Settings
	args.spacerBeforeCurrentLoot = ns.OptionsSpacer(order)
	order = order + 1
	args.currentLootHeader = ns.OptionsHeader(L["MASTER_LOOTER_CURRENT_LOOT_HEADER"], order)
	order = order + 1
	args.spacerAfterCurrentLootHeader = ns.OptionsSpacer(order)
	order = order + 1
	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = ns.OptionsSpacer(order, ns.IsLootThresholdIrrelevant)
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerBeforePopupToggle = ns.OptionsSpacer(order)
	order = order + 1
	ns.AddPopupToggleRow(args, order)

	return {
		type = "group",
		name = L["TAB_MASTER_LOOTER"],
		args = args,
	}
end
