--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local GetQualityColor = ns.GetQualityColor
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Shared Rows
--------------------------------------------------------------------------------

--[[
    The loot method, loot threshold, and Send All Loot To rows appear on this
    panel and again in the master looter pop-up (Options-Master-Looter-Popup.lua),
    so each is built once here and added to whichever args table asks for it.
    Every builder takes (args, order) and returns the next free order.
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
    dropdowns are editable for the leader and disabled for everyone else. When
    disabled in a group, the label names who does control them.
]]
local function IsNotLeader()
	return not ns:IsGroupLeader()
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

local function LabelWithLeader(baseKey)
	if not IsNotLeader() then
		return L[baseKey]
	end
	local leaderName = ns:GetGroupLeaderName()
	if leaderName then
		return L[baseKey] .. "  " .. string.format(L["MASTER_LOOTER_SET_BY"], leaderName)
	end
	return L[baseKey]
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootMethodRow(args, order)
	args.lootTypeLabel = ns.OptionsRowLabel(function()
		return LabelWithLeader("MASTER_LOOTER_LOOT_METHOD")
	end, order)
	args.lootType = {
		type = "select",
		name = "",
		style = "dropdown",
		width = ns.OPTIONS_CONTROL_WIDTH,
		values = BuildLootTypeValues,
		order = order + 1,
		disabled = IsNotLeader,
		get = function()
			return ns:SafeGetLootMethod()
		end,
		set = function(_, value)
			ns:SafeSetLootMethod(value)
			ns:RefreshMasterLooterPanels()
		end,
	}
	return order + 2
end

---@param args table
---@param order number
---@return number # the next free order
function ns.AddLootThresholdRow(args, order)
	args.lootThresholdLabel = ns.OptionsRowLabel(function()
		return LabelWithLeader("MASTER_LOOTER_LOOT_THRESHOLD")
	end, order)
	args.lootThresholdLabel.hidden = IsLootThresholdIrrelevant
	args.lootThreshold = {
		hidden = IsLootThresholdIrrelevant,
		type = "select",
		name = "",
		style = "dropdown",
		width = ns.OPTIONS_CONTROL_WIDTH,
		values = BuildThresholdValues,
		order = order + 1,
		disabled = IsNotLeader,
		get = function()
			return ns:SafeGetLootThreshold()
		end,
		set = function(_, value)
			ns:SafeSetLootThreshold(value)
			ns:RefreshMasterLooterPanels()
		end,
	}
	return order + 2
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
	args.sendAllLabel = ns.OptionsRowLabel(L["MASTER_LOOTER_SEND_ALL"], order)
	args.sendAllLabel.hidden = hidden
	args.sendAll = {
		hidden = hidden,
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
		order = order + 1,
		get = function()
			return ns:GetSharedDestination()
		end,
		set = function(_, value)
			ns:SetAllDestinations(value)
			ns:RefreshMasterLooterPanels()
		end,
	}
	return order + 2
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

	-- Warning + its own spacer, shown only while grouped and not the leader.
	local function WarningHidden()
		return (not IsInGroup()) or ns:IsGroupLeader()
	end

	local args = {}
	local order = 1

	args.currentLootDesc = ns.OptionsDesc(L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"], order)
	order = order + 1
	args.spacerAfterCurrentLootDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.leaderWarning = {
		type = "description",
		name = GetColor("OFF") .. L["MASTER_LOOTER_NOT_LEADER_WARNING"] .. "|r",
		fontSize = "medium",
		order = order,
		hidden = WarningHidden,
	}
	order = order + 1
	args.spacerAfterWarning = {
		type = "description",
		name = " ",
		order = order,
		hidden = WarningHidden,
	}
	order = order + 1

	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = ns.OptionsSpacer(order)
	args.spacerAfterLootType.hidden = ns.IsLootThresholdIrrelevant
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerBeforeAuto = ns.OptionsSpacer(order)
	order = order + 1
	args.autoHeader = ns.OptionsHeader(L["MASTER_LOOTER_AUTO_HEADER"], order)
	order = order + 1
	args.spacerAfterAutoHeader = ns.OptionsSpacer(order)
	order = order + 1
	args.autoDesc = ns.OptionsDesc(L["MASTER_LOOTER_AUTO_DESCRIPTION"], order)
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
	args.autoMasterLootOutsideInstances = {
		type = "toggle",
		name = L["MASTER_LOOTER_AUTO_OUTSIDE"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.autoMasterLootOutsideInstances
		end,
		set = function(_, value)
			ns.db.profile.autoMasterLootOutsideInstances = value
		end,
	}
	order = order + 1
	args.outsideInstancesCaution =
		ns.OptionsDesc(GetColor("OFF") .. L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] .. "|r", order)
	order = order + 1
	args.spacerBeforePopupToggle = ns.OptionsSpacer(order)
	order = order + 1
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
		end,
	}
	order = order + 1
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
        Destination rows — one per quality tier at or above loot threshold.
        Each row is colored quality text on the left with an unlabeled dropdown
        flowing next to it on the same line, the shared label-beside-control
        shape (ns.OptionsRowLabel); all three entries (text, dropdown, trailing
        spacer) share one hidden check so a tier below the threshold strands no
        blank line. The last visible tier's spacer also separates the section
        from the Ignore List header, so no extra spacer is needed there.
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
		local function HiddenBelowThreshold()
			return entry.quality < ns:SafeGetLootThreshold()
		end

		local destinationLabel = ns.OptionsRowLabel(GetQualityColor(entry.quality) .. entry.label .. "|r", order)
		destinationLabel.hidden = HiddenBelowThreshold
		args["destLabel_" .. qualityKey] = destinationLabel
		order = order + 1
		args["dest_" .. qualityKey] = {
			type = "select",
			name = "",
			desc = string.format(L["MASTER_LOOTER_DESTINATION_CHOOSE"], entry.label),
			style = "dropdown",
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = function()
				return ns:GetGroupMemberNames()
			end,
			order = order,
			hidden = HiddenBelowThreshold,
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
		}
		order = order + 1
		args["spacer_dest_" .. qualityKey] = {
			type = "description",
			name = " ",
			order = order,
			hidden = HiddenBelowThreshold,
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

	return {
		type = "group",
		name = L["TAB_MASTER_LOOTER"],
		args = args,
	}
end
