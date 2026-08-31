import 'package:bibly/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart' as auth;
import '../providers/theme_provider.dart';
import '../providers/reading_settings.dart';
import '../core/app_theme.dart';
import '../services/config_api_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_timpe_picker.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SettingsTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  _SectionLabel(label: '테마'),
                  _ThemeSelector(),
                  const SizedBox(height: 8),
                  _SectionLabel(label: '읽기'),
                  _ReadingSettings(),
                  const SizedBox(height: 8),
                  _SectionLabel(label: '성경'),
                  _BibleSettings(),
                  const SizedBox(height: 8),
                  _SectionLabel(label: '알림'),
                  _NotificationSettings(),
                  const SizedBox(height: 8),
                  _SectionLabel(label: '계정'),
                  _AccountSection(),
                  const SizedBox(height: 8),
                  _SectionLabel(label: '앱 정보'),
                  _AppInfo(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상단 바 ──────────────────────────────────────────
class _SettingsTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 라벨 ──────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(label, style: tt.labelLarge?.copyWith(letterSpacing: 0.3)),
    );
  }
}

// ── 설정 카드 ──────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

// ── 설정 행 ──────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData      icon;
  final String        label;
  final String?       subLabel;
  final Widget?       trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon, required this.label,
    this.subLabel, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outline, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.bodyMedium),
                  if (subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(subLabel!, style: tt.labelMedium),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ── 마지막 행 (보더 없음) ──────────────────────────────
class _SettingsRowLast extends StatelessWidget {
  final IconData      icon;
  final String        label;
  final String?       subLabel;
  final Widget?       trailing;
  final VoidCallback? onTap;

  const _SettingsRowLast({
    required this.icon, required this.label,
    this.subLabel, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 14, color: cs.onSurface)),
                  if (subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(subLabel!,
                        style: TextStyle(fontSize: 11, color: cs.secondary)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ── 테마 선택 ──────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      children: [
        _ThemeCard(
          label: '세이지 & 크림',
          desc: '따뜻하고 자연스러운 녹색 계열',
          colors: const [
            Color(0xFF4A7A42), Color(0xFFE8F0E4),
            Color(0xFFC8A97A), Color(0xFFF5F7F2),
          ],
          isSelected: themeProvider.themeType == AppThemeType.sage,
          onTap: () => themeProvider.setTheme(AppThemeType.sage),
        ),
        const SizedBox(height: 8),
        _ThemeCard(
          label: '블루그레이 & 오프화이트',
          desc: '단정하고 신뢰감 있는 블루 계열',
          colors: const [
            Color(0xFF4A6E96), Color(0xFFE2E8F2),
            Color(0xFFB8A890), Color(0xFFF4F6F9),
          ],
          isSelected: themeProvider.themeType == AppThemeType.blueGray,
          onTap: () => themeProvider.setTheme(AppThemeType.blueGray),
        ),
        const SizedBox(height: 8),
        _ThemeCard(
          label: '양피지 & 세피아',
          desc: '고전 성경책의 따뜻한 크림 계열',
          colors: const [
            Color(0xFF7B1D1D), Color(0xFFEDE4CC),
            Color(0xFFA0804A), Color(0xFFF5EFE0),
          ],
          isSelected: themeProvider.themeType == AppThemeType.parchment,
          onTap: () => themeProvider.setTheme(AppThemeType.parchment),
        ),
        const SizedBox(height: 8),
        _ThemeCard(
          label: '소프트 다크',
          desc: '눈이 편한 짙은 회색 다크 모드',
          colors: const [
            Color(0xFFA8C5A0), // primary
            Color(0xFF313131), // surfaceHigh
            Color(0xFF8A9E86), // secondary
            Color(0xFF1E1E1E), // background
          ],
          isSelected: themeProvider.themeType == AppThemeType.softDark,
          onTap: () => themeProvider.setTheme(AppThemeType.softDark),
        ),

      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String       label;
  final String       desc;
  final List<Color>  colors;
  final bool         isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label, required this.desc,
    required this.colors, required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Row(
              children: colors.map((c) => Container(
                width: 22, height: 22,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cs.outline, width: 0.5),
                ),
              )).toList(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.titleSmall),
                  Text(desc,  style: tt.labelMedium),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: cs.primary, size: 20)
            else
              Icon(Icons.circle_outlined, color: cs.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 읽기 설정 ──────────────────────────────────────────
// 모든 값을 ReadingSettings Provider 에서 읽고 씁니다.
class _ReadingSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final settings = context.watch<ReadingSettings>();

    return _SettingsCard(
      children: [
        // 글씨 크기
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.text_fields_outlined,
                        size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('글씨 크기',
                      style: TextStyle(fontSize: 14, color: cs.onSurface)),
                ],
              ),
              Text('${settings.fontSize.toInt()}px',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: cs.primary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text('가', style: TextStyle(fontSize: 12, color: cs.secondary)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 12, max: 26, divisions: 7,
                  activeColor: cs.primary,
                  inactiveColor: cs.surfaceContainerHighest,
                  onChanged: (v) =>
                      context.read<ReadingSettings>().setFontSize(v),
                ),
              ),
              Text('가',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500,
                      color: cs.secondary)),
            ],
          ),
        ),

        // 줄 간격
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.format_line_spacing,
                        size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('줄 간격',
                      style: TextStyle(fontSize: 14, color: cs.onSurface)),
                ],
              ),
              Text(settings.lineHeight.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: cs.primary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Slider(
            value: settings.lineHeight,
            min: 1.4, max: 2.4, divisions: 5,
            activeColor: cs.primary,
            inactiveColor: cs.surfaceContainerHighest,
            onChanged: (v) =>
                context.read<ReadingSettings>().setLineHeight(v),
          ),
        ),

        // 절 번호 표시 — Provider 연결
        _SettingsRow(
          icon: Icons.tag,
          label: '절 번호 표시',
          trailing: Switch(
            value: settings.showVerseNum,
            activeThumbColor: cs.primary,
            onChanged: (v) =>
                context.read<ReadingSettings>().setShowVerseNum(v),
          ),
        ),

        // 하이라이트 표시 — Provider 연결
        _SettingsRowLast(
          icon: Icons.highlight_outlined,
          label: '하이라이트 표시',
          subLabel: '저장한 하이라이트를 본문에 표시',
          trailing: Switch(
            value: settings.showHighlight,
            activeThumbColor: cs.primary,
            onChanged: (v) =>
                context.read<ReadingSettings>().setShowHighlight(v),
          ),
        ),
      ],
    );
  }
}

