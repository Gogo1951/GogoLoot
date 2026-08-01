--------------------------------------------------------------------------------
-- GogoLoot Default Settings
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------

--[[
    AceDB-3.0 defaults table, passed to AceDB:New in Features/Core.lua. Loot
    policy lives in the active profile (ns.db.profile); the presentation keys
    live in global, per the comment on that table below. AceDB physically copies
    these defaults into the saved table rather than resolving them through a
    metatable, so there is no manual merge anywhere. The empty
    ignoredItemsMaster / ignoredItemsSolo lists are seeded from the default
    lists below by Core's refill-on-empty rule, never here.
]]

ns.DATABASE_DEFAULTS = {
	profile = {
		announceDestinations = true,
		announceMasterLootAuto = true,
		announceMasterLootAutoThreshold = 3,
		announceTrade = true,
		announceTradeCondition = "always",
		announceTradeOutput = "whisper",
		autoGreed = false,
		--[[
            Automated rolls are configured per group context: the party pair
            applies whenever IsInRaid() is false, the raid pair whenever it is
            true. Action values are the ns.MANUAL / ns.PASS / ns.GREED / ns.NEED
            strings; MANUAL means "leave that context alone".
        ]]
		autoRollActionParty = ns.GREED,
		autoRollThresholdParty = 2,
		autoRollActionRaid = ns.GREED,
		autoRollThresholdRaid = 2,
		autoMasterLoot = true,
		autoMasterLootOutsideInstances = false,
		masterLooterPopup = true,
		customRollList = true,
		--[[
            Quality key -> recipient, and deliberately empty: an absent tier is
            "nobody chosen yet", which auto-distributes nothing and shows an
            empty dropdown. Seeding every tier with "self" would make AceDB
            re-apply it at each login, so a cleared setup could never survive a
            reload, and a destination nobody picked would look like one they had.
        ]]
		destinations = {},
		ignoredItemsMaster = {},
		ignoredItemsSolo = {},
	},
	--[[
		Account-wide: how GogoLoot presents itself and what it does to the
		client, which never varies by loot context. A profile switch, reset, or
		delete leaves all of it alone. Everything in profile above is loot
		policy, which is exactly what a second profile is for.
	]]
	global = {
		showWelcome = true,
		speedyLoot = true,
		minimap = {},
	},
}

--------------------------------------------------------------------------------
-- Default Custom Roll / Ignore Lists
--------------------------------------------------------------------------------

--[[
    Format: [itemId] = {expansion, rollOverride}
    Expansion: VANILLA=1, TBC=2, WRATH=3
    Roll Override (solo only): ROLL_INDEX_MANUAL=1, ROLL_INDEX_GREED=2, ROLL_INDEX_NEED=3, ROLL_INDEX_PASS=4
]]

