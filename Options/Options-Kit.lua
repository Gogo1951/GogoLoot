local ADDON_NAME, ns = ...

-- luacheck: read globals C_Container C_Item C_Timer ChatTypeInfo CHAT_PARTY_GET CHAT_WHISPER_GET CreateFrame
-- luacheck: read globals Enum GameTooltip GetUnitName InCombatLockdown LibStub NUM_BAG_SLOTS RAID_CLASS_COLORS
-- luacheck: read globals Settings UIParent UnitClass

--[[
    Options-Kit: the pieces every Gogo add-on's options panels are built from.

    Copied unchanged from Common-Core's addon-kits/Options-Kit/ into
    Options/Options-Kit.lua, first in the TOC's Options group, and checked byte
    for byte by CI. Never edit a copy: change Common-Core's and sync it.

    The kit knows nothing about the add-on. It reads only what every add-on
    already defines under one name: ns.PALETTE, ns.L, ns.db, ns.OPTIONS_REGISTRY,
    ns.FEATURES, ns:PrintMessage and, where they exist, ns.RefreshMenu,
    ns.UpdateMinimapIcon and ns.CLASS_COLORS. The strings it draws are handed to
    it once, localized, through Kit.SetText.

    Spec: Common-Core/Add-on Guide/References/Design System/Options Panels/
    Options-Kit.md. Rules: Style Guide → OPTIONS PANEL.
]]

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local format = string.format

local Kit = {}
ns.OptionsKit = Kit

--------------------------------------------------------------------------------
-- The Grid
--------------------------------------------------------------------------------

--[[
    AceConfigDialog sizes a widget at 170 points per width unit, so these are
    fractions of that, not points. Every row on every panel totals ROW_WIDTH, so
    every row ends where every other row ends; a label takes LABEL_WIDTH and its
    control CONTROL_WIDTH, so every dropdown on every panel lines up.

    The kit owns the grid and publishes it as ns.OPTIONS_* too, so panel code
    reads it where it always has. Data/Data.lua no longer defines it.
]]
Kit.UNIT_POINTS = 170
Kit.ROW_WIDTH = 3.4
Kit.LABEL_WIDTH = 2.1
Kit.CONTROL_WIDTH = Kit.ROW_WIDTH - Kit.LABEL_WIDTH
Kit.SUB_INDENT_WIDTH = 0.115 -- the blank cell a sub-option row leads with
Kit.SUB_LABEL_WIDTH = Kit.LABEL_WIDTH - Kit.SUB_INDENT_WIDTH -- a sub-row caption pays for its indent
Kit.PAIR_WIDTH = (Kit.ROW_WIDTH - 0.2) / 2 -- two to a line, with slack so the second never wraps
Kit.REMOVE_ICON_WIDTH = 0.25 -- a list row's remove column, sized to its icon
Kit.TAG_WIDTH = 0.55 -- a list row's one-word silver tag
Kit.SPEAKER_WIDTH = 0.15 -- a sound preview, past the row's end
Kit.TREE_PIXELS = 176 -- a tree group's sidebar, in points (Spacing Scale: past 128, a multiple of 16)
Kit.TREE_ROW_WIDTH = 2.5 -- what a tree group's pane has left beside its sidebar
Kit.TREE_LABEL_WIDTH = 1.2
Kit.TREE_CONTROL_WIDTH = Kit.TREE_ROW_WIDTH - Kit.TREE_LABEL_WIDTH

ns.OPTIONS_ROW_WIDTH = Kit.ROW_WIDTH
ns.OPTIONS_LABEL_WIDTH = Kit.LABEL_WIDTH
ns.OPTIONS_CONTROL_WIDTH = Kit.CONTROL_WIDTH
ns.OPTIONS_SUB_INDENT_WIDTH = Kit.SUB_INDENT_WIDTH
ns.OPTIONS_SUB_LABEL_WIDTH = Kit.SUB_LABEL_WIDTH
ns.OPTIONS_REMOVE_ICON_WIDTH = Kit.REMOVE_ICON_WIDTH
ns.OPTIONS_TREE_WIDTH = Kit.TREE_PIXELS
ns.OPTIONS_TREE_ROW_WIDTH = Kit.TREE_ROW_WIDTH

--------------------------------------------------------------------------------
-- Text and Color
--------------------------------------------------------------------------------

--[[
    Every string the kit draws, handed over once at load from the add-on's
    locale, under these keys in every add-on (Options-Kit.md → Strings):

      example       L["SAMPLE_EXAMPLE"]                      "Example"
      loading       L["LOADING_ITEM"]                        "Loading ID: %d"
      soundPreview  L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"]   the speaker's tooltip
      inCombat      L["CHAT_OPTIONS_IN_COMBAT"]              the Combat Guard's print
      reset         L["OPTIONS_RESET"]                       a Reset row's button
]]
local TEXT = {
	example = "Example",
	loading = "Loading ID: %d",
	soundPreview = "",
	inCombat = "",
	reset = "Reset",
}

function Kit.SetText(strings)
	for key, value in pairs(strings) do
		TEXT[key] = value
	end
end

-- A palette key or a six-digit hex, as the escape that opens it.
local function Open(key)
	return "|cff" .. ((ns.PALETTE and ns.PALETTE[key]) or key)
