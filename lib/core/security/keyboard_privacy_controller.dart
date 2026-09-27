import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

// Layer: core (security state).
//
// Keyboard privacy asks the keyboard not to learn from what is typed in the
// app (Android's IME_FLAG_NO_PERSONALIZED_LEARNING), so journal words do not
// end up in its personal dictionary or its suggestions in other apps. On by
// default. Text boxes read it through KeyboardPrivacyScope.

/// Thrown when the keyboard privacy choice cannot be saved.
class KeyboardPrivacyPersistenceException implements Exception {
  const KeyboardPrivacyPersistenceException();
}

/// Where the keyboard privacy choice is kept.
abstract class KeyboardPrivacyStore {
  /// SharedPreferences key. Value: a bool, `true` = keyboard must not learn.
  static const String prefKey = 'keyboard_privacy';

  /// `true` when the keyboard is asked not to learn. Missing means `true`.
  bool read();

  Future<void> write({required bool enabled});
}

/// [KeyboardPrivacyStore] backed by [SharedPreferences].
class SharedPreferencesKeyboardPrivacyStore implements KeyboardPrivacyStore {
  SharedPreferencesKeyboardPrivacyStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool read() => _prefs.getBool(KeyboardPrivacyStore.prefKey) ?? true;

  @override
  Future<void> write({required bool enabled}) async {
    final saved = await _prefs.setBool(KeyboardPrivacyStore.prefKey, enabled);
    if (!saved) throw const KeyboardPrivacyPersistenceException();
  }
}

/// [KeyboardPrivacyStore] that forgets on restart. The default for tests, and
/// the fallback when SharedPreferences cannot be opened.
class InMemoryKeyboardPrivacyStore implements KeyboardPrivacyStore {
  InMemoryKeyboardPrivacyStore({this.enabled = true});

  bool enabled;

  @override
  bool read() => enabled;

  @override
  Future<void> write({required bool enabled}) async => this.enabled = enabled;
}

/// Opens the persistent store. Called in `main()` before the first frame, so
/// no text box is ever built with the wrong value.
Future<KeyboardPrivacyStore> openKeyboardPrivacyStore() async {
  try {
    return SharedPreferencesKeyboardPrivacyStore(
      await SharedPreferences.getInstance(),
    );
  } catch (error, stackTrace) {
    AppLogger.error(
      'Keyboard privacy preference unavailable; keeping it on',
      error: error,
      stackTrace: stackTrace,
    );
    return InMemoryKeyboardPrivacyStore();
  }
}

/// The active [KeyboardPrivacyStore]. Overridden in `main.dart`.
final keyboardPrivacyStoreProvider = Provider<KeyboardPrivacyStore>((ref) {
  return InMemoryKeyboardPrivacyStore();
});

/// Holds whether keyboard privacy is on, and changes it.
///
/// Knows nothing about `BuildContext`, navigation or UI strings — the Settings
/// screen owns the dialog, the snackbar and the wording.
class KeyboardPrivacyController extends Notifier<bool> {
  @override
  bool build() {
    try {
      return ref.watch(keyboardPrivacyStoreProvider).read();
    } catch (_) {
      // Err on the private side.
      return true;
    }
  }

  /// Applies [enabled]. On failure the previous value is restored and a
  /// [KeyboardPrivacyPersistenceException] is thrown for the caller to report.
  Future<void> setEnabled(bool enabled) async {
    if (enabled == state) return;
    final previous = state;
    state = enabled;
    try {
      await ref.read(keyboardPrivacyStoreProvider).write(enabled: enabled);
    } catch (error, stackTrace) {
      state = previous;
      AppLogger.error(
        'Could not save the keyboard privacy choice',
        error: error,
        stackTrace: stackTrace,
      );
      throw const KeyboardPrivacyPersistenceException();
    }
  }
}

final keyboardPrivacyProvider =
    NotifierProvider<KeyboardPrivacyController, bool>(
      KeyboardPrivacyController.new,
    );
