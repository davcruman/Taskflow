import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- IMPORTANTE PARA EL CALENDARIO ---
import 'package:intl/date_symbol_data_local.dart'; 

// TUS IMPORTS
import 'firebase_options.dart';
import 'ui/providers/ui_provider.dart'; 
import 'services/notification_service.dart';
import 'screens/home_screen.dart';  
import 'screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicialización de Idiomas (Evita que el calendario explote)
  await initializeDateFormatting('es_ES', null);

  // 2. Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicialización de Notificaciones
  await NotificationService.init();

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
      
      // Aplicamos el idioma a nivel de App también
      locale: uiProvider.locale, 
      
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

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}