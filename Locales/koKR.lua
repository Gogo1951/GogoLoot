local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "koKR")
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
	"버전 %s. 설정(이 메시지를 끄는 옵션 포함)은 설정 > 애드온 > GogoLoot에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게 알리거나, CurseForge에서 즐겨찾기하거나, GitHub에서 Star를 눌러 주세요. (="
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 창을 열 수 없습니다."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] = "빠른 획득과 자동 열기에 필요한 게임의 %s 설정을 켰습니다."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "현재 %s 역할을 맡고 있지 않습니다."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "가방 빈 칸이 %d칸 이상 될 때까지 자동 열기를 일시 중지합니다."
L["MESSAGE_OPENING_RESUMED"] = "자동 열기를 다시 시작합니다."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s: 잠금이 풀리면 자동으로 열립니다."
L["MESSAGE_ITEM_IGNORED"] = "%s: 무시로 설정되어 있어 자동 열기가 건드리지 않습니다."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s: 공격대 또는 필드 우두머리에게서 얻은 아이템이므로, 거래하거나 판매할 수 있도록 자동 열기가 열지 않고 남겨 둡니다."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s: 고유 아이템이 들어 있을 수 있어, 직접 열 수 있도록 자동 열기가 열지 않고 남겨 둡니다."
-- A pickup the server refused after Speedy Loot had already closed the loot. %s is the client's own reason, such as "Inventory is full.", and leads, since it brings its own closing punctuation.
L["MESSAGE_LOOT_LEFT_ON_CORPSE"] = "%s 일부 전리품이 시체에 남았습니다."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"획득 알림이 켜져 있는 동안 %s 및 %s 설정을 %s 대화 탭에서 껐습니다."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "%s 및 %s 설정을 %s 대화 탭에서 다시 켰습니다."

-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s: 열지 않고 착용하는 아이템이므로 열기 목록에 추가할 수 없습니다."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "%s 주사위를 굴렸습니다: %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "주사위 굴리기를 포기했습니다: %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s님이 아이템을 차지했습니다: %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s님이 아이템을 차지했습니다: %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "아이템을 차지했습니다: %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "아이템을 차지했습니다: %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "%s 전달: %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "%s 전달: %s, 받음: %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "%s 받음: %s에게서."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s 전달: %s"
L["MESSAGE_DESTINATION_SET"] = "%s님이 파티의 %s 아이템을 보관합니다"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s님이 파티의 모든 전리품을 보관합니다"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] =
	"%s님이 파티를 떠났습니다. 이제 %s님이 파티의 %s 아이템을 보관합니다"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] =
	"%s님이 파티를 떠났습니다. 이제 %s님이 파티의 모든 전리품을 보관합니다"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s 전달: %s, 받음: %s"
L["MESSAGE_TRADE_RECEIVED"] = "%s 받음: %s에게서"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s님의 가방이 가득 찼습니다: %s"
L["ERROR_MAX_COUNT"] = "%s님은 이미 너무 많이 가지고 있습니다: %s"
L["ERROR_OUT_OF_RANGE"] = "%s님이 너무 멀리 있습니다: %s"
L["ERROR_NOT_IN_GROUP"] = "%s님이 더 이상 파티나 공격대에 없습니다: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "%s님에게 전리품을 주지 못했습니다: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "빠른 획득"
L["TAB_AUTOMATED_ROLLS"] = "자동 주사위"
L["TAB_ITEM_OVERRIDES"] = "아이템별 설정"
-- A child panel of Automated Rolls: each character's rolls by the stats and gear types it wants.
L["TAB_CHARACTER_RULES"] = "캐릭터별 규칙"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "전리품 공지"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "거래 공지"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "전리품 전담 공지"
L["TAB_LOOT_TOASTS"] = "획득 알림"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "필터"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "획득 소리"
L["TAB_AUTOMATED_OPENING"] = "자동 열기"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "잠긴 상자"
L["TAB_OPENABLE_ITEMS"] = "열기 목록"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "자동 전리품 분배"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "전리품 받을 사람"
L["TAB_IGNORE_LIST"] = "무시 목록"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "주사위 매크로"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "전리품 관리자"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "사용"
L["STATUS_DISABLED"] = "사용 안 함"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "일시 중지"

--[[
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"선택한 품질까지 대상 아이템에 대신 주사위를 굴립니다."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"가방에 있는 조개, 상자, 동전 주머니, 잠금 해제된 잠긴 상자를 엽니다."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "거래 요약과 전리품 분배 내역을 대화창에 게시합니다."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"품질별로 지정한 플레이어에게 전리품을 분배합니다."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "왼쪽 클릭"
L["MINIMAP_RIGHT_CLICK"] = "오른쪽 클릭"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + 왼쪽 클릭"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + 오른쪽 클릭"
L["MINIMAP_TOGGLE"] = "켜기/끄기"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "잠긴 아이템"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "%s에게 부탁하면 자물쇠를 열어 줍니다."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "%s 기술을 사용해 자물쇠를 여세요."
L["MINIMAP_OPTIONS"] = "GogoLoot 설정"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 가운데 클릭"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "거래 가능 전리품"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "외 %d개"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "전리품 관리자 및 전리품 추적기"
L["MINIMAP_TO_HAND_OUT"] = "분배할 아이템 %d개"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] =
	"아직 거래할 수 있는 전리품을 주사위로 분배하고, 모든 주사위를 지켜봅니다."
L["MINIMAP_MIDDLE_CLICK"] = "가운데 클릭"
L["MINIMAP_OPEN"] = "열기"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "수동"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s만"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s 이하"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
]]
L["ITEM_LIST_ADD"] = "아이템 추가"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으면 목록에 추가됩니다."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "아이템을 끌어다 놓거나 ID 입력"
L["ITEM_LIST_ADD_BUTTON"] = "추가"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "아이템 검색..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"이름, 아이템 ID, 설정 또는 태그에 입력한 내용이 포함된 아이템만 표시합니다."
L["ITEM_LIST_NO_MATCHES"] = "검색 조건에 맞는 아이템이 없습니다."
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"목록이 비어 있어 다음 접속 때 기본 항목이 돌아옵니다. 기본값 복원을 누르면 지금 바로 돌아옵니다."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "새 항목"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "모든 종류의 아이템 표시"
L["ITEM_LIST_KIND_DESCRIPTION"] =
	"목록의 모든 아이템을 표시하거나, 한 종류의 아이템만 표시합니다."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "가방에서 추가"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "가지고 있는 아이템을 목록에 추가합니다."
