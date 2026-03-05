import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // El archivo que acabas de generar

void main() async {
  // 1. Aseguramos que Flutter esté listo antes de llamar a Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase con tus credenciales
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_done, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Firebase Conectado 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}