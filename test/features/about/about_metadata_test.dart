import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';

void main() {
  const config = AppConfig(
    appName: 'SreerajP Journal Vault',
    description: 'A private journal.',
    version: '1.0.1',
    build: '1',
    details: {'Author': 'Sreeraj P'},
  );

  test(
    'buildAboutMetadata falls back when build timestamp define is missing',
    () {
      final metadata = buildAboutMetadata(
        config: config,
        buildTimestamp: '   ',
      );

      expect(metadata.appName, 'SreerajP Journal Vault');
      expect(metadata.versionBuild, '1.0.1 (build 1)');
      expect(metadata.lastBuildTimestamp, missingBuildTimestampLabel);
    },
  );

  test('buildAboutMetadata carries the details map through unchanged', () {
    final metadata = buildAboutMetadata(config: config, buildTimestamp: '');

    expect(metadata.details, {'Author': 'Sreeraj P'});
  });

  test('formatBuildTimestamp preserves YYYY-MM-DD date string', () {
    expect(formatBuildTimestamp('2026-08-29'), '2026-08-29');
  });

  test('formatBuildTimestamp normalizes ISO timestamps', () {
    expect(
      formatBuildTimestamp('2026-03-19T12:34:56Z'),
      isNot(missingBuildTimestampLabel),
    );
  });
}
