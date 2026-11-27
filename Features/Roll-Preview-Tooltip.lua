--------------------------------------------------------------------------------
-- GogoLoot Roll Preview Tooltip
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

local INDENT = "  "

local CONTEXTS = {
	{ name = PARTY, inRaid = false },
	{ name = RAID, inRaid = true },
}

---@param action string|nil
---@return string
local function RollWord(action)
	return ns.ROLL_OVERRIDE_LABELS[action or ns.MANUAL] or ""
end

---@param tooltip table
local function AddRollPreview(tooltip)
	if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then
		return
	end
	if not ns.db or not ns.db.profile.autoGreed then
		return
	end
	local _, itemLink = tooltip:GetItem()
	local itemIdentifier = type(itemLink) == "string" and tonumber(string.match(itemLink, "item:(%d+)"))
	if not itemIdentifier then
		return
	end
	local rows = {}
	for _, context in ipairs(CONTEXTS) do
		local action, reason = ns.DecidePlayerRoll(itemIdentifier, context.inRaid, itemLink)
		if not reason or reason == "OFF" then
			return
		end
		rows[#rows + 1] = { name = context.name, word = RollWord(action) }
	end

	local titleR, titleG, titleB = ns.GetColorRGB("TITLE")
	local mutedR, mutedG, mutedB = ns.GetColorRGB("MUTED")
	local bodyR, bodyG, bodyB = ns.GetColorRGB("BODY")
	local textR, textG, textB = ns.GetColorRGB("TEXT")
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(
		L["TAB_AUTOMATED_ROLLS"],
		L["ADDON_SHORT_NAME"],
		titleR,
		titleG,
		titleB,
		mutedR,
		mutedG,
		mutedB
	)
	for _, row in ipairs(rows) do
		tooltip:AddDoubleLine(INDENT .. row.name, row.word, bodyR, bodyG, bodyB, textR, textG, textB)
	end
	tooltip:Show()
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddRollPreview)
else
	for _, tooltip in ipairs({ GameTooltip, ItemRefTooltip }) do
		if tooltip and tooltip.HookScript then
			tooltip:HookScript("OnTooltipSetItem", AddRollPreview)
		end
	end
end
