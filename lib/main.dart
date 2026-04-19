import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- IMPORTANTE PARA EL STREAM
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TUS IMPORTS
import 'firebase_options.dart';
import 'ui/providers/ui_provider.dart'; 
import 'services/notification_service.dart';
import 'screens/home_screen.dart';  // Asegúrate de que la ruta sea correcta
import 'screens/login_screen.dart'; // Asegúrate de que la ruta sea correcta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de Notificaciones
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

      // CAMBIO CLAVE: Usamos StreamBuilder en lugar de AuthWrapper
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si Firebase está cargando la sesión
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Si snapshot tiene datos, hay un usuario activo -> Vamos a la Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Si no hay datos, el usuario cerró sesión o no ha entrado -> Login
          return const LoginScreen();
        },
      ),
    );
  }
}
