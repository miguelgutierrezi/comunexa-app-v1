import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';

/// URL de retorno para el correo de recuperación de contraseña.
///
/// Prioridad: `AUTH_REDIRECT_URL` en `.env` → origen web + `/reset-password`.
String authPasswordResetRedirectUrl() {
  final fromEnv = Env.authRedirectUrl;
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) {
    final base = Uri.base;
    if (base.hasScheme && base.host.isNotEmpty) {
      return '${base.origin}${AppRoutes.resetPassword}';
    }
  }

  // Placeholder para deep links móviles (Fase posterior).
  return 'comunexa://reset-password';
}
