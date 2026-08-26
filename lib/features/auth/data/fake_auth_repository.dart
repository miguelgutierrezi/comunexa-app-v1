import 'dart:async';

import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_state_change.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:flutter/foundation.dart';

/// Auth en memoria para tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.acceptAnyPassword = true,
    AuthUser? seed,
    this._pendingPasswordRecovery = false,
  }) : _current = seed;

  final bool acceptAnyPassword;
  String validPassword = 'password123';

  AuthFailureKind? nextSignInFailure;
  AuthFailureKind? nextResetFailure;
  AuthFailureKind? nextUpdatePasswordFailure;

  AuthUser? _current;
  bool _pendingPasswordRecovery;
  final _changes = StreamController<AuthStateChange>.broadcast();

  @override
  bool get pendingPasswordRecovery => _pendingPasswordRecovery;

  @override
  Stream<AuthStateChange> get authStateChanges => _changes.stream;

  @override
  AuthUser? get currentUser => _current;

  void seedSession(AuthUser user) {
    _current = user;
  }

  @visibleForTesting
  void clearSession() {
    _current = null;
    _pendingPasswordRecovery = false;
  }

  /// Simula deep link de recuperación (Supabase `PASSWORD_RECOVERY`).
  void simulatePasswordRecovery({AuthUser? user}) {
    _current = user ??
        const AuthUser(
          id: 'fake-recovery',
          email: 'recovery@test.com',
          displayName: 'Usuario Recovery',
        );
    _pendingPasswordRecovery = true;
    _emit(
      AuthStateChange(
        event: AuthSessionEvent.passwordRecovery,
        user: _current,
      ),
    );
  }

  void _emit(AuthStateChange change) {
    if (!_changes.isClosed) {
      _changes.add(change);
    }
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

    if (normalized.startsWith('demo:recovery')) {
      _pendingPasswordRecovery = true;
      final user = AuthUser(
        id: 'fake-${normalized.hashCode}',
        email: normalized,
        displayName: mockUserDisplayNameForEmail(normalized),
      );
      _current = user;
      _emit(
        AuthStateChange(event: AuthSessionEvent.passwordRecovery, user: user),
      );
      return user;
    }

    final user = AuthUser(
      id: 'fake-${normalized.hashCode}',
      email: normalized,
      displayName: mockUserDisplayNameForEmail(normalized),
    );
    _current = user;
    _pendingPasswordRecovery = false;
    _emit(AuthStateChange(event: AuthSessionEvent.signedIn, user: user));
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _pendingPasswordRecovery = false;
    _emit(const AuthStateChange(event: AuthSessionEvent.signedOut));
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

  @override
  Future<void> updatePassword(String newPassword) async {
    final failure = nextUpdatePasswordFailure;
    nextUpdatePasswordFailure = null;
    if (failure != null) {
      throw _failure(failure);
    }
    if (newPassword.trim().length < 8) {
      throw AuthFailure.invalidCredentials();
    }
    if (_current == null) {
      throw AuthFailure.invalidCredentials();
    }
    _pendingPasswordRecovery = false;
    _emit(
      AuthStateChange(
        event: AuthSessionEvent.userUpdated,
        user: _current,
      ),
    );
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

  @visibleForTesting
  void dispose() {
    _changes.close();
  }
}
