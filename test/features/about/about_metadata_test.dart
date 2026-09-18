import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';

void main() {
  const config = AppConfig(
    appName: LocalizedText.plain('SreerajP Journal Vault'),
    description: LocalizedText.plain('A private journal.'),
    version: '1.0.1',
    build: '1',
    details: {'author': LocalizedText.plain('Sreeraj P')},
  );

  test('buildAboutMetadata leaves the build date null when it is missing', () {
    final metadata = buildAboutMetadata(config: config, buildTimestamp: '   ');

    expect(metadata.appName.resolve('en'), 'SreerajP Journal Vault');
    expect(metadata.versionBuild, '1.0.1 (build 1)');
    // The screen shows a localized "unavailable" text for null.
    expect(metadata.lastBuildTimestamp, isNull);
  });

  test('buildAboutMetadata carries the details map through unchanged', () {
    final metadata = buildAboutMetadata(config: config, buildTimestamp: '');

    expect(metadata.details.keys, ['author']);
    expect(metadata.details['author']!.resolve('ml'), 'Sreeraj P');
  });

  test('formatBuildTimestamp preserves YYYY-MM-DD date string', () {
    expect(formatBuildTimestamp('2026-08-29'), '2026-08-29');
  });

  test('formatBuildTimestamp normalizes ISO timestamps', () {
    expect(
      formatBuildTimestamp('2026-03-19T12:34:56Z'),
      matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')),
    );
  });

  test('formatBuildTimestamp returns null for unparseable input', () {
    expect(formatBuildTimestamp('not a date'), isNull);
  });
}
