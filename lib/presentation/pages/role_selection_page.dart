import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/role_selection/role_selection_cubit.dart';
import '../bloc/role_selection/role_selection_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/user/upsert_user_usecase.dart';

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
          return Scaffold(
            appBar: AppBar(title: const Text('Choose your role')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'How will you use ${AppConstants.appName}?',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    _RoleCard(
                      title: 'Event Planner',
                      description:
                          'Find and book creative professionals for your events',
                      icon: Icons.event,
                      isLoading: state.status == RoleSelectionStatus.loading,
                      onTap: () => context
                          .read<RoleSelectionCubit>()
                          .selectRole(user, UserRole.eventPlanner),
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'Creative Professional',
                      description:
                          'Showcase your work and get booked for events',
                      icon: Icons.palette,
                      isLoading: state.status == RoleSelectionStatus.loading,
                      onTap: () => context
                          .read<RoleSelectionCubit>()
                          .selectRole(user, UserRole.creativeProfessional),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
