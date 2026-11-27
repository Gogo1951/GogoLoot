--------------------------------------------------------------------------------
-- GogoLoot Mini-map Menu
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

--[[
    GogoLoot only builds entries; opening, placing, closing and clicks are
    Menu-Kit's. Every row is a plain click, so a controller's cursor reaches all
    of it.
]]

local LIST_MAX = Kit.LIST_MAX -- A list's rows before a note counts the rest (Blocks Beyond Features → Long lists)

Kit.SetText({
	on = L["MENU_ON"],
	off = L["MENU_OFF"],
	toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"],
	moreFeatures = L["MENU_MORE_FEATURES"],
	featuresOn = L["MENU_FEATURE_COUNT_ON"],
	featuresOff = L["MENU_FEATURE_COUNT_OFF"],
	count = L["ITEM_QUANTITY"],
	loading = L["LOADING_ITEM"],
	shortName = L["ADDON_SHORT_NAME"],
})

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function FeatureTooltip(setting)
	local feature = ns.GetFeature(setting)
	return Kit.OptionTooltip(L[feature.caption], ns.FeatureDescription(feature))
end

local function IsFeatureOn(feature)
	local store = ns.db[feature.store]
	return store and store[feature.setting] and true or false
end

-- After every row click: open options pages, the menu and the button's icon redraw.
local function AfterChange()
	ns.RefreshSettings()
end

local OnOff = Kit.OnOff

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------

-- The way its options switch does: the ns.FEATURES apply with every side effect, else a plain write.
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

--------------------------------------------------------------------------------
-- Button Clicks
--------------------------------------------------------------------------------

-- Left-Click opens and holds the menu, or closes one it holds; no other click has a job.
local menu

---@param anchor table
---@param button string
---@return boolean
function ns.RunButtonClick(anchor, button)
	return menu ~= nil and menu:HandleClick(anchor, button) or false
end

--------------------------------------------------------------------------------
-- Locked Items
--------------------------------------------------------------------------------

