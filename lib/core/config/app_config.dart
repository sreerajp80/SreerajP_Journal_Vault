/// Typed values for the About screen, loaded from `assets/config/app_config.json`.
/// Changing About content is a config edit, not a code change.
///
/// Required by guideline.md section 1. The class name, the file path, and the
/// asset path are all fixed across apps — do not rename them.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.description,
    required this.version,
    required this.build,
    this.details = const {},
  });

  /// Safe built-in value used when the config file is missing or malformed,
  /// so the app never crashes on a bad config.
  static const AppConfig fallback = AppConfig(
    appName: 'SreerajP_Journal_Vault',
    description: 'A Flutter application.',
    version: '0.0.0',
    build: '0',
    details: {'License': 'All libraries used are open source.'},
  );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    String str(String key, String fallbackValue) {
      final value = json[key];
      return value is String ? value : fallbackValue;
    }

    Map<String, String> parseStringMap(String key) {
      final raw = json[key];
      if (raw is! Map) return const {};
      final out = <String, String>{};
      raw.forEach((k, v) {
        if (k is String && v is String) out[k] = v;
      });
      return out;
    }

    return AppConfig(
      appName: str('appName', fallback.appName),
      description: str('description', fallback.description),
      version: str('version', fallback.version),
      build: str('build', fallback.build),
      details: parseStringMap('details'),
    );
  }

  final String appName;
  final String description;
  final String version;
  final String build;

  /// Free-form label/value rows rendered on the About screen, in order.
  /// Adding or removing a key here is the only change needed to change the
  /// About screen — the screen must not hard-code any of these names.
  final Map<String, String> details;

  /// e.g. "1.0.1 (build 1)"
  String get versionBuild => '$version (build $build)';
}
