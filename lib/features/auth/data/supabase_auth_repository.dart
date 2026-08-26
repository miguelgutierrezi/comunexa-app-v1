import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final session = _auth.currentSession;
    if (session == null) return null;
    return _mapUser(session.user);
  }

  @override
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthFailure.invalidCredentials();
      }
      return _mapUser(user);
    } on AuthFailure {
      rethrow;
    } on AuthApiException catch (e) {
      throw _mapApiException(e);
    } on AuthRetryableFetchException catch (e) {
      throw AuthFailure.network(e);
    } catch (e) {
      throw AuthFailure.unknown(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthRetryableFetchException catch (e) {
      throw AuthFailure.network(e);
    } catch (e) {
      throw AuthFailure.unknown(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw AuthFailure.invalidCredentials();
    }
    try {
      await _auth.resetPasswordForEmail(normalized);
    } on AuthApiException catch (e) {
      throw _mapApiException(e);
    } on AuthRetryableFetchException catch (e) {
      throw AuthFailure.network(e);
    } catch (e) {
      throw AuthFailure.unknown(e);
    }
  }

  AuthUser _mapUser(User user) {
    final metaName = user.userMetadata?['full_name'] as String?;
    return AuthUser(
      id: user.id,
      email: (user.email ?? '').toLowerCase(),
      displayName: metaName,
    );
  }

  AuthFailure _mapApiException(AuthApiException e) {
    final status = e.statusCode;
    final message = e.message.toLowerCase();
    if (status == '400' ||
        status == '401' ||
        message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('email not confirmed')) {
      return AuthFailure.invalidCredentials(e);
    }
    if (status == '429' || message.contains('rate')) {
      return AuthFailure.rateLimited(e);
    }
    return AuthFailure.unknown(e);
  }
}
