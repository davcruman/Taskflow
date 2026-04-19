import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/utils/app_logger.dart';

class UIProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _vibrationEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;

  UIProvider() {
    AppLogger.i("🚀 UIProvider inicializado");
    _loadPreferences();
  }

  // --- CARGAR PREFERENCIAS (TEMA Y VIBRACIÓN) ---
  Future<void> _loadPreferences() async {
    try {
      AppLogger.i("⚙️ [START] _loadPreferences");
      AppLogger.i("⚙️ Cargando preferencias de usuario desde SharedPreferences...");
      
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar Tema
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      AppLogger.i("🌓 Tema recuperado: ${isDark ? 'Oscuro' : 'Claro'}");

      // Cargar Vibración
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      AppLogger.i("📳 Vibración recuperada: ${_vibrationEnabled ? 'Activada' : 'Desactivada'}");

      AppLogger.i("🔄 Notificando listeners tras cargar preferencias");
      notifyListeners();

      AppLogger.i("✅ [END] _loadPreferences completado correctamente");
    } catch (e, stack) {
      AppLogger.e("❌ Error al cargar preferencias persistentes", e, stack);
    }
  }

  // --- CAMBIAR TEMA (Y GUARDAR) ---
  void toggleTheme(bool isDark) async {
    try {
      AppLogger.i("⚙️ [START] toggleTheme");
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      AppLogger.i("🌓 Cambiando tema a: ${isDark ? 'Oscuro' : 'Claro'}");

      AppLogger.i("🔄 Notificando listeners por cambio de tema");
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
      AppLogger.i("💾 Preferencia de tema guardada");

      AppLogger.i("✅ [END] toggleTheme completado");
    } catch (e) {
      AppLogger.e("❌ Error al guardar preferencia de tema", e);
    }
  }

  // --- CAMBIAR VIBRACIÓN (Y GUARDAR) ---
  void toggleVibration(bool value) async {
    try {
      AppLogger.i("⚙️ [START] toggleVibration");
      _vibrationEnabled = value;
      AppLogger.i("📳 Cambiando vibración a: ${value ? 'Activada' : 'Desactivada'}");

      AppLogger.i("🔄 Notificando listeners por cambio de vibración");
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vibrationEnabled', value);
      AppLogger.i("💾 Preferencia de vibración guardada");

      AppLogger.i("✅ [END] toggleVibration completado");
    } catch (e) {
      AppLogger.e("❌ Error al guardar preferencia de vibración", e);
    }
  }

  // --- CAMBIAR IDIOMA ---
  void setLanguage(String code, BuildContext context) {
    try {
      AppLogger.i("⚙️ [START] setLanguage");
      AppLogger.i("🌐 Cambiando idioma a: $code");

      final newLocale = Locale(code);
      context.setLocale(newLocale); 
      
      // Verificamos si el cambio se aplicó
      AppLogger.i("✅ Idioma establecido correctamente: ${context.locale.languageCode}");

      AppLogger.i("🔄 Notificando listeners por cambio de idioma");
      notifyListeners();

      AppLogger.i("✅ [END] setLanguage completado");
    } catch (e) {
      AppLogger.e("❌ Error al cambiar el idioma", e);
    }
  }
}