/// 반응형 디자인 헬퍼 클래스와 위젯들
///
/// 이 파일은 반응형 디자인을 쉽게 구현할 수 있는
/// 헬퍼 클래스와 유틸리티 위젯들을 제공합니다.

import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// 반응형 디자인 헬퍼 클래스
class ResponsiveHelper {
  ResponsiveHelper._();

  /// 현재 화면의 디바이스 타입 반환
  static DeviceType getDeviceType(BuildContext context) {
    return ResponsiveBreakpoints.getDeviceTypeFromContext(context);
  }

  /// 화면 방향 반환
  static ScreenOrientation getOrientation(BuildContext context) {
    return ResponsiveBreakpoints.getOrientation(context);
  }

  /// 현재 화면이 모바일인지 확인
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 현재 화면이 태블릿인지 확인
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 현재 화면이 데스크톱인지 확인
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 현재 화면이 세로 모드인지 확인
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == ScreenOrientation.portrait;
  }

  /// 현재 화면이 가로 모드인지 확인
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == ScreenOrientation.landscape;
  }

  /// 작은 모바일 화면인지 확인
  static bool isSmallMobile(BuildContext context) {
    return ResponsiveBreakpoints.isSmallMobile(context);
  }

  /// 폴더블 디바이스인지 확인
  static bool isFoldable(BuildContext context) {
    return ResponsiveBreakpoints.isFoldableDevice(context);
  }

  /// 현재 화면 너비 반환
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 현재 화면 높이 반환
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 안전 영역을 고려한 화면 크기 반환
  static Size getSafeAreaSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Size(
      size.width,
      size.height - padding.top - padding.bottom,
    );
  }

  /// 반응형 값 반환 (디바이스 타입별)
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// 조건부 값 반환 (모바일/태블릿 이상)
  static T getValueBySize<T>(
    BuildContext context, {
    required T mobile,
    required T other,
  }) {
    return isMobile(context) ? mobile : other;
  }

  /// 폰트 크기 스케일링
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);
    final scaleFactor = ResponsiveTokens.fontScaleFactors[deviceType] ?? 1.0;
    return baseFontSize * scaleFactor;
  }

  /// 아이콘 크기 스케일링
  static double getScaledIconSize(BuildContext context, double baseIconSize) {
    final deviceType = getDeviceType(context);
    final scaleFactor = ResponsiveTokens.iconScaleFactors[deviceType] ?? 1.0;
    return baseIconSize * scaleFactor;
  }

  /// 간격 스케일링
  static double getScaledSpacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);
    final scaleFactor = ResponsiveTokens.spacingScaleFactors[deviceType] ?? 1.0;
    return baseSpacing * scaleFactor;
  }

  /// 콘텐츠 최대 너비 반환
  static double getContentMaxWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    return ResponsiveTokens.cardMaxWidths[deviceType] ?? double.infinity;
  }

  /// 그리드 컬럼 수 반환
  static int getGridColumnCount(BuildContext context, {int? maxColumns}) {
    final deviceType = getDeviceType(context);
    final defaultColumns = ResponsiveTokens.gridColumnCounts[deviceType] ?? 1;

    if (maxColumns != null) {
      return defaultColumns > maxColumns ? maxColumns : defaultColumns;
    }

    return defaultColumns;
  }

  /// 레이아웃 설정 반환
  static ResponsiveLayoutConfig getLayoutConfig(BuildContext context) {
    return ResponsiveLayoutConfig.getConfigFromContext(context);
  }
}

/// 조건부 위젯 렌더링
class ResponsiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? fallback;

  const ResponsiveWidget({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceType.tablet:
        return tablet ?? mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceType.desktop:
        return desktop ??
            tablet ??
            mobile ??
            fallback ??
            const SizedBox.shrink();
    }
  }
}

/// 조건부 위젯 빌더
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// 반응형 값을 제공하는 위젯
class ResponsiveValueWidget<T> extends StatelessWidget {
  final ResponsiveValues<T> values;
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValueWidget({
    Key? key,
    required this.values,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final value = values.getValueFromContext(context);
    return builder(context, value);
  }
}

/// 반응형 컨테이너
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final ResponsiveValues<EdgeInsetsGeometry>? padding;
  final ResponsiveValues<EdgeInsetsGeometry>? margin;
  final ResponsiveValues<double>? width;
  final ResponsiveValues<double>? height;
  final Color? color;
  final Decoration? decoration;
  final bool centerContent;
  final double? maxWidth;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.centerContent = false,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    Widget content = Container(
      padding: padding?.getValue(deviceType),
      margin: margin?.getValue(deviceType),
      width: width?.getValue(deviceType),
      height: height?.getValue(deviceType),
      color: color,
      decoration: decoration,
      child: child,
    );

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

/// 반응형 패딩
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final ResponsiveValues<EdgeInsetsGeometry>? padding;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  /// 기본 패딩 사용
  const ResponsivePadding.defaultPadding({
    Key? key,
    required this.child,
  })  : padding = const ResponsiveValues<EdgeInsetsGeometry>(
          mobile: EdgeInsets.all(16.0),
          tablet: EdgeInsets.all(20.0),
          desktop: EdgeInsets.all(24.0),
        ),
        super(key: key);

