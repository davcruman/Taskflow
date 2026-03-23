import 'package:flutter/material.dart';

class UIProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // Cambiar entre sol y luna
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Esto redibuja toda la app con los nuevos colores
  }

  // Cambiar entre español e inglés
  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
  }
}