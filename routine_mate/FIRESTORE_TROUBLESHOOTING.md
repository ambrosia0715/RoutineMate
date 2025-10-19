# 🔧 Firebase Firestore 문제 해결 가이드

## 문제: 앱을 재시작하면 데이터가 사라짐

### ✅ 해결 방법

---

## 1️⃣ Firebase 보안 규칙 설정

### 현재 문제
Firebase Firestore의 기본 보안 규칙이 너무 엄격하거나 만료되어 데이터를 읽을 수 없습니다.

### 해결 방법

#### Firebase Console에서 설정:

1. **Firebase Console 접속**
   ```
   https://console.firebase.google.com/
   ```

2. **프로젝트 선택**
   - RoutineMate 프로젝트 클릭

3. **Firestore Database 메뉴**
   - 좌측 메뉴 > Firestore Database 클릭

4. **규칙 탭 클릭**
   - 상단의 "규칙(Rules)" 탭 클릭

5. **규칙 수정**
   
   **개발용 (테스트):**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;  // ⚠️ 개발용만!
       }
     }
   }
   ```

   **프로덕션용 (권장):**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // routines 컬렉션
       match /routines/{routineId} {
         allow read: if true;
         allow write: if true;
         // 또는 인증 사용 시:
         // allow read, write: if request.auth != null;
       }
     }
   }
   ```

6. **게시 버튼 클릭**

---

## 2️⃣ Firestore 인덱스 생성

### 문제
`orderBy('createdAt')` 사용 시 인덱스가 필요할 수 있습니다.

### 해결 방법

#### 방법 A: 자동 생성 (권장)
1. 앱 실행
2. 루틴 추가 시도
3. 콘솔에 인덱스 생성 링크가 나타나면 클릭
4. Firebase Console에서 자동 생성

#### 방법 B: 수동 생성
1. Firebase Console > Firestore Database
2. "색인(Indexes)" 탭 클릭
3. "색인 추가" 클릭
4. 다음 설정:
   - **컬렉션 ID**: `routines`
   - **필드**: `createdAt` (내림차순)
   - **쿼리 범위**: 컬렉션
5. "만들기" 클릭

---

## 3️⃣ 디버깅 로그 확인

### 업데이트된 코드에 추가된 로그:

```dart
✅ 성공 로그:
📥 Firestore 데이터 수신: 3개
📋 루틴: 아침 운동 (ID: abc123)
💾 루틴 저장 시도: 아침 운동
✅ 루틴 저장 성공! ID: abc123

❌ 에러 로그:
❌ Firestore 에러: [에러 메시지]
❌ 루틴 추가 실패: [에러 메시지]
```

### 로그 확인 방법

#### Android Studio / VS Code:
1. 하단 "Debug Console" 또는 "터미널" 확인
2. `flutter run` 실행 중인 터미널 확인

#### Chrome DevTools:
1. 브라우저에서 F12 키
2. Console 탭에서 로그 확인

---

## 4️⃣ 테스트 단계별 체크리스트

### ✅ 단계 1: 데이터 추가
```
1. 앱 실행
2. 루틴 제목 입력: "테스트 루틴"
3. 시작/종료 시간 선택
4. "루틴 추가" 클릭
5. 콘솔 확인:
   ✓ 💾 루틴 저장 시도: 테스트 루틴
   ✓ ✅ 루틴 저장 성공! ID: xxx
```

### ✅ 단계 2: 데이터 확인
```
1. Firebase Console 접속
2. Firestore Database 클릭
3. routines 컬렉션 확인
4. 저장된 문서 확인:
   - title: "테스트 루틴"
   - start: "10:00"
   - end: "11:00"
   - createdAt: [타임스탬프]
```

### ✅ 단계 3: 앱 재시작
```
1. 앱 완전 종료 (백그라운드에서도 제거)
2. 앱 재실행
3. 콘솔 확인:
   ✓ 📥 Firestore 데이터 수신: 1개
   ✓ 📋 루틴: 테스트 루틴 (ID: xxx)
4. 화면에 루틴 표시 확인
```

---

## 5️⃣ 자주 발생하는 문제와 해결

### 문제 1: "Missing or insufficient permissions"
```
❌ 에러: [cloud_firestore/permission-denied]
```

**해결:**
- Firebase 보안 규칙을 위의 개발용 규칙으로 변경
- 규칙 게시 후 앱 재시작

---

### 문제 2: "Index not found"
```
❌ 에러: The query requires an index
```

**해결:**
- 콘솔의 에러 메시지에서 제공된 링크 클릭
- 또는 위의 "2️⃣ Firestore 인덱스 생성" 따라하기
- 인덱스 생성 완료까지 몇 분 대기

