import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/app_router.dart';
import '../data/hymn_data.dart';
import '../services/hymn_favorite_service.dart';

class HymnScreen extends StatefulWidget {
  const HymnScreen({super.key});

  @override
  State<HymnScreen> createState() => _HymnScreenState();
}

class _HymnScreenState extends State<HymnScreen> {
  String   _selectedCategory  = '전체';
  String   _searchQuery       = '';
  bool     _showFavoritesOnly = false;
  Set<int> _favoriteNumbers   = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await HymnFavoriteService.getAll();
    if (mounted) setState(() => _favoriteNumbers = favs);
  }

  void _toggleFavoritesOnly() {
    _loadFavorites();
    setState(() => _showFavoritesOnly = !_showFavoritesOnly);
  }

  @override
  Widget build(BuildContext context) {

    final filtered = hymnList.where((h) {
      final matchFav    = !_showFavoritesOnly || _favoriteNumbers.contains(h.number);
      final matchCat    = _selectedCategory == '전체' || h.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          h.title.contains(_searchQuery) ||
          h.englishTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.number.toString().contains(_searchQuery);
      return matchFav && matchCat && matchSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HymnTopBar(
              showFavoritesOnly: _showFavoritesOnly,
              onToggleFavorites: _toggleFavoritesOnly,
            ),
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
  final bool showFavoritesOnly;
  final VoidCallback onToggleFavorites;
  const _HymnTopBar({
    required this.showFavoritesOnly,
    required this.onToggleFavorites,
  });

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
              Text('${hymnList.length}장 수록', style: tt.labelMedium),
            ],
          ),
          GestureDetector(
            onTap: onToggleFavorites,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: showFavoritesOnly ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                showFavoritesOnly ? Icons.star : Icons.star_outline,
                size: 18,
                color: showFavoritesOnly ? cs.onPrimary : cs.primary,
              ),
            ),
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
        separatorBuilder: (_, _) => const SizedBox(width: 6),
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
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    HymnFavoriteService.isFavorite(widget.hymn.number).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
  }

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
              onTap: () async {
                final next = await HymnFavoriteService.toggle(widget.hymn.number);
                if (mounted) setState(() => _isFavorite = next);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_outline,
                  size: 18,
                  color: _isFavorite ? Colors.amber : cs.outline,
                ),
              ),
            ),

            // 재생 버튼 — 상세 화면으로 이동하며 자동 재생
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                AppRouter.slide(
                  page: HymnDetailScreen(hymn: widget.hymn, autoPlay: true),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 18,
                  color: cs.primary,
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
  final bool      autoPlay;
  const HymnDetailScreen({super.key, required this.hymn, this.autoPlay = false});

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool   _isPlaying    = false;
  int    _currentVerse = 0;
  double _fontSize     = 17;

  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.92);
    _tts.setCompletionHandler(_onVerseComplete);
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  void _onVerseComplete() {
    if (!mounted || !_isPlaying) return;
    // 후렴이 있으면 절 뒤에 후렴 낭독
    if (widget.hymn.chorus != null) {
      _tts.speak(widget.hymn.chorus!).then((_) {
        _advanceVerse();
      });
    } else {
      _advanceVerse();
    }
  }

  void _advanceVerse() {
    if (!mounted || !_isPlaying) return;
    if (_currentVerse < widget.hymn.verses.length - 1) {
      setState(() => _currentVerse++);
      _tts.speak(widget.hymn.verses[_currentVerse]);
    } else {
      // 마지막 절 완료
      setState(() {
        _isPlaying    = false;
        _currentVerse = 0;
      });
    }
  }

  Future<void> _play() async {
    setState(() => _isPlaying = true);
    await _tts.speak(widget.hymn.verses[_currentVerse]);
  }

  Future<void> _pause() async {
    await _tts.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  Future<void> _goToVerse(int index) async {
    final wasPlaying = _isPlaying;
    await _tts.stop();
    setState(() {
      _currentVerse = index;
      _isPlaying    = false;
    });
    if (wasPlaying) await _play();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

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
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final isSelected = _currentVerse == i;
                    return GestureDetector(
                      onTap: () => _goToVerse(i),
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
                  ? () => _goToVerse(_currentVerse - 1)
                  : null,
              onNextVerse: _currentVerse < widget.hymn.verses.length - 1
                  ? () => _goToVerse(_currentVerse + 1)
                  : null,
              onPlayPause: _togglePlayPause,
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

