import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/providers/ui_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Apariencia", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: Icon(uiProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            title: const Text("Modo Oscuro"),
            trailing: Switch(
              value: uiProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => uiProvider.toggleTheme(value),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Idioma", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
        ],
      ),
    );
  }
}