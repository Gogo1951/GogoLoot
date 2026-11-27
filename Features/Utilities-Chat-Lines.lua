--------------------------------------------------------------------------------
-- GogoLoot Utilities — Chat Lines
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    Every chat-line reader returns nothing for a secret line: WoW Forever can
    hand one over that passes the string check but can't be matched.
]]

--------------------------------------------------------------------------------
-- Client Format Strings
--------------------------------------------------------------------------------

-- Stand-in bytes first, so a capture already written, (%d+), is never read as a %d still to replace.
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
    Reads the game's words in any locale from its own format strings. A
    translation may number its arguments ("%2$s ... %1$s") to reorder them,
    hence the argument order beside the pattern.
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
    Counted forms first: "You receive loot: %s." would also match
    "[Linen Cloth]x2." and swallow the count. Each is matched whole, not as a
    prefix, for locales whose line doesn't end with the item (zhCN).
]]
local OWN_LOOT_FORMATS = {
	{ format = LOOT_ITEM_SELF_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_PUSHED_SELF_MULTIPLE, counted = true },
	{ format = LOOT_ITEM_SELF, counted = false },
	{ format = LOOT_ITEM_PUSHED_SELF, counted = false },
}

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

-- The find allocates nothing, so only a matching line pays for the tables.
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
    Every loot-line feature handles the same CHAT_MSG_LOOT, so each parser
    memoizes its last line. A secret line is turned away before the memo.
]]
local lastOwnMessage, lastOwnLink, lastOwnQuantity
local lastGroupMessage, lastGroupLooter, lastGroupLink, lastGroupQuantity

---@param message string
---@return string|nil itemLink
---@return number|nil quantity
local function MatchOwnLootLine(message)
	for _, entry in ipairs(ownLootPatterns) do
		local arguments = MatchLootLine(entry, message)
		local itemLink = arguments and arguments[1] and FindItemLink(arguments[1])
		if itemLink then
			return itemLink, entry.counted and tonumber(arguments[2]) or 1
		end
	end
	return nil
end

---@param message any
---@return string|nil itemLink
---@return number|nil quantity
function ns.ParseOwnLootMessage(message)
	if type(message) ~= "string" or ns.IsSecretValue(message) then
		return nil
	end
	if message ~= lastOwnMessage then
		lastOwnMessage = message
		lastOwnLink, lastOwnQuantity = MatchOwnLootLine(message)
	end
	return lastOwnLink, lastOwnQuantity
end

---@param message string
---@return string|nil looterName
---@return string|nil itemLink
---@return number|nil quantity
local function MatchGroupLootLine(message)
	for _, entry in ipairs(groupLootPatterns) do
		local arguments = MatchLootLine(entry, message)
		local itemLink = arguments and arguments[2] and FindItemLink(arguments[2])
		if itemLink then
			return arguments[1], itemLink, entry.counted and tonumber(arguments[3]) or 1
		end
	end
	return nil
end

