--------------------------------------------------------------------------------
-- GogoLoot Blizzard Roll Won Window
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    Only that one event: SHOW_LOOT_TOAST also feeds the money, currency and
    other loot alerts. AlertFrame isn't protected, so this taints nothing. The
    Classic clients' AlertFrame never registers it; whether it listened is read
    once, before GogoLoot first touches it, so it is never made to.
]]
local ROLL_WON_EVENT = "LOOT_ITEM_ROLL_WON"
local blizzardRollWonListens

---@return boolean # whether this client's AlertFrame puts up a window for a roll won
function ns.HasBlizzardRollWonWindow()
	if blizzardRollWonListens == nil then
		local alertFrame = AlertFrame
		if not alertFrame or not alertFrame.IsEventRegistered then
			return false
		end
		blizzardRollWonListens = alertFrame:IsEventRegistered(ROLL_WON_EVENT) and true or false
	end
	return blizzardRollWonListens
end

---@return nil
function ns.SyncBlizzardRollWonWindow()
	if not ns.db or not ns.HasBlizzardRollWonWindow() then
		return
	end
	local profile = ns.db.profile
	if profile.lootToasts and not profile.lootToastBlizzardRollWon then
		AlertFrame:UnregisterEvent(ROLL_WON_EVENT)
	else
		AlertFrame:RegisterEvent(ROLL_WON_EVENT)
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnPlayerEnteringWorld()
	ns.SyncBlizzardRollWonWindow()
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
