import 'package:flutter/material.dart';

import '../configs/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme;
  bool _isDarkMode;

  ThemeProvider({bool isDarkMode = false})
      : _isDarkMode = isDarkMode,
        _currentTheme = isDarkMode ? darkTheme : lightTheme;

  ThemeData get theme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}
