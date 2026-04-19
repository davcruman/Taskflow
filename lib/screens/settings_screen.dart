import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../ui/providers/ui_provider.dart';
import '../utils/app_logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estados locales para los interruptores
  bool _notificationsEnabled = false;
  bool _vibrationEnabled = true;

  // Función para gestionar permisos de notificación
  Future<void> _handleNotificationPermission(bool value) async {
    if (value) {
      final plugin = FlutterLocalNotificationsPlugin();
      final androidImplementation = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();

      setState(() {
        _notificationsEnabled = granted ?? false;
      });

      if (granted == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de notificaciones denegado")),
        );
      }
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: [
          // --- SECCIÓN: APARIENCIA ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Apariencia", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: Icon(uiProvider.themeMode == ThemeMode.dark 
                ? Icons.dark_mode 
                : Icons.light_mode),
            title: const Text("Modo Oscuro"),
            trailing: Switch(
              value: uiProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => uiProvider.toggleTheme(value),
            ),
          ),
          
          const Divider(),

          // --- SECCIÓN NUEVA: NOTIFICACIONES ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Notificaciones", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text("Permitir notificaciones"),
            value: _notificationsEnabled,
            onChanged: (val) => _handleNotificationPermission(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text("Vibración"),
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled 
                ? (val) => setState(() => _vibrationEnabled = val) 
                : null, // Bloqueado si no hay notificaciones
          ),

          const Divider(),

          // --- SECCIÓN: IDIOMA ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Idioma", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Idioma"),
            subtitle: Text(uiProvider.locale.languageCode == 'es' 
                ? "Español (España)" 
                : "English (US)"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              AppLogger.i("Cambiando idioma...");
            },
          ),
          RadioListTile<String>(
            title: const Text("Español"),
            value: 'es',
            groupValue: uiProvider.locale.languageCode,
            onChanged: (value) => uiProvider.setLanguage(value!),
          ),
          RadioListTile<String>(
            title: const Text("English"),
            value: 'en',
            groupValue: uiProvider.locale.languageCode,
            onChanged: (value) => uiProvider.setLanguage(value!),
          ),
          
          const SizedBox(height: 20),
          const Center(
            child: Text("Versión 1.0.0", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}