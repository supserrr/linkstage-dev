import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

const _keyThemeMode = 'theme_mode';
const _keyNotifications = 'notifications_enabled';
const _keyLanguage = 'language';
const _keyProfileVisibility = 'profile_visibility';
const _keyWhoCanMessage = 'who_can_message';
const _keyShowOnlineStatus = 'show_online_status';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs)
    : super(
        SettingsState(
          themeMode: _themeModeFromIndex(_prefs.getInt(_keyThemeMode) ?? 0),
          notificationsEnabled: _prefs.getBool(_keyNotifications) ?? true,
          language: _prefs.getString(_keyLanguage) ?? 'en',
          profileVisibility: _profileVisibilityFromIndex(
            _prefs.getInt(_keyProfileVisibility) ?? 0,
          ),
          whoCanMessage: _whoCanMessageFromIndex(
            _prefs.getInt(_keyWhoCanMessage) ?? 0,
          ),
          showOnlineStatus: _prefs.getBool(_keyShowOnlineStatus) ?? true,
        ),
      );

  final SharedPreferences _prefs;

  static ThemeMode _themeModeFromIndex(int i) {
    switch (i) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static int _themeModeToIndex(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, _themeModeToIndex(mode));
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_keyLanguage, code);
    emit(state.copyWith(language: code));
  }

  static ProfileVisibility _profileVisibilityFromIndex(int i) {
    switch (i) {
      case 1:
        return ProfileVisibility.connectionsOnly;
      case 2:
        return ProfileVisibility.onlyMe;
      default:
        return ProfileVisibility.everyone;
    }
  }

  static int _profileVisibilityToIndex(ProfileVisibility v) {
    switch (v) {
      case ProfileVisibility.connectionsOnly:
        return 1;
      case ProfileVisibility.onlyMe:
        return 2;
      default:
        return 0;
    }
  }

  static WhoCanMessage _whoCanMessageFromIndex(int i) {
    switch (i) {
      case 1:
        return WhoCanMessage.workedWith;
      case 2:
        return WhoCanMessage.noOne;
      default:
        return WhoCanMessage.everyone;
    }
  }

  static int _whoCanMessageToIndex(WhoCanMessage v) {
    switch (v) {
      case WhoCanMessage.workedWith:
        return 1;
      case WhoCanMessage.noOne:
        return 2;
      default:
        return 0;
    }
  }

  Future<void> setProfileVisibility(ProfileVisibility v) async {
    await _prefs.setInt(_keyProfileVisibility, _profileVisibilityToIndex(v));
    emit(state.copyWith(profileVisibility: v));
  }

  Future<void> setWhoCanMessage(WhoCanMessage v) async {
    await _prefs.setInt(_keyWhoCanMessage, _whoCanMessageToIndex(v));
    emit(state.copyWith(whoCanMessage: v));
  }

  Future<void> setShowOnlineStatus(bool v) async {
    await _prefs.setBool(_keyShowOnlineStatus, v);
    emit(state.copyWith(showOnlineStatus: v));
  }
}
