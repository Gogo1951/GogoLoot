local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- { armor subclass ID, or "HELD" }, in panel order: lightest first, then shields, held off-hands and relics
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

-- { weapon subclass ID }, which the panel sorts A to Z by the client's own names
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
	ROGUE = { "AGILITY", "ATTACK_POWER", "STRENGTH" },
	PRIEST = { "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "SPIRIT" },
	SHAMAN = { "AGILITY", "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "STRENGTH" },
	MAGE = { "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER" },
	WARLOCK = { "INTELLECT", "SPELL_POWER" },
	DRUID = { "AGILITY", "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "SPIRIT", "STRENGTH" },
}

-- { itemId, kind }
ns.SANITY_CHECK_TRASH = {
	-- Uncommon
	{ 12426, "UNCOMMON" }, -- Imperial Plate Boots (BoE)
	{ 13866, "UNCOMMON" }, -- Runecloth Headband (BoE)
	{ 14111, "UNCOMMON" }, -- Felcloth Hood (BoE)
	{ 15080, "UNCOMMON" }, -- Heavy Scorpid Helm (BoE)
	{ 15085, "UNCOMMON" }, -- Wicked Leather Armor (BoE)
	{ 15087, "UNCOMMON" }, -- Wicked Leather Pants (BoE)
	-- Rare
	{ 13091, "RARE" }, -- Medallion of Grand Marshal Morris (BoE)
	{ 13101, "RARE" }, -- Wolfrunner Shoes (BoE)
	{ 16672, "RARE" }, -- Gauntlets of Elements (BoE)
	{ 16696, "RARE" }, -- Devout Belt (BoE)
	{ 16726, "RARE" }, -- Lightforge Breastplate (BoP)
	{ 18736, "RARE" }, -- Plaguehound Leggings (BoE)
	{ 18744, "RARE" }, -- Plaguebat Fur Gloves (BoE)
	{ 19962, "RARE" }, -- Gri'lek's Carver (BoP)
	{ 20295, "RARE" }, -- Blue Dragonscale Leggings (BoE)
	{ 22302, "RARE" }, -- Ironweave Cowl (BoP)
	-- Bind on Equip epics
	{ 12640, "EPIC_BOE" }, -- Lionheart Helm (BoE)
	{ 16864, "EPIC_BOE" }, -- Belt of Might (BoE)
	{ 16984, "EPIC_BOE" }, -- Black Dragonscale Boots (BoE)
	{ 17014, "EPIC_BOE" }, -- Dark Iron Bracers (BoE)
	{ 18263, "EPIC_BOE" }, -- Flarecore Wraps (BoE)
	{ 22670, "EPIC_BOE" }, -- Icebane Gauntlets (BoE)
	-- Epics
	{ 13314, "EPIC" }, -- Alanna's Embrace (BoP)
	{ 13353, "EPIC" }, -- Book of the Dead (BoP)
	{ 19435, "EPIC" }, -- Essence Gatherer (BoP)
	{ 19927, "EPIC" }, -- Mar'li's Touch (BoP)
}

-- { itemId, kind }
ns.SANITY_CHECK_DUNGEON_BOSSES = {
	-- Uncommon
	{ 12422, "UNCOMMON" }, -- Imperial Plate Chest (BoE)
	{ 12427, "UNCOMMON" }, -- Imperial Plate Helm (BoE)
	{ 13867, "UNCOMMON" }, -- Runecloth Shoulders (BoE)
	{ 14108, "UNCOMMON" }, -- Felcloth Boots (BoE)
	{ 14112, "UNCOMMON" }, -- Felcloth Shoulders (BoE)
	-- Rare
	{ 11634, "RARE" }, -- Silkweb Gloves (BoP)
	{ 11722, "RARE" }, -- Dregmetal Spaulders (BoP)
	{ 11930, "RARE" }, -- The Emperor's New Cape (BoP)
	{ 12651, "RARE" }, -- Blackcrow (BoP)
	{ 12793, "RARE" }, -- Mixologist's Tunic (BoP)
	{ 13163, "RARE" }, -- Relentless Scythe (BoP)
	{ 13166, "RARE" }, -- Slamshot Shoulders (BoP)
	{ 13169, "RARE" }, -- Tressermane Leggings (BoP)
	{ 13210, "RARE" }, -- Pads of the Dread Wolf (BoP)
	{ 13372, "RARE" }, -- Slavedriver's Cane (BoP)
	{ 13405, "RARE" }, -- Wailing Nightbane Pauldrons (BoP)
	{ 16675, "RARE" }, -- Beaststalker's Boots (BoP)
	{ 18725, "RARE" }, -- Peacemaker (BoP)
	{ 22241, "RARE" }, -- Dark Warder's Pauldrons (BoP)
	-- Epics
	{ 12592, "EPIC" }, -- Blackblade of Shahram (BoP)
	{ 13143, "EPIC" }, -- Mark of the Dragon Lord (BoP)
	{ 13505, "EPIC" }, -- Runeblade of Baron Rivendare (BoP)
	{ 13937, "EPIC" }, -- Headmaster's Charge (BoP)
	-- Never Automated, quest items and Item Overrides
	{ 13335, "OTHER" }, -- Deathcharger's Reins (BoP)
}

-- { itemId, kind }
ns.SANITY_CHECK_RAID_BOSSES = {
	-- Uncommon
	{ 8290, "UNCOMMON" }, -- Arcane Robe (BoE)
	{ 12429, "UNCOMMON" }, -- Imperial Plate Leggings (BoE)
	{ 14144, "UNCOMMON" }, -- Ghostweave Pants (BoE)
	{ 15088, "UNCOMMON" }, -- Wicked Leather Belt (BoE)
	-- Rare
	{ 14548, "RARE" }, -- Royal Cap Spaulders (BoP)
	{ 15063, "RARE" }, -- Devilsaur Gauntlets (BoE)
	{ 16690, "RARE" }, -- Devout Robe (BoP)
	{ 20204, "RARE" }, -- Defiler's Plate Girdle (BoP)
	{ 22331, "RARE" }, -- Band of the Steadfast Hero (BoP)
	-- Bind on Equip epics
	{ 16799, "EPIC_BOE" }, -- Arcanist Bindings (BoE)
	{ 16982, "EPIC_BOE" }, -- Corehound Boots (BoE)
	{ 16983, "EPIC_BOE" }, -- Molten Helm (BoE)
	{ 19162, "EPIC_BOE" }, -- Corehound Belt (BoE)
	{ 19164, "EPIC_BOE" }, -- Dark Iron Gauntlets (BoE)
	{ 22666, "EPIC_BOE" }, -- Icy Scale Gauntlets (BoE)
	-- Epics
	{ 16820, "EPIC" }, -- Nightslayer Chestpiece (BoP)
	{ 16898, "EPIC" }, -- Stormrage Boots (BoP)
	{ 16923, "EPIC" }, -- Robes of Transcendence (BoP)
	{ 16937, "EPIC" }, -- Dragonstalker's Spaulders (BoP)
	{ 17063, "EPIC" }, -- Band of Accuria (BoP)
	{ 18203, "EPIC" }, -- Eskhandar's Right Claw (BoP)
	{ 18870, "EPIC" }, -- Helm of the Lifegiver (BoP)
	{ 19348, "EPIC" }, -- Red Dragonscale Protector (BoP)
	{ 19377, "EPIC" }, -- Prestor's Talisman of Connivery (BoP)
	{ 19407, "EPIC" }, -- Ebony Flame Gloves (BoP)
	{ 19852, "EPIC" }, -- Ancient Hakkari Manslayer (BoP)
	{ 19910, "EPIC" }, -- Arlokk's Grasp (BoP)
	-- Never Automated, quest items and Item Overrides
	{ 18423, "OTHER" }, -- Head of Onyxia (BoP)
	{ 19707, "OTHER" }, -- Red Hakkari Bijou (no binding)
	{ 18564, "OTHER" }, -- Bindings of the Windseeker (BoP)
}

--[[
How We Got the Data

Last Validated
	2026-11-27, wago.tools, Classic Era 1.15.9.70576

Notes
	- Character Rules' armor and weapon rows, and what each class starts with ticked. A row is an item subclass ID, or a name for a row no subclass names. Gear that is a ticked type and carries a ticked stat is left to the player to roll; the rest of the gear is greeded (Features/Character-Rules.lua).
	- SANITY_CHECK_TRASH, SANITY_CHECK_DUNGEON_BOSSES and SANITY_CHECK_RAID_BOSSES: the Loot Roll Sanity Check's drops, picked from Wowhead's classic item data (zone drop tables for the dungeons and raids of this expansion's last level band, and its most popular items of each quality for gear outside them), then each item checked one by one against Wowhead's tooltip for this client for its quality, its binding and fixed stats (no random enchantment), on 2026-11-16. Not literally from that kind of kill: a section mixes Bind on Pickup and Bind on Equip, and every section holds at least four greens and five blues, and Trash and Raid Bosses at least six Bind on Equip epics, so a draw can always show two of each (Options/Options-Sanity-Check.lua). OTHER rows are picked by hand to show a gate: a mount or legendary (Never Automated), a quest item or token, or a default Item Overrides row. Diagnostics' Validate Data lists each row with its kind, to compare against the item's quality in game.
	- The Sanity Check draws ten at a time from one list per section (Options/Options-Sanity-Check.lua). kind is UNCOMMON, RARE, EPIC_BOE or EPIC by the item's quality and binding, so a draw can promise each section its greens, blues and Bind on Equip epics, or OTHER for a row that shows one of Automated Rolls' gates. A row this client doesn't have is never drawn.
	- The starter lists every character gets until the player changes a box, worked out from Play It Forward's Match-Armor, Match-Weapons and Match-Specs tables, which its author validated on this client (its tables as of 2026-10-29, Season of Discovery 1.15.9.70576). Nothing is saved until the player changes a box, and Reset to Class Defaults clears what was saved.
	- Armor: every material the class can wear, its own and every lighter one (Play It Forward's NATIVE_ARMOR steps give the heaviest), so a paladin starts with Cloth, Leather, Mail and Plate and a druid with Cloth and Leather. Play It Forward ticks only the class's own materials; GogoLoot ticks the lighter ones too, mostly for healers, who wear them (maintainer, 2026-11-07). Shields, held off-hands and relics: the classes whose Play It Forward WEAPON_SPECS count is above 0.
	- Weapons: every type the class can train (WEAPON_SPECS above 0), assuming the character has trained everything (maintainer, 2026-11-07).
	- Stats: each spec's main stats, plus the role stats its useful list names (attack power, spell power, healing, mana per 5, Spirit), mapped to Character Rules' stat keys: RANGED_AP and FERAL_AP are ATTACK_POWER, SPELL_DAMAGE and the school damages are SPELL_POWER, HEALING is HEALING_POWER. A useful primary stat (a warrior's Agility, a hunter's Intellect) is left out, so gear built on it isn't held for the class. Stamina starts unticked for every class, and crit and hit ticked for every class (everyClass in ns.CHARACTER_RULE_STATS), so neither is listed here.
	- Stats the maintainer added beyond the spec mapping (2026-11-18): Strength for rogues, and Agility for shamans, so melee gear built on either is held for them. Shamans already start with Strength and Intellect.
	- "HELD" is the held off-hand row (orbs, tomes, lanterns). Those items are armor subclass 0 Miscellaneous, like rings, so Features/Character-Rules.lua tells them apart by their INVTYPE_HOLDABLE slot.
	- Cloaks are cloth (armor subclass 1) on every client, so Features/Character-Rules.lua treats INVTYPE_CLOAK as a slot with no type, like rings, necks and trinkets: stats alone decide them. Shirts and tabards never get a rule.
	- Weapon subclasses with no row of their own (9, 11 and 12, obsolete and exotic; 14 Miscellaneous; 17 Spears; 20 Fishing Poles) fall to the Other row (Data/Data.lua), which starts unticked for every class.
	- Hunters start with Thrown ticked: Play It Forward counts it 0 because no hunter spec builds on it, but a hunter trains it, and the user asked for every trainable weapon (2026-11-07).
	- Rechecked against this client's tables at build 1.15.9.70576: every armor and weapon row is a subclass in ItemSubClass, and every Sanity Check drop is in ItemSparse at the quality and binding its kind and comment give, with no random enchantment.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	https://www.wowhead.com/classic (dataEnv 4), the Sanity Check lists only

wago.tools
	https://wago.tools/db2/ItemSparse
	https://wago.tools/db2/ItemSubClass
	https://wago.tools/db2/ItemSubClass?build=1.15.9.70576
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/Item?build=1.15.9.70576

QuestieDB
	None.
]]
