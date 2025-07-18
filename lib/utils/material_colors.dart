import 'package:flutter/material.dart';

/// 머티리얼 디자인 3.0 컬러 시스템
class MaterialColors {
  // 기본 색상
  static const Color primary = Color(0xFF5A8DEE);
  static const Color primaryVariant = Color(0xFF4A7BD6);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // 표면 색상
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color background = Color(0xFFFFFBFE);
  
  // 텍스트 색상
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // 상태 색상
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF57C00);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  
  // 그라데이션 색상
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5A8DEE),
      Color(0xFF4A7BD6),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF03DAC6),
      Color(0xFF018786),
    ],
  );
  
  // 다크 테마 색상
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  
  // 머티리얼 디자인 Elevation 색상
  static Color elevatedSurface(int elevation) {
    switch (elevation) {
      case 1:
        return Color(0xFF1E1E1E);
      case 2:
        return Color(0xFF232323);
      case 3:
        return Color(0xFF252525);
      case 4:
        return Color(0xFF272727);
      case 6:
        return Color(0xFF2C2C2C);
      case 8:
        return Color(0xFF2E2E2E);
      case 12:
        return Color(0xFF333333);
      case 16:
        return Color(0xFF353535);
      case 24:
        return Color(0xFF383838);
      default:
        return Color(0xFF121212);
    }
  }
  
  // 카테고리별 색상 (기존 색상을 Material 3.0에 맞게 조정)
  static const Map<String, Color> categoryColors = {
    'business': Color(0xFF1976D2),
    'marketing': Color(0xFFE91E63),
    'it': Color(0xFF4CAF50),
    'hr': Color(0xFFFF9800),
    'communication': Color(0xFF9C27B0),
    'approval': Color(0xFF795548),
    'time': Color(0xFF607D8B),
    'other': Color(0xFF9E9E9E),
  };
  
  // 투명도 레벨 (Material Design 가이드라인)
  static const double disabled = 0.38;
  static const double hover = 0.04;
  static const double focus = 0.12;
  static const double selected = 0.08;
  static const double pressed = 0.12;
  static const double dragged = 0.16;
  
  // 그림자 색상
  static const Color shadow = Color(0xFF000000);
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowMedium = Color(0x3D000000);
  static const Color shadowDark = Color(0x66000000);
}

/// 머티리얼 디자인 컬러 스킴 생성기
class MaterialColorScheme {
  static ColorScheme lightScheme() {
    return ColorScheme.light(
      primary: MaterialColors.primary,
      primaryContainer: MaterialColors.primaryVariant,
      secondary: MaterialColors.secondary,
      secondaryContainer: MaterialColors.secondaryVariant,
      surface: MaterialColors.surface,
      surfaceContainerHighest: MaterialColors.surfaceVariant,
      error: MaterialColors.error,
      onPrimary: MaterialColors.onPrimary,
      onSecondary: MaterialColors.onSecondary,
      onSurface: MaterialColors.onSurface,
      onError: MaterialColors.onError,
      brightness: Brightness.light,
    );
  }
  
  static ColorScheme darkScheme() {
    return ColorScheme.dark(
      primary: MaterialColors.primary,
      primaryContainer: MaterialColors.primaryVariant,
      secondary: MaterialColors.secondary,
      secondaryContainer: MaterialColors.secondaryVariant,
      surface: MaterialColors.darkSurface,
      surfaceContainerHighest: MaterialColors.elevatedSurface(2),
      error: MaterialColors.error,
      onPrimary: MaterialColors.onPrimary,
      onSecondary: MaterialColors.onSecondary,
      onSurface: MaterialColors.darkOnSurface,
      onError: MaterialColors.onError,
      brightness: Brightness.dark,
    );
  }
}

/// 머티리얼 디자인 테마 생성기
class MaterialTheme {
  static ThemeData lightTheme() {
    final colorScheme = MaterialColorScheme.lightScheme();
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'NotoSansKR',
      
      // AppBar 테마
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shadowColor: MaterialColors.shadowLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 버튼 테마
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // FAB 테마
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static ThemeData darkTheme() {
    final colorScheme = MaterialColorScheme.darkScheme();
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'NotoSansKR',
      
      // AppBar 테마 (다크 모드)
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      
      // 카드 테마 (다크 모드)
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shadowColor: MaterialColors.shadowDark,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}