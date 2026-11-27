--------------------------------------------------------------------------------
-- GogoLoot Loot Sounds
--------------------------------------------------------------------------------

--[[
    Both sounds read the loot window's slots, which Speedy Loot empties, so its
    LOOT_READY handler runs ns.StampWorldLoot and ns.PlayPickPocketSound first.
]]
local _, ns = ...

local worldLootOpen = false
local worldLootClosedAt = nil
-- nil once its sound has played.
local pickPocketAt = nil

--------------------------------------------------------------------------------
-- Loot Source
--------------------------------------------------------------------------------

--[[
    Disenchanting, opening a container and the item merge arrive through the
    same loot window as a corpse; only the source GUID tells them apart.
    "unknown" is kept apart from "item" on purpose: GUIDs can arrive late, and a
    corpse not yet populated must not be taken for item loot.
]]
local function CurrentLootSource()
	local sawItem = false
	for slotIndex = 1, GetNumLootItems() do
		local sourceGuid = GetLootSourceInfo(slotIndex)
		local guidType = sourceGuid and string.match(sourceGuid, "^(%a+)")
		if guidType == "Creature" or guidType == "Vehicle" or guidType == "GameObject" then
			return "world"
		elseif guidType == "Item" then
			sawItem = true
		end
	end
	return sawItem and "item" or "unknown"
end

--[[
    Run on both LOOT_READY and LOOT_OPENED: the GUID can arrive on either.
      item    - closes outright, so a disenchant just after a corpse can't
                reuse its window.
      unknown - leaves it: one just opened must survive an empty re-read.
]]
---@return nil
function ns.StampWorldLoot()
	local source = CurrentLootSource()
	if source == "world" then
		worldLootOpen = true
	elseif source == "item" then
		worldLootOpen = false
		worldLootClosedAt = nil
	end
end

--------------------------------------------------------------------------------
-- Loot Sound
--------------------------------------------------------------------------------

-- ns.LOOT_SOUND_WINDOW covers loot lines that land just after the window closes.
---@param itemLink string
---@return nil
function ns.PlayLootSound(itemLink)
	if not ns.db.profile.lootSoundsEnabled or not ns.db.profile.lootSounds then
		return
	end
	if not worldLootOpen and not (worldLootClosedAt and GetTime() - worldLootClosedAt < ns.LOOT_SOUND_WINDOW) then
		return
	end
	local quality = ns.GetLinkQuality(itemLink)
	if quality and quality >= ns.db.profile.lootSoundThreshold then
		PlaySoundFile(ns.LOOT_SOUND_FILE, "Master")
	end
end

--------------------------------------------------------------------------------
-- Pick Pocket Sound
--------------------------------------------------------------------------------

-- The cast only ARMS the sound: picking empty pockets still fires a successful cast.
local function OnSpellcastSucceeded(unitIdentifier, _, spellIdentifier)
	-- WoW Forever can make the cast's spell secret, which can't be compared.
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return
	end
	if unitIdentifier == "player" and spellIdentifier == ns.SPELLS.PICK_POCKET then
		pickPocketAt = GetTime()
	end
end

--[[
    MUST RUN BEFORE SPEEDY LOOT: an emptied window is indistinguishable from a
    pickpocket that came up empty. Disarms as it plays, so one cast sounds once.
]]
---@return nil
function ns.PlayPickPocketSound()
	if not pickPocketAt or not ns.db or not ns.db.profile.lootSoundsEnabled or not ns.db.profile.pickPocketSound then
		return
	end
	if (GetTime() - pickPocketAt) >= ns.PICK_POCKET_LOOT_WINDOW or GetNumLootItems() == 0 then
		return
	end
	pickPocketAt = nil
	PlaySound(ns.SOUND_KIT_IDS.PICK_POCKET, "Master")
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- LOOT_READY is Speedy Loot's, which runs the same two first.
local function OnLootOpened()
	ns.StampWorldLoot()
	ns.PlayPickPocketSound()
end

local function OnLootClosed()
	if worldLootOpen then
		worldLootOpen = false
		worldLootClosedAt = GetTime()
	end
end

local function OnChatMessageLoot(message)
	local itemLink = ns.ParseOwnLootMessage(message)
	if itemLink then
		ns.PlayLootSound(itemLink)
	end
end

ns:RegisterModuleEvent("UNIT_SPELLCAST_SUCCEEDED", OnSpellcastSucceeded, "player")
ns:RegisterModuleEvent("LOOT_OPENED", OnLootOpened)
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)
ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMessageLoot)
