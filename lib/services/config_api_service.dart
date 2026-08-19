import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';

class ConfigApiService {

  // --- 싱글톤 ---
  static final ConfigApiService _instance = ConfigApiService._internal();
  // → 클래스당 한 번만 생성되는 유일한 인스턴스

  factory ConfigApiService() => _instance;
  // → 생성자를 factory로 만들어
  //   항상 기존 인스턴스를 반환하도록 제어

  ConfigApiService._internal();
  // → 외부에서 new Api()를 막기 위한
  //   private 생성자

  // 인스턴스에 변수 저장
  String aosVersion = "";
  String playStoreUrl = "";
  String privacyUrl = "";
  String termsUrl = "";

  Future<void> getRemoteConfig() async {

    try {
      final FirebaseRemoteConfig rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await rc.fetchAndActivate();

      aosVersion = rc.getString('app_version_aos');
      playStoreUrl = rc.getString('store_aos');
      privacyUrl = rc.getString('privacy');
      termsUrl = rc.getString('terms');

    } catch (e) {
      debugPrint('REMOTE CONFIG ERROR: $e');
    }
  }
}