--------------------------------------------------------------------------------
-- GogoLoot Options — Profiles
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 profiles panel (profile picker, Copy From,
    Delete a Profile, Reset Profile), registered second-to-last, directly above
    Diagnostic Tools. The profile-refresh hooks live in Features/Core.lua.
]]
local _, ns = ...

---@return table
function ns.BuildProfilesOptions()
	--[[
	    Return the stock table as-is. Never mutate it: AceDBOptions shares ONE
	    args table across every database it serves, so anything written into it
	    appears inside every other Ace3 add-on's Profiles panel on the account.
	]]
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db)
end
