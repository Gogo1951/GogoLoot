local _, ns = ...

-- { armor subclass ID, or "HELD" }, in panel order: lightest first, then shields, held off-hands and relics
ns.CHARACTER_RULE_ARMOR_TYPES = {
	1, -- Cloth
	2, -- Leather
	3, -- Mail
	4, -- Plate
	6, -- Shields
	"HELD", -- Held In Off-hand: armor subclass 0, told apart by its INVTYPE_HOLDABLE slot
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
	18, -- Crossbows
	19, -- Wands
}

-- [classFile] = { armor row ticked for the class until the player changes it, ... }
ns.CLASS_ARMOR_STARTER = {
	WARRIOR = { 1, 2, 3, 4, 6 },
	PALADIN = { 1, 2, 3, 4, 6, "HELD" },
	HUNTER = { 1, 2, 3 },
	ROGUE = { 1, 2 },
	PRIEST = { 1, "HELD" },
	SHAMAN = { 1, 2, 3, 6, "HELD" },
	MAGE = { 1, "HELD" },
	WARLOCK = { 1, "HELD" },
	DRUID = { 1, 2, "HELD" },
	DEATHKNIGHT = { 1, 2, 3, 4 },
	MONK = { 1, 2, "HELD" },
}

-- [classFile] = { weapon row ticked for the class until the player changes it, ... }
ns.CLASS_WEAPON_STARTER = {
	WARRIOR = { 0, 1, 4, 5, 6, 7, 8, 10, 13, 15 },
	PALADIN = { 0, 1, 4, 5, 6, 7, 8 },
	HUNTER = { 2, 3, 18 },
	ROGUE = { 0, 4, 7, 13, 15 },
	PRIEST = { 4, 10, 15, 19 },
	SHAMAN = { 0, 1, 4, 5, 10, 13, 15 },
	MAGE = { 7, 10, 15, 19 },
	WARLOCK = { 7, 10, 15, 19 },
	DRUID = { 4, 5, 6, 10, 13, 15 },
	DEATHKNIGHT = { 0, 1, 4, 5, 6, 7, 8 },
	MONK = { 0, 4, 6, 7, 10, 13 },
}

-- [classFile] = { stat key (ns.CHARACTER_RULE_STATS) ticked for the class, ... }; a stat this client doesn't offer is skipped.
ns.CLASS_STAT_STARTER = {
	WARRIOR = { "STRENGTH" },
	PALADIN = { "INTELLECT", "SPELL_POWER", "SPIRIT", "STRENGTH" },
	HUNTER = { "AGILITY" },
	ROGUE = { "AGILITY" },
	PRIEST = { "INTELLECT", "SPELL_POWER", "SPIRIT" },
	SHAMAN = { "AGILITY", "INTELLECT", "SPELL_POWER", "SPIRIT" },
	MAGE = { "INTELLECT", "SPELL_POWER" },
	WARLOCK = { "INTELLECT", "SPELL_POWER" },
	DRUID = { "AGILITY", "INTELLECT", "SPELL_POWER", "SPIRIT" },
	DEATHKNIGHT = { "STRENGTH" },
	MONK = { "AGILITY", "INTELLECT", "SPELL_POWER", "SPIRIT" },
}

