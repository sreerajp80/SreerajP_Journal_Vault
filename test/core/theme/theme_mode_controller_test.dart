import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';

void main() {
  group('ThemeModeController', () {
    test('ignores repeated updates while saving', () async {
      final store = _DelayedThemeModeStore();
      final controller = ThemeModeController(store);

      final firstUpdate = controller.updateTheme(ThemeMode.dark);

      expect(controller.state.mode, ThemeMode.dark);
      expect(controller.state.isUpdating, isTrue);
      expect(store.saveCount, 1);

      final secondResult = await controller.updateTheme(ThemeMode.light);
      expect(secondResult, ThemeModeUpdateResult.noChange);
      expect(store.saveCount, 1);

      store.complete();

      expect(await firstUpdate, ThemeModeUpdateResult.success);
      expect(controller.state.mode, ThemeMode.dark);
      expect(controller.state.isUpdating, isFalse);
    });
  });

  group('AppThemeMode properties', () {
    test('maps correctly to Flutter ThemeMode and booleans', () {
      expect(AppThemeMode.system.toFlutterThemeMode(), ThemeMode.system);
      expect(AppThemeMode.system.isDarkSurface, isFalse);
      expect(AppThemeMode.system.isSepia, isFalse);
      expect(AppThemeMode.system.isOled, isFalse);

      expect(AppThemeMode.light.toFlutterThemeMode(), ThemeMode.light);
      expect(AppThemeMode.light.isDarkSurface, isFalse);

      expect(AppThemeMode.sepia.toFlutterThemeMode(), ThemeMode.light);
      expect(AppThemeMode.sepia.isDarkSurface, isFalse);
      expect(AppThemeMode.sepia.isSepia, isTrue);

      expect(AppThemeMode.dark.toFlutterThemeMode(), ThemeMode.dark);
      expect(AppThemeMode.dark.isDarkSurface, isTrue);

      expect(AppThemeMode.oled.toFlutterThemeMode(), ThemeMode.dark);
      expect(AppThemeMode.oled.isDarkSurface, isTrue);
      expect(AppThemeMode.oled.isOled, isTrue);
    });
  });

  group('SharedPreferencesThemeModeStore', () {
    test('persists and restores AppThemeMode accurately', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = SharedPreferencesThemeModeStore(prefs);

      expect(store.readAppThemeMode(), AppThemeMode.system);
      expect(store.read(), ThemeMode.system);

      await store.saveAppThemeMode(AppThemeMode.sepia);
      expect(prefs.getString('app_theme_mode_v1'), 'sepia');
      expect(prefs.getString('theme_mode_v1'), 'light');
      expect(store.readAppThemeMode(), AppThemeMode.sepia);
      expect(store.read(), ThemeMode.light);

      await store.saveAppThemeMode(AppThemeMode.oled);
      expect(prefs.getString('app_theme_mode_v1'), 'oled');
      expect(prefs.getString('theme_mode_v1'), 'dark');
      expect(store.readAppThemeMode(), AppThemeMode.oled);
      expect(store.read(), ThemeMode.dark);
    });

    test(
      'falls back gracefully to legacy theme_mode_v1 if app_theme_mode_v1 is absent',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'theme_mode_v1': 'dark',
        });
        final prefs = await SharedPreferences.getInstance();
        final store = SharedPreferencesThemeModeStore(prefs);

        expect(store.readAppThemeMode(), AppThemeMode.dark);
        expect(store.read(), ThemeMode.dark);
      },
    );
  });
}

class _DelayedThemeModeStore extends ThemeModeStore {
  ThemeMode _mode = ThemeMode.light;
  final Completer<void> _completer = Completer<void>();
  int saveCount = 0;

  @override
  ThemeMode read() => _mode;

  @override
  Future<void> save(ThemeMode mode) async {
    saveCount += 1;
    await _completer.future;
    _mode = mode;
  }

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
