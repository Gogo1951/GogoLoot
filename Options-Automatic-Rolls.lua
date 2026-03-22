-------------------------------------------------------------------------------
-- GogoLoot Options — Automated Rolls
-------------------------------------------------------------------------------
local ACR = LibStub("AceConfigRegistry-3.0")

-------------------------------------------------------------------------------
-- Item Input Parsing
-------------------------------------------------------------------------------
local function ParseItemInput(rawInput)
    if not rawInput or rawInput == "" then return nil end

    local numericIdentifier = tonumber(rawInput)
    if numericIdentifier then return numericIdentifier end

    local fromLink = string.match(rawInput, "item:(%d+)")
    if fromLink then return tonumber(fromLink) end

    return nil
end

-------------------------------------------------------------------------------
-- Custom Roll List — Dynamic AceConfig Args
-------------------------------------------------------------------------------
local function BuildCustomRollListArgs()
    local args = {}
    local order = 1

    args.restoreDefaults = {
        type    = "execute",
        name    = "Restore Default Custom Roll List",
        width   = "double",
        order   = order,
        confirm = true,
        confirmText = "This will replace your custom roll list with the default items for your expansion. Continue?",
        func    = function()
            GogoLoot_Configuration.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
            ACR:NotifyChange("GogoLoot_AutomaticRolls")
        end,
    }
    order = order + 1

    args.spacerAfterRestore = GogoLoot:OptionsSpacer(order)
    order = order + 1

    args.addItemDesc = GogoLoot:OptionsDesc(
        "Enter an Item ID or paste an item link to add it to the list.",
        order
    )
    order = order + 1

    args.addItemInput = {
        type  = "input",
        name  = "Add Item",
        desc  = "Enter Item ID or drag an item link here.",
        order = order,
        get   = function() return "" end,
        set   = function(_, value)
            local itemIdentifier = ParseItemInput(value)
            if not itemIdentifier then return end
            GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier] = GogoLoot.MANUAL
            -- Trigger a cache request so the name is ready
            GogoLoot.GetItemInfo(itemIdentifier)
            ACR:NotifyChange("GogoLoot_AutomaticRolls")
        end,
    }
    order = order + 1

    args.spacerBeforeItems = GogoLoot:OptionsSpacer(order)
    order = order + 1

    -- Sort by rarity (highest first), then alphabetically by name
    local sortedIdentifiers = {}
    for itemIdentifier in pairs(GogoLoot_Configuration.ignoredItemsSolo) do
        table.insert(sortedIdentifiers, itemIdentifier)
    end
    table.sort(sortedIdentifiers, function(a, b)
        local infoA = GogoLoot:SafeGetItemInfo(a)
        local infoB = GogoLoot:SafeGetItemInfo(b)
        local qualityA = infoA and infoA.quality or -1
        local qualityB = infoB and infoB.quality or -1
        if qualityA ~= qualityB then return qualityA > qualityB end
        local nameA = infoA and infoA.name or ""
        local nameB = infoB and infoB.name or ""
        if nameA == "" and nameB == "" then return a < b end
        if nameA == "" then return false end
        if nameB == "" then return true end
        return nameA < nameB
    end)

    for _, itemIdentifier in ipairs(sortedIdentifiers) do
        local groupKey = "item_" .. itemIdentifier

        args[groupKey] = {
            type   = "group",
            name   = "",
            inline = true,
            order  = order,
            args   = {
                label = {
                    type          = "input",
                    dialogControl = "GogoLoot_ItemLink",
                    name          = "",
                    width         = 1.3,
                    order         = 1,
                    get           = function() return tostring(itemIdentifier) end,
                    set           = function() end,
                },
                action = {
                    type   = "select",
                    name   = "",
                    desc   = "Choose the automatic roll action for this item.",
                    values = GogoLoot.ROLL_OVERRIDE_LABELS,
                    width  = 0.7,
                    order  = 2,
                    get    = function()
                        return GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier]
                    end,
                    set    = function(_, value)
                        GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier] = value
                    end,
                },
                remove = {
                    type  = "execute",
                    name  = "Remove",
                    desc  = "Remove this item from the custom roll list.",
                    width = 0.6,
                    order = 3,
                    func  = function()
                        GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier] = nil
                        ACR:NotifyChange("GogoLoot_AutomaticRolls")
                    end,
                },
            },
        }
        order = order + 1
    end

    return args
end

-------------------------------------------------------------------------------
-- Options Table Builder
-------------------------------------------------------------------------------
function GogoLoot.BuildAutomaticRollOptions()
    local greedThresholdValues = {
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. "Poor Only|r",
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. "Common & Lower|r",
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. "Uncommon & Lower|r",
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. "Rare & Lower|r",
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. "Epic & Lower|r",
    }

    return {
        type = "group",
        name = "Automated Rolls",
        args = {
            description = GogoLoot:OptionsDesc(
                "Automatically rolls Greed on non-BoP items at or below the selected quality. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped. BoP items are never auto-greeded by the threshold, but can be automated via the Custom Roll List below.",
                2
            ),
            spacerAfterDesc = GogoLoot:OptionsSpacer(3),

            autoGreed = {
                type  = "toggle",
                name  = "Enable Automated Rolls",
                desc  = "Automatically rolls Greed on eligible items at or below the threshold.",
                width = "full",
                order = 4,
                get   = function() return GogoLoot_Configuration.autoGreed end,
                set   = function(_, value) GogoLoot_Configuration.autoGreed = value end,
            },

            spacerAfterToggle = GogoLoot:OptionsSpacer(5),

            autoGreedThreshold = {
                type   = "select",
                name   = "Automated Greed Threshold",
                desc   = "Items at or below this quality will be automatically greeded.",
                style  = "dropdown",
                values = greedThresholdValues,
                order  = 6,
                get    = function() return GogoLoot_Configuration.autoGreedThreshold end,
                set    = function(_, value) GogoLoot_Configuration.autoGreedThreshold = value end,
            },

            spacerBeforeCustom = GogoLoot:OptionsSpacer(9),
            customListHeader = GogoLoot:OptionsHeader("Custom Roll List", 10),
            customListDesc = GogoLoot:OptionsDesc(
                "Items on this list have their own roll rule that overrides the threshold. This is the only way to automate BoP items like Scourgestones or Demonic Runes. Set each item to Manual Roll, Greed, Need, or Pass. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped regardless of setting.",
                11
            ),
            spacerAfterCustomDesc = GogoLoot:OptionsSpacer(12),

            customList = {
                type   = "group",
                name   = "",
                inline = true,
                order  = 13,
                args   = BuildCustomRollListArgs(),
            },
        },
    }
end