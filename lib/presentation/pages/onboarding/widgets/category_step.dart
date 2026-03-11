import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../bloc/onboarding/profile_setup_state.dart';
import '../../../../domain/entities/profile_entity.dart';

class CategoryStep extends StatelessWidget {
  const CategoryStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  static const _categories = [
    (ProfileCategory.dj, 'DJ', Icons.music_note),
    (ProfileCategory.photographer, 'Photographer', Icons.camera_alt),
    (ProfileCategory.decorator, 'Decorator', Icons.palette),
    (ProfileCategory.contentCreator, 'Content Creator', Icons.videocam),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What do you do?',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your primary category.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ..._categories.map((e) {
                final (cat, label, icon) = e;
                final selected = state.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        context.read<ProfileSetupCubit>().setCategory(cat);
                        onNext();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 32,
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              label,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (selected) ...[
                              const Spacer(),
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
