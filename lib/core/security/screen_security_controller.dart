import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

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

  /// Applies [enabled] to the live window only. The saved choice is not
  /// changed, and the next app start applies the saved choice again.
  Future<void> apply({required bool enabled});
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

  @override
  Future<void> apply({required bool enabled}) => _channel.invokeMethod<void>(
    'applyScreenSecurity',
    <String, Object?>{'enabled': enabled},
  );
}

/// In-memory [ScreenSecurityStore] for tests and non-Android hosts.
class InMemoryScreenSecurityStore implements ScreenSecurityStore {
  InMemoryScreenSecurityStore({this.enabled = true}) : liveEnabled = enabled;

  /// The saved choice.
  bool enabled;

  /// What the live window shows now.
  bool liveEnabled;

  @override
  Future<bool> read() async => enabled;

  @override
  Future<void> write({required bool enabled}) async {
    this.enabled = enabled;
    liveEnabled = enabled;
  }

  @override
  Future<void> apply({required bool enabled}) async => liveEnabled = enabled;
}

/// The active [ScreenSecurityStore]. `main.dart` overrides this with the
/// method-channel store; tests and other hosts get the in-memory default.
final screenSecurityStoreProvider = Provider<ScreenSecurityStore>((ref) {
  return InMemoryScreenSecurityStore();
});

/// Holds whether screenshot protection is on, and changes it.
///
/// The state is the user's **saved** choice. Only the Settings switch changes
/// it. A screen that shows a secret (a pairing code or QR) instead calls
/// [holdOn] while it is open and [releaseHold] when it closes: protection is
/// then on for the live window only, and the saved choice is left alone.
///
/// Knows nothing about `BuildContext`, navigation or UI strings — the Settings
/// screen owns the dialog, the snackbar and the wording.
class ScreenSecurityController extends AsyncNotifier<bool> {
  /// How many open screens hold protection on.
  int _holds = 0;

  @override
  Future<bool> build() => ref.read(screenSecurityStoreProvider).read();

  /// Saves and applies [enabled]. On failure the previous value is restored
  /// and a [ScreenSecurityPersistenceException] is thrown for the caller to
  /// report.
  ///
  /// While a screen holds protection on, the new choice is saved but the live
  /// window stays protected until the last hold is released.
  Future<void> setEnabled(bool enabled) async {
    final previous = state.value ?? true;
    if (previous == enabled) return;

    final store = ref.read(screenSecurityStoreProvider);
    state = AsyncData(enabled);
    try {
      await store.write(enabled: enabled);
    } catch (_) {
      state = AsyncData(previous);
      throw const ScreenSecurityPersistenceException();
    }
    if (_holds > 0 && !enabled) await _applyLive(store, true);
  }

  /// Turns protection on for the live window while a screen that shows a
  /// secret is open, whatever the saved choice. Saves nothing. Pair every
  /// call with [releaseHold]. Never throws.
  Future<void> holdOn() async {
    _holds++;
    if (_holds > 1) return;
    await _applyLive(ref.read(screenSecurityStoreProvider), true);
  }

  /// Ends one [holdOn]. When the last hold ends, the live window goes back to
  /// the saved choice. Never throws.
  Future<void> releaseHold() async {
    if (_holds == 0) return;
    _holds--;
    if (_holds > 0) return;
    final store = ref.read(screenSecurityStoreProvider);
    bool saved;
    try {
      saved = await future;
    } catch (_) {
      saved = true;
    }
    // A new hold may have started while the saved choice was read.
    if (_holds > 0) return;
    await _applyLive(store, saved);
  }

  Future<void> _applyLive(ScreenSecurityStore store, bool enabled) async {
    try {
      await store.apply(enabled: enabled);
    } catch (e) {
      AppLogger.error('ScreenSecurity: live window not updated', error: e);
    }
  }
}

final screenSecurityProvider =
    AsyncNotifierProvider<ScreenSecurityController, bool>(
      ScreenSecurityController.new,
    );
