--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Money
--------------------------------------------------------------------------------

--[[
    The coin toasts: the amount read out of the game's money line, then drawn
    as one row through the stack in Features/Loot-Toasts.lua.
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
