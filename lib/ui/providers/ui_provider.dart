import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _vibrationEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;

  // Constructor: Al crear el Provider, cargamos las preferencias guardadas
  UIProvider() {
    _loadPreferences();
  }

  // --- CARGAR PREFERENCIAS (TEMA Y VIBRACIÓN) ---
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar Tema
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Cargar Vibración
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;

    notifyListeners();
  }

  // --- CAMBIAR TEMA (Y GUARDAR) ---
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // --- CAMBIAR VIBRACIÓN (Y GUARDAR) ---
  void toggleVibration(bool value) async {
    _vibrationEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
  }

  // --- CAMBIAR IDIOMA ---
  // easy_localization guarda automáticamente el idioma en el dispositivo,
  // por lo que solo necesitamos indicarle el nuevo Locale al context.
  void setLanguage(String code, BuildContext context) {
    final newLocale = Locale(code);
    context.setLocale(newLocale); 
    notifyListeners();
  }
}