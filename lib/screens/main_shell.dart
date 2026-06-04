import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'bible_screen.dart';
import 'hymn_screen.dart';
import 'settings_screen.dart';

/// 하단 탭 4개를 IndexedStack으로 유지하는 메인 셸.
/// 탭 전환 시 화면을 새로 생성하지 않으므로 즉시 전환되고 상태도 보존된다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    const BibleScreen(),
    const HymnScreen(),
    const SettingsScreen(),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    // 홈으로 돌아올 때 읽기 현황/최근 기록 갱신
    if (i == 0) _homeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNav(activeIndex: _index, onTap: _onTap),
    );
  }
}
