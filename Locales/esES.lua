local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esES")
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
	"Versión %s. Encontrarás los ajustes (incluida la opción de desactivar este mensaje) en Opciones > Accesorios > GogoLoot. ¿Te gusta este accesorio? Recomiéndaselo a un amigo, márcalo como favorito en CurseForge o dale Star en GitHub. (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por seguridad, la ventana de opciones no se puede abrir en combate."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"Se ha activado la opción %s del juego, que necesitan Despojo rápido y Apertura automática."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Ahora mismo no eres el %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"Apertura automática está en pausa hasta que tengas al menos %d huecos libres en las bolsas."
L["MESSAGE_OPENING_RESUMED"] = "Apertura automática se ha reanudado."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s se abrirá automáticamente en cuanto se desbloquee."
L["MESSAGE_ITEM_IGNORED"] = "%s está en Ignorar, así que Apertura automática no lo tocará."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s viene de un jefe de banda o del mundo, así que Apertura automática lo dejará cerrado para que lo comercies o lo vendas."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s puede contener un objeto único, así que Apertura automática te lo deja para que lo abras tú."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s se ha quedado en la ventana de botín para que lo despojes tú."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"Se han desactivado %s y %s en tu pestaña de chat %s mientras Avisos de botín está activado."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "Se han vuelto a activar %s y %s en tu pestaña de chat %s."

-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s se equiparía en lugar de abrirse, así que no puede entrar en la Lista de contenedores."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Has elegido %s para %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Has dejado pasar %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s ha ganado %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s ha ganado %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Has ganado %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Has ganado %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Entregué %s a %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Entregué %s a %s, recibí %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Recibí %s de %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Entregué %s a %s"
L["MESSAGE_DESTINATION_SET"] = "%s guardará los objetos de calidad %s para el grupo"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s guardará todo el botín para el grupo"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s ha dejado el grupo. Ahora %s guardará los objetos de calidad %s para el grupo"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s ha dejado el grupo. Ahora %s guardará todo el botín para el grupo"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Entregué %s a %s, recibí %s"
L["MESSAGE_TRADE_RECEIVED"] = "Recibí %s de %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Las bolsas de %s están llenas: %s"
L["ERROR_MAX_COUNT"] = "%s ya tiene demasiados: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fuera de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s ya no está en el grupo ni en la banda: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "No se pudo entregar el botín a %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Despojo rápido"
L["TAB_AUTOMATED_ROLLS"] = "Tiradas automáticas"
L["TAB_ITEM_OVERRIDES"] = "Excepciones de objetos"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Reglas por personaje"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Anuncios de botín"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Anuncios de comercio"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Anuncios de maestro despojador"
L["TAB_LOOT_TOASTS"] = "Avisos de botín"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtros"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sonidos de botín"
L["TAB_AUTOMATED_OPENING"] = "Apertura automática"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Cajas fuertes"
L["TAB_OPENABLE_ITEMS"] = "Lista de contenedores"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "Reparto automático"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinos del botín"
L["TAB_IGNORE_LIST"] = "Lista de ignorados"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Macro de tirada"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Gestor de botín"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Activado"
L["STATUS_DISABLED"] = "Desactivado"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "En pausa"

