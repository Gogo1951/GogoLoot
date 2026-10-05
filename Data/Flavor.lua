local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Flavor
--------------------------------------------------------------------------------

--[[
	The TOC the client chose names the flavor. Never work it out from the client:
	WoW Forever reports WOW_PROJECT_MAINLINE, the same as Retail.
]]
ns.FLAVOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-Flavor")

-- The game's major version, for "this expansion or later" comparisons.
ns.EXPANSION = ({ Vanilla = 1, Camelot = 1, TBC = 2, Wrath = 3, Mists = 5, Mainline = 12 })[ns.FLAVOR]

-- Season of Discovery shares the Classic Era client, so no TOC can name it.
ns.IS_DISCOVERY = ns.FLAVOR == "Vanilla" and C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfDiscovery

-- The Data/ folder whose tables this client built.
ns.DATA_FOLDER = ns.IS_DISCOVERY and "Discovery" or ns.FLAVOR
