local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "frFR")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names, the %s / %d
    placeholders, or the {rt4} raid marker — code and enUS.lua rely on them.
]]

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

-- Brands every print, sent message, options panel, and report. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent sous Options > AddOns > GogoLoot. Vous aimez l'add-on ? Parlez-en à un ami ! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Par précaution, l'interface des options ne peut pas être ouverte en combat."
L["MESSAGE_AUTO_LOOT_ENABLED"] =
	"La fouille automatique a été activée. Le Butin Rapide en a besoin pour fonctionner."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Vous n'êtes actuellement pas le Maître du butin."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "A donné %s à %s."
L["MESSAGE_DESTINATION_SET"] = "%s recevra tous les objets %s."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s gardera tout le butin pour le groupe."
L["MESSAGE_DESTINATION_LEFT"] = "%s a quitté le groupe. %s recevra désormais tous les objets %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "A donné %s à %s, reçu %s."
L["MESSAGE_TRADE_RECEIVED"] = "Reçu %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Les sacs de %s sont pleins : %s"
L["ERROR_MAX_COUNT"] = "%s possède déjà trop de : %s"
L["ERROR_OUT_OF_RANGE"] = "%s est hors de portée : %s"
L["ERROR_NOT_IN_GROUP"] = "%s n'est plus dans le groupe ou le raid : %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Impossible de donner à %s : %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Maître du butin"
L["TAB_AUTOMATED_ROLLS"] = "Jets Automatiques"
L["TAB_ANNOUNCEMENTS"] = "Annonces"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Activé"
L["STATUS_DISABLED"] = "Désactivé"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Lance les dés à ta place sur les objets éligibles jusqu'à la qualité choisie."

L["MINIMAP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_TOGGLE"] = "Basculer"
L["MINIMAP_OPTIONS"] = "Options de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Médiocre"
L["QUALITY_COMMON"] = "Commun"
L["QUALITY_UNCOMMON"] = "Inhabituel"
L["QUALITY_RARE"] = "Rare"
L["QUALITY_EPIC"] = "Épique"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Manuel"
L["ROLL_GREED"] = "Cupidité"
L["ROLL_NEED"] = "Besoin"
L["ROLL_PASS"] = "Passer"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Accès libre"
L["LOOT_METHOD_ROUND_ROBIN"] = "Chacun son tour"
L["LOOT_METHOD_MASTER"] = "Maître du butin"
L["LOOT_METHOD_GROUP"] = "Butin de groupe"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Le besoin avant la cupidité"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Médiocre uniquement"
L["THRESHOLD_COMMON_LOWER"] = "Commun & Inférieur"
L["THRESHOLD_UNCOMMON_LOWER"] = "Inhabituel & Inférieur"
L["THRESHOLD_RARE_LOWER"] = "Rare & Inférieur"
L["THRESHOLD_EPIC_LOWER"] = "Épique & Inférieur"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Ajouter un objet"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Entrez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Chargement... (ID: %d)"

-- Appended to both the Automated Master Looting and the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] =
	"Les objets de quête, recettes, livres, montures, mascottes et objets légendaires sont toujours ignorés."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "Version"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Aspirez l'équipement avec le Maître du Butin Automatisé, les Jets Automatiques et des Annonces transparentes. Les objets de quête, recettes, montures, mascottes et légendaires restent protégés. Ne laissez pas le butin ralentir votre zug !"
L["WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["MINIMAP_BUTTON_ENABLE"] = "Activer le bouton de la minicarte"

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

L["SPEEDY_LOOT_HEADER"] = "Butin Rapide"
L["SPEEDY_LOOT_DESCRIPTION"] = "Masque la fenêtre de butin pour un ramassage quasi instantané."
L["SPEEDY_LOOT_ENABLE"] = "Activer le Butin Rapide"

L["FEEDBACK_SUPPORT"] = "Retours & Assistance"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "La méthode et le seuil de butin actuels de votre groupe."
L["MASTER_LOOTER_LOOT_METHOD"] = "Méthode de Butin"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Seuil de Butin"
L["MASTER_LOOTER_SET_BY"] = "(Défini par %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Seul le chef de groupe peut modifier la méthode et le seuil de butin."

L["MASTER_LOOTER_AUTO_HEADER"] = "Maître du Butin Automatisé"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"Distribue le butin aux joueurs que vous désignez lorsque vous êtes Maître du butin."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activer le Maître du Butin Automatique en Instance"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Activer le Maître du Butin Automatique hors des Instances"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Attention : Le butin des boss en extérieur n'étant pas échangeable, ceci n'est pas conseillé !"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Réglages rapides"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] =
	"Ouvre une fenêtre pour configurer le butin dès que tu deviens Maître du butin."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Activer la fenêtre du Maître du butin"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinations du Butin"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Assignez un membre du groupe pour recevoir les objets de chaque niveau de qualité."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Soi-même"
