import 'package:bibly/providers/reading_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// _load / 저장은 비동기라, 마이크로태스크가 모두 처리될 때까지 잠시 대기한다.
Future<void> _settle() => Future.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadingSettings', () {
    test('저장된 값이 없으면 기본값을 가진다', () {
      SharedPreferences.setMockInitialValues({});
      final s = ReadingSettings();

      expect(s.fontSize, 17.0);
      expect(s.lineHeight, 1.9);
      expect(s.showVerseNum, true);
      expect(s.showHighlight, true);
      expect(s.translation, '개역개정');
      expect(s.language, '한국어');
    });

    test('translation 에 따라 bibleId 가 올바르게 매핑된다', () {
      SharedPreferences.setMockInitialValues({});
      final s = ReadingSettings();

      expect(s.bibleId, 'korean'); // 개역개정(기본)
      s.setTranslation('KJV');
      expect(s.bibleId, 'kjv');
      s.setTranslation('NIV');
      expect(s.bibleId, 'web');
      s.setTranslation('ESV');
      expect(s.bibleId, 'asv');
    });

    test('같은 값으로 setter 를 호출하면 리스너가 불리지 않는다', () {
      SharedPreferences.setMockInitialValues({});
      final s = ReadingSettings();
      var notified = 0;
      s.addListener(() => notified++);

      s.setFontSize(s.fontSize); // 동일 값
      expect(notified, 0);

      s.setFontSize(20.0); // 다른 값
      expect(notified, 1);
    });

    test('변경한 설정이 저장되고 새 인스턴스에서 복원된다', () async {
      SharedPreferences.setMockInitialValues({});

      final s = ReadingSettings();
      s.setFontSize(22.0);
      s.setLineHeight(2.2);
      s.setShowVerseNum(false);
      s.setShowHighlight(false);
      s.setTranslation('KJV');
      s.setLanguage('English');
      await _settle(); // 저장 완료 대기

      final restored = ReadingSettings();
      await _settle(); // _load 완료 대기

      expect(restored.fontSize, 22.0);
      expect(restored.lineHeight, 2.2);
      expect(restored.showVerseNum, false);
      expect(restored.showHighlight, false);
      expect(restored.translation, 'KJV');
      expect(restored.language, 'English');
    });
  });
}
