import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:linkstage/core/di/injection.dart';
import 'package:linkstage/core/router/auth_redirect.dart';
import 'package:linkstage/domain/repositories/auth_repository.dart';
import 'package:linkstage/presentation/bloc/onboarding/onboarding_cubit.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/password_reset_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/activity_tab_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/messages_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/profile/view_profile_page.dart';
import '../../presentation/pages/profile/creative_profile_edit_page.dart';
import '../../presentation/pages/profile/planner_profile_edit_page.dart';
import '../../presentation/pages/profile/profile_reviews_page.dart';
import '../../presentation/pages/settings/change_username_page.dart';
import '../../presentation/pages/settings/change_email_page.dart';
import '../../presentation/pages/settings/privacy_settings_page.dart';
import '../../presentation/pages/onboarding/profile_setup_flow_page.dart';
import '../../presentation/pages/onboarding/onboarding_intro_page.dart';
import '../../presentation/pages/role_selection_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/widgets/organisms/bottom_nav_shell.dart';

/// App route names.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordReset = '/password-reset';
  static const String roleSelection = '/role-selection';
  static const String onboardingIntro = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String search = '/search';
  static const String messages = '/messages';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String changeUsername = '/profile/change-username';
  static const String changeEmail = '/profile/change-email';
  static const String privacy = '/profile/privacy';
  static const String viewProfile = '/profile/view';
  static const String creativeProfile = '/profile/creative-profile';
  static const String plannerProfile = '/profile/planner-profile';
  static const String profileReviews = '/profile/view/reviews';
  static const String myEvents = '/my-events';

  /// Path for viewing another creative's public profile.
  static String creativeProfileView(String userId) => '/profile/creative/$userId';
}

/// Application router configuration.
class AppRouter {
  AppRouter._();

  static final GoRouter router = _createRouter();

  static GoRouter _createRouter() {
    final authNotifier = sl<AuthRedirectNotifier>();
    final splashNotifier = sl<SplashNotifier>();
    final onboardingListenable =
        OnboardingListenable(sl<OnboardingCubit>());
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: Listenable.merge([
        authNotifier,
        splashNotifier,
        onboardingListenable,
      ]),
      redirect: (context, state) {
        final isAuthenticated = authNotifier.isAuthenticated;
        final isAuthRoute =
            state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.passwordReset;
        final isOnboardingRoute =
            state.matchedLocation == AppRoutes.onboardingIntro;
        final isProfileSetupRoute =
            state.matchedLocation == AppRoutes.profileSetup;
        final isAppRoute =
            state.matchedLocation == AppRoutes.home ||
            state.matchedLocation == AppRoutes.search ||
            state.matchedLocation == AppRoutes.messages ||
            state.matchedLocation == AppRoutes.bookings ||
            state.matchedLocation == AppRoutes.myEvents ||
            state.matchedLocation.startsWith(AppRoutes.profile);

        // On iOS, use the same flow as Android: no onboarding intro, role selection, or
        // profile setup — go straight to login or home so both platforms show the same screens.
        final bool alignWithAndroid =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

        if (state.matchedLocation == AppRoutes.splash) {
          if (!splashNotifier.isComplete) return null;
          if (!alignWithAndroid && !onboardingListenable.introComplete) {
            return AppRoutes.onboardingIntro;
          }
          if (!isAuthenticated) return AppRoutes.login;
          if (!authNotifier.isReady) return null;
          if (!alignWithAndroid && authNotifier.needsRoleSelection) {
            return AppRoutes.roleSelection;
          }
          if (!alignWithAndroid && authNotifier.needsProfileSetup) {
            return AppRoutes.profileSetup;
          }
          return AppRoutes.home;
        }
        if (isOnboardingRoute) {
          if (alignWithAndroid || onboardingListenable.introComplete) {
            return isAuthenticated ? AppRoutes.home : AppRoutes.login;
          }
          return null;
        }
        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.login;
        }
        if (isAuthenticated && authNotifier.isReady) {
          if (!alignWithAndroid &&
              authNotifier.needsRoleSelection &&
              !state.matchedLocation.contains('role-selection')) {
            return AppRoutes.roleSelection;
          }
          if (!alignWithAndroid &&
              authNotifier.needsProfileSetup &&
              !isProfileSetupRoute &&
              state.matchedLocation != AppRoutes.roleSelection) {
            return AppRoutes.profileSetup;
          }
          if (!alignWithAndroid &&
              isAppRoute &&
              (authNotifier.needsRoleSelection || authNotifier.needsProfileSetup)) {
            if (authNotifier.needsRoleSelection) {
              return AppRoutes.roleSelection;
            }
            return AppRoutes.profileSetup;
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const Scaffold(
            body: Center(child: SizedBox.shrink()),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.passwordReset,
          name: 'passwordReset',
          builder: (context, state) => const PasswordResetPage(),
        ),
        GoRoute(
          path: AppRoutes.onboardingIntro,
          name: 'onboardingIntro',
          builder: (context, state) => const OnboardingIntroPage(),
        ),
        GoRoute(
          path: AppRoutes.roleSelection,
          name: 'roleSelection',
          builder: (context, state) {
            final user = (state.extra as UserEntity?) ??
                authNotifier.user ??
                sl<AuthRepository>().currentUser;
            if (user == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return RoleSelectionPage(user: user);
          },
        ),
        GoRoute(
          path: AppRoutes.profileSetup,
          name: 'profileSetup',
          builder: (context, state) {
            final user = (state.extra as UserEntity?) ??
                authNotifier.user ??
                sl<AuthRepository>().currentUser;
            if (user == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return ProfileSetupFlowPage(user: user);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              BottomNavShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HomePage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  name: 'search',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: SearchPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/messages',
                  name: 'messages',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: MessagesPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/bookings',
                  name: 'bookings',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: ActivityTabPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: SettingsPage()),
                  routes: [
                    GoRoute(
                      path: 'change-username',
                      name: 'changeUsername',
                      builder: (context, state) =>
                          const ChangeUsernamePage(),
                    ),
                    GoRoute(
                      path: 'change-email',
                      name: 'changeEmail',
                      builder: (context, state) =>
                          const ChangeEmailPage(),
                    ),
                    GoRoute(
                      path: 'privacy',
                      name: 'privacy',
                      builder: (context, state) =>
                          const PrivacySettingsPage(),
                    ),
                    GoRoute(
                      path: 'view',
                      name: 'viewProfile',
                      builder: (context, state) =>
                          const ViewProfilePage(),
                      routes: [
                        GoRoute(
                          path: 'reviews',
                          name: 'profileReviews',
                          builder: (context, state) =>
                              const ProfileReviewsPage(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'creative-profile',
                      name: 'creativeProfile',
                      builder: (context, state) =>
                          const CreativeProfileEditPage(),
                    ),
                    GoRoute(
                      path: 'planner-profile',
                      name: 'plannerProfile',
                      builder: (context, state) =>
                          const PlannerProfileEditPage(),
                    ),
                    GoRoute(
                      path: 'creative/:userId',
                      name: 'creativeProfileView',
                      builder: (context, state) {
                        final userId =
                            state.pathParameters['userId'] ?? '';
                        return ViewProfilePage(profileUserId: userId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
