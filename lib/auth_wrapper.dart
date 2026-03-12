import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.usuarioEstado,
      builder: (context, snapshot) {
        // Si el snapshot tiene datos, significa que hay un usuario logueado
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("TaskFlow Home"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => authService.salir(),
                )
              ],
            ),
            body: const Center(child: Text("¡Has iniciado sesión con éxito!")),
          );
        } else {
          // Si no hay datos, mostramos el login
          return const LoginScreen();
        }
      },
    );
  }
}