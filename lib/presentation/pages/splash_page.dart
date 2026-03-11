import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Splash screen with Lottie animation (light/dark mode aware).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lottieAsset = isDark
        ? 'assets/lottie/Link-Stage-Animation-Dark-Mode.json'
        : 'assets/lottie/Link-Stage-Animation-Light-Mode.json';

    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Theme.of(context).colorScheme.surface,
        child: Lottie.asset(
          lottieAsset,
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
