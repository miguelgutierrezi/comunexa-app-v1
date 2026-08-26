import 'package:comunexa/core/errors/app_exception.dart';

/// Fallos de autenticación mapeables a UI.
enum AuthFailureKind {
  invalidCredentials,
  network,
  notConfigured,
  rateLimited,
  unknown,
}

/// Error de dominio Auth (no confundir con `AuthException` de gotrue).
class AuthFailure extends AppException {
  const AuthFailure(
    super.message, {
    required this.kind,
    super.cause,
  });

  final AuthFailureKind kind;

  factory AuthFailure.invalidCredentials([Object? cause]) => AuthFailure(
        'Correo electrónico o contraseña incorrectos. Inténtalo de nuevo.',
        kind: AuthFailureKind.invalidCredentials,
        cause: cause,
      );

  factory AuthFailure.network([Object? cause]) => AuthFailure(
        'Sin conexión. Revisa tu red e inténtalo de nuevo.',
        kind: AuthFailureKind.network,
        cause: cause,
      );

  factory AuthFailure.notConfigured() => const AuthFailure(
        'Supabase no está configurado. Define SUPABASE_URL y SUPABASE_ANON_KEY.',
        kind: AuthFailureKind.notConfigured,
      );

  factory AuthFailure.rateLimited([Object? cause]) => AuthFailure(
        'Demasiados intentos. Espera un momento e inténtalo de nuevo.',
        kind: AuthFailureKind.rateLimited,
        cause: cause,
      );

  factory AuthFailure.unknown([Object? cause]) => AuthFailure(
        'No se pudo completar la autenticación. Inténtalo de nuevo.',
        kind: AuthFailureKind.unknown,
        cause: cause,
      );
}
