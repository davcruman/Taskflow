import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Importa esto

import 'firebase_options.dart';
import 'ui/providers/ui_provider.dart'; 
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Inicializa easy_localization
  await EasyLocalization.ensureInitialized();

  await NotificationService.init();

  runApp(
    // 3. Envuelve todo en EasyLocalization
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en'),Locale('fr'),Locale('pt')],
      path: 'assets/translations', // Carpeta donde crearás tus .json
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
      title: 'TaskFlow',
      
      // 4. Configura el MaterialApp para que use los idiomas
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // Usamos el locale que viene de tu UIProvider
      
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