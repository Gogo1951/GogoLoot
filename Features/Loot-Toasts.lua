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
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local TOAST_HANDLE_WIDTH = 400 -- The drag handle only; rows size themselves
local TOAST_HEIGHT = 24 -- Minimum row height; large fonts raise it, see RowHeight
local TOAST_SPACING = 8 -- Gap between rows, so entries read as separate lines
local TOAST_TEXT_PADDING = 6 -- Breathing room above and below the text itself

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

--[[
    Everything in a row is measured from the font size, so the layout holds its
    proportions at every size. The icon is half again the font size, which puts
    it just above the text's visual line height, and the gap is a third of it.
]]
local ICON_TO_FONT_RATIO = 1.5
local ICON_TEXT_GAP_RATIO = 1 / 3

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

local anchor
local pool = {}
local active = {}
local samples = {}
local unlocked = false

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

local function IconSize()
	return math.floor(FontSize() * ICON_TO_FONT_RATIO + 0.5)
end

local function IconGap()
	return math.max(2, math.floor(FontSize() * ICON_TEXT_GAP_RATIO))
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
	return IconSize() + IconGap() + math.floor(FontSize() * TEXT_WIDTH_RATIO)
end

--[[
    Which end of the anchor a row hangs off, and which side of the row its icon
    takes. The handle's caption goes to the opposite end, so the preview text and
    the rows never collide.
]]
local function AlignsRight()
	return ns.db ~= nil and ns.db.profile.lootToastAlign == "RIGHT"
end

-- The row clears the icon, which is taller than the text; at the default size this is TOAST_HEIGHT.
local function RowHeight()
	return math.max(TOAST_HEIGHT, IconSize() + TOAST_TEXT_PADDING)
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
	local gap = IconGap()
	toast:SetSize(RowWidth(), RowHeight())
	toast.icon:SetSize(iconSize, iconSize)
	toast.icon:ClearAllPoints()
	toast.text:ClearAllPoints()

	-- Font first: SetFont resets a font string's justification.
	ApplyFont(toast.text, path, size, flags, fallbackPath)

	toast.text:SetWidth(0)
	if AlignsRight() then
		toast.icon:SetPoint("RIGHT")
		toast.text:SetPoint("RIGHT", toast.icon, "LEFT", -gap, 0)
		toast.text:SetJustifyH("RIGHT")
	else
		toast.icon:SetPoint("LEFT")
		toast.text:SetPoint("LEFT", toast.icon, "RIGHT", gap, 0)
		toast.text:SetJustifyH("LEFT")
	end

	local maxTextWidth = RowWidth() - iconSize - gap
	if toast.text:GetStringWidth() > maxTextWidth then
		toast.text:SetWidth(maxTextWidth)
	end
end

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
	if AlignsRight() then
		frame.label:SetPoint("TOPLEFT", frame, "TOPLEFT", TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("LEFT")
		frame.disable:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
	else
		frame.label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TOAST_HANDLE_PADDING, -TOAST_HANDLE_PADDING)
		frame.label:SetJustifyH("RIGHT")
		frame.disable:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -TOAST_HANDLE_PADDING, TOAST_HANDLE_PADDING)
	end
end

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
				.. L["LOOT_TOASTS_HANDLE_TITLE"]
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
-- Toast Frames
--------------------------------------------------------------------------------

local function AcquireToast()
	local toast = table.remove(pool)
	if toast then
		toast.pooled = nil
		return toast
	end
	toast = CreateFrame("Frame", nil, UIParent)
	-- Both are positioned by Measure, which owns the row's layout per alignment.
	toast.icon = toast:CreateTexture(nil, "ARTWORK")
	toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- One line, always. An over-long name truncates rather than breaking the row.
	toast.text:SetWordWrap(false)

	toast.fade = toast:CreateAnimationGroup()
	toast.fadeOut = toast.fade:CreateAnimation("Alpha")
	toast.fadeOut:SetFromAlpha(1)
	toast.fadeOut:SetToAlpha(0)
	toast.fadeOut:SetDuration(ns.LOOT_TOAST_FADE_DURATION)
	toast.fade:SetScript("OnFinished", function(group)
		ns.ReleaseLootToast(group:GetParent())
	end)
	return toast
end

-- The time on screen is a setting, so it is stamped on the animation at play time.
local function PlayFade(toast)
	toast.fadeOut:SetStartDelay(ns.db.profile.lootToastDuration)
	toast.fade:Play()
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
	local step = RowHeight() + TOAST_SPACING
	local growDown = ns.db and ns.db.profile.lootToastGrowth == "DOWN"
	local corner = (growDown and "TOP" or "BOTTOM") .. (AlignsRight() and "RIGHT" or "LEFT")
	local path, size, flags, fallbackPath = ResolveFont()
	for index, toast in ipairs(active) do
		Measure(toast, path, size, flags, fallbackPath)
		toast:ClearAllPoints()
		local offset = (count - index) * step
		toast:SetPoint(corner, GetAnchor(), corner, 0, growDown and -offset or offset)
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
    The Filters row an item falls under, by the type the client files it under.
    A subclass row (Mount, Companion Pets) wins over its class's row, which is
    how Miscellaneous leaves them out. C_Item.GetItemInfoInstant answers from
    the client's own database, so the row is known the moment the item drops.
]]
local FILTER_ROWS_BY_CLASS, FILTER_ROWS_BY_SUBCLASS = {}, {}
for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
	if row.subclassIdentifier then
		FILTER_ROWS_BY_SUBCLASS[row.classIdentifier .. ":" .. row.subclassIdentifier] = row
	elseif row.classIdentifier then
		FILTER_ROWS_BY_CLASS[row.classIdentifier] = row
	end
