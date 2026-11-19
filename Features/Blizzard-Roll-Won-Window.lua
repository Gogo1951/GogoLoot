--------------------------------------------------------------------------------
-- GogoLoot Blizzard Roll Won Window
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    WoW Forever's AlertFrame listens for LOOT_ITEM_ROLL_WON and answers with
    its "You Won" window (LootAlertSystem, the roll type and winning roll on
    it), a second, unmatched copy of what the toasts already say. The Classic
    clients' AlertFrame never registers the event (Gethe/wow-ui-source,
    Blizzard_FrameXML/Classic/AlertFrames.lua on the Era, Anniversary and
    Mists branches), so there is no window there and no option either.

    With Enable Loot Toasts on and Enable Blizzard Default Roll Winner Window
    off, GogoLoot unregisters that one event from AlertFrame, and registers it
    back with either changed. Only that event: SHOW_LOOT_TOAST also feeds the
    money, currency and other loot alerts, which stay, and other add-ons' own
    registrations (Memento's screenshots) are untouched. AlertFrame isn't
    protected, so flipping its events taints nothing, in combat or out.
    Whether it listened is read once, before GogoLoot first touches it, so a
    client whose AlertFrame never did is never made to.
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
