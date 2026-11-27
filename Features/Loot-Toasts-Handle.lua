--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Handle
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local TOAST_HANDLE_WIDTH = 400 -- The drag handle only; rows size themselves

--[[
    THE SIZE IS FIXED, never font-derived: the handle marks where rows start,
    so a size that drifted with the font would walk the whole stack. Caption
    and buttons keep to the end the rows don't hang from, so the newest row
    never runs under a button.
]]
local TOAST_HANDLE_HEIGHT = 128
local TOAST_HANDLE_LABEL_WIDTH = 256
local TOAST_HANDLE_BUTTON_GAP = 8
local TOAST_HANDLE_BUTTON_WIDTH = (TOAST_HANDLE_LABEL_WIDTH - TOAST_HANDLE_BUTTON_GAP) / 2
local TOAST_HANDLE_BUTTON_HEIGHT = 32
local TOAST_HANDLE_PADDING = 8

local anchor
local unlocked = false

--------------------------------------------------------------------------------
-- Anchor
--------------------------------------------------------------------------------

local function GetAnchor()
	if anchor then
		return anchor
	end
	anchor = CreateFrame("Button", "GogoLootLootToastAnchor", UIParent)
	anchor:SetSize(TOAST_HANDLE_WIDTH, TOAST_HANDLE_HEIGHT)
	anchor:SetMovable(true)
	anchor:SetClampedToScreen(true)
	anchor:Hide()

	anchor.background = anchor:CreateTexture(nil, "BACKGROUND")
	anchor.background:SetAllPoints()
	anchor.background:SetColorTexture(0, 0, 0, 0.5)

	-- A width of its own, so a long translated title wraps inside the handle.
	anchor.label = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	anchor.label:SetWidth(TOAST_HANDLE_LABEL_WIDTH)
	anchor.label:SetJustifyV("TOP")

	anchor.disable = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
	anchor.disable:SetSize(TOAST_HANDLE_BUTTON_WIDTH, TOAST_HANDLE_BUTTON_HEIGHT)
	anchor.disable:SetText(L["LOOT_TOASTS_DISABLE_BUTTON"])
	anchor.disable:SetScript("OnClick", function()
		ns.DismissLootToastIntro()
		ns.SetLootToastsEnabled(false)
		ns.RefreshSettings()
	end)

	anchor.lock = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
	anchor.lock:SetSize(TOAST_HANDLE_BUTTON_WIDTH, TOAST_HANDLE_BUTTON_HEIGHT)
	anchor.lock:SetText(L["LOOT_TOASTS_LOCK"])
	anchor.lock:SetScript("OnClick", function()
		ns.DismissLootToastIntro()
		ns.SetLootToastsUnlocked(false)
	end)

	anchor:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	anchor:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ns.SaveLootToastPosition()
	end)

	anchor:RegisterForClicks("RightButtonUp")
	anchor:SetScript("OnClick", function()
		ns.DismissLootToastIntro()
		ns.SetLootToastsUnlocked(false)
	end)
	return anchor
end

ns.GetLootToastAnchor = GetAnchor

-- For Diagnostics, which must not create the frame.
---@return table|nil
function ns.GetLootToastAnchorFrame()
	return anchor
end

-- Re-run on every appearance change: the alignment setting can flip which end the rows use.
local function ApplyHandleLayout()
	local frame = GetAnchor()
	frame.label:ClearAllPoints()
	frame.disable:ClearAllPoints()
	frame.lock:ClearAllPoints()
	if ns.LootToastsAlignRight() then
		frame.label:SetPoint("TOPLEFT", frame, "TOPLEFT", TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("LEFT")
		frame.disable:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
		frame.lock:SetPoint("LEFT", frame.disable, "RIGHT", TOAST_HANDLE_BUTTON_GAP, 0)
	else
		frame.label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("RIGHT")
		frame.disable:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
		frame.lock:SetPoint("RIGHT", frame.disable, "LEFT", -TOAST_HANDLE_BUTTON_GAP, 0)
	end
end

ns.ApplyLootToastHandleLayout = ApplyHandleLayout

---@return nil
function ns.ApplyLootToastPosition()
	local frame = GetAnchor()
	local saved = ns.db and ns.db.global.lootToastPosition
	frame:ClearAllPoints()
	if saved and saved.point then
		frame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 192)
	end
end

---@return nil
function ns.SaveLootToastPosition()
	local point, _, relativePoint, x, y = GetAnchor():GetPoint()
	ns.db.global.lootToastPosition = { point = point, relativePoint = relativePoint, x = x, y = y }
end

---@return nil
function ns.ResetLootToastPosition()
	ns.db.global.lootToastPosition = {}
	ns.ApplyLootToastPosition()
end

-- Body white rather than helper silver: these lines ARE the point, read over open world.
---@param isUnlocked boolean
---@return nil
local function ApplyUnlocked(isUnlocked)
	local frame = GetAnchor()
	if isUnlocked then
		local function BodyLine(key)
			return "\n\n" .. GetColor("BODY") .. L[key] .. "|r"
		end
		frame.label:SetText(
			GetColor("TITLE")
				.. L["TAB_LOOT_TOASTS"]
				.. " // "
				.. L["ADDON_TITLE"]
				.. "|r"
				.. BodyLine("LOOT_TOASTS_CLICK_DRAG")
				.. BodyLine("LOOT_TOASTS_RIGHT_CLICK_LOCK")
		)
		frame:RegisterForDrag("LeftButton")
		frame:EnableMouse(true)
		frame:Show()
	else
		frame:RegisterForDrag()
		frame:EnableMouse(false)
		frame:Hide()
	end
	unlocked = isUnlocked and true or false
	ns.RefreshLootToastSamples()
end

---@param isUnlocked boolean
---@return nil
function ns.SetLootToastsUnlocked(isUnlocked)
	ApplyUnlocked(isUnlocked)
	ns.RefreshSettings()
end

---@return boolean
function ns.AreLootToastsUnlocked()
	return unlocked
end

--------------------------------------------------------------------------------
-- The Introduction
--------------------------------------------------------------------------------

--[[
    Remembered per profile, so a new or reset profile shows it again. Any of
    the four ways out counts: right-click, Lock Position, Disable, and the
    panel's Lock button.
]]
---@return nil
function ns.DismissLootToastIntro()
	if ns.db then
		ns.db.profile.lootToastsIntroSeen = true
	end
end

---@return nil
function ns.ShowLootToastIntro()
	if not ns.db or ns.db.profile.lootToastsIntroSeen or not ns.db.profile.lootToasts then
		return
	end
	ApplyUnlocked(true)
end

--[[
    Locks first: unlocking is a runtime choice the profile doesn't carry, and
    the samples refresh re-measures every row on screen.
]]
---@return nil
function ns.ApplyLootToastSettings()
	ApplyUnlocked(false)
	ns.ShowLootToastIntro()
end

-- Switching on raises the handle: the player has no other way to see where or how big. The caller refreshes.
---@param enabled boolean
---@return nil
function ns.SetLootToastsEnabled(enabled)
	ns.db.profile.lootToasts = enabled and true or false
	ApplyUnlocked(ns.db.profile.lootToasts)
	ns.SyncStandardLootMessages()
	ns.SyncBlizzardRollWonWindow()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnPlayerLogin()
	ns.ApplyLootToastPosition()
	ns.ShowLootToastIntro()
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