L["ITEM_LIST_BAGS_EMPTY"] = "가방에 추가할 아이템 없음"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "가지고 있는 모든 아이템이 이미 목록에 있습니다."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "기본값 복원"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "불러오는 중... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a quest item gets rolled on, and Item Overrides or Include Bind on Pickup
    the way a Bind on Pickup item does; nothing ever rolls on the rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"제조법, 책, 탈것, 애완동물, 전설 아이템에는 절대 주사위를 굴리지 않으며, 퀘스트 아이템은 아이템별 설정에 있을 때만, 획득 시 귀속 아이템은 아이템별 설정에 있거나 획득 시 귀속 포함이 켜져 있을 때만 굴립니다."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"제조법, 책, 탈것, 애완동물, 전설 아이템은 항상 직접 분배하도록 남겨 둡니다."

-- The channel choice that posts to the party or raid: Trade Announcements' Channel and the Loot Master's Announce In.
L["CHANNEL_GROUP_CHAT"] = "파티 대화"

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "예시: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"빠른 획득은 전리품 창 없이 시체를 비우고, 품질에 따라 입찰, 차비, 포기를 자동으로 고르며, 자동 전리품 분배가 전리품을 대신 나눠 줍니다. 조개, 용기, 잠금 해제된 잠긴 상자는 저절로 열립니다. 더 빨리 줍고, 더 빨리 다음 몹을 당기세요."
L["WELCOME_MESSAGE"] = "환영 메시지 사용"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"접속할 때마다 GogoLoot의 버전과 이 설정을 찾는 위치를 표시합니다."
L["MINIMAP_BUTTON_ENABLE"] = "미니맵 버튼 사용"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"미니맵에 GogoLoot 버튼을 표시합니다. 왼쪽 클릭은 자동 주사위, 오른쪽 클릭은 자동 열기, Shift + 왼쪽 클릭은 전리품 공지, Shift + 오른쪽 클릭은 자동 전리품 분배를 켜거나 끕니다."

