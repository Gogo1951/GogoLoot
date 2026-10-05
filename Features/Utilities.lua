--------------------------------------------------------------------------------
-- GogoLoot Utilities
--------------------------------------------------------------------------------

--[[
    Shared utilities used across feature modules and the options panels: the
    API compatibility shims, the scan tooltip, named timers, derived color
    tables and accessors, tooltip line helpers, player-name and item-link
    parsing, item lookups, bag space, the client's own format strings and the
    loot messages read with them, item quality, and small game-state
    predicates.
]]
local _, ns = ...

--------------------------------------------------------------------------------
-- API Compatibility Shims
--------------------------------------------------------------------------------

--[[
    Every API the engines genuinely differ on gets its one accessor here, so a
    client change is a one-line edit in one file rather than a hunt through the
    feature modules. Each picks by AVAILABILITY, never by truthy result: a
    `(modern call) or (legacy call)` chain silently falls through to the legacy
    read whenever the modern one legitimately returns false. Namespaced APIs
    every target client ships (C_Item, C_Container, C_AddOns) are called
    directly instead, with no legacy fallback.
]]

--[[
    GetGameMessageInfo maps a numeric message id to its constant name. The same
    error carries a different id on every flavor, and several ERR_* globals are
    unbound as strings on 1.15.9, so anything correlating a UI_ERROR_MESSAGE or
    UI_INFO_MESSAGE resolves the constants it cares about to this client's ids
    and matches on the number rather than on translated text.
]]
ns.GetGameMessageInfo = GetGameMessageInfo

--[[
    One walk of the message table, shared by the master-loot error correlation
    (Master-Looter-Distribution.lua), the trade-result watcher
    (Announcements-Trade.lua), and the Diagnostics Loot Method report, which
    passes both of those constant tables at once so the report costs one scan
    rather than one per table. `names` is any table keyed by constant name; the
    result maps this client's numeric id back to the name that resolved, and a
    constant this client doesn't carry simply never appears in it.

    The second return is how many messages the walk saw, which is the only thing
    that separates "this client resolved nothing" from "this client has no
    message table to resolve against" — a distinction the report has to draw.
]]
---@param names table
---@return table resolved
---@return number scannedCount
function ns:ResolveGameMessageIds(names)
	local resolved = {}
	if type(ns.GetGameMessageInfo) ~= "function" then
		return resolved, 0
	end

	local messageIndex = 1
	while true do
		local constantName = ns.GetGameMessageInfo(messageIndex)
		if not constantName then
			break
		end
		if names[constantName] then
			resolved[messageIndex] = constantName
		end
		messageIndex = messageIndex + 1
	end

	return resolved, messageIndex - 1
end

--[[
    Loot method and threshold: the engines differ per function, not per client.
    1.15.9 dropped the legacy GetLootMethod / SetLootMethod pair but kept
    GetLootThreshold / SetLootThreshold, so each resolves on its own, C_PartyInfo
    first, once at load; a client with neither leaves that accessor nil. The
    C_PartyInfo setter takes the numeric Enum.LootMethod value where the legacy
    one takes a string, and ns.SET_LOOT_METHOD_TAKES_ENUM records which won.
]]
ns.GetLootMethod = (C_PartyInfo and C_PartyInfo.GetLootMethod) or GetLootMethod
ns.GetLootThreshold = (C_PartyInfo and C_PartyInfo.GetLootThreshold) or GetLootThreshold
ns.SetLootMethod = (C_PartyInfo and C_PartyInfo.SetLootMethod) or SetLootMethod
ns.SetLootThreshold = (C_PartyInfo and C_PartyInfo.SetLootThreshold) or SetLootThreshold
ns.SET_LOOT_METHOD_TAKES_ENUM = C_PartyInfo ~= nil and C_PartyInfo.SetLootMethod ~= nil

---@return string|number|nil method
---@return number|nil masterLooterPartyIndex
---@return number|nil masterLooterRaidIndex
function ns:SafeCallLootMethod()
	if not ns.GetLootMethod then
		return nil
	end
	return ns.GetLootMethod()
end

--[[
    GetLootSlotType's "regular item" value. WoW Forever runs the Retail engine,
    which dropped the LOOT_SLOT_ITEM global for Enum.LootSlotType.Item. Picked by
    which table exists, never by what it holds.
]]
if Enum.LootSlotType then
	ns.LOOT_SLOT_TYPE_ITEM = Enum.LootSlotType.Item
else
	ns.LOOT_SLOT_TYPE_ITEM = LOOT_SLOT_ITEM
end

--[[
    An item's stat table from its link, for Character Rules and Validate Data. WoW Forever ships
    C_Item.GetItemStats; Classic Era and TBC Anniversary have only the legacy
    global GetItemStats, which returns the same table.
]]
ns.GetItemStats = C_Item.GetItemStats or GetItemStats

