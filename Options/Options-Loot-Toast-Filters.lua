--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Toasts: Filters
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local TOAST_QUALITY_VALUES, TOAST_QUALITY_SORTING = ns.OptionsQualityChoices(0, "+")

--------------------------------------------------------------------------------
-- Filter Rows
--------------------------------------------------------------------------------

-- An item-type row takes the client's own name for the type, so it needs no translating.
---@param row table
---@return string|nil # nil when this client has no such type
local function FilterRowCaption(row)
	if row.label then
		return row.label
	end
	if row.labelKey then
		return L[row.labelKey]
	end
	if row.subclassIdentifier then
		return C_Item.GetItemSubClassInfo(row.classIdentifier, row.subclassIdentifier)
	end
	return C_Item.GetItemClassInfo(row.classIdentifier)
end

local FILTER_DESCRIPTIONS = {
	Mine = {
		plain = "LOOT_TOASTS_FILTER_MINE_DESCRIPTION",
		rarity = "LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION",
		quality = "LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION",
	},
	Group = {
		plain = "LOOT_TOASTS_FILTER_GROUP_DESCRIPTION",
		rarity = "LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION",
		quality = "LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION",
	},
}

--[[
    Tooltips saying what a row gathers. Container is the bag class, not the
    clams and crates the rest of GogoLoot calls containers (those are Openables).
]]
local OWN_ROW_DESCRIPTIONS = {
	CONTAINER = {
		Mine = "LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION",
		Group = "LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION",
	},
	BIND_ON_PICKUP = {
		Mine = "LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION",
		Group = "LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION",
	},
	OPENABLES = {
		Mine = "LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION",
		Group = "LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION",
	},
	MONEY = { Mine = "LOOT_TOASTS_FILTER_MONEY_DESCRIPTION" },
}

--[[
    On a rarity row, a blank cell stands in for the quality dropdown while the
    box is clear, so the Group box never slides left.
]]
---@param side string # "Mine" or "Group"
---@param row table
---@param caption string
---@return table[]
local function FilterColumnCells(side, row, caption)
	local shown = "lootToast" .. side
	local qualities = "lootToast" .. side .. "Quality"
	local descriptions = FILTER_DESCRIPTIONS[side]
	local description
	if OWN_ROW_DESCRIPTIONS[row.key] then
		description = L[OWN_ROW_DESCRIPTIONS[row.key][side]]
	else
		description = L[row.rarity and descriptions.rarity or descriptions.plain]:format(caption)
	end
	local function IsTicked()
		return ns.db.profile[shown][row.key] == true
	end

	local cells = {
		{
			type = "toggle",
			name = L[side == "Mine" and "LOOT_TOASTS_FILTER_MINE" or "LOOT_TOASTS_FILTER_GROUP"],
			desc = description,
			width = row.rarity and ns.OPTIONS_FILTER_BOX_WIDTH or ns.OPTIONS_FILTER_COLUMN_WIDTH,
			get = IsTicked,
			set = function(_, value)
				ns.db.profile[shown][row.key] = value
				if side == "Mine" and row.rarity then
					ns.RefreshLootToastSamples()
				end
				ns.RefreshSettings()
			end,
		},
	}
	if row.rarity then
		cells[#cells + 1] = {
			type = "select",
			name = "",
			desc = L[descriptions.quality]:format(caption),
			values = TOAST_QUALITY_VALUES,
			sorting = TOAST_QUALITY_SORTING,
			width = ns.OPTIONS_FILTER_QUALITY_WIDTH,
			hidden = function()
				return not IsTicked()
			end,
			get = function()
				return ns.db.profile[qualities][row.key]
			end,
			set = function(_, value)
				ns.db.profile[qualities][row.key] = value
				if side == "Mine" then
					ns.RefreshLootToastSamples()
				end
				ns.RefreshSettings()
			end,
		}
		cells[#cells + 1] = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_FILTER_QUALITY_WIDTH,
			hidden = IsTicked,
		}
	end
	return cells
end

