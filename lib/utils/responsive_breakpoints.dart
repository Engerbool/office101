/// 반응형 디자인 Breakpoint 정의
///
/// 이 파일은 앱 전체에서 사용할 화면 크기 분류 기준과
/// 각 크기별 디자인 토큰을 정의합니다.

import 'package:flutter/material.dart';

/// 디바이스 타입 enum
enum DeviceType {
  mobile, // 스마트폰
  tablet, // 태블릿
  desktop, // 데스크톱/웹
}

/// 화면 방향 enum
enum ScreenOrientation {
  portrait, // 세로
  landscape, // 가로
}

/// 반응형 Breakpoint 상수
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  // Breakpoint 임계값 (논리적 픽셀 기준)
  static const double mobileMaxWidth = 600.0; // 모바일 최대 너비
  static const double tabletMaxWidth = 1200.0; // 태블릿 최대 너비
  static const double desktopMinWidth = 1200.0; // 데스크톱 최소 너비

  // 특별한 케이스들
  static const double smallMobileMaxWidth = 360.0; // 소형 모바일
  static const double largeMobileMaxWidth = 480.0; // 대형 모바일
  static const double smallTabletMaxWidth = 768.0; // 소형 태블릿

  // 폴더블 디바이스 지원
  static const double foldableUnfoldedMinWidth = 650.0; // 폴더블 펼친 상태

  /// 화면 너비로 디바이스 타입 판단
  static DeviceType getDeviceType(double width) {
    if (width < mobileMaxWidth) {
      return DeviceType.mobile;
    } else if (width < tabletMaxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// MediaQueryData로 디바이스 타입 판단
  static DeviceType getDeviceTypeFromContext(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceType(width);
  }

  /// 화면 방향 판단
  static ScreenOrientation getOrientation(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height
        ? ScreenOrientation.landscape
        : ScreenOrientation.portrait;
  }

  /// 폴더블 디바이스 여부 판단
  static bool isFoldableDevice(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= foldableUnfoldedMinWidth && width < tabletMaxWidth;
  }

  /// 작은 모바일 화면 여부
  static bool isSmallMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= smallMobileMaxWidth;
  }

  /// 큰 모바일 화면 여부
  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > largeMobileMaxWidth && width < mobileMaxWidth;
  }
}

/// 반응형 디자인 토큰
class ResponsiveTokens {
  ResponsiveTokens._();

  // 타이포그래피 스케일 팩터
  static const Map<DeviceType, double> fontScaleFactors = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.15,
    DeviceType.desktop: 1.3,
  };

  // 아이콘 크기 스케일 팩터
  static const Map<DeviceType, double> iconScaleFactors = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.2,
    DeviceType.desktop: 1.4,
  };

  // 패딩 및 마진 스케일 팩터
  static const Map<DeviceType, double> spacingScaleFactors = {
    DeviceType.mobile: 1.0,
    DeviceType.tablet: 1.25,
    DeviceType.desktop: 1.5,
  };

  // 카드 최대 너비 (콘텐츠 가독성을 위한 제한)
  static const Map<DeviceType, double> cardMaxWidths = {
    DeviceType.mobile: double.infinity, // 제한 없음
    DeviceType.tablet: 600.0, // 중간 제한
    DeviceType.desktop: 800.0, // 읽기 최적화
  };

  // 컬럼 수 (그리드 레이아웃용)
  static const Map<DeviceType, int> gridColumnCounts = {
    DeviceType.mobile: 1,
    DeviceType.tablet: 2,
    DeviceType.desktop: 3,
  };

  // 네비게이션 높이/너비
  static const Map<DeviceType, double> navigationSizes = {
    DeviceType.mobile: 80.0, // Bottom navigation 높이
    DeviceType.tablet: 120.0, // Navigation rail 너비
    DeviceType.desktop: 240.0, // Sidebar 너비
  };

  // 검색바 높이
  static const Map<DeviceType, double> searchBarHeights = {
    DeviceType.mobile: 48.0,
    DeviceType.tablet: 56.0,
    DeviceType.desktop: 64.0,
  };

  // FAB 크기
  static const Map<DeviceType, double> fabSizes = {
    DeviceType.mobile: 56.0,
    DeviceType.tablet: 64.0,
    DeviceType.desktop: 72.0,
  };
}

/// 반응형 값 관리 클래스
class ResponsiveValues<T> {
  final T mobile;
  final T tablet;
  final T desktop;

