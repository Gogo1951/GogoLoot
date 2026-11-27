--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Shared Rows
--------------------------------------------------------------------------------

--[[
    Rows shared with the master looter pop-up, built once so the two can't
    drift. Each takes (args, order) and returns the next free order.
]]

-- Personal Loot is listed only where the client names it, so the dropdown reads it back rather than going blank.
local function BuildLootTypeValues()
	local values = {
		["freeforall"] = LOOT_FREE_FOR_ALL,
		["roundrobin"] = LOOT_ROUND_ROBIN,
		["master"] = LOOT_MASTER_LOOTER,
		["group"] = LOOT_GROUP_LOOT,
		["needbeforegreed"] = LOOT_NEED_BEFORE_GREED,
	}
	if Enum.LootMethod.Personal and LOOT_PERSONAL_LOOT then
		values["personal"] = LOOT_PERSONAL_LOOT
	end
	return values
end

--[[
    TBC and later stop at Uncommon; Classic Era's SetLootThreshold accepts down
    to Poor. Flavor.lua counts WoW Forever as expansion 1, so it gets Era's list.
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

local function IsNotLeader()
	return not ns:IsGroupLeader()
end

-- ns:WillAutoMasterLoot ignores every tuning row while autoMasterLoot is off, so they hide rather than gray.
local function IsAutomationOff()
	return not ns.db.profile.autoMasterLoot
end

-- Composed, not assigned: the master switch adds a reason to hide, never replaces a row's own.
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

-- None of these consults quality, so the threshold row hides; callers hide its paired spacer too.
local THRESHOLDLESS_LOOT_METHODS = {
	freeforall = true,
	roundrobin = true,
	personal = true,
}

local function IsLootThresholdIrrelevant()
	return THRESHOLDLESS_LOOT_METHODS[ns:SafeGetLootMethod()] == true
end

ns.IsLootThresholdIrrelevant = IsLootThresholdIrrelevant

--[[
    Names the leader whoever it is, the player included, so it reads as whose
    group it is rather than as a complaint about a grayed-out control.
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
			return GetColor("HELP") .. string.format(L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"], leaderName) .. "|r"
		end,
		fontSize = "medium",
		order = order,
	}
	args.spacerAfterLeaderNote = Kit.Spacer(order + 1)
	return order + 2
end

-- These answer to no toggle, so they are label-beside-control rows rather than sub-options.
---@param args table
---@param key string
---@param order number
---@param label string
---@param control table # a select; its name and width are set by the kit
---@param hidden? function
---@return number # the next free order
local function AddLabeledRow(args, key, order, label, control, hidden)
	args[key] = Kit.LabelRow(order, hidden, label, control)
	return order + 1
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
			ns.RefreshSettings()
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
			ns.RefreshSettings()
		end,
	}, IsLootThresholdIrrelevant)
end

-- Reads back only when every quality agrees, so a mixed set shows blank rather than one quality's player.
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
			ns.RefreshSettings()
		end,
	}, hidden)
end

-- Also inside the pop-up: the window you'd most want to turn it off from is the one that just opened uninvited.
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
		get = Kit.Get("profile", "masterLooterPopup"),
		set = function(_, value)
			ns.db.profile.masterLooterPopup = value
			ns.RefreshSettings()
		end,
	}
	return order + 1
end

--------------------------------------------------------------------------------
-- Loot Destinations
--------------------------------------------------------------------------------

-- A quality below the loot threshold never passes through master loot, so its row hides.
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
	return not ns:IsQualityReachable(quality)
end

-- A partial setup needs no note: its blank rows say so.
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
		args["destinationRow_" .. qualityKey] = Kit.SubLabelRow(order, HiddenQualityRow, caption, {
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
			-- Every pick is announced, back to yourself included, or the group's last notice would stand.
			set = function(_, value)
				if value == ns.DESTINATION_LOOT_WINDOW then
					ns.db.profile.destinations[qualityKey] = nil
				else
					ns.db.profile.destinations[qualityKey] = value
					ns:AnnounceDestinationSet(value, qualityKey)
				end
				ns.RefreshSettings()
			end,
		})
		order = order + 1
	end
	return order
end

--------------------------------------------------------------------------------
-- Tradable Gear Tint
--------------------------------------------------------------------------------

--[[
    Its own switch, not Automated Master Looting's: the tint works whether or
    not anything is handed out, and sits here because raid leaders need it.
]]
local function IsTradableTintOff()
	return not ns.db.profile.tradableTintEnabled
end

