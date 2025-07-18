import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../services/error_service.dart';

/// 테마 모드 열거형
enum AppThemeMode {
  /// 시스템 설정 따름
  system,
  /// 라이트 모드
  light,
  /// 다크 모드
  dark,
}

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return '시스템 설정';
      case AppThemeMode.light:
        return '라이트 모드';
      case AppThemeMode.dark:
        return '다크 모드';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String get iosIconName {
    switch (this) {
      case AppThemeMode.system:
        return 'brightness_auto';
      case AppThemeMode.light:
        return 'light_mode';
      case AppThemeMode.dark:
        return 'dark_mode';
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  Box? _settingsBox;
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  BuildContext? _context;

  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  
  /// 컨텍스트 설정 (시스템 테마 감지용)
  void setContext(BuildContext context) {
    _context = context;
    if (_themeMode == AppThemeMode.system) {
      _updateSystemTheme();
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      
      // 기존 boolean 값을 enum으로 마이그레이션
      final savedThemeMode = _settingsBox!.get(_themeModeKey);
      if (savedThemeMode != null) {
        _themeMode = AppThemeMode.values[savedThemeMode];
      } else {
        // 기존 boolean 값이 있다면 마이그레이션
        final oldDarkMode = _settingsBox!.get('isDarkMode');
        if (oldDarkMode != null) {
          _themeMode = oldDarkMode ? AppThemeMode.dark : AppThemeMode.light;
          await _settingsBox!.put(_themeModeKey, _themeMode.index);
          await _settingsBox!.delete('isDarkMode');
        }
      }
      
      _updateThemeState();
      _isInitialized = true;
      notifyListeners();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError(
          'Loading theme settings', e, stackTrace);
      ErrorService.logError(error);

      // 기본값으로 폴백
      _themeMode = AppThemeMode.system;
      _updateThemeState();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (!_isInitialized) {
      final error = ErrorService.createDatabaseError(
          'Theme provider not initialized', null, null);
      ErrorService.logError(error);
      return;
    }

    try {
      _themeMode = mode;
      await _settingsBox!.put(_themeModeKey, mode.index);
      _updateThemeState();
      notifyListeners();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError(
          'Saving theme mode', e, stackTrace);
      ErrorService.logError(error);
    }
  }

  /// 시스템 테마 변경 감지
  void onSystemThemeChanged() {
    if (_themeMode == AppThemeMode.system) {
      _updateSystemTheme();
      notifyListeners();
    }
  }

  /// 테마 상태 업데이트
  void _updateThemeState() {
    switch (_themeMode) {
      case AppThemeMode.system:
        _updateSystemTheme();
        break;
      case AppThemeMode.light:
        _isDarkMode = false;
        break;
      case AppThemeMode.dark:
        _isDarkMode = true;
        break;
    }
  }

  /// 시스템 테마 감지 및 적용
  void _updateSystemTheme() {
    if (_context != null) {
      final brightness = MediaQuery.platformBrightnessOf(_context!);
      _isDarkMode = brightness == Brightness.dark;
    }
  }

  /// 레거시 지원용 메서드
  Future<void> setTheme(bool isDark) async {
    await setThemeMode(isDark ? AppThemeMode.dark : AppThemeMode.light);
  }

  /// iOS용 Cupertino 테마 생성
  CupertinoThemeData get cupertinoTheme => CupertinoThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
    barBackgroundColor: backgroundColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: CupertinoTextThemeData(
      primaryColor: textColor,
      textStyle: TextStyle(
        color: textColor,
        fontSize: 17,
        fontFamily: 'NotoSansKR',
      ),
      navTitleTextStyle: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansKR',
      ),
      navActionTextStyle: TextStyle(
        color: Color(0xFF5A8DEE),
        fontSize: 17,
        fontFamily: 'NotoSansKR',
      ),
      tabLabelTextStyle: TextStyle(
        color: textColor,
        fontSize: 12,
        fontFamily: 'NotoSansKR',
      ),
    ),
  );


  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEBF0F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEBF0F5),
          foregroundColor: Color(0xFF4F5A67),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4F5A67)),
          bodyMedium: TextStyle(color: Color(0xFF4F5A67)),
          titleLarge: TextStyle(color: Color(0xFF4F5A67)),
          titleMedium: TextStyle(color: Color(0xFF4F5A67)),
          titleSmall: TextStyle(color: Color(0xFF4F5A67)),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
          titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
        ),
      );

  // 색상 getters
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEBF0F5);
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFEBF0F5);
  Color get textColor => _isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF4F5A67);
  Color get subtitleColor => _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF8A8A8A);
  Color get shadowColor => _isDarkMode ? const Color(0xFF000000) : const Color(0xFFB0B8C5);
  Color get highlightColor => _isDarkMode ? const Color(0xFF404040) : const Color(0xFFFFFFFF);
  Color get dividerColor => _isDarkMode ? const Color(0xFF404040) : const Color(0xFFD0D0D0);
}