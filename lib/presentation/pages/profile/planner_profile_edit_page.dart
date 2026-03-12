import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event_entity.dart';
import '../../bloc/planner_profile/planner_profile_cubit.dart';
import '../../bloc/planner_profile/planner_profile_state.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../widgets/molecules/vendor_card.dart';

/// Event planner profile edit page.
class PlannerProfileEditPage extends StatelessWidget {
  const PlannerProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => PlannerProfileCubit(
        sl<UserRepository>(),
        sl<EventRepository>(),
        sl<BookingRepository>(),
        sl<ProfileRepository>(),
        user.id,
      ),
      child: const _PlannerProfileView(),
    );
  }
}

class _PlannerProfileView extends StatelessWidget {
  const _PlannerProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<PlannerProfileCubit, PlannerProfileState>(
        listenWhen: (a, b) => a.error != b.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfilePhotoSection(photoUrl: user.photoUrl),
              const SizedBox(height: 16),
              Text(
                user.displayName ?? 'Event Planner',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (user.username != null) ...[
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _SectionHeader(title: 'Past Events'),
              if (state.events.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...state.events.take(10).map((e) => _EventCard(event: e)),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Recent Creatives'),
              if (state.recentCreatives.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No creatives hired yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...state.recentCreatives.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VendorCard(profile: p),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? CachedNetworkImageProvider(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? const Icon(Icons.person, size: 48)
            : null,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final dateStr = event.date != null
        ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
        : '—';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text('${event.location.isNotEmpty ? event.location : '—'} · $dateStr'),
        trailing: Chip(
          label: Text(_statusLabel(event.status)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  String _statusLabel(EventStatus s) {
    switch (s) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.open:
        return 'Open';
      case EventStatus.booked:
        return 'Booked';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}
