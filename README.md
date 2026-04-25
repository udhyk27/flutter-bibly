# Bibly

Bibly는 성경 읽기, 말씀 묵상, 즐겨찾기, 찬송가, 신앙고백을 한곳에서 사용할 수 있는 Flutter 기반 성경 앱입니다. 매일의 말씀과 주간 읽기 기록을 보여주고, 성경 본문에는 TTS, 하이라이트, AI 구절 설명 같은 읽기 보조 기능을 제공합니다.

## 주요 기능

- 성경 66권 목록 제공 및 구약/신약, 장르, 책 이름 기준 탐색
- 장별 성경 본문 읽기, 이전/다음 장 이동, 글자 크기와 줄 간격 설정
- 오늘의 말씀, 주간 읽기 기록, 최근 읽은 장 표시
- 즐겨찾기 저장 및 최근 읽기 기록 관리
- Hive 캐시 기반 성경 본문 저장으로 재방문 시 빠른 로딩
- 캐시된 본문을 대상으로 한 키워드 검색
- 구절별 AI 설명, 성경 책별 흥미로운 이야기 생성
- Flutter TTS를 이용한 장/구절 음성 읽기
- 신앙고백, 찬송가, 설정 화면 제공
- 테마 선택, 알림 예약, 약관/개인정보처리방침 WebView 연결
- Firebase Remote Config, Cloud Functions, AdMob 연동

## 기술 스택

- Flutter / Dart
- Provider
- Firebase Core, Remote Config, Auth, Firestore, Analytics
- Firebase Cloud Functions for Node.js
- Google Gemini API
- Hive / SharedPreferences
- flutter_local_notifications / timezone
- flutter_tts
- google_mobile_ads

## 프로젝트 구조

```text
lib/
  core/        라우팅, 테마 정의
  model/       성경, 즐겨찾기, 최근 읽기, AI 응답 모델
  providers/   테마와 읽기 설정 상태 관리
  screens/     홈, 성경, 읽기, 검색, 즐겨찾기, 설정 등 주요 화면
  services/    성경 API, AI, 알림, 캐시, 즐겨찾기, 읽기 기록 로직
  widgets/     홈 카드, 하단 내비게이션, 메뉴 등 공통 UI

assets/
  data/        오늘의 말씀 JSON 데이터

functions/
  index.js     Gemini API를 호출하는 Firebase Cloud Functions
```

## 실행 방법

```bash
flutter pub get
flutter run
```

Firebase 기능을 사용하려면 각 플랫폼별 Firebase 설정 파일이 필요합니다.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- macOS: `macos/Runner/GoogleService-Info.plist`

Cloud Functions는 `functions/` 디렉터리에서 의존성을 설치한 뒤 실행하거나 배포합니다.

```bash
cd functions
npm install
npm run serve
npm run deploy
```

Gemini 연동을 위해 Firebase Functions secret에 `GEMINI_API_KEY`를 등록해야 합니다.

## 참고 사항

- 성경 본문은 `https://api.getbible.net/v2`에서 불러오며, 앱 내부에서 Hive 캐시에 저장합니다.
- 검색 기능은 현재 기기에 캐시된 성경 본문을 대상으로 동작합니다.
- `lib/screens/bible_reading_screen.dart`의 AdMob 배너 ID는 테스트 ID로 설정되어 있어 출시 전 실제 광고 단위 ID로 교체해야 합니다.
- AI 모델과 스토어/약관 URL 등 일부 설정은 Firebase Remote Config 값을 사용합니다.