end

function Kit.Color(key, text)
	return Open(key) .. text .. "|r"
end

--[[
    The text in one color, as a chat frame draws a line in its channel's color.
    A panel's text falls back to white, not the line's color, when a |r closes
    more than the text itself opened, so the color is opened again there and
    only there. Colors the text opens and closes itself (a link, coins, the
    add-on's prefix) are left alone: the game keeps open colors on a short
    stack, and reopening after every |r piles onto it until a later color
    (the second line of an Example, its coins) drops to white. "||" is a
    literal pipe, not an escape.
]]
function Kit.Tint(key, text)
	local color = Open(key)
	local depth = 1
	local tinted = string.gsub(text, "|(.)", function(code)
		if code == "c" then
			depth = depth + 1
		elseif code == "r" then
			depth = depth - 1
			if depth == 0 then
				depth = 1
				return "|r" .. color
			end
		end
	end)
	return color .. tinted .. "|r"
end

--------------------------------------------------------------------------------
-- One Refresh
--------------------------------------------------------------------------------

--[[
    Every change shows everywhere at once: every panel repaints, the open menu
    redraws and the button's icon follows. Every writer ends here, the kit's own
    setters included, and none notifies a single panel by hand. A change with
    side effects (registering events, a chat line) does them first, then calls
    this. Style Guide → MINIMAP MENU → One Refresh.
]]
function ns.RefreshSettings()
	for _, registryName in pairs(ns.OPTIONS_REGISTRY or {}) do
		AceConfigRegistry:NotifyChange(registryName)
	end
	if ns.RefreshMenu then
		ns.RefreshMenu()
	end
	if ns.UpdateMinimapIcon then
		ns.UpdateMinimapIcon()
	end
end

--------------------------------------------------------------------------------
-- Reading and Writing Settings
--------------------------------------------------------------------------------

--[[
    A setting is named by its store and a dotted path: ("profile",
    "dispense.party"). The table is looked up on every read and write, never
    captured, because a profile switch replaces ns.db.profile.
]]
local function Resolve(store, path)
	local node = ns.db and ns.db[store]
	local parts = {}
	for part in string.gmatch(path, "[^%.]+") do
		parts[#parts + 1] = part
	end
	for index = 1, #parts - 1 do
		node = node and node[parts[index]]
	end
	return node, parts[#parts]
end

-- get(info) for a setting.
function Kit.Get(store, path)
	return function()
		local node, key = Resolve(store, path)
		if node then
			return node[key]
		end
	end
end

-- set(info, value) for a setting: writes, runs onSet for side effects, then refreshes.
function Kit.Set(store, path, onSet)
	return function(_, value)
		local node, key = Resolve(store, path)
		if node then
			node[key] = value
			if onSet then
				onSet(value)
			end
		end
		ns.RefreshSettings()
	end
end

--[[
    A dropdown's get for a setting whose saved value may no longer be one of its
    choices (a list that changed, a value saved by an older version): reads the
    default instead, so the dropdown never draws blank.
]]
function Kit.GetChoice(store, path, values, default)
	local get = Kit.Get(store, path)
	return function(info)
		local value = get(info)
		local choices = type(values) == "function" and values() or values
		if value == nil or choices[value] == nil then
			return default
		end
		return value
	end
end

--------------------------------------------------------------------------------
-- Text Widgets
--------------------------------------------------------------------------------

function Kit.Header(text, order, hidden)
	return { type = "header", name = Kit.Color("TITLE", text), order = order, hidden = hidden }
end

function Kit.Desc(text, order, hidden)
	return { type = "description", name = text, fontSize = "medium", order = order, hidden = hidden }
end

function Kit.Spacer(order, hidden)
	return { type = "description", name = " ", order = order, hidden = hidden }
end

--[[
    The label half of a label-beside-control row. With desc, it is the stock
    InteractiveLabel, so hovering the caption shows the control's tooltip as
    hovering the control does.
]]
function Kit.Label(text, order, width, desc)
	return {
		type = "description",
		name = text,
		desc = desc,
		dialogControl = desc and "InteractiveLabel" or nil,
		fontSize = "medium",
		width = width or Kit.LABEL_WIDTH,
		order = order,
	}
end

function Kit.SubLabel(text)
	return Kit.Color("HELP", text)
end

--[[
    A page's opening sections share one shape: spacer, gold header, spacer, and
    the section's description with a spacer under it when it has one. Writes
    them into args under keyPrefix and returns the next free order.
]]
function Kit.Section(args, keyPrefix, order, title, description, hidden)
	args[keyPrefix .. "Space0"] = Kit.Spacer(order, hidden)
	args[keyPrefix .. "Header"] = Kit.Header(title, order + 0.1, hidden)
	args[keyPrefix .. "Space1"] = Kit.Spacer(order + 0.2, hidden)
	if description then
		args[keyPrefix .. "Desc"] = Kit.Desc(description, order + 0.3, hidden)
		args[keyPrefix .. "Space2"] = Kit.Spacer(order + 0.4, hidden)
	end
	return order + 1
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
    One row of cells, left to right, in an unnamed inline group, which AceConfig
    draws as a bare SimpleGroup at fill width. The group is load-bearing: a fill
    widget always gets a line to itself, so one group pins one row, where cells
    laid out flat run into the next row the moment the leftover space fits it.

    The cells total at most ROW_WIDTH and none is "full", or the last tips onto
    a line of its own. hidden goes on the group, never on the cells, or the
    cells left behind hold the line open.
]]
function Kit.Row(order, hidden, cells)
	local args = {}
	for index, cell in ipairs(cells) do
		cell.order = index
		args["cell" .. index] = cell
	end
	return { type = "group", name = "", inline = true, order = order, hidden = hidden, args = args }
end

--[[
    A sub-option: a control that only means anything while the control above it
    is on. Marked twice, an indented control and a silver caption, so the
    dependency reads by shape and by color. The indent is a real cell: AceConfig
    pins a checkbox to its widget's left edge, so padding the caption would move
    only the words.
]]
function Kit.SubRow(order, hidden, cells)
	local row = Kit.Row(order, hidden, cells)
	row.args.indent = { type = "description", name = " ", width = Kit.SUB_INDENT_WIDTH, order = 0 }
	return row
end

--[[
    A silver line under a field, in the control column, for what a player needs
    before they hover: a limit or a consequence ("General reaches only your
    current layer."). The control's tooltip still carries its description.
]]
function Kit.Helper(order, hidden, text)
	return Kit.Row(order, hidden, {
		Kit.Label(" ", nil, Kit.LABEL_WIDTH),
		Kit.Label(Kit.Color("HELP", text), nil, Kit.CONTROL_WIDTH),
	})
end

-- One arg holding a row and, when there is helper text, the helper line under its control.
local function WithHelper(order, hidden, row, helper)
	if not helper then
		row.order, row.hidden = order, hidden
		return row
	end
	row.order = 1
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = { row = row, helper = Kit.Helper(2, nil, helper) },
	}
end

-- A caption and its dropdown, slider or box on one line, at the panel's own level, with an optional helper line.
function Kit.LabelRow(order, hidden, caption, control, desc, helper)
	control.name = ""
	control.width = Kit.CONTROL_WIDTH
	local row = Kit.Row(nil, nil, { Kit.Label(caption, nil, Kit.LABEL_WIDTH, desc or control.desc), control })
	return WithHelper(order, hidden, row, helper)
end

--[[
    A section's field sets, one under the other with a spacer between each: a
    field set is a control with what belongs to it (its sub-rows, its helper
    line, its Example). Returns one arg.
]]
function Kit.FieldSets(order, hidden, sets)
	local args = {}
	for index, set in ipairs(sets) do
		if index > 1 then
			args["space" .. index] = Kit.Spacer(index * 2 - 1)
		end
		set.order = index * 2
		args["set" .. index] = set
	end
	return { type = "group", name = "", inline = true, order = order, hidden = hidden, args = args }
end

-- The same under the control it belongs to: the caption pays for the indent, so the control keeps its column.
function Kit.SubLabelRow(order, hidden, caption, control, desc)
	control.name = ""
	control.width = Kit.CONTROL_WIDTH
	return Kit.SubRow(order, hidden, {
		Kit.Label(Kit.SubLabel(caption), nil, Kit.SUB_LABEL_WIDTH, desc or control.desc),
		control,
	})
end

-- An on/off choice under the control it belongs to.
function Kit.SubToggleRow(order, hidden, toggle)
	toggle.name = Kit.SubLabel(toggle.name)
	toggle.width = Kit.ROW_WIDTH - Kit.SUB_INDENT_WIDTH - 0.2
	return Kit.SubRow(order, hidden, { toggle })
end

--[[
    Toggles two to a line, each pair its own row, for the root panel's Features
    section and any run of short switches. Returns one arg; each toggle's width
    and order are set here.
]]
function Kit.Pairs(order, hidden, toggles)
	local args = {}
	for index = 1, #toggles, 2 do
		local pair = {}
		for offset = 0, 1 do
			local toggle = toggles[index + offset]
			if toggle then
				toggle.width = Kit.PAIR_WIDTH
				pair[offset + 1] = toggle
			end
		end
		args["pair" .. ((index + 1) / 2)] = Kit.Row((index + 1) / 2, nil, pair)
	end
	return { type = "group", name = "", inline = true, order = order, hidden = hidden, args = args }
end

--------------------------------------------------------------------------------
-- A Switch and What Rides With It
--------------------------------------------------------------------------------

-- AceGUI's checkbox: a 24-point box, then its caption in GameFontHighlight.
local CHECKBOX_POINTS = 24
-- Room past the caption's last letter, so a caption that fits never grazes the edge it would be cut at.
local CAPTION_SLACK_POINTS = 16

local captionMeasure

--[[
    The width in units a checkbox needs to show its caption whole, measured on a
    hidden font string in the checkbox's own font. AceGUI cuts a long caption
    short with "...", and a German or French caption runs half as long again as
    the English.
]]
function Kit.ToggleWidth(caption)
	if not captionMeasure then
		local frame = CreateFrame("Frame")
		frame:Hide()
		captionMeasure = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	end
	captionMeasure:SetText(caption)
	return (CHECKBOX_POINTS + captionMeasure:GetStringWidth() + CAPTION_SLACK_POINTS) / Kit.UNIT_POINTS
end

--[[
    A switch with its one setting on the same line, in the control column, and
    a sound switch's speaker past the row's end. Both leave while the switch is
    off. A speaker with no setting gets a blank cell in the setting's place, so
    every speaker on a panel lines up. When the caption won't fit the label
    column, the switch takes the whole line and its setting drops to the line
    below, still in its column. extras.helper puts a silver helper line under
    the setting, leaving with it. toggle.get is called with no info.
]]
function Kit.ToggleRow(order, toggle, extras)
	extras = extras or {}
	local control, preview = extras.control, extras.preview
	local function IsOff()
		return not toggle.get()
	end

	local args = { toggle = toggle }
	toggle.order = 1

	local rest = {}
	if control then
		control.name = ""
		control.width = Kit.CONTROL_WIDTH
		control.order = 2
		rest.control = control
	elseif preview then
		rest.controlSpace = { type = "description", name = " ", width = Kit.CONTROL_WIDTH, order = 2 }
	end
	if preview then
		preview.order = 3
		rest.preview = preview
	end

	if not next(rest) then
		toggle.width = "full"
	elseif type(toggle.name) == "string" and Kit.ToggleWidth(toggle.name) <= Kit.LABEL_WIDTH then
		toggle.width = Kit.LABEL_WIDTH
		for key, cell in pairs(rest) do
			cell.hidden = IsOff
			args[key] = cell
		end
	else
		toggle.width = "full"
		rest.filler = { type = "description", name = " ", width = Kit.LABEL_WIDTH, order = 1 }
		args.below = { type = "group", name = "", inline = true, order = 2, hidden = IsOff, args = rest }
	end

	if extras.helper then
		local helper = Kit.Helper(3, IsOff, extras.helper)
		args.helper = helper
	end

	return { type = "group", name = "", inline = true, order = order, hidden = extras.hidden, args = args }
end

--[[
    A speaker that plays a sound, for ToggleRow's preview. It plays whether or
    not the sound is switched on: hearing it before turning it on is the point.
    The client's own voice-chat speaker, at 16 points.
]]
function Kit.SoundPreview(play)
	return {
		type = "execute",
		name = "",
		desc = TEXT.soundPreview,
		image = "Interface\\Common\\VoiceChat-Speaker",
		imageWidth = 16,
		imageHeight = 16,
		width = Kit.SPEAKER_WIDTH,
		func = play,
	}
end

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    ns.FEATURES, in Options/Options-Utilities.lua, is the one list the root
    panel's Features section, each feature panel's Enable switch and the
    mini-map menu all build from, in menu order: blocks first, then More
    Features. Each record:

      store, setting   where the switch lives: ns.db[store] and a dotted path ("strangers.enabled")
      name             the feature's name key (menu title, panel name)
      caption, desc    the Enable switch's caption and tooltip keys
      block            true for a feature players flip mid-session
      apply(value)     optional: writes the value and its side effects; default writes it
      confirm          optional: a key asked before switching off
      click            optional: the button click its Toggle row names (MINIMAP MENU)
      gate()           optional: true when this character can use it (menu only)
      opensOptions     optional: an OPTIONS_REGISTRY key its More Features row opens
]]
local function FindFeature(setting)
	for _, feature in ipairs(ns.FEATURES or {}) do
		if feature.setting == setting then
			return feature
		end
	end
	error(ADDON_NAME .. ": no ns.FEATURES entry for " .. tostring(setting), 2)
