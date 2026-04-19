// lib/ui/providers/ui_provider.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UIProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _vibrationEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleVibration(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  // MÉTODO CLAVE:
  void setLanguage(String code, BuildContext context) {
    final newLocale = Locale(code);
    context.setLocale(newLocale); // Esto es lo que cambia el idioma globalmente
    notifyListeners();
  }
}