import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
  }

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      String? theme = prefs.getString('theme');
      if (theme == null || theme == 'system'){
        _themeMode = ThemeMode.system;
      } else if (theme == 'dark'){
        _themeMode = ThemeMode.dark;
      }else if (theme == 'light') {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    });
  }

  Future<void> setDark() async {
    themeMode = ThemeMode.dark;
    notifyListeners();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('theme', 'dark');
  }

  Future<void> setLight() async {
    themeMode = ThemeMode.light;
    notifyListeners();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('theme', 'light');
  }

  Future<void> setSystem() async {
    themeMode = ThemeMode.system;
    notifyListeners();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('theme', 'system');
  }
}