end

function Kit.FeatureSwitch(setting, order, width)
	local feature = FindFeature(setting)
	local L = ns.L
	return {
		type = "toggle",
		name = L[feature.caption],
		desc = L[feature.desc],
		order = order,
		width = width or "full",
		confirm = feature.confirm and function(_, value)
			return not value and L[feature.confirm] or false
		end or nil,
		get = function()
			local node, key = Resolve(feature.store, feature.setting)
			return node and node[key]
		end,
		set = function(_, value)
			local node, key = Resolve(feature.store, feature.setting)
			if feature.apply then
				feature.apply(value)
			elseif node then
				node[key] = value
			end
			ns.RefreshSettings()
		end,
	}
end

-- The root panel's Features switches, two to a line, in ns.FEATURES order. One arg.
function Kit.FeatureSwitches(order)
	local toggles = {}
	for _, feature in ipairs(ns.FEATURES or {}) do
		toggles[#toggles + 1] = Kit.FeatureSwitch(feature.setting)
	end
	return Kit.Pairs(order, nil, toggles)
end

--------------------------------------------------------------------------------
-- Lines
--------------------------------------------------------------------------------

--[[
    A silver line that shows only while something elsewhere changes what this
    page does: Bag-Space Warnings holding slots back, a reload pending, the
    parent feature switched off. getText returns nil to hide it.
]]
function Kit.StatusLine(getText, order)
	return {
		type = "description",
		name = function()
			local text = getText()
			return text and Kit.Color("HELP", text) or ""
		end,
		fontSize = "medium",
		order = order,
		hidden = function()
			return getText() == nil
		end,
	}
end

--[[
    A red line that shows only while the settings mean nothing will happen:
    every box in a must-pick-one set unticked, a message too long to send.
    isWrong returns true to show it.
]]
function Kit.WarningLine(text, isWrong, order)
	return {
		type = "description",
		name = function()
			return Kit.Color("OFF", type(text) == "function" and text() or text)
		end,
		fontSize = "medium",
		order = order,
		hidden = function()
			return not isWrong()
		end,
	}
end

--------------------------------------------------------------------------------
-- Example Lines
--------------------------------------------------------------------------------

--[[
    What a chat-printing feature will print or send, drawn exactly as it
    arrives, closing the field set of the control that decides it:

      -- spacer
      Example
          [Party] [Aero]: Come & get it! [Peacebloom] in Teldrassil
          a second line, only when how the lines look together matters

    A spacer keeps it clear of the controls above, the silver "Example" label
    sits on its own line with no colon (a locale still on "Example: %s" loses
    its colon here, full-width colon included), and the message lines sit
    under it, indented like a sub-option and aligned with each other. getLines returns the finished line,
    or a list of lines, built through the feature's own builder on every draw,
    so the Example follows the settings and a reworded message rewords it.
]]
local FULL_WIDTH_COLON = "\239\188\154" -- U+FF1A, as Chinese locales write it

local function ExampleLabel()
	local label = format(TEXT.example, "")
	repeat
		local before = label
		label = string.gsub(label, "%s+$", "")
		label = string.gsub(label, ":$", "")
		label = string.gsub(label, FULL_WIDTH_COLON .. "$", "")
	until label == before
	return Kit.Color("HELP", label)
end

function Kit.Example(order, hidden, getLines)
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = {
			space = Kit.Spacer(1),
			label = { type = "description", name = ExampleLabel, fontSize = "medium", order = 2 },
			lines = Kit.SubRow(3, nil, {
				{
					type = "description",
					name = function()
						local lines = getLines()
						return type(lines) == "table" and table.concat(lines, "\n") or lines
					end,
					fontSize = "medium",
					width = Kit.ROW_WIDTH - Kit.SUB_INDENT_WIDTH,
				},
			}),
		},
	}
