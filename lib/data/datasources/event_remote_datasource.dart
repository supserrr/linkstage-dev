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
}
