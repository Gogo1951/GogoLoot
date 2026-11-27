--------------------------------------------------------------------------------
-- GogoLoot Standard Loot Messages
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    Flipped the way Blizzard's ChatConfigFrame does, so the client saves them.
    Only the groups GogoLoot took are returned, so a player who already kept
    loot out of General keeps it out. Acts only when the wanted state changes,
    never on an ordinary login, so a box ticked back in Blizzard's window
    sticks. Chat settings are per character, hence ns.db.char.
]]
local STANDARD_LOOT_MESSAGE_GROUPS = { "LOOT", "MONEY" }
local STANDARD_LOOT_SYNC_TIMER = "GogoLoot.StandardLootSync"
local STANDARD_LOOT_SYNC_DELAY = 1

---@return table|nil # the General tab, once the client has loaded its message groups
local function GeneralChatFrame()
	if ChatFrame1 and ChatFrame1.isInitialized == 1 then
		return ChatFrame1
	end
	return nil
end

---@return boolean
local function StandardLootMessagesWanted()
	return not (ns.db.profile.lootToasts and ns.db.profile.standardLootMessages == ns.STANDARD_LOOT_MESSAGES_DISABLE)
end

---@return nil
function ns.SyncStandardLootMessages()
	local chatFrame = ns.db and GeneralChatFrame()
	if not chatFrame then
		return
	end
	local hidden = not StandardLootMessagesWanted()
	local character = ns.db.char
	if character.standardLootMessagesHidden == hidden then
		return
	end
	character.standardLootMessagesHidden = hidden
	local taken = character.lootGroupsHiddenByGogoLoot
	for _, group in ipairs(STANDARD_LOOT_MESSAGE_GROUPS) do
		local shown = chatFrame:ContainsMessageGroup(group)
		if hidden and shown then
			chatFrame:RemoveMessageGroup(group)
			taken[group] = true
		elseif not hidden and taken[group] then
			if not shown then
				chatFrame:AddMessageGroup(group)
			end
			taken[group] = nil
		end
	end
end

local function ScheduleStandardLootSync()
	ns:After(STANDARD_LOOT_SYNC_TIMER, STANDARD_LOOT_SYNC_DELAY, ns.SyncStandardLootMessages)
end

local function OnPlayerEnteringWorld()
	ScheduleStandardLootSync()
end

local function OnUpdateChatWindows()
	ScheduleStandardLootSync()
end

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("UPDATE_CHAT_WINDOWS", OnUpdateChatWindows)