// ── 성경 설정 ──────────────────────────────────────────
// 번역본·언어를 Provider 에 저장합니다.
class _BibleSettings extends StatelessWidget {
  static const _translations = ['개역개정', '개역한글', '새번역', 'KJV', 'NIV', 'ESV'];
  static const _languages    = ['한국어', 'English', '日本語', 'Español', 'Português'];

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              const SizedBox(height: 12),
              ...items.map((item) => GestureDetector(
                onTap: () {
                  onSelect(item);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: cs.outline, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item, style: tt.bodyMedium),
                      if (selected == item)
                        Icon(Icons.check, size: 18, color: cs.primary),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final settings = context.watch<ReadingSettings>();

    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: Icons.book_outlined,
          label: '번역본',
          subLabel: settings.translation,
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () => _showPicker(
            context: context,
            title: '번역본 선택',
            items: _translations,
            selected: settings.translation,
            onSelect: (v) => context.read<ReadingSettings>().setTranslation(v),
          ),
        ),
        _SettingsRowLast(
          icon: Icons.language_outlined,
          label: '언어',
          subLabel: settings.language,
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () => _showPicker(
            context: context,
            title: '언어 선택',
            items: _languages,
            selected: settings.language,
            onSelect: (v) => context.read<ReadingSettings>().setLanguage(v),
          ),
        ),
      ],
    );
  }
}

