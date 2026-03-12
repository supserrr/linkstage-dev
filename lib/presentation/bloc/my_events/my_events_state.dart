import '../../../domain/entities/event_entity.dart';

/// State for my events list.
class MyEventsState {
  const MyEventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  final List<EventEntity> events;
  final bool isLoading;
  final String? error;

  MyEventsState copyWith({
    List<EventEntity>? events,
    bool? isLoading,
    String? error,
  }) {
    return MyEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
