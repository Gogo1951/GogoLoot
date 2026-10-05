local _, ns = ...

-- { itemId, rollAction }
ns.DEFAULT_IGNORE_LIST_SOLO = {
	{ 20873, ns.NEED }, -- Alabaster Idol
	{ 20869, ns.NEED }, -- Amber Idol
	{ 20866, ns.NEED }, -- Azure Idol
	{ 19706, ns.NEED }, -- Bloodscalp Coin
	{ 19708, ns.NEED }, -- Blue Hakkari Bijou
	{ 20864, ns.NEED }, -- Bone Scarab
	{ 19713, ns.NEED }, -- Bronze Hakkari Bijou
	{ 20861, ns.NEED }, -- Bronze Scarab
	{ 20863, ns.NEED }, -- Clay Scarab
	{ 12843, ns.MANUAL }, -- Corruptor's Scourgestone
	{ 20862, ns.NEED }, -- Crystal Scarab
	{ 20520, ns.MANUAL }, -- Dark Rune
	{ 12662, ns.MANUAL }, -- Demonic Rune
	{ 17010, ns.NEED }, -- Fiery Core
	{ 22682, ns.MANUAL }, -- Frozen Rune
	{ 19715, ns.NEED }, -- Gold Hakkari Bijou
	{ 20859, ns.NEED }, -- Gold Scarab
	{ 21762, ns.NEED }, -- Greater Scarab Coffer Key
	{ 19711, ns.NEED }, -- Green Hakkari Bijou
	{ 19701, ns.NEED }, -- Gurubashi Coin
	{ 19700, ns.NEED }, -- Hakkari Coin
	{ 20876, ns.NEED }, -- Idol of Death
	{ 20879, ns.NEED }, -- Idol of Life
	{ 20875, ns.NEED }, -- Idol of Night
	{ 20878, ns.NEED }, -- Idol of Rebirth
	{ 20881, ns.NEED }, -- Idol of Strife
	{ 20877, ns.NEED }, -- Idol of the Sage
	{ 20874, ns.NEED }, -- Idol of the Sun
	{ 20882, ns.NEED }, -- Idol of War
	{ 20865, ns.NEED }, -- Ivory Scarab
	{ 20870, ns.NEED }, -- Jasper Idol
	{ 20868, ns.NEED }, -- Lambent Idol
	{ 17011, ns.NEED }, -- Lava Core
	{ 11733, ns.MANUAL }, -- Libram of Constitution
	{ 18333, ns.MANUAL }, -- Libram of Focus
	{ 18334, ns.MANUAL }, -- Libram of Protection
	{ 18332, ns.MANUAL }, -- Libram of Rapidity
	{ 11736, ns.MANUAL }, -- Libram of Resilience
	{ 11732, ns.MANUAL }, -- Libram of Rumination
	{ 11734, ns.MANUAL }, -- Libram of Tenacity
	{ 11737, ns.MANUAL }, -- Libram of Voracity
	{ 20871, ns.NEED }, -- Obsidian Idol
	{ 20867, ns.NEED }, -- Onyx Idol
	{ 17966, ns.MANUAL }, -- Onyxia Hide Backpack
	{ 19710, ns.NEED }, -- Orange Hakkari Bijou
	{ 19914, ns.MANUAL }, -- Panther Hide Sack
	{ 19813, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19819, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19820, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19816, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19818, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19821, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19815, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19814, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19817, ns.MANUAL }, -- Punctured Voodoo Doll
	{ 19712, ns.NEED }, -- Purple Hakkari Bijou
	{ 19699, ns.NEED }, -- Razzashi Coin
	{ 19707, ns.NEED }, -- Red Hakkari Bijou
	{ 12811, ns.MANUAL }, -- Righteous Orb
	{ 19704, ns.NEED }, -- Sandfury Coin
	{ 21156, ns.NEED }, -- Scarab Bag
	{ 21761, ns.NEED }, -- Scarab Coffer Key
	{ 19714, ns.NEED }, -- Silver Hakkari Bijou
	{ 20860, ns.NEED }, -- Silver Scarab
	{ 19705, ns.NEED }, -- Skullsplitter Coin
	{ 20858, ns.NEED }, -- Stone Scarab
	{ 4500, ns.MANUAL }, -- Traveler's Backpack
	{ 20872, ns.NEED }, -- Vermillion Idol
	{ 19702, ns.NEED }, -- Vilebranch Coin
	{ 22374, ns.MANUAL }, -- Wartorn Chain Scrap
	{ 22376, ns.MANUAL }, -- Wartorn Cloth Scrap
	{ 22373, ns.MANUAL }, -- Wartorn Leather Scrap
	{ 22375, ns.MANUAL }, -- Wartorn Plate Scrap
	{ 19703, ns.NEED }, -- Witherbark Coin
	{ 23055, ns.MANUAL }, -- Word of Thawing
	{ 19709, ns.NEED }, -- Yellow Hakkari Bijou
	{ 19698, ns.NEED }, -- Zulian Coin
}

-- { itemId }
ns.DEFAULT_IGNORE_LIST_MASTER = {
	-- Crafting Materials
	{ 12662 }, -- Demonic Rune
	{ 20520 }, -- Dark Rune
	-- Bags
	{ 17966 }, -- Onyxia Hide Backpack
	{ 19914 }, -- Panther Hide Sack
}

--[[
How We Got the Data

Last Validated
	2026-10-04, WoW Forever 1.60.1.70205

Notes
	- Both lists are hand-picked, and Features/Core.lua seeds the player's list from them whenever that list is empty, skipping any ID this client doesn't know.
	- ns.DEFAULT_IGNORE_LIST_SOLO seeds Item Overrides, under Automated Rolls: items GogoLoot rolls on its own way rather than by the player's Party or Raid setting (Features/Automated-Rolls.lua). Need for the Zul'Gurub coins and bijous, the Ahn'Qiraj scarabs and idols, Scarab Bag, the two Scarab Coffer Keys, Fiery Core and Lava Core. Manual, which leaves the roll to the player, for the librams, the Punctured Voodoo Dolls, Demonic Rune and Dark Rune, Righteous Orb, Corruptor's Scourgestone, Frozen Rune, Word of Thawing, the bags and the Wartorn scraps.
	- The Wartorn scraps are listed at Manual on purpose. They are an AQ40 Cenarion Circle turn-in with real value, so auto-needing one in a pug reads as ninja-ing; the entry exists so the row is in the UI ready to change, not so the add-on rolls on it.
	- ns.DEFAULT_IGNORE_LIST_MASTER seeds the Master Looter Ignore List: items automated master looting leaves in the loot window for the master looter to hand out by hand (Features/Master-Looter-Distribution.lua). Demonic Rune and Dark Rune, then the raid bags Onyxia Hide Backpack and Panther Hide Sack.
	- Began as a copy of Data/Vanilla/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.
]]
