import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Datos serializables de sesión en disco.
class SessionSnapshot {
  const SessionSnapshot({
    required this.email,
    required this.displayName,
    this.activeContextId,
    this.lastUsedContextId,
  });

  final String email;
  final String displayName;
  final String? activeContextId;
  final String? lastUsedContextId;

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        if (activeContextId != null) 'activeContextId': activeContextId,
        if (lastUsedContextId != null) 'lastUsedContextId': lastUsedContextId,
      };

  factory SessionSnapshot.fromJson(Map<String, dynamic> json) {
    return SessionSnapshot(
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      activeContextId: json['activeContextId'] as String?,
      lastUsedContextId: json['lastUsedContextId'] as String?,
    );
  }
}

abstract class SessionStorage {
  Future<SessionSnapshot?> read();

  Future<void> write(SessionSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._prefs);

  static const _key = 'comunexa.session.v1';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesSessionStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesSessionStorage(prefs);
  }

  @override
  Future<SessionSnapshot?> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SessionSnapshot.fromJson(map);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(SessionSnapshot snapshot) async {
    await _prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}

/// Almacenamiento en memoria para tests.
class InMemorySessionStorage implements SessionStorage {
  SessionSnapshot? _snapshot;

  SessionSnapshot? get current => _snapshot;

  @override
  Future<void> clear() async {
    _snapshot = null;
  }

  @override
  Future<SessionSnapshot?> read() async => _snapshot;

  @override
  Future<void> write(SessionSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError(
    'sessionStorageProvider debe sobreescribirse en main/tests',
  );
});
