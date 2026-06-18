import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/bible_models.dart';
import '../screens/bible_reading_screen.dart';
import '../services/bible_prefetch_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();

  List<_SearchResult> _results       = [];
  bool                _searched      = false;
  bool                _loading       = false;
  bool                _prefetching   = false;
  int                 _prefetchDone  = 0;
  int                 _prefetchTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _startPrefetch() async {
    if (_prefetching) return;
    setState(() {
      _prefetching   = true;
      _prefetchDone  = 0;
      _prefetchTotal = 0;
    });
    await BiblePrefetchService.prefetchAll(
      onProgress: (done, total) {
        if (mounted) setState(() { _prefetchDone = done; _prefetchTotal = total; });
      },
    );
    if (mounted) setState(() => _prefetching = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() { _loading = true; _searched = true; });

    final results = <_SearchResult>[];
    final box     = Hive.box('bible_cache');
    final allBooks = [...oldTestament, ...newTestament];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;

      try {
        // 키 형식: "korean-{bookNumber}-{chapter}"
        final parts      = (key as String).split('-');
        if (parts.length < 3) continue;

        final bookNumber = int.tryParse(parts[1]);
        final chapterNum = int.tryParse(parts[2]);
        if (bookNumber == null || chapterNum == null) continue;

        // 책 정보를 키에서 파싱 (fromJson의 book 필드 신뢰 안 함)
        final book = allBooks.firstWhere(
              (b) => b.number == bookNumber,
          orElse: () => const BibleBookModel(
            number: 0, id: '', name: '', nameLong: '',
            englishName: '', genre: '', totalChapters: 0,
          ),
        );
        if (book.number == 0) continue;

        // 절 목록만 파싱
        final data    = jsonDecode(raw as String) as Map<String, dynamic>;
        final chapter = BibleChapterModel.fromJson(data);

        for (final verse in chapter.verses) {
          if (verse.text.contains(q)) {
            results.add(_SearchResult(
              book:    book,
              chapter: chapterNum,
              verse:   verse.verse,
              text:    verse.text,
              query:   q,
            ));
          }
        }
      } catch (e) {
        debugPrint('검색 파싱 오류 ($key): $e');
        continue;
      }
    }

    // 책 순서 → 장 → 절 순 정렬
    results.sort((a, b) {
      final bc = a.book.number.compareTo(b.book.number);
      if (bc != 0) return bc;
      final cc = a.chapter.compareTo(b.chapter);
      if (cc != 0) return cc;
      return a.verse.compareTo(b.verse);
    });

    setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios,
                        size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller:      _controller,
                        focusNode:       _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted:     _search,
                        style: TextStyle(
                            fontSize: 14, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: '키워드를 입력하세요',
                          hintStyle: TextStyle(
                              fontSize: 14, color: cs.outline),
                          prefixIcon: Icon(Icons.search,
                              size: 18, color: cs.secondary),
                          suffixIcon: _controller.text.isNotEmpty
                              ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() {
                                _results  = [];
                                _searched = false;
                              });
                            },
                            child: Icon(Icons.close,
                                size: 16, color: cs.secondary),
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _search(_controller.text),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('검색',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimary,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.6, color: cs.outline),

            // 결과
            Expanded(
              child: _loading
                  ? Center(
                  child: CircularProgressIndicator(
                      color: cs.primary))
                  : !_searched
                  ? _HintView(
                      prefetching:   _prefetching,
                      prefetchDone:  _prefetchDone,
                      prefetchTotal: _prefetchTotal,
                      onPrefetch:    _startPrefetch,
                    )
                  : _results.isEmpty
                  ? _EmptyView(
                      query:         _controller.text,
                      prefetching:   _prefetching,
                      prefetchDone:  _prefetchDone,
                      prefetchTotal: _prefetchTotal,
                      onPrefetch:    _startPrefetch,
                    )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 14, 20, 8),
                    child: Text(
                      '${_results.length}개의 결과',
                      style: tt.labelMedium,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 40),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: cs.outline),
                      itemBuilder: (context, index) =>
                          _ResultRow(result: _results[index]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 검색 결과 행 ─────────────────────────────────────
class _ResultRow extends StatelessWidget {
  final _SearchResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BibleReadingScreen(
            book:          result.book,
            chapterNumber: result.chapter,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${result.book.name} ${result.chapter}:${result.verse}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(result.book.genre, style: tt.labelSmall),
              ],
            ),
            const SizedBox(height: 8),
            _HighlightText(
              text:  result.text,
              query: result.query,
              cs:    cs,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 키워드 하이라이트 ────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String      text;
  final String      query;
  final ColorScheme cs;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: TextStyle(
              fontSize: 14, color: cs.onSurface, height: 1.6));
    }

    final spans  = <TextSpan>[];
    final lower  = text.toLowerCase();
    final qLower = query.toLowerCase();
    int   start  = 0;

    while (true) {
      final idx = lower.indexOf(qLower, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          color:           cs.primary,
          fontWeight:      FontWeight.w700,
          backgroundColor: cs.primary.withValues(alpha: 0.1),
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: 14, color: cs.onSurface, height: 1.6),
        children: spans,
      ),
    );
  }
}

