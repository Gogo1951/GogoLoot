--------------------------------------------------------------------------------
-- GogoLoot Announcements Module
--------------------------------------------------------------------------------

--[[
    The PrintMessage and Announce helpers, group-channel resolution, the
    status channel Automated Opening prints through, and the login welcome
    message. Trade announcements live in Announcements-Trade.lua and route
    through Announce here.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Messaging
--------------------------------------------------------------------------------

--[[
    PrintMessage and Announce are siblings:
      * PrintMessage writes to the player's local chat frame (informational),
        add-on name first, in the branded colors:
          "GogoLoot // <body>"
        The body ends the line, so it carries its own end punctuation.
      * Announce sends a chat message to other players via SendChatMessage,
        pulling the body template from L[formatKey] and decorating it with
        the target marker and add-on name. Every channel GogoLoot sends to
        uses the one format, on every flavor:
          WHISPER/PARTY/RAID/INSTANCE_CHAT -> "{rt4} <body> // GogoLoot"
        The name follows the body, so sent bodies carry no end punctuation.
        All cross-player chat output should route through Announce so the
        marker, name, and separator are handled in one place and locale
        strings stay clean bodies. It also enforces Enable Announcements
        (lootNotifications) for everything sent: with the master switch off,
        Announce sends nothing, whoever calls it, hand-outs and failure reports
        included.

    Announce signature:
      channel - "WHISPER", "PARTY", "RAID" or "INSTANCE_CHAT"
      target - whisper target name (or nil for non-whisper channels)
      formatKey - L[] key for the format string (e.g. "MESSAGE_GAVE")
      ... - format arguments substituted via string.format

    BuildAnnounceMessage builds the same decorated message without sending,
    so callers can measure against ns.CHAT_MESSAGE_MAX_LENGTH and split long
    content at safe boundaries before announcing (see ns:AnnounceParts).
    It takes no channel: the format is the same on every channel GogoLoot
    sends to.
]]

---@param text string
---@return nil
function ns:PrintMessage(text)
	print(
		GetColor("INFO")
			.. L["ADDON_TITLE"]
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//"
			.. "|r "
			.. GetColor("TEXT")
			.. text
			.. "|r"
	)
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
	-- No pipe-stripping: bodies carry item links (|Hitem...), which survive SendChatMessage and would break if stripped.
	return ns.TARGET_MARKER .. " " .. body .. " // " .. L["ADDON_TITLE"]
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
	SendChatMessage(message, channel, nil, target)
end

--[[
    Sends a list of parts (item links with counts, an enchant, money) as one or
    more announcements, packing as many parts into each message as fit within
    ns.CHAT_MESSAGE_MAX_LENGTH. Splits only at part boundaries, since an item
    link broken mid-escape is rejected by the client, and repeats the template
    so every message reads as a complete announcement. A single part over the
    limit on its own is sent anyway: it cannot be shortened without destroying
    the link. formatArguments(joinedParts) returns the template's arguments in
    order, because templates differ in where the list sits.
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

--[[
    Returns nil when not in a group — callers must guard or fall back
    (the trade announcement path in Announcements-Trade.lua whispers the
    trade partner instead).
]]
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
    Automated Opening's pause, resume and inventory-full lines go through here
    rather than straight to PrintMessage, for two reasons. A quiet window holds
    them back across a loading screen and the moments after, when bags and group
    state churn and a pause and its resume can land a second apart. And an
    identical line within ns.STATUS_REPEAT_COOLDOWN prints once.
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
---@return nil
function ns:StatusPrint(text)
	local now = GetTime()
	if now < quietUntil then
		return
	end
	if text == lastStatusText and (now - lastStatusAt) < ns.STATUS_REPEAT_COOLDOWN then
		return
	end
	lastStatusText, lastStatusAt = text, now
	ns:PrintMessage(text)
end

--[[
    One notice per item per ns.ITEM_ANNOUNCE_COOLDOWN. The two Ignore notices
    share the stamp on purpose: a player just told Speedy Loot left an item
    behind doesn't also need telling it won't be opened.
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
