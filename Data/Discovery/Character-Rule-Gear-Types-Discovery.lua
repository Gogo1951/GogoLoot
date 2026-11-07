local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

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
	MAGE = { "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER" },
	WARLOCK = { "INTELLECT", "SPELL_POWER" },
	DRUID = { "AGILITY", "ATTACK_POWER", "HEALING_POWER", "INTELLECT", "MP5", "SPELL_POWER", "SPIRIT", "STRENGTH" },
}

--[[
    { itemId, ... }: ten Bind on Equip greens for Character Rules' Sanity
    Check, in the order it lists them: one per armor material and stat mix
    the starter lists split on, a weapon, a ring and a held off-hand. Crafted
    pieces with fixed stats, so every client draws the same item.
]]
ns.CHARACTER_RULE_SAMPLE_ITEMS = {
	12427, -- Imperial Plate Helm: plate, Strength and Stamina
	7930, -- Heavy Mithril Breastplate: plate, Stamina only
	3836, -- Green Iron Helm: mail, Strength and Stamina
	8189, -- Turtle Scale Breastplate: mail, Intellect, Spirit and Stamina
	8175, -- Nightscape Tunic: leather, Agility and Stamina
	15094, -- Runic Leather Headband: leather, Intellect and Spirit
	13857, -- Runecloth Tunic: cloth, Intellect and Spirit
	7943, -- Wicked Mithril Blade: one-handed sword, Strength and Agility
	5743, -- Prismstone Ring: ring, Intellect
	15927, -- Bright Sphere: held in off-hand, Intellect and Spirit
}

--[[
How We Got the Data

Last Validated
	Not yet checked in game (Play It Forward's tables: 2026-10-29, Season of Discovery 1.15.9.70576)

Notes
	- CHARACTER_RULE_SAMPLE_ITEMS: items that are Uncommon and Bind on Equip with fixed stats (ItemSparse.OverallQualityID 2, Bonding 2, RandomSelect 0) on Classic Era, TBC, MoP Classic and WoW Forever alike, hand-picked to cover the armor materials and stat mixes the starter lists split on. The same ten in every folder.
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
	None.

wago.tools
	https://wago.tools/db2/ItemSparse
	https://wago.tools/db2/ItemSubClass

QuestieDB
	None.
]]
