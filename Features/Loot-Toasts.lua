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

local TOAST_HEIGHT = 24 -- Minimum row height; large fonts raise it, see RowHeight
local TOAST_SPACING = 8 -- Gap between rows, so entries read as separate lines
local TOAST_TEXT_PADDING = 6 -- Breathing room above and below the text itself

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

-- The handle lays its caption out by the same alignment (Features/Loot-Toasts-Handle.lua).
ns.LootToastsAlignRight = AlignsRight

-- The row clears the icon, which is taller than the text; only small font sizes leave it at TOAST_HEIGHT.
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

	-- The hover area runs from the icon's outer edge to the end of the text, the icon's height tall.
	toast.hover:ClearAllPoints()
	if AlignsRight() then
		toast.hover:SetPoint("TOPRIGHT", toast.icon, "TOPRIGHT")
		toast.hover:SetPoint("BOTTOMRIGHT", toast.icon, "BOTTOMRIGHT")
		toast.hover:SetPoint("LEFT", toast.text, "LEFT")
	else
		toast.hover:SetPoint("TOPLEFT", toast.icon, "TOPLEFT")
		toast.hover:SetPoint("BOTTOMLEFT", toast.icon, "BOTTOMLEFT")
		toast.hover:SetPoint("RIGHT", toast.text, "RIGHT")
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
	-- Both are positioned by Measure, which owns the row's layout per alignment.
	toast.icon = toast:CreateTexture(nil, "ARTWORK")
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
		ns.ReleaseLootToast(group:GetParent())
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
	local step = RowHeight() + TOAST_SPACING
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
---@return nil
local function PushToast(icon, text, itemLink, countItem, countQuantity)
	while #active >= MaxVisible() do
		ns.ReleaseLootToast(active[1])
	end
	local toast = AcquireToast()
	toast.icon:SetTexture(icon)
	toast.baseText, toast.countItem, toast.countQuantity = text, countItem, countQuantity
	toast.itemLink = itemLink
	toast.hover:SetMouseMotionEnabled(itemLink ~= nil)
	WriteToastText(toast)
	toast:SetAlpha(1)
	toast:Show()
	active[#active + 1] = toast
	Restack()
	PlayFade(toast)
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
	if not ns.IsLootToastWanted(ns.GetLinkQuality(itemLink), itemIdentifier, looterName) then
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
		PushToast(ns.GetItemIconByID(itemIdentifier), text, itemLink)
		return
	end
	if rollText then
		text = L["LOOT_TOASTS_YOU_WON_ROLL"]:format(text, rollText)
	end
	PushToast(ns.GetItemIconByID(itemIdentifier), text, itemLink, itemIdentifier, count)
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
