import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/auth_repository_provider.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/domain/auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionNotifier extends AsyncNotifier<SessionState> {
  SessionStorage get _storage => ref.read(sessionStorageProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  Future<SessionState> build() => _restore();

  Future<SessionState> _restore() async {
    final authUser = await _auth.restoreSession();
    if (authUser == null) {
      // Sin Auth no hay sesión; se conserva lastContextId solo como hint UX
      // (se valida contra membresías del próximo login).
      return SessionState.empty;
    }
    return _sessionFromAuthUser(authUser);
  }

  /// Login email/password vía Auth; contextos de membresía siguen mock hasta cutover.
  Future<PostLoginDestination> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final authUser = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = await _sessionFromAuthUser(authUser);
    state = AsyncData(session);
    return _destinationFor(session);
  }

  Future<void> selectContext(String contextId) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAuthenticated) return;

    final active = _findContext(current.availableContexts, contextId);
    if (active == null) return;

    final next = current.copyWith(
      activeContext: active,
      lastUsedContextId: contextId,
      availableContexts:
          applyLastUsedHighlight(current.availableContexts, contextId),
    );
    await _storage.writeLastContextId(contextId);
    state = AsyncData(next);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // No borrar lastContextId: no lleva PII; se revalida en el próximo login.
    state = const AsyncData(SessionState.empty);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email);
  }

  Future<SessionState> _sessionFromAuthUser(AuthUser authUser) async {
    final email = authUser.email;
    final displayName =
        authUser.displayName ?? mockUserDisplayNameForEmail(email);
    final contexts = mockUserContextsForEmail(email);
    final storedId = await _storage.readLastContextId();
    final preferred =
        storedId == null ? null : _findContext(contexts, storedId);

    if (contexts.isEmpty) {
      return SessionState.empty;
    }

    if (contexts.length == 1) {
      final active = contexts.first;
      await _storage.writeLastContextId(active.id);
      return SessionState(
        email: email,
        displayName: displayName,
        availableContexts: applyLastUsedHighlight(contexts, active.id),
        activeContext: active,
        lastUsedContextId: active.id,
      );
    }

    // Multirrol: si el último contextId sigue siendo membresía válida → home.
    if (preferred != null) {
      return SessionState(
        email: email,
        displayName: displayName,
        availableContexts: applyLastUsedHighlight(contexts, preferred.id),
        activeContext: preferred,
        lastUsedContextId: preferred.id,
      );
    }

    final highlightId = _defaultLastUsedId(contexts);
    return SessionState(
      email: email,
      displayName: displayName,
      availableContexts: applyLastUsedHighlight(contexts, highlightId),
      lastUsedContextId: highlightId,
    );
  }

  PostLoginDestination _destinationFor(SessionState session) {
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

/// Contexto activo expuesto para widgets del shell.
final activeContextProvider = Provider<UserAccessContext?>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.activeContext;
});

final sessionDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.displayName;
});

final availableContextsProvider = Provider<List<UserAccessContext>>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.availableContexts ?? const [];
});
