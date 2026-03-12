import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/role_selection/role_selection_cubit.dart';
import '../bloc/role_selection/role_selection_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/user/upsert_user_usecase.dart';
import '../widgets/atoms/app_button.dart';
import '../widgets/atoms/app_logo.dart';

/// Role selection after registration (Event Planner vs Creative Professional).
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleSelectionCubit(sl<UpsertUserUseCase>()),
      child: BlocConsumer<RoleSelectionCubit, RoleSelectionState>(
        listener: (context, state) {
          if (state.status == RoleSelectionStatus.success && state.user != null) {
            context.go(AppRoutes.profileSetup, extra: state.user);
          }
          if (state.status == RoleSelectionStatus.error &&
              state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return _RoleSelectionView(user: user);
        },
      ),
    );
  }
}

class _RoleSelectionView extends StatefulWidget {
  const _RoleSelectionView({required this.user});

  final UserEntity user;

  @override
  State<_RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<_RoleSelectionView> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoleSelectionCubit>().state;
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLogo(height: 96),
                    const SizedBox(height: 24),
                    Text(
                      'Choose your role below',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    _RoleCard(
                      title: 'Event Planner',
                      isSelected: _selectedRole == UserRole.eventPlanner,
                      onTap: () => setState(() => _selectedRole = UserRole.eventPlanner),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'or',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      title: 'Creative Professional',
                      isSelected: _selectedRole == UserRole.creativeProfessional,
                      onTap: () => setState(
                        () => _selectedRole = UserRole.creativeProfessional,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: 'Get started',
                onPressed: _selectedRole == null || state.status == RoleSelectionStatus.loading
                    ? null
                    : () => context
                        .read<RoleSelectionCubit>()
                        .selectRole(user, _selectedRole!),
                isLoading: state.status == RoleSelectionStatus.loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final foregroundColor =
        isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
