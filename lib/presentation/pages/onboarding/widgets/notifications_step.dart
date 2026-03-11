import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/settings/settings_cubit.dart';
import '../../../bloc/settings/settings_state.dart';

class NotificationsStep extends StatelessWidget {
  const NotificationsStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enable notifications',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Get notified about bookings and messages.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text('Push notifications'),
                value: settings.notificationsEnabled,
                onChanged: (v) {
                  context.read<SettingsCubit>().setNotificationsEnabled(v);
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: onNext,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onNext,
                child: const Text('Not now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
