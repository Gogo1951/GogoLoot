--------------------------------------------------------------------------------
-- GogoLoot Utilities
--------------------------------------------------------------------------------

--[[
    Stateless shared utilities used across feature modules and the options
    panels: the API compatibility shims, named timers, derived color tables and
    accessors, tooltip line helpers, player-name and item-link parsing, item
    lookups, and small game-state predicates.
]]
local _, ns = ...

--------------------------------------------------------------------------------
-- API Compatibility Shims
--------------------------------------------------------------------------------

--[[
    Every modern-versus-legacy API decision the add-on makes lives here, so a
    client change is a one-line edit in one file rather than a hunt through the
    feature modules. Each shim picks by AVAILABILITY, never by truthy result:
    a `(modern call) or (legacy call)` chain silently falls through to the legacy
    read whenever the modern one legitimately returns false.

    The one shim that cannot live here is Core's GetAddOnMetadata lookup: Core
    loads before Utilities and reads the version at file scope, so it keeps its
    own inline fallback.
]]

ns.GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
ns.GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
ns.GetContainerNumFreeSlots = (C_Container and C_Container.GetContainerNumFreeSlots) or GetContainerNumFreeSlots

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

local GetItemInfo = ns.GetItemInfo
local GetItemInfoInstant = ns.GetItemInfoInstant

--[[
    Loot method reads: the legacy global is gone on 1.15.9 while
    GetLootThreshold survives, so the split is per-function and neither can be
    inferred from the other.
]]
---@return string|number|nil method
---@return number|nil masterLooterPartyIndex
---@return number|nil masterLooterRaidIndex
function ns:SafeCallLootMethod()
	if type(GetLootMethod) == "function" then
		return GetLootMethod()
	end
	if C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
		return C_PartyInfo.GetLootMethod()
	end
	return nil
end

--------------------------------------------------------------------------------
-- Named Timers
--------------------------------------------------------------------------------

--[[
    C_Timer.After with a cancel handle. Scheduling an identifier that is already
    pending replaces it, so a caller never has to hand-roll a guard flag to stop
    a stale callback from firing, and ns:CancelTimer kills one outright.

    The scheduled closure checks its own generation before running: C_Timer has
    no cancel, so a superseded or cancelled timer still fires and must no-op.
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
    calls GetColor("KEY"); see the guide's GetColor Accessor section.
]]

local function HexToNormalizedRGB(hex)
	local r = tonumber(string.sub(hex, 1, 2), 16) / 255
	local g = tonumber(string.sub(hex, 3, 4), 16) / 255
	local b = tonumber(string.sub(hex, 5, 6), 16) / 255
	return r, g, b
end

ns.COLORS = {}
-- COLORS_RGB extends the guide's string-only COLORS form: tooltip/texture APIs take r, g, b numbers.
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

--[[
    Pick the API by availability, not by truthy result: a
    `(modern call) or (legacy call)` chain falls through to the legacy
    check whenever the modern API returns false (auto-loot disabled),
    silently reading the wrong source. Shared with Speedy-Loot.lua.
]]
---@return boolean
function ns:IsAutoLootCVarEnabled()
	if C_CVar and C_CVar.GetCVarBool then
		return C_CVar.GetCVarBool("autoLootDefault")
	end
	return GetCVar("autoLootDefault") == "1"
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

--[[
    Canonical key for player-name comparisons: realm suffix stripped, then
    lowercased. Cross-realm members appear as "Name-Realm" in some APIs
    (GetMasterLootCandidate) and as plain "Name" in others (UnitName), so
    destinations, candidate-map lookups, and group-member lookups must all
    pass through this one helper to compare equal.
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

---@param unitIdentifier string
---@return string|nil
function ns:GetCleanUnitName(unitIdentifier)
	return StripRealmSuffix((UnitName(unitIdentifier)))
end

---@param unitIdentifier string
---@return string|nil
function ns:GetLowercaseUnitName(unitIdentifier)
	return self:NormalizePlayerName((UnitName(unitIdentifier)))
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
    this restores the leading capital without touching the rest.

    Realm-qualified names were tried and dropped: "Name-Realm" is noise in a
    same-realm group, which is nearly all of them. The cost is that two
    cross-realm players sharing a first name read identically in chat — the
    candidate matching still tells them apart, only the message does not.

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
	return ns:CapitalizeFirstLetter(baseName)
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
		GetItemInfo(itemIdentifierOrLink)
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
    (method, masterLooterPartyIndex, masterLooterRaidIndex) — the same shape as
    the retired global — and the party index really is 0 when the player is the
    master looter. Enum.LootMethod does not exist on Era, so the numeric 2 is
    the live comparison there, not a fallback.
]]
---@return boolean
function ns:AreWeMasterLooter()
	local method, masterLooterPartyIndex = ns:SafeCallLootMethod()
	if method == nil then
		return false
	end

	local isMasterLoot = method == "master"
	if not isMasterLoot then
		local masterLootEnum = Enum and Enum.LootMethod and Enum.LootMethod.MasterLoot
		isMasterLoot = method == (masterLootEnum or 2)
	end

	return isMasterLoot and masterLooterPartyIndex == 0
end

--[[
    The absolute skips. Nothing automates a legendary, a recipe, a mount or a
    pet, and no Custom Roll List entry can opt back in — listing one of these
    by item id still leaves it to the player.
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
    Quest-class items are skipped by every path that picks items on its own —
    the roll threshold and master-loot distribution — but NOT by the Custom
    Roll List, which is an explicit per-item instruction from the player.

    That distinction is load-bearing rather than theoretical. The AQ and ZG
    war-effort tokens all report classId 12 with an ordinary bind type: scarabs
    (20858-20865), AQ20 idols (20866-20873), AQ40 idols (20874-20882), ZG coins
    (19698-19706), ZG bijous (19707-19715) and Wartorn scraps (22373-22376).
    While this test ran ahead of the list, every one of those default entries
    was unreachable — correct ids, correct saved action, and no roll.
]]
---@param itemInformation table
---@return boolean
function ns:IsQuestClassItem(itemInformation)
	if not itemInformation then
		return true
	end
	return itemInformation.classId == ns.ITEM_CLASS_QUEST or itemInformation.bindType == ns.BIND_QUEST_ITEM
end

--[[
    The full automatic skip: never-automated types plus quest-class items.
    Master-loot distribution takes the whole set, having no per-item roll
    instruction to honour; the roll path calls the two halves separately so the
    Custom Roll List can sit between them.
]]
---@param itemInformation table
---@return boolean
function ns:ShouldSkipItemByType(itemInformation)
	if not itemInformation then
		return true
	end

	return ns:IsNeverAutomatedItem(itemInformation) or ns:IsQuestClassItem(itemInformation)
end
