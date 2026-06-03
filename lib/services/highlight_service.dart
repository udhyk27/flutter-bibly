import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 장(chapter)별 하이라이트된 절 번호 목록을 SharedPreferences에 영구 저장합니다.
class HighlightService {
  static String _key(int bookNumber, int chapter) =>
      'highlights_${bookNumber}_$chapter';

  /// 해당 장의 하이라이트 절 ID 세트를 불러옵니다.
  static Future<Set<String>> load(int bookNumber, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(bookNumber, chapter));
    if (raw == null) return {};
    final list = jsonDecode(raw) as List;
    return list.map((e) => e.toString()).toSet();
  }

  /// 하이라이트 절 ID 세트를 저장합니다.
  static Future<void> save(
      int bookNumber, int chapter, Set<String> verseIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(bookNumber, chapter),
      jsonEncode(verseIds.toList()),
    );
  }
}
