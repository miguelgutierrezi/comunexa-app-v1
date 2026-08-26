import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_router.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/data/access_context_repository_provider.dart';
import 'package:comunexa/features/auth/data/auth_repository_provider.dart';
import 'package:comunexa/features/auth/data/fake_access_context_repository.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scope de tests: sesión en memoria + [FakeAuthRepository].
///
/// La autoridad de identidad es [auth]; [storage] solo guarda lastContextId.
class TestProviderScope extends StatelessWidget {
  const TestProviderScope({
    super.key,
    required this.child,
    this.storage,
    this.auth,
    this.accessContexts,
    this.splashDelay = Duration.zero,
    this.initialLocation,
  });

  final Widget child;
  final SessionStorage? storage;
  final FakeAuthRepository? auth;
  final FakeAccessContextRepository? accessContexts;

  /// Delay del splash (cero en tests).
  final Duration splashDelay;

  /// Si no es null, sobreescribe [routerProvider] con esta ruta inicial.
  final String? initialLocation;

  @override
  Widget build(BuildContext context) {
    final sessionStorage = storage ?? InMemorySessionStorage();
    final authRepo = auth ?? FakeAuthRepository();
    final accessRepo = accessContexts ?? FakeAccessContextRepository();

    return ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(sessionStorage),
        authRepositoryProvider.overrideWithValue(authRepo),
        accessContextRepositoryProvider.overrideWithValue(accessRepo),
        splashMinDelayProvider.overrideWithValue(splashDelay),
        if (initialLocation != null)
          routerProvider.overrideWith(
            (ref) => createAppRouter(ref, initialLocation: initialLocation!),
          ),
      ],
      child: child,
    );
  }
}

/// [MaterialApp.router] con el [routerProvider] del scope.
class TestRouterApp extends ConsumerWidget {
  const TestRouterApp({
    super.key,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.light,
  });

  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: theme ?? AppTheme.light(),
      darkTheme: darkTheme ?? AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

Future<void> initTestEnv() async {
  await Env.load();
}
