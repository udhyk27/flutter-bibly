import '../screens/hymn_screen.dart';

const List<HymnModel> hymnList = [
  // ── 예배 ────────────────────────────────────────────
  HymnModel(
    number: 1,
    title: '만복의 근원 하나님',
    englishTitle: 'Praise God, from Whom All Blessings Flow',
    category: '예배',
    verses: [
      '만복의 근원 하나님\n온 백성 찬송 드리세\n하늘과 땅의 천사들\n다 찬양 드리세',
    ],
  ),
  HymnModel(
    number: 2,
    title: '다 감사드리세',
    englishTitle: 'Now Thank We All Our God',
    category: '예배',
    verses: [
      '다 감사드리세 마음과 손과 뜻으로\n놀라운 은혜를 우리에게 주셨네\n갓난아이 때부터 지금 이 시간까지\n복 주시고 인도하신 주께 감사드리세',
      '영원히 변찮는 그 성삼위일체\n그 은총이 우리에게 충만케 하소서\n온 세상 위에서 찬양 소리 울리고\n아멘 아멘 아멘으로 영광 돌리세',
    ],
  ),
  HymnModel(
    number: 9,
    title: '온 천하 만물 우러러',
    englishTitle: 'All Creatures of Our God and King',
    category: '예배',
    verses: [
      '온 천하 만물 우러러\n다 주를 찬양하여라\n할렐루야 할렐루야\n빛나는 저 태양도\n은빛의 저 달빛도\n찬양 찬양 할렐루야',
      '오 바람 구름 비와 눈\n다 주를 찬양하여라\n할렐루야 할렐루야\n어두움 지날 때에\n새 날을 맞이하며\n찬양 찬양 할렐루야',
      '온 세상 만민들이여\n다 주를 찬양하여라\n할렐루야 할렐루야\n용서받은 백성들\n마음 다해 노래해\n찬양 찬양 할렐루야',
    ],
  ),
  HymnModel(
    number: 14,
    title: '주 하나님께 감사해',
    englishTitle: 'Give Thanks to God on High',
    category: '예배',
    verses: [
      '주 하나님께 감사해\n선하심이 영원해\n아버지께 감사해\n선하심이 영원해\n이스라엘 백성들\n선하심이 영원해\n주의 집에 모인 자\n선하심이 영원해',
    ],
  ),

  // ── 찬양 ────────────────────────────────────────────
  HymnModel(
    number: 21,
    title: '찬양하라 복되신 구세주',
    englishTitle: 'Blessed Redeemer',
    category: '찬양',
    verses: [
      '찬양하라 복되신 구세주\n예수 내 왕 내 주님\n그 사랑 한없이 크셔라\n길이 찬양하리',
      '주 예수 나의 왕이시니\n나 주만 따르리라\n그 은혜 영원히 변찮아\n날 인도하시네',
    ],
    chorus: '찬양 찬양 복되신 구세주\n찬양 찬양 주 예수\n길이길이 찬양하리\n주 예수 나의 왕',
  ),
  HymnModel(
    number: 23,
    title: '기뻐하며 경배하세',
    englishTitle: 'Joyful, Joyful, We Adore Thee',
    category: '찬양',
    verses: [
      '기뻐하며 경배하세 주 하나님 크시다\n하늘 아버지 앞에 기쁨으로 나아가\n봄 꽃 같이 피어나고 빛 같이 비추시니\n영원하신 주 하나님 함께 찬양 드리세',
      '주의 영광 나타나니 죄악 떠나가도다\n세상 걱정 근심 두고 주를 향해 나아가\n진리 안에 자유 있고 사랑 안에 하나되어\n주를 영원 찬양하며 기쁨으로 섬기세',
    ],
  ),
  HymnModel(
    number: 32,
    title: '찬양 찬양 찬양',
    englishTitle: 'Praise Him! Praise Him!',
    category: '찬양',
    verses: [
      '찬양 찬양 찬양\n예수 우리 주를\n죄의 사슬 끊으신\n어린 양을 찬양해\n예수님은 바위시요\n우리의 요새시라\n온 세상이 그의 영광\n찬양 노래 불러라',
      '찬양 찬양 찬양\n예수 우리 구주\n죄인들의 친구이신\n참 구원자 찬양해\n주는 크신 목자시요\n우리를 사랑하사\n십자가에 피를 흘려\n구속하신 주 찬양',
    ],
    chorus: '찬양해 예수님\n찬양해 예수님\n천사들도 주 앞에서\n영광 돌려 찬양해',
  ),
  HymnModel(
    number: 64,
    title: '주 하나님 지으신 모든 세계',
    englishTitle: 'How Great Thou Art',
    category: '찬양',
    verses: [
      '주 하나님 지으신 모든 세계\n내 마음속에 그리어볼 때\n하늘의 별 울려 퍼지는 뇌성\n주님의 권능 우주에 찼네',
      '숲 속에서 지저귀는 새소리\n고요한 시냇물 소리 들릴 때\n저 높은 산 아름다운 꽃 향기\n주님의 솜씨 거기서 보네',
      '주 하나님 독생자를 보내사\n죄인인 나를 구원하셨네\n십자가에 달리신 그 모습이\n내 죄를 씻어 깨끗케 하네',
      '주 예수님 다시 오실 그 날에\n큰 나팔 소리 울려 퍼지고\n온 세상을 다스리실 그 영광\n내 영혼 주를 찬양하리라',
    ],
    chorus: '내 주님 얼마나 크신지\n내 주님 얼마나 크신지\n내 영혼이 주를 찬양 드리네\n내 주님 얼마나 크신지',
  ),
  HymnModel(
    number: 76,
    title: '저 높고 푸른 하늘과',
    englishTitle: 'This Is My Father\'s World',
    category: '찬양',
    verses: [
      '저 높고 푸른 하늘과\n저 수많은 별들도\n저 넓고 넓은 바다와\n저 산들도 다 주님의 것',
      '저 바람 산들 불어도\n저 물결 잔잔해도\n이 모든 것이 다 주님의\n손으로 만든 것이라',
    ],
    chorus: '이 세상 내 아버지의 것\n내 아버지의 것\n이 넓은 세상 모두 다\n내 아버지의 것',
  ),

  // ── 기도 ────────────────────────────────────────────
  HymnModel(
    number: 93,
    title: '내 주를 가까이 하게 함은',
    englishTitle: 'Nearer, My God, to Thee',
    category: '기도',
    verses: [
      '내 주를 가까이 하게 함은\n십자가 짐 같은 고생이나\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
      '내 고생하는 것 옳다 하고\n성도가 모두 찬양할 때에\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
      '천사가 나를 부를 때에\n하늘의 나팔 울릴 때에\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
    ],
    chorus: '주께 더 나아가\n주께 더 나아가\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
  ),
  HymnModel(
    number: 364,
    title: '기도하는 이 시간',
    englishTitle: 'Sweet Hour of Prayer',
    category: '기도',
    verses: [
      '기도하는 이 시간\n주께 나아갑니다\n이 세상 고락 간에\n내 짐을 맡겨요\n내 맘에 어둠을 빛으로 바꾸사\n주여 나를 살피사 돌보아 주소서',
      '기도하는 이 시간\n죄짐을 내려요\n주 앞에 무릎 꿇고\n자복하오리다\n허물을 용서하사 새롭게 하시고\n주여 나를 살피사 돌보아 주소서',
      '기도하는 이 시간\n주 은혜 구해요\n세상을 이기도록\n능력을 주소서\n험한 이 세상 길을 무사히 지나서\n주여 나를 살피사 돌보아 주소서',
    ],
  ),
  HymnModel(
    number: 473,
    title: '내가 매일 기쁘게',
    englishTitle: 'Sunlight, Sunlight',
    category: '기도',
    verses: [
      '내가 매일 기쁘게 순례의 길 행함은\n주의 팔이 나를 안보함이라\n내가 주를 찬양해 내 입술을 열어서\n주의 영광 노래해 영원히',
      '어두운 밤 밝히고 빛이 비쳐올 때에\n주의 팔이 나를 안보함이라\n험한 세상 지나며 주 은혜를 받아서\n주의 영광 노래해 영원히',
    ],
    chorus: '주의 영광 빛이 온 세상 비추니\n내 모든 죄 사함을 받았네\n날마다 기쁘게 주 얼굴 보오니\n주의 영광 노래해 영원히',
  ),

  // ── 말씀 ────────────────────────────────────────────
  HymnModel(
    number: 200,
    title: '주의 말씀 듣고서',
    englishTitle: 'Break Thou the Bread of Life',
    category: '말씀',
    verses: [
      '주의 말씀 듣고서 생명 얻었으니\n그 생명의 떡으로 날마다 먹이소\n주의 성령 임하사 내 눈 밝혀 주시고\n주의 말씀 속에서 주를 만나게 하소',
      '주의 말씀 내 양식 주의 말씀 내 빛\n내 영혼이 주리니 주께 나아갑니다\n주의 보혈 안에서 죄를 씻어 주시고\n주의 말씀 통하여 새 힘 얻게 하소서',
    ],
  ),
  HymnModel(
    number: 234,
    title: '성경은 내게 주신 하나님의 책',
    englishTitle: 'Holy Bible, Book Divine',
    category: '말씀',
    verses: [
      '성경은 내게 주신 하나님의 책\n이 진리의 보배 내 삶의 빛이라\n이 책에서 생명의 길 내가 배우며\n날마다 이 말씀이 내 힘이 되네',
      '성경은 하나님의 살아있는 말씀\n내 영혼을 살리는 은혜의 보화\n이 책을 묵상하며 매일 살아갈 때\n주님의 사랑이 내 마음 채우네',
    ],
  ),
  HymnModel(
    number: 405,
    title: '예수 사랑하심은',
    englishTitle: 'Jesus Loves Me',
    category: '말씀',
    verses: [
      '예수 사랑하심은\n거룩하신 말씀에\n어린 우리들을\n품어 안으심이라',
      '내가 연약할수록\n더욱 귀히 여기사\n하늘 나라 오도록\n성령 인도하시네',
      '내가 주를 사랑해\n주는 나를 사랑해\n하늘나라 가는 날\n주를 만나게 되리',
    ],
    chorus: '날 사랑하심\n날 사랑하심\n날 사랑하심\n성경에 써 있네',
  ),

  // ── 감사 ────────────────────────────────────────────
  HymnModel(
    number: 310,
    title: '아 하나님의 은혜로',
    englishTitle: 'Grace Greater Than Our Sin',
    category: '감사',
    verses: [
      '아 하나님의 은혜로\n이 죄인 살았네\n주 예수 내게 오셔서\n내 죄 씻으셨네',
      '아 크고 놀라운 사랑\n한없는 그 사랑\n나 같은 죄인 살리려\n십자가 지셨네',
    ],
    chorus: '은혜 은혜 내게 넘치는 은혜\n높고 높은 하늘 보다 크신 은혜\n내 죄보다 넓고 깊은 은혜\n아 하나님의 은혜로 살았네',
  ),
  HymnModel(
    number: 569,
    title: '이 세상 험하고',
    englishTitle: 'This World Is Not My Home',
    category: '감사',
    verses: [
      '이 세상 험하고 물결이 거세도\n주님만 믿으면 두렵지 않아\n고난이 닥쳐도 십자가 붙들면\n주님이 인도해 주실 것을 믿어',
      '주 예수 오실 때 나팔이 울리고\n만성도 모두 다 주를 만날 때\n우리가 변하여 영광 받을 날에\n감사와 찬양을 영원 드리리',
    ],
    chorus: '주 예수 내 손 잡으시고\n천국 길 인도하시네\n눈물도 없는 그 나라\n주와 함께 가리라',
  ),
  HymnModel(
    number: 590,
    title: '감사해 감사해',
    englishTitle: 'Give Thanks',
    category: '감사',
    verses: [
      '감사해 감사해 주 안에서 감사해\n감사해 감사해 주 안에서 감사해\n주의 선하심 자비하심\n크신 사랑 감사해\n주의 선하심 자비하심\n오늘도 감사해',
    ],
  ),
  HymnModel(
    number: 600,
    title: '내게 강 같은 평화',
    englishTitle: 'It Is Well with My Soul',
    category: '감사',
    verses: [
      '내게 강 같은 평화\n내게 강 같은 평화\n내게 강 같은 평화\n충만하게 하소서',
      '내게 샘솟는 기쁨\n내게 샘솟는 기쁨\n내게 샘솟는 기쁨\n충만하게 하소서',
      '내게 불같은 사랑\n내게 불같은 사랑\n내게 불같은 사랑\n충만하게 하소서',
    ],
  ),

  // ── 전도 ────────────────────────────────────────────
  HymnModel(
    number: 190,
    title: '주 예수보다 더 귀한 것은 없네',
    englishTitle: 'No, Not One',
    category: '전도',
    verses: [
      '주 예수보다 더 귀한 것은 없네\n세상 부귀와 바꿀 수 없어\n주 예수보다 더 귀한 것은 없네\n세상 부귀와 바꿀 수 없어',
      '세상 즐거움 다 버리고\n주 예수 따라가네\n주 예수보다 더 귀한 것은 없네\n세상 부귀와 바꿀 수 없어',
    ],
  ),
  HymnModel(
    number: 252,
    title: '어서 돌아오오',
    englishTitle: 'Softly and Tenderly',
    category: '전도',
    verses: [
      '어서 돌아오오 주 예수 부르시네\n집 나간 자녀들 돌아오라\n주의 사랑의 음성 귀에 들리니\n집 나간 자녀들 돌아오라',
      '인생이 지나가고 죽음이 다가와\n불쌍히 여기사 부르시네\n오 주의 부르심 듣는 이 시간에\n집 나간 자녀들 돌아오라',
    ],
    chorus: '돌아오오 돌아오오\n집 나간 자녀들 돌아오라\n돌아오오 돌아오오\n주 예수 품으로 돌아오라',
  ),
  HymnModel(
    number: 261,
    title: '저 죄인 살리려',
    englishTitle: 'The Old Rugged Cross',
    category: '전도',
    verses: [
      '저 죄인 살리려 험한 십자가에\n주 예수 달리셨네\n온 세상 죄짐을 지시고 죽으신\n그 사랑 한없도다',
      '날마다 슬픔의 짐을 지시고\n험한 갈보리 산\n내 죄를 깨끗이 씻으려 피 흘린\n그 고통 잊으리오',
    ],
    chorus: '그 험한 십자가 내가 사랑해\n주 예수 달리신 곳\n그 보혈 힘입어 죄 씻음 받고\n영광의 면류관 쓰리',
  ),

  // ── 위로 ────────────────────────────────────────────
  HymnModel(
    number: 410,
    title: '내 영혼의 그윽히 깊은 데서',
    englishTitle: 'Like a River Glorious',
    category: '위로',
    verses: [
      '내 영혼의 그윽히 깊은 데서\n늘 흘러나는 평화의 강\n그 물결이 쉬지 않고 흘러\n내 마음에 부드럽게 닿네',
      '주님의 품에 아늑히 안기어\n영원한 평화 누리게 하소\n세상 풍파 모두 다 지나가도\n주의 평화 내 맘에 넘치네',
    ],
    chorus: '평화 평화로다\n하늘 위에서 내려오는 평화\n믿음으로 주께 나아오면\n평화의 강이 넘치리',
  ),
  HymnModel(
    number: 492,
    title: '주 안에 있는 나에게',
    englishTitle: 'Blessed Assurance',
    category: '위로',
    verses: [
      '주 안에 있는 나에게\n이제 근심 없도다\n주 피로 정케 됨으로\n큰 기쁨 누리네',
      '주 안에 거하는 자마다\n복락이 충만하다\n그 팔에 안기어 있으니\n넉넉히 쉬리라',
      '영원한 나라 향하여\n이 세상 지나는 동안\n주 예수 함께하시니\n넉넉히 이기네',
    ],
    chorus: '이것이 나의 간증이요\n이것이 나의 찬송일세\n나 구원받은 그 날부터\n주 찬양하리로다',
  ),
  HymnModel(
    number: 543,
    title: '나 어느 곳에 있든지',
    englishTitle: 'No, Never Alone',
    category: '위로',
    verses: [
      '나 어느 곳에 있든지\n주 예수 함께하시네\n이 세상 험한 길 가도\n주 나를 지키시네',
      '두려운 밤이 다가도\n주 예수 함께하시네\n빛 같이 나를 비추사\n새 힘을 주시네',
    ],
    chorus: '나 혼자 걷지 않네\n나 혼자 걷지 않네\n주 예수 함께하시니\n나 혼자 걷지 않네',
  ),
];
