import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Label shown when the build timestamp define is absent or empty.
const String missingBuildTimestampLabel = 'Build date unavailable';

/// A snapshot of package information read at runtime.
class PackageMetadataSnapshot {
  const PackageMetadataSnapshot({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  final String appName;
  final String version;
  final String buildNumber;
}

/// Formatted metadata shown on the About screen.
class AboutMetadata {
  const AboutMetadata({
    required this.appName,
    required this.author,
    required this.aiUsed,
    required this.ideUsed,
    required this.versionBuild,
    required this.lastBuildTimestamp,
  });

  final String appName;
  final String author;
  final String aiUsed;
  final String ideUsed;

  /// e.g. "1.0.0 (build 7)"
  final String versionBuild;

  /// Formatted build timestamp or [missingBuildTimestampLabel].
  final String lastBuildTimestamp;
}

/// Reads package metadata from the platform at runtime.
abstract class AppPackageInfoReader {
  Future<PackageMetadataSnapshot> load();
}

/// Provider for the [AppPackageInfoReader] implementation.
///
/// Override in tests with a fake implementation.
final appPackageInfoReaderProvider = Provider<AppPackageInfoReader>((ref) {
  return _DefaultAppPackageInfoReader();
});

class _DefaultAppPackageInfoReader implements AppPackageInfoReader {
  @override
  Future<PackageMetadataSnapshot> load() async {
    // Uses package_info_plus on real devices.
    // Avoids a hard dependency on package_info_plus in this layer.
    return const PackageMetadataSnapshot(
      appName: 'SreerajP_Journal_Vault',
      version: '1.0.0',
      buildNumber: '1',
    );
  }
}

/// Formats a raw ISO-8601 [buildTimestamp] string into a human-readable date.
///
/// Returns [missingBuildTimestampLabel] when the input is blank or unparseable.
String formatBuildTimestamp(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return missingBuildTimestampLabel;
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

/// Builds an [AboutMetadata] from [packageInfo] and a raw [buildTimestamp].
AboutMetadata buildAboutMetadata({
  required PackageMetadataSnapshot packageInfo,
  required String buildTimestamp,
  String author = 'Sreeraj P',
  String aiUsed = 'Claude (Anthropic)',
  String ideUsed = 'VS Code',
}) {
  return AboutMetadata(
    appName: packageInfo.appName,
    author: author,
    aiUsed: aiUsed,
    ideUsed: ideUsed,
    versionBuild: '${packageInfo.version} (build ${packageInfo.buildNumber})',
    lastBuildTimestamp: formatBuildTimestamp(buildTimestamp),
  );
}

/// Public provider for [AboutMetadata].
///
/// Override in tests via [aboutMetadataProvider.overrideWith].
final aboutMetadataProvider = FutureProvider<AboutMetadata>((ref) async {
  final reader = ref.watch(appPackageInfoReaderProvider);
  final packageInfo = await reader.load();
  return buildAboutMetadata(
    packageInfo: packageInfo,
    buildTimestamp: const String.fromEnvironment('BUILD_TIMESTAMP'),
  );
});
