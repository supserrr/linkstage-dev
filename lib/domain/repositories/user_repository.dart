import '../entities/profile_entity.dart';
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

  /// Atomically change username: check availability, create new profile,
  /// delete old profile, update users. Prevents TOCTOU race.
  Future<void> changeUsernameAtomic(
    String userId,
    String newUsername,
    String? oldUsername,
    ProfileEntity newProfileData,
    DateTime lastUsernameChangeAt,
  );

  /// Stream of user document for real-time updates.
  Stream<UserEntity?> watchUser(String userId);
}
