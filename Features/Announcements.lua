--------------------------------------------------------------------------------
-- GogoLoot Announcements Module
--------------------------------------------------------------------------------

--[[
    The PrintMessage and Announce helpers, group-channel resolution, and
    the login welcome message. Trade announcements live in
    Announcements-Trade.lua and route through Announce here.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Messaging
--------------------------------------------------------------------------------

--[[
    PrintMessage and Announce are siblings:
      * PrintMessage writes to the player's local chat frame (informational).
      * Announce sends a chat message to other players via SendChatMessage,
        pulling the body template from L[formatKey] and decorating it with
        the target marker and add-on name (style guide, MESSAGES). Every
        sent channel uses the one format:
          WHISPER/PARTY/RAID/INSTANCE_CHAT/SAY/YELL -> "{rt4} GogoLoot // <body>"
        All cross-player chat output should route through Announce so the
        marker, name, and separator are handled in one place and locale
        strings stay clean bodies.

    Announce signature:
      channel - "PARTY", "RAID", "SAY", "WHISPER", etc.
      target - whisper target name (or nil for non-whisper channels)
      formatKey - L[] key for the format string (e.g. "MESSAGE_LOOT_ANNOUNCE")
      ... - format arguments substituted via string.format

    BuildAnnounceMessage builds the same decorated message without sending,
    so callers can measure against ns.CHAT_MESSAGE_MAX_LENGTH and split long
    content at safe boundaries before announcing (see Announcements-Trade.lua).
    It takes no channel — the format is identical for every channel.
]]

function ns:PrintMessage(text)
    print(
        GetColor("INFO") ..
            L["ADDON_TITLE"] ..
                "|r " .. GetColor("SEPARATOR") .. "//" .. "|r " .. GetColor("TEXT") .. text .. "|r"
    )
end

function ns:BuildAnnounceMessage(formatKey, ...)
    local template = L[formatKey]
    if not template then
        return nil
    end
    local body = string.format(template, ...)
    -- Deviation from the guide's helpers: no gsub("|", "") pipe-stripping — bodies legitimately carry item links (|Hitem...), which are legal in outbound chat.
    return ns.TARGET_MARKER .. " " .. L["ADDON_TITLE"] .. " // " .. body
end

function ns:Announce(channel, target, formatKey, ...)
    if not channel then
        return
    end
    local message = ns:BuildAnnounceMessage(formatKey, ...)
    if not message then
        return
    end
    SendChatMessage(message, channel, nil, target)
end

--[[
    Returns nil when not in a group — callers must guard or fall back
    (the trade announcement path in Announcements-Trade.lua whispers the
    trade partner instead).
]]
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
-- Welcome Message
--------------------------------------------------------------------------------

local function PrintWelcome()
    if not ns.db or not ns.db.profile.showWelcome then
        return
    end
    ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
end

ns:RegisterModuleEvent("PLAYER_LOGIN", PrintWelcome)