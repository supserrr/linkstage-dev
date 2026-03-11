import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

const _keyThemeMode = 'theme_mode';
const _keyNotifications = 'notifications_enabled';
const _keyLanguage = 'language';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs)
    : super(
        SettingsState(
          themeMode: _themeModeFromIndex(_prefs.getInt(_keyThemeMode) ?? 0),
          notificationsEnabled: _prefs.getBool(_keyNotifications) ?? true,
          language: _prefs.getString(_keyLanguage) ?? 'en',
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
}
