import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/router/auth_redirect.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../bloc/planner_dashboard/planner_dashboard_cubit.dart';
import '../widgets/atoms/app_logo.dart';
import '../widgets/organisms/planner_dashboard_content.dart';

/// Main home screen. Shows planner dashboard for event planners,
/// generic welcome for creatives.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    final isPlanner = user?.role == UserRole.eventPlanner;

    if (isPlanner && user != null) {
      return BlocProvider(
        create: (_) => PlannerDashboardCubit(
          sl<EventRepository>(),
          sl<BookingRepository>(),
          sl<UserRepository>(),
          user.id,
        ),
        child: Scaffold(
          body: SafeArea(
            child: PlannerDashboardContent(
              displayName: user.displayName ??
                  user.username ??
                  user.email.split('@').first,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const AppLogo(height: 32)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to LinkStage',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Connect with creative professionals for your events.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
