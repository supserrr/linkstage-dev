import 'package:flutter/material.dart';

class DiscoverStep extends StatelessWidget {
  const DiscoverStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Discover creatives',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Find and follow creatives to get inspired. You can skip.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          FilledButton(
            onPressed: onNext,
            child: const Text('Continue'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onNext,
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
