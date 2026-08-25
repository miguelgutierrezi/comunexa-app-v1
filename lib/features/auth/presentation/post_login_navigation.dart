import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/features/auth/presentation/context_select_screen.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla inicial tras restaurar sesión (splash).
enum AppStartDestination { login, home, contextSelect }

AppStartDestination resolveAppStartDestination(SessionState session) {
  if (!session.isAuthenticated) return AppStartDestination.login;
  if (session.needsContextSelection) return AppStartDestination.contextSelect;
  if (session.hasActiveContext) return AppStartDestination.home;
  return AppStartDestination.login;
}

void navigateToAppStart(BuildContext context, AppStartDestination destination) {
  final Widget screen = switch (destination) {
    AppStartDestination.login => const LoginScreen(),
    AppStartDestination.home => const HomeShellScreen(),
    AppStartDestination.contextSelect => const ContextSelectScreen(),
  };
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}

Future<void> navigateAfterLogin(
  BuildContext context,
  WidgetRef ref, {
  required String email,
}) async {
  final destination =
      await ref.read(sessionProvider.notifier).signIn(email);
  if (!context.mounted) return;

  final Widget screen = switch (destination) {
    PostLoginDestination.home => const HomeShellScreen(),
    PostLoginDestination.contextSelect => const ContextSelectScreen(),
  };
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}

Future<void> navigateAfterLogout(BuildContext context, WidgetRef ref) async {
  await ref.read(sessionProvider.notifier).signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

Future<void> navigateAfterContextSelected(
  BuildContext context,
  WidgetRef ref, {
  required String contextId,
}) async {
  await ref.read(sessionProvider.notifier).selectContext(contextId);
  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const HomeShellScreen()),
  );
}
