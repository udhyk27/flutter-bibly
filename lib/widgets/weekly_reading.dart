import 'package:flutter/material.dart';

/// 이번 주(월~일) 성경 읽기 현황 위젯
/// - checkedDays: 완료된 날짜 Set (BibleScreen 등 외부에서 주입)
/// - onDayTap: 날짜 뱃지 탭 시 호출 (읽은 날짜 여부 전달)
class WeeklyReadingWidget extends StatelessWidget {
  final Set<DateTime> checkedDays;
  final void Function(DateTime day, bool isChecked)? onDayTap;

  const WeeklyReadingWidget({
    super.key,
    this.checkedDays = const {},
    this.onDayTap,
  });

  /// 이번 주 월요일 ~ 일요일 날짜 목록 반환
  static List<DateTime> currentWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final days = currentWeekDays();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final checked = checkedDays
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    // 이번 주 날짜와 교집합으로만 카운트
    final doneCount = days.where((d) => checked.contains(d)).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번 주 성경 읽기', style: tt.titleSmall),
              Text(
                '$doneCount / 7',
                style: tt.labelMedium!.copyWith(color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 날짜 뱃지 ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = days[i];
              final isChecked = checked.contains(day);
              final isToday = day == todayOnly;
              final isPast = day.isBefore(todayOnly);

              return _DayBadge(
                label: _dayLabels[i],
                date: day.day,
                isChecked: isChecked,
                isToday: isToday,
                isPast: isPast,
                cs: cs,
                tt: tt,
                onTap: onDayTap != null ? () => onDayTap!(day, isChecked) : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 개별 날짜 뱃지
// ─────────────────────────────────────────────────────────
class _DayBadge extends StatelessWidget {
  final String label;
  final int date;
  final bool isChecked;
  final bool isToday;
  final bool isPast;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onTap;

  const _DayBadge({
    required this.label,
    required this.date,
    required this.isChecked,
    required this.isToday,
    required this.isPast,
    required this.cs,
    required this.tt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 상태별 색 결정
    final Color circleBg;
    final Color circleText;

    if (isChecked) {
      circleBg = cs.primary;
      circleText = cs.onPrimary;
    } else if (isToday) {
      // 미읽음 오늘: 배경 투명 + 테두리만
      circleBg = Colors.transparent;
      circleText = cs.onSurface.withValues(alpha: 0.8);
    } else if (isPast) {
      circleBg = cs.surfaceContainerLow;
      circleText = cs.onSurface.withValues(alpha: 0.35);
    } else {
      circleBg = cs.surfaceContainerLow;
      circleText = cs.onSurface.withValues(alpha: 0.6);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 요일 라벨
        Text(
          label,
          style: tt.labelSmall!.copyWith(
            color: isToday ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),

        // 원형 날짜 뱃지
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            // 오늘 테두리 강조
            border: isToday && !isChecked
                ? Border.all(color: cs.primary, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: isChecked
              ? Icon(Icons.check, size: 16, color: circleText)
              : Text(
                  '$date',
                  style: tt.labelMedium!.copyWith(
                    color: circleText,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
        ),
      ],
      ),
    );
  }
}
