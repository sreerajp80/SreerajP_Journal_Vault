import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';

void main() {
  test('ThemeModeController ignores repeated updates while saving', () async {
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
}

class _DelayedThemeModeStore implements ThemeModeStore {
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
