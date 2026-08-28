import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data; // latest → latest_all (전체 타임존 포함)

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const int _dailyVerseId = 0;
  static const int _prayerId     = 1;

  // ── 초기화 ───────────────────────────────────────────
  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // ✅ 타임존 명시 설정

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // ✅ init에서는 false, 권한은 requestPermission()에서 요청
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // ✅ Android 알림 채널 생성 (Android 8.0+ 필수)
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'daily_verse',
        '오늘의 말씀',
        description: '매일 말씀 알림',
        importance: Importance.high,
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_reminder',
        '기도 알림',
        description: '기도 시간 알림',
        importance: Importance.defaultImportance,
      ),
    );
  }

  // ── 권한 요청 ─────────────────────────────────────────
  Future<bool> requestPermission() async {
    // ✅ iOS 권한 요청 추가
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true, badge: true, sound: true,
      );
      return granted ?? false;
    }

    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ── 오늘의 말씀 알림 예약 ──────────────────────────────
  Future<void> scheduleDailyVerse(TimeOfDay time) async {
    await _plugin.cancel(id: _dailyVerseId);
    await _plugin.zonedSchedule(
      id: _dailyVerseId,
      title: '오늘의 말씀 📖',
      body: '말씀으로 하루를 시작하세요',
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse',
          '오늘의 말씀',
          channelDescription: '매일 말씀 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 매일 정해진 시각의 말씀/기도 알림은 초 단위 정확도가 필요 없으므로
      // 부정확(inexact) 모드를 사용한다. 정확 알람(exact)은 Android 14+에서
      // 기본 거부되어 예약이 실패할 수 있다.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── 기도 알림 예약 ────────────────────────────────────
  Future<void> schedulePrayer(TimeOfDay time) async {
    await _plugin.cancel(id: _prayerId);
    await _plugin.zonedSchedule(
      id: _prayerId,
      title: '기도 시간 🙏',
      body: '잠시 멈추고 기도하는 시간을 가져보세요',
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminder',
          '기도 알림',
          channelDescription: '기도 시간 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 매일 정해진 시각의 말씀/기도 알림은 초 단위 정확도가 필요 없으므로
      // 부정확(inexact) 모드를 사용한다. 정확 알람(exact)은 Android 14+에서
      // 기본 거부되어 예약이 실패할 수 있다.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── 알림 취소 ─────────────────────────────────────────
  Future<void> cancelDailyVerse() => _plugin.cancel(id: _dailyVerseId);
  Future<void> cancelPrayer()     => _plugin.cancel(id: _prayerId);

  // ── 다음 알림 시각 계산 ───────────────────────────────
  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      time.hour, time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}