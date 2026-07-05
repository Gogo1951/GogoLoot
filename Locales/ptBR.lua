local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ptBR")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > GogoLoot. Gostando do add-on? Conte para um amigo! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "O Saque Automático é necessário para que o GogoLoot funcione corretamente. O Saque Automático foi ativado."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Você não é o Mestre Saqueador no momento."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "Deu %s para %s."
L["MESSAGE_DESTINATION_SET"] = "%s receberá todos os itens %s."
L["MESSAGE_DESTINATION_LEFT"] = "%s saiu do grupo. %s agora receberá todos os itens %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Deu %s para %s, recebeu %s."
L["MESSAGE_TRADE_GAVE"] = "Deu %s para %s."
L["MESSAGE_TRADE_RECEIVED"] = "Recebeu %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "O jogador que você selecionou para receber o item não tem espaço nas bolsas."
L["ERROR_MAX_COUNT"] = "O jogador selecionado já possui muitos deste item."
L["ERROR_OUT_OF_RANGE"] = "O jogador que você selecionou para receber o item está fora de alcance."
L["ERROR_NOT_IN_GROUP"] = "O jogador que você selecionou para receber esse item não está mais no grupo ou raide."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Mestre Saqueador"
L["TAB_AUTOMATED_ROLLS"] = "Rolagens Automáticas"
L["TAB_ANNOUNCEMENTS"] = "Anúncios"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "Ganância Automática"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Rola Ganância automaticamente em itens elegíveis iguais ou inferiores ao limite de qualidade selecionado. Quando isto está desligado, nada é rolado automaticamente — incluindo a Lista de Rolagem Personalizada."
L["MINIMAP_SPEEDY_LOOT"] = "Saque Rápido"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Pega o saque instantaneamente sem mostrar a janela de saque."

