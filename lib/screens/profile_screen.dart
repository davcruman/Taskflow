import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario logueado actualmente
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // AVATAR CON INICIAL
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            
            // EMAIL DEL USUARIO
            Text(
              user?.email ?? "Usuario Invitado",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            const Divider(),
            
            // LISTA DE OPCIONES DE PERFIL
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Editar Nombre"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}, // Funcionalidad futura
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text("Notificaciones"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const SizedBox(height: 40),

            // BOTÓN DE CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar Sesión"),
                onPressed: () async {
                  await AuthService().salir();
                  Navigator.pop(context); // Cerramos el perfil al salir
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}