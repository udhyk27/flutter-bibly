import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/daily_verse_service.dart';
import '../model/bible_models.dart';
import '../screens/bible_reading_screen.dart';

class TodayVerseCard extends StatefulWidget {
  const TodayVerseCard({super.key});

  @override
  State<TodayVerseCard> createState() => _TodayVerseCardState();
}

class _TodayVerseCardState extends State<TodayVerseCard> {
  DailyVerseModel? _verse;
  bool _loading = true;
  bool _error   = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = false; });
    try {
      final verse = await DailyVerseService.getToday();
      if (mounted) setState(() { _verse = verse; _loading = false; });
    } catch (e) {
      debugPrint('DailyVerse 오류: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  // 해당 장으로 이동
  void _navigateToVerse(BuildContext context) {
    if (_verse == null) return;
    final allBooks = [...oldTestament, ...newTestament];
    final book = allBooks.where((b) => b.id == _verse!.bookId).firstOrNull;
    if (book == null) return; // bookId 매칭 실패 시 이동하지 않음
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BibleReadingScreen(
          book:          book,
          chapterNumber: _verse!.chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 로딩 중 / 에러
    if (_loading || _verse == null) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _error
              ? TextButton.icon(
                  onPressed: _load,
                  icon: Icon(Icons.refresh, size: 18, color: cs.onPrimary),
                  label: Text(
                    '다시 시도',
                    style: TextStyle(color: cs.onPrimary),
                  ),
                )
              : CircularProgressIndicator(
                  color: cs.onPrimary, strokeWidth: 2,
                ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _navigateToVerse(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              '오늘의 말씀',
              style: TextStyle(
                fontSize: 11,
                color: cs.onPrimary.withValues(alpha: 0.65),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            // 본문
            Text(
              '"${_verse!.text}"',
              style: GoogleFonts.notoSerifKr(
                fontSize: 15,
                color: cs.onPrimary,
                height: 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),

            // 출처 + 화살표
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _verse!.reference,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: cs.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: cs.onPrimary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}