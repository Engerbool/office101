import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// iOS Dynamic Type 지원 유틸리티
class IOSDynamicType {
  /// iOS 텍스트 스타일 매핑
  static TextStyle getTextStyle(
    BuildContext context, {
    required IOSTextStyle style,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    if (PlatformUtils.isIOS) {
      return _getIOSTextStyle(context, style, color, fontWeight, decoration);
    } else {
      return _getAndroidTextStyle(context, style, color, fontWeight, decoration);
    }
  }
  
  /// iOS 전용 텍스트 스타일
  static TextStyle _getIOSTextStyle(
    BuildContext context,
    IOSTextStyle style,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  ) {
    // iOS에서는 시스템 폰트 크기 설정을 자동으로 반영
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    
    switch (style) {
      case IOSTextStyle.largeTitle:
        return TextStyle(
          fontSize: 34 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.2,
        );
      case IOSTextStyle.title1:
        return TextStyle(
          fontSize: 28 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.2,
        );
      case IOSTextStyle.title2:
        return TextStyle(
          fontSize: 22 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.2,
        );
      case IOSTextStyle.title3:
        return TextStyle(
          fontSize: 20 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.2,
        );
      case IOSTextStyle.headline:
        return TextStyle(
          fontSize: 17 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color,
          decoration: decoration,
          height: 1.3,
        );
      case IOSTextStyle.body:
        return TextStyle(
          fontSize: 17 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.4,
        );
      case IOSTextStyle.callout:
        return TextStyle(
          fontSize: 16 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.4,
        );
      case IOSTextStyle.subheadline:
        return TextStyle(
          fontSize: 15 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.4,
        );
      case IOSTextStyle.footnote:
        return TextStyle(
          fontSize: 13 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.4,
        );
      case IOSTextStyle.caption1:
        return TextStyle(
          fontSize: 12 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.3,
        );
      case IOSTextStyle.caption2:
        return TextStyle(
          fontSize: 11 * textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color,
          decoration: decoration,
          height: 1.3,
        );
    }
  }
  
  /// Android 전용 텍스트 스타일
  static TextStyle _getAndroidTextStyle(
    BuildContext context,
    IOSTextStyle style,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  ) {
    final theme = Theme.of(context);
    
    switch (style) {
      case IOSTextStyle.largeTitle:
        return theme.textTheme.displayLarge?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 32);
      case IOSTextStyle.title1:
        return theme.textTheme.displayMedium?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 28);
      case IOSTextStyle.title2:
        return theme.textTheme.displaySmall?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 24);
      case IOSTextStyle.title3:
        return theme.textTheme.headlineMedium?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 20);
      case IOSTextStyle.headline:
        return theme.textTheme.headlineSmall?.copyWith(
          color: color,
          fontWeight: fontWeight ?? FontWeight.w600,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 18);
      case IOSTextStyle.body:
        return theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 16);
      case IOSTextStyle.callout:
        return theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 15);
      case IOSTextStyle.subheadline:
        return theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 14);
      case IOSTextStyle.footnote:
        return theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 13);
      case IOSTextStyle.caption1:
        return theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 12);
      case IOSTextStyle.caption2:
        return theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: decoration,
        ) ?? TextStyle(fontSize: 11);
    }
  }
}

/// iOS 텍스트 스타일 열거형
enum IOSTextStyle {
  largeTitle,  // 34pt
  title1,      // 28pt
  title2,      // 22pt
  title3,      // 20pt
  headline,    // 17pt semibold
  body,        // 17pt
  callout,     // 16pt
  subheadline, // 15pt
  footnote,    // 13pt
  caption1,    // 12pt
  caption2,    // 11pt
}

/// iOS 다이나믹 타입 텍스트 위젯
class IOSText extends StatelessWidget {
  final String text;
  final IOSTextStyle style;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  
  const IOSText(
    this.text, {
    Key? key,
    required this.style,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: IOSDynamicType.getTextStyle(
        context,
        style: style,
        color: color,
        fontWeight: fontWeight,
        decoration: decoration,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// iOS 다이나믹 타입 최적화 위젯
class IOSTextScaleWrapper extends StatelessWidget {
  final Widget child;
  final double? maxScaleFactor;
  final double? minScaleFactor;
  
  const IOSTextScaleWrapper({
    Key? key,
    required this.child,
    this.maxScaleFactor = 1.3,
    this.minScaleFactor = 0.8,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      final currentScale = MediaQuery.textScaleFactorOf(context);
      final clampedScale = currentScale.clamp(
        minScaleFactor ?? 0.8,
        maxScaleFactor ?? 1.3,
      );
      
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: clampedScale,
        ),
        child: child,
      );
    } else {
      return child;
    }
  }
}

/// iOS 접근성 폰트 크기 감지 위젯
class IOSAccessibilityFontSizeDetector extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext, bool)? builder;
  
  const IOSAccessibilityFontSizeDetector({
    Key? key,
    required this.child,
    this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final isLargeFont = textScaleFactor > 1.2;
      
      if (builder != null) {
        return builder!(context, isLargeFont);
      }
      
      return child;
    } else {
      return child;
    }
  }
}

/// iOS 다이나믹 타입 헬퍼 클래스
class IOSDynamicTypeHelper {
  /// 현재 텍스트 스케일 팩터 반환
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.textScaleFactorOf(context);
  }
  
  /// 접근성 폰트 크기 사용 여부 확인
  static bool isAccessibilityFontSize(BuildContext context) {
    return getTextScaleFactor(context) > 1.2;
  }
  
  /// 폰트 크기 카테고리 반환
  static IOSFontSizeCategory getFontSizeCategory(BuildContext context) {
    final scale = getTextScaleFactor(context);
    
    if (scale <= 0.8) return IOSFontSizeCategory.extraSmall;
    if (scale <= 0.9) return IOSFontSizeCategory.small;
    if (scale <= 1.0) return IOSFontSizeCategory.medium;
    if (scale <= 1.1) return IOSFontSizeCategory.large;
    if (scale <= 1.2) return IOSFontSizeCategory.extraLarge;
    return IOSFontSizeCategory.accessibility;
  }
}

/// iOS 폰트 크기 카테고리
enum IOSFontSizeCategory {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
  accessibility,
}