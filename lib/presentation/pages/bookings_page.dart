import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../widgets/molecules/empty_state_illustrated.dart';

/// Bookings list placeholder.
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: EmptyStateIllustrated(
        assetPathDark: 'assets/images/no_gigs_empty_dark.svg',
        assetPathLight: 'assets/images/no_gigs_empty_light.svg',
        headline: "No gigs yet — let's find events to book!",
        description: 'Browse events and apply to get booked.',
        primaryLabel: 'Browse events',
        onPrimaryPressed: () => context.go(AppRoutes.search),
      ),
    );
  }
}
