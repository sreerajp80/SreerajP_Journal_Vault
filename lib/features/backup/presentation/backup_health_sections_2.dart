part of 'backup_health_screen.dart';

extension _BackupHealthScreenStatePart2 on _BackupHealthScreenState {
  void _showPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).titleBackupPassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(ctx).labelBackupPasswordEnter,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).actionCommonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isEmpty) return;
              final backupService = ref.read(backupServiceProvider);
              _rebuild(() => _isBackingUp = true);
              try {
                await backupService.createBackup(password: controller.text);
                _refreshAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).labelBackupSucceeded,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).errorBackup(e.toString()),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) _rebuild(() => _isBackingUp = false);
              }
            },
            child: Text(AppLocalizations.of(ctx).actionBackup),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorBackupPassword),
        ),
      );
      return;
    }

    final scheduler = ref.read(backupSchedulerProvider);
    await scheduler.configure(
      interval: _selectedInterval,
      password: _passwordController.text,
    );

    _rebuild(() => _isConfiguring = false);
    _passwordController.clear();
    _refreshAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).labelBackupScheduleSaved),
        ),
      );
    }
  }

  Future<void> _disableSchedule() async {
    final scheduler = ref.read(backupSchedulerProvider);
    await scheduler.disable();
    _refreshAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).labelBackupScheduleDisabled,
          ),
        ),
      );
    }
  }

  void _refreshAll() {
    ref.invalidate(backupScheduleSettingsProvider);
    ref.invalidate(latestSuccessfulBackupProvider);
    ref.invalidate(recentFailureCountProvider);
    ref.invalidate(recentBackupLogsProvider);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.labelBackupBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.labelBackupKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    return l10n.labelBackupMegabytes(
      (bytes / (1024 * 1024)).toStringAsFixed(1),
    );
  }

  /// The stored `interval`, `trigger` and `status` values are database codes,
  /// not text for the user. Map each one to a translated label here rather than
  /// capitalising the raw code.
  String _intervalName(AppLocalizations l10n, String interval) {
    switch (interval) {
      case 'daily':
        return l10n.labelBackupIntervalDaily;
      case 'weekly':
        return l10n.labelBackupIntervalWeekly;
      case 'monthly':
        return l10n.labelBackupIntervalMonthly;
      default:
        return interval;
    }
  }

  String _triggerName(AppLocalizations l10n, String trigger) {
    switch (trigger) {
      case 'manual':
        return l10n.labelBackupTriggerManual;
      case 'scheduled':
        return l10n.labelBackupTriggerScheduled;
      default:
        return trigger;
    }
  }

  String _statusName(AppLocalizations l10n, String status) {
    switch (status) {
      case 'success':
        return l10n.labelBackupStatusSuccess;
      case 'failed':
        return l10n.errorBackupStatus;
      case 'in_progress':
        return l10n.labelBackupStatusInProgress;
      default:
        return status;
    }
  }
}
