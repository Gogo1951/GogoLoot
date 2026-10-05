local ADDON_NAME, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
    Answers "the mini-map button is gone / off-screen" and "my loot toasts are
    off the edge of the screen" reports: screen size, UI scale, the button's
    saved placement, and the toast anchor. Read-only.
]]
function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))

	lines[#lines + 1] = ""
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	lines[#lines + 1] = string.format("Minimap button created: %s", button and "yes" or "no")

	local minimap = ns.db and ns.db.global.minimap
	if type(minimap) == "table" then
		lines[#lines + 1] = string.format("Minimap button hidden: %s", tostring(minimap.hide or false))
		lines[#lines + 1] = string.format("Minimap saved angle: %s", tostring(minimap.minimapPos))
	else
		lines[#lines + 1] = "Minimap saved position: (none yet)"
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
			"Button db is ns.db.global.minimap: %s",
			tostring(button.db ~= nil and minimap ~= nil and button.db == minimap)
		)
		lines[#lines + 1] = string.format("Button db.minimapPos: %s", tostring(button.db and button.db.minimapPos))
	end
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	local savedGlobal = type(saved) == "table" and saved.global
	local savedMinimap = type(savedGlobal) == "table" and savedGlobal.minimap
	lines[#lines + 1] = string.format(
		"%s.global.minimap.minimapPos: %s",
		ns.SAVED_VARIABLES_NAME,
		tostring(type(savedMinimap) == "table" and savedMinimap.minimapPos or nil)
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
			"Live toast anchor: point=%s relativePoint=%s x=%s y=%s",
			tostring(point),
			tostring(relativePoint),
			tostring(x),
			tostring(y)
		)
	else
		lines[#lines + 1] = "Live toast anchor: not created this session"
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

--[[
    Whether each add-on is loaded as well as loadable, which spots Open Sesame
    still running alongside the GogoLoot that replaced it.
]]
function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
		lines[#lines + 1] = string.format(
			"%s v%s [%s, %s]",
			name,
			version,
			loadable and "loadable" or "disabled",
			C_AddOns.IsAddOnLoaded(name) and "loaded" or "not loaded"
		)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

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
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile, and every Item Overrides, Ignore List and Openables List row.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
