--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Item Overrides
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

local function AutomatedRollsOn()
	return ns.db.profile.autoGreed
end

--[[
    Items with a roll action of their own, which Automated Rolls takes ahead of
    its thresholds. The list answers to its own switch: Automated Rolls being
    off hides nothing here, because a child panel hidden behind its parent's
    switch would open onto a blank page. Nothing on it rolls while Automated
    Rolls is off, though, so a line says so, rather than leaving a checked
    Enable Item Overrides to suggest otherwise.
]]
---@return table
function ns.BuildItemOverridesOptions()
	local listArgs = ns:BuildItemListOptions({
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
		notifyKey = ns.OPTIONS_REGISTRY.ItemOverrides,
		labels = {
			restoreDesc = L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"],
			restoreConfirm = L["ITEM_OVERRIDES_RESTORE_CONFIRM"],
			addDesc = L["ITEM_LIST_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			removeDesc = L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"],
			removeConfirm = L["ITEM_OVERRIDES_REMOVE_CONFIRM"],
		},
		actionColumn = {
			desc = L["ITEM_OVERRIDES_ACTION_DESCRIPTION"],
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

	local args = {
		description = ns.OptionsDesc(L["ITEM_OVERRIDES_DESCRIPTION"], 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	local order = ns.AddFeatureOffNote(args, 3, L["ROLLS_OFF_NOTE"], AutomatedRollsOn)
	args.itemOverridesEnable = {
		type = "toggle",
		name = L["ITEM_OVERRIDES_ENABLE"],
		desc = L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.customRollList
		end,
		set = function(_, value)
			ns.db.profile.customRollList = value
		end,
	}
	-- The list's add line below is a control in its own right, not part of the toggle.
	args.spacerBeforeItemOverrides = ns.OptionsSpacer(order + 1)
	args.itemOverrides = {
		type = "group",
		name = "",
		inline = true,
		order = order + 2,
		args = listArgs,
	}

	return {
		type = "group",
		name = L["TAB_ITEM_OVERRIDES"],
		args = args,
	}
end
