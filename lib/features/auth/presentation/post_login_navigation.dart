import 'package:comunexa/core/router/app_router.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/session/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:comunexa/core/session/session_state.dart'
    show PostLoginDestination;

/// Login → destino según contextos (redirect también reacciona a la sesión).
Future<void> navigateAfterLogin(
  BuildContext context,
  WidgetRef ref, {
  required String email,
  required String password,
}) async {
  final destination =
      await ref.read(sessionProvider.notifier).signInWithPassword(
            email: email,
            password: password,
          );
  if (!context.mounted) return;
  context.go(locationForPostLogin(destination));
}

Future<void> navigateAfterLogout(BuildContext context, WidgetRef ref) async {
  await ref.read(sessionProvider.notifier).signOut();
  if (!context.mounted) return;
  context.go(AppRoutes.login);
}

Future<void> navigateAfterContextSelected(
  BuildContext context,
  WidgetRef ref, {
  required String contextId,
}) async {
  await ref.read(sessionProvider.notifier).selectContext(contextId);
  if (!context.mounted) return;
  context.go(AppRoutes.home);
}