---@param order number
---@return table
local function BuildTradableTintRow(order)
	return Kit.Row(order, nil, {
		{
			type = "toggle",
			width = Kit.LABEL_WIDTH,
			name = L["TRADABLE_TINT_ENABLE"],
			desc = L["TRADABLE_TINT_ENABLE_DESCRIPTION"],
			get = Kit.Get("profile", "tradableTintEnabled"),
			set = function(_, value)
				ns.db.profile.tradableTintEnabled = value
				if ns.RefreshTradableTints then
					ns:RefreshTradableTints()
				end
				ns.RefreshSettings()
			end,
		},
		{
			type = "color",
			width = Kit.CONTROL_WIDTH,
			name = L["TRADABLE_TINT_COLOR"],
			desc = L["TRADABLE_TINT_COLOR_DESCRIPTION"],
			hasAlpha = true,
			hidden = IsTradableTintOff,
			get = function()
				local color = ns.db.profile.tradableTintColor
				return color.r, color.g, color.b, color.a
			end,
			set = function(_, r, g, b, a)
				local color = ns.db.profile.tradableTintColor
				color.r, color.g, color.b, color.a = r, g, b, a
				if ns.RefreshTradableTints then
					ns:RefreshTradableTints()
				end
				ns.RefreshSettings()
			end,
		},
	})
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    Group Loot Settings never hide with the switch: the method and threshold
    are the group's, and the pop-up opens on becoming Master Looter whether
    automation is on or not.
]]
---@return table
function ns.BuildMasterLooterOptions()
	local args = {}
	local order = 1

	args.autoDesc = Kit.Desc(
		L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"]:format(MASTER_LOOTER) .. " " .. L["SAFETY_SKIP_NOTE_MASTER_LOOTER"],
		order
	)
	order = order + 1
	args.spacerAfterAutoDesc = Kit.Spacer(order)
	order = order + 1
	args.autoMasterLoot = ns.FeatureSwitch("autoMasterLoot", order)
	order = order + 1
	args.outsideInstancesRow = Kit.SubToggleRow(order, IsAutomationOff, {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_OUTSIDE"],
		desc = L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"],
		get = Kit.Get("profile", "autoMasterLootOutsideInstances"),
		set = Kit.Set("profile", "autoMasterLootOutsideInstances"),
	})
	order = order + 1
	args.questItemsRow = Kit.SubToggleRow(order, IsAutomationOff, {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_QUEST_ITEMS"],
		desc = L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"],
		get = Kit.Get("profile", "autoMasterLootQuestItems"),
		set = Kit.Set("profile", "autoMasterLootQuestItems"),
	})
	order = order + 1

	args.spacerBeforeDestinations = HideWhenAutomationOff(Kit.Spacer(order))
	order = order + 1
	args.destinationsHeader = Kit.Header(L["TAB_LOOT_DESTINATIONS"], order, IsAutomationOff)
	order = order + 1
	args.spacerAfterDestinationsHeader = HideWhenAutomationOff(Kit.Spacer(order))
	order = order + 1
	args.destinationsDesc = HideWhenAutomationOff(Kit.Desc(L["MASTER_LOOTER_DESTINATION_DESCRIPTION"], order))
	order = order + 1
	args.spacerAfterDestinationsDesc = HideWhenAutomationOff(Kit.Spacer(order))
	order = order + 1
	args.noDestinationNote = {
		type = "description",
		name = GetColor("HELP") .. L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] .. "|r",
		fontSize = "medium",
		order = order,
		hidden = NoDestinationNoteHidden,
	}
	order = order + 1
	args.spacerAfterNoDestinationNote = Kit.Spacer(order, NoDestinationNoteHidden)
	order = order + 1
	order = ns.AddSendAllDestinationRow(args, order, IsAutomationOff)
	-- The quality rows are Send All Loot To's sub-rows, so they sit tight under it.
	order = AddDestinationRows(args, order)

	args.spacerBeforeCurrentLoot = Kit.Spacer(order)
	order = order + 1
	args.currentLootHeader = Kit.Header(L["MASTER_LOOTER_CURRENT_LOOT_HEADER"], order)
	order = order + 1
	args.spacerAfterCurrentLootHeader = Kit.Spacer(order)
	order = order + 1
	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = Kit.Spacer(order, ns.IsLootThresholdIrrelevant)
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerBeforePopupToggle = Kit.Spacer(order)
	order = order + 1
	order = ns.AddPopupToggleRow(args, order)

	args.spacerBeforeTradableTint = Kit.Spacer(order)
	order = order + 1
	args.tradableTintHeader = Kit.Header(L["TRADABLE_TINT_HEADER"], order)
	order = order + 1
	args.spacerAfterTradableTintHeader = Kit.Spacer(order)
	order = order + 1
	args.tradableTintDesc = Kit.Desc(L["TRADABLE_TINT_DESCRIPTION"], order)
	order = order + 1
	args.spacerAfterTradableTintDesc = Kit.Spacer(order)
	order = order + 1
	args.tradableTintRow = BuildTradableTintRow(order)

	return {
		type = "group",
		name = L["TAB_MASTER_LOOTER"],
		args = args,
	}
end
