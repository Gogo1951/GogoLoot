--------------------------------------------------------------------------------
-- GogoLoot Options — Feedback & Support
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--[[
    The four link rows split Kit.ROW_WIDTH unevenly: their labels are one
    short word, while the box beside them holds a full URL the player is meant
    to select and copy, so the label takes 0.6 and the box the rest of the row.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = Kit.ROW_WIDTH - LINK_LABEL_WIDTH

-- { captionKey, linkKey }, in display order. The URLs live in ns.LINKS (Data/Data.lua).
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}

local LEVEL_UP_PARAGRAPHS = {
	"OPTIONS_LEVEL_UP_INTRO",
	"OPTIONS_LEVEL_UP_WAYS",
	"OPTIONS_LEVEL_UP_FEEDBACK",
	"OPTIONS_LEVEL_UP_FRIEND",
	"OPTIONS_LEVEL_UP_CURSEFORGE",
	"OPTIONS_LEVEL_UP_GITHUB",
	"OPTIONS_LEVEL_UP_THANKS",
}

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    The group's name is the page's title, drawn when the page opens; the tree
    lists it as Feedback & Support, the name it is registered under
    (Options/Options.lua).
]]
---@return table
function ns.BuildFeedbackSupportOptions()
	local args = {}
	local order = 1

	for index, key in ipairs(LEVEL_UP_PARAGRAPHS) do
		if index > 1 then
			args["spacerLevelUp" .. index] = Kit.Spacer(order)
			order = order + 1
		end
		args["descLevelUp" .. index] = Kit.Desc(L[key], order)
		order = order + 1
	end

	args.spacerLinks0 = Kit.Spacer(50)
	args.headerLinks = Kit.Header(L["OPTIONS_FEEDBACK_LINKS_HEADER"], 51)
	args.spacerLinks1 = Kit.Spacer(52)

	order = 53
	for index, entry in ipairs(LINKS) do
		local captionKey, linkKey = entry[1], entry[2]
		if index > 1 then
			args["spacerLink" .. index] = Kit.Spacer(order)
			order = order + 1
		end
		args["labelLink" .. index] = Kit.Label(GetColor("TITLE") .. L[captionKey] .. "|r", order, LINK_LABEL_WIDTH)
		args["link" .. index] = {
			type = "input",
			name = "",
			width = LINK_URL_WIDTH,
			order = order + 1,
			get = function()
				return ns.LINKS[linkKey]
			end,
			set = function() end,
		}
		order = order + 2
	end

	args.spacerCopyLink = Kit.Spacer(order)
	args.descCopyLink = Kit.Desc(GetColor("HELP") .. L["OPTIONS_COPY_LINK"] .. "|r", order + 1)

	args.spaceVersion0 = {
		type = "description",
		name = " ",
		width = "full",
		order = 998,
	}
	args.versionLine = {
		type = "description",
		name = GetColor("INFO") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
		fontSize = "medium",
		order = 999,
	}

	return {
		type = "group",
		name = L["OPTIONS_LEVEL_UP_TITLE"],
		args = args,
	}
end
