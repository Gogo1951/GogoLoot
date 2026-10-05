-- Data/Discovery/Spells-Discovery.lua
local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- Copied from Data/Vanilla until Validate Data passes on this client.
-- { [key] = spellId }
ns.SPELLS = {
	PICK_LOCK = 1804,
	PICK_POCKET = 921,
	SHADOWMELD = 20580,
}