-- TODO: Add SQL Query
ns.DEFAULT_IGNORE_LIST_SOLO = {
	[19706] = { 1, 3 }, -- Bloodscalp Coin
	[19708] = { 1, 3 }, -- Blue Hakkari Bijou
	[20864] = { 1, 3 }, -- Bone Scarab
	[19713] = { 1, 3 }, -- Bronze Hakkari Bijou
	[20861] = { 1, 3 }, -- Bronze Scarab
	[20863] = { 1, 3 }, -- Clay Scarab
	[12843] = { 1, 1 }, -- Corruptor's Scourgestone
	[20862] = { 1, 3 }, -- Crystal Scarab
	[20520] = { 1, 1 }, -- Dark Rune
	[12662] = { 1, 1 }, -- Demonic Rune
	[17010] = { 1, 3 }, -- Fiery Core
	[22682] = { 1, 1 }, -- Frozen Rune
	[19715] = { 1, 3 }, -- Gold Hakkari Bijou
	[20859] = { 1, 3 }, -- Gold Scarab
	[19711] = { 1, 3 }, -- Green Hakkari Bijou
	[19701] = { 1, 3 }, -- Gurubashi Coin
	[19700] = { 1, 3 }, -- Hakkari Coin
	[20876] = { 1, 1 }, -- Idol of Death
	[20879] = { 1, 1 }, -- Idol of Life
	[20875] = { 1, 1 }, -- Idol of Night
	[20878] = { 1, 1 }, -- Idol of Rebirth
	[20881] = { 1, 1 }, -- Idol of Strife
	[20877] = { 1, 1 }, -- Idol of the Sage
	[20874] = { 1, 1 }, -- Idol of the Sun
	[20882] = { 1, 1 }, -- Idol of War
	[20865] = { 1, 3 }, -- Ivory Scarab
	[17011] = { 1, 3 }, -- Lava Core
	[11733] = { 1, 1 }, -- Libram of Constitution
	[18333] = { 1, 1 }, -- Libram of Focus
	[18334] = { 1, 1 }, -- Libram of Protection
	[18332] = { 1, 1 }, -- Libram of Rapidity
	[11736] = { 1, 1 }, -- Libram of Resilience
	[11732] = { 1, 1 }, -- Libram of Rumination
	[11734] = { 1, 1 }, -- Libram of Tenacity
	[11737] = { 1, 1 }, -- Libram of Voracity
	[19710] = { 1, 3 }, -- Orange Hakkari Bijou
	[19813] = { 1, 1 }, -- Punctured Voodoo Doll
	[19819] = { 1, 1 }, -- Punctured Voodoo Doll
	[19820] = { 1, 1 }, -- Punctured Voodoo Doll
	[19816] = { 1, 1 }, -- Punctured Voodoo Doll
	[19818] = { 1, 1 }, -- Punctured Voodoo Doll
	[19821] = { 1, 1 }, -- Punctured Voodoo Doll
	[19815] = { 1, 1 }, -- Punctured Voodoo Doll
	[19814] = { 1, 1 }, -- Punctured Voodoo Doll
	[19817] = { 1, 1 }, -- Punctured Voodoo Doll
	[19712] = { 1, 3 }, -- Purple Hakkari Bijou
	[19699] = { 1, 3 }, -- Razzashi Coin
	[19707] = { 1, 3 }, -- Red Hakkari Bijou
	[12811] = { 1, 1 }, -- Righteous Orb
	[19704] = { 1, 3 }, -- Sandfury Coin
	[19714] = { 1, 3 }, -- Silver Hakkari Bijou
	[20860] = { 1, 3 }, -- Silver Scarab
	[19705] = { 1, 3 }, -- Skullsplitter Coin
	[20858] = { 1, 3 }, -- Stone Scarab
	[4500] = { 1, 1 }, -- Traveler's Backpack
	[19702] = { 1, 3 }, -- Vilebranch Coin
	[19703] = { 1, 3 }, -- Witherbark Coin
	[23055] = { 1, 1 }, -- Word of Thawing
	[19709] = { 1, 3 }, -- Yellow Hakkari Bijou
	[19698] = { 1, 3 }, -- Zulian Coin
	[29739] = { 2, 1 }, -- Arcane Tome
	[32227] = { 2, 1 }, -- Crimson Spinel
	[23440] = { 2, 1 }, -- Dawnstone
	[32228] = { 2, 1 }, -- Empyrean Sapphire
	[29740] = { 2, 1 }, -- Fel Armament
	[32229] = { 2, 1 }, -- Lionseye
	[23436] = { 2, 1 }, -- Living Ruby
	[30183] = { 2, 1 }, -- Nether Vortex
	[23441] = { 2, 1 }, -- Nightseye
	[23439] = { 2, 1 }, -- Noble Topaz
	[22451] = { 2, 1 }, -- Primal Air
	[22452] = { 2, 1 }, -- Primal Earth
	[21884] = { 2, 1 }, -- Primal Fire
	[21886] = { 2, 1 }, -- Primal Life
	[22457] = { 2, 1 }, -- Primal Mana
	[23572] = { 2, 1 }, -- Primal Nether
	[22456] = { 2, 1 }, -- Primal Shadow
	[21885] = { 2, 1 }, -- Primal Water
	[32231] = { 2, 1 }, -- Pyrestone
	[32249] = { 2, 1 }, -- Seaspray Emerald
	[32230] = { 2, 1 }, -- Shadowsong Amethyst
	[23438] = { 2, 1 }, -- Star of Elune
	[23437] = { 2, 1 }, -- Talasite
}

-- TODO: Add SQL Query
ns.DEFAULT_IGNORE_LIST_MASTER = {
	-- Vanilla: BoP Crafting Materials
	[12662] = { 1 }, -- Demonic Rune
	[20520] = { 1 }, -- Dark Rune
	-- Vanilla: Bags
	[17966] = { 1 }, -- Onyxia Hide Backpack
	[19914] = { 1 }, -- Panther Hide Sack
	-- TBC: BoP Crafting Materials
	[23572] = { 2 }, -- Primal Nether
	[30183] = { 2 }, -- Nether Vortex
	[32428] = { 2 }, -- Heart of Darkness
	[34664] = { 2 }, -- Sunmote
	-- TBC: Bags
	[34845] = { 2 }, -- Pit Lord's Satchel
	[34846] = { 2 }, -- Black Sack of Gems
}
