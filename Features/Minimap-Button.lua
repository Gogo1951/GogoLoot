--------------------------------------------------------------------------------
-- GogoLoot Minimap Button
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local GetColor = ns.GetColor

local brokerObject

-- Matches the tooltip's own line height, so an icon sits on the text baseline.
local TOOLTIP_ICON_SIZE = 16

--[[
    The roll read-back under Automated Rolls: one line per group context, named
    with the game's own word for it, and set in by two spaces so the pair reads
    as detail under the description rather than as more of it.
]]
local ROLL_SETTING_INDENT = "  "
local ROLL_CONTEXTS = {
	{ name = PARTY, actionKey = "autoRollActionParty", thresholdKey = "autoRollThresholdParty" },
	{ name = RAID, actionKey = "autoRollActionRaid", thresholdKey = "autoRollThresholdRaid" },
}

---@param context table
---@return string
local function RollSettingLine(context)
	local action = ns.db.profile[context.actionKey]
	local actionLabel = ns.ROLL_OVERRIDE_LABELS[action] or ""
	if action == ns.MANUAL then
		return ROLL_SETTING_INDENT .. L["MINIMAP_ROLLS_SETTING_MANUAL"]:format(context.name, actionLabel)
	end
	local thresholdLabel = ns.ROLL_THRESHOLD_LABELS[ns.db.profile[context.thresholdKey]] or ""
	return ROLL_SETTING_INDENT .. L["MINIMAP_ROLLS_SETTING"]:format(context.name, actionLabel, thresholdLabel)
end

--------------------------------------------------------------------------------
-- Icon State
--------------------------------------------------------------------------------

--[[
    The minimap icon reflects the Automated Rolls toggle: on/off swap. Called
    from the click handler here and from the matching Options toggle so the icon
    stays in sync no matter where the user flips it.
]]

---@return nil
function ns:UpdateMinimapIcon()
	if not brokerObject then
		return
	end

	local state = ns.db.profile.autoGreed and "on" or "off"
	brokerObject.icon = ns.MINIMAP_ICONS[state] or ns.MINIMAP_ICONS.off

	if ns.db.global.minimap then
		LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
	end
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function GetStatusText(isEnabled, isPaused)
	if not isEnabled then
		return GetColor("OFF") .. L["STATUS_DISABLED"] .. "|r"
	end
	if isPaused then
		return GetColor("SEPARATOR") .. L["STATUS_PAUSED"] .. "|r"
	end
	return GetColor("ON") .. L["STATUS_ENABLED"] .. "|r"
end

--------------------------------------------------------------------------------
-- Click Handlers
--------------------------------------------------------------------------------

--[[
    The button toggles the four features a player switches in play: Automated
    Rolls on left-click, Automated Opening on right-click, Announcements and
    Automated Master Looting on the same clicks with Shift held. Speedy Loot
    isn't one of them: it simply stays on, so its switch lives only on the
    General options panel. Each toggle repaints every panel carrying its switch:
    its own and the General panel's Features section, and for the last two the
    master looter pop-up too.
]]
local function ToggleAutomatedOpening()
	ns.db.profile.autoOpen = not ns.db.profile.autoOpen
	if ns.db.profile.autoOpen then
		ns.EnsureAutoLoot()
	end
	ns.ScheduleOpeningScan(true)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.AutomatedOpening)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

local function ToggleAutomatedRolls()
	ns.db.profile.autoGreed = not ns.db.profile.autoGreed
	ns:UpdateMinimapIcon()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.AutomatedRolls)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

-- As the panel's own switch does: the trade window's checkbox and the pop-up's destination toggle follow it.
local function ToggleAnnouncements()
	ns.db.profile.lootNotifications = not ns.db.profile.lootNotifications
	ns:SyncTradeCheckbox()
	ns:RefreshMasterLooterPanels()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Announcements)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

