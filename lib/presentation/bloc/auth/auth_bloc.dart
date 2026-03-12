import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth/register_with_email_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithEmailUseCase signInWithEmail,
    required RegisterWithEmailUseCase registerWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SendPasswordResetUseCase sendPasswordReset,
    required SignOutUseCase signOut,
  }) : _signInWithEmail = signInWithEmail,
       _registerWithEmail = registerWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordReset = sendPasswordReset,
       _signOut = signOut,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final SignInWithEmailUseCase _signInWithEmail;
  final RegisterWithEmailUseCase _registerWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SendPasswordResetUseCase _sendPasswordReset;
  final SignOutUseCase _signOut;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Auth state is handled by stream in app; this is for explicit check.
    emit(const AuthInitial());
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithEmail(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _registerWithEmail(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _sendPasswordReset(event.email);
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  String _authErrorMessage(Object e) {
    final s = e.toString();
    if (s.contains('user-not-found') || s.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (s.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (s.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (s.contains('invalid-email')) {
      return 'Invalid email address.';
    }
    if (s.contains('cancelled')) {
      return 'Sign in was cancelled.';
    }
    return 'An error occurred. Please try again.';
  }
}
