--------------------------------------------------------------------------------
-- GogoLoot Options — Dropdowns Scrolled Out of View
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    An AceGUI dropdown's list is parented to UIParent, anchored to the dropdown,
    so the panel's scroll area never clips it: scroll with a list open and the
    list rides along with its dropdown, out past the bottom of the Options
    window. Blizzard's own menus close when their owner scrolls, and this does
    the same: while a dropdown has its list open, a change in where it sits
    inside its scroll area closes the list.

    The watch runs only while the Options window (SettingsPanel) is open, and
    checks only the open dropdown, so it costs nothing the rest of the time.
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
