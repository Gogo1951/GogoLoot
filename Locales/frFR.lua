local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "frFR")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names or the %s / %d
    placeholders: code and other locales rely on them. Chat Messages print as
    "GogoLoot // <message>", so each ends with its own punctuation. Chat
    Announcement Templates and the ERROR_ keys are sent as
    "{rt4} <message> // GogoLoot", with the marker and name added by code, so
    they take no closing period or other end punctuation.
]]

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

-- Brands every printed line, sent message, options panel, and report. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > GogoLoot. L'add-on vous plaît ? Parlez-en à un ami ! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Par précaution, l'interface des options ne peut pas être ouverte en combat."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"L'option %s du jeu a été activée, car le butin rapide et l'ouverture automatique en ont besoin."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Vous n'êtes pas actuellement %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"L'ouverture automatique est en pause jusqu'à ce que vous ayez au moins %d emplacements de sac libres."
L["MESSAGE_OPENING_RESUMED"] = "L'ouverture automatique a repris."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s s'ouvrira automatiquement une fois déverrouillé."
L["MESSAGE_ITEM_IGNORED"] = "%s est réglé sur Ignorer, l'ouverture automatique n'y touchera donc pas."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s provient d'un boss de raid ou d'un boss mondial, l'ouverture automatique le laisse donc fermé pour que vous puissiez l'échanger ou le vendre."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s peut contenir un objet unique, l'ouverture automatique vous laisse donc l'ouvrir vous-même."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] =
	"%s a été laissé dans la fenêtre de butin pour que vous le ramassiez vous-même."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s s'équiperait au lieu de s'ouvrir, il ne peut donc pas rejoindre la liste Objets à ouvrir."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Vous avez choisi %s pour %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Vous avez passé pour %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s a gagné %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s a gagné %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Vous avez gagné %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Vous avez gagné %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "%s remis à %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "%s remis à %s, reçu %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "%s reçu de %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s remis à %s"
L["MESSAGE_DESTINATION_SET"] = "%s garde les objets de qualité %s pour le groupe"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s garde tout le butin pour le groupe"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s a quitté le groupe. %s garde désormais les objets de qualité %s pour le groupe"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s a quitté le groupe. %s garde désormais tout le butin pour le groupe"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s remis à %s, reçu %s"
L["MESSAGE_TRADE_RECEIVED"] = "%s reçu de %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Les sacs de %s sont pleins : %s"
L["ERROR_MAX_COUNT"] = "%s en possède déjà trop : %s"
L["ERROR_OUT_OF_RANGE"] = "%s est hors de portée : %s"
L["ERROR_NOT_IN_GROUP"] = "%s n'est plus dans le groupe ou le raid : %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Impossible de remettre le butin à %s : %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Jets automatiques"
L["TAB_ITEM_OVERRIDES"] = "Exceptions par objet"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Règles par personnage"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Annonces"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Annonces d'échange"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Annonces du responsable du butin"
L["TAB_LOOT_TOASTS"] = "Notifications de butin"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtres"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sons de butin"
L["TAB_AUTOMATED_OPENING"] = "Ouverture automatique"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Coffrets"
L["TAB_OPENABLE_ITEMS"] = "Objets à ouvrir"
L["TAB_MASTER_LOOTER"] = "Responsable du butin"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinataires du butin"
L["TAB_IGNORE_LIST"] = "Liste d'ignorés"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Activé"
L["STATUS_DISABLED"] = "Désactivé"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "En pause"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Lance les dés à votre place sur les objets éligibles, jusqu'à la qualité choisie."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "Ouvre les palourdes, caisses, bourses et coffrets crochetés de vos sacs."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] =
	"Publie dans la discussion les résumés d'échange et les distributions du responsable du butin."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "Distribue le butin aux joueurs choisis pour chaque qualité."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Maj + Clic gauche"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Maj + Clic droit"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Distribution automatique"
