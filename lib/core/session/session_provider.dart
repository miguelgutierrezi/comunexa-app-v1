import 'dart:async';

import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/access_context_repository_provider.dart';
import 'package:comunexa/features/auth/data/auth_repository_provider.dart';
import 'package:comunexa/features/auth/data/access_context_mapper.dart';
import 'package:comunexa/features/auth/domain/access_context_repository.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_state_change.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionNotifier extends AsyncNotifier<SessionState> {
  SessionStorage get _storage => ref.read(sessionStorageProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);
  AccessContextRepository get _access =>
      ref.read(accessContextRepositoryProvider);

  StreamSubscription<AuthStateChange>? _authSubscription;

  @override
  Future<SessionState> build() async {
    _authSubscription ??= _auth.authStateChanges.listen(_onAuthStateChange);
    ref.onDispose(() => _authSubscription?.cancel());

    return _restore();
  }

  Future<SessionState> _restore() async {
    final authUser = await _auth.restoreSession();
    if (authUser == null) {
      return SessionState.empty;
    }
    if (_auth.pendingPasswordRecovery) {
      return _recoverySessionFromAuthUser(authUser);
    }
    return _sessionFromAuthUser(authUser);
  }

  void _onAuthStateChange(AuthStateChange change) {
    unawaited(_handleAuthStateChange(change));
  }

  Future<void> _handleAuthStateChange(AuthStateChange change) async {
    switch (change.event) {
      case AuthSessionEvent.initialSession:
        return;
      case AuthSessionEvent.signedOut:
        state = const AsyncData(SessionState.empty);
      case AuthSessionEvent.passwordRecovery:
        final user = change.user ?? _auth.currentUser;
        if (user == null) return;
        state = AsyncData(_recoverySessionFromAuthUser(user));
      case AuthSessionEvent.signedIn:
      case AuthSessionEvent.tokenRefreshed:
      case AuthSessionEvent.userUpdated:
        if (_auth.pendingPasswordRecovery ||
            state.valueOrNull?.pendingPasswordRecovery == true) {
          return;
        }
        final user = change.user ?? _auth.currentUser;
        if (user == null) {
          state = const AsyncData(SessionState.empty);
          return;
        }
        state = AsyncData(await _sessionFromAuthUser(user));
    }
  }

  Future<PostLoginDestination> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final authUser = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (_auth.pendingPasswordRecovery) {
      final session = _recoverySessionFromAuthUser(authUser);
      state = AsyncData(session);
      return PostLoginDestination.resetPassword;
    }
    final session = await _sessionFromAuthUser(authUser);
    state = AsyncData(session);
    return _destinationFor(session);
  }

  Future<PostLoginDestination> updatePassword(String password) async {
    await _auth.updatePassword(password);
    final authUser = _auth.currentUser;
    if (authUser == null) {
      state = const AsyncData(SessionState.empty);
      return PostLoginDestination.noAccess;
    }
    final session = await _sessionFromAuthUser(authUser);
    state = AsyncData(session);
    return _destinationFor(session);
  }

  Future<void> selectContext(String contextId) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAuthenticated) return;
    if (current.pendingPasswordRecovery) return;

    final profileId = _auth.currentUser?.id;
    if (profileId == null) return;

    final validated = await _access.validateContext(profileId, contextId);
    if (validated == null) return;

    final active = AccessContextMapper.toUserAccessContext(validated);
    final next = current.copyWith(
      activeContext: active,
      lastUsedContextId: contextId,
      availableContexts: AccessContextMapper.applyLastUsedHighlight(
        current.availableContexts,
        contextId,
      ),
    );
    await _storage.writeLastContextId(contextId);
    state = AsyncData(next);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncData(SessionState.empty);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email);
  }

  SessionState _recoverySessionFromAuthUser(AuthUser authUser) {
    final email = authUser.email;
    return SessionState(
      email: email,
      displayName: authUser.displayName,
      pendingPasswordRecovery: true,
    );
  }

  Future<SessionState> _sessionFromAuthUser(AuthUser authUser) async {
    final email = authUser.email;
    final displayName = authUser.displayName;
    final accessContexts =
        await _access.getAvailableContexts(authUser.id);
    final contexts = accessContexts
        .map(AccessContextMapper.toUserAccessContext)
        .toList();
    final storedId = await _storage.readLastContextId();
    final preferred =
        storedId == null ? null : _findContext(contexts, storedId);

    if (contexts.isEmpty) {
      return SessionState(
        email: email,
        displayName: displayName,
      );
    }

    if (contexts.length == 1) {
      final active = contexts.first;
      await _storage.writeLastContextId(active.id);
      return SessionState(
        email: email,
        displayName: displayName,
        availableContexts: AccessContextMapper.applyLastUsedHighlight(
          contexts,
          active.id,
        ),
        activeContext: active,
        lastUsedContextId: active.id,
      );
    }

    if (preferred != null) {
      return SessionState(
        email: email,
        displayName: displayName,
        availableContexts: AccessContextMapper.applyLastUsedHighlight(
          contexts,
          preferred.id,
        ),
        activeContext: preferred,
        lastUsedContextId: preferred.id,
      );
    }

    final highlightId = _defaultLastUsedId(contexts);
    return SessionState(
      email: email,
      displayName: displayName,
      availableContexts: AccessContextMapper.applyLastUsedHighlight(
        contexts,
        highlightId,
      ),
      lastUsedContextId: highlightId,
    );
  }

  PostLoginDestination _destinationFor(SessionState session) {
    if (session.needsPasswordRecovery) {
      return PostLoginDestination.resetPassword;
    }
    if (session.authenticatedWithoutAccess) {
      return PostLoginDestination.noAccess;
    }
    if (session.needsContextSelection) {
      return PostLoginDestination.contextSelect;
    }
    if (session.hasActiveContext) return PostLoginDestination.home;
    return PostLoginDestination.home;
  }

  UserAccessContext? _findContext(
    List<UserAccessContext> contexts,
    String id,
  ) {
    for (final context in contexts) {
      if (context.id == id) return context;
    }
    return null;
  }

  String? _defaultLastUsedId(List<UserAccessContext> contexts) {
    for (final context in contexts) {
      if (context.isLastUsed) return context.id;
    }
    return contexts.isEmpty ? null : contexts.first.id;
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

final activeContextProvider = Provider<UserAccessContext?>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.activeContext;
});

final sessionDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.displayName;
});

final availableContextsProvider = Provider<List<UserAccessContext>>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.availableContexts ?? const [];
});
