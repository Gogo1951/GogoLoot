--------------------------------------------------------------------------------
-- GogoLoot Options — Registration
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Initialization & Registration
--------------------------------------------------------------------------------

--[[
    AceConfigRegistry table names (first arg to RegisterOptionsTable / first
    arg to AddToBlizOptions) are stable identifiers and intentionally NOT
    localized — they're used by NotifyChange calls across modules.

    The user-facing display names passed as the SECOND arg to
    AddToBlizOptions are localized (the TAB_* locale keys, the stock Profiles
    name, the Diagnostics strings table). A panel directly under the add-on
    passes L["ADDON_TITLE"] as the parent (THIRD arg), which must match the
    root panel's display name exactly. A panel nested one level further down
    passes its parent's captured category ID instead: every child panel's
    display name is only a title, and nothing keeps titles unique.
    OpenOptionsPanel below routes by the root's captured category ID rather
    than by name.
]]

--[[
    The feature panels in Settings-tree order: the features that act on loot
    first, in the order loot meets them (rolls, master loot, opening), then the
    three that report it, what the player sees, what they hear, then what the
    group is told. A row with a `parent` belongs to that panel: it nests beneath it where
    ns.OPTIONS_NESTED_PANELS allows, and otherwise follows it as a sibling
    titled "Parent: Child". A parent is always listed before its children, so
    its category ID is captured by the time they need it. Profiles and
    Diagnostic Tools come after all of these, last.
]]
local FEATURE_PANELS = {
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
		onRegistered = "OnCharacterRulesRegistered",
	},
	{ key = "MasterLooter", builder = "BuildMasterLooterOptions", title = "TAB_MASTER_LOOTER" },
	{
		key = "MasterLooterIgnoreList",
		builder = "BuildMasterLooterIgnoreListOptions",
		title = "TAB_IGNORE_LIST",
		parent = "MasterLooter",
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
}

--[[
    No pcall around AddToBlizOptions: AceConfigDialog records a panel before it
    looks its parent up, so a failed call cannot be retried under the same name.
    A parent the client cannot resolve has to fail loudly, not half-register.
]]
---@param panel table # a FEATURE_PANELS row whose builder exists
---@param panelsByKey table # FEATURE_PANELS rows by key
---@param categoryIDs table # captured category IDs by panel key
---@return nil
local function AddFeaturePanel(panel, panelsByKey, categoryIDs)
	local registryName = ns.OPTIONS_REGISTRY[panel.key]
	local title = L[panel.title]
	local parent = L["ADDON_TITLE"]

	if panel.parent then
		if ns.OPTIONS_NESTED_PANELS then
			parent = categoryIDs[panel.parent]
		else
			title = L["TAB_NESTED_FORMAT"]:format(L[panelsByKey[panel.parent].title], title)
		end
	end

	AceConfigRegistry:RegisterOptionsTable(registryName, ns[panel.builder])
	local panelFrame, categoryID = AceConfigDialog:AddToBlizOptions(registryName, title, parent)
	categoryIDs[panel.key] = categoryID
	-- A panel that sets itself up once its frame exists names the function in onRegistered.
	if panel.onRegistered and ns[panel.onRegistered] then
		ns[panel.onRegistered](panelFrame, registryName)
	end
end

---@return nil
function ns.RegisterOptionsPanels()
	AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)

	if ns.BuildDiagnosticsOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
	end

	--[[
        Registered only, never added to the Blizzard tree: the master looter
        pop-up opens as its own AceConfigDialog window (Options-Master-Looter-Popup.lua).
    ]]
	if ns.BuildMasterLooterPopupOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.MasterLooterPopup, ns.BuildMasterLooterPopupOptions)
	end

	-- The Profiles panel is the stock AceDBOptions table, returned unmodified (Options-Profiles.lua).
	if ns.BuildProfilesOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Profiles, ns.BuildProfilesOptions)
	end

	--[[
        On clients with the Settings API, AddToBlizOptions returns the panel
        frame and, as a second value, the Settings category ID. Capture it so
        OpenOptionsPanel can route directly to this category without a
        name-based lookup.
    ]]
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])
	local categoryIDs = {}
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID, categoryIDs = categoryIDs }

	--[[
        Display order in Blizzard's settings UI is the order of AddToBlizOptions
        calls. A panel whose parent never registered (its file left out of this
        flavor's TOC) is skipped rather than registered in the wrong place.
    ]]
	local panelsByKey = {}
	for _, panel in ipairs(FEATURE_PANELS) do
		panelsByKey[panel.key] = panel
	end
	for _, panel in ipairs(FEATURE_PANELS) do
		local parentRegistered = not panel.parent or categoryIDs[panel.parent] ~= nil
		if ns[panel.builder] and parentRegistered then
			AddFeaturePanel(panel, panelsByKey, categoryIDs)
		end
	end

	if ns.BuildProfilesOptions then
		-- The panel's display name comes already-localized from AceDBOptions-3.0; read it from the built table.
		local profilesDisplayName = ns.BuildProfilesOptions().name
		AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Profiles, profilesDisplayName, L["ADDON_TITLE"])
	end

	--[[
	    Diagnostics added last so it sits at the bottom of the settings tree. Its
	    display name is a developer-facing string (never localized) from
	    ns.DiagnosticsStrings.
	]]
	if ns.BuildDiagnosticsOptions then
		AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, L["ADDON_TITLE"])
	end

	--[[
        Closing the Options window ends an item list's New section (see
        Options-Utilities-Item-List-Filter.lua). SettingsPanel is the window on all
        three clients; hooked rather than replaced, so Blizzard's own OnHide
        still runs.
    ]]
	if SettingsPanel then
		SettingsPanel:HookScript("OnHide", ns.ForgetNewListItems)
	end

	ns:WarmItemCache()
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

---@return nil
function ns:OpenOptionsPanel()
	-- Combat first: the Settings panel is protected there, so every route below is blocked.
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end

	if not ns.optionsFrames then
		return
	end

	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
		return
	end

	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_GOGOLOOT1 = "/gogo"
SlashCmdList["GOGOLOOT"] = function()
	ns:OpenOptionsPanel()
end
