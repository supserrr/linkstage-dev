import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user/upsert_user_usecase.dart';
import 'profile_setup_state.dart';

/// Manages profile setup flow state and persistence.
class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit(
    this._user,
    this._upsertUser,
    this._profileRepository,
    this._userRepository,
  ) : super(ProfileSetupState.initial()) {
    _loadInitial();
  }

  final UserEntity _user;
  final UpsertUserUseCase _upsertUser;
  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  void _loadInitial() {
    emit(state.copyWith(
      displayName: _user.displayName ?? '',
      isLoading: false,
    ));
  }

  void setUsername(String value) => emit(state.copyWith(username: value));

  void setPhoto(File? file) => emit(state.copyWith(photoFile: file));

  void setDisplayName(String value) => emit(state.copyWith(displayName: value));

  void setBio(String value) => emit(state.copyWith(bio: value));

  void setLocation(String value) => emit(state.copyWith(location: value));

  void setCategory(ProfileCategory? value) =>
      emit(state.copyWith(category: value));

  void setPriceRange(String value) => emit(state.copyWith(priceRange: value));

  Future<bool> checkUsernameAvailable(String username) async {
    if (username.length < 3) return false;
    return _userRepository.checkUsernameAvailable(username);
  }

  Future<void> submit() async {
    if (state.username == null || state.username!.isEmpty) {
      emit(state.copyWith(error: 'Username is required'));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final username = state.username!.toLowerCase().trim();
      final userWithUsername = UserEntity(
        id: _user.id,
        email: _user.email,
        username: username,
        displayName: state.displayName.isNotEmpty ? state.displayName : username,
        photoUrl: _user.photoUrl,
        role: _user.role,
      );
      await _upsertUser(userWithUsername);

      final profile = ProfileEntity(
        id: username,
        userId: _user.id,
        username: username,
        bio: state.bio,
        category: state.category,
        priceRange: state.priceRange,
        location: state.location,
        displayName:
            state.displayName.isNotEmpty ? state.displayName : username,
      );
      await _profileRepository.upsertProfile(profile);

      emit(state.copyWith(isLoading: false, success: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
