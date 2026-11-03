--------------------------------------------------------------------------------
-- GogoLoot Loot Tracker Window
--------------------------------------------------------------------------------

--[[
    The window every raider sees, in two tabs:

      * Rolls: the roll in progress, its rolls as they land, sorted highest
        first or as they came, the ones that don't count greyed with the
        reason, who hasn't rolled, and Roll and Pass buttons. Earlier rolls
        sit underneath and open to show theirs.
      * Drops: what dropped tonight, boss by boss, with who got it, printed,
        posted to the group, or copied as plain text.

    It opens on its own when someone calls for rolls (Open When Anyone Calls
    for Rolls), and when it did, closes itself a while after the roll ends
    unless the mouse is over it. Never for a roll the player called: they
    have the Loot Master open.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local WINDOW_NAME = "GogoLootLootTrackerFrame"
local WINDOW_WIDTH, WINDOW_HEIGHT = 440, 580
local LINE_HEIGHT = 18
local ROLL_LINE_HEIGHT = 18
local SCROLLBAR_ROOM = 26
-- Seconds the window stays after a roll it opened for has ended, and how often it looks again while the mouse is over it.
local AUTO_CLOSE_SECONDS = 30
local AUTO_CLOSE_RECHECK = 5

local frame
local tabs
local panels = {}
local selectedTab = "ROLLS"
local sortMode = "HIGH"
local openHistory = {}
local showWinners = true
local lastSeenRollId
local openedForRoll = false

---@param colorKey string
---@param text any
---@return string
local function Colored(colorKey, text)
	return GetColor(colorKey) .. tostring(text) .. "|r"
end

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

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
	line.name = ns.LootWindowText(line, "GameFontHighlight")
	line.name:SetPoint("LEFT", 24, 0)
	line.name:SetWidth(130)
	line.value = ns.LootWindowText(line, "GameFontHighlight", "RIGHT")
	line.value:SetPoint("LEFT", 156, 0)
	line.value:SetWidth(34)
	line.tag = ns.LootWindowText(line, "GameFontHighlightSmall")
	line.tag:SetPoint("LEFT", 198, 0)
	line.tag:SetPoint("RIGHT", 0, 0)
	return line
end

local function MakeHistoryRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(18, 18)
	row.icon:SetPoint("LEFT", 2, 0)
	row.name = ns.LootWindowText(row)
	row.name:SetPoint("LEFT", 24, 0)
	row.name:SetWidth(210)
	row.winner = ns.LootWindowText(row, "GameFontHighlightSmall", "RIGHT")
	row.winner:SetPoint("RIGHT", -4, 0)
	row.winner:SetWidth(130)
	row:SetScript("OnClick", function(self)
		if ns.InsertItemLinkIfShift(self.itemLink) then
			return
		end
		openHistory[self.session] = not openHistory[self.session]
		ns.RefreshLootWindows()
	end)
	ns.MakeItemHoverable(row)
	return row
end

local function MakeDropLine(parent)
	local line = CreateFrame("Button", nil, parent)
	line.icon = line:CreateTexture(nil, "ARTWORK")
	line.icon:SetSize(16, 16)
	line.icon:SetPoint("LEFT", 6, 0)
	line.name = ns.LootWindowText(line, "GameFontHighlightSmall")
	line.name:SetPoint("LEFT", 26, 0)
	line.name:SetWidth(220)
	line.who = ns.LootWindowText(line, "GameFontHighlightSmall", "RIGHT")
	line.who:SetPoint("RIGHT", -4, 0)
	line.who:SetWidth(130)
	line:SetScript("OnClick", function(self)
		ns.InsertItemLinkIfShift(self.itemLink)
	end)
	ns.MakeItemHoverable(line)
	return line
end

--------------------------------------------------------------------------------
-- Rolls
--------------------------------------------------------------------------------

---@param session table
---@param rolls table[]
---@param mode string
---@return table[]
local function OrderRolls(session, rolls, mode)
	local ordered = {}
	for _, roll in ipairs(rolls) do
		ordered[#ordered + 1] = roll
	end
	if mode == "TIME" then
		table.sort(ordered, function(a, b)
			return a.order < b.order
		end)
		return ordered
	end
	table.sort(ordered, function(a, b)
		local aCounts, bCounts = not a.reject and a.round == session.round, not b.reject and b.round == session.round
		if aCounts ~= bCounts then
			return aCounts
		end
		if aCounts and a.value ~= b.value then
			return a.value > b.value
		end
		return a.order < b.order
	end)
	return ordered
end

---@param panel table
---@param session table
---@param rolls table[]
---@param mode string
---@param indent number
---@return nil
local function LayoutRolls(panel, session, rolls, mode, indent)
	local playerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("player"))
	local counted = ns:GetCountedRolls(session)
	local rankOf = {}
	for rank, roll in ipairs(counted) do
		rankOf[roll] = rank
	end
	local top = counted[1] and counted[1].value
	for _, roll in ipairs(OrderRolls(session, rolls, mode)) do
		local line = panel.rollLines:Acquire()
		local tag, tagColor = ns:GetRollTag(session, roll)
		if tag == "" and roll.key == playerKey then
			tag, tagColor = L["LOOT_TRACKER_YOU"], "INFO"
		end
		line.rank:SetText(rankOf[roll] or "")
		line.name:SetText(ns.LootWindowName(roll.name))
		local valueColor = roll.reject and "MUTED"
			or (roll.value == top and roll.round == session.round) and "ON"
			or "TEXT"
		line.value:SetText(Colored(valueColor, roll.value))
		line.tag:SetText(Colored(tagColor, tag))
		panel.list:Place(line, ROLL_LINE_HEIGHT, indent)
	end
end

---@param session table
---@return string
local function RollTitle(session)
	if session.open then
		return session.round > 1 and L["LOOT_TRACKER_TIE_BREAK_ROLLS"] or L["LOOT_MASTER_ROUND_SO_FAR"]
	end
	if session.status == ns.ENTRY_WON and session.winner then
		return L["LOOT_TRACKER_WON_WITH"]:format(ns.LootWindowName(session.winner.name), session.winner.value or 0)
	elseif session.status == ns.ENTRY_TIED then
		return L["LOOT_MASTER_STATUS_TIED"]
	elseif session.status == ns.ENTRY_NOBODY then
		return L["LOOT_MASTER_STATUS_NOBODY"]
	end
	return L["LOOT_TRACKER_CLOSED"]
end

---@param session table
---@return string
local function MyLine(session)
	local playerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("player"))
	if session.passes[playerKey] then
		return L["LOOT_TRACKER_YOU_PASSED"]
	end
	for _, roll in ipairs(session.rolls) do
		if roll.key == playerKey and roll.round == session.round then
			return L["LOOT_TRACKER_YOU_ROLLED"]:format(roll.value)
		end
	end
	if session.eligible and not session.eligible[playerKey] then
		return L["LOOT_TRACKER_NOT_IN_TIE_BREAK"]
	end
	return session.open and L["LOOT_TRACKER_NOT_ROLLED"] or ""
end

---@return nil
local function RefreshRolls()
	local panel = panels.ROLLS
	for _, pool in ipairs({ panel.rollLines, panel.texts, panel.historyRows }) do
		pool:Release()
	end
	local list = panel.list
	list:Begin()

	local session = ns.currentRoll
	if not session then
		panel.icon:SetTexture(ns.LOOT_WINDOW_QUESTION_ICON)
		panel.item:SetText(Colored("MUTED", L["LOOT_TRACKER_NO_ROLL"]))
		panel.itemButton.itemLink = nil
		panel.caller:SetText("")
		panel.seconds:SetText("")
		panel.bar:SetValue(0)
		panel.note:SetText("")
		panel.title:SetText("")
		panel.roll:Disable()
		panel.pass:Disable()
		panel.mine:SetText("")
	else
		panel.icon:SetTexture(ns.GetLootWindowIcon(session.itemLink))
		panel.item:SetText(session.itemLink)
		panel.itemButton.itemLink = session.itemLink
		local caller = session.caller and ns.LootWindowName(session.caller) or ""
		panel.caller:SetText(
			session.synced and L["LOOT_TRACKER_CALLED_BY"]:format(caller) or L["LOOT_TRACKER_SPOTTED"]:format(caller)
		)
		local left = ns.GetRollSecondsLeft(session)
		if session.open then
			panel.seconds:SetText(
				Colored(session.pausedLeft and "MUTED" or "OFF", L["LOOT_TRACKER_SECONDS_LEFT"]:format(math.ceil(left)))
			)
			panel.bar:SetValue(session.length > 0 and left / session.length or 0)
		else
			panel.seconds:SetText("")
			panel.bar:SetValue(0)
		end
		if not session.synced and not session.isMine then
			panel.note:SetText(Colored("HELP", L["LOOT_TRACKER_UNSYNCED_NOTE"]:format(caller)))
		elseif session.pausedLeft then
			panel.note:SetText(Colored("HELP", L["LOOT_TRACKER_ON_HOLD"]))
		else
			panel.note:SetText("")
		end
		panel.title:SetText(Colored("TITLE", RollTitle(session)))

		local current = {}
		for _, roll in ipairs(session.rolls) do
			if roll.round == session.round then
				current[#current + 1] = roll
			end
		end
		LayoutRolls(panel, session, current, sortMode, 0)
		if session.open then
			local waiting = ns:GetRollWaitingNames(session)
			if #waiting > 0 then
				local line = panel.texts:Acquire()
				line.text:SetText(
					Colored("MUTED", L["LOOT_MASTER_HASNT_ROLLED"]:format(#waiting, table.concat(waiting, ", ")))
				)
				list:Place(line, LINE_HEIGHT, 0)
			end
		end
		local playerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("player"))
		local mayRoll = session.open and (not session.eligible or session.eligible[playerKey])
		local answered = session.passes[playerKey]
		for _, roll in ipairs(session.rolls) do
			if roll.key == playerKey and roll.round == session.round and not roll.reject then
				answered = true
			end
		end
		panel.roll:SetEnabled(mayRoll and not answered)
		panel.pass:SetEnabled(mayRoll and not answered and not session.isMine)
		panel.mine:SetText(MyLine(session))
	end

	-- Earlier tonight, newest first, each opening to show its rolls.
	local shownHistory = false
	for _, earlier in ipairs(ns.rollHistory) do
		if earlier ~= session and not earlier.canceled then
			if not shownHistory then
				shownHistory = true
				list:Gap(8)
				local header = panel.texts:Acquire()
				header.text:SetText(Colored("TITLE", L["LOOT_TRACKER_EARLIER"]))
				list:Place(header, LINE_HEIGHT, 0)
			end
			local row = panel.historyRows:Acquire()
			row.session, row.itemLink = earlier, earlier.itemLink
			row.icon:SetTexture(ns.GetLootWindowIcon(earlier.itemLink))
			row.name:SetText(earlier.itemLink)
			if earlier.winner then
				row.winner:SetText(
					ns.LootWindowName(earlier.winner.name) .. " " .. Colored("ON", earlier.winner.value or "")
				)
			else
				row.winner:SetText(Colored("MUTED", RollTitle(earlier)))
			end
			list:Place(row, 22, 0)
			if openHistory[earlier] then
				local rounds = {}
				for _, roll in ipairs(earlier.rolls) do
					if roll.round == earlier.round then
						rounds[#rounds + 1] = roll
					end
				end
				LayoutRolls(panel, earlier, rounds, "HIGH", 24)
			end
		end
	end
	list:Finish()
end

--------------------------------------------------------------------------------
-- Drops
--------------------------------------------------------------------------------

---@return nil
local function RefreshDrops()
	local panel = panels.DROPS
	panel.lines:Release()
	panel.texts:Release()
	local list = panel.list
	list:Begin()
	local raid = ns:GetDropRaids()[1]
	panel.raid:SetText(raid and raid.name or "")
	if not raid or #raid.bosses == 0 then
		local line = panel.texts:Acquire()
		line.text:SetText(Colored("MUTED", L["LOOT_TRACKER_DROPS_EMPTY"]))
		list:Place(line, LINE_HEIGHT * 2, 4)
	else
		for _, boss in ipairs(raid.bosses) do
			local header = panel.texts:Acquire()
			local when = boss.name and date("%H:%M", boss.at) or ""
			header.text:SetText(Colored("TITLE", ns:GetDropBossName(boss)) .. "  " .. Colored("MUTED", when))
			list:Place(header, LINE_HEIGHT + 2, 0)
			if #boss.items == 0 then
				local none = panel.texts:Acquire()
				none.text:SetText(Colored("MUTED", L["LOOT_TRACKER_DROPS_NOTHING_SEEN"]))
				list:Place(none, LINE_HEIGHT, 8)
			end
			for _, item in ipairs(boss.items) do
				local line = panel.lines:Acquire()
				line.itemLink = item.link
				line.icon:SetTexture(ns.GetLootWindowIcon(item.link))
				line.name:SetText(
					item.count and item.count > 1 and L["ITEM_QUANTITY_LINK"]:format(item.link, item.count) or item.link
				)
				if showWinners and item.winner then
					local who = ns.LootWindowName(item.winner)
					line.who:SetText(item.value and L["DROPS_WINNER_ROLL"]:format(who, item.value) or who)
				else
					line.who:SetText(showWinners and Colored("MUTED", L["LOOT_TRACKER_NOT_HANDED_OUT"]) or "")
				end
				list:Place(line, 20, 0)
			end
		end
	end
	list:Finish()
	panel.winners:SetChecked(showWinners)
	local any = raid ~= nil and #raid.bosses > 0
	panel.print:SetEnabled(any)
	panel.post:SetEnabled(any)
	panel.copy:SetEnabled(any)
end

local copyFrame

local function ShowCopyFrame(text)
	if not copyFrame then
		copyFrame = CreateFrame("Frame", "GogoLootDropsCopyFrame", UIParent, "BasicFrameTemplateWithInset")
		copyFrame:SetSize(420, 260)
		copyFrame:SetPoint("CENTER")
		copyFrame:SetFrameStrata("DIALOG")
		copyFrame:EnableMouse(true)
		table.insert(UISpecialFrames, "GogoLootDropsCopyFrame")
		if type(copyFrame.TitleText) == "table" then
			copyFrame.TitleText:SetText(L["LOOT_TRACKER_COPY_TITLE"])
		end
		local scroll = CreateFrame("ScrollFrame", nil, copyFrame, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", 14, -32)
		scroll:SetPoint("BOTTOMRIGHT", -32, 14)
		local editBox = CreateFrame("EditBox", nil, scroll)
		editBox:SetMultiLine(true)
		editBox:SetAutoFocus(true)
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(360)
		-- A multi-line box grows with its text; this is only where it starts, so the whole box takes a click.
		editBox:SetHeight(200)
		editBox:SetScript("OnEscapePressed", function()
			copyFrame:Hide()
		end)
		scroll:SetScrollChild(editBox)
		copyFrame.editBox = editBox
	end
	copyFrame.editBox:SetText(text)
	copyFrame:Show()
	copyFrame.editBox:SetFocus()
	copyFrame.editBox:HighlightText()
end

--------------------------------------------------------------------------------
-- Building the Window
--------------------------------------------------------------------------------

local function NewPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetPoint("TOPLEFT", 0, -30)
	panel:SetPoint("BOTTOMRIGHT", 0, 0)
	panel:Hide()
	return panel
end

local function BuildRollsPanel(content)
	local panel = NewPanel(content)
	panel.icon = panel:CreateTexture(nil, "ARTWORK")
	panel.icon:SetSize(30, 30)
	panel.icon:SetPoint("TOPLEFT", 0, 0)
	panel.itemButton = CreateFrame("Button", nil, panel)
	panel.itemButton:SetPoint("TOPLEFT", 36, 0)
	panel.itemButton:SetSize(290, 16)
	panel.itemButton:SetScript("OnClick", function(self)
		ns.InsertItemLinkIfShift(self.itemLink)
	end)
	ns.MakeItemHoverable(panel.itemButton)
	panel.item = ns.LootWindowText(panel.itemButton)
	panel.item:SetAllPoints()
	panel.caller = ns.LootWindowText(panel, "GameFontHighlightSmall")
	panel.caller:SetPoint("TOPLEFT", 36, -17)
	panel.caller:SetWidth(290)
	panel.seconds = ns.LootWindowText(panel, "GameFontHighlightSmall", "RIGHT")
	panel.seconds:SetPoint("TOPRIGHT", 0, -2)

	panel.bar = CreateFrame("StatusBar", nil, panel)
	panel.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	panel.bar:SetStatusBarColor(1, 0.28, 0)
	panel.bar:SetMinMaxValues(0, 1)
	panel.bar:SetPoint("TOPLEFT", 0, -36)
	panel.bar:SetPoint("TOPRIGHT", 0, -36)
	panel.bar:SetHeight(6)
	panel.bar.background = panel.bar:CreateTexture(nil, "BACKGROUND")
	panel.bar.background:SetAllPoints()
	panel.bar.background:SetColorTexture(0, 0, 0, 0.5)

	panel.note = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.note:SetPoint("TOPLEFT", 0, -48)
	panel.note:SetPoint("TOPRIGHT", 0, -48)
	panel.note:SetJustifyH("LEFT")
	panel.note:SetHeight(28)

	panel.title = ns.LootWindowText(panel, "GameFontNormal")
	panel.title:SetPoint("TOPLEFT", 0, -82)
	panel.sortTime = ns.LootWindowButton(panel, L["LOOT_TRACKER_SORT_TIME"], nil, function()
		sortMode = "TIME"
		ns.RefreshLootWindows()
	end)
	panel.sortTime:SetPoint("TOPRIGHT", 0, -78)
	panel.sortHigh = ns.LootWindowButton(panel, L["LOOT_TRACKER_SORT_HIGH"], nil, function()
		sortMode = "HIGH"
		ns.RefreshLootWindows()
	end)
	panel.sortHigh:SetPoint("RIGHT", panel.sortTime, "LEFT", -4, 0)

	panel.list = ns.LootWindowList(panel)
	panel.list:SetPoint("TOPLEFT", 0, -104)
	panel.list:SetPoint("BOTTOMRIGHT", -SCROLLBAR_ROOM, 32)

	panel.roll = ns.LootWindowButton(panel, L["LOOT_TRACKER_ROLL"], nil, function()
		RandomRoll(ns.ROLL_LOW, ns.ROLL_HIGH)
	end)
	panel.roll:SetPoint("BOTTOMLEFT", 0, 4)
	panel.pass = ns.LootWindowButton(panel, PASS, nil, function()
		local channel = ns:GetGroupChatChannel()
		if channel then
			C_ChatInfo.SendChatMessage(string.lower(PASS or "pass"), channel)
		end
	end)
	panel.pass:SetPoint("LEFT", panel.roll, "RIGHT", 4, 0)
	panel.mine = ns.LootWindowText(panel, "GameFontHighlightSmall")
	panel.mine:SetPoint("LEFT", panel.pass, "RIGHT", 8, 0)

	panel.rollLines = ns.LootWindowPool(panel.list.child, MakeRollLine)
	panel.texts = ns.LootWindowPool(panel.list.child, MakeTextLine)
	panel.historyRows = ns.LootWindowPool(panel.list.child, MakeHistoryRow)
	return panel
end

local function BuildDropsPanel(content)
	local panel = NewPanel(content)
	panel.raid = ns.LootWindowText(panel)
	panel.raid:SetPoint("TOPLEFT", 0, -4)
	panel.winners = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	panel.winners:SetSize(22, 22)
	panel.winners:SetPoint("TOPRIGHT", -150, 0)
	panel.winners.label = ns.LootWindowText(panel.winners)
	panel.winners.label:SetPoint("LEFT", panel.winners, "RIGHT", 2, 0)
	panel.winners.label:SetText(L["LOOT_TRACKER_SHOW_WINNERS"])
	panel.winners:SetScript("OnClick", function(self)
		showWinners = self:GetChecked() and true or false
		ns.RefreshLootWindows()
	end)

	panel.list = ns.LootWindowList(panel)
	panel.list:SetPoint("TOPLEFT", 0, -28)
	panel.list:SetPoint("BOTTOMRIGHT", -SCROLLBAR_ROOM, 32)

	panel.print = ns.LootWindowButton(panel, L["LOOT_TRACKER_PRINT"], nil, function()
		ns:PrintDrops()
	end)
	panel.print:SetPoint("BOTTOMLEFT", 0, 4)
	panel.post = ns.LootWindowButton(panel, L["LOOT_TRACKER_POST"], nil, function()
		ns:PostDrops(nil, showWinners)
	end)
	panel.post:SetPoint("LEFT", panel.print, "RIGHT", 4, 0)
	panel.copy = ns.LootWindowButton(panel, L["LOOT_TRACKER_COPY"], nil, function()
		ShowCopyFrame(ns:GetDropsText(nil, showWinners))
	end)
	panel.copy:SetPoint("LEFT", panel.post, "RIGHT", 4, 0)

	panel.lines = ns.LootWindowPool(panel.list.child, MakeDropLine)
	panel.texts = ns.LootWindowPool(panel.list.child, MakeTextLine)
	return panel
end

---@return boolean
local function HasLootToHandOut()
	return #ns:GetRollListEntries() > 0 or ns:AreWeMasterLooter()
end

local function Refresh()
	if not frame or not frame:IsShown() then
		return
	end
	tabs:Select(selectedTab)
	for key, panel in pairs(panels) do
		panel:SetShown(key == selectedTab)
	end
	frame.lootMaster:SetShown(HasLootToHandOut())
	if selectedTab == "ROLLS" then
		RefreshRolls()
	else
		RefreshDrops()
	end
end

local function BuildWindow()
	frame = ns.CreateLootWindow(WINDOW_NAME, L["LOOT_TRACKER_TITLE"], WINDOW_WIDTH, WINDOW_HEIGHT)
	local content = frame.content
	tabs = ns.LootWindowTabs(content, {
		{ key = "ROLLS", caption = L["LOOT_TRACKER_TAB_ROLLS"] },
		{ key = "DROPS", caption = L["LOOT_TRACKER_TAB_DROPS"] },
	}, function(key)
		selectedTab = key
		Refresh()
	end)
	frame.lootMaster = ns.LootWindowButton(content, L["TAB_LOOT_MASTER"], nil, function()
		ns:ShowLootMaster()
	end)
	frame.lootMaster:SetPoint("TOPRIGHT", 0, 0)

	panels.ROLLS = BuildRollsPanel(content)
	panels.DROPS = BuildDropsPanel(content)

	local elapsedSinceRefresh = 0
	frame:SetScript("OnUpdate", function(_, elapsed)
		elapsedSinceRefresh = elapsedSinceRefresh + elapsed
		-- A live roll's countdown repaints four times a second; otherwise once.
		local every = ns:IsRollOpen() and ns.ROLL_TICK_SECONDS or ns.WINDOW_TICK_SECONDS
		if elapsedSinceRefresh >= every then
			elapsedSinceRefresh = 0
			Refresh()
		end
	end)
	frame:SetScript("OnShow", Refresh)
	frame:SetScript("OnHide", function()
		openedForRoll = false
		ns:CancelTimer("lootTrackerAutoClose")
	end)
end

--------------------------------------------------------------------------------
-- Opening and Closing on Their Own
--------------------------------------------------------------------------------

local function AutoClose()
	if not frame or not frame:IsShown() or not openedForRoll then
		return
	end
	if ns:IsRollOpen() then
		return
	end
	if frame:IsMouseOver() then
		ns:After("lootTrackerAutoClose", AUTO_CLOSE_RECHECK, AutoClose)
		return
	end
	frame:Hide()
end

--[[
    Runs on every loot change, shown or not: a new roll called by someone else
    opens the window, and the end of one it opened for starts the countdown to
    close it.
]]
local function WatchRolls()
	if not ns.db or not ns.db.profile.lootMaster then
		return
	end
	local session = ns.currentRoll
	if session and session.id ~= lastSeenRollId then
		lastSeenRollId = session.id
		if session.open and not session.isMine and ns.db.profile.lootTrackerOpenOnRoll then
			local wasShown = frame and frame:IsShown()
			ns:ShowLootTracker()
			selectedTab = "ROLLS"
			openedForRoll = openedForRoll or not wasShown
			ns:CancelTimer("lootTrackerAutoClose")
		end
	end
	if openedForRoll and session and not session.open and ns.db.profile.lootTrackerAutoClose then
		if not ns:IsTimerPending("lootTrackerAutoClose") then
			ns:After("lootTrackerAutoClose", AUTO_CLOSE_SECONDS, AutoClose)
		end
	end
	Refresh()
end

ns.AddLootWindowRefresher(WatchRolls)

---@return nil
function ns:ShowLootTracker()
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
function ns:ToggleLootTracker()
	if frame and frame:IsShown() then
		frame:Hide()
	else
		ns:ShowLootTracker()
	end
end
