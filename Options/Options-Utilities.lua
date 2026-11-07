--------------------------------------------------------------------------------
-- GogoLoot Options — Utilities
--------------------------------------------------------------------------------

--[[
    The building blocks every Options panel uses: the AceConfig widget helper
    constructors, toggle rows, the feature-off note, quality choices and
    message examples. The item lists are built in
    Options-Utilities-Item-Lists.lua, over Options-Utilities-Item-Cache.lua and
    Options-Utilities-Item-List-Filter.lua.
]]
local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- AceConfig Widget Helpers
--------------------------------------------------------------------------------

--[[
    Shared by all Options-*.lua files. Defined with `.` (not `:`) — they
    don't use self, and dot definitions force dot invocation, matching the
    panel builder functions.
]]

---@param text string
---@param order number
---@param hidden? boolean|function
---@return table
function ns.OptionsHeader(text, order, hidden)
	return {
		type = "header",
		name = GetColor("TITLE") .. text .. "|r",
		order = order,
		hidden = hidden,
	}
end

---@param text string|function
---@param order number
---@return table
function ns.OptionsDesc(text, order)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		order = order,
	}
end

---@param order number
---@param hidden? boolean|function
---@return table
function ns.OptionsSpacer(order, hidden)
	return {
		type = "description",
		name = " ",
		order = order,
		hidden = hidden,
	}
end

--[[
    A child panel's line saying the feature it belongs to is off, so a page of
    settings nothing is using doesn't read as live. Its trailing spacer comes
    with it, and both leave while the feature is on. The whole line takes the
    Off red, which keeps each sentence one string in every locale. `text` may
    be a function, for a line whose wording depends on other settings. Returns
    the next free order.
]]
---@param args table
---@param order number
---@param text string|function
---@param featureOn function # true while the parent feature's switch is on
---@return number
function ns.AddFeatureOffNote(args, order, text, featureOn)
	local name = type(text) == "function" and function()
		return GetColor("OFF") .. text() .. "|r"
	end or GetColor("OFF") .. text .. "|r"
	args.featureOffNote = {
		type = "description",
		name = name,
		fontSize = "medium",
		order = order,
		hidden = featureOn,
	}
	args.spacerAfterFeatureOffNote = ns.OptionsSpacer(order + 1, featureOn)
	return order + 2
end

--[[
    The left half of a label-beside-control row. Pair it with a control whose
    own `name` is "" and whose width is ns.OPTIONS_CONTROL_WIDTH, ordered
    immediately after this cell, and the two flow onto one line instead of the
    control stacking under its own label.

    `text` may be a string or a function, exactly as AceConfig's `name` accepts.

    `width` overrides ns.OPTIONS_LABEL_WIDTH for the rare row whose control
    needs more room than the default split leaves it (the copyable URL boxes).
    Whatever it takes, give the control ns.OPTIONS_ROW_WIDTH minus that, so the
    row still ends where every other row does.
]]
---@param text string|function
---@param order number
---@param width? number
---@return table
function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end

--[[
    One row of cells, left to right, wrapped in an inline group with no name,
    which AceConfig renders as a bare SimpleGroup — no border, no title, no
    padding — at "fill" width. That wrapper is load-bearing, not decoration.
    Laid out flat, a row's cells are just more widgets in the panel's flow, kept
    together only by their widths happening to fill the line, and the row after
    them packs onto whatever space is left. A fill widget always gets a line to
    itself, so one group pins one row no matter what the pane is doing.

    Inside the group the cells total at most ns.OPTIONS_ROW_WIDTH and none is
    "full": a wider row tips its last cell onto a line of its own.

    Hiding belongs on the group, never on the cells inside it, or the cells left
    behind hold the line open.
]]
---@param order number
---@param hidden? boolean|function
---@param controls table[] # laid out left to right
---@return table
function ns.OptionsRow(order, hidden, controls)
	local args = {}
	for index, control in ipairs(controls) do
		control.order = index
		args["control" .. index] = control
	end
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

--[[
    A caption and its dropdown (or slider) on one line, for a setting that sits
    at the panel's own level rather than under a toggle: the caption takes the
    label column and the control the shared control column, so it lines up with
    every other dropdown on every panel.
]]
---@param order number
---@param hidden? boolean|function
---@param caption string
---@param control table # a select or range; its name and width are set here
---@return table
function ns.OptionsSelectRow(order, hidden, caption, control)
	control.name = ""
	control.width = ns.OPTIONS_CONTROL_WIDTH
	return ns.OptionsRow(order, hidden, { ns.OptionsRowLabel(caption, 0), control })
