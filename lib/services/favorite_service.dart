import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/favorite_model.dart';

class FavoriteService {
  static const _key = 'favorites';

  // ── 전체 불러오기 ─────────────────────────────────
  static Future<List<FavoriteModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_key);
    if (raw == null) return [];
    final list  = jsonDecode(raw) as List;
    final favorites = list.map((e) => FavoriteModel.fromJson(e)).toList();
    favorites.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return favorites;
  }

  // ── 장 즐겨찾기 추가 ─────────────────────────────
  static Future<void> add({
    required String bookId,
    required String bookName,
    required String bookEnglishName,
    required int    bookNumber,
    required int    chapter,
    required int    totalChapters,
    required String genre,
  }) async {
    final list = await getAll();
    list.removeWhere((e) => e.bookId == bookId && e.chapter == chapter && e.verse == null);
    list.insert(0, FavoriteModel(
      bookId:          bookId,
      bookName:        bookName,
      bookEnglishName: bookEnglishName,
      bookNumber:      bookNumber,
      chapter:         chapter,
      totalChapters:   totalChapters,
      genre:           genre,
      savedAt:         DateTime.now(),
    ));
    await _save(list);
  }

  // ── 구절 즐겨찾기 추가 ────────────────────────────
  static Future<void> addVerse({
    required String bookId,
    required String bookName,
    required String bookEnglishName,
    required int    bookNumber,
    required int    chapter,
    required int    totalChapters,
    required String genre,
    required int    verse,
    required String verseText,
  }) async {
    final list = await getAll();
    list.removeWhere((e) => e.bookId == bookId && e.chapter == chapter && e.verse == verse);
    list.insert(0, FavoriteModel(
      bookId:          bookId,
      bookName:        bookName,
      bookEnglishName: bookEnglishName,
      bookNumber:      bookNumber,
      chapter:         chapter,
      totalChapters:   totalChapters,
      genre:           genre,
      savedAt:         DateTime.now(),
      verse:           verse,
      verseText:       verseText,
    ));
    await _save(list);
  }

  // ── 장 즐겨찾기 제거 ─────────────────────────────
  static Future<void> remove(String bookId, int chapter) async {
    final list = await getAll();
    list.removeWhere((e) => e.bookId == bookId && e.chapter == chapter && e.verse == null);
    await _save(list);
  }

  // ── 구절 즐겨찾기 제거 ────────────────────────────
  static Future<void> removeVerse(String bookId, int chapter, int verse) async {
    final list = await getAll();
    list.removeWhere((e) => e.bookId == bookId && e.chapter == chapter && e.verse == verse);
    await _save(list);
  }

  // ── 장 즐겨찾기 여부 확인 ─────────────────────────
  static Future<bool> isFavorite(String bookId, int chapter) async {
    final list = await getAll();
    return list.any((e) => e.bookId == bookId && e.chapter == chapter && e.verse == null);
  }

  // ── 구절 즐겨찾기 여부 확인 ──────────────────────
  static Future<bool> isVerseFavorite(String bookId, int chapter, int verse) async {
    final list = await getAll();
    return list.any((e) => e.bookId == bookId && e.chapter == chapter && e.verse == verse);
  }

  // ── 특정 장의 즐겨찾기된 구절 번호 Set 반환 ────────
  static Future<Set<int>> favoritedVersesInChapter(String bookId, int chapter) async {
    final list = await getAll();
    return list
        .where((e) => e.bookId == bookId && e.chapter == chapter && e.verse != null)
        .map((e) => e.verse!)
        .toSet();
  }

  // ── 내부 저장 ────────────────────────────────────
  static Future<void> _save(List<FavoriteModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}
