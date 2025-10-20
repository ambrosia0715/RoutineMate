# 🔥 Firebase Console 인증 설정 가이드

## 📋 설정 체크리스트

- [ ] Firestore 데이터베이스 생성
- [ ] Authentication 활성화
- [ ] 이메일/비밀번호 인증 사용 설정
- [ ] Google 로그인 사용 설정
- [ ] Firestore 보안 규칙 업데이트
- [ ] (Android) SHA-1 인증서 추가

---

## 1️⃣ Authentication 활성화

### 단계:

1. **Firebase Console 접속**
   ```
   https://console.firebase.google.com/project/routinemate-5ff74
   ```

2. **Authentication 메뉴 클릭**
   - 좌측 메뉴에서 "Authentication" 클릭

3. **"시작하기" 버튼 클릭**
   (처음 사용하는 경우)

---

## 2️⃣ 이메일/비밀번호 인증 설정

### 단계:

1. **Sign-in method 탭 클릭**

2. **"이메일/비밀번호" 행 클릭**

3. **"사용 설정" 토글 ON**
   ```
   ✅ 사용 설정됨
   ```

4. **"저장" 버튼 클릭**

### 완료!
이제 사용자가 이메일/비밀번호로 회원가입하고 로그인할 수 있습니다.

---

## 3️⃣ Google 로그인 설정

### 단계:

1. **Sign-in method 탭에서**

2. **"Google" 행 클릭**

3. **"사용 설정" 토글 ON**

4. **프로젝트 지원 이메일 선택**
   - 드롭다운에서 이메일 선택

5. **"저장" 버튼 클릭**

### Android 추가 설정 (필수!):

#### SHA-1 인증서 지문 추가:

**1. SHA-1 확인:**
```bash
cd c:\work\RoutineMate\routine_mate\android
./gradlew signingReport
```

출력 예시:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
MD5: AA:BB:CC:...
SHA1: 1A:2B:3C:4D:5E:6F:...  ← 이것을 복사!
SHA-256: ...
```

**2. Firebase Console에서:**
1. 프로젝트 설정 (⚙️ 아이콘)
2. "내 앱" 섹션
3. Android 앱 선택
4. "SHA 인증서 지문" 섹션
5. "지문 추가" 클릭
6. SHA-1 붙여넣기
7. "저장" 클릭

**3. google-services.json 재다운로드:**
1. 프로젝트 설정 > 앱
2. Android 앱 > "google-services.json 다운로드"
3. 파일을 다음 위치에 교체:
   ```
   routine_mate/android/app/google-services.json
   ```

---

## 4️⃣ Firestore 보안 규칙 업데이트

### 단계:

1. **Firestore Database 메뉴 클릭**

2. **"규칙" 탭 클릭**

3. **다음 규칙으로 교체:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 정보 컬렉션
    match /users/{userId} {
      // 로그인한 사용자는 모든 사용자 정보 읽기 가능
      allow read: if request.auth != null;
      // 자신의 정보만 쓰기 가능
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 루틴 컬렉션 (사용자별 분리)
    match /routines/{routineId} {
      // 자신의 루틴만 읽기 가능
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      
      // 자신의 userId로만 생성 가능
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // 자신의 루틴만 수정/삭제 가능
      allow update, delete: if request.auth != null && 
                              resource.data.userId == request.auth.uid;
    }
  }
}
```

4. **"게시" 버튼 클릭**

5. **확인 메시지에서 "게시" 클릭**

---

## 5️⃣ Firestore 인덱스 생성

### 필요한 인덱스:

#### 인덱스 1: userId + createdAt
```
컬렉션: routines
필드:
  - userId (오름차순)
  - createdAt (내림차순)
쿼리 범위: 컬렉션
```

### 자동 생성 방법:

1. **앱 실행 후 로그인**
2. **루틴 추가**
3. **콘솔에 인덱스 생성 링크 나타남**
4. **링크 클릭하여 자동 생성**

### 수동 생성 방법:

1. Firestore Database > "색인" 탭
2. "복합 색인 추가" 클릭
3. 위의 설정 입력
4. "만들기" 클릭
5. 생성 완료 대기 (1-2분)

---

## 6️⃣ 테스트

### Authentication 테스트:

