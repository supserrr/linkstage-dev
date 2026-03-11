import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

/// Implementation of [UserRepository] using Firestore.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<UserEntity?> getUser(String userId) => _remote.getUser(userId);

  @override
  Future<void> upsertUser(UserEntity user) => _remote.upsertUser(user);

  @override
  Future<void> updateRole(String userId, UserRole role) =>
      _remote.updateRole(userId, role);

  @override
  Future<bool> checkUsernameAvailable(String username, {String? excludeUserId}) =>
      _remote.checkUsernameAvailable(username, excludeUserId: excludeUserId);

  @override
  Future<void> updateUsername(
    String userId,
    String newUsername,
    DateTime lastUsernameChangeAt,
  ) =>
      _remote.updateUsername(userId, newUsername, lastUsernameChangeAt);

  @override
  Stream<UserEntity?> watchUser(String userId) => _remote.watchUser(userId);
}
