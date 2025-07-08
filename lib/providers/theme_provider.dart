import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  late Box _settingsBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _settingsBox = await Hive.openBox('settings');
    _isDarkMode = _settingsBox.get(_themeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _settingsBox.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _settingsBox.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

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
    cardColor: const Color(0xFFEBF0F5),
    dividerColor: const Color(0xFFA6B4C4),
    iconTheme: const IconThemeData(color: Color(0xFF4F5A67)),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Color(0xFFE5E5E5),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE5E5E5)),
      bodyMedium: TextStyle(color: Color(0xFFE5E5E5)),
      titleLarge: TextStyle(color: Color(0xFFE5E5E5)),
      titleMedium: TextStyle(color: Color(0xFFE5E5E5)),
      titleSmall: TextStyle(color: Color(0xFFE5E5E5)),
    ),
    cardColor: const Color(0xFF2A2A2A),
    dividerColor: const Color(0xFF4A4A4A),
    iconTheme: const IconThemeData(color: Color(0xFFE5E5E5)),
  );

  // Helper methods for colors that need to be accessed by widgets
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEBF0F5);
  Color get cardColor => _isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEBF0F5);
  Color get textColor => _isDarkMode ? const Color(0xFFE5E5E5) : const Color(0xFF4F5A67);
  Color get subtitleColor => _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF4F5A67);
  Color get shadowColor => _isDarkMode ? const Color(0xFF000000) : const Color(0xFFA6B4C4);
  Color get highlightColor => _isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
  Color get dividerColor => _isDarkMode ? const Color(0xFF4A4A4A) : const Color(0xFFA6B4C4);
}