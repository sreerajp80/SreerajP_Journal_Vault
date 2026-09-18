import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Layer: core (localization wiring).
//
// flutter_localizations has no Sanskrit ('sa') translation. Without these
// delegates, Locale('sa') throws the first time a Material widget needs
// framework strings — a date picker, a dialog button, the text-selection menu.
//
// Each delegate answers for 'sa' by loading the English framework strings, so
// the app's own Sanskrit strings (AppLocalizations) still render while Material
// widgets keep working. English, never Hindi, so no Hindi text can leak into a
// Sanskrit screen. Engineering standard §8.3.1.
//
// Register them before the Global* delegates so they win for 'sa'.

/// Serves English [MaterialLocalizations] when the app language is Sanskrit.
class SaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<Object?> old) => false;
}

/// Serves English [CupertinoLocalizations] when the app language is Sanskrit.
class SaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<Object?> old) => false;
}

/// Serves English [WidgetsLocalizations] when the app language is Sanskrit.
class SaWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const SaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<Object?> old) => false;
}
