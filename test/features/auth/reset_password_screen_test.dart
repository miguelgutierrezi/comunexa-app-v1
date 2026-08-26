import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/features/auth/data/fake_access_context_seed.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:comunexa/features/auth/presentation/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('reset password muestra formulario', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const TestProviderScope(
        child: MaterialApp(
          home: ResetPasswordScreen(),
        ),
      ),
    );

    expect(find.text('Nueva contraseña'), findsOneWidget);
    expect(find.text('Guardar contraseña'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('contraseñas distintas muestran error', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const TestProviderScope(
        child: MaterialApp(
          home: ResetPasswordScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'password123');
    await tester.enterText(find.byType(TextField).at(1), 'password456');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });

  testWidgets('recovery completo navega al home', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

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
        initialLocation: AppRoutes.resetPassword,
        child: const TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'newpassword99');
    await tester.enterText(find.byType(TextField).at(1), 'newpassword99');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pumpAndSettle();

    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsOneWidget);
  });
}
