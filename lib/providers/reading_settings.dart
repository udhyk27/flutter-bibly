import 'package:flutter/foundation.dart';

class ReadingSettings extends ChangeNotifier {
  // ── 폰트 / 레이아웃 ───────────────────────────────
  double _fontSize   = 17.0;
  double _lineHeight = 1.9;

  double _speechRate = 0.4;   // ✅ 고정값으로 맞춤
  double _pitch      = 0.88;  // ✅ 고정값으로 맞춤

  // ── 표시 옵션 ────────────────────────────────────
  bool _showVerseNum  = true;
  bool _showHighlight = true;

  // ── 번역본 / 언어 ────────────────────────────────
  String _translation = '개역개정';
  String _language    = '한국어';

  // getters
  double get fontSize      => _fontSize;
  double get lineHeight    => _lineHeight;
  double get speechRate    => _speechRate;
  double get pitch         => _pitch;
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

  void setSpeechRate(double v) { _speechRate = v; notifyListeners(); }
  void setPitch(double v)      { _pitch = v;      notifyListeners(); }

  void setFontSize(double v) {
    if (_fontSize == v) return;
    _fontSize = v;
    notifyListeners();
  }

  void setLineHeight(double v) {
    if (_lineHeight == v) return;
    _lineHeight = v;
    notifyListeners();
  }

  void setShowVerseNum(bool v) {
    if (_showVerseNum == v) return;
    _showVerseNum = v;
    notifyListeners();
  }

  void setShowHighlight(bool v) {
    if (_showHighlight == v) return;
    _showHighlight = v;
    notifyListeners();
  }

  void setTranslation(String v) {
    if (_translation == v) return;
    _translation = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    if (_language == v) return;
    _language = v;
    notifyListeners();
  }
}