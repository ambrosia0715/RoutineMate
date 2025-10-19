# 🔥 Firebase 보안 규칙 설정

## 빠른 설정 가이드

---

## 📋 개발용 보안 규칙 (권장)

Firebase Console에 복사해서 붙여넣으세요:

### 1. Firebase Console 접속
```
https://console.firebase.google.com/
```

### 2. Firestore Database > 규칙 탭

### 3. 아래 규칙 복사 & 붙여넣기

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // RoutineMate 루틴 컬렉션
    match /routines/{routineId} {
      allow read: if true;   // 누구나 읽기 가능
      allow create: if true; // 누구나 생성 가능
      allow update: if true; // 누구나 수정 가능
      allow delete: if true; // 누구나 삭제 가능
    }
  }
}
```

### 4. "게시" 버튼 클릭

---

## 🔒 프로덕션용 보안 규칙 (배포 시)

나중에 앱을 배포할 때 사용하세요:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 인증된 사용자만 자신의 루틴 관리
    match /routines/{routineId} {
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
                       request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.data.userId;
    }
  }
}
```

**주의**: 프로덕션 규칙 사용 시 코드에 `userId` 필드 추가 필요!

---

## 🎯 현재 상태 확인

### Firebase Console에서:

1. **Firestore Database** 클릭
2. **데이터 탭**에서 `routines` 컬렉션 확인
3. 문서가 있는지 확인

### 앱 콘솔에서:

다음 로그를 찾으세요:
```
✅ 정상:
📥 Firestore 데이터 수신: X개
📋 루틴: [제목] (ID: xxx)

❌ 에러:
❌ Firestore 에러: [permission-denied]
```

---

## ⚡ 빠른 테스트

### 1단계: 보안 규칙 설정
위의 개발용 규칙 설정

### 2단계: 앱에서 루틴 추가
```
1. 제목: "테스트"
2. 시작: 10:00
3. 종료: 11:00
4. "루틴 추가" 클릭
```

### 3단계: 콘솔 확인
```
✅ 성공 시:
💾 루틴 저장 시도: 테스트
✅ 루틴 저장 성공! ID: abc123
📥 Firestore 데이터 수신: 1개
📋 루틴: 테스트 (ID: abc123)
```

### 4단계: Firebase Console 확인
```
routines/
  └── abc123/
      ├── title: "테스트"
      ├── start: "10:00"
      ├── end: "11:00"
      └── createdAt: [timestamp]
```

### 5단계: 앱 재시작
```
1. 앱 완전 종료
2. 다시 실행
3. "테스트" 루틴이 여전히 표시되면 ✅ 성공!
```

---

## 🚨 문제 발생 시

### 에러 1: Permission Denied
```
[cloud_firestore/permission-denied]
```
**해결**: 보안 규칙 재확인 및 재게시

### 에러 2: Index Required
```
The query requires an index
```
**해결**: 
1. 에러 메시지의 링크 클릭
2. 또는 수동으로 인덱스 생성:
   - 컬렉션: `routines`
   - 필드: `createdAt` (내림차순)

### 에러 3: Network Error
```
Failed host lookup
```
**해결**: 인터넷 연결 확인

---

## 📝 firestore.rules 파일 (로컬)

프로젝트 루트에 `firestore.rules` 파일 생성 (선택사항):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /routines/{routineId} {
      allow read, write: if true;
    }
  }
}
```

Firebase CLI로 배포:
```bash
firebase deploy --only firestore:rules
```

---

## 🎯 체크리스트

설정 완료 확인:

- [ ] Firebase Console 접속
- [ ] Firestore Database 메뉴 확인
- [ ] 규칙 탭에서 보안 규칙 설정
- [ ] 규칙 게시 완료
- [ ] 앱에서 루틴 추가 테스트
- [ ] 콘솔에서 성공 로그 확인
- [ ] Firebase Console에서 데이터 확인
- [ ] 앱 재시작 후 데이터 유지 확인

모두 완료하면 **데이터 영구 저장 완성!** 🎉

---

**중요**: 개발이 끝나고 앱을 배포할 때는 반드시 프로덕션 규칙으로 변경하세요!
