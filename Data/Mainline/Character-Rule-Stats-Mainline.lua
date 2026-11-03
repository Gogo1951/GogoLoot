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
How We Got the Data

Last Validated
	Never. Copied from Data/Wrath/.

Notes
	- The stat keys Character Rules offers on this client, from ns.CHARACTER_RULE_STATS (Data/Data.lua); Features/Character-Rules.lua drops the rest, and any section left empty, at load.
	- Every key: this client's items carry their secondary stats as item stats GetItemStats reports.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