-- { itemId, kind }
ns.SANITY_CHECK_TRASH = {
	-- Uncommon
	{ 81518, "UNCOMMON" }, -- Lory Feather Band (BoP)
	{ 81672, "UNCOMMON" }, -- Faded Forest Diviner's Rod (BoP)
	{ 82962, "UNCOMMON" }, -- Spiritguard Shield (BoE)
	{ 83211, "UNCOMMON" }, -- Wasteland Armored Girdle (BoP)
	{ 84097, "UNCOMMON" }, -- Shield of the Wakener (BoP)
	{ 84330, "UNCOMMON" }, -- Grainlord's Choker (BoP)
	-- Rare
	{ 55080, "RARE" }, -- Ornate Pyrium Gauntlets (BoE)
	{ 80895, "RARE" }, -- Yan-Zhu's Pressure Valve (BoP)
	{ 81066, "RARE" }, -- Yan-Zhu's Pressure Valve (BoP)
	{ 81134, "RARE" }, -- Barreldodger Boots (BoP)
	{ 81565, "RARE" }, -- Temperature-Sensing Necklace (BoP)
	{ 82419, "RARE" }, -- Tranquil Bracers (BoE)
	{ 82925, "RARE" }, -- Masterwork Spiritguard Boots (BoE)
	{ 82964, "RARE" }, -- Ghost-Forged Blade (BoE)
	{ 82973, "RARE" }, -- Masterwork Spiritblade Decimator (BoE)
	{ 87418, "RARE" }, -- Lerah's Ribsmasher (BoE)
	-- Bind on Equip epics
	{ 86189, "EPIC_BOE" }, -- Jagged Hornet Bracers (BoE)
	{ 90590, "EPIC_BOE" }, -- Dorian's Necklace of Burgeoning Dreams (BoE)
	{ 90721, "EPIC_BOE" }, -- Cournith Waterstrider's Silken Finery (BoE)
	{ 94578, "EPIC_BOE" }, -- Mooncleaver, Reborn (BoE)
	{ 94584, "EPIC_BOE" }, -- Dragonmaw, Reborn (BoE)
	{ 98614, "EPIC_BOE" }, -- Gorge Stalker Belt (BoE)
	-- Epics
	{ 86331, "EPIC" }, -- Taoren, the Soul Burner (BoP)
	{ 86973, "EPIC" }, -- Grasps of Panic (BoP)
	{ 87058, "EPIC" }, -- Chestguard of Total Annihilation (BoP)
	{ 89842, "EPIC" }, -- Gauntlets of the Shadow's Caress (BoP)
}

-- { itemId, kind }
ns.SANITY_CHECK_DUNGEON_BOSSES = {
	-- Uncommon
	{ 80740, "UNCOMMON" }, -- Ambermist Gloves (BoP)
	{ 82505, "UNCOMMON" }, -- Waterfall Robe (BoP)
	{ 83226, "UNCOMMON" }, -- Wasteland Leather Armwraps (BoP)
	{ 83703, "UNCOMMON" }, -- Steppebeast Gloves (BoP)
	{ 92360, "UNCOMMON" }, -- Partisan Greatsword (BoP)
	-- Rare
	{ 80930, "RARE" }, -- Swarmbringer Chestguard (BoP)
	{ 81079, "RARE" }, -- Staff of Trembling Will (BoP)
	{ 81111, "RARE" }, -- Airstream Treads (BoP)
	{ 81124, "RARE" }, -- Crystallized Droplet (BoP)
	{ 81127, "RARE" }, -- Flameheart Sandals (BoP)
	{ 81135, "RARE" }, -- Belt of Brazen Inebriation (BoP)
	{ 81190, "RARE" }, -- Grenadier's Belt (BoP)
	{ 81256, "RARE" }, -- Mind's Eye Breastplate (BoP)
	{ 81263, "RARE" }, -- Flashfrozen Resin Globule (BoP)
	{ 81271, "RARE" }, -- Engraved Amber Pendant (BoP)
	{ 81272, "RARE" }, -- Girdle of Soothing Detonation (BoP)
	{ 82816, "RARE" }, -- Melted Hypnotic Blade (BoP)
	{ 100950, "RARE" }, -- Engraved Amber Pendant (BoP)
	{ 100961, "RARE" }, -- Aerial Bombardment Cloak (BoP)
	-- Epics
	{ 87542, "EPIC" }, -- Mogu'Dar, Blade of the Thousand Slaves (BoP)
	{ 95966, "EPIC" }, -- Deeproot Treads (BoP)
	{ 95971, "EPIC" }, -- Abandoned Zandalari Moonstrap (BoP)
	{ 95974, "EPIC" }, -- Abandoned Zandalari Greatbelt (BoP)
}

