--------------------------------------------------------------------------------
-- GogoLoot Options — Item List Widgets
--------------------------------------------------------------------------------

--[[
    The two custom AceGUI widgets the shared item list builder
    (Options-Utilities-Item-Lists.lua) draws with: GogoLoot_ItemListFilter, the
    filter box, and GogoLoot_ItemListAdd, the add box and its button. A row's
    item is the Options-Kit's Kit.ITEM_LINK_WIDGET.
]]
local _, ns = ...
local L = ns.L

local MeasureCaptionPixels = ns.MeasureCaptionPixels
local SetListFilter = ns.SetItemListFilter
local REMOVE_ICON = ns.ITEM_LIST_REMOVE_ICON

local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Custom AceGUI Widget: GogoLoot_ItemListFilter
--------------------------------------------------------------------------------

--[[
    The filter box above every item list: a magnifying glass, then a box that
    reads "Filter items..." while empty and shows a clear button while not. Used
    via dialogControl on the AceConfig "input" entry BuildItemListOptions adds.
    AceConfigDialog hands that entry's `arg` to SetCustomData, which is how the
    box knows whose filter it is, and so whether a redraw owes it the keyboard
    back (see Options-Utilities-Item-List-Filter.lua).

    Typing filters as the player goes, rather than on Enter as a stock AceGUI
    EditBox would: the box writes the list's filter itself and asks for a
    redraw once typing pauses. Enter still applies at once, through the entry's
    set.
]]
local filterWidgetType = ns.ITEM_LIST_FILTER_WIDGET_TYPE
local filterWidgetVersion = 1

-- A redraw rebuilds within a frame or two; a box built later than this is a fresh visit, not a redraw.
local FILTER_FOCUS_HANDOVER_SECONDS = 1

-- The list whose filter box last had the keyboard, where its cursor sat, and until when a redraw may take it back.
local focusedFilterList, focusedFilterCursor
local focusHandoverUntil = 0

local FILTER_WIDGET_HEIGHT = 32
-- Kept off the spacing scale: fitted to InputBoxTemplate's art, which clips its text any shorter and stretches its caps any taller.
local FILTER_BOX_HEIGHT = 19
-- The box's top and bottom text insets, fitted to that same art.
local FILTER_BOX_TEXT_INSET = 3
local SEARCH_ICON = "Interface\\Common\\UI-Searchbox-Icon"
local SEARCH_ICON_SIZE = 16
local SEARCH_ICON_LEFT = 0
-- InputBoxTemplate draws its left cap past the box's edge, so the box starts this far right of the icon.
local SEARCH_ICON_GAP = 16
--[[
    Where the box starts, clear of the icon, and how far in from the widget's
    right edge it ends (its right cap sits on its edge). The add pair on the
    line above spans the same stretch (GogoLoot_ItemListAdd), so the two boxes
    stack in one column.
]]
local FILTER_BOX_LEFT = SEARCH_ICON_LEFT + SEARCH_ICON_SIZE + SEARCH_ICON_GAP
local FILTER_BOX_RIGHT_INSET = 2
-- The rows' red remove icon, as Connoisseur's Restocker clears its filter: the same "get rid of this" mark everywhere on the panel.
local CLEAR_ICON = REMOVE_ICON
local CLEAR_ICON_SIZE = 16
-- The clear icon's inset from the box's right edge, and the room the text keeps clear of it.
local CLEAR_ICON_INSET = 4
local CLEAR_ICON_TEXT_GAP = 8

local function UpdateFilterDecorations(widget)
	if widget.editbox:GetText() == "" then
		widget.placeholder:Show()
		widget.clearButton:Hide()
	else
		widget.placeholder:Hide()
		widget.clearButton:Show()
	end
end