// ── 알림 설정 ──────────────────────────────────────────
// NotificationService 와 연동합니다.
class _NotificationSettings extends StatefulWidget {
  @override
  State<_NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<_NotificationSettings> {
  static const _kDailyVerse     = 'notif_daily_verse';
  static const _kPrayerReminder = 'notif_prayer_reminder';
  static const _kVerseHour      = 'notif_verse_hour';
  static const _kVerseMinute    = 'notif_verse_minute';
  static const _kPrayerHour     = 'notif_prayer_hour';
  static const _kPrayerMinute   = 'notif_prayer_minute';

  bool      _dailyVerse     = false;
  bool      _prayerReminder = false;
  TimeOfDay _verseTime      = const TimeOfDay(hour: 7,  minute: 0);
  TimeOfDay _prayerTime     = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyVerse     = prefs.getBool(_kDailyVerse)     ?? false;
      _prayerReminder = prefs.getBool(_kPrayerReminder) ?? false;
      _verseTime  = TimeOfDay(
        hour:   prefs.getInt(_kVerseHour)   ?? 7,
        minute: prefs.getInt(_kVerseMinute) ?? 0,
      );
      _prayerTime = TimeOfDay(
        hour:   prefs.getInt(_kPrayerHour)   ?? 21,
        minute: prefs.getInt(_kPrayerMinute) ?? 0,
      );
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDailyVerse,     _dailyVerse);
    await prefs.setBool(_kPrayerReminder, _prayerReminder);
    await prefs.setInt(_kVerseHour,       _verseTime.hour);
    await prefs.setInt(_kVerseMinute,     _verseTime.minute);
    await prefs.setInt(_kPrayerHour,      _prayerTime.hour);
    await prefs.setInt(_kPrayerMinute,    _prayerTime.minute);
  }

  Future<void> _pickTime(BuildContext context, bool isVerse) async {
    final picked = await showCustomTimePicker(
      context: context,
      initialTime: isVerse ? _verseTime : _prayerTime,
    );
    if (picked == null) return;

    setState(() {
      if (isVerse) {
        _verseTime = picked;
      } else {
        _prayerTime = picked;
      }
    });
    await _savePrefs();

    if (isVerse && _dailyVerse) {
      await NotificationService().scheduleDailyVerse(picked);
    }
    if (!isVerse && _prayerReminder) {
      await NotificationService().schedulePrayer(picked);
    }
  }

  // 알림 권한이 거부되면 알림을 켜도 아무것도 오지 않으므로,
  // 권한 요청 결과를 확인해 거부 시 토글을 되돌리고 안내한다.
  Future<void> _toggleDailyVerse(bool v) async {
    if (v) {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        if (!mounted) return;
        setState(() => _dailyVerse = false);
        await _savePrefs();
        _showPermissionDenied();
        return;
      }
    }

    setState(() => _dailyVerse = v);
    await _savePrefs();

    if (v) {
      await NotificationService().scheduleDailyVerse(_verseTime);
    } else {
      await NotificationService().cancelDailyVerse();
    }
  }

  Future<void> _togglePrayer(bool v) async {
    if (v) {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        if (!mounted) return;
        setState(() => _prayerReminder = false);
        await _savePrefs();
        _showPermissionDenied();
        return;
      }
    }

    setState(() => _prayerReminder = v);
    await _savePrefs();

    if (v) {
      await NotificationService().schedulePrayer(_prayerTime);
    } else {
      await NotificationService().cancelPrayer();
    }
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('알림 권한이 꺼져 있어요. 기기 설정에서 알림을 허용해주세요.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _SettingsCard(
      children: [
        // 오늘의 말씀 알림
        _SettingsRow(
          icon: Icons.wb_sunny_outlined,
          label: '오늘의 말씀 알림',
          subLabel: _dailyVerse
              ? '매일 ${_verseTime.format(context)}'
              : '꺼짐',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_dailyVerse)
                GestureDetector(
                  onTap: () => _pickTime(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _verseTime.format(context),
                      style: TextStyle(
                          fontSize: 12, color: cs.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Switch(
                value: _dailyVerse,
                activeThumbColor: cs.primary,
                onChanged: _toggleDailyVerse,
              ),
            ],
          ),
        ),

        // 기도 알림
        _SettingsRowLast(
          icon: Icons.nightlight_outlined,
          label: '기도 알림',
          subLabel: _prayerReminder
              ? '매일 ${_prayerTime.format(context)}'
              : '꺼짐',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_prayerReminder)
                GestureDetector(
                  onTap: () => _pickTime(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _prayerTime.format(context),
                      style: TextStyle(
                          fontSize: 12, color: cs.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Switch(
                value: _prayerReminder,
                activeThumbColor: cs.primary,
                onChanged: _togglePrayer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 계정 ──────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final tt        = Theme.of(context).textTheme;
    final authProv  = context.watch<auth.AuthProvider>();

    if (!authProv.isSignedIn) {
      return _SettingsCard(
        children: [
          _SettingsRowLast(
            icon: Icons.login_outlined,
            label: '로그인',
            subLabel: '구글 계정으로 로그인하세요',
            trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
            onTap: () async {
            final ok = await authProv.signInWithGoogle();
            if (!ok && context.mounted && authProv.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('로그인 실패: ${authProv.errorMessage}')),
              );
            }
          },
          ),
        ],
      );
    }

    final user       = authProv.user!;
    final email      = user.email ?? '';
    final name       = user.displayName ?? email;
    final photoUrl   = user.photoURL;

    return _SettingsCard(
      children: [
        // 유저 정보 행
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Icon(Icons.person_outline, size: 18, color: cs.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,  style: tt.bodyMedium),
                    Text(email, style: tt.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 구분선
        Divider(height: 0.5, thickness: 0.5, color: cs.outline),
        // 로그아웃 버튼
        _SettingsRowLast(
          icon: Icons.logout,
          label: '로그아웃',
          onTap: () => _confirmSignOut(context, authProv),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, auth.AuthProvider authProv) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소', style: TextStyle(color: cs.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('로그아웃',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await authProv.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }
}

// ── 앱 정보 ──────────────────────────────────────────
class _AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: Icons.info_outline,
          label: '버전',
          subLabel: ConfigApiService().aosVersion,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('최신 버전',
                style: tt.labelSmall?.copyWith(color: cs.primary)),
          ),
        ),
        _SettingsRow(
          icon: Icons.star_outline,
          label: '앱 평가하기',
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () {
            final url = ConfigApiService().playStoreUrl;
            if (url.isNotEmpty) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          },
        ),
        _SettingsRow(
          icon: Icons.share_outlined,
          label: '앱 공유하기',
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () => SharePlus.instance
              .share(ShareParams(text: ConfigApiService().playStoreUrl)),
        ),
        _SettingsRow(
          icon: Icons.lock_outline,
          label: '개인정보처리방침',
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewScreen(
                url: ConfigApiService().privacyUrl,
                title: '개인정보처리방침',
              ),
            ),
          ),
        ),
        _SettingsRowLast(
          icon: Icons.description_outlined,
          label: '이용약관',
          trailing: Icon(Icons.chevron_right, size: 18, color: cs.outline),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewScreen(
                url: ConfigApiService().termsUrl,
                title: '이용약관',
              ),
            ),
          ),
        ),
      ],
    );
  }
}