L["MASTER_LOOTER_SEND_ALL"] = "Envoyer tout le butin à"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Envoie toutes les qualités à un seul joueur. Ajuste les qualités individuelles ci-dessous pour outrepasser ce choix."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Choisissez qui reçoit les objets %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Liste d'Ignorés"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Les objets listés ignorent la distribution automatique et restent à assigner manuellement."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurer la Liste d'Ignorés par Défaut"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Cela remplacera votre liste d'ignorés du maître du butin par les objets par défaut de votre extension. Continuer ?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Retirer cet objet de la liste d'ignorés."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Lance les dés à votre place sur les objets non liés quand ramassés jusqu'à la qualité choisie, en groupe comme en raid."
L["ROLLS_ENABLE"] = "Activer les Jets Automatiques"
L["ROLLS_THRESHOLD_HEADER"] = "Seuils"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Choisis la limite de qualité et le jet que GogoLoot effectue pour toi, séparément en groupe et en raid."
L["ROLLS_IN_PARTY"] = "En groupe"
L["ROLLS_IN_RAID"] = "En raid"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s : lance automatiquement les dés sur les objets de cette qualité et inférieure."
L["ROLLS_ACTION_CHOOSE"] = "%s : quel jet GogoLoot effectue pour toi, ou s'il te laisse lancer les dés."

L["ROLLS_CUSTOM_LIST"] = "Liste de Jets Personnalisés"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] =
	"Les objets de cette liste ont leur propre règle de jet qui l'emporte sur le seuil."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Activer la Liste de jets personnalisés"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurer la Liste de Jets Personnalisés par Défaut"
L["ROLLS_RESTORE_CONFIRM"] =
	"Cela remplacera votre liste de jets personnalisés par les objets par défaut de votre extension. Continuer ?"
L["ROLLS_CHOOSE_ACTION"] = "Choisissez l'action de jet automatique pour cet objet."
L["ROLLS_REMOVE_DESCRIPTION"] = "Retirer cet objet de la liste de jets personnalisés."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Annonces d'Échange"
L["TRADE_DESCRIPTION"] = "Publie un résumé de chaque échange terminé : objets, enchantements et or."
L["TRADE_ENABLE"] = "Activer les Annonces d'Échange"
L["TRADE_CONDITION"] = "Quand"
L["TRADE_CONDITION_ALWAYS"] = "Toujours"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Seulement en Groupe ou Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "Seulement en Raid"
L["TRADE_OUTPUT"] = "Sortie des Messages"
L["TRADE_OUTPUT_WHISPER"] = "Chuchotement"
L["TRADE_OUTPUT_GROUP"] = "Canal Groupe"
L["TRADE_EXAMPLE"] = "Exemple : {rt4} GogoLoot // A donné [Objet X] x2, [Objet Y] à Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publie un résumé dans la discussion lorsque cet échange est terminé."
L["TRADE_TOOLTIP_OUTPUT"] = "Sortie actuelle"
L["TRADE_CHECKBOX_LABEL"] = "Annoncer"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Publie l'activité du maître du butin dans la discussion de groupe. Les distributions automatiques utilisent un seuil de qualité pour éviter le spam ; les distributions manuelles sont toujours annoncées."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activer les messages de destination du butin"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Exemple : {rt4} GogoLoot // Aevala recevra tous les objets Épiques."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activer les Annonces Automatiques du Maître du Butin"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Seuil d'Annonce Automatique"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Exemple : {rt4} GogoLoot // A donné [Objet X] à Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Note : Chaque objet distribué manuellement est toujours annoncé, quelle que soit sa qualité."
