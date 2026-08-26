import 'package:comunexa/features/auth/domain/user_access_context.dart';

/// Destino tras autenticación (email/password).
enum PostLoginDestination { home, contextSelect }

/// Sesión de usuario: correo, contextos disponibles y propiedad/rol activo.
class SessionState {
  const SessionState({
    this.email,
    this.displayName,
    this.availableContexts = const [],
    this.activeContext,
    this.lastUsedContextId,
  });

  final String? email;
  final String? displayName;
  final List<UserAccessContext> availableContexts;
  final UserAccessContext? activeContext;
  final String? lastUsedContextId;

  static const empty = SessionState();

  bool get isAuthenticated => email != null && email!.isNotEmpty;

  bool get hasActiveContext => activeContext != null;

  bool get needsContextSelection =>
      isAuthenticated && !hasActiveContext && availableContexts.length > 1;

  SessionState copyWith({
    String? email,
    String? displayName,
    List<UserAccessContext>? availableContexts,
    UserAccessContext? activeContext,
    String? lastUsedContextId,
    bool clearActiveContext = false,
  }) {
    return SessionState(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      availableContexts: availableContexts ?? this.availableContexts,
      activeContext:
          clearActiveContext ? null : (activeContext ?? this.activeContext),
      lastUsedContextId: lastUsedContextId ?? this.lastUsedContextId,
    );
  }
}
