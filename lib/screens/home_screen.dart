import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/top_bar.dart';
import '../widgets/today_verse_card.dart';
import '../widgets/main_menu_grid.dart';
import '../widgets/recent_section.dart';
import '../widgets/weekly_reading.dart';
import '../services/reading_date_service.dart'; // 추가

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

  // 읽기 날짜 로드
  Future<void> _loadReadDays() async {
    final days = await ReadingDateService.checkedDaysThisWeek();
    if (mounted) setState(() => _readDays = days);
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
                    AbsorbPointer(
                      child: WeeklyReadingWidget(checkedDays: _readDays), // 수정
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