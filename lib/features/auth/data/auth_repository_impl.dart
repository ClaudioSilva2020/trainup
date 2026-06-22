import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
