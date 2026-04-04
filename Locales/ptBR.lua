local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ptBR")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "As configurações foram redefinidas para esta atualização. Use /gl para revisar suas opções."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "Todas as configurações foram redefinidas para os padrões."
L["MSG_CONFLICT_DETECTED"] = "Addons de saque conflitantes detectados."
L["MSG_CONFLICT_ADDON"] = "Addon conflitante: %s"
L["MSG_AUTO_LOOT_ENABLED"] = "O Saque Automático é necessário para que o GogoLoot funcione corretamente. O Saque Automático foi ativado."
L["MSG_NOT_MASTER_LOOTER"] = "Você não é o Mestre Saqueador no momento."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Pobre"
L["QUALITY_COMMON"] = "Comum"
L["QUALITY_UNCOMMON"] = "Incomum"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Épico"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Rolagem Manual"
L["ROLL_GREED"] = "Ganância"
L["ROLL_NEED"] = "Necessidade"
L["ROLL_PASS"] = "Passar"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Livre para Todos"
L["LOOT_METHOD_ROUND_ROBIN"] = "Alternado"
L["LOOT_METHOD_MASTER"] = "Mestre Saqueador"
L["LOOT_METHOD_GROUP"] = "Saque em Grupo"
L["LOOT_METHOD_NBG"] = "Necessidade Antes da Ganância"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Apenas Pobre"
L["THRESHOLD_COMMON_LOWER"] = "Comum e Inferior"
L["THRESHOLD_UNCOMMON_LOWER"] = "Incomum e Inferior"
L["THRESHOLD_RARE_LOWER"] = "Raro e Inferior"
L["THRESHOLD_EPIC_LOWER"] = "Épico e Inferior"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "Geral"
L["GENERAL_DESC"] = "Configurações principais que se aplicam sempre que o GogoLoot está ativo."
L["SPEEDY_LOOT"] = "Ativar Saque Rápido"
L["SPEEDY_LOOT_DESC"] = "Pega o saque instantaneamente sem mostrar a janela de saque, economizando tempo entre os abates."

L["COMMANDS"] = "/Comandos"
L["COMMANDS_DESC_GL"] = "Abre a interface de opções do GogoLoot."
L["COMMANDS_DESC_GOGOLOOT"] = "Abre a interface de opções do GogoLoot."

L["RESET"] = "Redefinir"
L["RESET_DESC"] = "Limpa todas as configurações do GogoLoot e restaura cada opção para seu valor padrão."
L["RESET_ALL"] = "Redefinir todas as opções do GogoLoot"
L["RESET_CONFIRM"] = "Isso redefinirá TODAS as configurações do GogoLoot para seus padrões. Isso não pode ser desfeito. Continuar?"

L["FEEDBACK_SUPPORT"] = "Feedback e Suporte"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Carregando... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "Posta automaticamente um resumo das trocas concluídas no chat, incluindo itens, encantamentos e ouro trocados."
L["TRADE_ENABLE"] = "Ativar Anúncios de Troca"
L["TRADE_ENABLE_DESC"] = "Posta um resumo da troca quando uma troca é concluída."
L["TRADE_CONDITION"] = "Quando em Grupo"
L["TRADE_CONDITION_DESC"] = "Controla quando os anúncios de troca estão ativos."
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Apenas em Grupo ou Raide"
L["TRADE_CONDITION_RAID_ONLY"] = "Apenas em Raide"
L["TRADE_OUTPUT"] = "Saída da Mensagem"
L["TRADE_OUTPUT_DESC"] = "Para onde o resumo da troca é enviado."
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat do Grupo"
L["TRADE_OUTPUT_RAID"] = "Chat da Raide"
L["TRADE_EXAMPLE"] = "Exemplo: {rt4} Deu [Item X] x2, [Item Y] para Fathom. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Anúncios de Troca"
L["TRADE_TOOLTIP_DESC"] = "Posta um resumo no chat quando esta troca for concluída."
L["TRADE_TOOLTIP_OUTPUT"] = "Saída Atual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Rola Ganância automaticamente em itens não Vinculados ao Recolher iguais ou inferiores à qualidade selecionada. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados. Itens Vinculados ao Recolher nunca têm rolagem automática de ganância pelo limite, mas podem ser automatizados através da Lista de Rolagem Personalizada abaixo."
L["ROLLS_ENABLE"] = "Ativar Rolagens Automáticas"
L["ROLLS_ENABLE_DESC"] = "Rola Ganância automaticamente em itens elegíveis iguais ou inferiores ao limite."
L["ROLLS_THRESHOLD"] = "Limite de Ganância Automática"
L["ROLLS_THRESHOLD_DESC"] = "Itens desta qualidade ou inferior terão rolagem automática de ganância."

