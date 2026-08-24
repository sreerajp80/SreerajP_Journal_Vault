import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading and appearance theme modes supported in SreerajP Journal Vault.
enum AppThemeMode {
  system,
  light,
  sepia,
  dark,
  oled;

  /// Returns standard Flutter [ThemeMode] matching this theme.
  ThemeMode toFlutterThemeMode() {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light || AppThemeMode.sepia => ThemeMode.light,
      AppThemeMode.dark || AppThemeMode.oled => ThemeMode.dark,
    };
  }

  /// Whether this theme represents a dark reading surface.
  bool get isDarkSurface =>
      this == AppThemeMode.dark || this == AppThemeMode.oled;

  /// Whether this theme is the warm parchment / sepia reading theme.
  bool get isSepia => this == AppThemeMode.sepia;

  /// Whether this theme is the pitch-black OLED theme.
  bool get isOled => this == AppThemeMode.oled;
}

enum ThemeModeUpdateResult { success, noChange }

/// Thrown when a theme mode save operation fails.
class ThemeModePersistenceException implements Exception {
  const ThemeModePersistenceException();
}

abstract class ThemeModeStore {
  ThemeMode read();
  Future<void> save(ThemeMode mode);

  AppThemeMode readAppThemeMode() {
    final m = read();
    return switch (m) {
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.system => AppThemeMode.system,
    };
  }

  Future<void> saveAppThemeMode(AppThemeMode mode) async {
    await save(mode.toFlutterThemeMode());
  }
}

/// [ThemeModeStore] backed by [SharedPreferences].
///
/// Persists the selected [AppThemeMode] under `'app_theme_mode_v1'` and
/// maintains backwards compatibility with `'theme_mode_v1'`.
class SharedPreferencesThemeModeStore implements ThemeModeStore {
  SharedPreferencesThemeModeStore(this._prefs);

  final SharedPreferences _prefs;
  static const _legacyKey = 'theme_mode_v1';
  static const _appThemeKey = 'app_theme_mode_v1';

  @override
  ThemeMode read() {
    return readAppThemeMode().toFlutterThemeMode();
  }

  @override
  AppThemeMode readAppThemeMode() {
    final rawApp = _prefs.getString(_appThemeKey);
    if (rawApp != null) {
      return switch (rawApp) {
        'sepia' => AppThemeMode.sepia,
        'oled' => AppThemeMode.oled,
        'dark' => AppThemeMode.dark,
        'light' => AppThemeMode.light,
        _ => AppThemeMode.system,
      };
    }
    final rawLegacy = _prefs.getString(_legacyKey);
    return switch (rawLegacy) {
      'dark' => AppThemeMode.dark,
      'light' => AppThemeMode.light,
      _ => AppThemeMode.system,
    };
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final appMode = switch (mode) {
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.system => AppThemeMode.system,
    };
    await saveAppThemeMode(appMode);
  }

  @override
  Future<void> saveAppThemeMode(AppThemeMode mode) async {
    final appValue = switch (mode) {
      AppThemeMode.sepia => 'sepia',
      AppThemeMode.oled => 'oled',
      AppThemeMode.dark => 'dark',
      AppThemeMode.light => 'light',
      AppThemeMode.system => 'system',
    };
    await _prefs.setString(_appThemeKey, appValue);
    await _prefs.setString(_legacyKey, mode.toFlutterThemeMode().name);
  }
}

class InMemoryThemeModeStore implements ThemeModeStore {
  InMemoryThemeModeStore([AppThemeMode initialMode = AppThemeMode.light])
    : _appMode = initialMode;

  AppThemeMode _appMode;

  @override
  ThemeMode read() => _appMode.toFlutterThemeMode();

  @override
  AppThemeMode readAppThemeMode() => _appMode;

  @override
  Future<void> save(ThemeMode mode) async {
    _appMode = switch (mode) {
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.system => AppThemeMode.system,
    };
  }

  @override
  Future<void> saveAppThemeMode(AppThemeMode mode) async {
    _appMode = mode;
  }
}

/// Provider for the active [ThemeModeStore].
final themeModeStoreProvider = Provider<ThemeModeStore>((ref) {
  return InMemoryThemeModeStore();
});

class AppThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    try {
      return ref.watch(themeModeStoreProvider).readAppThemeMode();
    } catch (_) {
      return AppThemeMode.system;
    }
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    final prev = state;
    state = mode;
    try {
      final store = ref.read(themeModeStoreProvider);
      await store.saveAppThemeMode(mode);
    } catch (_) {
      state = prev;
      rethrow;
    }
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, AppThemeMode>(
      AppThemeModeNotifier.new,
    );

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final appTheme = ref.watch(appThemeModeProvider);
    return appTheme.toFlutterThemeMode();
  }

  Future<void> setMode(ThemeMode mode) async {
    final appMode = switch (mode) {
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.system => AppThemeMode.system,
    };
    await ref.read(appThemeModeProvider.notifier).setAppThemeMode(appMode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

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