--[[
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira por ti en los objetos elegibles hasta la calidad que elijas."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre almejas, cajones, monederos y cajas fuertes desbloqueadas de tus bolsas."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica en el chat los resúmenes de comercio y los repartos del maestro despojador."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "Reparte el botín a los jugadores que elegiste para cada calidad."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Mayús + clic izquierdo"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Mayús + clic derecho"
L["MINIMAP_TOGGLE"] = "Activar/desactivar"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Objetos bloqueados"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "Un %s puede forzarlos por ti."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "Usa %s para abrirlos."
L["MINIMAP_OPTIONS"] = "Opciones de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Mayús + clic central"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Botín comerciable"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "%d más"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Gestor de botín y Rastreador de botín"
L["MINIMAP_TO_HAND_OUT"] = "%d por repartir"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Sortea con tiradas lo que aún puedes comerciar y sigue cada tirada."
L["MINIMAP_MIDDLE_CLICK"] = "Clic central"
L["MINIMAP_OPEN"] = "Abrir"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Solo %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s o inferior"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
]]
L["ITEM_LIST_ADD"] = "Añadir objeto"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Escribe el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Suelta un objeto aquí o escribe su ID"
L["ITEM_LIST_ADD_BUTTON"] = "Añadir"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Muestra solo los objetos cuyo nombre, ID, ajuste o etiqueta contenga lo que escribas."
L["ITEM_LIST_NO_MATCHES"] = "Ningún objeto coincide con el filtro."
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"Esta lista está vacía, así que sus valores predeterminados volverán la próxima vez que entres en el juego. Restaurar predeterminados los recupera ahora."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Nuevos"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Mostrar todos los tipos de objeto"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Muestra todos los objetos de la lista, o solo los de un tipo."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Añadir desde las bolsas"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Añade a la lista un objeto que llevas encima."
L["ITEM_LIST_BAGS_EMPTY"] = "No hay nada en tus bolsas para añadir"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Todos los objetos que llevas ya están en la lista."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Restaurar predeterminados"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Cargando... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Nunca tira en recetas, libros, monturas, mascotas ni legendarios, y solo tira en objetos ligados al recogerlos o de misión si están en Excepciones de objetos."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Las recetas, libros, monturas, mascotas y legendarios siempre se quedan para ti."

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "Ejemplo: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"El Despojo rápido vacía los cadáveres sin ventana de botín, elige Necesidad, Codicia o Pasar según la calidad, y el Reparto automático entrega el botín por ti. Almejas, contenedores y cajas fuertes desbloqueadas se abren solos. Despoja más rápido, ataca antes."
L["WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Muestra la versión de GogoLoot y dónde encontrar estos ajustes cada vez que entras en el juego."
L["MINIMAP_BUTTON_ENABLE"] = "Activar botón del minimapa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Muestra el botón de GogoLoot en el minimapa. Clic izquierdo activa o desactiva Tiradas automáticas; clic derecho, Apertura automática; Mayús + clic izquierdo, Anuncios de botín; y Mayús + clic derecho, Reparto automático."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la ventana de opciones de este accesorio."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funciones"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Se lleva todo de un cadáver en cuanto lo abres, para que nunca tengas que esperar a la ventana de botín."
L["SPEEDY_LOOT_ENABLE"] = "Activar Despojo rápido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Vacía cada cadáver en cuanto lo abres, sin mostrar la ventana de botín. Mantén pulsado Mayús al despojar para ver la ventana. Activa la opción %s del juego y no actúa mientras eres %s."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Añade a tus Macros generales una macro llamada %s, con un icono de monedas de oro, para que todos los personajes de tu cuenta puedan arrastrarla a una barra de acción."
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Tirar 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Tirar 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Tirada de banda"
L["ROLL_MACRO_ENABLE"] = "Activar Macro de tirada"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Una tirada de banda entrega un objeto a alguien al azar. Tira del 1 al número de jugadores de tu grupo, así que cada número corresponde a un jugador: cuenta en tu lista de banda o de grupo hasta el número que salga para encontrar al ganador. Si estás solo, tira 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Mantiene la macro %s en tus Macros generales: clic izquierdo tira 1-100, clic derecho 1-99 y clic central hace una tirada de banda. Al desactivarlo, se borra."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "La macro %s está en tus Macros generales. Escribe %s y arrástrala a una barra de acción."
L["ROLL_MACRO_REMOVED"] = "Se ha borrado la macro %s."
L["ROLL_MACRO_FULL_LOADING"] =
	"No se pudo añadir la macro %s: tus Macros generales están llenas. Borra una y se añadirá tras la próxima pantalla de carga."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Ayuda a GogoLoot a subir de nivel"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Este accesorio lo han creado jugadores a los que les encanta este juego y que quieren hacerlo lo más divertido posible para todos. Nunca te pediremos donativos. La verdadera satisfacción es saber que nuestro trabajo te mejora un poco el juego. Si es así, ¡nos encantaría saberlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Estas son algunas formas de ayudarnos a llegar a más jugadores."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Danos tu opinión: ¿Has encontrado un error o tienes una idea? Cuéntanoslo en Discord. Tu opinión nos ayuda a mejorar el accesorio, y las contribuciones de código siempre son bienvenidas."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Cuéntaselo a un amigo: ¿Conoces a alguien a quien le pueda gustar este accesorio? Háblale de él. El boca a boca ayuda a que más jugadores descubran buenos accesorios."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorito en CurseForge: Abre el enlace de CurseForge de abajo, inicia sesión y haz clic en la estrella que hay bajo el botón Download. Los favoritos ayudan a que más jugadores descubran el accesorio."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star en GitHub: Abre el enlace de GitHub de abajo, inicia sesión y haz clic en Star, arriba a la derecha. Las estrellas ayudan a que el proyecto pueda optar a más herramientas gratuitas para desarrolladores."
L["OPTIONS_LEVEL_UP_THANKS"] = "¡Gracias por elegir GogoLoot!"

L["OPTIONS_FEEDBACK"] = "Comentarios y soporte"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Enlaces de opinión y ayuda"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Para copiar un enlace, haz clic en su casilla y pulsa Ctrl+A y Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Versión %s"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Ajustes de botín del grupo"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Decide cómo se reparte el botín de tu grupo. Solo el líder del grupo puede cambiarlo."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Fija la calidad mínima de objeto a la que se aplica el reparto de botín. Solo el líder del grupo puede cambiarla."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Estos ajustes los controla %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Únete a un grupo para cambiar estos ajustes. Solo el líder del grupo puede hacerlo."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Entrega cada objeto al jugador que elegiste para su calidad en cuanto abres la ventana de botín, mientras eres %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activar Reparto automático"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Activa o desactiva el reparto automático. Solo funciona dentro de mazmorras y bandas, salvo que actives También fuera de estancias."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "También fuera de estancias"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Reparte el botín también en el mundo abierto. El botín de los jefes del mundo no se puede comerciar, así que no se recomienda."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Incluir objetos de misión"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Reparte también los objetos de misión, para subir a un personaje que llevas tú mismo. Solo funciona con un límite de botín Común o inferior, y solo con objetos de misión que caen una vez para todo el grupo. No se recomienda en bandas."

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "Ajustes rápidos"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Abre estos ajustes en una ventana cada vez que pasas a ser %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Activar ventana de maestro despojador"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Elige quién recibe cada calidad. Una calidad sin nadie elegido se queda en la ventana de botín para ti."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Yo"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Ventana de botín"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar todo el botín a"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Asigna todas las calidades de abajo a un solo jugador."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Elige quién recibe los objetos de calidad %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Aún no hay nadie elegido, así que todo el botín espera en la ventana de botín para ti."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Los objetos de esta lista nunca se reparten automáticamente. Esperan en la ventana de botín para que los repartas tú."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] = "Estos ajustes no se usan mientras Reparto automático está desactivado."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Sustituye la Lista de ignorados por los objetos predeterminados de tu expansión."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"¿Sustituir tu Lista de ignorados por los objetos predeterminados de tu expansión?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Quita este objeto de la Lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Tira %s, %s o %s por ti en el botín de grupo, hasta la calidad que elijas, con ajustes distintos para grupos y bandas."
L["ROLLS_ENABLE"] = "Activar Tiradas automáticas"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Activa o desactiva las tiradas automáticas, incluidas Excepciones de objetos y Reglas por personaje."
L["ROLLS_IN_PARTY"] = "En grupo"
L["ROLLS_IN_RAID"] = "En banda"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Hasta la calidad"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: la calidad más alta en la que tira GogoLoot."
L["ROLLS_ACTION_CHOOSE"] = "%s: la tirada que hace GogoLoot. Manual te deja la tirada a ti."
-- Section headers on the Automated Rolls panel.
L["ROLLS_PARTY_AND_RAID_HEADER"] = "Tiradas en grupo y banda"
L["ROLLS_MESSAGES_HEADER"] = "Mensajes de tiradas"
L["ROLLS_PRINT_ITEM"] = "Mostrar objeto en el chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Muestra en tu chat cada objeto en el que tira GogoLoot y la tirada que hizo. La ventana de tirada se cierra en cuanto GogoLoot tira, así que este es tu registro de lo que salió."
L["ROLLS_HIDE_MESSAGES"] = "Ocultar mensajes de tiradas"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Oculta las líneas de chat del juego de cada tirada: quién eligió %s, %s o %s, y cada número obtenido. Lo que recibió cada ganador se queda en el chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Mostrar resumen del ganador"
L["ROLLS_WINNER_SUMMARY_NONE"] = "No mostrar resumen del ganador"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Mostrar resumen del ganador pone una línea en el chat por cada victoria, con el ganador, el objeto y la tirada ganadora, en lugar de la línea del propio juego. No mostrar resumen del ganador deja la línea del juego que dice quién ganó."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Fija la tirada de objetos concretos, por encima de los ajustes de calidad. Es la única forma de que GogoLoot tire en un objeto ligado al recogerlo o de misión."
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Estos ajustes no se usan mientras Tiradas automáticas está desactivado."
L["ITEM_OVERRIDES_ENABLE"] = "Activar Excepciones de objetos"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Usa las tiradas fijadas abajo. Si está desactivado, estos objetos siguen los ajustes de calidad como cualquier otro."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "Estas tiradas no se usan mientras Excepciones de objetos está desactivado."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Sustituye tus Excepciones de objetos por los objetos predeterminados de tu expansión."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"¿Sustituir tus Excepciones de objetos por los objetos predeterminados de tu expansión?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Fija la tirada automática para este objeto."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Quita este objeto de Excepciones de objetos."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "¿Quitar este objeto y su tirada de Excepciones de objetos?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"Escribe el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista con la opción Manual."

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Te deja a ti el equipo con los atributos que elijas, personaje a personaje: pon %s en Manual en tu %s, y el equipo con %s conserva su ventana de tirada mientras todo lo demás se tira como siempre. Excepciones de objetos sigue teniendo prioridad."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Atributos principales"
L["CHARACTER_RULES_SECONDARY"] = "Atributos secundarios"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Tirada automática estándar"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manual te deja a ti el equipo que lo tenga en este personaje, con su ventana de tirada incluida. Tirada automática estándar tira en él como en cualquier otro objeto."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica en el chat los resúmenes de comercio y los repartos del maestro despojador, para que todos sepan adónde fue el botín."
L["ANNOUNCEMENTS_ENABLE"] = "Activar Anuncios de botín"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Activa o desactiva todos los anuncios. Mientras esté desactivado, GogoLoot no envía nada a tu grupo ni a las personas con quienes comercias, ni siquiera los objetos que repartes tú."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Publica un resumen de cada comercio completado: objetos, encantamientos y oro."
L["TRADE_ENABLE"] = "Activar Anuncios de comercio"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Publica un resumen al completar un comercio. La casilla Anunciar de la ventana de comercio es este mismo interruptor."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Elige cuándo se publican los resúmenes de comercio: siempre, en grupo o banda, o solo en banda."
L["TRADE_CONDITION_ALWAYS"] = "Siempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "En grupo o banda"
L["TRADE_CONDITION_RAID_ONLY"] = "En banda"
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "Cuándo"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envía cada resumen a la persona con quien comercias. Chat de grupo lo publica en tu grupo o banda, y fuera de un grupo lo susurra igualmente. Solo yo lo muestra en tu propio chat y no lo envía a nadie."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Chat de grupo"
L["TRADE_OUTPUT_SELF"] = "Solo yo"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica un resumen del comercio en el chat cuando se complete."
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Dice a tu grupo quién guarda cada calidad y qué has repartido."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activar anuncios de destino"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Dice al grupo quién guarda cada calidad cada vez que fijas un destino."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activar anuncios de reparto automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Anuncia cada objeto que GogoLoot reparte automáticamente, de la calidad que elijas o superior."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Los repartos automáticos por debajo de esta calidad no se anuncian."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Activar anuncios de reparto manual"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Anuncia cada objeto que repartes tú desde el menú de %s, sea cual sea su calidad, con el mismo texto que un reparto automático. Un reparto fallido se notifica en cualquier caso."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Muestra en pantalla durante unos segundos cada objeto y moneda que despojas, para que no se te escape nada mientras Despojo rápido oculta la ventana de botín. Con los avisos activados, las líneas de botín del propio juego pueden dejar de aparecer en tu pestaña de chat %s."
L["LOOT_TOASTS_ENABLE"] = "Activar Avisos de botín"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = "Muestra un aviso para el botín que elijas en Filtros, el tuyo y el de tu grupo."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Desactivar mensajes de botín estándar"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Activar mensajes de botín estándar"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Desactivar apaga %s y %s en tu pestaña de chat %s mientras Avisos de botín está activado, y al desactivar Avisos de botín vuelven. Es la misma opción que en la Configuración de esa pestaña, y las demás pestañas conservan la suya."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Pila de avisos"
L["LOOT_TOASTS_TEXT_HEADER"] = "Texto"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "Estos ajustes no se usan mientras Avisos de botín está desactivado."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Elige qué recibe un aviso y qué dice, para tu propio botín y el de tu grupo. El botín de tu grupo muestra al lado el nombre de quien lo despoja."
L["LOOT_TOASTS_FILTER_MINE"] = "Mío"
L["LOOT_TOASTS_FILTER_GROUP"] = "Grupo"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Muestra los objetos de tipo %s que despojas."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despoja cualquiera de tu grupo o banda, con el nombre de quien los despoja."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despojas, de la calidad indicada al lado o superior."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despoja cualquiera de tu grupo o banda, de la calidad indicada al lado o superior, con el nombre de quien los despoja."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"La calidad mínima que deben tener los objetos de tipo %s que despojas para recibir un aviso."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"La calidad mínima que deben tener los objetos de tipo %s que despoja tu grupo para recibir un aviso."
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"Muestra las bolsas que despojas. Las almejas, los cajones y las cajas fuertes están en Para abrir."
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"Muestra las bolsas que despoja cualquiera de tu grupo o banda, con el nombre de quien las despoja. Las almejas, los cajones y las cajas fuertes están en Para abrir."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Se liga al recogerlo"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Muestra todo objeto ligado al recogerlo que despojes, sea cual sea su tipo o calidad."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Muestra todo objeto ligado al recogerlo que despoje tu grupo, sea cual sea su tipo o calidad."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Para abrir"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Muestra los contenedores que despojas y que GogoLoot puede abrir, cajas fuertes incluidas, sea cual sea su calidad."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Muestra los contenedores que despoja tu grupo y que GogoLoot puede abrir, cajas fuertes incluidas, sea cual sea su calidad."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Muestra un aviso para las monedas que despojas. El juego no informa de las monedas de otros jugadores, así que no hay casilla de Grupo."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Tirada ganadora"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Añade a su aviso la tirada con la que ganaste un objeto, como (Has ganado, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Añade a su aviso la tirada con la que un miembro del grupo ganó un objeto, como (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Has ganado, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Cantidad en bolsas"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Añade a los avisos de tu propio botín cuántos llevas ahora, como x3 (27), en cuanto llevas más de los que indica el aviso."
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Máximo de avisos"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"El máximo de avisos en pantalla a la vez; el más antiguo se va para hacer sitio."
L["LOOT_TOASTS_UNLIMITED"] = "Ilimitado"
L["LOOT_TOASTS_DURATION"] = "Segundos en pantalla"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Cuántos segundos dura cada aviso antes de desvanecerse."
L["LOOT_TOASTS_GROWTH"] = "Dirección de crecimiento"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"Si los avisos más antiguos se desplazan hacia arriba o hacia abajo, alejándose del más reciente."
L["LOOT_TOASTS_GROW_UP"] = "Hacia arriba"
L["LOOT_TOASTS_GROW_DOWN"] = "Hacia abajo"
L["LOOT_TOASTS_ALIGN_TOASTS"] = "Alinear avisos"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "A qué lado del ancla se alinean los avisos."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Izquierda"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Derecha"

-- Text
L["LOOT_TOASTS_FONT"] = "Fuente"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "La fuente con la que se escriben los avisos."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Predeterminada"
L["LOOT_TOASTS_FONT_SIZE"] = "Tamaño de fuente"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "El tamaño del texto de los avisos; los iconos crecen y se encogen con él."
L["LOOT_TOASTS_OUTLINE"] = "Contorno de fuente"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"El contorno alrededor del texto de los avisos, que lo mantiene legible sobre fondos claros."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Ninguno"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contorno"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contorno grueso"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monocromo"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contorno monocromo"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Desbloquear posición"
L["LOOT_TOASTS_LOCK"] = "Bloquear posición"
L["LOOT_TOASTS_RESET"] = "Restablecer posición"
L["LOOT_TOASTS_RESET_CONFIRM"] = "¿Devolver los avisos de botín a su posición predeterminada?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Muestra u oculta el ancla para arrastrar los avisos a otro sitio."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Devuelve los avisos a su posición predeterminada, encima del centro de la pantalla."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "Clic y arrastrar para mover"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clic derecho para bloquear"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Desactivar Avisos de botín"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Objeto de ejemplo"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Reproduce un sonido para el botín de la calidad que elijas o superior, y un sonido de bolsa cuando %s se lleva algo."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Activar Sonidos de botín"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Activa o desactiva todos los sonidos de botín de GogoLoot."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Activar campanilla de botín"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Reproduce un sonido cuando despojas de un cadáver o cofre un objeto de la calidad que elijas o superior."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "La calidad mínima de objeto que hace sonar la campanilla de botín."
L["LOOT_SOUNDS_TEST"] = "Reproduce la campanilla de botín."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Activar sonido de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Reproduce un sonido de bolsa cuando %s se lleva algo de verdad."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Reproduce el sonido de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre por ti las almejas, cajones, monederos y cajas fuertes desbloqueadas de tus bolsas, siempre que te queden al menos %d huecos libres."
L["AUTOMATED_OPENING_ENABLE"] = "Activar Apertura automática"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Abre un contenedor cada vez y espera si estás en combate, lanzando un hechizo, en sigilo, o con la ventana de un mercader, del banco, del buzón, de la casa de subastas o de comercio abierta. Activa la opción %s del juego mientras está activada."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Solo fuera de estancias"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"No abre nada mientras estás en una mazmorra, banda o campo de batalla."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Solo en solitario"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "No abre nada mientras estás en un grupo o banda."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Una caja fuerte no se abre hasta que un %s la fuerce. Estas opciones muestran la habilidad de %s que necesita cada una y te avisan cuando hay una esperando."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Activar descripciones de cajas fuertes"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] =
	"Añade a la descripción de cada caja fuerte la habilidad de %s que necesita."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Elige si las descripciones de cajas fuertes aparecen solo para pícaros o para todos los personajes."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Activar avisos de cajas fuertes"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Te avisa en el chat cuando despojas una caja fuerte que se abrirá en cuanto se desbloquee."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Elige si los avisos de cajas fuertes aparecen solo para pícaros o para todos los personajes."
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"Los avisos de cajas fuertes no se usan mientras Apertura automática está desactivada."
L["LOCKBOXES_FOR_ROGUES"] = "Para pícaros"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Para todos los personajes"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Tu %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Activar avisos de Ignorar"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Te avisa en el chat cuando GogoLoot no toca un contenedor porque la Lista de contenedores dice Ignorar, y por qué."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Todos los contenedores que conoce GogoLoot y qué hace Apertura automática con cada uno. Ignorar mantiene un contenedor cerrado, y Despojo rápido lo deja en la ventana de botín para ti. Tus cambios se aplican a todos tus personajes."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Mientras Apertura automática está desactivada, solo se usa Ignorar: sigue impidiendo que Despojo rápido se lleve estos objetos."
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] =
	"Estos ajustes no se usan mientras Apertura automática y Despojo rápido están desactivados."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Devuelve la lista a sus valores predeterminados: cada objeto recupera su ajuste predeterminado, los quitados vuelven y los añadidos se van."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"¿Devolver la lista a sus valores predeterminados? Se desharán todos los ajustes que cambiaste y todos los objetos que añadiste o quitaste."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Escribe el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista, en Abrir. No se puede añadir equipo ni bolsas, porque al usarlos se equipan."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Añade a la lista un objeto que llevas encima, en Abrir. No se ofrecen equipo ni bolsas, porque al usarlos se equipan."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Quita este objeto de la lista. GogoLoot lo trata entonces como un objeto normal: nunca se abre y se despoja como cualquier otro."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "¿Quitar este objeto de la lista? Añádelo de nuevo para recuperarlo."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Elige qué hace Apertura automática con este contenedor."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Abrir"
L["OPENING_ACTION_IGNORE"] = "Ignorar"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vender cerrado"
L["OPENING_TAG_UNIQUE"] = "Posible único"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Necesita que un %s lo fuerce. Una vez forzado, se abre como cualquier otro contenedor."
L["OPENING_REASON_RAID"] =
	"Lo suelta un jefe de banda o del mundo. Un contenedor sin abrir se puede comerciar o vender, a menudo por más de lo que contiene."
L["OPENING_REASON_BIND_ON_PICKUP"] = "Puede contener botín ligado al recogerlo. Cerrado, se puede comerciar o vender."
L["OPENING_REASON_UNIQUE"] = "Puede contener un objeto único. Abrirlo falla con un error si ya llevas uno."

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
L["ROLL_CALL_START"] = "Tirad por %s con /roll, %d segundos"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "Quedan %d segundos para %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d segundos más para %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "No cuentan en %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s tiró antes de tiempo (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s tiró de más (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s sacó %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s sacó %d (no está en el desempate)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s empatan a %d en %s. Solo %s, volved a tirar con /roll, %d segundos"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s empatan a %d en %s. Habrá desempate"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s gana %s con %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "Ahora %s gana %s con %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Nadie ha tirado por %s. De momento sigue en mi lista"
L["ROLL_CALL_NOBODY_LEFT"] = "Ninguna tirada por %s sigue contando. Vuelve a mi lista"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "He descalificado la tirada de %s (%d) en %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "He descalificado la tirada de %s (%d) en %s: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "He restaurado la tirada de %s (%d) en %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "He anulado todas las tiradas por %s. Volved a tirar con /roll, %d segundos"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Tirada por %s cancelada. Esperad para tirar"
L["ROLL_CALL_PAUSED"] = "Esperad para tirar. %s está en pausa"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Se reanudan las tiradas por %s, quedan %d segundos"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Se sortean en este orden: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Se sortea: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Botín suelto que se sortea: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "No estás en un grupo, así que esto no le ha llegado a nadie: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] = "%s ha ganado %s. Abre un comercio con esa persona y GogoLoot lo pondrá en la ventana."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Tiró antes del aviso"
L["ROLL_TAG_LATE"] = "Tiró después del cierre"
L["ROLL_TAG_REPEAT"] = "Tirada extra, no cuenta"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Rango erróneo (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "No está en el desempate"
L["ROLL_TAG_DISQUALIFIED"] = "Descalificada"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Descalificada: %s"
L["ROLL_TAG_WINNER"] = "Ganador"
L["ROLL_TAG_HIGHEST"] = "La más alta por ahora"
L["ROLL_TAG_TIED"] = "Empate"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "No puede optar a este objeto"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Ya ha ganado un objeto esta noche"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Tiró por otra persona"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Sin motivo"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Lista de tiradas (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Botín suelto (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Entregados (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Reservas flexibles"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Sortear"
L["LOOT_MASTER_ROLL_AGAIN"] = "Sortear de nuevo"
L["LOOT_MASTER_ROLL_ALL"] = "Sortear todo"
L["LOOT_MASTER_PAUSE"] = "Pausar"
L["LOOT_MASTER_RESUME"] = "Reanudar"
L["LOOT_MASTER_STOP"] = "Detener"
L["LOOT_MASTER_LIST_IN_RAID"] = "Publicar en banda"
L["LOOT_MASTER_MOVE_UP"] = "Subir"
L["LOOT_MASTER_MOVE_DOWN"] = "Bajar"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d segundos"
L["LOOT_MASTER_CLOSE_NOW"] = "Cerrar ya"
L["LOOT_MASTER_VOID"] = "Anular todas las tiradas"
L["LOOT_MASTER_CANCEL_ROLL"] = "Cancelar tirada"
L["LOOT_MASTER_TAKE_OFF"] = "Quitar de la lista"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Dar a %s"
L["LOOT_MASTER_TRADE"] = "Comerciar con %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Anunciar ganador"
L["LOOT_MASTER_HANDED_OUT"] = "Marcar como entregado"
L["LOOT_MASTER_REROLL_TIED"] = "Desempatar"
L["LOOT_MASTER_DISQUALIFY"] = "Descalificar"
L["LOOT_MASTER_RESTORE"] = "Restaurar"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "En el cadáver"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Cadáver cerrado"
L["LOOT_MASTER_BOUND"] = "Ligado"
L["LOOT_MASTER_NO_LIMIT"] = "Sin límite"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "En curso, %d tiradas"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Desempate, %d tiradas"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "En espera, %d tiradas"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Empate"
L["LOOT_MASTER_STATUS_NOBODY"] = "Nadie ha tirado"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Ya ligado"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "El siguiente"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "En curso, quedan %d segundos."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "En espera con %d segundos restantes."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Desempate entre %s, quedan %d segundos."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s ha ganado con %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s han empatado a %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Ya está ligado, así que no se puede comerciar."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Despojado de %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "De Botín suelto."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Se puede comerciar durante %s más."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Tiradas hasta ahora"
L["LOOT_MASTER_ROUND_ROLLS"] = "Tiradas"
L["LOOT_MASTER_ROUND_FIRST"] = "Primera tirada"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Desempate"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "No han tirado (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Aún no hay nada que repartir. El botín comerciable que recojas aparece aquí solo; usa Alt + clic en cualquier otro objeto de las bolsas para añadirlo."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "En pausa."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Sortear todo: faltan %d."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "Una tirada cada vez."
L["LOOT_MASTER_STATE_WAITING"] = "%d esperando tirada."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d por repartir."
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d por repartir; la próxima ventana de comercio se cierra en %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + clic en un objeto de las bolsas para añadirlo"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Descalificar una tirada"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "¿Sacar la tirada de %s (%d) de la disputa por %s? Puedes restaurarla más tarde."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Motivo"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot dice al grupo:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "¿Descartar todas las tiradas por %s y volver a pedir tiradas?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] =
	"Sortear todo ha terminado. Todos los objetos de la Lista de tiradas han tenido su tirada."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "Sortear todo en pausa. No empieza nada nuevo hasta que pulses Reanudar."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Sortear todo se ha reanudado."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Sortear todo detenido. Una tirada en curso termina igualmente."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s se puede comerciar durante %d minutos más."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s ya no se puede comerciar."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "Se ha puesto %s en la ventana de comercio para %s, que lo ha ganado con %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s no puede recibir %s de este cadáver."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s se ha añadido a la Lista de tiradas."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s no se puede comerciar, así que no puede ir a la Lista de tiradas."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Objetos de Botín suelto añadidos a la Lista de tiradas: %d."
L["LOOT_MASTER_OFF"] =
	"El Gestor de botín está desactivado. Actívalo en Opciones > Accesorios > GogoLoot > Gestor de botín."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "En la Lista de tiradas."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Ganado por %s con %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Botín sin tiempo de comercio que quieres sortear: materiales, recetas, equipo que se liga al equiparlo. Empieza vacío, así que solo se sortea lo que añades. Una tirada por pila."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	"Aún no hay nada. Elige en Añadir desde las bolsas o suelta un objeto en la casilla de arriba."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "%d en las bolsas"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "En la Lista de tiradas"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Quita este objeto de Botín suelto."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Otros"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Añadir todo a la Lista de tiradas"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Recogido en esta estancia"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "También en tus bolsas"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Nada comerciable de tus bolsas coincide con "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"Aún no se ha entregado nada. Un objeto ganado aparece aquí cuando su ganador lo tiene."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Tirada de %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Entregado %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Borrar"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Pega aquí un texto de reservas flexibles para ver quién ha reservado qué. Próximamente: por ahora esta pestaña es provisional."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "La importación de reservas flexibles aún no está lista."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Importar"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Rastreador de botín"
L["LOOT_TRACKER_TAB_ROLLS"] = "Tiradas"
L["LOOT_TRACKER_TAB_DROPS"] = "Botín caído"
L["LOOT_TRACKER_NO_ROLL"] = "Aún no hay tiradas esta noche."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Pedida por %s"
L["LOOT_TRACKER_SPOTTED"] = "Vista en el chat de %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "Quedan %d s"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s no usa GogoLoot, así que estas son las tiradas vistas en el chat, comprobadas con las reglas habituales: 1-100, solo la primera tirada. Quien pidió la tirada tiene la última palabra."
L["LOOT_TRACKER_ON_HOLD"] = "En espera. Aguarda al aviso para volver a tirar."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Tiradas de desempate"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s ha ganado con %d"
L["LOOT_TRACKER_CLOSED"] = "Cerrada"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Más alta"
L["LOOT_TRACKER_SORT_TIME"] = "Por orden"
L["LOOT_TRACKER_ROLL"] = "Tirar (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Tú"
L["LOOT_TRACKER_YOU_ROLLED"] = "Has sacado %d."
L["LOOT_TRACKER_YOU_PASSED"] = "Has pasado."
L["LOOT_TRACKER_NOT_ROLLED"] = "No has tirado."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Ahora solo tiran los jugadores empatados."
L["LOOT_TRACKER_EARLIER"] = "Anteriores esta noche"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "tirad"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Mostrar quién se llevó qué"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Aún no se ha visto botín. Aparece aquí a medida que mueren los jefes y se despojan los cadáveres."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Nadie con GogoLoot lo ha despojado aún."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Aún sin entregar"
L["LOOT_TRACKER_PRINT"] = "Mostrar"
L["LOOT_TRACKER_POST"] = "Publicar en banda"
L["LOOT_TRACKER_COPY"] = "Copiar"
L["LOOT_TRACKER_COPY_TITLE"] = "Copiar con Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Bichos"
L["DROPS_NONE"] = "Aún no hay botín registrado."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Botín en %s:"
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
	"Sortea con tiradas lo que aún puedes comerciar, con el tiempo de comercio de cada objeto, y sigue cada tirada en el Rastreador de botín. Haz clic central en el botón del minimapa o escribe /gogo master o /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Activar Gestor de botín"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Sigue el botín que aún puedes comerciar y pide tiradas por él. Si está desactivado, el Gestor de botín y el Rastreador de botín nunca se abren y no se lee ninguna tirada."
L["LOOT_MASTER_OPEN"] = "Abrir Gestor de botín"
L["LOOT_TRACKER_OPEN"] = "Abrir Rastreador de botín"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d segundos"
L["LOOT_MASTER_MINUTES"] = "%d minutos"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Pedir tiradas"
L["LOOT_MASTER_ROLL_LENGTH"] = "Duración de la tirada"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Cuánto tiempo sigue abierta una tirada."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Anunciar en"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Adónde van los avisos de tirada, los empates y las pausas."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Chat de grupo"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"Aviso de banda pasa al chat de grupo cuando no eres líder ni ayudante. Los ganadores siempre van al chat de grupo."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Avisar cuando queden %d segundos"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Avisa al grupo cuando una tirada está a punto de cerrarse."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Añadir %d segundos cuando alguien tire tarde"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Una tirada en los últimos segundos mantiene la tirada abierta un poco más, para que la latencia no deje fuera a nadie."
L["LOOT_MASTER_END_EARLY"] = "Terminar antes si todos han tirado o pasado"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] =
	"Cierra la tirada en cuanto todos los miembros del grupo han tirado o han escrito pasar."
L["LOOT_MASTER_REROLL_TIES"] = "Desempatar entre los jugadores empatados"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Pide un desempate para los jugadores empatados al momento. Si está desactivado, un empate espera a que pulses Desempatar."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pausa entre objetos en Sortear todo"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] = "Cuánto espera Sortear todo tras una tirada antes de pedir la siguiente."

L["LOOT_MASTER_COUNTING_HEADER"] = "Tiradas que cuentan"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Un /roll normal (1-100), solo la primera de cada jugador, de tu grupo, mientras la tirada está abierta (%d segundo de margen por la latencia). Las tiradas que no cuentan se quedan en la lista con el motivo."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Anunciar tiradas que no cuentan"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Enumera en una línea, al cerrarse la tirada, las tiradas que no contaron y por qué. Una tirada que descalificas siempre se anuncia."

L["LOOT_MASTER_TRADE_HEADER"] = "Botín comerciable"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Abrir al despojar algo comerciable"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Abre el Gestor de botín cuando llega a tus bolsas botín ligado al recogerlo que aún puedes comerciar, mientras estás en un grupo."
L["LOOT_MASTER_TRADE_WARN"] = "Avisarme cuando quede poco tiempo de comercio"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Te avisa una vez, en el chat, cuando un objeto de la Lista de tiradas está a punto de ligarse."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "Cuánto tiempo de comercio queda cuando se te avisa."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Poner los objetos ganados en la ventana de comercio"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"Cuando abres un comercio con un ganador, lo que ha ganado se coloca solo. Tú sigues pulsando Comerciar."

L["LOOT_MASTER_FLOOR_HEADER"] = "Botín suelto"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"Botín suelto empieza vacío y solo contiene lo que añades. Añadir desde las bolsas muestra primero lo que recogiste en esta estancia."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Quitar objetos cuando salgan de mis bolsas"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Quita un objeto de Botín suelto cuando ya no te queda ninguno: comerciado, vendido o usado."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Vaciar Botín suelto al salir de la banda"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Empieza cada banda con la lista de Botín suelto vacía."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Abrir cuando alguien pida tiradas"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Abre el Rastreador de botín cuando alguien de tu grupo pide tiradas, con GogoLoot o con un aviso de banda."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Cerrarse solo al terminar la tirada"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Un Rastreador de botín que se abrió solo se cierra 30 segundos después de terminar la tirada, salvo que tengas el ratón encima."
L["LOOT_TRACKER_KEEP_DROPS"] = "Bandas que guardar en Botín caído"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "Cuántas bandas recuerda la pestaña Botín caído."
