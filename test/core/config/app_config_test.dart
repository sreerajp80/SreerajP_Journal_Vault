import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';

void main() {
  group('AppConfig.fromJson', () {
    test('reads a well-formed config', () {
      final config = AppConfig.fromJson(const {
        'appName': 'Vault',
        'description': 'Desc',
        'version': '2.0.0',
        'build': '5',
        'details': {'Author': 'Sreeraj P', 'IDE used': 'VS Code'},
      });

      expect(config.appName, 'Vault');
      expect(config.description, 'Desc');
      expect(config.versionBuild, '2.0.0 (build 5)');
      expect(config.details, {'Author': 'Sreeraj P', 'IDE used': 'VS Code'});
    });

    test('preserves the order keys appear in the file', () {
      final config = AppConfig.fromJson(const {
        'details': {'Third': 'c', 'First': 'a', 'Second': 'b'},
      });

      expect(config.details.keys.toList(), ['Third', 'First', 'Second']);
    });

    test('falls back per field, not wholesale, on missing keys', () {
      final config = AppConfig.fromJson(const {'appName': 'Only Name'});

      expect(config.appName, 'Only Name');
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

      expect(config.appName, AppConfig.fallback.appName);
      expect(config.version, AppConfig.fallback.version);
      expect(config.details, isEmpty);
    });

    test('drops non-string entries from details', () {
      final config = AppConfig.fromJson(const {
        'details': {'Good': 'kept', 'Bad': 7, 8: 'also bad'},
      });

      expect(config.details, {'Good': 'kept'});
    });

    test('an empty map yields the full fallback', () {
      final config = AppConfig.fromJson(const {});

      expect(config.appName, AppConfig.fallback.appName);
      expect(config.description, AppConfig.fallback.description);
      expect(config.version, AppConfig.fallback.version);
      expect(config.build, AppConfig.fallback.build);
    });
  });
}
