--------------------------------------------------------------------------------
-- GogoLoot Speedy Loot Module
--------------------------------------------------------------------------------

--[[
    Watches LOOT_READY and loots every slot at once, keeping the loot window
    hidden so pickup is near instant.

    Gated by ns.db.global.speedyLoot, and stands down for the whole master-loot
    session whenever ns:AreWeMasterLooter() is true: LootSlot calls in a
    master-loot session race the distribution path and pop the candidate
    dropdown for items the engine would have placed automatically.

    The window stays up whenever something is left in it: an item set to Ignore
    on the Openables List, which is left for the player to take by hand, loot
    the bags had no room for, or a Bind on Pickup item waiting on the client's
    bind question. Auto Loot, which this depends on, is enforced by
    Features/Auto-Loot.lua.
]]
local _, ns = ...

local LOOT_THROTTLE_SECONDS = 0.3
local lastLootAttemptTime = nil

--[[
    True only when the most recent pass took everything with bag space to spare,
    so nothing was left in the window and nothing it asked for can still bounce
    off full bags. The LootFrame OnShow hook at the bottom of this file re-hides
    the window the instant the default UI shows it on LOOT_OPENED. That re-show
    is what makes the window flash for half a second: a plain LootFrame:Hide()
    on LOOT_READY is a no-op because the frame isn't shown yet, and nothing
    re-hides it after. Hooking OnShow rather than handling LOOT_OPENED makes the
    suppression independent of handler order: it hides after whatever showed the
    frame.

    Cleared on LOOT_CLOSED, so a throttled LOOT_READY can't carry one corpse's
    "fully looted" verdict onto the next corpse's window.
]]
local suppressLootWindow = false

--------------------------------------------------------------------------------
-- Loot Slot Type
--------------------------------------------------------------------------------

-- Money and currency slots take no bag space, so only item slots count against the free slots.
local function IsItemLootSlot(slotIndex)
	return GetLootSlotType(slotIndex) == ns.LOOT_SLOT_TYPE_ITEM
end

--------------------------------------------------------------------------------
-- Speedy Loot
--------------------------------------------------------------------------------

local function RunSpeedyLoot()
	if not ns.db or not ns.db.global.speedyLoot then
		return
	end

	--[[
        Stand down for the whole loot session whenever we are the master looter,
        not only when GogoLoot will auto-distribute. Master loot is a managed
        flow: at-or-above-threshold items are assigned through the master looter
        window (automatically by Master-Looter.lua, or by hand) and sub-threshold
        items are handed out by the group method. LootSlot here would vacuum that
        loot into the master looter's own bags before it can be assigned, and
        LootSlot on a threshold item pops MasterLooterFrame_Show, which errors on
        some clients (the nil colorInfo loot-frame crash). AreWeMasterLooter() is
        the superset of WillAutoMasterLoot(), so this also covers loot outside
        instances, where auto-distribution is off by default.
    ]]
	if ns:AreWeMasterLooter() then
		return
	end

	--[[
        Respect the user's Auto Loot setting plus the modifier-key inversion, so
        holding the auto-loot modifier still flips behavior as expected.
    ]]
	local autoLootEnabled = ns:IsAutoLootCVarEnabled()
	local modifierKeyHeld = IsModifiedClick("AUTOLOOTTOGGLE")
	if autoLootEnabled == modifierKeyHeld then
		return
	end

	-- Throttle to avoid double-firing on closely spaced LOOT_READY events.
	local currentTime = GetTime()
	if lastLootAttemptTime and (currentTime - lastLootAttemptTime) < LOOT_THROTTLE_SECONDS then
		return
	end

	local lootSlotCount = GetNumLootItems()
	if lootSlotCount < 1 then
		return
	end

	local availableBagSlots = ns.CountFreeBagSlots()

	--[[
        With no bag space and item slots present, loot nothing and leave the
        standard loot window visible: hiding it would strand the loot.
    ]]
	if availableBagSlots <= 0 then
		for slotIndex = 1, lootSlotCount do
			if IsItemLootSlot(slotIndex) then
				return
			end
		end
	end

	--[[
        Set whenever the window has to stay up: an item set to Ignore, one
        skipped because the bags filled partway through, or a Bind on Pickup
        item, whose bind question the client only asks while the loot session is
        open, so hiding the window would cancel it and leave the item behind. It
        drives both re-showing the window and the suppression flag below: the
        window is only suppressed when this pass took everything.
    ]]
	local leftBehind = false
	local tookItem = false

	--[[
        From the bottom of the list upward, mirroring the game's own auto loot
        and avoiding index shifts as slots empty. The free-slot count is read once
        and decremented per item, one slot per item even when it would stack onto
        one already carried: conservative, and anything left behind stays
        reachable in the window.
    ]]
	for slotIndex = lootSlotCount, 1, -1 do
		-- A locked slot is still being rolled for, or isn't the player's to take yet; its roll window handles it.
		local locked = select(6, GetLootSlotInfo(slotIndex))
		if not locked then
			if not IsItemLootSlot(slotIndex) then
				LootSlot(slotIndex)
			elseif availableBagSlots > 0 then
				local itemLink = GetLootSlotLink(slotIndex)
				local itemIdentifier = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
				if itemIdentifier and ns:IsOpeningIgnored(itemIdentifier) then
					if ns.db.profile.openingIgnoreNotifications then
						ns:AnnounceItemOnce("MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW", itemIdentifier, itemLink)
					end
					leftBehind = true
				else
					LootSlot(slotIndex)
					availableBagSlots = availableBagSlots - 1
					tookItem = true
					if itemLink and select(14, C_Item.GetItemInfo(itemLink)) == ns.BIND_ON_PICKUP then
						leftBehind = true
					end
				end
			else
				leftBehind = true
			end
		end
	end

	--[[
        Hiding the window closes the loot (the default UI calls CloseLoot from
        its OnHide), and the hide lands before the server has answered a single
        LootSlot. The free-slot count is only a guess until then: items from the
        previous corpse can still be arriving. So once this pass leaves fewer
        than ns.MIN_FREE_SLOTS free, the line Automated Opening pauses at, the
        window stays up. It closes itself when the last item is taken, and a
        pickup that bounces off full bags stays in it instead of on a corpse the
        player can no longer see.
    ]]
	local bagsTight = tookItem and availableBagSlots < ns.MIN_FREE_SLOTS

	suppressLootWindow = not leftBehind and not bagsTight

	-- Belt and braces with the default UI's own show: stranded loot must be seen.
	if leftBehind and LootFrame then
		LootFrame:Show()
	end

	lastLootAttemptTime = currentTime
end

--[[
    The one LOOT_READY handler, and its order is load-bearing. The world-loot
    stamp and the Pick Pocket sound (Features/Loot-Sounds.lua) read the loot
    slots, which the Speedy Loot pass empties, so both run first.
]]
local function OnLootReady()
	ns.StampWorldLoot()
	ns.PlayPickPocketSound()
	RunSpeedyLoot()
end

local function OnLootClosed()
	suppressLootWindow = false
end

ns:RegisterModuleEvent("LOOT_READY", OnLootReady)
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)

--------------------------------------------------------------------------------
-- Loot Window OnShow Hook
--------------------------------------------------------------------------------

--[[
    Re-hide the loot window the instant the default UI shows it, but only when
    the last pass took everything. This is what actually kills the flash; see
    suppressLootWindow above. Hooked once at load: LootFrame exists by then,
    since the default UI loads before add-ons.
]]
if LootFrame then
	LootFrame:HookScript("OnShow", function(self)
		if suppressLootWindow then
			self:Hide()
		end
	end)
end