end

--[[
    A sub-option is a control that only means anything while the toggle above it
    is on, and it is marked two ways at once.

    The row leads with a blank indent cell, which moves the checkbox itself.
    Padding the label instead would indent only the caption — AceConfig pins a
    checkbox at the left edge of its own widget — leaving the box lined up with
    its parent's and the words drifting away from it.

    ns.OptionsSubLabel then colors the caption HELP silver against the parent's
    white, so the row reads as subordinate rather than merely shifted. Silver is
    the palette's secondary-text role and is well clear of the dimmer gray AceGUI
    paints a genuinely disabled label, so a sub-option that greys out with its
    parent still reads as disabled rather than as ordinary sub-option text.

    It is an ns.OptionsRow led by the indent, and the row's group is what keeps
    the indent with its control: laid out flat, the pair after it would pack onto
    the leftover space and its indent would stop indenting anything. The indent
    counts toward ns.OPTIONS_ROW_WIDTH like any other cell, and since hiding
    rides on the group, a hidden sub-option takes its indent cell with it.
]]
---@param order number
---@param hidden? boolean|function
---@param controls table[] # laid out left to right after the indent cell
---@return table
function ns.OptionsSubRow(order, hidden, controls)
	local row = ns.OptionsRow(order, hidden, controls)
	row.args.indent = {
		type = "description",
		name = " ",
		width = ns.OPTIONS_SUB_INDENT_WIDTH,
		order = 0,
	}
	return row
end

---@param text string
---@return string
function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

--[[
    A dropdown sub-option: its silver caption and the dropdown on one indented
    line. The caption pays for the indent out of its own label column
    (ns.OPTIONS_SUB_LABEL_WIDTH), so the dropdown keeps the shared control width
    and lines up with every other dropdown on the panel, sub-option or not.
]]
---@param order number
---@param hidden? boolean|function
---@param caption string
---@param control table # a select; its name and width are set here
---@return table
function ns.OptionsSubSelectRow(order, hidden, caption, control)
	control.name = ""
	control.width = ns.OPTIONS_CONTROL_WIDTH
	return ns.OptionsSubRow(order, hidden, {
		ns.OptionsRowLabel(ns.OptionsSubLabel(caption), 0, ns.OPTIONS_SUB_LABEL_WIDTH),
		control,
	})
end

--------------------------------------------------------------------------------
-- Toggle Rows
--------------------------------------------------------------------------------

--[[
    How a toggle carries what belongs to it, the layout Connoisseur uses, with
    Control Freak's speaker:

      * One setting of its own rides on the toggle's line, in the control column,
        and leaves the line while the toggle is off (ns.OptionsToggleRow).
      * A sound toggle carries a speaker that plays the sound, past the end of
        the row after its setting, in the right margin, and leaves with the
        setting while the toggle is off. A sound with no setting to choose keeps
        its speaker in that same column, so every speaker on a panel lines up.
      * Anything else it owns, an on/off choice or one of several settings, sits
        on an indented sub-row below it (ns.OptionsSubToggleRow, ns.OptionsSubRow)
        that leaves the panel while the toggle is off.

    A caption and what rides with it share the line only when the caption fits
    the label column, which its measured width decides as the panel is built:
    AceGUI draws a checkbox caption on one line and cuts a longer one short with
    "...", and a German or French caption can run half as long again as the
    English. A caption that won't fit takes the whole line, and its setting and
    speaker drop to the line below, still in their columns.
]]

-- AceGUI's checkbox: a 24-pixel box, then its caption in GameFontHighlight.
local CHECKBOX_BOX_PIXELS = 24
-- Room past the caption's last letter, so a caption that fits never grazes the edge it would be cut at.
local CAPTION_SLACK_PIXELS = 12

local captionMeasure

--[[
    The width in pixels of a caption in GameFontHighlight, read off a hidden
    font string without drawing anything. GameFontNormal, a button's caption
    font, differs only in color, so it measures the same, which is how the item
    lists' Add button sizes itself too.
]]
---@param caption string
---@return number
function ns.MeasureCaptionPixels(caption)
	if not captionMeasure then
		local measureFrame = CreateFrame("Frame")
		measureFrame:Hide()
		captionMeasure = measureFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	end
	captionMeasure:SetText(caption)
	return captionMeasure:GetStringWidth()
