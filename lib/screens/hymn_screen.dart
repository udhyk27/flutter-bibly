import 'package:flutter/material.dart';
import '../core/app_router.dart';

class HymnScreen extends StatefulWidget {
  const HymnScreen({super.key});

  @override
  State<HymnScreen> createState() => _HymnScreenState();
}

class _HymnScreenState extends State<HymnScreen> {
  String _selectedCategory = '전체';
  String _searchQuery      = '';

  @override
  Widget build(BuildContext context) {

    final filtered = _hymnList.where((h) {
      final matchCat    = _selectedCategory == '전체' || h.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          h.title.contains(_searchQuery) ||
          h.englishTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.number.toString().contains(_searchQuery);
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HymnTopBar(),
            _HymnSearchBar(onChanged: (q) => setState(() => _searchQuery = q)),
            _CategoryFilter(
              selected: _selectedCategory,
              onSelect: (c) => setState(() => _selectedCategory = c),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyView()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length + 1,
                itemBuilder: (context, index) {
                  if (index == filtered.length) {
                    return const SizedBox(height: 20);
                  }
                  final hymn        = filtered[index];
                  final showHeader  = index == 0 ||
                      filtered[index - 1].category != hymn.category;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showHeader && _selectedCategory == '전체')
                        _CategoryHeader(category: hymn.category),
                      _HymnRow(hymn: hymn),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상단 바 ──────────────────────────────────────────
class _HymnTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('찬송가', style: tt.headlineSmall),
              Text('${_hymnList.length}장 수록', style: tt.labelMedium),
            ],
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sort_outlined, size: 18, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// ── 검색창 ──────────────────────────────────────────
class _HymnSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _HymnSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: cs.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: '찬송가 번호, 제목으로 검색',
                  hintStyle: TextStyle(fontSize: 13, color: cs.secondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(fontSize: 13, color: cs.onSurface),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 필터 ──────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryFilter({required this.selected, required this.onSelect});

  static const _categories = ['전체', '예배', '찬양', '기도', '말씀', '감사', '전도', '위로'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final isSelected = _categories[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(_categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? cs.onPrimary : cs.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 카테고리 헤더 ──────────────────────────────────────
class _CategoryHeader extends StatelessWidget {
  final String category;
  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── 찬송가 행 ──────────────────────────────────────────
class _HymnRow extends StatefulWidget {
  final HymnModel hymn;
  const _HymnRow({required this.hymn});

  @override
  State<_HymnRow> createState() => _HymnRowState();
}

class _HymnRowState extends State<_HymnRow> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.slide(page: HymnDetailScreen(hymn: widget.hymn)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outline, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // 번호 배지
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.hymn.number}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.hymn.title, style: tt.bodyMedium),
                  Text(widget.hymn.englishTitle, style: tt.labelMedium),
                ],
              ),
            ),

            // 즐겨찾기
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.star_outline,
                  size: 18,
                  color: cs.outline,
                ),
              ),
            ),

            // 재생 버튼
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _isPlaying ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 18,
                  color: _isPlaying ? cs.onPrimary : cs.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 빈 화면 ──────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text(
            '검색 결과가 없어요',
            style: TextStyle(fontSize: 15, color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            '다른 검색어나 카테고리를 시도해보세요',
            style: TextStyle(fontSize: 12, color: cs.secondary),
          ),
        ],
      ),
    );
  }
}