end

local SENT_FORMS = {
	PARTY = { chatType = "PARTY", hex = "AAAAFF", prefix = CHAT_PARTY_GET or "[Party] %s: " },
	WHISPER = { chatType = "WHISPER", hex = "FF80FF", prefix = CHAT_WHISPER_GET or "%s whispers: " },
}

local function ChatColor(form)
	local info = ChatTypeInfo and ChatTypeInfo[form.chatType]
	if not info then
		return form.hex
	end
	return format("%02x%02x%02x", info.r * 255 + 0.5, info.g * 255 + 0.5, info.b * 255 + 0.5)
end

-- A class token's color as six hex digits: the add-on's ns.CLASS_COLORS, else the client's.
function Kit.ClassColor(classFile)
	local hex = ns.CLASS_COLORS and ns.CLASS_COLORS[classFile]
	if hex then
		return hex
	end
	local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
	return color and color.colorStr and string.sub(color.colorStr, 3) or "FFFFFF"
end

-- "You": the character the panel is open on, in its class color, read as the line is drawn.
function Kit.You()
	local _, classFile = UnitClass("player")
	return Kit.Color(Kit.ClassColor(classFile), GetUnitName("player") or "")
end

-- Raid-marker tokens as the icons chat shows in their place.
function Kit.Markers(text)
	return (
		string.gsub(text, "{rt(%d)}", function(index)
			return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. index .. ":0|t"
		end)
	)
