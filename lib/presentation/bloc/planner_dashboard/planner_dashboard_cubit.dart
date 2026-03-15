import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/booking_entity.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'planner_dashboard_state.dart';

/// Cubit for the event planner home dashboard.
/// Subscribes to Firestore streams for events and pending bookings.
class PlannerDashboardCubit extends Cubit<PlannerDashboardState> {
  PlannerDashboardCubit(
    this._eventRepository,
    this._bookingRepository,
    this._userRepository,
    this._plannerId,
  ) : super(const PlannerDashboardState()) {
    _subscribe();
  }

  final EventRepository _eventRepository;
  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;
  final String _plannerId;

  StreamSubscription<List<EventEntity>>? _eventsSubscription;
  StreamSubscription<List<BookingEntity>>? _bookingsSubscription;
  List<EventEntity> _latestEvents = [];
  List<BookingEntity> _latestBookings = [];
  int _emitSequence = 0;

  static const int _recentActivityLimit = 10;

  void _subscribe() {
    _eventsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _latestEvents = [];
    _latestBookings = [];
    emit(state.copyWith(isLoading: true, error: null));

    _eventsSubscription = _eventRepository
        .getEventsByPlannerId(_plannerId)
        .listen(
          (events) {
            _latestEvents = events;
            _rebuildAndEmit();
          },
          onError: (e) => emit(state.copyWith(
            isLoading: false,
            error: e.toString().replaceAll('Exception:', '').trim(),
          )),
        );

    _bookingsSubscription = _bookingRepository
        .watchPendingBookingsByPlannerId(_plannerId)
        .listen(
          (bookings) {
            _latestBookings = bookings;
            _rebuildAndEmit();
          },
          onError: (e) => emit(state.copyWith(
            isLoading: false,
            error: e.toString().replaceAll('Exception:', '').trim(),
          )),
        );
  }

  Future<void> _rebuildAndEmit() async {
    final seq = ++_emitSequence;
    final events = List<EventEntity>.from(_latestEvents);
    final pendingBookings = List<BookingEntity>.from(_latestBookings);

    final eventById = {for (final e in events) e.id: e};
    final pendingCountByEventId = <String, int>{};
    for (final b in pendingBookings) {
      pendingCountByEventId[b.eventId] =
          (pendingCountByEventId[b.eventId] ?? 0) + 1;
    }

    final recentBookings = pendingBookings.take(_recentActivityLimit).toList();
    final recentActivities = <PlannerDashboardActivityItem>[];
    for (final b in recentBookings) {
      final user = await _userRepository.getUser(b.creativeId);
      final creativeName = user?.displayName ??
          user?.username ??
          user?.email.split('@').firstOrNull ??
          'Someone';
      final event = eventById[b.eventId];
      final eventTitle = event?.title ?? 'Event';
      final createdAt = b.createdAt ?? DateTime.now();
      recentActivities.add(PlannerDashboardActivityItem(
        creativeName: creativeName,
        eventTitle: eventTitle,
        createdAt: createdAt,
      ));
    }

    if (seq != _emitSequence) return;
    emit(state.copyWith(
      events: events,
      applicantsCount: pendingBookings.length,
      eventsCount: events.length,
      unreadCount: 0,
      recentActivities: recentActivities,
      pendingCountByEventId: pendingCountByEventId,
      isLoading: false,
    ));
  }

  /// Retry stream subscriptions on error.
  void load() {
    _subscribe();
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
