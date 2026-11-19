--------------------------------------------------------------------------------
-- GogoLoot Minimap Button
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

local brokerObject

--------------------------------------------------------------------------------
-- Icon State
--------------------------------------------------------------------------------

--[[
    The icon reflects the Automated Rolls switch: on/off swap. Assigning the
    launcher's icon is enough, since LibDBIcon and every LDB display redraw
    from it. ns.RefreshSettings() calls this, so the icon follows the switch
    whichever surface flipped it.
]]
---@return nil
function ns.UpdateMinimapIcon()
	if not brokerObject or not ns.db then
		return
	end
	local iconState = ns.db.profile.autoGreed and "on" or "off"
	brokerObject.icon = ns.MINIMAP_ICONS[iconState] or ns.MINIMAP_ICONS.off
end

--------------------------------------------------------------------------------
-- Placement
--------------------------------------------------------------------------------

--[[
    Shown or hidden in one place. The position and the Enable Mini-map Button
    preference (minimap.hide, inverted) live on the profile, so Refresh re-points
    the button at the current profile's table after a profile switch or reset.
]]
---@return nil
function ns:ApplyMinimapButton()
	if not ns.db or not brokerObject then
		return
	end
	LibDBIcon:Refresh(ADDON_NAME, ns.db.profile.minimap)
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

--[[
    Hovering opens the menu (Minimap-Menu.lua). A click runs its job from the
    menu's click table. Left-Click has a job (Automated Rolls), so hover alone
    opens the menu, and a click with no entry (Shift + Right-Click, held for
    the Master Looting Window) does nothing.
]]
function ns.HandleLauncherClick(_, button)
	ns.RunButtonClick(button)
end

function ns.HandleLauncherEnter(frame)
	ns.ShowMenu(frame, nil, "hover")
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
		OnClick = ns.HandleLauncherClick,
		--[[
		    OnEnter rather than OnTooltipShow: LibDBIcon and every LDB display
		    call it on hover, and the menu closes itself once the cursor leaves,
		    so OnLeave has nothing to do.
		]]
		OnEnter = ns.HandleLauncherEnter,
		OnLeave = function() end,
	})

	LibDBIcon:Register(ADDON_NAME, brokerObject, ns.db.profile.minimap)

	--[[
	    Icon Fit. On Camelot and Mainline, LibDBIcon centers an 18px square icon
	    on the button under a ring (file 136430, Retail's art) whose hole is
	    off-center and wider than the icon. The square's corners then show
	    against the ring's lopsided shading and the icon reads as off-center. So
	    the icon is masked round, grown to 20 so its rim tucks under the gold,
	    and nudged onto the hole. The nudge was tuned by eye on Forever, where
	    one unit is about two screen pixels; the texture alone doesn't predict
	    it. Refresh leaves all of this alone, and a click swaps the icon's
	    texture (brokerObject.icon), which keeps the size, anchor and mask. The
	    icon is sized and anchored by hand rather than through SetButtonIcon,
	    whose ResetButtonIcon calls icon:UpdateCoord() and errors when another
	    add-on has replaced the button's icon.
	]]
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	if (ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline") and button and button.icon then
		button.icon:SetSize(20, 20)
		button.icon:ClearAllPoints()
		button.icon:SetPoint("CENTER", 1, -0.35)

		local mask = button:CreateMaskTexture()
		mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
end
