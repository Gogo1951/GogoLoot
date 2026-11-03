local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local TooltipLines = ns.DiagnosticTooltipLines

--------------------------------------------------------------------------------
-- Validate Data
--------------------------------------------------------------------------------

-- The file a manifest entry names in the data folder this client loaded.
function ns.DataSourceFileName(entry)
	local folder = tostring(ns.DATA_FOLDER)
	return string.format("%s/%s-%s.lua", folder, entry.label, folder)
end

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local GetItemInfo = C_Item.GetItemInfo
local GetItemInfoInstant = C_Item.GetItemInfoInstant

--[[
    The reads beyond the item-info pair, each read once at load and nil where
    the client lacks it. One the client lacks leaves its cells blank, and its
    API Endpoints row says why.
]]
local GetItemSpell = C_Item.GetItemSpell
local GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo
local GetItemStats = ns.GetItemStats
local GetItemClassName = C_Item.GetItemClassInfo
local GetItemSubClassName = C_Item.GetItemSubClassInfo
local GetSpellDescription = C_Spell.GetSpellDescription
local RequestLoadSpellData = C_Spell.RequestLoadSpellData
local IsSpellDataCached = C_Spell.IsSpellDataCached
local GetQuestTitle = C_QuestLog.GetTitleForQuestID or C_QuestLog.GetQuestInfo
local RequestLoadQuest = C_QuestLog.RequestLoadQuestByID

--[[
    The spell and area kinds' own reads, through _G because an add-on whose
    data holds no spell or area never names them anywhere else.
]]
local GetSpellName = C_Spell.GetSpellName
local DoesSpellExist = C_Spell.DoesSpellExist
local IsPlayerSpell = _G.IsPlayerSpell
local IsSpellKnown = _G.IsSpellKnown
local GetAreaInfo = type(_G.C_Map) == "table" and _G.C_Map.GetAreaInfo or nil

