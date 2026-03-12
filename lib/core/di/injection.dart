import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth/register_with_email_usecase.dart';
import '../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/update_email_usecase.dart';
import '../../domain/usecases/user/change_username_usecase.dart';
import '../../domain/usecases/user/upsert_user_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/onboarding/onboarding_cubit.dart';
import '../../presentation/bloc/onboarding/profile_setup_draft_storage.dart';
import '../../presentation/bloc/settings/settings_cubit.dart';
import '../router/auth_redirect.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Initialize dependency injection.
Future<void> initInjection() async {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(AuthRemoteDataSource.new);
  sl.registerLazySingleton<UserRemoteDataSource>(UserRemoteDataSource.new);
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    ProfileRemoteDataSource.new,
  );
  sl.registerLazySingleton<EventRemoteDataSource>(EventRemoteDataSource.new);
  sl.registerLazySingleton<ReviewRemoteDataSource>(ReviewRemoteDataSource.new);
  sl.registerLazySingleton<BookingRemoteDataSource>(
    BookingRemoteDataSource.new,
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(sl<EventRemoteDataSource>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl<BookingRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => RegisterWithEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => SendPasswordResetUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpsertUserUseCase(sl<UserRepository>()));
  sl.registerLazySingleton(
    () => ChangeUsernameUseCase(
      sl<UserRepository>(),
      sl<ProfileRepository>(),
    ),
  );

  // Blocs (singleton so auth state is shared app-wide)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signInWithEmail: sl<SignInWithEmailUseCase>(),
      registerWithEmail: sl<RegisterWithEmailUseCase>(),
      signInWithGoogle: sl<SignInWithGoogleUseCase>(),
      sendPasswordReset: sl<SendPasswordResetUseCase>(),
      signOut: sl<SignOutUseCase>(),
    ),
  );

  // Settings (requires async SharedPreferences)
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(prefs));
  sl.registerLazySingleton<OnboardingCubit>(() => OnboardingCubit(prefs));
  sl.registerLazySingleton<ProfileSetupDraftStorage>(
    () => ProfileSetupDraftStorage(prefs),
  );

  // Router refresh (must be registered after AuthRepository)
  sl.registerLazySingleton<AuthRedirectNotifier>(
    () => AuthRedirectNotifier(
      sl<AuthRepository>(),
      sl<UserRepository>(),
      sl<ProfileRepository>(),
    ),
  );
  sl.registerLazySingleton<SplashNotifier>(SplashNotifier.new);
}
