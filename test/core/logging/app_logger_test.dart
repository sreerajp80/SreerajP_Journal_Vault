import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

void main() {
  tearDown(() => AppLogger.debugOverrideLogger(null));

  group('redact', () {
    test('never reveals the value itself', () {
      expect(AppLogger.redact('super-secret-pin'), '[redacted 16 chars]');
      expect(AppLogger.redact('super-secret-pin'), isNot(contains('secret')));
    });

    test('distinguishes null and empty without leaking', () {
      expect(AppLogger.redact(null), '[null]');
      expect(AppLogger.redact(''), '[empty]');
    });
  });

  group('before init', () {
    test('logging is a no-op rather than throwing', () {
      // Losing a log line must never crash the app.
      AppLogger.debugOverrideLogger(null);

      expect(() => AppLogger.info('no logger yet'), returnsNormally);
      expect(() => AppLogger.error('no logger yet'), returnsNormally);
      expect(() => AppLogger.fatal('no logger yet'), returnsNormally);
    });
  });

  group('routing', () {
    test('each level reaches the underlying logger', () {
      final recorder = _RecordingLogger();
      AppLogger.debugOverrideLogger(recorder);

      AppLogger.trace('t');
      AppLogger.debug('d');
      AppLogger.info('i');
      AppLogger.warning('w');
      AppLogger.error('e');
      AppLogger.fatal('f');

      expect(recorder.levels, [
        Level.trace,
        Level.debug,
        Level.info,
        Level.warning,
        Level.error,
        Level.fatal,
      ]);
    });
  });

  group('release builds', () {
    test(
      'a prod-level logger with ProductionFilter passes info, drops debug',
      () {
        // DevelopmentFilter — the package default — would drop both outside
        // debug mode. The filter must honour the level on its own.
        final filter = ProductionFilter()..level = Level.info;
        LogEvent event(Level level) => LogEvent(level, 'm');

        expect(filter.shouldLog(event(Level.info)), isTrue);
        expect(filter.shouldLog(event(Level.error)), isTrue);
        expect(filter.shouldLog(event(Level.debug)), isFalse);
      },
    );

    test('only the error type is logged, never its text', () {
      final recorder = _RecordingLogger();
      AppLogger.debugOverrideLogger(recorder);

      AppLogger.error(
        'save failed',
        error: const FileSystemException('cannot open', 'diary/secret.pdf'),
      );

      expect(recorder.errors.single, 'FileSystemException');
      expect('${recorder.errors.single}', isNot(contains('secret')));
    });

    test('warning and fatal also log only the error type', () {
      final recorder = _RecordingLogger();
      AppLogger.debugOverrideLogger(recorder);

      AppLogger.warning('parse failed', error: const FormatException('bad'));
      AppLogger.fatal('crash', error: StateError('secret.txt'));

      expect(recorder.errors, ['FormatException', 'StateError']);
    });
  });

  group('flavor gating', () {
    test('verbose logging is off unless the flavor is dev', () {
      // Tests run without --flavor, so FLUTTER_APP_FLAVOR falls back to prod.
      // This is the safe default: an unflavored build must not log verbosely.
      expect(AppFlavorConfig.instance.isProd, isTrue);
      expect(AppFlavorConfig.instance.enableVerboseLogging, isFalse);
    });
  });
}

class _RecordingLogger implements Logger {
  final List<Level> levels = [];
  final List<Object?> errors = [];

  @override
  void log(
    Level level,
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    levels.add(level);
    if (error != null) errors.add(error);
  }

  @override
  void t(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.trace, message);

  @override
  void d(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.debug, message);

  @override
  void i(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.info, message);

  @override
  void w(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.warning, message, error: error);

  @override
  void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.error, message, error: error);

  @override
  void f(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) => log(Level.fatal, message, error: error);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
