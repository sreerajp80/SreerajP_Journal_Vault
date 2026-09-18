import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';

void main() {
  group('SharedPreferencesOcrLanguageStore', () {
    test('returns the default when nothing is saved', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = SharedPreferencesOcrLanguageStore();
      expect(await store.read(), OcrLanguageStore.defaultLanguage);
    });

    test('saves and reads back a supported language', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = SharedPreferencesOcrLanguageStore();
      await store.save('eng');
      expect(await store.read(), 'eng');
    });

    test('ignores an unknown saved value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        OcrLanguageStore.prefKey: 'xyz',
      });
      const store = SharedPreferencesOcrLanguageStore();
      expect(await store.read(), OcrLanguageStore.defaultLanguage);
    });

    test('does not save an unknown language', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = SharedPreferencesOcrLanguageStore();
      await store.save('fra');
      expect(await store.read(), OcrLanguageStore.defaultLanguage);
    });
  });
}
