import '../model/bible_models.dart';
import 'bible_api_service.dart';

class BiblePrefetchService {
  static bool _running = false;
  static bool get isRunning => _running;

  /// 전체 성경(한국어)을 Hive에 순차 다운로드.
  /// [onProgress] : (완료 장 수, 전체 장 수)
  static Future<void> prefetchAll({
    void Function(int done, int total)? onProgress,
  }) async {
    if (_running) return;
    _running = true;

    final allBooks = [...oldTestament, ...newTestament];
    final total    = allBooks.fold<int>(0, (s, b) => s + b.totalChapters);
    int done = 0;

    try {
      for (final book in allBooks) {
        for (int ch = 1; ch <= book.totalChapters; ch++) {
          try {
            await BibleApiService.getChapter(
              bookNumber: book.number,
              chapter:    ch,
              bibleId:    BibleApiService.bibleIdKo,
            );
          } catch (_) {
            // 개별 장 실패는 무시하고 계속 진행
          }
          done++;
          onProgress?.call(done, total);
        }
      }
    } finally {
      _running = false;
    }
  }

  /// 현재 캐시된 장 수와 전체 장 수 반환
  static (int cached, int total) getCoverage() {
    final total = [...oldTestament, ...newTestament]
        .fold<int>(0, (s, b) => s + b.totalChapters);
    return (BibleApiService.getCacheCount(), total);
  }
}
