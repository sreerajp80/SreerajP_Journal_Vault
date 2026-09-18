import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

// Layer: service. Remembers the OCR language the user last picked, so someone
// who scans English pages picks English once instead of on every scan.
//
// The value is only a language code (`eng+mal`, `mal` or `eng`), never journal
// content.

/// Where the last chosen OCR language is kept.
abstract class OcrLanguageStore {
  /// SharedPreferences key.
  static const String prefKey = 'ocr_language';

  /// The language used when nothing has been saved yet.
  static const String defaultLanguage = 'eng+mal';

  /// Every language code the OCR engine accepts.
  static const Set<String> supportedLanguages = <String>{
    'eng+mal',
    'mal',
    'eng',
  };

  /// The saved language, or [defaultLanguage].
  Future<String> read();

  /// Saves [language]. Unknown codes are ignored.
  Future<void> save(String language);
}

/// [OcrLanguageStore] backed by [SharedPreferences].
class SharedPreferencesOcrLanguageStore implements OcrLanguageStore {
  const SharedPreferencesOcrLanguageStore();

  @override
  Future<String> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(OcrLanguageStore.prefKey);
      if (value != null &&
          OcrLanguageStore.supportedLanguages.contains(value)) {
        return value;
      }
    } catch (e) {
      AppLogger.warning('OcrLanguageStore: read failed: $e');
    }
    return OcrLanguageStore.defaultLanguage;
  }

  @override
  Future<void> save(String language) async {
    if (!OcrLanguageStore.supportedLanguages.contains(language)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(OcrLanguageStore.prefKey, language);
    } catch (e) {
      AppLogger.warning('OcrLanguageStore: save failed: $e');
    }
  }
}

/// [OcrLanguageStore] that forgets on restart. Used by tests.
class InMemoryOcrLanguageStore implements OcrLanguageStore {
  InMemoryOcrLanguageStore([this._language = OcrLanguageStore.defaultLanguage]);

  String _language;

  @override
  Future<String> read() async => _language;

  @override
  Future<void> save(String language) async {
    if (!OcrLanguageStore.supportedLanguages.contains(language)) return;
    _language = language;
  }
}
