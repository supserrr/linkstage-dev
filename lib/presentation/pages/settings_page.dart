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

/// Settings page with account badge, account settings, profile management,
/// app settings, and sign out.
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
              _AccountTypeBadge(role: role),
              const Divider(),
              _SectionHeader(title: 'Account Settings'),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? '—'),
                trailing: const Icon(Icons.chevron_right, color: Colors.transparent),
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
                subtitle: Text(
                  state.language == 'en' ? 'English' : state.language,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: future language picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: future privacy settings
                },
              ),
              const Divider(),
              _SectionHeader(title: 'Public Profile'),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Manage profile'),
                subtitle: Text(
                  role == UserRole.creativeProfessional
                      ? 'Edit portfolio, rates, availability'
                      : role == UserRole.eventPlanner
                          ? 'Edit past events, recent creatives'
                          : 'Set up your profile',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (role == UserRole.creativeProfessional) {
                    context.push(AppRoutes.creativeProfile);
                  } else if (role == UserRole.eventPlanner) {
                    context.push(AppRoutes.plannerProfile);
                  }
                },
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setThemeMode(v);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setThemeMode(v);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setThemeMode(v);
                  }
                },
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

class _AccountTypeBadge extends StatelessWidget {
  const _AccountTypeBadge({this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final label = role == UserRole.creativeProfessional
        ? 'Creative Professional'
        : role == UserRole.eventPlanner
            ? 'Event Planner'
            : 'Account';
    final color = role == UserRole.creativeProfessional
        ? Theme.of(context).colorScheme.primary
        : role == UserRole.eventPlanner
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Chip(
        avatar: Icon(
          role == UserRole.creativeProfessional
              ? Icons.palette_outlined
              : role == UserRole.eventPlanner
                  ? Icons.event_available
                  : Icons.person_outline,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
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
