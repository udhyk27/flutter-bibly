import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/recent_read_model.dart';

class RecentReadService {
  static const _key     = 'recent_reads';
  static const _maxSize = 5; // 최대 5개

  // 저장
  static Future<void> save({
    required String bookName,
    required String bookEnglishName,
    required String bookId,
    required String bookNameLong,
    required String bookGenre,
    required int    bookNumber,
    required int    totalChapters,
    required int    chapter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getAll();

    list.removeWhere(
          (e) => e.bookNumber == bookNumber && e.chapter == chapter,
    );

    list.insert(0, RecentReadModel(
      bookName:        bookName,
      bookEnglishName: bookEnglishName,
      bookId:          bookId,
      bookNameLong:    bookNameLong,
      bookGenre:       bookGenre,
      bookNumber:      bookNumber,
      totalChapters:   totalChapters,
      chapter:         chapter,
      timestamp:       DateTime.now().millisecondsSinceEpoch,
    ));

    if (list.length > _maxSize) list.removeLast();

    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // 전체 불러오기
  static Future<List<RecentReadModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_key);
    if (raw == null) return [];
    final list  = jsonDecode(raw) as List;
    return list.map((e) => RecentReadModel.fromJson(e)).toList();
  }
}