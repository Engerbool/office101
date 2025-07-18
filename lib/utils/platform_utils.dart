import 'package:flutter/foundation.dart';

/// 웹 호환 플랫폼 감지 유틸리티
class PlatformUtils {
  /// iOS 플랫폼인지 확인 (웹에서는 false 반환)
  static bool get isIOS {
    if (kIsWeb) {
      return false;
    }
    try {
      // dart:io를 동적으로 import하여 웹에서의 오류 방지
      return defaultTargetPlatform == TargetPlatform.iOS;
    } catch (e) {
      return false;
    }
  }

  /// Android 플랫폼인지 확인 (웹에서는 false 반환)
  static bool get isAndroid {
    if (kIsWeb) {
      return false;
    }
    try {
      return defaultTargetPlatform == TargetPlatform.android;
    } catch (e) {
      return false;
    }
  }

  /// 웹 플랫폼인지 확인
  static bool get isWeb => kIsWeb;

  /// 모바일 플랫폼인지 확인 (iOS 또는 Android)
  static bool get isMobile => isIOS || isAndroid;

  /// 데스크톱 플랫폼인지 확인
  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    }
    try {
      return defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.macOS ||
             defaultTargetPlatform == TargetPlatform.linux;
    } catch (e) {
      return false;
    }
  }

  /// 현재 플랫폼 이름 반환
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isDesktop) return 'Desktop';
    return 'Unknown';
  }
}