import '../entities/user_entity.dart';

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  /// Stream of current user; emits null when logged out.
  Stream<UserEntity?> get authStateChanges;

  /// Current user or null.
  UserEntity? get currentUser;

  /// Sign in with email and password.
  Future<UserEntity> signInWithEmail(String email, String password);

  /// Register with email and password.
  /// [displayName] optional; falls back to email local part if omitted.
  Future<UserEntity> registerWithEmail(
    String email,
    String password, [
    String? displayName,
  ]);

  /// Sign in with Google.
  Future<UserEntity> signInWithGoogle();

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out.
  Future<void> signOut();
}
