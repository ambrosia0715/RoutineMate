# 🔐 Firebase Authentication 가이드

## ✨ 추가된 기능

### 1️⃣ 이메일/비밀번호 인증
- ✅ 회원가입 (이름, 이메일, 비밀번호)
- ✅ 로그인
- ✅ 로그아웃
- ✅ 비밀번호 유효성 검사

### 2️⃣ Google 소셜 로그인
- ✅ Google 계정으로 빠른 로그인
- ✅ 자동 프로필 정보 가져오기

### 3️⃣ 사용자별 데이터 관리
- ✅ 각 사용자의 루틴 분리 저장
- ✅ userId 기반 데이터 필터링
- ✅ Firestore 보안 규칙 적용 가능

---

## 📱 화면 구성

### 1. 로그인 화면 (LoginScreen)
```
┌─────────────────────────────────┐
│         🎯 RoutineMate         │
│  루틴을 관리하는 가장 스마트한 방법 │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 📧 이메일                  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🔒 비밀번호                │  │
│  └───────────────────────────┘  │
│                                 │
│  [      로그인 버튼       ]     │
│                                 │
│  ─────────── 또는 ──────────    │
│                                 │
│  [🔍 Google로 로그인]           │
│                                 │
│  계정이 없으신가요? [회원가입]    │
└─────────────────────────────────┘
```

### 2. 회원가입 화면 (SignUpScreen)
```
┌─────────────────────────────────┐
│       새로운 계정 만들기         │
│  RoutineMate와 함께 시작하세요   │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 👤 이름                    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 📧 이메일                  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🔒 비밀번호                │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🔒 비밀번호 확인            │  │
│  └───────────────────────────┘  │
│                                 │
│  [      회원가입 버튼      ]     │
│                                 │
│  이미 계정이 있으신가요? [로그인]  │
└─────────────────────────────────┘
```

### 3. 홈 화면 (로그인 후)
```
┌─────────────────────────────────┐
│  🎯 RoutineMate    User名  ⋮   │
│                          └─로그아웃
├─────────────────────────────────┤
│  [루틴 추가 폼]                  │
├─────────────────────────────────┤
│  내 루틴 목록 (사용자별 분리)     │
└─────────────────────────────────┘
```

---

## 🔧 구현 상세

### AuthService (services/auth_service.dart)

#### 주요 메서드:

```dart
// 회원가입
Future<UserCredential?> signUpWithEmail({
  required String email,
  required String password,
  required String name,
})

// 로그인
Future<UserCredential?> signInWithEmail({
  required String email,
  required String password,
})

// Google 로그인
Future<UserCredential?> signInWithGoogle()

// 로그아웃
Future<void> signOut()
```

#### 기능:
- ✅ Firebase Authentication 연동
- ✅ 에러 메시지 한글화
- ✅ Firestore에 사용자 정보 저장
- ✅ 상세한 로깅

---

## 📊 데이터 구조

### Firestore - users 컬렉션
```javascript
users/
  └── [userId]/
      ├── name: "홍길동"
      ├── email: "user@example.com"
      ├── createdAt: Timestamp
      ├── provider: "email" | "google"
      └── photoUrl: "https://..." (Google만)
```

### Firestore - routines 컬렉션 (수정됨)
```javascript
routines/
  └── [routineId]/
      ├── userId: "abc123"      ← 추가됨!
      ├── title: "아침 운동"
      ├── start: "07:00"
      ├── end: "08:00"
      └── createdAt: Timestamp
```

---

## 🔐 Firebase 설정

### 1. Firebase Console 설정

#### Authentication 활성화:
1. Firebase Console 접속
2. Authentication > Sign-in method
3. 이메일/비밀번호 **사용 설정**
4. Google **사용 설정**

