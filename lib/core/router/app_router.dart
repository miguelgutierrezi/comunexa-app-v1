import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/features/auth/presentation/context_select_screen.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/home/presentation/add_news_screen.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:comunexa/features/splash/presentation/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Delay mínimo del splash (override a [Duration.zero] en tests).
final splashMinDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1200),
);

/// Splash listo cuando pasó el delay y la sesión terminó de restaurar.
final splashReadyProvider = FutureProvider<bool>((ref) async {
  await Future<void>.delayed(ref.watch(splashMinDelayProvider));
  await ref.watch(sessionProvider.future);
  return true;
});

/// Notifica a [GoRouter] cuando cambian sesión o splash.
class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(splashReadyProvider, (_, _) => notifyListeners());
  }
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return refresh;
});

/// Crea el router (tests pueden fijar [initialLocation]).
GoRouter createAppRouter(
  Ref ref, {
  String initialLocation = AppRoutes.splash,
}) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectContext,
        builder: (context, state) => const ContextSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsNew,
        builder: (context, state) => const AddNewsScreen(),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => createAppRouter(ref));

String? _redirect(Ref ref, GoRouterState state) {
  final loc = state.matchedLocation;
  final splashReady = ref.read(splashReadyProvider);
  final sessionAsync = ref.read(sessionProvider);
  final session = sessionAsync.valueOrNull ?? SessionState.empty;

  // Splash solo en `/`: espera delay + restore, luego destino por sesión.
  if (loc == AppRoutes.splash) {
    if (!splashReady.hasValue || sessionAsync.isLoading) return null;
    return locationForAppStart(session);
  }

  // Deep links: esperar restore sin saltar a splash.
  if (sessionAsync.isLoading) return null;

  if (!session.isAuthenticated) {
    if (loc == AppRoutes.login) return null;
    return AppRoutes.login;
  }

  if (session.needsContextSelection) {
    if (loc == AppRoutes.selectContext) return null;
    return AppRoutes.selectContext;
  }

  if (session.hasActiveContext) {
    if (loc == AppRoutes.login || loc == AppRoutes.selectContext) {
      return AppRoutes.home;
    }
    return null;
  }

  return AppRoutes.login;
}

/// Destino post-login (también usado por SessionNotifier).
String locationForPostLogin(PostLoginDestination destination) {
  return switch (destination) {
    PostLoginDestination.home => AppRoutes.home,
    PostLoginDestination.contextSelect => AppRoutes.selectContext,
  };
}

String locationForAppStart(SessionState session) {
  if (!session.isAuthenticated) return AppRoutes.login;
  if (session.needsContextSelection) return AppRoutes.selectContext;
  if (session.hasActiveContext) return AppRoutes.home;
  return AppRoutes.login;
}
