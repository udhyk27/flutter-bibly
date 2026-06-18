import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../model/bible_models.dart';

class BibleApiService {
  static const String _baseUrl = 'https://api.getbible.net/v2';
  static const String _boxName    = 'bible_cache';

  static const String bibleIdKo   = 'korean';
  static const String bibleIdEn   = 'kjv';
  static String currentBibleId    = bibleIdKo;

  // 메모리 캐시 (앱 실행 중 재호출 방지)
  static final Map<String, BibleChapterModel> _memoryCache = {};

  // ── 초기화 (main.dart에서 앱 시작 시 1회 호출) ────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // ── 책 목록 (로컬, API 호출 없음) ────────────────────
  static List<BibleBookModel> getBooks() =>
      oldTestament + newTestament;

  static List<BibleBookModel> getOldTestament() => oldTestament;
  static List<BibleBookModel> getNewTestament()  => newTestament;

  // ── 장 본문 (메모리 → Hive → API 순서로 확인) ─────────
  static Future<BibleChapterModel> getChapter({
    required int    bookNumber,
    required int    chapter,
    String?         bibleId,
  }) async {
    final id       = bibleId ?? currentBibleId;
    final cacheKey = '$id-$bookNumber-$chapter';

    // 1단계: 메모리 캐시 확인
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 2단계: Hive(기기 저장소) 확인
    final box    = Hive.box(_boxName);
    final cached = box.get(cacheKey);
    if (cached != null) {
      final model = BibleChapterModel.fromJson(
        jsonDecode(cached as String),
      );
      _memoryCache[cacheKey] = model; // 메모리에도 올림
      return model;
    }

    // 3단계: API 호출
    final model = await _fetchFromApi(
      bookNumber: bookNumber,
      chapter:    chapter,
      bibleId:    id,
    );

    // 메모리 + Hive 둘 다 저장
    _memoryCache[cacheKey] = model;
    await box.put(cacheKey, jsonEncode(model.toJson()));

    return model;
  }

  // ── API 실제 호출 ──────────────────────────────────
  static Future<BibleChapterModel> _fetchFromApi({
    required int    bookNumber,
    required int    chapter,
    required String bibleId,
  }) async {
    final url = '$_baseUrl/$bibleId/$bookNumber/$chapter.json';
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('본문 로딩 실패 (status: ${res.statusCode})');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    return BibleChapterModel.fromJson(data);
  }

  // ── 캐시 삭제 (설정에서 초기화할 때 사용) ──────────────
  static Future<void> clearCache() async {
    _memoryCache.clear();
    final box = Hive.box(_boxName);
    await box.clear();
  }

  // ── 캐시 용량 확인 ─────────────────────────────────
  static int getCacheCount() {
    final box = Hive.box(_boxName);
    return box.length;
  }
}

