import 'package:flutter/material.dart';

/// 깔끔한 커스텀 시간 선택 바텀시트
///
/// 사용법:
///   final picked = await showCustomTimePicker(
///     context: context,
///     initialTime: _verseTime,
///   );
///   if (picked != null) setState(() => _verseTime = picked);

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CustomTimePicker(initialTime: initialTime),
  );
}

class _CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  const _CustomTimePicker({required this.initialTime});

  @override
  State<_CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<_CustomTimePicker> {
  late int _hour;
  late int _minute;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour   = widget.initialTime.hour;
    _minute = widget.initialTime.minute;

    _hourController   = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 타이틀 + 확인 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('시간 설정',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    )),
                GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _hour, minute: _minute),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('확인',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: cs.onPrimary,
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 피커
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // 시 피커
                  Expanded(
                    child: _PickerColumn(
                      controller: _hourController,
                      itemCount: 24,
                      selectedIndex: _hour,
                      label: '시',
                      onChanged: (v) => setState(() => _hour = v),
                    ),
                  ),

                  // 구분자
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(':',
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w300,
                          color: cs.onSurface,
                        )),
                  ),

                  // 분 피커
                  Expanded(
                    child: _PickerColumn(
                      controller: _minuteController,
                      itemCount: 60,
                      selectedIndex: _minute,
                      label: '분',
                      onChanged: (v) => setState(() => _minute = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int    itemCount;
  final int    selectedIndex;
  final String label;
  final ValueChanged<int> onChanged;

  const _PickerColumn({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 선택 영역 하이라이트
        Positioned(
          child: Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // 스크롤 휠
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 44,
          perspective: 0.003,
          diameterRatio: 2.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (context, index) {
              final isSelected = index == selectedIndex;
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize:   isSelected ? 22 : 18,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected ? cs.primary : cs.outline,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}