# 직장생활은 처음이라 📱

신입사원을 위한 직장생활 가이드 모바일 앱

## 프로젝트 개요

사회초년생들이 회사에서 사용하는 전문 용어와 업무 예절을 쉽게 학습할 수 있도록 도와주는 모바일 앱입니다.

## 주요 기능

### 📚 용어 사전
- **6개 카테고리**: 결재/보고, 비즈니스/전략, 마케팅/세일즈, IT/개발, 인사(HR)/조직문화, 커뮤니케이션
- **고급 검색**: 용어명, 정의, 태그로 실시간 검색
- **한글 정렬**: 초성별 인덱스 스크롤 및 정렬
- **북마크 기능**: 자주 사용하는 용어 즐겨찾기
- **사용자 정의 용어**: 개인 맞춤 용어 추가 및 관리
- **카테고리 필터**: 카테고리별 용어 분류 및 필터링

### ✉️ 이메일 & 업무 예절
- **상황별 템플릿**: 요청, 보고, 회의, 사과 등 15개 이상의 템플릿
- **작성 팁**: 각 템플릿별 주의사항과 실무 가이드
- **복사 기능**: 템플릿을 클립보드로 원터치 복사
- **실무 중심**: 실제 업무 상황을 고려한 현실적인 템플릿

### 💡 직장생활 꿀팁
- **실무 노하우**: 일정관리, 보고스킬, 회의참석, 업무 커뮤니케이션
- **핵심 포인트**: 각 팁별 중요 사항 및 주의사항 정리
- **우선순위**: 중요도에 따른 팁 분류 및 추천

### 🎨 사용자 경험
- **다크 모드**: 라이트/다크 테마 지원
- **뉴모피즘 디자인**: 부드럽고 현대적인 UI/UX
- **접근성**: 한국어 최적화 및 직관적인 인터페이스
- **오프라인 지원**: 인터넷 연결 없이도 모든 기능 사용 가능

## 기술 스택

- **프레임워크**: Flutter (Dart)
- **로컬 DB**: Hive (NoSQL)
- **상태관리**: Provider
- **폰트**: Google Fonts (Noto Sans KR)
- **디자인**: Neumorphism (Soft UI)

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점 및 테마 설정
├── models/                   # 데이터 모델 (Hive 어댑터 포함)
│   ├── term.dart            # 용어 모델
│   ├── email_template.dart  # 이메일 템플릿 모델
│   └── workplace_tip.dart   # 직장생활 팁 모델
├── services/                 # 서비스 레이어
│   ├── database_service.dart # Hive 데이터베이스 관리
│   └── error_service.dart   # 에러 처리 및 로깅
├── providers/                # 상태 관리 (Provider 패턴)
│   ├── term_provider.dart   # 용어 관련 상태 관리
│   └── theme_provider.dart  # 다크모드 테마 관리
├── screens/                  # 화면 구성
│   ├── splash_screen.dart   # 스플래시 화면
│   ├── landing_screen.dart  # 랜딩 화면
│   ├── main_navigation_screen.dart # 메인 내비게이션
│   ├── home_screen.dart     # 홈 화면
│   ├── terms_tab_screen.dart # 용어 탭 (인덱스 스크롤 포함)
│   ├── add_term_screen.dart # 용어 추가 화면
│   ├── term_search_screen.dart # 용어 검색
│   ├── category_terms_screen.dart # 카테고리별 용어
│   ├── term_detail_screen.dart # 용어 상세 정보
│   ├── email_templates_screen.dart # 이메일 템플릿 목록
│   ├── email_template_detail_screen.dart # 템플릿 상세
│   ├── workplace_tips_screen.dart # 직장생활 팁 목록
│   ├── workplace_tip_detail_screen.dart # 팁 상세
│   └── settings_screen.dart # 설정 화면
├── widgets/                  # 재사용 위젯
│   ├── neumorphic_container.dart # 뉴모피즘 컨테이너
│   ├── search_bar_widget.dart # 검색바
│   ├── category_grid.dart   # 카테고리 그리드
│   ├── category_filter_chips.dart # 카테고리 필터 칩
│   ├── term_list_widget.dart # 용어 목록 위젯
│   ├── autocomplete_search_bar.dart # 자동완성 검색바
│   ├── index_scroll_bar.dart # 인덱스 스크롤바
│   └── error_display_widget.dart # 에러 표시 위젯
└── utils/                    # 유틸리티
    └── korean_sort_utils.dart # 한글 정렬 유틸리티

