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

-- Assigning the launcher's icon is enough: LibDBIcon and every LDB display redraw from it.
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

-- Position and hide live on the profile, so Refresh re-points the button after a profile switch or reset.
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

function ns.HandleLauncherClick(frame, button)
	ns.RunButtonClick(frame, button)
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
		-- OnEnter, not OnTooltipShow; the menu closes itself once the cursor leaves, so OnLeave has nothing to do.
		OnEnter = ns.HandleLauncherEnter,
		OnLeave = function() end,
	})

	LibDBIcon:Register(ADDON_NAME, brokerObject, ns.db.profile.minimap)

	--[[
	    On Camelot and Mainline, LibDBIcon's Retail ring has an off-center hole
	    wider than the 18px square icon, so the icon is masked round, grown to 20
	    so its rim tucks under the gold, and nudged onto the hole (tuned by eye on
	    Forever). An icon swap keeps all three. Set by hand, not through
	    SetButtonIcon, whose ResetButtonIcon errors when another add-on has
	    replaced the icon.
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
