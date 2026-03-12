import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/profile_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'planner_profile_state.dart';

/// Cubit for planner profile edit flow.
class PlannerProfileCubit extends Cubit<PlannerProfileState> {
  PlannerProfileCubit(
    this._userRepository,
    this._eventRepository,
    this._bookingRepository,
    this._profileRepository,
    String plannerId,
  ) : super(const PlannerProfileState()) {
    load(plannerId);
  }

  final UserRepository _userRepository;
  final EventRepository _eventRepository;
  final BookingRepository _bookingRepository;
  final ProfileRepository _profileRepository;

  Future<void> load(String plannerId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await _userRepository.getUser(plannerId);
      final events = await _eventRepository.fetchEventsByPlannerId(plannerId);
      final bookings =
          await _bookingRepository.getCompletedBookingsByPlannerId(plannerId);
      final creativeIds = bookings
          .map((b) => b.creativeId)
          .toSet()
          .toList();
      final creatives = <ProfileEntity>[];
      for (final id in creativeIds.take(10)) {
        final p = await _profileRepository.getProfileByUserId(id);
        if (p != null) creatives.add(p);
      }
      emit(state.copyWith(
        user: user,
        events: events,
        recentCreatives: creatives,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
