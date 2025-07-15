import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
}