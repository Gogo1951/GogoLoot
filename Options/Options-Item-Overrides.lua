--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls: Item Overrides
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    Never hidden behind Automated Rolls (a child panel would open blank); the
    feature-off line says nothing rolls while it is off.
]]
---@return table
function ns.BuildItemOverridesOptions()
	local function ListHidden()
		return not ns.db.profile.customRollList
	end
	-- A hidden list builds no rows: the panel is rebuilt on every refresh, and the switch turning on is one.
	local listArgs = ListHidden() and {}
		or ns:BuildItemListOptions({
			getSourceTable = function()
				return ns.db.profile.ignoredItemsSolo
			end,
			onRestore = function()
				ns.db.profile.ignoredItemsSolo = ns:BuildDefaultIgnoreListSolo()
			end,
			isDefault = function()
				return ns.ItemListsMatch(ns.db.profile.ignoredItemsSolo, ns:BuildDefaultIgnoreListSolo())
			end,
			onAdd = function(itemIdentifier)
				ns.db.profile.ignoredItemsSolo[itemIdentifier] = ns.MANUAL
			end,
			onRemove = function(itemIdentifier)
				ns.db.profile.ignoredItemsSolo[itemIdentifier] = nil
			end,
			notifyKey = ns.OPTIONS_REGISTRY.ItemOverrides,
			refillsWhenEmpty = true,
			labels = {
				restoreDesc = L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"],
				restoreConfirm = L["ITEM_OVERRIDES_RESTORE_CONFIRM"],
				addDesc = L["ITEM_OVERRIDES_ADD_DESCRIPTION"],
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
		description = Kit.Desc(L["ITEM_OVERRIDES_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
	}
	local order = ns.AddFeatureOffLine(args, 3, "autoGreed")
	args.itemOverridesEnable = {
		type = "toggle",
		name = L["ITEM_OVERRIDES_ENABLE"],
		desc = L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"],
		width = "full",
		order = order,
		get = Kit.Get("profile", "customRollList"),
		set = Kit.Set("profile", "customRollList"),
	}
	-- The list's add line below is a control in its own right, not part of the toggle.
	args.spacerBeforeItemOverrides = Kit.Spacer(order + 1, ListHidden)
	args.itemOverrides = {
		type = "group",
		name = "",
		inline = true,
		order = order + 2,
		hidden = ListHidden,
		args = listArgs,
	}

	return {
		type = "group",
		name = L["TAB_ITEM_OVERRIDES"],
		args = args,
	}
end
