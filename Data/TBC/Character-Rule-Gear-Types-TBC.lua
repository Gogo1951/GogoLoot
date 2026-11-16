local _, ns = ...

--[[
    Character Rules' armor and weapon rows, and what each class starts with
    ticked. A row is an item subclass ID, or a name for a row no subclass
    names. Gear that is a ticked type and carries a ticked stat is left to the
    player to roll; the rest of the gear is greeded (Features/Character-Rules.lua).
]]

-- The armor rows, in panel order: lightest first, then shields, held off-hands and relics.
ns.CHARACTER_RULE_ARMOR_TYPES = {
	1, -- Cloth
	2, -- Leather
	3, -- Mail
	4, -- Plate
	6, -- Shields
	"HELD", -- Held In Off-hand: armor subclass 0, told apart by its INVTYPE_HOLDABLE slot
	7, -- Librams
	8, -- Idols
	9, -- Totems
}

-- The weapon rows. The panel sorts them A to Z by the client's own names.
ns.CHARACTER_RULE_WEAPON_TYPES = {
	0, -- One-Handed Axes
	1, -- Two-Handed Axes
	2, -- Bows
	3, -- Guns
	4, -- One-Handed Maces
	5, -- Two-Handed Maces
	6, -- Polearms
	7, -- One-Handed Swords
	8, -- Two-Handed Swords
	10, -- Staves
	13, -- Fist Weapons
	15, -- Daggers
	16, -- Thrown
	18, -- Crossbows
	19, -- Wands
}

-- [classFile] = { armor row ticked for the class until the player changes it, ... }
ns.CLASS_ARMOR_STARTER = {
	WARRIOR = { 1, 2, 3, 4, 6 },
	PALADIN = { 1, 2, 3, 4, 6, "HELD", 7 },
	HUNTER = { 1, 2, 3 },
	ROGUE = { 1, 2 },
	PRIEST = { 1, "HELD" },
	SHAMAN = { 1, 2, 3, 6, "HELD", 9 },
	MAGE = { 1, "HELD" },
	WARLOCK = { 1, "HELD" },
	DRUID = { 1, 2, "HELD", 8 },
}

-- [classFile] = { weapon row ticked for the class until the player changes it, ... }
ns.CLASS_WEAPON_STARTER = {
	WARRIOR = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 },
	PALADIN = { 0, 1, 4, 5, 6, 7, 8 },
	HUNTER = { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 16, 18 },
	ROGUE = { 2, 3, 4, 7, 13, 15, 16, 18 },
	PRIEST = { 4, 10, 15, 19 },
	SHAMAN = { 0, 1, 4, 5, 10, 13, 15 },
	MAGE = { 7, 10, 15, 19 },
	WARLOCK = { 7, 10, 15, 19 },
	DRUID = { 4, 5, 10, 13, 15 },
}

