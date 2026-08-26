import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/errors/app_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso tipado al cliente Supabase (anon key + RLS).
///
/// `presentation` no debe usar esto directo: pasar por repositorios `data/`.
abstract final class ComunexaSupabase {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Inicializa solo si `Env.isConfigured`. Sin URL/key, la UI mock sigue viva.
  static Future<void> initialize() async {
    if (_initialized) return;

    if (!Env.isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'ComunexaSupabase: omitido (SUPABASE_URL / SUPABASE_ANON_KEY vacíos)',
        );
      }
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    _initialized = true;
  }

  /// Cliente listo. Lanza si no se llamó [initialize] con credenciales.
  static SupabaseClient get client {
    if (!_initialized) {
      throw const AppException(
        'Supabase no está configurado. Define SUPABASE_URL y SUPABASE_ANON_KEY.',
      );
    }
    return Supabase.instance.client;
  }

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
  }
}
