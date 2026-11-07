local _, ns = ...

-- { statKey }
ns.CHARACTER_RULE_STAT_KEYS = {
	"STRENGTH",
	"AGILITY",
	"STAMINA",
	"INTELLECT",
	"SPIRIT",
	"SPELL_POWER",
	"HEALING_POWER",
	"ATTACK_POWER",
	"CRIT",
	"HIT",
	"MP5",
}

--[[
    { [spellId] = { statKey, ... } }: one item "Equip:" spell for every way this
    client words a stat line, and the stats it carries. Features/Character-
    Rules.lua builds each line's pattern from the spell's own description.
    Several IDs word differently here than on Classic Era (7678 carries damage
    too), which is why each folder keeps its own list.
]]
ns.CHARACTER_RULE_EQUIP_SPELLS = {
	-- Spell power and healing
	[9397] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases damage and healing done by magical spells and effects by up to #.
	[7678] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases healing done by up to # and damage done by up to # for all magical spells and effects.
	[28155] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases your spell damage by up to # and your healing by up to #.
	[43921] = { "SPELL_POWER" }, -- Increases damage done by magical spells and effects by up to #.
	[7706] = { "SPELL_POWER" }, -- Increases damage done by Shadow spells and effects by up to #.
	[7689] = { "SPELL_POWER" }, -- Fire
	[7700] = { "SPELL_POWER" }, -- Frost
	[7696] = { "SPELL_POWER" }, -- Nature
	[13598] = { "SPELL_POWER" }, -- Arcane
	[21518] = { "SPELL_POWER" }, -- Holy
	[42041] = { "SPELL_POWER" }, -- Increases the damage done by Holy spells and effects by up to #.
	-- Attack power
	[9330] = { "ATTACK_POWER" }, -- Increases attack power by #.
	[24694] = { "ATTACK_POWER" }, -- Increases attack power by # in Cat, Bear, Dire Bear, and Moonkin forms only.
	[21433] = { "ATTACK_POWER" }, -- Increases ranged attack power by #.
	[28347] = { "ATTACK_POWER" }, -- Increases melee and ranged attack power by #.
	-- Mana per 5
	[18378] = { "MP5" }, -- Restores # mana per 5 sec.
	-- Crit
	[7597] = { "CRIT" }, -- Increases your critical strike rating by #.
	[18382] = { "CRIT" }, -- Increases your spell critical strike rating by #.
	[24433] = { "CRIT" }, -- Increases spell critical strike rating by #.
	[24852] = { "CRIT" }, -- Increases your critical strike rating with Nature spells by #.
	[9132] = { "CRIT" }, -- Increases your ranged critical strike rating by #.
	[23434] = { "CRIT" }, -- Improves your chance to get a critical strike with spells by #%.
	-- Hit
	[15464] = { "HIT" }, -- Increases your hit rating by #.
	[23727] = { "HIT" }, -- Increases your spell hit rating by #.
}

--[[
How We Got the Data

Last Validated
	2026-11-03, TBC Anniversary 2.5.6.70577

Notes
	- The stat keys Character Rules offers on this client, from ns.CHARACTER_RULE_STATS (Data/Data.lua); Features/Character-Rules.lua drops the rest, and any section left empty, at load.
	- Every stat. The primary attributes come from GetItemStats and the tooltip's stat lines; the secondary stats (spell power, healing, attack power, crit, hit and mana per 5) are "Equip:" item spells, read off the tooltip through CHARACTER_RULE_EQUIP_SPELLS.
	- CHARACTER_RULE_EQUIP_SPELLS: every item spell with an On Equip trigger (ItemEffect.TriggerType 1) whose effects apply a stat aura (SpellEffect.EffectAura 13 spell damage, except the physical-only school mask 1; 135 healing; 99 and 124 attack power; 85 mana regeneration; 52 and 57 crit; 54 and 55 hit; on TBC, 189 ratings for crit and hit), grouped by Spell.Description_lang, keeping one spell per wording. Wordings no item carries more than once were kept when they read as plain stats and dropped when they don't (a set bonus, a one-off proc). Defense, dodge, parry, block and weapon skill have no box, so they are left out.
	- Each wording's pattern is built in game from the spell's own description in the player's language (Features/Character-Rules.lua), so nothing here is localized, and no pattern was taken from another add-on.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellEffect?build=2.5.6.70577
	https://wago.tools/db2/Spell?build=2.5.6.70577

QuestieDB
	None.
]]
