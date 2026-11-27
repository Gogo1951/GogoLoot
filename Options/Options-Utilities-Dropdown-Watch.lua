--------------------------------------------------------------------------------
-- GogoLoot Options — Dropdowns Scrolled Out of View
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    An AceGUI dropdown's list is parented to UIParent, so scrolling the panel
    carries it out of the Options window. Like Blizzard's menus, close it when
    its dropdown moves inside the scroll area. Runs only while SettingsPanel is
    shown.
]]
local AceGUI = LibStub("AceGUI-3.0")

---@param frame table
---@return table|nil
local function EnclosingScrollFrame(frame)
	local parent = frame:GetParent()
	while parent do
		if parent.IsObjectType and parent:IsObjectType("ScrollFrame") then
			return parent
		end
		parent = parent:GetParent()
	end
end

---@return nil
function ns.WatchScrolledDropdowns()
	if ns.dropdownScrollWatcher then
		return
	end

	local watched, scrollFrame, offset
	local watcher = CreateFrame("Frame")
	ns.dropdownScrollWatcher = watcher

	watcher:SetScript("OnUpdate", function()
		local widget = AceGUI.FocusedWidget
		if not (widget and widget.type == "Dropdown" and widget.open and widget.frame) then
			watched = nil
			return
		end

		if widget ~= watched then
			watched = widget
			scrollFrame = EnclosingScrollFrame(widget.frame)
			offset = scrollFrame
				and widget.frame:GetTop()
				and scrollFrame:GetTop()
				and widget.frame:GetTop() - scrollFrame:GetTop()
			return
		end

		if not offset then
			return
		end

		local top, scrollTop = widget.frame:GetTop(), scrollFrame:GetTop()
		if not (top and scrollTop) or math.abs(top - scrollTop - offset) > 0.5 then
			watched = nil
			AceGUI:ClearFocus()
		end
	end)

	-- Hidden, a frame's OnUpdate doesn't run; a client without SettingsPanel keeps it shown.
	if not SettingsPanel then
		return
	end
	watcher:SetShown(SettingsPanel:IsShown())
	SettingsPanel:HookScript("OnShow", function()
		watcher:Show()
	end)
	SettingsPanel:HookScript("OnHide", function()
		watched = nil
		watcher:Hide()
	end)
end
