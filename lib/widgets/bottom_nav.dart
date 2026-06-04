import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, this.activeIndex = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      _NavItem(icon: Icons.home_outlined,       activeIcon: Icons.home,          label: '홈'),
      _NavItem(icon: Icons.menu_book_outlined,  activeIcon: Icons.menu_book,     label: '성경'),
      _NavItem(icon: Icons.music_note_outlined, activeIcon: Icons.music_note,    label: '찬송가'),
      _NavItem(icon: Icons.settings_outlined,   activeIcon: Icons.settings,      label: '설정'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        )),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = i == activeIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 활성 탭: filled 아이콘으로만 구분
                  Icon(
                    isActive ? items[i].activeIcon : items[i].icon,
                    color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].label,
                    style: tt.labelSmall?.copyWith(
                      color: isActive
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
