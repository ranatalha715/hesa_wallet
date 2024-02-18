import 'package:flutter/material.dart';
import '../constants/my_theme_preferences.dart';

class ThemeProvider extends ChangeNotifier {
   bool _isDark=true;
   MyThemePreferences _preferences= MyThemePreferences();
  bool get isDark => _isDark;

   ThemeProvider() {
    _isDark = true;
    _preferences = MyThemePreferences();
    getPreferences();
  }
//Switching the themes
  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}

