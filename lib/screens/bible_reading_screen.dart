import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../model/bible_models.dart';
import '../providers/reading_settings.dart';
import '../services/bible_api_service.dart';
import '../services/ai_service.dart';
import '../services/favorite_service.dart';
import '../services/highlight_service.dart';
import '../services/reading_date_service.dart';
import '../services/recent_read_service.dart';
import '../services/verse_note_service.dart';

class BibleReadingScreen extends StatefulWidget {
  final BibleBookModel book;
  final int chapterNumber;

  const BibleReadingScreen({
    super.key,
    required this.book,
    required this.chapterNumber,
  });

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  static const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

  BibleChapterModel? _chapter;
  bool _isLoading = true;
  String? _error;

  int _currentChapter = 1;
  String? _selectedVerseId;
  bool _isFavorite = false;

  final Map<String, Color> _highlights = {};
  final Map<String, String> _notes = {};
  final Map<String, String> _aiAnswers = {};
  final Map<String, bool> _aiLoading = {};

  // ── TTS ──────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;


  // ── AdMob 배너 ──────────────────────────────────────
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // 테스트 ID — 출시 전 실제 ID로 교체
  // Android: ca-app-pub-3940256099942544/6300978111
  // iOS:     ca-app-pub-3940256099942544/2934735716
  static const String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
    _initTts();
    _loadChapter();
    if (!_screenshotMode) {
      _loadBannerAd(); // 배너 로드
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner, // 320×50
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _tts.stop();
    _bannerAd?.dispose(); // ✅ 메모리 해제
    super.dispose();
  }
  // ─────────────────────────────────────────────────────

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.88);
    await _tts.setVoice({'name': 'ko-kr-x-kod-local', 'locale': 'ko-KR'});

    _tts.setCompletionHandler(() {});
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  String _addBreaths(String text) {
    return text
        .replaceAll(RegExp(r'([,，、])'), r'\1  ')
        .replaceAll(RegExp(r'([.。!！?？])'), r'\1   ');
  }

  Future<void> _toggleChapterSpeak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    if (_chapter == null) return;

    setState(() => _isSpeaking = true);

    for (final verse in _chapter!.verses) {
      if (!_isSpeaking) break;
      final text = _addBreaths(verse.text);
      final completer = Completer<void>();
      _tts.setCompletionHandler(() => completer.complete());
      _tts.setErrorHandler((_) {
        if (!completer.isCompleted) completer.complete();
        if (mounted) setState(() => _isSpeaking = false);
      });
      await _tts.speak(text);
      await completer.future;
      if (_isSpeaking) await Future.delayed(const Duration(milliseconds: 1500));
    }

    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _loadChapter() async {
    // context는 첫 await 이전에 읽어야 함 (use_build_context_synchronously)
    final bibleId = context.read<ReadingSettings>().bibleId;

    setState(() {
      _isLoading = true;
      _error = null;
      _selectedVerseId = null;
      _highlights.clear();
      _notes.clear();
    });

    await _tts.stop();
    setState(() => _isSpeaking = false);

    await RecentReadService.save(
      bookName: widget.book.name,
      bookEnglishName: widget.book.englishName,
      bookId: widget.book.id,
      bookNameLong: widget.book.nameLong,
      bookGenre: widget.book.genre,
      bookNumber: widget.book.number,
      totalChapters: widget.book.totalChapters,
      chapter: _currentChapter,
    );

    await ReadingDateService.markToday();

    try {
      final chapter = await BibleApiService.getChapter(
        bookNumber: widget.book.number,
        chapter:    _currentChapter,
        bibleId:    bibleId,
      );
      setState(() {
        _chapter = chapter;
        _isLoading = false;
      });
      _loadFavoriteState();
      _loadHighlightsAndNotes();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _goToChapter(int chapter) async {
    if (chapter < 1 || chapter > widget.book.totalChapters) return;
    setState(() => _currentChapter = chapter);
    await _loadChapter();
  }

  Future<void> _askAI(String verseId, String text) async {
    setState(() => _aiLoading[verseId] = true);
    try {
      final answer = await AiService.askVerse(text);
      setState(() {
        _aiAnswers[verseId] = answer;
        _aiLoading[verseId] = false;
      });
    } catch (e) {
      setState(() {
        _aiAnswers[verseId] = '답변을 불러오지 못했어요. 다시 시도해주세요.';
        _aiLoading[verseId] = false;
      });
    }
  }

  Future<void> _loadFavoriteState() async {
    final result = await FavoriteService.isFavorite(
      widget.book.id,
      _currentChapter,
    );
    setState(() => _isFavorite = result);
  }

  void _onVerseTap(String verseId) {
    setState(() {
      _selectedVerseId = (_selectedVerseId == verseId) ? null : verseId;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoriteService.remove(widget.book.id, _currentChapter);
    } else {
      await FavoriteService.add(
        bookId: widget.book.id,
        bookName: widget.book.name,
        bookEnglishName: widget.book.englishName,
        bookNumber: widget.book.number,
        chapter: _currentChapter,
        totalChapters: widget.book.totalChapters,
        genre: widget.book.genre,
      );
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  void _onHighlight(String verseId) {
    final cs = Theme.of(context).colorScheme;
    setState(() {
      if (_highlights.containsKey(verseId)) {
        _highlights.remove(verseId);
      } else {
        _highlights[verseId] = cs.primary.withValues(alpha: 0.15);
      }
    });
    // 비동기 영구 저장 (fire-and-forget)
    HighlightService.save(
      widget.book.number,
      _currentChapter,
      _highlights.keys.toSet(),
    );
  }

  // ── 하이라이트 & 메모 로드 ──────────────────────────────
  Future<void> _loadHighlightsAndNotes() async {
    final verseIds = await HighlightService.load(
      widget.book.number, _currentChapter);
    final notes = await VerseNoteService.loadAll(
      widget.book.number, _currentChapter);
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    setState(() {
      _highlights.clear();
      for (final id in verseIds) {
        _highlights[id] = cs.primary.withValues(alpha: 0.15);
      }
      _notes
        ..clear()
        ..addAll(notes);
    });
  }

  // ── 메모 편집 시트 열기 ────────────────────────────────
  Future<void> _onNote(String verseId, String verseText) async {
    final existingNote = _notes[verseId] ?? '';
    final controller = TextEditingController(text: existingNote);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NoteSheet(
        verseText: verseText,
        controller: controller,
        hasExisting: existingNote.isNotEmpty,
        onSave: (text) async {
          await VerseNoteService.save(
            widget.book.number, _currentChapter, verseId, text);
          if (!mounted) return;
          setState(() {
            if (text.trim().isEmpty) {
              _notes.remove(verseId);
            } else {
              _notes[verseId] = text.trim();
            }
          });
          if (ctx.mounted) Navigator.pop(ctx);
        },
        onDelete: () async {
          await VerseNoteService.delete(
            widget.book.number, _currentChapter, verseId);
          if (!mounted) return;
          setState(() => _notes.remove(verseId));
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
    controller.dispose();
  }

  void _showSettingsSheet(BuildContext context) {
    final settings = context.read<ReadingSettings>();
    final cs = Theme.of(context).colorScheme;

    double localFontSize = settings.fontSize;
    double localLineHeight = settings.lineHeight;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (ctx, _, _) => Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            top: false,
            child: StatefulBuilder(
              builder: (ctx, setSheet) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '읽기 설정',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SliderRow(
                      label: '글씨 크기',
                      valueText: '${localFontSize.toInt()}px',
                      cs: cs,
                    ),
                    _CustomSlider(
                      value: localFontSize,
                      min: 12,
                      max: 26,
                      activeColor: cs.primary,
                      inactiveColor: cs.surfaceContainerHighest,
                      onChanged: (v) {
                        setSheet(() => localFontSize = v);
                        context.read<ReadingSettings>().setFontSize(v);
                      },
                    ),
                    const SizedBox(height: 8),
                    _SliderRow(
                      label: '줄 간격',
                      valueText: localLineHeight.toStringAsFixed(1),
                      cs: cs,
                    ),
                    _CustomSlider(
                      value: localLineHeight,
                      min: 1.4,
                      max: 2.4,
                      activeColor: cs.primary,
                      inactiveColor: cs.surfaceContainerHighest,
                      onChanged: (v) {
                        setSheet(() => localLineHeight = v);
                        context.read<ReadingSettings>().setLineHeight(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<ReadingSettings>();

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          Positioned.fill(
            child: CustomPaint(painter: _PaperTexturePainter(cs.onSurface)),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  book: widget.book,
                  chapterNumber: _currentChapter,
                  isSpeaking: _isSpeaking,
                  onSpeakTap: _toggleChapterSpeak,
                  onSettingsTap: () => _showSettingsSheet(context),
                  isFavorite: _isFavorite,
                  onFavoriteTap: _toggleFavorite,
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: cs.primary),
                        )
                      : _error != null
                      ? _ErrorView(error: _error!, onRetry: _loadChapter)
                      : _chapter == null
                      ? const SizedBox()
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: CurvedAnimation(
                              parent: anim,
                              curve: const Interval(0.3, 1.0),
                            ),
                            child: child,
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(_currentChapter),
                            child: _VerseList(
                              verses: _chapter!.verses,
                              selectedVerseId: _selectedVerseId,
                              highlights: _highlights,
                              notes: _notes,
                              aiAnswers: _aiAnswers,
                              aiLoading: _aiLoading,
                              fontSize: settings.fontSize,
                              lineHeight: settings.lineHeight,
                              showVerseNum: settings.showVerseNum,
                              showHighlight: settings.showHighlight,
                              onVerseTap: _onVerseTap,
                              onHighlight: _onHighlight,
                              onNote: _onNote,
                              onAskAI: _askAI,
                            ),
                          ),
                        ),
                ),

                // 배너 광고 — 장 이동 버튼 바로 위
                if (!_screenshotMode && _isBannerAdReady && _bannerAd != null)
                  Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                  ),

                _BottomChapterNav(
                  currentChapter: _currentChapter,
                  totalChapters: widget.book.totalChapters,
                  onPrev: () => _goToChapter(_currentChapter - 1),
                  onNext: () => _goToChapter(_currentChapter + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 종이 질감 ────────────────────────────────────────────
class _PaperTexturePainter extends CustomPainter {
  final Color baseColor;
  _PaperTexturePainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = baseColor.withValues(alpha: 0.018);
    int rx = 127, ry = 311;
    int next() {
      rx = (rx * 1664525 + 1013904223) & 0xFFFFFFFF;
      ry = (ry * 22695477 + 1) & 0xFFFFFFFF;
      return (rx ^ ry) & 0xFFFFFFFF;
    }

    for (int i = 0; i < 3000; i++) {
      final x = (next() % 10000) / 10000.0 * size.width;
      final y = (next() % 10000) / 10000.0 * size.height;
      canvas.drawCircle(Offset(x, y), 0.55, paint);
    }
  }

  @override
  bool shouldRepaint(_PaperTexturePainter old) => old.baseColor != baseColor;
}

// ── 슬라이더 레이블 ──────────────────────────────────────
class _SliderRow extends StatelessWidget {
  final String label, valueText;
  final ColorScheme cs;
  const _SliderRow({
    required this.label,
    required this.valueText,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface)),
      Text(
        valueText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.primary,
        ),
      ),
    ],
  );
}

// ── 커스텀 슬라이더 ──────────────────────────────────────
class _CustomSlider extends StatelessWidget {
  final double value, min, max;
  final Color activeColor, inactiveColor;
  final ValueChanged<double> onChanged;

  const _CustomSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.inactiveColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final ratio = ((value - min) / (max - min)).clamp(0.0, 1.0);
        const thumbSz = 20.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => onChanged(
            min + (d.localPosition.dx / width).clamp(0.0, 1.0) * (max - min),
          ),
          onTapDown: (d) => onChanged(
            min + (d.localPosition.dx / width).clamp(0.0, 1.0) * (max - min),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: thumbSz,
              width: width,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    top: (thumbSz - 4) / 2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: inactiveColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    top: (thumbSz - 4) / 2,
                    left: 0,
                    child: Container(
                      height: 4,
                      width: width * ratio,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (width * ratio - thumbSz / 2).clamp(
                      0,
                      width - thumbSz,
                    ),
                    child: Container(
                      width: thumbSz,
                      height: thumbSz,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── 상단 바 ──────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final BibleBookModel book;
  final int chapterNumber;
  final bool isSpeaking; // ✅
  final VoidCallback onSpeakTap; // ✅
  final VoidCallback onSettingsTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _TopBar({
    required this.book,
    required this.chapterNumber,
    required this.isSpeaking,
    required this.onSpeakTap,
    required this.onSettingsTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios, size: 18, color: cs.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${book.name} $chapterNumber장',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      book.englishName.toUpperCase(),
                      style: GoogleFonts.ebGaramond(
                        fontSize: 10,
                        color: cs.secondary,
                        letterSpacing: 3.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ 재생/정지 버튼
              _TopIconBtn(
                icon: isSpeaking
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline,
                cs: cs,
                onTap: onSpeakTap,
              ),
              const SizedBox(width: 8),
              _TopIconBtn(
                icon: isFavorite ? Icons.star : Icons.star_outline,
                cs: cs,
                onTap: onFavoriteTap,
              ),
              const SizedBox(width: 8),
              _TopIconBtn(
                icon: Icons.text_fields_outlined,
                cs: cs,
                onTap: onSettingsTap,
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.6, color: cs.outline),
      ],
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _TopIconBtn({
    required this.icon,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: cs.primary),
    ),
  );
}

// ── 절 목록 ──────────────────────────────────────────────
class _VerseList extends StatelessWidget {
  final List<BibleVerseModel> verses;
  final String? selectedVerseId;
  final Map<String, Color> highlights;
  final Map<String, String> notes;
  final Map<String, String> aiAnswers;
  final Map<String, bool> aiLoading;
  final double fontSize;
  final double lineHeight;
  final bool showVerseNum;
  final bool showHighlight;
  final Function(String) onVerseTap;
  final Function(String) onHighlight;
  final Function(String, String) onNote;
  final Function(String, String) onAskAI;

  const _VerseList({
    required this.verses,
    required this.selectedVerseId,
    required this.highlights,
    required this.notes,
    required this.aiAnswers,
    required this.aiLoading,
    required this.fontSize,
    required this.lineHeight,
    required this.showVerseNum,
    required this.showHighlight,
    required this.onVerseTap,
    required this.onHighlight,
    required this.onNote,
    required this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: verses.length + 1,
      itemBuilder: (context, index) {
        if (index == verses.length) return const SizedBox(height: 40);

        final verse = verses[index];
        final verseId = '${verse.verse}';
        final isSelected = selectedVerseId == verseId;
        final aiAnswer = aiAnswers[verseId];
        final isAiLoading = aiLoading[verseId] ?? false;
        final highlightColor = showHighlight ? highlights[verseId] : null;
        final noteText = notes[verseId];
        final hasNote = noteText != null;

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VerseRow(
                verseNum: verseId,
                text: verse.text,
                isSelected: isSelected,
                highlightColor: highlightColor,
                hasNote: hasNote,
                fontSize: fontSize,
                lineHeight: lineHeight,
                showVerseNum: showVerseNum,
                onTap: () => onVerseTap(verseId),
              ),
              if (isSelected)
                _ActionBar(
                  verseId: verseId,
                  text: verse.text,
                  isHighlighted: highlights.containsKey(verseId),
                  hasNote: hasNote,
                  onHighlight: () => onHighlight(verseId),
                  onNote: () => onNote(verseId, verse.text),
                  onAskAI: onAskAI,
                ),
              if (hasNote)
                _NoteBubble(
                  note: noteText,
                  onEdit: () => onNote(verseId, verse.text),
                ),
              if (isAiLoading) const _AiLoadingBubble(),
              if (aiAnswer != null && !isAiLoading) _AiBubble(answer: aiAnswer),
            ],
          ),
        );
      },
    );
  }
}

// ── 절 행 ────────────────────────────────────────────────
class _VerseRow extends StatelessWidget {
  final String verseNum;
  final String text;
  final bool isSelected;
  final Color? highlightColor;
  final bool hasNote;
  final double fontSize;
  final double lineHeight;
  final bool showVerseNum;
  final VoidCallback onTap;

  const _VerseRow({
    required this.verseNum,
    required this.text,
    required this.isSelected,
    required this.highlightColor,
    required this.hasNote,
    required this.fontSize,
    required this.lineHeight,
    required this.showVerseNum,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = cs.surfaceContainerHighest;
    } else if (highlightColor != null) {
      bgColor = highlightColor!;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showVerseNum)
              SizedBox(
                width: 28,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    verseNum,
                    style: GoogleFonts.ebGaramond(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      height: lineHeight,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.notoSerifKr(
                  fontSize: fontSize,
                  color: cs.onSurface,
                  height: lineHeight,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (hasNote)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 6),
                child: Icon(
                  Icons.edit_note,
                  size: 15,
                  color: cs.primary.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 액션 바 ──────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final String verseId;
  final String text;
  final bool isHighlighted;
  final bool hasNote;
  final VoidCallback onHighlight;
  final VoidCallback onNote;
  final Function(String, String) onAskAI;

  const _ActionBar({
    required this.verseId,
    required this.text,
    required this.isHighlighted,
    required this.hasNote,
    required this.onHighlight,
    required this.onNote,
    required this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 38, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionChip(
              label: '복사',
              icon: Icons.copy_outlined,
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('클립보드에 복사됐어요'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            _ActionChip(
              label: isHighlighted ? '하이라이트 해제' : '하이라이트',
              icon: isHighlighted ? Icons.highlight : Icons.highlight_outlined,
              isActive: isHighlighted,
              onTap: onHighlight,
            ),
            const SizedBox(width: 6),
            _ActionChip(
              label: hasNote ? '메모 수정' : '메모',
              icon: hasNote ? Icons.edit_note : Icons.note_add_outlined,
              isActive: hasNote,
              onTap: onNote,
            ),
            const SizedBox(width: 6),
            _ActionChip(
              label: 'AI 질문',
              icon: Icons.auto_awesome_outlined,
              isPrimary: true,
              onTap: () => onAskAI(verseId, text),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = isPrimary
        ? cs.primary
        : isActive
        ? cs.primary.withValues(alpha: 0.15)
        : cs.surfaceContainerHighest;
    final fgColor = isPrimary ? cs.onPrimary : cs.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fgColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.ebGaramond(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI 로딩 버블 ─────────────────────────────────────────
class _AiLoadingBubble extends StatelessWidget {
  const _AiLoadingBubble();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 38, bottom: 12, right: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
          const SizedBox(width: 8),
          Text(
            'AI가 해석 중이에요…',
            style: TextStyle(fontSize: 12, color: cs.secondary),
          ),
        ],
      ),
    );
  }
}

// ── AI 답변 버블 ─────────────────────────────────────────
class _AiBubble extends StatelessWidget {
  final String answer;
  const _AiBubble({required this.answer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 38, bottom: 16, right: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                'AI 해석',
                style: GoogleFonts.ebGaramond(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.notoSerifKr(
              fontSize: 13,
              color: cs.onSurface,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 하단 장 이동 ─────────────────────────────────────────
class _BottomChapterNav extends StatelessWidget {
  final int currentChapter;
  final int totalChapters;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomChapterNav({
    required this.currentChapter,
    required this.totalChapters,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasPrev = currentChapter > 1;
    final hasNext = currentChapter < totalChapters;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: hasPrev ? onPrev : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: hasPrev
                      ? cs.surfaceContainerHighest
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: hasPrev ? cs.primary : cs.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentChapter - 1}장',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: hasPrev ? cs.primary : cs.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$currentChapter장',
              style: GoogleFonts.ebGaramond(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: hasNext ? onNext : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: hasNext
                      ? cs.surfaceContainerHighest
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentChapter + 1}장',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: hasNext ? cs.primary : cs.outline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: hasNext ? cs.primary : cs.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 메모 버블 (항상 표시) ────────────────────────────────
class _NoteBubble extends StatelessWidget {
  final String note;
  final VoidCallback onEdit;

  const _NoteBubble({required this.note, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(left: 38, bottom: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.07),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: cs.primary.withValues(alpha: 0.18), width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.edit_note, size: 15, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note,
                style: GoogleFonts.notoSerifKr(
                  fontSize: 13,
                  color: cs.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 메모 작성/편집 시트 ───────────────────────────────────
class _NoteSheet extends StatefulWidget {
  final String verseText;
  final TextEditingController controller;
  final bool hasExisting;
  final Future<void> Function(String) onSave;
  final Future<void> Function() onDelete;

  const _NoteSheet({
    required this.verseText,
    required this.controller,
    required this.hasExisting,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '메모',
            style: GoogleFonts.ebGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          // 해당 절 미리보기
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.verseText,
              style: GoogleFonts.notoSerifKr(
                fontSize: 13,
                color: cs.secondary,
                height: 1.6,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          // 텍스트 입력
          TextField(
            controller: widget.controller,
            autofocus: true,
            maxLines: 4,
            minLines: 2,
            style: GoogleFonts.notoSerifKr(
              fontSize: 14,
              color: cs.onSurface,
              height: 1.7,
            ),
            decoration: InputDecoration(
              hintText: '이 말씀에 대한 묵상이나 기도를 적어보세요…',
              hintStyle: GoogleFonts.notoSerifKr(
                fontSize: 13,
                color: cs.outline,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.hasExisting) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await widget.onDelete();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '삭제',
                          style: GoogleFonts.ebGaramond(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          await widget.onSave(widget.controller.text);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : Text(
                              '저장',
                              style: GoogleFonts.ebGaramond(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 에러 화면 ────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text(
            '불러오기 실패',
            style: GoogleFonts.notoSerifKr(fontSize: 15, color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: cs.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '다시 시도',
                style: GoogleFonts.ebGaramond(
                  fontSize: 13,
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
