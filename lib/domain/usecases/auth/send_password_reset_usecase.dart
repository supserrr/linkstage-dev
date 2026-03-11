import '../../repositories/auth_repository.dart';

/// Use case: send password reset email.
class SendPasswordResetUseCase {
  SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
