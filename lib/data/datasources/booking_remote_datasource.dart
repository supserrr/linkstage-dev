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
}