L["MINIMAP_LEFT_CLICK"] = "Botão Esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Botão Direito"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Pobre"
L["QUALITY_COMMON"] = "Comum"
L["QUALITY_UNCOMMON"] = "Incomum"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Épico"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Rolagem Manual"
L["ROLL_GREED"] = "Ganância"
L["ROLL_NEED"] = "Necessidade"
L["ROLL_PASS"] = "Passar"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Livre para Todos"
L["LOOT_METHOD_ROUND_ROBIN"] = "Alternado"
L["LOOT_METHOD_MASTER"] = "Mestre Saqueador"
L["LOOT_METHOD_GROUP"] = "Saque em Grupo"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Necessidade Antes da Ganância"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Apenas Pobre"
L["THRESHOLD_COMMON_LOWER"] = "Comum e Inferior"
L["THRESHOLD_UNCOMMON_LOWER"] = "Incomum e Inferior"
L["THRESHOLD_RARE_LOWER"] = "Raro e Inferior"
L["THRESHOLD_EPIC_LOWER"] = "Épico e Inferior"

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Carregando... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Versão"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Colete equipamentos com o Mestre Saqueador automático, role Necessidade ou Ganância automaticamente em saques não-BoP e anuncie de forma transparente cada troca no chat. Itens de missão, receitas, montarias, mascotes e lendários estão sempre seguros. Não deixe o saque atrasar o seu zug!"
L["WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Minimap Button"

L["COMMANDS"] = "/Comandos"
L["COMMANDS_DESCRIPTION"] = "Abre a interface de opções do GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Saque Rápido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Pega o saque instantaneamente sem mostrar a janela de saque, economizando tempo entre os abates."
L["SPEEDY_LOOT_ENABLE"] = "Ativar Saque Rápido"

L["FEEDBACK_SUPPORT"] = "Feedback e Suporte"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Reset All Profiles"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Reset every profile on this account back to default settings."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "This will reset ALL profiles on your account back to default settings — every character. There is no undo. Continue?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Your group's current loot method and loot threshold."
L["MASTER_LOOTER_LOOT_TYPE"] = "Tipo de Saque (somente leitura, altere pelo Menu do Jogo)"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Limite de Saque (somente leitura, altere pelo Menu do Jogo)"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "Mestre Saqueador Automático"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribui automaticamente o saque aos jogadores designados quando você é o Mestre Saqueador. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados e aparecerão em uma janela de saque padrão."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Ativar Mestre Saqueador Automático em Instâncias"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Ativar Mestre Saqueador Automático Fora de Instâncias"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Cuidado: Como o saque de chefes mundiais não é trocável, isso não é aconselhável!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinos do Saque"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Designe um membro do grupo para receber itens de cada nível de qualidade."
L["MASTER_LOOTER_DESTINATION_SELF"] = "A si mesmo"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Escolha quem recebe itens %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista de Ignorados"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Itens nesta lista não serão distribuídos automaticamente e aparecerão em uma janela de saque padrão para atribuição manual."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Padrão"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Isso substituirá sua lista de ignorados do mestre saqueador pelos itens padrão de sua expansão. Continuar?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Insira um ID de Item ou cole um link de item para adicioná-lo à lista de ignorados."
L["MASTER_LOOTER_IGNORE_ADD"] = "Adicionar Item"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Remover"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Remover este item da lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Rola Ganância automaticamente em itens não Vinculados ao Recolher iguais ou inferiores à qualidade selecionada. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados. Itens Vinculados ao Recolher nunca têm rolagem automática de ganância pelo limite, mas podem ser automatizados através da Lista de Rolagem Personalizada abaixo. Itens na Lista de Rolagem Personalizada seguem sua ação de Necessidade, Ganância ou Passar em vez do limite. Quando as Rolagens Automáticas estão desligadas, nada é rolado automaticamente — incluindo a Lista de Rolagem Personalizada."
L["ROLLS_ENABLE"] = "Ativar Rolagens Automáticas"
L["ROLLS_THRESHOLD"] = "Limite de Ganância Automática"

L["ROLLS_CUSTOM_LIST"] = "Lista de Rolagem Personalizada"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Itens nesta lista têm sua própria regra de rolagem que substitui o limite. Esta é a única maneira de automatizar itens Vinculados ao Recolher como Pedras do Flagelo ou Runas Demoníacas. Defina cada item para Rolagem Manual, Ganância, Necessidade ou Passar. A lista só se aplica enquanto as Rolagens Automáticas estão ativadas. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados, independentemente da configuração."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Ativar Lista de Rolagem Personalizada"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Rolagem Personalizada Padrão"
L["ROLLS_RESTORE_CONFIRM"] = "Isso substituirá sua lista de rolagem personalizada pelos itens padrão de sua expansão. Continuar?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Insira um ID de Item ou arraste um item aqui para adicioná-lo à lista."
L["ROLLS_ADD_ITEM"] = "Adicionar Item"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "Remover"
L["ROLLS_REMOVE_DESCRIPTION"] = "Remove este item da lista de rolagem personalizada."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Anúncios de Troca"
L["TRADE_DESCRIPTION"] = "Posta automaticamente um resumo das trocas concluídas no chat, incluindo itens, encantamentos e ouro trocados."
L["TRADE_ENABLE"] = "Ativar Anúncios de Troca"
L["TRADE_CONDITION"] = "Quando"
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Apenas em Grupo ou Raide"
L["TRADE_CONDITION_RAID_ONLY"] = "Apenas em Raide"
L["TRADE_OUTPUT"] = "Saída da Mensagem"
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat do Grupo"
L["TRADE_EXAMPLE"] = "Exemplo: {rt4} Deu [Item X] x2, [Item Y] para Fathom. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Posta um resumo no chat quando esta troca for concluída."
L["TRADE_TOOLTIP_OUTPUT"] = "Saída Atual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Posta a atividade do mestre saqueador no chat do grupo para transparência. Configure limites separados para distribuições automáticas e manuais para que o saque automático não encha o chat de spam, enquanto os desvios manuais permaneçam visíveis."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Ativar Mensagens quando Mestre Saqueador For Definido"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Exemplo: {rt4} GogoLoot // Aevala receberá todos os itens Épicos."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Ativar Anúncios de Saque Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Limite de Anúncio Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note: Every item distributed manually is always announced, regardless of quality."
