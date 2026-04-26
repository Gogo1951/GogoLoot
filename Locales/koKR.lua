local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "koKR")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "이번 업데이트로 설정이 초기화되었습니다. 옵션을 확인하려면 /gl 을 사용하세요."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "모든 설정이 기본값으로 초기화되었습니다."
L["MSG_CONFLICT_DETECTED"] = "충돌하는 전리품 애드온이 감지되었습니다."
L["MSG_CONFLICT_ADDON"] = "충돌하는 애드온: %s"
L["MSG_AUTO_LOOT_ENABLED"] = "GogoLoot가 정상적으로 작동하려면 자동 획득이 필요합니다. 자동 획득이 활성화되었습니다."
L["MSG_NOT_MASTER_LOOTER"] = "현재 전리품 담당자가 아닙니다."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "활성화됨"
L["STATUS_DISABLED"] = "비활성화됨"

L["MINIMAP_AUTO_GREED"] = "자동 차상위"
L["MINIMAP_AUTO_GREED_DESC"] = "선택한 품질 임계값 이하의 대상 아이템에 대해 자동으로 차상위를 굴립니다."
L["MINIMAP_SPEEDY_LOOT"] = "빠른 획득"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "전리품 창을 표시하지 않고 즉시 전리품을 획득합니다."

L["MINIMAP_LEFT_CLICK"] = "좌클릭"
L["MINIMAP_RIGHT_CLICK"] = "우클릭"
L["MINIMAP_TOGGLE"] = "전환"
L["MINIMAP_HINT"] = "추가 설정은 설정 > 애드온 > GogoLoot에서 찾을 수 있습니다."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "하급"
L["QUALITY_COMMON"] = "일반"
L["QUALITY_UNCOMMON"] = "고급"
L["QUALITY_RARE"] = "희귀"
L["QUALITY_EPIC"] = "영웅"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "수동 주사위"
L["ROLL_GREED"] = "차상위"
L["ROLL_NEED"] = "입찰"
L["ROLL_PASS"] = "포기"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "자유 획득"
L["LOOT_METHOD_ROUND_ROBIN"] = "차례대로 획득"
L["LOOT_METHOD_MASTER"] = "전리품 담당자"
L["LOOT_METHOD_GROUP"] = "주사위 굴림"
L["LOOT_METHOD_NBG"] = "주사위 굴림 (착용자 우선)"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "하급만"
L["THRESHOLD_COMMON_LOWER"] = "일반 및 그 이하"
L["THRESHOLD_UNCOMMON_LOWER"] = "고급 및 그 이하"
L["THRESHOLD_RARE_LOWER"] = "희귀 및 그 이하"
L["THRESHOLD_EPIC_LOWER"] = "영웅 및 그 이하"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "일반"
L["GENERAL_DESC"] = "GogoLoot가 활성화되어 있을 때 적용되는 기본 설정입니다."
L["SPEEDY_LOOT"] = "빠른 획득 활성화"
L["SPEEDY_LOOT_DESC"] = "전리품 창을 표시하지 않고 즉시 전리품을 획득하여 시간을 절약합니다."

L["COMMANDS"] = "/명령어"
L["COMMANDS_DESC_GL"] = "GogoLoot 옵션 인터페이스를 엽니다."
L["COMMANDS_DESC_GOGOLOOT"] = "GogoLoot 옵션 인터페이스를 엽니다."

L["RESET"] = "초기화"
L["RESET_DESC"] = "모든 GogoLoot 설정을 지우고 각 옵션을 기본값으로 복원합니다."
L["RESET_ALL"] = "모든 GogoLoot 옵션 초기화"
L["RESET_CONFIRM"] = "모든 GogoLoot 설정을 기본값으로 초기화합니다. 이 작업은 되돌릴 수 옵습니다. 계속하시겠습니까?"

L["FEEDBACK_SUPPORT"] = "피드백 및 지원"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "불러오는 중... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "거래된 아이템, 마법부여, 골드를 포함하여 완료된 거래 요약을 채팅에 자동으로 게시합니다."
L["TRADE_ENABLE"] = "거래 알림 활성화"
L["TRADE_ENABLE_DESC"] = "거래가 완료되면 거래 요약을 게시합니다."
L["TRADE_CONDITION"] = "파티/공격대 상태일 때"
L["TRADE_CONDITION_DESC"] = "거래 알림이 활성화되는 시기를 제어합니다."
L["TRADE_CONDITION_ALWAYS"] = "항상"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "파티 또는 공격대일 때만"
L["TRADE_CONDITION_RAID_ONLY"] = "공격대일 때만"
L["TRADE_OUTPUT"] = "메시지 출력"
L["TRADE_OUTPUT_DESC"] = "거래 요약이 전송되는 위치입니다."
L["TRADE_OUTPUT_WHISPER"] = "귓속말"
L["TRADE_OUTPUT_GROUP"] = "파티 대화"
L["TRADE_OUTPUT_RAID"] = "공격대 대화"
L["TRADE_EXAMPLE"] = "예시: {rt4} [아이템 X] x2, [아이템 Y]을(를) Fathom에게 주었습니다. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "거래 알림"
L["TRADE_TOOLTIP_DESC"] = "이 거래가 완료되면 채팅에 요약을 게시합니다."
L["TRADE_TOOLTIP_OUTPUT"] = "현재 출력"
L["TRADE_CHECKBOX_LABEL"] = "알림"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "선택한 품질 이하의 획득 시 귀속이 아닌 아이템에 대해 자동으로 차상위를 굴립니다. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설 아이템은 항상 건너뜁니다. 획득 시 귀속 아이템은 임계값에 의해 자동으로 차상위가 굴려지지 않지만, 아래의 사용자 지정 주사위 목록을 통해 자동화할 수 있습니다."
L["ROLLS_ENABLE"] = "자동 주사위 활성화"
L["ROLLS_ENABLE_DESC"] = "임계값 이하의 대상 아이템에 대해 자동으로 차상위를 굴립니다."
L["ROLLS_THRESHOLD"] = "자동 차상위 임계값"
L["ROLLS_THRESHOLD_DESC"] = "이 품질 이하의 아이템은 자동으로 차상위가 굴려집니다."

