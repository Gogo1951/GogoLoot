local ADDON_NAME, ns = ...

-- luacheck: read globals C_Item C_Timer CreateFrame GameTooltip GetCursorPosition GetItemInfo GetItemQualityColor
-- luacheck: read globals IsShiftKeyDown MenuUtil NO PlaySound SOUNDKIT StaticPopup_Show UIParent UISpecialFrames YES
-- luacheck: globals StaticPopupDialogs

--[[
    Menu-Kit v2: every Gogo add-on's menus, drawn on Pretty Wide Quest Log's
    Quest Arrow plate: the mini-map menu and its flyouts, a right-click menu, a
    flyout off a window's line, and the game's menus or an AceGUI dropdown's
    list in the kit's dress.

    Copied unchanged from Common-Core's addon-kits/Menu-Kit/ into
    Features/Menu-Kit.lua, after Features/Utilities.lua in the TOC, with its
    plate at Includes/Images/Menu-Plate.tga and its sub-menu arrow at
    Includes/Images/Menu-Arrow.tga, and checked byte for byte by CI.
    Never edit a copy: change Common-Core's and sync it
    (Common-Core/scripts/sync-addon-kits.sh).

    The kit knows nothing about the add-on. It reads only what every add-on
    already defines under one name: ns.PALETTE, ns.L, ns.db, ns.FEATURES and
    ns:OpenOptionsPanel. The strings it draws are handed to it once, localized,
    through Kit.SetText.

    Spec: Common-Core/Add-on Guide/References/Design System/Mini-map Menus/
    Menu-Kit.md. Rules: Style Guide → MENUS and MINIMAP MENU.

    Entries, each a table with a `kind`:
      header       left, right            The add-on's name, its version on the right
      spacer                              A line's room
      section      left, right            A group's gold label
      status       left, right            A gold label and where it stands
      submenu      left, right, submenu   A gold label that opens a flyout
      separator                           A thin line
      action       left, click            A row to click: blue; on the right what it touches, or its click gray
      toggle       left, on               A switch: On in green, or Off with its name gray
      choice       left, selected, right  One of a set: the check on the left (the rest keep its room empty),
                                          the pick light yellow, the rest white; a list of values on the right
      item         itemID or link, count  An item: its icon, its name in its quality color, the count
      value        left, right            A setting's value: white label, light yellow value (Off gray)
      description  left                   What a feature does, white, wrapped at 320
      note         left                   Gray helper text, wrapped at 256

    Any entry may carry:
      leftColor, rightColor   a palette key, a six-digit hex or { r, g, b }
      onClick                 what a click does; the menu's afterChange runs after it
      closes                  true for a pick that acts: the menu closes first
      click                   the button's kept click that does the same ("RightButton"), its name from
                              clicks drawn gray on the right; or a gesture's localized name ("Drag"),
                              drawn the same and routing nothing
      disabled                true: gray, no highlight, no click, no sub-menu (its arrow gray); its tooltip still shows
      tooltip                 a function(GameTooltip), shown beside the row under the cursor
      helper                  a gray sentence under the row's tooltip (or an item's), after a spacer
      submenu                 the key of the flyout its hover opens (flyouts[key]), or with
      flyout                  a function returning the flyout's entries in place of flyouts[key]
      rightOnHover            true: the right side shows only while the row is hovered
      hover                   { right, rightColor }: the right side while hovered, name brightened

    The kit's own row kinds keep v1's names, so an add-on still on v1's
    Kit.CreatePanel and its own Minimap-Menu.lua runs on this file unchanged.
]]

local Kit = {}
ns.MenuKit = Kit

local format = string.format

local SPACE = { LINE = 4, NEAR = 8, GROUP = 16 }

--[[
    The plate's art, drawn at half its size so the edges stay sharp: PLATE_SIZE
    pixels square, the plate itself PLATE_MARGIN in from each edge and the rest its
    shadow, each corner piece PLATE_CORNER across.
]]
local PLATE_TEXTURE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Menu-Plate"
local PLATE_SIZE = 128
local PLATE_MARGIN = { left = 12, right = 12, top = 10, bottom = 14 }
local PLATE_CORNER = 32
local PLATE_SCALE = 0.5
local PLATE_ALPHA = 0.8 -- The art is black: a little of the world shows through, so it reads lighter

local MIN_WIDTH = 128
local MAX_WIDTH = 320 -- No menu or flyout is wider: a long label wraps instead
local NOTE_MAX_WIDTH = 256 -- A note wraps here when nothing else makes the panel wider
local DESCRIPTION_MAX_WIDTH = 320 -- A description gets more room before it wraps
local EDGE = SPACE.GROUP -- From the plate's edge to the text, on every side
local ROW_INSET = SPACE.NEAR -- From the plate's edge to a row's highlight
local TEXT_INSET = EDGE - ROW_INSET -- From a row's edge to its text
local PANEL_INSET = EDGE - SPACE.NEAR -- Above the first row and below the last: a row's own SPACE.NEAR makes up EDGE
local OPTION_INDENT = SPACE.LINE -- Options sit a little in from the text above them, so a list reads as one
local RIGHT_GAP = SPACE.GROUP -- From a row's left text to its right side
local ARROW_GAP = SPACE.LINE -- From a row's right side to the arrow's column
local LINE_HEIGHT = 12
local HIGHLIGHT_ALPHA = 0.16
local SEPARATOR_ALPHA = 0.35

local HOVER_CLOSE_DELAY = 0.5 -- Forgiving for a cursor that slips off the edge, or a controller's
local CLICK_CLOSE_DELAY = 1.0
local MENU_GAP = 2 -- From the launcher's corner to the menu's
local MAX_DEPTH = 4 -- The menu and three sub-menus deep
local SCREEN_MARGIN = 64 -- A panel is never taller than the screen less this; past it, it scrolls
local SCROLL_STEP = 3 -- Rows per notch of the wheel
local THUMB_WIDTH = 2
local THUMB_ALPHA = 0.6
local LIST_MAX = 8

local OPTIONS = { choice = true, toggle = true, item = true, value = true }
local WRAPS = { description = DESCRIPTION_MAX_WIDTH, note = NOTE_MAX_WIDTH }
local HEADINGS = { section = true, status = true, submenu = true }

Kit.MAX_WIDTH = MAX_WIDTH
Kit.LIST_MAX = LIST_MAX

-- The kit's own thin chevron on a row with a submenu (white, at line height), the game's check mark, an
-- empty texture the check's size for a choice not picked, and the loot window's Pass for a delete.
Kit.SUBMENU_ARROW = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Menu-Arrow:0|t"
Kit.CHECK_MARK = "|TInterface\\Buttons\\UI-CheckBox-Check:0|t"
Kit.CHECK_BLANK = "|TInterface\\Common\\spacer:0|t"
Kit.REMOVE_ICON = "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:0|t"

--[[
    A sub-menu overlaps its menu, as the game's own do: its edge sits
    FLYOUT_OVERLAP inside the menu's (where a row's highlight ends, clear of the
    arrow), and it rises FLYOUT_RISE so its first row meets the row that opened
    it. FLYOUT_GAP is v1's name, measured from the row rather than the plate,
    and 0 now: an add-on still placing its own flyout with it gets the overlap too.
]]
Kit.FLYOUT_OVERLAP = ROW_INSET
Kit.FLYOUT_RISE = PANEL_INSET
Kit.FLYOUT_GAP = ROW_INSET - Kit.FLYOUT_OVERLAP

--------------------------------------------------------------------------------
-- Text
--------------------------------------------------------------------------------

--[[
    Every string the kit draws, handed over once at load from the add-on's
    locale, under these keys in every add-on (Menu-Kit.md → API):

      on, off            L["MENU_ON"], L["MENU_OFF"]
      toggle             L["MENU_TOGGLE"]
      more               L["MENU_MORE"]                 "%d more"
      moreFeatures       L["MENU_MORE_FEATURES"]        "More Features"
      featuresOn/Off     L["MENU_FEATURE_COUNT_ON/OFF"] "%d On", "%d Off"
      count              L["ITEM_QUANTITY"]             "x%d"
      loading            L["LOADING_ITEM"]              "Loading ID: %d"
      shortName          L["ADDON_SHORT_NAME"]          a right-click menu's header
      clicks             { RightButton = L["MENU_CLICK_RIGHT"] }  "Right-Click"; only where the button keeps it
]]
local TEXT = {
	on = "On",
	off = "Off",
	toggle = "Toggle",
	more = "%d more",
	moreFeatures = "More Features",
	featuresOn = "%d On",
	featuresOff = "%d Off",
	count = "x%d",
	loading = "Loading ID: %d",
	shortName = "",
	clicks = {},
}

-- A button click ("RightButton", "ShiftLeftButton"), as opposed to a gesture the caller names ("Drag").
local function IsButtonClick(click)
	return type(click) == "string" and click:match("Button%d*$") ~= nil
end

function Kit.SetText(strings)
	for key, value in pairs(strings) do
		TEXT[key] = value
	end
