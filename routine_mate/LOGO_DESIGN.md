# 🎨 RoutineMate 로고 디자인 가이드

## 📱 로고 개요

RoutineMate의 로고는 **목표 달성**과 **루틴 관리**를 시각적으로 표현합니다.

---

## 🎯 디자인 컨셉

### 핵심 요소
1. **🎯 타겟(Target)** - `Icons.track_changes`
   - 루틴의 목표와 초점을 상징
   - 정확한 일정 관리를 의미

2. **✅ 체크마크** - `Icons.check`
   - 완료된 루틴을 나타냄
   - 성취감과 달성을 상징

3. **🌈 그라디언트**
   - 인디고에서 퍼플로 이어지는 그라디언트
   - 현대적이고 역동적인 느낌

---

## 🎨 컬러 팔레트

### 주요 색상
```dart
Primary Gradient:
- Colors.indigo.shade600  (#3F51B5)
- Colors.indigo.shade400  (#5C6BC0)
- Colors.purple.shade400  (#AB47BC)

Accent:
- Colors.greenAccent.shade400  (#66BB6A)
- Colors.white  (#FFFFFF)
```

### 색상 의미
- **인디고**: 신뢰성, 전문성, 안정성
- **퍼플**: 창의성, 지혜, 영감
- **그린 액센트**: 성공, 성장, 완료

---

## 📐 로고 구조

```
┌─────────────────────────┐
│  ╔═══════════════════╗  │
│  ║   [그라디언트]     ║  │
│  ║                   ║  │
│  ║    ◎ 타겟 아이콘   ║  │
│  ║                   ║  │
│  ║        ✓ 체크     ║  │
│  ╚═══════════════════╝  │
└─────────────────────────┘
```

### 레이어 구성
1. **배경 컨테이너**
   - 그라디언트 배경
   - 둥근 모서리 (25% radius)
   - 그림자 효과

2. **장식 원형**
   - 반투명 흰색 원
   - 우측 상단 배치
   - 깊이감 연출

3. **메인 아이콘**
   - 타겟/다트보드 아이콘
   - 60% 크기
   - 흰색

4. **체크마크 뱃지**
   - 녹색 원형 배경
   - 흰색 테두리
   - 우측 하단 배치

---

## 📏 사이즈 가이드

### 기본 사이즈
```dart
const RoutineMateLogo(size: 48)  // 기본
const RoutineMateLogo(size: 32)  // AppBar용
const RoutineMateLogo(size: 80)  // 빈 상태 표시
const RoutineMateLogo(size: 120) // 스플래시/온보딩
```

### 사이즈별 용도
| 크기 | 용도 | 위치 |
|------|------|------|
| 24px | 리스트 아이템 | 작은 아이콘 |
| 32px | AppBar | 상단 바 |
| 48px | 카드/버튼 | 일반 UI |
| 80px | Empty State | 빈 화면 |
| 120px | 스플래시 | 앱 시작 화면 |

---

## 🎨 사용 예시

### 1. AppBar에 로고 표시
```dart
AppBar(
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const RoutineMateLogo(size: 32),
      const SizedBox(width: 12),
      const Text('RoutineMate'),
    ],
  ),
)
```

### 2. 빈 상태 화면
```dart
Center(
  child: Column(
    children: [
      const RoutineMateLogo(size: 80),
      const SizedBox(height: 24),
      const Text('등록된 루틴이 없습니다.'),
    ],
  ),
)
```

### 3. 스플래시 화면
```dart
Scaffold(
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RoutineMateLogo(size: 120),
        const SizedBox(height: 32),
        const Text(
          'RoutineMate',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
)
```

---

## 💡 디자인 특징

### 1. 그라디언트 효과
- **방향**: 좌상단 → 우하단
- **부드러운 전환**: 3색 그라디언트
- **시각적 깊이**: 입체감 연출

### 2. 그림자 효과
```dart
BoxShadow(
  color: Colors.indigo.withOpacity(0.3),
  blurRadius: 8,
  offset: const Offset(0, 4),
)
```

### 3. 둥근 모서리
- **BorderRadius**: `size * 0.25`
- **부드러운 느낌**: 친근하고 현대적

### 4. 레이어링
- **3D 효과**: 여러 레이어 중첩
- **깊이감**: 체크마크 뱃지 돌출

---

## 🎯 로고 변형

### 심플 버전 (텍스트 없음)
```dart
const RoutineMateLogo(size: 48)
```

### 텍스트 포함 버전
```dart
Row(
  children: [
    const RoutineMateLogo(size: 32),
    const SizedBox(width: 12),
    Text('RoutineMate'),
  ],
)
```

### 컴팩트 버전 (작은 크기)
```dart
const RoutineMateLogo(size: 24)
```

---

## 🖼️ 애니메이션 아이디어

### 1. 회전 애니메이션
```dart
AnimatedRotation(
  turns: _animation.value,
  child: const RoutineMateLogo(size: 80),
)
```

### 2. 펄스 효과
```dart
ScaleTransition(
  scale: _scaleAnimation,
  child: const RoutineMateLogo(size: 80),
)
```

### 3. 페이드 인
```dart
FadeTransition(
  opacity: _fadeAnimation,
  child: const RoutineMateLogo(size: 120),
)
```

---

## 📱 반응형 디자인

### 화면 크기별 로고 사이즈
```dart
Widget responsiveLogo(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  
  return RoutineMateLogo(
    size: screenWidth < 600 ? 32 : 48,
  );
}
```

---

## 🎨 브랜드 일관성

### DO ✅
- 로고 비율 유지
- 지정된 색상 팔레트 사용
- 충분한 여백 확보
- 명확한 배경 사용

### DON'T ❌
- 로고 왜곡 금지
- 색상 임의 변경 금지
- 과도한 압축 금지
- 복잡한 배경 위 사용 자제

---

## 🔮 향후 개선 아이디어

1. **다크 모드 버전**
   - 어두운 배경용 로고 변형
   
2. **애니메이션 로고**
   - 로딩 시 회전/펄스 효과

3. **계절별 테마**
   - 봄/여름/가을/겨울 색상 변형

4. **성취 뱃지**
   - 루틴 달성 단계별 로고 변형

---

## 📄 로고 코드

전체 로고 위젯 코드는 `lib/main.dart`의 `RoutineMateLogo` 클래스에서 확인할 수 있습니다.

```dart
class RoutineMateLogo extends StatelessWidget {
  final double size;
  
  const RoutineMateLogo({super.key, this.size = 48});
  
  @override
  Widget build(BuildContext context) {
    // 로고 구현...
  }
}
```

---

**디자인 철학**: 
> "명확하고 친근하며, 성취감을 주는 디자인"

**제작일**: 2025-10-19
**버전**: 1.0
