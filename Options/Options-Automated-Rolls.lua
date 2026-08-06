--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local GetQualityColor = ns.GetQualityColor

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    autoGreed is the master switch for every automated roll — the Custom Roll
    List included — so with it off nothing below it on this panel changes
    anything. The whole rest of the panel therefore hides rather than sitting
    there inert: a player who has turned the feature off is not choosing a
    threshold or curating a list, and greying out a page of controls says the
    same thing at far greater length.
]]
local function RollsOff()
	return not ns.db.profile.autoGreed
end

---@param entry table
---@return table # the same entry, hidden while the master switch is off
local function HideWhenRollsOff(entry)
	entry.hidden = RollsOff
	return entry
end

---@return table
function ns.BuildAutomatedRollOptions()
	local rollThresholdValues = {
		[0] = GetQualityColor(0) .. L["THRESHOLD_POOR_ONLY"] .. "|r",
		[1] = GetQualityColor(1) .. L["THRESHOLD_COMMON_LOWER"] .. "|r",
		[2] = GetQualityColor(2) .. L["THRESHOLD_UNCOMMON_LOWER"] .. "|r",
		[3] = GetQualityColor(3) .. L["THRESHOLD_RARE_LOWER"] .. "|r",
		[4] = GetQualityColor(4) .. L["THRESHOLD_EPIC_LOWER"] .. "|r",
	}

	local customListArgs = ns:BuildItemListOptions({
		getSourceTable = function()
			return ns.db.profile.ignoredItemsSolo
		end,
		onRestore = function()
			ns.db.profile.ignoredItemsSolo = ns:BuildDefaultIgnoreListSolo()
		end,
		onAdd = function(itemIdentifier)
			ns.db.profile.ignoredItemsSolo[itemIdentifier] = ns.MANUAL
		end,
		onRemove = function(itemIdentifier)
			ns.db.profile.ignoredItemsSolo[itemIdentifier] = nil
		end,
		notifyKey = ns.OPTIONS_REGISTRY.AutomatedRolls,
		labels = {
			restore = L["ROLLS_RESTORE_DEFAULTS"],
			restoreConfirm = L["ROLLS_RESTORE_CONFIRM"],
			addDesc = L["ITEM_LIST_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			removeDesc = L["ROLLS_REMOVE_DESCRIPTION"],
		},
		actionColumn = {
			desc = L["ROLLS_CHOOSE_ACTION"],
			values = ns.ROLL_OVERRIDE_LABELS,
			sorting = ns.ROLL_OVERRIDE_ORDER,
			get = function(itemIdentifier)
				return ns.db.profile.ignoredItemsSolo[itemIdentifier]
			end,
			set = function(itemIdentifier, value)
				ns.db.profile.ignoredItemsSolo[itemIdentifier] = value
			end,
		},
	})

	local args = {}
	local order = 1

	args.description = ns.OptionsDesc(L["ROLLS_DESCRIPTION"] .. " " .. L["SAFETY_SKIP_NOTE"], order)
	order = order + 1
	args.spacerAfterDesc = ns.OptionsSpacer(order)
	order = order + 1
	args.autoGreed = {
		type = "toggle",
		name = L["ROLLS_ENABLE"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.autoGreed
		end,
		set = function(_, value)
			ns.db.profile.autoGreed = value
			if ns.UpdateMinimapIcon then
				ns:UpdateMinimapIcon()
			end
		end,
	}
	order = order + 1
	args.spacerAfterToggle = ns.OptionsSpacer(order)
	order = order + 1
	args.thresholdHeader = ns.OptionsHeader(L["ROLLS_THRESHOLD_HEADER"], order, RollsOff)
	order = order + 1
	args.spacerAfterThresholdHeader = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.thresholdDesc = HideWhenRollsOff(ns.OptionsDesc(L["ROLLS_THRESHOLD_DESCRIPTION"], order))
	order = order + 1
	args.spacerAfterThresholdDesc = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1

	--[[
        One row per group context — the label, the quality ceiling, and the
        action taken at or below it — flowing onto a single line, the same
        label-plus-dropdown idiom the Master Looter destination rows use. The
        row's trailing spacer separates it from the next; the last one also
        separates the section from the Custom Roll List header.

        This is the one row carrying two controls, so it sets its own column
        widths rather than taking ns.OPTIONS_LABEL_WIDTH / OPTIONS_CONTROL_WIDTH
        — but they still total ns.OPTIONS_ROW_WIDTH, and the action dropdown
        takes the same width the Custom Roll List column does, so the two stacks
        of Greed/Need/Pass dropdowns read as one column rather than two sizes.

        Setting a row's action to Manual turns automation off for that context
        alone, so Automated Rolls can run in raids but not parties (or the
        reverse) without touching the master toggle above.
    ]]
	local rollContexts = {
		{ configurationSuffix = "Party", label = L["ROLLS_IN_PARTY"] },
		{ configurationSuffix = "Raid", label = L["ROLLS_IN_RAID"] },
	}

	for _, entry in ipairs(rollContexts) do
		local thresholdKey = "autoRollThreshold" .. entry.configurationSuffix
		local actionKey = "autoRollAction" .. entry.configurationSuffix

		args["rollLabel_" .. thresholdKey] = {
			type = "description",
			name = entry.label,
			fontSize = "medium",
			width = 0.7,
			order = order,
			hidden = RollsOff,
		}
		order = order + 1
		args[thresholdKey] = {
			type = "select",
			name = "",
			desc = string.format(L["ROLLS_THRESHOLD_CHOOSE"], entry.label),
			style = "dropdown",
			width = 1.2,
			values = rollThresholdValues,
			order = order,
			hidden = RollsOff,
			get = function()
				return ns.db.profile[thresholdKey]
			end,
			set = function(_, value)
				ns.db.profile[thresholdKey] = value
			end,
		}
		order = order + 1
		args[actionKey] = {
			type = "select",
			name = "",
			desc = string.format(L["ROLLS_ACTION_CHOOSE"], entry.label),
			style = "dropdown",
			width = ns.ROLL_ACTION_DROPDOWN_WIDTH,
			values = ns.ROLL_OVERRIDE_LABELS,
			sorting = ns.ROLL_OVERRIDE_ORDER,
			order = order,
			hidden = RollsOff,
			get = function()
				return ns.db.profile[actionKey]
			end,
			set = function(_, value)
				ns.db.profile[actionKey] = value
			end,
		}
		order = order + 1
		args["spacerAfter_" .. thresholdKey] = HideWhenRollsOff(ns.OptionsSpacer(order))
		order = order + 1
	end

	args.customListHeader = ns.OptionsHeader(L["ROLLS_CUSTOM_LIST"], order, RollsOff)
	order = order + 1
	args.spacerAfterCustomHeader = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.customListDesc = HideWhenRollsOff(ns.OptionsDesc(L["ROLLS_CUSTOM_LIST_DESCRIPTION"], order))
	order = order + 1
	args.spacerAfterCustomDesc = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.customListEnable = {
		type = "toggle",
		name = L["ROLLS_CUSTOM_LIST_ENABLE"],
		width = "full",
		order = order,
		hidden = RollsOff,
		get = function()
			return ns.db.profile.customRollList
		end,
		set = function(_, value)
			ns.db.profile.customRollList = value
		end,
	}
	order = order + 1
	-- The button below is a control in its own right, not part of the toggle.
	args.spacerBeforeCustomList = HideWhenRollsOff(ns.OptionsSpacer(order))
	order = order + 1
	args.customList = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = RollsOff,
		args = customListArgs,
	}

	return {
		type = "group",
		name = L["TAB_AUTOMATED_ROLLS"],
		args = args,
	}
end
