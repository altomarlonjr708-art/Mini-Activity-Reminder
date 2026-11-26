import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController() {
    _loadTheme();
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('theme_mode');
    if (value == 'light') _themeMode = ThemeMode.light;
    if (value == 'dark') _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    SharedPreferences.getInstance().then((preferences) {
      preferences.setString('theme_mode', mode.name);
    });
  }
}
