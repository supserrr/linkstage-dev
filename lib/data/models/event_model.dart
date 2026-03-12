import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entity.dart';

/// Firestore model for event document.
class EventModel {
  EventModel({
    required this.id,
    required this.plannerId,
    required this.title,
    this.date,
    this.location = '',
    this.description = '',
    this.status = EventStatus.draft,
  });

  factory EventModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['date'] as Timestamp?;
    return EventModel(
      id: doc.id,
      plannerId: data['plannerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      date: ts?.toDate(),
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: EventEntity.statusFromKey(data['status'] as String?) ??
          EventStatus.draft,
    );
  }

  final String id;
  final String plannerId;
  final String title;
  final DateTime? date;
  final String location;
  final String description;
  final EventStatus status;

  Map<String, dynamic> toFirestore() {
    return {
      'plannerId': plannerId,
      'title': title,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'location': location,
      'description': description,
      'status': _statusKey,
    };
  }

  String get _statusKey {
    switch (status) {
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

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      plannerId: plannerId,
      title: title,
      date: date,
      location: location,
      description: description,
      status: status,
    );
  }
}
