local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ptBR")
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
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) ficam em Opções > AddOns > GogoLoot. Curtindo este add-on? Conte para um amigo, favorite-o no CurseForge ou dê uma estrela no GitHub. (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por segurança, a janela de opções não pode ser aberta durante o combate."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"A opção %s do jogo foi ativada, pois o Saque Rápido e a Abertura Automática precisam dela."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Você não é o %s no momento."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"A Abertura Automática está pausada até você ter pelo menos %d espaços livres nas bolsas."
L["MESSAGE_OPENING_RESUMED"] = "A Abertura Automática foi retomada."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s será aberto automaticamente assim que for destrancado."
L["MESSAGE_ITEM_IGNORED"] = "%s está definido como Ignorar, então a Abertura Automática não vai mexer nele."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s vem de um chefe de raide ou chefe mundial, então a Abertura Automática vai deixá-lo fechado para você negociar ou vender."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s pode conter um item único, então a Abertura Automática vai deixá-lo para você abrir."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s ficou na janela de saque para você mesmo saquear."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"%s e %s foram desativados na sua aba de chat %s enquanto os Avisos de Saque estiverem ativados."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "%s e %s foram reativados na sua aba de chat %s."

-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s seria equipado em vez de aberto, então não pode entrar na Lista de Abríveis."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Você rolou %s em %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Você passou em %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s ganhou %s com %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s ganhou %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Você ganhou %s com %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Você ganhou %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Deu %s para %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Deu %s para %s, recebeu %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Recebeu %s de %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Deu %s para %s"
L["MESSAGE_DESTINATION_SET"] = "%s vai guardar os itens de qualidade %s para o grupo"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s vai guardar todo o saque para o grupo"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s saiu do grupo. Agora %s vai guardar os itens de qualidade %s para o grupo"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s saiu do grupo. Agora %s vai guardar todo o saque para o grupo"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Deu %s para %s, recebeu %s"
L["MESSAGE_TRADE_RECEIVED"] = "Recebeu %s de %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "As bolsas de %s estão cheias: %s"
L["ERROR_MAX_COUNT"] = "%s já tem o máximo permitido de: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fora de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s não está mais no grupo ou raide: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Não foi possível entregar o saque para %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Saque Rápido"
L["TAB_AUTOMATED_ROLLS"] = "Rolagens Automáticas"
L["TAB_ITEM_OVERRIDES"] = "Exceções de Itens"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Regras de Personagem"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Anúncios de Saque"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Anúncios de Troca"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Anúncios do Mestre do Saque"
L["TAB_LOOT_TOASTS"] = "Avisos de Saque"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtros"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sons de Saque"
L["TAB_AUTOMATED_OPENING"] = "Abertura Automática"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Cofres"
L["TAB_OPENABLE_ITEMS"] = "Lista de Abríveis"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "Mestre do Saque Automatizado"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinos do Saque"
L["TAB_IGNORE_LIST"] = "Lista de Ignorados"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Macro de Rolagem"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Gerente de Saque"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Ativado"
L["STATUS_DISABLED"] = "Desativado"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "Pausado"

--[[
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rola por você nos itens elegíveis até a qualidade que você escolher."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre mariscos, caixotes, bolsas de moedas e cofres destrancados nas suas bolsas."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "Publica no chat os resumos de trocas e as entregas do Mestre do Saque."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"Entrega o saque aos jogadores que você escolheu para cada qualidade."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clique esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Clique direito"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + Clique esquerdo"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + Clique direito"
L["MINIMAP_TOGGLE"] = "Alternar"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Itens trancados"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "Um %s pode destrancá-los para você."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "Use %s para destrancá-los."
L["MINIMAP_OPTIONS"] = "Opções do GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do meio"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Saque Negociável"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "Mais %d"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Gerente de Saque e Rastreador de Saque"
L["MINIMAP_TO_HAND_OUT"] = "%d para entregar"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Distribua por rolagem o que ainda pode ser negociado e acompanhe cada rolagem."
L["MINIMAP_MIDDLE_CLICK"] = "Clique do meio"
L["MINIMAP_OPEN"] = "Abrir"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Só %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s e abaixo"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
]]
L["ITEM_LIST_ADD"] = "Adicionar Item"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Digite a ID de um item ou arraste um item até aqui para adicioná-lo à lista."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Solte o item aqui ou digite a ID"
L["ITEM_LIST_ADD_BUTTON"] = "Adicionar"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtrar itens..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Mostra só os itens cujo nome, ID, configuração ou etiqueta contém o que você digitar."
L["ITEM_LIST_NO_MATCHES"] = "Nenhum item corresponde ao filtro."
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"Esta lista está vazia, então os padrões voltam na próxima vez que você entrar no jogo. Restaurar Padrões os traz de volta agora."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Novos"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Mostrar Todos os Tipos de Itens"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Mostra todos os itens da lista, ou só os itens de um tipo."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Adicionar das Bolsas"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Adiciona à lista um item que você carrega."
L["ITEM_LIST_BAGS_EMPTY"] = "Nada nas bolsas para adicionar"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Todos os itens que você carrega já estão na lista."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Restaurar Padrões"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Carregando... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Nunca rola em receitas, livros, montarias, mascotes ou lendários, e só rola em itens que se vinculam ao ser recolhidos ou itens de missão se estiverem em Exceções de Itens."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Receitas, livros, montarias, mascotes e lendários sempre ficam para você."

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "Exemplo: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"O Saque Rápido esvazia corpos sem a janela de saque, escolhe Necessidade, Ganância ou Passar pela qualidade, e o Mestre do Saque Automatizado distribui o saque por você. Mariscos, recipientes e cofres destrancados se abrem sozinhos. Saqueie mais rápido, puxe mais cedo."
L["WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Mostra a versão do GogoLoot e onde encontrar estas configurações sempre que você entra no jogo."
L["MINIMAP_BUTTON_ENABLE"] = "Ativar Botão do Minimapa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Mostra o botão do GogoLoot no minimapa. Clique esquerdo alterna as Rolagens Automáticas, Clique direito a Abertura Automática, Shift + Clique esquerdo os Anúncios de Saque, e Shift + Clique direito o Mestre do Saque Automatizado."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a janela de opções deste add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Recursos"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Pega tudo de um corpo assim que você o abre, para você nunca esperar pela janela de saque."
L["SPEEDY_LOOT_ENABLE"] = "Ativar Saque Rápido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Esvazia cada corpo assim que você o abre, sem mostrar a janela de saque. Segure Shift ao saquear para ver a janela. Ativa a opção %s do jogo e fica inativo enquanto você é o %s."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Adiciona uma macro chamada %s, com um ícone de moedas de ouro, às suas Macros Gerais, para que todos os personagens da sua conta possam arrastá-la para uma barra de ações."
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Rolar 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Rolar 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Rolagem de Raide"
L["ROLL_MACRO_ENABLE"] = "Ativar Macro de Rolagem"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Uma rolagem de raide entrega um item a alguém ao acaso. Ela rola de 1 até o número de jogadores no seu grupo, então cada número representa um jogador: conte na lista da raide ou do grupo até o número rolado para achar o vencedor. Sozinho, ela rola 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Mantém a macro %s nas suas Macros Gerais: Clique esquerdo rola 1-100, Clique direito 1-99, Clique do meio uma rolagem de raide. Desativar isto apaga a macro."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "A macro %s está nas suas Macros Gerais. Digite %s e arraste-a para uma barra de ações."
L["ROLL_MACRO_REMOVED"] = "A macro %s foi apagada."
L["ROLL_MACRO_FULL_LOADING"] =
	"Não foi possível adicionar a macro %s: suas Macros Gerais estão cheias. Apague uma, e ela será adicionada depois da próxima tela de carregamento."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Ajude o GogoLoot a Subir de Nível"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Este add-on foi feito por jogadores que amam este jogo e querem deixá-lo o mais divertido possível para todos. Nunca vamos pedir doações. A verdadeira satisfação vem de saber que nosso trabalho deixa o jogo um pouco melhor para você. Se for o caso, adoraríamos saber!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Aqui estão algumas formas de nos ajudar a alcançar mais jogadores."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Dê sua Opinião: Achou um bug ou tem uma ideia? Conte para nós no Discord. Sua opinião nos ajuda a melhorar o add-on, e contribuições de código são sempre bem-vindas."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Conte para um Amigo: Conhece alguém que pode gostar deste add-on? Fale dele para essa pessoa. O boca a boca ajuda mais jogadores a descobrir ótimos add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorite no CurseForge: Abra o link do CurseForge abaixo, entre na sua conta e clique na estrela abaixo do botão Download. Os favoritos ajudam mais jogadores a descobrir o add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Dê uma Estrela no GitHub: Abra o link do GitHub abaixo, entre na sua conta e clique em Star no canto superior direito. As estrelas ajudam o projeto a se qualificar para mais ferramentas gratuitas de desenvolvimento."
L["OPTIONS_LEVEL_UP_THANKS"] = "Obrigado por escolher o GogoLoot!"

L["OPTIONS_FEEDBACK"] = "Feedback e Suporte"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Links de Opinião e Suporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Para copiar um link, clique na caixa dele e pressione Ctrl+A e Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Versão %s"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Configurações de Saque do Grupo"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Define como o saque do grupo é distribuído. Só o líder do grupo pode mudar isso."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Define a qualidade de item mais baixa à qual o método de saque se aplica. Só o líder do grupo pode mudar isso."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Estas configurações são controladas por %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Entre em um grupo para mudar isto. Só o líder do grupo pode."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Entrega cada item ao jogador escolhido para a qualidade dele assim que você abre a janela de saque, enquanto você é o %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Ativar Mestre do Saque Automatizado"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Liga ou desliga as entregas automáticas. Só funciona dentro de masmorras e raides, a menos que Também Fora de Instâncias esteja ativado."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Também Fora de Instâncias"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Também entrega o saque no mundo aberto. O saque de chefes mundiais não pode ser negociado, então isso não é recomendado."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Incluir Itens de Missão"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Também entrega itens de missão, para ajudar a upar um personagem que você mesmo joga. Só funciona com limite de saque Comum ou abaixo, e só para itens de missão que caem uma vez para o grupo todo. Não recomendado em raides."

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "Configurações Rápidas"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Abre estas configurações em uma janela sempre que você se torna o %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Ativar Janela do Mestre do Saque"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Escolha quem recebe cada qualidade. Uma qualidade sem ninguém escolhido fica na janela de saque para você."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Eu mesmo"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Janela de Saque"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar Todo o Saque Para"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Define um único jogador para todas as qualidades abaixo."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Define quem recebe os itens de qualidade %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Ninguém foi escolhido ainda, então todo o saque espera na janela de saque por você."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Os itens desta lista nunca são entregues automaticamente. Eles esperam na janela de saque para você mesmo entregar."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Estas configurações não são usadas enquanto o Mestre do Saque Automatizado estiver desativado."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] = "Substitui a Lista de Ignorados pelos itens padrão da sua expansão."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Substituir sua Lista de Ignorados pelos itens padrão da sua expansão?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Remove este item da Lista de Ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Rola %s, %s ou %s por você no saque em grupo, até a qualidade que você escolher, com configurações separadas para grupos e raides."
L["ROLLS_ENABLE"] = "Ativar Rolagens Automáticas"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Liga ou desliga as rolagens automáticas, incluindo as Exceções de Itens e as Regras de Personagem."
L["ROLLS_IN_PARTY"] = "Em Grupo"
L["ROLLS_IN_RAID"] = "Em Raide"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Até a Qualidade"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: a qualidade mais alta em que o GogoLoot rola."
L["ROLLS_ACTION_CHOOSE"] = "%s: a rolagem que o GogoLoot faz. Manual deixa a rolagem com você."
-- Section headers on the Automated Rolls panel.
L["ROLLS_PARTY_AND_RAID_HEADER"] = "Rolagens em Grupo e Raide"
L["ROLLS_MESSAGES_HEADER"] = "Mensagens de Rolagem"
L["ROLLS_PRINT_ITEM"] = "Mostrar Item no Chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Mostra no seu chat cada item em que o GogoLoot rola e a rolagem que ele fez. A janela de rolagem fecha assim que o GogoLoot rola, então este é o seu registro do que apareceu."
L["ROLLS_HIDE_MESSAGES"] = "Ocultar Mensagens de Rolagem"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Oculta as linhas de chat do jogo para cada rolagem: quem escolheu %s, %s ou %s, e cada número rolado. O que cada vencedor recebeu continua no chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Mostrar Resumo do Vencedor"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Não Mostrar Resumo do Vencedor"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Mostrar Resumo do Vencedor põe no chat uma linha para cada vitória, com o vencedor, o item e a rolagem vencedora, no lugar da linha do próprio jogo. Não Mostrar Resumo do Vencedor mantém a linha do jogo dizendo quem ganhou."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Define a rolagem para itens específicos, antes das configurações de qualidade. É a única forma de o GogoLoot rolar em um item que se vincula ao ser recolhido ou em um item de missão."
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Estas configurações não são usadas enquanto as Rolagens Automáticas estiverem desativadas."
L["ITEM_OVERRIDES_ENABLE"] = "Ativar Exceções de Itens"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Usa as rolagens definidas abaixo. Desativado, estes itens seguem as configurações de qualidade como qualquer outro."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "Estas rolagens não são usadas enquanto as Exceções de Itens estiverem desativadas."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "Substitui suas Exceções de Itens pelos itens padrão da sua expansão."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] = "Substituir suas Exceções de Itens pelos itens padrão da sua expansão?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Define a rolagem automática para este item."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Remove este item das Exceções de Itens."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Remover este item e a rolagem dele das Exceções de Itens?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"Digite a ID de um item ou arraste um item até aqui para adicioná-lo à lista, definido como Manual."

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Deixa com você os equipamentos com os atributos que você escolher, personagem por personagem: defina %s como Manual no seu %s, e os equipamentos com %s mantêm a janela de rolagem enquanto todo o resto rola normalmente. As Exceções de Itens ainda vêm primeiro."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Atributos Primários"
L["CHARACTER_RULES_SECONDARY"] = "Atributos Secundários"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Rolagem Automática Padrão"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manual deixa com você os equipamentos com esse atributo neste personagem, janela de rolagem e tudo. Rolagem Automática Padrão rola neles como em qualquer outro item."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica no chat os resumos de trocas e as entregas do Mestre do Saque, para que todos saibam para onde o saque foi."
L["ANNOUNCEMENTS_ENABLE"] = "Ativar Anúncios de Saque"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Liga ou desliga todos os anúncios. Desativado, o GogoLoot não envia nada ao seu grupo nem aos seus parceiros de troca, nem mesmo os itens que você entrega pessoalmente."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Publica um resumo de cada troca concluída: itens, encantamentos e ouro."
L["TRADE_ENABLE"] = "Ativar Anúncios de Troca"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Publica um resumo quando uma troca é concluída. A caixa Anunciar na janela de troca é esta mesma opção."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Escolhe quando os resumos de troca são publicados: sempre, quando em grupo ou raide, ou quando em raide."
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Em Grupo ou Raide"
L["TRADE_CONDITION_RAID_ONLY"] = "Em Raide"
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "Quando"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envia cada resumo ao seu parceiro de troca. Chat do Grupo publica no grupo ou raide, e sussurra mesmo assim fora de um grupo. Só Eu mostra no seu próprio chat e não envia a ninguém."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Chat do Grupo"
L["TRADE_OUTPUT_SELF"] = "Só Eu"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica um resumo da troca no chat quando esta troca for concluída."
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Informa ao grupo quem guarda cada qualidade e o que você já entregou."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Ativar Anúncios de Destino"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Informa ao grupo quem guarda cada qualidade sempre que você define um destino."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Ativar Anúncios de Entrega Automática"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Anuncia cada item que o GogoLoot entrega automaticamente, na qualidade que você escolher ou acima."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Entregas automáticas abaixo desta qualidade não são anunciadas."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Ativar Anúncios de Entrega Manual"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Anuncia cada item que você mesmo entrega pelo menu do %s, seja qual for a qualidade, com o mesmo texto de uma entrega automática. Uma entrega que falha é informada de qualquer forma."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Mostra na tela por alguns segundos cada item e moeda que você saqueia, para que nada passe despercebido enquanto o Saque Rápido oculta a janela de saque. Com os avisos ativados, as linhas de saque do próprio jogo podem sair da sua aba de chat %s."
L["LOOT_TOASTS_ENABLE"] = "Ativar Avisos de Saque"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"Mostra um aviso para o saque que você escolher em Filtros, o seu e o do seu grupo."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Desativar Mensagens de Saque Padrão"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Ativar Mensagens de Saque Padrão"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Desativar desliga %s e %s na sua aba de chat %s enquanto os Avisos de Saque estiverem ativados, e desligar os Avisos de Saque os traz de volta. É a mesma opção das Configurações dessa aba, e as outras abas mantêm as suas."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Pilha"
L["LOOT_TOASTS_TEXT_HEADER"] = "Texto"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "Estas configurações não são usadas enquanto os Avisos de Saque estiverem desativados."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Escolha o que ganha um aviso, e o que ele diz, para o seu saque e o do seu grupo. O saque do grupo mostra ao lado o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE"] = "Meu"
L["LOOT_TOASTS_FILTER_GROUP"] = "Grupo"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Mostra os itens do tipo %s que você saqueia."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Mostra os itens do tipo %s que alguém do seu grupo ou raide saqueia, com o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Mostra os itens do tipo %s que você saqueia, na qualidade ao lado ou acima."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Mostra os itens do tipo %s que alguém do seu grupo ou raide saqueia, na qualidade ao lado ou acima, com o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"A qualidade mínima para os itens do tipo %s que você saqueia ganharem um aviso."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"A qualidade mínima para os itens do tipo %s que seu grupo saqueia ganharem um aviso."
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"Mostra as bolsas que você saqueia. Mariscos, caixotes e cofres ficam em Abríveis."
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"Mostra as bolsas que alguém do seu grupo ou raide saqueia, com o nome de quem saqueou. Mariscos, caixotes e cofres ficam em Abríveis."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Vincula-se ao ser recolhido"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Mostra todo item que você saqueia e que se vincula ao ser recolhido, seja qual for o tipo ou a qualidade."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Mostra todo item que seu grupo saqueia e que se vincula ao ser recolhido, seja qual for o tipo ou a qualidade."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Abríveis"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Mostra os recipientes que você saqueia e que o GogoLoot pode abrir, cofres incluídos, seja qual for a qualidade."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Mostra os recipientes que seu grupo saqueia e que o GogoLoot pode abrir, cofres incluídos, seja qual for a qualidade."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Mostra um aviso para as moedas que você saqueia. O jogo não informa as moedas de outros jogadores, então não há caixa de Grupo."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Rolagem Vencedora"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Adiciona ao aviso a rolagem com que você ganhou o item, como (Você Ganhou, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Adiciona ao aviso de um membro do grupo a rolagem com que ele ganhou o item, como (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Você Ganhou, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Total nas Bolsas"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Adiciona aos avisos do seu próprio saque quantos você carrega agora, como x3 (27), quando você carrega mais do que a quantidade mostrada no aviso."
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Máximo de Avisos"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] = "O máximo de avisos na tela ao mesmo tempo; o mais antigo sai para dar lugar."
L["LOOT_TOASTS_UNLIMITED"] = "Ilimitado"
L["LOOT_TOASTS_DURATION"] = "Segundos na Tela"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Quantos segundos cada aviso fica na tela antes de sumir."
L["LOOT_TOASTS_GROWTH"] = "Direção de Crescimento"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "Se os avisos mais antigos sobem ou descem, afastando-se do mais recente."
L["LOOT_TOASTS_GROW_UP"] = "Para Cima"
L["LOOT_TOASTS_GROW_DOWN"] = "Para Baixo"
L["LOOT_TOASTS_ALIGN_TOASTS"] = "Alinhar Avisos"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "Em que lado da alça os avisos se alinham."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Esquerda"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Direita"

-- Text
L["LOOT_TOASTS_FONT"] = "Fonte"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "A fonte usada nos avisos."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Padrão"
L["LOOT_TOASTS_FONT_SIZE"] = "Tamanho da Fonte"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "O tamanho do texto dos avisos; os ícones crescem e diminuem junto."
L["LOOT_TOASTS_OUTLINE"] = "Contorno da Fonte"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"O contorno desenhado em volta do texto dos avisos, que o mantém legível sobre cenários claros."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Nenhum"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contorno"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contorno Grosso"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monocromático"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contorno Monocromático"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Destravar Posição"
L["LOOT_TOASTS_LOCK"] = "Travar Posição"
L["LOOT_TOASTS_RESET"] = "Redefinir Posição"
L["LOOT_TOASTS_RESET_CONFIRM"] = "Levar os avisos de saque de volta à posição padrão?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Mostra ou oculta a alça para arrastar os avisos para outro lugar."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Leva os avisos de volta à posição padrão, acima do centro da tela."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "Clique e arraste para posicionar"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clique direito para travar"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Desativar Avisos de Saque"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Item de Exemplo"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Toca um sinal para saques na qualidade que você escolher ou acima, e um som de bolsa quando %s pega algo."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Ativar Sons de Saque"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Liga ou desliga todos os sons de saque do GogoLoot."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Ativar Sinal de Saque"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Toca um sinal quando você saqueia de um corpo ou baú um item na qualidade que você escolher ou acima."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "A qualidade de item mais baixa que toca o sinal de saque."
L["LOOT_SOUNDS_TEST"] = "Toca o sinal de saque."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Ativar Som de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Toca um som de bolsa quando %s realmente pega algo."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Toca o som de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre por você mariscos, caixotes, bolsas de moedas e cofres destrancados nas suas bolsas, sempre que você tiver pelo menos %d espaços livres nas bolsas."
L["AUTOMATED_OPENING_ENABLE"] = "Ativar Abertura Automática"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Abre um recipiente por vez e espera durante combate, lançamento de feitiços, furtividade, ou enquanto um mercador, banco, caixa de correio, casa de leilões ou janela de troca estiver aberto. Ativa a opção %s do jogo enquanto estiver ativada."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Só Fora de Instâncias"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Não abre nada enquanto você estiver em uma masmorra, raide ou campo de batalha."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Só Sozinho"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "Não abre nada enquanto você estiver em grupo ou raide."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Um cofre só abre depois que um %s o arromba. Estas opções mostram a habilidade de %s que cada um exige e avisam quando um está esperando."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Ativar Dicas de Cofres"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Adiciona à dica de cada cofre a habilidade de %s que ele exige."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Define se as dicas de cofres aparecem só para Ladinos ou para todos os personagens."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Ativar Notificações de Cofres"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Avisa no chat quando você saqueia um cofre que será aberto assim que for destrancado."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Define se as notificações de cofres aparecem só para Ladinos ou para todos os personagens."
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"As notificações de cofres não são usadas enquanto a Abertura Automática estiver desativada."
L["LOCKBOXES_FOR_ROGUES"] = "Para Ladinos"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Para Todos os Personagens"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Seu %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Ativar Avisos de Ignorados"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Avisa no chat quando o GogoLoot deixa um recipiente de lado porque a Lista de Abríveis diz Ignorar, e por quê."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Todo recipiente que o GogoLoot conhece e o que a Abertura Automática faz com ele. Ignorar mantém o recipiente lacrado, e o Saque Rápido o deixa na janela de saque para você. Suas alterações valem para todos os seus personagens."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Só Ignorar está em uso enquanto a Abertura Automática estiver desativada: ele ainda impede o Saque Rápido de pegar estes itens."
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] =
	"Estas configurações não são usadas enquanto a Abertura Automática e o Saque Rápido estiverem desativados."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Volta a lista ao padrão: cada item volta à configuração padrão, os itens removidos retornam e os adicionados saem."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Voltar a lista ao padrão? Toda configuração que você mudou e todo item que você adicionou ou removeu serão desfeitos."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Digite a ID de um item ou arraste um item até aqui para adicioná-lo à lista, definido como Abrir. Equipamentos e bolsas não podem ser adicionados, pois usá-los os equipa."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Adiciona à lista um item que você carrega, definido como Abrir. Equipamentos e bolsas não são oferecidos, pois usá-los os equipa."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Remove este item da lista. O GogoLoot passa a tratá-lo como um item normal: nunca é aberto e é saqueado como qualquer outro."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "Remover este item da lista? Adicione-o de novo para trazê-lo de volta."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Define o que a Abertura Automática faz com este recipiente."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Abrir"
L["OPENING_ACTION_IGNORE"] = "Ignorar"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vender Lacrado"
L["OPENING_TAG_UNIQUE"] = "Pode Ter Único"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Precisa de um %s para arrombá-lo. Depois de arrombado, abre como qualquer outro recipiente."
L["OPENING_REASON_RAID"] =
	"Deixado por um chefe de raide ou chefe mundial. Um recipiente fechado ainda pode ser negociado ou vendido, muitas vezes por mais do que o conteúdo."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Pode conter saque que se vincula ao ser recolhido. Lacrado, ainda pode ser negociado ou vendido."
L["OPENING_REASON_UNIQUE"] = "Pode conter um item único. Abrir falha com um erro se você já tiver um."

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
L["ROLL_CALL_START"] = "Role para %s com /roll, %d segundos"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "%d segundos restantes para %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "Mais %d segundos para %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Não contaram em %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s rolou cedo (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s rolou de novo (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s tirou %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s tirou %d (fora do desempate)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s empataram com %d em %s. Só %s, /roll de novo, %d segundos"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s empataram com %d em %s. Vai haver desempate"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s ganha %s com %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "Agora %s ganha %s com %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Ninguém rolou em %s. Continua na minha lista por enquanto"
L["ROLL_CALL_NOBODY_LEFT"] = "Nenhuma rolagem em %s ainda conta. Volta para a minha lista"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "Desqualifiquei a rolagem de %s (%d) em %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "Desqualifiquei a rolagem de %s (%d) em %s: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "Restaurei a rolagem de %s (%d) em %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "Anulei todas as rolagens em %s. Role de novo com /roll, %d segundos"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Rolagem de %s cancelada. Esperem para rolar"
L["ROLL_CALL_PAUSED"] = "Esperem para rolar. %s está em pausa"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Rolagens retomadas para %s, %d segundos restantes"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Rolando estes em ordem: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Para rolar: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Saque avulso para rolar: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "Você não está em um grupo, então isto não foi para ninguém: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] = "%s ganhou %s. Abra uma troca com essa pessoa e o GogoLoot coloca o item na janela."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Rolou antes da chamada"
L["ROLL_TAG_LATE"] = "Rolou depois do fim"
L["ROLL_TAG_REPEAT"] = "Rolagem extra, não conta"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Faixa errada (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Fora do desempate"
L["ROLL_TAG_DISQUALIFIED"] = "Desqualificada"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Desqualificada: %s"
L["ROLL_TAG_WINNER"] = "Vencedor"
L["ROLL_TAG_HIGHEST"] = "Maior até agora"
L["ROLL_TAG_TIED"] = "Empatou"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Não pode receber este item"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Já ganhou um item hoje"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Rolou por outra pessoa"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Sem motivo informado"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Lista de Rolagem (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Saque Avulso (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Entregues (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Reservas Leves"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Rolar"
L["LOOT_MASTER_ROLL_AGAIN"] = "Rolar de Novo"
L["LOOT_MASTER_ROLL_ALL"] = "Rolar Todos"
L["LOOT_MASTER_PAUSE"] = "Pausar"
L["LOOT_MASTER_RESUME"] = "Retomar"
L["LOOT_MASTER_STOP"] = "Parar"
L["LOOT_MASTER_LIST_IN_RAID"] = "Listar na Raide"
L["LOOT_MASTER_MOVE_UP"] = "Subir"
L["LOOT_MASTER_MOVE_DOWN"] = "Descer"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d Segundos"
L["LOOT_MASTER_CLOSE_NOW"] = "Encerrar Agora"
L["LOOT_MASTER_VOID"] = "Anular Todas as Rolagens"
L["LOOT_MASTER_CANCEL_ROLL"] = "Cancelar Rolagem"
L["LOOT_MASTER_TAKE_OFF"] = "Tirar da Lista"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Dar para %s"
L["LOOT_MASTER_TRADE"] = "Trocar com %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Anunciar Vencedor"
L["LOOT_MASTER_HANDED_OUT"] = "Marcar como Entregue"
L["LOOT_MASTER_REROLL_TIED"] = "Desempatar"
L["LOOT_MASTER_DISQUALIFY"] = "Desqualificar"
L["LOOT_MASTER_RESTORE"] = "Restaurar"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "No Corpo"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Corpo Fechado"
L["LOOT_MASTER_BOUND"] = "Vinculado"
L["LOOT_MASTER_NO_LIMIT"] = "Sem Limite"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "Rolando, %d rolagens"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Desempate, %d rolagens"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "Em espera, %d rolagens"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Empate"
L["LOOT_MASTER_STATUS_NOBODY"] = "Ninguém rolou"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Vinculado agora"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "A seguir"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Rolando, faltam %d segundos."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "Em espera, faltando %d segundos."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Desempate entre %s, faltam %d segundos."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s ganhou com %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s empataram com %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Vinculado agora, então não pode mais ser negociado."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Saqueado de %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "Do Saque Avulso."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Negociável por mais %s."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Rolagens até agora"
L["LOOT_MASTER_ROUND_ROLLS"] = "Rolagens"
L["LOOT_MASTER_ROUND_FIRST"] = "Primeira rolagem"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Desempate"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Não rolaram (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Nada para entregar ainda. O saque negociável que você pega aparece aqui sozinho; use Alt + Clique em qualquer outro item da bolsa para adicioná-lo."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "Pausado."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Rolar Todos: faltam %d."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "Uma rolagem por vez."
L["LOOT_MASTER_STATE_WAITING"] = "%d esperando rolagem."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d para entregar."
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d para entregar, o próximo prazo de troca termina em %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + Clique em um item da bolsa para adicioná-lo"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Desqualificar uma Rolagem"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "Tirar a rolagem de %s (%d) da disputa por %s? Você pode restaurá-la depois."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Motivo"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "O GogoLoot avisa o grupo:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "Descartar todas as rolagens em %s e pedir rolagens de novo?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "Rolar Todos terminou. Todos os itens da Lista de Rolagem já tiveram sua rolagem."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "Rolar Todos pausado. Nada novo começa até você apertar Retomar."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Rolar Todos retomado."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Rolar Todos parado. Uma rolagem em andamento ainda termina."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s pode ser negociado por mais %d minutos."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s não pode mais ser negociado."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "%s colocado na janela de troca para %s, que ganhou com %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s não pode receber %s deste corpo."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s entrou na Lista de Rolagem."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s não pode ser negociado, então não pode entrar na Lista de Rolagem."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Itens do Saque Avulso que entraram na Lista de Rolagem: %d."
L["LOOT_MASTER_OFF"] =
	"O Gerente de Saque está desativado. Ative-o em Opções > AddOns > GogoLoot > Gerente de Saque."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "Na Lista de Rolagem."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Ganho por %s com %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Saque sem prazo de troca que você quer sortear por rolagem: materiais, receitas, equipamentos que se vinculam ao equipar. Começa vazio, então só o que você adicionar é rolado. Uma rolagem por pilha."
L["LOOT_MASTER_FLOOR_EMPTY"] = "Nada aqui ainda. Escolha em Adicionar das Bolsas ou solte um item na caixa acima."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "%d nas bolsas"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "Na Lista de Rolagem"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Tira este item do Saque Avulso."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Outros"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Adicionar Todos à Lista de Rolagem"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Pegos nesta instância"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Também nas suas bolsas"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Nada negociável nas suas bolsas corresponde a "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] = "Nada entregue ainda. Um item ganho aparece aqui quando o vencedor o recebe."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Rolou %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Entregue: %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Limpar"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Cole aqui um texto de reservas leves para ver quem reservou o quê. Em breve: por enquanto esta aba é só um espaço reservado."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "A importação de reservas leves ainda não está pronta."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Importar"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Rastreador de Saque"
L["LOOT_TRACKER_TAB_ROLLS"] = "Rolagens"
L["LOOT_TRACKER_TAB_DROPS"] = "Espólios"
L["LOOT_TRACKER_NO_ROLL"] = "Nenhuma rolagem ainda hoje."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Chamada por %s"
L["LOOT_TRACKER_SPOTTED"] = "Vista no chat, de %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "%ds restantes"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s não está usando o GogoLoot, então estas são as rolagens vistas no chat, conferidas pelas regras de sempre: 1-100, só a primeira rolagem. Quem chamou tem a palavra final."
L["LOOT_TRACKER_ON_HOLD"] = "Em espera. Aguarde a chamada para rolar de novo."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Rolagens de desempate"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s ganhou com %d"
L["LOOT_TRACKER_CLOSED"] = "Encerrada"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Maior"
L["LOOT_TRACKER_SORT_TIME"] = "Por Ordem"
L["LOOT_TRACKER_ROLL"] = "Rolar (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Você"
L["LOOT_TRACKER_YOU_ROLLED"] = "Você rolou %d."
L["LOOT_TRACKER_YOU_PASSED"] = "Você passou."
L["LOOT_TRACKER_NOT_ROLLED"] = "Você não rolou."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Agora só os empatados rolam."
L["LOOT_TRACKER_EARLIER"] = "Mais cedo hoje"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "rola"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Mostrar Quem Levou o Quê"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Nenhum espólio visto ainda. Eles aparecem aqui conforme os chefes morrem e os corpos são saqueados."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Ninguém com o GogoLoot saqueou isso ainda."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Ainda não entregue"
L["LOOT_TRACKER_PRINT"] = "Mostrar"
L["LOOT_TRACKER_POST"] = "Publicar na Raide"
L["LOOT_TRACKER_COPY"] = "Copiar"
L["LOOT_TRACKER_COPY_TITLE"] = "Copie com Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Lacaios"
L["DROPS_NONE"] = "Nenhum espólio registrado ainda."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Espólios em %s:"
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
	"Distribua por rolagem o que ainda pode ser negociado, com o prazo de troca de cada item, e acompanhe cada rolagem no Rastreador de Saque. Clique do meio no botão do minimapa, ou digite /gogo master ou /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Ativar Gerente de Saque"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Acompanha o saque que você ainda pode negociar e pede rolagens nele. Desativado, o Gerente de Saque e o Rastreador de Saque nunca abrem e nenhuma rolagem é lida."
L["LOOT_MASTER_OPEN"] = "Abrir Gerente de Saque"
L["LOOT_TRACKER_OPEN"] = "Abrir Rastreador de Saque"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d Segundos"
L["LOOT_MASTER_MINUTES"] = "%d Minutos"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Chamada de Rolagens"
L["LOOT_MASTER_ROLL_LENGTH"] = "Duração da Rolagem"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Quanto tempo uma rolagem fica aberta."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Anunciar Em"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Para onde vão as chamadas de rolagem, os empates e as pausas."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Chat do Grupo"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"O Aviso de Raide passa para o chat do grupo quando você não é líder nem assistente. Os vencedores sempre vão para o chat do grupo."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Avisar Quando Faltarem %d Segundos"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Avisa o grupo quando uma rolagem está prestes a fechar."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Adicionar %d Segundos Quando Alguém Rolar Tarde"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Uma rolagem nos últimos segundos mantém a rolagem aberta um pouco mais, para que ninguém fique de fora por causa da latência."
L["LOOT_MASTER_END_EARLY"] = "Encerrar Antes Quando Todos Tiverem Rolado ou Passado"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] = "Fecha a rolagem assim que todos do grupo tiverem rolado ou digitado pass."
L["LOOT_MASTER_REROLL_TIES"] = "Desempatar Entre os Jogadores Empatados"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Chama na hora um desempate para os jogadores empatados. Desativado, um empate espera você apertar Desempatar."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pausa Entre Itens em Rolar Todos"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] =
	"Quanto tempo Rolar Todos espera após uma rolagem antes de chamar a próxima."

L["LOOT_MASTER_COUNTING_HEADER"] = "Rolagens Que Contam"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Um /roll simples (1-100), só o primeiro de cada jogador, do seu grupo, enquanto a rolagem está aberta (%d s de tolerância para a latência). Rolagens que não contam ficam na lista com o motivo."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Anunciar Rolagens Que Não Contam"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Lista as rolagens que não contaram, e por quê, em uma linha quando a rolagem fecha. Uma rolagem que você desqualifica é sempre anunciada."

L["LOOT_MASTER_TRADE_HEADER"] = "Saque Negociável"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Abrir Quando Eu Saquear Algo Negociável"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Abre o Gerente de Saque quando um saque que se vincula ao ser recolhido, mas ainda pode ser negociado, chega às suas bolsas enquanto você está em grupo."
L["LOOT_MASTER_TRADE_WARN"] = "Avisar Quando o Tempo de Troca Estiver Acabando"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Avisa você uma vez, no chat, quando um item da Lista de Rolagem está prestes a ficar vinculado."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "Quanto tempo de troca resta quando você é avisado."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Colocar Itens Ganhos na Janela de Troca"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"Quando você abre uma troca com um vencedor, o que ele ganhou entra sozinho. Você ainda aperta Trocar."

L["LOOT_MASTER_FLOOR_HEADER"] = "Saque Avulso"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"O Saque Avulso começa vazio e só guarda o que você adicionar. Adicionar das Bolsas lista primeiro o que você pegou nesta instância."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Tirar Itens Quando Saírem das Minhas Bolsas"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Tira um item do Saque Avulso quando você não tiver mais nenhum: negociado, vendido ou usado."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Esvaziar o Saque Avulso Quando Eu Sair da Raide"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Começa cada raide com a lista do Saque Avulso vazia."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Abrir Quando Alguém Pedir Rolagens"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Abre o Rastreador de Saque quando alguém do seu grupo pede rolagens, com o GogoLoot ou com um aviso de raide."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Fechar Sozinho Quando a Rolagem Terminar"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Um Rastreador de Saque que abriu sozinho fecha 30 segundos após o fim da rolagem, a menos que o mouse esteja sobre ele."
L["LOOT_TRACKER_KEEP_DROPS"] = "Raides Guardadas em Espólios"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "Quantas raides a aba Espólios guarda."
