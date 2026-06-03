import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 장(chapter)별 절(verse) 메모를 SharedPreferences에 영구 저장합니다.
/// 저장 형식: {verseId: noteText} JSON 맵 1개 per chapter.
class VerseNoteService {
  static String _key(int bookNumber, int chapter) =>
      'notes_${bookNumber}_$chapter';

  /// 해당 장의 모든 메모를 `{verseId: text}` 형태로 불러옵니다.
  static Future<Map<String, String>> loadAll(
      int bookNumber, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(bookNumber, chapter));
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  /// 특정 절의 메모를 저장합니다. [text]가 비어 있으면 자동으로 삭제합니다.
  static Future<void> save(
      int bookNumber, int chapter, String verseId, String text) async {
    final notes = await loadAll(bookNumber, chapter);
    if (text.trim().isEmpty) {
      notes.remove(verseId);
    } else {
      notes[verseId] = text.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(bookNumber, chapter), jsonEncode(notes));
  }

  /// 특정 절의 메모를 삭제합니다.
  static Future<void> delete(
      int bookNumber, int chapter, String verseId) async {
    await save(bookNumber, chapter, verseId, '');
  }
}
