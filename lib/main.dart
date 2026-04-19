import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- NUEVO

import 'firebase_options.dart';
import 'ui/providers/ui_provider.dart'; 
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 0. Selección y Carga de Entorno
  // Mañana puedes explicar que aquí cambias entre .env.dev y .env.prod
  const String envFile = ".env.dev"; 
  try {
    await dotenv.load(fileName: envFile);
    debugPrint("🚀 Entorno cargado: ${dotenv.env['ENVIRONMENT']}");
  } catch (e) {
    debugPrint("⚠️ No se pudo cargar el archivo $envFile: $e");
  }

  // 1. Inicialización de Formatos de Fecha
  await initializeDateFormatting();

  // 2. Inicialización de Firebase (Ahora leerá de los dotenv en firebase_options.dart)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 3. Inicializa easy_localization
  await EasyLocalization.ensureInitialized();

  // 4. Inicialización de Notificaciones
  await NotificationService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('es'), 
        Locale('en'),
        Locale('fr'),
        Locale('pt')
      ],
      path: 'assets/translations', 
      fallbackLocale: const Locale('es'),
      child: ChangeNotifierProvider(
        create: (_) => UIProvider(),
        child: const TaskFlowApp(),
      ),
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
      // Usamos el nombre de la app definido en el entorno cargado
      title: dotenv.env['APP_NAME'] ?? 'TaskFlow', 
      
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      
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