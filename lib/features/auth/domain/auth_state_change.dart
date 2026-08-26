import 'package:comunexa/features/auth/domain/auth_user.dart';

/// Eventos de sesión Auth relevantes para la app (Supabase GoTrue).
enum AuthSessionEvent {
  initialSession,
  signedIn,
  signedOut,
  tokenRefreshed,
  passwordRecovery,
  userUpdated,
}

class AuthStateChange {
  const AuthStateChange({
    required this.event,
    this.user,
  });

  final AuthSessionEvent event;
  final AuthUser? user;
}
