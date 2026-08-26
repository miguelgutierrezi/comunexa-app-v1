import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencia local: solo el último contextId elegido.
///
/// **No** es autoridad de sesión: correo, rol y membresías vienen de Auth + backend.
abstract class SessionStorage {
  Future<String?> readLastContextId();

  Future<void> writeLastContextId(String contextId);

  Future<void> clear();
}

class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._prefs);

  /// Clave nueva (solo id). La v1 con email/displayName se migra y elimina.
  static const _key = 'comunexa.last_context_id.v1';
  static const _legacyKey = 'comunexa.session.v1';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesSessionStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SharedPreferencesSessionStorage(prefs);
    await storage._migrateLegacyIfNeeded();
    return storage;
  }

  Future<void> _migrateLegacyIfNeeded() async {
    final legacy = _prefs.getString(_legacyKey);
    if (legacy == null || legacy.isEmpty) return;

    if (!_prefs.containsKey(_key)) {
      try {
        final map = jsonDecode(legacy) as Map<String, dynamic>;
        final preferred = (map['activeContextId'] as String?) ??
            (map['lastUsedContextId'] as String?);
        if (preferred != null && preferred.trim().isNotEmpty) {
          await _prefs.setString(_key, preferred.trim());
        }
      } catch (_) {
        // Ignorar JSON legacy inválido.
      }
    }
    await _prefs.remove(_legacyKey);
  }

  @override
  Future<String?> readLastContextId() async {
    final value = _prefs.getString(_key);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  @override
  Future<void> writeLastContextId(String contextId) async {
    final trimmed = contextId.trim();
    if (trimmed.isEmpty) {
      await clear();
      return;
    }
    await _prefs.setString(_key, trimmed);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
    await _prefs.remove(_legacyKey);
  }
}

/// Almacenamiento en memoria para tests.
class InMemorySessionStorage implements SessionStorage {
  String? _lastContextId;

  String? get current => _lastContextId;

  @override
  Future<void> clear() async {
    _lastContextId = null;
  }

  @override
  Future<String?> readLastContextId() async => _lastContextId;

  @override
  Future<void> writeLastContextId(String contextId) async {
    final trimmed = contextId.trim();
    _lastContextId = trimmed.isEmpty ? null : trimmed;
  }
}

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError(
    'sessionStorageProvider debe sobreescribirse en main/tests',
  );
});
