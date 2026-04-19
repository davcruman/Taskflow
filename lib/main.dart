import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TUS IMPORTS
import 'firebase_options.dart';
import 'auth_wrapper.dart'; 
import 'ui/providers/ui_provider.dart'; 
import 'services/notification_service.dart'; // <--- IMPORT AÑADIDO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de Notificaciones
  await NotificationService.init(); // <--- LLAMADA AÑADIDA

  runApp(
    ChangeNotifierProvider(
      create: (_) => UIProvider(),
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      
      themeMode: uiProvider.themeMode, 
      
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),

      home: const AuthWrapper(),
    );
  }
}