L["OPTIONS_COMMANDS_HEADER"] = "/명령어"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 창을 엽니다."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "기능"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"시체를 여는 즉시 모든 것을 가져오므로, 전리품 창을 기다릴 필요가 없습니다."
L["SPEEDY_LOOT_ENABLE"] = "빠른 획득 사용"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"시체를 여는 즉시 전리품 창 없이 모두 획득합니다. 전리품 창을 보려면 Shift 키를 누른 채 획득하세요. 게임의 %s 설정을 켜며, %s 역할을 맡는 동안에는 작동하지 않습니다."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"금화 아이콘이 붙은 %s 매크로를 일반 매크로에 추가해, 계정의 모든 캐릭터가 행동 단축바로 끌어다 놓을 수 있게 합니다."
--[[
    The three rows under it, each beside its mouse button's caption
    (MINIMAP_LEFT_CLICK and its neighbors). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "1-100 굴리기"
L["ROLL_MACRO_RIGHT_CLICK"] = "1-99 굴리기"
L["ROLL_MACRO_MIDDLE_CLICK"] = "공격대 주사위"
L["ROLL_MACRO_ENABLE"] = "주사위 매크로 사용"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"공격대 주사위는 아이템을 무작위로 한 사람에게 줍니다. 1부터 파티 인원 수까지 굴리므로 숫자 하나가 플레이어 한 명을 뜻합니다: 공격대나 파티 목록을 위에서부터 나온 숫자만큼 세어 승자를 찾으세요. 혼자일 때는 1-100을 굴립니다."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"%s 매크로를 일반 매크로에 유지합니다: 왼쪽 클릭은 1-100, 오른쪽 클릭은 1-99, 가운데 클릭은 공격대 주사위를 굴립니다. 끄면 매크로를 삭제합니다."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] =
	"%s 매크로가 일반 매크로에 있습니다. %s 입력 후 행동 단축바로 끌어다 놓으세요."
L["ROLL_MACRO_REMOVED"] = "%s 매크로를 삭제했습니다."
L["ROLL_MACRO_FULL_LOADING"] =
	"%s 매크로를 추가하지 못했습니다: 일반 매크로가 가득 찼습니다. 하나를 삭제하면 다음 로딩 화면이 지난 뒤 추가됩니다."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "GogoLoot의 레벨 업을 도와주세요"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"이 애드온은 이 게임을 사랑하고 모두가 최대한 즐겁게 플레이하기를 바라는 플레이어들이 만들었습니다. 후원을 요청하는 일은 절대 없을 겁니다. 우리의 작업이 여러분의 게임을 조금이라도 더 낫게 만든다는 것이 진정한 보람입니다. 그렇다면 꼭 이야기를 들려주세요!"
L["OPTIONS_LEVEL_UP_WAYS"] =
	"더 많은 플레이어에게 다가갈 수 있도록 도와주는 방법을 몇 가지 소개합니다."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 피드백 공유: 버그를 찾았거나 아이디어가 있나요? Discord에서 알려 주세요. 여러분의 피드백은 애드온을 개선하는 데 도움이 되며, 풀 리퀘스트도 언제나 환영합니다."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 친구에게 알리기: 이 애드온을 좋아할 만한 사람이 있나요? 소개해 주세요. 입소문은 더 많은 플레이어가 좋은 애드온을 발견하는 데 도움이 됩니다."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• CurseForge에서 즐겨찾기: 아래 CurseForge 링크를 열고 로그인한 뒤, 다운로드 버튼 아래의 별을 클릭하세요. 즐겨찾기는 더 많은 플레이어가 이 애드온을 발견하는 데 도움이 됩니다."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• GitHub에서 Star 누르기: 아래 GitHub 링크를 열고 로그인한 뒤, 오른쪽 위의 Star를 클릭하세요. Star는 프로젝트가 더 많은 무료 개발자 도구를 받을 자격을 얻는 데 도움이 됩니다."
L["OPTIONS_LEVEL_UP_THANKS"] = "GogoLoot를 선택해 주셔서 감사합니다!"

L["OPTIONS_FEEDBACK"] = "피드백 및 지원"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "피드백 및 지원 링크"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "링크를 복사하려면 상자를 클릭한 다음 Ctrl+A, Ctrl+C를 누르세요."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "버전 %s"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "파티 전리품 설정"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"파티의 전리품을 나누는 방식을 정합니다. 파티장만 변경할 수 있습니다."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"획득 방식이 적용되는 가장 낮은 아이템 품질을 정합니다. 파티장만 변경할 수 있습니다."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "이 설정은 %s님이 관리합니다."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "변경하려면 파티에 참여하세요. 파티장만 변경할 수 있습니다."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"%s 역할을 맡는 동안, 전리품 창을 여는 즉시 각 아이템을 품질별로 지정한 플레이어에게 분배합니다."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "자동 전리품 분배 사용"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"자동 분배를 켜거나 끕니다. '인스턴스 밖에서도'를 켜지 않으면 던전과 공격대 안에서만 작동합니다."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "인스턴스 밖에서도"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"필드에서도 전리품을 분배합니다. 필드 우두머리 전리품은 거래할 수 없으므로 권장하지 않습니다."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "퀘스트 아이템 포함"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"직접 조작하는 다른 캐릭터를 육성할 때를 위해 퀘스트 아이템도 분배합니다. 획득 기준이 일반 이하일 때만, 그리고 파티 전체에 하나만 떨어지는 퀘스트 아이템에만 작동합니다. 공격대에서는 권장하지 않습니다."

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "빠른 설정"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "%s 역할을 맡게 될 때마다 이 설정을 창으로 엽니다."
L["MASTER_LOOTER_POPUP_ENABLE"] = "전리품 전담 팝업 사용"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"품질별로 받을 사람을 선택하세요. 받을 사람이 없는 품질은 전리품 창에 남겨 둡니다."
L["MASTER_LOOTER_DESTINATION_SELF"] = "자신"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "전리품 창"
L["MASTER_LOOTER_SEND_ALL"] = "모든 전리품 받을 사람"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "아래의 모든 품질을 한 플레이어에게 지정합니다."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "%s 아이템을 받을 사람을 정합니다."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"아직 받을 사람이 없어 모든 전리품이 전리품 창에 남아 있습니다."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"이 목록의 아이템은 절대 자동으로 분배하지 않습니다. 직접 분배할 수 있도록 전리품 창에 남겨 둡니다."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"자동 전리품 분배가 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"무시 목록을 현재 확장팩의 기본 아이템으로 바꾸시겠습니까?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "무시 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"주사위 굴림 방식의 전리품에서 선택한 품질까지 %s, %s, %s 중 하나를 대신 선택합니다. 파티와 공격대를 따로 설정할 수 있습니다."
L["ROLLS_ENABLE"] = "자동 주사위 사용"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"아이템별 설정과 캐릭터별 규칙을 포함해 자동 주사위를 켜거나 끕니다."
L["ROLLS_IN_PARTY"] = "파티에서"
L["ROLLS_IN_RAID"] = "공격대에서"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "최대 품질"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: GogoLoot가 주사위를 굴리는 가장 높은 품질입니다."
L["ROLLS_ACTION_CHOOSE"] =
	"%s: GogoLoot가 선택할 주사위입니다. 수동은 직접 선택하도록 남겨 둡니다."
L["ROLLS_INCLUDE_BIND_ON_PICKUP"] = "획득 시 귀속 포함"
L["ROLLS_INCLUDE_BIND_ON_PICKUP_DESCRIPTION"] =
	"위 주사위 설정과 캐릭터별 규칙이 획득 시 귀속 아이템에도 주사위를 굴립니다. 획득 시 귀속 전리품은 보통 직접 굴릴 만하므로 기본값은 꺼짐입니다."
-- Section headers on the Automated Rolls panel.
L["ROLLS_PARTY_AND_RAID_HEADER"] = "파티 및 공격대 주사위"
L["ROLLS_MESSAGES_HEADER"] = "주사위 메시지"
L["ROLLS_PRINT_ITEM"] = "대화창에 아이템 표시"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"GogoLoot가 주사위를 굴린 아이템과 선택한 주사위를 대화창에 하나씩 표시합니다. GogoLoot가 주사위를 굴리면 주사위 창이 바로 닫히므로, 무엇이 나왔는지 확인할 수 있는 기록이 됩니다."
L["ROLLS_HIDE_MESSAGES"] = "주사위 메시지 숨기기"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"주사위마다 나오는 게임의 대화창 메시지를 숨깁니다. 누가 %s, %s, %s 중 무엇을 선택했는지와 굴린 모든 숫자가 해당됩니다. 각 승자가 무엇을 받았는지는 대화창에 그대로 남습니다."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "승자 요약 표시"
L["ROLLS_WINNER_SUMMARY_NONE"] = "승자 요약 표시 안 함"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"'승자 요약 표시'는 게임 자체 메시지 대신, 승리할 때마다 승자, 아이템, 승리 주사위를 담은 한 줄을 대화창에 표시합니다. '승자 요약 표시 안 함'은 누가 이겼는지 알려 주는 게임의 메시지를 그대로 둡니다."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"특정 아이템의 주사위를 품질 설정보다 우선하여 정합니다. GogoLoot가 퀘스트 아이템에, 또는 획득 시 귀속 포함이 꺼져 있을 때 획득 시 귀속 아이템에 주사위를 굴리는 유일한 방법입니다."
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "자동 주사위가 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
L["ITEM_OVERRIDES_ENABLE"] = "아이템별 설정 사용"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"아래에 정한 주사위를 사용합니다. 끄면 이 아이템들도 다른 아이템처럼 품질 설정을 따릅니다."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] =
	"아이템별 설정이 꺼져 있는 동안에는 이 주사위 설정이 사용되지 않습니다."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"아이템별 설정을 현재 확장팩의 기본 아이템으로 바꿉니다."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"아이템별 설정을 현재 확장팩의 기본 아이템으로 바꾸시겠습니까?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "이 아이템에 자동으로 선택할 주사위를 정합니다."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "아이템별 설정에서 이 아이템을 제거합니다."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] =
	"아이템별 설정에서 이 아이템과 주사위 설정을 제거하시겠습니까?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으면 수동으로 설정되어 목록에 추가됩니다."

--[[
    Character Rules, under Automated Rolls: the stats and the armor and
    weapon types each character wants, whose gear is left to the player. The
    stat, armor and weapon names come from the game's own strings.
]]
-- Arguments: the game's own name for Strength, then for the Warrior class, then Strength again.
L["CHARACTER_RULES_PANEL_INTRO"] =
	"%s 장비를 %s 캐릭터가 갖고 싶나요? %s 능력치와 사용하는 방어구 및 무기 종류를 체크하세요. 조건에 맞는 장비는 직접 굴리도록 남겨 두고, 나머지는 '그 밖의 장비'가 처리합니다. 아이템별 설정이 여전히 우선합니다."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "주 능력치"
