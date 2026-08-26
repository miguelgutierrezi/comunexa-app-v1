import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/home/presentation/add_news_screen.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  Future<void> pumpAddNews(
    WidgetTester tester, {
    ThemeData? theme,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: const AddNewsScreen(),
        ),
      ),
    );
  }

  Future<void> revealPublishButton(WidgetTester tester) async {
    final publish = find.text('Publicar noticia');
    await tester.scrollUntilVisible(
      publish,
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(publish);
    await tester.pumpAndSettle();
  }

  testWidgets('add news mobile light muestra formulario Figma #112:5',
      (tester) async {
    await pumpAddNews(tester);

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('TÍTULO'), findsOneWidget);
    expect(find.text('EDIFICIO'), findsOneWidget);
    expect(find.text('CATEGORÍA'), findsOneWidget);
    expect(find.text('DESCRIPCIÓN'), findsOneWidget);
    expect(find.text('FECHA DE PUBLICACIÓN'), findsOneWidget);
    expect(find.text('ARCHIVOS ADJUNTOS'), findsOneWidget);
    expect(find.text('Administración'), findsOneWidget);
    expect(find.text('Evento'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.text('Normativa'), findsOneWidget);
    expect(find.text('Torres del Parque'), findsOneWidget);
    expect(find.text('24 de Agosto, 2026'), findsOneWidget);
    expect(find.text('comunicado.pdf'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
    expect(
      find.text('Escribe un título claro y conciso...'),
      findsOneWidget,
    );
  });

  testWidgets('add news mobile dark muestra formulario Figma #112:86',
      (tester) async {
    await pumpAddNews(tester, theme: AppTheme.dark());

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsOneWidget);
    expect(find.text('comunicado.pdf'), findsOneWidget);
    expect(find.text('Administración'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('add news desktop light muestra card y sidebar Figma #112:217',
      (tester) async {
    await pumpAddNews(tester, size: const Size(1440, 900));

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.textContaining('COMUN'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Arrastra o selecciona archivos'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsNothing);
    expect(find.text('comunicado.pdf'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
  });

  testWidgets('add news desktop dark usa ink y chrome Figma #112:317',
      (tester) async {
    await pumpAddNews(
      tester,
      theme: AppTheme.dark(),
      size: const Size(1440, 900),
    );

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Arrastra o selecciona archivos'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('add news tablet landscape light muestra card Figma #114:8',
      (tester) async {
    await pumpAddNews(tester, size: const Size(1194, 834));

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Arrastra o selecciona archivos'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsNothing);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
  });

  testWidgets('add news tablet landscape dark usa ink Figma #114:107',
      (tester) async {
    await pumpAddNews(
      tester,
      theme: AppTheme.dark(),
      size: const Size(1194, 834),
    );

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Arrastra o selecciona archivos'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('add news tablet portrait light muestra form Figma #116:5',
      (tester) async {
    await pumpAddNews(tester, size: const Size(834, 1194));

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsOneWidget);
    expect(find.text('Arrastra o selecciona archivos'), findsNothing);
    expect(find.text('Configuración'), findsNothing);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
  });

  testWidgets('add news tablet portrait dark usa ink Figma #116:92',
      (tester) async {
    await pumpAddNews(
      tester,
      theme: AppTheme.dark(),
      size: const Size(834, 1194),
    );

    expect(find.text('Añadir noticia'), findsOneWidget);
    expect(find.text('Selecciona archivos'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);
  });

  testWidgets('add news publicar sin título muestra snackbar', (tester) async {
    await pumpAddNews(tester);
    await revealPublishButton(tester);

    await tester.tap(find.text('Publicar noticia'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un título para la noticia'), findsOneWidget);
  });

  testWidgets('add news publicar con título muestra próximamente',
      (tester) async {
    await pumpAddNews(tester);

    await tester.enterText(
      find.byType(TextField).first,
      'Mantenimiento del ascensor',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await revealPublishButton(tester);
    await tester.tap(find.text('Publicar noticia'));
    await tester.pumpAndSettle();
    expect(find.text('Publicar noticia — próximamente'), findsOneWidget);
  });

  testWidgets('home móvil abre add news desde FAB', (tester) async {
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

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Añadir noticia'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
  });

  testWidgets('home desktop abre add news desde CTA', (tester) async {
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

    expect(find.text('Añadir noticia'), findsOneWidget);
    await tester.tap(find.text('Añadir noticia'));
    await tester.pumpAndSettle();
    expect(find.text('Arrastra o selecciona archivos'), findsOneWidget);
    await revealPublishButton(tester);
    expect(find.text('Publicar noticia'), findsOneWidget);
  });
}
