import 'package:bibly/providers/auth_provider.dart';
import 'package:bibly/providers/reading_settings.dart';
import 'package:bibly/services/config_api_service.dart';
import 'package:bibly/services/notification_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'services/bible_api_service.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    // 앱 무결성 검증(App Check) — 위조된 요청으로부터 Cloud Functions를 보호한다.
    // 디버그 빌드에서는 debug provider를 사용해야 개발 중에도 토큰이 발급된다.
    // (콘솔의 App Check에 디버그 토큰을 등록해 두어야 함)
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
    // Remote Config는 설정 화면 등 후속 화면에서만 쓰이므로
    // 시작 지연을 피하기 위해 await하지 않고 백그라운드로 로딩한다.
    ConfigApiService().getRemoteConfig();
    await MobileAds.instance.initialize();
    await NotificationService().init();
  } catch (e, st) {
    // 초기화 일부가 실패해도 앱은 계속 실행되도록 한다.
    debugPrint('앱 초기화 오류: $e\n$st');
  }

  // 성경 로컬 캐시(Hive)는 앱 동작에 필수이므로 실패 시 그대로 보고한다.
  await BibleApiService.init();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool(OnboardingScreen.prefsKey) ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReadingSettings()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, this.hasSeenOnboarding = true});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Bibly',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // 전역 변수 사용
      theme: themeProvider.themeData,
      home: hasSeenOnboarding ? const MainShell() : const OnboardingScreen(),
    );
  }
}
