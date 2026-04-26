import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios en el estado del usuario
  Stream<User?> get usuarioEstado {
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        AppLogger.i("🔐 Usuario detectado: ${user.email} | Nombre: ${user.displayName} (UID: ${user.uid})");
      } else {
        AppLogger.w("👤 Estado Auth: Sin usuario conectado");
      }
      return user;
    });
  }

  // REGISTRO (Actualizado para guardar el Nombre)
  Future<String?> registrar(String email, String password, String nombre) async {
    try {
      AppLogger.i("🆕 Intentando registrar usuario: $email con nombre: $nombre");
      
      // 1. Crear el usuario
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );

      // 2. SOLUCIÓN PROBLEMA DISPLAYNAME: Actualizar el perfil con el nombre
      if (credential.user != null) {
        await credential.user!.updateDisplayName(nombre);
        // Forzamos recarga para que el cambio sea inmediato
        await credential.user!.reload();
        AppLogger.i("✅ Nombre '$nombre' asignado correctamente a ${credential.user!.email}");
      }

      AppLogger.i("✅ Registro completo para: $email");
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
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
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

  // RECUPERAR CONTRASEÑA (Nueva función Problema 2)
  Future<String?> recuperarContrasena(String email) async {
    try {
      AppLogger.i("📧 Solicitando recuperación de contraseña para: $email");
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.i("✅ Correo de recuperación enviado a: $email");
      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.w("⚠️ No se pudo enviar el correo: ${e.code}");
      return _manejarError(e);
    } catch (e) {
      AppLogger.e("🔥 Error inesperado en recuperación", e);
      return 'No se pudo enviar el correo.';
    }
  }

  // CERRAR SESIÓN
  Future<void> salir() async {
    final email = _auth.currentUser?.email;
    AppLogger.w("🔌 Cerrando sesión de: $email");
    await _auth.signOut();
  }

  // MANEJO DE ERRORES
  String _manejarError(FirebaseAuthException e) {
    AppLogger.w("Analizando error de Firebase: ${e.code}");
    switch (e.code) {
      case 'user-not-found': return 'No existe el usuario.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'El email ya está en uso.';
      case 'invalid-email': return 'Email no válido.';
      case 'weak-password': return 'Contraseña muy corta (mín. 6 caracteres).';
      case 'network-request-failed': return 'Sin conexión a internet.';
      case 'too-many-requests': return 'Demasiados intentos. Inténtalo más tarde.';
      case 'user-disabled': return 'Esta cuenta ha sido deshabilitada.';
      default: return 'Ocurrió un error inesperado (${e.code}).';
    }
  }
}