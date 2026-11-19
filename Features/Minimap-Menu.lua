--------------------------------------------------------------------------------
-- GogoLoot Mini-map Menu
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

--[[
    The mini-map button's menu (Style Guide → MINIMAP MENU), drawn on
    Menu-Kit.lua's plate: the add-on's name, then Locked Items while any box
    waits on a lock, then a block for each feature a player switches in play
    (Automated Rolls, Automated Opening, Loot Announcements), each a gold title
    with On or Off on the right, a line saying what it does and a blue Toggle
    row naming the button click that does the same. Automated Rolls' Party and
    Raid rows each open a flyout setting that context, with links to the
    pages that also shape the rolls (Global Item Overrides, Character
    Overrides, the Loot Roll Sanity Check); a pick there closes the menu.
    More Features holds the set-and-forget switches in a flyout, and the
    Options row closes the menu.

    Hovering the button opens it, and it closes a moment after the cursor
    leaves the button, the menu and the flyout. Every row is a plain click, so
    a controller's cursor reaches all of it, and the button keeps its clicks
    (Button Clicks, below).
]]

local HOVER_CLOSE_DELAY = 0.4
local CLICK_CLOSE_DELAY = 1.0
local MENU_GAP = 2 -- From the button's corner to the menu's
local LIST_MAX = 8 -- A list's rows before a note counts the rest (Blocks Beyond Features → Long lists)

local menu = Kit.CreatePanel(ADDON_NAME .. "Menu", UIParent)
local flyout = Kit.CreatePanel(nil, menu)
flyout:SetFrameLevel(menu:GetFrameLevel() + 20)

-- Escape closes it, as it does any game menu.
table.insert(UISpecialFrames, menu:GetName())

Kit.SetToggleText(L["MENU_ON"], L["MENU_OFF"])

