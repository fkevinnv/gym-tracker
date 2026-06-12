import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios de sesión
  Stream<User?> get userStream => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null = éxito
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'weak-password':
          return 'La contraseña es demasiado débil';
        case 'invalid-email':
          return 'Email no válido';
        default:
          return 'Error: ${e.message}';
      }
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-email':
          return 'Email no válido';
        default:
          return 'Error: ${e.message}';
      }
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}