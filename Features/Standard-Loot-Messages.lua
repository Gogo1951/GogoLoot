--------------------------------------------------------------------------------
-- GogoLoot Standard Loot Messages
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    The game's own Item Loot and Money Loot checkboxes for the General chat tab
    (right-click the tab, Settings, Other), the two kinds of line the toasts
    stand in for. They are flipped the way Blizzard's ChatConfigFrame flips
    them, so the client saves them with the rest of the chat settings. Prints
    are unaffected: they go to the frame directly, not through a message group,
    and the toasts hear CHAT_MSG_LOOT and CHAT_MSG_MONEY on their own frame.

    With Enable Loot Toasts on and the dropdown beside it on Disable, GogoLoot
    takes those lines off General; with either changed back it returns them,
    but only the groups GogoLoot took, so a player who already kept loot out
    of General (a Loot tab, say) keeps it out. Chat settings are per character,
    so the marks live in ns.db.char. GogoLoot acts only when the wanted state
    changes, never on an ordinary login, so a box ticked back in Blizzard's
    window sticks. A character's first sync counts as a change.
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

ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", ScheduleStandardLootSync)
ns:RegisterModuleEvent("UPDATE_CHAT_WINDOWS", ScheduleStandardLootSync)
