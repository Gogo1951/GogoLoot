--------------------------------------------------------------------------------
-- GogoLoot Options — Registration
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Initialization & Registration
--------------------------------------------------------------------------------

--[[
    AceConfigRegistry table names (first arg to RegisterOptionsTable / first
    arg to AddToBlizOptions) are stable identifiers and intentionally NOT
    localized — they're used by NotifyChange calls across modules.

    The user-facing display names passed as the SECOND arg to
    AddToBlizOptions, and the parent reference (THIRD arg), are localized
    via the TAB_* locale keys. The parent reference must match the display
    name registered for the parent panel exactly so the child panels nest
    correctly under the main GogoLoot category. OpenOptionsPanel below
    routes by the category ID captured from the main-panel registration
    rather than by name.
]]

function ns:InitializeOptions()
    AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)

    if ns.BuildAnnouncementOptions then
        AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Announcements, ns.BuildAnnouncementOptions)
    end

    if ns.BuildAutomatedRollOptions then
        AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.AutomatedRolls, ns.BuildAutomatedRollOptions)
    end

    if ns.BuildMasterLooterOptions then
        AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.MasterLooter, ns.BuildMasterLooterOptions)
    end

    if ns.BuildDiagnosticsOptions then
        AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
    end

    -- The Profiles panel is the stock AceDBOptions table plus Reset All Profiles (Options-Profiles.lua).
    if ns.BuildProfilesOptions then
        AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Profiles, ns.BuildProfilesOptions)
    end

    --[[
        On clients with the Settings API, AddToBlizOptions returns the panel
        frame and, as a second value, the Settings category ID. Capture it so
        OpenOptionsPanel can route directly to this category without a
        name-based lookup.
    ]]
    local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])
    ns.optionsFrames = {main = mainPanel, categoryID = mainCategoryID}

    --[[
        Child-panel display order in Blizzard's settings UI is the order of
        AddToBlizOptions calls: Master Looter, Automated Rolls, Announcements,
        Profiles — with Diagnostics registered last so it sits at the bottom.
    ]]
    if ns.BuildMasterLooterOptions then
        ns.optionsFrames.ml =
            AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.MasterLooter, L["TAB_MASTER_LOOTER"], L["ADDON_TITLE"])
    end

    if ns.BuildAutomatedRollOptions then
        ns.optionsFrames.rolls =
            AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.AutomatedRolls, L["TAB_AUTOMATED_ROLLS"], L["ADDON_TITLE"])
    end

    if ns.BuildAnnouncementOptions then
        ns.optionsFrames.trade =
            AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Announcements, L["TAB_ANNOUNCEMENTS"], L["ADDON_TITLE"])
    end

    if ns.BuildProfilesOptions then
        -- The panel's display name comes already-localized from AceDBOptions-3.0; read it from the built table.
        local profilesDisplayName = ns.BuildProfilesOptions().name
        ns.optionsFrames.profiles =
            AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Profiles, profilesDisplayName, L["ADDON_TITLE"])
    end

    -- Diagnostics added last so it sits at the bottom of the settings tree.
    -- Its display name is a developer-facing string (never localized) from ns.DiagnosticsStrings.
    if ns.BuildDiagnosticsOptions then
        ns.optionsFrames.diagnostics =
            AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, L["ADDON_TITLE"])
    end

    ns:WarmItemCache()
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

function ns:OpenOptionsPanel()
    if not ns.optionsFrames then
        return
    end

    if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
        Settings.OpenToCategory(ns.optionsFrames.categoryID)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(ns.optionsFrames.main)
        -- Called twice for Classic compatibility
        InterfaceOptionsFrame_OpenToCategory(ns.optionsFrames.main)
        return
    end

    AceConfigDialog:Open(ns.OPTIONS_REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_GOGOLOOT1 = "/gl"
SLASH_GOGOLOOT2 = "/gogoloot"
SlashCmdList["GOGOLOOT"] = function()
    ns:OpenOptionsPanel()
end