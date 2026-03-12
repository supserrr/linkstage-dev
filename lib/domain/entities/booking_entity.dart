import 'package:equatable/equatable.dart';

/// Booking status.
enum BookingStatus { pending, accepted, declined, completed }

/// Domain entity for a booking.
class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.eventId,
    required this.creativeId,
    required this.plannerId,
    this.status = BookingStatus.pending,
    this.agreedPrice,
    this.createdAt,
  });

  final String id;
  final String eventId;
  final String creativeId;
  final String plannerId;
  final BookingStatus status;
  final double? agreedPrice;
  final DateTime? createdAt;

  static BookingStatus? statusFromKey(String? key) {
    switch (key) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'declined':
        return BookingStatus.declined;
      case 'completed':
        return BookingStatus.completed;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, eventId, creativeId, plannerId, status];
}
