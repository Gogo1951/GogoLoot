local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "frFR")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages (printed to local chat frame via PrintMessage)
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Les paramètres ont été réinitialisés pour cette mise à jour. Utilisez /gl pour vérifier vos options."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "Tous les paramètres ont été réinitialisés par défaut."
L["MSG_AUTO_LOOT_ENABLED"] = "La fouille automatique est requise pour que GogoLoot fonctionne correctement. La fouille automatique a été activée."
L["MSG_NOT_MASTER_LOOTER"] = "Vous n'êtes actuellement pas le Maître du butin."

--------------------------------------------------------------------------------
-- Chat Announcement Templates (sent to other players via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["MSG_PREFIX"] = "{rt4} "
L["MSG_SUFFIX"] = " // GogoLoot"

L["MSG_LOOT_ANNOUNCE"] = "A donné %s à %s."
L["MSG_DESTINATION_SET"] = "%s recevra tous les objets %s."
L["MSG_DESTINATION_LEFT"] = "%s a quitté le groupe. %s recevra désormais tous les objets %s."

L["MSG_TRADE_GAVE_RECEIVED"] = "A donné %s à %s, reçu %s."
L["MSG_TRADE_GAVE"] = "A donné %s à %s."
L["MSG_TRADE_RECEIVED"] = "Reçu %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors (sent to group via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["ERR_BAG_FULL"] = "Le joueur sélectionné pour recevoir cet objet n'a plus de place dans ses sacs."
L["ERR_MAX_COUNT"] = "Le joueur sélectionné pour recevoir cet objet en possède déjà trop."
L["ERR_OUT_OF_RANGE"] = "Le joueur sélectionné pour recevoir cet objet est hors de portée."
L["ERR_NOT_IN_GROUP"] = "Le joueur sélectionné pour recevoir cet objet n'est plus dans le groupe ou le raid."

--------------------------------------------------------------------------------
-- Options Panel Tab Names
--------------------------------------------------------------------------------

L["TAB_GENERAL"] = "GogoLoot"
L["TAB_AUTOMATED_ROLLS"] = "Jets Automatiques"
L["TAB_MASTER_LOOTER"] = "Maître du butin"
L["TAB_TRADE_ANNOUNCEMENTS"] = "Annonces"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Activé"
L["STATUS_DISABLED"] = "Désactivé"

L["MINIMAP_AUTO_GREED"] = "Cupidité Auto"
L["MINIMAP_AUTO_GREED_DESC"] = "Effectue automatiquement un jet de Cupidité sur les objets éligibles au niveau ou en dessous du seuil de qualité sélectionné."
L["MINIMAP_SPEEDY_LOOT"] = "Butin Rapide"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "Ramasse instantanément le butin sans afficher la fenêtre de butin."

L["MINIMAP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_TOGGLE"] = "Basculer"
L["MINIMAP_HINT"] = "Des paramètres supplémentaires se trouvent dans Options > AddOns > GogoLoot."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Médiocre"
L["QUALITY_COMMON"] = "Commun"
L["QUALITY_UNCOMMON"] = "Inhabituel"
L["QUALITY_RARE"] = "Rare"
L["QUALITY_EPIC"] = "Épique"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Jet manuel"
L["ROLL_GREED"] = "Cupidité"
L["ROLL_NEED"] = "Besoin"
L["ROLL_PASS"] = "Passer"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Accès libre"
L["LOOT_METHOD_ROUND_ROBIN"] = "Chacun son tour"
L["LOOT_METHOD_MASTER"] = "Maître du butin"
L["LOOT_METHOD_GROUP"] = "Butin de groupe"
L["LOOT_METHOD_NBG"] = "Le besoin avant la cupidité"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Médiocre uniquement"
L["THRESHOLD_COMMON_LOWER"] = "Commun & Inférieur"
L["THRESHOLD_UNCOMMON_LOWER"] = "Inhabituel & Inférieur"
L["THRESHOLD_RARE_LOWER"] = "Rare & Inférieur"
L["THRESHOLD_EPIC_LOWER"] = "Épique & Inférieur"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "Général"
L["GENERAL_DESC"] = "Paramètres de base s'appliquant chaque fois que GogoLoot est actif."
L["SPEEDY_LOOT"] = "Activer le Butin Rapide"
L["SPEEDY_LOOT_DESC"] = "Ramasse instantanément le butin sans afficher la fenêtre de butin, gagnant du temps entre les éliminations."

L["COMMANDS"] = "/Commandes"
L["COMMANDS_DESC"] = "Ouvre l'interface des options de GogoLoot."

L["RESET"] = "Réinitialiser"
L["RESET_DESC"] = "Efface tous les paramètres de GogoLoot et restaure la valeur par défaut de chaque option."
L["RESET_ALL"] = "Réinitialiser toutes les options GogoLoot"
L["RESET_CONFIRM"] = "Cela réinitialisera TOUS les paramètres de GogoLoot par défaut. Cette action est irréversible. Continuer ?"

L["FEEDBACK_SUPPORT"] = "Retours & Assistance"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Chargement... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements

L["TRADE_HEADER"] = "Annonces d'Échange"
L["TRADE_DESC"] = "Publie automatiquement un résumé des échanges terminés dans la discussion, y compris les objets, enchantements et pièces d'or échangés."
L["TRADE_ENABLE"] = "Activer les Annonces d'Échange"
L["TRADE_ENABLE_DESC"] = "Publie un résumé d'échange lorsqu'un échange est terminé."
L["TRADE_CONDITION"] = "Lorsqu'en Groupe"
L["TRADE_CONDITION_DESC"] = "Contrôle l'activation des annonces d'échange."
L["TRADE_CONDITION_ALWAYS"] = "Toujours"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Seulement en Groupe ou Raid"
L["TRADE_CONDITION_RAID_ONLY"] = "Seulement en Raid"
L["TRADE_OUTPUT"] = "Sortie des Messages"
L["TRADE_OUTPUT_DESC"] = "Où le résumé de l'échange est envoyé."
L["TRADE_OUTPUT_WHISPER"] = "Chuchotement"
L["TRADE_OUTPUT_GROUP"] = "Canal Groupe"
L["TRADE_OUTPUT_RAID"] = "Discussion Raid"
L["TRADE_EXAMPLE"] = "Exemple : {rt4} A donné [Objet X] x2, [Objet Y] à Fathom. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Annonces d'Échange"
L["TRADE_TOOLTIP_DESC"] = "Publie un résumé dans la discussion lorsque cet échange est terminé."
L["TRADE_TOOLTIP_OUTPUT"] = "Sortie actuelle"
L["TRADE_CHECKBOX_LABEL"] = "Annoncer"

-- Master Looter Announcements

L["ML_ANNOUNCE_HEADER"] = "Annonces du Maître du Butin"
L["ML_ANNOUNCE_DESC"] = "Publie l'activité du maître du butin dans la discussion de groupe pour plus de transparence. Configurez des seuils séparés pour les distributions automatiques et manuelles afin que le butin automatique routinier ne spamme pas la discussion, tout en gardant les écarts manuels visibles."

L["ML_ANNOUNCE_DESTINATION"] = "Activer les messages lorsque le Maître du Butin est défini"
L["ML_ANNOUNCE_DESTINATION_DESC"] = "Annonce lorsque les destinations de butin sont configurées, et lorsqu'un joueur de destination quitte le groupe."
L["ML_ANNOUNCE_DESTINATION_EXAMPLE"] = "Exemple : {rt4} Aevala recevra tous les objets Épiques. // GogoLoot"

L["ML_ANNOUNCE_AUTO"] = "Activer les Annonces Automatiques du Maître du Butin"
L["ML_ANNOUNCE_AUTO_DESC"] = "Annonce les objets distribués automatiquement par GogoLoot."
L["ML_ANNOUNCE_AUTO_THRESHOLD"] = "Seuil d'Annonce Automatique"
L["ML_ANNOUNCE_AUTO_THRESHOLD_DESC"] = "N'annoncez que les distributions automatiques de cette qualité ou supérieure."

L["ML_ANNOUNCE_MANUAL"] = "Activer les Annonces Manuelles du Maître du Butin"
L["ML_ANNOUNCE_MANUAL_DESC"] = "Annonce les objets distribués manuellement via le menu déroulant. Par défaut inférieur à l'automatique pour que les écarts par rapport aux règles configurées soient visibles pour le groupe."
L["ML_ANNOUNCE_MANUAL_THRESHOLD"] = "Seuil d'Annonce Manuelle"
L["ML_ANNOUNCE_MANUAL_THRESHOLD_DESC"] = "N'annoncez que les distributions manuelles de cette qualité ou supérieure."

L["ML_ANNOUNCE_EXAMPLE"] = "Exemple : {rt4} A donné [Objet X] à Gogowarrior. // GogoLoot"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Effectue automatiquement un jet de Cupidité sur les objets non liés quand ramassés (LQE) de qualité égale ou inférieure à celle sélectionnée. Les objets de quête, livres, recettes, montures, mascottes et objets légendaires sont toujours ignorés. Les objets liés quand ramassés (LQR) ne sont jamais automatiquement tirés en Cupidité par le seuil, mais peuvent être automatisés via la Liste de Jets Personnalisés ci-dessous."
L["ROLLS_ENABLE"] = "Activer les Jets Automatiques"
L["ROLLS_ENABLE_DESC"] = "Effectue automatiquement un jet de Cupidité sur les objets éligibles au niveau ou en dessous du seuil."
L["ROLLS_THRESHOLD"] = "Seuil de Cupidité Automatique"
L["ROLLS_THRESHOLD_DESC"] = "Les objets de cette qualité ou inférieure seront automatiquement tirés en Cupidité."

L["ROLLS_CUSTOM_LIST"] = "Liste de Jets Personnalisés"
L["ROLLS_CUSTOM_LIST_DESC"] = "Les objets de cette liste ont leur propre règle de jet qui l'emporte sur le seuil. C'est le seul moyen d'automatiser les objets liés quand ramassés comme les Pierres du Fléau ou les Runes démoniaques. Réglez chaque objet sur Jet Manuel, Cupidité, Besoin ou Passer. Les objets de quête, livres, recettes, montures, mascottes et légendaires sont toujours ignorés quels que soient les paramètres."
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar la Liste de Jets Personnalisés par Défaut"
L["ROLLS_RESTORE_CONFIRM"] = "Cela remplacera votre liste de jets personnalisés par les objets par défaut de votre extension. Continuer ?"
L["ROLLS_ADD_ITEM_DESC"] = "Entrez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste."
L["ROLLS_ADD_ITEM"] = "Ajouter un objet"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Entrez l'ID de l'objet ou faites glisser un lien d'objet ici."
L["ROLLS_CHOOSE_ACTION"] = "Choisissez l'action de jet automatique pour cet objet."
L["ROLLS_REMOVE"] = "Retirer"
L["ROLLS_REMOVE_DESC"] = "Retirer cet objet de la liste de jets personnalisés."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Type de Butin (lecture seule, modifiez via le Menu de Jeu)"
L["ML_LOOT_THRESHOLD"] = "Seuil de Butin (lecture seule, modifiez via le Menu de Jeu)"

L["ML_AUTO_HEADER"] = "Maître du Butin Automatisé"
L["ML_AUTO_DESC"] = "Distribue automatiquement le butin aux joueurs désignés lorsque vous êtes le Maître du butin. Les objets de quête, livres, recettes, montures, mascottes et légendaires sont toujours ignorés et apparaîtront dans une fenêtre de butin standard."
L["ML_AUTO_ENABLE"] = "Activer le Maître du Butin Automatique en Instance"
L["ML_AUTO_ENABLE_DESC"] = "Distribue automatiquement le butin aux destinations configurées."
L["ML_AUTO_OUTSIDE"] = "Activer le Maître du Butin Automatique hors des Instances"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Attention : Le butin des boss en extérieur n'étant pas échangeable, ceci n'est pas conseillé !"

L["ML_DEST_HEADER"] = "Destinations du Butin"
L["ML_DEST_DESC"] = "Assignez un membre du groupe pour recevoir les objets de chaque niveau de qualité."
L["ML_DEST_SELF"] = "Soi-même"
L["ML_DEST_CHOOSE"] = "Choisissez qui reçoit les objets %s."

L["ML_IGNORE_HEADER"] = "Liste d'Ignorés"
L["ML_IGNORE_DESC"] = "Les objets de cette liste ne seront pas automatiquement distribués et apparaîtront dans une fenêtre de butin standard pour une assignation manuelle."
L["ML_IGNORE_RESTORE"] = "Restaurer la Liste d'Ignorés par Défaut"
L["ML_IGNORE_RESTORE_CONFIRM"] = "Cela remplacera votre liste d'ignorés du maître du butin par les objets par défaut de votre extension. Continuer ?"
L["ML_IGNORE_ADD_DESC"] = "Entrez l'ID d'un objet ou collez un lien d'objet pour l'ajouter à la liste d'ignorés."
L["ML_IGNORE_ADD"] = "Ajouter un objet"
L["ML_IGNORE_ADD_TOOLTIP"] = "Entrez l'ID d'un objet ou faites glisser un objet ici pour l'ajouter à la liste."
L["ML_IGNORE_REMOVE"] = "Retirer"
L["ML_IGNORE_REMOVE_DESC"] = "Retirer cet objet de la liste d'ignorés."