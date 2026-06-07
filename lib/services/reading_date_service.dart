import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 성경 읽은 날짜만 관리하는 서비스
/// RecentReadService.save() 와 함께 호출해서 오늘 날짜를 기록
class ReadingDateService {
  static const _key = 'reading_dates';

  /// 오늘 날짜 저장 (중복 무시)
  static Future<void> markToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = _load(prefs);
    final today = _fmt(DateTime.now());
    // debugPrint('[ReadingDateService] markToday: $today, before: $saved');
    if (!saved.contains(today)) {
      saved.add(today);
      await prefs.setString(_key, jsonEncode(saved));
    }
    // debugPrint('[ReadingDateService] markToday after: ${_load(prefs)}');
  }

  /// 이번 주(월~일) 읽은 날짜 Set 반환
  static Future<Set<DateTime>> checkedDaysThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _load(prefs);
    // debugPrint('[ReadingDateService] checkedDaysThisWeek raw: $raw');
    final saved = raw.map(_parse).whereType<DateTime>().toSet();

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    return saved.intersection(weekDays);
  }

  // ── 내부 헬퍼 ──────────────────────────────────
  static List<String> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parse(String s) {
    try {
      final parts = s.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }
}