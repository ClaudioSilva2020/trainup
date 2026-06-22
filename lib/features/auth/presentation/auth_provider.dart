import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// State para operações de login/cadastro
sealed class AuthFormState {
  const AuthFormState();
}

class AuthFormIdle extends AuthFormState {
  const AuthFormIdle();
}

class AuthFormLoading extends AuthFormState {
  const AuthFormLoading();
}

class AuthFormError extends AuthFormState {
  const AuthFormError(this.message);
  final String message;
}

class AuthFormSuccess extends AuthFormState {
  const AuthFormSuccess();
}

class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormIdle();

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthFormLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      state = const AuthFormSuccess();
    } on AuthException catch (e) {
      state = AuthFormError(_translateAuthError(e.message));
    } catch (_) {
      state = const AuthFormError('Erro inesperado. Tente novamente.');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    state = const AuthFormLoading();
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
          );
      state = const AuthFormSuccess();
    } on AuthException catch (e) {
      state = AuthFormError(_translateAuthError(e.message));
    } catch (_) {
      state = const AuthFormError('Erro inesperado. Tente novamente.');
    }
  }

  void reset() => state = const AuthFormIdle();

  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (message.contains('User already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'A senha precisa ter ao menos 6 caracteres.';
    }
    if (message.contains('Unable to validate email address')) {
      return 'E-mail inválido.';
    }
    return message;
  }
}

final authFormProvider =
    NotifierProvider<AuthFormNotifier, AuthFormState>(AuthFormNotifier.new);
