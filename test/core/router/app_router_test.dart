import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/fake_access_context_seed.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/presentation/context_select_screen.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/auth/presentation/no_access_screen.dart';
import 'package:comunexa/features/auth/presentation/reset_password_screen.dart';
import 'package:comunexa/features/home/presentation/add_news_screen.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('sesión activa: splash → /home', (tester) async {
    final storage = InMemorySessionStorage();
    await storage.writeLastContextId('ctx-torres-resident');
    final auth = FakeAuthRepository(
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:single@test.com'),
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        auth: auth,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeShellScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('multirrol sin lastContextId: splash → /select-context',
      (tester) async {
    final auth = FakeAuthRepository(
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:multi@test.com'),
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        auth: auth,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ContextSelectScreen), findsOneWidget);
    expect(find.text('Selecciona a dónde quieres acceder'), findsOneWidget);
  });

  testWidgets('/news/new con sesión abre añadir noticia', (tester) async {
    final storage = InMemorySessionStorage();
    await storage.writeLastContextId('ctx-torres-resident');
    final auth = FakeAuthRepository(
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:single@test.com'),
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        auth: auth,
        initialLocation: AppRoutes.newsNew,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddNewsScreen), findsOneWidget);
    expect(find.text('Añadir noticia'), findsOneWidget);
  });

  testWidgets('sin membresías: splash → /no-access', (tester) async {
    final auth = FakeAuthRepository(
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:noaccess@test.com'),
        email: 'demo:noaccess@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        auth: auth,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.text('Aún no tienes acceso'), findsOneWidget);
    expect(find.byType(HomeShellScreen), findsNothing);
  });

  testWidgets('sin membresías: /home redirige a /no-access', (tester) async {
    final auth = FakeAuthRepository(
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:noaccess@test.com'),
        email: 'demo:noaccess@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        auth: auth,
        initialLocation: AppRoutes.home,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.byType(HomeShellScreen), findsNothing);
  });

  testWidgets('recovery pendiente: splash → /reset-password', (tester) async {
    final auth = FakeAuthRepository(
      pendingPasswordRecovery: true,
      seed: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:single@test.com'),
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        auth: auth,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(find.byType(HomeShellScreen), findsNothing);
  });

  testWidgets('recovery pendiente: /home redirige a /reset-password',
      (tester) async {
    final auth = FakeAuthRepository(
      pendingPasswordRecovery: true,
      seed: const AuthUser(
        id: 'u-recovery',
        email: 'recovery@test.com',
        displayName: 'Recovery User',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        auth: auth,
        initialLocation: AppRoutes.home,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(find.byType(HomeShellScreen), findsNothing);
  });
}
