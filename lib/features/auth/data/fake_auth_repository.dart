import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:flutter/foundation.dart';

/// Auth en memoria para tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.acceptAnyPassword = true,
    AuthUser? seed,
  }) : _current = seed;

  final bool acceptAnyPassword;
  String validPassword = 'password123';

  AuthFailureKind? nextSignInFailure;
  AuthFailureKind? nextResetFailure;

  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  void seedSession(AuthUser user) {
    _current = user;
  }

  @visibleForTesting
  void clearSession() {
    _current = null;
  }

  @override
  Future<AuthUser?> restoreSession() async => _current;

  @override
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final failure = nextSignInFailure;
    nextSignInFailure = null;
    if (failure != null) {
      throw _failure(failure);
    }

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      throw AuthFailure.invalidCredentials();
    }
    if (!acceptAnyPassword && password != validPassword) {
      throw AuthFailure.invalidCredentials();
    }

    final user = AuthUser(
      id: 'fake-${normalized.hashCode}',
      email: normalized,
      displayName: mockUserDisplayNameForEmail(normalized),
    );
    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final failure = nextResetFailure;
    nextResetFailure = null;
    if (failure != null) {
      throw _failure(failure);
    }
    if (email.trim().isEmpty) {
      throw AuthFailure.invalidCredentials();
    }
  }

  AuthFailure _failure(AuthFailureKind kind) {
    return switch (kind) {
      AuthFailureKind.invalidCredentials => AuthFailure.invalidCredentials(),
      AuthFailureKind.network => AuthFailure.network(),
      AuthFailureKind.notConfigured => AuthFailure.notConfigured(),
      AuthFailureKind.rateLimited => AuthFailure.rateLimited(),
      AuthFailureKind.unknown => AuthFailure.unknown(),
    };
  }
}
