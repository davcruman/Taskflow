// ... (tus otros imports)
import 'package:firebase_auth/firebase_auth.dart'; // Necesitas este paquete
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';

// Dentro de tu clase MyApp:
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      
      // EL CONTROLADOR DE FLUJO (Punto clave de la Persona A)
      home: StreamBuilder<User?>(
        // Escuchamos el canal de Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Si está cargando la conexión con Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // 2. Si hay un usuario activo, mostramos Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // 3. Si no hay nadie, mostramos Login
          return const LoginScreen();
        },
      ),
    );
  }
}