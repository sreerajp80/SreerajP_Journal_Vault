import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';

void main() {
  test(
    'buildAboutMetadata falls back when build timestamp define is missing',
    () {
      final metadata = buildAboutMetadata(
        packageInfo: const PackageMetadataSnapshot(
          appName: 'SreerajP_Journal_Vault',
          version: '1.0.0',
          buildNumber: '1',
        ),
        buildTimestamp: '   ',
      );

      expect(metadata.appName, 'SreerajP_Journal_Vault');
      expect(metadata.versionBuild, '1.0.0 (build 1)');
      expect(metadata.lastBuildTimestamp, missingBuildTimestampLabel);
    },
  );

  test('formatBuildTimestamp normalizes ISO timestamps', () {
    expect(
      formatBuildTimestamp('2026-03-19T12:34:56Z'),
      isNot(missingBuildTimestampLabel),
    );
  });
}
