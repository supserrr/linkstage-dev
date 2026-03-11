import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../widgets/atoms/app_text_field.dart';

class LocationStep extends StatefulWidget {
  const LocationStep({
    super.key,
    required this.initialValue,
    required this.onNext,
  });

  final String initialValue;
  final VoidCallback onNext;

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
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
            'Where are you based?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'City or region. You can skip.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _controller,
            label: 'Location',
            hint: 'e.g. Kigali, Rwanda',
            onChanged: (v) => context.read<ProfileSetupCubit>().setLocation(v ?? ''),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              context.read<ProfileSetupCubit>().setLocation(_controller.text.trim());
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
