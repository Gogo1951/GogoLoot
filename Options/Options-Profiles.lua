--------------------------------------------------------------------------------
-- GogoLoot Options — Profiles
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 profiles panel (profile picker, Copy From,
    Delete a Profile, Reset Profile) extended with one custom control: Reset
    All Profiles, which resets every profile on the account (ns:ResetAllProfiles
    in Features/Core.lua). Registered second-to-last, directly above Diagnostic
    Tools. The stock widgets are never re-labeled or reordered.
]]
local _, ns = ...
local L = ns.L

function ns.BuildProfilesOptions()
    local options = LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db)
    options.args.resetAllProfiles = {
        type = "execute",
        name = L["OPTIONS_RESET_ALL_PROFILES"],
        desc = L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"],
        confirm = true,
        confirmText = L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"],
        func = function()
            ns:ResetAllProfiles()
        end,
        order = 100
    }
    return options
end
