import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('login light muestra bienvenida y acciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.light,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('login desktop muestra panel hero', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.textContaining('Gestiona tu residencia'), findsOneWidget);
    expect(find.text('© 2026 Comunexa Inc.'), findsOneWidget);
    expect(find.text('Versión 1.0.0'), findsOneWidget);
  });

  testWidgets('login tablet landscape light usa densidad compacta', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.textContaining('Gestiona tu residencia'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Bienvenido de nuevo'));
    expect(title.style?.fontSize, 28);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.seedColor);
    expect(forgot.style?.fontSize, 12);
  });

  testWidgets('login desktop dark usa panel ink y acentos teal', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.textContaining('Gestiona tu residencia'), findsOneWidget);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.accentTeal);

    final register = tester.widget<Text>(find.text('Regístrate'));
    expect(register.style?.color, AppTheme.accentTeal);
  });
}
