import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';

class ComunexaApp extends StatelessWidget {
  const ComunexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comunexa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
