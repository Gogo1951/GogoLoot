--------------------------------------------------------------------------------
-- GogoLoot Named Timers
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    Scheduling a pending identifier replaces it. C_Timer.After has no cancel, so
    a superseded or canceled timer still fires and checks its generation.
    Generations are global, not per identifier: canceling forgets the
    identifier, so a per-identifier count would restart and let a canceled
    timer match its replacement.
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
