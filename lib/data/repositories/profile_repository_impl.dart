import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// Implementation of [ProfileRepository] using Firestore.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Stream<List<ProfileEntity>> getProfiles({
    ProfileCategory? category,
    String? location,
    int limit = 20,
  }) =>
      _remote.getProfiles(
        category: category,
        location: location,
        limit: limit,
      );

  @override
  Future<ProfileEntity?> getProfile(String username) =>
      _remote.getProfile(username);

  @override
  Future<ProfileEntity?> getProfileByUserId(String userId) =>
      _remote.getProfileByUserId(userId);

  @override
  Stream<ProfileEntity?> watchProfile(String username) =>
      _remote.watchProfile(username);

  @override
  Future<void> upsertProfile(ProfileEntity profile) =>
      _remote.upsertProfile(profile);

  @override
  Future<void> deleteProfile(String username) => _remote.deleteProfile(username);
}