// ── 찬송가 상세 화면 ──────────────────────────────────
class HymnDetailScreen extends StatefulWidget {
  final HymnModel hymn;
  const HymnDetailScreen({super.key, required this.hymn});

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool   _isPlaying = false;
  int    _currentVerse = 0; // 현재 절
  double _fontSize  = 17;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hymn.title, style: tt.titleLarge),
                        Text('${widget.hymn.number}장 · ${widget.hymn.category}',
                            style: tt.labelMedium),
                      ],
                    ),
                  ),
                  // 글씨 크기 조절
                  GestureDetector(
                    onTap: () => _showFontSheet(context),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.text_fields_outlined,
                          size: 18, color: cs.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 즐겨찾기
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.star_outline,
                        size: 18, color: cs.primary),
                  ),
                ],
              ),
            ),

            // 절 탭 선택
            if (widget.hymn.verses.length > 1) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.hymn.verses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final isSelected = _currentVerse == i;
                    return GestureDetector(
                      onTap: () => setState(() => _currentVerse = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${i + 1}절', style: isSelected
                            ? tt.labelLarge?.copyWith(color: cs.onPrimary)
                            : tt.labelMedium),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 가사
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 현재 절 가사
                    Text(widget.hymn.verses[_currentVerse], style: TextStyle(
                      fontSize: _fontSize,   // 슬라이더 유지
                      color: cs.onSurface,
                      height: 2.0,
                      fontFamily: 'Georgia',
                    )),

                    // 후렴 (있을 경우)
                    if (widget.hymn.chorus != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('후렴', style: tt.labelLarge?.copyWith(letterSpacing: 0.3)),
                            const SizedBox(height: 10),
                            Text(
                              widget.hymn.chorus!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _fontSize,
                                color: cs.onSurface,
                                height: 2.0,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 재생 컨트롤
            _PlayerBar(
              isPlaying: _isPlaying,
              hymnNumber: widget.hymn.number,
              onPrevVerse: _currentVerse > 0
                  ? () => setState(() => _currentVerse--)
                  : null,
              onNextVerse: _currentVerse < widget.hymn.verses.length - 1
                  ? () => setState(() => _currentVerse++)
                  : null,
              onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('글씨 크기',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('크기',
                      style: TextStyle(fontSize: 14, color: cs.onSurface)),
                  Text('${_fontSize.toInt()}px',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: cs.primary)),
                ],
              ),
              Slider(
                value: _fontSize,
                min: 12, max: 26, divisions: 7,
                activeColor: cs.primary,
                inactiveColor: cs.surfaceContainerHighest,
                onChanged: (v) {
                  setSheet(() {});
                  setState(() => _fontSize = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 재생 바 ──────────────────────────────────────────
class _PlayerBar extends StatelessWidget {
  final bool       isPlaying;
  final int        hymnNumber;
  final VoidCallback? onPrevVerse;
  final VoidCallback? onNextVerse;
  final VoidCallback  onPlayPause;

  const _PlayerBar({
    required this.isPlaying,
    required this.hymnNumber,
    required this.onPlayPause,
    this.onPrevVerse,
    this.onNextVerse,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 절
          GestureDetector(
            onTap: onPrevVerse,
            child: Icon(
              Icons.skip_previous_rounded,
              size: 32,
              color: onPrevVerse != null ? cs.primary : cs.outline,
            ),
          ),

          // 재생/정지
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                size: 30,
                color: cs.onPrimary,
              ),
            ),
          ),

          // 다음 절
          GestureDetector(
            onTap: onNextVerse,
            child: Icon(
              Icons.skip_next_rounded,
              size: 32,
              color: onNextVerse != null ? cs.primary : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 데이터 모델 ────────────────────────────────────────
class HymnModel {
  final int          number;
  final String       title;
  final String       englishTitle;
  final String       category;
  final List<String> verses;
  final String?      chorus;

  const HymnModel({
    required this.number,
    required this.title,
    required this.englishTitle,
    required this.category,
    required this.verses,
    this.chorus,
  });
}

// ── 샘플 데이터 ────────────────────────────────────────
// 실제 찬송가 가사는 저작권 확인 후 추가 필요
const List<HymnModel> _hymnList = [
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
    number: 93,
    title: '내 주를 가까이 하게 함은',
    englishTitle: 'Nearer, My God, to Thee',
    category: '기도',
    verses: [
      '내 주를 가까이 하게 함은\n십자가 짐 같은 고생이나\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
      '내 고생하는 것 옳다 하고\n성도가 모두 찬양할 때에\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
    ],
    chorus: '주께 더 나아가\n주께 더 나아가\n내 일생 소원은 늘 찬송하면서\n주께 더 나아가기 원하네',
  ),
  HymnModel(
    number: 405,
    title: '예수 사랑하심은',
    englishTitle: 'Jesus Loves Me',
    category: '말씀',
    verses: [
      '예수 사랑하심은\n거룩하신 말씀에\n어린 우리들을\n품어 안으심이라',
      '내가 연약할수록\n더욱 귀히 여기사\n하늘 나라 오도록\n성령 인도하시네',
    ],
    chorus: '날 사랑하심\n날 사랑하심\n날 사랑하심\n성경에 써 있네',
  ),
  HymnModel(
    number: 310,
    title: '아 하나님의 은혜로',
    englishTitle: 'Grace Greater Than Our Sin',
    category: '감사',
    verses: [
      '아 하나님의 은혜로\n이 죄인 살았네\n주 예수 내게 오셔서\n내 죄 씻으셨네',
    ],
    chorus: '은혜 은혜 내게 넘치는 은혜\n높고 높은 하늘 보다 크신 은혜\n내 죄보다 넓고 깊은 은혜\n아 하나님의 은혜로 살았네',
  ),
  HymnModel(
    number: 492,
    title: '주 안에 있는 나에게',
    englishTitle: 'Blessed Assurance',
    category: '위로',
    verses: [
      '주 안에 있는 나에게\n이제 근심 없도다\n주 피로 정케 됨으로\n큰 기쁨 누리네',
      '주 안에 거하는 자마다\n복락이 충만하다\n그 팔에 안기어 있으니\n넉넉히 쉬리라',
    ],
    chorus: '이것이 나의 간증이요\n이것이 나의 찬송일세\n나 구원받은 그 날부터\n주 찬양하리로다',
  ),
  HymnModel(
    number: 190,
    title: '주 예수보다 더 귀한 것은 없네',
    englishTitle: 'No, Not One',
    category: '전도',
    verses: [
      '주 예수보다 더 귀한 것은 없네\n세상 부귀와 바꿀 수 없어\n주 예수보다 더 귀한 것은 없네\n세상 부귀와 바꿀 수 없어',
    ],
  ),
];