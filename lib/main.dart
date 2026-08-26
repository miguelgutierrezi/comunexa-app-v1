import 'package:comunexa/app.dart';
import 'package:comunexa/bootstrap.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final boot = await bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(boot.sessionStorage),
      ],
      child: const ComunexaApp(),
    ),
  );
}
