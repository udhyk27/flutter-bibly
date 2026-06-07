import 'package:flutter/material.dart';
import '../model/favorite_model.dart';
import '../model/bible_models.dart';
import '../services/favorite_service.dart';
import '../screens/bible_reading_screen.dart';

/// 홈 화면에 붙이는 즐겨찾기 목록 위젯
///
/// 사용법 (home_screen.dart):
///   FavoriteListWidget(key: _favoriteKey)
///
/// 즐겨찾기 추가/삭제 후 새로고침이 필요하면:
///   final _favoriteKey = GlobalKey<FavoriteListWidgetState>();
///   _favoriteKey.currentState?.reload();

class FavoriteListWidget extends StatefulWidget {
  const FavoriteListWidget({super.key});

  @override
  State<FavoriteListWidget> createState() => FavoriteListWidgetState();
}

class FavoriteListWidgetState extends State<FavoriteListWidget> {
  List<FavoriteModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await FavoriteService.getAll();
    if (mounted) setState(() => _favorites = list);
  }

  // 외부에서 호출해 새로고침
  Future<void> reload() => _load();

  @override
  Widget build(BuildContext context) {
    if (_favorites.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('즐겨찾기',
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
              Text('${_favorites.length}개',
                  style: tt.labelMedium),
            ],
          ),
        ),

        // 가로 스크롤 카드 목록
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _favorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _FavoriteCard(
                favorite: _favorites[index],
                onDeleted: _load, // 삭제 후 목록 갱신
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 카드 ──────────────────────────────────────────────
class _FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback  onDeleted;

  const _FavoriteCard({
    required this.favorite,
    required this.onDeleted,
  });

  BibleBookModel? _findBook() {
    try {
      return [...oldTestament, ...newTestament]
          .firstWhere((b) => b.id == favorite.bookId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        final book = _findBook();
        if (book == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BibleReadingScreen(
              book:          book,
              chapterNumber: favorite.chapter,
            ),
          ),
        );
      },
      onLongPress: () => _showDeleteSheet(context),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 책 이름 + 장
            Row(
              children: [
                Icon(Icons.star, size: 11, color: cs.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${favorite.bookName} ${favorite.chapter}장',
                    style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // 영문 이름
            Text(
              favorite.bookEnglishName,
              style: tt.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 저장 날짜
            Text(
              favorite.formattedDate,
              style: tt.labelSmall?.copyWith(color: cs.secondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              Text(
                '${favorite.bookName} ${favorite.chapter}장',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text('즐겨찾기에서 삭제할까요?',
                  style: TextStyle(fontSize: 13, color: cs.secondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('취소',
                              style: TextStyle(
                                  fontSize: 14, color: cs.onSurface)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await FavoriteService.remove(
                            favorite.bookId, favorite.chapter);
                        if (context.mounted) {
                          Navigator.pop(context);
                          onDeleted();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('삭제',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onPrimary)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}