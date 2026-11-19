--------------------------------------------------------------------------------
-- GogoLoot Named Timers
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    C_Timer.After with a cancel handle. Scheduling an identifier that is already
    pending replaces it, so a caller never has to hand-roll a guard flag to stop
    a stale callback from firing, and ns:CancelTimer kills one outright.

    The scheduled closure checks its own generation before running:
    C_Timer.After has no cancel, so a superseded or canceled timer still fires
    and must no-op.
    Generations are globally unique rather than counted per identifier: canceling
    forgets the identifier, so a per-identifier count would restart and let a
    canceled timer match the generation of the one that replaced it, running the
    canceled callback and swallowing the replacement.
]]
local scheduledTimers = {}
local timerGeneration = 0

---@param identifier string
---@param seconds number
---@param callback function
---@return nil
function ns:After(identifier, seconds, callback)
	timerGeneration = timerGeneration + 1
	local generation = timerGeneration
	scheduledTimers[identifier] = generation

	C_Timer.After(seconds, function()
		if scheduledTimers[identifier] ~= generation then
			return
		end
		scheduledTimers[identifier] = nil
		callback()
	end)
end

---@param identifier string
---@return nil
function ns:CancelTimer(identifier)
	scheduledTimers[identifier] = nil
end

---@param identifier string
---@return boolean
function ns:IsTimerPending(identifier)
	return scheduledTimers[identifier] ~= nil
end
