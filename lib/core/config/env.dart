import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de entorno.
///
/// Prioridad: valores de `.env` (flutter_dotenv) → `--dart-define` / `--dart-define-from-file`.
abstract final class Env {
  static String get appEnv => _read('APP_ENV', defaultValue: 'development');

  static String get supabaseUrl => _read('SUPABASE_URL');

  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  static String get firebaseProjectId => _read('FIREBASE_PROJECT_ID');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Carga `.env` (local). Si no existe, intenta `.env.example`.
  /// En CI se genera `.env` antes del build (ver `web.yml`).
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      await dotenv.load(fileName: '.env.example', isOptional: true);
    }
  }

  static String _read(String key, {String defaultValue = ''}) {
    final fromDotenv = dotenv.isInitialized
        ? dotenv.maybeGet(key)?.trim()
        : null;
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return String.fromEnvironment(key, defaultValue: defaultValue);
  }
}
