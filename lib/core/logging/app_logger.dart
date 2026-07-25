import 'package:logger/logger.dart';

import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';

/// The app's only logging entry point.
///
/// Engineering standard section 14 (levels, setup) and 15.5 (Sensitive Data
/// Extension: structured logging, verbose output gated by flavor).
///
/// RULES — this app is under the Sensitive Data Extension, so these are not
/// style preferences:
///
/// - NEVER log journal titles, entry text, attachment names or bytes, PINs,
///   passwords, key material, or decrypted content of any kind.
/// - Log the operation name and an error category. Do not log raw exception
///   messages that might carry user data — use [redact] if unsure.
/// - [trace] and [debug] produce no output in prod builds; they are gated by
///   [AppFlavorConfig.enableVerboseLogging].
/// - `print` is banned by the `avoid_print` lint. `debugPrint` is banned too
///   (section 14.3) but the linter cannot catch it — use this class instead.
class AppLogger {
  AppLogger._();

  static Logger? _logger;

  /// Set up logging. Call once from `main()` before anything else logs.
  ///
  /// Safe to call more than once; later calls are ignored. If a log call
  /// happens before this runs, it degrades to a no-op rather than throwing —
  /// losing a log line must never crash the app.
  static void init() {
    if (_logger != null) return;

    final verbose = AppFlavorConfig.instance.enableVerboseLogging;

    _logger = Logger(
      // Prod ships info and above. trace/debug are compiled past at runtime.
      level: verbose ? Level.trace : Level.info,
      printer: PrettyPrinter(
        colors: verbose,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      // Console only. No file output: log files in an encrypted-journal app
      // are an extra place for content to leak, and nothing currently needs
      // post-hoc log retrieval. See docs/security.md section 9.
      output: ConsoleOutput(),
    );
  }

  /// Replaces the logger, for tests.
  static void debugOverrideLogger(Logger? logger) => _logger = logger;

  /// Masks a value that may contain user data, keeping only its length.
  /// Use when a diagnostic genuinely needs to distinguish empty from non-empty.
  static String redact(Object? value) {
    if (value == null) return '[null]';
    final text = value.toString();
    if (text.isEmpty) return '[empty]';
    return '[redacted ${text.length} chars]';
  }

  static void trace(String message) => _logger?.t(message);

  static void debug(String message) => _logger?.d(message);

  static void info(String message) => _logger?.i(message);

  static void warning(String message, {Object? error}) =>
      _logger?.w(message, error: error);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger?.e(message, error: error, stackTrace: stackTrace);

  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger?.f(message, error: error, stackTrace: stackTrace);
}
