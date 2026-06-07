import 'package:flutter/material.dart';
import '../model/bible_models.dart';
import '../model/recent_read_model.dart';
import '../services/recent_read_service.dart';
import '../screens/bible_reading_screen.dart';
import '../core/app_router.dart';

class RecentSection extends StatefulWidget {
  const RecentSection({super.key});

  @override
  State<RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<RecentSection> {
  List<RecentReadModel> _recents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await RecentReadService.getAll();
    if (mounted) {
      setState(() {
        _recents = list;
        _loading = false;
      });
    }
  }

  String _timeAgo(int timestamp) {
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (diff.inMinutes < 60) return '방금 전';
    if (diff.inHours   < 24) return '오늘';
    if (diff.inDays    == 1) return '어제';
    if (diff.inDays    <  7) return '${diff.inDays}일 전';
    return '${(diff.inDays / 7).floor()}주 전';
  }

  void _goToReading(RecentReadModel item) {
    Navigator.push(
      context,
      AppRouter.slide(
        page: BibleReadingScreen(
          book: BibleBookModel(
            number:        item.bookNumber,
            name:          item.bookName,
            nameLong:      item.bookNameLong,
            englishName:   item.bookEnglishName,
            id:            item.bookId,
            genre:         item.bookGenre,
            totalChapters: item.totalChapters,
          ),
          chapterNumber: item.chapter,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 읽은',
          style: tt.labelLarge?.copyWith(
            letterSpacing: 0.3,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 8),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_recents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '아직 읽은 기록이 없어요',
              style: tt.bodySmall?.copyWith(color: cs.secondary),
            ),
          )
        else
          ..._recents.map((item) => _RecentRow(
            title:   '${item.bookName} ${item.chapter}장',
            timeAgo: _timeAgo(item.timestamp),
            onTap:   () => _goToReading(item),
          )),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  final String       title;
  final String       timeAgo;
  final VoidCallback onTap;

  const _RecentRow({
    required this.title,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outline, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: tt.bodyMedium),
              Row(
                children: [
                  Text(timeAgo, style: tt.labelMedium),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: cs.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}