end

--[[
    A sent message as the person receiving it sees it: "[Party] [You]: …" or
    "[You] whispers: …", in that channel's color as the player has set it.
    formKey is "PARTY" (every group channel is drawn as party) or "WHISPER".
]]
function Kit.SentLine(formKey, message)
	local form = SENT_FORMS[formKey]
	return Kit.Tint(ChatColor(form), format(form.prefix, "[" .. Kit.You() .. "]") .. Kit.Markers(message))
end

-- A print as the player's own window shows it: printLine is the add-on's print helper's finished string.
function Kit.PrintedLine(printLine)
	return Kit.Tint("TEXT", printLine)
end

--------------------------------------------------------------------------------
-- Reset
--------------------------------------------------------------------------------

--[[
    A Reset for a setting that takes real effort to put back by hand: on its
    own row, its button in the control column so it lines up with the controls
    above it. isDefault returns true while there is nothing to reset, which
    grays the button. confirmText, when given, is asked first: pass one when it
    discards more than one value. Style Guide → SAVED VARIABLES → Reset.
]]
function Kit.ResetRow(order, hidden, caption, desc, isDefault, reset, confirmText)
	return Kit.Row(order, hidden, {
		Kit.Label(caption or " ", nil, Kit.LABEL_WIDTH),
		{
			type = "execute",
			name = TEXT.reset,
			desc = desc,
			width = Kit.CONTROL_WIDTH,
			disabled = isDefault,
			confirm = confirmText and true or nil,
			confirmText = confirmText,
			func = function()
				reset()
				ns.RefreshSettings()
			end,
		},
	})
end

--------------------------------------------------------------------------------
-- Hiding a Page Behind Its Switch
--------------------------------------------------------------------------------

