import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

/// Implementation of [EventRepository] using Firestore.
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._remote);

  final EventRemoteDataSource _remote;

  @override
  Stream<List<EventEntity>> getEventsByPlannerId(String plannerId) =>
      _remote.getEventsByPlannerId(plannerId);

  @override
  Future<List<EventEntity>> fetchEventsByPlannerId(String plannerId) =>
      _remote.fetchEventsByPlannerId(plannerId);
}
