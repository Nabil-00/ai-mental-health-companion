import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState {
  final bool darkMode;
  final bool notificationsEnabled;

  const AppSettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
  });

  AppSettingsState copyWith({bool? darkMode, bool? notificationsEnabled}) {
    return AppSettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  static const _darkModeKey = 'settings.dark_mode';
  static const _notificationsKey = 'settings.notifications';

  AppSettingsNotifier() : super(const AppSettingsState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      darkMode: prefs.getBool(_darkModeKey) ?? state.darkMode,
      notificationsEnabled:
          prefs.getBool(_notificationsKey) ?? state.notificationsEnabled,
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(darkMode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
      return AppSettingsNotifier();
    });