local state = {
	anchor = nil,
	flyoutKey = nil,
	closeDelay = HOVER_CLOSE_DELAY,
	idle = 0,
	openLeft = true,
	openDown = true,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- An option's caption and tooltip, drawn the way the options panel draws them.
local function OptionTooltip(name, desc)
	return function(tooltip)
		tooltip:SetText(name, 1, 0.82, 0, 1, true)
		if desc and desc ~= "" then
			tooltip:AddLine(desc, 1, 1, 1, true)
		end
	end
end

-- A feature's switch tooltip, from its ns.FEATURES record (Options/Options-Utilities.lua).
local function FeatureTooltip(setting)
	local feature = ns.GetFeature(setting)
	return OptionTooltip(L[feature.caption], ns.FeatureDescription(feature))
end

local function IsFeatureOn(feature)
	local store = ns.db[feature.store]
	return store and store[feature.setting] and true or false
end

-- An open options page redraws with the new value, and so do the menu and the button's icon.
local function AfterChange()
	ns.RefreshSettings()
end

-- The right side of a feature's title: On in green, Off in gray.
local function OnOff(enabled)
	if enabled then
		return L["MENU_ON"], "ON"
	end
	return L["MENU_OFF"], "MUTED"
end

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------

--[[
    Flips a feature the way its options switch does: its ns.FEATURES apply,
    with every side effect (Auto Loot, the opening scan, the trade window's
    checkbox, the not-master-looter chat line), or a plain write. The caller
    refreshes after (AfterChange, above).
]]
---@param setting string # an ns.FEATURES setting
---@return nil
function ns.FlipFeature(setting)
	local feature = ns.GetFeature(setting)
	local store = ns.db[feature.store]
	local value = not store[feature.setting]
	if feature.apply then
		feature.apply(value)
	else
		store[feature.setting] = value
	end
end

-- The three clicks that switch a feature (Button Clicks, below).
function ns.ToggleAutomatedRolls()
	ns.FlipFeature("autoGreed")
end

function ns.ToggleAutomatedOpening()
	ns.FlipFeature("autoOpen")
end

function ns.ToggleAnnouncements()
	ns.FlipFeature("lootNotifications")
end

--------------------------------------------------------------------------------
-- Loot Windows
--------------------------------------------------------------------------------

--[[
    Middle-Click opens the loot windows: the Loot Master for a player with loot
    to hand out (tradable loot on the Roll List, or Master Looter), the Loot
    Tracker for everyone else. The windows are parked out of the TOCs for now;
    with their files unloaded, the click does nothing.
]]
---@return boolean
function ns.LootWindowsLoaded()
	return ns.db.profile.lootMaster and ns.GetRollListEntries ~= nil or false
end

local function HasLootToHandOut()
	return #ns:GetRollListEntries() > 0 or ns:AreWeMasterLooter()
end

function ns.OpenLootWindow()
	if HasLootToHandOut() then
		ns:ToggleLootMaster()
	else
		ns:ToggleLootTracker()
	end
end

--------------------------------------------------------------------------------
-- Button Clicks
--------------------------------------------------------------------------------

--[[
    One table, both ways: the button's OnClick looks the click up here, and the
    row that does the same job names the click on its right, so a row never
    names a click that does something else. Each toggle keeps its side effects
    (Toggles, above) and the click then refreshes.

    Shift + Right-Click has no entry: it is held for the Master Looting Window,
    and does nothing until that window is built. Left-Click has a job, so hover
    alone opens the menu.
]]
local CLICKS = {
	rolls = {
		button = "LeftButton",
		shift = false,
		name = "MENU_CLICK_LEFT",
		run = function()
			ns.ToggleAutomatedRolls()
		end,
	},
	opening = {
		button = "RightButton",
		shift = false,
		name = "MENU_CLICK_RIGHT",
		run = function()
			ns.ToggleAutomatedOpening()
		end,
	},
	announcements = {
		button = "LeftButton",
		shift = true,
		name = "MENU_CLICK_SHIFT_LEFT",
		run = function()
			ns.ToggleAnnouncements()
		end,
	},
	-- The loot windows, only while their files are loaded; they're parked out of the TOCs for now.
	lootWindows = {
		button = "MiddleButton",
		shift = false,
		name = "MENU_CLICK_MIDDLE",
		run = function()
			if ns.LootWindowsLoaded() then
				ns.OpenLootWindow()
			end
		end,
	},
	options = {
		button = "MiddleButton",
		shift = true,
		name = "MENU_CLICK_SHIFT_MIDDLE",
		run = function()
			ns.HideMenu()
			ns:OpenOptionsPanel()
		end,
	},
}
ns.MENU_CLICKS = CLICKS

--[[
    Runs the click's job and redraws the menu, any open options page and the
    icon; false when the click has none.
]]
---@param button string
---@return boolean
function ns.RunButtonClick(button)
	local shift = IsShiftKeyDown() and true or false
	for _, click in pairs(CLICKS) do
		if click.button == button and click.shift == shift then
			if not ns.db and click ~= CLICKS.options then
				return true
			end
			click.run()
			AfterChange()
			return true
		end
	end
	return false
end

-- An action row: blue, naming its button click on the right in gray.
local function ClickRow(label, clickKey, tooltip)
	local click = CLICKS[clickKey]
	return {
		kind = "action",
		left = label,
		leftColor = "INFO",
		right = L[click.name],
		rightColor = "MUTED",
		tooltip = tooltip,
		onClick = function()
			click.run()
			AfterChange()
		end,
	}
end

--------------------------------------------------------------------------------
-- Locked Items
--------------------------------------------------------------------------------

--[[
    Locked Items leads, above the feature blocks, and shows only while boxes
    are waiting on a lock: it is the one part that changes with the bags
    rather than a setting, so it is what the player opened the menu to check.
    One item row per distinct box, its icon then its name from the item's own
    link (already localized and quality-colored) without the brackets, with a
    count only when there's more than one, so no locale needs a plural. Eight
    rows at most, then a note counting the rest. A gray note closes it: a Rogue
    is told to use Pick Lock, anyone else that a Rogue can pick them. The Rogue
    line waits for the spell's name rather than showing a blank one.
]]
local function LockedItemRow(box)
	local icon = box.icon and ("|T" .. box.icon .. ":0|t ") or ""
	local name = box.link and string.gsub(box.link, "|h%[(.-)%]|h", "|h%1|h")
		or (ns.GetColor("TEXT") .. box.itemIdentifier .. "|r")
	local count = box.count > 1 and (" " .. ns.GetColor("TEXT") .. L["ITEM_QUANTITY"]:format(box.count) .. "|r") or ""
	return {
		kind = "item",
		left = icon .. name .. count,
		tooltip = box.link and function(tooltip)
			tooltip:SetHyperlink(box.link)
		end or nil,
	}
end

--[[
    Inside the Automated Opening block, while it's on: the containers in the
    bags the Openables List keeps sealed, drawn like Locked Items, each with
    its reason (Sell Sealed, May Hold Unique) on the right in gray. Locked Items
    shows what waits on a Rogue; this shows what waits on the player to trade,
    sell or open by hand. Eight rows at most, then a note counting the rest.
]]
---@return table[]|nil
local function SealedContainerRows()
	if not ns.db.profile.autoOpen then
		return nil
	end
	local containers = ns.GetSealedContainers()
	local rows = {}
	for index = 1, math.min(#containers, LIST_MAX) do
		local container = containers[index]
		local row = LockedItemRow(container)
		row.right = container.tag
		row.rightColor = container.tag and "MUTED" or nil
		-- The item's own tooltip, then why it's kept sealed.
		if container.link and container.note then
			row.tooltip = function(tooltip)
				tooltip:SetHyperlink(container.link)
				tooltip:AddLine(" ")
				tooltip:AddLine(ns.GetColor("TITLE") .. L["ADDON_SHORT_NAME"] .. "|r")
				tooltip:AddLine(ns.GetColor("HELP") .. container.note .. "|r", nil, nil, nil, true)
			end
		end
		rows[#rows + 1] = row
	end
	if #containers > LIST_MAX then
		rows[#rows + 1] = { kind = "note", left = L["MENU_MORE"]:format(#containers - LIST_MAX) }
	end
	return rows
end

local function AddLockedItems(entries)
	local boxes = ns.GetLockedBoxes()
	if #boxes == 0 then
		return
	end
	entries[#entries + 1] = { kind = "status", left = L["MINIMAP_LOCKED_ITEMS"] }
	for index = 1, math.min(#boxes, LIST_MAX) do
		entries[#entries + 1] = LockedItemRow(boxes[index])
	end
	if #boxes > LIST_MAX then
		entries[#entries + 1] = { kind = "note", left = L["MENU_MORE"]:format(#boxes - LIST_MAX) }
	end
	local hint
	if ns.IsPlayerRogue() then
		local pickLock = C_Spell.GetSpellName(ns.SPELLS.PICK_LOCK)
		hint = pickLock and L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"]:format(pickLock)
	else
		hint = L["MINIMAP_LOCKED_ITEMS_HINT"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE or "")
	end
	if hint then
		entries[#entries + 1] = { kind = "note", left = hint }
	end
end

--------------------------------------------------------------------------------
-- Feature Blocks
--------------------------------------------------------------------------------

--[[
    Automated Rolls reads back each group context's roll under its
    description, one row each, named with the game's own word for it: the roll
    and the highest quality it rolls on, or the roll alone on Manual. Each row
    opens a flyout that sets that context the way its options rows do:
    Automation (the roll), Threshold (Up to Quality) and Include Bind on Pickup,
    then a note that Item Overrides and Character Overrides still apply, with a
    link to each page and one to the Sanity Check. Item Overrides is named in
    the note only while its switch is on, and its link says Off while it isn't.
]]
local ROLL_CONTEXTS = {
	{
		name = PARTY,
		flyout = "rollsParty",
		actionKey = "autoRollActionParty",
		thresholdKey = "autoRollThresholdParty",
		bindOnPickupKey = "rollBindOnPickupParty",
	},
	{
		name = RAID,
		flyout = "rollsRaid",
		actionKey = "autoRollActionRaid",
		thresholdKey = "autoRollThresholdRaid",
		bindOnPickupKey = "rollBindOnPickupRaid",
	},
}

-- Poor to Epic: the qualities Up to Quality offers, lowest first.
local THRESHOLD_ORDER = { 0, 1, 2, 3, 4 }

--[[
    Rolls carry the roll window's own button art (ns.ROLL_ICONS) and
    qualities their item color, the way the game shows both. A choice that
    isn't picked sits back, the way the kit grays one: its color and its icon
    at DIM_SHARE of full brightness. The menu kit colors a row with
    SetTextColor, so an inline color applies to its own words alone.
    Manual has no art of its own; it gets a blank of the same size, cut from
    the transparent corner of the Pass art, so the four labels line up.
]]
local DIM_SHARE = 0.6
local ICON_SIZE = 32 -- The art's square; only the ratio matters for the crop
local BLANK_ICON = "|T" .. ns.ROLL_ICONS[ns.PASS] .. ":0:0:0:0:" .. ICON_SIZE .. ":" .. ICON_SIZE .. ":0:1:0:1|t"

local function Dimmed(hex)
	local channels = {}
	for index = 1, 5, 2 do
		local value = tonumber(string.sub(hex, index, index + 1), 16) or 0
		channels[#channels + 1] = string.format("%02X", math.floor(value * DIM_SHARE + 0.5))
	end
	return table.concat(channels)
end

-- A roll's icon then a space; dim draws it at DIM_SHARE.
local function RollIcon(action, dim)
	local path = ns.ROLL_ICONS[action]
	if not path then
		return BLANK_ICON .. " "
	end
	local shade = dim and math.floor(255 * DIM_SHARE + 0.5) or 255
	return "|T"
		.. path
		.. ":0:0:0:0:"
		.. ICON_SIZE
		.. ":"
		.. ICON_SIZE
		.. ":0:"
		.. ICON_SIZE
		.. ":0:"
		.. ICON_SIZE
		.. ":"
		.. shade
		.. ":"
		.. shade
		.. ":"
		.. shade
		.. "|t "
end

-- A quality's label in its item color; dim draws it at DIM_SHARE.
local function QualityLabel(quality, dim)
	local hex = ns.QUALITY_COLORS[quality] or ns.QUALITY_COLORS[1]
	return "|cff" .. (dim and Dimmed(hex) or hex) .. (ns.ROLL_THRESHOLD_LABELS[quality] or "") .. "|r"
end

---@param context table
---@return string
function ns.MenuRollSetting(context)
	local profile = ns.db.profile
	local action = profile[context.actionKey]
	local actionLabel = ns.ROLL_OVERRIDE_LABELS[action] or ""
	if action == ns.MANUAL then
		return actionLabel
	end
	local thresholdLabel = QualityLabel(profile[context.thresholdKey])
	return RollIcon(action) .. L["MENU_ROLLS_SETTING"]:format(actionLabel, thresholdLabel)
end

local function RollSettingRows()
	local rows = {}
	for _, context in ipairs(ROLL_CONTEXTS) do
		rows[#rows + 1] = {
			kind = "value",
			left = context.name,
			leftColor = "BODY",
			right = ns.MenuRollSetting(context) .. " " .. Kit.SUBMENU_ARROW,
			rightColor = "TEXT",
			submenu = context.flyout,
			onClick = function()
				ns.OpenFlyout(context.flyout)
			end,
		}
	end
	return rows
end

-- One of a set, written to the profile the way the options' dropdown writes it.
local function ChoiceRow(label, selected, key, value)
	return {
		kind = "choice",
		left = label,
		selected = selected,
		onClick = function()
			ns.db.profile[key] = value
			-- A pick from a list closes the menu, before the refresh so it isn't redrawn on its way out; a switch keeps it open.
			ns.HideMenu()
			AfterChange()
		end,
	}
end

-- A blue link to an options page; the menu closes as the page opens.
local function PageLink(label, panelKey, right)
	return {
		kind = "hint",
		left = label,
		right = right,
		rightColor = right and "MUTED" or nil,
		onClick = function()
			ns.HideMenu()
			ns:OpenOptionsPanel(panelKey)
		end,
	}
end

local function OverridesNote()
	if ns.db.profile.customRollList then
		return L["MENU_ROLLS_OVERRIDES_NOTE"]:format(L["TAB_ITEM_OVERRIDES"], L["TAB_CHARACTER_RULES"])
	end
	return L["MENU_ROLLS_OVERRIDE_NOTE"]:format(L["TAB_CHARACTER_RULES"])
end

---@param context table
---@return table[]
local function RollContextFlyout(context)
	local profile = ns.db.profile
	local rows = { { kind = "section", left = L["MENU_ROLLS_AUTOMATION"] } }
	for _, action in ipairs(ns.ROLL_OVERRIDE_ORDER) do
		local selected = profile[context.actionKey] == action
		rows[#rows + 1] = ChoiceRow(
			RollIcon(action, not selected) .. ns.ROLL_OVERRIDE_LABELS[action],
			selected,
			context.actionKey,
			action
		)
	end

	rows[#rows + 1] = { kind = "section", left = L["ROLLS_UP_TO_QUALITY"] }
	for _, quality in ipairs(THRESHOLD_ORDER) do
		local selected = profile[context.thresholdKey] == quality
		rows[#rows + 1] = ChoiceRow(QualityLabel(quality, not selected), selected, context.thresholdKey, quality)
	end
	rows[#rows + 1] = { kind = "spacer" }
	rows[#rows + 1] = {
		kind = "toggle",
		left = L["ROLLS_INCLUDE_BIND_ON_PICKUP"],
		on = profile[context.bindOnPickupKey] and true or false,
		tooltip = OptionTooltip(L["ROLLS_INCLUDE_BIND_ON_PICKUP"], L["ROLLS_INCLUDE_BIND_ON_PICKUP_DESCRIPTION"]),
		onClick = function()
			profile[context.bindOnPickupKey] = not profile[context.bindOnPickupKey]
			AfterChange()
		end,
	}

	rows[#rows + 1] = { kind = "spacer" }
	rows[#rows + 1] = { kind = "note", left = OverridesNote() }
	rows[#rows + 1] =
		PageLink(L["TAB_ITEM_OVERRIDES"], "ItemOverrides", not profile.customRollList and L["MENU_OFF"] or nil)
	rows[#rows + 1] = PageLink(L["TAB_CHARACTER_RULES"], "CharacterRules")
	rows[#rows + 1] = PageLink(L["TAB_SANITY_CHECK"], "SanityCheck")
	return rows
end

--[[
    Automated Opening's title: On, Paused while something holds it back, or
    Off. ns:GetAutomatedOpeningHold (Features/Automated-Opening.lua) names the
    hold: waiting for free bag slots, a fishing pole, an instance or a group,
    and while paused a note under the description says which.
]]
local OPENING_HOLD_NOTES = {
	FISHING = "MENU_OPENING_FISHING_POLE",
	INSTANCE = "MENU_OPENING_INSTANCE",
	GROUP = "MENU_OPENING_GROUP",
}

---@return string|nil
local function OpeningHold()
	return ns.db.profile.autoOpen and ns:GetAutomatedOpeningHold() or nil
end

---@return string|nil
local function OpeningNote()
	local hold = OpeningHold()
	if hold == "BAGS" then
		return L["MENU_OPENING_WAITING"]:format(ns.MIN_FREE_SLOTS)
	end
	return hold and L[OPENING_HOLD_NOTES[hold]] or nil
end

local function OpeningState()
	if not ns.db.profile.autoOpen then
		return OnOff(false)
	end
	if OpeningHold() then
		return L["MENU_PAUSED"], "MUTED"
	end
	return OnOff(true)
end

--[[
    A feature's block: the gold title with where it stands on the right, what
    the feature does, any note on why it's paused, any rows of its own
    (Automated Rolls' read-back, each row opening its context's flyout), then
    the blue Toggle row naming its click, its tooltip the feature's switch.
    Each title is a plain status heading.
]]
local function AddFeature(entries, block)
	entries[#entries + 1] = {
		kind = "status",
		left = block.title,
		right = block.right,
		rightColor = block.rightColor,
	}
	entries[#entries + 1] = { kind = "description", left = block.description }
	if block.note then
		entries[#entries + 1] = { kind = "note", left = block.note }
	end
	for _, row in ipairs(block.rows or {}) do
		entries[#entries + 1] = row
	end
	entries[#entries + 1] = ClickRow(L["MENU_TOGGLE"], block.click, FeatureTooltip(block.setting))
end

--------------------------------------------------------------------------------
-- More Features
--------------------------------------------------------------------------------

local FLYOUTS = {}

for _, context in ipairs(ROLL_CONTEXTS) do
	FLYOUTS[context.flyout] = function()
		return RollContextFlyout(context)
	end
end

--[[
    More Features: every feature on the options' main page that isn't a block
    above, one On/Off row each, in the main page's order, its switch's caption
    and description as the tooltip. A row flips its switch the way the
    options do, side effects first (ns.FlipFeature). They live in a flyout so
    the main menu stays short; its title counts how many are on and off.
]]
local function MoreFeatures()
	local features = {}
	for _, feature in ipairs(ns.FEATURES or {}) do
		if not feature.block then
			features[#features + 1] = feature
		end
	end
	return features
end

function FLYOUTS.features()
	local rows = {}
	for _, feature in ipairs(MoreFeatures()) do
		rows[#rows + 1] = {
			kind = "toggle",
			left = L[feature.name],
			on = IsFeatureOn(feature),
			tooltip = FeatureTooltip(feature.setting),
			onClick = function()
				ns.FlipFeature(feature.setting)
				AfterChange()
			end,
		}
	end
	return rows
end

-- Only the flyout's switches count; a block's switch doesn't.
---@return number on
---@return number off
function ns.CountMoreFeatures()
	local on, off = 0, 0
	for _, feature in ipairs(MoreFeatures()) do
		if IsFeatureOn(feature) then
			on = on + 1
		else
			off = off + 1
		end
	end
	return on, off
end

local function AddMoreFeatures(entries)
	local on, off = ns.CountMoreFeatures()
	-- The On count green, like an On switch, the comma white, and the Off count the label's gray.
	local onText = ns.GetColor("ON") .. L["MENU_FEATURE_COUNT_ON"]:format(on) .. "|r"
	local offText = L["MENU_FEATURE_COUNT_OFF"]:format(off)
	entries[#entries + 1] = {
		kind = "submenu",
		left = L["MENU_MORE_FEATURES"],
		right = onText .. ns.GetColor("TEXT") .. ",|r " .. offText,
		submenu = "features",
		onClick = function()
			ns.OpenFlyout("features")
		end,
	}
end

--------------------------------------------------------------------------------
-- Main Menu
--------------------------------------------------------------------------------

---@return table[]
function ns.BuildMenuEntries()
	local profile = ns.db.profile
	local entries = {
		{ kind = "header", left = L["ADDON_TITLE"], right = ns.Version or "" },
		{ kind = "spacer" },
	}

	AddLockedItems(entries)

	local right, rightColor = OnOff(profile.autoGreed)
	AddFeature(entries, {
		title = L["TAB_AUTOMATED_ROLLS"],
		right = right,
		rightColor = rightColor,
		description = L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"],
		rows = RollSettingRows(),
		click = "rolls",
		setting = "autoGreed",
	})

	right, rightColor = OpeningState()
	AddFeature(entries, {
		title = L["TAB_AUTOMATED_OPENING"],
		right = right,
		rightColor = rightColor,
		description = L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"],
		note = OpeningNote(),
		rows = SealedContainerRows(),
		click = "opening",
		setting = "autoOpen",
	})

	right, rightColor = OnOff(profile.lootNotifications)
	AddFeature(entries, {
		title = L["TAB_ANNOUNCEMENTS"],
		right = right,
		rightColor = rightColor,
		description = L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"],
		click = "announcements",
		setting = "lootNotifications",
	})

	AddMoreFeatures(entries)

	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = ClickRow(L["MENU_OPTIONS"], "options")
	return entries
end

---@param key string
---@return table[]|nil
function ns.BuildMenuFlyout(key)
	return FLYOUTS[key] and FLYOUTS[key]()
end

--------------------------------------------------------------------------------
-- Drawing & Placement
--------------------------------------------------------------------------------

--[[
    The flyout beside its title, its first row level with the title, on the
    side the menu opened toward. The title keeps its highlight while it's open.
]]
local function PositionFlyout(row)
	flyout:ClearAllPoints()
	if state.openLeft then
		flyout:SetPoint("TOPRIGHT", row, "TOPLEFT", -Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	else
		flyout:SetPoint("TOPLEFT", row, "TOPRIGHT", Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	end
end

local function RenderFlyout()
	local key = state.flyoutKey
	local row = key and menu:SubmenuRow(key)
	local builder = key and FLYOUTS[key]
	if not (row and builder) then
		state.flyoutKey = nil
		flyout:Hide()
		return
	end
	flyout.tooltipAnchor = menu.tooltipAnchor
	flyout:Render(builder())
	PositionFlyout(row)
	flyout:Show()
	row:LockHighlight()
end

local function Render()
	if not menu:IsShown() or not ns.db then
		return
	end
	menu:Render(ns.BuildMenuEntries())
	RenderFlyout()
end

function ns.OpenFlyout(key)
	if key ~= state.flyoutKey then
		state.flyoutKey = key
		Render()
	end
end

-- Entering a title opens its flyout, and any other row closes it, the way any game submenu behaves.
menu.onEnterRow = function(_, entry)
	ns.OpenFlyout(entry and entry.submenu or nil)
end

-- Opens away from the screen edges: left of the button on the right half of the screen, below it on the top half.
local function PositionMenu(anchor)
	local x, y = anchor:GetCenter()
	local scale = anchor:GetEffectiveScale() / UIParent:GetEffectiveScale()
	state.openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
	state.openDown = (y or 0) * scale > UIParent:GetHeight() / 2

	local point = (state.openDown and "TOP" or "BOTTOM") .. (state.openLeft and "RIGHT" or "LEFT")
	local relative = (state.openDown and "BOTTOM" or "TOP") .. (state.openLeft and "LEFT" or "RIGHT")
	menu:ClearAllPoints()
	menu:SetPoint(
		point,
		anchor,
		relative,
		state.openLeft and -MENU_GAP or MENU_GAP,
		state.openDown and -MENU_GAP or MENU_GAP
	)
	menu.tooltipAnchor = state.openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

-- Closes a moment after the cursor has left the button, the menu, and the flyout.
menu:SetScript("OnUpdate", function(self, elapsed)
	local anchor = state.anchor
	if not anchor or not anchor:IsVisible() then
		self:Hide()
		return
	end
	if Kit.IsCursorOver(anchor) or Kit.IsCursorOver(self) or Kit.IsCursorOver(flyout) then
		state.idle = 0
		return
	end
	state.idle = state.idle + elapsed
	if state.idle >= state.closeDelay then
		self:Hide()
	end
end)

menu:SetScript("OnHide", function()
	state.flyoutKey = nil
	state.anchor = nil
	flyout:Hide()
	if ns.IsMenuFrame(GameTooltip:GetOwner()) then
		GameTooltip:Hide()
	end
end)

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--[[
    Opens the menu from a launcher. how is "hover" or "click"; a click keeps it
    open a little longer once the cursor leaves. flyoutKey opens that title's
    flyout at once. A launcher already showing the menu keeps its place and its
    open flyout.
]]
function ns.ShowMenu(anchor, flyoutKey, how)
	if not ns.db or not anchor then
		return
	end
	local reopen = menu:IsShown() and state.anchor == anchor
	if not reopen then
		state.closeDelay = HOVER_CLOSE_DELAY
		state.flyoutKey = nil
	end
	state.anchor = anchor
	state.idle = 0
	if how == "click" then
		state.closeDelay = CLICK_CLOSE_DELAY
	end
	if flyoutKey then
		state.flyoutKey = flyoutKey
	end
	if not reopen then
		PositionMenu(anchor)
	end
	menu:Show()
	Render()
end

function ns.HideMenu()
	menu:Hide()
end

-- Redraws the menu in place while it is open; a no-op otherwise.
function ns.RefreshMenu()
	Render()
end

function ns.IsMenuShown()
	return menu:IsShown()
end

-- True for the menu, its flyout, and anything inside them.
function ns.IsMenuFrame(frame)
	return frame ~= nil and Kit.IsInside(frame, menu)
end
