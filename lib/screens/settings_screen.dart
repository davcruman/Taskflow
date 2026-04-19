import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart'; // Importante
import '../ui/providers/ui_provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final bool? isGranted = await android?.areNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = isGranted ?? false);
  }

  Future<void> _handleNotificationPermission(bool value) async {
    if (value) {
      final plugin = FlutterLocalNotificationsPlugin();
      final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      setState(() => _notificationsEnabled = granted ?? false);
    } else {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("ajustes".tr())),
      body: ListView(
        children: [
          _buildHeader("apariencia".tr()),
          ListTile(
            leading: Icon(uiProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            title: Text("modo_oscuro".tr()),
            trailing: Switch(
              value: uiProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => uiProvider.toggleTheme(value),
            ),
          ),
          const Divider(),
          _buildHeader("notificaciones".tr()),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text("permitir_notificaciones".tr()),
            value: _notificationsEnabled,
            onChanged: (val) => _handleNotificationPermission(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text("vibracion".tr()),
            value: uiProvider.vibrationEnabled,
            onChanged: _notificationsEnabled ? (val) => uiProvider.toggleVibration(val) : null,
          ),
          const Divider(),
          _buildHeader("idioma".tr()),
         // Dentro de tu SettingsScreen, donde están los RadioListTile:
RadioListTile<String>(
  title: Text("espanol".tr()),
  value: 'es',
  groupValue: context.locale.languageCode,
  onChanged: (value) => uiProvider.setLanguage(value!, context),
),
RadioListTile<String>(
  title: Text("ingles".tr()),
  value: 'en',
  groupValue: context.locale.languageCode,
  onChanged: (value) => uiProvider.setLanguage(value!, context),
),
RadioListTile<String>(
  title: Text("frances".tr()),
  value: 'fr',
  groupValue: context.locale.languageCode,
  onChanged: (value) => uiProvider.setLanguage(value!, context),
),
RadioListTile<String>(
  title: Text("portugues".tr()),
  value: 'pt',
  groupValue: context.locale.languageCode,
  onChanged: (value) => uiProvider.setLanguage(value!, context),
),
          const Divider(),
          _buildHeader("cuenta".tr()),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text("cerrar_sesion".tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            subtitle: Text("subtitulo_cerrar_sesion".tr()),
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 30),
          Center(child: Text("version".tr(args: ['1.0.0']), style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("cerrar_sesion".tr()),
        content: Text("seguro_salir".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancelar".tr())),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              await FirebaseAuth.instance.signOut();
            },
            child: Text("si_salir".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}