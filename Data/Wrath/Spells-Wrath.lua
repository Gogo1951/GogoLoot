-- Data/Wrath/Spells-Wrath.lua
local _, ns = ...

--[[
    Hand-set spell IDs, not generated. Each is checked against the Wrath Classic
    client's SpellName table on wago.tools, build 3.4.4.61581, where Shadowmeld
    is 58984: this client has no spell 20580.

    LOCKPICKING is the skill spell behind skill line 633, not something a player
    casts. It is here because its NAME is the localized name of the Lockpicking
    skill line, which is the only handle Features/Lockbox-Tooltips.lua has for
    finding the player's rank in GetSkillLineInfo.
]]
-- { [key] = spellId }
ns.SPELLS = {
	PICK_LOCK = 1804,
	PICK_POCKET = 921,
	SHADOWMELD = 58984,
}
