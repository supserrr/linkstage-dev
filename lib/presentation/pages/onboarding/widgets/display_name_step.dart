import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What\'s your name?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This is how you\'ll appear to others. You can skip.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _controller,
            label: 'Display name',
            onChanged: (v) => context.read<ProfileSetupCubit>().setDisplayName(v ?? ''),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              context.read<ProfileSetupCubit>().setDisplayName(_controller.text.trim());
              widget.onNext();
            },
            child: const Text('Next'),
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
