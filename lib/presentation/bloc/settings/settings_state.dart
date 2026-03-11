import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String language;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}
