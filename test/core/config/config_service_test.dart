import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:sreerajp_journal_vault/core/config/config_service.dart';

void main() {
  group('ConfigService.load', () {
    test('reads the configured asset path', () async {
      String? requested;
      final service = ConfigService(
        loadAsset: (path) async {
          requested = path;
          return '{"appName":"Vault"}';
        },
      );

      await service.load();

      expect(requested, ConfigService.assetPath);
      expect(ConfigService.assetPath, 'assets/config/app_config.json');
    });

    test('parses valid JSON', () async {
      final service = ConfigService(
        loadAsset: (_) async => '{"appName":"Vault","version":"3.1.4"}',
      );

      final config = await service.load();

      expect(config.appName.resolve('en'), 'Vault');
      expect(config.version, '3.1.4');
    });

    test('falls back when the asset is missing', () async {
      final service = ConfigService(
        loadAsset: (_) async => throw StateError('not bundled'),
      );

      expect(
        (await service.load()).appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
    });

    test('falls back on malformed JSON', () async {
      final service = ConfigService(loadAsset: (_) async => '{not json');

      expect(
        (await service.load()).appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
    });

    test('falls back when the JSON root is not an object', () async {
      final service = ConfigService(loadAsset: (_) async => '["a","b"]');

      expect(
        (await service.load()).appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
    });

    test('falls back on an empty file', () async {
      final service = ConfigService(loadAsset: (_) async => '');

      expect(
        (await service.load()).appName.resolve('en'),
        AppConfig.fallback.appName.resolve('en'),
      );
    });
  });

  group('ConfigService.loadAndVerify', () {
    test('returns the config even when package info is unavailable', () async {
      // PackageInfo.fromPlatform() throws in a plain unit test. The service
      // must swallow that and still return the parsed config.
      final service = ConfigService(
        loadAsset: (_) async => '{"appName":"Vault","version":"9.9.9"}',
      );

      final config = await service.loadAndVerify();

      expect(config.appName.resolve('en'), 'Vault');
      expect(config.version, '9.9.9');
    });
  });
}
