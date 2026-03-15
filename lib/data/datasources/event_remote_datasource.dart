import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entity.dart';
import '../models/event_model.dart';

/// Remote data source for events in Firestore.
class EventRemoteDataSource {
  EventRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _eventsCollection = 'events';

  /// Stream of events for a planner.
  Stream<List<EventEntity>> getEventsByPlannerId(String plannerId) {
    return _firestore
        .collection(_eventsCollection)
        .where('plannerId', isEqualTo: plannerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => EventModel.fromFirestore(d).toEntity())
              .toList(),
        );
  }

  /// One-time fetch of events for a planner.
  Future<List<EventEntity>> fetchEventsByPlannerId(String plannerId) async {
    final snapshot = await _firestore
        .collection(_eventsCollection)
        .where('plannerId', isEqualTo: plannerId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((d) => EventModel.fromFirestore(d).toEntity())
        .toList();
  }

  /// Create a new event.
  Future<EventEntity> createEvent({
    required String plannerId,
    required String title,
    DateTime? date,
    String location = '',
    String description = '',
    EventStatus status = EventStatus.draft,
    List<String> imageUrls = const [],
  }) async {
    final model = EventModel(
      id: '',
      plannerId: plannerId,
      title: title,
      date: date,
      location: location,
      description: description,
      status: status,
      imageUrls: imageUrls,
    );
    final ref = await _firestore
        .collection(_eventsCollection)
        .add(model.toFirestore());
    return EventEntity(
      id: ref.id,
      plannerId: plannerId,
      title: title,
      date: date,
      location: location,
      description: description,
      status: status,
      imageUrls: imageUrls,
    );
  }

  /// Update an existing event.
  Future<EventEntity> updateEvent(EventEntity event) async {
    final model = EventModel(
      id: event.id,
      plannerId: event.plannerId,
      title: event.title,
      date: event.date,
      location: event.location,
      description: event.description,
      status: event.status,
      imageUrls: event.imageUrls,
    );
    await _firestore
        .collection(_eventsCollection)
        .doc(event.id)
        .update(model.toFirestore());
    return event;
  }

  /// Update only the status of an event.
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    await _firestore.collection(_eventsCollection).doc(eventId).update({
      'status': _statusKey(status),
    });
  }

  /// Delete an event.
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_eventsCollection).doc(eventId).delete();
  }

  String _statusKey(EventStatus s) {
    switch (s) {
      case EventStatus.draft:
        return 'draft';
      case EventStatus.open:
        return 'open';
      case EventStatus.booked:
        return 'booked';
      case EventStatus.completed:
        return 'completed';
    }
  }
}
