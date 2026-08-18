import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeUpdateResult { success, noChange }

/// Thrown when a theme mode save operation fails.
class ThemeModePersistenceException implements Exception {
  const ThemeModePersistenceException();
}

abstract class ThemeModeStore {
  ThemeMode read();
  Future<void> save(ThemeMode mode);
}

/// [ThemeModeStore] backed by [SharedPreferences].
///
/// Persists the selected [ThemeMode] under the key `'theme_mode_v1'`.
class SharedPreferencesThemeModeStore implements ThemeModeStore {
  SharedPreferencesThemeModeStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'theme_mode_v1';

  @override
  ThemeMode read() {
    final raw = _prefs.getString(_key);
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_key, value);
  }
}

/// Provider for the active [ThemeModeStore].
///
/// Override in tests or at app startup with the desired implementation.
final themeModeStoreProvider = Provider<ThemeModeStore>((ref) {
  throw UnimplementedError(
    'themeModeStoreProvider must be overridden before use.',
  );
});

class ThemeModeState {
  final ThemeMode mode;
  final bool isUpdating;

  const ThemeModeState({required this.mode, required this.isUpdating});
}

class ThemeModeController {
  final ThemeModeStore _store;
  bool _isSaving = false;

  late ThemeModeState _state;
  ThemeModeState get state => _state;

  ThemeModeController(this._store)
    : _state = ThemeModeState(mode: _store.read(), isUpdating: false);

  Future<ThemeModeUpdateResult> updateTheme(ThemeMode mode) async {
    if (_isSaving) {
      return ThemeModeUpdateResult.noChange;
    }

    _isSaving = true;
    _state = ThemeModeState(mode: mode, isUpdating: true);

    try {
      await _store.save(mode);
      return ThemeModeUpdateResult.success;
    } finally {
      _isSaving = false;
      _state = ThemeModeState(mode: mode, isUpdating: false);
    }
  }
}