-- The box's frame is hidden until its container shows it, so taking the keyboard waits for that.
local function FilterFrame_OnShowFocus(frame)
	local widget = frame.obj
	frame:SetScript("OnShow", nil)
	widget.editbox:SetFocus()
	widget.editbox:SetCursorPosition(math.min(focusedFilterCursor or 0, #widget.editbox:GetText()))
end

local function FilterBox_OnTextChanged(editbox, userInput)
	local widget = editbox.obj
	UpdateFilterDecorations(widget)
	if userInput and widget.registryName then
		SetListFilter(widget.registryName, editbox:GetText())
	end
end

local function FilterBox_OnFocusGained(editbox)
	local widget = editbox.obj
	AceGUI:SetFocus(widget)
	focusedFilterList = widget.registryName
end

--[[
    A box losing the keyboard while its frame still shows is the player leaving
    it. One losing it hidden is a redraw releasing it (or the options closing),
    which opens a short window for the rebuilt box to take it back.
]]
local function FilterBox_OnFocusLost(editbox)
	local widget = editbox.obj
	if widget.frame:IsShown() then
		focusedFilterList = nil
		return
	end
	focusedFilterCursor = editbox:GetCursorPosition()
	focusHandoverUntil = GetTime() + FILTER_FOCUS_HANDOVER_SECONDS
end

local function FilterBox_OnEscapePressed()
	AceGUI:ClearFocus()
end

local function FilterBox_OnEnterPressed(editbox)
	local widget = editbox.obj
	AceGUI:ClearFocus()
	widget:Fire("OnEnterPressed", editbox:GetText())
end

local function FilterBox_OnEnter(editbox)
	editbox.obj:Fire("OnEnter")
end

local function FilterBox_OnLeave(editbox)
	editbox.obj:Fire("OnLeave")
end

local function ClearButton_OnClick(button)
	local widget = button.obj
	widget.editbox:SetText("")
	UpdateFilterDecorations(widget)
	if widget.registryName then
		SetListFilter(widget.registryName, "", true)
	end
end

local filterMethods = {}

function filterMethods:OnAcquire()
	self.registryName = nil
	self:SetHeight(FILTER_WIDGET_HEIGHT)
	self:SetDisabled(false)
	self.editbox:SetText("")
	UpdateFilterDecorations(self)
end

function filterMethods:OnRelease()
	self.frame:SetScript("OnShow", nil)
	self.editbox:ClearFocus()
	self.registryName = nil
end

function filterMethods:SetText(text)
	self.editbox:SetText(text or "")
	UpdateFilterDecorations(self)
end

function filterMethods:GetText()
	return self.editbox:GetText()
end

function filterMethods:SetDisabled(disabled)
	self.editbox:EnableMouse(not disabled)
	if disabled then
		self.editbox:ClearFocus()
		self.editbox:SetTextColor(0.5, 0.5, 0.5)
	else
		self.editbox:SetTextColor(1, 1, 1)
	end
end

function filterMethods:ClearFocus()
	self.editbox:ClearFocus()
end

--[[
    Called by AceConfigDialog after SetText, with the entry's arg. A redraw of
    the list whose box just had the keyboard hands it straight back.
]]
function filterMethods:SetCustomData(arg)
	self.registryName = arg and arg.registryName
	if self.registryName and self.registryName == focusedFilterList and GetTime() <= focusHandoverUntil then
		focusHandoverUntil = 0
		self.frame:SetScript("OnShow", FilterFrame_OnShowFocus)
	end
end

function filterMethods:SetLabel() end
function filterMethods:SetMaxLetters() end

local function FilterWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	frame:SetHeight(FILTER_WIDGET_HEIGHT)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexture(SEARCH_ICON)
	icon:SetSize(SEARCH_ICON_SIZE, SEARCH_ICON_SIZE)
	icon:SetPoint("LEFT", frame, "LEFT", SEARCH_ICON_LEFT, 0)

	local editbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetTextInsets(0, CLEAR_ICON_SIZE + CLEAR_ICON_TEXT_GAP, FILTER_BOX_TEXT_INSET, FILTER_BOX_TEXT_INSET)
	editbox:SetMaxLetters(64)
	editbox:SetHeight(FILTER_BOX_HEIGHT)
	editbox:SetPoint("LEFT", icon, "RIGHT", SEARCH_ICON_GAP, 0)
	editbox:SetPoint("RIGHT", frame, "RIGHT", -FILTER_BOX_RIGHT_INSET, 0)
	editbox:SetScript("OnTextChanged", FilterBox_OnTextChanged)
	editbox:SetScript("OnEditFocusGained", FilterBox_OnFocusGained)
	editbox:SetScript("OnEditFocusLost", FilterBox_OnFocusLost)
	editbox:SetScript("OnEscapePressed", FilterBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", FilterBox_OnEnterPressed)
	editbox:SetScript("OnEnter", FilterBox_OnEnter)
	editbox:SetScript("OnLeave", FilterBox_OnLeave)

	-- The same small gray hint as the add box above it (GogoLoot_ItemListAdd), so the two boxes match.
	local placeholder = editbox:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	placeholder:SetPoint("LEFT", editbox, "LEFT", 0, 0)
	placeholder:SetPoint("RIGHT", editbox, "RIGHT", 0, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["ITEM_LIST_FILTER_PLACEHOLDER"])

	local clearButton = CreateFrame("Button", nil, editbox)
	clearButton:SetSize(CLEAR_ICON_SIZE, CLEAR_ICON_SIZE)
	clearButton:SetPoint("RIGHT", editbox, "RIGHT", -CLEAR_ICON_INSET, 0)
	clearButton.texture = clearButton:CreateTexture(nil, "ARTWORK")
	clearButton.texture:SetTexture(CLEAR_ICON)
	clearButton.texture:SetAllPoints()
	clearButton:SetScript("OnClick", ClearButton_OnClick)
	clearButton:Hide()

	local widget = {
		frame = frame,
		editbox = editbox,
		placeholder = placeholder,
		clearButton = clearButton,
		type = filterWidgetType,
	}
	for method, func in pairs(filterMethods) do
		widget[method] = func
	end
	editbox.obj = widget
	clearButton.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(filterWidgetType, FilterWidgetConstructor, filterWidgetVersion)

--------------------------------------------------------------------------------
-- Custom AceGUI Widget: GogoLoot_ItemListAdd
--------------------------------------------------------------------------------

--[[
    The line above an item list's filter, Connoisseur's Restocker add pair: a
    box that reads "Drop item here, or type item ID" while it is empty, with an
    Add button bolted to its right, so adding never depends on knowing to
    press Enter. Used via dialogControl on the AceConfig "input" entry
    BuildItemListOptions adds. Every way in fires OnEnterPressed with what to
    add, which AceConfigDialog hands to that entry's set:

      * Add, or Enter in the box: what was typed, an item ID or a pasted link.
      * An item dropped on the box, or clicked into it off the cursor: its
        link, added as it lands, as the stock AceGUI EditBox does.

    The box empties as it hands its text over. The button and the box show the
    entry's one tooltip, being two halves of one control.
]]
local addWidgetType = ns.ITEM_LIST_ADD_WIDGET_TYPE
local addWidgetVersion = 1

-- The widget and its box take the filter's heights, so the two lines match.
-- Kept off the spacing scale: UIPanelButtonTemplate's stock height, which its art is drawn for.
local ADD_BUTTON_HEIGHT = 22
-- Tucks the box's right cap under the button, so the pair reads as one control.
local ADD_BOX_BUTTON_OVERLAP = 4
-- Fitted to its caption and never narrower than this, so a longer word in another locale widens the button.
local ADD_BUTTON_MIN_WIDTH = 64
local ADD_BUTTON_CAPTION_PADDING = 32

local function UpdateAddPlaceholder(widget)
	if widget.editbox:GetText() == "" then
		widget.placeholder:Show()
	else
		widget.placeholder:Hide()
	end
end

---@param widget table
---@param text string|nil
local function SubmitAddition(widget, text)
	if not text or text == "" then
		return
	end
	widget.editbox:SetText("")
	UpdateAddPlaceholder(widget)
	AceGUI:ClearFocus()
	widget:Fire("OnEnterPressed", text)
end

local function AddBox_OnEnterPressed(editbox)
	SubmitAddition(editbox.obj, editbox:GetText())
end

local function AddButton_OnClick(button)
	local widget = button.obj
	SubmitAddition(widget, widget.editbox:GetText())
end

local function AddBox_OnReceiveDrag(editbox)
	local infoType, _, itemLink = GetCursorInfo()
	if infoType == "item" and itemLink then
		ClearCursor()
		SubmitAddition(editbox.obj, itemLink)
	end
end

local function AddBox_OnMouseUp(editbox, mouseButton)
	if mouseButton == "LeftButton" then
		AddBox_OnReceiveDrag(editbox)
	end
end

local function AddBox_OnTextChanged(editbox)
	UpdateAddPlaceholder(editbox.obj)
end

local function AddBox_OnFocusGained(editbox)
	AceGUI:SetFocus(editbox.obj)
end

local function AddBox_OnEscapePressed()
	AceGUI:ClearFocus()
end

local function AddControl_OnEnter(control)
	control.obj:Fire("OnEnter")
end

local function AddControl_OnLeave(control)
	control.obj:Fire("OnLeave")
end

local addMethods = {}

function addMethods:OnAcquire()
	self:SetHeight(FILTER_WIDGET_HEIGHT)
	self:SetDisabled(false)
	self:SetText("")
end

function addMethods:OnRelease()
	self.editbox:ClearFocus()
end

function addMethods:SetText(text)
	self.editbox:SetText(text or "")
	UpdateAddPlaceholder(self)
end

function addMethods:GetText()
	return self.editbox:GetText()
end

function addMethods:SetDisabled(disabled)
	self.editbox:EnableMouse(not disabled)
	if disabled then
		self.editbox:ClearFocus()
		self.button:Disable()
	else
		self.button:Enable()
	end
end

function addMethods:ClearFocus()
	self.editbox:ClearFocus()
end

-- The entry's name titles its tooltip; the box itself draws no label.
function addMethods:SetLabel() end
function addMethods:SetMaxLetters() end

local function AddWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	frame:SetHeight(FILTER_WIDGET_HEIGHT)

	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetText(L["ITEM_LIST_ADD_BUTTON"])
	button:SetSize(
		math.max(ADD_BUTTON_MIN_WIDTH, MeasureCaptionPixels(L["ITEM_LIST_ADD_BUTTON"]) + ADD_BUTTON_CAPTION_PADDING),
		ADD_BUTTON_HEIGHT
	)
	-- Ends where the filter's box below it does.
	button:SetPoint("RIGHT", frame, "RIGHT", -FILTER_BOX_RIGHT_INSET, 0)
	button:SetScript("OnClick", AddButton_OnClick)
	button:SetScript("OnEnter", AddControl_OnEnter)
	button:SetScript("OnLeave", AddControl_OnLeave)

	local editbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetTextInsets(0, 0, FILTER_BOX_TEXT_INSET, FILTER_BOX_TEXT_INSET)
	editbox:SetHeight(FILTER_BOX_HEIGHT)
	-- Over the filter's box, clear of its magnifying glass, so the two boxes stack in one column.
	editbox:SetPoint("LEFT", frame, "LEFT", FILTER_BOX_LEFT, 0)
	editbox:SetPoint("RIGHT", button, "LEFT", ADD_BOX_BUTTON_OVERLAP, 0)
	editbox:SetScript("OnTextChanged", AddBox_OnTextChanged)
	editbox:SetScript("OnEditFocusGained", AddBox_OnFocusGained)
	editbox:SetScript("OnEscapePressed", AddBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", AddBox_OnEnterPressed)
	editbox:SetScript("OnReceiveDrag", AddBox_OnReceiveDrag)
	editbox:SetScript("OnMouseUp", AddBox_OnMouseUp)
	editbox:SetScript("OnEnter", AddControl_OnEnter)
	editbox:SetScript("OnLeave", AddControl_OnLeave)

	--[[
	    The hint, shown only while the box is empty. A font string rather than
	    the box's own text, so nothing clips it for us: anchored on both sides
	    and kept to one line, a hint that outgrows the box ends inside it instead
	    of running on under the Add button.
	]]
	local placeholder = editbox:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	placeholder:SetPoint("LEFT", editbox, "LEFT", 0, 0)
	placeholder:SetPoint("RIGHT", editbox, "RIGHT", 0, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["ITEM_LIST_ADD_PLACEHOLDER"])

	local widget = {
		frame = frame,
		editbox = editbox,
		button = button,
		placeholder = placeholder,
		type = addWidgetType,
	}
	for method, func in pairs(addMethods) do
		widget[method] = func
	end
	editbox.obj = widget
	button.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(addWidgetType, AddWidgetConstructor, addWidgetVersion)
