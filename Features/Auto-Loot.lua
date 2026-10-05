--------------------------------------------------------------------------------
-- GogoLoot Auto Loot
--------------------------------------------------------------------------------

--[[
    Speedy Loot and Automated Opening both depend on the game's Auto Loot
    setting: Speedy Loot only speeds up what Auto Loot takes, and a container
    Automated Opening opens would otherwise sit in an open loot window. So the
    autoLootDefault CVar is enforced while either feature is on, and the two
    feature toggles are the opt-out every enforced write has to carry. The
    write only ever fires when the CVar is actually off, and always announces
    itself.
]]
local _, ns = ...
local L = ns.L

---@return boolean
function ns:IsAutoLootNeeded()
	return ns.db ~= nil and (ns.db.global.speedyLoot or ns.db.profile.autoOpen) and true or false
end

--[[
    Called at login when either feature is on, whenever either is switched on,
    and on a profile switch that brings Automated Opening with it.
]]
---@return nil
function ns.EnsureAutoLoot()
	if not ns:IsAutoLootCVarEnabled() then
		SetCVar("autoLootDefault", "1")
		ns:PrintMessage(L["MESSAGE_AUTO_LOOT_SETTING_ON"]:format(AUTO_LOOT_DEFAULT_TEXT))
	end
end

--[[
    Only enforce for a player actually running one of the two features. The
    one-shot flag is set when the check is scheduled rather than on the first
    fire, so turning a feature on later still gets its login-time enforcement on
    the next loading screen.
]]
local hasCheckedAutoLoot = false

local function OnPlayerEnteringWorld()
	if hasCheckedAutoLoot or not ns:IsAutoLootNeeded() then
		return
	end
	hasCheckedAutoLoot = true
	C_Timer.After(3, ns.EnsureAutoLoot)
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
