import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
