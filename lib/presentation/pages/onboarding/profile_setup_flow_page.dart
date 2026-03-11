import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/onboarding/onboarding_cubit.dart';
import '../../bloc/onboarding/profile_setup_cubit.dart';
import '../../bloc/onboarding/profile_setup_state.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user/upsert_user_usecase.dart';
import '../onboarding/widgets/bio_step.dart';
import '../onboarding/widgets/category_step.dart';
import '../onboarding/widgets/display_name_step.dart';
import '../onboarding/widgets/discover_step.dart';
import '../onboarding/widgets/location_step.dart';
import '../onboarding/widgets/notifications_step.dart';
import '../onboarding/widgets/price_range_step.dart';
import '../onboarding/widgets/profile_photo_step.dart';
import '../onboarding/widgets/username_step.dart';

/// Post-auth profile setup flow (step-by-step).
class ProfileSetupFlowPage extends StatefulWidget {
  const ProfileSetupFlowPage({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  State<ProfileSetupFlowPage> createState() => _ProfileSetupFlowPageState();
}

class _ProfileSetupFlowPageState extends State<ProfileSetupFlowPage> {
  late final PageController _pageController;
  late final List<_StepConfig> _steps;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final isCreative =
        widget.user.role == UserRole.creativeProfessional;
    _steps = [
      _StepConfig(title: 'Username', isCreative: false),
      _StepConfig(title: 'Photo', isCreative: false),
      _StepConfig(title: 'Name', isCreative: false),
      _StepConfig(title: 'Bio', isCreative: false),
      _StepConfig(title: 'Location', isCreative: false),
      if (isCreative) _StepConfig(title: 'Category', isCreative: true),
      if (isCreative) _StepConfig(title: 'Price', isCreative: true),
      _StepConfig(title: 'Discover', isCreative: false),
      _StepConfig(title: 'Notifications', isCreative: false),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    await context.read<ProfileSetupCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileSetupCubit(
        widget.user,
        sl<UpsertUserUseCase>(),
        sl<ProfileRepository>(),
        sl<UserRepository>(),
      ),
      child: BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
        listenWhen: (a, b) => b.success || b.error != null,
        listener: (context, state) {
          if (state.success) {
            sl<OnboardingCubit>().setProfileComplete();
            context.go(AppRoutes.home);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_currentStep + 1} of ${_steps.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _buildStepWidgets(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStepWidgets() {
    final cubit = context.read<ProfileSetupCubit>();
    final isCreative =
        widget.user.role == UserRole.creativeProfessional;

    return [
      UsernameStep(onNext: _next),
      ProfilePhotoStep(onNext: _next),
      DisplayNameStep(
        initialValue: cubit.state.displayName,
        onNext: _next,
      ),
      BioStep(
        initialValue: cubit.state.bio,
        onNext: _next,
      ),
      LocationStep(
        initialValue: cubit.state.location,
        onNext: _next,
      ),
      if (isCreative) CategoryStep(onNext: _next),
      if (isCreative) PriceRangeStep(onNext: _next),
      DiscoverStep(onNext: _next),
      NotificationsStep(onNext: _next),
    ];
  }
}

class _StepConfig {
  _StepConfig({required this.title, required this.isCreative});

  final String title;
  final bool isCreative;
}
