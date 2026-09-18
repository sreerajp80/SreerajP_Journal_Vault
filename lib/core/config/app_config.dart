/// A config text that may be language-independent (one string) or translated
/// (one string per locale code). Resolution order: exact locale → 'en' → any.
///
/// Required by guideline.md section 1.4. A plain string means "the same text
/// in every language" — right for a name or an email address, wrong for a
/// sentence. Sentences use the `{"en": …, "ml": …, "sa": …}` map.
class LocalizedText {
  const LocalizedText.plain(String value)
    : _plain = value,
      _byLocale = const {};

  const LocalizedText.byLocale(Map<String, String> byLocale)
    : _plain = '',
      _byLocale = byLocale;

  /// Accepts a JSON string or a `{"en": ..., "ml": ..., "sa": ...}` map.
  factory LocalizedText.fromJson(Object? raw, {String fallback = ''}) {
    if (raw is String) return LocalizedText.plain(raw);
    if (raw is Map) {
      final out = <String, String>{};
      raw.forEach((k, v) {
        if (k is String && v is String) out[k] = v;
      });
      if (out.isNotEmpty) return LocalizedText.byLocale(out);
    }
    return LocalizedText.plain(fallback);
  }

  final Map<String, String> _byLocale;
  final String _plain;

  bool get isEmpty => _plain.trim().isEmpty && _byLocale.isEmpty;

  /// Whether this text carries one value per language.
  bool get isTranslated => _byLocale.isNotEmpty;

  /// [languageCode] is the active app language: 'en', 'ml' or 'sa'.
  String resolve(String languageCode) {
    if (_byLocale.isEmpty) return _plain;
    return _byLocale[languageCode] ??
        _byLocale['en'] ??
        (_byLocale.values.isEmpty ? '' : _byLocale.values.first);
  }
}

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
    appName: LocalizedText.plain('SreerajP Journal Vault'),
    description: LocalizedText.plain(''),
    version: '0.0.0',
    build: '0',
  );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    String str(String key, String fallbackValue) {
      final value = json[key];
      return value is String ? value : fallbackValue;
    }

    Map<String, LocalizedText> parseDetails(String key) {
      final raw = json[key];
      if (raw is! Map) return const {};
      final out = <String, LocalizedText>{};
      raw.forEach((k, v) {
        if (k is String) {
          final text = LocalizedText.fromJson(v);
          if (!text.isEmpty) out[k] = text;
        }
      });
      return out;
    }

    return AppConfig(
      appName: LocalizedText.fromJson(
        json['appName'],
        fallback: fallback.appName.resolve('en'),
      ),
      description: LocalizedText.fromJson(
        json['description'],
        fallback: fallback.description.resolve('en'),
      ),
      version: str('version', fallback.version),
      build: str('build', fallback.build),
      details: parseDetails('details'),
    );
  }

  /// The app's own name. Translated, because the About heading and the task
  /// switcher both show it to a reader in their own language. Keep it in step
  /// with the ARB key `titleApp`, which the window title uses.
  final LocalizedText appName;
  final LocalizedText description;
  final String version;
  final String build;

  /// Free-form rows rendered on the About screen, in file order. Keys are
  /// lowerCamelCase identifiers (`author`, `aiUsed`); the visible label comes
  /// from the ARB key `aboutDetail<Key>`. Adding or removing a key here is the
  /// only change needed to change the rows — the screen must not hard-code any
  /// of these names.
  final Map<String, LocalizedText> details;

  /// e.g. "1.0.1 (build 1)"
  String get versionBuild => '$version (build $build)';
}
