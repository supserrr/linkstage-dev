import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/router/auth_redirect.dart';
import '../../domain/entities/user_entity.dart';
import 'bookings_page.dart';
import 'my_events_page.dart';

/// Tab that shows My Gigs (bookings) for creatives or My Events for planners.
class ActivityTabPage extends StatelessWidget {
  const ActivityTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = sl<AuthRedirectNotifier>().user?.role;
    if (role == UserRole.eventPlanner) {
      return const MyEventsPage();
    }
    return const BookingsPage();
  }
}
