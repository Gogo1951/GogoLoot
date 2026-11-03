--------------------------------------------------------------------------------
-- GogoLoot Loot Windows — Shared Parts
--------------------------------------------------------------------------------

--[[
    What the Loot Master and Loot Tracker windows share: the window itself (the
    game's own BasicFrameTemplateWithInset, on all three clients), its tabs,
    buttons, a scrolling list, and pooled widgets laid out top to bottom on
    every repaint, so a list of any length costs no more frames than its
    longest showing. Nothing here is protected, so the windows open and work
    in combat.

    Repaints are coalesced: everything that changes loot state calls
    ns.RefreshLootWindows, which repaints on the next frame, once.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

-- The item lists' remove icon (Options-Utilities-Item-Lists.lua), so a remove button reads the same everywhere.
ns.LOOT_WINDOW_REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
ns.LOOT_WINDOW_ARROW_UP = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up"
ns.LOOT_WINDOW_ARROW_DOWN = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"
ns.LOOT_WINDOW_QUESTION_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- The inset the template draws, which content keeps inside.
local CONTENT_TOP, CONTENT_SIDE, CONTENT_BOTTOM = 28, 10, 10

--------------------------------------------------------------------------------
-- Repainting
--------------------------------------------------------------------------------

local refreshers = {}

-- A window's repaint, run by ns.RefreshLootWindows whether the window is showing or not.
---@param refresher function
---@return nil
function ns.AddLootWindowRefresher(refresher)
	table.insert(refreshers, refresher)
end

---@return nil
function ns.RefreshLootWindows()
	ns:After("lootWindowsRefresh", 0, function()
		for _, refresher in ipairs(refreshers) do
			refresher()
		end
	end)
end

--------------------------------------------------------------------------------
-- The Window
--------------------------------------------------------------------------------

--[[
    A movable window, closed by Escape, that remembers where it was left
    (ns.db.global.lootWindowPositions, by frame name, account-wide because it
    is about the screen, like the toasts' position).
]]
---@param frameName string
---@param title string
---@param width number
---@param height number
---@return table
function ns.CreateLootWindow(frameName, title, width, height)
	local frame = CreateFrame("Frame", frameName, UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(width, height)
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relativePoint, x, y = self:GetPoint(1)
		ns.db.global.lootWindowPositions[frameName] = { point, relativePoint, x, y }
	end)
	local saved = ns.db.global.lootWindowPositions[frameName]
	if saved then
		frame:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
	else
		frame:SetPoint("CENTER")
	end
	if type(frame.TitleText) == "table" then
		frame.TitleText:SetText(
			GetColor("INFO") .. L["ADDON_TITLE"] .. "|r " .. GetColor("SEPARATOR") .. "//|r " .. title
		)
	end
	frame:Hide()
	table.insert(UISpecialFrames, frameName)

	frame.content = CreateFrame("Frame", nil, frame)
	frame.content:SetPoint("TOPLEFT", CONTENT_SIDE, -CONTENT_TOP)
	frame.content:SetPoint("BOTTOMRIGHT", -CONTENT_SIDE, CONTENT_BOTTOM)
	return frame
end

--------------------------------------------------------------------------------
-- Text and Buttons
--------------------------------------------------------------------------------

---@param parent table
---@param fontObject? string
---@param justify? string
---@return table
function ns.LootWindowText(parent, fontObject, justify)
	local text = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontHighlight")
	text:SetJustifyH(justify or "LEFT")
	text:SetWordWrap(false)
	return text
end

---@param parent table
---@param caption string
---@param width? number
---@param onClick? function
---@return table
function ns.LootWindowButton(parent, caption, width, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or (ns.MeasureCaptionPixels(caption) + 24), 22)
	button:SetText(caption)
	if onClick then
		button:SetScript("OnClick", onClick)
	end
	return button
end

-- A button's caption changed after it was made: resize it to fit.
---@param button table
---@param caption string
---@return nil
function ns.SetLootWindowButtonText(button, caption)
	button:SetText(caption)
	button:SetWidth(ns.MeasureCaptionPixels(caption) + 24)
end

-- A square button showing only an icon, with its meaning in a tooltip.
---@param parent table
---@param texture string
---@param size number
---@param tooltip string
---@param onClick function
---@return table
function ns.LootWindowIconButton(parent, texture, size, tooltip, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(size, size)
	button:SetNormalTexture(texture)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	-- Greyed out while it can't be used, such as the top row's Move Up.
	button:SetDisabledTexture(texture)
	local disabled = button:GetDisabledTexture()
	if disabled then
		disabled:SetDesaturated(true)
		disabled:SetAlpha(0.35)
	end
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", GameTooltip_Hide)
	return button
end

--[[
    A row of tabs across the top of the content. Each is a plain button; the
    open one is lit and gold, the rest white. onSelect(key) runs on a click.
]]
---@param parent table
---@param tabs table[] # { key, caption }
---@param onSelect function
---@return table
function ns.LootWindowTabs(parent, tabs, onSelect)
	local bar = { buttons = {} }
	local previous
	for _, tab in ipairs(tabs) do
		local button = ns.LootWindowButton(parent, tab.caption, nil, function()
			onSelect(tab.key)
		end)
		if previous then
			button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
		else
			button:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
		end
		bar.buttons[tab.key] = button
		previous = button
	end
	function bar:Select(selectedKey)
		for key, button in pairs(self.buttons) do
			if key == selectedKey then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end
		end
	end
	function bar:SetCaption(key, caption)
		ns.SetLootWindowButtonText(self.buttons[key], caption)
	end
	return bar
end

--------------------------------------------------------------------------------
-- Scrolling List
--------------------------------------------------------------------------------

--[[
    A scroll frame whose child grows to what was laid out on it. Lay out from
    the top with list:Begin(), then list:Place(widget, height, indent) for each
    widget in order, then list:Finish().
]]
---@param parent table
---@return table
function ns.LootWindowList(parent)
	local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(1, 1)
	scroll:SetScrollChild(child)
	scroll.child = child
	scroll.y = 0
	-- The list's width is only known once the window has laid out, so the first repaint after that redoes the rows.
	scroll:SetScript("OnSizeChanged", function()
		ns.RefreshLootWindows()
	end)

	function scroll:Begin()
		self.y = 0
		self.child:SetWidth(math.max(1, self:GetWidth()))
	end
	function scroll:Width()
		return math.max(1, self:GetWidth())
	end
	function scroll:Place(widget, height, indent)
		widget:ClearAllPoints()
		widget:SetPoint("TOPLEFT", self.child, "TOPLEFT", indent or 0, -self.y)
		widget:SetPoint("TOPRIGHT", self.child, "TOPRIGHT", 0, -self.y)
		widget:SetHeight(height)
		widget:Show()
		self.y = self.y + height
	end
	function scroll:Gap(height)
		self.y = self.y + height
	end
	function scroll:Finish()
		self.child:SetHeight(math.max(1, self.y))
	end
	return scroll
end

--[[
    Widgets made once and handed out again on each repaint: Acquire returns
    the next free one, made by `make(parent)` when the pool runs out, and
    Release hides them all for the next layout.
]]
---@param parent table
---@param make function
---@return table
function ns.LootWindowPool(parent, make)
	local pool = { items = {}, used = 0 }
	function pool:Release()
		for _, item in ipairs(self.items) do
			item:Hide()
		end
		self.used = 0
	end
	function pool:Acquire()
		self.used = self.used + 1
		local item = self.items[self.used]
		if not item then
			item = make(parent)
			self.items[self.used] = item
		end
		return item
	end
	return pool
end

--------------------------------------------------------------------------------
-- Items in Rows
--------------------------------------------------------------------------------

--[[
    An item shown in a row answers like one in the bags: hovering shows its
    tooltip, Shift-Click puts its link in chat. `frame.itemLink` says which.
]]
---@param frame table
---@return nil
function ns.MakeItemHoverable(frame)
	frame:SetScript("OnEnter", function(self)
		if self.itemLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.itemLink)
			GameTooltip:Show()
		end
	end)
	frame:SetScript("OnLeave", GameTooltip_Hide)
end

---@param itemLink string|nil
---@return boolean
function ns.InsertItemLinkIfShift(itemLink)
	if itemLink and IsShiftKeyDown() and ChatEdit_InsertLink then
		ChatEdit_InsertLink(itemLink)
		return true
	end
	return false
end

---@param itemLink string|nil
---@return number|string
function ns.GetLootWindowIcon(itemLink)
	local itemId = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
	return ns.GetItemIconByID(itemId) or ns.LOOT_WINDOW_QUESTION_ICON
end

-- Minutes and seconds, with hours when there are any: 1:42:10, 24:05, 0:42.
---@param seconds number
---@return string
function ns.FormatClock(seconds)
	seconds = math.max(0, math.floor(seconds))
	local hours, minutes, rest = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, rest)
	end
	return string.format("%d:%02d", minutes, rest)
end

-- A name in its class color, the same in every window.
---@param name string|nil
---@return string
function ns.LootWindowName(name)
	return name and ns:ColorRollName(name) or ""
end
