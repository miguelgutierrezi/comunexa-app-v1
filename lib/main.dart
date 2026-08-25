import 'package:comunexa/app.dart';
import 'package:comunexa/core/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  if (kDebugMode) {
    debugPrint(
      'Env: APP_ENV=${Env.appEnv} '
      'supabaseConfigured=${Env.isConfigured} '
      'firebaseProjectId=${Env.firebaseProjectId}',
    );
  }

  runApp(const ProviderScope(child: ComunexaApp()));
}
