--------------------------------------------------------------------------------
-- GogoLoot Options — Registration
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Initialization & Registration
--------------------------------------------------------------------------------

--[[
    Settings-tree order. A parent comes before its children, so its category
    ID is captured by the time they need it. LootMaster is parked: its builder
    exists only while its file loads, so registration skips it.
]]
local FEATURE_PANELS = {
	{ key = "SpeedyLoot", builder = "BuildSpeedyLootOptions", title = "TAB_SPEEDY_LOOT" },
	{ key = "AutomatedRolls", builder = "BuildAutomatedRollOptions", title = "TAB_AUTOMATED_ROLLS" },
	{
		key = "ItemOverrides",
		builder = "BuildItemOverridesOptions",
		title = "TAB_ITEM_OVERRIDES",
		parent = "AutomatedRolls",
	},
	{
		key = "CharacterRules",
		builder = "BuildCharacterRulesOptions",
		title = "TAB_CHARACTER_RULES",
		parent = "AutomatedRolls",
	},
	{
		key = "SanityCheck",
		builder = "BuildSanityCheckOptions",
		title = "TAB_SANITY_CHECK",
		parent = "AutomatedRolls",
	},
	{ key = "AutomatedOpening", builder = "BuildAutomatedOpeningOptions", title = "TAB_AUTOMATED_OPENING" },
	{
		key = "OpenableItems",
		builder = "BuildOpenableItemsOptions",
		title = "TAB_OPENABLE_ITEMS",
		parent = "AutomatedOpening",
	},
	{
		key = "Lockboxes",
		builder = "BuildLockboxOptions",
		title = "TAB_LOCKBOXES",
		parent = "AutomatedOpening",
	},
	{ key = "LootToasts", builder = "BuildLootToastOptions", title = "TAB_LOOT_TOASTS" },
	{
		key = "LootToastFilters",
		builder = "BuildLootToastFilterOptions",
		title = "TAB_LOOT_TOAST_FILTERS",
		parent = "LootToasts",
	},
	{ key = "LootSounds", builder = "BuildLootSoundOptions", title = "TAB_LOOT_SOUNDS" },
	{ key = "Announcements", builder = "BuildAnnouncementOptions", title = "TAB_ANNOUNCEMENTS" },
	{ key = "MasterLooter", builder = "BuildMasterLooterOptions", title = "TAB_MASTER_LOOTER" },
	{
		key = "MasterLooterIgnoreList",
		builder = "BuildMasterLooterIgnoreListOptions",
		title = "TAB_IGNORE_LIST",
		parent = "MasterLooter",
	},
	{ key = "RollMacro", builder = "BuildRollMacroOptions", title = "TAB_ROLL_MACRO" },
	{ key = "LootMaster", builder = "BuildLootMasterOptions", title = "TAB_LOOT_MASTER" },
}

---@param panel table # a FEATURE_PANELS row with a parent
---@param panelsByKey table
---@return function
local function SubPanelBuilder(panel, panelsByKey)
	local build = ns[panel.builder]
	return function(...)
		local options = build(...)
		options.name = Kit.SubPanelTitle(L[panelsByKey[panel.parent].title], L[panel.title])
		return options
	end
end

--[[
    No pcall around a registration: AceConfigDialog records a panel before it
    looks its parent up, so a failed call cannot be retried under the same name.
    A parent the client cannot resolve has to fail loudly, not half-register.
]]
---@param panel table # a FEATURE_PANELS row whose builder exists
---@param panelsByKey table # FEATURE_PANELS rows by key
---@return nil
local function AddFeaturePanel(panel, panelsByKey)
	local builder = panel.parent and SubPanelBuilder(panel, panelsByKey) or ns[panel.builder]
	Kit.RegisterPanel(panel.key, builder, L[panel.title], panel.parent)
end

---@return nil
function ns.RegisterOptionsPanels()
	Kit.RegisterPanel("General", ns.BuildGeneralOptions, L["ADDON_TITLE"])

	-- Registered only, never in the tree: the pop-up opens as its own AceConfigDialog window.
	if ns.BuildMasterLooterPopupOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.MasterLooterPopup, ns.BuildMasterLooterPopupOptions)
	end

	-- Registration order is tree order. A panel whose parent never registered is skipped, not misplaced.
	local panelsByKey, registered = {}, {}
	for _, panel in ipairs(FEATURE_PANELS) do
		panelsByKey[panel.key] = panel
	end
	for _, panel in ipairs(FEATURE_PANELS) do
		local parentRegistered = not panel.parent or registered[panel.parent]
		if ns[panel.builder] and parentRegistered then
			AddFeaturePanel(panel, panelsByKey)
			registered[panel.key] = true
		end
	end

	-- Character Rules opens on the character being played, every time.
	if registered.CharacterRules then
		Kit.PrepareTree("CharacterRules", function()
			return ns.db.keys.char
		end)
	end

	-- The Profiles panel is the stock AceDBOptions table; its display name comes already localized.
	if ns.BuildProfilesOptions then
		Kit.RegisterPanel("Profiles", ns.BuildProfilesOptions, ns.BuildProfilesOptions().name)
	end

	if ns.BuildFeedbackSupportOptions then
		Kit.RegisterPanel("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])
	end

	-- Last, so it sits at the bottom of the tree; its name is developer-facing and never localized.
	if ns.BuildDiagnosticsOptions then
		Kit.RegisterPanel("Diagnostics", ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
	end

	-- Hooked, not replaced, so Blizzard's own OnHide still runs.
	if SettingsPanel then
		SettingsPanel:HookScript("OnHide", ns.ForgetNewListItems)
		SettingsPanel:HookScript("OnHide", ns.ForgetPanelItemLists)
	end

	ns.WatchScrolledDropdowns()

	ns:WarmItemCache()
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

-- ns:OpenOptionsPanel(key) and ns.IsOptionsPanelOpen() are the kit's (Options-Kit.lua), Combat Guard included.

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

--[[
    /gogo opens Options. Three words after it open the loot windows or print
    tonight's drops; they stay English in every locale, like the command.
]]
local SLASH_SUBCOMMANDS = {
	master = function()
		ns:ShowLootMaster()
	end,
	tracker = function()
		ns:ShowLootTracker()
	end,
	drops = function()
		ns:PrintDrops()
	end,
}

SLASH_GOGOLOOT1 = "/gogo"
SlashCmdList["GOGOLOOT"] = function(input)
	local subcommand = SLASH_SUBCOMMANDS[string.lower(string.match(input or "", "^%s*(%S*)") or "")]
	-- The loot windows are parked out of the TOCs for now; unloaded, their words fall through to Options.
	if subcommand and ns.ShowLootMaster then
		subcommand()
		return
	end
	ns:OpenOptionsPanel()
end
