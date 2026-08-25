import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scope de tests con almacenamiento de sesión en memoria.
class TestProviderScope extends StatelessWidget {
  const TestProviderScope({
    super.key,
    required this.child,
    this.storage,
  });

  final Widget child;
  final SessionStorage? storage;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(
          storage ?? InMemorySessionStorage(),
        ),
      ],
      child: child,
    );
  }
}

Future<void> initTestEnv() async {
  await Env.load();
}