  /// 카드 패딩 사용
  const ResponsivePadding.cardPadding({
    Key? key,
    required this.child,
  })  : padding = const ResponsiveValues<EdgeInsetsGeometry>(
          mobile: EdgeInsets.all(16.0),
          tablet: EdgeInsets.all(20.0),
          desktop: EdgeInsets.all(24.0),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final paddingValue = padding ??
        const ResponsiveValues<EdgeInsetsGeometry>(
          mobile: EdgeInsets.all(16.0),
          tablet: EdgeInsets.all(20.0),
          desktop: EdgeInsets.all(24.0),
        );

    return ResponsiveValueWidget<EdgeInsetsGeometry>(
      values: paddingValue,
      builder: (context, value) {
        return Padding(
          padding: value,
          child: child,
        );
      },
    );
  }
}

/// 반응형 SizedBox
class ResponsiveSizedBox extends StatelessWidget {
  final ResponsiveValues<double>? width;
  final ResponsiveValues<double>? height;
  final Widget? child;

  const ResponsiveSizedBox({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  /// 높이만 지정하는 생성자
  const ResponsiveSizedBox.height(
    ResponsiveValues<double> height, {
    Key? key,
  })  : width = null,
        height = height,
        child = null,
        super(key: key);

  /// 너비만 지정하는 생성자
  const ResponsiveSizedBox.width(
    ResponsiveValues<double> width, {
    Key? key,
  })  : width = width,
        height = null,
        child = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    return SizedBox(
      width: width?.getValue(deviceType),
      height: height?.getValue(deviceType),
      child: child,
    );
  }
}

/// 반응형 그리드 뷰
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValues<int>? crossAxisCount;
  final ResponsiveValues<double>? crossAxisSpacing;
  final ResponsiveValues<double>? mainAxisSpacing;
  final ResponsiveValues<double>? childAspectRatio;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    final defaultCrossAxisCount = ResponsiveValues<int>(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    final defaultSpacing = ResponsiveValues<double>(
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    return GridView.count(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      crossAxisCount:
          (crossAxisCount ?? defaultCrossAxisCount).getValue(deviceType),
      crossAxisSpacing:
          (crossAxisSpacing ?? defaultSpacing).getValue(deviceType),
      mainAxisSpacing: (mainAxisSpacing ?? defaultSpacing).getValue(deviceType),
      childAspectRatio: childAspectRatio?.getValue(deviceType) ?? 1.0,
      children: children,
    );
  }
}

/// 반응형 텍스트
class ResponsiveText extends StatelessWidget {
  final String text;
  final ResponsiveValues<double>? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  }) : super(key: key);

  /// 제목용 텍스트
  const ResponsiveText.title(
    this.text, {
    Key? key,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  })  : fontSize = CommonResponsiveValues.titleFontSize,
        super(key: key);

  /// 부제목용 텍스트
  const ResponsiveText.subtitle(
    this.text, {
    Key? key,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  })  : fontSize = CommonResponsiveValues.subtitleFontSize,
        super(key: key);

  /// 본문용 텍스트
  const ResponsiveText.body(
    this.text, {
    Key? key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  })  : fontSize = CommonResponsiveValues.bodyFontSize,
        super(key: key);

  /// 캡션용 텍스트
  const ResponsiveText.caption(
    this.text, {
    Key? key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  })  : fontSize = CommonResponsiveValues.captionFontSize,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final defaultFontSize = CommonResponsiveValues.bodyFontSize;

    return Text(
      text,
      style: TextStyle(
        fontSize: (fontSize ?? defaultFontSize).getValue(deviceType),
        fontWeight: fontWeight,
        color: color,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 반응형 아이콘
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final ResponsiveValues<double>? size;
  final Color? color;

  const ResponsiveIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  /// 기본 크기 아이콘
  const ResponsiveIcon.defaultSize(
    this.icon, {
    Key? key,
    this.color,
  })  : size = CommonResponsiveValues.iconSize,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final defaultSize = CommonResponsiveValues.iconSize;

    return Icon(
      icon,
      size: (size ?? defaultSize).getValue(deviceType),
      color: color,
    );
  }
}

/// 디바이스별 조건부 렌더링 믹스인
mixin ResponsiveMixin {
  /// 모바일에서만 실행
  void onMobile(BuildContext context, VoidCallback callback) {
    if (ResponsiveHelper.isMobile(context)) {
      callback();
    }
  }

  /// 태블릿에서만 실행
  void onTablet(BuildContext context, VoidCallback callback) {
    if (ResponsiveHelper.isTablet(context)) {
      callback();
    }
  }

  /// 데스크톱에서만 실행
  void onDesktop(BuildContext context, VoidCallback callback) {
    if (ResponsiveHelper.isDesktop(context)) {
      callback();
    }
  }

  /// 세로 모드에서만 실행
  void onPortrait(BuildContext context, VoidCallback callback) {
    if (ResponsiveHelper.isPortrait(context)) {
      callback();
    }
  }

  /// 가로 모드에서만 실행
  void onLandscape(BuildContext context, VoidCallback callback) {
    if (ResponsiveHelper.isLandscape(context)) {
      callback();
    }
  }
}
