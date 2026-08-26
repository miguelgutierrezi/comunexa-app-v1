import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/core/supabase/comunexa_supabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Resultado del arranque (env, storage, Supabase).
class BootstrapResult {
  const BootstrapResult({
    required this.sessionStorage,
    required this.supabaseReady,
  });

  final SessionStorage sessionStorage;
  final bool supabaseReady;
}

/// Carga env, storage de sesión e inicializa Supabase si hay credenciales.
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  final sessionStorage = await SharedPreferencesSessionStorage.create();
  await ComunexaSupabase.initialize();

  if (kDebugMode) {
    debugPrint(
      'Bootstrap: APP_ENV=${Env.appEnv} '
      'supabaseReady=${ComunexaSupabase.isInitialized} '
      'firebaseProjectId=${Env.firebaseProjectId}',
    );
  }

  return BootstrapResult(
    sessionStorage: sessionStorage,
    supabaseReady: ComunexaSupabase.isInitialized,
  );
}
