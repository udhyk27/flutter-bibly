import 'package:flutter/material.dart';
import '../model/favorite_model.dart';
import '../model/bible_models.dart';
import '../services/favorite_service.dart';
import '../screens/bible_reading_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteModel> _favorites = [];
  bool _isLoading = true;

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
    await _load();
  }

  BibleBookModel? _findBook(String bookId) {
    try {
      return [...oldTestament, ...newTestament]
          .firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios,
                        size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('즐겨찾기',
                        style: tt.headlineSmall),
                  ),
                  if (_favorites.isNotEmpty)
                    Text('${_favorites.length}개',
                        style: tt.labelMedium),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.6, color: cs.outline),

            // 목록
            Expanded(
              child: _isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                      color: cs.primary))
                  : _favorites.isEmpty
                  ? _EmptyView()
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                itemCount: _favorites.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: cs.outline),
                itemBuilder: (context, index) {
                  final fav = _favorites[index];
                  return _FavoriteRow(
                    favorite: fav,
                    onTap: () {
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
                    },
                    onDelete: () => _delete(fav),
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

// ── 즐겨찾기 행 ───────────────────────────────────────
class _FavoriteRow extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback  onTap;
  final VoidCallback  onDelete;

  const _FavoriteRow({
    required this.favorite,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      // 좌로 스와이프 → 삭제
      key: Key(favorite.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline,
            color: Colors.redAccent, size: 20),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              // 별 아이콘
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.star,
                    size: 18, color: cs.primary),
              ),
              const SizedBox(width: 14),

              // 책 이름 + 장
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${favorite.bookName} ${favorite.chapter}장',
                      style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      favorite.bookEnglishName,
                      style: tt.labelMedium,
                    ),
                  ],
                ),
              ),

              // 저장 날짜
              Text(
                favorite.formattedDate,
                style: tt.labelSmall?.copyWith(
                    color: cs.secondary),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 16, color: cs.outline),
            ],
          ),
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
              style: TextStyle(
                  fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('성경 읽기 중 ★ 버튼을 눌러 저장하세요',
              style: TextStyle(
                  fontSize: 12, color: cs.secondary)),
        ],
      ),
    );
  }
}