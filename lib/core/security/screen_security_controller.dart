import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thrown when the screenshot-protection choice cannot be saved.
class ScreenSecurityPersistenceException implements Exception {
  const ScreenSecurityPersistenceException();
}

/// Reads and writes the user's screenshot-protection choice.
///
/// The value lives on the native side, because `MainActivity.onCreate` has to
/// know it before the first frame is drawn.
abstract class ScreenSecurityStore {
  /// `true` when screenshots, screen recording and the task-switcher preview
  /// are blocked. Protection is the default.
  Future<bool> read();

  /// Saves the choice and applies it to the live window at once.
  Future<void> write({required bool enabled});
}

/// [ScreenSecurityStore] backed by the `sreerajp.journal_vault/screen_security`
/// MethodChannel implemented in `MainActivity.kt`.
class MethodChannelScreenSecurityStore implements ScreenSecurityStore {
  MethodChannelScreenSecurityStore({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('sreerajp.journal_vault/screen_security');

  final MethodChannel _channel;

  @override
  Future<bool> read() async {
    final enabled = await _channel.invokeMethod<bool>(
      'isScreenSecurityEnabled',
    );
    // A host without the channel answers null. Err on the protected side.
    return enabled ?? true;
  }

  @override
  Future<void> write({required bool enabled}) async {
    try {
      await _channel.invokeMethod<void>(
        'setScreenSecurityEnabled',
        <String, Object?>{'enabled': enabled},
      );
    } on PlatformException {
      throw const ScreenSecurityPersistenceException();
    } on MissingPluginException {
      throw const ScreenSecurityPersistenceException();
    }
  }
}

/// In-memory [ScreenSecurityStore] for tests and non-Android hosts.
class InMemoryScreenSecurityStore implements ScreenSecurityStore {
  InMemoryScreenSecurityStore({this.enabled = true});

  bool enabled;

  @override
  Future<bool> read() async => enabled;

  @override
  Future<void> write({required bool enabled}) async => this.enabled = enabled;
}

/// The active [ScreenSecurityStore]. `main.dart` overrides this with the
/// method-channel store; tests and other hosts get the in-memory default.
final screenSecurityStoreProvider = Provider<ScreenSecurityStore>((ref) {
  return InMemoryScreenSecurityStore();
});

/// Holds whether screenshot protection is on, and changes it.
///
/// Knows nothing about `BuildContext`, navigation or UI strings — the Settings
/// screen owns the dialog, the snackbar and the wording.
class ScreenSecurityController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(screenSecurityStoreProvider).read();

  /// Applies [enabled]. On failure the previous value is restored and a
  /// [ScreenSecurityPersistenceException] is thrown for the caller to report.
  Future<void> setEnabled(bool enabled) async {
    final previous = state.value ?? true;
    if (previous == enabled) return;

    state = AsyncData(enabled);
    try {
      await ref.read(screenSecurityStoreProvider).write(enabled: enabled);
    } catch (_) {
      state = AsyncData(previous);
      throw const ScreenSecurityPersistenceException();
    }
  }
}

final screenSecurityProvider =
    AsyncNotifierProvider<ScreenSecurityController, bool>(
      ScreenSecurityController.new,
    );
