import '../entities/booking_entity.dart';

/// Abstract contract for booking operations.
abstract class BookingRepository {
  /// Fetch completed bookings for a creative (for total gigs count).
  Future<List<BookingEntity>> getCompletedBookingsByCreativeId(String creativeId);

  /// Fetch completed bookings for a planner.
  Future<List<BookingEntity>> getCompletedBookingsByPlannerId(String plannerId);
}
