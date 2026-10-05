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
		["BloodElf"] = { [2] = 9589, [3] = 9590 }, -- Blood Elf male, female
		["Draenei"] = { [2] = 9504, [3] = 9505 }, -- Draenei male, female
	},
}
