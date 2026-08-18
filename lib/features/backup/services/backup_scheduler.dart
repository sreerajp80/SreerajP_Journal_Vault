import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';

/// Manages automatic backup scheduling.
///
/// Uses a periodic timer to trigger encrypted backups at the configured
/// interval. Schedule settings are persisted via SharedPreferences.
///
/// Supported intervals: daily, weekly, monthly, or disabled.
class BackupScheduler {
  final BackupService _backupService;
  Timer? _timer;

  static const _keyEnabled = 'backup_scheduler_enabled';
  static const _keyInterval = 'backup_scheduler_interval';
  static const _keyPassword = 'backup_scheduler_password';
  static const _keyLastRun = 'backup_scheduler_last_run';

  BackupScheduler(this._backupService);

  /// Initializes the scheduler by reading persisted settings and starting
  /// the timer if a schedule is configured.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyEnabled) ?? false;
    if (!enabled) return;

    final interval = prefs.getString(_keyInterval) ?? 'daily';
    final password = prefs.getString(_keyPassword);
    if (password == null || password.isEmpty) return;

    _scheduleNext(interval, password);
  }

  /// Configures and starts the backup schedule.
  Future<void> configure({
    required String interval,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, true);
    await prefs.setString(_keyInterval, interval);
    await prefs.setString(_keyPassword, password);

    _timer?.cancel();
    _scheduleNext(interval, password);
  }

  /// Disables the backup schedule.
  Future<void> disable() async {
    _timer?.cancel();
    _timer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, false);
  }

  /// Returns current schedule settings.
  Future<BackupScheduleSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyEnabled) ?? false;
    final interval = prefs.getString(_keyInterval) ?? 'daily';
    final lastRunStr = prefs.getString(_keyLastRun);
    final lastRun = lastRunStr != null ? DateTime.tryParse(lastRunStr) : null;
    final hasPassword = (prefs.getString(_keyPassword) ?? '').isNotEmpty;

    return BackupScheduleSettings(
      isEnabled: enabled,
      interval: interval,
      lastRun: lastRun,
      hasPassword: hasPassword,
      isTimerActive: _timer?.isActive ?? false,
    );
  }

  void _scheduleNext(String interval, String password) {
    final duration = _intervalToDuration(interval);

    // Check if a backup is due now
    _checkAndRunBackup(interval, password);

    // Set up periodic timer
    _timer = Timer.periodic(duration, (_) {
      _runBackup(password);
    });
  }

  Future<void> _checkAndRunBackup(String interval, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRunStr = prefs.getString(_keyLastRun);

    if (lastRunStr == null) {
      // Never backed up — run now
      await _runBackup(password);
      return;
    }

    final lastRun = DateTime.tryParse(lastRunStr);
    if (lastRun == null) {
      await _runBackup(password);
      return;
    }

    final duration = _intervalToDuration(interval);
    if (DateTime.now().difference(lastRun) >= duration) {
      await _runBackup(password);
    }
  }

  Future<void> _runBackup(String password) async {
    try {
      await _backupService.createBackup(
        password: password,
        triggerType: 'scheduled',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastRun, DateTime.now().toIso8601String());
    } catch (_) {
      // Error is already logged in BackupService via BackupLogsDao
    }
  }

  Duration _intervalToDuration(String interval) {
    switch (interval) {
      case 'daily':
        return const Duration(hours: 24);
      case 'weekly':
        return const Duration(days: 7);
      case 'monthly':
        return const Duration(days: 30);
      default:
        return const Duration(hours: 24);
    }
  }

  /// Triggers a manual backup using the stored password.
  /// Returns null if no password is configured.
  Future<BackupResult?> triggerManualBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString(_keyPassword);
    if (password == null || password.isEmpty) return null;

    return _backupService.createBackup(password: password);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class BackupScheduleSettings {
  final bool isEnabled;
  final String interval;
  final DateTime? lastRun;
  final bool hasPassword;
  final bool isTimerActive;

  const BackupScheduleSettings({
    required this.isEnabled,
    required this.interval,
    this.lastRun,
    required this.hasPassword,
    required this.isTimerActive,
  });

  // The interval is stored as a database code ('daily', 'weekly', 'monthly').
  // Its display name is looked up in the UI layer, where AppLocalizations is
  // reachable — a service must not build text for the user.
}
