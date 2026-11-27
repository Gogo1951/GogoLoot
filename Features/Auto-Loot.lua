--------------------------------------------------------------------------------
-- GogoLoot Auto Loot
--------------------------------------------------------------------------------

--[[
    Speedy Loot and Automated Opening both need the game's Auto Loot, so it is
    enforced while either is on; the two switches are the opt-out. It prints
    nothing: both features' descriptions disclose it.
]]
local _, ns = ...

---@return boolean
function ns:IsAutoLootNeeded()
	return ns.db ~= nil and (ns.db.global.speedyLoot or ns.db.profile.autoOpen) and true or false
end

---@return nil
function ns.EnsureAutoLoot()
	if not ns:IsAutoLootCVarEnabled() then
		C_CVar.SetCVar("autoLootDefault", "1")
	end
end

-- Set when scheduled, so a feature turned on later still gets enforced at the next loading screen.
local hasCheckedAutoLoot = false

local function OnPlayerEnteringWorld()
	if hasCheckedAutoLoot or not ns:IsAutoLootNeeded() then
		return
	end
	hasCheckedAutoLoot = true
	C_Timer.After(3, ns.EnsureAutoLoot)
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
