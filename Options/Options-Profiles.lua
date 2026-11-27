--------------------------------------------------------------------------------
-- GogoLoot Options — Profiles
--------------------------------------------------------------------------------

local _, ns = ...

---@return table
function ns.BuildProfilesOptions()
	--[[
	    Never mutate it: AceDBOptions shares ONE args table across every
	    database, so anything written here appears in every other Ace3 add-on's
	    Profiles panel.
	]]
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db)
end
