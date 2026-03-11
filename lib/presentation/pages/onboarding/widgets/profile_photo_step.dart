import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../bloc/onboarding/profile_setup_state.dart';

class ProfilePhotoStep extends StatelessWidget {
  const ProfilePhotoStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (x != null && context.mounted) {
      context.read<ProfileSetupCubit>().setPhoto(File(x.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      builder: (context, state) {
        final photoFile = state.photoFile;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add a profile photo',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Help others recognize you. You can skip for now.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: photoFile != null
                        ? FileImage(photoFile)
                        : null,
                    child: photoFile == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => _pickImage(context),
                  child: const Text('Add photo'),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onNext,
                child: const Text('Next'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onNext,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
