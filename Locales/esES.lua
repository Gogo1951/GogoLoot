local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esES") or LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esMX")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Se han restablecido los ajustes para esta actualización. Usa /gl para revisar tus opciones."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "Todos los ajustes han sido restablecidos a sus valores predeterminados."
L["MSG_CONFLICT_DETECTED"] = "Se detectaron addons de botín conflictivos."
L["MSG_CONFLICT_ADDON"] = "Addon en conflicto: %s"
L["MSG_AUTO_LOOT_ENABLED"] = "El despojo automático es necesario para que GogoLoot funcione correctamente. Se ha activado el despojo automático."
L["MSG_NOT_MASTER_LOOTER"] = "Actualmente no eres el Maestro Despojador."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Activado"
L["STATUS_DISABLED"] = "Desactivado"

L["MINIMAP_AUTO_GREED"] = "Codicia Automática"
L["MINIMAP_AUTO_GREED_DESC"] = "Tira automáticamente Codicia por los objetos elegibles de calidad igual o inferior al umbral seleccionado."
L["MINIMAP_SPEEDY_LOOT"] = "Despojo Rápido"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "Recoge el botín al instante sin mostrar la ventana de despojo."

L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_HINT"] = "Puedes encontrar ajustes adicionales en Opciones > AddOns > GogoLoot."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Pobre"
L["QUALITY_COMMON"] = "Común"
L["QUALITY_UNCOMMON"] = "Poco común"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Épico"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Tirada Manual"
L["ROLL_GREED"] = "Codicia"
L["ROLL_NEED"] = "Necesidad"
L["ROLL_PASS"] = "Pasar"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Libre para todos"
L["LOOT_METHOD_ROUND_ROBIN"] = "Por turnos"
L["LOOT_METHOD_MASTER"] = "Maestro despojador"
L["LOOT_METHOD_GROUP"] = "Botín de grupo"
L["LOOT_METHOD_NBG"] = "Necesidad antes que codicia"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Solo Pobre"
L["THRESHOLD_COMMON_LOWER"] = "Común y Menor"
L["THRESHOLD_UNCOMMON_LOWER"] = "Poco común y Menor"
L["THRESHOLD_RARE_LOWER"] = "Raro y Menor"
L["THRESHOLD_EPIC_LOWER"] = "Épico y Menor"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "General"
L["GENERAL_DESC"] = "Ajustes básicos que se aplican siempre que GogoLoot está activo."
L["SPEEDY_LOOT"] = "Activar Despojo Rápido"
L["SPEEDY_LOOT_DESC"] = "Recoge el botín al instante sin mostrar la ventana de despojo, ahorrando tiempo entre muertes."

L["COMMANDS"] = "/Comandos"
L["COMMANDS_DESC_GL"] = "Abre la interfaz de opciones de GogoLoot."
L["COMMANDS_DESC_GOGOLOOT"] = "Abre la interfaz de opciones de GogoLoot."

L["RESET"] = "Restablecer"
L["RESET_DESC"] = "Borra todos los ajustes de GogoLoot y restaura cada opción a su valor predeterminado."
L["RESET_ALL"] = "Restablecer todas las opciones de GogoLoot"
L["RESET_CONFIRM"] = "Esto restablecerá TODOS los ajustes de GogoLoot a sus valores predeterminados. Esto no se puede deshacer. ¿Continuar?"

L["FEEDBACK_SUPPORT"] = "Comentarios y Soporte"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Cargando... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "Publica automáticamente en el chat un resumen de los intercambios completados, incluyendo objetos, encantamientos y oro intercambiado."
L["TRADE_ENABLE"] = "Activar Anuncios de Intercambio"
L["TRADE_ENABLE_DESC"] = "Publica un resumen del intercambio cuando este se completa."
L["TRADE_CONDITION"] = "Al estar en grupo"
L["TRADE_CONDITION_DESC"] = "Controla cuándo están activos los anuncios de intercambio."
L["TRADE_CONDITION_ALWAYS"] = "Siempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo en Grupo o Banda"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo en Banda"
L["TRADE_OUTPUT"] = "Salida del Mensaje"
L["TRADE_OUTPUT_DESC"] = "Dónde se envía el resumen del intercambio."
L["TRADE_OUTPUT_WHISPER"] = "Susurro"
L["TRADE_OUTPUT_GROUP"] = "Chat de Grupo"
L["TRADE_OUTPUT_RAID"] = "Chat de Banda"
L["TRADE_EXAMPLE"] = "Ejemplo: {rt4} Entregó [Objeto X] x2, [Objeto Y] a Fathom. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Anuncios de Intercambio"
L["TRADE_TOOLTIP_DESC"] = "Publica un resumen en el chat cuando este intercambio se completa."
L["TRADE_TOOLTIP_OUTPUT"] = "Salida actual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Tira automáticamente Codicia por los objetos que no se ligan al recogerlos de calidad igual o inferior a la seleccionada. Los objetos de misión, libros, recetas, monturas, mascotas y legendarios siempre se omiten. Los objetos que se ligan al recogerlos nunca se tiran automáticamente por el umbral, pero pueden automatizarse a través de la Lista de Tirada Personalizada a continuación."
L["ROLLS_ENABLE"] = "Activar Tiradas Automáticas"
L["ROLLS_ENABLE_DESC"] = "Tira automáticamente Codicia por los objetos elegibles de calidad igual o inferior al umbral."
L["ROLLS_THRESHOLD"] = "Umbral de Codicia Automática"
L["ROLLS_THRESHOLD_DESC"] = "Se tirará Codicia automáticamente por los objetos de esta calidad o inferior."

