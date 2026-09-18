import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

// Layer: core (localization state).
//
// The single source of truth for the app language (engineering standard §8.4).
// MaterialApp.locale is driven by localeControllerProvider; no screen reads the
// language from anywhere else.

/// The user's language choice. [system] follows the device language.
enum AppLanguage {
  system,
  en,
  ml,
  sa;

  /// The value saved under [AppLanguageStore.prefKey].
  String get storageValue => name;

  /// The locale to give MaterialApp. `null` means "follow the system".
  Locale? get locale => this == AppLanguage.system ? null : Locale(name);

  static AppLanguage fromStorage(String? value) {
    for (final language in AppLanguage.values) {
      if (language.storageValue == value) return language;
    }
    return AppLanguage.system;
  }
}

/// The locale the app is showing for [language], resolved the same way
/// `MaterialApp` resolves it.
///
/// For code that cannot call `Localizations.localeOf(context)` — for example
/// `initState`, where depending on an inherited widget is not allowed.
Locale effectiveAppLocale(AppLanguage language) {
  return language.locale ??
      resolveAppLocale(
        WidgetsBinding.instance.platformDispatcher.locale,
        appSupportedLocales,
      );
}

/// Where the language choice is kept.
abstract class AppLanguageStore {
  /// SharedPreferences key. Values: `system` | `en` | `ml` | `sa`.
  static const String prefKey = 'app_language';

  AppLanguage read();
  Future<void> save(AppLanguage language);
}

/// [AppLanguageStore] backed by [SharedPreferences].
class SharedPreferencesAppLanguageStore implements AppLanguageStore {
  SharedPreferencesAppLanguageStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  AppLanguage read() =>
      AppLanguage.fromStorage(_prefs.getString(AppLanguageStore.prefKey));

  @override
  Future<void> save(AppLanguage language) async {
    await _prefs.setString(AppLanguageStore.prefKey, language.storageValue);
  }
}

/// [AppLanguageStore] that forgets on restart. The default for tests, and the
/// fallback when SharedPreferences cannot be opened.
class InMemoryAppLanguageStore implements AppLanguageStore {
  InMemoryAppLanguageStore([this._language = AppLanguage.system]);

  AppLanguage _language;

  @override
  AppLanguage read() => _language;

  @override
  Future<void> save(AppLanguage language) async => _language = language;
}

/// Opens the persistent store. Called in `main()` before the first frame, so
/// the app never flashes the wrong language at startup.
Future<AppLanguageStore> openAppLanguageStore() async {
  try {
    return SharedPreferencesAppLanguageStore(
      await SharedPreferences.getInstance(),
    );
  } catch (error, stackTrace) {
    AppLogger.error(
      'Language preference unavailable; following the system language',
      error: error,
      stackTrace: stackTrace,
    );
    return InMemoryAppLanguageStore();
  }
}

/// The active [AppLanguageStore]. Overridden in `main.dart`.
final appLanguageStoreProvider = Provider<AppLanguageStore>((ref) {
  return InMemoryAppLanguageStore();
});

/// Holds the current [AppLanguage] and saves changes. A change applies at once,
/// app-wide, without a restart.
class LocaleController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    try {
      return ref.watch(appLanguageStoreProvider).read();
    } catch (_) {
      return AppLanguage.system;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == state) return;
    final previous = state;
    state = language;
    try {
      await ref.read(appLanguageStoreProvider).save(language);
    } catch (error, stackTrace) {
      state = previous;
      AppLogger.error(
        'Could not save the language choice',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, AppLanguage>(LocaleController.new);
