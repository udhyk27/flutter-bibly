import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSettings extends ChangeNotifier {
  // ── SharedPreferences 키 ──────────────────────────
  static const _kFontSize      = 'reading_font_size';
  static const _kLineHeight    = 'reading_line_height';
  static const _kShowVerseNum  = 'reading_show_verse_num';
  static const _kShowHighlight = 'reading_show_highlight';
  static const _kTranslation   = 'reading_translation';
  static const _kLanguage      = 'reading_language';

  // ── 폰트 / 레이아웃 ───────────────────────────────
  double _fontSize   = 17.0;
  double _lineHeight = 1.9;

  // ── 표시 옵션 ────────────────────────────────────
  bool _showVerseNum  = true;
  bool _showHighlight = true;

  // ── 번역본 / 언어 ────────────────────────────────
  String _translation = '개역개정';
  String _language    = '한국어';

  ReadingSettings() {
    _load();
  }

  // getters
  double get fontSize      => _fontSize;
  double get lineHeight    => _lineHeight;
  bool   get showVerseNum  => _showVerseNum;
  bool   get showHighlight => _showHighlight;
  String get translation   => _translation;
  String get language      => _language;

  String get bibleId {
    switch (_translation) {
      case 'KJV': return 'kjv';
      case 'NIV': return 'web';
      case 'ESV': return 'asv';
      default:    return 'korean';
    }
  }

  // ── 저장된 설정 복원 ──────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize      = prefs.getDouble(_kFontSize)     ?? _fontSize;
    _lineHeight    = prefs.getDouble(_kLineHeight)   ?? _lineHeight;
    _showVerseNum  = prefs.getBool(_kShowVerseNum)   ?? _showVerseNum;
    _showHighlight = prefs.getBool(_kShowHighlight)  ?? _showHighlight;
    _translation   = prefs.getString(_kTranslation)  ?? _translation;
    _language      = prefs.getString(_kLanguage)     ?? _language;
    notifyListeners();
  }

  void setFontSize(double v) {
    if (_fontSize == v) return;
    _fontSize = v;
    notifyListeners();
    _persistDouble(_kFontSize, v);
  }

  void setLineHeight(double v) {
    if (_lineHeight == v) return;
    _lineHeight = v;
    notifyListeners();
    _persistDouble(_kLineHeight, v);
  }

  void setShowVerseNum(bool v) {
    if (_showVerseNum == v) return;
    _showVerseNum = v;
    notifyListeners();
    _persistBool(_kShowVerseNum, v);
  }

  void setShowHighlight(bool v) {
    if (_showHighlight == v) return;
    _showHighlight = v;
    notifyListeners();
    _persistBool(_kShowHighlight, v);
  }

  void setTranslation(String v) {
    if (_translation == v) return;
    _translation = v;
    notifyListeners();
    _persistString(_kTranslation, v);
  }

  void setLanguage(String v) {
    if (_language == v) return;
    _language = v;
    notifyListeners();
    _persistString(_kLanguage, v);
  }

  // ── 저장 헬퍼 (ThemeProvider와 동일한 fire-and-forget 방식) ──
  Future<void> _persistDouble(String key, double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, v);
  }

  Future<void> _persistBool(String key, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, v);
  }

  Future<void> _persistString(String key, String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, v);
  }
}