end

---@param itemIdentifier number
---@return table|nil
local function FilterRowFor(itemIdentifier)
	local _, _, _, _, _, classIdentifier, subclassIdentifier = C_Item.GetItemInfoInstant(itemIdentifier)
	if not classIdentifier then
		return nil
	end
	return FILTER_ROWS_BY_SUBCLASS[classIdentifier .. ":" .. tostring(subclassIdentifier)]
		or FILTER_ROWS_BY_CLASS[classIdentifier]
end

--[[
    Whether an item gets a toast, by the Mine boxes for the player's own loot
    and the Group boxes for anyone else's. An item counts when its type's box is
    ticked and, on a rarity row, it reaches the quality beside the box. Three
    rows reach across types: Openables (an item on the Openables List, whatever
    it is set to, since the toast is the player's cue that the add-on may be
    about to act), Bind on Pickup, and Quest, which also takes an item the game
    binds as a quest item whatever its class (Soft-shelled Clam is a Key), and
    a quest STARTER, as often an ordinary trinket or blade as a quest item.

    ORDER HERE IS BY COST. The list lookup and the type are free, Bind on Pickup
    needs the full C_Item.GetItemInfo, which can answer nil on a cold cache;
    that reads as "not Bind on Pickup", acceptable because the item was just
    looted, the one moment the client is sure to have it cached. The quest
    starter costs a tooltip, so it is last. A quality nobody can read passes a
    rarity row: a toast is a display, and silently swallowing something that
    was looted is the worse failure.
]]
---@param quality number|nil
---@param itemIdentifier number|nil
---@param looterName string|nil # nil for the player's own loot
---@return boolean
local function Wanted(quality, itemIdentifier, looterName)
	if not itemIdentifier then
		return true
	end
	local profile = ns.db.profile
	local shown = looterName and profile.lootToastGroup or profile.lootToastMine
	local qualities = looterName and profile.lootToastGroupQuality or profile.lootToastMineQuality
	if shown.OPENABLES and ns:GetOpeningAction(itemIdentifier) ~= nil then
		return true
	end
	local row = FilterRowFor(itemIdentifier)
	if row and shown[row.key] then
		if not row.rarity or not quality or quality >= (qualities[row.key] or 0) then
			return true
		end
	end
	local bindType = select(14, C_Item.GetItemInfo(itemIdentifier))
	if shown.BIND_ON_PICKUP and bindType == ns.BIND_ON_PICKUP then
		return true
	end
	if shown.QUEST and bindType == ns.BIND_QUEST_ITEM then
		return true
	end
	return shown.QUEST and not (row and row.key == "QUEST") and ns.ItemStartsQuest(itemIdentifier) or false
