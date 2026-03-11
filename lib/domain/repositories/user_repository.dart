import '../entities/user_entity.dart';

/// Abstract contract for user document operations.
abstract class UserRepository {
  /// Get user by ID.
  Future<UserEntity?> getUser(String userId);

  /// Create or update user document.
  Future<void> upsertUser(UserEntity user);

  /// Update user role.
  Future<void> updateRole(String userId, UserRole role);

  /// Check if username is available.
  /// [excludeUserId] when changing username: exclude own profile from uniqueness check.
  Future<bool> checkUsernameAvailable(String username, {String? excludeUserId});

  /// Update username and lastUsernameChangeAt (for username change flow).
  Future<void> updateUsername(
    String userId,
    String newUsername,
    DateTime lastUsernameChangeAt,
  );

  /// Stream of user document for real-time updates.
  Stream<UserEntity?> watchUser(String userId);
}
