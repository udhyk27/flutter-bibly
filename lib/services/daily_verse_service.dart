import 'dart:convert';
import 'package:flutter/services.dart';

class DailyVerseModel {
  final int    day;
  final String bookId;
  final String book;
  final int    chapter;
  final int    verse;
  final String text;
  final String meditation;

  const DailyVerseModel({
    required this.day,
    required this.bookId,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.meditation,
  });

  factory DailyVerseModel.fromJson(Map<String, dynamic> json) =>
      DailyVerseModel(
        day:        json['day']        as int,
        bookId:     json['bookId']     as String,
        book:       json['book']       as String,
        chapter:    json['chapter']    as int,
        verse:      json['verse']      as int,
        text:       json['text']       as String,
        meditation: json['meditation'] as String,
      );

  // "잠언 3:5" 형식
  String get reference => '$book $chapter:$verse';
}

class DailyVerseService {
  static List<DailyVerseModel>? _cache;

  static Future<List<DailyVerseModel>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw  = await rootBundle.loadString('assets/data/daily_verses.json');
    final list = jsonDecode(raw) as List;
    _cache = list.map((e) => DailyVerseModel.fromJson(e)).toList();
    return _cache!;
  }

  /// 오늘 날짜 기준으로 구절 반환
  /// 1월 1일 = day 1, 12월 31일 = day 365
  static Future<DailyVerseModel> getToday() async {
    final all = await _loadAll();
    if (all.isEmpty) {
      throw StateError('daily_verses.json 이 비어 있습니다.');
    }
    final now = DateTime.now();
    // 1월 1일부터 몇 번째 날인지 계산
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear   = now.difference(startOfYear).inDays + 1;
    // 윤년의 12월 31일(366일째)이 1월 1일 구절로 되돌아가지 않도록
    // 마지막 인덱스로 고정한다.
    final index = (dayOfYear - 1).clamp(0, all.length - 1);
    return all[index];
  }
}