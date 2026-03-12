import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/onboarding/onboarding_cubit.dart';
import '../../widgets/atoms/app_button.dart';
import '../../widgets/atoms/app_logo.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';

/// Pre-auth welcome screen (single screen, logo + Login/Sign Up).
class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({super.key});

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  late final OnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<OnboardingCubit>();
  }

  Future<void> _goToLogin() async {
    await _cubit.setIntroComplete();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _goToRegister() async {
    await _cubit.setIntroComplete();
    if (mounted) context.go(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AppLogo(height: 96)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _goToLogin,
                  child: const Text('Login'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 16),
              AppButton(
                label: 'Sign Up',
                onPressed: _goToRegister,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