-- [classFile] = { stat key (ns.CHARACTER_RULE_STATS) ticked for the class, ... }; a stat this client doesn't offer is skipped.
ns.CLASS_STAT_STARTER = {
	WARRIOR = { "ATTACK_POWER", "STRENGTH" },
	PALADIN = { "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "STRENGTH" },
	HUNTER = { "AGILITY", "ATTACK_POWER" },
	ROGUE = { "AGILITY", "ATTACK_POWER" },
	PRIEST = { "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "SPIRIT" },
	SHAMAN = { "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "STRENGTH" },
	MAGE = { "INTELLECT", "SPELL_POWER" },
	WARLOCK = { "INTELLECT", "SPELL_POWER" },
	DRUID = { "AGILITY", "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "SPIRIT", "STRENGTH" },
}

--[[
    The drops the Loot Roll Sanity Check draws ten from at a time, one list
    per section (Options/Options-Sanity-Check.lua): { itemId, kind }. kind is
    UNCOMMON, RARE, EPIC_BOE or EPIC by the item's quality and binding, so a
    draw can promise each section its greens, blues and Bind on Equip epics,
    or OTHER for a row that shows one of Automated Rolls' gates. A row this
    client doesn't have is never drawn.
]]
ns.SANITY_CHECK_TRASH = {
	-- Uncommon
	{ 21852, "UNCOMMON" }, -- Netherweave Pants (BoE)
	{ 23503, "UNCOMMON" }, -- Adamantite Cleaver (BoE)
	{ 23505, "UNCOMMON" }, -- Adamantite Rapier (BoE)
	{ 23746, "UNCOMMON" }, -- Adamantite Rifle (BoE)
	{ 24078, "UNCOMMON" }, -- Heavy Adamantite Ring (BoE)
	{ 29377, "UNCOMMON" }, -- Ethereum Phase-Spear (BoE)
	-- Rare
	{ 23515, "RARE" }, -- Flamebane Bracers (BoE)
	{ 23518, "RARE" }, -- Felsteel Leggings (BoE)
	{ 28248, "RARE" }, -- Totem of the Void (BoP)
	{ 28249, "RARE" }, -- Capacitus' Cloak of Calibration (BoP)
	{ 28250, "RARE" }, -- Vestia's Pauldrons of Inner Grace (BoP)
	{ 28251, "RARE" }, -- Boots of the Glade-Keeper (BoP)
	{ 31204, "RARE" }, -- The Gunblade (BoE)
	{ 31289, "RARE" }, -- Staff of Divine Infusion (BoE)
	{ 31297, "RARE" }, -- Robe of the Crimson Order (BoE)
	{ 32662, "RARE" }, -- Flaming Quartz Staff (BoE)
	-- Bind on Equip epics
	{ 23537, "EPIC_BOE" }, -- Black Felsteel Bracers (BoE)
	{ 23556, "EPIC_BOE" }, -- Hand of Eternity (BoE)
	{ 30733, "EPIC_BOE" }, -- Hope Ender (BoE)
	{ 30738, "EPIC_BOE" }, -- Ring of Reciprocity (BoE)
	{ 32400, "EPIC_BOE" }, -- Greaves of Shackled Souls (BoE)
	{ 34837, "EPIC_BOE" }, -- The 2 Ring (BoE)
	-- Epics
	{ 28454, "EPIC" }, -- Stalker's War Bands (BoP)
	{ 30022, "EPIC" }, -- Pendant of the Perilous (BoP)
	{ 30091, "EPIC" }, -- True-Aim Stalker Bands (BoP)
	{ 30674, "EPIC" }, -- Zierhut's Lost Treads (BoP)
}

ns.SANITY_CHECK_DUNGEON_BOSSES = {
	-- Uncommon
	{ 21855, "UNCOMMON" }, -- Netherweave Tunic (BoE)
	{ 23502, "UNCOMMON" }, -- Adamantite Maul (BoE)
	{ 25671, "UNCOMMON" }, -- Thick Draenic Vest (BoE)
	{ 29372, "UNCOMMON" }, -- Void-Talon (BoE)
	{ 29380, "UNCOMMON" }, -- Ethereum Phase Blade (BoE)
	-- Rare
	{ 27789, "RARE" }, -- Cloak of Whispering Shells (BoP)
	{ 27791, "RARE" }, -- Serpentcrest Life-Staff (BoP)
	{ 27793, "RARE" }, -- Earth Mantle Handwraps (BoP)
	{ 27803, "RARE" }, -- Shoulderguards of the Bold (BoP)
	{ 27804, "RARE" }, -- Devilshark Cape (BoP)
	{ 27890, "RARE" }, -- Wand of the Netherwing (BoP)
	{ 27892, "RARE" }, -- Cloak of the Inciter (BoP)
	{ 27893, "RARE" }, -- Ornate Leggings of the Venerated (BoP)
	{ 27905, "RARE" }, -- Greatsword of Horrid Dreams (BoP)
	{ 27977, "RARE" }, -- Legplates of the Bold (BoP)
	{ 27987, "RARE" }, -- Melmorta's Twilight Longbow (BoP)
	{ 28254, "RARE" }, -- Warp Engineer's Prismatic Chain (BoP)
	{ 28263, "RARE" }, -- Stellaris (BoP)
	{ 28285, "RARE" }, -- Helm of the Righteous (BoP)
	-- Epics
	{ 29261, "EPIC" }, -- Girdle of Ferocity (BoP)
	{ 29351, "EPIC" }, -- Wrathtide Longbow (BoP)
	{ 29353, "EPIC" }, -- Shockwave Truncheon (BoP)
	{ 29362, "EPIC" }, -- The Sun Eater (BoP)
}

ns.SANITY_CHECK_RAID_BOSSES = {
	-- Uncommon
	{ 21854, "UNCOMMON" }, -- Netherweave Robe (BoE)
	{ 30362, "UNCOMMON" }, -- Energized Helm (BoP)
	{ 30926, "UNCOMMON" }, -- Ashwalker's Footwraps (BoP)
	{ 31474, "UNCOMMON" }, -- Wand of the Ancestors (BoP)
	-- Rare
	{ 27449, "RARE" }, -- Blood Knight Defender (BoP)
	{ 27767, "RARE" }, -- Bogreaver (BoP)
	{ 27795, "RARE" }, -- Sash of Serpentra (BoP)
	{ 28182, "RARE" }, -- Helm of the Claw (BoP)
	{ 31544, "RARE" }, -- Clefthoof Hide Leggings (BoP)
	-- Bind on Equip epics
	{ 24256, "EPIC_BOE" }, -- Girdle of Ruination (BoE)
	{ 24261, "EPIC_BOE" }, -- Whitemend Pants (BoE)
	{ 31318, "EPIC_BOE" }, -- Singing Crystal Axe (BoE)
	{ 31330, "EPIC_BOE" }, -- Lightning Crown (BoE)
	{ 32404, "EPIC_BOE" }, -- Shadesteel Greaves (BoE)
	{ 34370, "EPIC_BOE" }, -- Gloves of Immortal Dusk (BoE)
	-- Epics
	{ 28518, "EPIC" }, -- Iron Gauntlets of the Maiden (BoP)
	{ 28524, "EPIC" }, -- Emerald Ripper (BoP)
	{ 28565, "EPIC" }, -- Nethershard Girdle (BoP)
	{ 28579, "EPIC" }, -- Romulo's Poison Vial (BoP)
	{ 28593, "EPIC" }, -- Eternium Greathelm (BoP)
	{ 28610, "EPIC" }, -- Ferocious Swift-Kickers (BoP)
	{ 28670, "EPIC" }, -- Boots of the Infernal Coven (BoP)
	{ 28672, "EPIC" }, -- Drape of the Dark Reavers (BoP)
	{ 28732, "EPIC" }, -- Cowl of Defiance (BoP)
	{ 28733, "EPIC" }, -- Girdle of Truth (BoP)
	{ 28734, "EPIC" }, -- Jewel of Infinite Possibilities (BoP)
	{ 30081, "EPIC" }, -- Warboots of Obliteration (BoP)
	-- Never Automated, quest items and Item Overrides
	{ 29753, "OTHER" }, -- Chestguard of the Fallen Defender (BoP)
	{ 32837, "OTHER" }, -- Warglaive of Azzinoth (BoP)
}

--[[
How We Got the Data

Last Validated
	Not yet checked in game (Play It Forward's tables: 2026-10-29, TBC Anniversary 2.5.6.70577)

Notes
	- SANITY_CHECK_TRASH, SANITY_CHECK_DUNGEON_BOSSES and SANITY_CHECK_RAID_BOSSES: the Loot Roll Sanity Check's drops, picked from Wowhead's tbc item data (zone drop tables for the dungeons and raids of this expansion's last level band, and its most popular items of each quality for gear outside them), then each item checked one by one against Wowhead's tooltip for this client for its quality, its binding and fixed stats (no random enchantment), on 2026-11-16. Not literally from that kind of kill: a section mixes Bind on Pickup and Bind on Equip, and every section holds at least four greens and five blues, and Trash and Raid Bosses at least six Bind on Equip epics, so a draw can always show two of each (Options/Options-Sanity-Check.lua). OTHER rows are picked by hand to show a gate: a mount or legendary (Never Automated), a quest item or token, or a default Item Overrides row. Diagnostics' Validate Data lists each row with its kind, to compare against the item's quality in game.
	- The starter lists every character gets until the player changes a box, worked out from Play It Forward's Match-Armor, Match-Weapons and Match-Specs tables, which its author validated on this client. Nothing is saved until the player changes a box, and Reset to Class Defaults clears what was saved.
	- Armor: every material the class can wear, its own and every lighter one (Play It Forward's NATIVE_ARMOR steps give the heaviest), so a paladin starts with Cloth, Leather, Mail and Plate and a druid with Cloth and Leather. Play It Forward ticks only the class's own materials; GogoLoot ticks the lighter ones too, mostly for healers, who wear them (maintainer, 2026-11-07). Shields, held off-hands and relics: the classes whose Play It Forward WEAPON_SPECS count is above 0.
	- Weapons: every type the class can train (WEAPON_SPECS above 0), assuming the character has trained everything (maintainer, 2026-11-07).
	- Stats: each spec's main stats, plus the role stats its useful list names (attack power, spell power, healing, mana per 5, Spirit), mapped to Character Rules' stat keys: RANGED_AP and FERAL_AP are ATTACK_POWER, SPELL_DAMAGE and the school damages are SPELL_POWER, HEALING is HEALING_POWER. A useful primary stat (a warrior's Agility, a hunter's Intellect) is left out, so gear built on it isn't held for the class. Stamina starts unticked for every class, and crit and hit ticked for every class (everyClass in ns.CHARACTER_RULE_STATS), so neither is listed here.
	- "HELD" is the held off-hand row (orbs, tomes, lanterns). Those items are armor subclass 0 Miscellaneous, like rings, so Features/Character-Rules.lua tells them apart by their INVTYPE_HOLDABLE slot.
	- Cloaks are cloth (armor subclass 1) on every client, so Features/Character-Rules.lua treats INVTYPE_CLOAK as a slot with no type, like rings, necks and trinkets: stats alone decide them. Shirts and tabards never get a rule.
	- Weapon subclasses with no row of their own (9, 11 and 12, obsolete and exotic; 14 Miscellaneous; 17 Spears; 20 Fishing Poles) fall to the Other row (Data/Data.lua), which starts unticked for every class.
	- Hunters start with Thrown ticked: Play It Forward counts it 0 because no hunter spec builds on it, but a hunter trains it, and the user asked for every trainable weapon (2026-11-07).

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	https://www.wowhead.com/tbc (dataEnv 5), the Sanity Check lists only

wago.tools
	https://wago.tools/db2/ItemSparse
	https://wago.tools/db2/ItemSubClass

QuestieDB
	None.
]]
