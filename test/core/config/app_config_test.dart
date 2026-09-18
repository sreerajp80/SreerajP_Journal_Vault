import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';

void main() {
  group('LocalizedText', () {
    test('a plain string is the same text in every language', () {
      final text = LocalizedText.fromJson('Sreeraj P');
      expect(text.isTranslated, isFalse);
      expect(text.resolve('en'), 'Sreeraj P');
      expect(text.resolve('ml'), 'Sreeraj P');
      expect(text.resolve('sa'), 'Sreeraj P');
    });

    test('a locale map resolves exact language, then English, then any', () {
      final text = LocalizedText.fromJson(const {
        'en': 'Open source',
        'ml': 'ഓപ്പൺ സോഴ്സ്',
      });
      expect(text.isTranslated, isTrue);
      expect(text.resolve('ml'), 'ഓപ്പൺ സോഴ്സ്');
      expect(text.resolve('sa'), 'Open source');

      final noEnglish = LocalizedText.fromJson(const {'sa': 'मुक्तस्रोतम्'});
      expect(noEnglish.resolve('ml'), 'मुक्तस्रोतम्');
    });

    test(
      'non-string map values are dropped; a bad value uses the fallback',
      () {
        expect(
          LocalizedText.fromJson(const {'en': 'ok', 'ml': 7}).resolve('ml'),
          'ok',
        );
        expect(LocalizedText.fromJson(42, fallback: 'x').resolve('en'), 'x');
        expect(LocalizedText.fromJson(null).isEmpty, isTrue);
      },
    );
  });

  group('AppConfig.fromJson', () {
    test('reads a well-formed config with plain and translated values', () {
      final config = AppConfig.fromJson(const {
        'appName': 'Vault',
        'description': {'en': 'Desc', 'ml': 'വിവരണം', 'sa': 'वर्णनम्'},
        'version': '2.0.0',
        'build': '5',
        'details': {
          'author': 'Sreeraj P',
          'license': {'en': 'Open', 'ml': 'തുറന്ന', 'sa': 'मुक्तम्'},
        },
      });

      expect(config.appName.resolve('en'), 'Vault');
      expect(config.description.resolve('sa'), 'वर्णनम्');
      expect(config.versionBuild, '2.0.0 (build 5)');
      expect(config.details.keys, ['author', 'license']);
      expect(config.details['author']!.resolve('ml'), 'Sreeraj P');
      expect(config.details['license']!.resolve('ml'), 'തുറന്ന');
    });

    test('a translated appName resolves per language', () {
      final config = AppConfig.fromJson(const {
        'appName': {
          'en': 'Journal Vault',
          'ml': 'ജേണൽ വോൾട്ട്',
          'sa': 'दैनन्दिनीकोषः',
        },
      });

      expect(config.appName.isTranslated, isTrue);
      expect(config.appName.resolve('en'), 'Journal Vault');
      expect(config.appName.resolve('ml'), 'ജേണൽ വോൾട്ട്');
      expect(config.appName.resolve('sa'), 'दैनन्दिनीकोषः');
    });

    test('a plain appName still works, so an older config is not broken', () {
      final config = AppConfig.fromJson(const {'appName': 'Journal Vault'});

      expect(config.appName.isTranslated, isFalse);
      expect(config.appName.resolve('ml'), 'Journal Vault');
      expect(config.appName.resolve('sa'), 'Journal Vault');
    });

    test('preserves the order keys appear in the file', () {
      final config = AppConfig.fromJson(const {
        'details': {'third': 'c', 'first': 'a', 'second': 'b'},
      });

      expect(config.details.keys.toList(), ['third', 'first', 'second']);
    });

    test('falls back per field, not wholesale, on missing keys', () {
      final config = AppConfig.fromJson(const {'appName': 'Only Name'});

      expect(config.appName.resolve('en'), 'Only Name');
      expect(config.version, AppConfig.fallback.version);
      expect(config.build, AppConfig.fallback.build);
      expect(config.details, isEmpty);
    });

    test('falls back per field on wrong types instead of throwing', () {
      final config = AppConfig.fromJson(const {
        'appName': 42,
        'version': ['not', 'a', 'string'],
        'details': 'not a map',
      });

      expect(
        config.appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
      expect(config.version, AppConfig.fallback.version);
      expect(config.details, isEmpty);
    });

    test('drops details that are neither text nor a locale map', () {
      final config = AppConfig.fromJson(const {
        'details': {'good': 'kept', 'bad': 7, 8: 'also bad', 'blank': '  '},
      });

      expect(config.details.keys, ['good']);
    });

    test('an empty map yields the full fallback', () {
      final config = AppConfig.fromJson(const {});

      expect(
        config.appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
      expect(
        config.description.resolve('en'),
        AppConfig.fallback.description.resolve('en'),
      );
      expect(config.version, AppConfig.fallback.version);
      expect(config.build, AppConfig.fallback.build);
    });
  });
}
