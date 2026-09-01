import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;

/// A [FlutterQuillLocalizations] delegate that never refuses a locale.
///
/// `flutter_quill` only translates the locales it ships an `.arb` file for. On
/// a device set to any other language — Malayalam (`ml`) is one this app
/// itself supports — Flutter finds the package delegate unsupported and simply
/// leaves it out. Every Quill widget then reads `context.loc`, which throws
/// `MissingFlutterQuillLocalizationException` while building, and the editor
/// and its toolbar are drawn as a grey error box in a release build.
///
/// This wrapper reports support for every locale and hands Quill a language it
/// actually knows: the real locale when the package translates it, English
/// otherwise. The app's own text still comes from `AppLocalizations`, so only
/// Quill's built-in labels fall back.
class QuillLocalizationsFallbackDelegate
    extends LocalizationsDelegate<FlutterQuillLocalizations> {
  const QuillLocalizationsFallbackDelegate();

  /// The language used when `flutter_quill` has no translation for the device
  /// locale.
  static const Locale fallbackLocale = Locale('en');

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<FlutterQuillLocalizations> load(Locale locale) {
    final resolved = FlutterQuillLocalizations.delegate.isSupported(locale)
        ? locale
        : fallbackLocale;
    return FlutterQuillLocalizations.delegate.load(resolved);
  }

  @override
  bool shouldReload(QuillLocalizationsFallbackDelegate old) => false;
}

/// The single instance wired into `MaterialApp.localizationsDelegates`.
const QuillLocalizationsFallbackDelegate quillLocalizationsFallbackDelegate =
    QuillLocalizationsFallbackDelegate();
