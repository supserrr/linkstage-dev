import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkstage/domain/entities/user_entity.dart';
import 'package:linkstage/domain/repositories/auth_repository.dart';
import 'package:linkstage/domain/usecases/auth/register_with_email_usecase.dart';
import 'package:linkstage/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:linkstage/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:linkstage/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:linkstage/domain/usecases/auth/sign_out_usecase.dart';
import 'package:linkstage/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkstage/presentation/bloc/auth/auth_event.dart';
import 'package:linkstage/presentation/bloc/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeAuthRepository extends Fake implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthRepository());
  });

  group('AuthBloc', () {
    const testUser = UserEntity(id: '1', email: 'test@test.com');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
      build: () {
        final mock = MockAuthRepository();
        when(
          () => mock.signInWithEmail(any(), any()),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(
          signInWithEmail: SignInWithEmailUseCase(mock),
          registerWithEmail: RegisterWithEmailUseCase(mock),
          signInWithGoogle: SignInWithGoogleUseCase(mock),
          sendPasswordReset: SendPasswordResetUseCase(mock),
          signOut: SignOutUseCase(mock),
        );
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(
          email: 'test@test.com',
          password: 'password123',
        ),
      ),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        final mock = MockAuthRepository();
        when(
          () => mock.signInWithEmail(any(), any()),
        ).thenThrow(Exception('Invalid credentials'));
        return AuthBloc(
          signInWithEmail: SignInWithEmailUseCase(mock),
          registerWithEmail: RegisterWithEmailUseCase(mock),
          signInWithGoogle: SignInWithGoogleUseCase(mock),
          sendPasswordReset: SendPasswordResetUseCase(mock),
          signOut: SignOutUseCase(mock),
        );
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(
          email: 'test@test.com',
          password: 'wrong',
        ),
      ),
      expect: () => [const AuthLoading(), isA<AuthError>()],
    );
  });
}
