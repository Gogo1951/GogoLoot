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

-- { [spellId] = { statKey, ... } }
ns.CHARACTER_RULE_EQUIP_SPELLS = {}

--[[
How We Got the Data

Last Validated
	2026-11-07, WoW Forever 1.60.1.70862

Notes
	- The stat keys Character Rules offers on this client, from ns.CHARACTER_RULE_STATS (Data/Data.lua); Features/Character-Rules.lua drops the rest, and any section left empty, at load.
	- Every key: this client's items carry their secondary stats as item stats GetItemStats reports.
	- CHARACTER_RULE_EQUIP_SPELLS is empty on purpose: this client reports every secondary stat through GetItemStats, so no "Equip:" line needs matching.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
