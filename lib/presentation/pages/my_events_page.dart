import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/my_events/my_events_cubit.dart';
import '../bloc/my_events/my_events_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../core/router/auth_redirect.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event_entity.dart';
import '../widgets/molecules/empty_state_illustrated.dart';

/// Events list for event planners.
class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => MyEventsCubit(
        sl<EventRepository>(),
        sl<BookingRepository>(),
        user.id,
      ),
      child: const _MyEventsView(),
    );
  }
}

class _MyEventsView extends StatelessWidget {
  const _MyEventsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push<bool?>(AppRoutes.createEvent),
            tooltip: 'Create event',
          ),
        ],
      ),
      body: BlocBuilder<MyEventsCubit, MyEventsState>(
        builder: (context, state) {
          if (state.isLoading && state.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<MyEventsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.events.isEmpty) {
            return EmptyStateIllustrated(
              assetPathDark: 'assets/images/no_events_empty_dark.svg',
              assetPathLight: 'assets/images/no_events_empty_light.svg',
              headline: "No events yet? Let's create your first one!",
              description:
                  'Create events to find and book creatives for your next occasion.',
              primaryLabel: 'Create event',
              onPrimaryPressed: () =>
                  context.push<bool?>(AppRoutes.createEvent),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: state.events.length,
            itemBuilder: (context, index) {
              final event = state.events[index];
              return _EventCard(
                event: event,
                applicantCount: state.pendingCountByEventId[event.id] ?? 0,
                onEdit: () async {
                  final updated = await context.push<bool?>(
                    AppRoutes.editEvent,
                    extra: event,
                  );
                  if (updated == true && context.mounted) {
                    context.read<MyEventsCubit>().load();
                  }
                },
                onTogglePublish: () {
                  final cubit = context.read<MyEventsCubit>();
                  final newStatus = event.status == EventStatus.open
                      ? EventStatus.draft
                      : EventStatus.open;
                  if (event.status == EventStatus.draft ||
                      event.status == EventStatus.open) {
                    cubit.updateStatus(event.id, newStatus);
                  }
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete event?'),
                      content: Text(
                        'Are you sure you want to delete "${event.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(ctx).colorScheme.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<MyEventsCubit>().delete(event.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.applicantCount,
    required this.onEdit,
    required this.onTogglePublish,
    required this.onDelete,
  });

  final EventEntity event;
  final int applicantCount;
  final VoidCallback onEdit;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

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

  String _daysLeftText(DateTime? date) {
    if (date == null) return 'No date set';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final diff = eventDay.difference(today).inDays;
    if (diff < 0) return '${-diff} days ago';
    if (diff == 0) return 'Today';
    if (diff == 1) return '1 day left';
    return '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = event.date != null
        ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
        : '—';
    final location =
        event.location.isNotEmpty ? event.location : '—';
    final daysLeft = _daysLeftText(event.date);
    final canToggle = event.status == EventStatus.draft ||
        event.status == EventStatus.open;

    final circleButtonStyle = IconButton.styleFrom(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(36, 36),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: event.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: event.imageUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Icon(
                        Icons.event,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Chip(
                  label: Text(
                    _statusLabel(event.status),
                    style: theme.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        daysLeft,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '$dateStr \u2022 $location',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      applicantCount == 1
                          ? '1 applicant'
                          : '$applicantCount applicants',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                      style: circleButtonStyle,
                      tooltip: 'Edit',
                    ),
                    if (canToggle) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          event.status == EventStatus.open
                              ? Icons.visibility_off_outlined
                              : Icons.publish_outlined,
                          size: 18,
                        ),
                        onPressed: onTogglePublish,
                        style: circleButtonStyle,
                        tooltip: event.status == EventStatus.open
                            ? 'Unpublish'
                            : 'Publish',
                      ),
                    ],
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: onDelete,
                      style: circleButtonStyle,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