L["CHARACTER_RULES_SECONDARY"] = "보조 능력치"
-- The armor and weapon sections above the stats; each box is named by the game.
L["CHARACTER_RULES_ARMOR"] = "방어구 종류"
L["CHARACTER_RULES_WEAPONS"] = "무기 종류"
-- The catch-all row at the bottom, under the game's own "Other": any armor or weapon no row above names.
L["CHARACTER_RULES_OTHER_GEAR"] = "기타 방어구 및 무기"
L["CHARACTER_RULES_OTHER_GEAR_NOTE"] =
	"낚싯대, 기타 무기, 그리고 위 종류에 없는 모든 방어구나 무기입니다."
-- The section under the lists: what happens to gear that doesn't match, and the button that clears a character's changes.
L["CHARACTER_RULES_EVERYTHING_ELSE"] = "그 밖의 장비"
L["CHARACTER_RULES_UNWANTED_ACTION"] = "조건에 맞지 않는 장비"
L["CHARACTER_RULES_RESET"] = "직업 기본값으로 초기화"
-- Sanity Check, at the foot of each character's page: ten sample items and how each would roll.
L["CHARACTER_RULES_SANITY_CHECK"] = "점검"
L["CHARACTER_RULES_SANITY_CHECK_NOTE"] =
	"위 상자 설정대로라면 이 캐릭터에게 이 착용 시 귀속 고급 아이템들이 어떻게 굴려지는지 보여줍니다."
--[[
    A Sanity Check row's outcome, Roll Window or Automated Roll, then in
    brackets why, where the boxes don't say: one of the SANITY_ reasons below,
    or Item Overrides by its panel name (TAB_ITEM_OVERRIDES).
]]
L["CHARACTER_RULES_SANITY_ROLL_WINDOW"] = "주사위 창"
L["CHARACTER_RULES_SANITY_AUTOMATED_ROLL"] = "자동 주사위"
-- The note under a sample item's tooltip. Argument: the game's own names for the stats it carries, joined by commas.
L["CHARACTER_RULES_SANITY_STATS"] = "캐릭터별 규칙이 읽는 능력치: %s"
L["CHARACTER_RULES_SANITY_LOW_LEVEL"] = "저레벨 장비"
L["CHARACTER_RULES_SANITY_ROLLS_OFF"] = "자동 주사위 꺼짐"
L["CHARACTER_RULES_SANITY_QUALITY"] = "품질 설정"
-- Argument: the game's own name for the character's class.
L["CHARACTER_RULES_CLASS"] = "직업: %s"
L["CHARACTER_RULES_LOW_LEVEL"] = "저레벨 장비에 자동 차비"
L["CHARACTER_RULES_LOW_LEVEL_DESCRIPTION"] =
	"요구 레벨이 내 레벨보다 이만큼 이상 낮은 방어구와 무기에 일치 여부와 관계없이 그 밖의 장비의 품질까지 차비를 선택하므로, 레벨업 중 이미 지난 장비가 발목을 잡지 않습니다."
-- The dropdown beside it: Off, then a level gap. Argument: how many levels below the character's own, 1 to 5.
L["CHARACTER_RULES_LOW_LEVEL_OFF"] = "끄기"
L["CHARACTER_RULES_LOW_LEVEL_BELOW"] = "내 레벨 - %d"
-- Printed once per account, at the first login where Automated Rolls is on by default.
L["MESSAGE_AUTOMATED_ROLLS_ON"] =
	"자동 주사위가 이제 켜져 있습니다. 각 캐릭터가 원하는 장비는 직접 굴리도록 남겨 두고, 나머지는 차비를 선택합니다. 설정 > 애드온 > GogoLoot > 자동 주사위에서 바꿀 수 있습니다."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"거래 요약과 전리품 분배 내역을 대화창에 게시해, 전리품이 어디로 갔는지 모두가 알 수 있게 합니다."
L["ANNOUNCEMENTS_ENABLE"] = "전리품 공지 사용"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"모든 공지를 켜거나 끕니다. 꺼져 있으면 GogoLoot는 직접 분배한 아이템을 포함해 파티나 거래 상대에게 아무것도 보내지 않습니다."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "완료된 거래마다 아이템, 마법부여, 골드를 요약해 게시합니다."
L["TRADE_ENABLE"] = "거래 공지 사용"
L["TRADE_ENABLE_DESCRIPTION"] =
	"거래가 완료되면 요약을 게시합니다. 거래 창의 공지 확인란과 같은 설정입니다."
L["TRADE_CONDITION_DESCRIPTION"] =
	"거래 요약을 게시할 때를 선택합니다: 항상, 파티나 공격대에 있을 때, 공격대에 있을 때."
L["TRADE_CONDITION_ALWAYS"] = "항상"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "파티 또는 공격대일 때"
L["TRADE_CONDITION_RAID_ONLY"] = "공격대일 때"
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "조건"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "채널"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s: 각 요약을 거래 상대에게 보냅니다. 파티 대화: 파티나 공격대에 게시하며, 파티에 없을 때는 귓속말로 보냅니다. 나만 보기: 내 대화창에만 표시하고 아무에게도 보내지 않습니다."
-- The Channel dropdown's choices (Whisper is the client's WHISPER, Group Chat is CHANNEL_GROUP_CHAT), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_SELF"] = "나만 보기"
L["TRADE_TOOLTIP_DESCRIPTION"] = "이 거래가 완료되면 대화창에 거래 요약을 게시합니다."
L["TRADE_CHECKBOX_LABEL"] = "공지"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"품질별로 누가 보관하는지와 무엇을 분배했는지 파티에 알립니다."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "받을 사람 공지 사용"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"받을 사람을 지정할 때마다 품질별로 누가 보관하는지 파티에 알립니다."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "자동 분배 공지 사용"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"GogoLoot가 자동으로 분배한 아이템 중 선택한 품질 이상인 것을 하나씩 공지합니다."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"이 품질 미만의 자동 분배는 공지하지 않습니다."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "수동 분배 공지 사용"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"%s 메뉴에서 직접 분배한 아이템을 품질과 관계없이 하나씩, 자동 분배와 같은 형식으로 공지합니다. 분배에 실패하면 이 설정과 관계없이 알립니다."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"획득한 아이템과 돈을 몇 초 동안 화면에 표시해, 빠른 획득이 전리품 창을 숨겨도 놓치는 것이 없게 합니다. 획득 알림을 켜 두는 동안에는 게임 자체 획득 메시지를 %s 대화 탭에서 뺄 수 있습니다."
L["LOOT_TOASTS_ENABLE"] = "획득 알림 사용"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"필터에서 선택한 전리품을 알림으로 표시합니다. 내 전리품과 파티의 전리품 모두 해당됩니다."
-- The checkbox under Enable Loot Toasts, and its tooltip.
L["LOOT_TOASTS_TOOLTIPS_ENABLE"] = "획득 알림 아이템 툴팁 사용"
L["LOOT_TOASTS_TOOLTIPS_DESCRIPTION"] =
	"알림을 가리키면 아이템 툴팁을 보여줍니다. 끄면 알림이 마우스를 무시하므로 뒤에 있는 몹과 시체를 가리키고 클릭할 수 있습니다."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "기본 획득 메시지 사용 안 함"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "기본 획득 메시지 사용"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"'기본 획득 메시지 사용 안 함'을 선택하면 획득 알림이 켜져 있는 동안 %s 및 %s 설정을 %s 대화 탭에서 끄고, 획득 알림을 끄면 다시 켭니다. 그 탭의 설정에 있는 것과 같은 설정이며, 다른 탭은 각자의 설정을 유지합니다."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "알림 배치"
