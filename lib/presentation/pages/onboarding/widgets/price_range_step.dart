import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../bloc/onboarding/profile_setup_state.dart';

const _options = ['Budget', 'Mid-range', 'Premium'];

class PriceRangeStep extends StatelessWidget {
  const PriceRangeStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

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
                'Price range',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Give clients an idea of your rates. You can skip.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _options.map((opt) {
                  final selected = state.priceRange == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: selected,
                    onSelected: (_) {
                      context.read<ProfileSetupCubit>().setPriceRange(opt);
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => onNext(),
                child: const Text('Next'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => onNext(),
                child: const Text('Skip'),
              ),
            ],
          ),
        );
      },
    );
  }
}
