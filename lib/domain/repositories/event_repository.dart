import '../entities/event_entity.dart';

/// Abstract contract for event operations.
abstract class EventRepository {
  /// Stream of events for a planner.
  Stream<List<EventEntity>> getEventsByPlannerId(String plannerId);

  /// One-time fetch of events for a planner.
  Future<List<EventEntity>> fetchEventsByPlannerId(String plannerId);
}
