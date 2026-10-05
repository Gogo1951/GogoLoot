-- Data/Wrath/Default-Item-Lists-Wrath.lua
local _, ns = ...

-- Copied from Data/TBC until Validate Data passes on this client.
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
	--[[
        The Wartorn scraps are listed at Manual on purpose. They are an AQ40
        Cenarion Circle turn-in with real value, so auto-needing one in a pug
        reads as ninja-ing; the entry exists so the row is in the UI ready to
        change, not so the add-on rolls on it.
    ]]
	{ 22374, ns.MANUAL }, -- Wartorn Chain Scrap
	{ 22376, ns.MANUAL }, -- Wartorn Cloth Scrap
	{ 22373, ns.MANUAL }, -- Wartorn Leather Scrap
	{ 22375, ns.MANUAL }, -- Wartorn Plate Scrap
	{ 19703, ns.NEED }, -- Witherbark Coin
	{ 23055, ns.MANUAL }, -- Word of Thawing
	{ 19709, ns.NEED }, -- Yellow Hakkari Bijou
	{ 19698, ns.NEED }, -- Zulian Coin
	{ 29739, ns.MANUAL }, -- Arcane Tome
	{ 32227, ns.MANUAL }, -- Crimson Spinel
	{ 23440, ns.MANUAL }, -- Dawnstone
	{ 32228, ns.MANUAL }, -- Empyrean Sapphire
	{ 29740, ns.MANUAL }, -- Fel Armament
	{ 32229, ns.MANUAL }, -- Lionseye
	{ 23436, ns.MANUAL }, -- Living Ruby
	{ 30183, ns.MANUAL }, -- Nether Vortex
	{ 23441, ns.MANUAL }, -- Nightseye
	{ 23439, ns.MANUAL }, -- Noble Topaz
	{ 22451, ns.MANUAL }, -- Primal Air
	{ 22452, ns.MANUAL }, -- Primal Earth
	{ 21884, ns.MANUAL }, -- Primal Fire
	{ 21886, ns.MANUAL }, -- Primal Life
	{ 22457, ns.MANUAL }, -- Primal Mana
	{ 23572, ns.MANUAL }, -- Primal Nether
	{ 22456, ns.MANUAL }, -- Primal Shadow
	{ 21885, ns.MANUAL }, -- Primal Water
	{ 32231, ns.MANUAL }, -- Pyrestone
	{ 32249, ns.MANUAL }, -- Seaspray Emerald
	{ 32230, ns.MANUAL }, -- Shadowsong Amethyst
	{ 23438, ns.MANUAL }, -- Star of Elune
	{ 23437, ns.MANUAL }, -- Talasite
}

-- Copied from Data/TBC until Validate Data passes on this client.
-- { itemId }
ns.DEFAULT_IGNORE_LIST_MASTER = {
	-- BoP Crafting Materials
	{ 12662 }, -- Demonic Rune
	{ 20520 }, -- Dark Rune
	{ 23572 }, -- Primal Nether
	{ 30183 }, -- Nether Vortex
	{ 32428 }, -- Heart of Darkness
	{ 34664 }, -- Sunmote
	-- Bags
	{ 17966 }, -- Onyxia Hide Backpack
	{ 19914 }, -- Panther Hide Sack
	{ 34845 }, -- Pit Lord's Satchel
	{ 34846 }, -- Black Sack of Gems
}
