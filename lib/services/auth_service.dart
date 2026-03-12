import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. EL DETECTOR (Punto #1 del flujo)
  // Este "Stream" avisa constantemente si el usuario está dentro o fuera.
  Stream<User?> get usuarioEstado => _auth.authStateChanges();

  // 2. FUNCIÓN DE REGISTRO (Punto #2)
  Future<String?> registrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return _manejarError(e);
    }
  }

  // 3. FUNCIÓN DE LOGIN (Punto #3)
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return _manejarError(e);
    }
  }

  // 4. CERRAR SESIÓN
  Future<void> salir() async {
    await _auth.signOut();
  }

  // Traductor de errores de Firebase a español sencillo
  String _manejarError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No existe ningún usuario con este email.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'Este email ya está registrado.';
      case 'invalid-email': return 'El formato del email no es válido.';
      case 'weak-password': return 'La contraseña es muy débil (mínimo 6 caracteres).';
      default: return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
    }
  }
}