--------------------------------------------------------------------------------
-- Scan Tooltip
--------------------------------------------------------------------------------

--[[
    One hidden tooltip answers every question only a tooltip can: whether a bag
    slot's container is still locked (Automated Opening, the mini-map's Locked
    Items, Diagnostics' Locked Boxes), whether an item starts a quest (Loot
    Toasts), and an item's or spell's lines for Validate Data where the client
    has no C_TooltipInfo. Made on first use, since a session may never ask.

    THE OWNER IS SET ON EVERY CALL, not once, and that is load-bearing: hiding a
    tooltip drops its owner, and an unowned tooltip takes a SetBagItem without
    complaint and populates NOTHING, so every box would read as unlocked.
    Setting a tooltip also shows it, hence the Hide after every read: shown and
    hidden inside a single frame, it never renders.

    A GameTooltipTemplate tooltip's lines are only reachable through the frame's
    name.
]]
local SCAN_TOOLTIP_NAME = "GogoLootScanTooltip"
local scanTooltip

---@return table
local function PrepareScanTooltip()
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	return scanTooltip
end

--[[
    Matched against the WHOLE line, never as a substring: LOCKED is a short word,
    and other add-ons write lines that contain it without meaning it.
]]
---@param needle string
---@return boolean
local function ScanTooltipHasLine(needle)
	for lineIndex = 1, scanTooltip:NumLines() do
		local line = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		if line and line:GetText() == needle then
			return true
		end
	end
	return false
end

--[[
    Whether a bag slot's container still waits on a lock. The second return is
    the tooltip's line count, for Diagnostics' Locked Boxes probe: zero lines
    means the tooltip read nothing, which also answers "not locked", and is the
    failure to look for on a client whose tooltips build differently.
]]
---@param bagIndex number
---@param slotIndex number
---@return boolean locked
---@return number lineCount
function ns.IsItemLocked(bagIndex, slotIndex)
	local tooltip = PrepareScanTooltip()
	tooltip:SetBagItem(bagIndex, slotIndex)
	local locked = ScanTooltipHasLine(LOCKED)
	local lineCount = tooltip:NumLines()
	tooltip:Hide()
	return locked, lineCount
end

--[[
    "Does this item begin a quest", which the client says in a tooltip and
    nowhere else: no API on any target client flags it, and the item's class does
    not give it away either, since quest starters are ordinary weapons, armor and
    trinkets as often as they are class 12. Read by hyperlink, because this is
    asked of loot, which may never reach the bags at all.

    The scan is the most expensive question Loot Toasts asks, so it is also the
    last one asked.
]]
---@param itemIdentifier number|nil
---@return boolean
function ns.ItemStartsQuest(itemIdentifier)
	if not itemIdentifier then
		return false
	end
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink("item:" .. itemIdentifier)
	local startsQuest = ScanTooltipHasLine(ITEM_STARTS_QUEST)
	tooltip:Hide()
	return startsQuest
end

--[[
    An item's or spell's tooltip as plain lines, for Validate Data, a right-hand
    column kept after " >> ". kind is "item" or "spell". C_TooltipInfo hands the
    lines over as data where the client ships both its GetItemByID and
    GetSpellByID getters (WoW Forever); elsewhere they are read off the scan
    tooltip. Color escapes are stripped so each line reads as its words. A read
    can throw on an odd id, so callers protect it.
]]
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }

---@param text any
---@return string|nil
local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

---@param left any
---@param right any
---@return string
local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

---@param kind string
---@param identifier number
---@return string[]
local function ReadTooltipData(kind, identifier)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](identifier)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

---@param kind string
---@param identifier number
---@return string[]
local function ReadScanTooltip(kind, identifier)
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink(kind .. ":" .. identifier)
	local lines = {}
	for lineIndex = 1, tooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. lineIndex]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	tooltip:Hide()
	return lines
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

