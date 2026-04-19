import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_logger.dart'; // Asegúrate de que la ruta sea correcta

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios en el estado del usuario
  Stream<User?> get usuarioEstado {
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        AppLogger.i("🔐 Usuario detectado: ${user.email} (UID: ${user.uid})");
      } else {
        AppLogger.w("👤 Estado Auth: Sin usuario conectado");
      }
      return user;
    });
  }

  // REGISTRO
  Future<String?> registrar(String email, String password) async {
    try {
      AppLogger.i("🆕 Intentando registrar usuario: $email");
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      AppLogger.i("✅ Registro exitoso para: $email");
      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.e("❌ Error en registro de Firebase", e.code, StackTrace.current);
      return _manejarError(e);
    } catch (e) {
      AppLogger.e("🔥 Error desconocido en registro", e);
      return 'Error inesperado.';
    }
  }

  // INICIO DE SESIÓN
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      AppLogger.i("🔑 Intentando login: $email");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      AppLogger.i("✅ Login correcto: $email");
      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.w("⚠️ Fallo de autenticación: ${e.code}");
      return _manejarError(e);
    } catch (e, stack) {
      AppLogger.e("🔥 Error crítico en iniciarSesion", e, stack);
      return 'Error de conexión.';
    }
  }

  // CERRAR SESIÓN
  Future<void> salir() async {
    final email = _auth.currentUser?.email;
    AppLogger.w("🔌 Cerrando sesión de: $email");
    await _auth.signOut();
  }

  // MANEJO DE ERRORES (Con logs específicos)
  String _manejarError(FirebaseAuthException e) {
    AppLogger.w("Analizando error de Firebase: ${e.code}");
    switch (e.code) {
      case 'user-not-found': return 'No existe el usuario.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'El email ya está en uso.';
      case 'invalid-email': return 'Email no válido.';
      case 'weak-password': return 'Contraseña muy corta (mín. 6 caracteres).';
      case 'network-request-failed': return 'Sin conexión a internet.';
      default: return 'Ocurrió un error inesperado (${e.code}).';
    }
  }
}