end

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
    arrived. An item of the player's own passes its id and looted count, for
    Bag Count.
]]
---@param icon number|string
---@param text string
---@param countItem number|nil
---@param countQuantity number|nil
---@return nil
local function PushToast(icon, text, countItem, countQuantity)
	while #active >= MaxVisible() do
		ns.ReleaseLootToast(active[1])
	end
	local toast = AcquireToast()
	toast.icon:SetTexture(icon)
	toast.baseText, toast.countItem, toast.countQuantity = text, countItem, countQuantity
	WriteToastText(toast)
	toast:SetAlpha(1)
	toast:Show()
	active[#active + 1] = toast
	Restack()
	PlayFade(toast)
end

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
    silver, after the looter or straight after the item when it was the
    player's, while Winning Roll is on for that side.
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
	if not Wanted(ns.GetLinkQuality(itemLink), itemIdentifier, looterName) then
		return
	end
	local text = string.gsub(itemLink, "|h%[(.-)%]|h", "|h%1|h")
	local count = quantity or 1
	if count > 1 then
		text = text .. " " .. L["LOOT_TOASTS_QUANTITY"]:format(count)
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
		PushToast(ns.GetItemIconByID(itemIdentifier), text)
		return
	end
	if rollText then
		text = L["LOOT_TOASTS_WON_ROLL"]:format(text, rollText)
	end
	PushToast(ns.GetItemIconByID(itemIdentifier), text, itemIdentifier, count)
end

--------------------------------------------------------------------------------
-- Money
--------------------------------------------------------------------------------

local goldPattern = ns.BuildFormatPattern(GOLD_AMOUNT)
local silverPattern = ns.BuildFormatPattern(SILVER_AMOUNT)
local copperPattern = ns.BuildFormatPattern(COPPER_AMOUNT)

--[[
    A coin total out of a money message ("You loot 1 Gold, 24 Silver, 7
    Copper"). The client hands over the sentence, not the number, and matching
    its OWN GOLD_AMOUNT, SILVER_AMOUNT and COPPER_AMOUNT formats is what makes
    that work in every locale. A unit the message doesn't mention simply doesn't
    match, which is the same as none of it.
]]
---@param message any
---@return number
function ns.ParseMoney(message)
	if type(message) ~= "string" then
		return 0
	end
	local gold = goldPattern and tonumber(string.match(message, goldPattern)) or 0
	local silver = silverPattern and tonumber(string.match(message, silverPattern)) or 0
	local copper = copperPattern and tonumber(string.match(message, copperPattern)) or 0
	return (gold * ns.COPPER_PER_GOLD) + (silver * ns.COPPER_PER_SILVER) + copper
end

local MONEY_COLORS = {}
for key, hex in pairs(ns.MONEY_PALETTE) do
	MONEY_COLORS[key] = "|cff" .. hex
end

--[[
    One coin: the amount in body white, then its unit in that coin's own color,
    so a stack of these lines its numbers up as one white column and the eye
    reads the unit off the color. The symbol is the client's own, so it reads
    right in a locale that doesn't call them gold, silver and copper.
]]
local function Coin(amount, digits, symbol, colorKey)
	return GetColor("BODY") .. string.format(digits, amount) .. "|r" .. MONEY_COLORS[colorKey] .. symbol .. "|r"
end

--[[
    "123g 02s 27c": the largest unit the amount reaches, then every unit below
    it padded to two digits, and nothing above it. Padding the lower units lines
    the numbers up when several toasts stack; a leading "0g" would be noise.
]]
local function FormatMoney(copper)
	local gold = math.floor(copper / ns.COPPER_PER_GOLD)
	local silver = math.floor((copper % ns.COPPER_PER_GOLD) / ns.COPPER_PER_SILVER)
	local remainder = copper % ns.COPPER_PER_SILVER
	if gold > 0 then
		return Coin(gold, "%d", GOLD_AMOUNT_SYMBOL, "GOLD")
			.. " "
			.. Coin(silver, "%02d", SILVER_AMOUNT_SYMBOL, "SILVER")
			.. " "
			.. Coin(remainder, "%02d", COPPER_AMOUNT_SYMBOL, "COPPER")
	end
	if silver > 0 then
		return Coin(silver, "%d", SILVER_AMOUNT_SYMBOL, "SILVER")
			.. " "
			.. Coin(remainder, "%02d", COPPER_AMOUNT_SYMBOL, "COPPER")
	end
	return Coin(remainder, "%d", COPPER_AMOUNT_SYMBOL, "COPPER")
end

-- The coin pile says the magnitude before the digits are read.
local function MoneyIcon(copper)
	if copper >= ns.COPPER_PER_GOLD then
		return ns.MONEY_ICON_GOLD
	end
	if copper >= ns.COPPER_PER_SILVER then
		return ns.MONEY_ICON_SILVER
	end
	return ns.MONEY_ICON_COPPER
end

--[[
    COIN IS THE ONLY LOOT WITH NO ITEM BEHIND IT: no link, no icon of its own, no
    quality, so no item-type row or quality could have an opinion about it. It
    answers to the Money row's Mine box alone, since every kill drops coin and
    this is the row a player is likeliest to want gone.
]]
---@param copper number
---@return nil
function ns.ShowMoneyToast(copper)
	if not copper or copper <= 0 or not ns.db or not ns.db.profile.lootToasts then
		return
	end
	if not ns.db.profile.lootToastMine.MONEY then
		return
	end
	PushToast(MoneyIcon(copper), FormatMoney(copper))
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
	ApplyHandleLayout()
	-- Restack still runs while locked, so a change with real toasts on screen re-hangs them too.
	if ns.db and unlocked then
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

local function OnPlayerLogin()
	ns.ApplyLootToastPosition()
	ns.ShowLootToastIntro()
end

--[[
    The player's own loot, and the rest of the group's. The client prints loot
    lines only for the player's own party or raid, so a line naming someone else
    is already a group member's; the Group boxes decide whether it shows.
]]
local function OnChatMessageLoot(message)
	if ns.RecordRollLine(message) then
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

--[[
    With the loot window hidden, the chat line this event carries is the only
    record of coin, and the amount comes back out of that sentence.
]]
local function OnChatMessageMoney(message)
	ns.ShowMoneyToast(ns.ParseMoney(message))
end

-- The bags settled: every own-loot toast on screen re-reads its count (see WriteToastText).
local function OnBagsSettled()
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

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMessageLoot)
ns:RegisterModuleEvent("CHAT_MSG_MONEY", OnChatMessageMoney)
ns:RegisterModuleEvent("BAG_UPDATE_DELAYED", OnBagsSettled)
