import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/errors/app_exception.dart';
import 'package:comunexa/core/supabase/comunexa_supabase.dart';
import 'package:comunexa/core/supabase/supabase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ComunexaSupabase.resetForTest();
  });

  tearDown(() {
    ComunexaSupabase.resetForTest();
  });

  test('initialize sin credenciales no marca ready', () async {
    await Env.load();
    // .env.example / CI suelen dejar URL y key vacíos.
    if (Env.isConfigured) {
      // Entorno local con .env real: no forzar este caso.
      return;
    }

    await ComunexaSupabase.initialize();
    expect(ComunexaSupabase.isInitialized, isFalse);
    expect(
      () => ComunexaSupabase.client,
      throwsA(isA<AppException>()),
    );
  });

  test('supabaseClientProvider es null si no hay init', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(supabaseClientProvider), isNull);
  });
}
