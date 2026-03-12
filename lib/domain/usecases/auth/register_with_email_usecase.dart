import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case: register with email, password, and display name.
class RegisterWithEmailUseCase {
  RegisterWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call(String email, String password, [String? displayName]) {
    return _repository.registerWithEmail(email, password, displayName);
  }
}