L["ROLLS_CUSTOM_LIST"] = "사용자 지정 주사위 목록"
L["ROLLS_CUSTOM_LIST_DESC"] = "이 목록의 아이템은 임계값을 무시하는 고유한 주사위 규칙을 갖습니다. 스컬지석이나 악마의 룬 같은 획득 시 귀속 아이템을 자동화하는 유일한 방법입니다. 각 아이템을 수동 주사위, 차상위, 입찰 또는 포기로 설정하세요. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설은 설정과 관계없이 항상 건너뜁니다."
L["ROLLS_RESTORE_DEFAULTS"] = "기본 사용자 지정 주사위 목록 복원"
L["ROLLS_RESTORE_CONFIRM"] = "사용자 지정 주사위 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["ROLLS_ADD_ITEM_DESC"] = "아이템 ID를 입력하거나 아이템을 여기로 드래그하여 목록에 추가하세요."
L["ROLLS_ADD_ITEM"] = "아이템 추가"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "여기에 아이템 ID를 입력하거나 아이템 링크를 드래그하세요."
L["ROLLS_CHOOSE_ACTION"] = "이 아이템에 대한 자동 주사위 작업을 선택하세요."
L["ROLLS_REMOVE"] = "제거"
L["ROLLS_REMOVE_DESC"] = "사용자 지정 주사위 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "획득 방식 (읽기 전용, 게임 메뉴에서 변경)"
L["ML_LOOT_THRESHOLD"] = "획득 일치 (읽기 전용, 게임 메뉴에서 변경)"

L["ML_AUTO_HEADER"] = "자동 전리품 담당자"
L["ML_AUTO_DESC"] = "당신이 전리품 담당자일 때 지정된 플레이어에게 전리품을 자동으로 분배합니다. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설은 항상 건너뛰며 표준 전리품 창에 나타납니다."
L["ML_AUTO_ENABLE"] = "인스턴스에서 자동 전리품 담당자 활성화"
L["ML_AUTO_ENABLE_DESC"] = "구성된 대상에게 전리품을 자동으로 분배합니다."
L["ML_AUTO_OUTSIDE"] = "인스턴스 외부에서 자동 전리품 담당자 활성화"
L["ML_AUTO_OUTSIDE_CAUTION"] = "주의: 야외 우두머리 전리품은 거래할 수 없으므로 권장하지 않습니다!"

L["ML_DEST_HEADER"] = "전리품 대상"
L["ML_DEST_DESC"] = "각 품질 등급의 아이템을 받을 파티원을 할당하세요."
L["ML_DEST_SELF"] = "자신"
L["ML_DEST_CHOOSE"] = "%s 아이템을 받을 사람을 선택하세요."

L["ML_ANNOUNCE_HEADER"] = "전리품 알림"
L["ML_ANNOUNCE_DESC"] = "전리품 담당자를 통해 아이템이 분배되면 파티 대화에 메시지를 게시합니다. 수동 분배는 임계값에 관계없이 항상 알립니다."
L["ML_ANNOUNCE_ENABLE"] = "전리품 알림 활성화"
L["ML_ANNOUNCE_ENABLE_DESC"] = "파티 대화에 아이템 분배를 알립니다."
L["ML_ANNOUNCE_THRESHOLD"] = "알림 임계값"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "이 품질 이상의 아이템만 알립니다."
L["ML_ANNOUNCE_EXAMPLE"] = "예시: {rt4} [아이템 X]을(를) Gogowarrior에게 주었습니다. // GogoLoot"

L["ML_IGNORE_HEADER"] = "무시 목록"
L["ML_IGNORE_DESC"] = "이 목록의 아이템은 자동으로 분배되지 않으며 수동 할당을 위해 표준 전리품 창에 나타납니다."
L["ML_IGNORE_RESTORE"] = "기본 무시 목록 복원"
L["ML_IGNORE_RESTORE_CONFIRM"] = "전리품 담당자 무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["ML_IGNORE_ADD_DESC"] = "무시 목록에 추가하려면 아이템 ID를 입력하거나 아이템 링크를 붙여넣으세요."
L["ML_IGNORE_ADD"] = "아이템 추가"
L["ML_IGNORE_ADD_TOOLTIP"] = "아이템 ID를 입력하거나 아이템을 여기로 드래그하여 목록에 추가하세요."
L["ML_IGNORE_REMOVE"] = "제거"
L["ML_IGNORE_REMOVE_DESC"] = "무시 목록에서 이 아이템을 제거합니다."