--[[
    Hides every arg but those named in keep while isHidden says so, composed
    with each arg's own hidden, so a feature switched off leaves only its
    description and switch on the page, as the menu leaves only its title.
]]
function Kit.HideAllExcept(args, isHidden, keep)
	local kept = {}
	for _, key in ipairs(keep) do
		kept[key] = true
	end
	for key, arg in pairs(args) do
		if not kept[key] then
			local own = arg.hidden
			arg.hidden = function(info)
				if isHidden() then
					return true
				end
				if type(own) == "function" then
					return own(info)
				end
				return own
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Items
--------------------------------------------------------------------------------

local GetItemInfo = C_Item.GetItemInfo

--[[
    The bags a player carries: the backpack, the four bag slots and, where the
    client has one, the reagent bag.
]]
local CARRIED_BAGS = {}
for bag = 0, NUM_BAG_SLOTS or 4 do
	CARRIED_BAGS[#CARRIED_BAGS + 1] = bag
end
if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
	CARRIED_BAGS[#CARRIED_BAGS + 1] = Enum.BagIndex.ReagentBag
end

-- A bare ID or a whole item link, as shift-clicking a link drops it into a box. Anything else is nil.
function Kit.ParseItem(rawInput)
	if type(rawInput) ~= "string" then
		return nil
	end
	local itemId = tonumber(rawInput:match("item:(%d+)") or rawInput:match("^%s*(%d+)%s*$"))
	if itemId and itemId > 0 and (not C_Item.DoesItemExistByID or C_Item.DoesItemExistByID(itemId)) then
		return itemId
	end
	return nil
end

-- Icon and the item's own colored link without brackets, or a gray loading line until the client has it.
function Kit.ItemName(itemId)
	local _, itemLink, _, _, _, _, _, _, _, icon = GetItemInfo(itemId)
	if itemLink then
		local bare = string.gsub(itemLink, "[%[%]]", "")
		return icon and format("|T%s:16|t %s", icon, bare) or bare
	end
	return Kit.Color("MUTED", format(TEXT.loading, itemId))
end

--[[
    By name, because a list ordered by ID reads as random. Uncached items sink
    to the bottom by ID until they load; equal names tie-break on ID, so rows
    never reshuffle between repaints.
]]
function Kit.SortItems(itemIds)
	table.sort(itemIds, function(a, b)
		local nameA, nameB = GetItemInfo(a) or "", GetItemInfo(b) or ""
		if nameA == nameB then
			return a < b
		elseif nameA == "" then
			return false
		elseif nameB == "" then
			return true
		end
		return nameA < nameB
	end)
end

--[[
    Asks the server for items the client hasn't cached and repaints as they
    land: one bounded poll per registry name, watching every cold ID handed in
    while it runs, repainting only when one arrives, and giving up on an ID the
    server never answers for.
]]
local WARM_RETRY_SECONDS = 0.5
local WARM_MAX_ATTEMPTS = 10
local warming, attempts = {}, {}

function Kit.WarmItems(itemIds, registryName)
	if not (itemIds and itemIds[1] and registryName) then
		return
	end
	local outstanding = warming[registryName]
	local running = outstanding ~= nil
	if not outstanding then
		outstanding = {}
		warming[registryName] = outstanding
	end
	for _, itemId in ipairs(itemIds) do
		C_Item.RequestLoadItemDataByID(itemId)
		if not outstanding[itemId] then
			outstanding[itemId] = true
			attempts[registryName] = 0
		end
	end
	if running then
		return
	end

	local function Poll()
		attempts[registryName] = attempts[registryName] + 1
		local anyWarm, anyCold = false, false
		for itemId in pairs(outstanding) do
			if GetItemInfo(itemId) then
				outstanding[itemId] = nil
				anyWarm = true
			else
				anyCold = true
			end
		end
		if anyWarm then
			AceConfigRegistry:NotifyChange(registryName)
		end
		if anyCold and attempts[registryName] < WARM_MAX_ATTEMPTS then
			C_Timer.After(WARM_RETRY_SECONDS, Poll)
		else
			warming[registryName], attempts[registryName] = nil, nil
		end
	end
	C_Timer.After(WARM_RETRY_SECONDS, Poll)
end

--[[
    The item cell: icon and colored link, the item's own tooltip on hover. An
    input whose dialogControl is this type hands it the item ID as text.
]]
Kit.ITEM_LINK_WIDGET = ADDON_NAME .. "_ItemLink"

do
	local methods = {}

	function methods:OnAcquire()
		self.itemId = nil
		self:SetHeight(20)
	end

	function methods:OnRelease()
		self.itemId = nil
	end

	function methods:SetText(text)
		self.itemId = tonumber(text)
		self.label:SetText(self.itemId and Kit.ItemName(self.itemId) or text or "")
	end

	function methods:GetText()
		return self.itemId and tostring(self.itemId) or ""
	end

	-- AceConfigDialog drives every input through these; the cell is read-only.
	function methods.SetLabel() end
	function methods.SetMaxLetters() end
	function methods.SetDisabled() end

	local function OnEnter(frame)
		local widget = frame.obj
		if widget.itemId then
			-- The bare "item:id" form, so a row still loading gets a tooltip, and hovering pulls the data it waits for.
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink("item:" .. widget.itemId)
			GameTooltip:Show()
		end
	end

	local function OnLeave()
		GameTooltip:Hide()
	end

	local function Constructor()
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetHeight(20)
		frame:EnableMouse(true)
		frame:SetScript("OnEnter", OnEnter)
		frame:SetScript("OnLeave", OnLeave)
		local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		label:SetJustifyH("LEFT")
		label:SetPoint("TOPLEFT")
		label:SetPoint("BOTTOMRIGHT")
		local widget = { frame = frame, label = label, type = Kit.ITEM_LINK_WIDGET }
		for name, method in pairs(methods) do
			widget[name] = method
		end
		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(Kit.ITEM_LINK_WIDGET, Constructor, 1)
end

local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"

local function CarriedItemChoices(sourceTable)
	local values, sorting, seen = {}, {}, {}
	for _, bag in ipairs(CARRIED_BAGS) do
		for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local itemId = info and info.itemID
			if itemId and not seen[itemId] and not (sourceTable and sourceTable[itemId]) then
				seen[itemId] = true
				values[itemId] = Kit.ItemName(itemId)
				sorting[#sorting + 1] = itemId
			end
		end
	end
	Kit.SortItems(sorting)
	return values, sorting
end

--[[
    A player-managed list of items. The panel supplies the words, the source
    table and the callbacks; the kit owns the shape (Build Reference → Item
    Lists): Add from Bags, Add Item, one row per item sorted by name, then
    Restore Defaults and Clear List at the foot. Returns args to merge into a
    page or a tree pane. Spec:

      getSourceTable()   the table whose keys are the listed item IDs
      onAdd(itemId), onRemove(itemId)
      onRestore()        optional: puts the list back to its defaults (confirmed)
      onClear()          optional: empties it (confirmed; shown while not empty)
      labels             addName, addHelp, addInvalid, removeDesc, empty, plus
                         fromBagsName/fromBagsDesc, restoreName/restoreDesc/
                         restoreConfirm and clearName/clearDesc/clearConfirm
                         for the optional parts
      addFromBags        true for the Add from Bags picker
      rowWidth           ROW_WIDTH, or TREE_ROW_WIDTH in a tree pane
      startOrder         the first order, so a page can seat its own head above
      registryName       the panel to repaint as cold items load
      actionColumn       optional per-row cell: { type = "execute", name, desc,
                         width, func(itemId), confirm? } or { type = "select",
                         desc, values, sorting, width, get(itemId), set(itemId, v) }
      getRowTag(itemId)  optional: one short silver word, or nil
]]
function Kit.ItemList(spec)
	local labels = spec.labels
	local rowWidth = spec.rowWidth or Kit.ROW_WIDTH
	local order = spec.startOrder or 1
	local args = {}

	local function Changed()
		ns.RefreshSettings()
	end

	if spec.addFromBags then
		local values, sorting = CarriedItemChoices(spec.getSourceTable())
		args.addFromBags = Kit.Row(order, nil, {
			Kit.Label(labels.fromBagsName, nil, rowWidth - Kit.CONTROL_WIDTH, labels.fromBagsDesc),
			{
				type = "select",
				name = "",
				desc = labels.fromBagsDesc,
				width = Kit.CONTROL_WIDTH,
				values = values,
				sorting = sorting,
				disabled = function()
					return sorting[1] == nil
				end,
				get = function() end,
				set = function(_, itemId)
					spec.onAdd(itemId)
					Changed()
				end,
			},
		})
		order = order + 1
	end

	args.addItem = Kit.Row(order, nil, {
		Kit.Label(labels.addName, nil, rowWidth - Kit.CONTROL_WIDTH, labels.addHelp),
		{
			type = "input",
			name = "",
			desc = labels.addHelp,
			width = Kit.CONTROL_WIDTH,
			validate = function(_, value)
				return Kit.ParseItem(value) and true or labels.addInvalid
			end,
			get = function()
				return ""
			end,
			set = function(_, value)
				local itemId = Kit.ParseItem(value)
				if itemId then
					spec.onAdd(itemId)
					Changed()
				end
			end,
		},
	})
	args.spacerRows = Kit.Spacer(order + 1)
	order = order + 2

	local source = spec.getSourceTable() or {}
	local itemIds = {}
	for itemId in pairs(source) do
		itemIds[#itemIds + 1] = itemId
	end

	if not itemIds[1] then
		args.empty = Kit.Desc(Kit.Color("HELP", labels.empty), order)
	end
	Kit.SortItems(itemIds)

	local action = spec.actionColumn
	local itemWidth = rowWidth - Kit.REMOVE_ICON_WIDTH - (action and action.width or 0)
	local cold = {}

	for _, itemId in ipairs(itemIds) do
		if not GetItemInfo(itemId) then
			cold[#cold + 1] = itemId
		end
		local tag = spec.getRowTag and spec.getRowTag(itemId)
		local cells = {
			{
				type = "input",
				name = "",
				dialogControl = Kit.ITEM_LINK_WIDGET,
				width = tag and (itemWidth - Kit.TAG_WIDTH) or itemWidth,
				get = function()
					return tostring(itemId)
				end,
				set = function() end,
			},
		}
		if tag then
			cells[#cells + 1] = Kit.Desc(Kit.Color("HELP", tag))
			cells[#cells].width = Kit.TAG_WIDTH
		end
		if action and action.type == "execute" then
			cells[#cells + 1] = {
				type = "execute",
				name = action.name,
				desc = action.desc,
				width = action.width,
				confirm = action.confirm,
				func = function()
					action.func(itemId)
					Changed()
				end,
			}
		elseif action then
			cells[#cells + 1] = {
				type = "select",
				name = "",
				desc = action.desc,
				values = action.values,
				sorting = action.sorting,
				width = action.width,
				get = function()
					return action.get(itemId)
				end,
				set = function(_, value)
					action.set(itemId, value)
					Changed()
				end,
			}
		end
		-- An item the player can put back in seconds removes on one click, no confirm.
		cells[#cells + 1] = {
			type = "execute",
			name = "",
			desc = labels.removeDesc,
			image = REMOVE_ICON,
			imageWidth = 16,
			imageHeight = 16,
			width = Kit.REMOVE_ICON_WIDTH,
			func = function()
				spec.onRemove(itemId)
				Changed()
			end,
		}
		args["item" .. itemId] = Kit.Row(order, nil, cells)
		order = order + 1
	end

	-- The top of a list is for finding and adding; a rarely used reset goes at its foot.
	local canClear = spec.onClear and itemIds[1] ~= nil
	if spec.onRestore or canClear then
		args.spacerFoot = Kit.Spacer(order)
		local foot = {}
		if spec.onRestore then
			foot[#foot + 1] = {
				type = "execute",
				name = labels.restoreName,
				desc = labels.restoreDesc,
				confirm = true,
				confirmText = labels.restoreConfirm,
				func = function()
					spec.onRestore()
					Changed()
				end,
			}
		end
		if canClear then
			foot[#foot + 1] = {
				type = "execute",
				name = labels.clearName,
				desc = labels.clearDesc,
				confirm = true,
				confirmText = labels.clearConfirm,
				func = function()
					spec.onClear()
					Changed()
				end,
			}
		end
		args.foot = Kit.Row(order + 1, nil, foot)
	end

	Kit.WarmItems(cold, spec.registryName)
	return args
end

--------------------------------------------------------------------------------
-- Panels
--------------------------------------------------------------------------------

local panels = {} -- registry key → { frame, categoryID }

--[[
    Registers one panel and adds it to the Settings tree. builder is the
    panel's builder function, registered as the function so every repaint
    rebuilds the table; parentKey nests it under that panel by the category ID
    its registration returned (AceConfigDialog resolves only the root by name).
    Call in tree order: the root, each feature panel followed by its
    sub-panels, then Profiles, Feedback & Support, Diagnostic Tools.
]]
function Kit.RegisterPanel(key, builder, displayName, parentKey)
	local registryName = ns.OPTIONS_REGISTRY[key]
	AceConfigRegistry:RegisterOptionsTable(registryName, builder)
	local parent
	if parentKey then
		parent = panels[parentKey] and panels[parentKey].categoryID
	elseif next(panels) then
		parent = ns.L["ADDON_TITLE"]
	end
	local frame, categoryID = AceConfigDialog:AddToBlizOptions(registryName, displayName, parent)
	panels[key] = { frame = frame, categoryID = categoryID }
	return frame, categoryID
end

-- A sub-panel's page title: "Farm Mode > Abilities". The tree shows the plain name.
function Kit.SubPanelTitle(parentName, name)
	return parentName .. " > " .. name
end

--[[
    A tree group's sidebar width, and the pane it opens on: home() returns the
    group key to select (the current character), at registration and again
    every time the panel closes, so it always reopens there.
]]
function Kit.PrepareTree(key, home)
	local status = AceConfigDialog:GetStatusTable(ns.OPTIONS_REGISTRY[key])
	status.groups = status.groups or {}
	status.groups.treewidth = Kit.TREE_PIXELS
	status.groups.selected = home()
	local panel = panels[key]
	if panel and panel.frame then
		panel.frame:HookScript("OnHide", function()
			status.groups.selected = home()
		end)
	end
end

--[[
    Opens the root panel, or any panel by its registry key, inside the Blizzard
    Options/Settings interface. Refused in combat with the mandated print, every
    time it's asked, never queued (Style Guide → OPTIONS PANEL → Combat Guard).
    Routed by the category ID captured at registration, never by a name.
]]
function ns:OpenOptionsPanel(key)
	if InCombatLockdown() then
		ns:PrintMessage(TEXT.inCombat)
		return
	end
	local panel = panels[key] or panels.General
	if not panel then
		return
	end
	if Settings and Settings.OpenToCategory and panel.categoryID then
		Settings.OpenToCategory(panel.categoryID)
		return
	end
	-- Last resort, reached only if registration returned no category ID: a floating window, a visible symptom.
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY[key] or ns.OPTIONS_REGISTRY.General)
end

-- Whether any of the add-on's panels is on screen, read live: IsVisible goes false when the Settings window closes.
function ns.IsOptionsPanelOpen()
	for _, panel in pairs(panels) do
		if panel.frame and panel.frame:IsVisible() then
			return true
		end
	end
	return false
end