#### Firestore 보안 규칙 (프로덕션용):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 정보
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 루틴 (사용자별 분리)
    match /routines/{routineId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                              resource.data.userId == request.auth.uid;
    }
  }
}
```

### 2. Google 로그인 설정 (Android)

#### SHA-1 지문 추가 (필수):
```bash
# SHA-1 확인
cd android
./gradlew signingReport
```

Firebase Console:
1. 프로젝트 설정
2. Android 앱 선택
3. SHA 인증서 지문 추가
4. `google-services.json` 다시 다운로드

---

## 🎯 사용 흐름

### 신규 사용자:
```
1. 앱 실행 → 로그인 화면
2. "회원가입" 클릭
3. 이름, 이메일, 비밀번호 입력
4. "회원가입" 버튼 클릭
5. 자동으로 로그인 화면으로 이동
6. 이메일/비밀번호 입력하여 로그인
7. 홈 화면으로 이동
```

### Google 로그인:
```
1. 앱 실행 → 로그인 화면
2. "Google로 로그인" 클릭
3. Google 계정 선택
4. 자동으로 홈 화면으로 이동
```

### 기존 사용자:
```
1. 앱 실행 → 자동 로그인 (세션 유지)
2. 바로 홈 화면으로 이동
```

---

## ✅ 유효성 검사

### 이메일:
- ✅ 빈 값 체크
- ✅ @ 포함 확인
- ✅ Firebase 중복 체크

### 비밀번호:
- ✅ 6자 이상 필수
- ✅ 빈 값 체크
- ✅ 비밀번호 확인 일치 체크

### 이름:
- ✅ 빈 값 체크

---

## 🎨 UI/UX 특징

### 로그인 화면:
- 🎯 큰 로고와 브랜드 컬러
- 📱 깔끔한 입력 필드
- 👁️ 비밀번호 보기/숨기기 토글
- ⚡ 로딩 인디케이터
- 🔍 Google 버튼 (아이콘 포함)

### 회원가입 화면:
- 📝 4단계 입력 폼
- 💡 비밀번호 힌트 표시
- ✅ 실시간 유효성 검사
- 🎨 일관된 디자인

### 홈 화면:
- 👤 사용자 이름 표시
- 🚪 로그아웃 메뉴
- 📋 사용자별 루틴 표시

---

## 🐛 에러 처리

### 한글 에러 메시지:

```dart
'weak-password' → '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.'
'email-already-in-use' → '이미 사용 중인 이메일입니다.'
'invalid-email' → '유효하지 않은 이메일 주소입니다.'
'user-not-found' → '존재하지 않는 계정입니다.'
'wrong-password' → '잘못된 비밀번호입니다.'
'too-many-requests' → '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.'
```

### SnackBar 알림:
- 🟢 성공: 녹색 배경
- 🔴 에러: 빨간색 배경
- ⚪ 정보: 기본 색상

---

## 🔍 디버깅 로그

### 인증 관련:
```
📝 회원가입 시도: user@example.com
✅ 회원가입 성공: abc123
🔐 로그인 시도: user@example.com
✅ 로그인 성공: abc123
🔍 Google 로그인 시도
✅ Google 로그인 성공: xyz789
👋 로그아웃 시도
✅ 로그아웃 완료
```

### 루틴 관련 (사용자별):
```
📥 Firestore 데이터 수신: 3개 (userId: abc123)
💾 루틴 저장 시도: 아침 운동 (userId: abc123)
✅ 루틴 저장 성공! ID: routine123
```

---

## 🚀 테스트 시나리오

### 1. 회원가입 테스트:
```
1. 앱 실행
2. "회원가입" 클릭
3. 정보 입력:
   - 이름: 테스트 유저
   - 이메일: test@example.com
   - 비밀번호: test123
   - 비밀번호 확인: test123
4. "회원가입" 버튼 클릭
5. 성공 메시지 확인
6. 로그인 화면으로 자동 이동 확인
```

### 2. 로그인 테스트:
```
1. 로그인 화면에서:
   - 이메일: test@example.com
   - 비밀번호: test123
2. "로그인" 버튼 클릭
3. 홈 화면으로 이동 확인
4. 상단에 사용자 이름 표시 확인
```

### 3. Google 로그인 테스트:
```
1. "Google로 로그인" 클릭
2. Google 계정 선택
3. 권한 허용
4. 홈 화면으로 이동 확인
5. Google 프로필 정보 확인
```

### 4. 루틴 저장 테스트 (사용자별):
```
1. 사용자 A로 로그인
2. 루틴 추가: "아침 운동"
3. 로그아웃
4. 사용자 B로 로그인
5. 빈 루틴 목록 확인 (분리됨!) ✅
6. 루틴 추가: "저녁 독서"
7. 로그아웃 후 사용자 A로 재로그인
8. "아침 운동"만 표시됨 확인 ✅
```

### 5. 로그아웃 테스트:
```
1. 상단 ⋮ 메뉴 클릭
2. "로그아웃" 클릭
3. 확인 다이얼로그에서 "로그아웃" 클릭
4. 로그인 화면으로 이동 확인
```

---

## 📦 추가된 파일

```
lib/
├── services/
│   └── auth_service.dart          ← 인증 서비스
├── screens/
│   ├── login_screen.dart          ← 로그인 화면 (개선됨)
│   └── signup_screen.dart         ← 회원가입 화면 (신규)
└── main.dart                       ← 인증 상태 관리 추가
```

---

## 🎁 보안 개선

### Before (인증 없음):
```
❌ 누구나 모든 루틴 조회 가능
❌ 데이터 분리 없음
❌ 사용자 식별 불가
```

### After (인증 적용):
```
✅ 로그인한 사용자만 접근
✅ 사용자별 루틴 분리
✅ userId 기반 보안 규칙 적용 가능
✅ 프로필 정보 저장
```

---

## 🔮 향후 개선 사항

- [ ] 비밀번호 재설정 (이메일 전송)
- [ ] 이메일 인증
- [ ] 프로필 수정 기능
- [ ] 애플 로그인 (Apple Sign-In)
- [ ] 페이스북 로그인
- [ ] 다중 기기 로그인 관리
- [ ] 세션 만료 처리
- [ ] 계정 탈퇴 기능

---

## 💡 주의사항

### Firebase Console 설정 필수:
1. ✅ Authentication 활성화
2. ✅ 이메일/비밀번호 사용 설정
3. ✅ Google 사용 설정
4. ✅ SHA-1 지문 추가 (Android)
5. ✅ Firestore 보안 규칙 업데이트

### 테스트 계정:
개발 중에는 테스트 계정을 만들어 사용하세요.
```
이메일: test@routinemate.com
비밀번호: test123456
```

---

## 📱 플랫폼별 주의사항

### Android:
- SHA-1 인증서 필수
- `google-services.json` 최신 버전

### iOS:
- GoogleService-Info.plist 필요
- URL Schemes 설정

### Web:
- Firebase 프로젝트에서 웹 앱 등록
- API 키 설정

---

**업데이트 날짜**: 2025-10-20
**버전**: 2.0 (인증 시스템 추가)

---

<div align="center">
  <h2>🎉 인증 시스템 완성!</h2>
  <p>안전하고 개인화된 루틴 관리가 가능합니다!</p>
  <p>🔐 Firebase Authentication + 🔥 Firestore</p>
</div>
