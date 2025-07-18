import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'platform_utils.dart';

class HapticUtils {
  /// 가벼운 햅틱 피드백 (일반적인 탭, 선택)
  static Future<void> lightTap() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
  }

  /// 중간 햅틱 피드백 (버튼 누름, 스위치 토글)
  static Future<void> mediumTap() async {
    if (!kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// 강한 햅틱 피드백 (중요한 액션, 오류)
  static Future<void> heavyTap() async {
    if (!kIsWeb) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// 선택 햅틱 피드백 (리스트 아이템 선택)
  static Future<void> selection() async {
    if (!kIsWeb) {
      await HapticFeedback.selectionClick();
    }
  }

  /// 진동 햅틱 피드백 (알림, 성공)
  static Future<void> vibrate() async {
    if (!kIsWeb) {
      await HapticFeedback.vibrate();
    }
  }

  /// 북마크 토글용 햅틱 피드백
  static Future<void> bookmarkToggle() async {
    await mediumTap();
  }

  /// 검색 시작 햅틱 피드백
  static Future<void> searchStart() async {
    await lightTap();
  }

  /// 카테고리 선택 햅틱 피드백
  static Future<void> categorySelect() async {
    await lightTap();
  }

  /// 스와이프 액션 햅틱 피드백
  static Future<void> swipeAction() async {
    await mediumTap();
  }

  /// 오류 발생 햅틱 피드백
  static Future<void> error() async {
    await heavyTap();
  }

  /// 성공 액션 햅틱 피드백
  static Future<void> success() async {
    await mediumTap();
  }

  /// 페이지 네비게이션 햅틱 피드백
  static Future<void> navigation() async {
    await lightTap();
  }

  /// 설정 변경 햅틱 피드백
  static Future<void> settingsChange() async {
    await lightTap();
  }
  
  /// iOS 전용 Taptic Engine 최적화 햅틱 피드백
  
  /// iOS 스타일 버튼 탭 피드백
  static Future<void> buttonTap() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
  }
  
  /// iOS 스타일 토글 스위치 피드백
  static Future<void> toggleSwitch() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
  }
  
  /// iOS 스타일 성공 피드백
  static Future<void> successTaptic() async {
    if (PlatformUtils.isIOS) {
      // iOS에서는 가벼운 임팩트 두 번으로 성공 표현
      await HapticFeedback.lightImpact();
      await Future.delayed(Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }
  
  /// iOS 스타일 오류 피드백
  static Future<void> errorTaptic() async {
    if (PlatformUtils.isIOS) {
      // iOS에서는 강한 임팩트로 오류 표현
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// iOS 스타일 경고 피드백
  static Future<void> warningTaptic() async {
    if (PlatformUtils.isIOS) {
      // iOS에서는 중간 임팩트로 경고 표현
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// iOS 스타일 새로고침 피드백
  static Future<void> refreshTaptic() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }
  
  /// iOS 스타일 스크롤 끝 피드백
  static Future<void> scrollEndTaptic() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.lightImpact();
    }
    // Android에서는 스크롤 끝 피드백 없음
  }
  
  /// iOS 스타일 검색 결과 피드백
  static Future<void> searchResultTaptic() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.selectionClick();
    } else {
      await HapticFeedback.selectionClick();
    }
  }
}
