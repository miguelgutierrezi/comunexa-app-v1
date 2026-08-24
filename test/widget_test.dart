import 'package:comunexa/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de splash de Comunexa', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ComunexaApp()),
    );

    expect(find.text('Comunexa'), findsOneWidget);
    expect(
      find.text('Conecta administradoras con sus comunidades'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