end

--[[
    The width, in AceConfig units, a checkbox needs to show its caption whole,
    measured in the checkbox's own font.
]]
---@param caption string
---@return number
function ns.OptionsToggleWidth(caption)
	return (CHECKBOX_BOX_PIXELS + ns.MeasureCaptionPixels(caption) + CAPTION_SLACK_PIXELS)
		/ ns.OPTIONS_PIXELS_PER_WIDTH_UNIT
end

--[[
    A primary toggle with what rides on its line: `extras.control`, its one
    setting (a select or range, given its tooltip in `desc`; its name and width
    are set here) in the control column, then `extras.preview`, a speaker from
    Options-Loot-Sounds.lua's SoundPreview, past the end of the row. A speaker with no setting
    beside it gets a blank cell the control column's width in the setting's
    place, so it lands where every other speaker does. Everything after the
    toggle leaves the line while the toggle is off. One unnamed inline group,
    so the row keeps a line of its own, and a caption too long to share it
    sends the rest to the line below.
]]
---@param order number
---@param toggle table # a toggle with a string name (it is measured); its get decides whether the rest shows
---@param extras table # { control = table?, preview = table? }
---@return table
function ns.OptionsToggleRow(order, toggle, extras)
	local control, preview = extras.control, extras.preview
	local function IsOff()
		return not toggle.get()
	end

	local args = { toggle = toggle }
	toggle.order = 1

	-- What follows the caption, left to right: the setting or the blank cell standing in for it, then the speaker.
	local rest = {}
	if control then
		control.name = ""
		control.width = ns.OPTIONS_CONTROL_WIDTH
		control.order = 2
		rest.control = control
	elseif preview then
		rest.controlSpace = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = 2,
		}
	end
	if preview then
		preview.order = 3
		rest.preview = preview
	end

	if not next(rest) then
		toggle.width = "full"
	elseif ns.OptionsToggleWidth(toggle.name) <= ns.OPTIONS_LABEL_WIDTH then
		toggle.width = ns.OPTIONS_LABEL_WIDTH
		for key, cell in pairs(rest) do
			cell.hidden = IsOff
			args[key] = cell
		end
	else
		--[[
            The line below, in a group of its own. A group always starts a new
            line; a filler left to wrap there by itself could, on a wide enough
            panel, stay beside a long caption and push the setting to the left
            edge.
        ]]
		toggle.width = "full"
		rest.filler = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_LABEL_WIDTH,
			order = 1,
		}
		args.controlRow = {
			type = "group",
			name = "",
			inline = true,
			order = 2,
			hidden = IsOff,
			args = rest,
		}
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = args,
	}
end

--[[
    An on/off choice that belongs to the toggle above it: an indented checkbox
    with a silver caption, leaving the panel while `hidden` says the parent is
    off.
]]
---@param order number
---@param hidden? function
---@param toggle table
---@return table
function ns.OptionsSubToggleRow(order, hidden, toggle)
	toggle.name = ns.OptionsSubLabel(toggle.name)
	toggle.width = ns.OPTIONS_SUB_TOGGLE_WIDTH
	return ns.OptionsSubRow(order, hidden, { toggle })
end

