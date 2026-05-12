import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighlightService {
  static String _key(String bookId, int chapter) => 'hl_${bookId}_$chapter';

  static Future<Map<String, Color>> load(String bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(bookId, chapter));
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, Color(v as int)));
  }

  static Future<void> save(
    String bookId,
    int chapter,
    Map<String, Color> highlights,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (highlights.isEmpty) {
      await prefs.remove(_key(bookId, chapter));
      return;
    }
    final encoded = highlights.map((k, v) => MapEntry(k, v.toARGB32()));
    await prefs.setString(_key(bookId, chapter), jsonEncode(encoded));
  }
}
