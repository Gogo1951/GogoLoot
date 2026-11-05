--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts
--------------------------------------------------------------------------------

--[[
    Speedy Loot hides the loot window, so the only record of what was picked up
    is the chat log. Toasts are a small on-screen readout of the same thing:
    icon, colored link, quantity. Which loot gets one is the Filters rows: a
    Mine and a Group box per item type (see ns.LOOT_TOAST_FILTER_ROWS), so the
    rest of the group's pickups can join the player's, each naming its looter.
    An item won on a roll says how it was won.

    The stack reads like a chat log. A new entry appears at the anchor and
    everything already on screen shifts one row away from it, upward by
    default, downward when lootToastGrowth is "DOWN", so the oldest row is
    always the one at the far end, fading out of it. That keeps the reading
    order stable, and the row the player just triggered is always in the same
    place on screen.

    The anchor the stack hangs from, its drag handle and the first-login
    introduction live in Features/Loot-Toasts-Handle.lua.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LSM = LibStub("LibSharedMedia-3.0")

--[[
    THE GRID. Every size in a row is a step of the 2, 4, 8, 16, 32 scale at
    the default font size (GRID_FONT_SIZE, 16), and scales with the font from
    there (GridSize), so the layout keeps its proportions at every size. At 16:

        row 32, the framed icon filling it: 28 of art inside a 2 border
        8 from the frame to the text, 8 between rows, so 40 row to row

    The frame is the item's quality color, the way bags and the loot window
    mark quality, and its corners are rounded (see ICON_BORDER_MASK). The icon
    art is cropped by ICON_CROP on every side to drop the bevel Blizzard
    paints into each icon, which would otherwise double the frame.
]]
local GRID_FONT_SIZE = 16
local ROW_UNITS = 32 -- The row's height, which the framed icon fills
local BORDER_UNITS = 2
local TEXT_GAP_UNITS = 8
local ROW_SPACING_UNITS = 8
local ICON_CROP = 0.07

--[[
    Rounded corners. A texture can't round its own corners, so each square is
    cut by an alpha mask shipped with the add-on: the frame by one whose
    corners are 4 of its 32, the art by one whose corners are 2 of its 28, so
    the two curves stay concentric (outer radius less the border) at every
    size. Both are 64-pixel squares, a power of two as masks must be.
]]
local ICON_BORDER_MASK = "Interface\\AddOns\\GogoLoot\\Includes\\Images\\Toast-Icon-Border-Mask.tga"
local ICON_ART_MASK = "Interface\\AddOns\\GogoLoot\\Includes\\Images\\Toast-Icon-Art-Mask.tga"

--[[
    A dark shade behind each row, darkest at the icon and fading to nothing a
    few characters past the end of the text, so the text holds up over a bright
    world without a hard box edge. BACKDROP_TAIL_UNITS is that fade-out run
    beyond the text, on the grid (48 at the default size). The shade starts
    under the middle of the icon, so its square end stays hidden behind the
    rounded frame.
]]
local BACKDROP_ALPHA = 0.7
local BACKDROP_TAIL_UNITS = 48

--[[
    Motion. A new row slides in from the side the stack lines up on and fades
    up while it does; a burst of loot enters one row per
    ns.LOOT_TOAST_ENTRY_INTERVAL rather than all at once, so each can be read
    as it arrives. The slide is on the grid too (16 at the default size).
]]
local SLIDE_DURATION = 0.2
local SLIDE_UNITS = 16

--[[
    An Epic or better item lights its row in its quality color for a moment,
    brightest at the icon and fading along the row like the shade under it.
]]
local FLASH_MIN_QUALITY = 4
local FLASH_ALPHA = 0.6
local FLASH_DURATION = 1

--[[
    How wide a row may get: roughly 64 characters at any size, since a glyph
    averages about half the em box. That clears the longest thing Classic can
    name, a random-suffix weapon, with room for a quantity. It scales with the
    font, because doubling the font halves how many characters fit a fixed
    width. It is a ceiling, not the working width: Measure sizes the text to the
    string and truncates only a name that overruns it.
]]
local TEXT_WIDTH_RATIO = 32

-- Sample rows the position preview shows when the cap is Unlimited, which has no count to mirror.
local SAMPLE_COUNT_UNLIMITED = 8

local pool = {}
local active = {}
local samples = {}

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------

--[[
    Fonts come from LibSharedMedia, the registry other add-ons publish their
    faces into. GogoLoot ships it, so the dropdown is never empty: on its own
    the library still registers the faces the client itself carries, and it
    masks its list by locale, so a koKR client is only offered faces that can
    draw Korean.

    "DEFAULT" is our own sentinel rather than a registered face: it resolves to
    whatever GameFontNormal uses, the only right answer on a locale whose client
    ships its own font. A face the library no longer knows falls back to it too.
]]
local function FontPath(value, defaultPath)
	if not value or value == "DEFAULT" then
		return defaultPath
	end
	return LSM:IsValid("font", value) and LSM:Fetch("font", value) or defaultPath
end

--[[
    Rebuilt on every call rather than cached, so a face registered by an add-on
    that loaded after this one still turns up the next time the dropdown opens.
]]
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

--[[
    THE FLAG STRING CARRIES THE WEIGHT, because the client offers no bold:
    SetFont takes a face, a size and a flag string, and a thicker outline is what
    reads as heavier against a bright world. "NONE" is ours and resolves to the
    empty string SetFont expects.
]]
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

--[[
    Resolved once per restack and passed down: every row in a pass uses the same
    face. Deliberately not cached across restacks, so a face registered later,
    or a font change, reaches rows already on screen.
]]
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

-- A grid size (in units at GRID_FONT_SIZE) at the current font size, whole, and never below `minimum`.
local function GridSize(units, minimum)
	return math.max(minimum, math.floor(units * FontSize() / GRID_FONT_SIZE + 0.5))
end

-- The framed icon, border included: what the text and the hover area measure from. It fills the row.
local function FramedIconSize()
	return GridSize(ROW_UNITS, 8)
end

local function BorderSize()
	return GridSize(BORDER_UNITS, 1)
end

-- The art inside the frame.
local function IconSize()
	return FramedIconSize() - 2 * BorderSize()
end

local function IconGap()
	return GridSize(TEXT_GAP_UNITS, 2)
end

local function RowSpacing()
	return GridSize(ROW_SPACING_UNITS, 2)
end

--[[
    Unlimited is stored as 0, which must never reach the cap arithmetic as a
    number: `#active >= 0` is always true and would retire every row the moment
    it was drawn. It resolves to infinity, so the same comparison never fires.
]]
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

--[[
    Which end of the anchor a row hangs off, and which side of the row its icon
    takes. The handle's caption goes to the opposite end, so the preview text and
    the rows never collide.
]]
local function AlignsRight()
	return ns.db ~= nil and ns.db.profile.lootToastAlign == "RIGHT"
end

-- The handle lays its caption out by the same alignment (Features/Loot-Toasts-Handle.lua).
ns.LootToastsAlignRight = AlignsRight

-- The framed icon fills the row, so the row is exactly as tall as it.
local function RowHeight()
	return FramedIconSize()
end

--[[
    One owner for every font-dependent measurement and the row's internal
    layout, run from Restack, so a change to the font, size or alignment reaches
    toasts already on screen.

    THE TRAP: a text box spanning the whole row makes the name's position depend
    on its justification, and one row holding a stale justification stranded
    its name at the far end, far from its own icon. So the box is sized to the
    string (SetWidth(0) auto-sizes) and pinned to the icon; only a name too long
    for the row takes a fixed width, and it fills that box.
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

	-- The frame wraps the icon on every side, so it is drawn from the icon rather than placed on its own.
	toast.border:ClearAllPoints()
	toast.border:SetPoint("TOPLEFT", toast.icon, "TOPLEFT", -border, border)
	toast.border:SetPoint("BOTTOMRIGHT", toast.icon, "BOTTOMRIGHT", border, -border)

	-- Font first: SetFont resets a font string's justification.
	ApplyFont(toast.text, path, size, flags, fallbackPath)

	--[[
	    The shade spans the row's height from the middle of the icon to just
	    past the text, darkest on the icon side. SetGradient's first color is always the
	    left end, so the two colors swap with the alignment.
	]]
	local dark, clear = CreateColor(0, 0, 0, BACKDROP_ALPHA), CreateColor(0, 0, 0, 0)
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

	-- The hover area runs from the frame's outer edge to the end of the text, the frame's height tall.
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

--[[
    The icon's frame takes the item's quality color. Coin has no quality (see
    Features/Loot-Toasts-Money.lua), so its frame stays black: still framed,
    the same size as every other row, but saying nothing about rarity.
]]
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

-- The time on screen is a setting, so it is stamped on the animation at play time.
local function PlayFade(toast)
	toast.fadeOut:SetStartDelay(ns.db.profile.lootToastDuration)
	toast.fade:Play()
end

--[[
    New loot keeps the whole stack up: every row already on screen starts its
    time over, and one already fading comes back to full, so a run of pickups
    stays readable together and leaves together. Not a row under the pointer,
    whose fade is paused for its tooltip and resumes when the pointer leaves,
    and not the samples, which never fade.

    THE TRAP: stopping a fade can fire its OnFinished, which would release the
    row. `restarting` tells that handler this stop is not the end.
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

-- Slides in from beyond the side the rows line up on: from the left on a left-aligned stack.
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

--[[
    An item row shows the item's own tooltip on hover, the one chat shows for
    the same link. It sits against the hovered icon and name, on the side away
    from where the rows line up. THE TRAP: not against the row's frame, which is
    RowWidth() wide whatever the text, so a short name left the tooltip stranded
    far across the screen. The fade pauses while the pointer is on the row and
    resumes where it left off, so a row can't vanish from under a tooltip being read.
]]
local function OnToastEnter(hover)
	local toast = hover:GetParent()
	if not toast.itemLink then
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
	-- Hiding a row under the pointer leaves it too; a pooled row has no fade to resume.
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
	-- All four are positioned by Measure, which owns the row's layout per alignment.
	-- White bases, so the gradient and the quality tint are the only color either carries.
	toast.backdrop = toast:CreateTexture(nil, "BACKGROUND")
	toast.backdrop:SetColorTexture(1, 1, 1, 1)
	-- The Epic flash glows over the shade, across the same span; its gradient is painted with the shade's.
	toast.flash = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
	toast.flash:SetColorTexture(1, 1, 1, 1)
	toast.flash:SetBlendMode("ADD")
	toast.flash:SetAllPoints(toast.backdrop)
	toast.flash:Hide()
	toast.border = toast:CreateTexture(nil, "BORDER")
	toast.border:SetColorTexture(1, 1, 1, 1)
	toast.icon = toast:CreateTexture(nil, "ARTWORK")
	toast.icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)
	-- The masks follow their textures' size and place, so Measure never touches them.
	toast.borderMask = toast:CreateMaskTexture()
	toast.borderMask:SetTexture(ICON_BORDER_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	toast.borderMask:SetAllPoints(toast.border)
	toast.border:AddMaskTexture(toast.borderMask)
	toast.iconMask = toast:CreateMaskTexture()
	toast.iconMask:SetTexture(ICON_ART_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	toast.iconMask:SetAllPoints(toast.icon)
	toast.icon:AddMaskTexture(toast.iconMask)
	toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- One line, always. An over-long name truncates rather than breaking the row.
	toast.text:SetWordWrap(false)

	--[[
        THE TRAP: the row is far wider than its text (RowWidth is a ceiling), so
        a mouse-enabled row would put a long invisible strip over the world. The
        hover area is a child covering only the icon and text (see Measure), it
        takes the pointer only on an item row (see PushToast), and it never
        takes clicks, so a click on a toast still reaches whatever is behind it.
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

	--[[
	    The slide: a zero-length jump out to the side, then the glide back to
	    the row's place while it fades up. Translations don't persist, so the
	    row is exactly where Restack put it once this ends, and a restack while
	    it plays carries the slide along with the row.
	]]
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
    `active` runs oldest first, and the offset is measured from the END of the
    list, so the newest row sits at the anchor and age carries a row away from
    it. Adding a row raises the count, so every row already up moves one step;
    retiring the oldest drops the count and every survivor's index together,
    which cancels, so nothing near the anchor twitches.

    Rows pin to a corner of the anchor, never its center: growth picks the top
    or bottom edge and alignment picks the left or right end. Centered, a row's
    width would decide where its icon landed and a font change would walk the
    stack across the screen.
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
    THE TRAP: callers loop until a list shrinks, so a release that removed
    nothing would spin forever and freeze the client. The two removals below
    therefore ALWAYS run, and every call makes progress.

    Only the pooling is idempotent: stopping the fade can fire its own
    OnFinished, which releases the same frame again, and pooling it twice would
    hand one frame out as two rows.
]]
---@param toast table
---@return nil
function ns.ReleaseLootToast(toast)
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
	Restack()
end

--------------------------------------------------------------------------------
-- Entry Points
--------------------------------------------------------------------------------

--[[
    Bag Count: how many of the item the player now carries, after the count
    the toast looted, as "x3 (27)". It reads live rather than once, because the
    client may print the loot line before the bags take the item or after: the
    count is read as the toast goes up and again whenever the bags settle while
    it is on screen, so it always lands on the true number. Shown only when it
    says more than the toast's own count, so a first stack or a piece of gear
    reads as before.
]]
local function WriteToastText(toast)
	local carried = toast.countItem and ns.db.profile.lootToastBagCount and C_Item.GetItemCount(toast.countItem)
	if carried and carried > toast.countQuantity then
		toast.text:SetText(toast.baseText .. " " .. L["LOOT_TOASTS_BAG_COUNT"]:format(carried))
	else
		toast.text:SetText(toast.baseText)
	end
end

--[[
    Everything a row does once its icon and text are decided, so an item and a
    coin pile reach the screen the same way. The cap retires the OLDEST toast
    rather than dropping the new one: a burst of loot should show what just
    arrived. An item row passes its link, for its tooltip; an item of the
    player's own also passes its id and looted count, for Bag Count.
]]
---@param icon number|string
---@param text string
---@param itemLink string|nil
---@param countItem number|nil
---@param countQuantity number|nil
---@param quality number|nil # colors the icon's frame; nil for coin
---@return nil
local function EnterToast(icon, text, itemLink, countItem, countQuantity, quality)
	while #active >= MaxVisible() do
		ns.ReleaseLootToast(active[1])
	end
	RestartFades()
	local toast = AcquireToast()
	toast.icon:SetTexture(icon)
	SetToastQuality(toast, quality)
	toast.baseText, toast.countItem, toast.countQuantity = text, countItem, countQuantity
	toast.itemLink = itemLink
	toast.hover:SetMouseMotionEnabled(itemLink ~= nil)
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

--[[
    Rows enter one per ns.LOOT_TOAST_ENTRY_INTERVAL. A row with nothing ahead of it and no
    row just entered goes up at once; anything else waits its turn in
    `pending`, which drains on one timer at a time. Bag Count is read as a row
    enters, not as it queues, so a queued row still lands on the true count.
    Turning the toasts off empties the queue.
]]
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

-- The money toasts reach the screen the same way (Features/Loot-Toasts-Money.lua).
ns.PushLootToast = PushToast

-- Another group member's name, in their class color while the roster still holds them, silver once it doesn't.
local function LooterNameColor(looterName)
	return ns:GetGroupMemberClassColor(looterName) or GetColor("HELP")
end

--[[
    The square brackets a link carries are chat punctuation, marking where a link
    starts and ends in running text; a toast is one item on its own line, so they
    go. The escape sequence stays, so the text is still a real link.

    A group member's loot names its looter after the item, so every row's item
    still starts at its icon. An item won on a roll adds the winning roll, in
    silver, after the looter, or after "You Won" when it was the player's,
    while Winning Roll is on for that side.
]]
---@param itemLink string
---@param quantity number|nil
---@param looterName string|nil # nil for the player's own loot
---@param winningRoll string|nil # the roll it was won with, as LOOT_TOASTS_ROLL_RESULT reads
---@return nil
function ns.ShowLootToast(itemLink, quantity, looterName, winningRoll)
	if not itemLink or not ns.db or not ns.db.profile.lootToasts then
		return
	end
	local itemIdentifier = tonumber(string.match(itemLink, "item:(%d+)"))
	local quality = ns.GetLinkQuality(itemLink)
	if not ns.IsLootToastWanted(quality, itemIdentifier, looterName) then
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

--[[
    While the handle is up it stands in one "Example Item" sample per row the
    cap allows, each in a random quality at or above the lowest quality ticked
    on a Mine rarity row (Poor when none is), with a
    potion icon to match. The preview shows at once where the stack sits, how
    many rows it holds, what the font looks like, and which qualities the
    Mine rarity rows let through. The samples are rebuilt on every appearance change,
    and the reshuffled colors make the preview visibly answer each one. Samples
    never fade; they go when the handle does.
]]
local function ReleaseSamples()
	-- ReleaseLootToast takes the frame out of `samples` itself, so drain the tail.
	while #samples > 0 do
		ns.ReleaseLootToast(samples[#samples])
	end
end

-- The cap just changed: trim now, so the setting just picked is the one on screen.
---@return nil
function ns.ApplyLootToastLimit()
	while #active > MaxVisible() do
		ns.ReleaseLootToast(active[1])
	end
	ns.RefreshLootToastSamples()
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

--[[
    The player's own loot, and the rest of the group's. The client prints loot
    lines only for the player's own party or raid, so a line naming someone else
    is already a group member's; the Group boxes decide whether it shows.
]]
local function OnChatMessageLoot(message)
	-- Roll lines are read whatever the toasts' switch says: the winner summary needs them too.
	if ns.RecordRollLine(message) or not ns.db.profile.lootToasts then
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

-- The bags settled: every own-loot toast on screen re-reads its count (see WriteToastText).
local function OnBagUpdateDelayed()
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
