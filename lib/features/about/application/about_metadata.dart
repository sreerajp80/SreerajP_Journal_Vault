import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:sreerajp_journal_vault/core/config/config_service.dart';
import 'package:sreerajp_journal_vault/core/constants/build_date.g.dart';

/// Label shown when the build timestamp define is absent or empty.
const String missingBuildTimestampLabel = 'Build date unavailable';

/// Formatted metadata shown on the About screen.
///
/// Per guideline.md section 1.6 the attribution rows live in [details] and are
/// rendered by looping the map. This class must NOT gain named fields like
/// `author` or `ideUsed` — adding a row is a change to
/// `assets/config/app_config.json`, not to Dart.
class AboutMetadata {
  const AboutMetadata({
    required this.appName,
    required this.description,
    required this.versionBuild,
    required this.lastBuildTimestamp,
    this.details = const {},
  });

  final String appName;
  final String description;

  /// e.g. "1.0.1 (build 1)"
  final String versionBuild;

  /// Formatted build timestamp or [missingBuildTimestampLabel].
  final String lastBuildTimestamp;

  /// Label/value rows straight from the config, in file order.
  final Map<String, String> details;
}

/// Provider for the [ConfigService] used to load About values.
///
/// Override in tests with an injected asset loader.
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

/// Formats a raw build timestamp or date string into a human-readable date.
///
/// Returns [missingBuildTimestampLabel] when the input is blank or unparseable.
String formatBuildTimestamp(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return missingBuildTimestampLabel;
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
    return trimmed;
  }
  try {
    final dt = DateTime.parse(trimmed).toLocal();
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  } catch (_) {
    return missingBuildTimestampLabel;
  }
}

/// Builds an [AboutMetadata] from a loaded [config] and a raw [buildTimestamp].
AboutMetadata buildAboutMetadata({
  required AppConfig config,
  required String buildTimestamp,
}) {
  return AboutMetadata(
    appName: config.appName,
    description: config.description,
    versionBuild: config.versionBuild,
    lastBuildTimestamp: formatBuildTimestamp(buildTimestamp),
    details: config.details,
  );
}

/// Public provider for [AboutMetadata].
///
/// Override in tests via [aboutMetadataProvider.overrideWith].
final aboutMetadataProvider = FutureProvider<AboutMetadata>((ref) async {
  final config = await ref.watch(configServiceProvider).loadAndVerify();
  const buildTimestampEnv = String.fromEnvironment('BUILD_TIMESTAMP');
  final buildTimestamp = buildTimestampEnv.isNotEmpty
      ? buildTimestampEnv
      : kBuildDate;
  return buildAboutMetadata(config: config, buildTimestamp: buildTimestamp);
});
