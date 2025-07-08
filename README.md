# 직장생활은 처음이라 📱

신입사원을 위한 직장생활 가이드 모바일 앱

## 프로젝트 개요

사회초년생들이 회사에서 사용하는 전문 용어와 업무 예절을 쉽게 학습할 수 있도록 도와주는 모바일 앱입니다.

## 주요 기능

### 📚 용어 사전
- **6개 카테고리**: 결재/보고, 비즈니스/전략, 마케팅/세일즈, IT/개발, 인사(HR)/조직문화, 커뮤니케이션
- **검색 기능**: 용어명, 정의, 태그로 검색 가능
- **상세 정보**: 정의, 사용 예시, 관련 태그 제공

### ✉️ 이메일 & 업무 예절
- **상황별 템플릿**: 요청, 보고, 회의, 사과 등
- **작성 팁**: 각 템플릿별 주의사항과 가이드
- **복사 기능**: 템플릿을 클립보드로 복사

### 💡 직장생활 꿀팁
- **실무 노하우**: 일정관리, 보고스킬, 회의참석 등
- **핵심 포인트**: 각 팁별 중요 사항 정리
- **우선순위**: 중요도에 따른 팁 분류

## 기술 스택

- **프레임워크**: Flutter (Dart)
- **로컬 DB**: Hive (NoSQL)
- **상태관리**: Provider
- **폰트**: Google Fonts (Noto Sans KR)
- **디자인**: Neumorphism (Soft UI)

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── term.dart
│   ├── email_template.dart
│   └── workplace_tip.dart
├── services/                 # 서비스 레이어
│   └── database_service.dart
├── providers/                # 상태 관리
│   └── term_provider.dart
├── screens/                  # 화면 구성
│   ├── home_screen.dart
│   ├── term_search_screen.dart
│   ├── email_templates_screen.dart
│   └── workplace_tips_screen.dart
└── widgets/                  # 재사용 위젯
    ├── neumorphic_container.dart
    ├── search_bar_widget.dart
    └── category_grid.dart

assets/
└── data/                     # JSON 데이터
    ├── terms.json
    ├── email_templates.json
    └── workplace_tips.json
```

## 설치 및 실행

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. Hive 어댑터 생성
```bash
flutter packages pub run build_runner build
```

### 3. 앱 실행
```bash
flutter run
```

또는 제공된 스크립트 사용:
```bash
./run_app.sh
```

## 디자인 가이드

### 컬러 팔레트
- **Base**: `#EBF0F5`
- **Dark Shadow**: `#A6B4C4`
- **Light Highlight**: `#FFFFFF`
- **Text/Icon**: `#4F5A67`
- **Accent**: `#5A8DEE`

### UI 원칙
- **뉴모피즘 스타일**: 부드럽고 현대적인 디자인
- **접근성**: 대비비 4.5:1 이상 유지
- **일관성**: 전체 앱에서 통일된 디자인 언어

## 데이터 구조

### 용어 (Term)
```json
{
  "term_id": "string",
  "category": "enum",
  "term": "string",
  "definition": "string",
  "example": "string",
  "tags": ["string"],
  "user_added": false
}
```

### 이메일 템플릿 (EmailTemplate)
```json
{
  "template_id": "string",
  "title": "string",
  "situation": "string",
  "subject": "string",
  "body": "string",
  "tips": ["string"],
  "category": "enum"
}
```

### 직장생활 팁 (WorkplaceTip)
```json
{
  "tip_id": "string",
  "title": "string",
  "content": "string",
  "key_points": ["string"],
  "category": "enum",
  "priority": 0
}
```

## 버전 정보

- **현재 버전**: 1.0.0
- **대상 플랫폼**: Android, iOS
- **최소 요구사항**: 
  - Android: API 21 (Android 5.0)
  - iOS: iOS 11.0

## 로드맵

- ✅ **v1.0**: 기본 기능 구현
- 🔄 **v1.1**: 사용자 정의 용어 추가 기능
- 📋 **v1.2**: 즐겨찾기 및 최근 검색 기능
- 🎨 **v1.3**: 다크 모드 지원

## 기여하기

이 프로젝트는 오픈소스이며, 신입사원들에게 도움이 되는 콘텐츠 추가나 기능 개선에 대한 기여를 환영합니다.

## 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

---

**직장생활이 처음이신가요? 이 앱과 함께 성공적인 직장생활을 시작하세요! 🚀**