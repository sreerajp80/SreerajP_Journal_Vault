/// Build flavor, resolved at compile time.
///
/// Required by engineering standard section 5.2. Two variables are read, in
/// priority order, because Flutter signals the flavor differently per platform:
///
/// 1. `APP_FLAVOR` — passed explicitly via `--dart-define=APP_FLAVOR=<value>`.
///    Desktop targets need this, because `flutter build windows` does not
///    accept `--flavor` and `FLUTTER_APP_FLAVOR` is reserved by the framework.
/// 2. `FLUTTER_APP_FLAVOR` — injected automatically by the Flutter tool on
///    Android and iOS whenever `--flavor` is passed.
///
/// Falls back to `prod`, so an unflavored build still has a deterministic
/// value and never accidentally enables verbose logging.
enum AppFlavor { dev, prod }

class AppFlavorConfig {
  AppFlavorConfig._(this.flavor);

  static const String _appFlavorValue = String.fromEnvironment('APP_FLAVOR');

  static const String _frameworkFlavorValue = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'prod',
  );

  static String _resolved() =>
      _appFlavorValue.isNotEmpty ? _appFlavorValue : _frameworkFlavorValue;

  static final AppFlavorConfig instance = AppFlavorConfig._(
    _parse(_resolved()),
  );

  final AppFlavor flavor;

  static AppFlavor _parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  /// Verbose logging is dev-only. Engineering standard section 15.5 requires
  /// this gate for apps under the Sensitive Data Extension.
  bool get enableVerboseLogging => isDev;

  /// Whether the extra sync entry points are offered: the sync status and
  /// conflict shortcut on the home screen, and the conflict row in Security
  /// settings.
  ///
  /// Wi-Fi Sync itself is reachable from Storage settings, and its screen
  /// links to the conflict list. It sends journals, entries, tags, links,
  /// revisions and attachments one way, host to client, edits and deletes
  /// included (see `docs/architecture.md` section 21). These extra shortcuts
  /// stay off until that sync has been tried on real phones.
  bool get enableSyncUi => false;
}
