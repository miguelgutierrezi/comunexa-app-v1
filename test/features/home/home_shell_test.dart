import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });
  testWidgets('home shell muestra feed y cambia a placeholder', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.text('Mantenimiento del ascensor'), findsOneWidget);

    await tester.tap(find.text('Zonas'));
    await tester.pumpAndSettle();
    expect(find.text('Próximamente'), findsOneWidget);
  });

  testWidgets('mobile multirrol permite cambiar propiedad desde header',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Torres del Parque'), findsOneWidget);

    await tester.tap(find.text('Torres del Parque'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Parque Empresarial Omega'));
    await tester.pumpAndSettle();

    expect(find.text('Parque Empresarial Omega'), findsOneWidget);
  });

  testWidgets('home desktop light muestra sidebar y eventos', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Carlos Méndez'), findsOneWidget);
    expect(find.text('Reservar Zona Común'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Buscar novedades...'), findsOneWidget);
    expect(find.text('Normativa'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.text('Residente - T. A'), findsOneWidget);
    expect(find.text('Residente · Torre A, Apto 502'), findsOneWidget);
  });

  testWidgets('desktop multirrol permite cambiar propiedad desde sidebar',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Torres del Parque'), findsOneWidget);

    await tester.tap(find.text('Torres del Parque'));
    await tester.pumpAndSettle();

    expect(find.text('Conjunto Residencial Atalia'), findsOneWidget);
    await tester.tap(find.text('Conjunto Residencial Atalia'));
    await tester.pumpAndSettle();

    expect(find.text('Conjunto Residencial Atalia'), findsOneWidget);
  });

  testWidgets('home tablet portrait light muestra feed, eventos y nav',
      (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Buscar novedades...'), findsOneWidget);
    expect(find.text('Mantenimiento del ascensor'), findsOneWidget);
    expect(find.text('Ver todos'), findsOneWidget);
    expect(find.text('Noticias'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.textContaining('COMUN'), findsNothing);
    expect(find.text('Configuración'), findsNothing); // bottom nav, no sidebar

    final title = tester.widget<Text>(find.text('Novedades de la Comunidad'));
    expect(title.style?.fontSize, 24);

    final noticias = tester.widget<Text>(find.text('Noticias'));
    expect(noticias.style?.color, AppTheme.seedColor);
    expect(noticias.style?.fontSize, 11);

    // Sin sidebar desktop: no card de usuario.
    expect(find.text('Carlos Méndez'), findsNothing);

    await tester.tap(find.text('Zonas'));
    await tester.pumpAndSettle();
    expect(find.text('Próximamente'), findsOneWidget);
  });

  testWidgets('home tablet portrait dark usa ink, sky y header card',
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
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Buscar novedades...'), findsOneWidget);
    expect(find.text('Administración'), findsOneWidget);
    expect(find.text('Carlos Méndez'), findsNothing);

    final title = tester.widget<Text>(find.text('Novedades de la Comunidad'));
    expect(title.style?.fontSize, 24);
    expect(title.style?.color, Colors.white);

    final events = tester.widget<Text>(find.text('Próximos Eventos'));
    expect(events.style?.color, Colors.white);

    // Nav activa dark: sky (`#74:117`).
    final noticias = tester.widget<Text>(find.text('Noticias'));
    expect(noticias.style?.color, AppTheme.accentSky);

    final verTodosBtn = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Ver todos'),
    );
    expect(verTodosBtn.style?.foregroundColor?.resolve({}), AppTheme.accentSky);
  });

  testWidgets('tablet portrait multirrol permite cambiar propiedad desde header',
      (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Torres del Parque'), findsOneWidget);

    await tester.tap(find.text('Torres del Parque'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conjunto Residencial Atalia'));
    await tester.pumpAndSettle();

    expect(find.text('Conjunto Residencial Atalia'), findsOneWidget);
  });

  testWidgets('home tablet landscape light muestra sidebar compacto', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Carlos Méndez'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Noticias'), findsWidgets);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.text('Residente - T. A'), findsOneWidget);

    // Densidad tablet: título de top bar a 20 (desktop usa 22).
    final title = tester.widget<Text>(find.text('Novedades de la Comunidad'));
    expect(title.style?.fontSize, 20);
  });
  testWidgets('home tablet landscape dark usa ink, sky y densidad compacta',
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
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Carlos Méndez'), findsOneWidget);
    expect(find.text('Ver todos'), findsOneWidget);
    expect(find.text('Administración'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Novedades de la Comunidad'));
    expect(title.style?.fontSize, 20);
    expect(title.style?.color, Colors.white);

    final events = tester.widget<Text>(find.text('Próximos Eventos'));
    expect(events.style?.color, Colors.white);
    expect(events.style?.fontSize, 15);

    // Nav activa: sky `#38BDF8` (Figma `#35:606`).
    final noticias = tester.widget<Text>(find.text('Noticias').first);
    expect(noticias.style?.color, AppTheme.accentSky);

    final verTodosBtn = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Ver todos'),
    );
    expect(verTodosBtn.style?.foregroundColor?.resolve({}), AppTheme.accentSky);
  });

  testWidgets('tablet landscape multirrol permite cambiar propiedad desde sidebar',
      (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final storage = InMemorySessionStorage();
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-torres-resident',
        lastUsedContextId: 'ctx-torres-resident',
      ),
    );

    await tester.pumpWidget(
      TestProviderScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Torres del Parque'), findsOneWidget);

    await tester.tap(find.text('Torres del Parque'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hotel Boutique Serena'));
    await tester.pumpAndSettle();

    expect(find.text('Hotel Boutique Serena'), findsOneWidget);
    expect(find.text('Recepcionista'), findsNWidgets(2));
  });

  testWidgets('home desktop dark usa panel ink y cards oscuras', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const HomeShellScreen(),
        ),
      ),
    );

    expect(find.text('Novedades de la Comunidad'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Carlos Méndez'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Novedades de la Comunidad'));
    expect(title.style?.color, Colors.white);
    expect(title.style?.fontSize, 22);

    final events = tester.widget<Text>(find.text('Próximos Eventos'));
    expect(events.style?.color, Colors.white);

    final noticias = tester.widget<Text>(find.text('Noticias').first);
    expect(noticias.style?.color, AppTheme.accentSky);
  });
}
