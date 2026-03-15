import 'package:equatable/equatable.dart';

/// Event status.
enum EventStatus { draft, open, booked, completed }

/// Domain entity for an event.
class EventEntity extends Equatable {
  const EventEntity({
    required this.id,
    required this.plannerId,
    required this.title,
    this.date,
    this.location = '',
    this.description = '',
    this.status = EventStatus.draft,
    this.imageUrls = const [],
  });

  final String id;
  final String plannerId;
  final String title;
  final DateTime? date;
  final String location;
  final String description;
  final EventStatus status;
  final List<String> imageUrls;

  static EventStatus? statusFromKey(String? key) {
    switch (key) {
      case 'draft':
        return EventStatus.draft;
      case 'open':
        return EventStatus.open;
      case 'booked':
        return EventStatus.booked;
      case 'completed':
        return EventStatus.completed;
      default:
        return null;
    }
  }

  String get statusKey {
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

  @override
  List<Object?> get props => [id, plannerId, title, date, location, description, status, imageUrls];
}