--[[
    Every other reader the clients ship that answers from the id alone, one
    column per return: { namespace, function, header or headers }. Taken from
    the generated API documentation of the classic_era, classic_anniversary and
    forever branches; player and session state (counts, cooldowns, range,
    usability, whether it's equipped or on the cursor) and reads about one
    copy of an item rather than the record are left out. Each is resolved once
    at load, so a reader this client lacks leaves blank cells, and each list a
    manifest kind reads gets API Endpoints rows of its own, added at the end of
    that list below. A table return prints as sorted key=value pairs.
]]
local ITEM_READERS = {
	{ "C_Item", "GetItemNameByID", "BYID_NAME" },
	{ "C_Item", "GetItemQualityByID", "BYID_QUALITY" },
	{ "C_Item", "GetItemIconByID", "BYID_ICON" },
	{ "C_Item", "GetItemMaxStackSizeByID", "BYID_MAX_STACK" },
	{ "C_Item", "GetItemInventoryTypeByID", "BYID_INVENTORY_TYPE" },
	{
		"C_Item",
		"GetItemUniquenessByID",
		{ "UNIQUE_IS_UNIQUE", "UNIQUE_LIMIT_CATEGORY_NAME", "UNIQUE_LIMIT_CATEGORY_COUNT", "UNIQUE_LIMIT_CATEGORY_ID" },
	},
	{ "C_Item", "GetItemUniqueness", { "UNIQUENESS_LIMIT_CATEGORY", "UNIQUENESS_LIMIT_MAX" } },
	{ "C_Item", "GetItemFamily", "ITEM_FAMILY" },
	{ "C_Item", "GetItemNumSockets", "NUM_SOCKETS" },
	{ "C_Item", "GetItemSpecInfo", "SPEC_INFO" },
	{ "C_Item", "GetItemLearnTransmogSet", "TRANSMOG_SET_ID" },
	{ "C_Item", "IsConsumableItem", "IS_CONSUMABLE" },
	{ "C_Item", "IsEquippableItem", "IS_EQUIPPABLE" },
	{ "C_Item", "IsHelpfulItem", "IS_HELPFUL" },
	{ "C_Item", "IsHarmfulItem", "IS_HARMFUL" },
	{ "C_Item", "ItemHasRange", "HAS_RANGE" },
	{ "C_Item", "IsDressableItem", "IS_DRESSABLE" },
	{ "C_Item", "IsDressableItemByID", "IS_DRESSABLE_BYID" },
	{ "C_Item", "IsCosmeticItem", "IS_COSMETIC" },
	{ "C_Item", "IsArtifactPowerItem", "IS_ARTIFACT_POWER" },
	{ "C_Item", "IsCurioItem", "IS_CURIO" },
	{ "C_Item", "IsCorruptedItem", "IS_CORRUPTED" },
	{ "C_Item", "IsRelicItem", "IS_RELIC" },
	{ "C_Item", "IsDecorItem", "IS_DECOR" },
	{ "C_Item", "IsAnimaItemByID", "IS_ANIMA" },
	{ "C_Item", "IsItemKeystoneByID", "IS_KEYSTONE" },
	{ "C_Item", "IsItemBindToAccount", "IS_BIND_TO_ACCOUNT" },
	{ "C_Item", "IsItemBindToAccountUntilEquip", "IS_BIND_TO_ACCOUNT_UNTIL_EQUIP" },
}

-- Read for the item's own spell, beside its description.
local SPELL_READERS = {
	{ "C_Spell", "GetSpellInfo", "SPELL_INFO" },
	{ "C_Spell", "GetSpellSubtext", "SPELL_SUBTEXT" },
	{ "C_Spell", "GetSpellLink", "SPELL_LINK" },
	{ "C_Spell", "GetSpellLevelLearned", "SPELL_LEVEL_LEARNED" },
	{ "C_Spell", "GetSpellSkillLineAbilityRank", "SPELL_SKILL_RANK" },
	{ "C_Spell", "GetSpellPowerCost", "SPELL_POWER_COST" },
	{ "C_Spell", "GetSpellMaxCumulativeAuraApplications", "SPELL_MAX_STACKS" },
	{ "C_Spell", "GetAuraStatChanges", { "SPELL_AURA_HEALTH_CHANGE", "SPELL_AURA_POWER_CHANGES" } },
	{ "C_Spell", "IsConsumableSpell", "SPELL_IS_CONSUMABLE" },
	{ "C_Spell", "IsSpellHelpful", "SPELL_IS_HELPFUL" },
	{ "C_Spell", "IsSpellHarmful", "SPELL_IS_HARMFUL" },
	{ "C_Spell", "IsSpellPassive", "SPELL_IS_PASSIVE" },
	{ "C_Spell", "IsSelfBuff", "SPELL_IS_SELF_BUFF" },
	{ "C_Spell", "IsSpellCrowdControl", "SPELL_IS_CROWD_CONTROL" },
	{ "C_Spell", "IsExternalDefensive", "SPELL_IS_EXTERNAL_DEFENSIVE" },
	{ "C_Spell", "IsSpellImportant", "SPELL_IS_IMPORTANT" },
	{ "C_Spell", "IsPriorityAura", "SPELL_IS_PRIORITY_AURA" },
	{ "C_Spell", "SpellHasRange", "SPELL_HAS_RANGE" },
}

local QUEST_READERS = {
	{ "C_QuestLog", "GetQuestDifficultyLevel", "DIFFICULTY_LEVEL" },
	{ "C_QuestLog", "GetQuestType", "QUEST_TYPE" },
	{ "C_QuestLog", "GetQuestTagInfo", "TAG_INFO" },
	{ "C_QuestLog", "GetSuggestedGroupSize", "SUGGESTED_GROUP_SIZE" },
	{ "C_QuestLog", "GetQuestDetailsTheme", "DETAILS_THEME" },
	{ "C_QuestLog", "GetQuestObjectives", "OBJECTIVES" },
	{ "C_QuestLog", "IsQuestFlaggedCompletedOnAccount", "IS_COMPLETED_ON_ACCOUNT" },
	{ "C_QuestLog", "IsAccountQuest", "IS_ACCOUNT_QUEST" },
	{ "C_QuestLog", "IsEliteQuest", "IS_ELITE" },
	{ "C_QuestLog", "IsRepeatableQuest", "IS_REPEATABLE" },
	{ "C_QuestLog", "IsQuestReplayable", "IS_REPLAYABLE" },
	{ "C_QuestLog", "IsQuestTask", "IS_TASK" },
	{ "C_QuestLog", "IsWorldQuest", "IS_WORLD_QUEST" },
	{ "C_QuestLog", "IsImportantQuest", "IS_IMPORTANT" },
	{ "C_QuestLog", "IsMetaQuest", "IS_META" },
	{ "C_QuestLog", "IsQuestCalling", "IS_CALLING" },
	{ "C_QuestLog", "IsQuestInvasion", "IS_INVASION" },
	{ "C_QuestLog", "IsThreatQuest", "IS_THREAT" },
	{ "C_QuestLog", "IsQuestBounty", "IS_BOUNTY" },
	{ "C_QuestLog", "IsQuestFromContentPush", "IS_FROM_CONTENT_PUSH" },
	{ "C_QuestLog", "ShouldShowQuestRewards", "SHOULD_SHOW_REWARDS" },
}

local function ReaderHeaders(readers)
	local headers = {}
	for _, reader in ipairs(readers) do
		local names = type(reader[3]) == "table" and reader[3] or { reader[3] }
		for _, name in ipairs(names) do
			headers[#headers + 1] = name
		end
	end
	return headers
end

local function AddApiCheck(namespace, name)
	local label = (namespace and (namespace .. "." .. name) or name) .. " (Validate Data)"
	ns.DIAGNOSTIC_API_CHECKS[#ns.DIAGNOSTIC_API_CHECKS + 1] = {
		label,
		function()
			if not namespace then
				return type(_G[name]) == "function"
			end
			local current = _G[namespace]
			return type(current) == "table" and type(current[name]) == "function"
		end,
	}
end

--[[
    The reader lists each manifest kind reads: an item row reads its spell's
    too. Only a list some kind in ns.DIAGNOSTIC_DATA_SOURCES reads gets API
    Endpoints rows, so the report never probes an API the add-on doesn't use.
]]
local KIND_READERS = {
	item = { ITEM_READERS, SPELL_READERS },
	spell = { SPELL_READERS },
	quest = { QUEST_READERS },
}

local kindsUsed = {}
for _, entry in ipairs(ns.DIAGNOSTIC_DATA_SOURCES) do
	for _, source in ipairs(entry.sources) do
		kindsUsed[source.kind] = true
	end
end

local probedReaders = {}
for kind in pairs(kindsUsed) do
	for _, readers in ipairs(KIND_READERS[kind] or {}) do
		probedReaders[readers] = true
	end
end

for _, readers in ipairs({ ITEM_READERS, SPELL_READERS, QUEST_READERS }) do
	for _, reader in ipairs(readers) do
		local namespace, name = reader[1], reader[2]
		local library = _G[namespace]
		reader.fn = type(library) == "table" and library[name] or nil
		reader.count = type(reader[3]) == "table" and #reader[3] or 1
		if probedReaders[readers] then
			AddApiCheck(namespace, name)
		end
	end
end

-- The spell and area kinds' own reads, likewise only for a kind a manifest source uses.
local KIND_API_CHECKS = {
	-- { kind, namespace or nil for a global, function }
	{ "spell", "C_Spell", "DoesSpellExist" },
	{ "spell", "C_Spell", "GetSpellName" },
	{ "spell", nil, "IsPlayerSpell" },
	{ "spell", nil, "IsSpellKnown" },
	{ "area", "C_Map", "GetAreaInfo" },
}

for _, check in ipairs(KIND_API_CHECKS) do
	if kindsUsed[check[1]] then
		AddApiCheck(check[2], check[3])
	end
end

--[[
    A run works one batch at a time: it requests a batch, polls until every row
    in it has settled, asks again for stragglers every few idle polls, and only
    then starts the next batch, so a thousand lookups never stall one frame. A
    straggler still unanswered after a bounded run of idle polls settles as a
    flagged row rather than holding the run open.
]]
local VALIDATE_BATCH_SIZE = 100
local VALIDATE_POLL_SECONDS = 0.5
local VALIDATE_REASK_POLLS = 3
local VALIDATE_MAX_IDLE_POLLS = 12

local ITEM_INFO_RETURNS = 18
local ITEM_INFO_INSTANT_RETURNS = 7

local ITEM_COLUMNS = {
	"STATUS",
	"SOURCE",
	"ITEM_ID",
	"NAME",
	"LINK",
	"QUALITY",
	"ITEM_LEVEL",
	"MIN_LEVEL",
	"TYPE",
	"SUBTYPE",
	"STACK_COUNT",
	"EQUIP_LOC",
	"TEXTURE",
	"SELL_PRICE",
	"CLASS_ID",
	"SUBCLASS_ID",
	"BIND_TYPE",
	"EXPANSION_ID",
	"SET_ID",
	"CRAFTING_REAGENT",
	"DESCRIPTION",
	"INSTANT_ITEM_ID",
	"INSTANT_TYPE",
	"INSTANT_SUBTYPE",
	"INSTANT_EQUIP_LOC",
	"INSTANT_ICON",
	"INSTANT_CLASS_ID",
	"INSTANT_SUBCLASS_ID",
}

--[[
    Follow the DATA_* columns on every item row: the item's spell, its
    description, the spell's own readers and tooltip; the level, class and stat
    reads; the other item readers; then the whole item tooltip last.
]]
local EXTRA_ITEM_COLUMNS = {}
for _, group in ipairs({
	{ "SPELL_NAME", "SPELL_ID", "SPELL_DESCRIPTION" },
	ReaderHeaders(SPELL_READERS),
	{ "SPELL_TOOLTIP", "ILVL_EFFECTIVE", "ILVL_PREVIEW", "ILVL_BASE", "CLASS_NAME", "SUBCLASS_NAME", "STATS" },
	ReaderHeaders(ITEM_READERS),
	{ "TOOLTIP" },
}) do
	for _, column in ipairs(group) do
		EXTRA_ITEM_COLUMNS[#EXTRA_ITEM_COLUMNS + 1] = column
	end
end

local QUEST_COLUMNS = {
	"STATUS",
	"SOURCE",
	"QUEST_ID",
	"TITLE",
	"IS_FLAGGED_COMPLETED",
}

-- The spell's description, its readers and its tooltip, blank for an item with no spell.
local SPELL_CELL_COUNT = 2 + #ReaderHeaders(SPELL_READERS)

-- Follow the DATA_* columns on every quest row.
local QUEST_READER_COLUMNS = ReaderHeaders(QUEST_READERS)

--[[
    A spell row carries the same spell columns an item's spell does, plus
    whether this character has the spell, which no other kind can say.
]]
local SPELL_COLUMNS = {
	"STATUS",
	"SOURCE",
	"SPELL_ID",
	"NAME",
	"IS_PLAYER_SPELL",
	"IS_SPELL_KNOWN",
}

-- Follow the DATA_* columns on every spell row.
local EXTRA_SPELL_COLUMNS = { "SPELL_DESCRIPTION" }
for _, column in ipairs(ReaderHeaders(SPELL_READERS)) do
	EXTRA_SPELL_COLUMNS[#EXTRA_SPELL_COLUMNS + 1] = column
end
EXTRA_SPELL_COLUMNS[#EXTRA_SPELL_COLUMNS + 1] = "SPELL_TOOLTIP"

local AREA_COLUMNS = {
	"STATUS",
	"SOURCE",
	"AREA_ID",
	"NAME",
}

-- An "other" table answers to no lookup, so it prints its row count alone.
local OTHER_COLUMNS = {
	"STATUS",
	"SOURCE",
	"ROWS",
}

-- STATUS, SOURCE and the id come first, so the name or title is the fourth cell.
local NAME_CELL = 4

local STATUS_OK = "OK"
ns.DIAGNOSTIC_STATUS_OK = STATUS_OK
local STATUS_NOT_ON_CLIENT = "NOT ON CLIENT"
local STATUS_INCOMPLETE = "INCOMPLETE"
local STATUS_ERROR = "ERROR"
local STATUS_TABLE_MISSING = "TABLE MISSING"
local STATUS_NO_TITLE = "NO TITLE"
local STATUS_NO_NAME = "NO NAME"

local validations = {}

local VALIDATE_REPAINT_SECONDS = 1

--[[
    Repaints the panel, whose status rows read each run's progress as they draw.
    A repaint rebuilds the whole panel, output box included, so mid-run it waits
    until a row has settled since the last one and a second has passed; force
    repaints at once, for a file's start and finish.
]]
local function NotifyValidation(run, force)
	local now = GetTime()
	if not force and (run.resolved == run.notifiedResolved or now - run.notifiedAt < VALIDATE_REPAINT_SECONDS) then
		return
	end
	run.notifiedResolved = run.resolved
	run.notifiedAt = now
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

--[[
    One TSV cell. A tab or newline inside a value would break the row, and a
    raw pipe would render an item link as a clickable swatch instead of the
    copyable text a spreadsheet needs.
]]
local function CellText(value)
	if value == nil then
		return ""
	end
	local text = tostring(value):gsub("[\t\r\n]", " ")
	return (text:gsub("|", "||"))
end

local function AppendBlanks(cells, count)
	for _ = 1, count do
		cells[#cells + 1] = ""
	end
end

-- A table as sorted key=value pairs, nested tables in braces, a few levels deep.
local function FormatTable(value, depth)
	if type(value) ~= "table" then
		return value
	end
	depth = depth or 0
	if depth > 3 then
		return "{...}"
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	local parts = {}
	for _, key in ipairs(keys) do
		local item = value[key]
		local text = type(item) == "table" and ("{" .. FormatTable(item, depth + 1) .. "}") or tostring(item)
		parts[#parts + 1] = tostring(key) .. "=" .. text
	end
	return table.concat(parts, "; ")
end

local function AppendResults(cells, count, ok, ...)
	if not ok then
		AppendBlanks(cells, count)
		return tostring((...))
	end
	for index = 1, count do
		cells[#cells + 1] = CellText(FormatTable((select(index, ...))))
	end
	return nil
end

--[[
    Calls a read the client may lack or may refuse for one odd id, filling
    exactly count cells either way so every row keeps its column alignment. A
    throw comes back as its message, for the row's ERROR status.
]]
local function AppendCall(cells, count, fn, ...)
	if type(fn) ~= "function" then
		AppendBlanks(cells, count)
		return nil
	end
	return AppendResults(cells, count, pcall(fn, ...))
end

-- Keeps the first problem a row met; both arguments are always evaluated.
local function FirstProblem(current, found)
	return current or found
end

-- A read's first return, or nil and the message when it throws.
local function TryRead(fn, ...)
	local ok, result = pcall(fn, ...)
	if ok then
		return result, nil
	end
	return nil, tostring(result)
end

-- One cell per return of every reader in the list, all called with the same id.
local function AppendReaderCells(cells, readers, id)
	local problem
	for _, reader in ipairs(readers) do
		problem = FirstProblem(problem, AppendCall(cells, reader.count, reader.fn, id))
	end
	return problem
end

local function ItemSpellId(itemId)
	if type(GetItemSpell) ~= "function" then
		return nil
	end
	local ok, _, spellId = pcall(GetItemSpell, itemId)
	return ok and spellId or nil
end

--[[
    A spell's description, its readers and its tooltip in one cell, lines
    joined by " // ": the tail of every spell row and the spell columns of an
    item that casts one. Returns the first read that threw.
]]
local function AppendSpellCells(cells, spellId)
	local problem = AppendCall(cells, 1, GetSpellDescription, spellId)
	problem = FirstProblem(problem, AppendReaderCells(cells, SPELL_READERS, spellId))
	local spellLines, spellProblem = TooltipLines("spell", spellId)
	cells[#cells + 1] = CellText(table.concat(spellLines, " // "))
	return FirstProblem(problem, spellProblem)
end

--[[
    Everything after the DATA_* columns, in EXTRA_ITEM_COLUMNS order. Both
    tooltips go in one cell each, lines joined by " // ". Returns the first read
    that threw.
]]
local function AppendExtraItemCells(cells, itemId)
	local infoOk, infoResult, link, _, _, _, _, _, _, _, _, _, classId, subclassId = pcall(GetItemInfo, itemId)
	local problem = FirstProblem(not infoOk and tostring(infoResult) or nil, AppendCall(cells, 2, GetItemSpell, itemId))
	local spellId = ItemSpellId(itemId)
	if spellId then
		problem = FirstProblem(problem, AppendSpellCells(cells, spellId))
	else
		AppendBlanks(cells, SPELL_CELL_COUNT)
	end
	problem = FirstProblem(problem, AppendCall(cells, 3, GetDetailedItemLevelInfo, link or itemId))
	if classId then
		problem = FirstProblem(problem, AppendCall(cells, 1, GetItemClassName, classId))
	else
		AppendBlanks(cells, 1)
	end
	if classId and subclassId then
		problem = FirstProblem(problem, AppendCall(cells, 1, GetItemSubClassName, classId, subclassId))
	else
		AppendBlanks(cells, 1)
	end
	local stats
	if type(GetItemStats) == "function" and link then
		local ok, result = pcall(GetItemStats, link)
		if ok then
			stats = FormatTable(result)
		else
			problem = FirstProblem(problem, tostring(result))
		end
	end
	cells[#cells + 1] = CellText(stats)
	problem = FirstProblem(problem, AppendReaderCells(cells, ITEM_READERS, itemId))
	local tooltipLines, tooltipProblem = TooltipLines("item", itemId)
	cells[#cells + 1] = CellText(table.concat(tooltipLines, " // "))
	return FirstProblem(problem, tooltipProblem)
end

local function AppendDataCells(cells, entry, dataHeaders)
	for _, header in ipairs(dataHeaders) do
		cells[#cells + 1] = CellText(entry.data[header])
	end
end

--[[
    A flagged row still carries its id, source table and DATA_* values, so the
    bad entry is copyable straight out of the sheet; only an id the client has
    reads the extras and the tooltip. A read that throws turns the row's status
    to ERROR, with the message in the name cell.
]]
local function BuildItemRow(status, entry, dataHeaders)
	local itemId = entry.id
	local cells = { status, entry.source, tostring(itemId) }
	local problem = FirstProblem(entry.problem, AppendCall(cells, ITEM_INFO_RETURNS, GetItemInfo, itemId))
	problem = FirstProblem(problem, AppendCall(cells, ITEM_INFO_INSTANT_RETURNS, GetItemInfoInstant, itemId))
	AppendDataCells(cells, entry, dataHeaders)
	if status == STATUS_NOT_ON_CLIENT then
		AppendBlanks(cells, #EXTRA_ITEM_COLUMNS)
	else
		problem = FirstProblem(problem, AppendExtraItemCells(cells, itemId))
	end
	if problem then
		cells[1] = STATUS_ERROR
		cells[NAME_CELL] = CellText(problem)
	end
	return cells
end

--[[
    A quest has no existence check to ask, so an unknown quest and an uncached
    one look the same until the polls run out: the title is the only answer,
    and a quest that never gives one is NO TITLE rather than NOT ON CLIENT.
]]
local function QuestTitle(questId)
	if type(GetQuestTitle) ~= "function" then
		return nil
	end
	local ok, title = pcall(GetQuestTitle, questId)
	if ok and type(title) == "string" and title ~= "" then
		return title
	end
	return nil
end

local function BuildQuestRow(status, entry, dataHeaders)
	local questId = entry.id
	local cells = { status, entry.source, tostring(questId), CellText(QuestTitle(questId)) }
	local problem = FirstProblem(entry.problem, AppendCall(cells, 1, C_QuestLog.IsQuestFlaggedCompleted, questId))
	AppendDataCells(cells, entry, dataHeaders)
	problem = FirstProblem(problem, AppendReaderCells(cells, QUEST_READERS, questId))
	if problem then
		cells[1] = STATUS_ERROR
		cells[NAME_CELL] = CellText(problem)
	end
	return cells
end

-- A name read that answers with a non-empty string, or nil and any message it threw.
local function ReadName(fn, id)
	if type(fn) ~= "function" then
		return nil, nil
	end
	local name, problem = TryRead(fn, id)
	if type(name) == "string" and name ~= "" then
		return name, nil
	end
	return nil, problem
end

local function AreaName(areaId)
	return ReadName(GetAreaInfo, areaId)
end

local function BuildSpellRow(status, entry, dataHeaders)
	local spellId = entry.id
	local name, problem = ReadName(GetSpellName, spellId)
	local cells = { status, entry.source, tostring(spellId), CellText(name) }
	problem = FirstProblem(entry.problem, problem)
	problem = FirstProblem(problem, AppendCall(cells, 1, IsPlayerSpell, spellId))
	problem = FirstProblem(problem, AppendCall(cells, 1, IsSpellKnown, spellId))
	AppendDataCells(cells, entry, dataHeaders)
	if status == STATUS_NOT_ON_CLIENT then
		AppendBlanks(cells, #EXTRA_SPELL_COLUMNS)
	else
		problem = FirstProblem(problem, AppendSpellCells(cells, spellId))
	end
	if problem then
		cells[1] = STATUS_ERROR
		cells[NAME_CELL] = CellText(problem)
	end
	return cells
end

local function BuildAreaRow(status, entry, dataHeaders)
	local areaId = entry.id
	local name, problem = AreaName(areaId)
	local cells = { status, entry.source, tostring(areaId), CellText(name) }
	AppendDataCells(cells, entry, dataHeaders)
	problem = FirstProblem(entry.problem, problem)
	if problem then
		cells[1] = STATUS_ERROR
		cells[NAME_CELL] = CellText(problem)
	end
	return cells
end

local ROW_BUILDERS = {
	item = BuildItemRow,
	quest = BuildQuestRow,
	spell = BuildSpellRow,
	area = BuildAreaRow,
}

--[[
    Whether this client's item database knows the id at all, which is a
    different question from whether the item's data is cached. A throw comes
    back as its message, for an ERROR row.
]]
local function ItemExistsOnClient(itemId)
	local exists, problem = TryRead(C_Item.DoesItemExistByID, itemId)
	return exists and true or false, problem
end

local function CollectEntries(source, rows)
	if source.collect then
		return source.collect(rows)
	end
	local entries = {}
	for key, row in pairs(rows) do
		entries[#entries + 1] = { id = source.rowId(key, row), key = key, row = row }
	end
	return entries
end

local function CountRows(rows)
	local count = 0
	for _ in pairs(rows) do
		count = count + 1
	end
	return count
end

--[[
    Every id the entry's sources reach, grouped by kind and each in id order,
    with its DATA_* values already read; each kind's DATA_* headers in
    first-seen order, so a file with several sources still gets one header row
    per block; every source whose table this client's folder never built; and
    each "other" table's row count.
]]
local function CollectIds(entry)
	local ids, missing, others = {}, {}, {}
	local headers, seenHeaders = {}, {}

	for _, source in ipairs(entry.sources) do
		local kindHeaders = headers[source.kind] or {}
		local kindSeen = seenHeaders[source.kind] or {}
		headers[source.kind], seenHeaders[source.kind] = kindHeaders, kindSeen
		local columns = source.dataColumns or {}
		for _, column in ipairs(columns) do
			if not kindSeen[column[1]] then
				kindSeen[column[1]] = true
				kindHeaders[#kindHeaders + 1] = column[1]
			end
		end

		local rows = ns[source.table]
		if type(rows) ~= "table" then
			missing[#missing + 1] = source
		elseif source.kind == "other" then
			others[#others + 1] = { STATUS_OK, source.table, tostring(CountRows(rows)) }
		else
			for _, found in ipairs(CollectEntries(source, rows)) do
				if type(found.id) == "number" then
					local data = {}
					for _, column in ipairs(columns) do
						data[column[1]] = column[2](found.key, found.row)
					end
					ids[#ids + 1] = { id = found.id, source = source.table, kind = source.kind, data = data }
				end
			end
		end
	end

	table.sort(ids, function(a, b)
		if a.kind ~= b.kind then
			return a.kind < b.kind
		end
		if a.id == b.id then
			return a.source < b.source
		end
		return a.id < b.id
	end)
	return ids, headers, missing, others
end

--[[
    Asks the client for one id's data: the item and its spell, the quest, or
    the spell. An area has nothing to ask for.
]]
local function RequestEntry(entry)
	if entry.kind == "quest" then
		if type(RequestLoadQuest) == "function" then
			pcall(RequestLoadQuest, entry.id)
		end
		return
	end
	if entry.kind == "spell" then
		if type(RequestLoadSpellData) == "function" then
			pcall(RequestLoadSpellData, entry.id)
			entry.spellRequested = true
		end
		return
	end
	if entry.kind == "area" then
		return
	end
	local _, problem = TryRead(C_Item.RequestLoadItemDataByID, entry.id)
	entry.problem = entry.problem or problem
	local spellId = ItemSpellId(entry.id)
	if spellId and type(RequestLoadSpellData) == "function" then
		pcall(RequestLoadSpellData, spellId)
		entry.spellRequested = true
	end
end

-- The spell's description, or nil until it has loaded as non-empty text.
local function SpellDescription(spellId)
	if type(GetSpellDescription) ~= "function" then
		return nil
	end
	local ok, description = pcall(GetSpellDescription, spellId)
	if ok and type(description) == "string" and description ~= "" then
		return description
	end
	return nil
end

--[[
    Whether a spell's data has landed, for a spell row or an item's spell. A
    spell not yet requested is requested now. Plenty of quest-object spells
    (keys that cast Opening) have no description at all, so an empty one
    settles once the client says the spell's data is cached, or where it can't
    say, one poll after the request. A client without GetSpellDescription can't
    be waited on for one.
]]
local function IsSpellSettled(entry, spellId)
	if type(GetSpellDescription) ~= "function" then
		return true
	end
	if not entry.spellRequested then
		entry.spellRequested = true
		if type(RequestLoadSpellData) == "function" then
			pcall(RequestLoadSpellData, spellId)
		end
		return false
	end
	if SpellDescription(spellId) ~= nil then
		return true
	end
	if type(IsSpellDataCached) == "function" then
		local ok, cached = pcall(IsSpellDataCached, spellId)
		if ok then
			return cached == true
		end
	end
	if entry.spellPolled then
		return true
	end
	entry.spellPolled = true
	return false
end

--[[
    Whether an id's row can be written: an item once its data, its tooltip and
    its spell have loaded, a spell once its name, its tooltip and its data
    have, a quest once it has a title, and any entry at once when a read has
    thrown, so the run carries on past it. An item whose spell only shows up
    once its data arrives gets that spell requested then.
]]
local function IsSettled(entry)
	if entry.problem then
		return true
	end
	if entry.kind == "quest" then
		return QuestTitle(entry.id) ~= nil
	end
	if entry.kind == "spell" then
		local name, problem = ReadName(GetSpellName, entry.id)
		if problem then
			entry.problem = problem
			return true
		end
		if not name or #TooltipLines("spell", entry.id) == 0 then
			return false
		end
		return IsSpellSettled(entry, entry.id)
	end
	local name, problem = TryRead(GetItemInfo, entry.id)
	if problem then
		entry.problem = problem
		return true
	end
	if not name or #TooltipLines("item", entry.id) == 0 then
		return false
	end
	local spellId = ItemSpellId(entry.id)
	if not spellId then
		return true
	end
	return IsSpellSettled(entry, spellId)
end

--[[
    A straggler the polls gave up on: an item or spell whose data loaded
    without its tooltip or its spell's data is INCOMPLETE, and a quest without
    a title is NO TITLE.
]]
local function UnsettledStatus(entry)
	if entry.problem then
		return STATUS_ERROR
	end
	if entry.kind == "quest" then
		return STATUS_NO_TITLE
	end
	if entry.kind == "spell" then
		return ReadName(GetSpellName, entry.id) and STATUS_INCOMPLETE or STATUS_NOT_ON_CLIENT
	end
	if TryRead(GetItemInfo, entry.id) then
		return STATUS_INCOMPLETE
	end
	return STATUS_NOT_ON_CLIENT
end

local function ResolveRow(run, index, status)
	local entry = run.ids[index]
	run.rows[index] = ROW_BUILDERS[entry.kind](status, entry, run.headers[entry.kind])
	run.resolved = run.resolved + 1
end

--[[
    How far a run has got, for the status row beside its button: ids resolved
    and ids in all, or nil for a file with no run in flight.
]]
function ns:GetDataValidationProgress(fileIndex)
	local run = validations[fileIndex]
	if not run or run.finished or not run.ids then
		return nil
	end
	return run.resolved, #run.ids
end

local function ReleaseRun(run)
	run.ids = {}
	run.rows = {}
	run.pending = {}
	run.missing = {}
	run.others = {}
end

--[[
    A step that throws ends this file's validation and hands the error to the
    run's callback, so the report runner writes it into the box and moves on
    rather than waiting on a chain that will never finish.
]]
local function FailValidation(run, problem)
	local onFinish = run.onFinish
	run.generation = run.generation + 1
	run.finished = true
	run.onFinish = nil
	ReleaseRun(run)
	if onFinish then
		onFinish(nil, nil, tostring(problem))
	end
	NotifyValidation(run, true)
end

--[[
    Every timer a run schedules carries the generation it was created under and
    drops out once a newer one exists, so a second click on the button, or the
    panel being switched off, retires the old chain rather than leaving two runs
    writing the same box.
]]
local function ScheduleValidation(fileIndex, run, delay, step)
	local generation = run.generation
	C_Timer.After(delay, function()
		if run.generation ~= generation then
			return
		end
		local ok, problem = pcall(step, fileIndex, run)
		if not ok then
			FailValidation(run, problem)
		end
	end)
end

local function JoinColumns(...)
	local header = {}
	for index = 1, select("#", ...) do
		for _, column in ipairs((select(index, ...))) do
			header[#header + 1] = column
		end
	end
	return header
end

--[[
    One kind's TSV block: its header row, a TABLE MISSING row for each of its
    tables this client never built, then one row per id in id order, or for
    "other" one row count per table. A kind with nothing to show prints no
    block.
]]
local function AppendKindBlock(lines, run, kind, header)
	local rows = {}
	for _, source in ipairs(run.missing) do
		if source.kind == kind then
			local cells = { STATUS_TABLE_MISSING, source.table }
			AppendBlanks(cells, #header - #cells)
			rows[#rows + 1] = cells
		end
	end
	if kind == "other" then
		for _, cells in ipairs(run.others) do
			rows[#rows + 1] = cells
		end
	end
	for index, entry in ipairs(run.ids) do
		if entry.kind == kind then
			rows[#rows + 1] = run.rows[index]
		end
	end
	if #rows == 0 then
		return
	end
	if lines[#lines] ~= "" then
		lines[#lines + 1] = ""
	end
	lines[#lines + 1] = table.concat(header, "\t")
	for _, cells in ipairs(rows) do
		lines[#lines + 1] = table.concat(cells, "\t")
	end
end

-- Every row's STATUS cell tallied, TABLE MISSING rows included, for the run's summary line.
local function CountStatuses(run)
	local counts = {}
	for _, cells in pairs(run.rows) do
		counts[cells[1]] = (counts[cells[1]] or 0) + 1
	end
	for _, cells in ipairs(run.others) do
		counts[cells[1]] = (counts[cells[1]] or 0) + 1
	end
	if #run.missing > 0 then
		counts[STATUS_TABLE_MISSING] = #run.missing
	end
	return counts
end

--[[
    The report is the client header, a blank line, then one TSV block per kind.
    It goes to the callback the run was started with, with the status tallies.
]]
local function FinishValidation(_, run)
	local lines = { GetClientHeader(), "" }
	local headers = run.headers
	AppendKindBlock(lines, run, "item", JoinColumns(ITEM_COLUMNS, headers.item or {}, EXTRA_ITEM_COLUMNS))
	AppendKindBlock(lines, run, "quest", JoinColumns(QUEST_COLUMNS, headers.quest or {}, QUEST_READER_COLUMNS))
	AppendKindBlock(lines, run, "spell", JoinColumns(SPELL_COLUMNS, headers.spell or {}, EXTRA_SPELL_COLUMNS))
	AppendKindBlock(lines, run, "area", JoinColumns(AREA_COLUMNS, headers.area or {}))
	AppendKindBlock(lines, run, "other", OTHER_COLUMNS)
	local counts = CountStatuses(run)
	local onFinish = run.onFinish
	run.finished = true
	run.onFinish = nil
	ReleaseRun(run)
	if onFinish then
		onFinish(table.concat(lines, "\n"), counts)
	end
	NotifyValidation(run, true)
end

local PollValidation

--[[
    Opens the next batch: an item or spell id the client does not know is
    flagged on the spot, an area settles at once since there is nothing to ask
    the server for, and everything else is requested and left for the polls.
]]
local function StartBatch(fileIndex, run)
	run.idlePolls = 0
	run.pending = {}
	local last = math.min(run.cursor + VALIDATE_BATCH_SIZE, #run.ids)
	for index = run.cursor + 1, last do
		local entry = run.ids[index]
		local exists, problem = true, nil
		if entry.kind == "item" then
			exists, problem = ItemExistsOnClient(entry.id)
		elseif entry.kind == "spell" and type(DoesSpellExist) == "function" then
			exists, problem = TryRead(DoesSpellExist, entry.id)
		end
		if problem then
			entry.problem = problem
			ResolveRow(run, index, STATUS_ERROR)
		elseif not exists then
			ResolveRow(run, index, STATUS_NOT_ON_CLIENT)
		elseif entry.kind == "area" then
			ResolveRow(run, index, AreaName(entry.id) and STATUS_OK or STATUS_NO_NAME)
		else
			RequestEntry(entry)
			run.pending[#run.pending + 1] = index
		end
	end
	run.cursor = last
	NotifyValidation(run)
	ScheduleValidation(fileIndex, run, VALIDATE_POLL_SECONDS, PollValidation)
end

function PollValidation(fileIndex, run)
	local stillPending = {}
	local settled = 0
	for _, index in ipairs(run.pending) do
		local entry = run.ids[index]
		if IsSettled(entry) then
			ResolveRow(run, index, entry.problem and STATUS_ERROR or STATUS_OK)
			settled = settled + 1
		else
			stillPending[#stillPending + 1] = index
		end
	end
	run.pending = stillPending
	run.idlePolls = settled > 0 and 0 or run.idlePolls + 1

	if #run.pending > 0 and run.idlePolls >= VALIDATE_MAX_IDLE_POLLS then
		for _, index in ipairs(run.pending) do
			ResolveRow(run, index, UnsettledStatus(run.ids[index]))
		end
		run.pending = {}
	elseif #run.pending > 0 and run.idlePolls > 0 and run.idlePolls % VALIDATE_REASK_POLLS == 0 then
		for _, index in ipairs(run.pending) do
			RequestEntry(run.ids[index])
		end
	end

	if #run.pending > 0 then
		NotifyValidation(run)
		ScheduleValidation(fileIndex, run, VALIDATE_POLL_SECONDS, PollValidation)
	elseif run.cursor < #run.ids then
		StartBatch(fileIndex, run)
	else
		FinishValidation(fileIndex, run)
	end
end

--[[
    onFinish(text, counts) receives the finished export and its STATUS tallies,
    or onFinish(nil, nil, problem) when a step threw. A run that is stopped or
    replaced never calls it.
]]
function ns:StartDataValidation(fileIndex, onFinish)
	local entry = ns.DIAGNOSTIC_DATA_SOURCES[fileIndex]
	if not entry then
		return
	end

	local run = validations[fileIndex] or { generation = 0 }
	validations[fileIndex] = run

	run.generation = run.generation + 1
	run.ids, run.headers, run.missing, run.others = CollectIds(entry)
	run.rows = {}
	run.pending = {}
	run.cursor = 0
	run.resolved = 0
	run.idlePolls = 0
	run.finished = false
	run.onFinish = onFinish
	run.notifiedResolved = nil
	run.notifiedAt = 0
	NotifyValidation(run, true)

	if #run.ids == 0 then
		FinishValidation(fileIndex, run)
		return
	end
	StartBatch(fileIndex, run)
end

--[[
    Called when a run is stopped or the panel is switched off, so nothing is
    left ticking. The bumped generation retires every pending timer, and a run
    cut off mid-way is marked finished without ever calling its onFinish.
]]
function ns:StopDataValidation()
	for _, run in pairs(validations) do
		run.generation = run.generation + 1
		if not run.finished then
			run.finished = true
			run.onFinish = nil
			ReleaseRun(run)
		end
	end
end
