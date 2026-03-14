import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/entities/user_entity.dart';

/// Shell with bottom navigation for main app tabs.
/// Tab labels differ by role: creatives see "My Gigs", planners see "My Events".
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.scaffoldBackgroundColor;
    return ListenableBuilder(
      listenable: sl<AuthRedirectNotifier>(),
      builder: (context, _) {
        final role = sl<AuthRedirectNotifier>().user?.role;
        final activityLabel = role == UserRole.eventPlanner ? 'My Events' : 'My Gigs';
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GNav(
                  selectedIndex: navigationShell.currentIndex,
                  onTabChange: (index) => navigationShell.goBranch(index),
                  rippleColor: colorScheme.surfaceContainerHighest,
                  hoverColor: colorScheme.surfaceContainerHigh,
                  gap: 8,
                  activeColor: colorScheme.onPrimaryContainer,
                  iconSize: 24,
                  tabBackgroundColor: colorScheme.primaryContainer,
                  color: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  tabs: [
                    GButton(
                      icon: Icons.home_outlined,
                      text: 'Home',
                    ),
                    GButton(
                      icon: Icons.search,
                      text: 'Search',
                    ),
                    GButton(
                      icon: Icons.message_outlined,
                      text: 'Messages',
                    ),
                    GButton(
                      icon: Icons.event_outlined,
                      text: activityLabel,
                    ),
                    GButton(
                      icon: Icons.settings_outlined,
                      text: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
