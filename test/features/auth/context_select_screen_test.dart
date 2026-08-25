import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/presentation/context_select_screen.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('context select light muestra saludo y propiedades', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('Hola, Carlos'), findsOneWidget);
    expect(find.text('Selecciona a dónde quieres acceder'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.text('Conjunto Residencial Atalia'), findsOneWidget);
    expect(find.text('Hotel Boutique Serena'), findsOneWidget);
    expect(find.text('Parque Empresarial Omega'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 24);
    expect(greeting.style?.fontWeight, FontWeight.w800);
    expect(greeting.style?.color, AppTheme.ink);
  });

  testWidgets('context select dark usa ink, teal en card activa y textos claros',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('Hola, Carlos'), findsOneWidget);
    expect(find.text('Selecciona a dónde quieres acceder'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.color, Colors.white);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.color, AppTheme.slateLight);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 1.5);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('context select resalta último contexto usado', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    // Torres del Parque tiene isLastUsed → borde activo (Material shape).
    final torres = find.ancestor(
      of: find.text('Torres del Parque'),
      matching: find.byType(Material),
    );
    expect(torres, findsWidgets);
  });

  testWidgets('context select navega al home al elegir propiedad', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Conjunto Residencial Atalia'));
    await tester.pumpAndSettle();

    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsOneWidget);
    expect(find.text('Hola, Carlos'), findsNothing);
  });

  testWidgets('context select cerrar sesión vuelve al login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsNothing);
  });

  testWidgets('context select desktop light usa hero y card activa teal',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.text('Versión ${LoginScreen.appVersion}'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.fontWeight, FontWeight.w800);
    expect(greeting.style?.color, AppTheme.ink);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.fontSize, 16);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 2);
  });

  testWidgets('context select tablet landscape light usa hero y card activa teal',
      (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.textContaining('v${LoginScreen.appVersion}'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.fontWeight, FontWeight.w800);
    expect(greeting.style?.color, AppTheme.ink);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 2);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.bgLight);
  });

  testWidgets('context select tablet landscape dark usa hero, ink y card activa teal',
      (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);
    expect(find.textContaining('v${LoginScreen.appVersion}'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.color, Colors.white);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.color, AppTheme.slateLight);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 2);
    expect(torresMaterial.color, AppTheme.cardDark);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('context select desktop dark usa hero, ink y card activa teal',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(find.text('SECURE ENTERPRISE LOGIN'), findsOneWidget);

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.color, Colors.white);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.color, AppTheme.slateLight);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 2);
    expect(torresMaterial.color, AppTheme.cardDark);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('context select tablet portrait light usa cards amplias y seed blue',
      (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.color, AppTheme.ink);
    expect(greeting.textAlign, TextAlign.center);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.fontSize, 18);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.seedColor);
    expect(shape.side.width, 2);
    expect(shape.borderRadius.resolve(TextDirection.ltr).topLeft.x, 16);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.bgLight);
  });

  testWidgets('context select tablet portrait dark usa cards amplias y teal',
      (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: ContextSelectScreen(
            userName: 'Carlos Méndez',
            contexts: mockMultipleContexts,
          ),
        ),
      ),
    );

    final greeting = tester.widget<Text>(find.text('Hola, Carlos'));
    expect(greeting.style?.fontSize, 32);
    expect(greeting.style?.color, Colors.white);

    final subtitle = tester.widget<Text>(
      find.text('Selecciona a dónde quieres acceder'),
    );
    expect(subtitle.style?.fontSize, 18);
    expect(subtitle.style?.color, AppTheme.slateLight);

    final torresMaterial = tester.widget<Material>(
      find.ancestor(
        of: find.text('Torres del Parque'),
        matching: find.byType(Material),
      ).first,
    );
    final shape = torresMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppTheme.accentTeal);
    expect(shape.side.width, 2);
    expect(torresMaterial.color, AppTheme.cardDark);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('login demo:multi muestra selector de contexto', (tester) async {
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

    await tester.enterText(find.byType(TextField).first, 'demo:multi@test.com');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona a dónde quieres acceder'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.textContaining('NOVEDADES DE LA COMUNIDAD'), findsNothing);
  });
}
