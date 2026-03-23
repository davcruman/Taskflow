import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskflow - Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.salir(), // Botón para cerrar sesión
          ),
        ],
      ),
      body: const Center(
        child: Text('¡Bienvenido! Aquí irán tus tareas 🚀'),
      ),
    );
  }
}