import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Detector de estado de la sesión (Punto #1 del flujo)
  Stream<User?> get usuarioEstado => _auth.authStateChanges();

  // Función de Registro (Punto #2)
  Future<String?> registrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; 
    } on FirebaseAuthException catch (e) {
      return _manejarError(e);
    }
  }

  // Función de Login (Punto #3)
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _manejarError(e);
    }
  }

  Future<void> salir() async => await _auth.signOut();

  String _manejarError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No existe el usuario.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'El email ya está en uso.';
      case 'invalid-email': return 'Email no válido.';
      case 'weak-password': return 'Contraseña muy corta (mín. 6)';
      default: return 'Error inesperado.';
    }
  }
}