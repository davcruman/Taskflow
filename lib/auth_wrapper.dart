import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.usuarioEstado,
      builder: (context, snapshot) {
        // 1. Mientras comprueba si hay sesión (Cargando)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si el snapshot tiene datos, el usuario está logueado
        if (snapshot.hasData) {
          // IMPORTANTE: Aquí llamamos a tu pantalla real de la Persona A
          return const HomeScreen(); 
        } 
        
        // 3. Si no hay datos, mostramos el login
        else {
          return const LoginScreen();
        }
      },
    );
  }
}