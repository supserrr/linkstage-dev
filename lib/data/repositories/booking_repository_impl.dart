import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

/// Implementation of [BookingRepository] using Firestore.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<List<BookingEntity>> getCompletedBookingsByCreativeId(
    String creativeId,
  ) =>
      _remote.getCompletedBookingsByCreativeId(creativeId);

  @override
  Future<List<BookingEntity>> getCompletedBookingsByPlannerId(
    String plannerId,
  ) =>
      _remote.getCompletedBookingsByPlannerId(plannerId);

  @override
  Future<List<BookingEntity>> getPendingBookingsByPlannerId(
    String plannerId,
  ) =>
      _remote.getPendingBookingsByPlannerId(plannerId);

  @override
  Stream<List<BookingEntity>> watchPendingBookingsByPlannerId(
    String plannerId,
  ) =>
      _remote.watchPendingBookingsByPlannerId(plannerId);

  @override
  Stream<List<BookingEntity>> watchCompletedBookingsByCreativeId(
    String creativeId,
  ) =>
      _remote.watchCompletedBookingsByCreativeId(creativeId);
}
