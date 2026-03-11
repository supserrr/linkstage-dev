import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';

class BioStep extends StatefulWidget {
  const BioStep({
    super.key,
    required this.initialValue,
    required this.onNext,
  });

  final String initialValue;
  final VoidCallback onNext;

  @override
  State<BioStep> createState() => _BioStepState();
}

class _BioStepState extends State<BioStep> {
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
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'A short bio helps others get to know you. You can skip.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Write a short introduction...',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => context.read<ProfileSetupCubit>().setBio(v),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              context.read<ProfileSetupCubit>().setBio(_controller.text.trim());
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