L["LOOT_TOASTS_TEXT_HEADER"] = "글자"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "획득 알림이 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"내 전리품과 파티의 전리품 각각에 대해 무엇을 알림으로 표시하고 어떤 내용을 담을지 선택하세요. 파티의 전리품에는 획득한 사람의 이름이 함께 표시됩니다."
L["LOOT_TOASTS_FILTER_MINE"] = "본인"
L["LOOT_TOASTS_FILTER_GROUP"] = "파티"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "내가 획득한 %s 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"파티나 공격대의 누군가가 획득한 %s 아이템을 획득한 사람의 이름과 함께 표시합니다."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"내가 획득한 %s 아이템 중 옆에서 선택한 품질 이상인 것을 표시합니다."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"파티나 공격대의 누군가가 획득한 %s 아이템 중 옆에서 선택한 품질 이상인 것을 획득한 사람의 이름과 함께 표시합니다."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"내가 획득한 %s 아이템 중 알림을 표시할 가장 낮은 품질입니다."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"파티가 획득한 %s 아이템 중 알림을 표시할 가장 낮은 품질입니다."
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"내가 획득한 가방을 표시합니다. 조개, 상자, 잠긴 상자는 열기 대상에 있습니다."
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"파티나 공격대의 누군가가 획득한 가방을 획득한 사람의 이름과 함께 표시합니다. 조개, 상자, 잠긴 상자는 열기 대상에 있습니다."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "획득 시 귀속"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"종류나 품질에 관계없이, 내가 획득한 모든 획득 시 귀속 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"종류나 품질에 관계없이, 파티가 획득한 모든 획득 시 귀속 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "열기 대상"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"품질에 관계없이, 내가 획득한 상자 중 GogoLoot가 열 수 있는 것을 잠긴 상자를 포함해 표시합니다."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"품질에 관계없이, 파티가 획득한 상자 중 GogoLoot가 열 수 있는 것을 잠긴 상자를 포함해 표시합니다."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"획득한 돈을 알림으로 표시합니다. 게임이 다른 플레이어의 돈은 알려 주지 않으므로 파티 확인란은 없습니다."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "승리 주사위"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"아이템을 차지할 때 이긴 주사위를 (내가 획득, %s)처럼 알림에 추가합니다."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"파티원이 아이템을 차지할 때 이긴 주사위를 (%s, %s)처럼 그 사람의 알림에 추가합니다."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (내가 획득, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "소지 개수"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"알림에 표시된 수량보다 많이 가지고 있으면, 내 전리품 알림에 지금 가진 개수를 x3 (27)처럼 추가합니다."
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "최대 알림 수"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"화면에 동시에 표시되는 최대 알림 수입니다. 가장 오래된 알림부터 사라집니다."
L["LOOT_TOASTS_UNLIMITED"] = "무제한"
L["LOOT_TOASTS_DURATION"] = "표시 시간(초)"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "각 알림이 사라지기 전까지 표시되는 시간(초)입니다."
L["LOOT_TOASTS_GROWTH"] = "쌓이는 방향"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"오래된 알림이 가장 최근 알림에서 위로 밀려날지 아래로 밀려날지 정합니다."
L["LOOT_TOASTS_GROW_UP"] = "위로"
L["LOOT_TOASTS_GROW_DOWN"] = "아래로"
L["LOOT_TOASTS_ALIGN_TOASTS"] = "알림 정렬"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "알림을 이동 핸들의 어느 쪽에 맞춰 정렬할지 정합니다."
L["LOOT_TOASTS_ALIGN_LEFT"] = "왼쪽"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "오른쪽"

-- Text
L["LOOT_TOASTS_FONT"] = "글꼴"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "알림에 사용할 글꼴입니다."
L["LOOT_TOASTS_FONT_DEFAULT"] = "기본값"
L["LOOT_TOASTS_FONT_SIZE"] = "글꼴 크기"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "알림 글자 크기입니다. 아이콘도 함께 커지고 작아집니다."
L["LOOT_TOASTS_OUTLINE"] = "글꼴 외곽선"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"알림 글자 주위에 그리는 외곽선으로, 밝은 배경에서도 글자를 읽기 쉽게 합니다."
L["LOOT_TOASTS_OUTLINE_NONE"] = "없음"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "외곽선"
L["LOOT_TOASTS_OUTLINE_THICK"] = "굵은 외곽선"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "단색"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "단색 외곽선"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "위치 잠금 해제"
L["LOOT_TOASTS_LOCK"] = "위치 잠금"
L["LOOT_TOASTS_RESET"] = "위치 초기화"
L["LOOT_TOASTS_RESET_CONFIRM"] = "획득 알림을 기본 위치로 되돌리시겠습니까?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "알림을 새 위치로 끌어 옮기는 핸들을 표시하거나 숨깁니다."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "알림을 화면 중앙 위쪽의 기본 위치로 되돌립니다."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "클릭 후 끌어서 위치 지정"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "오른쪽 클릭으로 잠금"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "획득 알림 끄기"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "예시 아이템"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"선택한 품질 이상의 전리품에는 알림음을 재생하고, %s에 성공해 무언가를 얻으면 가방 소리를 재생합니다."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "획득 소리 사용"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "GogoLoot의 모든 획득 소리를 켜거나 끕니다."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "획득 알림음 사용"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"시체나 상자에서 선택한 품질 이상의 아이템을 획득하면 알림음을 재생합니다."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] =
	"획득 알림음을 재생하는 가장 낮은 아이템 품질입니다."
L["LOOT_SOUNDS_TEST"] = "획득 알림음을 재생합니다."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "%s 소리 사용"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] =
	"%s에 실제로 성공해 무언가를 얻으면 가방 소리를 재생합니다."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "%s 소리를 재생합니다."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"가방 빈 칸이 %d칸 이상일 때마다 가방에 있는 조개, 상자, 동전 주머니, 잠금 해제된 잠긴 상자를 대신 열어 줍니다."