// ── 초기 안내 ────────────────────────────────────────
class _HintView extends StatelessWidget {
  final bool         prefetching;
  final int          prefetchDone;
  final int          prefetchTotal;
  final VoidCallback onPrefetch;

  const _HintView({
    required this.prefetching,
    required this.prefetchDone,
    required this.prefetchTotal,
    required this.onPrefetch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: cs.outline),
            const SizedBox(height: 12),
            Text('말씀을 검색해보세요',
                style: TextStyle(fontSize: 15, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text('캐시된 장에서 검색됩니다',
                style: TextStyle(fontSize: 12, color: cs.secondary)),
            const SizedBox(height: 20),
            _PrefetchButton(
              prefetching:   prefetching,
              prefetchDone:  prefetchDone,
              prefetchTotal: prefetchTotal,
              onPrefetch:    onPrefetch,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 결과 없음 ────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final String       query;
  final bool         prefetching;
  final int          prefetchDone;
  final int          prefetchTotal;
  final VoidCallback onPrefetch;

  const _EmptyView({
    required this.query,
    required this.prefetching,
    required this.prefetchDone,
    required this.prefetchTotal,
    required this.onPrefetch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: cs.outline),
            const SizedBox(height: 12),
            Text('"$query" 검색 결과가 없어요',
                style: TextStyle(fontSize: 15, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text('전체 성경을 다운로드하면 더 넓게 검색할 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: cs.secondary)),
            const SizedBox(height: 20),
            _PrefetchButton(
              prefetching:   prefetching,
              prefetchDone:  prefetchDone,
              prefetchTotal: prefetchTotal,
              onPrefetch:    onPrefetch,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 전체 다운로드 버튼 ────────────────────────────────
class _PrefetchButton extends StatelessWidget {
  final bool         prefetching;
  final int          prefetchDone;
  final int          prefetchTotal;
  final VoidCallback onPrefetch;

  const _PrefetchButton({
    required this.prefetching,
    required this.prefetchDone,
    required this.prefetchTotal,
    required this.onPrefetch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (prefetching) {
      final progress = prefetchTotal > 0
          ? prefetchDone / prefetchTotal
          : 0.0;
      return Column(
        children: [
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              value:            progress,
              backgroundColor:  cs.surfaceContainerHighest,
              color:            cs.primary,
              borderRadius:     BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$prefetchDone / $prefetchTotal 장',
            style: TextStyle(fontSize: 12, color: cs.secondary),
          ),
        ],
      );
    }

    final (cached, total) = BiblePrefetchService.getCoverage();
    if (cached >= total) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: cs.primary),
          const SizedBox(width: 4),
          Text('전체 성경 다운로드 완료',
              style: TextStyle(fontSize: 12, color: cs.primary)),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: onPrefetch,
      icon: const Icon(Icons.download_outlined, size: 16),
      label: Text('전체 성경 다운로드 ($cached/$total장 캐시됨)'),
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── 검색 결과 모델 ───────────────────────────────────
class _SearchResult {
  final BibleBookModel book;
  final int            chapter;
  final int            verse;
  final String         text;
  final String         query;

  const _SearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.query,
  });
}