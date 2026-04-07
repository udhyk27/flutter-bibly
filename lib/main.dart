import 'package:Bibly/providers/reading_settings.dart';
import 'package:Bibly/services/config_api_service.dart';
import 'package:Bibly/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/bible_api_service.dart';
import 'screens/home_screen.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ConfigApiService().getRemoteConfig();

  await MobileAds.instance.initialize();
  await NotificationService().init();
  await BibleApiService.init();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ReadingSettings()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Bibly',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // 전역 변수 사용
      theme: themeProvider.themeData,
      home: const HomeScreen(),
    );
  }
}