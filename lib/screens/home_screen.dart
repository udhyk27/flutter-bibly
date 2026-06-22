import 'package:flutter/material.dart';
import '../main.dart';
import '../model/bible_models.dart';
import '../widgets/top_bar.dart';
import '../widgets/today_verse_card.dart';
import '../widgets/main_menu_grid.dart';
import '../widgets/recent_section.dart';
import '../widgets/weekly_reading.dart';
import '../services/reading_date_service.dart';
import '../services/recent_read_service.dart';
import '../core/app_router.dart';
import 'bible_reading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  int _recentKey = 0;
  Set<DateTime> _readDays = {};  // 추가

  /// 다른 탭에서 홈으로 돌아올 때 셸이 호출 — 읽기 현황/최근 기록 갱신
  void refresh() {
    if (!mounted) return;
    setState(() => _recentKey++);
    _loadReadDays();
  }

  Future<void> _loadReadDays() async {
    final days = await ReadingDateService.checkedDaysThisWeek();
    if (mounted) setState(() => _readDays = days);
  }

  Future<void> _onDayTap(DateTime day, bool isChecked) async {
    final recents = await RecentReadService.getAll();
    if (recents.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최근 읽은 기록이 없어요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final latest = recents.first;
    final allBooks = [...oldTestament, ...newTestament];
    final book = allBooks.cast<BibleBookModel?>().firstWhere(
      (b) => b!.number == latest.bookNumber,
      orElse: () => null,
    );
    if (book == null || !mounted) return;

    await Navigator.push(
      context,
      AppRouter.slide(
        page: BibleReadingScreen(book: book, chapterNumber: latest.chapter),
      ),
    );
    _loadReadDays();
    setState(() => _recentKey++);
  }

  @override
  void initState() {
    super.initState();
    _loadReadDays(); // 추가
  }

  @override
  void didPopNext() {
    setState(() => _recentKey++);
    _loadReadDays(); // 추가: 성경 화면에서 돌아올 때 날짜 갱신
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const TodayVerseCard(),
                    const SizedBox(height: 10),
                    WeeklyReadingWidget(
                      checkedDays: _readDays,
                      onDayTap: _onDayTap,
                    ),
                    const SizedBox(height: 10),
                    const MainMenuGrid(),
                    const SizedBox(height: 20),
                    RecentSection(key: ValueKey(_recentKey)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}