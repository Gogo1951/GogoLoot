--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter Pop-up
--------------------------------------------------------------------------------

--[[
    The window that opens when the player becomes master looter, so a run can be
    set up without going through Options. It carries the same rows the Master
    Looter panel opens with, built from the shared row builders in
    Options-Master-Looter.lua and Options-Announcements.lua so the two can never
    drift: the pop-up's own on/off toggle, Enable Automated Master Looting, the
    destination-message toggle, then loot method, loot threshold, and Send All
    Loot To.

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
    Sized to the window's tallest state: the three toggles, the leader note and
    its spacer, and all three label-plus-dropdown rows. That state is also the common
    one — the note shows precisely when somebody else handed you the role, which
    is the usual way this window opens.

    One height serves every open. Rows that do not apply to the current loot
    method hide rather than shrink the window, because AceConfigDialog takes the
    frame size from the status table this writes and never from how much content
    is on show, so a height sized to anything less scrolls in the fullest case.

    The width is one options row, in pixels, plus the frame's borders and
    padding.
]]
local POPUP_FRAME_PADDING = 58
local POPUP_WIDTH = math.ceil(ns.OPTIONS_ROW_WIDTH * ns.OPTIONS_PIXELS_PER_WIDTH_UNIT) + POPUP_FRAME_PADDING
local POPUP_HEIGHT = 346

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
	    here is going and finding one in Options. Then the automation switch, since
	    a destination picked below hands nothing out while it is off. Then the
	    destination-message toggle, because the destination you are about to set
	    is exactly what it decides whether to announce.
	]]
	order = ns.AddPopupToggleRow(args, order)
	args.autoMasterLoot = ns.AutomatedMasterLootingSwitch()
	args.autoMasterLoot.width = "full"
	args.autoMasterLoot.order = order
	order = order + 1
	order = ns.AddDestinationMessagesRow(args, order)
	args.spacerAfterToggles = ns.OptionsSpacer(order)
	order = order + 1

	-- Says who controls the two dropdowns below when it isn't you.
	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = ns.OptionsSpacer(order, ns.IsLootThresholdIrrelevant)
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerAfterLootThreshold = ns.OptionsSpacer(order)
	order = order + 1
	--[[
	    The destination only means anything under master loot with the
	    automation on, so it is hidden outright rather than left visible and
	    inert otherwise, as it is on the panel.
	]]
	ns.AddSendAllDestinationRow(args, order, function()
		return ns:SafeGetLootMethod() ~= "master" or not ns.db.profile.autoMasterLoot
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
        Fixed size: the window holds three toggles, a note and three rows, none of
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
