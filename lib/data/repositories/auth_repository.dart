import 'package:admin_app/core/services/auth_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  Future<User?> signUpWithEmail(String email, String password) async {
    return _authService.signUpWithEmail(email, password);
  }

  Future<User?> loginWithEmail(String email, String password) async {
    return _authService.loginWithEmail(email, password);
  }

  Future<void> signOut() async {
    return _authService.signOut();
  }

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges();
}