end

-- v1's way to set the two state words.
function Kit.SetToggleText(on, off)
	TEXT.on, TEXT.off = on, off
end

--------------------------------------------------------------------------------
-- Color
--------------------------------------------------------------------------------

local function HexRGB(hex)
	return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

-- Roles an add-on's ns.PALETTE may not have yet (Style Guide → COLORS).
local PALETTE_FALLBACK = { VALUE = "FFFF99", HELP = "CCCCCC" }

-- A palette key, a six-digit hex (a class or quality color), or { r, g, b }.
local function RGB(color)
	if type(color) == "table" then
		return color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1
	end
	local hex = ns.PALETTE and ns.PALETTE[color] or PALETTE_FALLBACK[color]
	if not hex and type(color) == "string" and color:match("^%x%x%x%x%x%x$") then
		hex = color
	end
	return HexRGB(hex or "FFFFFF")
end

-- The text wrapped in a color's escape, for one row that mixes colors (More Features' count).
function Kit.Color(color, text)
	local red, green, blue = RGB(color)
	local function Byte(value)
		return math.floor(value * 255 + 0.5)
	end
	return format("|cff%02x%02x%02x%s|r", Byte(red), Byte(green), Byte(blue), text)
end

-- The arrow tinted, for a gray row: a texture escape takes its color as 0–255 after its texel box.
local ARROW_PATH = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Menu-Arrow"
local function ArrowIn(color)
	local red, green, blue = RGB(color)
	local function Byte(value)
		return math.floor(value * 255 + 0.5)
	end
	return format("|T%s:0:0:0:0:32:32:0:32:0:32:%d:%d:%d|t", ARROW_PATH, Byte(red), Byte(green), Byte(blue))
end

local function PlayClick()
	if PlaySound and SOUNDKIT and SOUNDKIT.U_CHAT_SCROLL_BUTTON then
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end
end

--------------------------------------------------------------------------------
-- Cursor Test
--------------------------------------------------------------------------------

--[[
    True while the cursor is over a frame. Read from the cursor position rather
    than IsMouseOver, so a controller's virtual cursor reports here too.
]]
function Kit.IsCursorOver(frame)
	if not frame or not frame:IsVisible() then
		return false
	end
	local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
	if not left then
		return false
	end
	local scale = frame:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale
	return x >= left and x <= right and y >= bottom and y <= top
end

-- True when frame is the panel or sits anywhere inside it.
function Kit.IsInside(frame, panel)
	while frame do
		if frame == panel then
			return true
		end
		frame = frame.GetParent and frame:GetParent() or nil
	end
	return false
end

--------------------------------------------------------------------------------
-- The Plate
--------------------------------------------------------------------------------

--[[
    Nine pieces: the corners at their own size, keeping the angle and shadow, the
    edges and middle stretched. Laid under any frame: a panel, a window, the
    game's menu or a dropdown's list. Returns the plate's own frame, so a caller
    can hide it again; a frame that already has one gets it back, shown.
]]
function Kit.AddPlate(frame)
	if frame.menuKitPlate then
		frame.menuKitPlate:Show()
		return frame.menuKitPlate
	end
	local plate = CreateFrame("Frame", nil, frame)
	plate:SetPoint("TOPLEFT", -PLATE_MARGIN.left * PLATE_SCALE, PLATE_MARGIN.top * PLATE_SCALE)
	plate:SetPoint("BOTTOMRIGHT", PLATE_MARGIN.right * PLATE_SCALE, -PLATE_MARGIN.bottom * PLATE_SCALE)
	plate:SetFrameLevel(frame:GetFrameLevel()) -- Under the rows, which sit above their panel
	plate:SetAlpha(PLATE_ALPHA)

	local near, far = PLATE_CORNER / PLATE_SIZE, 1 - PLATE_CORNER / PLATE_SIZE
	local corner = PLATE_CORNER * PLATE_SCALE

	local function Piece(left, right, top, bottom)
		local texture = plate:CreateTexture(nil, "BACKGROUND")
		texture:SetTexture(PLATE_TEXTURE)
		texture:SetTexCoord(left, right, top, bottom)
		return texture
	end

	local topLeft = Piece(0, near, 0, near)
	topLeft:SetSize(corner, corner)
	topLeft:SetPoint("TOPLEFT")
	local topRight = Piece(far, 1, 0, near)
	topRight:SetSize(corner, corner)
	topRight:SetPoint("TOPRIGHT")
	local bottomLeft = Piece(0, near, far, 1)
	bottomLeft:SetSize(corner, corner)
	bottomLeft:SetPoint("BOTTOMLEFT")
	local bottomRight = Piece(far, 1, far, 1)
	bottomRight:SetSize(corner, corner)
	bottomRight:SetPoint("BOTTOMRIGHT")

	local top = Piece(near, far, 0, near)
	top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
	top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
	local bottom = Piece(near, far, far, 1)
	bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")
	local left = Piece(0, near, near, far)
	left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
	local right = Piece(far, 1, near, far)
	right:SetPoint("TOPLEFT", topRight, "BOTTOMLEFT")
	right:SetPoint("BOTTOMRIGHT", bottomRight, "TOPRIGHT")
	local middle = Piece(near, far, near, far)
	middle:SetPoint("TOPLEFT", topLeft, "BOTTOMRIGHT")
	middle:SetPoint("BOTTOMRIGHT", bottomRight, "TOPLEFT")

	frame.menuKitPlate = plate
	return plate
end

--------------------------------------------------------------------------------
-- Items
--------------------------------------------------------------------------------

--[[
    An item row reads the item's name, quality and icon from the client. One not
    cached yet draws "Loading ID: %d" in gray, asks for it, and every open menu
    redraws once it arrives.
]]
local pendingItems = {}
local itemWatcher

local function GetItem(item)
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	if not getInfo or item == nil then
		return nil
	end
	local name, link, quality, _, _, _, _, _, _, icon = getInfo(item)
	return name, link, quality, icon
end

local function QualityRGB(quality)
	local getColor = (C_Item and C_Item.GetItemQualityColor) or GetItemQualityColor
	if quality and getColor then
		local red, green, blue = getColor(quality)
		if red then
			return { red, green, blue }
		end
	end
	return "TEXT"
end

local function ItemID(entry)
	if entry.itemID then
		return entry.itemID
	end
	local id = type(entry.link) == "string" and entry.link:match("item:(%d+)")
	return id and tonumber(id) or nil
end

local function WatchItem(itemID)
	if not itemID or pendingItems[itemID] then
		return
	end
	pendingItems[itemID] = true
	if C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(itemID)
	end
	if not itemWatcher then
		itemWatcher = CreateFrame("Frame")
		itemWatcher:SetScript("OnEvent", function(_, _, arrived)
			if arrived and pendingItems[arrived] then
				pendingItems[arrived] = nil
				Kit.RefreshAll()
			end
		end)
	end
	itemWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

local function Paint(fontString, text, color)
	fontString:SetText(text or "")
	if color then
		fontString:SetTextColor(RGB(color))
	end
	fontString:SetShown(text ~= nil)
end

--[[
    What each kind shows: its fonts, colors, and right side, filled in from the
    entry. Every row is the same type size; kinds differ by color only, never by
    a smaller font.
]]
local function Look(entry)
	local kind = entry.kind
	local left, right = entry.left, entry.right
	local leftColor, rightColor = entry.leftColor, entry.rightColor
	local leftFont = "GameFontHighlight"
	if kind == "header" or kind == "submenu" or kind == "section" then
		leftFont = "GameFontNormal"
		leftColor, rightColor = leftColor or "TITLE", rightColor or "MUTED"
	elseif kind == "status" then
		-- A status reads as a heading over its reason, so it's gold like every label.
		leftColor = leftColor or "TITLE"
	elseif kind == "toggle" then
		right = entry.on and TEXT.on or TEXT.off
		leftColor = leftColor or (not entry.on and "MUTED") or "TEXT"
		rightColor = rightColor or (entry.on and "ON") or "MUTED"
	elseif kind == "choice" then
		-- The check sits on the left and every row keeps its room, so names (or values on the right) line up.
		-- The pick matches the value on the row that opened it; the rest are options, not gray. Off stays gray.
		local color = ((left == TEXT.off or right == TEXT.off) and "MUTED") or (entry.selected and "VALUE") or "BODY"
		local mark = entry.selected and Kit.CHECK_MARK or Kit.CHECK_BLANK
		left = left and (mark .. " " .. left) or mark
		leftColor, rightColor = leftColor or color, rightColor or color
	elseif kind == "action" then
		-- The button's kept click is named on its row, gray, as a gesture is ("Drag").
		if not right and entry.click then
			if IsButtonClick(entry.click) then
				right = TEXT.clicks[entry.click]
			else
				right = entry.click
			end
			rightColor = rightColor or "MUTED"
		end
		leftColor, rightColor = leftColor or "INFO", rightColor or "VALUE"
	elseif kind == "hint" then
		-- v1's click hint, kept so an add-on not yet moved still draws; new menus use action rows.
		leftColor, rightColor = leftColor or "INFO", rightColor or "INFO"
	elseif kind == "item" then
		local itemID = ItemID(entry)
		if itemID or entry.link then
			local name, _, quality, icon = GetItem(entry.link or itemID)
			if name then
				left = (icon and format("|T%s:0|t ", icon) or "") .. name
				leftColor = leftColor or QualityRGB(quality)
			else
				left = format(TEXT.loading, itemID or 0)
				leftColor = "MUTED"
				WatchItem(itemID)
			end
		end
		if entry.count then
			left = (left or "") .. " " .. Kit.Color("TEXT", format(TEXT.count, entry.count))
		end
		rightColor = rightColor or "VALUE"
	elseif kind == "value" then
		leftColor = leftColor or "BODY"
		rightColor = rightColor or (right == TEXT.off and "MUTED") or "VALUE"
	elseif kind == "description" then
		leftColor = leftColor or "BODY"
	elseif kind == "note" then
		leftColor = leftColor or "MUTED"
	end
	-- A row that can't be used right now reads gray on both sides, as the game grays its own.
	if entry.disabled then
		leftColor, rightColor = "MUTED", "MUTED"
	end
	return {
		left = left,
		right = right,
		leftColor = leftColor or "TEXT",
		rightColor = rightColor or "TEXT",
		leftFont = leftFont,
		rightOnHover = entry.rightOnHover,
		hover = entry.hover,
	}
