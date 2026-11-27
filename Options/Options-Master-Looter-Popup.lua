--------------------------------------------------------------------------------
-- GogoLoot Options — Quick Settings Pop-up
--------------------------------------------------------------------------------

--[[
    An AceConfigDialog standalone window, never passed to AddToBlizOptions.
    Nothing here is protected, so opening it in combat is safe.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--[[
    Sized to the tallest state. AceConfigDialog takes the frame size from its
    status table, never from the content shown, so hidden rows don't shrink it
    and anything shorter scrolls in the fullest case. Width: one options row
    plus borders and padding, rounded up to a multiple of 16.
]]
local POPUP_WIDTH = 640
local POPUP_HEIGHT = 384

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildMasterLooterPopupOptions()
	local args = {}
	local order = 1

	order = ns.AddPopupToggleRow(args, order)
	args.spacerAfterPopupToggle = Kit.Spacer(order)
	order = order + 1
	args.autoMasterLoot = ns.FeatureSwitch("autoMasterLoot", order)
	order = order + 1
	-- Hides with the destination-message toggle below it.
	args.spacerAfterAutoMasterLoot = Kit.Spacer(order, function()
		return not ns.db.profile.lootNotifications
	end)
	order = order + 1
	order = ns.AddDestinationMessagesRow(args, order)
	args.spacerAfterToggles = Kit.Spacer(order)
	order = order + 1

	order = ns.AddLeaderNoteRow(args, order)
	order = ns.AddLootMethodRow(args, order)
	args.spacerAfterLootType = Kit.Spacer(order, ns.IsLootThresholdIrrelevant)
	order = order + 1
	order = ns.AddLootThresholdRow(args, order)
	args.spacerAfterLootThreshold = Kit.Spacer(order)
	order = order + 1
	-- Stricter than the panel, which hides it only while automation is off.
	ns.AddSendAllDestinationRow(args, order, function()
		return ns:SafeGetLootMethod() ~= "master" or not ns.db.profile.autoMasterLoot
	end)

	return {
		type = "group",
		name = L["QUICK_SETTINGS_TITLE"] .. " // " .. L["ADDON_TITLE"],
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

---@return boolean
function ns.IsMasterLooterPopupShown()
	return AceConfigDialog.OpenFrames[ns.OPTIONS_REGISTRY.MasterLooterPopup] ~= nil
end

---@return nil
function ns:ShowMasterLooterPopup()
	AceConfigDialog:SetDefaultSize(ns.OPTIONS_REGISTRY.MasterLooterPopup, POPUP_WIDTH, POPUP_HEIGHT)
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.MasterLooterPopup)

	-- The widget exists only once AceConfigDialog has opened it.
	local openFrame = AceConfigDialog.OpenFrames[ns.OPTIONS_REGISTRY.MasterLooterPopup]
	if openFrame and openFrame.EnableResize then
		openFrame:EnableResize(false)
	end
end
