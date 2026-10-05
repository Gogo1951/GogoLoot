--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Toasts: Filters
--------------------------------------------------------------------------------

--[[
    A child panel of Loot Toasts: what gets a toast, for the player's own loot
    and the group's, and what a toast says. A row per item type with a Mine and
    a Group box, then Bag Count and Winning Roll in the same columns. Not
    hidden behind the Loot Toasts switch, which would leave a child panel
    opening onto a blank page; a red line says so while the switch is off.
]]
local _, ns = ...
local L = ns.L

local TOAST_QUALITY_VALUES, TOAST_QUALITY_SORTING = ns.OptionsQualityChoices(0, "+")

--------------------------------------------------------------------------------
-- Filter Rows
--------------------------------------------------------------------------------

--[[
    One row per ns.LOOT_TOAST_FILTER_ROWS entry: its caption, then a Mine box
    and a Group box in two columns of one width (see the Filters widths in
    Data.lua). An item-type row is captioned with the client's own name for the
    type, so it needs no translating; the last three are GogoLoot's own rows,
    captioned in GogoLoot's words but for Money, which is the client's. A
    rarity row puts a quality dropdown beside each box, shown while the box is
    ticked, with a blank cell the same width standing in for it while the box
    is clear, so the Group box never slides left. Those two cells are the one
    place a row's members hide, and only ever one of each pair.
]]
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

-- The last three rows' tooltips, which say what the row gathers rather than name a type.
local OWN_ROW_DESCRIPTIONS = {
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

-- One column's cells, a box and, on a rarity row, its quality dropdown and the blank cell standing in for it.
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
	local cells = { ns.OptionsRowLabel(caption, 0, ns.OPTIONS_FILTER_LABEL_WIDTH) }
	for _, cell in ipairs(FilterColumnCells("Mine", row, caption)) do
		cells[#cells + 1] = cell
	end
	if not row.mineOnly then
		for _, cell in ipairs(FilterColumnCells("Group", row, caption)) do
			cells[#cells + 1] = cell
		end
	end
	return ns.OptionsRow(0, nil, cells)
end

--[[
    The rows in their three groups, a blank line between each: the rarity rows
    in the order Data.lua lists them, then the other item types A to Z by the
    name this client gives them, then GogoLoot's own three. A type this client
    lacks, or an expansion it hasn't reached, gets no row.
]]
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

-- A Filters-grid row about what a toast says: its caption, then a box per side it applies to, each its own setting.
---@param captionKey string
---@param boxes table[] # { side = "Mine" | "Group", setting = string, desc = string }
---@return table
-- The made-up wins the Winning Roll tooltips show, worded as a toast words them.
local EXAMPLE_PLAYER = "Aero"
local EXAMPLE_MINE_ROLL = 54
local EXAMPLE_GROUP_ROLL = 87

local function ToastTextRow(captionKey, boxes)
	local cells = { ns.OptionsRowLabel(L[captionKey], 0, ns.OPTIONS_FILTER_LABEL_WIDTH) }
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
			end,
		}
	end
	return ns.OptionsRow(0, nil, cells)
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

local function LootToastsOn()
	return ns.db.profile.lootToasts
end

---@return table
function ns.BuildLootToastFilterOptions()
	local args = {
		description = ns.OptionsDesc(L["LOOT_TOASTS_FILTERS_CAPTION"], 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	local order = ns.AddFeatureOffNote(args, 3, L["LOOT_TOASTS_OFF_NOTE"], LootToastsOn) - 1
	local function Add(key, entry)
		order = order + 1
		entry.order = order
		args[key] = entry
	end

	-- The rows in their groups, a blank line between each.
	for groupIndex, group in ipairs(FilterRowGroups()) do
		if groupIndex > 1 then
			Add("spacerBeforeFilterGroup" .. groupIndex, ns.OptionsSpacer(0))
		end
		for _, entry in ipairs(group) do
			Add("filterRow_" .. entry.row.key, FilterRow(entry.row, entry.caption))
		end
	end

	--[[
        Two rows about what a toast says rather than which loot gets one, in the
        grid's own columns, so their boxes line up under every other Mine and
        Group box. Bag Count reads the player's own bags, so it has no Group box.
    ]]
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
					EXAMPLE_PLAYER,
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
