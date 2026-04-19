import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // Constructor: Al crear el Provider, cargamos lo que haya en memoria
  UIProvider() {
    _loadPreferences();
  }

  // --- CARGAR PREFERENCIAS (MODO OSCURO E IDIOMA) ---
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar Tema
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Cargar Idioma
    final String languageCode = prefs.getString('languageCode') ?? 'es';
    _locale = Locale(languageCode);

    notifyListeners();
  }

  // --- CAMBIAR TEMA (Y GUARDAR) ---
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // --- CAMBIAR IDIOMA (Y GUARDAR) ---
  void setLanguage(String code) async {
    _locale = Locale(code);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }
}