L["AUTOMATED_OPENING_ENABLE"] = "자동 열기 사용"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"상자를 한 번에 하나씩 열며, 전투 중, 시전 중, 은신 중이거나 상점, 은행, 우편함, 경매장, 거래 창이 열려 있을 때는 기다립니다. 사용하는 동안 게임의 %s 설정을 켭니다."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "인스턴스 밖에서만"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"던전, 공격대, 전장 안에서는 아무것도 열지 않습니다."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "혼자일 때만"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] =
	"파티나 공격대에 있는 동안에는 아무것도 열지 않습니다."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"잠긴 상자는 %s에게 따 달라고 해야 열 수 있습니다. 이 설정은 각 상자에 필요한 %s 숙련도를 보여 주고, 따야 할 상자가 생기면 알려 줍니다."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "잠긴 상자 툴팁 사용"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "각 잠긴 상자에 필요한 %s 숙련도를 툴팁에 추가합니다."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"잠긴 상자 툴팁을 도적에게만 표시할지 모든 캐릭터에게 표시할지 정합니다."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "잠긴 상자 알림 사용"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"잠금이 풀리면 열리게 될 잠긴 상자를 획득하면 대화창으로 알려 줍니다."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"잠긴 상자 알림을 도적에게만 표시할지 모든 캐릭터에게 표시할지 정합니다."
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"자동 열기가 꺼져 있는 동안에는 잠긴 상자 알림이 사용되지 않습니다."
L["LOCKBOXES_FOR_ROGUES"] = "도적만"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "모든 캐릭터"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "내 %s"

-- On the Openables List panel.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "무시 알림 사용"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"열기 목록에서 무시로 설정되어 GogoLoot가 상자를 열지 않을 때, 그 이유와 함께 대화창으로 알려 줍니다."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"GogoLoot가 아는 모든 상자와 자동 열기가 각 상자를 어떻게 처리하는지 보여 줍니다. 무시로 설정한 상자는 열지 않습니다. 변경 사항은 모든 캐릭터에 적용됩니다."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] = "자동 열기가 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"목록을 기본값으로 되돌립니다: 모든 아이템이 기본 설정으로 돌아가고, 제거한 아이템은 다시 나타나며, 추가한 아이템은 사라집니다."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"목록을 기본값으로 되돌리시겠습니까? 변경한 모든 설정과 추가하거나 제거한 모든 아이템이 원래대로 돌아갑니다."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으면 열기로 설정되어 목록에 추가됩니다. 장비와 가방은 사용하면 착용되므로 추가할 수 없습니다."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"가지고 있는 아이템을 열기로 설정해 목록에 추가합니다. 장비와 가방은 사용하면 착용되므로 목록에 나오지 않습니다."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"목록에서 이 아이템을 제거합니다. 이후 GogoLoot는 이 아이템을 일반 아이템으로 취급하여, 열지 않고 다른 아이템처럼 획득합니다."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] =
	"목록에서 이 아이템을 제거하시겠습니까? 다시 추가하면 되돌릴 수 있습니다."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "자동 열기가 이 상자를 어떻게 처리할지 정합니다."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "열기"
L["OPENING_ACTION_IGNORE"] = "무시"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "미개봉 판매"
L["OPENING_TAG_UNIQUE"] = "고유 아이템 가능"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"%s에게 따 달라고 해야 합니다. 자물쇠를 따고 나면 다른 상자처럼 열립니다."
L["OPENING_REASON_RAID"] =
	"공격대 또는 필드 우두머리가 떨어뜨립니다. 열지 않은 상자는 거래하거나 판매할 수 있으며, 내용물보다 비싸게 팔리는 경우가 많습니다."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"획득 시 귀속 아이템이 들어 있을 수 있습니다. 열지 않으면 거래하거나 판매할 수 있습니다."