1. **앱 실행**
2. **회원가입 화면에서:**
   ```
   이름: 테스트유저
   이메일: test@example.com
   비밀번호: test123456
   ```
3. **"회원가입" 버튼 클릭**
4. **Firebase Console > Authentication > Users 확인**
   - 새 사용자가 추가되었는지 확인

### Firestore 테스트:

1. **로그인 후 루틴 추가**
2. **Firebase Console > Firestore Database 확인**
3. **users 컬렉션 확인:**
   ```
   users/
     └── [userId]/
         ├── name: "테스트유저"
         ├── email: "test@example.com"
         └── ...
   ```
4. **routines 컬렉션 확인:**
   ```
   routines/
     └── [routineId]/
         ├── userId: [userId]  ← 중요!
         ├── title: "..."
         └── ...
   ```

### 보안 규칙 테스트:

1. **사용자 A로 로그인**
2. **루틴 추가**
3. **로그아웃**
4. **사용자 B로 로그인**
5. **사용자 A의 루틴이 보이지 않음 확인 ✅**

---

## 📱 플랫폼별 추가 설정

### Android:

#### 1. AndroidManifest.xml
이미 설정되어 있습니다:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

#### 2. build.gradle
자동으로 설정됩니다.

### iOS:

#### 1. GoogleService-Info.plist
```bash
# iOS 앱에 추가 (해당하는 경우)
routine_mate/ios/Runner/GoogleService-Info.plist
```

#### 2. Info.plist
URL Schemes 추가 필요 (Google 로그인용)

### Web:

#### 1. Firebase 프로젝트에 웹 앱 등록
```
프로젝트 설정 > 앱 > 웹 앱 추가
```

#### 2. firebase_options.dart
FlutterFire CLI로 자동 생성됩니다.

---

## 🎯 빠른 설정 체크리스트

### 필수 설정:

- [x] Firestore 데이터베이스 생성
- [ ] Authentication > 이메일/비밀번호 **사용**
- [ ] Authentication > Google **사용**
- [ ] Firestore 보안 규칙 **업데이트**
- [ ] (Android) SHA-1 지문 **추가**
- [ ] (Android) google-services.json **재다운로드**

### 선택 설정:

- [ ] Firestore 인덱스 생성
- [ ] 사용자 정보 수집 설정
- [ ] 이메일 인증 활성화

---

## 🐛 문제 해결

### 문제 1: Google 로그인 실패 (Android)
```
PlatformException(sign_in_failed, ...)
```

**해결:**
1. SHA-1 인증서 지문 확인
2. google-services.json 최신 버전 확인
3. 앱 재설치

### 문제 2: 보안 규칙 에러
```
[permission-denied] Missing or insufficient permissions
```

**해결:**
1. Firestore 보안 규칙 확인
2. userId 필드가 제대로 저장되는지 확인
3. 로그아웃 후 재로그인

### 문제 3: 인덱스 에러
```
The query requires an index
```

**해결:**
1. 콘솔의 에러 메시지 링크 클릭
2. 또는 수동으로 인덱스 생성
3. 생성 완료 후 앱 재시작

---

## 📊 설정 완료 확인

### Firebase Console에서:

#### Authentication > Users:
```
✅ 테스트 사용자 1개 이상
```

#### Firestore Database > 데이터:
```
users/
  └── [userId]/
      └── ... (사용자 정보)

routines/
  └── [routineId]/
      └── userId: [userId]  ← 확인!
```

#### Firestore Database > 규칙:
```javascript
✅ 사용자별 데이터 분리 규칙 적용
```

#### Firestore Database > 색인:
```
✅ routines (userId + createdAt) 인덱스
```

---

## 🎉 완료!

모든 설정이 완료되었습니다!

### 이제 가능한 것:
✅ 이메일/비밀번호 회원가입
✅ 이메일/비밀번호 로그인
✅ Google 소셜 로그인
✅ 사용자별 루틴 분리
✅ 안전한 데이터 보안

---

## 📚 참고 문서

- Firebase Authentication: https://firebase.google.com/docs/auth
- Firestore 보안 규칙: https://firebase.google.com/docs/firestore/security/get-started
- Google Sign-In: https://firebase.google.com/docs/auth/flutter/federated-auth

---

**작성일**: 2025-10-20
**버전**: 1.0