--[[
    Locked Items leads: it is the one part that changes with the bags rather
    than a setting. A count shows only above one, so no locale needs a plural.
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
	-- The Rogue hint waits for the spell's name rather than showing a blank one.
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

-- Manual has no art; a blank of the same size, cut from the Pass art's transparent corner, keeps the labels lined up.
local ICON_SIZE = 32 -- The art's square; only the ratio matters for the crop
local BLANK_ICON = "|T" .. ns.ROLL_ICONS[ns.PASS] .. ":0:0:0:0:" .. ICON_SIZE .. ":" .. ICON_SIZE .. ":0:1:0:1|t"

-- A roll's icon then a space.
local function RollIcon(action)
	local path = ns.ROLL_ICONS[action]
	if not path then
		return BLANK_ICON .. " "
	end
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
		.. ":255:255:255|t "
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
	local thresholdLabel = ns.ROLL_THRESHOLD_LABELS[profile[context.thresholdKey]] or ""
	return RollIcon(action) .. L["MENU_ROLLS_SETTING"]:format(actionLabel, thresholdLabel)
end

local function RollSettingRows()
	local rows = {}
	for _, context in ipairs(ROLL_CONTEXTS) do
		rows[#rows + 1] = {
			kind = "value",
			left = context.name,
			leftColor = "BODY",
			right = ns.MenuRollSetting(context),
			submenu = context.flyout,
		}
	end
	rows[#rows + 1] = { kind = "value", left = L["MENU_ROLL_AUDIT"], submenu = "rollAudit" }
	return rows
end

local ROLL_WORDS = {
	[ns.ROLL_KIND_NEED] = NEED,
	[ns.ROLL_KIND_GREED] = GREED,
	[ns.ROLL_KIND_DISENCHANT] = ROLL_DISENCHANT,
	PASS = PASS,
	NO_ROLL = L["MENU_ROLL_AUDIT_NO_ROLL"],
}

local function AuditName(line)
	local name = line.isPlayer and L["MENU_ROLL_AUDIT_YOU"] or line.name or "?"
	return (ns.GetClassColor(line.classFile) or ns.GetColor("TEXT")) .. name .. "|r"
end

local function AuditResult(line)
	local word = ROLL_WORDS[line.kind] or ""
	if line.roll then
		return L["MENU_ROLL_AUDIT_RESULT"]:format(word, line.roll)
	end
	return word
end

local function AuditLines(roll)
	local rows = {}
	for _, line in ipairs(roll.lines) do
		rows[#rows + 1] = { kind = "value", left = AuditName(line), right = AuditResult(line) }
	end
	return rows
end

local function AuditWinner(roll)
	local winner = roll.winner
	if roll.everyonePassed or not winner then
		return L["MENU_ROLL_AUDIT_ALL_PASSED"], "MUTED"
	end
	local word = ROLL_WORDS[winner.kind]
	if word and winner.kind ~= "PASS" and winner.kind ~= "NO_ROLL" then
		return L["MENU_ROLL_AUDIT_WINNER"]:format(AuditName(winner), word), nil
	end
	return AuditName(winner), nil
end

---@return table[]
local function RollAuditFlyout()
	local entries = { { kind = "section", left = L["MENU_RECENT_ROLLS"] } }
	local audit = ns.GetRollAudit()
	if #audit == 0 then
		entries[#entries + 1] = { kind = "note", left = L["MENU_ROLL_AUDIT_EMPTY"] }
		return entries
	end
	local rows = {}
	for index, roll in ipairs(audit) do
		local right, rightColor = AuditWinner(roll)
		rows[#rows + 1] = {
			kind = "item",
			link = roll.itemLink,
			right = right,
			rightColor = rightColor,
			submenu = "rollAudit" .. index,
			flyout = #roll.lines > 0 and function()
				return AuditLines(roll)
			end or nil,
		}
	end
	Kit.List(entries, rows)
	return entries
end

-- closes: the kit hides the menu before the refresh, so it isn't redrawn on its way out.
local function ChoiceRow(label, selected, key, value)
	return {
		kind = "choice",
		left = label,
		selected = selected,
		closes = true,
		onClick = function()
			ns.db.profile[key] = value
		end,
	}
end

local function PageLink(label, panelKey, right)
	return {
		kind = "action",
		left = label,
		right = right,
		rightColor = right and "MUTED" or nil,
		closes = true,
		onClick = function()
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
		rows[#rows + 1] =
			ChoiceRow(RollIcon(action) .. ns.ROLL_OVERRIDE_LABELS[action], selected, context.actionKey, action)
	end

	rows[#rows + 1] = { kind = "section", left = L["ROLLS_UP_TO_QUALITY"] }
	for _, quality in ipairs(THRESHOLD_ORDER) do
		local selected = profile[context.thresholdKey] == quality
		rows[#rows + 1] = ChoiceRow(ns.ROLL_THRESHOLD_LABELS[quality] or "", selected, context.thresholdKey, quality)
	end
	rows[#rows + 1] = { kind = "spacer" }
	rows[#rows + 1] = {
		kind = "toggle",
		left = L["ROLLS_INCLUDE_BIND_ON_PICKUP"],
		on = profile[context.bindOnPickupKey] and true or false,
		tooltip = Kit.OptionTooltip(L["ROLLS_INCLUDE_BIND_ON_PICKUP"], L["ROLLS_INCLUDE_BIND_ON_PICKUP_DESCRIPTION"]),
		onClick = function()
			profile[context.bindOnPickupKey] = not profile[context.bindOnPickupKey]
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

local function AddFeature(entries, block)
	local feature = ns.GetFeature(block.setting)
	Kit.FeatureBlock(entries, {
		title = block.title,
		state = block.right,
		stateColor = block.rightColor,
		description = block.description,
		note = block.note,
		rows = block.rows,
		toggle = {
			name = L[feature.caption],
			desc = ns.FeatureDescription(feature),
			flip = function()
				ns.FlipFeature(block.setting)
			end,
		},
	})
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
FLYOUTS.rollAudit = RollAuditFlyout

-- Drawn here rather than with Kit.MoreFeatures, whose tooltips can't fill a description's %s slots.
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
	local onText = ns.GetColor("ON") .. L["MENU_FEATURE_COUNT_ON"]:format(on) .. "|r"
	local offText = L["MENU_FEATURE_COUNT_OFF"]:format(off)
	entries[#entries + 1] = {
		kind = "submenu",
		left = L["MENU_MORE_FEATURES"],
		right = onText .. ns.GetColor("TEXT") .. ",|r " .. offText,
		submenu = "features",
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
		setting = "autoOpen",
	})

	right, rightColor = OnOff(profile.lootNotifications)
	AddFeature(entries, {
		title = L["TAB_ANNOUNCEMENTS"],
		right = right,
		rightColor = rightColor,
		description = L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"],
		setting = "lootNotifications",
	})

	AddMoreFeatures(entries)

	Kit.OptionsRow(entries, L["MENU_OPTIONS"])
	return entries
end

---@param key string
---@return table[]|nil
function ns.BuildMenuFlyout(key)
	return FLYOUTS[key] and FLYOUTS[key]()
end

--------------------------------------------------------------------------------
-- The Menu
--------------------------------------------------------------------------------

-- Also sets ns.ShowMenu, ns.HideMenu, ns.RefreshMenu, ns.IsMenuShown, ns.IsMenuFrame and ns.OpenFlyout.
menu = Kit.CreateMenu({
	name = ADDON_NAME .. "Menu",
	build = function()
		return ns.BuildMenuEntries()
	end,
	flyouts = FLYOUTS,
	afterChange = AfterChange,
})