L["OPENING_REASON_UNIQUE"] =
	"고유 아이템이 들어 있을 수 있습니다. 이미 가지고 있으면 열 때 오류가 발생합니다."

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
L["ROLL_CALL_START"] = "%s: /roll로 주사위를 굴리세요, %d초"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "%d초 남음: %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d초 연장: %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "%s 집계 제외: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s님 호출 전 주사위 (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s님 추가 주사위 (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s님 %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s님 %d (동점 재굴림 대상 아님)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s님 %d 동점: %s. %s님만 /roll 다시, %d초"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s님 %d 동점: %s. 동점 재굴림 예정"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s님 획득: %s (%d)"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "변경, %s님 획득: %s (%d)"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "%s: 아무도 굴리지 않음. 일단 내 목록에 남겨 둠"
L["ROLL_CALL_NOBODY_LEFT"] = "%s: 유효한 주사위 없음. 다시 내 목록으로"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "%s님의 주사위 %d 실격 처리: %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "%s님의 주사위 %d 실격 처리: %s, 사유: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "%s님의 주사위 %d 복원: %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "%s: 모든 주사위 무효. /roll로 다시 굴리세요, %d초"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "%s 주사위 취소. 굴리지 말고 대기"
L["ROLL_CALL_PAUSED"] = "굴리지 말고 대기. %s 일시 중지"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "%s 주사위 재개, %d초 남음"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "순서대로 주사위 진행: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "주사위 대상: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "기타 전리품 주사위 대상: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "파티에 속해 있지 않아 아무에게도 보내지 않았습니다: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] =
	"%s님이 차지했습니다: %s. 그 플레이어와 거래를 열면 GogoLoot가 아이템을 거래 창에 넣어 줍니다."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "호출 전에 굴림"
L["ROLL_TAG_LATE"] = "마감 후에 굴림"
L["ROLL_TAG_REPEAT"] = "추가 주사위, 집계 안 됨"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "잘못된 범위 (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "동점 재굴림 대상 아님"
L["ROLL_TAG_DISQUALIFIED"] = "실격"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "실격: %s"
L["ROLL_TAG_WINNER"] = "승자"
L["ROLL_TAG_HIGHEST"] = "현재 최고"
L["ROLL_TAG_TIED"] = "동점"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "이 아이템을 받을 자격 없음"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "오늘 밤 이미 아이템 획득"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "다른 사람 대신 굴림"
L["ROLL_DISQUALIFY_REASON_NONE"] = "사유 없음"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "주사위 목록 (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "기타 전리품 (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "분배 완료 (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "소프트 예약"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "주사위 시작"
L["LOOT_MASTER_ROLL_AGAIN"] = "주사위 다시 시작"
L["LOOT_MASTER_ROLL_ALL"] = "전체 주사위"
L["LOOT_MASTER_PAUSE"] = "일시 중지"
L["LOOT_MASTER_RESUME"] = "재개"
L["LOOT_MASTER_STOP"] = "중단"
L["LOOT_MASTER_LIST_IN_RAID"] = "공격대에 목록 게시"
L["LOOT_MASTER_MOVE_UP"] = "위로 이동"
L["LOOT_MASTER_MOVE_DOWN"] = "아래로 이동"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d초"
L["LOOT_MASTER_CLOSE_NOW"] = "지금 마감"
L["LOOT_MASTER_VOID"] = "모든 주사위 무효화"
L["LOOT_MASTER_CANCEL_ROLL"] = "주사위 취소"
L["LOOT_MASTER_TAKE_OFF"] = "목록에서 제거"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "%s님에게 주기"
L["LOOT_MASTER_TRADE"] = "%s님과 거래"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "승자 공지"
L["LOOT_MASTER_HANDED_OUT"] = "분배 완료로 표시"
L["LOOT_MASTER_REROLL_TIED"] = "동점자 재굴림"
L["LOOT_MASTER_DISQUALIFY"] = "실격"
L["LOOT_MASTER_RESTORE"] = "복원"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "시체에 있음"
L["LOOT_MASTER_CORPSE_CLOSED"] = "시체 닫힘"
L["LOOT_MASTER_BOUND"] = "귀속됨"
L["LOOT_MASTER_NO_LIMIT"] = "제한 없음"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "진행 중, 주사위 %d개"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "동점 재굴림, 주사위 %d개"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "보류, 주사위 %d개"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "동점"
L["LOOT_MASTER_STATUS_NOBODY"] = "아무도 굴리지 않음"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "이제 귀속됨"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "다음 차례"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "주사위 진행 중, %d초 남았습니다."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "%d초 남은 상태로 보류 중입니다."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "%s님 동점 재굴림 중, %d초 남았습니다."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s님이 승리했습니다: %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s님이 동점입니다: %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "이제 귀속되어 더 이상 거래할 수 없습니다."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "획득처: %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "출처: 기타 전리품."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "앞으로 %s 동안 거래할 수 있습니다."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "지금까지의 주사위"
L["LOOT_MASTER_ROUND_ROLLS"] = "주사위"
L["LOOT_MASTER_ROUND_FIRST"] = "첫 주사위"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "동점 재굴림"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "굴리지 않음 (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"아직 분배할 것이 없습니다. 획득한 거래 가능 전리품은 자동으로 여기에 추가되며, 다른 가방 아이템은 Alt + 클릭으로 추가하세요."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "일시 중지됨."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "전체 주사위: %d개 남음."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "한 번에 하나씩 진행합니다."
L["LOOT_MASTER_STATE_WAITING"] = "%d개가 주사위를 기다리는 중."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "분배할 아이템 %d개."
L["LOOT_MASTER_FOOTER_CLOCK"] = "분배할 아이템 %d개, 다음 거래 기한은 %s 후 만료됩니다."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "가방 아이템을 Alt + 클릭하여 추가"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "주사위 실격"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] =
	"%s님의 주사위(%d)를 %s 경쟁에서 제외하시겠습니까? 나중에 복원할 수 있습니다."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "사유"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot가 파티에 알릴 내용:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] =
	"%s에 대한 모든 주사위를 무효화하고 다시 주사위를 요청하시겠습니까?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] =
	"전체 주사위가 끝났습니다. 주사위 목록의 모든 아이템에 주사위를 굴렸습니다."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] =
	"전체 주사위를 일시 중지했습니다. 재개를 누를 때까지 새 주사위를 시작하지 않습니다."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "전체 주사위를 재개했습니다."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] =
	"전체 주사위를 중단했습니다. 진행 중인 주사위는 끝까지 진행됩니다."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s: 앞으로 %d분 동안 거래할 수 있습니다."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s: 더 이상 거래할 수 없습니다."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "%s 아이템을 거래 창에 넣었습니다: %s님, 승리 주사위 %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s님에게 이 시체의 %s 아이템을 줄 수 없습니다."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s: 주사위 목록에 추가되었습니다."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s: 거래할 수 없어 주사위 목록에 추가할 수 없습니다."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "기타 전리품 아이템이 주사위 목록에 추가되었습니다: %d개."
L["LOOT_MASTER_OFF"] =
	"전리품 관리자가 꺼져 있습니다. 설정 > 애드온 > GogoLoot > 전리품 관리자에서 켜세요."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "주사위 목록에 있음."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "획득자: %s, 주사위 %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"거래 기한이 없지만 주사위로 나누고 싶은 전리품: 재료, 제조법, 착용 시 귀속 장비. 처음엔 비어 있어 추가한 것만 주사위를 굴립니다. 묶음당 주사위 한 번."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	"아직 아무것도 없습니다. '가방에서 추가'에서 고르거나, 위 칸에 아이템을 끌어다 놓으세요."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "가방에 %d개"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "주사위 목록에 있음"
