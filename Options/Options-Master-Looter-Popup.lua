--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter Pop-up
--------------------------------------------------------------------------------

--[[
    The window that opens when the player becomes master looter, so a run can be
    set up without going through Options. It carries the same rows the Master
    Looter panel opens with, built from the shared row builders in
    Options-Master-Looter.lua and Options-Announcements.lua so the two can never
    drift: the pop-up's own on/off toggle, the destination-message toggle, then
    loot method, loot threshold, and Send All Loot To.

    This is an AceConfigDialog standalone window rather than a hand-built frame:
    it is registered with AceConfigRegistry like any other panel but never passed
    to AddToBlizOptions, so it takes the add-on's existing widget styling and
    stays out of the Blizzard settings tree. Nothing here is protected, so
    opening it during combat is safe.
]]
local _, ns = ...
local L = ns.L
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--[[
    Sized to the window's tallest state: both toggles, the leader note and its
    spacer, and all three label-plus-dropdown rows. That state is also the common
    one — the note shows precisely when somebody else handed you the role, which
    is the usual way this window opens.

    One height serves every open. Rows that do not apply to the current loot
    method hide rather than shrink the window, because AceConfigDialog takes the
    frame size from the status table this writes and never from how much content
    is on show, so a height sized to anything less scrolls in the fullest case.
]]
local POPUP_WIDTH = 500
local POPUP_HEIGHT = 320

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildMasterLooterPopupOptions()
	local args = {}
	local order = 1

	--[[
	    The pop-up's own switch first, because this window is where you are most
	    likely to want it: it opened on its own, and the alternative to a switch
	    here is going and finding one in Options. Then the destination-message
	    toggle, because the destination you are about to set below is exactly what
	    it decides whether to announce.
	]]
	order = ns.AddPopupToggleRow(args, order)
	order = ns.AddDestinationMessagesRow(args, order)
	args.spacerAfterToggles = ns.OptionsSpacer(order)
	order = order + 1

	-- Says who controls the two dropdowns below when it isn't you.
	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = ns.OptionsSpacer(order)
	args.spacerAfterLootType.hidden = ns.IsLootThresholdIrrelevant
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerAfterLootThreshold = ns.OptionsSpacer(order)
	order = order + 1
	--[[
	    The destination only means anything under master loot, so it is hidden
	    outright rather than left visible and inert when the method above it says
	    anything else.
	]]
	order = ns.AddSendAllDestinationRow(args, order, function()
		return ns:SafeGetLootMethod() ~= "master"
	end)

	return {
		type = "group",
		name = L["MASTER_LOOTER_POPUP_TITLE"],
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

---@return nil
function ns:ShowMasterLooterPopup()
	AceConfigDialog:SetDefaultSize(ns.OPTIONS_REGISTRY.MasterLooterPopup, POPUP_WIDTH, POPUP_HEIGHT)
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.MasterLooterPopup)

	--[[
        Fixed size: the window holds two toggles, a note and three rows, none of
        which benefits from being dragged bigger. EnableResize is AceGUI's own
        Frame method rather than a reach into library internals, but the widget
        only exists once AceConfigDialog has opened it, so this runs after the
        Open above.
    ]]
	local openFrame = AceConfigDialog.OpenFrames[ns.OPTIONS_REGISTRY.MasterLooterPopup]
	if openFrame and openFrame.EnableResize then
		openFrame:EnableResize(false)
	end
end
