--------------------------------------------------------------------------------
-- GogoLoot Loot Master Window
--------------------------------------------------------------------------------

--[[
    The window the loot is handed out from, in four tabs:

      * Roll List: everything that can be rolled off, in the player's order,
        each with its trade clock. A row opens to show its rolls, with a
        Disqualify beside each counted one, and what can be done next.
        Roll All, Pause and Stop work down the list.
      * Floor Loot: an item list like the Ignore List, empty to start, of the
        loot with no trade clock the player wants to roll off.
      * Awarded: what was handed out, to whom, with the winning roll.
      * Soft Reserves: a place for a soft-reserve import, empty for now.

    Built the first time it opens. Everything it shows comes from
    Features/Loot-Master.lua and Features/Roll-Calls.lua; it keeps no state of
    its own beyond which tab is open, which rows are expanded, and the filter.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local WINDOW_NAME = "GogoLootLootMasterFrame"
local WINDOW_WIDTH, WINDOW_HEIGHT = 600, 620

local ROW_HEIGHT = 26
local LINE_HEIGHT = 18
local ROLL_LINE_HEIGHT = 20
local ACTION_ROW_HEIGHT = 28
local DETAIL_INDENT = 38
local SCROLLBAR_ROOM = 26

local frame
local tabs
local panels = {}
local selectedTab = "LIST"
local expanded = {}
local floorFilter = ""

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

local function MakeEntryRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:RegisterForClicks("LeftButtonUp")
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

	row.bar = row:CreateTexture(nil, "BACKGROUND")
	row.bar:SetPoint("TOPLEFT")
	row.bar:SetPoint("BOTTOMLEFT")

	row.up = ns.LootWindowIconButton(row, ns.LOOT_WINDOW_ARROW_UP, 16, L["LOOT_MASTER_MOVE_UP"], function(self)
		ns:MoveRollListEntry(self:GetParent().entry, -1)
	end)
	row.up:SetPoint("LEFT", 0, 0)
	row.down = ns.LootWindowIconButton(row, ns.LOOT_WINDOW_ARROW_DOWN, 16, L["LOOT_MASTER_MOVE_DOWN"], function(self)
		ns:MoveRollListEntry(self:GetParent().entry, 1)
	end)
	row.down:SetPoint("LEFT", 16, 0)

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(20, 20)
	row.icon:SetPoint("LEFT", 36, 0)

	row.name = ns.LootWindowText(row)
	row.name:SetPoint("LEFT", 62, 0)
	row.name:SetWidth(232)

	row.clock = ns.LootWindowText(row, "GameFontHighlightSmall", "RIGHT")
	row.clock:SetPoint("LEFT", 296, 0)
	row.clock:SetWidth(62)

	row.status = ns.LootWindowText(row, "GameFontHighlightSmall")
	row.status:SetPoint("LEFT", 366, 0)
	row.status:SetWidth(110)

	row.roll = ns.LootWindowButton(row, L["LOOT_MASTER_ROLL"], 54, function(self)
		ns:RollEntry(self:GetParent().entry)
	end)
	row.roll:SetPoint("RIGHT", -2, 0)

	row:SetScript("OnClick", function(self)
		if ns.InsertItemLinkIfShift(self.itemLink) then
			return
		end
		expanded[self.entry.key] = not expanded[self.entry.key]
		ns.RefreshLootWindows()
	end)
	ns.MakeItemHoverable(row)
	return row
end

local function MakeTextLine(parent)
	local line = CreateFrame("Frame", nil, parent)
	line.text = ns.LootWindowText(line, "GameFontHighlightSmall")
	line.text:SetPoint("LEFT")
	line.text:SetPoint("RIGHT")
	return line
end

local function MakeRollLine(parent)
	local line = CreateFrame("Frame", nil, parent)
	line.rank = ns.LootWindowText(line, "GameFontDisableSmall", "RIGHT")
	line.rank:SetPoint("LEFT", 0, 0)
	line.rank:SetWidth(18)
	line.name = ns.LootWindowText(line, "GameFontHighlightSmall")
	line.name:SetPoint("LEFT", 24, 0)
	line.name:SetWidth(120)
	line.value = ns.LootWindowText(line, "GameFontHighlightSmall", "RIGHT")
	line.value:SetPoint("LEFT", 146, 0)
	line.value:SetWidth(32)
	line.tag = ns.LootWindowText(line, "GameFontHighlightSmall")
	line.tag:SetPoint("LEFT", 186, 0)
	line.tag:SetWidth(200)
	line.action = ns.LootWindowButton(line, L["LOOT_MASTER_DISQUALIFY"], 92)
	line.action:SetHeight(18)
	line.action:SetPoint("RIGHT", -2, 0)
	return line
end

local MAX_ACTIONS = 5

local function MakeActionRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row.buttons = {}
	for index = 1, MAX_ACTIONS do
		local button = ns.LootWindowButton(row, "", 60)
		if index == 1 then
			button:SetPoint("LEFT", 0, 0)
		else
			button:SetPoint("LEFT", row.buttons[index - 1], "RIGHT", 4, 0)
		end
		row.buttons[index] = button
	end
	function row:SetActions(actions)
		for index, button in ipairs(self.buttons) do
			local action = actions[index]
			if action then
				ns.SetLootWindowButtonText(button, action.caption)
				button:SetScript("OnClick", action.onClick)
				button:SetEnabled(not action.disabled)
				button:Show()
			else
				button:Hide()
			end
		end
	end
	return row
end

local function MakeTimeBar(parent)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetMinMaxValues(0, 1)
	bar.background = bar:CreateTexture(nil, "BACKGROUND")
	bar.background:SetAllPoints()
	bar.background:SetColorTexture(0, 0, 0, 0.5)
	return bar
end

--------------------------------------------------------------------------------
-- Roll List Rows
--------------------------------------------------------------------------------

---@param colorKey string
---@param text string
---@return string
local function Colored(colorKey, text)
	return GetColor(colorKey) .. text .. "|r"
end

---@param entry table
---@return string clock
---@return number|nil barShare # 0 to 1
---@return number r, number g, number b, number a # the bar's color
local function EntryClock(entry)
	if entry.source == ns.LOOT_SOURCE_CORPSE then
		return Colored("INFO", entry.onCorpse and L["LOOT_MASTER_ON_CORPSE"] or L["LOOT_MASTER_CORPSE_CLOSED"]), nil
	end
	if entry.status == ns.ENTRY_EXPIRED then
		return Colored("MUTED", L["LOOT_MASTER_BOUND"]), nil
	end
	local left = ns:GetEntrySecondsLeft(entry)
	if not left then
		return Colored("MUTED", L["LOOT_MASTER_NO_LIMIT"]), nil
	end
	local share = math.min(1, left / ns.TRADE_WINDOW_SECONDS)
	if left < ns.TRADE_RED_SECONDS then
		return Colored("OFF", ns.FormatClock(left)), share, 0.8, 0.2, 0.2, 0.25
	elseif left < ns.TRADE_YELLOW_SECONDS then
		return Colored("TITLE", ns.FormatClock(left)), share, 1, 0.82, 0, 0.15
	end
	return ns.FormatClock(left), share, 1, 1, 1, 0.06
end

---@param entry table
---@param session table|nil
---@param isNext boolean
---@return string
local function EntryStatus(entry, session, isNext)
	if session and session.open then
		local count = 0
		for _, roll in ipairs(session.rolls) do
			if roll.round == session.round then
				count = count + 1
			end
		end
		local key = session.pausedLeft and "LOOT_MASTER_STATUS_ON_HOLD"
			or session.round > 1 and "LOOT_MASTER_STATUS_TIE_BREAK"
			or "LOOT_MASTER_STATUS_ROLLING"
		return Colored("OFF", L[key]:format(count))
	end
	if entry.status == ns.ENTRY_WON then
		return ns.LootWindowName(entry.winner)
	elseif entry.status == ns.ENTRY_TIED then
		return Colored("TITLE", L["LOOT_MASTER_STATUS_TIED"])
	elseif entry.status == ns.ENTRY_NOBODY then
		return Colored("MUTED", L["LOOT_MASTER_STATUS_NOBODY"])
	elseif entry.status == ns.ENTRY_EXPIRED then
		return Colored("MUTED", L["LOOT_MASTER_STATUS_SOULBOUND"])
	elseif isNext then
		return Colored("INFO", L["LOOT_MASTER_STATUS_UP_NEXT"])
	end
	return ""
end

-- A whole minute count of an entry's clock, for the detail line.
---@param entry table
---@return string
local function TradeLine(entry)
	local left = ns:GetEntrySecondsLeft(entry)
	if not left then
		return ""
	end
	return " "
		.. L["LOOT_MASTER_TRADABLE_FOR"]:format(SecondsToTime and SecondsToTime(left, true) or ns.FormatClock(left))
end

---@param entry table
---@param session table|nil
---@return string
local function EntryHeadline(entry, session)
	if session and session.open then
		local left = math.ceil(ns.GetRollSecondsLeft(session))
		if session.pausedLeft then
			return L["LOOT_MASTER_HEADLINE_ON_HOLD"]:format(left)
		elseif session.round > 1 then
			local names = {}
			for key in pairs(session.eligible or {}) do
				local roster = ns:GetRollRoster()
				names[#names + 1] = roster[key] and roster[key].name or key
			end
			table.sort(names)
			return L["LOOT_MASTER_HEADLINE_TIE_BREAK"]:format(table.concat(names, ", "), left)
		end
		return L["LOOT_MASTER_HEADLINE_ROLLING"]:format(left)
	end
	if entry.status == ns.ENTRY_WON then
		return L["LOOT_MASTER_HEADLINE_WON"]:format(ns.LootWindowName(entry.winner), entry.winValue or 0)
			.. TradeLine(entry)
	elseif entry.status == ns.ENTRY_TIED and session and session.tied then
		local names = {}
		for _, roll in ipairs(session.tied) do
			names[#names + 1] = ns.LootWindowName(roll.name)
		end
		return L["LOOT_MASTER_HEADLINE_TIED"]:format(table.concat(names, ", "), session.tied[1].value)
	elseif entry.status == ns.ENTRY_EXPIRED then
		return L["LOOT_MASTER_HEADLINE_SOULBOUND"]
	end
	local origin = entry.boss and L["LOOT_MASTER_LOOTED_FROM"]:format(entry.boss)
		or entry.source == ns.LOOT_SOURCE_FLOOR and L["LOOT_MASTER_FROM_FLOOR_LOOT"]
		or ""
	return origin .. TradeLine(entry)
end

-- The unit to trade with a winner, by name, while they're in the group.
---@param nameKey string
---@return string|nil
local function UnitForName(nameKey)
	local prefix, count = "party", GetNumGroupMembers() - 1
	if IsInRaid() then
		prefix, count = "raid", GetNumGroupMembers()
	end
	for index = 1, count do
		local unitIdentifier = prefix .. index
		if ns:GetLowercaseUnitName(unitIdentifier) == nameKey then
			return unitIdentifier
		end
	end
	return nil
end

local ShowDisqualifyDialog

---@param entry table
---@param session table|nil
---@return table[]
local function EntryActions(entry, session)
	if session and session.open and session.isMine then
		return {
			{
				caption = L["LOOT_MASTER_EXTEND"]:format(ns.ROLL_EXTEND_SECONDS),
				onClick = function()
					ns:ExtendRoll(session)
				end,
			},
			{
				caption = L["LOOT_MASTER_CLOSE_NOW"],
				onClick = function()
					ns:CloseRollNow(session)
				end,
			},
			{
				caption = L["LOOT_MASTER_VOID"],
				onClick = function()
					StaticPopup_Show("GOGOLOOT_VOID_ROLLS", session.itemLink, nil, session)
				end,
			},
			{
				caption = L["LOOT_MASTER_CANCEL_ROLL"],
				onClick = function()
					ns:CancelRoll(session)
				end,
			},
		}
	end
	local takeOff = {
		caption = L["LOOT_MASTER_TAKE_OFF"],
		onClick = function()
			ns:RemoveRollListEntry(entry)
		end,
	}
	if entry.status == ns.ENTRY_WON then
		local actions = {}
		if entry.source == ns.LOOT_SOURCE_CORPSE then
			actions[#actions + 1] = {
				caption = L["LOOT_MASTER_GIVE"]:format(entry.winner or ""),
				disabled = not entry.onCorpse,
				onClick = function()
					ns:GiveCorpseEntry(entry)
				end,
			}
		else
			local unitIdentifier = entry.winnerKey and UnitForName(entry.winnerKey)
			actions[#actions + 1] = {
				caption = L["LOOT_MASTER_TRADE"]:format(entry.winner or ""),
				disabled = unitIdentifier == nil,
				onClick = function()
					InitiateTrade(unitIdentifier)
				end,
			}
		end
		actions[#actions + 1] = {
			caption = L["LOOT_MASTER_ANNOUNCE_WINNER"],
			disabled = session == nil,
			onClick = function()
				ns:AnnounceRollWinner(session)
			end,
		}
		actions[#actions + 1] = {
			caption = L["LOOT_MASTER_VOID"],
			disabled = session == nil or ns:IsOwnRollOpen(),
			onClick = function()
				StaticPopup_Show("GOGOLOOT_VOID_ROLLS", session.itemLink, nil, session)
			end,
		}
		actions[#actions + 1] = {
			caption = L["LOOT_MASTER_HANDED_OUT"],
			onClick = function()
				ns:MarkEntryHandedOut(entry)
			end,
		}
		return actions
	end
	if entry.status == ns.ENTRY_TIED and session then
		return {
			{
				caption = L["LOOT_MASTER_REROLL_TIED"],
				disabled = ns:IsOwnRollOpen(),
				onClick = function()
					ns:RerollTie(session)
				end,
			},
			{
				caption = L["LOOT_MASTER_VOID"],
				disabled = ns:IsOwnRollOpen(),
				onClick = function()
					StaticPopup_Show("GOGOLOOT_VOID_ROLLS", session.itemLink, nil, session)
				end,
			},
			takeOff,
		}
	end
	if entry.status == ns.ENTRY_EXPIRED then
		return { takeOff }
	end
	return {
		{
			caption = entry.status == ns.ENTRY_NOBODY and L["LOOT_MASTER_ROLL_AGAIN"] or L["LOOT_MASTER_ROLL"],
			disabled = not ns:CanRollEntry(entry),
			onClick = function()
				ns:RollEntry(entry)
			end,
		},
		takeOff,
	}
end

---@param panel table
---@param session table
---@param round number
---@param title string
---@return nil
local function LayoutRound(panel, session, round, title)
	local list = panel.list
	local header = panel.texts:Acquire()
	header.text:SetText(Colored("TITLE", title))
	list:Place(header, LINE_HEIGHT, DETAIL_INDENT)

	-- Counted rolls first, highest first, then the ones that don't count, in the order they came.
	local counted = {}
	for _, roll in ipairs(session.rolls) do
		if roll.round == round and not roll.reject then
			counted[#counted + 1] = roll
		end
	end
	table.sort(counted, function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		end
		return a.order < b.order
	end)
	local top = counted[1] and counted[1].value
	for rank, roll in ipairs(counted) do
		local line = panel.rollLines:Acquire()
		local tag, tagColor = ns:GetRollTag(session, roll)
		line.rank:SetText(rank)
		line.name:SetText(ns.LootWindowName(roll.name))
		line.value:SetText(Colored(roll.value == top and "ON" or "TEXT", roll.value))
		line.tag:SetText(Colored(tagColor, tag))
		local canDisqualify = session.isMine
			and round == session.round
			and (session.open or session.status == ns.ENTRY_WON)
		line.action:SetShown(canDisqualify)
		if canDisqualify then
			ns.SetLootWindowButtonText(line.action, L["LOOT_MASTER_DISQUALIFY"])
			line.action:SetScript("OnClick", function()
				ShowDisqualifyDialog(session, roll)
			end)
		end
		list:Place(line, ROLL_LINE_HEIGHT, DETAIL_INDENT)
	end
	for _, roll in ipairs(session.rolls) do
		if roll.round == round and roll.reject then
			local line = panel.rollLines:Acquire()
			local tag, tagColor = ns:GetRollTag(session, roll)
			line.rank:SetText("")
			line.name:SetText(ns.LootWindowName(roll.name))
			line.value:SetText(Colored("MUTED", roll.value))
			line.tag:SetText(Colored(tagColor, tag))
			local canRestore = session.isMine and roll.reject == ns.ROLL_REJECT_MANUAL
			line.action:SetShown(canRestore)
			if canRestore then
				ns.SetLootWindowButtonText(line.action, L["LOOT_MASTER_RESTORE"])
				line.action:SetScript("OnClick", function()
					ns:RestoreRoll(session, roll)
				end)
			end
			list:Place(line, ROLL_LINE_HEIGHT, DETAIL_INDENT)
		end
	end
end

---@param panel table
---@param entry table
---@param session table|nil
---@return nil
local function LayoutDetails(panel, entry, session)
	local list = panel.list
	local headline = panel.texts:Acquire()
	headline.text:SetText(EntryHeadline(entry, session))
	list:Place(headline, LINE_HEIGHT, DETAIL_INDENT)

	if session and session.open then
		local bar = panel.bars:Acquire()
		bar:SetValue(session.length > 0 and ns.GetRollSecondsLeft(session) / session.length or 0)
		if session.pausedLeft then
			bar:SetStatusBarColor(0.5, 0.5, 0.5)
		else
			bar:SetStatusBarColor(1, 0.28, 0)
		end
		list:Place(bar, 6, DETAIL_INDENT)
		list:Gap(4)
	end

	if session and #session.rolls > 0 then
		if session.round > 1 then
			LayoutRound(panel, session, session.round, L["LOOT_MASTER_ROUND_TIE_BREAK"])
			for round = session.round - 1, 1, -1 do
				LayoutRound(
					panel,
					session,
					round,
					round == 1 and L["LOOT_MASTER_ROUND_FIRST"] or L["LOOT_MASTER_ROUND_TIE_BREAK"]
				)
			end
		else
			LayoutRound(
				panel,
				session,
				1,
				session.open and L["LOOT_MASTER_ROUND_SO_FAR"] or L["LOOT_MASTER_ROUND_ROLLS"]
			)
		end
	end

	if session and session.open then
		local waiting = ns:GetRollWaitingNames(session)
		if #waiting > 0 then
			local line = panel.texts:Acquire()
			line.text:SetText(
				Colored("MUTED", L["LOOT_MASTER_HASNT_ROLLED"]:format(#waiting, table.concat(waiting, ", ")))
			)
			list:Place(line, LINE_HEIGHT, DETAIL_INDENT)
		end
	end

	local actions = panel.actionRows:Acquire()
	actions:SetActions(EntryActions(entry, session))
	list:Place(actions, ACTION_ROW_HEIGHT, DETAIL_INDENT)
	list:Gap(6)
end

---@return nil
local function RefreshRollList()
	local panel = panels.LIST
	local entries = ns:GetRollListEntries()
	local live = ns:IsRollOpen() and ns.currentRoll or nil
	local firstWaiting
	for _, entry in ipairs(entries) do
		if entry.status == ns.ENTRY_WAITING then
			firstWaiting = entry
			break
		end
	end

	for _, pool in ipairs({ panel.rows, panel.texts, panel.rollLines, panel.actionRows, panel.bars }) do
		pool:Release()
	end
	local list = panel.list
	list:Begin()

	if #entries == 0 then
		local line = panel.texts:Acquire()
		line.text:SetText(Colored("MUTED", L["LOOT_MASTER_EMPTY"]))
		list:Place(line, LINE_HEIGHT * 2, 4)
	end

	local soonest
	for index, entry in ipairs(entries) do
		local session = ns:GetEntryRoll(entry)
		local isLive = live and session == live
		local row = panel.rows:Acquire()
		row.entry, row.itemLink = entry, entry.link
		row.icon:SetTexture(ns.GetLootWindowIcon(entry.link))
		row.name:SetText(ns:GetEntryLinkText(entry))
		local clock, share, r, g, b, a = EntryClock(entry)
		row.clock:SetText(clock)
		if share then
			row.bar:SetColorTexture(r, g, b, a)
			row.bar:SetWidth(math.max(1, (list:Width() - 4) * share))
			row.bar:Show()
		else
			row.bar:Hide()
		end
		row.status:SetText(EntryStatus(entry, session, ns.rollAll.running and entry == firstWaiting))
		row.roll:SetEnabled(ns:CanRollEntry(entry))
		row.up:SetEnabled(index > 1)
		row.down:SetEnabled(index < #entries)
		list:Place(row, ROW_HEIGHT, 0)
		if expanded[entry.key] or isLive then
			LayoutDetails(panel, entry, session)
		end
		local left = ns:GetEntrySecondsLeft(entry)
		if left and entry.status ~= ns.ENTRY_EXPIRED and (not soonest or left < soonest) then
			soonest = left
		end
	end
	list:Finish()

	-- The toolbar.
	local rollAll, waiting = ns.rollAll, 0
	for _, entry in ipairs(entries) do
		if entry.status == ns.ENTRY_WAITING then
			waiting = waiting + 1
		end
	end
	panel.rollAll:SetEnabled(not rollAll.running and waiting > 0)
	-- The live roll's own pause decides the button while one of the player's is open; Roll All's otherwise.
	local ownLive = live ~= nil and live.isMine
	local paused = ownLive and live.pausedLeft ~= nil or (not ownLive and rollAll.paused)
	ns.SetLootWindowButtonText(panel.pause, paused and L["LOOT_MASTER_RESUME"] or L["LOOT_MASTER_PAUSE"])
	panel.pause:SetEnabled(rollAll.running or ownLive)
	panel.stop:SetEnabled(rollAll.running)
	panel.listInRaid:SetEnabled(waiting > 0)
	local state
	if paused then
		state = L["LOOT_MASTER_STATE_PAUSED"]
	elseif rollAll.running then
		state = L["LOOT_MASTER_STATE_ROLL_ALL"]:format(waiting)
	elseif live then
		state = L["LOOT_MASTER_STATE_ONE_AT_A_TIME"]
	else
		state = L["LOOT_MASTER_STATE_WAITING"]:format(waiting)
	end
	panel.state:SetText(state)

	if soonest then
		panel.footer:SetText(L["LOOT_MASTER_FOOTER_CLOCK"]:format(#entries, ns.FormatClock(soonest)))
	else
		panel.footer:SetText(L["LOOT_MASTER_FOOTER"]:format(#entries))
	end
end

--------------------------------------------------------------------------------
-- Disqualify and Void Dialogs
--------------------------------------------------------------------------------

local dialog

local function BuildDisqualifyDialog()
	dialog = CreateFrame("Frame", "GogoLootDisqualifyDialog", UIParent, "BasicFrameTemplateWithInset")
	dialog:SetSize(420, 268)
	dialog:SetPoint("CENTER", 0, 80)
	dialog:SetFrameStrata("DIALOG")
	dialog:SetToplevel(true)
	dialog:EnableMouse(true)
	dialog:Hide()
	table.insert(UISpecialFrames, "GogoLootDisqualifyDialog")
	if type(dialog.TitleText) == "table" then
		dialog.TitleText:SetText(L["LOOT_MASTER_DISQUALIFY_TITLE"])
	end

	dialog.body = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	dialog.body:SetPoint("TOPLEFT", 16, -36)
	dialog.body:SetPoint("TOPRIGHT", -16, -36)
	dialog.body:SetJustifyH("LEFT")

	dialog.reasonTitle = ns.LootWindowText(dialog, "GameFontNormal")
	dialog.reasonTitle:SetPoint("TOPLEFT", dialog.body, "BOTTOMLEFT", 0, -10)
	dialog.reasonTitle:SetText(L["LOOT_MASTER_DISQUALIFY_REASON"])

	dialog.reasons = {}
	local previous = dialog.reasonTitle
	for _, reasonKey in ipairs(ns.ROLL_DISQUALIFY_REASONS) do
		local check = CreateFrame("CheckButton", nil, dialog, "UICheckButtonTemplate")
		check:SetSize(22, 22)
		check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previous == dialog.reasonTitle and -2 or 0, -2)
		check.label = ns.LootWindowText(check)
		check.label:SetPoint("LEFT", check, "RIGHT", 2, 0)
		check.label:SetText(L["ROLL_DISQUALIFY_REASON_" .. reasonKey])
		check.reasonKey = reasonKey
		check:SetScript("OnClick", function(self)
			dialog.reasonKey = self.reasonKey
			dialog:Update()
		end)
		dialog.reasons[#dialog.reasons + 1] = check
		previous = check
	end

	dialog.previewTitle = ns.LootWindowText(dialog, "GameFontHighlightSmall")
	dialog.previewTitle:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 2, -8)
	dialog.previewTitle:SetText(Colored("HELP", L["LOOT_MASTER_DISQUALIFY_TELLS"]))
	dialog.preview = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	dialog.preview:SetPoint("TOPLEFT", dialog.previewTitle, "BOTTOMLEFT", 0, -4)
	dialog.preview:SetWidth(388)
	dialog.preview:SetJustifyH("LEFT")

	dialog.ok = ns.LootWindowButton(dialog, L["LOOT_MASTER_DISQUALIFY"], 110, function()
		ns:DisqualifyRoll(dialog.session, dialog.roll, dialog.reasonKey)
		dialog:Hide()
	end)
	dialog.ok:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -4, 12)
	dialog.cancel = ns.LootWindowButton(dialog, CANCEL, 110, function()
		dialog:Hide()
	end)
	dialog.cancel:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", 4, 12)

	function dialog:Update()
		for _, check in ipairs(self.reasons) do
			check:SetChecked(check.reasonKey == self.reasonKey)
		end
		local message = ns:BuildDisqualifyMessage(self.roll, self.session.itemLink, self.reasonKey)
		self.preview:SetText(message or "")
	end
end

---@param session table
---@param roll table
---@return nil
ShowDisqualifyDialog = function(session, roll)
	if not dialog then
		BuildDisqualifyDialog()
	end
	dialog.session, dialog.roll = session, roll
	dialog.reasonKey = ns.ROLL_DISQUALIFY_REASONS[1]
	dialog.body:SetText(
		L["LOOT_MASTER_DISQUALIFY_BODY"]:format(ns.LootWindowName(roll.name), roll.value, session.itemLink)
	)
	dialog:Update()
	dialog:Show()
end

StaticPopupDialogs["GOGOLOOT_VOID_ROLLS"] = {
	text = L["LOOT_MASTER_VOID_CONFIRM"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(_, session)
		ns:VoidRolls(session)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

--------------------------------------------------------------------------------
-- Floor Loot
--------------------------------------------------------------------------------

local function MakeFloorRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(18, 18)
	row.icon:SetPoint("LEFT", 4, 0)
	row.name = ns.LootWindowText(row)
	row.name:SetPoint("LEFT", 28, 0)
	row.name:SetWidth(250)
	row.count = ns.LootWindowText(row, "GameFontHighlightSmall", "RIGHT")
	row.count:SetPoint("LEFT", 282, 0)
	row.count:SetWidth(70)
	row.status = ns.LootWindowText(row, "GameFontHighlightSmall")
	row.status:SetPoint("LEFT", 360, 0)
	row.status:SetWidth(84)
	row.roll = ns.LootWindowButton(row, L["LOOT_MASTER_ROLL"], 54, function(self)
		local entry = ns:AddFloorLootToRollList(self:GetParent().itemId)
		if entry and not ns.rollAll.running then
			ns:RollEntry(entry)
		end
	end)
	row.roll:SetPoint("RIGHT", -26, 0)
	row.remove = ns.LootWindowIconButton(
		row,
		ns.LOOT_WINDOW_REMOVE_ICON,
		16,
		L["LOOT_MASTER_FLOOR_REMOVE"],
		function(self)
			ns:RemoveFloorLoot(self:GetParent().itemId)
		end
	)
	row.remove:SetPoint("RIGHT", -4, 0)
	row:SetScript("OnClick", function(self)
		ns.InsertItemLinkIfShift(self.itemLink)
	end)
	ns.MakeItemHoverable(row)
	return row
end

-- A Floor Loot item's kind, as the game names its item class, for the list's headings.
---@param itemId number
---@return string
local function ItemKind(itemId)
	local _, _, _, _, _, _, _, _, _, _, _, classId = C_Item.GetItemInfo(itemId)
	return (classId and C_Item.GetItemClassInfo(classId)) or L["LOOT_MASTER_FLOOR_OTHER"]
end

---@return nil
local function RefreshFloorLoot()
	local panel = panels.FLOOR
	panel.rows:Release()
	panel.texts:Release()
	local list = panel.list
	list:Begin()

	local needle = string.lower(floorFilter)
	local groups, order = {}, {}
	for _, itemId in ipairs(ns:GetFloorLoot()) do
		local name, itemLink = C_Item.GetItemInfo(itemId)
		local shown = needle == ""
			or (name and string.find(string.lower(name), needle, 1, true))
			or string.find(tostring(itemId), needle, 1, true)
		if shown then
			local kind = ItemKind(itemId)
			if not groups[kind] then
				groups[kind] = {}
				order[#order + 1] = kind
			end
			table.insert(groups[kind], { itemId = itemId, link = itemLink, name = name or tostring(itemId) })
		end
	end
	table.sort(order)

	if #order == 0 then
		local line = panel.texts:Acquire()
		local empty = #ns:GetFloorLoot() == 0 and L["LOOT_MASTER_FLOOR_EMPTY"] or L["ITEM_LIST_NO_MATCHES"]
		line.text:SetText(Colored("MUTED", empty))
		list:Place(line, LINE_HEIGHT * 2, 4)
	end
	for _, kind in ipairs(order) do
		local header = panel.texts:Acquire()
		header.text:SetText(Colored("TITLE", kind))
		list:Place(header, LINE_HEIGHT, 0)
		table.sort(groups[kind], function(a, b)
			return a.name < b.name
		end)
		for _, item in ipairs(groups[kind]) do
			local row = panel.rows:Acquire()
			row.itemId, row.itemLink = item.itemId, item.link
			row.icon:SetTexture(ns.GetItemIconByID(item.itemId) or ns.LOOT_WINDOW_QUESTION_ICON)
			row.name:SetText(item.link or item.name)
			row.count:SetText(L["LOOT_MASTER_FLOOR_IN_BAGS"]:format(C_Item.GetItemCount(item.itemId)))
			local entry = ns:GetFloorLootEntry(item.itemId)
			row.status:SetText(entry and Colored("INFO", L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"]) or "")
			row.roll:SetEnabled(entry == nil and C_Item.GetItemCount(item.itemId) > 0)
			list:Place(row, 24, 0)
		end
	end
	list:Finish()

	local any = #ns:GetFloorLoot() > 0
	panel.listInRaid:SetEnabled(any)
	panel.addAll:SetEnabled(any)
end

-- Add from Bags: a short menu of what can be added, what was picked up in this instance first.
local function MakeMenuItem(parent)
	local item = CreateFrame("Button", nil, parent)
	item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	item.icon = item:CreateTexture(nil, "ARTWORK")
	item.icon:SetSize(16, 16)
	item.icon:SetPoint("LEFT", 4, 0)
	item.text = ns.LootWindowText(item, "GameFontHighlightSmall")
	item.text:SetPoint("LEFT", 24, 0)
	item.text:SetPoint("RIGHT", -4, 0)
	ns.MakeItemHoverable(item)
	return item
end

---@return nil
local function RefreshMenu()
	local menu = panels.FLOOR.menu
	menu.items:Release()
	menu.headers:Release()
	local list = menu.list
	list:Begin()
	local lastGroup
	local choices = ns:GetFloorLootChoices()
	if #choices == 0 then
		local line = menu.headers:Acquire()
		line.text:SetText(Colored("MUTED", L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"]))
		list:Place(line, LINE_HEIGHT * 2, 4)
	end
	for _, choice in ipairs(choices) do
		if choice.pickedUp ~= lastGroup then
			lastGroup = choice.pickedUp
			local header = menu.headers:Acquire()
			header.text:SetText(
				Colored(
					"TITLE",
					choice.pickedUp and L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] or L["LOOT_MASTER_FLOOR_MENU_BAGS"]
				)
			)
			list:Place(header, LINE_HEIGHT, 4)
		end
		local item = menu.items:Acquire()
		item.itemLink = choice.link
		item.icon:SetTexture(ns.GetItemIconByID(choice.itemId) or ns.LOOT_WINDOW_QUESTION_ICON)
		item.text:SetText(choice.count > 1 and L["ITEM_QUANTITY_LINK"]:format(choice.link, choice.count) or choice.link)
		item:SetScript("OnClick", function()
			ns:AddFloorLoot(choice.itemId)
			menu:Hide()
		end)
		list:Place(item, 20, 0)
	end
	list:Finish()
end

---@param panel table
---@return nil
local function AddTypedFloorLoot(panel)
	local text = panel.addBox:GetText()
	local itemId = ns:ResolveFloorLootInput(text)
	if itemId and C_Item.GetItemCount(itemId) > 0 then
		ns:AddFloorLoot(itemId)
		panel.addBox:SetText("")
		panel.addBox:ClearFocus()
	elseif text ~= "" then
		ns:PrintMessage(L["LOOT_MASTER_FLOOR_NOT_FOUND"]:format(text))
	end
end

-- An item dropped on the add box, or on its Add button, goes straight onto the list.
---@param panel table
---@return boolean
local function TakeCursorItem(panel)
	local kind, itemId = GetCursorInfo()
	if kind == "item" and itemId then
		ClearCursor()
		ns:AddFloorLoot(itemId)
		panel.addBox:ClearFocus()
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Awarded
--------------------------------------------------------------------------------

local function MakeAwardedRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(18, 18)
	row.icon:SetPoint("LEFT", 4, 0)
	row.name = ns.LootWindowText(row)
	row.name:SetPoint("LEFT", 28, 0)
	row.name:SetWidth(250)
	row.winner = ns.LootWindowText(row, "GameFontHighlightSmall")
	row.winner:SetPoint("LEFT", 284, 0)
	row.winner:SetWidth(110)
	row.note = ns.LootWindowText(row, "GameFontDisableSmall", "RIGHT")
	row.note:SetPoint("RIGHT", -4, 0)
	row.note:SetWidth(130)
	row:SetScript("OnClick", function(self)
		ns.InsertItemLinkIfShift(self.itemLink)
	end)
	ns.MakeItemHoverable(row)
	return row
end

---@return nil
local function RefreshAwarded()
	local panel = panels.DONE
	panel.rows:Release()
	panel.texts:Release()
	local list = panel.list
	list:Begin()
	local awarded = ns:GetAwarded()
	if #awarded == 0 then
		local line = panel.texts:Acquire()
		line.text:SetText(Colored("MUTED", L["LOOT_MASTER_AWARDED_EMPTY"]))
		list:Place(line, LINE_HEIGHT * 2, 4)
	end
	for _, record in ipairs(awarded) do
		local row = panel.rows:Acquire()
		row.itemLink = record.link
		row.icon:SetTexture(ns.GetLootWindowIcon(record.link))
		row.name:SetText(
			record.count and record.count > 1 and L["ITEM_QUANTITY_LINK"]:format(record.link, record.count)
				or record.link
		)
		row.winner:SetText(ns.LootWindowName(record.winner))
		local when = date("%H:%M", record.at)
		row.note:SetText(
			record.value and L["LOOT_MASTER_AWARDED_ROLLED"]:format(record.value, when)
				or L["LOOT_MASTER_AWARDED_GIVEN"]:format(when)
		)
		list:Place(row, 24, 0)
	end
	list:Finish()
	panel.clear:SetEnabled(#awarded > 0)
end

--------------------------------------------------------------------------------
-- Building the Window
--------------------------------------------------------------------------------

---@param parent table
---@return table
local function NewPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetPoint("TOPLEFT", 0, -30)
	panel:SetPoint("BOTTOMRIGHT", 0, 0)
	panel:Hide()
	return panel
end

local function BuildRollListPanel(content)
	local panel = NewPanel(content)
	panel.rollAll = ns.LootWindowButton(panel, L["LOOT_MASTER_ROLL_ALL"], nil, function()
		ns:StartRollAll()
	end)
	panel.rollAll:SetPoint("TOPLEFT", 0, 0)
	panel.pause = ns.LootWindowButton(panel, L["LOOT_MASTER_PAUSE"], nil, function()
		ns:TogglePauseRollAll()
	end)
	panel.pause:SetPoint("LEFT", panel.rollAll, "RIGHT", 4, 0)
	panel.stop = ns.LootWindowButton(panel, L["LOOT_MASTER_STOP"], nil, function()
		ns:StopRollAll()
	end)
	panel.stop:SetPoint("LEFT", panel.pause, "RIGHT", 4, 0)
	panel.listInRaid = ns.LootWindowButton(panel, L["LOOT_MASTER_LIST_IN_RAID"], nil, function()
		ns:ListRollListInRaid()
	end)
	panel.listInRaid:SetPoint("LEFT", panel.stop, "RIGHT", 4, 0)
	panel.state = ns.LootWindowText(panel, "GameFontHighlightSmall", "RIGHT")
	panel.state:SetPoint("TOPRIGHT", 0, -5)
	panel.state:SetWidth(150)

	panel.list = ns.LootWindowList(panel)
	panel.list:SetPoint("TOPLEFT", 0, -28)
	panel.list:SetPoint("BOTTOMRIGHT", -SCROLLBAR_ROOM, 20)

	panel.footer = ns.LootWindowText(panel, "GameFontDisableSmall")
	panel.footer:SetPoint("BOTTOMLEFT", 2, 2)
	panel.hint = ns.LootWindowText(panel, "GameFontDisableSmall", "RIGHT")
	panel.hint:SetPoint("BOTTOMRIGHT", -2, 2)
	panel.hint:SetText(L["LOOT_MASTER_ALT_CLICK_HINT"])

	panel.rows = ns.LootWindowPool(panel.list.child, MakeEntryRow)
	panel.texts = ns.LootWindowPool(panel.list.child, MakeTextLine)
	panel.rollLines = ns.LootWindowPool(panel.list.child, MakeRollLine)
	panel.actionRows = ns.LootWindowPool(panel.list.child, MakeActionRow)
	panel.bars = ns.LootWindowPool(panel.list.child, MakeTimeBar)
	return panel
end

local function BuildFloorLootPanel(content)
	local panel = NewPanel(content)
	panel.description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.description:SetPoint("TOPLEFT", 0, 0)
	panel.description:SetPoint("TOPRIGHT", 0, 0)
	panel.description:SetJustifyH("LEFT")
	panel.description:SetText(L["LOOT_MASTER_FLOOR_DESCRIPTION"])

	panel.addBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	panel.addBox:SetSize(250, 22)
	panel.addBox:SetAutoFocus(false)
	panel.addBox:SetPoint("TOPLEFT", panel.description, "BOTTOMLEFT", 6, -10)
	panel.addBox.placeholder = ns.LootWindowText(panel.addBox, "GameFontDisableSmall")
	panel.addBox.placeholder:SetPoint("LEFT", 2, 0)
	panel.addBox.placeholder:SetText(L["ITEM_LIST_ADD_PLACEHOLDER"])
	panel.addBox:SetScript("OnTextChanged", function(self)
		self.placeholder:SetShown(self:GetText() == "")
	end)
	panel.addBox:SetScript("OnEnterPressed", function()
		AddTypedFloorLoot(panel)
	end)
	panel.addBox:SetScript("OnEscapePressed", panel.addBox.ClearFocus)
	panel.addBox:SetScript("OnReceiveDrag", function()
		TakeCursorItem(panel)
	end)
	panel.addBox:HookScript("OnMouseDown", function()
		TakeCursorItem(panel)
	end)

	panel.add = ns.LootWindowButton(panel, L["ITEM_LIST_ADD_BUTTON"], nil, function()
		if not TakeCursorItem(panel) then
			AddTypedFloorLoot(panel)
		end
	end)
	panel.add:SetPoint("LEFT", panel.addBox, "RIGHT", 4, 0)
	panel.add:SetScript("OnReceiveDrag", function()
		TakeCursorItem(panel)
	end)

	panel.fromBags = ns.LootWindowButton(panel, L["ITEM_LIST_ADD_FROM_BAGS"], nil, function()
		if panel.menu:IsShown() then
			panel.menu:Hide()
		else
			RefreshMenu()
			panel.menu:Show()
		end
	end)
	panel.fromBags:SetPoint("LEFT", panel.add, "RIGHT", 8, 0)

	panel.filter = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	panel.filter:SetSize(250, 22)
	panel.filter:SetAutoFocus(false)
	panel.filter:SetPoint("TOPLEFT", panel.addBox, "BOTTOMLEFT", 0, -6)
	panel.filter.placeholder = ns.LootWindowText(panel.filter, "GameFontDisableSmall")
	panel.filter.placeholder:SetPoint("LEFT", 2, 0)
	panel.filter.placeholder:SetText(L["ITEM_LIST_FILTER_PLACEHOLDER"])
	panel.filter:SetScript("OnTextChanged", function(self)
		self.placeholder:SetShown(self:GetText() == "")
		floorFilter = self:GetText() or ""
		ns.RefreshLootWindows()
	end)
	panel.filter:SetScript("OnEscapePressed", panel.filter.ClearFocus)
	panel.filter:SetScript("OnEnterPressed", panel.filter.ClearFocus)

	panel.list = ns.LootWindowList(panel)
	panel.list:SetPoint("TOPLEFT", panel.filter, "BOTTOMLEFT", -6, -8)
	panel.list:SetPoint("BOTTOMRIGHT", -SCROLLBAR_ROOM, 30)

	panel.listInRaid = ns.LootWindowButton(panel, L["LOOT_MASTER_LIST_IN_RAID"], nil, function()
		ns:ListFloorLootInRaid()
	end)
	panel.listInRaid:SetPoint("BOTTOMLEFT", 0, 2)
	panel.addAll = ns.LootWindowButton(panel, L["LOOT_MASTER_FLOOR_ADD_ALL"], nil, function()
		if ns:AddAllFloorLootToRollList() > 0 then
			ns:SelectLootMasterTab("LIST")
		end
	end)
	panel.addAll:SetPoint("LEFT", panel.listInRaid, "RIGHT", 4, 0)

	panel.rows = ns.LootWindowPool(panel.list.child, MakeFloorRow)
	panel.texts = ns.LootWindowPool(panel.list.child, MakeTextLine)

	local menu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	menu:SetSize(300, 300)
	menu:SetPoint("TOPLEFT", panel.fromBags, "BOTTOMLEFT", 0, -2)
	menu:SetFrameStrata("DIALOG")
	menu:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	menu:SetBackdropColor(0, 0, 0, 0.95)
	menu:EnableMouse(true)
	menu:Hide()
	menu.list = ns.LootWindowList(menu)
	menu.list:SetPoint("TOPLEFT", 8, -8)
	menu.list:SetPoint("BOTTOMRIGHT", -28, 8)
	menu.items = ns.LootWindowPool(menu.list.child, MakeMenuItem)
	menu.headers = ns.LootWindowPool(menu.list.child, MakeTextLine)
	panel.menu = menu
	panel:SetScript("OnHide", function()
		menu:Hide()
	end)
	return panel
end

local function BuildAwardedPanel(content)
	local panel = NewPanel(content)
	panel.list = ns.LootWindowList(panel)
	panel.list:SetPoint("TOPLEFT", 0, 0)
	panel.list:SetPoint("BOTTOMRIGHT", -SCROLLBAR_ROOM, 30)
	panel.clear = ns.LootWindowButton(panel, L["LOOT_MASTER_AWARDED_CLEAR"], nil, function()
		ns:ClearAwarded()
	end)
	panel.clear:SetPoint("BOTTOMLEFT", 0, 2)
	panel.rows = ns.LootWindowPool(panel.list.child, MakeAwardedRow)
	panel.texts = ns.LootWindowPool(panel.list.child, MakeTextLine)
	return panel
end

-- Soft Reserves: the import box, drawn and not yet wired up.
local function BuildSoftReservesPanel(content)
	local panel = NewPanel(content)
	panel.description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.description:SetPoint("TOPLEFT", 0, 0)
	panel.description:SetPoint("TOPRIGHT", 0, 0)
	panel.description:SetJustifyH("LEFT")
	panel.description:SetText(L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"])

	local box = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	box:SetPoint("TOPLEFT", panel.description, "BOTTOMLEFT", 0, -10)
	box:SetPoint("TOPRIGHT", panel.description, "BOTTOMRIGHT", 0, -10)
	box:SetHeight(220)
	box:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	box:SetBackdropColor(0, 0, 0, 0.6)
	local placeholder = ns.LootWindowText(box, "GameFontDisable")
	placeholder:SetPoint("TOPLEFT", 10, -10)
	placeholder:SetText(L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"])

	local import = ns.LootWindowButton(panel, L["LOOT_MASTER_SOFT_RESERVES_IMPORT"])
	import:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -8)
	import:Disable()
	return panel
end

local TAB_REFRESHERS = {
	LIST = RefreshRollList,
	FLOOR = RefreshFloorLoot,
	DONE = RefreshAwarded,
}

---@return nil
local function Refresh()
	if not frame or not frame:IsShown() then
		return
	end
	tabs:SetCaption("LIST", L["LOOT_MASTER_TAB_ROLL_LIST"]:format(#ns:GetRollListEntries()))
	tabs:SetCaption("FLOOR", L["LOOT_MASTER_TAB_FLOOR_LOOT"]:format(#ns:GetFloorLoot()))
	tabs:SetCaption("DONE", L["LOOT_MASTER_TAB_AWARDED"]:format(#ns:GetAwarded()))
	tabs:Select(selectedTab)
	for key, panel in pairs(panels) do
		panel:SetShown(key == selectedTab)
	end
	local refresher = TAB_REFRESHERS[selectedTab]
	if refresher then
		refresher()
	end
end

local function BuildWindow()
	frame = ns.CreateLootWindow(WINDOW_NAME, L["TAB_LOOT_MASTER"], WINDOW_WIDTH, WINDOW_HEIGHT)
	local content = frame.content
	tabs = ns.LootWindowTabs(content, {
		{ key = "LIST", caption = L["LOOT_MASTER_TAB_ROLL_LIST"]:format(0) },
		{ key = "FLOOR", caption = L["LOOT_MASTER_TAB_FLOOR_LOOT"]:format(0) },
		{ key = "DONE", caption = L["LOOT_MASTER_TAB_AWARDED"]:format(0) },
		{ key = "SOFT", caption = L["LOOT_MASTER_TAB_SOFT_RESERVES"] },
	}, function(key)
		ns:SelectLootMasterTab(key)
	end)

	panels.LIST = BuildRollListPanel(content)
	panels.FLOOR = BuildFloorLootPanel(content)
	panels.DONE = BuildAwardedPanel(content)
	panels.SOFT = BuildSoftReservesPanel(content)

	-- The clocks run while the window shows.
	local elapsedSinceRefresh = 0
	frame:SetScript("OnUpdate", function(_, elapsed)
		elapsedSinceRefresh = elapsedSinceRefresh + elapsed
		if elapsedSinceRefresh >= ns.WINDOW_TICK_SECONDS then
			elapsedSinceRefresh = 0
			Refresh()
		end
	end)
	frame:SetScript("OnShow", Refresh)
end

ns.AddLootWindowRefresher(Refresh)

--------------------------------------------------------------------------------
-- Opening
--------------------------------------------------------------------------------

---@param key string
---@return nil
function ns:SelectLootMasterTab(key)
	selectedTab = key
	Refresh()
end

---@return nil
function ns:ShowLootMaster()
	if not ns.db.profile.lootMaster then
		ns:PrintMessage(L["LOOT_MASTER_OFF"])
		return
	end
	if not frame then
		BuildWindow()
	end
	frame:Show()
	Refresh()
end

---@return nil
function ns:ToggleLootMaster()
	if frame and frame:IsShown() then
		frame:Hide()
	else
		ns:ShowLootMaster()
	end
end

---@return boolean
function ns:IsLootMasterShown()
	return frame ~= nil and frame:IsShown()
end
