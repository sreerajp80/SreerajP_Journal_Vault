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

  /// Whether the encrypted-sync UI is offered.
  ///
  /// Off everywhere until sync actually works. `SyncEngine` and
  /// `ConflictResolutionService` are implemented and tested, but `SyncProtocol`
  /// has no concrete transport, so nothing can ever push or pull. Showing a
  /// health dashboard and a conflict list for a sync that cannot run tells the
  /// user their data is being replicated when it is not.
  ///
  /// Flip this to `isDev` once a transport lands, and remove it once sync
  /// ships. See `docs/architecture.md` section 21.
  bool get enableSyncUi => false;
}
