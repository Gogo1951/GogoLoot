--------------------------------------------------------------------------------
-- GogoLoot Loot Sounds
--------------------------------------------------------------------------------

--[[
    A chime for loot at or above the player's chosen quality from a corpse or
    chest, and the bag-grab sound for a Pick Pocket that actually took
    something. Speedy Loot hides the loot window, so these, with the loot
    toasts, are how the player hears what just came in. Each answers to its
    own toggle alone, on the Loot Sounds panel.

    Both read the loot window's slots, which Speedy Loot empties, so Speedy
    Loot's own LOOT_READY handler runs ns.StampWorldLoot and
    ns.PlayPickPocketSound before it takes anything (Features/Speedy-Loot.lua).
]]
local _, ns = ...

-- Whether a corpse or chest's loot window is open, and when the last one closed.
local worldLootOpen = false
local worldLootClosedAt = nil
-- When Pick Pocket last landed; nil once its sound has played, or before any cast.
local pickPocketAt = nil

--------------------------------------------------------------------------------
-- Loot Source
--------------------------------------------------------------------------------

--[[
    A loot window alone doesn't say where the loot came from: disenchanting,
    prospecting and milling, opening a container, and the server's
    white-into-green item merge all arrive through the same loot window and loot
    message a corpse does. They differ only in the loot source GUID: an item
    carries "Item-...", a corpse "Creature-..." or "Vehicle-...", a chest or node
    "GameObject-...".

    Three answers, so ns.StampWorldLoot can treat each differently: "world" when
    any open slot is a corpse, chest or node; "item" when every resolved source
    is an item; "unknown" when there is nothing to go on yet, because the window
    is empty or the GUIDs haven't arrived. "unknown" is kept apart from "item"
    on purpose: source info can arrive late, and Speedy Loot may loot at once, so
    a corpse not yet populated must not be taken for item loot.
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
    Opens the window the chime may play in, which stays open as long as the
    corpse or chest's loot window does, so a Bind on Pickup item confirmed or an
    item looted by hand seconds later still chimes:
      world   - open it. Run on both LOOT_READY and LOOT_OPENED, because the
                source GUID can arrive on either and Speedy Loot may empty the
                slots between them.
      item    - close it outright, so a disenchant or merge just after a real
                corpse can't reuse its window.
      unknown - leave it: a late world GUID must still be able to open it, and
                one just opened for this corpse must survive an empty re-read.
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

--[[
    Only loot from a corpse or chest chimes: while its loot window is open, or
    within ns.LOOT_SOUND_WINDOW seconds of its closing, for loot lines that land
    just after. Item-made loot never opens the window, so it stays silent even
    though it travels the same path, and so does a roll win.
]]
---@param itemLink string
---@return nil
function ns.PlayLootSound(itemLink)
	if not ns.db.profile.lootSounds then
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

--[[
    A successful Pick Pocket cast ARMS the sound; it doesn't play it. The cast
    succeeding says nothing about whether the pockets held anything: picking a
    target whose pockets are already empty fires the cast event and an error
    together. So what the player hears waits for loot to actually turn up.
]]
local function OnSpellcastSucceeded(unitIdentifier, _, spellIdentifier)
	-- WoW Forever can make the cast's spell secret, which can't be compared, so ask C_Secrets first.
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return
	end
	if unitIdentifier == "player" and spellIdentifier == ns.SPELLS.PICK_POCKET then
		pickPocketAt = GetTime()
	end
end

--[[
    The half that decides whether the sound is heard: a loot window with
    something in it, opening within ns.PICK_POCKET_LOOT_WINDOW of the cast. A
    pickpocket that yields nothing opens no window, so the arming simply times
    out. Disarms as it plays, so one cast sounds once however many loot events
    the window generates.

    MUST RUN BEFORE SPEEDY LOOT: it empties the slots, and an emptied window is
    indistinguishable from a pickpocket that came up empty.
]]
---@return nil
function ns.PlayPickPocketSound()
	if not pickPocketAt or not ns.db or not ns.db.profile.pickPocketSound then
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

-- LOOT_READY is Speedy Loot's, which runs the same two first; see the header.
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
