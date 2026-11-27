--------------------------------------------------------------------------------
-- GogoLoot Utilities
--------------------------------------------------------------------------------

local _, ns = ...

--------------------------------------------------------------------------------
-- API Compatibility Shims
--------------------------------------------------------------------------------

--[[
    Each accessor picks by AVAILABILITY, never by truthy result: a
    `(modern call) or (legacy call)` chain falls through to the legacy read
    whenever the modern one legitimately returns false.
]]

--[[
    The same error carries a different id on every flavor, and several ERR_*
    globals are unbound on 1.15.9, so message correlation matches on this
    client's ids, never on translated text.
]]
ns.GetGameMessageInfo = GetGameMessageInfo

--[[
    The count tells "this client resolved nothing" from "this client has no
    message table", which the Diagnostics report has to draw.
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
    Per function, not per client: 1.15.9 dropped the legacy GetLootMethod /
    SetLootMethod but kept GetLootThreshold / SetLootThreshold. The C_PartyInfo
    setter takes Enum.LootMethod where the legacy one takes a string.
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

-- WoW Forever runs the Retail engine, which dropped LOOT_SLOT_ITEM for Enum.LootSlotType.Item.
if Enum.LootSlotType then
	ns.LOOT_SLOT_TYPE_ITEM = Enum.LootSlotType.Item
else
	ns.LOOT_SLOT_TYPE_ITEM = LOOT_SLOT_ITEM
end

-- Classic Era and TBC Anniversary have only the legacy global, which returns the same table.
ns.GetItemStats = C_Item.GetItemStats or GetItemStats

-- WoW Forever can hand over a unit's identity as a secret in combat: it can't be compared or matched.
ns.IsSecretValue = issecretvalue or function()
	return false
end

--[[
    WoW Forever has no skill-line API, but other add-ons put look-alike globals
    back (Questie restores GetSkillLineInfo), so there it is always nil.
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
-- UI Colors
--------------------------------------------------------------------------------

local function HexToNormalizedRGB(hex)
	local r = tonumber(string.sub(hex, 1, 2), 16) / 255
	local g = tonumber(string.sub(hex, 3, 4), 16) / 255
	local b = tonumber(string.sub(hex, 5, 6), 16) / 255
	return r, g, b
end

ns.COLORS = {}
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

---@param quality number
---@return number r
---@return number g
---@return number b
function ns.GetQualityColorRGB(quality)
	return HexToNormalizedRGB(ns.QUALITY_COLORS[quality] or ns.QUALITY_COLORS[1])
end

---@param classFile string|nil
---@return string|nil
function ns.GetClassColor(classFile)
	local hex = classFile and ns.CLASS_COLORS[classFile]
	return hex and "|cff" .. hex or nil
end

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

local captionMeasure

-- GameFontNormal, a button's caption font, differs only in color, so this measures button captions too.
---@param caption string
---@return number
function ns.MeasureCaptionPixels(caption)
	if not captionMeasure then
		local measureFrame = CreateFrame("Frame")
		measureFrame:Hide()
		captionMeasure = measureFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	end
	captionMeasure:SetText(caption)
	return captionMeasure:GetStringWidth()
end

---@param number number
---@return string
function ns:FormatCommaNumber(number)
	return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

--[[
    Cross-realm members read "Name-Realm" in some APIs (GetMasterLootCandidate)
    and "Name" in others (UnitName), so every name comparison goes through
    ns:NormalizePlayerName. A WoW Forever name has no dash and passes whole.
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

-- nil once the roster no longer holds them.
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
    WoW Forever's UnitName returns the last name where other flavors return the
    realm, while loot candidates and chat authors read "First Last": rejoining
    them lets a destination picked from the roster match the loot window. A
    secret name reads as unknown (nil).
]]
---@param unitIdentifier string
---@return string|nil
function ns:GetCleanUnitName(unitIdentifier)
	local name, realm = UnitName(unitIdentifier)
	if ns.IsSecretValue(name) or ns.IsSecretValue(realm) then
		return nil
	end
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
    Stored names are lowercased, so each word's capital is restored (a WoW
    Forever name has two). The realm is dropped as noise in nearly every group;
    two cross-realm namesakes then read alike in chat, though matching still
    tells them apart.
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
	local itemName, itemLink, itemQuality, _, requiredLevel, _, _, _, equipLocation, _, _, classId, subclassId, bindType =
		C_Item.GetItemInfo(itemIdentifierOrLink)
	if not itemName then
		return nil
	end

	return {
		name = itemName,
		link = itemLink,
		quality = itemQuality,
		requiredLevel = requiredLevel,
		equipLocation = equipLocation,
		classId = classId,
		subclassId = subclassId,
		bindType = bindType,
	}
end

--[[
    Verified on 1.15.9: C_PartyInfo.GetLootMethod returns the legacy global's
    shape, the party index is 0 when the player is master looter, and the
    method is an Enum.LootMethod number (a string only from the legacy global).
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

-- Absolute: no Item Overrides entry can opt one of these back in.
---@param itemInformation table
---@return boolean
function ns:IsNeverAutomatedItem(itemInformation)
	if not itemInformation then
		return true
	end

	if itemInformation.quality == 5 then
		return true
	end
	if itemInformation.classId == ns.ITEM_CLASS_RECIPE then
		return true
	end
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
    Kept apart from ns:IsNeverAutomatedItem because Item Overrides must run
    before it: the AQ and ZG war-effort tokens on the default list report the
    quest class, and testing this first would make those entries unreachable.
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
-- The Loot Window
--------------------------------------------------------------------------------

--[[
    ElvUI and Tukui create their loot window only while their loot module is
    on, so whichever exists IS the loot window. They build it at login, after
    GogoLoot loads, so this is asked at loot time, never cached.
]]
---@return table|nil
function ns.GetLootWindow()
	for _, frameName in ipairs(ns.LOOT_WINDOW_REPLACEMENTS) do
		local frame = _G[frameName]
		if frame then
			return frame
		end
	end
	return LootFrame
end

---@return boolean
function ns.IsLootWindowShown()
	local frame = ns.GetLootWindow()
	return frame ~= nil and frame:IsShown() and true or false
end

--------------------------------------------------------------------------------
-- Class
--------------------------------------------------------------------------------

---@return boolean
function ns.IsPlayerRogue()
	local _, classFile = UnitClass("player")
	return classFile == "ROGUE"
end

---@param scope string
---@return boolean
function ns.LockboxScopeAllows(scope)
	return scope ~= "ROGUES" or ns.IsPlayerRogue()
end
