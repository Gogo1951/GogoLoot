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

    "The window" is whichever loot window is in use: the game's, or ElvUI's or
    Tukui's in its place (ns.GetLootWindow).
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
-- Bag Space
--------------------------------------------------------------------------------

-- The key family bit: what the keyring takes.
local KEY_FAMILY = 256

local GetItemFamily = C_Item.GetItemFamily or GetItemFamily

--[[
    Whether this client has a keyring, asked the way the client itself asks:
    MoP Classic still defines KEYRING_CONTAINER but has no keyring.
]]
local function HasKeyring()
	if not KEYRING_CONTAINER then
		return false
	end
	if IsKeyRingEnabled then
		return IsKeyRingEnabled() and true or false
	end
	if C_ActionBar and C_ActionBar.ShouldShowKeyring then
		return C_ActionBar.ShouldShowKeyring() and true or false
	end
	return false
end

--[[
    Where this pass's loot can go, read once per pass: free slots in the
    general-purpose bags, each specialty bag on its own with its family (a
    quiver, a herb bag, a soul bag), and the keyring where the client has one.
    `incoming` counts what the pass has already sent for each item, so two
    stacks of the same cloth in one corpse are measured against each other.
]]
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
	-- Era and Anniversary only; the keyring takes keys alone, whatever family it reports for itself.
	if HasKeyring() then
		local free = C_Container.GetContainerNumFreeSlots(KEYRING_CONTAINER)
		if free and free > 0 then
			space.specialty[#space.specialty + 1] = { free = free, family = KEY_FAMILY }
		end
	end
	return space
end

--[[
    Whether an item has somewhere to go, spending the space it takes. Cheapest
    first, the same order the client fills bags in:

    1. ONTO A STACK ALREADY CARRIED. The room left on the carried stacks is
       counted as if every stack but the last were full, which is the least
       room they can have, so this never promises space that isn't there.
    2. A SPECIALTY BAG whose family the item shares (arrows in a quiver, herbs
       in a herb bag). A bag or quiver as loot is never one of these: its own
       family names what it HOLDS, not where it may go.
    3. A GENERAL-PURPOSE SLOT.

    An item the client hasn't loaded reads no stack size and no family, and a
    slot with no link reads nothing at all, so either falls through to a
    general slot: conservative, as before.
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
		-- A fresh stack: what it holds is carried room for the next copy in this corpse.
		space.incoming[itemIdentifier] = (space.incoming[itemIdentifier] or 0) + quantity
	end
	return taken
end

--------------------------------------------------------------------------------
-- Speedy Loot
--------------------------------------------------------------------------------

--[[
    When the last pass that took an item closed the loot behind it, for the
    refused-pickup warning below. Nil while the window stayed up: an item it
    couldn't take is still in front of the player there.
]]
local closedPassAt = nil

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

	local space = ReadBagSpace()

	--[[
        Set whenever the window has to stay up: an item set to Ignore, one with
        nowhere to go, or a Bind on Pickup item, whose bind question the client
        only asks while the loot session is open, so hiding the window would
        cancel it and leave the item behind. It drives both re-showing the
        window and the suppression flag below: the window is only suppressed
        when this pass took everything.
    ]]
	local leftBehind = false
	local tookItem = false

	--[[
        From the bottom of the list upward, mirroring the game's own auto loot
        and avoiding index shifts as slots empty. Each item is measured against
        the space read above and spends what it takes (TakeSpaceFor); one with
        nowhere to go stays in the window, and everything that fits, coin
        included, is still taken.
    ]]
	for slotIndex = lootSlotCount, 1, -1 do
		-- A locked slot is still being rolled for, or isn't the player's to take yet; its roll window handles it.
		local _, _, quantity, _, _, locked = GetLootSlotInfo(slotIndex)
		if not locked then
			if not IsItemLootSlot(slotIndex) then
				LootSlot(slotIndex)
			else
				local itemLink = GetLootSlotLink(slotIndex)
				local itemIdentifier = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
				-- Ignore on the Openables List also leaves the item here for the player.
				if itemIdentifier and ns:IsOpeningIgnored(itemIdentifier) then
					if ns.db.profile.openingIgnoreNotifications then
						ns:AnnounceItemOnce("MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW", itemIdentifier, itemLink)
					end
					leftBehind = true
				elseif TakeSpaceFor(space, itemLink, itemIdentifier, quantity or 1) then
					LootSlot(slotIndex)
					tookItem = true
					if itemLink then
						-- A bind type of nil is an item the client hasn't loaded yet, which may be Bind on Pickup too.
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
        Hiding the window closes the loot (the default UI calls CloseLoot from
        its OnHide), and the hide lands before the server has answered a single
        LootSlot. The free-slot count is only a guess until then: items from the
        previous corpse can still be arriving. So once this pass leaves fewer
        than ns.MIN_FREE_SLOTS general slots free, the line Automated Opening
        pauses at, the window stays up. It closes itself when the last item is
        taken, and a pickup that bounces off full bags stays in it instead of on
        a corpse the player can no longer see.
    ]]
	local bagsTight = tookItem and space.general < ns.MIN_FREE_SLOTS

	suppressLootWindow = not leftBehind and not bagsTight
	closedPassAt = (suppressLootWindow and tookItem) and currentTime or nil

	-- Belt and braces with the loot window's own show: stranded loot must be seen.
	local lootWindow = ns.GetLootWindow()
	if leftBehind and lootWindow then
		lootWindow:Show()
	end

	lastLootAttemptTime = currentTime
end

--[[
    A pickup the server refused after the pass had already closed the loot:
    full bags (anything still arriving from the last corpse can fill them), or
    a unique item already carried. The item is still on the corpse, but the
    window that would have shown it is gone, and reopening the loot would mean
    holding every session open until the server answers. So the player is told
    instead, once per ns.BAG_FULL_COOLDOWN (shared with Automated Opening's
    warning), with the client's own reason, and for full bags hears their
    character's inventory-full line (never for a unique item, where "my bags
    are full" would be wrong). Only within ns.LOOT_BOUNCE_WINDOW of such a pass: any
    other refusal is the game's to report.
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
    Re-hide the loot window the instant it shows, but only when the last pass
    took everything. This is what actually kills the flash; see
    suppressLootWindow above.

    THREE KINDS OF LOOT WINDOW.

    The game's old one (LootFrame_Show, a plain UIPanel) on Era, Anniversary and
    MoP Classic, and ElvUI's and Tukui's replacements (ElvLootFrame,
    TukuiLootFrame) on any client: each is shown by one Show() on LOOT_OPENED
    and closes the loot from its own OnHide, so hiding it from its own OnShow
    is clean.

    WoW Forever's own window is Retail's (LootFrameMixin), whose Open() shows
    the frame and THEN keeps going: it sets isOpen and plays its open
    animation. Hiding from OnShow there lands mid-Open, so Open finishes on a
    hidden frame that now believes it is open, with its item list already
    emptied by OnHide. The next time Blizzard re-applies the frame's shown
    state (SetShown(isOpen)) an empty "Items" window comes back and nothing
    closes it. So on that frame the hide waits until Open has returned, and
    goes through the frame's own Close and HideUIPanel, leaving isOpen, the
    animations and the UI panel slot the way Blizzard's own close leaves them.
    Open is a mixin method copied onto the frame table itself, so rawget finds
    it on Forever and nothing on the old frame, whose methods are all widget
    methods behind the metatable.
]]
local function HideFromOnShow(frame)
	if suppressLootWindow then
		frame:Hide()
	end
end

-- LootFrame exists at load, since the default UI loads before add-ons.
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

--[[
    ElvUI and Tukui build their loot windows at login, after GogoLoot loads, so
    their hooks go on the first time loot is ready, before the window's
    LOOT_OPENED show. Once per frame: a HookScript stacks.
]]
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
    The one LOOT_READY handler, and its order is load-bearing. The world-loot
    stamp and the Pick Pocket sound (Features/Loot-Sounds.lua) read the loot
    slots, which the Speedy Loot pass empties, so both run first.
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
