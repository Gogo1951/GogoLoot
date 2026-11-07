local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

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
]]
ns.CHARACTER_RULE_EQUIP_SPELLS = {
	-- Spell power and healing
	[9397] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases damage and healing done by magical spells and effects by up to #.
	[467142] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases healing done by up to # and damage done by up to # for all magical spells and effects.
	[28155] = { "SPELL_POWER", "HEALING_POWER" }, -- Increases your spell damage by up to # and your healing by up to #.
	[7678] = { "HEALING_POWER" }, -- Increases healing done by spells and effects by up to #.
	[7706] = { "SPELL_POWER" }, -- Increases damage done by Shadow spells and effects by up to #.
	[7700] = { "SPELL_POWER" }, -- Frost
	[7689] = { "SPELL_POWER" }, -- Fire
	[21503] = { "SPELL_POWER" }, -- Holy
	[7696] = { "SPELL_POWER" }, -- Nature
	[13598] = { "SPELL_POWER" }, -- Arcane
	[468785] = { "SPELL_POWER" }, -- Shadow and Arcane
	-- Attack power
	[9330] = { "ATTACK_POWER" }, -- +# Attack Power.
	[24994] = { "ATTACK_POWER" }, -- +# Attack Power in Cat, Bear, and Dire Bear forms only.
	[21433] = { "ATTACK_POWER" }, -- +# ranged Attack Power.
	-- Mana per 5
	[18378] = { "MP5" }, -- Restores # mana per 5 sec.
	-- Crit
	[436239] = { "CRIT" }, -- Improves your chance to get a critical strike with all spells and attacks by #%.
	[7597] = { "CRIT" }, -- Improves your chance to get a critical strike by #%.
	[23434] = { "CRIT" }, -- Improves your chance to get a critical strike with spells by #%.
	[9132] = { "CRIT" }, -- Improves your chance to get a critical strike with missile weapons by #%.
	-- Hit
	[432639] = { "HIT" }, -- Improves your chance to hit with all spells and attacks by #%.
	[15464] = { "HIT" }, -- Improves your chance to hit by #%.
	[23727] = { "HIT" }, -- Improves your chance to hit with spells by #%.
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Season of Discovery 1.15.9.70576

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
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/Spell?build=1.15.9.70576

QuestieDB
	None.
]]