L["ROLLS_CUSTOM_LIST"] = "Lista de Tirada Personalizada"
L["ROLLS_CUSTOM_LIST_DESC"] = "Los objetos de esta lista tienen su propia regla de tirada que anula el umbral. Esta es la única forma de automatizar objetos que se ligan al recogerlos como las Piedras de la Plaga o Runas demoníacas. Establece cada objeto en Tirada Manual, Codicia, Necesidad o Pasar. Los objetos de misión, libros, recetas, monturas, mascotas y legendarios siempre se omiten independientemente de la configuración."
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Tirada Personalizada Predeterminada"
L["ROLLS_RESTORE_CONFIRM"] = "Esto reemplazará tu lista de tirada personalizada con los objetos predeterminados para tu expansión. ¿Continuar?"
L["ROLLS_ADD_ITEM_DESC"] = "Introduce el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."
L["ROLLS_ADD_ITEM"] = "Añadir Objeto"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Introduce el ID del objeto o arrastra el enlace del objeto aquí."
L["ROLLS_CHOOSE_ACTION"] = "Elige la acción de tirada automática para este objeto."
L["ROLLS_REMOVE"] = "Eliminar"
L["ROLLS_REMOVE_DESC"] = "Elimina este objeto de la lista de tirada personalizada."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Tipo de Botín (solo lectura, cambiar en el Menú del Juego)"
L["ML_LOOT_THRESHOLD"] = "Umbral de Botín (solo lectura, cambiar en el Menú del Juego)"

L["ML_AUTO_HEADER"] = "Maestro Despojador Automático"
L["ML_AUTO_DESC"] = "Distribuye automáticamente el botín a los jugadores designados cuando eres el Maestro Despojador. Los objetos de misión, libros, recetas, monturas, mascotas y legendarios siempre se omiten y aparecerán en la ventana de botín estándar."
L["ML_AUTO_ENABLE"] = "Activar Maestro Despojador Automático en Estancias"
L["ML_AUTO_ENABLE_DESC"] = "Distribuye el botín a los destinos configurados de forma automática."
L["ML_AUTO_OUTSIDE"] = "Activar Maestro Despojador Automático fuera de Estancias"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Precaución: Debido a que el botín de los jefes de mundo no es intercambiable, ¡esto no es recomendable!"

L["ML_DEST_HEADER"] = "Destinos del Botín"
L["ML_DEST_DESC"] = "Asigna a un miembro del grupo para que reciba los objetos de cada nivel de calidad."
L["ML_DEST_SELF"] = "A mí mismo"
L["ML_DEST_CHOOSE"] = "Elige quién recibe los objetos de calidad %s."

L["ML_ANNOUNCE_HEADER"] = "Anuncios de Botín"
L["ML_ANNOUNCE_DESC"] = "Publica un mensaje en el chat de grupo cuando los objetos se distribuyen a través del Maestro Despojador. Las distribuciones manuales siempre se anuncian independientemente del umbral."
L["ML_ANNOUNCE_ENABLE"] = "Activar Anuncios de Botín"
L["ML_ANNOUNCE_ENABLE_DESC"] = "Anuncia las distribuciones de objetos en el chat de grupo."
L["ML_ANNOUNCE_THRESHOLD"] = "Umbral de Anuncio"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "Anuncia solo objetos de esta calidad o superior."
L["ML_ANNOUNCE_EXAMPLE"] = "Ejemplo: {rt4} Entregó [Objeto X] a Gogowarrior. // GogoLoot"

L["ML_IGNORE_HEADER"] = "Lista de Ignorados"
L["ML_IGNORE_DESC"] = "Los objetos de esta lista no se distribuirán automáticamente y aparecerán en la ventana de botín estándar para su asignación manual."
L["ML_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Predeterminada"
L["ML_IGNORE_RESTORE_CONFIRM"] = "Esto reemplazará tu lista de ignorados del maestro despojador con los objetos predeterminados para tu expansión. ¿Continuar?"
L["ML_IGNORE_ADD_DESC"] = "Introduce el ID de un objeto o pega un enlace de objeto para añadirlo a la lista de ignorados."
L["ML_IGNORE_ADD"] = "Añadir Objeto"
L["ML_IGNORE_ADD_TOOLTIP"] = "Introduce el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."
L["ML_IGNORE_REMOVE"] = "Eliminar"
L["ML_IGNORE_REMOVE_DESC"] = "Elimina este objeto de la lista de ignorados."