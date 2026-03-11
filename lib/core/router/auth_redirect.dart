import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Wraps OnboardingCubit to expose Listenable for router refresh.
class OnboardingListenable extends ChangeNotifier {
  OnboardingListenable(this._cubit) {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  final dynamic _cubit;
  late final StreamSubscription<dynamic> _subscription;

  bool get introComplete => _cubit.introComplete;
  bool get profileComplete => _cubit.profileComplete;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Notifier that completes after a minimum display duration (e.g. for splash).
class SplashNotifier extends ChangeNotifier {
  SplashNotifier() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!_isComplete) {
        _isComplete = true;
        notifyListeners();
      }
    });
  }

  bool _isComplete = false;
  bool get isComplete => _isComplete;
}

/// Notifier for router refresh when auth state changes.
class AuthRedirectNotifier extends ChangeNotifier {
  AuthRedirectNotifier(
    this._authRepository,
    this._userRepository,
    this._profileRepository,
  ) {
    _subscription = _authRepository.authStateChanges.listen((_) {
      _refreshUserAndProfile();
    });
    _refreshUserAndProfile();
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;
  late final StreamSubscription<dynamic> _subscription;

  UserEntity? _user;
  ProfileEntity? _profile;
  bool _loading = true;

  bool get isAuthenticated => _authRepository.currentUser != null;

  UserEntity? get user => _user;

  bool get isReady => !_loading;

  bool get needsRoleSelection =>
      isAuthenticated && _user != null && _user!.role == null;

  bool get needsProfileSetup {
    if (!isAuthenticated || _user == null || _user!.role == null) {
      return false;
    }
    return _profile == null;
  }

  Future<void> refresh() => _refreshUserAndProfile();

  Future<void> _refreshUserAndProfile() async {
    final authUser = _authRepository.currentUser;
    if (authUser == null) {
      _user = null;
      _profile = null;
      _loading = false;
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _user = await _userRepository.getUser(authUser.id);
      if (_user != null && _user!.role != null) {
        _profile = await _profileRepository.getProfileByUserId(_user!.id);
      } else {
        _profile = null;
      }
    } catch (_) {
      _user = null;
      _profile = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
