import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/presentation/context_select_screen.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/home/presentation/add_news_screen.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('sesión activa: splash → /home', (tester) async {
    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );
    final auth = FakeAuthRepository(
      seed: const AuthUser(
        id: 'u1',
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

  testWidgets('multirrol sin contexto: splash → /select-context', (tester) async {
    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );
    final auth = FakeAuthRepository(
      seed: const AuthUser(
        id: 'u2',
        email: 'demo:multi@test.com',
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

    expect(find.byType(ContextSelectScreen), findsOneWidget);
    expect(find.text('Selecciona a dónde quieres acceder'), findsOneWidget);
  });

  testWidgets('/news/new con sesión abre añadir noticia', (tester) async {
    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        initialLocation: AppRoutes.newsNew,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddNewsScreen), findsOneWidget);
    expect(find.text('Añadir noticia'), findsOneWidget);
  });
}
