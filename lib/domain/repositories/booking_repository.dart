import '../entities/booking_entity.dart';

/// Abstract contract for booking operations.
abstract class BookingRepository {
  /// Fetch completed bookings for a creative (for total gigs count).
  Future<List<BookingEntity>> getCompletedBookingsByCreativeId(String creativeId);

  /// Fetch completed bookings for a planner.
  Future<List<BookingEntity>> getCompletedBookingsByPlannerId(String plannerId);

  /// Fetch pending bookings for a planner (applicants, recent proposals).
  Future<List<BookingEntity>> getPendingBookingsByPlannerId(String plannerId);

  /// Stream of pending bookings for a planner (real-time updates).
  Stream<List<BookingEntity>> watchPendingBookingsByPlannerId(String plannerId);

  /// Stream of completed bookings for a creative (real-time updates).
  Stream<List<BookingEntity>> watchCompletedBookingsByCreativeId(
    String creativeId,
  );
}
