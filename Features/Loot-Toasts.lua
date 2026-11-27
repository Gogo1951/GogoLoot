--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts
--------------------------------------------------------------------------------

--[[
    The stack reads like a chat log: a new row appears at the anchor and the
    rest shift one row away, so the newest is always in the same place and the
    oldest fades out of the far end.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LSM = LibStub("LibSharedMedia-3.0")

--[[
    THE GRID: every size is set at GRID_FONT_SIZE and scales with the font
    (GridSize), so the layout keeps its proportions. ICON_CROP drops the bevel
    Blizzard paints into each icon, which would otherwise double the frame.
]]
local GRID_FONT_SIZE = 16
local ROW_UNITS = 32
local BORDER_UNITS = 2
local TEXT_GAP_UNITS = 8
local ROW_SPACING_UNITS = 8
local ICON_CROP = 0.07

--[[
    The frame's corners are 4 of its 32 and the art's 2 of its 28, so the two
    curves stay concentric. Masks must be a power of two: both are 64 pixels.
]]
local ICON_BORDER_MASK = "Interface\\AddOns\\GogoLoot\\Includes\\Images\\Toast-Icon-Border-Mask.tga"
local ICON_ART_MASK = "Interface\\AddOns\\GogoLoot\\Includes\\Images\\Toast-Icon-Art-Mask.tga"

-- The shade starts under the middle of the icon, so its square end hides behind the rounded frame.
local BACKDROP_ALPHA = 0.7
local BACKDROP_DARK = CreateColor(0, 0, 0, BACKDROP_ALPHA)
local BACKDROP_CLEAR = CreateColor(0, 0, 0, 0)
local BACKDROP_TAIL_UNITS = 64

local SLIDE_DURATION = 0.2
local SLIDE_UNITS = 16

local FLASH_MIN_QUALITY = 4
local FLASH_ALPHA = 0.6
local FLASH_DURATION = 1

--[[
    About 64 characters at any size (a glyph averages half the em box), enough
    for a random-suffix weapon and a quantity. A ceiling: Measure sizes the text
    to the string and truncates only past it.
]]
local TEXT_WIDTH_RATIO = 32

local SAMPLE_COUNT_UNLIMITED = 8

local pool = {}
local active = {}
local samples = {}

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------

-- "DEFAULT" is GameFontNormal's face, the only right answer on a locale whose client ships its own font.
local function FontPath(value, defaultPath)
	if not value or value == "DEFAULT" then
		return defaultPath
	end
	return LSM:IsValid("font", value) and LSM:Fetch("font", value) or defaultPath
end

-- Rebuilt on every call, so a face registered by a later add-on still turns up.
---@return table values
---@return table sorting
function ns.GetLootToastFontChoices()
	local values = { DEFAULT = L["LOOT_TOASTS_FONT_DEFAULT"] }
	local sorting = { "DEFAULT" }
	for _, fontName in ipairs(LSM:List("font")) do
		values[fontName] = fontName
		sorting[#sorting + 1] = fontName
	end
	return values, sorting
end

-- THE FLAG STRING CARRIES THE WEIGHT: the client offers no bold, so a thicker outline reads heavier.
local function ResolveFlags()
	local flags = ns.db and ns.db.profile.lootToastFontFlags
	if not flags or flags == "NONE" then
		return ""
	end
	return flags
end

local function FontSize()
	return (ns.db and ns.db.profile.lootToastFontSize) or ns.LOOT_TOAST_FONT_SIZE_MIN
end

-- Deliberately not cached across restacks, so a later face or a font change reaches rows on screen.
local function ResolveFont()
	local fallbackPath = GameFontNormal:GetFont()
	return FontPath(ns.db and ns.db.profile.lootToastFont, fallbackPath), FontSize(), ResolveFlags(), fallbackPath
end

-- The flags ride both calls, so a face that fails to load keeps its weight on the fallback.
local function ApplyFont(fontString, path, size, flags, fallbackPath)
	if fontString:SetFont(path, size, flags) == false then
		fontString:SetFont(fallbackPath, size, flags)
	end
end

local function GridSize(units, minimum)
	return math.max(minimum, math.floor(units * FontSize() / GRID_FONT_SIZE + 0.5))
end

local function FramedIconSize()
	return GridSize(ROW_UNITS, 8)
end

local function BorderSize()
	return GridSize(BORDER_UNITS, 1)
end

local function IconSize()
	return FramedIconSize() - 2 * BorderSize()
end

local function IconGap()
	return GridSize(TEXT_GAP_UNITS, 2)
end

local function RowSpacing()
	return GridSize(ROW_SPACING_UNITS, 2)
end

-- Unlimited is stored as 0, and `#active >= 0` would retire every row as it was drawn.
local function MaxVisible()
	local limit = ns.db and ns.db.profile.lootToastMaxVisible
	if not limit or limit <= ns.LOOT_TOAST_UNLIMITED then
		return math.huge
	end
	return limit
end

local function RowWidth()
	return FramedIconSize() + IconGap() + math.floor(FontSize() * TEXT_WIDTH_RATIO)
end

local function AlignsRight()
	return ns.db ~= nil and ns.db.profile.lootToastAlign == "RIGHT"
end

ns.LootToastsAlignRight = AlignsRight

local function RowHeight()
	return FramedIconSize()
end

--[[
    THE TRAP: a text box spanning the row makes the name's position depend on
    its justification, and a stale one strands the name far from its icon. So
    the box is sized to the string (SetWidth(0)) and pinned to the icon.
]]
local function Measure(toast, path, size, flags, fallbackPath)
	local iconSize = IconSize()
	local border = BorderSize()
	local gap = IconGap()
	local tail = GridSize(BACKDROP_TAIL_UNITS, 8)
	local iconMiddle = math.floor(FramedIconSize() / 2)
	toast:SetSize(RowWidth(), RowHeight())
	toast.icon:SetSize(iconSize, iconSize)
	toast.icon:ClearAllPoints()
	toast.text:ClearAllPoints()
	toast.backdrop:ClearAllPoints()

	toast.border:ClearAllPoints()
	toast.border:SetPoint("TOPLEFT", toast.icon, "TOPLEFT", -border, border)
	toast.border:SetPoint("BOTTOMRIGHT", toast.icon, "BOTTOMRIGHT", border, -border)

	-- Font first: SetFont resets a font string's justification.
	ApplyFont(toast.text, path, size, flags, fallbackPath)

	-- SetGradient's first color is always the left end, so the colors swap with the alignment.
	local dark, clear = BACKDROP_DARK, BACKDROP_CLEAR
	toast.text:SetWidth(0)
	if AlignsRight() then
		toast.icon:SetPoint("RIGHT", -border, 0)
		toast.text:SetPoint("RIGHT", toast.border, "LEFT", -gap, 0)
		toast.text:SetJustifyH("RIGHT")
		toast.backdrop:SetPoint("TOPRIGHT", -iconMiddle, 0)
		toast.backdrop:SetPoint("BOTTOMRIGHT", -iconMiddle, 0)
		toast.backdrop:SetPoint("LEFT", toast.text, "LEFT", -tail, 0)
		toast.backdrop:SetGradient("HORIZONTAL", clear, dark)
		if toast.flashColor then
			toast.flash:SetGradient("HORIZONTAL", toast.flashClear, toast.flashColor)
		end
	else
		toast.icon:SetPoint("LEFT", border, 0)
		toast.text:SetPoint("LEFT", toast.border, "RIGHT", gap, 0)
		toast.text:SetJustifyH("LEFT")
		toast.backdrop:SetPoint("TOPLEFT", iconMiddle, 0)
		toast.backdrop:SetPoint("BOTTOMLEFT", iconMiddle, 0)
		toast.backdrop:SetPoint("RIGHT", toast.text, "RIGHT", tail, 0)
		toast.backdrop:SetGradient("HORIZONTAL", dark, clear)
		if toast.flashColor then
			toast.flash:SetGradient("HORIZONTAL", toast.flashColor, toast.flashClear)
		end
	end

	local maxTextWidth = RowWidth() - FramedIconSize() - gap
	if toast.text:GetStringWidth() > maxTextWidth then
		toast.text:SetWidth(maxTextWidth)
	end

	toast.hover:ClearAllPoints()
	if AlignsRight() then
		toast.hover:SetPoint("TOPRIGHT", toast.border, "TOPRIGHT")
		toast.hover:SetPoint("BOTTOMRIGHT", toast.border, "BOTTOMRIGHT")
		toast.hover:SetPoint("LEFT", toast.text, "LEFT")
	else
		toast.hover:SetPoint("TOPLEFT", toast.border, "TOPLEFT")
		toast.hover:SetPoint("BOTTOMLEFT", toast.border, "BOTTOMLEFT")
		toast.hover:SetPoint("RIGHT", toast.text, "RIGHT")
	end
end

-- Coin has no quality, so its frame stays black.
local function SetToastQuality(toast, quality)
	if quality then
		toast.border:SetVertexColor(ns.GetQualityColorRGB(quality))
	else
		toast.border:SetVertexColor(0, 0, 0)
	end
end

--------------------------------------------------------------------------------
-- Toast Frames
--------------------------------------------------------------------------------

local function PlayFade(toast)
	toast.fadeOut:SetStartDelay(ns.db.profile.lootToastDuration)
	toast.fade:Play()
end

--[[
    So a run of pickups leaves together. THE TRAP: stopping a fade can fire its
    OnFinished, which would release the row; `restarting` says this stop is not
    the end.
]]
local function RestartFades()
	for _, toast in ipairs(active) do
		if not toast.isSample and not toast.hovered then
			toast.restarting = true
			toast.fade:Stop()
			toast.restarting = nil
			toast:SetAlpha(1)
			PlayFade(toast)
		end
	end
end

local function PlayEnter(toast)
	local distance = GridSize(SLIDE_UNITS, 4)
	local offset = AlignsRight() and distance or -distance
	toast.enterOffset:SetOffset(offset, 0)
	toast.enterSlide:SetOffset(-offset, 0)
	toast.enter:Play()
end

local function PlayFlash(toast, quality)
	if not quality or quality < FLASH_MIN_QUALITY then
		toast.flashColor = nil
		toast.flash:Hide()
		return
	end
	local r, g, b = ns.GetQualityColorRGB(quality)
	toast.flashColor, toast.flashClear = CreateColor(r, g, b, FLASH_ALPHA), CreateColor(r, g, b, 0)
	toast.flash:Show()
	toast.flashAnimation:Play()
end

local function TakesPointer(toast)
	return toast.itemLink ~= nil and ns.db ~= nil and ns.db.profile.lootToastTooltips == true
end

--[[
    THE TRAP: anchored to the hover child, not the row, which is RowWidth()
    wide whatever the text, so a short name would strand the tooltip.
]]
local function OnToastEnter(hover)
	local toast = hover:GetParent()
	if not TakesPointer(toast) then
		return
	end
	toast.hovered = true
	toast.fade:Pause()
	GameTooltip:SetOwner(hover, "ANCHOR_NONE")
	GameTooltip:ClearAllPoints()
	if AlignsRight() then
		GameTooltip:SetPoint("RIGHT", hover, "LEFT")
	else
		GameTooltip:SetPoint("LEFT", hover, "RIGHT")
	end
	GameTooltip:SetHyperlink(toast.itemLink)
	GameTooltip:Show()
end

local function OnToastLeave(hover)
	local toast = hover:GetParent()
	toast.hovered = nil
	if GameTooltip:IsOwned(hover) then
		GameTooltip:Hide()
	end
	-- Hiding a row under the pointer leaves it too, and a pooled row has no fade to resume.
	if toast.itemLink and not toast.pooled then
		toast.fade:Play()
	end
end

local function AcquireToast()
	local toast = table.remove(pool)
	if toast then
		toast.pooled = nil
		return toast
	end
	toast = CreateFrame("Frame", nil, UIParent)
	-- White bases, so the gradient and the quality tint are the only color either carries.
	toast.backdrop = toast:CreateTexture(nil, "BACKGROUND")
	toast.backdrop:SetColorTexture(1, 1, 1, 1)
	toast.flash = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
	toast.flash:SetColorTexture(1, 1, 1, 1)
	toast.flash:SetBlendMode("ADD")
	toast.flash:SetAllPoints(toast.backdrop)
	toast.flash:Hide()
	toast.border = toast:CreateTexture(nil, "BORDER")
	toast.border:SetColorTexture(1, 1, 1, 1)
	toast.icon = toast:CreateTexture(nil, "ARTWORK")
	toast.icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)
	toast.borderMask = toast:CreateMaskTexture()
	toast.borderMask:SetTexture(ICON_BORDER_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	toast.borderMask:SetAllPoints(toast.border)
	toast.border:AddMaskTexture(toast.borderMask)
	toast.iconMask = toast:CreateMaskTexture()
	toast.iconMask:SetTexture(ICON_ART_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	toast.iconMask:SetAllPoints(toast.icon)
	toast.icon:AddMaskTexture(toast.iconMask)
	toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	toast.text:SetWordWrap(false)

	--[[
        THE TRAP: the row is far wider than its text, so a mouse-enabled row
        would lay an invisible strip over the world. Only this child takes the
        pointer, motion only, never clicks.
    ]]
	toast.hover = CreateFrame("Frame", nil, toast)
	toast.hover:SetMouseClickEnabled(false)
	toast.hover:SetMouseMotionEnabled(false)
	toast.hover:SetScript("OnEnter", OnToastEnter)
	toast.hover:SetScript("OnLeave", OnToastLeave)

	toast.fade = toast:CreateAnimationGroup()
	toast.fadeOut = toast.fade:CreateAnimation("Alpha")
	toast.fadeOut:SetFromAlpha(1)
	toast.fadeOut:SetToAlpha(0)
	toast.fadeOut:SetDuration(ns.LOOT_TOAST_FADE_DURATION)
	toast.fade:SetScript("OnFinished", function(group)
		local finished = group:GetParent()
		if not finished.restarting then
			ns.ReleaseLootToast(finished)
		end
	end)

	-- Translations don't persist, so the row ends exactly where Restack put it.
	toast.enter = toast:CreateAnimationGroup()
	toast.enterOffset = toast.enter:CreateAnimation("Translation")
	toast.enterOffset:SetDuration(0)
	toast.enterOffset:SetOrder(1)
	toast.enterSlide = toast.enter:CreateAnimation("Translation")
	toast.enterSlide:SetDuration(SLIDE_DURATION)
	toast.enterSlide:SetOrder(2)
	toast.enterSlide:SetSmoothing("OUT")
	local enterAlpha = toast.enter:CreateAnimation("Alpha")
	enterAlpha:SetFromAlpha(0)
	enterAlpha:SetToAlpha(1)
	enterAlpha:SetDuration(SLIDE_DURATION)
	enterAlpha:SetOrder(2)

	toast.flashAnimation = toast:CreateAnimationGroup()
	local flashFade = toast.flashAnimation:CreateAnimation("Alpha")
	flashFade:SetTarget(toast.flash)
	flashFade:SetFromAlpha(1)
	flashFade:SetToAlpha(0)
	flashFade:SetDuration(FLASH_DURATION)
	toast.flashAnimation:SetScript("OnFinished", function()
		toast.flash:Hide()
	end)
	return toast
end

--[[
    Offsets run from the END of `active` (oldest first), so retiring the oldest
    moves nothing near the anchor. Rows pin to a corner, never the center: a
    centered row's width would move its icon, and a font change would walk the
    stack.
]]
local function Restack()
	local count = #active
	local step = RowHeight() + RowSpacing()
	local growDown = ns.db and ns.db.profile.lootToastGrowth == "DOWN"
	local corner = (growDown and "TOP" or "BOTTOM") .. (AlignsRight() and "RIGHT" or "LEFT")
	local path, size, flags, fallbackPath = ResolveFont()
	for index, toast in ipairs(active) do
		Measure(toast, path, size, flags, fallbackPath)
		toast:ClearAllPoints()
		local offset = (count - index) * step
		toast:SetPoint(corner, ns.GetLootToastAnchor(), corner, 0, growDown and -offset or offset)
	end
end

--[[
    THE TRAP: callers loop until a list shrinks, so the two removals ALWAYS
    run. Only the pooling is guarded: stopping the fade can fire OnFinished,
    which releases the same frame again, and pooling it twice hands one frame
    out as two rows.
]]
---@param toast table
---@param skipRestack boolean|nil
---@return nil
function ns.ReleaseLootToast(toast, skipRestack)
	for index, candidate in ipairs(samples) do
		if candidate == toast then
			table.remove(samples, index)
			break
		end
	end
	for index, candidate in ipairs(active) do
		if candidate == toast then
			table.remove(active, index)
			break
		end
	end
	if not toast.pooled then
		toast.pooled = true
		toast.countItem = nil
		toast.itemLink = nil
		toast.isSample = nil
		toast.hovered = nil
		toast.flashColor = nil
		toast.enter:Stop()
		toast.flashAnimation:Stop()
		toast.flash:Hide()
		toast.hover:SetMouseMotionEnabled(false)
		if GameTooltip:IsOwned(toast.hover) then
			GameTooltip:Hide()
		end
		toast.fade:Stop()
		toast:Hide()
		toast:SetAlpha(1)
		pool[#pool + 1] = toast
	end
	if not skipRestack then
		Restack()
	end
end

--------------------------------------------------------------------------------
-- Entry Points
--------------------------------------------------------------------------------

--[[
    Bag Count reads live: the loot line may land before or after the bags take
    the item, so it is re-read whenever the bags settle.
]]
local function WriteToastText(toast)
	local carried = toast.countItem and ns.db.profile.lootToastBagCount and C_Item.GetItemCount(toast.countItem)
	if carried and carried > toast.countQuantity then
		toast.text:SetText(toast.baseText .. " " .. L["LOOT_TOASTS_BAG_COUNT"]:format(carried))
	else
		toast.text:SetText(toast.baseText)
	end
end

-- The cap retires the OLDEST toast, so a burst shows what just arrived.
---@param icon number|string
---@param text string
---@param itemLink string|nil
---@param countItem number|nil
---@param countQuantity number|nil
---@param quality number|nil # colors the icon's frame; nil for coin
---@return nil
local function EnterToast(icon, text, itemLink, countItem, countQuantity, quality)
	while #active >= MaxVisible() do
		ns.ReleaseLootToast(active[1], true)
	end
	RestartFades()
	local toast = AcquireToast()
	toast.icon:SetTexture(icon)
	SetToastQuality(toast, quality)
	toast.baseText, toast.countItem, toast.countQuantity = text, countItem, countQuantity
	toast.itemLink = itemLink
	toast.hover:SetMouseMotionEnabled(TakesPointer(toast))
	WriteToastText(toast)
	toast:SetAlpha(1)
	toast:Show()
	active[#active + 1] = toast
	-- The flash's colors first: Restack paints its gradient with the shade's.
	PlayFlash(toast, quality)
	Restack()
	PlayEnter(toast)
	PlayFade(toast)
end

-- Rows enter one per ns.LOOT_TOAST_ENTRY_INTERVAL, so a burst can be read as it arrives.
local pending = {}
local lastEntryAt = nil
local drainScheduled = false

local ScheduleDrain

local function DrainPending()
	drainScheduled = false
	if not ns.db or not ns.db.profile.lootToasts then
		wipe(pending)
		return
	end
	local entry = table.remove(pending, 1)
	if entry then
		lastEntryAt = GetTime()
		EnterToast(entry[1], entry[2], entry[3], entry[4], entry[5], entry[6])
	end
	if #pending > 0 then
		ScheduleDrain()
	end
end

function ScheduleDrain()
	if drainScheduled then
		return
	end
	drainScheduled = true
	C_Timer.After(math.max(0, (lastEntryAt or 0) + ns.LOOT_TOAST_ENTRY_INTERVAL - GetTime()), DrainPending)
end

local function PushToast(icon, text, itemLink, countItem, countQuantity, quality)
	local now = GetTime()
	if #pending == 0 and (not lastEntryAt or now - lastEntryAt >= ns.LOOT_TOAST_ENTRY_INTERVAL) then
		lastEntryAt = now
		EnterToast(icon, text, itemLink, countItem, countQuantity, quality)
		return
	end
	pending[#pending + 1] = { icon, text, itemLink, countItem, countQuantity, quality }
	ScheduleDrain()
end

ns.PushLootToast = PushToast

local function LooterNameColor(looterName)
	return ns:GetGroupMemberClassColor(looterName) or GetColor("HELP")
end

-- A group item turned down while uncached (bind type unknown) is judged once more.
local GROUP_ITEM_RETRY_SECONDS = 1

-- A link's brackets are chat punctuation and go; the escape stays, so it is still a real link.
---@param itemLink string
---@param quantity number|nil
---@param looterName string|nil # nil for the player's own loot
---@param winningRoll string|nil # the roll it was won with, as LOOT_TOASTS_ROLL_RESULT reads
---@param retried boolean|nil # true on the second look at an uncached group item
---@return nil
function ns.ShowLootToast(itemLink, quantity, looterName, winningRoll, retried)
	if not itemLink or not ns.db or not ns.db.profile.lootToasts then
		return
	end
	local itemIdentifier = tonumber(string.match(itemLink, "item:(%d+)"))
	local quality = ns.GetLinkQuality(itemLink)
	if not ns.IsLootToastWanted(quality, itemIdentifier, looterName) then
		if looterName and itemIdentifier and not retried and not C_Item.GetItemInfo(itemIdentifier) then
			C_Item.RequestLoadItemDataByID(itemIdentifier)
			C_Timer.After(GROUP_ITEM_RETRY_SECONDS, function()
				ns.ShowLootToast(itemLink, quantity, looterName, winningRoll, true)
			end)
		end
		return
	end
	local text = string.gsub(itemLink, "|h%[(.-)%]|h", "|h%1|h")
	local count = quantity or 1
	if count > 1 then
		text = text .. " " .. L["ITEM_QUANTITY"]:format(count)
	end
	local profile = ns.db.profile
	local showRoll = winningRoll
		and (looterName and profile.lootToastWinningRollGroup or not looterName and profile.lootToastWinningRollMine)
	local rollText = showRoll and (GetColor("HELP") .. winningRoll .. "|r")
	if looterName then
		local name = LooterNameColor(looterName) .. looterName .. "|r"
		if rollText then
			text = L["LOOT_TOASTS_LOOTED_BY_ROLL"]:format(text, name, rollText)
		else
			text = L["LOOT_TOASTS_LOOTED_BY"]:format(text, name)
		end
		PushToast(ns.GetItemIconByID(itemIdentifier), text, itemLink, nil, nil, quality)
		return
	end
	if rollText then
		text = L["LOOT_TOASTS_YOU_WON_ROLL"]:format(text, rollText)
	end
	PushToast(ns.GetItemIconByID(itemIdentifier), text, itemLink, itemIdentifier, count, quality)
end

--------------------------------------------------------------------------------
-- Samples
--------------------------------------------------------------------------------

local function ReleaseSamples()
	while #samples > 0 do
		ns.ReleaseLootToast(samples[#samples], true)
	end
end

---@return nil
function ns.ApplyLootToastLimit()
	while #active > MaxVisible() do
		ns.ReleaseLootToast(active[1], true)
	end
	ns.RefreshLootToastSamples()
end

---@return nil
function ns.ApplyLootToastTooltips()
	for _, toast in ipairs(active) do
		local takes = TakesPointer(toast)
		if not takes and toast.hovered then
			OnToastLeave(toast.hover)
		end
		toast.hover:SetMouseMotionEnabled(takes)
	end
end

local MAX_SAMPLE_QUALITY = 4

local function LowestMineQuality()
	local profile = ns.db.profile
	local lowest
	for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
		if row.rarity and profile.lootToastMine[row.key] then
			local quality = profile.lootToastMineQuality[row.key] or 0
			lowest = math.min(lowest or quality, quality)
		end
	end
	return math.min(lowest or 0, MAX_SAMPLE_QUALITY)
end

--[[
    Rebuilt on every appearance change: the reshuffled colors make the preview
    visibly answer each one. Samples never fade; they go with the handle.
]]
---@return nil
function ns.RefreshLootToastSamples()
	ReleaseSamples()
	ns.ApplyLootToastHandleLayout()
	-- Restack still runs while locked, so a change with real toasts on screen re-hangs them too.
	if ns.db and ns.AreLootToastsUnlocked() then
		local rows = MaxVisible()
		if rows == math.huge then
			rows = SAMPLE_COUNT_UNLIMITED
		end
		local lowestQuality = LowestMineQuality()
		for _ = 1, rows do
			-- 5 is Legendary, the top of ns.LOOT_TOAST_SAMPLE_ICONS.
			local quality = math.random(lowestQuality, 5)
			local toast = AcquireToast()
			toast.icon:SetTexture(ns.LOOT_TOAST_SAMPLE_ICONS[quality])
			SetToastQuality(toast, quality)
			toast.isSample = true
			toast.text:SetText(ns.GetQualityColor(quality) .. L["LOOT_TOASTS_EXAMPLE_ITEM"] .. "|r")
			toast:SetAlpha(1)
			toast:Show()
			active[#active + 1] = toast
			samples[#samples + 1] = toast
		end
	end
	Restack()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- The client prints loot lines only for the player's own group, so any other name is a member's.
local function OnChatMessageLoot(message)
	if not ns.db.profile.lootToasts or ns.ParseRollResultMessage(message) or ns.ParseRollWonMessage(message) then
		return
	end
	local itemLink, quantity = ns.ParseOwnLootMessage(message)
	if itemLink then
		ns.ShowLootToast(itemLink, quantity, nil, ns.ClaimWinningRoll(ns:GetCleanUnitName("player"), itemLink))
		return
	end
	local looterName, groupItemLink, groupQuantity = ns.ParseGroupLootMessage(message)
	if groupItemLink then
		ns.ShowLootToast(groupItemLink, groupQuantity, looterName, ns.ClaimWinningRoll(looterName, groupItemLink))
	end
end

local function OnBagUpdateDelayed()
	if not ns.db or not ns.db.profile.lootToastBagCount then
		return
	end
	local rewritten = false
	for _, toast in ipairs(active) do
		if toast.countItem then
			WriteToastText(toast)
			rewritten = true
		end
	end
	if rewritten then
		Restack()
	end
end

ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMessageLoot)
ns:RegisterModuleEvent("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
