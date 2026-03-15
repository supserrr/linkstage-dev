import '../entities/event_entity.dart';

/// Abstract contract for event operations.
abstract class EventRepository {
  /// Stream of events for a planner.
  Stream<List<EventEntity>> getEventsByPlannerId(String plannerId);

  /// One-time fetch of events for a planner.
  Future<List<EventEntity>> fetchEventsByPlannerId(String plannerId);

  /// Create a new event.
  Future<EventEntity> createEvent({
    required String plannerId,
    required String title,
    DateTime? date,
    String location = '',
    String description = '',
    EventStatus status = EventStatus.draft,
    List<String> imageUrls = const [],
  });

  /// Update an existing event.
  Future<EventEntity> updateEvent(EventEntity event);

  /// Update only the status of an event (e.g. publish/unpublish).
  Future<void> updateEventStatus(String eventId, EventStatus status);

  /// Delete an event.
  Future<void> deleteEvent(String eventId);
}
