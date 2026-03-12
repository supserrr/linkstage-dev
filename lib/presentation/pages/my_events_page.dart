import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/my_events/my_events_cubit.dart';
import '../bloc/my_events/my_events_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/auth_redirect.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event_entity.dart';

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
      create: (_) => MyEventsCubit(sl<EventRepository>(), user.id),
      child: const _MyEventsView(),
    );
  }
}

class _MyEventsView extends StatelessWidget {
  const _MyEventsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create events to find creatives',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.events.length,
            itemBuilder: (context, index) {
              final event = state.events[index];
              return _EventCard(event: event);
            },
          );
        },
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text(
          '${event.location.isNotEmpty ? event.location : '—'} · $dateStr',
        ),
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