assets/
├── data/                     # JSON 데이터 (초기 데이터 로드용)
│   ├── terms/               # 카테고리별 용어 데이터
│   │   ├── approval.json
│   │   ├── business.json
│   │   └── ...
│   ├── email_templates.json # 이메일 템플릿 데이터
│   └── workplace_tips.json  # 직장생활 팁 데이터
└── images/                   # 앱 내 사용 이미지
    ├── landing.png
    └── ...
```

## 설치 및 실행

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. Hive 어댑터 생성
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
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
용어 데이터는 `assets/data/terms/` 폴더 내에 카테고리별 JSON 파일로 분리되었습니다. 각 파일은 Term 객체의 리스트를 포함합니다.
```json
// 예: assets/data/terms/business.json
[
  {
    "term_id": "string",
    "category": "business",
    "term": "string",
    "definition": "string",
    "example": "string",
    "tags": ["string"],
    "user_added": false,
    "is_bookmarked": false
  }
]
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

- **현재 버전**: 1.1.0
- **대상 플랫폼**: Android, iOS
- **최소 요구사항**: 
  - Android: API 21 (Android 5.0)
  - iOS: iOS 11.0

## 개발 현황 및 로드맵

### 🎉 완료된 기능 (v1.1)
- ✅ **데이터 구조 개편**: `terms.json`을 카테고리별 파일로 분리하여 관리 용이성 및 성능 향상
- ✅ **핵심 기능**: 용어 사전, 이메일 템플릿, 직장생활 팁
- ✅ **사용자 정의 용어**: 개인 맞춤 용어 추가 및 관리 기능
- ✅ **북마크 시스템**: 즐겨찾기 용어 저장 및 관리
- ✅ **다크 모드**: 완전한 라이트/다크 테마 지원
- ✅ **한글 정렬 및 인덱스**: 초성별 인덱스 스크롤 및 정렬 시스템
- ✅ **고급 검색**: 실시간 검색, 자동완성, 카테고리 필터
- ✅ **뉴모피즘 UI**: 일관된 현대적 디자인 시스템
- ✅ **설정 화면**: 테마 변경 및 앱 설정 관리
- ✅ **시작 화면**: 스플래시 및 랜딩 화면 추가

### 📋 예정 기능 (v1.2+)
- 📋 **검색 기록**: 최근 검색어 저장 및 추천
- 📋 **사용 통계**: 자주 사용하는 용어 분석 및 개인화
- 📋 **데이터 백업**: 사용자 데이터 내보내기/가져오기
- 📋 **알림 시스템**: 일일 용어 학습 알림
- 📋 **퀴즈 기능**: 용어 학습 게임화
- 📋 **공유 기능**: 용어 및 템플릿 공유
- 📋 **오디오 지원**: 용어 발음 가이드

## 주요 기술적 특징

### 📱 Flutter 네이티브 앱
- **크로스 플랫폼**: Android, iOS 동시 지원
- **고성능**: 네이티브 수준의 성능 및 부드러운 애니메이션
- **Material Design**: 구글 디자인 가이드라인 준수

### 🗄️ Hive 로컬 데이터베이스
- **빠른 성능**: NoSQL 키-값 저장소로 빠른 읽기/쓰기
- **오프라인 지원**: 인터넷 연결 없이 모든 기능 사용
- **타입 안전성**: 코드 생성을 통한 타입 안전한 데이터 저장

### 🎨 뉴모피즘 디자인
- **현대적 UI**: 부드러운 그림자와 하이라이트 효과
- **일관된 디자인**: 전체 앱에서 통일된 디자인 언어
- **접근성**: 색상 대비 및 터치 영역 최적화

### 🔤 한국어 최적화
- **초성 검색**: 한글 초성으로 빠른 검색
- **한글 정렬**: 한글 문자 순서에 따른 정렬
- **인덱스 스크롤**: 한글 자모 인덱스 네비게이션

## 기여하기

이 프로젝트는 오픈소스이며, 신입사원들에게 도움이 되는 콘텐츠 추가나 기능 개선에 대한 기여를 환영합니다.

### 기여 방법
1. 이슈 등록 또는 기존 이슈 확인
2. 포크(Fork) 후 기능 브랜치 생성
3. 코드 작성 및 테스트
4. 풀 리퀘스트(PR) 제출

### 기여 가능한 영역
- 📝 **콘텐츠 추가**: 새로운 용어, 이메일 템플릿, 직장생활 팁
- 🐛 **버그 수정**: 발견된 버그 리포트 및 수정
- ✨ **기능 개선**: 사용자 경험 개선 및 새로운 기능 제안
- 📚 **문서화**: 코드 문서화 및 가이드 작성

## 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

---

**직장생활이 처음이신가요? 이 앱과 함께 성공적인 직장생활을 시작하세요! 🚀**