local function ToggleAutomatedMasterLooting()
	ns.db.profile.autoMasterLoot = not ns.db.profile.autoMasterLoot
	if ns.db.profile.autoMasterLoot and not ns:AreWeMasterLooter() then
		ns:PrintMessage(L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"]:format(MASTER_LOOTER))
	end
	ns:RefreshMasterLooterPanels()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

-- Which toggle each click runs: the plain clicks, then the same clicks with Shift held.
local CLICK_TOGGLES = {
	LeftButton = ToggleAutomatedRolls,
	RightButton = ToggleAutomatedOpening,
}
local SHIFT_CLICK_TOGGLES = {
	LeftButton = ToggleAnnouncements,
	RightButton = ToggleAutomatedMasterLooting,
}

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

--[[
    One feature block: its name and state, its description, any silver detail
    lines under it (Automated Rolls' read-back), its click, then a blank line.
]]
local function AddFeatureBlock(tooltip, title, status, description, click, detailLines)
	tooltip:AddDoubleLine(GetColor("TITLE") .. title .. "|r", status)
	ns:AddTooltipLine(tooltip, description, "BODY", true)
	for _, line in ipairs(detailLines or {}) do
		ns:AddTooltipLine(tooltip, line, "HELP")
	end
	tooltip:AddDoubleLine(GetColor("INFO") .. click .. "|r", GetColor("INFO") .. L["MINIMAP_TOGGLE"] .. "|r")
	tooltip:AddLine(" ")
end

local function ShowTooltip(anchor)
	local tooltip = GameTooltip
	tooltip:SetOwner(anchor, "ANCHOR_NONE")
	tooltip:SetPoint("TOPRIGHT", anchor, "BOTTOMLEFT")
	tooltip:ClearLines()

	-- Title and version
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r", GetColor("MUTED") .. ns.Version .. "|r")
	tooltip:AddLine(" ")
	tooltip:AddLine(" ")

	--[[
	    Locked Items leads, above the feature blocks, and appears only while
	    boxes are actually waiting on a lock. It is the one part that changes
	    with the bags rather than with a setting, so it is what the player opened
	    the tooltip to check. One line per distinct box, icon then name, with a
	    count only when there is more than one, so no locale needs a plural. The
	    name comes from the item's own link, already localized and
	    quality-colored, with the brackets stripped: a tooltip line isn't
	    running text.
	]]
	local lockedBoxes = ns.GetLockedBoxes()
	if #lockedBoxes > 0 then
		ns:AddTooltipLine(tooltip, L["MINIMAP_LOCKED_ITEMS"], "TITLE")
		for _, row in ipairs(lockedBoxes) do
			local icon = row.icon and ("|T" .. row.icon .. ":" .. TOOLTIP_ICON_SIZE .. "|t ") or ""
			local name = row.link and string.gsub(row.link, "|h%[(.-)%]|h", "|h%1|h")
				or (GetColor("TEXT") .. row.itemIdentifier .. "|r")
			tooltip:AddLine(icon .. name .. (row.count > 1 and (" x" .. row.count) or ""))
		end
		tooltip:AddLine(" ")
	end

	-- The feature blocks, in the order of their clicks: left, right, then the two with Shift held.
	local profile = ns.db.profile
	local rollLines = {}
	for _, context in ipairs(ROLL_CONTEXTS) do
		rollLines[#rollLines + 1] = RollSettingLine(context)
	end
	AddFeatureBlock(
		tooltip,
		L["TAB_AUTOMATED_ROLLS"],
		GetStatusText(profile.autoGreed),
		L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"],
		L["MINIMAP_LEFT_CLICK"],
		rollLines
	)
	AddFeatureBlock(
		tooltip,
		L["TAB_AUTOMATED_OPENING"],
		GetStatusText(profile.autoOpen, ns:IsAutomatedOpeningPaused()),
		L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"],
		L["MINIMAP_RIGHT_CLICK"]
	)
	AddFeatureBlock(
		tooltip,
		L["TAB_ANNOUNCEMENTS"],
		GetStatusText(profile.lootNotifications),
		L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"],
		L["MINIMAP_SHIFT_LEFT_CLICK"]
	)
	AddFeatureBlock(
		tooltip,
		L["MINIMAP_AUTOMATED_MASTER_LOOTING"],
		GetStatusText(profile.autoMasterLoot),
		L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"],
		L["MINIMAP_SHIFT_RIGHT_CLICK"]
	)

	-- GogoLoot Options (Shift + Middle-Click opens the options panel)
	ns:AddTooltipLine(tooltip, L["MINIMAP_OPTIONS"], "TITLE")
	ns:AddTooltipLine(tooltip, L["MINIMAP_OPTIONS_KEYBIND"], "INFO")

	tooltip:Show()
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

---@return nil
function ns:InitMinimap()
	local initialState = ns.db.profile.autoGreed and "on" or "off"

	brokerObject = LibDataBroker:NewDataObject(ADDON_NAME, {
		type = "launcher",
		label = L["ADDON_TITLE"],
		icon = ns.MINIMAP_ICONS[initialState],
		OnClick = function(frame, button)
			if button == "MiddleButton" and IsShiftKeyDown() then
				if ns.OpenOptionsPanel then
					ns:OpenOptionsPanel()
				end
				return
			end
			local toggle = (IsShiftKeyDown() and SHIFT_CLICK_TOGGLES or CLICK_TOGGLES)[button]
			if toggle then
				toggle()
			end

			-- Re-render the tooltip in place so the status reflects the click
			if GameTooltip:GetOwner() == frame then
				ShowTooltip(frame)
			end
		end,
		OnEnter = function(frame)
			ShowTooltip(frame)
		end,
		OnLeave = function()
			GameTooltip:Hide()
		end,
	})

	LibDBIcon:Register(ADDON_NAME, brokerObject, ns.db.global.minimap)

	--[[
	    On Retail and WoW Forever, which both report WOW_PROJECT_MAINLINE,
	    LibDBIcon centers an 18px square icon on the button under a ring
	    (file 136430, the same art on both clients) whose hole is off-center
	    and wider than the icon. The square's corners then show against the
	    ring's lopsided shading and the icon reads as off-center. So the icon
	    is masked round, grown to 20 so its rim tucks under the gold, and
	    nudged onto the hole. The nudge was tuned by eye on Forever, where one
	    unit is about two screen pixels; the texture alone doesn't predict it.
	    Refresh leaves all of this alone, and a click only changes the icon's
	    texture coordinates.
	]]
	if ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline" then
		LibDBIcon:SetButtonIcon(ADDON_NAME, nil, 20, "CENTER", 1, -0.35)

		local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
		local mask = button:CreateMaskTexture()
		mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
end
