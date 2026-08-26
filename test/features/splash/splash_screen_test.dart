import '../../helpers/test_provider_scope.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('splash light móvil muestra marca Figma #118:5', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('UN EDIFICIO, UNA COMUNIDAD, UNA SOLA APP'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientLight,
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.bgLight);

    // Avanza el delay mínimo + sesión vacía → login.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash dark móvil usa ink y símbolo Figma #118:27',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('UN EDIFICIO, UNA COMUNIDAD, UNA SOLA APP'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientDark,
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash desktop light muestra marca Figma #118:73',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );
    expect(
      find.text('UN EDIFICIO, UNA COMUNIDAD, UNA SOLA APP'),
      findsNothing,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientLight,
    );
    expect(svg.width, 140);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, Colors.white);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash desktop dark usa ink Figma #118:84', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientDark,
    );
    expect(svg.width, 140);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash tablet landscape light Figma #118:95', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientLight,
    );
    expect(svg.width, 120);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, Colors.white);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash tablet landscape dark Figma #118:106', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientDark,
    );
    expect(svg.width, 120);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash tablet portrait light Figma #118:117', (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientLight,
    );
    expect(svg.width, 110);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, Colors.white);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('splash tablet portrait dark Figma #118:128', (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TestProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('COMUNEXA'), findsOneWidget);
    expect(
      find.text('Un edificio, una comunidad, una sola app'),
      findsOneWidget,
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      BrandAssets.symbolGradientDark,
    );
    expect(svg.width, 110);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.ink);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
