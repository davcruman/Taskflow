import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
// IMPORTANTE: Aquí la Persona A tendrá que importar su LoginScreen y su HomeScreen
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';

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
          // Persona A: Aquí pon tu pantalla principal (Home)
          return const Scaffold(body: Center(child: Text("Pantalla Principal")));
        } else {
          // Persona A: Aquí pon tu pantalla de Login
          return const Scaffold(body: Center(child: Text("Pantalla de Login")));
        }
      },
    );
  }
}