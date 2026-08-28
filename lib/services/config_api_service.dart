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

  // 기본값 — Remote Config 미설정/fetch 실패 시에도 항상 유효한 링크가 열리도록 한다.
  static const String _defaultPrivacyUrl = 'https://udhyk27.github.io/bibly/privacy';
  static const String _defaultTermsUrl   = 'https://udhyk27.github.io/bibly/terms';

  // 인스턴스에 변수 저장
  String aosVersion = "";
  String playStoreUrl = "";
  String privacyUrl = _defaultPrivacyUrl;
  String termsUrl = _defaultTermsUrl;

  Future<void> getRemoteConfig() async {

    try {
      final FirebaseRemoteConfig rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      // Remote Config에 값이 없을 때 사용할 기본값
      await rc.setDefaults(const {
        'privacy': _defaultPrivacyUrl,
        'terms': _defaultTermsUrl,
      });

      await rc.fetchAndActivate();

      aosVersion = rc.getString('app_version_aos');
      playStoreUrl = rc.getString('store_aos');

      // Remote Config 값이 비어 있으면 기본값을 유지한다.
      final privacy = rc.getString('privacy');
      final terms   = rc.getString('terms');
      if (privacy.isNotEmpty) privacyUrl = privacy;
      if (terms.isNotEmpty)   termsUrl   = terms;

    } catch (e) {
      debugPrint('REMOTE CONFIG ERROR: $e');
    }
  }
}