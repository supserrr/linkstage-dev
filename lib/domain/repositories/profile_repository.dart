import '../entities/profile_entity.dart';

/// Abstract contract for profile operations.
abstract class ProfileRepository {
  /// Stream of profiles (for discovery).
  Stream<List<ProfileEntity>> getProfiles({
    ProfileCategory? category,
    String? location,
    int limit = 20,
  });

  /// Get profile by username (doc ID).
  Future<ProfileEntity?> getProfile(String username);

  /// Get profile by user ID.
  Future<ProfileEntity?> getProfileByUserId(String userId);

  /// Stream of single profile for real-time updates.
  Stream<ProfileEntity?> watchProfile(String username);

  /// Create or update profile.
  Future<void> upsertProfile(ProfileEntity profile);

  /// Delete profile by username (used when migrating during username change).
  Future<void> deleteProfile(String username);
}