L["MINIMAP_TOGGLE"] = "Activer/désactiver"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Objets verrouillés"
L["MINIMAP_OPTIONS"] = "Options de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuel"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s uniquement"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s et inférieur"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Ajouter un objet"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Saisissez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Déposez un objet ici ou tapez son ID"
L["ITEM_LIST_ADD_BUTTON"] = "Ajouter"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtrer les objets..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"N'affiche que les objets dont le nom, l'ID, le réglage ou l'étiquette contient votre saisie."
L["ITEM_LIST_NO_MATCHES"] = "Aucun objet ne correspond à votre filtre."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Nouveaux"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Tous les types d'objets"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Affiche tous les objets de la liste, ou seulement ceux d'un type donné."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Ajouter depuis les sacs"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Ajoute à la liste un objet que vous portez."
L["ITEM_LIST_BAGS_EMPTY"] = "Rien à ajouter dans vos sacs"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Tous les objets que vous portez sont déjà dans la liste."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Valeurs par défaut"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Chargement... (ID : %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Aucun jet n'est jamais fait sur les recettes, livres, montures, mascottes ou objets légendaires, et les objets Lié quand ramassé ou de quête ne le sont que s'ils figurent dans Exceptions par objet."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"Les recettes, livres, montures, mascottes et objets légendaires vous sont toujours laissés."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Exemple : %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Version %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Le butin rapide vide les cadavres en un clin d'œil, les jets automatiques et la distribution automatique décident qui reçoit quoi, et l'ouverture automatique éventre chaque palourde et chaque caisse. Les notifications de butin vous montrent tout, et les objets de quête, recettes, montures, mascottes et objets légendaires restent à l'abri. Ne laissez pas le butin freiner votre rush !"
L["WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Affiche la version de GogoLoot et l'emplacement de ces paramètres à chaque connexion."
L["MINIMAP_BUTTON_ENABLE"] = "Activer le bouton de la minicarte"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Affiche le bouton GogoLoot sur la minicarte. Clic gauche active ou désactive les jets automatiques, Clic droit l'ouverture automatique, Maj + Clic gauche les annonces, et Maj + Clic droit la distribution automatique."

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Fonctionnalités"

L["SPEEDY_LOOT_ENABLE"] = "Activer le butin rapide"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Vide chaque cadavre dès que vous le fouillez, sans afficher la fenêtre de butin. Maintenez Maj en fouillant pour voir la fenêtre. Active l'option %s du jeu, et se met en retrait quand vous êtes %s."

L["FEEDBACK_SUPPORT"] = "Commentaires et assistance"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Réglages du butin de groupe"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Définit comment le butin du groupe est réparti. Seul le chef de groupe peut le modifier."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Définit la qualité d'objet minimale à laquelle s'applique le mode de butin. Seul le chef de groupe peut le modifier."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Ces réglages sont contrôlés par %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Rejoignez un groupe pour les modifier. Seul le chef de groupe le peut."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Remet chaque objet au joueur choisi pour sa qualité dès que vous ouvrez la fenêtre de butin, quand vous êtes %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activer la distribution automatique"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Active ou désactive la distribution automatique. Elle ne fonctionne que dans les donjons et les raids, sauf si Aussi hors instance est coché."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Aussi hors instance"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Distribue aussi le butin dans le monde extérieur. Le butin des boss mondiaux n'est pas échangeable, ce n'est donc pas conseillé."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Inclure les objets de quête"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Distribue aussi les objets de quête, pour booster un personnage que vous jouez vous-même. Ne fonctionne qu'avec un seuil de butin Commun ou inférieur, et seulement pour les objets de quête qui tombent une fois pour tout le groupe. Déconseillé en raid."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Réglages rapides"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Ouvre ces réglages dans une fenêtre dès que vous devenez %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Activer la fenêtre du responsable du butin"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Choisissez qui reçoit chaque qualité. Une qualité sans destinataire reste dans la fenêtre de butin pour vous."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Moi"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Fenêtre de butin"
L["MASTER_LOOTER_SEND_ALL"] = "Tout le butin à"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Attribue toutes les qualités ci-dessous à un seul joueur."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Définit qui reçoit les objets de qualité %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Personne n'est encore choisi, tout le butin attend donc dans la fenêtre de butin."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Les objets de cette liste ne sont jamais distribués automatiquement. Ils attendent dans la fenêtre de butin que vous les distribuiez vous-même."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Ces réglages ne sont pas utilisés tant que la distribution automatique est désactivée."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Remplace la Liste d'ignorés par les objets par défaut de votre extension."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Votre Liste d'ignorés sera remplacée par les objets par défaut de votre extension. Continuer ?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Retire cet objet de la Liste d'ignorés."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Choisit %s, %s ou %s à votre place sur le butin de groupe, jusqu'à la qualité choisie, avec des réglages distincts en groupe et en raid."
L["ROLLS_ENABLE"] = "Activer les jets automatiques"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Active ou désactive les jets automatiques, Exceptions par objet et Règles par personnage comprises."
L["ROLLS_IN_PARTY"] = "En groupe"
L["ROLLS_IN_RAID"] = "En raid"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Jusqu'à la qualité"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s : la qualité maximale sur laquelle GogoLoot lance les dés."
L["ROLLS_ACTION_CHOOSE"] = "%s : le jet que fait GogoLoot. Manuel vous laisse le choix."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Seuils de butin"
L["ROLLS_MESSAGES_HEADER"] = "Messages de jets"
L["ROLLS_PRINT_ITEM"] = "Afficher l'objet dans la discussion"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Affiche dans votre discussion chaque objet sur lequel GogoLoot lance les dés, et le jet choisi. La fenêtre de jet se ferme dès que GogoLoot a joué, vous gardez donc ainsi une trace de ce qui est tombé."
L["ROLLS_HIDE_MESSAGES"] = "Masquer les messages de jets"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Masque les lignes de discussion du jeu pour chaque jet : qui a choisi %s, %s ou %s, et chaque nombre tiré. Ce que chaque gagnant a reçu reste dans la discussion."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Afficher le résumé des gagnants"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Ne pas afficher le résumé des gagnants"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Afficher le résumé des gagnants met une ligne dans la discussion pour chaque victoire, avec le gagnant, l'objet et le jet gagnant, à la place de la ligne du jeu. Ne pas afficher le résumé des gagnants garde la ligne du jeu qui annonce le gagnant."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Définit le jet pour des objets précis, avant les réglages de qualité. C'est la seule façon pour GogoLoot de lancer les dés sur un objet Lié quand ramassé ou de quête."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Ces réglages ne sont pas utilisés tant que les jets automatiques sont désactivés."
L["ITEM_OVERRIDES_ENABLE"] = "Activer les exceptions par objet"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Utilise les jets définis ci-dessous. Désactivé, ces objets suivent les réglages de qualité comme les autres."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Remplace vos Exceptions par objet par les objets par défaut de votre extension."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Vos Exceptions par objet seront remplacées par les objets par défaut de votre extension. Continuer ?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Définit le jet automatique pour cet objet."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Retire cet objet des Exceptions par objet."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Retirer cet objet et son jet des Exceptions par objet ?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Vous laisse l'équipement doté des caractéristiques choisies, personnage par personnage : réglez %s sur Manuel pour votre %s, et l'équipement avec %s garde sa fenêtre de jet tandis que le reste est joué comme d'habitude. Les Exceptions par objet passent toujours en premier."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Caractéristiques principales"
L["CHARACTER_RULES_SECONDARY"] = "Caractéristiques secondaires"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Jet automatique standard"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s : Manuel vous laisse l'équipement qui en possède sur ce personnage, fenêtre de jet comprise. Jet automatique standard lance les dés dessus comme pour tout autre objet."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publie dans la discussion les résumés d'échange et les distributions du responsable du butin, pour que chacun sache où est parti le butin."
L["ANNOUNCEMENTS_ENABLE"] = "Activer les annonces"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Active ou désactive toutes les annonces. Désactivé, GogoLoot n'envoie rien à votre groupe ni à vos partenaires d'échange, pas même les objets que vous distribuez vous-même."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Publie un résumé de chaque échange conclu : objets, enchantements et or."
L["TRADE_ENABLE"] = "Activer les annonces d'échange"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Publie un résumé à la fin d'un échange. La case Annoncer de la fenêtre d'échange est ce même réglage."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Choisit quand les résumés d'échange sont publiés : toujours, en groupe ou en raid, ou seulement en raid."
L["TRADE_CONDITION_ALWAYS"] = "Toujours"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "En groupe ou en raid"
L["TRADE_CONDITION_RAID_ONLY"] = "En raid"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envoie chaque résumé à votre partenaire d'échange. Canal de groupe le publie dans votre groupe ou raid, et le chuchote quand même hors groupe. Moi seul l'affiche dans votre propre discussion sans l'envoyer à personne."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Canal de groupe"
L["TRADE_OUTPUT_SELF"] = "Moi seul"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publie un résumé dans la discussion quand cet échange est conclu."
L["TRADE_CHECKBOX_LABEL"] = "Annoncer"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Indique à votre groupe qui garde chaque qualité et ce que vous avez distribué."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activer les annonces de destinataire"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Indique au groupe qui garde chaque qualité chaque fois que vous choisissez un destinataire."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activer les annonces de distribution automatique"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Annonce chaque objet que GogoLoot distribue automatiquement, à partir de la qualité choisie."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Les distributions automatiques en dessous de cette qualité ne sont pas annoncées."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Activer les annonces de distribution manuelle"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Annonce chaque objet que vous distribuez vous-même depuis le menu %s, quelle que soit sa qualité, formulé comme une distribution automatique. Une distribution qui échoue est signalée dans tous les cas."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Affiche à l'écran pendant quelques secondes chaque objet et chaque pièce que vous ramassez, pour que rien ne vous échappe pendant que le butin rapide masque la fenêtre de butin. Tant qu'elles sont activées, les lignes de butin du jeu peuvent être retirées de votre onglet de discussion %s."
L["LOOT_TOASTS_ENABLE"] = "Activer les notifications de butin"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"Affiche une notification pour le butin choisi dans Filtres, le vôtre et celui de votre groupe."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Désactiver les messages de butin standard"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Activer les messages de butin standard"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Désactiver coupe %s et %s dans votre onglet de discussion %s tant que les notifications de butin sont activées, et couper les notifications de butin les rétablit. C'est le même réglage que dans les Réglages de cet onglet, et les autres onglets gardent le leur."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Empilement"
L["LOOT_TOASTS_TEXT_HEADER"] = "Texte"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] =
	"Ces réglages ne sont pas utilisés tant que les notifications de butin sont désactivées."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Choisissez ce qui reçoit une notification, et ce qu'elle indique, pour votre butin et celui de votre groupe. Le butin de votre groupe affiche à côté le nom de celui qui l'a ramassé."
L["LOOT_TOASTS_FILTER_MINE"] = "Moi"
L["LOOT_TOASTS_FILTER_GROUP"] = "Groupe"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Affiche les objets de type %s que vous ramassez."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Affiche les objets de type %s ramassés par n'importe qui dans votre groupe ou raid, avec le nom de celui qui les ramasse."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Affiche les objets de type %s que vous ramassez, de la qualité indiquée à côté ou supérieure."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Affiche les objets de type %s ramassés par n'importe qui dans votre groupe ou raid, de la qualité indiquée à côté ou supérieure, avec le nom de celui qui les ramasse."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"La qualité minimale des objets de type %s que vous ramassez pour obtenir une notification."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"La qualité minimale des objets de type %s ramassés par votre groupe pour obtenir une notification."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Lié quand ramassé"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Affiche chaque objet Lié quand ramassé que vous obtenez, quels que soient son type et sa qualité."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Affiche chaque objet Lié quand ramassé obtenu par votre groupe, quels que soient son type et sa qualité."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Objets à ouvrir"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Affiche les conteneurs que vous ramassez et que GogoLoot peut ouvrir, coffrets compris, quelle que soit leur qualité."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Affiche les conteneurs ramassés par votre groupe et que GogoLoot peut ouvrir, coffrets compris, quelle que soit leur qualité."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Affiche une notification pour les pièces que vous ramassez. Le jeu ne signale pas l'argent des autres joueurs, il n'y a donc pas de case Groupe."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Jet gagnant"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Ajoute à sa notification le jet avec lequel vous avez gagné un objet, par exemple (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Ajoute à sa notification le jet avec lequel un membre du groupe a gagné un objet, par exemple (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Quantité en sac"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Ajoute aux notifications de votre propre butin la quantité que vous portez désormais, par exemple x3 (27), dès que vous en portez plus que la quantité de la notification."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Nombre maximum"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"Le nombre maximum de notifications à l'écran en même temps ; la plus ancienne disparaît pour faire de la place."
L["LOOT_TOASTS_UNLIMITED"] = "Illimité"
L["LOOT_TOASTS_DURATION"] = "Secondes à l'écran"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Combien de secondes chaque notification reste affichée avant de s'estomper."
L["LOOT_TOASTS_GROWTH"] = "Sens d'empilement"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"Si les anciennes notifications montent ou descendent, en s'éloignant de la plus récente."
L["LOOT_TOASTS_GROW_UP"] = "Vers le haut"
L["LOOT_TOASTS_GROW_DOWN"] = "Vers le bas"
L["LOOT_TOASTS_ALIGN"] = "Alignement"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "De quel côté de la poignée les notifications s'alignent."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Gauche"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Droite"

-- Text
L["LOOT_TOASTS_FONT"] = "Police"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "La police utilisée pour les notifications."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Par défaut"
L["LOOT_TOASTS_FONT_SIZE"] = "Taille de police"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] =
	"La taille du texte des notifications ; les icônes grandissent et rétrécissent avec lui."
L["LOOT_TOASTS_OUTLINE"] = "Contour de police"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"Le contour tracé autour du texte des notifications, qui le garde lisible sur les décors clairs."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Aucun"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contour"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contour épais"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monochrome"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contour monochrome"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Déverrouiller la position"
L["LOOT_TOASTS_LOCK"] = "Verrouiller la position"
L["LOOT_TOASTS_RESET"] = "Réinitialiser la position"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Affiche ou masque la poignée qui sert à déplacer les notifications."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Replace les notifications à leur position par défaut, au-dessus du centre de l'écran."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "Notifications de butin GogoLoot"
L["LOOT_TOASTS_CLICK_DRAG"] = "Clic + glisser pour déplacer"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clic droit pour verrouiller"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Désactiver les notifications de butin"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Objet d'exemple"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Joue un carillon pour le butin de la qualité choisie ou supérieure, et un bruit de sac quand %s dérobe quelque chose."
L["LOOT_SOUNDS_ENABLE"] = "Activer le son de butin"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Joue un carillon quand vous ramassez sur un cadavre ou dans un coffre un objet de la qualité choisie ou supérieure."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "La qualité d'objet minimale qui déclenche le son de butin."
L["LOOT_SOUNDS_TEST"] = "Joue le son de butin."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Activer le son de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Joue un bruit de sac quand %s dérobe réellement quelque chose."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Joue le son de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Ouvre pour vous les palourdes, caisses, bourses et coffrets crochetés de vos sacs, dès que vous avez au moins %d emplacements de sac libres."
L["AUTOMATED_OPENING_ENABLE"] = "Activer l'ouverture automatique"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Ouvre un conteneur à la fois, et attend si vous êtes en combat, en train d'incanter, camouflé, ou si une fenêtre de marchand, de banque, de boîte aux lettres, d'hôtel des ventes ou d'échange est ouverte. Active l'option %s du jeu tant que l'ouverture automatique est activée."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Seulement hors instance"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"N'ouvre rien tant que vous êtes dans un donjon, un raid ou un champ de bataille."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Seulement en solo"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "N'ouvre rien tant que vous êtes en groupe ou en raid."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Un coffret ne s'ouvre pas tant qu'un %s ne l'a pas crocheté. Ces options affichent la compétence %s requise pour chacun et vous préviennent quand l'un d'eux attend."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Activer les infobulles de coffrets"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Ajoute à l'infobulle de chaque coffret la compétence %s qu'il requiert."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Choisit si les infobulles de coffrets s'affichent seulement pour les Voleurs ou pour tous les personnages."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Activer les alertes de coffrets"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Vous prévient dans la discussion quand vous ramassez un coffret qui s'ouvrira une fois déverrouillé."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Choisit si les alertes de coffrets s'affichent seulement pour les Voleurs ou pour tous les personnages."
L["LOCKBOXES_FOR_ROGUES"] = "Pour les Voleurs"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Pour tous les personnages"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Votre %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Activer les alertes d'objets ignorés"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Vous prévient dans la discussion quand GogoLoot laisse un conteneur de côté parce que la liste Objets à ouvrir indique Ignorer, et pourquoi."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Tous les conteneurs que GogoLoot connaît, et ce que l'ouverture automatique en fait. Ignorer garde un conteneur fermé, et le butin rapide le laisse dans la fenêtre de butin pour vous. Vos modifications s'appliquent à tous vos personnages."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Seul Ignorer est utilisé tant que l'ouverture automatique est désactivée : il empêche toujours le butin rapide de prendre ces objets."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Rétablit la liste par défaut : chaque objet reprend son réglage par défaut, les objets retirés reviennent et les objets ajoutés disparaissent."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Rétablir la liste par défaut ? Tous les réglages modifiés, et tous les objets ajoutés ou retirés, seront annulés."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Saisissez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste, réglé sur Ouvrir. L'équipement et les sacs ne peuvent pas être ajoutés, car les utiliser les équipe."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Ajoute à la liste un objet que vous portez, réglé sur Ouvrir. L'équipement et les sacs ne sont pas proposés, car les utiliser les équipe."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Retire cet objet de la liste. GogoLoot le traite alors comme un objet ordinaire : jamais ouvert, et ramassé comme les autres."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "Retirer cet objet de la liste ? Ajoutez-le de nouveau pour le récupérer."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Définit ce que l'ouverture automatique fait de ce conteneur."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Ouvrir"
L["OPENING_ACTION_IGNORE"] = "Ignorer"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vendre fermé"
L["OPENING_TAG_UNIQUE"] = "Unique possible"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Doit être crocheté par un %s. Une fois crocheté, il s'ouvre comme n'importe quel autre conteneur."
L["OPENING_REASON_RAID"] =
	"Butin d'un boss de raid ou d'un boss mondial. Un conteneur fermé peut encore être échangé ou vendu, souvent plus cher que son contenu."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Peut contenir du butin Lié quand ramassé. Fermé, il peut encore être échangé ou vendu."
L["OPENING_REASON_UNIQUE"] =
	"Peut contenir un objet unique. L'ouverture échoue avec une erreur si vous en portez déjà un."