-- { itemId, kind }
ns.SANITY_CHECK_RAID_BOSSES = {
	-- Uncommon
	{ 82530, "UNCOMMON" }, -- Summit Guardian Warboots (BoP)
	{ 82568, "UNCOMMON" }, -- Band of the Unsealed Tomb (BoP)
	{ 84610, "UNCOMMON" }, -- Ring of Shallowstep Pass (BoP)
	{ 101286, "UNCOMMON" }, -- Oathsworn Vambraces (BoP)
	-- Rare
	{ 66975, "RARE" }, -- Hood of the Crying Rogue (BoE)
	{ 80872, "RARE" }, -- Firebelcher Hand Cannon (BoP)
	{ 83666, "RARE" }, -- Swampwalker Robe (BoP)
	{ 90845, "RARE" }, -- Replica Shado-Pan Helmet (BoP)
	{ 100953, "RARE" }, -- Girdle of Soothing Detonation (BoP)
	-- Bind on Equip epics
	{ 65103, "EPIC_BOE" }, -- Soul Blade (BoE)
	{ 79330, "EPIC_BOE" }, -- Relic of Chi-Ji (BoE)
	{ 86192, "EPIC_BOE" }, -- Darting Damselfly Cuffs (BoE)
	{ 94580, "EPIC_BOE" }, -- Bloodmoon, Reborn (BoE)
	{ 94591, "EPIC_BOE" }, -- Blazefury, Reborn (BoE)
	{ 98612, "EPIC_BOE" }, -- Belt of the Night Sky (BoE)
	-- Epics
	{ 86204, "EPIC" }, -- Wingslasher Pauldrons (BoP)
	{ 86214, "EPIC" }, -- Monstrous Stompers (BoP)
	{ 86227, "EPIC" }, -- Kri'tak, Imperial Scepter of the Swarm (BoP)
	{ 86318, "EPIC" }, -- Casque of Expelled Corruption (BoP)
	{ 86389, "EPIC" }, -- Dreadwoven Leggings of Failure (BoP)
	{ 86758, "EPIC" }, -- Imperial Ghostbinder's Robes (BoP)
	{ 86834, "EPIC" }, -- Bonebreaker Gauntlets (BoP)
	{ 86859, "EPIC" }, -- Treads of Deadly Secretions (BoP)
	{ 87153, "EPIC" }, -- Asani's Uncleansed Sandals (BoP)
	{ 89819, "EPIC" }, -- Mindshard Drape (BoP)
	{ 90526, "EPIC" }, -- Cloak of Overwhelming Corruption (BoP)
	{ 90528, "EPIC" }, -- Asani's Uncleansed Sandals (BoP)
	-- Never Automated, quest items and Item Overrides
	{ 89237, "OTHER" }, -- Chest of the Shadowy Conqueror (BoP)
	{ 87777, "OTHER" }, -- Reins of the Astral Cloud Serpent (BoP)
}

