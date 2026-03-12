import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      context.read<ProfileSetupCubit>().setPhoto(x);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      builder: (context, state) {
        final photoFile = state.photoFile;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final asset = isDark
                        ? 'assets/images/profile_page_illustration_dark.svg'
                        : 'assets/images/profile_page_illustration_light.svg';
                    return SvgPicture.asset(
                      asset,
                      width: constraints.maxWidth,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Add a profile photo',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pickImage(context),
                        borderRadius: BorderRadius.circular(60),
                        child: FutureBuilder<Uint8List>(
                          future: photoFile?.readAsBytes(),
                          builder: (context, snapshot) {
                            final bytes = snapshot.data;
                            return Container(
                              width: 120,
                              height: 120,
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
                                image: bytes != null && bytes.isNotEmpty
                                    ? DecorationImage(
                                        image: MemoryImage(bytes),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: photoFile == null
                                  ? Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 36,
                                        color:
                                            theme.colorScheme.onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Next',
                    onPressed: photoFile != null ? onNext : null,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onNext,
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