---@param row table
---@param caption string
---@return table
local function FilterRow(row, caption)
	local cells = { Kit.Label(caption, 0, ns.OPTIONS_FILTER_LABEL_WIDTH) }
	for _, cell in ipairs(FilterColumnCells("Mine", row, caption)) do
		cells[#cells + 1] = cell
	end
	if not row.mineOnly then
		for _, cell in ipairs(FilterColumnCells("Group", row, caption)) do
			cells[#cells + 1] = cell
		end
	end
	return Kit.Row(0, nil, cells)
end

-- Rarity rows in data order, other types A to Z by client name, then GogoLoot's own rows.
---@return table[] # { { row = table, caption = string }, ... } per group
local function FilterRowGroups()
	local rarity, types, own = {}, {}, {}
	for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
		local caption = FilterRowCaption(row)
		if caption and caption ~= "" and (row.minimumExpansion or 0) <= ns.EXPANSION then
			local entry = { row = row, caption = caption }
			if row.label or row.labelKey then
				own[#own + 1] = entry
			elseif row.rarity then
				rarity[#rarity + 1] = entry
			else
				types[#types + 1] = entry
			end
		end
	end
	table.sort(types, function(a, b)
		return a.caption < b.caption
	end)
	return { rarity, types, own }
end

-- The made-up wins the Winning Roll tooltips show.
local EXAMPLE_PLAYER_CLASS = "DRUID"
local EXAMPLE_MINE_ROLL = 54
local EXAMPLE_GROUP_ROLL = 87

---@param captionKey string
---@param boxes table[] # { side = "Mine" | "Group", setting = string, desc = string, descText? = string }
---@return table
local function ToastTextRow(captionKey, boxes)
	local cells = { Kit.Label(L[captionKey], 0, ns.OPTIONS_FILTER_LABEL_WIDTH) }
	for _, box in ipairs(boxes) do
		cells[#cells + 1] = {
			type = "toggle",
			name = L[box.side == "Mine" and "LOOT_TOASTS_FILTER_MINE" or "LOOT_TOASTS_FILTER_GROUP"],
			desc = box.descText or L[box.desc],
			width = ns.OPTIONS_FILTER_COLUMN_WIDTH,
			get = function()
				return ns.db.profile[box.setting]
			end,
			set = function(_, value)
				ns.db.profile[box.setting] = value
				ns.RefreshSettings()
			end,
		}
	end
	return Kit.Row(0, nil, cells)
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootToastFilterOptions()
	local args = {
		description = Kit.Desc(L["LOOT_TOASTS_FILTERS_CAPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
	}
	local order = ns.AddFeatureOffLine(args, 3, "lootToasts") - 1
	local function Add(key, entry)
		order = order + 1
		entry.order = order
		args[key] = entry
	end

	for groupIndex, group in ipairs(FilterRowGroups()) do
		if groupIndex > 1 then
			Add("spacerBeforeFilterGroup" .. groupIndex, Kit.Spacer(0))
		end
		for _, entry in ipairs(group) do
			Add("filterRow_" .. entry.row.key, FilterRow(entry.row, entry.caption))
		end
	end

	-- Bag Count reads the player's own bags, so it has no Group box.
	Add(
		"filterRow_BAG_COUNT",
		ToastTextRow("LOOT_TOASTS_FILTER_BAG_COUNT", {
			{ side = "Mine", setting = "lootToastBagCount", desc = "LOOT_TOASTS_BAG_COUNT_DESCRIPTION" },
		})
	)
	Add(
		"filterRow_WINNING_ROLL",
		ToastTextRow("LOOT_TOASTS_WINNING_ROLL", {
			{
				side = "Mine",
				setting = "lootToastWinningRollMine",
				descText = L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"]:format(
					L["LOOT_TOASTS_ROLL_RESULT"]:format(GREED, EXAMPLE_MINE_ROLL)
				),
			},
			{
				side = "Group",
				setting = "lootToastWinningRollGroup",
				descText = L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"]:format(
					ns.GetClassColor(EXAMPLE_PLAYER_CLASS) .. ns.SAMPLE_NAMES[EXAMPLE_PLAYER_CLASS] .. "|r",
					L["LOOT_TOASTS_ROLL_RESULT"]:format(NEED, EXAMPLE_GROUP_ROLL)
				),
			},
		})
	)

	return {
		type = "group",
		name = L["TAB_LOOT_TOAST_FILTERS"],
		args = args,
	}
end
