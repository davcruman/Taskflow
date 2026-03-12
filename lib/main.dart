import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // Importamos vuestro nuevo "controlador de tráfico"

void main() async {
  // 1. Aseguramos que los enlaces de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase con la configuración generada por el CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Para que tenga un diseño más moderno
      ),
      // 3. El punto de entrada ahora es el Wrapper. 
      // Él decidirá si mostrar el Login o la Home.
      home: const AuthWrapper(),
    );
  }
}