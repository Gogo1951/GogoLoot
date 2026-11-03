local _, ns = ...

-- { statKey }
ns.CHARACTER_RULE_STAT_KEYS = {
	"STRENGTH",
	"AGILITY",
	"STAMINA",
	"INTELLECT",
	"SPIRIT",
	"SPELL_POWER",
	"ATTACK_POWER",
	"CRIT",
	"HIT",
}

--[[
How We Got the Data

Last Validated
	2026-11-03, MoP Classic 5.5.4.70631

Notes
	- The stat keys Character Rules offers on this client, from ns.CHARACTER_RULE_STATS (Data/Data.lua); Features/Character-Rules.lua drops the rest, and any section left empty, at load.
	- The primary attributes and the secondary stats this client's items carry as item stats GetItemStats reports: spell power, attack power, crit and hit.
	- Healing and mana regeneration are left out. Healing merged into spell power in Wrath, and ItemSparse at build 5.5.4.70631 carries the healing stat (41) on 2 items and mana per 5 (43) on 11, against spell power (45) on 1,518. On this client ITEM_MOD_POWER_REGEN0_SHORT, the Mana Per 5 label, is also nil (Diagnostics' Game Names report), so that row would show with no name.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631

QuestieDB
	None.
]]
