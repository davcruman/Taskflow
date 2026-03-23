import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TUS IMPORTS (Asegúrate de que las rutas coincidan)
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // Tu "policía" de la navegación
import 'ui/providers/ui_provider.dart'; // Tu controlador de Modo Oscuro

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase (Lo de tu amigo)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Como ahora solo tenemos un Provider (el tuyo), usamos ChangeNotifierProvider directo
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
    // Escuchamos al UIProvider para saber si el usuario quiere Modo Oscuro
    final uiProvider = Provider.of<UIProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      
      // CONFIGURACIÓN DE TEMA DINÁMICO
      themeMode: uiProvider.themeMode, 
      
      // Tema Claro (Light)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      
      // Tema Oscuro (Dark)
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),

      // Punto de entrada
      home: const AuthWrapper(),
    );
  }
}