end

-- How a row reads, or under the cursor its hover: the name brightened and the hover's right side.
local function Dress(row, over)
	local look = row.look
	if not look then
		return
	end
	local hover = over and look.hover
	Paint(row.left, look.left, hover and "TEXT" or look.leftColor)
	if hover then
		Paint(row.right, hover.right, hover.rightColor or look.rightColor)
	else
		Paint(row.right, look.right, look.rightColor)
	end
	if look.rightOnHover and not over then
		row.right:Hide()
	end
end

local function ColorKey(color)
	if type(color) == "table" then
		return format("%.3f,%.3f,%.3f", RGB(color))
	end
	return tostring(color)
end

-- A key for a panel's rows that changes only when what they show does.
local function LooksKey(entries, looks, arrows)
	local parts = {}
	for index, entry in ipairs(entries) do
		local look = looks[index]
		parts[index] = table.concat({
			entry.kind or "",
			look and look.left or "",
			look and look.right or "",
			look and ColorKey(look.leftColor) or "",
			look and ColorKey(look.rightColor) or "",
			look and look.hover and look.hover.right or "",
			look and look.rightOnHover and "h" or "",
			arrows[index] and ">" or "",
			entry.onClick and "c" or "",
			entry.tooltip and "t" or "",
			entry.disabled and "d" or "",
		}, "\31")
	end
	return table.concat(parts, "\30")
end

-- A new section of a tooltip gets a spacer above it: the row's helper sits one blank line under the rest, gray.
local function AddHelper(tooltip, helper)
	if not helper or helper == "" then
		return
	end
	tooltip:AddLine(" ")
	local red, green, blue = RGB("HELP")
	tooltip:AddLine(helper, red, green, blue, true)
end

local function HideOwnTooltip(owner)
	if GameTooltip:GetOwner() == owner then
		GameTooltip:Hide()
	end
end

local function Row(panel, index)
	local row = panel.rows[index]
	if row then
		row:Show()
		return row
	end
	row = CreateFrame("Button", nil, panel)
	row:RegisterForClicks("AnyUp") -- Any mouse button does a row's job, so an old Right-Click habit can't miss.
	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints()
	local red, green, blue = RGB("TITLE")
	row.highlight:SetColorTexture(red, green, blue, HIGHLIGHT_ALPHA)
	row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.left:SetJustifyH("LEFT")
	row.left:SetJustifyV("TOP")
	row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.right:SetJustifyH("RIGHT")
	row.right:SetWordWrap(false)
	row.arrow = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.arrow:SetText(Kit.SUBMENU_ARROW)
	row.line = row:CreateTexture(nil, "ARTWORK")
	row.line:SetHeight(1)
	row.line:SetPoint("LEFT", TEXT_INSET, 0)
	row.line:SetPoint("RIGHT", -TEXT_INSET, 0)
	red, green, blue = RGB("SEPARATOR")
	row.line:SetColorTexture(red, green, blue, SEPARATOR_ALPHA)

	row:SetScript("OnClick", function(self)
		local entry = self.entry
		if not entry or entry.disabled then
			return
		end
		local menu = panel.menu
		if entry.onClick then
			PlayClick()
			if entry.closes and menu then
				menu:Hide()
			end
			entry.onClick()
			if menu then
				menu:AfterChange()
			end
		elseif self.opensFlyout and menu then
			menu:OpenFlyout(entry.submenu, panel.depth + 1)
		end
	end)

	--[[
		A row that opens a sub-menu opens it, and any other row closes the ones
		beyond this panel, as a game dropdown's submenu does.
	]]
	row:SetScript("OnEnter", function(self)
		local entry = self.entry
		if self.look and (self.look.hover or self.look.rightOnHover) then
			Dress(self, true)
		end
		if entry and entry.tooltip then
			GameTooltip:SetOwner(self, panel.tooltipAnchor or "ANCHOR_RIGHT")
			entry.tooltip(GameTooltip)
			AddHelper(GameTooltip, entry.helper)
			GameTooltip:Show()
		elseif entry and entry.kind == "item" and (entry.itemID or entry.link) then
			GameTooltip:SetOwner(self, panel.tooltipAnchor or "ANCHOR_RIGHT")
			if entry.link then
				GameTooltip:SetHyperlink(entry.link)
			else
				GameTooltip:SetItemByID(entry.itemID)
			end
			AddHelper(GameTooltip, entry.helper)
			GameTooltip:Show()
		end
		local menu = panel.menu
		if menu then
			if self.opensFlyout then
				menu:OpenFlyout(entry.submenu, panel.depth + 1)
			else
				menu:CloseFrom(panel.depth + 1)
			end
		end
		if panel.onEnterRow then
			panel.onEnterRow(self, entry)
		end
	end)
	row:SetScript("OnLeave", function(self)
		if self.look and (self.look.hover or self.look.rightOnHover) then
			Dress(self, false)
		end
		HideOwnTooltip(self)
	end)
	row:SetScript("OnHide", HideOwnTooltip)
	panel.rows[index] = row
	return row
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

local Panel = {}

local SPACER = { kind = "spacer" }

