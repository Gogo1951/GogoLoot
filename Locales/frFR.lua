local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "frFR")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent sous Options > AddOns > GogoLoot. Vous aimez l'add-on ? Parlez-en à un ami ! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "La fouille automatique est requise pour que GogoLoot fonctionne correctement. La fouille automatique a été activée."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Vous n'êtes actuellement pas le Maître du butin."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "A donné %s à %s."
L["MESSAGE_DESTINATION_SET"] = "%s recevra tous les objets %s."
L["MESSAGE_DESTINATION_LEFT"] = "%s a quitté le groupe. %s recevra désormais tous les objets %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "A donné %s à %s, reçu %s."
L["MESSAGE_TRADE_GAVE"] = "A donné %s à %s."
L["MESSAGE_TRADE_RECEIVED"] = "Reçu %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Le joueur sélectionné pour recevoir cet objet n'a plus de place dans ses sacs."
L["ERROR_MAX_COUNT"] = "Le joueur sélectionné pour recevoir cet objet en possède déjà trop."
L["ERROR_OUT_OF_RANGE"] = "Le joueur sélectionné pour recevoir cet objet est hors de portée."
L["ERROR_NOT_IN_GROUP"] = "Le joueur sélectionné pour recevoir cet objet n'est plus dans le groupe ou le raid."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Maître du butin"
L["TAB_AUTOMATED_ROLLS"] = "Jets Automatiques"
L["TAB_ANNOUNCEMENTS"] = "Annonces"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Activé"
L["STATUS_DISABLED"] = "Désactivé"

