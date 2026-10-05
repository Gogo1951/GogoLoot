local _, ns = ...

-- { [key] = skillLineId }
ns.SKILL_LINE_IDS = {
	LOCKPICKING = 633, -- Lockpicking
}

-- { [key] = itemId }
ns.ITEM_IDS = {
	BIND_PROBE = 6948, -- Hearthstone
}

-- { [key] = soundKitId }, BAG_FULL_BY_RACE as { [raceFile] = { [sex] = soundKitId } }
ns.SOUND_KIT_IDS = {
	BAG_FULL_FALLBACK = 846, -- Inventory full, for a race with no voice line below
	PICK_POCKET = 1183, -- PickupBag
	BAG_FULL_BY_RACE = {
		["Human"] = { [2] = 1897, [3] = 2021 }, -- Human male, female
		["Orc"] = { [2] = 2308, [3] = 2363 }, -- Orc male, female
		["Dwarf"] = { [2] = 1609, [3] = 1673 }, -- Dwarf male, female
		["NightElf"] = { [2] = 2140, [3] = 2251 }, -- Night Elf male, female
		["Scourge"] = { [2] = 2076, [3] = 2196 }, -- Undead male, female
		["Tauren"] = { [2] = 2440, [3] = 2441 }, -- Tauren male, female
		["Gnome"] = { [2] = 1730, [3] = 1787 }, -- Gnome male, female
		["Troll"] = { [2] = 1842, [3] = 1952 }, -- Troll male, female
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-04, WoW Forever 1.60.1.70205

Notes
	- The game IDs GogoLoot's code reads by key, hand-picked, each under the key the code uses.
	- SKILL_LINE_IDS.LOCKPICKING is the Lockpicking skill line. Its name, from C_TradeSkillUI.GetTradeSkillDisplayName, is how Lockbox Tooltips finds the player's rank in every locale (Features/Lockbox-Tooltips.lua).
	- ITEM_IDS.BIND_PROBE is the Hearthstone, a Bind on Pickup item every character carries. Diagnostics checks against it which C_Item.GetItemInfo return carries the bind type (Diagnostics/Manifests.lua).
	- SOUND_KIT_IDS.PICK_POCKET is the bag-pickup sound played for a pick-pocket loot window (Features/Loot-Sounds.lua) and previewed beside its option. BAG_FULL_BY_RACE is each race's "inventory is full" voice line, by sex as UnitSex returns it (2 male, 3 female), played when Automated Opening stops for a full bag (Features/Automated-Opening.lua); BAG_FULL_FALLBACK plays for a race with no row.
	- Validate Data looks up ITEM_IDS only. SKILL_LINE_IDS and SOUND_KIT_IDS hold IDs no client API looks up, so it only counts their rows.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SoundKit?build=1.60.1.70205
]]
