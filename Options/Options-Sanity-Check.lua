--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Roll Sanity Check
--------------------------------------------------------------------------------

--[[
    The panel after Roll Macro: ten drops for each of Trash, Dungeon Bosses
    and Raid Bosses, drawn at random from that section's list
    (ns.SANITY_CHECK_TRASH, _DUNGEON_BOSSES, _RAID_BOSSES in the flavor's
    Character-Rule-Gear-Types file), and what Automated Rolls would do with
    each for the character being played, straight from the ns.DecideRoll a
    real roll takes, so every row follows the settings as they change. Every
    draw holds at least two greens and two blues, and Trash and Raid Bosses
    two Bind on Equip epics as well. Trash and Dungeon Bosses read the In
    Party settings, Raid Bosses In Raid. Pick New Drops draws another ten for
    each; a draw lasts until then or a reload.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local DROPS_PER_SECTION = 10

-- minimum: how many of each kind (the second field of a list's rows) every draw holds.
local SECTIONS = {
	{
		key = "TRASH",
		title = "SANITY_CHECK_TRASH",
		pool = "SANITY_CHECK_TRASH",
		inRaid = false,
		minimum = { UNCOMMON = 2, RARE = 2, EPIC_BOE = 2 },
	},
	{
		key = "DUNGEON_BOSSES",
		title = "SANITY_CHECK_DUNGEON_BOSSES",
		pool = "SANITY_CHECK_DUNGEON_BOSSES",
		inRaid = false,
		minimum = { UNCOMMON = 2, RARE = 2 },
	},
	{
		key = "RAID_BOSSES",
		title = "SANITY_CHECK_RAID_BOSSES",
		pool = "SANITY_CHECK_RAID_BOSSES",
		inRaid = true,
		minimum = { UNCOMMON = 2, RARE = 2, EPIC_BOE = 2 },
	},
}

-- The kinds a minimum names, in the order a draw fills them.
local KIND_ORDER = { "UNCOMMON", "RARE", "EPIC_BOE" }

--------------------------------------------------------------------------------
-- Drawing Drops
--------------------------------------------------------------------------------

-- [section key] = { itemId, ... }, the current draw; nil until the panel first builds.
local drawn = nil
-- Every drawn item as a set, watched for this panel (Options-Utilities-Item-Cache.lua).
local watched = {}

-- Takes one of candidates at random, removing it, or nil once none are left.
---@param candidates number[]
---@return number|nil
local function TakeAtRandom(candidates)
	if #candidates == 0 then
		return nil
	end
	return table.remove(candidates, math.random(#candidates))
end

--[[
    Up to count items from a { { itemId, kind }, ... } list at random, never
    the same one twice and never one this client lacks: first each kind's
    minimum, then the rest from whatever is left, shuffled together so the
    kinds don't come in blocks.
]]
---@param list table[]
---@param count number
---@param minimum table<string, number>
---@return number[]
local function DrawFrom(list, count, minimum)
	local byKind, everything = {}, {}
	for _, row in ipairs(list or {}) do
		local itemIdentifier, kind = row[1], row[2]
		if ns.IsItemOnClient(itemIdentifier) then
			byKind[kind] = byKind[kind] or {}
			table.insert(byKind[kind], itemIdentifier)
		end
	end
	local picks = {}
	for _, kind in ipairs(KIND_ORDER) do
		for _ = 1, math.min(minimum[kind] or 0, count - #picks) do
			picks[#picks + 1] = TakeAtRandom(byKind[kind] or {})
		end
	end
	for _, items in pairs(byKind) do
		for _, itemIdentifier in ipairs(items) do
			everything[#everything + 1] = itemIdentifier
		end
	end
	-- pairs walks the kinds in no fixed order; sorting first keeps a draw reproducible under a seeded math.random.
	table.sort(everything)
	while #picks < count do
		local itemIdentifier = TakeAtRandom(everything)
		if not itemIdentifier then
			break
		end
		picks[#picks + 1] = itemIdentifier
	end
	for index = #picks, 2, -1 do
		local other = math.random(index)
		picks[index], picks[other] = picks[other], picks[index]
	end
	return picks
end

--[[
    A fresh ten for every section. The panel watches what was drawn, so a
    link still loading when the panel opens fills in on its own.
]]
---@return nil
function ns.DrawSanityCheckDrops()
	drawn = {}
	for itemIdentifier in pairs(watched) do
		watched[itemIdentifier] = nil
	end
	local outstanding = false
	for _, section in ipairs(SECTIONS) do
		local picks = DrawFrom(ns[section.pool], DROPS_PER_SECTION, section.minimum)
		drawn[section.key] = picks
		for _, itemIdentifier in ipairs(picks) do
			watched[itemIdentifier] = true
			if ns.IsItemOutstanding(itemIdentifier) then
				outstanding = true
			end
		end
	end
	ns.WatchItemList(ns.OPTIONS_REGISTRY.SanityCheck, function()
		return watched
	end)
	if outstanding then
		ns.EnsureItemRefreshWatcher()
	end
end

--------------------------------------------------------------------------------
-- Outcomes
--------------------------------------------------------------------------------

-- The binding's short name, by C_Item's bindType; nil for an item that doesn't bind.
local BIND_LABELS = {
	[ns.BIND_ON_PICKUP] = "SANITY_CHECK_BOP",
	[ns.BIND_ON_EQUIP] = "SANITY_CHECK_BOE",
}

--[[
    A drop's tag line: its binding, then the stats Character Overrides reads
    on it, by the game's own names ("BoE, Strength, Stamina"). Blank while the
    item loads.
]]
---@param itemIdentifier number
---@return string
local function TagLine(itemIdentifier)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	local itemInformation = itemLink and ns:SafeGetItemInfo(itemIdentifier)
	if not itemInformation then
		return ""
	end
	local parts = {}
	local bind = BIND_LABELS[itemInformation.bindType]
	if bind then
		parts[1] = L[bind]
	end
	local found = ns.ReadCharacterRuleStats(itemLink)
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if found[stat.key] then
			parts[#parts + 1] = stat.label
		end
	end
	return ns.GetColor("HELP") .. table.concat(parts, ", ") .. "|r"
end

-- Why a drop goes the way it does, by ns.DecideRoll's reason: a SANITY_CHECK_ string or the page that decided it.
local REASONS = {
	OFF = "SANITY_CHECK_ROLLS_OFF",
	NEVER = "SANITY_CHECK_NEVER",
	OVERRIDE = "TAB_ITEM_OVERRIDES",
	QUEST = "SANITY_CHECK_QUEST",
	LOW_LEVEL = "SANITY_CHECK_LOW_LEVEL",
	WANTED = "TAB_CHARACTER_RULES",
	EVERYTHING_ELSE = "TAB_CHARACTER_RULES",
	BIND_ON_PICKUP = "SANITY_CHECK_BIND_ON_PICKUP",
	MANUAL = "SANITY_CHECK_QUALITY",
	QUALITY = "SANITY_CHECK_QUALITY",
	ABOVE_QUALITY = "SANITY_CHECK_QUALITY",
}

--[[
    What Automated Rolls would do with a drop, and why, for the character
    being played, through the same ns.DecideRoll a real roll takes. Nil
    while the item loads.
]]
---@param itemIdentifier number
---@param inRaid boolean
---@return string|nil rollAction
---@return string|nil reason
local function Decide(itemIdentifier, inRaid)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	local itemInformation = itemLink and ns:SafeGetItemInfo(itemIdentifier)
	if not itemInformation then
		return nil, nil
	end
	local _, classFile = UnitClass("player")
	return ns.DecideRoll(
		itemIdentifier,
		itemInformation,
		itemLink,
		itemInformation.quality,
		ns.db.char.characterRules,
		classFile,
		UnitLevel("player"),
		inRaid
	)
end

--[[
    A row's outcome: Automatic and the roll, with the roll window's own button
    art, or Manual Roll in blue when the roll window is left to the player.
]]
---@param itemIdentifier number
---@param inRaid boolean
---@return string
local function OutcomeText(itemIdentifier, inRaid)
	local rollAction, reason = Decide(itemIdentifier, inRaid)
	if not reason then
		return ""
	end
	if not rollAction then
		return ns.GetColor("INFO") .. L["SANITY_CHECK_MANUAL_ROLL"] .. "|r"
	end
	local icon = ns.ROLL_ICONS[rollAction]
	return (icon and ("|T" .. icon .. ":0|t ") or "")
		.. L["SANITY_CHECK_AUTOMATIC"]:format(ns.ROLL_OVERRIDE_LABELS[rollAction] or "")
end

-- Under the outcome, in silver: the setting or page that decided it.
---@param itemIdentifier number
---@param inRaid boolean
---@return string
local function ReasonText(itemIdentifier, inRaid)
	local _, reason = Decide(itemIdentifier, inRaid)
	local why = reason and REASONS[reason]
	if not why then
		return ""
	end
	return ns.GetColor("HELP") .. L[why] .. "|r"
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    One section per kind of kill: a gold header, which group settings it
    reads, then two lines per drop and a spacer between drops. The first is
    the item through GogoLoot_ItemLink, which shows its tooltip on hover,
    beside the outcome; the second, in silver, its tag line beside the
    reason. A drop this client stops knowing (the server refused it) hides
    both lines.
]]
---@param args table
---@param order number
---@param section table # a SECTIONS row
---@return number # the next free order
local function AddSection(args, order, section)
	local context = section.inRaid and L["ROLLS_IN_RAID"] or L["ROLLS_IN_PARTY"]
	order = Kit.Section(args, section.key, order, L[section.title])
	args[section.key .. "Context"] =
		Kit.Desc(ns.GetColor("HELP") .. L["SANITY_CHECK_CONTEXT"]:format(context) .. "|r", order)
	order = order + 1
	for index, itemIdentifier in ipairs(drawn[section.key] or {}) do
		local function NotOnClient()
			return not ns.IsItemOnClient(itemIdentifier)
		end
		args[section.key .. "Spacer" .. index] = Kit.Spacer(order, NotOnClient)
		args[section.key .. "Drop" .. index] = Kit.Row(order + 0.25, NotOnClient, {
			{
				type = "input",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				name = "",
				width = Kit.LABEL_WIDTH,
				get = function()
					return tostring(itemIdentifier)
				end,
				set = function() end,
			},
			Kit.Label(function()
				return OutcomeText(itemIdentifier, section.inRaid)
			end, 0, Kit.CONTROL_WIDTH),
		})
		args[section.key .. "Tags" .. index] = Kit.Row(order + 0.5, NotOnClient, {
			Kit.Label(function()
				return TagLine(itemIdentifier)
			end, 0, Kit.LABEL_WIDTH),
			Kit.Label(function()
				return ReasonText(itemIdentifier, section.inRaid)
			end, 0, Kit.CONTROL_WIDTH),
		})
		order = order + 1
	end
	return order
end

---@return table
function ns.BuildSanityCheckOptions()
	if not drawn then
		ns.DrawSanityCheckDrops()
	end
	local args = {
		description = Kit.Desc(L["SANITY_CHECK_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
	}
	local order = ns.AddFeatureOffLine(args, 3, "autoGreed")
	args.refresh = Kit.Row(order, nil, {
		{
			type = "execute",
			name = L["SANITY_CHECK_REFRESH"],
			desc = L["SANITY_CHECK_REFRESH_DESCRIPTION"],
			width = Kit.CONTROL_WIDTH,
			func = function()
				ns.DrawSanityCheckDrops()
				ns.RefreshSettings()
			end,
		},
	})
	order = order + 1
	for _, section in ipairs(SECTIONS) do
		order = AddSection(args, order, section)
	end

	return {
		type = "group",
		name = L["TAB_SANITY_CHECK"],
		args = args,
	}
end