-- Every heading gets a spacer above it, unless it opens the panel or a spacer is already there.
local function WithSpacers(source)
	local entries = {}
	for _, entry in ipairs(source) do
		local previous = entries[#entries]
		if HEADINGS[entry.kind] and previous and previous.kind ~= "spacer" then
			entries[#entries + 1] = SPACER
		end
		entries[#entries + 1] = entry
	end
	return entries
end

--[[
    Lays the entries out and sizes the panel to them. Each row is a line plus
    SPACE.NEAR above and below, a spacer SPACE.GROUP, a separator SPACE.NEAR.

    The panel is as wide as its widest row, between MIN_WIDTH and MAX_WIDTH. A
    row's left text wraps within what its right side leaves, and the row grows
    to fit; the right side never wraps and stays level with the first line. A
    note or a description wraps to the width the other rows settle on, so on its
    own it never makes the panel wider than its cap.

    In a panel where any row opens a sub-menu, every right side ends where the
    arrow's column begins, so an On without an arrow lines up with one beside it.

    context, from Kit.CreateMenu, says which rows open a sub-menu (hasFlyout);
    without it, as in v1, a submenu row always carries the arrow. A panel is laid
    out again only when what its rows show changes; their clicks always follow
    the new entries.
]]
function Panel:Render(source, context)
	local entries = WithSpacers(source)
	local looks, arrows = {}, {}
	local anyArrow = false
	for index, entry in ipairs(entries) do
		local kind = entry.kind
		if kind ~= "spacer" and kind ~= "separator" then
			looks[index] = Look(entry)
		end
		if entry.submenu ~= nil or entry.flyout ~= nil then
			if context and context.hasFlyout then
				arrows[index] = context.hasFlyout(entry)
			else
				arrows[index] = kind == "submenu"
			end
			anyArrow = anyArrow or arrows[index]
		end
	end

	local rows = self.rows
	self.rowCount = #entries
	for index, entry in ipairs(entries) do
		local row = Row(self, index)
		row.entry = entry
		-- A gray row keeps its arrow, gray, but opens nothing: hover and click both pass it by.
		row.opensFlyout = (arrows[index] and not entry.disabled) or false
		row:UnlockHighlight()
	end
	for index = #entries + 1, #rows do
		rows[index]:Hide()
		rows[index].entry = nil
		rows[index].look = nil
		rows[index].opensFlyout = false
	end

	local key = LooksKey(entries, looks, arrows)
	if key == self.shownKey then
		self:Layout() -- Row() showed every row again: a scrolled list hides the ones out of view
		return
	end
	self.shownKey = key

	local arrowWidth = 0
	if anyArrow then
		local probe = Row(self, 1)
		arrowWidth = (probe.arrow:GetStringWidth() or LINE_HEIGHT) + ARROW_GAP
	end
	local insets = 2 * (TEXT_INSET + ROW_INSET)

	-- First pass: what each row says, and the width the widest needs.
	local width = MIN_WIDTH
	local measured = {}
	for index, entry in ipairs(entries) do
		local row = rows[index]
		local kind = entry.kind
		local look = looks[index]
		local clickable = (entry.onClick ~= nil or row.opensFlyout) and not entry.disabled
		row.look = look
		row:EnableMouse(
			clickable
				or entry.tooltip ~= nil
				or (kind == "item" and (entry.itemID or entry.link) ~= nil)
				or (look and (look.hover or look.rightOnHover)) ~= nil
		)
		row.highlight:SetShown(clickable)
		row.line:SetShown(kind == "separator")
		row.arrow:SetShown(arrows[index] or false)
		row.arrow:SetText(entry.disabled and ArrowIn("MUTED") or Kit.SUBMENU_ARROW)

		if not look then
			Paint(row.left, nil)
			Paint(row.right, nil)
			row.height = kind == "spacer" and SPACE.GROUP or SPACE.NEAR
		else
			row.left:SetFontObject(look.leftFont)
			row.right:SetFontObject("GameFontHighlight")
			row.left:SetWordWrap(false)
			row.left:SetWidth(0)
			row.left:SetHeight(0)
			-- As wide as its widest look: the hover's right side measured too, so nothing shifts on hover.
			local rightWidth = 0
			if look.hover then
				Dress(row, true)
				rightWidth = row.right:GetStringWidth() or 0
			end
			Paint(row.left, look.left, look.leftColor)
			Paint(row.right, look.right, look.rightColor)
			if look.right then
				rightWidth = math.max(rightWidth, row.right:GetStringWidth() or 0)
			end
			if anyArrow and (arrows[index] or rightWidth > 0) then
				rightWidth = rightWidth + arrowWidth
			end
			local indent = OPTIONS[kind] and OPTION_INDENT or 0
			local leftWidth = row.left:GetStringWidth() or 0
			local rightPart = rightWidth > 0 and (RIGHT_GAP + rightWidth) or 0
			measured[index] = { indent = indent, leftWidth = leftWidth, rightPart = rightPart }
			if WRAPS[kind] then
				width = math.max(width, math.min(leftWidth + indent + insets, WRAPS[kind]))
			else
				width = math.max(width, leftWidth + indent + rightPart + insets)
			end
		end
	end
	width = math.min(math.ceil(width), MAX_WIDTH)

	-- Second pass: a left side that doesn't fit wraps within what the right side leaves, and the row grows.
	for index, entry in ipairs(entries) do
		local row = rows[index]
		local size = measured[index]
		if size then
			local available = width - insets - size.indent - size.rightPart
			local _, fontSize = row.left:GetFont()
			local lineHeight = fontSize or LINE_HEIGHT
			if WRAPS[entry.kind] or size.leftWidth > available then
				row.left:SetWordWrap(true)
				row.left:SetWidth(math.max(available, 1))
				-- Cleared, then set: the game doesn't re-wrap unchanged text, so a refresh would keep the one-line layout.
				local text = row.left:GetText() or ""
				row.left:SetText("")
				row.left:SetText(text)
				local textHeight = math.max(lineHeight, math.ceil(row.left:GetStringHeight() or lineHeight))
				row.left:SetHeight(textHeight)
				row.height = textHeight + 2 * SPACE.NEAR
			else
				row.left:SetHeight(lineHeight)
				row.height = lineHeight + 2 * SPACE.NEAR
			end
			row.left:ClearAllPoints()
			row.left:SetPoint("TOPLEFT", TEXT_INSET + size.indent, -SPACE.NEAR)
			row.arrow:ClearAllPoints()
			row.arrow:SetPoint("TOPRIGHT", -TEXT_INSET, -SPACE.NEAR)
			row.right:ClearAllPoints()
			row.right:SetPoint("TOPRIGHT", -(TEXT_INSET + (anyArrow and arrowWidth or 0)), -SPACE.NEAR)
		end
		row:SetHeight(row.height)
	end
	self:SetWidth(width)
	self:Layout()
	-- A row already under the cursor shows its hover look; every other hover-only right side hides.
	for index = 1, #entries do
		local row = rows[index]
		if row.look then
			Dress(row, row:IsMouseEnabled() and Kit.IsCursorOver(row))
		end
	end
end

--[[
    Stacks the rows and sets the panel's height. Every panel, the main menu
    included, grows to fit its rows. Only one whose rows would run off the
    screen (taller than the screen less SCREEN_MARGIN, as a very long bag list
    can be) stays that tall and shows whole rows from self.scroll on: the mouse
    wheel moves them SCROLL_STEP at a time, and a thin thumb in the plate's
    right margin shows where the view sits in the list.
]]
function Panel:Layout()
	local rows, count = self.rows, self.rowCount or 0
	local content = 0
	for index = 1, count do
		content = content + rows[index].height
	end
	-- The screen's height in this panel's own points, whatever the UI scale.
	local screen = UIParent:GetHeight() * UIParent:GetEffectiveScale() / self:GetEffectiveScale()
	local maxHeight = math.floor(screen - SCREEN_MARGIN)
	local room = maxHeight - 2 * PANEL_INSET
	local scrolls = content > room

	-- The first row shown: never so far down that the view has room left at the bottom.
	local first = 1
	if scrolls then
		local lastFirst, used = count, 0
		for index = count, 1, -1 do
			used = used + rows[index].height
			if used > room then
				break
			end
			lastFirst = index
		end
		first = math.max(1, math.min(self.scroll or 1, lastFirst))
	end
	self.scroll = first

	local y, above, full = PANEL_INSET, 0, false
	for index = 1, count do
		local row = rows[index]
		if index < first then
			above = above + row.height
		elseif not full and (not scrolls or y + row.height <= PANEL_INSET + room) then
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", self, "TOPLEFT", ROW_INSET, -y)
			row:SetPoint("TOPRIGHT", self, "TOPRIGHT", -ROW_INSET, -y)
			y = y + row.height
		else
			full = true
		end
		row:SetShown(index >= first and not full)
	end
	self:SetHeight(scrolls and maxHeight or y + PANEL_INSET)
	self:EnableMouseWheel(scrolls)

	if scrolls and not self.thumb then
		self.thumb = self:CreateTexture(nil, "ARTWORK")
		self.thumb:SetWidth(THUMB_WIDTH)
		local red, green, blue = RGB("SEPARATOR")
		self.thumb:SetColorTexture(red, green, blue, THUMB_ALPHA)
		self:SetScript("OnMouseWheel", function(panel, delta)
			panel:Scroll(delta)
		end)
	end
	if self.thumb then
		self.thumb:SetShown(scrolls)
		if scrolls then
			self.thumb:ClearAllPoints()
			local top = PANEL_INSET + room * above / content
			self.thumb:SetPoint("TOPRIGHT", self, "TOPRIGHT", -(ROW_INSET - THUMB_WIDTH) / 2, -top)
			self.thumb:SetHeight(math.max(room * (y - PANEL_INSET) / content, LINE_HEIGHT))
		end
	end
end

-- A notch of the wheel up (delta 1) or down (-1); a sub-menu off a row that moved closes.
function Panel:Scroll(delta)
	local before = self.scroll
	self.scroll = (self.scroll or 1) - delta * SCROLL_STEP
	self:Layout()
	if self.scroll ~= before and self.menu then
		self.menu:CloseFrom(self.depth + 1)
	end
end

-- The row that opens a flyout by name, for placing the flyout beside it.
function Panel:SubmenuRow(name)
	for _, row in ipairs(self.rows) do
		if row:IsShown() and row.entry and row.entry.submenu == name then
			return row
		end
	end
end

--[[
    A new, hidden panel on its plate. A named panel can be listed in
    UISpecialFrames so Escape closes it. Mouse is enabled so a click on the plate
    never falls through to the world. Kit.CreateMenu makes its own; an add-on
    still on v1 makes them here and places them itself.
]]
function Kit.CreatePanel(name, parent)
	local panel = CreateFrame("Frame", name, parent or UIParent)
	panel:Hide()
	panel:SetFrameStrata("DIALOG")
	panel:SetToplevel(true)
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)
	panel.rows = {}
	panel.depth = 1
	Kit.AddPlate(panel)
	for key, method in pairs(Panel) do
		panel[key] = method
	end
	return panel
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

local Menu = {}
Menu.__index = Menu
local menus = {}

--[[
    A menu and the sub-menus its rows open, with the opening, placing and
    closing every Gogo menu shares (Style Guide → MENUS, MINIMAP MENU →
    Placement and Behavior):

      Kit.CreateMenu({
          name = ADDON_NAME .. "Menu",  -- named, so Escape closes it
          build = BuildMainEntries,     -- returns the menu's entries
          flyouts = FLYOUTS,            -- flyouts[key]() returns a sub-menu's entries
          afterChange = ns.RefreshSettings, -- after every row click and button click
          fallback = nil,               -- optional { RightButton = fn }: when no row's click matches
          publish = nil,                -- false: don't set ns.ShowMenu and the rest
      })

    A sub-menu with nothing to show doesn't open, and its row has no arrow.
    Sub-menus go MAX_DEPTH - 1 deep, each on the side the menu opened toward.

    The first menu an add-on creates without publish = false is its mini-map
    menu, and sets v1's public names: ns.ShowMenu(anchor, flyoutKey, how),
    ns.HideMenu, ns.RefreshMenu (every open menu redraws), ns.IsMenuShown,
    ns.IsMenuFrame and ns.OpenFlyout(key).
]]
function Kit.CreateMenu(spec)
	local menu = setmetatable({
		spec = spec,
		flyouts = spec.flyouts or {},
		panels = {},
		state = { open = {}, idle = 0, closeDelay = HOVER_CLOSE_DELAY, openLeft = true, openDown = true },
	}, Menu)

	local main = Kit.CreatePanel(spec.name, UIParent)
	main.menu = menu
	menu.panels[1] = main
	menu.frame = main
	if spec.name then
		table.insert(UISpecialFrames, spec.name)
	end
	main:SetScript("OnUpdate", function(_, elapsed)
		menu:OnUpdate(elapsed)
	end)
	main:SetScript("OnHide", function()
		menu:OnHide()
	end)
	menus[#menus + 1] = menu

	if spec.publish ~= false and not Kit.mainMenu then
		Kit.mainMenu = menu
		function ns.ShowMenu(anchor, flyoutKey, how)
			menu:Show(anchor, how, flyoutKey)
		end
		function ns.HideMenu()
			menu:Hide()
		end
		function ns.IsMenuShown()
			return menu:IsShown()
		end
		function ns.OpenFlyout(key)
			menu:OpenFlyout(key, 2)
		end
		ns.RefreshMenu = Kit.RefreshAll
		ns.IsMenuFrame = Kit.IsMenuFrame
	end
	return menu
end

--[[
    A dropdown on the kit's own menu (Kit.CreateMenu): its own frames, never
    the game's shared dropdown frames, so nothing taints them.
    menu:Open(anchor, entries, onClose, upward) shows entries under anchor, or
    over it when upward (a click on the open anchor again closes it);
    menu:Close(); and menu:IsOpenFor(anchor). A row's click closes the menu
    first, unless the entry sets keepOpen. onClose runs whenever it hides.
]]
function Kit.CreateDropdownMenu(name)
	local shown = { entries = nil, onClose = nil }
	local kitMenu = Kit.CreateMenu({
		name = name,
		publish = false,
		build = function()
			return shown.entries or {}
		end,
	})
	local frame = kitMenu.frame
	frame:SetFrameStrata("FULLSCREEN_DIALOG") -- In front of the window it drops from
	frame:HookScript("OnHide", function()
		local onClose = shown.onClose
		shown.entries, shown.onClose = nil, nil
		if onClose then
			onClose()
		end
	end)

	local menu = {}

	function menu:Close()
		kitMenu:Hide()
	end

	function menu:IsOpenFor(anchor)
		return kitMenu:IsShown() and kitMenu.state.anchor == anchor
	end

	function menu:Open(anchor, entries, onClose, upward)
		if menu:IsOpenFor(anchor) then
			kitMenu:Hide()
			return
		end
		kitMenu:Hide()
		local list = {}
		for index, entry in ipairs(entries) do
			if entry.onClick and not entry.keepOpen and not entry.closes then
				local copy = {}
				for key, value in pairs(entry) do
					copy[key] = value
				end
				copy.closes = true
				entry = copy
			end
			list[index] = entry
		end
		shown.entries, shown.onClose = list, onClose
		kitMenu:Show(anchor, "hover")
		-- A dropdown's list hangs straight under its field, or over it, MENU_GAP off it, not off a corner.
		frame:ClearAllPoints()
		if upward then
			frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, MENU_GAP)
		else
			frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -MENU_GAP)
		end
	end

	return menu
end

-- Every open menu redraws in place; the rest wait until they open.
function Kit.RefreshAll()
	for _, menu in ipairs(menus) do
		menu:Refresh()
	end
end

-- True for any of the add-on's menus, their sub-menus, and anything inside them.
function Kit.IsMenuFrame(frame)
	if frame == nil then
		return false
	end
	for _, menu in ipairs(menus) do
		if Kit.IsInside(frame, menu.frame) then
			return true
		end
	end
	return false
end

-- The panel at a depth: 1 is the menu, 2 its first sub-menu, drawn over it.
function Menu:Panel(depth)
	local panel = self.panels[depth]
	if not panel then
		panel = Kit.CreatePanel(nil, self.frame)
		panel:SetFrameLevel(self.frame:GetFrameLevel() + 20 * (depth - 1))
		panel.menu = self
		panel.depth = depth
		self.panels[depth] = panel
	end
	return panel
end

function Menu:Builder(entry)
	return entry.flyout or (entry.submenu ~= nil and self.flyouts[entry.submenu]) or nil
end

function Menu:HasFlyout(entry)
	local builder = self:Builder(entry)
	if not builder then
		return false
	end
	local entries = builder()
	return entries ~= nil and #entries > 0
end

--[[
    How far a window's line sits inside the window's edge on the side its
    flyout opens toward, so the flyout overlaps the window, not the line, by
    FLYOUT_OVERLAP. Measured when the window is on screen; else the line's
    usual place, ROW_INSET in, where Kit.AddOptionsLine's text meets the body's.
]]
local function LineInset(line, openLeft)
	local window = line.window
	if window then
		if openLeft and line:GetLeft() and window:GetLeft() then
			return line:GetLeft() - window:GetLeft()
		elseif not openLeft and line:GetRight() and window:GetRight() then
			return window:GetRight() - line:GetRight()
		end
	end
	return ROW_INSET
end

--[[
    Where a menu opens (MINIMAP MENU → Placement, MENUS → Opening and Closing),
    decided once by which half of the screen it opens in:
      "hover", "click"  off a button's corner, the menu's corner MENU_GAP from the opposite one
      "line"            off a window's line, overlapping the window's edge by FLYOUT_OVERLAP
      "cursor"          a right-click menu, at the cursor, as the game opens its own
]]
function Menu:Place(anchor, how)
	local main, state = self.frame, self.state
	local width, height = UIParent:GetWidth(), UIParent:GetHeight()
	main:ClearAllPoints()
	if how == "cursor" or not anchor then
		local scale = UIParent:GetEffectiveScale()
		local x, y = GetCursorPosition()
		x, y = x / scale, y / scale
		state.openLeft, state.openDown = x > width / 2, y > height / 2
		local point = (state.openDown and "TOP" or "BOTTOM") .. (state.openLeft and "RIGHT" or "LEFT")
		main:SetPoint(point, UIParent, "BOTTOMLEFT", x, y)
	else
		local x, y = anchor:GetCenter()
		local scale = anchor:GetEffectiveScale() / UIParent:GetEffectiveScale()
		state.openLeft = (x or 0) * scale > width / 2
		state.openDown = (y or 0) * scale > height / 2
		if how == "line" then
			local inside = Kit.FLYOUT_OVERLAP - LineInset(anchor, state.openLeft)
			if state.openLeft then
				main:SetPoint("TOPRIGHT", anchor, "TOPLEFT", inside, Kit.FLYOUT_RISE)
			else
				main:SetPoint("TOPLEFT", anchor, "TOPRIGHT", -inside, Kit.FLYOUT_RISE)
			end
		else
			local point = (state.openDown and "TOP" or "BOTTOM") .. (state.openLeft and "RIGHT" or "LEFT")
			local relative = (state.openDown and "BOTTOM" or "TOP") .. (state.openLeft and "LEFT" or "RIGHT")
			main:SetPoint(
				point,
				anchor,
				relative,
				state.openLeft and -MENU_GAP or MENU_GAP,
				state.openDown and -MENU_GAP or MENU_GAP
			)
		end
	end
	main.tooltipAnchor = state.openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

-- A sub-menu beside the row that opened it, overlapping its panel, its first row level with that row.
local function PlaceFlyout(panel, row, openLeft)
	local inside = Kit.FLYOUT_OVERLAP - ROW_INSET
	panel:ClearAllPoints()
	if openLeft then
		panel:SetPoint("TOPRIGHT", row, "TOPLEFT", inside, Kit.FLYOUT_RISE)
	else
		panel:SetPoint("TOPLEFT", row, "TOPRIGHT", -inside, Kit.FLYOUT_RISE)
	end
end

--[[
    Opens the menu. how is "hover", "click", "line" or "cursor" (Place, above);
    a click keeps it open a little longer once the cursor leaves. flyoutKey
    opens that row's sub-menu at once. An anchor already showing the menu keeps
    its place and its open sub-menus.
]]
function Menu:Show(anchor, how, flyoutKey)
	if not ns.db then
		return
	end
	local state, main = self.state, self.frame
	local reopen = main:IsShown() and anchor ~= nil and state.anchor == anchor and how ~= "cursor"
	if not reopen then
		state.closeDelay = HOVER_CLOSE_DELAY
		state.open = {}
		-- A long list opens at its top.
		for _, panel in ipairs(self.panels) do
			panel.scroll, panel.shownFor = 1, nil
		end
	end
	state.anchor = anchor
	state.idle = 0
	if how == "click" then
		state.closeDelay = CLICK_CLOSE_DELAY
	end
	if flyoutKey then
		state.open = { [2] = flyoutKey }
	end
	if not reopen then
		self:Place(anchor, how)
	end
	main:Show()
	self:Render()
end

function Menu:Hide()
	self.frame:Hide()
end

function Menu:IsShown()
	return self.frame:IsShown()
end

-- Redraws in place while open; a no-op otherwise.
function Menu:Refresh()
	if self.frame:IsShown() then
		self:Render()
	end
end

function Menu:OpenFlyout(key, depth)
	depth = depth or 2
	if depth > MAX_DEPTH then
		return
	end
	if self.state.open[depth] == key then
		return
	end
	self.state.open[depth] = key
	for deeper = depth + 1, MAX_DEPTH do
		self.state.open[deeper] = nil
	end
	self:Render()
end

-- Closes the sub-menus from this depth on.
function Menu:CloseFrom(depth)
	local changed = false
	for level = depth, MAX_DEPTH do
		if self.state.open[level] ~= nil then
			self.state.open[level] = nil
			changed = true
		end
		local panel = self.panels[level]
		if panel and panel:IsShown() then
			panel:Hide()
			changed = true
		end
	end
	if changed then
		local opener = self.panels[depth - 1]
		for _, row in ipairs(opener and opener.rows or {}) do
			row:UnlockHighlight()
		end
	end
end

function Menu:Render()
	local main = self.frame
	if not main:IsShown() then
		return
	end
	local context = {
		hasFlyout = function(entry)
			return self:HasFlyout(entry)
		end,
	}
	main:Render(self.spec.build(self) or {}, context)
	for depth = 2, MAX_DEPTH do
		local key = self.state.open[depth]
		local parent = self.panels[depth - 1]
		local row = key ~= nil and parent and parent:IsShown() and parent:SubmenuRow(key)
		local builder = row and self:Builder(row.entry)
		local entries = builder and builder()
		if not (entries and #entries > 0) then
			self:CloseFrom(depth)
			return
		end
		local panel = self:Panel(depth)
		if panel.shownFor ~= key then
			panel.scroll, panel.shownFor = 1, key
		end
		panel.tooltipAnchor = main.tooltipAnchor
		panel:Render(entries, context)
		PlaceFlyout(panel, row, self.state.openLeft)
		panel:Show()
		row:LockHighlight()
	end
end

-- Every row click and button click ends here: the add-on's afterChange, then a redraw.
function Menu:AfterChange()
	if self.spec.afterChange then
		self.spec.afterChange()
	end
	self:Refresh()
end

function Menu:IsCursorOver()
	for _, panel in ipairs(self.panels) do
		if panel:IsShown() and Kit.IsCursorOver(panel) then
			return true
		end
	end
	return false
end

-- Closes a moment after the cursor has left the anchor, the menu, and its sub-menus.
function Menu:OnUpdate(elapsed)
	local state = self.state
	local anchor = state.anchor
	if anchor and not anchor:IsVisible() then
		self:Hide()
		return
	end
	if (anchor and Kit.IsCursorOver(anchor)) or self:IsCursorOver() then
		state.idle = 0
		return
	end
	state.idle = state.idle + elapsed
	if state.idle >= state.closeDelay then
		self:Hide()
	end
end

function Menu:OnHide()
	self.state.open = {}
	self.state.anchor = nil
	for depth = 2, #self.panels do
		self.panels[depth]:Hide()
	end
	if Kit.IsInside(GameTooltip:GetOwner(), self.frame) then
		GameTooltip:Hide()
	end
end

--------------------------------------------------------------------------------
-- Button Clicks
--------------------------------------------------------------------------------

--[[
    Left-Click toggles the menu in every add-on: it holds a menu that hover
    opened, and closes one it already holds. Any other click runs the main
    entry that names it (the add-on's one kept click, a Right-Click: Style Guide
    → MINIMAP MENU → Button Clicks), else the add-on's fallback for it; a click
    with no job does nothing. True when the click did something.
]]
function Menu:HandleClick(anchor, button)
	if not ns.db then
		return false
	end
	if button == "LeftButton" then
		local state = self.state
		if self:IsShown() and state.anchor == anchor and state.closeDelay == CLICK_CLOSE_DELAY then
			self:Hide()
		else
			self:Show(anchor, "click")
		end
		return true
	end
	local key = (IsShiftKeyDown() and "Shift" or "") .. button
	for _, entry in ipairs(self.spec.build(self) or {}) do
		if entry.click == key and entry.onClick and not entry.disabled then
			if entry.closes then
				self:Hide()
			end
			entry.onClick()
			self:AfterChange()
			return true
		end
	end
	local fallback = self.spec.fallback and self.spec.fallback[key]
	if fallback then
		fallback(anchor)
		self:AfterChange()
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------

--[[
    Every window's title, the add-on's own windows and a window drawn on the
    plate alike (Style Guide → WINDOWS): the title white, the slashes gray, the
    Short Name blue, "Buff Duty // GtG".
]]
function Kit.WindowTitle(title)
	return Kit.Color("TEXT", title) .. " " .. Kit.Color("SEPARATOR", "//") .. " " .. Kit.Color("INFO", TEXT.shortName)
end

--[[
    A window drawn on the plate (Style Guide → WINDOWS) is laid out as a menu
    is, by the same numbers, so every window spaces alike. Its y runs down from
    the window's top, negative, as SetPoint takes it.

      the title          its text WINDOW_EDGE in from the top and left, the close button
                         (WINDOW_HEADER_HEIGHT square) WINDOW_EDGE in from the right, on its line
      the body           from WINDOW_BODY_TOP: the title's room, then two spacers' room
      every line         a ROW_HEIGHT row (Kit.AddWindowRow), its highlight across the
                         window ROW_INSET in from each side, its text TEXT_INSET in from that
      between groups     a spacer, WINDOW_SPACER
      the foot           a spacer, the separator in its own SPACE.NEAR, and the Options line
                         (Kit.PlaceOptionsLine), as a menu's Options row sits
      the bottom         WINDOW_EDGE under the last text (Kit.WindowHeight), as on every side

    Its height is what it holds, never rounded up, so no filler lands between
    its rows; its width is a multiple of 16 (Kit.WindowWidth).
]]
Kit.WINDOW_EDGE = EDGE
Kit.WINDOW_HEADER_HEIGHT = SPACE.GROUP
Kit.WINDOW_BODY_TOP = EDGE + Kit.WINDOW_HEADER_HEIGHT + 2 * SPACE.GROUP
Kit.WINDOW_SPACER = SPACE.GROUP
Kit.WINDOW_ROW_INSET = ROW_INSET
Kit.WINDOW_TEXT_INSET = TEXT_INSET
Kit.ROW_HEIGHT = LINE_HEIGHT + 2 * SPACE.NEAR
local WINDOW_STEP = 16
local WINDOW_MIN_WIDTH = 200 -- The maintainer's number (Style Guide → WINDOWS)

--[[
    The header of a window drawn on the plate (Buff Duty): the title's text
    EDGE in from the top and left, as every other side's text is, and the
    game's close button EDGE in from the right, centered on the title's line.
    onClose replaces the button's own click, which would hide a protected
    parent. Returns the title's font string and the button; the body starts
    WINDOW_BODY_TOP down.
]]
function Kit.AddWindowHeader(frame, title, onClose)
	local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("TOPLEFT", frame, "TOPLEFT", EDGE, -EDGE)
	text:SetHeight(LINE_HEIGHT)
	text:SetText(Kit.WindowTitle(title))
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetSize(Kit.WINDOW_HEADER_HEIGHT, Kit.WINDOW_HEADER_HEIGHT)
	close:SetPoint("RIGHT", frame, "TOPRIGHT", -EDGE, -(EDGE + LINE_HEIGHT / 2))
	if onClose then
		close:SetScript("OnClick", onClose)
	end
	return text, close
end

--[[
    Opens a kit menu off a window's row as a "line" flyout, overlapping the
    window's edge by FLYOUT_OVERLAP, and keeps the row lit while it's open, as
    a menu row keeps its highlight while its sub-menu is open. For a window
    whose rows share one menu (Currency Replenish's amounts): set what the
    menu shows, then call this from the row's OnEnter and OnClick.
]]
function Kit.OpenRowMenu(row, menu)
	local held = menu.heldRow
	if held and held ~= row then
		held:UnlockHighlight()
	end
	menu.heldRow = nil
	menu:Show(row, "line")
	if not menu:IsShown() then
		return
	end
	menu.heldRow = row
	row:LockHighlight()
	if not menu.unlocksRow then
		menu.unlocksRow = true
		menu.frame:HookScript("OnHide", function()
			if menu.heldRow then
				menu.heldRow:UnlockHighlight()
				menu.heldRow = nil
			end
		end)
	end
end

--[[
    A line of a window's body (Style Guide → WINDOWS): a ROW_HEIGHT row in the
    menus' font, row.left at its left and row.right at its right. With a
    flyout, the row carries the sub-menu arrow in its own column (row.right
    ends where it begins), lights across its whole width under the cursor,
    and hovering anywhere on it or a click opens the flyout (Kit.OpenRowMenu).
    flyout is a function returning the entries, on a menu of the row's own
    (row.menu, afterChange after every click there), or a kit menu several
    rows share. Without one, it's a plain line: no arrow, no highlight, and
    the mouse passes through to the window. Place it with Kit.PlaceWindowRow;
    anything the window lays over it (Buff Duty's icons) sits at a higher
    frame level, between its two sides.
]]
function Kit.AddWindowRow(frame, flyout, afterChange)
	local row = CreateFrame("Button", nil, frame)
	row:SetHeight(Kit.ROW_HEIGHT)
	row.window = frame
	row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.left:SetPoint("LEFT", TEXT_INSET, 0)
	row.left:SetJustifyH("LEFT")
	row.left:SetWordWrap(false)
	row.arrow = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.arrow:SetPoint("RIGHT", -TEXT_INSET, 0)
	row.arrow:SetText(Kit.SUBMENU_ARROW)
	row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.right:SetJustifyH("RIGHT")
	row.right:SetWordWrap(false)
	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints()
	local red, green, blue = RGB("TITLE")
	row.highlight:SetColorTexture(red, green, blue, HIGHLIGHT_ALPHA)

	if not flyout then
		row.arrow:Hide()
		row.highlight:Hide()
		row.right:SetPoint("RIGHT", -TEXT_INSET, 0)
		row:EnableMouse(false)
		return row
	end
	row.right:SetPoint("RIGHT", row.arrow, "LEFT", -ARROW_GAP, 0)
	row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	if type(flyout) == "function" then
		row.menu = Kit.CreateMenu({ publish = false, build = flyout, afterChange = afterChange })
	else
		row.menu = flyout
	end
	local function Open(self)
		Kit.OpenRowMenu(self, self.menu)
	end
	row:SetScript("OnEnter", Open)
	row:SetScript("OnClick", Open)
	return row
end

-- Sets a window's row across the window, its top at y. Returns the y under it.
function Kit.PlaceWindowRow(row, y)
	row:ClearAllPoints()
	row:SetPoint("TOPLEFT", row.window, "TOPLEFT", ROW_INSET, y)
	row:SetPoint("TOPRIGHT", row.window, "TOPRIGHT", -ROW_INSET, y)
	return y - row:GetHeight()
end

--[[
    A window's Options line (Buff Duty's footer): a window row with the label
    blue and the arrow, its flyout opening beside the window (Kit.AddWindowRow),
    and the separator that sits above it. Returns the line and its separator;
    Kit.PlaceOptionsLine places both under the body.
]]
function Kit.AddOptionsLine(frame, label, flyout, afterChange)
	local separator = frame:CreateTexture(nil, "ARTWORK")
	separator:SetHeight(1)
	local red, green, blue = RGB("SEPARATOR")
	separator:SetColorTexture(red, green, blue, SEPARATOR_ALPHA)

	local line = Kit.AddWindowRow(frame, flyout, afterChange)
	line.left:SetText(Kit.Color("INFO", label))
	return line, separator
end

--[[
    The window's foot under y, the bottom of its body (a row's bottom edge, or
    a button's): a spacer, the separator in a SPACE.NEAR of its own across the
    text's width, then the Options line, as a menu's Options row sits
    (Kit.OptionsRow). Returns the y under the line, for Kit.WindowHeight.
]]
function Kit.PlaceOptionsLine(line, separator, y)
	local window = line.window
	y = y - SPACE.GROUP
	separator:ClearAllPoints()
	separator:SetPoint("TOPLEFT", window, "TOPLEFT", EDGE, y - SPACE.LINE)
	separator:SetPoint("TOPRIGHT", window, "TOPRIGHT", -EDGE, y - SPACE.LINE)
	return Kit.PlaceWindowRow(line, y - SPACE.NEAR)
end

--[[
    A window's height from y, the bottom of the last thing it shows: EDGE
    under the last text, as on every side. A row already holds SPACE.NEAR
    under its text, so a window ending on a row (the Options line) adds
    PANEL_INSET; one ending on bare text (Buff Duty's key hint) adds EDGE.
    Never rounded: rounding would put filler between its rows.
]]
function Kit.WindowHeight(y, endsOnText)
	return -y + (endsOnText and EDGE or PANEL_INSET)
end

-- A window's width around the widest thing its body holds: EDGE each side, a multiple of 16, at least 200.
function Kit.WindowWidth(inner)
	local width = math.max(inner + 2 * EDGE, WINDOW_MIN_WIDTH)
	return math.ceil(width / WINDOW_STEP) * WINDOW_STEP
end

--------------------------------------------------------------------------------
-- Building Blocks
--------------------------------------------------------------------------------

-- An option's caption and tooltip, drawn the way the options panel draws them.
function Kit.OptionTooltip(name, desc)
	return function(tooltip)
		tooltip:SetText(name, 1, 0.82, 0, 1, true)
		if desc and desc ~= "" then
			tooltip:AddLine(desc, 1, 1, 1, true)
		end
	end
end

-- The right side of a feature's title: On in green, Off in gray.
function Kit.OnOff(enabled)
	if enabled then
		return TEXT.on, "ON"
	end
	return TEXT.off, "MUTED"
end

function Kit.Section(text, right, rightColor)
	return { kind = "section", left = text, right = right, rightColor = rightColor }
end

function Kit.Separator()
	return { kind = "separator" }
end

function Kit.Spacer()
	return { kind = "spacer" }
end

-- A right-click menu's header: what was clicked, gold, and the add-on's Short Name gray.
function Kit.MenuHeader(title)
	return { kind = "header", left = title, right = TEXT.shortName ~= "" and TEXT.shortName or nil }
end

--[[
    Asks Yes or No before onYes runs, as the options panel's confirm does. The
    text is passed as an argument, never formatted, so a % in it is safe.
]]
local CONFIRM = ADDON_NAME .. "MenuKitConfirm"
function Kit.Confirm(text, onYes)
	if not StaticPopupDialogs then
		onYes()
		return
	end
	StaticPopupDialogs[CONFIRM] = StaticPopupDialogs[CONFIRM]
		or {
			text = "%s",
			button1 = YES,
			button2 = NO,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			OnAccept = function(_, data)
				data()
			end,
		}
	StaticPopup_Show(CONFIRM, text, nil, onYes)
end

-- A switch bound to one saved field of store, a table. onChange(value) runs after the write.
function Kit.Toggle(store, field, name, desc, onChange)
	return {
		kind = "toggle",
		left = name,
		on = store[field] and true or false,
		tooltip = Kit.OptionTooltip(name, desc),
		onClick = function()
			store[field] = not store[field]
			if onChange then
				onChange(store[field])
			end
		end,
	}
end

--[[
    A feature's block (MINIMAP MENU → Layout): the gold title with where it
    stands on the right, what the feature does, any note, any rows of its own (a
    pick list or a report), the blue Toggle row, and any rows after it (a
    follow-up action). The title opens flyouts[key] while it has something to
    show; otherwise it's a plain heading.

      Kit.FeatureBlock(entries, {
          key, title, state, stateColor, description, note, rows, after,
          toggle = { name, desc, flip, click, label, on, confirm },
      })

    toggle.name and desc are the feature's Enable option, its tooltip. label
    replaces Toggle (Open). click is the button's kept click that does the same
    (RightButton), named gray on the row's right.
    With on and confirm, turning it off asks confirm first.
]]
function Kit.FeatureBlock(entries, block)
	entries[#entries + 1] = {
		kind = "status",
		submenu = block.key,
		left = block.title,
		right = block.state,
		rightColor = block.stateColor,
	}
	if block.description then
		entries[#entries + 1] = { kind = "description", left = block.description }
	end
	if block.note then
		entries[#entries + 1] = { kind = "note", left = block.note }
	end
	for _, row in ipairs(block.rows or {}) do
		entries[#entries + 1] = row
	end
	local toggle = block.toggle
	if toggle then
		entries[#entries + 1] = {
			kind = "action",
			left = toggle.label or TEXT.toggle,
			click = toggle.click,
			tooltip = toggle.name and Kit.OptionTooltip(toggle.name, toggle.desc) or nil,
			onClick = function()
				if toggle.on and toggle.confirm then
					Kit.Confirm(toggle.confirm, function()
						toggle.flip()
						Kit.AfterConfirm()
					end)
				else
					toggle.flip()
				end
			end,
		}
	end
	for _, row in ipairs(block.after or {}) do
		entries[#entries + 1] = row
	end
end

-- After a confirmed change: the main menu's afterChange, so every panel and menu shows it.
function Kit.AfterConfirm()
	if Kit.mainMenu then
		Kit.mainMenu:AfterChange()
	else
		Kit.RefreshAll()
	end
end

-- Every row, or up to max when the add-on gives one, then a gray note saying how many more.
function Kit.List(entries, rows, max)
	max = max or #rows
	for index = 1, math.min(#rows, max) do
		entries[#entries + 1] = rows[index]
	end
	if #rows > max then
		entries[#entries + 1] = { kind = "note", left = format(TEXT.more, #rows - max) }
	end
end

-- The Options footer: a spacer, a separator, and the Options action row. It has no button click.
function Kit.OptionsRow(entries, label)
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = label,
		closes = true,
		onClick = function()
			if ns.OpenOptionsPanel then
				ns:OpenOptionsPanel()
			end
		end,
	}
end

--------------------------------------------------------------------------------
-- More Features
--------------------------------------------------------------------------------

--[[
    The set-and-forget features from ns.FEATURES (Options-Kit's record shape),
    in its order: every feature that isn't a block and that this character can
    use (gate). Style Guide → MINIMAP MENU → Features Mirror.
]]
local function Resolve(store, path)
	local node = ns.db and ns.db[store]
	local parts = {}
	for part in string.gmatch(path, "[^%.]+") do
		parts[#parts + 1] = part
	end
	for index = 1, #parts - 1 do
		node = node and node[parts[index]]
	end
	return node, parts[#parts]
end

local function IsOn(feature)
	local node, key = Resolve(feature.store, feature.setting)
	return node ~= nil and node[key] and true or false
end

local function Compact(features)
	local list = {}
	for _, feature in ipairs(features or ns.FEATURES or {}) do
		if not feature.block and (not feature.gate or feature.gate()) then
			list[#list + 1] = feature
		end
	end
	return list
end

local function Write(feature, value)
	if feature.apply then
		feature.apply(value)
	else
		local node, key = Resolve(feature.store, feature.setting)
		if node then
			node[key] = value
		end
	end
end

-- One compact switch per feature, gated and confirmed as its options switch is.
local function MoreFeaturesRows(features)
	local L = ns.L or {}
	local rows = {}
	for _, feature in ipairs(Compact(features)) do
		local on = IsOn(feature)
		rows[#rows + 1] = {
			kind = "toggle",
			left = L[feature.name],
			on = on,
			tooltip = Kit.OptionTooltip(L[feature.caption], L[feature.desc]),
			closes = feature.opensOptions ~= nil,
			onClick = function()
				if feature.opensOptions then
					if ns.OpenOptionsPanel then
						ns:OpenOptionsPanel(feature.opensOptions)
					end
				elseif on and feature.confirm then
					Kit.Confirm(L[feature.confirm], function()
						Write(feature, false)
						Kit.AfterConfirm()
					end)
				else
					Write(feature, not on)
				end
			end,
		}
	end
	return rows
end

--[[
    The More Features row, last before Options: its right side counts the
    flyout's switches, "4 On, 3 Off" (On count green, comma white, Off count
    gray), then the arrow; its flyout holds the switches. Nothing is added when
    no feature is left after the gates. features defaults to ns.FEATURES.
]]
Kit.MORE_FEATURES = "moreFeatures"

function Kit.MoreFeatures(entries, features)
	local list = Compact(features)
	if #list == 0 then
		return
	end
	local on = 0
	for _, feature in ipairs(list) do
		if IsOn(feature) then
			on = on + 1
		end
	end
	entries[#entries + 1] = {
		kind = "submenu",
		left = TEXT.moreFeatures,
		right = Kit.Color("ON", format(TEXT.featuresOn, on)) .. Kit.Color("TEXT", ",") .. " " .. Kit.Color(
			"MUTED",
			format(TEXT.featuresOff, #list - on)
		),
		submenu = Kit.MORE_FEATURES,
		flyout = function()
			return MoreFeaturesRows(features)
		end,
	}
end

--------------------------------------------------------------------------------
-- The Game's Menus in the Kit's Dress
--------------------------------------------------------------------------------

--[[
    For a right-click menu not yet moved onto the kit's panels (Style Guide →
    MENUS → One Look, Three Ways to Draw It). The game's menu opens as usual,
    then the kit lays its plate under it and under each sub-menu as it opens, so
    it lands after any skin add-on has had its turn. Whatever background the
    menu carries (the game's own, or a skin's backdrop) goes clear, and comes
    back when the game pools the frame again.
]]
local function Undress(frame)
	if frame.menuKitPlate then
		frame.menuKitPlate:Hide()
	end
	for region, alpha in pairs(frame.menuKitHidden or {}) do
		region:SetAlpha(alpha)
	end
	frame.menuKitHidden = nil
end

local function Dressed(frame)
	frame.menuKitHidden = frame.menuKitHidden or {}
	local function Clear(region)
		if region and region.GetAlpha and not frame.menuKitHidden[region] then
			frame.menuKitHidden[region] = region:GetAlpha()
			region:SetAlpha(0)
		end
	end
	for _, region in ipairs({ frame:GetRegions() }) do
		if region.GetDrawLayer and region:GetDrawLayer() == "BACKGROUND" then
			Clear(region)
		end
	end
	Clear(frame.NineSlice)
	Clear(frame.backdrop) -- A skin's square backdrop (ElvUI and its kin)
	Clear(frame.Background)
	Kit.AddPlate(frame)
end

local function DressDescription(description)
	if description.AddMenuAcquiredCallback then
		description:AddMenuAcquiredCallback(Dressed)
	end
	if description.AddMenuReleasedCallback then
		description:AddMenuReleasedCallback(Undress)
	end
end

--[[
    Opens the game's context menu on owner, built by generator(owner,
    rootDescription), in the kit's dress. Every sub-menu the generator makes
    through Kit.Submenu is dressed too. Returns the game's menu, or nil where
    the client has no MenuUtil.
]]
function Kit.OpenContextMenu(owner, generator)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return nil
	end
	return MenuUtil.CreateContextMenu(owner, function(ownerRegion, rootDescription)
		DressDescription(rootDescription)
		generator(ownerRegion, rootDescription)
	end)
end

-- A sub-menu on the game's menu, dressed like its parent.
function Kit.Submenu(description, text)
	local child = description:CreateButton(text)
	DressDescription(child)
	return child
end

--[[
    The header on the game's menu: what was clicked in gold, the add-on's Short
    Name gray on the right, then a spacer (MENUS → The Header).
]]
function Kit.AddMenuHeader(rootDescription, title)
	local header = rootDescription:CreateTitle(Kit.Color("TITLE", title))
	if TEXT.shortName ~= "" and header.AddInitializer then
		header:AddInitializer(function(button)
			if not button.menuKitRight then
				button.menuKitRight = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				button.menuKitRight:SetPoint("RIGHT", -TEXT_INSET, 0)
			end
			Paint(button.menuKitRight, TEXT.shortName, "MUTED")
		end)
		if header.AddResetter then
			header:AddResetter(function(button)
				if button.menuKitRight then
					button.menuKitRight:Hide()
				end
			end)
		end
	end
	if rootDescription.CreateSpacer then
		rootDescription:CreateSpacer()
	end
	return header
end

--[[
    An AceGUI dropdown's list on the plate, in place of its border, given back
    when the dropdown is released: AceGUI pools that frame for every add-on.
    Call it once the dropdown is made; it's safe to call again.
]]
function Kit.PlatePullout(dropdown)
	local pullout = dropdown and dropdown.pullout
	local frame = pullout and pullout.frame
	if not frame or dropdown.menuKitRelease then
		return
	end
	local backdrop = frame.GetBackdrop and frame:GetBackdrop()
	local color = frame.GetBackdropColor and { frame:GetBackdropColor() }
	local border = frame.GetBackdropBorderColor and { frame:GetBackdropBorderColor() }
	if frame.SetBackdrop then
		frame:SetBackdrop(nil)
	end
	Kit.AddPlate(frame)

	local release = dropdown.OnRelease
	dropdown.menuKitRelease = release
	dropdown.OnRelease = function(self, ...)
		if frame.menuKitPlate then
			frame.menuKitPlate:Hide()
		end
		if frame.SetBackdrop and backdrop then
			frame:SetBackdrop(backdrop)
			if color and color[1] then
				frame:SetBackdropColor(unpack(color))
			end
			if border and border[1] then
				frame:SetBackdropBorderColor(unpack(border))
			end
		end
		self.OnRelease = release
		self.menuKitRelease = nil
		if release then
			return release(self, ...)
		end
	end
end
