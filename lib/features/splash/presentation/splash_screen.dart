import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Splash breve → restaura sesión persistida o login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 1200));
    final sessionFuture = ref.read(sessionProvider.future);
    await Future.wait([minDelay, sessionFuture]);

    if (!mounted) return;
    final session = ref.read(sessionProvider).valueOrNull ?? SessionState.empty;
    navigateToAppStart(
      context,
      resolveAppStartDestination(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  BrandAssets.logoHorizontal,
                  height: 88,
                  semanticsLabel: 'Comunexa',
                ),
                const SizedBox(height: 40),
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
