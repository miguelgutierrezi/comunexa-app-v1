import 'package:comunexa/features/auth/domain/auth_user.dart';

/// Contrato de autenticación (email/password hoy; OAuth después).
abstract class AuthRepository {
  /// Usuario de la sesión actual, si hay JWT restaurado o login previo.
  AuthUser? get currentUser;

  /// Restaura sesión persistida (Supabase local storage / fake seed).
  Future<AuthUser?> restoreSession();

  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Envía correo de recuperación (Supabase Auth).
  Future<void> sendPasswordResetEmail(String email);
}
