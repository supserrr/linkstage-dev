import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../bloc/onboarding/profile_setup_state.dart';
import '../../../widgets/atoms/app_button.dart';

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
              Center(
                child: Column(
                  children: [
                    Text(
                      'Add a profile photo',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optional. Skip for now.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _pickImage(context),
                      borderRadius: BorderRadius.circular(80),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: photoFile != null
                                ? Colors.transparent
                                : theme.colorScheme.primary,
                          ),
                          color: photoFile != null
                              ? null
                              : theme.colorScheme.primaryContainer,
                          image: photoFile != null
                              ? DecorationImage(
                                  image: FileImage(photoFile),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: photoFile == null
                            ? Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              AppButton(
                label: 'Next',
                onPressed: onNext,
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
