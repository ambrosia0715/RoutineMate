# 🎯 RoutineMate - Full Feature List

## ✨ 구현된 기능

### 1. **Firebase 연동** 🔥
- Firebase Firestore를 사용한 실시간 데이터베이스
- 루틴 데이터 실시간 동기화
- 서버 타임스탬프를 사용한 정확한 시간 기록

### 2. **루틴 관리** 📋
- ✅ 루틴 추가 (제목, 시작 시간, 종료 시간)
- ✅ 루틴 목록 실시간 조회
- ✅ 루틴 삭제
- ✅ 시간 순서대로 정렬된 루틴 표시

### 3. **알림 시스템** 🔔
- **시작 알림**: 루틴 시작 시간에 알림
- **중간 알림**: 루틴 진행 중간 시점에 알림
- **종료 알림**: 루틴 종료 시간에 알림
- Android 13+ 알림 권한 자동 처리

### 4. **음성 안내 (TTS)** 🔊
- 한국어 음성 지원
- 루틴 추가/삭제 시 음성 피드백
- 조절 가능한 음성 속도, 볼륨, 피치

### 5. **사용자 인터페이스** 🎨
- Material Design 3 적용
- 직관적인 시간 선택 다이얼로그
- 반응형 카드 레이아웃
- 실시간 데이터 업데이트
- 스낵바를 통한 사용자 피드백

---

## 🚀 사용 방법

### 루틴 추가하기
1. 상단 폼에 루틴 제목 입력
2. "시작 시간" 버튼을 눌러 시작 시간 선택
3. "종료 시간" 버튼을 눌러 종료 시간 선택
4. "루틴 추가" 버튼 클릭
5. 음성으로 확인 메시지 들음
6. 설정한 시간에 자동 알림 수신

### 루틴 삭제하기
- 루틴 카드 오른쪽의 🗑️ 아이콘 클릭

---

## 📦 필요한 패키지

```yaml
dependencies:
  firebase_core: ^4.2.0          # Firebase 초기화
  cloud_firestore: ^6.0.3        # 실시간 데이터베이스
  flutter_tts: ^4.2.3            # 음성 안내
  flutter_local_notifications: ^19.5.0  # 로컬 알림
  intl: ^0.20.2                  # 날짜/시간 포맷팅
```

---

## 🔧 설정 요구사항

### Android (AndroidManifest.xml)
```xml
<!-- 필요한 권한 -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Firebase 설정
- `google-services.json` (Android)
- `firebase_options.dart` (자동 생성)

---

## 🎯 알림 스케줄링 로직

```
루틴: "아침 운동"
시작: 07:00
종료: 08:00

→ 07:00 - 🎯 "아침 운동 시작 시간입니다!"
→ 07:30 - ⏰ "아침 운동 절반 진행되었습니다!"
→ 08:00 - ✅ "아침 운동 종료 시간입니다!"
```

---

## 💡 주요 기능 설명

### 실시간 데이터 동기화
```dart
FirebaseFirestore.instance
  .collection('routines')
  .orderBy('createdAt', descending: true)
  .snapshots()
  .listen((snapshot) {
    // 자동으로 UI 업데이트
  });
```

### TTS 음성 안내
```dart
await _tts.setLanguage('ko-KR');
await _tts.speak('루틴이 추가되었습니다.');
```

### 알림 표시
```dart
await _notifications.show(
  id, 
  '🎯 루틴 시작', 
  '운동 시작 시간입니다!', 
  notificationDetails
);
```

---

## 🐛 문제 해결

### 알림이 표시되지 않는 경우
1. Android 설정 > 앱 > RoutineMate > 알림 권한 확인
2. 배터리 최적화 제외 설정
3. 앱을 백그라운드에서 강제 종료하지 않기

### TTS가 작동하지 않는 경우
1. 기기에 한국어 TTS 엔진 설치 확인
2. 기기 설정 > 접근성 > TTS 확인

### Firebase 연결 오류
1. `google-services.json` 파일 위치 확인
2. Firebase 프로젝트 설정 확인
3. 인터넷 연결 확인

---

## 📱 테스트 방법

1. **루틴 추가 테스트**
   - 다양한 시간대로 루틴 추가
   - TTS 음성 피드백 확인

2. **알림 테스트**
   - 가까운 시간으로 루틴 설정
   - 알림 수신 확인

3. **실시간 동기화 테스트**
   - 여러 기기에서 동시 접속
   - 데이터 실시간 반영 확인

---

## 🔮 향후 개선 가능 사항

- [ ] 루틴 수정 기능
- [ ] 루틴 완료 체크 기능
- [ ] 주간/월간 통계
- [ ] 루틴 카테고리 분류
- [ ] 위젯 지원
- [ ] 다크 모드
- [ ] 반복 루틴 설정
- [ ] 푸시 알림 서버 연동

---

## 📄 라이선스
MIT License

---

**만든이**: RoutineMate Team 🚀
**버전**: 2.0.0
**최종 업데이트**: 2025-10-19
