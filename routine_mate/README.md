# 🎯 RoutineMate

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
</div>

<div align="center">
  <h3>일상 루틴을 스마트하게 관리하는 앱</h3>
  <p>자동 알림 📢 | 음성 안내 🔊 | 실시간 동기화 ⚡</p>
</div>

---

## ✨ 주요 기능

### 🎯 핵심 기능
- ✅ **사용자 인증**: 이메일/비밀번호 및 Google 소셜 로그인
- ✅ **사용자별 데이터 분리**: 각 사용자의 루틴 개별 관리
- ✅ **루틴 관리**: 시작/종료 시간 설정으로 체계적인 일정 관리
- 🔔 **스마트 알림**: 시작/중간/종료 시점 자동 알림
- 🔊 **음성 안내**: 한국어 TTS로 실시간 피드백
- ☁️ **클라우드 동기화**: Firebase Firestore 실시간 데이터베이스
- 🎨 **Modern UI**: Material Design 3 적용
- 🔐 **안전한 보안**: Firebase Authentication + Firestore 보안 규칙

### 🎨 새로운 디자인
- 💎 **커스텀 로고**: 그라디언트 효과의 아름다운 로고
- 🌈 **반응형 카드**: 루틴 카드에 그라디언트 배경 적용
- ✨ **애니메이션**: 부드러운 UI/UX 경험

---

## 📱 스크린샷

### 메인 화면
```
┌──────────────────────────────┐
│  🎯 RoutineMate             │  ← 커스텀 로고
├──────────────────────────────┤
│  루틴 추가 폼                 │
│  ┌────────────────────────┐  │
│  │ 제목: [입력]            │  │
│  │ [시작] [종료]           │  │
│  │ [루틴 추가 버튼]        │  │
│  └────────────────────────┘  │
├──────────────────────────────┤
│  📋 등록된 루틴               │
│  ┌────────────────────────┐  │
│  │ 1  아침 운동       🗑️  │  │
│  │    ⏰ 07:00 ~ 08:00    │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

## 🚀 시작하기

### 1. 저장소 클론
```bash
git clone https://github.com/ambrosia0715/RoutineMate.git
cd RoutineMate/routine_mate
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. Firebase 설정
1. Firebase 콘솔에서 프로젝트 생성
2. **Authentication 활성화**:
   - 이메일/비밀번호 사용 설정
   - Google 로그인 사용 설정
3. **Firestore Database 생성**:
   - 테스트 모드로 시작
   - 보안 규칙 업데이트 (아래 참조)
4. `google-services.json` 다운로드 → `android/app/` 에 배치
5. FlutterFire CLI로 설정:
```bash
flutterfire configure
```

#### Firestore 보안 규칙:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /routines/{routineId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### 4. 앱 실행
```bash
flutter run
```

---

## 📦 패키지

```yaml
dependencies:
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  google_sign_in: ^6.2.2
  flutter_tts: ^4.2.3
  flutter_local_notifications: ^19.5.0
  provider: ^6.1.5+1
```

---

## 🎨 로고 디자인

RoutineMate의 커스텀 로고는 다음을 상징합니다:
- 🎯 **타겟**: 명확한 목표와 루틴
- ✅ **체크마크**: 완료와 성취
- 🌈 **그라디언트**: 현대적이고 역동적인 디자인

자세한 내용은 [LOGO_DESIGN.md](LOGO_DESIGN.md)를 참조하세요.

---

## 📖 문서

- [AUTHENTICATION_GUIDE.md](AUTHENTICATION_GUIDE.md) - 인증 시스템 완전 가이드
- [FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md) - Firebase Console 설정 가이드
- [FEATURES.md](FEATURES.md) - 전체 기능 설명
- [QUICKSTART.md](QUICKSTART.md) - 빠른 시작 가이드
- [LOGO_DESIGN.md](LOGO_DESIGN.md) - 로고 디자인 가이드
- [FIRESTORE_TROUBLESHOOTING.md](FIRESTORE_TROUBLESHOOTING.md) - 문제 해결
- [FIREBASE_RULES.md](FIREBASE_RULES.md) - 보안 규칙

---

## 🎯 사용 방법

### 회원가입 / 로그인
1. 앱 실행 → 로그인 화면
2. **이메일/비밀번호로 가입**:
   - "회원가입" 클릭
   - 이름, 이메일, 비밀번호 입력
   - 회원가입 완료 후 로그인
3. **Google로 로그인**:
   - "Google로 로그인" 클릭
   - Google 계정 선택
   - 자동으로 로그인 완료

### 루틴 추가
1. 루틴 제목 입력
2. 시작 시간 선택
3. 종료 시간 선택
4. "루틴 추가" 버튼 클릭
5. 🔊 음성으로 확인 메시지 수신

### 알림 받기
- **시작 알림**: 루틴 시작 시간
- **중간 알림**: 절반 진행 시점
- **종료 알림**: 루틴 종료 시간

---

## 🔧 기술 스택

- **Frontend**: Flutter 3.9.2
- **Backend**: Firebase (Firestore, Auth)
- **Notifications**: flutter_local_notifications
- **TTS**: flutter_tts
- **State Management**: Provider (선택적)

---

## 🎁 특별한 기능

### 1. 스마트 알림 스케줄링
```dart
시작: 07:00 → 🎯 "아침 운동 시작!"
중간: 07:30 → ⏰ "절반 진행!"
종료: 08:00 → ✅ "완료!"
```

### 2. 실시간 동기화
여러 기기에서 동시에 루틴 관리 가능

### 3. 음성 피드백
모든 액션에 대한 한국어 TTS 안내

---

## 🐛 문제 해결

### 알림이 안 보일 때
1. 설정 > 앱 > RoutineMate > 알림 권한 확인
2. 배터리 최적화 제외

### TTS가 작동 안 할 때
1. 기기 설정 > 접근성 > TTS 확인
2. 한국어 TTS 엔진 설치 확인

---

## 🔮 향후 계획

- [ ] 위젯 지원
- [ ] 다크 모드
- [ ] 루틴 통계 대시보드
- [ ] 카테고리별 루틴 분류
- [ ] 반복 루틴 설정
- [ ] 소셜 기능 (친구와 루틴 공유)

---

## 📄 라이선스

MIT License

---

## 👨‍💻 개발자

**RoutineMate Team**
- GitHub: [@ambrosia0715](https://github.com/ambrosia0715)

---

## 🌟 기여하기

PR은 언제나 환영합니다! 

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

---

<div align="center">
  <p>Made with ❤️ by RoutineMate Team</p>
  <p>⭐ 이 프로젝트가 도움이 되었다면 Star를 눌러주세요!</p>
</div>
