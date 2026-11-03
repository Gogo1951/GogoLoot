--------------------------------------------------------------------------------
-- GogoLoot Utilities
--------------------------------------------------------------------------------

--[[
    Shared utilities used across feature modules and the options panels: the
    API compatibility shims, named timers, derived color tables and accessors,
    tooltip line helpers, player-name and item-link parsing, item lookups, bag
    space, and small game-state predicates. The scan tooltip lives in
    Utilities-Scan-Tooltip.lua, and the client's own format strings, the chat
    lines read with them and link quality live in Utilities-Chat-Lines.lua.
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

--[[
    A skill line's current rank, found by its name in the player's language, or
    nil when it can't be read. Resolved once, here. WoW Forever has no
    skill-line API, and other add-ons put look-alike globals back there
    (Questie restores GetSkillLineInfo), so on Forever it is always nil, and a
    skill count that isn't a number reads as unknown on every client.
]]
local SkillLineRankByName = function()
	return nil
end
if ns.FLAVOR ~= "Camelot" and GetNumSkillLines and GetSkillLineInfo then
	SkillLineRankByName = function(skillName)
		local skillCount = GetNumSkillLines()
		if type(skillCount) ~= "number" then
			return nil
		end
		for skillIndex = 1, skillCount do
			local lineName, isHeader, _, rank = GetSkillLineInfo(skillIndex)
			if not isHeader and lineName == skillName then
				return rank
			end
		end
		return nil
	end
end

---@param skillName string|nil
---@return number|nil
function ns.GetSkillLineRankByName(skillName)
	if not skillName then
		return nil
	end
	return SkillLineRankByName(skillName)
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

-- A class's color escape from its token ("WARRIOR"), or nil for a token ns.CLASS_COLORS doesn't hold.
---@param classFile string|nil
---@return string|nil
function ns.GetClassColor(classFile)
	local hex = classFile and ns.CLASS_COLORS[classFile]
	return hex and "|cff" .. hex or nil
end

-- A coin's color escape (ns.MONEY_PALETTE: GOLD, SILVER or COPPER).
---@param key string
---@return string
function ns.GetMoneyColor(key)
	return "|cff" .. (ns.MONEY_PALETTE[key] or ns.PALETTE.TEXT)
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
			return ns.GetClassColor(classFile)
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
