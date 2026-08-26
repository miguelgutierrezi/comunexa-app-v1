import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/presentation/login_alerts.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resultado de validación previa al submit (demos Figma o campos vacíos).
sealed class LoginValidationResult {
  const LoginValidationResult();
}

class LoginValidationProceed extends LoginValidationResult {
  const LoginValidationProceed(this.email, this.password);

  final String email;
  final String password;
}

class LoginValidationShowAlert extends LoginValidationResult {
  const LoginValidationShowAlert(this.alert);

  final LoginAlertKind alert;
}

class LoginValidationShowLocked extends LoginValidationResult {
  const LoginValidationShowLocked();
}

class LoginValidationShowOffline extends LoginValidationResult {
  const LoginValidationShowOffline();
}

LoginValidationResult validateLoginInput({
  required String email,
  required String password,
}) {
  if (email.startsWith('demo:locked')) {
    return const LoginValidationShowLocked();
  }
  if (email.startsWith('demo:offline')) {
    return const LoginValidationShowOffline();
  }
  if (email.startsWith('demo:invalid')) {
    return const LoginValidationShowAlert(LoginAlertKind.invalidCredentials);
  }
  if (email.startsWith('demo:empty')) {
    return const LoginValidationShowAlert(LoginAlertKind.emptyFields);
  }
  if (email.isEmpty || password.isEmpty) {
    return const LoginValidationShowAlert(LoginAlertKind.emptyFields);
  }
  return LoginValidationProceed(email, password);
}

Future<void> submitLogin({
  required BuildContext context,
  required WidgetRef ref,
  required String email,
  required String password,
}) async {
  await navigateAfterLogin(
    context,
    ref,
    email: email,
    password: password,
  );
}

Future<void> handleAuthFailure({
  required BuildContext context,
  required AuthFailure failure,
  required void Function(LoginAlertKind alert) onFormAlert,
  required VoidCallback onRetrySubmit,
}) async {
  switch (failure.kind) {
    case AuthFailureKind.invalidCredentials:
      onFormAlert(LoginAlertKind.invalidCredentials);
    case AuthFailureKind.network:
      showNetworkErrorToast(context, onRetry: onRetrySubmit);
    case AuthFailureKind.notConfigured:
    case AuthFailureKind.rateLimited:
    case AuthFailureKind.unknown:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
  }
}

Future<void> sendForgotPassword({
  required BuildContext context,
  required WidgetRef ref,
  required String email,
  required void Function(LoginAlertKind alert) onFormAlert,
  required VoidCallback onRetrySubmit,
}) async {
  if (email.isEmpty || email.startsWith('demo:')) {
    onFormAlert(LoginAlertKind.emptyFields);
    return;
  }

  try {
    await ref.read(sessionProvider.notifier).sendPasswordResetEmail(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si el correo existe, recibirás un enlace para restablecer tu contraseña.',
        ),
      ),
    );
  } on AuthFailure catch (e) {
    if (!context.mounted) return;
    await handleAuthFailure(
      context: context,
      failure: e,
      onFormAlert: onFormAlert,
      onRetrySubmit: onRetrySubmit,
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo enviar el correo de recuperación.'),
      ),
    );
  }
}

void showSocialComingSoon(BuildContext context) {
  showComingSoonDialog(context);
}

void showLoginComingSoon(BuildContext context, String label) {
  if (label.contains('Google') || label.contains('Apple')) {
    showSocialComingSoon(context);
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label — próximamente')),
  );
}