**임시 해결:**
- 앱이 자동으로 `_listenRoutinesWithoutOrder()` 호출
- 정렬 없이 데이터 로드 (클라이언트 측 정렬)

---

### 문제 3: "Network error"
```
❌ 에러: Failed host lookup
```

**해결:**
- 인터넷 연결 확인
- Wi-Fi 또는 모바일 데이터 확인
- Firebase 프로젝트 상태 확인

---

### 문제 4: 데이터는 저장되는데 화면에 안 보임
```
✅ 루틴 저장 성공! ID: abc123
하지만 화면에는 빈 상태...
```

**해결:**
1. 콘솔에서 `📥 Firestore 데이터 수신` 로그 확인
2. 없다면 리스너 에러 확인
3. 보안 규칙 재확인
4. 앱 완전 재시작 (핫 리로드 말고)

---

## 6️⃣ Firebase Console에서 직접 데이터 확인

### 단계:
1. https://console.firebase.google.com/ 접속
2. RoutineMate 프로젝트 선택
3. Firestore Database 클릭
4. `routines` 컬렉션 확인

### 확인 사항:
```
routines/
  └── [문서 ID]
      ├── title: "아침 운동"
      ├── start: "07:00"
      ├── end: "08:00"
      └── createdAt: Timestamp
```

### 수동 삭제:
- 문서 클릭 > 우측 상단 ... 메뉴 > "문서 삭제"

---

## 7️⃣ 코드 개선 사항 (이미 적용됨)

### ✅ 추가된 기능:

1. **상세 로깅**
   - 모든 Firestore 작업에 로그 추가
   - 성공/실패 명확히 표시

2. **에러 핸들링**
   - `onError` 콜백으로 Firestore 에러 캐치
   - 사용자에게 에러 메시지 표시

3. **자동 복구**
   - 인덱스 에러 시 자동으로 정렬 없이 재시도
   - 클라이언트 측에서 정렬 수행

4. **문서 ID 저장**
   - 각 루틴에 Firebase 문서 ID 저장
   - 삭제 시 정확한 문서 참조

---

## 8️⃣ 테스트 시나리오

### 완전 테스트:
```bash
1. 앱 실행
   → 콘솔: "📥 Firestore 데이터 수신"

2. 루틴 추가
   → 콘솔: "💾 루틴 저장 시도"
   → 콘솔: "✅ 루틴 저장 성공"
   → 화면: 루틴 카드 표시

3. 앱 종료 (완전 종료)

4. 앱 재실행
   → 콘솔: "📥 Firestore 데이터 수신: 1개"
   → 콘솔: "📋 루틴: [제목]"
   → 화면: 저장된 루틴 표시 ✅

5. 루틴 삭제
   → 콘솔: "🗑️ 루틴 삭제 시도"
   → 콘솔: "✅ 루틴 삭제 성공"
   → 화면: 루틴 사라짐

6. 앱 재실행
   → 화면: 빈 상태 (루틴 없음) ✅
```

---

## 9️⃣ 긴급 문제 해결

### 모든 것이 실패할 때:

1. **Firebase 프로젝트 재설정**
   ```bash
   flutter pub run flutterfire_cli:flutterfire configure
   ```

2. **캐시 클리어**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **앱 완전 재설치**
   ```bash
   flutter run --uninstall-first
   ```

4. **Firestore 데이터 직접 확인**
   - Firebase Console에서 수동으로 문서 생성
   - 앱에서 표시되는지 확인

---

## 🎯 최종 체크리스트

- [ ] Firebase 보안 규칙 설정 완료
- [ ] Firestore 인덱스 생성 (필요 시)
- [ ] 앱 실행 시 콘솔 로그 확인
- [ ] 루틴 추가 → 저장 성공 로그 확인
- [ ] Firebase Console에서 데이터 확인
- [ ] 앱 재시작 → 데이터 로드 로그 확인
- [ ] 화면에 루틴 표시 확인

---

## 💡 예방 팁

1. **개발 중**: 관대한 보안 규칙 사용
2. **프로덕션**: 인증 기반 규칙 사용
3. **정기 백업**: Firebase Console에서 데이터 내보내기
4. **로그 모니터링**: 에러 로그 주기적 확인

---

**문제가 계속되면:**
1. 콘솔 로그 전체 캡처
2. Firebase Console 스크린샷
3. 이슈 리포트 작성

---

**업데이트 날짜**: 2025-10-19
**버전**: 1.1 (디버깅 강화)
