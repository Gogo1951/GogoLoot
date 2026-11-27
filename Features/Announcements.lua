--------------------------------------------------------------------------------
-- GogoLoot Announcements Module
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Messaging
--------------------------------------------------------------------------------

--[[
    Printed: "GogoLoot // <body>", so a printed body carries its own end
    punctuation. Sent: "{rt4} <body> // GogoLoot" on every channel, so a sent
    body carries none. Announce is the only sender, and Enable Loot
    Announcements (lootNotifications) silences everything it sends.
]]

---@param text string
---@return string
function ns.BuildPrintMessage(text)
	return GetColor("INFO")
		.. L["ADDON_TITLE"]
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//"
		.. "|r "
		.. GetColor("TEXT")
		.. text
		.. "|r"
end

---@param text string
---@return nil
function ns:PrintMessage(text)
	print(ns.BuildPrintMessage(text))
end

---@param formatKey string
---@param ... any
---@return string|nil
function ns:BuildAnnounceMessage(formatKey, ...)
	local template = L[formatKey]
	if not template then
		return nil
	end
	local body = string.format(template, ...)
	-- No pipe-stripping: bodies carry item links (|Hitem...), which survive sent chat and would break if stripped.
	return ns.TARGET_MARKER .. " " .. body .. " // " .. L["ADDON_SHORT_NAME"]
end

---@param channel string|nil
---@param target string|nil
---@param formatKey string
---@param ... any
---@return nil
function ns:Announce(channel, target, formatKey, ...)
	if not channel or not ns.db.profile.lootNotifications then
		return
	end
	local message = ns:BuildAnnounceMessage(formatKey, ...)
	if not message then
		return
	end
	C_ChatInfo.SendChatMessage(message, channel, nil, target)
end

--[[
    Splits only at part boundaries: the client rejects an item link broken
    mid-escape, so a single part over ns.CHAT_MESSAGE_MAX_LENGTH is sent anyway.
    formatArguments(joinedParts) exists because templates differ in where the
    list sits.
]]
---@param channel string|nil
---@param target string|nil
---@param formatKey string
---@param parts string[]
---@param formatArguments function
---@return nil
function ns:AnnounceParts(channel, target, formatKey, parts, formatArguments)
	local startIndex = 1
	while startIndex <= #parts do
		local endIndex = startIndex
		while endIndex < #parts do
			local candidateList = table.concat(parts, ", ", startIndex, endIndex + 1)
			local candidateMessage = ns:BuildAnnounceMessage(formatKey, formatArguments(candidateList))
			if not candidateMessage or #candidateMessage > ns.CHAT_MESSAGE_MAX_LENGTH then
				break
			end
			endIndex = endIndex + 1
		end
		ns:Announce(channel, target, formatKey, formatArguments(table.concat(parts, ", ", startIndex, endIndex)))
		startIndex = endIndex + 1
	end
end

-- nil when not in a group: callers must guard or fall back.
---@return string|nil
function ns:GetGroupChatChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
	return nil
end

--------------------------------------------------------------------------------
-- Status Channel
--------------------------------------------------------------------------------

--[[
    A quiet window holds lines back across a loading screen, when a pause and
    its resume can land a second apart, and an identical line within
    ns.STATUS_REPEAT_COOLDOWN prints once. StatusPrint returns false only for a
    line the quiet window held back, which the caller still owes.
]]
local quietUntil = 0
local lastStatusText = nil
local lastStatusAt = 0

---@param seconds number
---@return nil
function ns:SetQuiet(seconds)
	local untilTimestamp = GetTime() + (seconds or 0)
	if untilTimestamp > quietUntil then
		quietUntil = untilTimestamp
	end
end

---@param text string
---@return boolean
function ns:StatusPrint(text)
	local now = GetTime()
	if now < quietUntil then
		return false
	end
	if text == lastStatusText and (now - lastStatusAt) < ns.STATUS_REPEAT_COOLDOWN then
		return true
	end
	lastStatusText, lastStatusAt = text, now
	ns:PrintMessage(text)
	return true
end

--[[
    The two Ignore notices share the stamp on purpose: a player just told Speedy
    Loot left an item behind doesn't also need telling it won't be opened.
]]
local lastAnnouncedAt = {}

---@param formatKey string
---@param itemIdentifier number
---@param itemLink string
---@return nil
function ns:AnnounceItemOnce(formatKey, itemIdentifier, itemLink)
	local now = GetTime()
	local announcedAt = lastAnnouncedAt[itemIdentifier]
	if announcedAt and (now - announcedAt) <= ns.ITEM_ANNOUNCE_COOLDOWN then
		return
	end
	lastAnnouncedAt[itemIdentifier] = now
	ns:PrintMessage(L[formatKey]:format(itemLink))
end

local function OnLoadingScreenEnabled()
	ns:SetQuiet(10)
end

local function OnLoadingScreenDisabled()
	ns:SetQuiet(3)
end

ns:RegisterModuleEvent("LOADING_SCREEN_ENABLED", OnLoadingScreenEnabled)
ns:RegisterModuleEvent("LOADING_SCREEN_DISABLED", OnLoadingScreenDisabled)

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------

local function OnPlayerLogin()
	if not ns.db or not ns.db.global.showWelcome then
		return
	end
	ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
