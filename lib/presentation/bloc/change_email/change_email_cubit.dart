import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/usecases/auth/update_email_usecase.dart';
import 'change_email_state.dart';

/// Cubit for change email flow.
class ChangeEmailCubit extends Cubit<ChangeEmailState> {
  ChangeEmailCubit(this._updateEmail) : super(const ChangeEmailState());

  final UpdateEmailUseCase _updateEmail;

  Future<void> submit(String newEmail, String currentPassword) async {
    final emailError = Validators.email(newEmail);
    if (emailError != null) {
      emit(state.copyWith(error: emailError));
      return;
    }
    if (currentPassword.isEmpty) {
      emit(state.copyWith(error: 'Password is required'));
      return;
    }
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _updateEmail(newEmail, currentPassword);
      emit(state.copyWith(isSubmitting: false, success: true, error: null));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception:', '').trim();
      emit(state.copyWith(isSubmitting: false, error: msg));
    }
  }
}
