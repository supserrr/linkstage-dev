import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../core/router/auth_redirect.dart';
import '../../domain/entities/user_entity.dart';

/// Settings page with View Profile at top, account settings, app settings.
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
    final user = sl<AuthRedirectNotifier>().user;
    final role = user?.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _ViewProfileSection(user: user, role: role),
              const Divider(),
              _SectionHeader(title: 'Account Settings'),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? '—'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.changeEmail),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Username'),
                subtitle: Text(
                  user?.username != null ? '@${user!.username}' : '—',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.changeUsername),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(_languageLabel(state.language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, state),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                subtitle: const Text('Profile visibility, messaging'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacy),
              ),
              const Divider(),
              _SectionHeader(title: 'Premium'),
              ListTile(
                leading: const Icon(Icons.diamond_outlined),
                title: const Text('Premium Status'),
                subtitle: const Text('Inactive'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: premium
                },
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: const Text('Refer a friend'),
                subtitle: const Text('50 /referral'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: referral
                },
              ),
              const Divider(),
              _SectionHeader(title: 'App Settings'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      context.read<SettingsCubit>().setThemeMode(selection.first);
                    }
                  },
                ),
              ),
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
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewProfileSection extends StatelessWidget {
  const _ViewProfileSection({this.user, this.role});

  final dynamic user;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl as String?;
    return Padding(
      padding: const EdgeInsets.all(20),
        child: GestureDetector(
        onTap: () => context.push(AppRoutes.viewProfile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              'View profile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _languageLabel(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'fr':
      return 'Francais';
    case 'rw':
      return 'Kinyarwanda';
    case 'sw':
      return 'Kiswahili';
    default:
      return code;
  }
}

void _showLanguagePicker(BuildContext context, SettingsState state) {
  const languages = [
    ('en', 'English'),
    ('fr', 'Francais'),
    ('rw', 'Kinyarwanda'),
    ('sw', 'Kiswahili'),
  ];
  final cubit = context.read<SettingsCubit>();
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Language',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          ...languages.map((l) => ListTile(
                title: Text(l.$2),
                trailing: state.language == l.$1
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  cubit.setLanguage(l.$1);
                  Navigator.pop(ctx);
                },
              )),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
