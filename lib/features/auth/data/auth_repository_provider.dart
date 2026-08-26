import 'package:comunexa/core/supabase/comunexa_supabase.dart';
import 'package:comunexa/features/auth/data/supabase_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_state_change.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!ComunexaSupabase.isInitialized) {
    return const UnconfiguredAuthRepository();
  }
  return SupabaseAuthRepository(ComunexaSupabase.client);
});

/// Sin `SUPABASE_URL` / anon key: cualquier operación de Auth falla claro.
class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  @override
  AuthUser? get currentUser => null;

  @override
  bool get pendingPasswordRecovery => false;

  @override
  Stream<AuthStateChange> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser?> restoreSession() async => null;

  @override
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    throw AuthFailure.notConfigured();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw AuthFailure.notConfigured();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw AuthFailure.notConfigured();
  }
}
