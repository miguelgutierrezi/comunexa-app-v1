import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionNotifier extends AsyncNotifier<SessionState> {
  SessionStorage get _storage => ref.read(sessionStorageProvider);

  @override
  Future<SessionState> build() => _restore();

  Future<SessionState> _restore() async {
    final snapshot = await _storage.read();
    if (snapshot == null) return SessionState.empty;

    final contexts = mockUserContextsForEmail(snapshot.email);
    if (contexts.isEmpty) {
      await _storage.clear();
      return SessionState.empty;
    }

    final lastUsedId = snapshot.lastUsedContextId ??
        snapshot.activeContextId ??
        _defaultLastUsedId(contexts);

    UserAccessContext? active;
    if (snapshot.activeContextId != null) {
      active = _findContext(contexts, snapshot.activeContextId!);
    } else if (contexts.length == 1) {
      active = contexts.first;
    }

    if (active == null && contexts.length == 1) {
      active = contexts.first;
    }

    return SessionState(
      email: snapshot.email,
      displayName: snapshot.displayName,
      availableContexts: applyLastUsedHighlight(contexts, lastUsedId),
      activeContext: active,
      lastUsedContextId: lastUsedId,
    );
  }

  Future<PostLoginDestination> signIn(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();
    final displayName = mockUserDisplayNameForEmail(email);
    final contexts = mockUserContextsForEmail(email);
    final snapshot = await _storage.read();

    final lastUsedId = snapshot?.email == email
        ? (snapshot?.lastUsedContextId ??
            snapshot?.activeContextId ??
            _defaultLastUsedId(contexts))
        : _defaultLastUsedId(contexts);

    if (contexts.length <= 1) {
      final active = contexts.first;
      final next = SessionState(
        email: email,
        displayName: displayName,
        availableContexts: applyLastUsedHighlight(contexts, active.id),
        activeContext: active,
        lastUsedContextId: active.id,
      );
      await _persist(next);
      state = AsyncData(next);
      return PostLoginDestination.home;
    }

    if (snapshot?.email == email && snapshot?.activeContextId != null) {
      final active = _findContext(contexts, snapshot!.activeContextId!);
      if (active != null) {
        final next = SessionState(
          email: email,
          displayName: displayName,
          availableContexts: applyLastUsedHighlight(contexts, lastUsedId),
          activeContext: active,
          lastUsedContextId: lastUsedId,
        );
        await _persist(next);
        state = AsyncData(next);
        return PostLoginDestination.home;
      }
    }

    final pending = SessionState(
      email: email,
      displayName: displayName,
      availableContexts: applyLastUsedHighlight(contexts, lastUsedId),
      lastUsedContextId: lastUsedId,
    );
    await _persist(pending, persistActive: false);
    state = AsyncData(pending);
    return PostLoginDestination.contextSelect;
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
    await _persist(next);
    state = AsyncData(next);
  }

  Future<void> signOut() async {
    await _storage.clear();
    state = const AsyncData(SessionState.empty);
  }

  Future<void> _persist(
    SessionState session, {
    bool persistActive = true,
  }) async {
    final email = session.email;
    final displayName = session.displayName;
    if (email == null || displayName == null) return;

    await _storage.write(
      SessionSnapshot(
        email: email,
        displayName: displayName,
        activeContextId:
            persistActive ? session.activeContext?.id : null,
        lastUsedContextId: session.lastUsedContextId,
      ),
    );
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
