--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter Pop-up
--------------------------------------------------------------------------------

--[[
    The window that opens when the player becomes master looter, so a run can be
    set up without going through Options. It carries the same three rows the
    Master Looter panel opens with, built from the shared row builders in
    Options-Master-Looter.lua so the two can never drift: loot method, loot
    threshold, and Send All Loot To.

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
    Sized to hold all three label-plus-dropdown rows. Rows that do not apply to
    the current loot method hide rather than shrink the window: AceConfigDialog
    takes the frame size from the status table this writes, never from how much
    content is on show, so the height below is what every open uses.
]]
local POPUP_WIDTH = 500
local POPUP_HEIGHT = 205

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildMasterLooterPopupOptions()
	local args = {}
	local order = 1

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
        Fixed size: the window holds three rows and nothing that benefits from
        being dragged bigger. EnableResize is AceGUI's own Frame method rather
        than a reach into library internals, but the widget only exists once
        AceConfigDialog has opened it, so this runs after the Open above.
    ]]
	local openFrame = AceConfigDialog.OpenFrames[ns.OPTIONS_REGISTRY.MasterLooterPopup]
	if openFrame and openFrame.EnableResize then
		openFrame:EnableResize(false)
	end
end