--[[
How We Got the Data

Last Validated
	2026-11-27, wago.tools, MoP Classic 5.5.4.71089

Notes
	- Character Rules' armor and weapon rows, and what each class starts with ticked. A row is an item subclass ID, or a name for a row no subclass names. Gear that is a ticked type and carries a ticked stat is left to the player to roll; the rest of the gear is greeded (Features/Character-Rules.lua).
	- SANITY_CHECK_TRASH, SANITY_CHECK_DUNGEON_BOSSES and SANITY_CHECK_RAID_BOSSES: the Loot Roll Sanity Check's drops, picked from Wowhead's mop-classic item data (zone drop tables for the dungeons and raids of this expansion's last level band, and its most popular items of each quality for gear outside them), then each item checked one by one against Wowhead's tooltip for this client for its quality, its binding and fixed stats (no random enchantment), on 2026-11-16. Not literally from that kind of kill: a section mixes Bind on Pickup and Bind on Equip, and every section holds at least four greens and five blues, and Trash and Raid Bosses at least six Bind on Equip epics, so a draw can always show two of each (Options/Options-Sanity-Check.lua). OTHER rows are picked by hand to show a gate: a mount or legendary (Never Automated), a quest item or token, or a default Item Overrides row. Diagnostics' Validate Data lists each row with its kind, to compare against the item's quality in game.
	- The Sanity Check draws ten at a time from one list per section (Options/Options-Sanity-Check.lua). kind is UNCOMMON, RARE, EPIC_BOE or EPIC by the item's quality and binding, so a draw can promise each section its greens, blues and Bind on Equip epics, or OTHER for a row that shows one of Automated Rolls' gates. A row this client doesn't have is never drawn.
	- The starter lists every character gets until the player changes a box, worked out from Play It Forward's Match-Armor, Match-Weapons and Match-Specs tables, which its author validated on this client (its tables as of 2026-10-29, MoP Classic 5.5.4.70631). Nothing is saved until the player changes a box, and Reset to Class Defaults clears what was saved.
	- Armor: every material the class can wear, its own and every lighter one (Play It Forward's NATIVE_ARMOR steps give the heaviest), so a paladin starts with Cloth, Leather, Mail and Plate and a druid with Cloth and Leather. Play It Forward ticks only the class's own materials; GogoLoot ticks the lighter ones too, mostly for healers, who wear them (maintainer, 2026-11-07). Shields, held off-hands and relics: the classes whose Play It Forward WEAPON_SPECS count is above 0.
	- Weapons: every type the class can train (WEAPON_SPECS above 0), assuming the character has trained everything (maintainer, 2026-11-07).
	- Stats: each spec's main stats, plus the role stats its useful list names (attack power, spell power, healing, mana per 5, Spirit), mapped to Character Rules' stat keys: RANGED_AP and FERAL_AP are ATTACK_POWER, SPELL_DAMAGE and the school damages are SPELL_POWER, HEALING is HEALING_POWER. A useful primary stat (a warrior's Agility, a hunter's Intellect) is left out, so gear built on it isn't held for the class. Stamina starts unticked for every class, and crit and hit ticked for every class (everyClass in ns.CHARACTER_RULE_STATS), so neither is listed here.
	- "HELD" is the held off-hand row (orbs, tomes, lanterns). Those items are armor subclass 0 Miscellaneous, like rings, so Features/Character-Rules.lua tells them apart by their INVTYPE_HOLDABLE slot.
	- Cloaks are cloth (armor subclass 1) on every client, so Features/Character-Rules.lua treats INVTYPE_CLOAK as a slot with no type, like rings, necks and trinkets: stats alone decide them. Shirts and tabards never get a rule.
	- Weapon subclasses with no row of their own (9, 11 and 12, obsolete and exotic; 14 Miscellaneous; 17 Spears; 20 Fishing Poles) fall to the Other row (Data/Data.lua), which starts unticked for every class.
	- No relic rows: Librams, Idols and Totems left the game in Mists of Pandaria, and Thrown went with the ranged slot.
	- Hunters start with bows, guns and crossbows only, as Play It Forward lists them: from Mists of Pandaria on the ranged weapon is a hunter's main hand.
	- Play It Forward's Mists specs name healing and spell damage, which merged into spell power on this client, so both start as SPELL_POWER; its healer and hybrid-caster specs gear for Spirit, which starts ticked for them.
	- Rechecked against this client's tables at build 5.5.4.71089: every armor and weapon row is a subclass in ItemSubClass, and every Sanity Check drop is in ItemSparse at the quality and binding its kind and comment give, with no random enchantment.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	https://www.wowhead.com/mop-classic (dataEnv 15), the Sanity Check lists only

wago.tools
	https://wago.tools/db2/ItemSubClass?build=5.5.4.70960
	https://wago.tools/db2/ItemSparse?build=5.5.4.70960
	https://wago.tools/db2/Item?build=5.5.4.70960
	https://wago.tools/db2/ItemSubClass?build=5.5.4.71089
	https://wago.tools/db2/ItemSparse?build=5.5.4.71089
	https://wago.tools/db2/Item?build=5.5.4.71089

QuestieDB
	None.
]]
