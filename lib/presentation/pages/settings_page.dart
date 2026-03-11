import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../core/router/auth_redirect.dart';

/// Settings page with theme, notifications, language, username.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final username = sl<AuthRedirectNotifier>().user?.username;

          return ListView(
            children: [
              ListTile(
                title: const Text('Username'),
                subtitle: Text(username != null ? '@$username' : '—'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.changeUsername),
              ),
              const Divider(),
              const ListTile(
                title: Text('Theme'),
                subtitle: Text('Choose light, dark, or system'),
              ),
              RadioGroup<ThemeMode>(
                groupValue: state.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    context.read<SettingsCubit>().setThemeMode(value);
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text(
                  'Receive booking and message notifications',
                ),
                value: state.notificationsEnabled,
                onChanged: (v) =>
                    context.read<SettingsCubit>().setNotificationsEnabled(v),
              ),
              const Divider(),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(
                  state.language == 'en' ? 'English' : state.language,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
