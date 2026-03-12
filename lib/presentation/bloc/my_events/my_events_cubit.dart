import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/event_repository.dart';
import 'my_events_state.dart';

/// Cubit for my events list (event planners).
class MyEventsCubit extends Cubit<MyEventsState> {
  MyEventsCubit(this._eventRepository, this._plannerId)
    : super(const MyEventsState()) {
    load();
  }

  final EventRepository _eventRepository;
  final String _plannerId;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final events = await _eventRepository.fetchEventsByPlannerId(_plannerId);
      emit(state.copyWith(events: events, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
