import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../widgets/atoms/app_button.dart';
import '../../../widgets/atoms/app_text_field.dart';

class DisplayNameStep extends StatefulWidget {
  const DisplayNameStep({
    super.key,
    required this.initialValue,
    required this.onNext,
  });

  final String initialValue;
  final VoidCallback onNext;

  @override
  State<DisplayNameStep> createState() => _DisplayNameStepState();
}

class _DisplayNameStepState extends State<DisplayNameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "What's your name?",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'It will be shown on your profile and in messages.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: AppTextField(
                  controller: _controller,
                  label: 'Display name',
                  onChanged: (v) => context.read<ProfileSetupCubit>().setDisplayName(v),
                ),
              ),
            ),
          ),
          AppButton(
            label: 'Next',
            onPressed: () {
              context.read<ProfileSetupCubit>().setDisplayName(_controller.text.trim());
              widget.onNext();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onNext,
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
