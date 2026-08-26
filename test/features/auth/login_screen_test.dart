import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });
  testWidgets('login light muestra bienvenida y acciones', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.light,
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
  testWidgets('login oculta Apple fuera de plataformas Apple', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: false),
        ),
      ),
    );

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });
  testWidgets('login muestra Apple cuando la plataforma lo ofrece', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    expect(find.text('Apple'), findsOneWidget);
  });
  testWidgets('login desktop muestra panel hero', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
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
  testWidgets('login tablet portrait light usa hero apilado', (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsNothing);
    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.textContaining('Gestiona tu residencia'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('v1.0.0'), findsNothing);
    expect(find.text('Versión 1.0.0'), findsNothing);

    final title = tester.widget<Text>(find.text('Bienvenido'));
    expect(title.style?.fontSize, 28);

    final brand = tester.widget<Text>(find.text('COMUNEXA'));
    expect(brand.style?.fontSize, 36);
    expect(brand.style?.letterSpacing, 6);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.seedColor);
    expect(forgot.style?.fontSize, 13);
  });
  testWidgets('login tablet portrait dark usa ink y acentos teal', (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsNothing);
    expect(find.text('COMUNEXA'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Bienvenido'));
    expect(title.style?.fontSize, 28);
    expect(title.style?.color, Colors.white);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.accentTeal);
    expect(forgot.style?.fontSize, 13);

    final register = tester.widget<Text>(find.text('Regístrate'));
    expect(register.style?.color, AppTheme.accentTeal);
  });
  testWidgets('login tablet landscape light usa densidad compacta', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
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
    expect(find.text('Bienvenido'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Bienvenido'));
    expect(title.style?.fontSize, 28);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.seedColor);
    expect(forgot.style?.fontSize, 12);
  });
  testWidgets('login tablet landscape dark usa ink y acentos teal', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Bienvenido'));
    expect(title.style?.fontSize, 28);
    expect(title.style?.color, Colors.white);

    final forgot = tester.widget<Text>(
      find.text('¿Olvidaste tu contraseña?'),
    );
    expect(forgot.style?.color, AppTheme.accentTeal);
    expect(forgot.style?.fontSize, 12);

    final register = tester.widget<Text>(find.text('Regístrate'));
    expect(register.style?.color, AppTheme.accentTeal);
  });
  testWidgets('login desktop dark usa panel ink y acentos teal', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
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
  testWidgets('login campos vacíos muestra banner de campos obligatorios',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Iniciar Sesión'));
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(
      find.textContaining('completa todos los campos obligatorios'),
      findsOneWidget,
    );
    expect(find.text('Este campo es obligatorio.'), findsNWidgets(2));
    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsNothing);
  });

  testWidgets('login email/password entra al home', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const TestProviderScope(
        initialLocation: AppRoutes.login,
        child: TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'demo:single@test.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.ensureVisible(find.text('Iniciar Sesión'));
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pumpAndSettle();

    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsOneWidget);
    expect(find.text('Mantenimiento del ascensor'), findsOneWidget);
    expect(find.text('Noticias'), findsOneWidget);
  });

  testWidgets('olvidé contraseña muestra confirmación genérica', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'user@test.com');
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Si el correo existe, recibirás un enlace'),
      findsOneWidget,
    );
  });
  testWidgets('login demo:invalid muestra banner de credenciales', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField).first,
      'demo:invalid@test.com',
    );
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(
      find.textContaining('Correo electrónico o contraseña incorrectos'),
      findsOneWidget,
    );
    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsNothing);
  });
  testWidgets('login demo:empty muestra banner de campos obligatorios', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'demo:empty');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(
      find.textContaining('completa todos los campos obligatorios'),
      findsOneWidget,
    );
    expect(find.text('Este campo es obligatorio.'), findsNWidgets(2));
  });
  testWidgets('Google muestra coming soon', (tester) async {
    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(showAppleSignIn: true),
        ),
      ),
    );

    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(find.text('Disponible Próximamente'), findsOneWidget);
    expect(find.text('Usar Correo Electrónico'), findsOneWidget);
  });
}
