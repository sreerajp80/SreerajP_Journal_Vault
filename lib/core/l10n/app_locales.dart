import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sreerajp_journal_vault/core/l10n/quill_localizations_fallback.dart';
import 'package:sreerajp_journal_vault/core/l10n/sa_framework_localizations.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Layer: core (localization wiring). Shared by every MaterialApp in the app,
// so the main app and the vault-unavailable app can never drift apart.

/// The three languages every app ships, in the fixed order: English (template),
/// Malayalam, Sanskrit. Engineering standard §8.1 and §8.3.
const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('ml'),
  Locale('sa'),
];

/// Localization delegates for `MaterialApp.localizationsDelegates`.
///
/// The Sanskrit delegates come before the Global* ones so they win for `sa`.
/// The Quill delegate is the fallback wrapper, because flutter_quill has no
/// Malayalam or Sanskrit translation.
const List<LocalizationsDelegate<Object?>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  quillLocalizationsFallbackDelegate,
  SaMaterialLocalizationsDelegate(),
  SaCupertinoLocalizationsDelegate(),
  SaWidgetsLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// `MaterialApp.localeResolutionCallback`: the device language when it is one
/// of the three, English otherwise. Only used while the user's choice is
/// "System default"; an explicit choice sets `MaterialApp.locale` directly.
Locale resolveAppLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  for (final locale in supported) {
    if (locale.languageCode == deviceLocale?.languageCode) return locale;
  }
  return const Locale('en');
}
