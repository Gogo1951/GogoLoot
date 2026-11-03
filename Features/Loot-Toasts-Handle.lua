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
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local TOAST_HANDLE_WIDTH = 400 -- The drag handle only; rows size themselves

--[[
    The handle carries its caption as three blank-line-separated rows, the name
    and the two gestures, over a button in the bottom corner, so it stands as a
    panel rather than a strip of text the bottom toast sits on.

    BOTH NUMBERS ARE FIXED, never font-derived: the handle marks where rows
    start, so a size that drifted with the font would walk the whole stack. The
    height holds the caption's five rendered lines from the top, the button at
    the bottom, and padding at both ends, plus air between the two; every pixel
    added here lands in that gap.

    The caption keeps to its own column at one end, and rows hang off the other
    end (lootToastAlign), so the two never share horizontal space.
]]
local TOAST_HANDLE_HEIGHT = 130
local TOAST_HANDLE_LABEL_WIDTH = 260
local TOAST_HANDLE_BUTTON_WIDTH = 150
local TOAST_HANDLE_BUTTON_HEIGHT = 22
local TOAST_HANDLE_PADDING = 10

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
    the button sits in the corner below it at the same inset. Re-run on every
    appearance change, since the alignment setting can flip which end that is.
]]
local function ApplyHandleLayout()
	local frame = GetAnchor()
	frame.label:ClearAllPoints()
	frame.disable:ClearAllPoints()
	if ns.LootToastsAlignRight() then
		frame.label:SetPoint("TOPLEFT", frame, "TOPLEFT", TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("LEFT")
		frame.disable:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
	else
		frame.label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("RIGHT")
		frame.disable:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
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
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
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
function ns.SetLootToastsUnlocked(isUnlocked)
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
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.LootToasts)
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
    profile show it again. Any of the three ways out counts: the right-click the
    handle advertises, its Disable button, and the panel's own Lock button.
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
	ns.SetLootToastsUnlocked(true)
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
	ns.SetLootToastsUnlocked(false)
	ns.ShowLootToastIntro()
end

--[[
    Switching toasts on raises the handle and its samples, because the player
    has just turned on something that draws on their screen and has no other way
    to see where or how big. Switching off puts the handle away. Both panels
    carrying the switch are told either way, the Loot Toasts panel and
    the General panel's Features section, since the handle's own Disable button
    reaches this from outside both.
]]
---@param enabled boolean
---@return nil
function ns.SetLootToastsEnabled(enabled)
	ns.db.profile.lootToasts = enabled and true or false
	ns.SetLootToastsUnlocked(ns.db.profile.lootToasts)
	ns.SyncStandardLootMessages()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.LootToasts)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnPlayerLogin()
	ns.ApplyLootToastPosition()
	ns.ShowLootToastIntro()
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