L["MINIMAP_AUTO_GREED"] = "Cupidité Auto"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Effectue automatiquement un jet de Cupidité sur les objets éligibles au niveau ou en dessous du seuil de qualité sélectionné."
L["MINIMAP_SPEEDY_LOOT"] = "Butin Rapide"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Ramasse instantanément le butin sans afficher la fenêtre de butin."

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
L["ROLL_MANUAL"] = "Jet manuel"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Chargement... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Version"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Amassez l'équipement avec le Maître du butin automatisé, effectuez automatiquement des jets de besoin ou de cupidité sur les butins non liés quand ramassés, et annoncez chaque échange dans la discussion en toute transparence. Les objets de quête, recettes, monturas, mascottes et objets légendaires sont toujours en sécurité. Ne laissez pas le butin ralentir votre zug !"
L["WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["MINIMAP_BUTTON_ENABLE"] = "Activer le bouton de la minicarte"

L["COMMANDS"] = "/Commandes"
L["COMMANDS_DESCRIPTION"] = "Ouvre l'interface des options de GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Butin Rapide"
L["SPEEDY_LOOT_DESCRIPTION"] = "Ramasse instantanément le butin sans afficher la fenêtre de butin, gagnant du temps entre les éliminations."
L["SPEEDY_LOOT_ENABLE"] = "Activer le Butin Rapide"

L["FEEDBACK_SUPPORT"] = "Retours & Assistance"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Réinitialiser tous les profils"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Réinitialise chaque profil de ce compte à ses paramètres par défaut."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "Ceci réinitialisera TOUS les profils de votre compte aux paramètres par défaut — chaque personnage. Il n'y a pas d'annulation possible. Continuer ?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "La méthode et le seuil de butin actuels de votre groupe."
L["MASTER_LOOTER_LOOT_TYPE"] = "Type de Butin"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Seuil de Butin"
L["MASTER_LOOTER_SET_BY"] = "(Défini par %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Seul le chef de groupe peut modifier la méthode et le seuil de butin."

L["MASTER_LOOTER_AUTO_HEADER"] = "Maître du Butin Automatisé"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribue automatiquement le butin aux joueurs désignés lorsque vous êtes le Maître du butin. Les objets de quête, livres, recettes, montures, mascottes et légendaires sont toujours ignorés et apparaîtront dans une fenêtre de butin standard."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activer le Maître du Butin Automatique en Instance"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Activar le Maître du Butin Automatique hors des Instances"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Attention : Le butin des boss en extérieur n'étant pas échangeable, ceci n'est pas conseillé !"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinations du Butin"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Assignez un membre du groupe pour recevoir les objets de chaque niveau de qualité."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Soi-même"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Choisissez qui reçoit les objets %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Liste d'Ignorés"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Les objets de cette liste ne seront pas automatiquement distribués et apparaîtront dans une fenêtre de butin standard pour une assignation manuelle."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurer la Liste d'Ignorés par Défaut"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Cela remplacera votre liste d'ignorés du maître du butin par les objets par défaut de votre extension. Continuer ?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Entrez l'ID d'un objet ou collez un lien d'objet pour l'ajouter à la liste d'ignorés."
L["MASTER_LOOTER_IGNORE_ADD"] = "Ajouter un objet"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Retirer"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Retirer cet objet de la liste d'ignorés."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Effectue automatiquement un jet de Cupidité sur les objets non liés quand ramassés (LQE) de qualité égale ou inférieure à celle sélectionnée. Les objets de quête, livres, recettes, montures, mascottes et objets légendaires sont toujours ignorés."
L["ROLLS_ENABLE"] = "Activer les Jets Automatiques"
L["ROLLS_THRESHOLD"] = "Seuil de Cupidité Automatique"

L["ROLLS_CUSTOM_LIST"] = "Liste de Jets Personnalisés"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Les objets de cette liste ont leur propre règle de jet qui l'emporte sur le seuil."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Activer la Liste de jets personnalisés"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar la Liste de Jets Personnalisés par Défaut"
L["ROLLS_RESTORE_CONFIRM"] = "Cela remplacera votre liste de jets personnalisés par les objets par défaut de votre extension. Continuer ?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Entrez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste."
L["ROLLS_ADD_ITEM"] = "Ajouter un objet"
L["ROLLS_CHOOSE_ACTION"] = "Choisissez l'action de jet automatique pour cet objet."
L["ROLLS_REMOVE"] = "Retirer"
L["ROLLS_REMOVE_DESCRIPTION"] = "Retirer cet objet de la liste de jets personnalisés."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Annonces d'Échange"
L["TRADE_DESCRIPTION"] = "Publie automatiquement un résumé des échanges terminés dans la discussion, y compris les objets, enchantements et pièces d'or échangés."
L["TRADE_ENABLE"] = "Activer les Annonces d'Échange"
L["TRADE_CONDITION"] = "Quand"
L["TRADE_CONDITION_ALWAYS"] = "Toujours"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Seulement en Groupe ou Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "Seulement en Raid"
L["TRADE_OUTPUT"] = "Sortie des Messages"
L["TRADE_OUTPUT_WHISPER"] = "Chuchotement"
L["TRADE_OUTPUT_GROUP"] = "Canal Groupe"
L["TRADE_EXAMPLE"] = "Exemple : {rt4} A donné [Objet X] x2, [Objet Y] à Fathom. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publie un résumé dans la discussion lorsque cet échange est terminé."
L["TRADE_TOOLTIP_OUTPUT"] = "Sortie actuelle"
L["TRADE_CHECKBOX_LABEL"] = "Annoncer"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Publie l'activité du maître du butin dans la discussion de groupe pour plus de transparence. Les distributions automáticas utilisent un seuil de qualité pour éviter le spam ; les distributions manuelles sont toujours annoncées."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activer les messages lorsque le Maître du Butin est défini"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Exemple : {rt4} GogoLoot // Aevala recevra tous les objets Épiques."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activer les Annonces Automatiques du Maître du Butin"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Seuil d'Annonce Automatique"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Exemple : {rt4} GogoLoot // A donné [Objet X] à Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note : Chaque objet distribué manuellement est toujours annoncé, quelle que soit sa qualité."
