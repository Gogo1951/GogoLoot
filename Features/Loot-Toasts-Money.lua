--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Money and Currency
--------------------------------------------------------------------------------

local _, ns = ...
local GetColor = ns.GetColor

local goldPattern = ns.BuildFormatPattern(GOLD_AMOUNT)
local silverPattern = ns.BuildFormatPattern(SILVER_AMOUNT)
local copperPattern = ns.BuildFormatPattern(COPPER_AMOUNT)

-- The client hands over the sentence, not the number; its own formats read it in every locale.
---@param message any
---@return number
function ns.ParseMoney(message)
	if type(message) ~= "string" or ns.IsSecretValue(message) then
		return 0
	end
	local gold = goldPattern and tonumber(string.match(message, goldPattern)) or 0
	local silver = silverPattern and tonumber(string.match(message, silverPattern)) or 0
	local copper = copperPattern and tonumber(string.match(message, copperPattern)) or 0
	return (gold * ns.COPPER_PER_GOLD) + (silver * ns.COPPER_PER_SILVER) + copper
end

local function Coin(amount, digits, symbol, colorKey)
	return GetColor("BODY") .. string.format(digits, amount) .. "|r" .. ns.GetMoneyColor(colorKey) .. symbol .. "|r"
end

-- "123g 02s 27c": lower units padded so stacked toasts line up; no leading "0g".
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

local function MoneyIcon(copper)
	if copper >= ns.COPPER_PER_GOLD then
		return ns.MONEY_ICON_GOLD
	end
	if copper >= ns.COPPER_PER_SILVER then
		return ns.MONEY_ICON_SILVER
	end
	return ns.MONEY_ICON_COPPER
end

---@param copper number
---@return nil
function ns.ShowMoneyToast(copper)
	if not copper or copper <= 0 or not ns.db or not ns.db.profile.lootToasts then
		return
	end
	if not ns.db.profile.lootToastMine.MONEY then
		return
	end
	ns.PushLootToast(MoneyIcon(copper), FormatMoney(copper))
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnChatMessageMoney(message)
	if not ns.db.profile.lootToasts then
		return
	end
	ns.ShowMoneyToast(ns.ParseMoney(message))
end

ns:RegisterModuleEvent("CHAT_MSG_MONEY", OnChatMessageMoney)

--------------------------------------------------------------------------------
-- Currency
--------------------------------------------------------------------------------

-- Counted forms first: "%s x%d." would otherwise read as "%s." with the count swallowed.
local CURRENCY_FORMATS = {
	{ format = CURRENCY_GAINED_MULTIPLE_BONUS, counted = true },
	{ format = CURRENCY_GAINED_MULTIPLE, counted = true },
	{ format = CURRENCY_GAINED, counted = false },
}

local currencyPatterns = {}
for _, entry in ipairs(CURRENCY_FORMATS) do
	local pattern, argumentOrder = ns.BuildFormatPattern(entry.format)
	if pattern then
		currencyPatterns[#currencyPatterns + 1] =
			{ pattern = "^" .. pattern .. "$", order = argumentOrder, counted = entry.counted }
	end
end

local function FindCurrencyLink(text)
	return string.match(text, "|c[^|]+|Hcurrency:%d+.-|h%[.-%]|h|r")
end

-- A line no format matches but carrying a currency link counts as one, for a client worded its own way.
---@param message any
---@return string|nil currencyLink
---@return number|nil quantity
function ns.ParseCurrencyMessage(message)
	if type(message) ~= "string" or ns.IsSecretValue(message) then
		return nil
	end
	for _, entry in ipairs(currencyPatterns) do
		if string.find(message, entry.pattern) then
			local captures = { string.match(message, entry.pattern) }
			local byArgument = {}
			for index, argument in ipairs(entry.order) do
				byArgument[argument] = captures[index]
			end
			local link = byArgument[1] and FindCurrencyLink(byArgument[1])
			if link then
				return link, entry.counted and tonumber(byArgument[2]) or 1
			end
		end
	end
	local link = FindCurrencyLink(message)
	if link then
		return link, 1
	end
	return nil
end

local function CurrencyLook(currencyIdentifier)
	local info = currencyIdentifier and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(currencyIdentifier)
	if type(info) ~= "table" then
		return ns.QUESTION_MARK_ICON, nil
	end
	return info.iconFileID or ns.QUESTION_MARK_ICON, info.quality
end

-- The game reports only the player's own currency, so there is no Group box.
---@param currencyLink string
---@param quantity number|nil
---@return nil
function ns.ShowCurrencyToast(currencyLink, quantity)
	if not currencyLink or not ns.db or not ns.db.profile.lootToasts then
		return
	end
	if not ns.db.profile.lootToastMine.CURRENCY then
		return
	end
	local currencyIdentifier = tonumber(string.match(currencyLink, "currency:(%d+)"))
	local icon, quality = CurrencyLook(currencyIdentifier)
	local text = string.gsub(currencyLink, "|h%[(.-)%]|h", "|h%1|h")
	local count = quantity or 1
	if count > 1 then
		text = text .. " " .. ns.L["ITEM_QUANTITY"]:format(count)
	end
	ns.PushLootToast(icon, text, currencyLink, nil, nil, quality)
end

local function OnChatMessageCurrency(message)
	if not ns.db.profile.lootToasts then
		return
	end
	ns.ShowCurrencyToast(ns.ParseCurrencyMessage(message))
end

ns:RegisterModuleEvent("CHAT_MSG_CURRENCY", OnChatMessageCurrency)
