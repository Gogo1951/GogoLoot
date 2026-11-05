--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Money and Currency
--------------------------------------------------------------------------------

--[[
    The coin toasts: the amount read out of the game's money line, then drawn
    as one row through the stack in Features/Loot-Toasts.lua. And the currency
    toasts (Justice Points, Valor Points), from the game's currency line.
]]
local _, ns = ...
local GetColor = ns.GetColor

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

--[[
    One coin: the amount in body white, then its unit in that coin's own color,
    so a stack of these lines its numbers up as one white column and the eye
    reads the unit off the color. The symbol is the client's own, so it reads
    right in a locale that doesn't call them gold, silver and copper.
]]
local function Coin(amount, digits, symbol, colorKey)
	return GetColor("BODY") .. string.format(digits, amount) .. "|r" .. ns.GetMoneyColor(colorKey) .. symbol .. "|r"
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
	ns.PushLootToast(MoneyIcon(copper), FormatMoney(copper))
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
    With the loot window hidden, the chat line this event carries is the only
    record of coin, and the amount comes back out of that sentence.
]]
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

--[[
    The player's own currency lines, matched whole through the client's own
    formats like the item loot lines, counted forms first ("%s x%d." would
    otherwise read as "%s." with the count swallowed into the link). The bonus
    form adds a suffix after the count.
]]
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

--[[
    The currency link out of the player's own currency line, and how many came.
    A line no format matches but that still carries a currency link counts as
    one, so a client wording the line its own way still gets a toast.
]]
---@param message any
---@return string|nil currencyLink
---@return number|nil quantity
function ns.ParseCurrencyMessage(message)
	if type(message) ~= "string" then
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

--[[
    The currency's own icon and quality, from C_CurrencyInfo. The quality
    colors the icon's frame like an item's; a currency the client can't
    describe gets the question-mark icon and an uncolored frame.
]]
local function CurrencyLook(currencyIdentifier)
	local info = currencyIdentifier and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(currencyIdentifier)
	if type(info) ~= "table" then
		return ns.LOOT_WINDOW_QUESTION_ICON, nil
	end
	return info.iconFileID or ns.LOOT_WINDOW_QUESTION_ICON, info.quality
end

--[[
    Like coin, currency has no item behind it, so no item-type row has an
    opinion: it answers to the Currency row's Mine box alone. The game reports
    only the player's own currency, so there is no Group box. The link stays a
    link, so hovering the row shows the currency's own tooltip.
]]
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
