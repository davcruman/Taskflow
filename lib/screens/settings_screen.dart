import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
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
      
      if (mounted) setState(() => _notificationsEnabled = granted ?? false);

      if (granted == false && mounted) {
        _showPermissionDeniedDialog();
      }
    } else {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("notificaciones".tr()),
        content: const Text("Para activar las notificaciones, por favor habilítalas en los ajustes del sistema."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancelar".tr())),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
            child: const Text("Ir a Ajustes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    final currentLocale = context.locale.languageCode;

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
          const Divider(),
          _buildHeader("idioma".tr()),
          _buildLanguageOption("es", "espanol".tr(), currentLocale, uiProvider),
          _buildLanguageOption("en", "ingles".tr(), currentLocale, uiProvider),
          _buildLanguageOption("fr", "frances".tr(), currentLocale, uiProvider),
          _buildLanguageOption("pt", "portugues".tr(), currentLocale, uiProvider),
          const Divider(),
          _buildHeader("cuenta".tr()),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text("cerrar_sesion".tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label, String current, UIProvider provider) {
    return ListTile(
      title: Text(label),
      leading: Icon(current == code ? Icons.radio_button_checked : Icons.radio_button_unchecked),
      onTap: () => provider.setLanguage(code, context),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  void _showLogoutDialog() {
    final BuildContext dialogContext = context;
    
    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Text("cerrar_sesion".tr()),
        content: Text("seguro_salir".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancelar".tr())),
          TextButton(
            onPressed: () async {
              final auth = FirebaseAuth.instance;
              await auth.signOut();
              
              if (mounted) {
                Navigator.of(dialogContext).popUntil((route) => route.isFirst);
              }
            },
            child: Text("si_salir".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}