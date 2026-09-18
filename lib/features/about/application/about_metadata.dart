import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:sreerajp_journal_vault/core/config/config_service.dart';
import 'package:sreerajp_journal_vault/core/constants/build_date.g.dart';

/// Formatted metadata shown on the About screen.
///
/// Per guideline.md section 1.6 the attribution rows live in [details] and are
/// rendered by looping the map. This class must NOT gain named fields like
/// `author` or `ideUsed` — adding a row is a change to
/// `assets/config/app_config.json`, not to Dart.
///
/// Layer: application. It holds no UI strings; text that needs a language is
/// kept as [LocalizedText] and resolved by the screen.
class AboutMetadata {
  const AboutMetadata({
    required this.appName,
    required this.description,
    required this.versionBuild,
    required this.lastBuildTimestamp,
    this.details = const {},
  });

  final LocalizedText appName;
  final LocalizedText description;

  /// e.g. "1.0.1 (build 1)"
  final String versionBuild;

  /// Formatted build timestamp, or `null` when it is not available. The screen
  /// shows a localized "unavailable" text for `null`.
  final String? lastBuildTimestamp;

  /// Rows straight from the config, in file order.
  final Map<String, LocalizedText> details;
}

/// Provider for the [ConfigService] used to load About values.
///
/// Override in tests with an injected asset loader.
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

/// Formats a raw build timestamp or date string into a readable date.
///
/// Returns `null` when the input is blank or cannot be parsed.
String? formatBuildTimestamp(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
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
    return null;
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
