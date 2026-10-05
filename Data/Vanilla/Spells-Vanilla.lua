local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- { [key] = spellId }
ns.SPELLS = {
	PICK_LOCK = 1804,
	PICK_POCKET = 921,
	SHADOWMELD = 20580,
}

--[[
How We Got the Data

Last Validated
	2026-10-04, Classic Era 1.15.9.70003

Notes
	- The spells GogoLoot listens for or reads, hand-picked, each under the key the code uses.
	- PICK_LOCK is the Rogue's Pick Lock. A successful cast makes Automated Opening look through the bags again, so a box opens as soon as it is unlocked (Features/Automated-Opening.lua).
	- PICK_POCKET is the Rogue's Pick Pocket. A successful cast arms the pick-pocket sound for the loot window that follows (Features/Loot-Sounds.lua), and its name captions that sound's option (Options/Options-Loot-Sounds.lua).
	- SHADOWMELD is the Night Elf racial. Automated Opening waits while its aura is up, as it does in stealth (Features/Automated-Opening.lua).
	- The Lockpicking skill line Lockbox Tooltips reads is SKILL_LINE_IDS.LOCKPICKING in Game-IDs, not a spell.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.
]]
