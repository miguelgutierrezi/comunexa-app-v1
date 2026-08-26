import 'package:comunexa/features/auth/domain/user_access_context.dart';

/// Destino tras autenticación (email/password).
enum PostLoginDestination {
  home,
  contextSelect,
  noAccess,
  resetPassword,
}

/// Sesión de usuario: correo, contextos disponibles y propiedad/rol activo.
class SessionState {
  const SessionState({
    this.email,
    this.displayName,
    this.availableContexts = const [],
    this.activeContext,
    this.lastUsedContextId,
    this.pendingPasswordRecovery = false,
  });

  final String? email;
  final String? displayName;
  final List<UserAccessContext> availableContexts;
  final UserAccessContext? activeContext;
  final String? lastUsedContextId;

  /// Deep link recovery: JWT válido pero falta definir nueva contraseña.
  final bool pendingPasswordRecovery;

  static const empty = SessionState();

  bool get isAuthenticated => email != null && email!.isNotEmpty;

  bool get hasActiveContext => activeContext != null;

  bool get needsContextSelection =>
      isAuthenticated && !hasActiveContext && availableContexts.length > 1;

  /// Autenticado en Auth pero sin membresías activas válidas.
  bool get authenticatedWithoutAccess =>
      isAuthenticated &&
      !pendingPasswordRecovery &&
      availableContexts.isEmpty;

  /// Flujo recovery: autenticado temporalmente hasta [updatePassword].
  bool get needsPasswordRecovery =>
      isAuthenticated && pendingPasswordRecovery;

  SessionState copyWith({
    String? email,
    String? displayName,
    List<UserAccessContext>? availableContexts,
    UserAccessContext? activeContext,
    String? lastUsedContextId,
    bool? pendingPasswordRecovery,
    bool clearActiveContext = false,
  }) {
    return SessionState(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      availableContexts: availableContexts ?? this.availableContexts,
      activeContext:
          clearActiveContext ? null : (activeContext ?? this.activeContext),
      lastUsedContextId: lastUsedContextId ?? this.lastUsedContextId,
      pendingPasswordRecovery:
          pendingPasswordRecovery ?? this.pendingPasswordRecovery,
    );
  }
}
