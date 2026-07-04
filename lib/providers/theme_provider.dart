import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider — مدير وضع السمة (فاتح / داكن)
///
/// يحفظ تفضيل المستخدم في SharedPreferences ويُعيد تحميله عند بدء التطبيق.
class ThemeProvider extends ChangeNotifier {
  static const String _kThemeModeKey = 'shams_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// يُحمَّل عند بدء التشغيل — يُعيد قراءة التفضيل المحفوظ.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_kThemeModeKey);
    if (savedIndex != null && savedIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[savedIndex];
      notifyListeners();
    }
  }

  /// يُبدّل بين الوضع الفاتح والداكن ويحفظ الاختيار.
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, _themeMode.index);
  }

  /// يضبط وضع السمة مباشرة.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }
}
