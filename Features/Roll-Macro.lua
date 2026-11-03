--------------------------------------------------------------------------------
-- GogoLoot Roll Macro Module
--------------------------------------------------------------------------------

--[[
    Keeps the Roll Macro (ns.ROLL_MACRO_NAME, Data.lua) among the player's
    General macros while ns.db.global.rollMacro is on: made if it's missing, and
    put back if its icon or text was changed. Switching the setting off deletes
    it. Nothing is deleted at login, so a macro of the same name the player made
    themselves is only ever touched while the switch is on.

    The game refuses macro changes in combat, so a change asked for there waits
    for PLAYER_REGEN_ENABLED.
]]
local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

-- The game's shortest command for its Macros window, the same in every locale.
local MACRO_COMMAND = "/m"

-- The change waiting on combat to end, and whether it prints when it lands.
local pendingAction = nil
local pendingAnnounce = false

-- A full General tab is reported once a session at login; switching it on always reports.
local warnedMacrosFull = false

--------------------------------------------------------------------------------
-- Macro Changes
--------------------------------------------------------------------------------

---@param announce boolean
---@return nil
local function AddRollMacro(announce)
	local name = ns.ROLL_MACRO_NAME
	local index = GetMacroIndexByName(name)
	if index and index > 0 then
		-- The client may hand the text back with a trailing newline.
		local _, icon, body = GetMacroInfo(index)
		if icon ~= ns.ROLL_MACRO_ICON or string.gsub(body or "", "%s+$", "") ~= ns.ROLL_MACRO_BODY then
			EditMacro(index, name, ns.ROLL_MACRO_ICON, ns.ROLL_MACRO_BODY)
		end
	else
		-- CreateMacro errors rather than returning when the General tab is full.
		local ok, created = pcall(CreateMacro, name, ns.ROLL_MACRO_ICON, ns.ROLL_MACRO_BODY, false)
		if not ok or not created or created == 0 then
			if announce or not warnedMacrosFull then
				warnedMacrosFull = true
				ns:PrintMessage(L["ROLL_MACRO_FULL_LOADING"]:format(name))
			end
			return
		end
	end
	if announce then
		ns:PrintMessage(L["ROLL_MACRO_ADDED"]:format(name, GetColor("INFO") .. MACRO_COMMAND .. "|r"))
	end
end

---@param announce boolean
---@return nil
local function DeleteRollMacro(announce)
	local index = GetMacroIndexByName(ns.ROLL_MACRO_NAME)
	if not index or index == 0 then
		return
	end
	DeleteMacro(index)
	if announce then
		ns:PrintMessage(L["ROLL_MACRO_REMOVED"]:format(ns.ROLL_MACRO_NAME))
	end
end

---@param action function
---@param announce boolean
---@return nil
local function RunOutOfCombat(action, announce)
	if InCombatLockdown() then
		pendingAction = action
		pendingAnnounce = announce
		return
	end
	pendingAction = nil
	action(announce)
end

--[[
    Called by the Enable Roll Macro switch once the setting is saved: adds the
    macro when it's on, deletes it when it's off, and says which in chat.
]]
---@return nil
function ns.ApplyRollMacro()
	RunOutOfCombat(ns.db.global.rollMacro and AddRollMacro or DeleteRollMacro, true)
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- Every load, so a macro deleted or edited by hand comes back.
local function OnPlayerEnteringWorld()
	if ns.db and ns.db.global.rollMacro then
		RunOutOfCombat(AddRollMacro, false)
	end
end

local function OnPlayerRegenEnabled()
	if pendingAction then
		RunOutOfCombat(pendingAction, pendingAnnounce)
	end
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)
