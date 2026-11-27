--------------------------------------------------------------------------------
-- GogoLoot Speedy Loot Module
--------------------------------------------------------------------------------

-- "The window" is whichever loot window is in use: the game's, or ElvUI's or Tukui's (ns.GetLootWindow).
local _, ns = ...

local LOOT_THROTTLE_SECONDS = 0.3
local lastLootAttemptTime = nil

--[[
    True only when the last pass took everything with bag space to spare. A
    Hide() on LOOT_READY is a no-op (the frame isn't shown yet), so the show
    hook below re-hides it, after whatever showed it. Cleared on LOOT_CLOSED,
    so a throttled LOOT_READY can't carry one corpse's verdict to the next.
]]
local suppressLootWindow = false

--------------------------------------------------------------------------------
-- Loot Slot Type
--------------------------------------------------------------------------------

local function IsItemLootSlot(slotIndex)
	return GetLootSlotType(slotIndex) == ns.LOOT_SLOT_TYPE_ITEM
end

--------------------------------------------------------------------------------
-- Bag Space
--------------------------------------------------------------------------------

local KEY_FAMILY = 256

local GetItemFamily = C_Item.GetItemFamily or GetItemFamily

-- MoP Classic still defines KEYRING_CONTAINER but has no keyring.
local function HasKeyring()
	if not KEYRING_CONTAINER then
		return false
	end
	if C_ActionBar and C_ActionBar.ShouldShowKeyring then
		return C_ActionBar.ShouldShowKeyring() and true or false
	end
	if IsKeyRingEnabled then
		return IsKeyRingEnabled() and true or false
	end
	return false
end

-- `incoming` counts what this pass already sent, so two stacks of one cloth are measured against each other.
local function ReadBagSpace()
	local space = { general = 0, specialty = {}, incoming = {} }
	for bagIndex = 0, NUM_BAG_SLOTS do
		local free, family = C_Container.GetContainerNumFreeSlots(bagIndex)
		if free and free > 0 then
			if family == 0 or family == nil then
				space.general = space.general + free
			else
				space.specialty[#space.specialty + 1] = { free = free, family = family }
			end
		end
	end
	-- The keyring takes keys alone, whatever family it reports for itself.
	if HasKeyring() then
		local free = C_Container.GetContainerNumFreeSlots(KEYRING_CONTAINER)
		if free and free > 0 then
			space.specialty[#space.specialty + 1] = { free = free, family = KEY_FAMILY }
		end
	end
	return space
end

--[[
    Cheapest first, as the client fills bags:
    1. ONTO A CARRIED STACK, counted as if every stack but the last were full,
       the least room they can have.
    2. A SPECIALTY BAG of the item's family. A looted bag or quiver is never
       one: its family names what it HOLDS, not where it may go.
    3. A GENERAL SLOT, also where an uncached or linkless item falls.
]]
local function TakeSpaceFor(space, itemLink, itemIdentifier, quantity)
	local stackSize = itemLink and select(8, C_Item.GetItemInfo(itemLink))
	if itemIdentifier and stackSize and stackSize > 1 then
		local carried = (C_Item.GetItemCount(itemIdentifier) or 0) + (space.incoming[itemIdentifier] or 0)
		local room = (stackSize - carried % stackSize) % stackSize
		if carried > 0 and room >= quantity then
			space.incoming[itemIdentifier] = (space.incoming[itemIdentifier] or 0) + quantity
			return true
		end
	end
	local classIdentifier = itemLink and select(6, C_Item.GetItemInfoInstant(itemLink))
	local isBag = classIdentifier == ns.ITEM_CLASS_BAG or classIdentifier == ns.ITEM_CLASS_QUIVER
	local itemFamily = itemLink and not isBag and GetItemFamily and GetItemFamily(itemLink) or 0
	local taken = false
	if itemFamily ~= 0 then
		for _, bag in ipairs(space.specialty) do
			if bag.free > 0 and bit.band(itemFamily, bag.family) ~= 0 then
				bag.free = bag.free - 1
				taken = true
				break
			end
		end
	end
	if not taken and space.general > 0 then
		space.general = space.general - 1
		taken = true
	end
	if taken and itemIdentifier then
		space.incoming[itemIdentifier] = (space.incoming[itemIdentifier] or 0) + quantity
	end
	return taken
end

--------------------------------------------------------------------------------
-- Speedy Loot
--------------------------------------------------------------------------------

-- nil while the window stayed up: a refused item is still in front of the player there.
local closedPassAt = nil

local function RunSpeedyLoot()
	if not ns.db or not ns.db.global.speedyLoot then
		return
	end

	--[[
        Not WillAutoMasterLoot(): any LootSlot in a master-loot session vacuums
        threshold loot into the master looter's bags, or pops
        MasterLooterFrame_Show, which errors on some clients.
    ]]
	if ns:AreWeMasterLooter() then
		return
	end

	local autoLootEnabled = ns:IsAutoLootCVarEnabled()
	local modifierKeyHeld = IsModifiedClick("AUTOLOOTTOGGLE")
	if autoLootEnabled == modifierKeyHeld then
		return
	end

	local currentTime = GetTime()
	if lastLootAttemptTime and (currentTime - lastLootAttemptTime) < LOOT_THROTTLE_SECONDS then
		return
	end

	local lootSlotCount = GetNumLootItems()
	if lootSlotCount < 1 then
		return
	end

	local space = ReadBagSpace()

	-- The client asks a Bind on Pickup item's bind question only while the loot session is open.
	local leftBehind = false
	local tookItem = false

	-- Bottom-up, as the game's own auto loot does, so no index shifts as slots empty.
	for slotIndex = lootSlotCount, 1, -1 do
		-- A locked slot is still being rolled for, or isn't the player's to take yet.
		local _, _, quantity, _, _, locked = GetLootSlotInfo(slotIndex)
		if not locked then
			if not IsItemLootSlot(slotIndex) then
				LootSlot(slotIndex)
			else
				local itemLink = GetLootSlotLink(slotIndex)
				local itemIdentifier = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
				--[[
                    Openables List Ignore is still looted: left in the window, a
                    fishing catch is lost for good (maintainer, 2026-11-07).
                ]]
				if TakeSpaceFor(space, itemLink, itemIdentifier, quantity or 1) then
					LootSlot(slotIndex)
					tookItem = true
					if itemLink then
						-- A nil bind type is an uncached item, which may be Bind on Pickup too.
						local bindType = select(14, C_Item.GetItemInfo(itemLink))
						if bindType == nil or bindType == ns.BIND_ON_PICKUP then
							leftBehind = true
						end
					end
				else
					leftBehind = true
				end
			end
		end
	end

	--[[
        Hiding closes the loot before the server answers any LootSlot, so the
        free-slot count is only a guess. Under ns.MIN_FREE_SLOTS the window stays
        up, so a pickup that bounces stays in it rather than on the corpse.
    ]]
	local bagsTight = tookItem and space.general < ns.MIN_FREE_SLOTS

	suppressLootWindow = not leftBehind and not bagsTight
	closedPassAt = (suppressLootWindow and tookItem) and currentTime or nil

	local lootWindow = ns.GetLootWindow()
	if leftBehind and lootWindow then
		lootWindow:Show()
	end

	lastLootAttemptTime = currentTime
end

--[[
    A pickup refused after the pass closed the loot is reported, not reopened:
    reopening would mean holding every session open. The voice line plays for
    full bags only, never a unique item.
]]
local function OnUiErrorMessage(errorIdentifier, message)
	if not closedPassAt or (GetTime() - closedPassAt) > ns.LOOT_BOUNCE_WINDOW then
		return
	end
	if not ns.IsLootBounceErrorID(errorIdentifier) then
		return
	end
	closedPassAt = nil
	if ns.ClaimBagFullWarning() then
		local reason = type(message) == "string" and message or ERR_INV_FULL
		ns:StatusPrint(ns.L["MESSAGE_LOOT_LEFT_ON_CORPSE"]:format(reason))
		if ns.IsBagFullErrorID(errorIdentifier) then
			ns.PlayBagFullSound()
		end
	end
end

--------------------------------------------------------------------------------
-- Loot Window Hooks
--------------------------------------------------------------------------------

--[[
    The old LootFrame and ElvUI's and Tukui's are shown by one Show() and close
    the loot from OnHide, so hiding from OnShow is clean.

    WoW Forever's Retail LootFrameMixin Open() keeps going after the show: a
    hide from OnShow lands mid-Open and later strands an empty, un-closable
    "Items" window. There the hide waits for Open to return and goes through
    Close and HideUIPanel. Open is a mixin method on the frame table, so rawget
    finds it only there.
]]
local function HideFromOnShow(frame)
	if suppressLootWindow then
		frame:Hide()
	end
end

if LootFrame then
	if type(rawget(LootFrame, "Open")) == "function" then
		hooksecurefunc(LootFrame, "Open", function(self)
			if suppressLootWindow then
				self:Close()
				self:StopAllAnimations()
				HideUIPanel(self)
			end
		end)
	else
		LootFrame:HookScript("OnShow", HideFromOnShow)
	end
end

-- ElvUI and Tukui build their windows at login, after GogoLoot loads. Once per frame: a HookScript stacks.
local hookedReplacements = {}

local function HookReplacementLootWindows()
	for _, frameName in ipairs(ns.LOOT_WINDOW_REPLACEMENTS) do
		local frame = _G[frameName]
		if frame and not hookedReplacements[frameName] then
			hookedReplacements[frameName] = true
			frame:HookScript("OnShow", HideFromOnShow)
		end
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
    Order is load-bearing: anything that reads the loot slots on LOOT_READY
    goes here, before RunSpeedyLoot. Another module's LOOT_READY handler runs
    after the pass and finds the slots empty.
]]
local function OnLootReady()
	HookReplacementLootWindows()
	ns.StampWorldLoot()
	ns.PlayPickPocketSound()
	RunSpeedyLoot()
end

local function OnLootClosed()
	suppressLootWindow = false
end

ns:RegisterModuleEvent("LOOT_READY", OnLootReady)
ns:RegisterModuleEvent("LOOT_CLOSED", OnLootClosed)
ns:RegisterModuleEvent("UI_ERROR_MESSAGE", OnUiErrorMessage)
