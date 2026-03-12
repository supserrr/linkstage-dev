import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] using Firebase Auth.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  @override
  UserEntity? get currentUser => _remote.currentUser;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) {
    return _remote.signInWithEmail(email, password);
  }

  @override
  Future<UserEntity> registerWithEmail(
    String email,
    String password, [
    String? displayName,
  ]) {
    return _remote.registerWithEmail(email, password, displayName);
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return _remote.signInWithGoogle();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remote.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _remote.signOut();
  }
}
