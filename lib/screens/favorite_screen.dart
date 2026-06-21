import 'package:flutter/material.dart';
import '../model/favorite_model.dart';
import '../model/bible_models.dart';
import '../services/favorite_service.dart';
import '../screens/bible_reading_screen.dart';

// ── 정렬 모드 ─────────────────────────────────────────
enum _SortMode { recent, oldest, biblical }

// ── 보기 모드 ─────────────────────────────────────────
enum _ViewMode { list, grouped }

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteModel> _favorites = [];
  bool      _isLoading = true;
  _SortMode _sortMode  = _SortMode.recent;
  _ViewMode _viewMode  = _ViewMode.list;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await FavoriteService.getAll();
    if (mounted) setState(() { _favorites = list; _isLoading = false; });
  }

  Future<void> _delete(FavoriteModel fav) async {
    await FavoriteService.remove(fav.bookId, fav.chapter);
    final list = await FavoriteService.getAll();
    if (mounted) setState(() => _favorites = list);
  }

  BibleBookModel? _findBook(String bookId) {
    try {
      return [...oldTestament, ...newTestament]
          .firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
  }

  List<FavoriteModel> get _sorted {
    final list = [..._favorites];
    switch (_sortMode) {
      case _SortMode.recent:
        list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      case _SortMode.oldest:
        list.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      case _SortMode.biblical:
        list.sort((a, b) {
          final bc = a.bookNumber.compareTo(b.bookNumber);
          return bc != 0 ? bc : a.chapter.compareTo(b.chapter);
        });
    }
    return list;
  }

  // 책별 그룹 맵 (bookName → items)
  Map<String, List<FavoriteModel>> get _grouped {
    final result = <String, List<FavoriteModel>>{};
    for (final fav in _sorted) {
      result.putIfAbsent(fav.bookName, () => []).add(fav);
    }
    return result;
  }

  void _showSortSheet() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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

                // 보기 방식
                Text('보기 방식', style: tt.labelLarge?.copyWith(letterSpacing: 0.3)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ChipOption(
                      label: '목록',
                      icon: Icons.list_outlined,
                      selected: _viewMode == _ViewMode.list,
                      onTap: () {
                        setState(() => _viewMode = _ViewMode.list);
                        setSheet(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    _ChipOption(
                      label: '책별 그룹',
                      icon: Icons.folder_outlined,
                      selected: _viewMode == _ViewMode.grouped,
                      onTap: () {
                        setState(() => _viewMode = _ViewMode.grouped);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 정렬
                Text('정렬', style: tt.labelLarge?.copyWith(letterSpacing: 0.3)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _ChipOption(
                      label: '최근 저장순',
                      icon: Icons.access_time,
                      selected: _sortMode == _SortMode.recent,
                      onTap: () {
                        setState(() => _sortMode = _SortMode.recent);
                        setSheet(() {});
                      },
                    ),
                    _ChipOption(
                      label: '오래된 순',
                      icon: Icons.history,
                      selected: _sortMode == _SortMode.oldest,
                      onTap: () {
                        setState(() => _sortMode = _SortMode.oldest);
                        setSheet(() {});
                      },
                    ),
                    _ChipOption(
                      label: '성경 순서',
                      icon: Icons.menu_book_outlined,
                      selected: _sortMode == _SortMode.biblical,
                      onTap: () {
                        setState(() => _sortMode = _SortMode.biblical);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(FavoriteModel fav) {
    final book = _findBook(fav.bookId);
    if (book == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BibleReadingScreen(
          book:          book,
          chapterNumber: fav.chapter,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── 상단 바 ──────────────────────────────
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
                    child: Text('즐겨찾기', style: tt.headlineSmall),
                  ),
                  if (_favorites.isNotEmpty) ...[
                    Text('${_favorites.length}개', style: tt.labelMedium),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showSortSheet,
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune_outlined, size: 16, color: cs.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.6, color: cs.outline),

            // ── 정렬/보기 현황 칩 ──────────────────────
            if (_favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    _StatusChip(
                      label: _sortMode == _SortMode.recent  ? '최근 저장순'
                           : _sortMode == _SortMode.oldest  ? '오래된 순'
                           : '성경 순서',
                      icon: Icons.sort,
                    ),
                    const SizedBox(width: 6),
                    _StatusChip(
                      label: _viewMode == _ViewMode.list ? '목록' : '책별 그룹',
                      icon: _viewMode == _ViewMode.list
                          ? Icons.list_outlined
                          : Icons.folder_outlined,
                    ),
                  ],
                ),
              ),

            // ── 목록 ─────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: cs.primary))
                  : _favorites.isEmpty
                  ? _EmptyView()
                  : _viewMode == _ViewMode.list
                  ? _ListView(
                      items:      _sorted,
                      onTap:      _navigateTo,
                      onDelete:   _delete,
                    )
                  : _GroupedView(
                      grouped:    _grouped,
                      onTap:      _navigateTo,
                      onDelete:   _delete,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 목록 뷰 ───────────────────────────────────────────
class _ListView extends StatelessWidget {
  final List<FavoriteModel>            items;
  final ValueChanged<FavoriteModel>    onTap;
  final ValueChanged<FavoriteModel>    onDelete;

  const _ListView({
    required this.items,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: cs.outline),
      itemBuilder: (context, i) => _FavoriteRow(
        favorite: items[i],
        onTap:    () => onTap(items[i]),
        onDelete: () => onDelete(items[i]),
      ),
    );
  }
}

// ── 책별 그룹 뷰 ──────────────────────────────────────
class _GroupedView extends StatelessWidget {
  final Map<String, List<FavoriteModel>> grouped;
  final ValueChanged<FavoriteModel>      onTap;
  final ValueChanged<FavoriteModel>      onDelete;

  const _GroupedView({
    required this.grouped,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final bookName = entries[i].key;
        final items    = entries[i].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book_outlined,
                        size: 14, color: cs.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(bookName,
                      style: tt.titleSmall?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Text('${items.length}장',
                      style: tt.labelSmall?.copyWith(color: cs.secondary)),
                ],
              ),
            ),
            // 해당 책의 장 목록
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline, width: 0.5),
              ),
              child: Column(
                children: List.generate(items.length, (j) {
                  final fav = items[j];
                  final isLast = j == items.length - 1;
                  return Column(
                    children: [
                      _FavoriteRow(
                        favorite: fav,
                        onTap:    () => onTap(fav),
                        onDelete: () => onDelete(fav),
                        compact:  true,
                      ),
                      if (!isLast)
                        Divider(
                          height: 0.5, thickness: 0.5,
                          indent: 16, endIndent: 16,
                          color: cs.outline,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── 즐겨찾기 행 ───────────────────────────────────────
class _FavoriteRow extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback  onTap;
  final VoidCallback  onDelete;
  final bool          compact;

  const _FavoriteRow({
    required this.favorite,
    required this.onTap,
    required this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(favorite.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: compact ? BorderRadius.circular(12) : BorderRadius.zero,
        ),
        child: const Icon(Icons.delete_outline,
            color: Colors.redAccent, size: 20),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 0,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.star, size: 16, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact
                          ? '${favorite.chapter}장'
                          : '${favorite.bookName} ${favorite.chapter}장',
                      style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 2),
                      Text(favorite.bookEnglishName,
                          style: tt.labelMedium),
                    ],
                  ],
                ),
              ),
              Text(
                favorite.formattedDate,
                style: tt.labelSmall?.copyWith(color: cs.secondary),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 정렬/보기 현황 칩 ──────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String  label;
  final IconData icon;
  const _StatusChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.secondary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: cs.secondary)),
        ],
      ),
    );
  }
}

// ── 정렬/보기 선택 칩 ──────────────────────────────────
class _ChipOption extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _ChipOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: selected ? cs.onPrimary : cs.secondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? cs.onPrimary : cs.onSurface,
                )),
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
          Icon(Icons.star_outline, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text('즐겨찾기가 없어요',
              style: TextStyle(fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('성경 읽기 중 ★ 버튼을 눌러 저장하세요',
              style: TextStyle(fontSize: 12, color: cs.secondary)),
        ],
      ),
    );
  }
}