  const ResponsiveValues({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  /// 현재 화면 크기에 맞는 값 반환
  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Context로부터 적절한 값 반환
  T getValueFromContext(BuildContext context) {
    final deviceType = ResponsiveBreakpoints.getDeviceTypeFromContext(context);
    return getValue(deviceType);
  }
}

/// 자주 사용되는 반응형 값들 사전 정의
class CommonResponsiveValues {
  CommonResponsiveValues._();

  // 기본 패딩 값
  static const ResponsiveValues<double> defaultPadding = ResponsiveValues(
    mobile: 16.0,
    tablet: 20.0,
    desktop: 24.0,
  );

  // 카드 패딩
  static const ResponsiveValues<double> cardPadding = ResponsiveValues(
    mobile: 16.0,
    tablet: 20.0,
    desktop: 24.0,
  );

  // 섹션 간격
  static const ResponsiveValues<double> sectionSpacing = ResponsiveValues(
    mobile: 24.0,
    tablet: 32.0,
    desktop: 40.0,
  );

  // 버튼 높이
  static const ResponsiveValues<double> buttonHeight = ResponsiveValues(
    mobile: 48.0,
    tablet: 52.0,
    desktop: 56.0,
  );

  // 기본 아이콘 크기
  static const ResponsiveValues<double> iconSize = ResponsiveValues(
    mobile: 24.0,
    tablet: 28.0,
    desktop: 32.0,
  );

  // 제목 폰트 크기
  static const ResponsiveValues<double> titleFontSize = ResponsiveValues(
    mobile: 24.0,
    tablet: 28.0,
    desktop: 32.0,
  );

  // 부제목 폰트 크기
  static const ResponsiveValues<double> subtitleFontSize = ResponsiveValues(
    mobile: 18.0,
    tablet: 20.0,
    desktop: 22.0,
  );

  // 본문 폰트 크기
  static const ResponsiveValues<double> bodyFontSize = ResponsiveValues(
    mobile: 16.0,
    tablet: 17.0,
    desktop: 18.0,
  );

  // 캡션 폰트 크기
  static const ResponsiveValues<double> captionFontSize = ResponsiveValues(
    mobile: 12.0,
    tablet: 13.0,
    desktop: 14.0,
  );

  // 카드 최소 높이
  static const ResponsiveValues<double> cardMinHeight = ResponsiveValues(
    mobile: 120.0,
    tablet: 140.0,
    desktop: 160.0,
  );

  // 리스트 아이템 높이
  static const ResponsiveValues<double> listItemHeight = ResponsiveValues(
    mobile: 72.0,
    tablet: 80.0,
    desktop: 88.0,
  );
}

/// 디바이스별 레이아웃 설정
class ResponsiveLayoutConfig {
  final bool shouldUseBottomNavigation; // Bottom navigation 사용 여부
  final bool shouldUseNavigationRail; // Navigation rail 사용 여부
  final bool shouldUseSidebar; // Sidebar 사용 여부
  final bool shouldUseCompactMode; // 압축 모드 여부
  final bool shouldShowSecondaryInfo; // 부가 정보 표시 여부
  final int maxColumnsInGrid; // 그리드 최대 컬럼 수
  final double contentMaxWidth; // 콘텐츠 최대 너비

  const ResponsiveLayoutConfig({
    required this.shouldUseBottomNavigation,
    required this.shouldUseNavigationRail,
    required this.shouldUseSidebar,
    required this.shouldUseCompactMode,
    required this.shouldShowSecondaryInfo,
    required this.maxColumnsInGrid,
    required this.contentMaxWidth,
  });

  /// 디바이스 타입별 기본 설정
  static ResponsiveLayoutConfig getConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const ResponsiveLayoutConfig(
          shouldUseBottomNavigation: true,
          shouldUseNavigationRail: false,
          shouldUseSidebar: false,
          shouldUseCompactMode: true,
          shouldShowSecondaryInfo: false,
          maxColumnsInGrid: 1,
          contentMaxWidth: double.infinity,
        );

      case DeviceType.tablet:
        return const ResponsiveLayoutConfig(
          shouldUseBottomNavigation: false,
          shouldUseNavigationRail: true,
          shouldUseSidebar: false,
          shouldUseCompactMode: false,
          shouldShowSecondaryInfo: true,
          maxColumnsInGrid: 2,
          contentMaxWidth: 800.0,
        );

      case DeviceType.desktop:
        return const ResponsiveLayoutConfig(
          shouldUseBottomNavigation: false,
          shouldUseNavigationRail: false,
          shouldUseSidebar: true,
          shouldUseCompactMode: false,
          shouldShowSecondaryInfo: true,
          maxColumnsInGrid: 3,
          contentMaxWidth: 1000.0,
        );
    }
  }

  /// Context로부터 적절한 설정 반환
  static ResponsiveLayoutConfig getConfigFromContext(BuildContext context) {
    final deviceType = ResponsiveBreakpoints.getDeviceTypeFromContext(context);
    return getConfig(deviceType);
  }
}
