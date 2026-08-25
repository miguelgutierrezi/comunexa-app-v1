/// Smoke tests de pantallas viven en `test/features/`.
/// Este archivo mantiene un entrypoint mínimo para el template Flutter.
library;

import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('login smoke mínimo en viewport móvil', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: false),
        ),
      ),
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