L["LOOT_MASTER_FLOOR_REMOVE"] = "기타 전리품에서 이 아이템을 제거합니다."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "기타"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "모두 주사위 목록에 추가"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "이 인스턴스에서 획득"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "가방에 있는 다른 아이템"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = '가방에 "%s"에 맞는 거래 가능 아이템이 없습니다.'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"아직 분배한 것이 없습니다. 승자가 아이템을 받으면 여기에 표시됩니다."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "주사위 %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "분배: %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "지우기"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"누가 무엇을 예약했는지 보려면 여기에 소프트 예약 문자열을 붙여 넣으세요. 준비 중: 이 탭은 아직 자리만 잡아 둔 상태입니다."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "소프트 예약 가져오기는 아직 준비되지 않았습니다."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "가져오기"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "전리품 추적기"
L["LOOT_TRACKER_TAB_ROLLS"] = "주사위"
L["LOOT_TRACKER_TAB_DROPS"] = "드롭 목록"
L["LOOT_TRACKER_NO_ROLL"] = "오늘 밤에는 아직 주사위가 없습니다."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "요청자: %s"
L["LOOT_TRACKER_SPOTTED"] = "%s님의 대화에서 발견"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "%d초 남음"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s님은 GogoLoot를 사용하지 않으므로, 대화창에서 본 주사위를 일반 규칙(1-100, 첫 주사위만)으로 확인한 결과입니다. 최종 결정은 요청자에게 있습니다."
L["LOOT_TRACKER_ON_HOLD"] = "보류 중입니다. 다시 굴리라는 요청을 기다리세요."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "동점 재굴림 주사위"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s님 승리: %d"
L["LOOT_TRACKER_CLOSED"] = "마감"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "높은 순"
L["LOOT_TRACKER_SORT_TIME"] = "굴린 순"
L["LOOT_TRACKER_ROLL"] = "주사위 (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "나"
L["LOOT_TRACKER_YOU_ROLLED"] = "주사위 결과: %d."
L["LOOT_TRACKER_YOU_PASSED"] = "포기했습니다."
L["LOOT_TRACKER_NOT_ROLLED"] = "아직 굴리지 않았습니다."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "지금은 동점자만 굴립니다."
L["LOOT_TRACKER_EARLIER"] = "오늘 밤 이전 기록"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "주사위"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "누가 무엇을 받았는지 표시"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"아직 본 드롭이 없습니다. 우두머리를 처치하고 시체에서 전리품을 획득하면 여기에 표시됩니다."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "GogoLoot를 사용하는 사람이 아직 획득하지 않았습니다."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "아직 분배 안 됨"
L["LOOT_TRACKER_PRINT"] = "대화창에 표시"
L["LOOT_TRACKER_POST"] = "공격대에 게시"
L["LOOT_TRACKER_COPY"] = "복사"
L["LOOT_TRACKER_COPY_TITLE"] = "Ctrl+C로 복사"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "일반 몹"
L["DROPS_NONE"] = "아직 기록된 드롭이 없습니다."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "%s 드롭 목록:"
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
	"아직 거래할 수 있는 전리품을 아이템별 거래 기한과 함께 주사위로 분배하고, 전리품 추적기에서 모든 주사위를 지켜보세요. 미니맵 버튼을 가운데 클릭하거나 /gogo master 또는 /gogo tracker를 입력하세요."
L["LOOT_MASTER_ENABLE"] = "전리품 관리자 사용"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"아직 거래할 수 있는 전리품을 추적하고 주사위를 요청합니다. 끄면 전리품 관리자와 전리품 추적기가 열리지 않고 주사위도 읽지 않습니다."
L["LOOT_MASTER_OPEN"] = "전리품 관리자 열기"
L["LOOT_TRACKER_OPEN"] = "전리품 추적기 열기"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d초"
L["LOOT_MASTER_MINUTES"] = "%d분"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "주사위 요청"
L["LOOT_MASTER_ROLL_LENGTH"] = "주사위 시간"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "주사위가 열려 있는 시간입니다."
L["LOOT_MASTER_ANNOUNCE_IN"] = "공지 채널"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "주사위 요청, 동점, 일시 중지를 알릴 곳입니다."
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"공격대장이나 부공격대장이 아니면 공격대 경보 대신 파티 대화로 보냅니다. 승자는 항상 파티 대화로 알립니다."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "%d초 남았을 때 경고"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "주사위가 곧 마감될 때 파티에 알립니다."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "늦게 굴리면 %d초 추가"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"마지막 몇 초 안에 누가 주사위를 굴리면 주사위를 조금 더 열어 두어, 지연 때문에 놓치는 사람이 없게 합니다."
L["LOOT_MASTER_END_EARLY"] = "모두 굴리거나 포기하면 조기 마감"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] =
	"모든 파티원이 주사위를 굴리거나 pass를 입력하면 바로 마감합니다."
L["LOOT_MASTER_REROLL_TIES"] = "동점자끼리 재굴림"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"동점이 나오면 바로 동점자에게 재굴림을 요청합니다. 끄면 '동점자 재굴림'을 누를 때까지 기다립니다."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "전체 주사위의 아이템 간 대기 시간"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] =
	"전체 주사위가 주사위 하나를 끝내고 다음 주사위를 요청하기 전까지 기다리는 시간입니다."

L["LOOT_MASTER_COUNTING_HEADER"] = "집계되는 주사위"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"주사위가 열려 있는 동안 파티원이 굴린 일반 /roll (1-100) 중 플레이어별 첫 주사위만 집계합니다(지연을 고려해 %d초 유예). 집계되지 않는 주사위도 사유와 함께 목록에 남습니다."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "집계되지 않은 주사위 공지"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"주사위가 마감되면 집계되지 않은 주사위와 그 이유를 한 줄로 알립니다. 실격 처리한 주사위는 항상 공지합니다."

L["LOOT_MASTER_TRADE_HEADER"] = "거래 가능 전리품"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "거래 가능 전리품 획득 시 열기"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"파티에 있는 동안 아직 거래할 수 있는 획득 시 귀속 전리품이 가방에 들어오면 전리품 관리자를 엽니다."
L["LOOT_MASTER_TRADE_WARN"] = "거래 시간이 얼마 남지 않으면 경고"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"주사위 목록의 아이템이 곧 귀속될 때 대화창으로 한 번 알려 줍니다."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "경고할 때 남은 거래 시간입니다."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "차지한 아이템을 거래 창에 넣기"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"승자와 거래를 열면 승자가 차지한 아이템을 대신 넣어 줍니다. 거래 버튼은 직접 누르세요."

L["LOOT_MASTER_FLOOR_HEADER"] = "기타 전리품"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"기타 전리품은 처음엔 비어 있고 추가한 것만 담습니다. '가방에서 추가'는 이 인스턴스에서 획득한 아이템을 먼저 보여 줍니다."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "가방에서 없어지면 목록에서 제거"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"거래, 판매, 사용으로 아이템이 하나도 남지 않으면 기타 전리품에서 제거합니다."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "공격대를 떠나면 기타 전리품 비우기"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "공격대마다 빈 기타 전리품 목록으로 시작합니다."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "누군가 주사위를 요청하면 열기"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"파티의 누군가가 GogoLoot나 공격대 경보로 주사위를 요청하면 전리품 추적기를 엽니다."
L["LOOT_TRACKER_AUTO_CLOSE"] = "주사위가 끝나면 자동으로 닫기"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"자동으로 열린 전리품 추적기는 주사위가 끝나고 30초 뒤에 닫힙니다. 단, 마우스를 올려 두고 있으면 닫히지 않습니다."
L["LOOT_TRACKER_KEEP_DROPS"] = "드롭 목록에 보관할 공격대 수"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "드롭 목록 탭에 기억할 공격대 수입니다."
