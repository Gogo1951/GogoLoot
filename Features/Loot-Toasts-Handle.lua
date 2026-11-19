--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Handle
--------------------------------------------------------------------------------

--[[
    The anchor the toast stack hangs from (Features/Loot-Toasts.lua): its saved
    position, the drag handle that moves it, and the introduction that raises
    the handle the first time a profile meets the toasts.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local TOAST_HANDLE_WIDTH = 400 -- The drag handle only; rows size themselves

--[[
    The handle carries its caption as three blank-line-separated rows, the name
    and the two gestures, over two buttons side by side in the bottom corner, so it stands as a
    panel rather than a strip of text the bottom toast sits on.

    THE SIZE IS FIXED, never font-derived: the handle marks where rows start,
    so a size that drifted with the font would walk the whole stack. The
    height holds the caption's five rendered lines from the top, the buttons at
    the bottom, and padding at both ends, plus air between the two; every pixel
    added here lands in that gap.

    The caption and both buttons keep to one column at one end, and rows hang
    off the other end (lootToastAlign), so the newest row never runs under a
    button.
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

--[[
    The fixed point toasts stack from. Its saved point lives in
    ns.db.global.lootToastPosition: where a player wants this on screen is not a
    per-profile decision. Made on first use.
]]
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

	--[[
        A width of its own, so a long translated title wraps inside the handle
        instead of running under the rows. Anchored from the top, because the
        button hangs off the bottom edge and the two have to stack predictably.
    ]]
	anchor.label = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	anchor.label:SetWidth(TOAST_HANDLE_LABEL_WIDTH)
	anchor.label:SetJustifyV("TOP")

	--[[
        The way out, offered where the feature is: a player meeting toasts for
        the first time shouldn't have to find an options panel to decline them.
    ]]
	anchor.disable = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
	anchor.disable:SetSize(TOAST_HANDLE_BUTTON_WIDTH, TOAST_HANDLE_BUTTON_HEIGHT)
	anchor.disable:SetText(L["LOOT_TOASTS_DISABLE_BUTTON"])
	anchor.disable:SetScript("OnClick", function()
		ns.DismissLootToastIntro()
		ns.SetLootToastsEnabled(false)
		ns.RefreshSettings()
	end)

	-- Does what right-click does, as a button anyone can find, so finishing a drag never means switching toasts off.
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

	-- Left drag moves, right click locks, and the handle says so.
	anchor:RegisterForClicks("RightButtonUp")
	anchor:SetScript("OnClick", function()
		ns.DismissLootToastIntro()
		ns.SetLootToastsUnlocked(false)
	end)
	return anchor
end

-- What the stack's rows hang from (Restack in Features/Loot-Toasts.lua).
ns.GetLootToastAnchor = GetAnchor

-- The read-only half of GetAnchor, for Diagnostics, which must not create the frame.
---@return table|nil
function ns.GetLootToastAnchorFrame()
	return anchor
end

--[[
    The caption pins to the end the rows don't use, justified into that end, and
    Disable sits in the corner below it at the same inset, with Lock Position
    beside it toward the middle, both inside the caption's column. Re-run on every
    appearance change, since the alignment setting can flip which end that is.
]]
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

-- Run by every samples refresh (ns.RefreshLootToastSamples), which every appearance change goes through.
ns.ApplyLootToastHandleLayout = ApplyHandleLayout

---@return nil
function ns.ApplyLootToastPosition()
	local frame = GetAnchor()
	local saved = ns.db and ns.db.global.lootToastPosition
	frame:ClearAllPoints()
	if saved and saved.point then
		frame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
	else
		-- Default: above center, clear of the action bars and the chat frame.
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

--[[
    Unlocking shows the anchor as a draggable handle so the player can see what
    they're moving; locking hides it again. Purely visual, no secure frames.

    The caption is the name, then the two gestures in the order a player meets
    them, blank lines between so they read as a list. Body white rather than
    helper silver: these lines ARE the point, read over open world.
]]
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

-- The same, then every panel and the menu repaint, for a caller that doesn't refresh on its own.
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
    A profile with the toasts on that has never put the handle away gets it
    raised at login, so the first a player knows of them isn't loot drawn
    somewhere they didn't choose: it says what the feature is, where it will
    draw, how to move it and put it away, and offers a button to decline.

    Dismissing is remembered per profile, which is what makes a new or reset
    profile show it again. Any of the four ways out counts: the right-click the
    handle advertises, its Lock Position and Disable buttons, and the panel's
    own Lock button.
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
    Re-applies the active profile's toast settings on a profile switch, reset or
    copy. The handle settles to locked first either way: unlocking is a runtime
    choice the profile doesn't carry, and the samples refresh it runs re-measures
    every row on screen, so the new profile's look reaches toasts already drawn.
    Then the incoming profile gets its own introduction, if it is owed one.
]]
---@return nil
function ns.ApplyLootToastSettings()
	ApplyUnlocked(false)
	ns.ShowLootToastIntro()
end

--[[
    Switching toasts on raises the handle and its samples, because the player
    has just turned on something that draws on their screen and has no other way
    to see where or how big. Switching off puts the handle away. The caller
    refreshes: the panel switch and the menu click already do, and the
    handle's own Disable button does it itself.
]]
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
