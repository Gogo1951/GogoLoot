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

-- The Full Name: leads every printed line, and names the options panels, window titles and the mini-map header. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
-- The Short Name: closes every sent message and names the add-on on tooltip lines other than the mini-map header. A proper noun; keep it untranslated.
L["ADDON_SHORT_NAME"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > GogoLoot. L'add-on vous plaît ? Parlez-en à un ami, ajoutez-le à vos favoris sur CurseForge ou donnez-lui une Star sur GitHub. (="
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
-- A pickup the server refused after Speedy Loot had already closed the loot. %s is the client's own reason, such as "Inventory is full.", and leads, since it brings its own closing punctuation.
L["MESSAGE_LOOT_LEFT_ON_CORPSE"] = "%s Une partie du butin est restée sur le cadavre."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"%s et %s ont été désactivés dans votre onglet de discussion %s tant que les notifications de butin sont activées."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "%s et %s ont été réactivés dans votre onglet de discussion %s."

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Butin rapide"
L["TAB_AUTOMATED_ROLLS"] = "Jets automatiques"
L["TAB_ITEM_OVERRIDES"] = "Exceptions par objet"
-- A child panel of Automated Rolls: each character's rolls by the stats and gear types it wants.
L["TAB_CHARACTER_RULES"] = "Règles par personnage"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Annonces de butin"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Annonces d'échange"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Annonces du responsable du butin"
L["TAB_LOOT_TOASTS"] = "Notifications de butin"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtres"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sons de butin"
L["TAB_AUTOMATED_OPENING"] = "Ouverture automatique"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Coffrets"
L["TAB_OPENABLE_ITEMS"] = "Objets à ouvrir"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "Distribution automatique"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinataires du butin"
L["TAB_IGNORE_LIST"] = "Liste d'ignorés"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Macro de jet"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Maître du butin"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Lance les dés à votre place sur les objets éligibles, jusqu'à la qualité choisie."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Ouvre les palourdes, caisses, bourses et coffrets déverrouillés de vos sacs."
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
L["MINIMAP_TOGGLE"] = "Activer/désactiver"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Objets verrouillés"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "Un %s peut les crocheter pour vous."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "Utilisez %s pour les déverrouiller."
L["MINIMAP_OPTIONS"] = "Options de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Butin échangeable"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "%d de plus"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Maître du butin et Suivi du butin"
L["MINIMAP_TO_HAND_OUT"] = "%d à distribuer"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Distribuez par jet ce que vous pouvez encore échanger, et suivez chaque jet."
L["MINIMAP_MIDDLE_CLICK"] = "Clic central"
L["MINIMAP_OPEN"] = "Ouvrir"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuel"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s uniquement"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s et inférieur"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
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
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"Cette liste est vide : ses valeurs par défaut reviendront à votre prochaine connexion. Le bouton Valeurs par défaut les rétablit tout de suite."

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
    a quest item gets rolled on, and Item Overrides or Include Bind on Pickup
    the way a Bind on Pickup item does; nothing ever rolls on the rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Aucun jet n'est jamais fait sur les recettes, livres, montures, mascottes ou objets légendaires, les objets de quête ne le sont que s'ils figurent dans Exceptions par objet, et les objets Lié quand ramassé que s'ils y figurent ou si Inclure Lié quand ramassé est activé."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"Les recettes, livres, montures, mascottes et objets légendaires vous sont toujours laissés."

-- The channel choice that posts to the party or raid: Trade Announcements' Channel and the Loot Master's Announce In.
L["CHANNEL_GROUP_CHAT"] = "Canal de groupe"

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "Exemple : %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Le Butin rapide vide les cadavres sans fenêtre de butin, choisit Besoin, Cupidité ou Passer selon la qualité, et la Distribution automatique attribue le butin pour vous. Palourdes, conteneurs et coffrets déverrouillés s'ouvrent tout seuls. Ramassez plus vite, enchaînez plus tôt."
L["WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Affiche la version de GogoLoot et l'emplacement de ces paramètres à chaque connexion."
L["MINIMAP_BUTTON_ENABLE"] = "Activer le bouton de la minicarte"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Affiche le bouton GogoLoot sur la minicarte. Clic gauche active ou désactive les jets automatiques, Clic droit l'ouverture automatique, Maj + Clic gauche les annonces de butin, et Maj + Clic droit la distribution automatique."

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Fonctionnalités"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Prend tout sur un cadavre dès que vous le fouillez, pour ne jamais attendre la fenêtre de butin."
L["SPEEDY_LOOT_ENABLE"] = "Activer le butin rapide"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Vide chaque cadavre dès que vous le fouillez, sans afficher la fenêtre de butin. Maintenez Maj en fouillant pour voir la fenêtre. Active l'option %s du jeu, et se met en retrait quand vous êtes %s."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Ajoute à vos macros générales une macro nommée %s, avec une icône de pièces d'or, pour que chaque personnage de votre compte puisse la glisser sur une barre d'action."
--[[
    The three rows under it, each beside its mouse button's caption
    (MINIMAP_LEFT_CLICK and its neighbors). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Jet 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Jet 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Jet de raid"
L["ROLL_MACRO_ENABLE"] = "Activer la macro de jet"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Un jet de raid attribue un objet à quelqu'un au hasard. Il tire un nombre de 1 au nombre de joueurs de votre groupe, chaque nombre correspondant à un joueur : comptez dans la liste de votre raid ou de votre groupe jusqu'au nombre tiré pour trouver le gagnant. Seul, il tire de 1 à 100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Garde la macro %s dans vos macros générales : Clic gauche tire 1-100, Clic droit 1-99, Clic central un jet de raid. La désactiver la supprime."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "La macro %s est dans vos macros générales. Tapez %s et glissez-la sur une barre d'action."
L["ROLL_MACRO_REMOVED"] = "La macro %s a été supprimée."
L["ROLL_MACRO_FULL_LOADING"] =
	"Impossible d'ajouter la macro %s : vos macros générales sont pleines. Supprimez-en une, et elle sera ajoutée après votre prochain écran de chargement."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Aidez GogoLoot à monter de niveau"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Cet add-on a été créé par des joueurs qui adorent ce jeu et veulent le rendre aussi amusant que possible pour tous. Nous ne demanderons jamais de dons. Notre vraie satisfaction, c'est de savoir que notre travail rend le jeu un peu meilleur pour vous. Si c'est le cas, nous serions ravis de le savoir !"
L["OPTIONS_LEVEL_UP_WAYS"] = "Voici quelques façons de nous aider à toucher plus de joueurs."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Donner votre avis : un bug ou une idée ? Dites-le-nous sur Discord. Vos retours nous aident à améliorer l'add-on, et les demandes de fusion sont toujours bienvenues."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Parler à un ami : vous connaissez quelqu'un qui pourrait apprécier cet add-on ? Parlez-lui-en. Le bouche-à-oreille aide plus de joueurs à découvrir de bons add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favori sur CurseForge : ouvrez le lien CurseForge ci-dessous, connectez-vous et cliquez sur l'étoile sous le bouton de téléchargement. Les favoris aident plus de joueurs à découvrir l'add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Une Star sur GitHub : ouvrez le lien GitHub ci-dessous, connectez-vous et cliquez sur Star en haut à droite. Les Stars aident le projet à obtenir plus d'outils de développement gratuits."
L["OPTIONS_LEVEL_UP_THANKS"] = "Merci d'avoir choisi GogoLoot !"

L["OPTIONS_FEEDBACK"] = "Commentaires et assistance"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Liens d'avis et d'assistance"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Pour copier un lien, cliquez dans sa case, puis appuyez sur Ctrl+A et Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Version %s"

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

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "Réglages rapides"
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
	"Remplacer votre Liste d'ignorés par les objets par défaut de votre extension ?"
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
L["ROLLS_INCLUDE_BIND_ON_PICKUP"] = "Inclure Lié quand ramassé"
L["ROLLS_INCLUDE_BIND_ON_PICKUP_DESCRIPTION"] =
	"Les jets ci-dessus et les Règles par personnage lancent aussi les dés sur les objets Lié quand ramassé. Désactivé par défaut, car mieux vaut en général lancer les dés soi-même sur le butin Lié quand ramassé."
-- Section headers on the Automated Rolls panel.
L["ROLLS_PARTY_AND_RAID_HEADER"] = "Jets en groupe et en raid"
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
	"Définit le jet pour des objets précis, avant les réglages de qualité. C'est la seule façon pour GogoLoot de lancer les dés sur un objet de quête, ou sur un objet Lié quand ramassé tant qu'Inclure Lié quand ramassé est désactivé."
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Ces réglages ne sont pas utilisés tant que les jets automatiques sont désactivés."
L["ITEM_OVERRIDES_ENABLE"] = "Activer les exceptions par objet"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Utilise les jets définis ci-dessous. Désactivé, ces objets suivent les réglages de qualité comme les autres."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "Ces jets ne sont pas utilisés tant que les exceptions par objet sont désactivées."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Remplace vos Exceptions par objet par les objets par défaut de votre extension."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Remplacer vos Exceptions par objet par les objets par défaut de votre extension ?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Définit le jet automatique pour cet objet."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Retire cet objet des Exceptions par objet."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Retirer cet objet et son jet des Exceptions par objet ?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"Saisissez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste, réglé sur Manuel."

--[[
    Character Rules, under Automated Rolls: the stats and the armor and
    weapon types each character wants, whose gear is left to the player. The
    stat, armor and weapon names come from the game's own strings.
]]
-- Arguments: the game's own name for Strength, then for the Warrior class, then Strength again.
L["CHARACTER_RULES_PANEL_INTRO"] =
	"Vous voulez de l'équipement avec %s pour votre %s ? Cochez %s et les types d'armure et d'arme que vous utilisez. L'équipement correspondant vous est laissé pour lancer les dés, et Tout le reste s'occupe du reste. Les Exceptions par objet passent toujours en premier."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Caractéristiques principales"
L["CHARACTER_RULES_SECONDARY"] = "Caractéristiques secondaires"
-- The armor and weapon sections above the stats; each box is named by the game.
L["CHARACTER_RULES_ARMOR"] = "Types d'armure"
L["CHARACTER_RULES_WEAPONS"] = "Types d'arme"
-- The catch-all row at the bottom, under the game's own "Other": any armor or weapon no row above names.
L["CHARACTER_RULES_OTHER_GEAR"] = "Autres armures et armes"
L["CHARACTER_RULES_OTHER_GEAR_NOTE"] =
	"Cannes à pêche, armes Divers, et toute armure ou arme qu'aucun type ci-dessus ne nomme."
-- The section under the lists: what happens to gear that doesn't match, and the button that clears a character's changes.
L["CHARACTER_RULES_EVERYTHING_ELSE"] = "Tout le reste"
L["CHARACTER_RULES_UNWANTED_ACTION"] = "Équipement non correspondant"
L["CHARACTER_RULES_RESET"] = "Rétablir les valeurs de la classe"
-- Sanity Check, at the foot of each character's page: ten sample items and how each would roll.
L["CHARACTER_RULES_SANITY_CHECK"] = "Vérification"
L["CHARACTER_RULES_SANITY_CHECK_NOTE"] =
	"Comment ces objets verts Lié quand équipé seraient joués pour ce personnage, selon les cases ci-dessus."
--[[
    A Sanity Check row's outcome, Roll Window or Automated Roll, then in
    brackets why, where the boxes don't say: one of the SANITY_ reasons below,
    or Item Overrides by its panel name (TAB_ITEM_OVERRIDES).
]]
L["CHARACTER_RULES_SANITY_ROLL_WINDOW"] = "Fenêtre de jet"
L["CHARACTER_RULES_SANITY_AUTOMATED_ROLL"] = "Jet automatique"
-- The note under a sample item's tooltip. Argument: the game's own names for the stats it carries, joined by commas.
L["CHARACTER_RULES_SANITY_STATS"] = "Caractéristiques lues par les Règles par personnage : %s"
L["CHARACTER_RULES_SANITY_LOW_LEVEL"] = "Équipement de bas niveau"
L["CHARACTER_RULES_SANITY_ROLLS_OFF"] = "Jets automatiques désactivés"
L["CHARACTER_RULES_SANITY_QUALITY"] = "Réglages de qualité"
-- Argument: the game's own name for the character's class.
L["CHARACTER_RULES_CLASS"] = "Classe : %s"
L["CHARACTER_RULES_LOW_LEVEL"] = "Cupidité automatique sur l'équipement de bas niveau"
L["CHARACTER_RULES_LOW_LEVEL_DESCRIPTION"] =
	"Fait Cupidité sur les armures et armes dont le niveau requis est au moins autant inférieur au vôtre, qu'elles correspondent ou non, jusqu'à la qualité de Tout le reste, pour que l'équipement dépassé ne vous retienne jamais pendant la montée de niveau."
-- The dropdown beside it: Off, then a level gap. Argument: how many levels below the character's own, 1 to 5.
L["CHARACTER_RULES_LOW_LEVEL_OFF"] = "Désactivé"
L["CHARACTER_RULES_LOW_LEVEL_BELOW"] = "Votre niveau - %d"
-- Printed once per account, at the first login where Automated Rolls is on by default.
L["MESSAGE_AUTOMATED_ROLLS_ON"] =
	"Les Jets automatiques sont maintenant activés : l'équipement que veut chaque personnage vous est laissé pour lancer les dés, et le reste est joué en Cupidité. Modifiez-le dans Options > AddOns > GogoLoot > Jets automatiques."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publie dans la discussion les résumés d'échange et les distributions du responsable du butin, pour que chacun sache où est parti le butin."
L["ANNOUNCEMENTS_ENABLE"] = "Activer les annonces de butin"
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
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "Quand"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envoie chaque résumé à votre partenaire d'échange. Canal de groupe le publie dans votre groupe ou raid, et le chuchote quand même hors groupe. Moi seul l'affiche dans votre propre discussion sans l'envoyer à personne."
-- The Channel dropdown's choices (Whisper is the client's WHISPER, Group Chat is CHANNEL_GROUP_CHAT), and the trade window checkbox tooltip's Channel value.
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
-- The checkbox under Enable Loot Toasts, and its tooltip.
L["LOOT_TOASTS_TOOLTIPS_ENABLE"] = "Activer les infobulles des objets des notifications de butin"
L["LOOT_TOASTS_TOOLTIPS_DESCRIPTION"] =
	"Affiche l'infobulle d'un objet quand vous pointez sa notification. Désactivé, les notifications ignorent la souris : vous pouvez pointer et cliquer les monstres et les cadavres derrière elles."
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
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"Affiche les sacs que vous ramassez. Les palourdes, caisses et coffrets sont sous Objets à ouvrir."
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"Affiche les sacs ramassés par n'importe qui dans votre groupe ou raid, avec le nom de celui qui les ramasse. Les palourdes, caisses et coffrets sont sous Objets à ouvrir."

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
	"Affiche une notification pour les pièces que vous ramassez. Le jeu ne signale pas les pièces des autres joueurs, il n'y a donc pas de case Groupe."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Jet gagnant"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Ajoute à sa notification le jet avec lequel vous avez gagné un objet, par exemple (Gagné, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Ajoute à sa notification le jet avec lequel un membre du groupe a gagné un objet, par exemple (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Gagné, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Quantité en sac"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Ajoute aux notifications de votre propre butin la quantité que vous portez désormais, par exemple x3 (27), dès que vous en portez plus que la quantité de la notification."
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
L["LOOT_TOASTS_ALIGN_TOASTS"] = "Aligner les notifications"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "De quel côté de la poignée les notifications s'alignent."
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
L["LOOT_TOASTS_RESET_CONFIRM"] = "Replacer les notifications de butin à leur position par défaut ?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Affiche ou masque la poignée qui sert à déplacer les notifications."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Replace les notifications à leur position par défaut, au-dessus du centre de l'écran."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "Clic + glisser pour déplacer"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clic droit pour verrouiller"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Désactiver les notifications de butin"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Objet d'exemple"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Joue un carillon pour le butin de la qualité choisie ou supérieure, et un bruit de sac quand %s dérobe quelque chose."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Activer les sons de butin"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Active ou désactive tous les sons de butin de GogoLoot."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Activer le carillon de butin"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Joue un carillon quand vous ramassez sur un cadavre ou dans un coffre un objet de la qualité choisie ou supérieure."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "La qualité d'objet minimale qui déclenche le carillon de butin."
L["LOOT_SOUNDS_TEST"] = "Joue le carillon de butin."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Activer le son de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Joue un bruit de sac quand %s dérobe réellement quelque chose."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Joue le son de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Ouvre pour vous les palourdes, caisses, bourses et coffrets déverrouillés de vos sacs, dès que vous avez au moins %d emplacements de sac libres."
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
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"Les alertes de coffrets ne sont pas utilisées tant que l'ouverture automatique est désactivée."
L["LOCKBOXES_FOR_ROGUES"] = "Pour les Voleurs"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Pour tous les personnages"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Votre %s"

-- On the Openables List panel.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Activer les alertes d'objets ignorés"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Vous prévient dans la discussion quand GogoLoot laisse un conteneur de côté parce que la liste Objets à ouvrir indique Ignorer, et pourquoi."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Tous les conteneurs que GogoLoot connaît, et ce que l'ouverture automatique en fait. Ignorer garde un conteneur fermé. Vos modifications s'appliquent à tous vos personnages."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] = "Ces réglages ne sont pas utilisés tant que l'ouverture automatique est désactivée."
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

--------------------------------------------------------------------------------
-- Roll Calls: Sent to the Group
--------------------------------------------------------------------------------

--[[
    What the Loot Master sends when it calls a roll, in the sent format: no
    closing period, since the add-on name follows. Item arguments are links.
    Calls, ties and pauses go to Raid Warning where the player can send one;
    results go to group chat.
]]
-- Arguments: the item, then the roll's length in seconds.
L["ROLL_CALL_START"] = "Faites /roll pour %s, %d secondes"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "%d secondes restantes pour %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d secondes de plus pour %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Non comptés pour %s : %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "jet anticipé de %s (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "jet en trop de %s (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s a fait %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s a fait %d (hors départage)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s à égalité avec %d pour %s. %s uniquement, refaites /roll, %d secondes"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s à égalité avec %d pour %s. Un départage va suivre"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s remporte %s avec %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "%s remporte désormais %s avec %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Personne n'a fait de jet pour %s. Il reste sur ma liste pour l'instant"
L["ROLL_CALL_NOBODY_LEFT"] = "Plus aucun jet ne compte pour %s. Il retourne sur ma liste"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "J'ai disqualifié le jet de %s (%d) pour %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "J'ai disqualifié le jet de %s (%d) pour %s : %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "J'ai rétabli le jet de %s (%d) pour %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "J'ai annulé tous les jets pour %s. Refaites /roll, %d secondes"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Jet pour %s annulé. Ne lancez pas encore"
L["ROLL_CALL_PAUSED"] = "Ne lancez pas encore. %s est en pause"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Les jets reprennent pour %s, %d secondes restantes"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Mis en jeu dans l'ordre : %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Mis en jeu : %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Butin au sol mis en jeu : %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "Vous n'êtes pas en groupe, ceci n'a donc été envoyé à personne : %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] =
	"%s a gagné %s. Ouvrez un échange avec ce joueur et GogoLoot place l'objet dans la fenêtre."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Jet avant l'appel"
L["ROLL_TAG_LATE"] = "Jet après la clôture"
L["ROLL_TAG_REPEAT"] = "Jet en trop, non compté"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Mauvaise plage (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Hors départage"
L["ROLL_TAG_DISQUALIFIED"] = "Disqualifié"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Disqualifié : %s"
L["ROLL_TAG_WINNER"] = "Gagnant"
L["ROLL_TAG_HIGHEST"] = "Le plus haut pour l'instant"
L["ROLL_TAG_TIED"] = "Égalité"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Pas éligible pour cet objet"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "A déjà gagné un objet ce soir"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Jet pour quelqu'un d'autre"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Aucune raison donnée"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Liste des jets (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Butin au sol (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Attribués (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Réservations souples"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Lancer"
L["LOOT_MASTER_ROLL_AGAIN"] = "Relancer"
L["LOOT_MASTER_ROLL_ALL"] = "Jets en chaîne"
L["LOOT_MASTER_PAUSE"] = "Mettre en pause"
L["LOOT_MASTER_RESUME"] = "Reprendre"
L["LOOT_MASTER_STOP"] = "Arrêter"
L["LOOT_MASTER_LIST_IN_RAID"] = "Publier en raid"
L["LOOT_MASTER_MOVE_UP"] = "Monter"
L["LOOT_MASTER_MOVE_DOWN"] = "Descendre"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d secondes"
L["LOOT_MASTER_CLOSE_NOW"] = "Clôturer maintenant"
L["LOOT_MASTER_VOID"] = "Annuler tous les jets"
L["LOOT_MASTER_CANCEL_ROLL"] = "Annuler le jet"
L["LOOT_MASTER_TAKE_OFF"] = "Retirer de la liste"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Donner à %s"
L["LOOT_MASTER_TRADE"] = "Échanger avec %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Annoncer le gagnant"
L["LOOT_MASTER_HANDED_OUT"] = "Marquer comme remis"
L["LOOT_MASTER_REROLL_TIED"] = "Départager"
L["LOOT_MASTER_DISQUALIFY"] = "Disqualifier"
L["LOOT_MASTER_RESTORE"] = "Rétablir"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "Sur le cadavre"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Cadavre fermé"
L["LOOT_MASTER_BOUND"] = "Lié"
L["LOOT_MASTER_NO_LIMIT"] = "Sans limite"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "En cours, %d jets"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Départage, %d jets"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "En attente, %d jets"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Égalité"
L["LOOT_MASTER_STATUS_NOBODY"] = "Aucun jet"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Désormais lié"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "À suivre"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Jet en cours, %d secondes restantes."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "En attente, %d secondes restantes."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Départage entre %s, %d secondes restantes."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s a gagné avec %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s à égalité avec %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Désormais lié, il ne peut plus être échangé."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Ramassé sur %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "Provient du Butin au sol."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Encore échangeable pendant %s."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Jets jusqu'ici"
L["LOOT_MASTER_ROUND_ROLLS"] = "Jets"
L["LOOT_MASTER_ROUND_FIRST"] = "Premier jet"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Départage"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Sans jet (%d) : %s"

L["LOOT_MASTER_EMPTY"] =
	"Rien à distribuer pour l'instant. Le butin échangeable que vous ramassez arrive ici tout seul ; Alt + Clic sur tout autre objet de vos sacs pour l'ajouter."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "En pause."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Jets en chaîne : %d restants."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "Un jet à la fois."
L["LOOT_MASTER_STATE_WAITING"] = "%d en attente d'un jet."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d à distribuer."
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d à distribuer, le prochain délai d'échange expire dans %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + Clic sur un objet de vos sacs pour l'ajouter"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Disqualifier un jet"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "Écarter le jet de %s (%d) pour %s ? Vous pourrez le rétablir plus tard."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Raison"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot annonce au groupe :"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "Annuler tous les jets pour %s et relancer l'appel ?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "Jets en chaîne terminés. Chaque objet de la Liste des jets a eu son jet."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] =
	"Jets en chaîne en pause. Rien de nouveau ne démarre tant que vous n'appuyez pas sur Reprendre."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Jets en chaîne repris."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Jets en chaîne arrêtés. Un jet en cours se termine quand même."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s peut encore être échangé pendant %d minutes."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s ne peut plus être échangé."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "%s placé dans la fenêtre d'échange pour %s, qui l'a gagné avec %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s ne peut pas recevoir %s depuis ce cadavre."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s a rejoint la Liste des jets."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s ne peut pas être échangé, il ne peut donc pas aller dans la Liste des jets."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Objets du Butin au sol ajoutés à la Liste des jets : %d."
L["LOOT_MASTER_OFF"] =
	"Le Maître du butin est désactivé. Activez-le dans Options > AddOns > GogoLoot > Maître du butin."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "Dans la Liste des jets."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Gagné par %s avec %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Butin sans délai d'échange que vous voulez mettre en jeu : composants, recettes, équipement Lié quand équipé. La liste démarre vide, seul ce que vous ajoutez est donc mis en jeu. Un jet par pile."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	"Rien ici pour l'instant. Choisissez dans Ajouter depuis les sacs, ou déposez un objet dans la case ci-dessus."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "%d dans les sacs"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "Dans la Liste des jets"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Retire cet objet du Butin au sol."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Autre"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Tout ajouter à la Liste des jets"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Ramassé dans cette instance"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Aussi dans vos sacs"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Rien d\'échangeable dans vos sacs ne correspond à "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"Rien de distribué pour l'instant. Un objet gagné arrive ici une fois que son gagnant l'a reçu."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Jet de %d, à %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Remis à %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Effacer"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Collez ici une chaîne de réservations souples pour voir qui a réservé quoi. Bientôt disponible : cet onglet n'est qu'un espace réservé pour l'instant."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "L'import des réservations souples n'est pas encore prêt."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Importer"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Suivi du butin"
L["LOOT_TRACKER_TAB_ROLLS"] = "Jets"
L["LOOT_TRACKER_TAB_DROPS"] = "Butin"
L["LOOT_TRACKER_NO_ROLL"] = "Aucun jet ce soir pour l'instant."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Appelé par %s"
L["LOOT_TRACKER_SPOTTED"] = "Repéré dans la discussion (%s)"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "%d s restantes"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s n'utilise pas GogoLoot, voici donc les jets vus dans la discussion, vérifiés selon les règles habituelles : 1-100, premier jet seulement. Celui qui a lancé l'appel a le dernier mot."
L["LOOT_TRACKER_ON_HOLD"] = "En attente. Attendez l'appel pour relancer."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Jets de départage"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s a gagné avec %d"
L["LOOT_TRACKER_CLOSED"] = "Clos"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Plus haut"
L["LOOT_TRACKER_SORT_TIME"] = "Ordre des jets"
L["LOOT_TRACKER_ROLL"] = "Lancer (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Vous"
L["LOOT_TRACKER_YOU_ROLLED"] = "Vous avez fait %d."
L["LOOT_TRACKER_YOU_PASSED"] = "Vous avez passé."
L["LOOT_TRACKER_NOT_ROLLED"] = "Vous n'avez pas encore lancé."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Seuls les joueurs à égalité lancent maintenant."
L["LOOT_TRACKER_EARLIER"] = "Plus tôt ce soir"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "/rand"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Afficher qui a eu quoi"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Aucun butin vu pour l'instant. Il apparaît ici à mesure que les boss tombent et que les cadavres sont fouillés."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Personne avec GogoLoot ne l'a encore fouillé."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Pas encore distribué"
L["LOOT_TRACKER_PRINT"] = "Afficher"
L["LOOT_TRACKER_POST"] = "Publier en raid"
L["LOOT_TRACKER_COPY"] = "Copier"
L["LOOT_TRACKER_COPY_TITLE"] = "Copier avec Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Menu fretin"
L["DROPS_NONE"] = "Aucun butin enregistré pour l'instant."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Butin dans %s :"
-- Arguments: the boss, then its drops, joined by commas.
L["DROPS_PRINT_LINE"] = "%s: %s."
-- An item and who got it. Arguments: the item, then the winner (with their roll, below).
L["DROPS_WINNER"] = "%s (%s)"
-- Arguments: the winner, then their winning roll.
L["DROPS_WINNER_ROLL"] = "%s %d"

--------------------------------------------------------------------------------
-- Options: Loot Master
--------------------------------------------------------------------------------

L["LOOT_MASTER_PANEL_DESCRIPTION"] =
	"Distribuez par jet ce que vous pouvez encore échanger, avec le délai d'échange de chaque objet, et suivez chaque jet dans le Suivi du butin. Clic central sur le bouton de la minicarte, ou tapez /gogo master ou /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Activer le Maître du butin"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Suit le butin que vous pouvez encore échanger et lance les appels aux jets. Désactivé, le Maître du butin et le Suivi du butin ne s'ouvrent jamais et aucun jet n'est lu."
L["LOOT_MASTER_OPEN"] = "Ouvrir le Maître du butin"
L["LOOT_TRACKER_OPEN"] = "Ouvrir le Suivi du butin"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d secondes"
L["LOOT_MASTER_MINUTES"] = "%d minutes"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Appel des jets"
L["LOOT_MASTER_ROLL_LENGTH"] = "Durée du jet"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Combien de temps un jet reste ouvert."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Annoncer dans"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Où vont les appels aux jets, les égalités et les pauses."
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"L'avertissement raid bascule sur le canal de groupe quand vous n'êtes ni chef ni assistant. Les gagnants sont toujours annoncés dans le canal de groupe."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Prévenir à %d secondes de la fin"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Prévient le groupe quand un jet est sur le point de se clore."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Ajouter %d secondes en cas de jet tardif"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Un jet dans les dernières secondes garde le jet ouvert un peu plus longtemps, pour que personne ne soit pénalisé par la latence."
L["LOOT_MASTER_END_EARLY"] = "Clore plus tôt quand tout le monde a lancé ou passé"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] =
	'Clôt le jet dès que chaque membre du groupe a lancé les dés ou tapé "passer".'
L["LOOT_MASTER_REROLL_TIES"] = "Départager les joueurs à égalité"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Lance aussitôt un départage pour les joueurs à égalité. Désactivé, une égalité attend que vous appuyiez sur Départager."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pause entre les objets en Jets en chaîne"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] =
	"Combien de temps Jets en chaîne attend après un jet avant d'appeler le suivant."

L["LOOT_MASTER_COUNTING_HEADER"] = "Jets qui comptent"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Un simple /roll (1-100), le premier de chaque joueur, venant de votre groupe, pendant que le jet est ouvert (%d seconde de tolérance pour la latence). Les jets qui ne comptent pas restent dans la liste avec leur raison."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Annoncer les jets qui ne comptent pas"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Liste en une ligne les jets qui n'ont pas compté, et pourquoi, à la clôture du jet. Un jet que vous disqualifiez est toujours annoncé."

L["LOOT_MASTER_TRADE_HEADER"] = "Butin échangeable"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Ouvrir quand je ramasse un objet échangeable"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Ouvre le Maître du butin quand un butin Lié quand ramassé encore échangeable arrive dans vos sacs alors que vous êtes en groupe."
L["LOOT_MASTER_TRADE_WARN"] = "Me prévenir quand le délai d'échange s'épuise"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Vous prévient une fois, dans la discussion, quand un objet de la Liste des jets est sur le point de devenir lié."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "Le délai d'échange restant au moment de l'alerte."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Placer les objets gagnés dans la fenêtre d'échange"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"Quand vous ouvrez un échange avec un gagnant, ce qu'il a gagné y est placé pour vous. Vous appuyez toujours vous-même sur Échanger."

L["LOOT_MASTER_FLOOR_HEADER"] = "Butin au sol"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"Le Butin au sol démarre vide et ne contient que ce que vous ajoutez. Ajouter depuis les sacs liste d'abord ce que vous avez ramassé dans cette instance."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Retirer les objets quand ils quittent mes sacs"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Retire un objet du Butin au sol quand il ne vous en reste plus : échangé, vendu ou utilisé."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Vider le Butin au sol quand je quitte le raid"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Commence chaque raid avec une liste Butin au sol vide."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Ouvrir quand quelqu'un appelle aux jets"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Ouvre le Suivi du butin quand quelqu'un de votre groupe appelle aux jets, avec GogoLoot ou un avertissement raid."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Se fermer à la fin du jet"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Un Suivi du butin ouvert tout seul se ferme 30 secondes après la fin du jet, sauf si votre souris est dessus."
L["LOOT_TRACKER_KEEP_DROPS"] = "Raids conservés dans Butin"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "Combien de raids l'onglet Butin garde en mémoire."
