import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';

/// Firestore model for booking document.
class BookingModel {
  BookingModel({
    required this.id,
    required this.eventId,
    required this.creativeId,
    required this.plannerId,
    this.status = BookingStatus.pending,
    this.agreedPrice,
    this.createdAt,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'] as Timestamp?;
    return BookingModel(
      id: doc.id,
      eventId: data['eventId'] as String? ?? '',
      creativeId: data['creativeId'] as String? ?? '',
      plannerId: data['plannerId'] as String? ?? '',
      status: BookingEntity.statusFromKey(data['status'] as String?) ??
          BookingStatus.pending,
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble(),
      createdAt: ts?.toDate(),
    );
  }

  final String id;
  final String eventId;
  final String creativeId;
  final String plannerId;
  final BookingStatus status;
  final double? agreedPrice;
  final DateTime? createdAt;

  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      eventId: eventId,
      creativeId: creativeId,
      plannerId: plannerId,
      status: status,
      agreedPrice: agreedPrice,
      createdAt: createdAt,
    );
  }
}