L["ROLLS_CUSTOM_LIST"] = "Lista de Rolagem Personalizada"
L["ROLLS_CUSTOM_LIST_DESC"] = "Itens nesta lista têm sua própria regra de rolagem que substitui o limite. Esta é a única maneira de automatizar itens Vinculados ao Recolher como Pedras do Flagelo ou Runas Demoníacas. Defina cada item para Rolagem Manual, Ganância, Necessidade ou Passar. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados, independentemente da configuração."
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Rolagem Personalizada Padrão"
L["ROLLS_RESTORE_CONFIRM"] = "Isso substituirá sua lista de rolagem personalizada pelos itens padrão de sua expansão. Continuar?"
L["ROLLS_ADD_ITEM_DESC"] = "Insira um ID de Item ou cole um link de item para adicioná-lo à lista."
L["ROLLS_ADD_ITEM"] = "Adicionar Item"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Insira o ID do Item ou arraste um link de item aqui."
L["ROLLS_CHOOSE_ACTION"] = "Escolha a ação de rolagem automática para este item."
L["ROLLS_REMOVE"] = "Remover"
L["ROLLS_REMOVE_DESC"] = "Remove este item da lista de rolagem personalizada."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Tipo de Saque (somente leitura, altere pelo Menu do Jogo)"
L["ML_LOOT_THRESHOLD"] = "Limite de Saque (somente leitura, altere pelo Menu do Jogo)"

L["ML_AUTO_HEADER"] = "Mestre Saqueador Automático"
L["ML_AUTO_DESC"] = "Distribui automaticamente o saque aos jogadores designados quando você é o Mestre Saqueador. Itens de Missão, Livros, Receitas, Montarias, Mascotes e Lendários são sempre ignorados e aparecerão em uma janela de saque padrão."
L["ML_AUTO_ENABLE"] = "Ativar Mestre Saqueador Automático em Instâncias"
L["ML_AUTO_ENABLE_DESC"] = "Distribui o saque para destinos configurados automaticamente."
L["ML_AUTO_OUTSIDE"] = "Ativar Mestre Saqueador Automático Fora de Instâncias"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Cuidado: Como o saque de chefes mundiais não é trocável, isso não é aconselhável!"

L["ML_DEST_HEADER"] = "Destinos do Saque"
L["ML_DEST_DESC"] = "Designe um membro do grupo para receber itens de cada nível de qualidade."
L["ML_DEST_SELF"] = "A si mesmo"
L["ML_DEST_CHOOSE"] = "Escolha quem recebe itens %s."

L["ML_ANNOUNCE_HEADER"] = "Anúncios de Saque"
L["ML_ANNOUNCE_DESC"] = "Posta uma mensagem no chat do grupo quando os itens são distribuídos pelo Mestre Saqueador. Distribuições manuais são sempre anunciadas, independentemente do limite."
L["ML_ANNOUNCE_ENABLE"] = "Ativar Anúncios de Saque"
L["ML_ANNOUNCE_ENABLE_DESC"] = "Anuncia as distribuições de itens no chat do grupo."
L["ML_ANNOUNCE_THRESHOLD"] = "Limite de Anúncio"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "Apenas anunciar itens desta qualidade ou superior."
L["ML_ANNOUNCE_EXAMPLE"] = "Exemplo: {rt4} Deu [Item X] para Gogowarrior. // GogoLoot"

L["ML_IGNORE_HEADER"] = "Lista de Ignorados"
L["ML_IGNORE_DESC"] = "Itens nesta lista não serão distribuídos automaticamente e aparecerão em uma janela de saque padrão para atribuição manual."
L["ML_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Padrão"
L["ML_IGNORE_RESTORE_CONFIRM"] = "Isso substituirá sua lista de ignorados do mestre saqueador pelos itens padrão de sua expansão. Continuar?"
L["ML_IGNORE_ADD_DESC"] = "Insira um ID de Item ou cole um link de item para adicioná-lo à lista de ignorados."
L["ML_IGNORE_ADD"] = "Adicionar Item"
L["ML_IGNORE_ADD_TOOLTIP"] = "Insira o ID do Item ou arraste um link de item aqui."
L["ML_IGNORE_REMOVE"] = "Remover"
L["ML_IGNORE_REMOVE_DESC"] = "Remover este item da lista de ignorados."