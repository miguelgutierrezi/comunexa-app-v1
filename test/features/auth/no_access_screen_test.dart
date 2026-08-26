import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/data/fake_access_context_seed.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/auth/presentation/no_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('no access light mobile muestra saludo e info', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const NoAccessScreen(userName: 'Carlos Méndez'),
        ),
      ),
    );

    expect(find.text('Hola, Carlos'), findsOneWidget);
    expect(find.text('Aún no tienes acceso'), findsOneWidget);
    expect(find.text('¿Qué puedes hacer?'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(
      find.textContaining('no tienes membresías'),
      findsOneWidget,
    );
  });

  testWidgets('no access dark usa ink y card oscura', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const NoAccessScreen(userName: 'María López'),
        ),
      ),
    );

    expect(find.text('Hola, María'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, María'));
    expect(greeting.style?.color, Colors.white);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('no access desktop light muestra hero y mensaje', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const NoAccessScreen(userName: 'Carlos Méndez'),
        ),
      ),
    );

    expect(find.text('Hola, Carlos'), findsOneWidget);
    expect(find.text('Aún no tienes acceso'), findsOneWidget);
    expect(find.textContaining('COMUN'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('cerrar sesión vuelve al login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

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
        initialLocation: AppRoutes.noAccess,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoAccessScreen), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(NoAccessScreen), findsNothing);
  });
}
