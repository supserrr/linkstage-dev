// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/settings/settings_cubit.dart';
import '../../bloc/settings/settings_state.dart';
import '../../../core/di/injection.dart';

/// Privacy settings page with industry-standard options.
class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: const _PrivacySettingsView(),
    );
  }
}

class _PrivacySettingsView extends StatelessWidget {
  const _PrivacySettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Profile visibility',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              RadioListTile<ProfileVisibility>(
                title: const Text('Everyone'),
                subtitle: const Text('Your profile is visible to all users'),
                value: ProfileVisibility.everyone,
                groupValue: state.profileVisibility,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setProfileVisibility(v);
                  }
                },
              ),
              RadioListTile<ProfileVisibility>(
                title: const Text('Connections only'),
                subtitle: const Text('Only people you\'ve connected with'),
                value: ProfileVisibility.connectionsOnly,
                groupValue: state.profileVisibility,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setProfileVisibility(v);
                  }
                },
              ),
              RadioListTile<ProfileVisibility>(
                title: const Text('Only me'),
                subtitle: const Text('Profile is private'),
                value: ProfileVisibility.onlyMe,
                groupValue: state.profileVisibility,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setProfileVisibility(v);
                  }
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Who can message you',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              RadioListTile<WhoCanMessage>(
                title: const Text('Everyone'),
                subtitle: const Text('Any user can send you messages'),
                value: WhoCanMessage.everyone,
                groupValue: state.whoCanMessage,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setWhoCanMessage(v);
                  }
                },
              ),
              RadioListTile<WhoCanMessage>(
                title: const Text('People you\'ve worked with'),
                subtitle: const Text('Only after a completed booking'),
                value: WhoCanMessage.workedWith,
                groupValue: state.whoCanMessage,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setWhoCanMessage(v);
                  }
                },
              ),
              RadioListTile<WhoCanMessage>(
                title: const Text('No one'),
                subtitle: const Text('Disable direct messages'),
                value: WhoCanMessage.noOne,
                groupValue: state.whoCanMessage,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setWhoCanMessage(v);
                  }
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show when you\'re active'),
                subtitle: const Text(
                  'Let others see when you were last active',
                ),
                value: state.showOnlineStatus,
                onChanged: (v) =>
                    context.read<SettingsCubit>().setShowOnlineStatus(v),
              ),
            ],
          );
        },
      ),
    );
  }
}
