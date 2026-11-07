--------------------------------------------------------------------------------
-- GogoLoot Utilities — Chat Lines
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Client Format Strings
--------------------------------------------------------------------------------

--[[
    Swaps an escaped format's placeholders, numbered or not, for captures. Each
    goes through a stand-in byte first, so a capture already written, (%d+),
    is never read as a %d still to replace.
]]
---@param escapedFormat string
---@return string
local function PlaceholdersToCaptures(escapedFormat)
	local pattern = escapedFormat:gsub("%%%d+%%%$s", "\1")
	pattern = pattern:gsub("%%%d+%%%$d", "\2")
	pattern = pattern:gsub("%%s", "\1")
	pattern = pattern:gsub("%%d", "\2")
	pattern = pattern:gsub("\1", "(.+)")
	pattern = pattern:gsub("\2", "(%%d+)")
	return pattern
end

--[[
    Turns one of the client's own format strings into a Lua pattern that
    captures what the client filled in. This is how the add-on reads the game's
    words in any locale without shipping a translation of them: LOOT_ITEM_SELF
    becomes the player's own loot line, GOLD_AMOUNT the coin count in a money
    message, ITEM_MIN_SKILL a lockbox's requirement line.

    The magic characters are escaped first, leaving % alone so the format's own
    %s and %d survive to become captures. A translation may number its
    arguments ("%2$s ... %1$s") to put them in another order, so the second
    return lists, capture by capture, which argument each one is.
]]
---@param format any
---@return string|nil pattern
---@return number[]|nil argumentOrder # the argument number of each capture, in capture order
function ns.BuildFormatPattern(format)
	if type(format) ~= "string" then
		return nil
	end
	local argumentOrder = {}
	for position in string.gmatch(format, "%%(%d*)%$?[sd]") do
		argumentOrder[#argumentOrder + 1] = tonumber(position) or (#argumentOrder + 1)
	end
	local escapedFormat = format:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	return PlaceholdersToCaptures(escapedFormat), argumentOrder
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

-- Another group member's loot lines, in the same counted-first order.
local GROUP_LOOT_FORMATS = {
	{ format = LOOT_ITEM_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_PUSHED_MULTIPLE, counted = true },
	{ format = LOOT_ITEM, counted = false },
	{ format = LOOT_ITEM_PUSHED, counted = false },
}

local function BuildLootPatterns(formats)
	local patterns = {}
	for _, entry in ipairs(formats) do
		local pattern, argumentOrder = ns.BuildFormatPattern(entry.format)
		if pattern then
			patterns[#patterns + 1] =
				{ pattern = "^" .. pattern .. "$", order = argumentOrder, counted = entry.counted }
		end
	end
	return patterns
end

--[[
    A loot line's captures in the format's own argument order, whatever order
    the translation prints them in; nil when the line doesn't match. The find
    allocates nothing, so only a matching line pays for the tables.
]]
local function MatchLootLine(entry, message)
	if not string.find(message, entry.pattern) then
		return nil
	end
	local captures = { string.match(message, entry.pattern) }
	local byArgument = {}
	for index, argument in ipairs(entry.order) do
		byArgument[argument] = captures[index]
	end
	return byArgument
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
		local arguments = MatchLootLine(entry, message)
		local itemLink = arguments and arguments[1] and FindItemLink(arguments[1])
		if itemLink then
			return itemLink, entry.counted and tonumber(arguments[2]) or 1
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
		local arguments = MatchLootLine(entry, message)
		local itemLink = arguments and arguments[2] and FindItemLink(arguments[2])
		if itemLink then
			return arguments[1], itemLink, entry.counted and tonumber(arguments[3]) or 1
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
    the only number to find. The link itself names the roll, two copies of one
    item apart, so the matcher hands it back too.

    Captures are read by what they hold rather than where they sit, since a
    translation may put its arguments in another order: the one carrying an
    item link is the item, the number is the roll, and the other text is the
    player.
]]
local LEADING_HISTORY_LINK = "^|H.-|h.-|h:?%s*"
local AFTER_LEADING_HISTORY_LINK = LEADING_HISTORY_LINK .. "(.*)$"
local HISTORY_LINK_CAPTURE = "^(|H.-|h.-|h)"

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
	local pattern = PlaceholdersToCaptures((string.gsub(format, "([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")))
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
---@return table|nil # { matcher, itemLink, roll?, playerName?, historyLink? }
local function MatchRollLine(matchers, message)
	if type(message) ~= "string" then
		return nil
	end
	local text = (string.gsub(message, LEADING_HISTORY_LINK, ""))
	for _, matcher in ipairs(matchers) do
		-- The find allocates nothing, so only a line that matches pays for the captures table.
		local captures = string.find(text, matcher.pattern) and { string.match(text, matcher.pattern) }
		if captures and captures[1] then
			local found = { matcher = matcher, historyLink = string.match(message, HISTORY_LINK_CAPTURE) }
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
	local rest = string.match(message, AFTER_LEADING_HISTORY_LINK)
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
---@return string|nil historyLink # the roll's own "[Loot]" link, where the line carries one
function ns.ParseRollResultMessage(message)
	local found = MatchRollLine(rollResultMatchers, message)
	if not found or not found.roll or not found.playerName then
		return nil
	end
	return found.playerName, found.matcher.rollKind, found.roll, found.itemLink, found.historyLink
end

--[[
    Who won an item: the winner's name (nil when it was the player), then the
    item, then the winning roll where the line carries one (only the forms
    printed with the roll spam turned down do), then the roll's own "[Loot]"
    link where the line carries one.
]]
---@param message any
---@return boolean|nil isWon
---@return string|nil winnerName
---@return string|nil itemLink
---@return string|nil rollKind
---@return number|nil roll
---@return string|nil historyLink
function ns.ParseRollWonMessage(message)
	local found = MatchRollLine(rollWonMatchers, message)
	if not found then
		return nil
	end
	local winnerName = not found.matcher.isSelf and found.playerName or nil
	if not found.matcher.isSelf and not winnerName then
		return nil
	end
	return true, winnerName, found.itemLink, found.matcher.rollKind, found.roll, found.historyLink
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
