import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../models/booking_model.dart';

/// Remote data source for bookings in Firestore.
class BookingRemoteDataSource {
  BookingRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _bookingsCollection = 'bookings';

  static const String _statusCompleted = 'completed';
  static const String _statusPending = 'pending';

  /// Fetch pending bookings for a planner (applicants, recent proposals, per-event counts).
  Future<List<BookingEntity>> getPendingBookingsByPlannerId(
    String plannerId,
  ) async {
    final snapshot = await _firestore
        .collection(_bookingsCollection)
        .where('plannerId', isEqualTo: plannerId)
        .where('status', isEqualTo: _statusPending)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => BookingModel.fromFirestore(d).toEntity())
        .toList();
  }

  /// Fetch completed bookings for a creative (for total gigs count).
  Future<List<BookingEntity>> getCompletedBookingsByCreativeId(
    String creativeId,
  ) async {
    final snapshot = await _firestore
        .collection(_bookingsCollection)
        .where('creativeId', isEqualTo: creativeId)
        .where('status', isEqualTo: _statusCompleted)
        .get();
    return snapshot.docs
        .map((d) => BookingModel.fromFirestore(d).toEntity())
        .toList();
  }

  /// Fetch completed bookings for a planner (to get recent creatives).
  Future<List<BookingEntity>> getCompletedBookingsByPlannerId(
    String plannerId,
  ) async {
    final snapshot = await _firestore
        .collection(_bookingsCollection)
        .where('plannerId', isEqualTo: plannerId)
        .where('status', isEqualTo: _statusCompleted)
        .get();
    return snapshot.docs
        .map((d) => BookingModel.fromFirestore(d).toEntity())
        .toList();
  }

  /// Stream of pending bookings for a planner (applicants, recent proposals).
  Stream<List<BookingEntity>> watchPendingBookingsByPlannerId(
    String plannerId,
  ) {
    return _firestore
        .collection(_bookingsCollection)
        .where('plannerId', isEqualTo: plannerId)
        .where('status', isEqualTo: _statusPending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => BookingModel.fromFirestore(d).toEntity())
              .toList(),
        );
  }

  /// Stream of completed bookings for a creative (for gig list).
  Stream<List<BookingEntity>> watchCompletedBookingsByCreativeId(
    String creativeId,
  ) {
    return _firestore
        .collection(_bookingsCollection)
        .where('creativeId', isEqualTo: creativeId)
        .where('status', isEqualTo: _statusCompleted)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => BookingModel.fromFirestore(d).toEntity())
              .toList(),
        );
  }
}
