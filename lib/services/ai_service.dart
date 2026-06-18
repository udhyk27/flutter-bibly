import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/bible_story_model.dart';
import 'config_api_service.dart';

// 캐시 모델
class _CachedStory {
  final BibleStoryModel story;
  final DateTime fetchedAt;

  _CachedStory({required this.story, required this.fetchedAt});
}

class AiService {
  static const String _askBibleUrl = 'https://askbible-r7wxadmqnq-uc.a.run.app';
  static const String _getBibleStoryUrl = 'https://getbiblestory-r7wxadmqnq-uc.a.run.app';

  // 캐시 저장소
  static final Map<String, _CachedStory> _storyCache = {};

  static Future<BibleStoryModel> getBibleStory(String bookName) async {
    // 캐시 확인 - 1시간 이내면 캐시 반환
    final cached = _storyCache[bookName];
    if (cached != null && DateTime.now().difference(cached.fetchedAt).inHours < 1) {
      debugPrint('getBibleStory 캐시 사용: $bookName');
      return cached.story;
    }

    final response = await http.post(
      Uri.parse(_getBibleStoryUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookName': bookName}),
    ).timeout(const Duration(seconds: 30));

    debugPrint('getBibleStory 상태코드: ${response.statusCode}');
    debugPrint('getBibleStory 응답: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final story = BibleStoryModel.fromJson(data);

      // 캐시 저장
      _storyCache[bookName] = _CachedStory(
        story: story,
        fetchedAt: DateTime.now(),
      );

      return story;
    } else {
      throw Exception('AI 응답 오류: ${response.statusCode}');
    }
  }

  static Future<String> askVerse(String verseText) async {
    final response = await http.post(
      Uri.parse(_askBibleUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'verse': verseText,
        'question': '이 구절을 2~3문장으로 간결하게 설명해주세요.',
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'];
    } else {
      throw Exception('AI 응답 오류: ${response.statusCode}');
    }
  }

  static Future<String> askQuestion({
    required String verse,
    required String question,
  }) async {
    final aiModel = ConfigApiService().aiModel;

    final response = await http.post(
      Uri.parse(_askBibleUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'verse': verse,
        'question': question,
        'aiModel': aiModel,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'];
    } else {
      throw Exception('AI 응답 오류: ${response.statusCode}');
    }
  }
}