local ADDON_NAME, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
    Answers "the mini-map button is gone / off-screen", "hovering the button
    shows nothing" and "my loot toasts are off the edge of the screen" reports:
    screen size, UI scale, the button's saved placement, whether its menu
    loaded and is wired to the button, and the toast anchor. Read-only.
]]

-- True when Escape's list of frames to close holds the menu (Features/Minimap-Menu.lua).
local function MenuClosesOnEscape()
	local menuName = ADDON_NAME .. "Menu"
	for _, name in ipairs(type(UISpecialFrames) == "table" and UISpecialFrames or {}) do
		if name == menuName then
			return true
		end
	end
	return false
end

function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))

	lines[#lines + 1] = ""
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	-- Without the data object, login never registers a button and every repaint returns early.
	local brokerObject = LibStub("LibDataBroker-1.1"):GetDataObjectByName(ADDON_NAME)
	lines[#lines + 1] = string.format("Data broker object: %s", brokerObject and "present" or "MISSING")
	lines[#lines + 1] = string.format("Minimap button created: %s", button and "yes" or "no")
	if button then
		lines[#lines + 1] = string.format(
			"Minimap button shown: %s, visible: %s",
			tostring(button:IsShown() and true or false),
			tostring(button:IsVisible() and true or false)
		)
	end

	local minimap = ns.db and ns.db.profile.minimap
	if type(minimap) == "table" then
		lines[#lines + 1] = string.format("Minimap button hidden: %s", tostring(minimap.hide or false))
		lines[#lines + 1] = string.format("Minimap saved angle: %s", tostring(minimap.minimapPos))
	else
		lines[#lines + 1] = "Minimap saved position: (none yet)"
	end

	--[[
	    The menu opens from the data object's OnEnter through ns.ShowMenu, which
	    returns early until the database is open; a TOC missing the menu's files
	    leaves ns.ShowMenu nil and the hover does nothing.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Menu loaded: %s, database open: %s",
		type(ns.ShowMenu) == "function" and "yes" or "MISSING",
		ns.db and "yes" or "no"
	)
	lines[#lines + 1] = string.format(
		"Button hover opens menu: %s, click runs menu clicks: %s",
		tostring(type(brokerObject) == "table" and type(brokerObject.OnEnter) == "function"),
		tostring(
			type(brokerObject) == "table"
				and type(brokerObject.OnClick) == "function"
				and type(ns.RunButtonClick) == "function"
		)
	)
	lines[#lines + 1] = string.format(
		"Menu open now: %s, closes on Escape: %s",
		tostring(type(ns.IsMenuShown) == "function" and ns.IsMenuShown() or false),
		tostring(MenuClosesOnEscape())
	)
	if ns.db and type(ns.CountMoreFeatures) == "function" then
		lines[#lines + 1] = string.format("More Features rows: %d on, %d off", ns.CountMoreFeatures())
	end

	--[[
	    Where a dragged position lives, link by link: LibDBIcon's drag handler
	    computes the angle with math.atan2 every frame and writes it into the
	    button's db, which has to be the very table AceDB saves, and the raw
	    SavedVariables value is what the client writes at logout.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("math.atan2 present: %s", tostring(type(math.atan2) == "function"))
	lines[#lines + 1] = string.format("LibDBIcon-1.0 minor: %s", tostring(LibStub.minors["LibDBIcon-1.0"]))
	if button then
		lines[#lines + 1] = string.format("Button db present: %s", tostring(button.db ~= nil))
		lines[#lines + 1] = string.format(
			"Button db is ns.db.profile.minimap: %s",
			tostring(button.db ~= nil and minimap ~= nil and button.db == minimap)
		)
		lines[#lines + 1] = string.format("Button db.minimapPos: %s", tostring(button.db and button.db.minimapPos))
	end
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	local profileKey = ns.db and ns.db.keys and ns.db.keys.profile
	local savedProfiles = type(saved) == "table" and saved.profiles
	local savedProfile = type(savedProfiles) == "table" and profileKey and savedProfiles[profileKey]
	local savedMinimap = type(savedProfile) == "table" and savedProfile.minimap
	lines[#lines + 1] = string.format(
		"%s.profiles[%s].minimap.minimapPos: %s",
		ns.SAVED_VARIABLES_NAME,
		tostring(profileKey),
		tostring(type(savedMinimap) == "table" and savedMinimap.minimapPos or nil)
	)
	-- Login moves a pre-profile global.minimap into the profiles (Features/Core.lua), so "yes" means it never ran.
	local savedGlobal = type(saved) == "table" and saved.global
	lines[#lines + 1] = string.format(
		"%s.global.minimap still present: %s",
		ns.SAVED_VARIABLES_NAME,
		tostring(type(savedGlobal) == "table" and savedGlobal.minimap ~= nil)
	)

	--[[
	    The toast anchor, saved and live. The live frame is read through
	    ns.GetLootToastAnchorFrame, which returns nil rather than creating it, so
	    this report never makes a frame.
	]]
	lines[#lines + 1] = ""
	local savedToast = ns.db and ns.db.global.lootToastPosition
	if savedToast and savedToast.point then
		lines[#lines + 1] = string.format(
			"Saved toast anchor: point=%s relativePoint=%s x=%s y=%s",
			tostring(savedToast.point),
			tostring(savedToast.relativePoint),
			tostring(savedToast.x),
			tostring(savedToast.y)
		)
	else
		lines[#lines + 1] = "Saved toast anchor: unset (the default position is in use)"
	end
	local anchorFrame = ns.GetLootToastAnchorFrame()
	if anchorFrame then
		local point, _, relativePoint, x, y = anchorFrame:GetPoint()
		lines[#lines + 1] = string.format(
			"Live toast anchor: point=%s relativePoint=%s x=%s y=%s shown=%s",
			tostring(point),
			tostring(relativePoint),
			tostring(x),
			tostring(y),
			tostring(anchorFrame:IsShown())
		)
		local left, bottom = anchorFrame:GetLeft(), anchorFrame:GetBottom()
		lines[#lines + 1] =
			string.format("Live toast anchor on screen at: left=%s bottom=%s", tostring(left), tostring(bottom))
	else
		lines[#lines + 1] = "Live toast anchor: not created this session"
	end

	--[[
	    The slash command that opens the options (Options/Options.lua): another
	    add-on claiming the same word runs its own command instead.
	]]
	lines[#lines + 1] = ""
	local command = type(SLASH_GOGOLOOT1) == "string" and SLASH_GOGOLOOT1 or nil
	local others = {}
	if command and type(SlashCmdList) == "table" then
		for key in pairs(SlashCmdList) do
			for index = 1, 9 do
				local word = _G["SLASH_" .. tostring(key) .. index]
				if key ~= "GOGOLOOT" and type(word) == "string" and strlower(word) == strlower(command) then
					others[#others + 1] = tostring(key)
				end
			end
		end
	end
	table.sort(others)
	lines[#lines + 1] = string.format(
		"Slash command: %s, handler %s, also claimed by: %s",
		tostring(command),
		type(SlashCmdList) == "table" and type(SlashCmdList.GOGOLOOT) == "function" and "present" or "MISSING",
		#others > 0 and table.concat(others, ", ") or "nobody"
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

-- Plain text: pipes escaped, so a saved item link pastes as text rather than drawing as a link.
local function Plain(value)
	return (string.gsub(tostring(value), "|", "||"))
end

--[[
    Every row prints, except a table named in ns.DIAGNOSTIC_SAVED_SUMMARY_KEYS
    (Manifests.lua): data the add-on fills in itself, which prints its row
    count instead, so a long history can't swamp the rows a player edits.
]]
local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" and ns.DIAGNOSTIC_SAVED_SUMMARY_KEYS[key] then
			lines[#lines + 1] = string.format("%s%s = <%d rows>", indent, Plain(key), CountKeys(entry))
		elseif type(entry) == "table" then
			lines[#lines + 1] = indent .. Plain(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. Plain(key) .. " = " .. Plain(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile, each character's own section (Character Rules and its loot lines),
    and every Item Overrides, Ignore List and Openables List row.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