--[[
    A quality dropdown's values from `lowest` up to Epic, each in the game's own
    quality color so the tiers read like the items themselves, and the order to
    show them in. `suffix` ("+") makes a threshold read as one where no caption
    says so.
]]
---@param lowest number
---@param suffix? string
---@return table values
---@return number[] sorting
function ns.OptionsQualityChoices(lowest, suffix)
	local values, sorting = {}, {}
	for quality = lowest, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		values[quality] = ns.GetQualityColor(quality) .. ns.QUALITY_DISPLAY_NAMES[qualityKey] .. (suffix or "") .. "|r"
		sorting[#sorting + 1] = quality
	end
	return values, sorting
end

--------------------------------------------------------------------------------
-- Message Examples
--------------------------------------------------------------------------------

--[[
    What a message looks like when it arrives, under the toggle that decides
    whether it goes out: the Announcements panel's posts, Automated Rolls' two
    prints, and the Openables List's Ignore notice. Each panel runs
    the real template, a sent one through ns:BuildAnnounceMessage and a printed
    one through ns.BuildPrintMessage, so an example can't drift from its
    message in any language. The line is drawn in the colors of where it goes:

      printed   the exact string ns:PrintMessage prints, branded colors and all
      PARTY     "[Party] [You]: ..." in the player's party chat color, for every
                group channel, since party is the one every group has
      WHISPER   "[You] whispers: ..." in their whisper color, as the other
                player receives it

    "You" is the character the panel is opened on, in their class color.
    Everybody else is from ns.SAMPLE_NAMES, and every item is a real link from
    ns.SAMPLE_ITEM_IDS or the flavor's data, which reads as loading until the
    client has it; the panel's function names fill it in on the next repaint.
    The raid marker is drawn as the icon chat shows, where a panel would print
    "{rt4}". Only the "Example:" label is silver.

    An example stays on show while its own toggle is off, because it is what
    somebody reads to decide whether to turn that toggle on.
]]
local RAID_MARKER_ICON = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t"

--[[
    chatType is the client's own ChatTypeInfo key, so a player who recolored a
    channel sees their own color; the hex is only for a client that hasn't
    filled that table in. prefix is the client's own line opener, so "[Party]"
    and "whispers:" read in the player's language.
]]
local SENT_FORMS = {
	PARTY = { chatType = "PARTY", hex = "AAAAFF", prefix = CHAT_PARTY_GET or "[Party] %s: " },
	WHISPER = { chatType = "WHISPER", hex = "FF80FF", prefix = CHAT_WHISPER_GET or "%s whispers: " },
}

---@param form table
---@return string
local function ChatColor(form)
	local info = ChatTypeInfo and ChatTypeInfo[form.chatType]
	if not info then
		return "|cff" .. form.hex
	end
	return string.format(
		"|cff%02x%02x%02x",
		math.floor(info.r * 255 + 0.5),
		math.floor(info.g * 255 + 0.5),
		math.floor(info.b * 255 + 0.5)
	)
end

--[[
    A chat frame falls back to the line's color when a link closes; a panel
    falls back to white, so the color is opened again after every |r.
]]
---@param color string
---@param text string
---@return string
local function Tint(color, text)
	return color .. (string.gsub(text, "|r", "|r" .. color)) .. "|r"
end

-- The character the panel is opened on, in their class color, read as the line is drawn.
---@return string
function ns.OptionsExampleYou()
	local name = GetUnitName("player") or ns.SAMPLE_NAMES.DRUID
	local _, classFile = UnitClass("player")
	local classColor = ns.GetClassColor(classFile)
	return classColor and classColor .. name .. "|r" or name
end

-- A roster player, in their class color, the way a printed line names a group member.
---@param classFile string
---@return string
function ns.OptionsExampleOther(classFile)
	return ns.GetClassColor(classFile) .. ns.SAMPLE_NAMES[classFile] .. "|r"
end

---@param itemIdentifier number
---@return string # the item's link, or the loading line until the client has it
function ns.OptionsExampleLink(itemIdentifier)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	return itemLink or L["ITEM_LOADING"]:format(itemIdentifier)
end

---@param text string # the body ns:PrintMessage would print
---@return string
function ns.OptionsPrintedLine(text)
	return Tint(GetColor("TEXT"), ns.BuildPrintMessage(text))
end

---@param formKey string # "PARTY" or "WHISPER"
---@param message string # as ns:BuildAnnounceMessage builds it
---@return string
function ns.OptionsSentLine(formKey, message)
	local form = SENT_FORMS[formKey]
	message = string.gsub(message, "{rt(%d)}", function(markerIndex)
		return RAID_MARKER_ICON:format(markerIndex)
	end)
	return Tint(ChatColor(form), form.prefix:format("[" .. ns.OptionsExampleYou() .. "]") .. message)
end

-- Silver opened again after the line, for a locale whose label runs on past it.
---@param line string # from ns.OptionsPrintedLine or ns.OptionsSentLine
---@return string
local function ExampleLine(line)
	return GetColor("HELP") .. L["OPTIONS_EXAMPLE"]:format(line .. GetColor("HELP")) .. "|r"
end

--[[
    An example sits under its toggle the way a sub-option does, indented,
    across the rest of the row. Its text is read as the panel draws, so it
    follows the settings it shows.
]]
---@param order number
---@param buildMessage function # returns the finished line the example shows
---@return table
function ns.OptionsExampleRow(order, buildMessage)
	return ns.OptionsSubRow(order, nil, {
		{
			type = "description",
			name = function()
				return ExampleLine(buildMessage())
			end,
			fontSize = "medium",
			width = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_SUB_INDENT_WIDTH,
		},
	})
end