--[[
    An item's tooltip read from its whole link rather than its id, so a random
    suffix ("of the Owl") shows the stats it rolled, for Character Rules. Left
    lines only, color escapes stripped. C_TooltipInfo.GetHyperlink where the
    client has it (WoW Forever); the scan tooltip elsewhere.
]]
---@param itemLink string
---@return string[]
function ns.GetItemLinkTooltipLines(itemLink)
	local lines = {}
	if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
		local data = C_TooltipInfo.GetHyperlink(itemLink)
		for _, line in ipairs(data and data.lines or {}) do
			lines[#lines + 1] = PlainText(line.leftText) or ""
		end
		return lines
	end
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink(itemLink)
	for lineIndex = 1, tooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		lines[#lines + 1] = PlainText(left and left:GetText()) or ""
	end
	tooltip:Hide()
	return lines
end

--------------------------------------------------------------------------------
-- Named Timers
--------------------------------------------------------------------------------

--[[
    C_Timer.After with a cancel handle. Scheduling an identifier that is already
    pending replaces it, so a caller never has to hand-roll a guard flag to stop
    a stale callback from firing, and ns:CancelTimer kills one outright.

    The scheduled closure checks its own generation before running:
    C_Timer.After has no cancel, so a superseded or cancelled timer still fires
    and must no-op.
    Generations are globally unique rather than counted per identifier: cancelling
    forgets the identifier, so a per-identifier count would restart and let a
    cancelled timer match the generation of the one that replaced it, running the
    cancelled callback and swallowing the replacement.
]]
local scheduledTimers = {}
local timerGeneration = 0

---@param identifier string
---@param seconds number
---@param callback function
---@return nil
function ns:After(identifier, seconds, callback)
	timerGeneration = timerGeneration + 1
	local generation = timerGeneration
	scheduledTimers[identifier] = generation

	C_Timer.After(seconds, function()
		if scheduledTimers[identifier] ~= generation then
			return
		end
		scheduledTimers[identifier] = nil
		callback()
	end)
end

---@param identifier string
---@return nil
function ns:CancelTimer(identifier)
	scheduledTimers[identifier] = nil
end

---@param identifier string
---@return boolean
function ns:IsTimerPending(identifier)
	return scheduledTimers[identifier] ~= nil
end

--------------------------------------------------------------------------------
-- UI Colors
--------------------------------------------------------------------------------

--[[
    Built from the raw hex palettes in Data.lua and exposed in two forms:
      * ns.COLORS[key] -> "|cffRRGGBB" (for inline chat/string use)
      * ns.COLORS_RGB[key] -> {r, g, b} (for tooltip/texture APIs)
    Consumers should prefer ns.GetColor(key) / ns.GetColorRGB(key)
    over indexing the tables directly. These are dot functions (no self),
    so every file aliases them once — local GetColor = ns.GetColor — and
    calls GetColor("KEY"); see Style Guide → COLORS.
]]

local function HexToNormalizedRGB(hex)
	local r = tonumber(string.sub(hex, 1, 2), 16) / 255
	local g = tonumber(string.sub(hex, 3, 4), 16) / 255
	local b = tonumber(string.sub(hex, 5, 6), 16) / 255
	return r, g, b
end

ns.COLORS = {}
-- Tooltip and texture APIs take numeric colors, so COLORS_RGB mirrors the palette as r, g, b.
ns.COLORS_RGB = {}

for colorKey, hexValue in pairs(ns.PALETTE) do
	ns.COLORS[colorKey] = "|cff" .. hexValue
	local r, g, b = HexToNormalizedRGB(hexValue)
	ns.COLORS_RGB[colorKey] = { r = r, g = g, b = b }
end

---@param key string
---@return string
function ns.GetColor(key)
	return ns.COLORS[key] or ns.COLORS.TEXT
end

---@param key string
---@return number r
---@return number g
---@return number b
function ns.GetColorRGB(key)
	local rgb = ns.COLORS_RGB[key] or ns.COLORS_RGB.TEXT
	return rgb.r, rgb.g, rgb.b
end

---@param quality number
---@return string
function ns.GetQualityColor(quality)
	local hex = ns.QUALITY_COLORS[quality] or ns.QUALITY_COLORS[1]
	return "|cff" .. hex
end

local GetColorRGB = ns.GetColorRGB

--------------------------------------------------------------------------------
-- Auto Loot CVar
--------------------------------------------------------------------------------

---@return boolean
function ns:IsAutoLootCVarEnabled()
	return C_CVar.GetCVarBool("autoLootDefault")
end

--------------------------------------------------------------------------------
-- Tooltip Helpers
--------------------------------------------------------------------------------

--[[
    Thin wrappers around GameTooltip:AddLine / AddDoubleLine that accept color
    keys from ns.COLORS_RGB, so tooltip code doesn't repeat RGB literals.
    Pass nil for colorKey to use the default text color.
]]

---@param tooltip table
---@param text string
---@param colorKey string|nil
---@param wrap any
---@return nil
function ns:AddTooltipLine(tooltip, text, colorKey, wrap)
	local r, g, b = GetColorRGB(colorKey or "TEXT")
	tooltip:AddLine(text, r, g, b, wrap)
end

---@param tooltip table
---@param leftText any
---@param rightText any
---@param leftColorKey string|nil
---@param rightColorKey string|nil
---@return nil
function ns:AddTooltipDoubleLine(tooltip, leftText, rightText, leftColorKey, rightColorKey)
	local leftRed, leftGreen, leftBlue = GetColorRGB(leftColorKey or "TEXT")
	local rightRed, rightGreen, rightBlue = GetColorRGB(rightColorKey or "TEXT")
	tooltip:AddDoubleLine(leftText, rightText, leftRed, leftGreen, leftBlue, rightRed, rightGreen, rightBlue)
end

--------------------------------------------------------------------------------
-- Name / Text Helpers
--------------------------------------------------------------------------------

-- 1240 as "1,240", for Diagnostic Tools' progress and tallies.
---@param number number
---@return string
function ns:FormatCommaNumber(number)
	return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

--[[
    Canonical key for player-name comparisons: realm suffix stripped, then
    lowercased. Cross-realm members appear as "Name-Realm" in some APIs
    (GetMasterLootCandidate) and as plain "Name" in others (UnitName), so
    destinations, candidate-map lookups, and group-member lookups must all
    pass through this one helper to compare equal. A WoW Forever name
    ("Aero Bramblefoot") has no realm and no dash, so it passes through
    whole.
]]
local function StripRealmSuffix(fullName)
	if not fullName then
		return nil
	end
	local dashPosition = string.find(fullName, "-")
	if dashPosition then
		return string.sub(fullName, 1, dashPosition - 1)
	end
	return fullName
end

---@param playerName string
---@return string|nil
function ns:NormalizePlayerName(playerName)
	if not playerName or playerName == "" then
		return nil
	end
	return strlower(StripRealmSuffix(playerName))
end

--[[
    A group member's class color as a color escape ("|cffc79c6e"), while the
    roster still holds them; nil once it doesn't. The name is as a chat line
    prints it, which meets the roster's through ns:NormalizePlayerName: a realm
    suffix on a cross-realm name, the whole "First Last" on WoW Forever. Shared
    by the loot toasts' looter names and the winner summary.
]]
---@param playerName string|nil
---@return string|nil
function ns:GetGroupMemberClassColor(playerName)
	local wantedName = ns:NormalizePlayerName(playerName)
	if not wantedName then
		return nil
	end
	local unitPrefix = IsInRaid() and "raid" or "party"
	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = unitPrefix .. memberIndex
		if ns:GetLowercaseUnitName(unitIdentifier) == wantedName then
			local _, classFile = UnitClass(unitIdentifier)
			local classColor = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
			if type(classColor) == "table" and type(classColor.colorStr) == "string" then
				return "|c" .. classColor.colorStr
			end
			return nil
		end
	end
	return nil
end

--[[
    A unit's name as GogoLoot knows the player: the bare character name, or on
    WoW Forever the whole "First Last" name. Forever's UnitName returns the last
    name where other flavors return the realm ("Aero", "Bramblefoot", the
    player included), while the loot window's candidates and chat authors read
    "Aero Bramblefoot". Rejoining the two is what lets a destination picked
    from the group roster match the loot window.
]]
---@param unitIdentifier string
---@return string|nil
function ns:GetCleanUnitName(unitIdentifier)
	local name, realm = UnitName(unitIdentifier)
	if ns.FLAVOR == "Camelot" and name and realm and realm ~= "" then
		return name .. " " .. realm
	end
	return StripRealmSuffix(name)
end

---@param unitIdentifier string
---@return string|nil
function ns:GetLowercaseUnitName(unitIdentifier)
	return self:NormalizePlayerName(self:GetCleanUnitName(unitIdentifier))
end

---@param text string
---@return string
function ns:CapitalizeFirstLetter(text)
	if not text or text == "" then
		return text
	end
	return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

--[[
    How a player name is written in anything sent to chat: the bare character
    name, realm stripped. Names are stored and compared realm-stripped and
    lowercased, which is right for matching but loses the original casing, so
    this restores the leading capital of each word (a WoW Forever name has two)
    without touching the rest.

    Names go out without the realm: "Name-Realm" is noise in a same-realm
    group, which is nearly all of them. The cost is that two cross-realm
    players sharing a first name read identically in chat; the candidate
    matching still tells them apart, only the message does not.

    Nothing here decorates the name. Chat escapes colour codes into literal
    text, so how it renders is the receiving client's business.
]]
---@param playerName string
---@return string
function ns:FormatPlayerName(playerName)
	if not playerName or playerName == "" then
		return ""
	end
	local baseName = string.match(playerName, "^([^%-]+)") or playerName
	return (string.gsub(baseName, "%S+", function(word)
		return ns:CapitalizeFirstLetter(word)
	end))
end

---@param itemLink string
---@return table|nil
function ns:ParseItemLink(itemLink)
	if not itemLink then
		return nil
	end
	local itemIdentifier, itemName = string.match(itemLink, "item:(%d+).-%[([^%]]+)%]")
	if not itemIdentifier then
		return nil
	end
	return {
		itemIdentifier = tonumber(itemIdentifier),
		itemName = itemName,
	}
end

---@param itemIdentifierOrLink number|string
---@return table|nil
function ns:SafeGetItemInfo(itemIdentifierOrLink)
	if not itemIdentifierOrLink then
		return nil
	end
	local itemName, itemLink, itemQuality, _, _, _, _, _, _, _, _, classId, subclassId, bindType =
		C_Item.GetItemInfo(itemIdentifierOrLink)
	if not itemName then
		return nil
	end

	return {
		name = itemName,
		link = itemLink,
		quality = itemQuality,
		classId = classId,
		subclassId = subclassId,
		bindType = bindType,
	}
end

--[[
    Verified against a live 1.15.9 client: C_PartyInfo.GetLootMethod returns
    (method, masterLooterPartyIndex, masterLooterRaidIndex), the same shape as
    the retired global, and the party index really is 0 when the player is the
    master looter. The method is an Enum.LootMethod number there, and a string
    only from the legacy global.
]]
---@return boolean
function ns:AreWeMasterLooter()
	local method, masterLooterPartyIndex = ns:SafeCallLootMethod()
	if method == nil then
		return false
	end
	local isMasterLoot = method == "master" or method == Enum.LootMethod.Masterlooter
	return isMasterLoot and masterLooterPartyIndex == 0
end

--[[
    The absolute skips. Nothing automates a legendary, a recipe, a mount or a
    pet, and no Item Overrides entry can opt back in — listing one
    of these by item id still leaves it to the player.
]]
---@param itemInformation table
---@return boolean
function ns:IsNeverAutomatedItem(itemInformation)
	if not itemInformation then
		return true
	end

	-- Legendaries
	if itemInformation.quality == 5 then
		return true
	end
	-- Recipes, Books, Patterns, Plans, Schematics, Formulas (all classId 9)
	if itemInformation.classId == ns.ITEM_CLASS_RECIPE then
		return true
	end
	-- Mounts and Companion Pets
	if
		itemInformation.classId == ns.ITEM_CLASS_MISCELLANEOUS
		and (
			itemInformation.subclassId == ns.ITEM_SUBCLASS_COMPANION_PET
			or itemInformation.subclassId == ns.ITEM_SUBCLASS_MOUNT
		)
	then
		return true
	end

	return false
end

--[[
    Quest-class items are skipped by every path that picks items on its own,
    the roll threshold and master-loot distribution, but NOT by Item
    Overrides, which is an explicit per-item instruction from the player.

    That distinction is load-bearing rather than theoretical. The AQ and ZG
    war-effort tokens all report classId 12 with an ordinary bind type: scarabs
    (20858-20865), AQ20 idols (20866-20873), AQ40 idols (20874-20882), ZG coins
    (19698-19706), ZG bijous (19707-19715) and Wartorn scraps (22373-22376).
    Run this test ahead of the list and every one of those default entries
    becomes unreachable: correct ids, correct saved action, and no roll.
]]
---@param itemInformation table
---@return boolean
function ns:IsQuestClassItem(itemInformation)
	if not itemInformation then
		return true
	end
	return itemInformation.classId == ns.ITEM_CLASS_QUEST or itemInformation.bindType == ns.BIND_QUEST_ITEM
end

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

--[[
    C_Container.GetContainerNumFreeSlots returns freeSlots, bagFamily.

    Only general-purpose bags (bagFamily 0 or nil) count: specialty bags (soul
    bags, quivers, ammo pouches, profession bags) can't hold normal loot, so
    their free slots are useless to Speedy Loot and to Automated Opening, the
    two callers. This is deliberately conservative: loot that could stack into a
    matching specialty bag may be left in the loot window instead, where it stays
    reachable, rather than risk a count that overstates usable space.
]]
---@return number
function ns.CountFreeBagSlots()
	local totalFree = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		local freeInBag, bagFamily = C_Container.GetContainerNumFreeSlots(bagIndex)
		if freeInBag and (bagFamily == 0 or bagFamily == nil) then
			totalFree = totalFree + freeInBag
		end
	end
	return totalFree
end

--[[
    A bag slot's item ID. The ID call can come back empty for an item whose data
    the client has not loaded yet, while the slot's link already carries it.
]]
---@param bagIndex number
---@param slotIndex number
---@return number|nil
function ns.GetBagItemIdentifier(bagIndex, slotIndex)
	local itemIdentifier = C_Container.GetContainerItemID(bagIndex, slotIndex)
	if itemIdentifier then
		return itemIdentifier
	end
	local itemLink = C_Container.GetContainerItemLink(bagIndex, slotIndex)
	return itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
end

--[[
    C_Item.GetItemInfoInstant answers from the client's own database, with no
    cold-cache nil, so the icon is there the first time an item is drawn.
]]
---@param itemIdentifier number|nil
---@return number|string|nil
function ns.GetItemIconByID(itemIdentifier)
	if not itemIdentifier then
		return nil
	end
	local _, _, _, _, icon = C_Item.GetItemInfoInstant(itemIdentifier)
	return icon
end

--------------------------------------------------------------------------------
-- Bag-Full Error
--------------------------------------------------------------------------------

--[[
    All three target clients carry the inventory-full message id as the
    LE_GAME_ERR_INV_FULL global, which the API Endpoints report proves on each.
    That global is a number, so comparing anything else against it is already
    false. This is the only inventory-full test in the add-on: Automated
    Opening's handler and Diagnostics' event-log filter both classify
    UI_ERROR_MESSAGE through it, so a firing can never pause opening while the
    log files it away as noise. Never add a message-text match beside it; the
    two would disagree exactly when a bug report needs the log line.
]]
---@param errorIdentifier any
---@return boolean
function ns.IsBagFullErrorID(errorIdentifier)
	return errorIdentifier == LE_GAME_ERR_INV_FULL
end

--------------------------------------------------------------------------------
-- Client Format Strings
--------------------------------------------------------------------------------

--[[
    Turns one of the client's own format strings into a Lua pattern that
    captures what the client filled in. This is how the add-on reads the game's
    words in any locale without shipping a translation of them: LOOT_ITEM_SELF
    becomes the player's own loot line, GOLD_AMOUNT the coin count in a money
    message, ITEM_MIN_SKILL a lockbox's requirement line.

    The magic characters are escaped first, leaving % alone so the format's own
    %s and %d survive to become captures on the next two lines.
]]
---@param format any
---@return string|nil
function ns.BuildFormatPattern(format)
	if type(format) ~= "string" then
		return nil
	end
	local pattern = format:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	pattern = pattern:gsub("%%s", "(.+)")
	pattern = pattern:gsub("%%d", "(%%d+)")
	return pattern
end

--[[
    The player's own loot lines, each matched whole. The counted forms go first:
    "You receive loot: %s." would also match "[Linen Cloth]x2." and swallow the
    count into the item. Matching the full format rather than a prefix is what
    keeps this right in locales whose line doesn't end with the item, such as
    zhCN's, which closes on its own full stop.
]]
local OWN_LOOT_FORMATS = {
	{ format = LOOT_ITEM_SELF_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_PUSHED_SELF_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_SELF, counted = false },
	{ format = LOOT_ITEM_PUSHED_SELF, counted = false },
}

--[[
    Another group member's loot lines, in the same counted-first order. Every
    locale's format names the looter before the item, so the captures come back
    in that order everywhere.
]]
local GROUP_LOOT_FORMATS = {
	{ format = LOOT_ITEM_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_PUSHED_MULTIPLE, counted = true },
	{ format = LOOT_ITEM, counted = false },
	{ format = LOOT_ITEM_PUSHED, counted = false },
}

local function BuildLootPatterns(formats)
	local patterns = {}
	for _, entry in ipairs(formats) do
		local pattern = ns.BuildFormatPattern(entry.format)
		if pattern then
			patterns[#patterns + 1] = { pattern = "^" .. pattern .. "$", counted = entry.counted }
		end
	end
	return patterns
end

local ownLootPatterns = BuildLootPatterns(OWN_LOOT_FORMATS)
local groupLootPatterns = BuildLootPatterns(GROUP_LOOT_FORMATS)

--[[
    The link's color may be a hex code or, on a Retail-engine client, a named
    quality color; either way it runs from |c to the link's closing |r.
]]
local function FindItemLink(text)
	return string.match(text, "|c[^|]+|Hitem:.-|h%[.-%]|h|r")
end

--[[
    The item link out of one of the player's own loot messages, and how many
    came. Nil for anyone else's loot and for anything that is not a loot line.
]]
---@param message any
---@return string|nil itemLink
---@return number|nil quantity
function ns.ParseOwnLootMessage(message)
	if type(message) ~= "string" then
		return nil
	end
	for _, entry in ipairs(ownLootPatterns) do
		local itemText, count = string.match(message, entry.pattern)
		local itemLink = itemText and FindItemLink(itemText)
		if itemLink then
			return itemLink, entry.counted and tonumber(count) or 1
		end
	end
	return nil
end

--[[
    Who looted what out of another group member's loot line, and how many came.

    ASK ns.ParseOwnLootMessage FIRST: in zhCN the player's own line
    ("你获得了物品：%s。") also reads as a looter called 你 under the group format
    ("%s获得了物品：%s。"), so only a line that isn't the player's own may come
    here.
]]
---@param message any
---@return string|nil looterName
---@return string|nil itemLink
---@return number|nil quantity
function ns.ParseGroupLootMessage(message)
	if type(message) ~= "string" then
		return nil
	end
	for _, entry in ipairs(groupLootPatterns) do
		local looterName, itemText, count = string.match(message, entry.pattern)
		local itemLink = itemText and FindItemLink(itemText)
		if itemLink then
			return looterName, itemLink, entry.counted and tonumber(count) or 1
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Roll Messages
--------------------------------------------------------------------------------

--[[
    The game's loot-roll lines, read the way the loot lines are: from the
    client's own formats, so every locale works. Most of them open on a hidden
    "[Loot]" history link carrying a number of its own, so the matcher drops
    that link from the format and the message alike, which leaves the roll as
    the only number to find.

    Captures are read by what they hold rather than where they sit, since a
    translation may put its arguments in another order: the one carrying an
    item link is the item, the number is the roll, and the other text is the
    player.
]]
local LEADING_HISTORY_LINK = "^|H.-|h.-|h:?%s*"

---@param format any
---@param rollKind? string
---@param isSelf? boolean
---@return table|nil
local function BuildRollMatcher(format, rollKind, isSelf)
	if type(format) ~= "string" then
		return nil
	end
	format = string.gsub(format, LEADING_HISTORY_LINK, "")
	local kinds = {}
	for kind in string.gmatch(format, "%%%d*%$?([sd])") do
		kinds[#kinds + 1] = kind
	end
	local pattern = string.gsub(format, "([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	pattern = string.gsub(pattern, "%%%d+%%%$s", "(.+)")
	pattern = string.gsub(pattern, "%%%d+%%%$d", "(%%d+)")
	pattern = string.gsub(pattern, "%%s", "(.+)")
	pattern = string.gsub(pattern, "%%d", "(%%d+)")
	return { pattern = "^" .. pattern .. "$", kinds = kinds, rollKind = rollKind, isSelf = isSelf }
end

---@param entries table[] # { format, rollKind?, isSelf? }
---@return table[]
local function BuildRollMatchers(entries)
	local matchers = {}
	for _, entry in ipairs(entries) do
		local matcher = BuildRollMatcher(entry[1], entry[2], entry[3])
		if matcher then
			matchers[#matchers + 1] = matcher
		end
	end
	return matchers
end

-- Each player's roll and its number, printed while a roll is open.
local rollResultMatchers = BuildRollMatchers({
	{ LOOT_ROLL_ROLLED_NEED_ROLE_BONUS, ns.ROLL_KIND_NEED },
	{ LOOT_ROLL_ROLLED_NEED, ns.ROLL_KIND_NEED },
	{ LOOT_ROLL_ROLLED_GREED, ns.ROLL_KIND_GREED },
	{ LOOT_ROLL_ROLLED_DE, ns.ROLL_KIND_DISENCHANT },
})

--[[
    Who won. With the game's roll spam turned down it prints no roll lines at
    all, only a won line carrying the winning roll, so those forms go first: the
    plain form would match them too and lose the roll.
]]
local rollWonMatchers = BuildRollMatchers({
	{ LOOT_ROLL_YOU_WON_NO_SPAM_NEED, ns.ROLL_KIND_NEED, true },
	{ LOOT_ROLL_YOU_WON_NO_SPAM_GREED, ns.ROLL_KIND_GREED, true },
	{ LOOT_ROLL_YOU_WON_NO_SPAM_DE, ns.ROLL_KIND_DISENCHANT, true },
	{ LOOT_ROLL_WON_NO_SPAM_NEED, ns.ROLL_KIND_NEED },
	{ LOOT_ROLL_WON_NO_SPAM_GREED, ns.ROLL_KIND_GREED },
	{ LOOT_ROLL_WON_NO_SPAM_DE, ns.ROLL_KIND_DISENCHANT },
	{ LOOT_ROLL_YOU_WON, nil, true },
	{ LOOT_ROLL_WON },
})

-- The lines Hide Roll Messages keeps out of chat: every pick and every number, never who won.
local rollChatterMatchers = BuildRollMatchers({
	{ LOOT_ROLL_NEED },
	{ LOOT_ROLL_NEED_SELF },
	{ LOOT_ROLL_NEED_SELF_OFF_SPEC },
	{ LOOT_ROLL_GREED },
	{ LOOT_ROLL_GREED_SELF },
	{ LOOT_ROLL_DISENCHANT },
	{ LOOT_ROLL_DISENCHANT_SELF },
	{ LOOT_ROLL_PASSED },
	{ LOOT_ROLL_PASSED_SELF },
	{ LOOT_ROLL_PASSED_AUTO },
	{ LOOT_ROLL_PASSED_AUTO_FEMALE },
	{ LOOT_ROLL_PASSED_SELF_AUTO },
	{ LOOT_ROLL_LOST_ROLL },
})
for _, matcher in ipairs(rollResultMatchers) do
	rollChatterMatchers[#rollChatterMatchers + 1] = matcher
end

---@param matchers table[]
---@param message any
---@return table|nil # { matcher, itemLink, roll?, playerName? }
local function MatchRollLine(matchers, message)
	if type(message) ~= "string" then
		return nil
	end
	local text = (string.gsub(message, LEADING_HISTORY_LINK, ""))
	for _, matcher in ipairs(matchers) do
		-- The find allocates nothing, so only a line that matches pays for the captures table.
		local captures = string.find(text, matcher.pattern) and { string.match(text, matcher.pattern) }
		if captures and captures[1] then
			local found = { matcher = matcher }
			for index, kind in ipairs(matcher.kinds) do
				local value = captures[index]
				local itemLink = kind == "s" and not found.itemLink and FindItemLink(value)
				if kind == "d" then
					found.roll = tonumber(value)
				elseif itemLink then
					found.itemLink = itemLink
				else
					found.playerName = value
				end
			end
			if found.itemLink then
				return found
			end
		end
	end
	return nil
end

--[[
    True for a roll line that says only who picked what or rolled what. A roll
    opening prints its history link then the item alone (LOOT_ROLL_STARTED),
    which as a format is nothing but "%s", so it is recognised by that shape
    instead, and never by a pattern that would match any line with a link in
    it.
]]
---@param message any
---@return boolean
function ns.IsRollChatterMessage(message)
	if type(message) ~= "string" then
		return false
	end
	local rest = string.match(message, LEADING_HISTORY_LINK .. "(.*)$")
	if rest and rest ~= "" and FindItemLink(rest) == rest then
		return true
	end
	return MatchRollLine(rollChatterMatchers, message) ~= nil
end

---@param message any
---@return string|nil playerName
---@return string|nil rollKind # ns.ROLL_KIND_*
---@return number|nil roll
---@return string|nil itemLink
function ns.ParseRollResultMessage(message)
	local found = MatchRollLine(rollResultMatchers, message)
	if not found or not found.roll or not found.playerName then
		return nil
	end
	return found.playerName, found.matcher.rollKind, found.roll, found.itemLink
end

--[[
    Who won an item: the winner's name (nil when it was the player), then the
    item, then the winning roll where the line carries one. Only the forms
    printed with the roll spam turned down do.
]]
---@param message any
---@return boolean|nil isWon
---@return string|nil winnerName
---@return string|nil itemLink
---@return string|nil rollKind
---@return number|nil roll
function ns.ParseRollWonMessage(message)
	local found = MatchRollLine(rollWonMatchers, message)
	if not found then
		return nil
	end
	local winnerName = not found.matcher.isSelf and found.playerName or nil
	if not found.matcher.isSelf and not winnerName then
		return nil
	end
	return true, winnerName, found.itemLink, found.matcher.rollKind, found.roll
end

--------------------------------------------------------------------------------
-- Item Quality
--------------------------------------------------------------------------------

-- ns.QUALITY_COLORS read the other way: lowercase hex -> quality.
local QUALITY_BY_HEX = {}
for quality, hex in pairs(ns.QUALITY_COLORS) do
	QUALITY_BY_HEX[string.lower(hex)] = quality
end

--[[
    An item link's quality, for the loot sound and the loot toasts. The link's
    own color answers without a C_Item.GetItemInfo round trip: a hex code on
    Classic, or a named quality color ("|cnIQ4:") on a Retail-engine client.
    Anything else falls back to C_Item.GetItemInfo, which has the item cached the
    moment it is looted; nil means nobody knows, and each caller decides what
    unknown means.
]]
---@param itemLink any
---@return number|nil
function ns.GetLinkQuality(itemLink)
	if type(itemLink) ~= "string" then
		return nil
	end
	local colorSequence = string.match(itemLink, "|c(%x%x%x%x%x%x%x%x)|H")
	local quality = colorSequence and QUALITY_BY_HEX[string.lower(string.sub(colorSequence, 3))]
	if quality then
		return quality
	end
	local namedQuality = string.match(itemLink, "|cnIQ(%d+):|H")
	if namedQuality then
		return tonumber(namedQuality)
	end
	local _, _, itemQuality = C_Item.GetItemInfo(itemLink)
	return itemQuality
end

--------------------------------------------------------------------------------
-- Class
--------------------------------------------------------------------------------

---@return boolean
function ns.IsPlayerRogue()
	local _, classFile = UnitClass("player")
	return classFile == "ROGUE"
end

--[[
    Both lockbox features, the tooltip line and the looted-lockbox notice, carry
    a scope beside their toggle: "ROGUES" shows them only to a Rogue, "ALL" to
    every character. A non-Rogue can't pick a lock, so Rogues only is the
    default for both. The rule lives here so both apply the same one.
]]
---@param scope string
---@return boolean
function ns.LockboxScopeAllows(scope)
	return scope ~= "ROGUES" or ns.IsPlayerRogue()
end