--[[
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
	if type(message) ~= "string" or ns.IsSecretValue(message) then
		return nil
	end
	if message ~= lastGroupMessage then
		lastGroupMessage = message
		lastGroupLooter, lastGroupLink, lastGroupQuantity = MatchGroupLootLine(message)
	end
	return lastGroupLooter, lastGroupLink, lastGroupQuantity
end

--------------------------------------------------------------------------------
-- Roll Messages
--------------------------------------------------------------------------------

--[[
    Most roll lines open on a hidden "[Loot]" history link carrying a number of
    its own, so it is dropped from format and message alike, leaving the roll
    the only number. The link tells two copies of one item apart, so it is
    handed back too. Captures are read by what they hold, not where they sit,
    since a translation may reorder them.
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

local rollResultMatchers = BuildRollMatchers({
	{ LOOT_ROLL_ROLLED_NEED_ROLE_BONUS, ns.ROLL_KIND_NEED },
	{ LOOT_ROLL_ROLLED_NEED, ns.ROLL_KIND_NEED },
	{ LOOT_ROLL_ROLLED_GREED, ns.ROLL_KIND_GREED },
	{ LOOT_ROLL_ROLLED_DE, ns.ROLL_KIND_DISENCHANT },
})

--[[
    With roll spam turned down the game prints only a won line carrying the
    roll, so those forms go first: the plain form would match them and lose it.
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

local lastRollMessages, lastRollAnswers = {}, {}

---@param matchers table[]
---@param message string
---@return table|nil
local function FindRollLine(matchers, message)
	local text = (string.gsub(message, LEADING_HISTORY_LINK, ""))
	for _, matcher in ipairs(matchers) do
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

---@param matchers table[]
---@param message any
---@return table|nil # { matcher, itemLink, roll?, playerName?, historyLink? }, shared: read it, never change it
local function MatchRollLine(matchers, message)
	if type(message) ~= "string" or ns.IsSecretValue(message) then
		return nil
	end
	if lastRollMessages[matchers] ~= message then
		lastRollMessages[matchers] = message
		lastRollAnswers[matchers] = FindRollLine(matchers, message)
	end
	return lastRollAnswers[matchers]
end

--[[
    A roll opening (LOOT_ROLL_STARTED) is nothing but "%s" as a format, so it is
    recognized by its shape, never by a pattern that would match any link line.
]]
---@param message any
---@return boolean
function ns.IsRollChatterMessage(message)
	if type(message) ~= "string" or ns.IsSecretValue(message) then
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

-- winnerName is nil when it was the player; roll only on the forms printed with roll spam turned down.
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

-- The player's own forms first: the plain form would read "You" as a name.
local rollPassMatchers = BuildRollMatchers({
	{ LOOT_ROLL_PASSED_SELF, nil, true },
	{ LOOT_ROLL_PASSED_SELF_AUTO, nil, true },
	{ LOOT_ROLL_PASSED_AUTO },
	{ LOOT_ROLL_PASSED_AUTO_FEMALE },
	{ LOOT_ROLL_PASSED },
})

local rollAllPassedMatchers = BuildRollMatchers({ { LOOT_ROLL_ALL_PASSED } })

--[[
    ASK ns.ParseRollAllPassedMessage FIRST: "Everyone passed on: %s" also reads
    as a player called Everyone under the plain pass form.
]]
---@param message any
---@return boolean|nil isPass
---@return string|nil playerName
---@return string|nil itemLink
---@return string|nil historyLink
function ns.ParseRollPassMessage(message)
	local found = MatchRollLine(rollPassMatchers, message)
	if not found then
		return nil
	end
	local playerName = not found.matcher.isSelf and found.playerName or nil
	if not found.matcher.isSelf and not playerName then
		return nil
	end
	return true, playerName, found.itemLink, found.historyLink
end

---@param message any
---@return string|nil itemLink
---@return string|nil historyLink
function ns.ParseRollAllPassedMessage(message)
	local found = MatchRollLine(rollAllPassedMatchers, message)
	if not found or found.playerName then
		return nil
	end
	return found.itemLink, found.historyLink
end

--------------------------------------------------------------------------------
-- A /roll
--------------------------------------------------------------------------------

-- Only CHAT_MSG_SYSTEM is trusted: anyone can type "Aero rolls 100 (1-100)" in normal chat.
local rollPattern, rollArgumentOrder = ns.BuildFormatPattern(RANDOM_ROLL_RESULT)
if rollPattern then
	rollPattern = "^" .. rollPattern .. "$"
end

---@param message any
---@return string|nil playerName
---@return number|nil roll
---@return number|nil low
---@return number|nil high
function ns.ParseRandomRollMessage(message)
	if not rollPattern or type(message) ~= "string" or ns.IsSecretValue(message) then
		return nil
	end
	if not string.find(message, rollPattern) then
		return nil
	end
	local captures = { string.match(message, rollPattern) }
	local byArgument = {}
	for index, argument in ipairs(rollArgumentOrder) do
		byArgument[argument] = captures[index]
	end
	local roll, low, high = tonumber(byArgument[2]), tonumber(byArgument[3]), tonumber(byArgument[4])
	if not byArgument[1] or not roll then
		return nil
	end
	return byArgument[1], roll, low, high
end

--------------------------------------------------------------------------------
-- The Trade Clock
--------------------------------------------------------------------------------

--[[
    A duration format's plural forms spelled out: "%d |4hour:hrs;" becomes
    "%d hour" and "%d hrs". ruRU's three forms come out as three.
]]
---@param format string
---@return string[]
local function ExpandPluralForms(format)
	local before, forms, after = string.match(format, "^(.-)|4([^;]*);(.*)$")
	if not before then
		return { format }
	end
	local expanded = {}
	for form in string.gmatch(forms .. ":", "([^:]*):") do
		for _, rest in ipairs(ExpandPluralForms(after)) do
			expanded[#expanded + 1] = before .. form .. rest
		end
	end
	return expanded
end

-- Longest form first, so "hours" is tried before "hour".
local DURATION_UNITS = {}
for _, unit in ipairs({
	{ format = INT_SPELL_DURATION_HOURS, seconds = 3600 },
	{ format = INT_SPELL_DURATION_MIN, seconds = 60 },
	{ format = INT_SPELL_DURATION_SEC, seconds = 1 },
}) do
	if type(unit.format) == "string" then
		local patterns = {}
		for _, form in ipairs(ExpandPluralForms(unit.format)) do
			patterns[#patterns + 1] = (ns.BuildFormatPattern(form))
		end
		table.sort(patterns, function(a, b)
			return #a > #b
		end)
		DURATION_UNITS[#DURATION_UNITS + 1] = { patterns = patterns, seconds = unit.seconds }
	end
end

local tradeLinePattern = ns.BuildFormatPattern(BIND_TRADE_TIME_REMAINING)
if tradeLinePattern then
	tradeLinePattern = "^" .. tradeLinePattern .. "$"
end

-- The tooltip counts in whole minutes, so this is right to within a minute.
---@param line any
---@return number|nil
function ns.ParseTradeTimeLine(line)
	if not tradeLinePattern or type(line) ~= "string" then
		return nil
	end
	local duration = string.match(line, tradeLinePattern)
	if not duration then
		return nil
	end
	local seconds, matched = 0, false
	for _, unit in ipairs(DURATION_UNITS) do
		for _, pattern in ipairs(unit.patterns) do
			local amount = tonumber(string.match(duration, pattern))
			if amount then
				seconds = seconds + amount * unit.seconds
				matched = true
				break
			end
		end
	end
	return matched and seconds or nil
end

--------------------------------------------------------------------------------
-- Item Quality
--------------------------------------------------------------------------------

local QUALITY_BY_HEX = {}
for quality, hex in pairs(ns.QUALITY_COLORS) do
	QUALITY_BY_HEX[string.lower(hex)] = quality
end

--[[
    The link's color answers without an item lookup: a hex code on Classic, a
    named quality ("|cnIQ4:") on a Retail-engine client. nil means unknown, and
    each caller decides what that means.
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
