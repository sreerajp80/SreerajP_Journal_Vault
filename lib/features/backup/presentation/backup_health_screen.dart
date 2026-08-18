import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/restore_backup_screen.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_scheduler.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Dashboard for monitoring backup health and configuring schedules.
///
/// Shows:
/// - Current backup schedule status
/// - Last successful backup details
/// - Recent failure count and diagnostics
/// - Backup history log
/// - Manual backup trigger
/// - Schedule configuration
class BackupHealthScreen extends ConsumerStatefulWidget {
  const BackupHealthScreen({super.key});

  @override
  ConsumerState<BackupHealthScreen> createState() => _BackupHealthScreenState();
}

class _BackupHealthScreenState extends ConsumerState<BackupHealthScreen> {
  bool _isBackingUp = false;
  bool _isConfiguring = false;
  final _passwordController = TextEditingController();
  String _selectedInterval = 'daily';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(backupScheduleSettingsProvider);
    final latestSuccess = ref.watch(latestSuccessfulBackupProvider);
    final failureCount = ref.watch(recentFailureCountProvider);
    final recentLogs = ref.watch(recentBackupLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: l10n.commonRefresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Health status card
          _buildHealthStatusCard(theme, latestSuccess, failureCount),
          const SizedBox(height: 16),

          // Schedule card
          _buildScheduleCard(theme, settings),
          const SizedBox(height: 16),

          // Manual backup button
          FilledButton.icon(
            onPressed: _isBackingUp ? null : _triggerManualBackup,
            icon: _isBackingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup),
            label: Text(
              _isBackingUp ? l10n.backupInProgressLabel : l10n.backupNow,
            ),
          ),
          const SizedBox(height: 12),

          // Restore. A backup that has never been restored is only a file.
          OutlinedButton.icon(
            key: const Key('backup-restore-open'),
            onPressed: _isBackingUp
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const RestoreBackupScreen(),
                    ),
                  ),
            icon: const Icon(Icons.restore),
            label: Text(l10n.restoreOpenAction),
          ),
          const SizedBox(height: 24),

          // Backup history
          Text(l10n.backupHistoryHeading, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildBackupHistory(theme, recentLogs),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(
    ThemeData theme,
    AsyncValue<BackupLog?> latestSuccess,
    AsyncValue<int> failureCount,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHealthIndicator(latestSuccess, failureCount),
                const SizedBox(width: 12),
                Text(
                  l10n.backupStatusHeading,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            latestSuccess.when(
              data: (log) {
                if (log == null) {
                  return Text(
                    l10n.backupNoneYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      l10n.backupLastBackup,
                      _formatDateTime(log.completedAt ?? log.startedAt),
                    ),
                    _buildInfoRow(l10n.backupEntries, '${log.entryCount}'),
                    _buildInfoRow(
                      l10n.backupAttachments,
                      '${log.attachmentCount}',
                    ),
                    if (log.sizeBytes != null)
                      _buildInfoRow(
                        l10n.backupSize,
                        _formatBytes(l10n, log.sizeBytes!),
                      ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.commonError(e.toString())),
            ),
            const SizedBox(height: 8),
            failureCount.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.backupRecentFailures(count),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(
    AsyncValue<BackupLog?> latestSuccess,
    AsyncValue<int> failureCount,
  ) {
    return latestSuccess.when(
      data: (log) {
        final failures = failureCount.whenOrNull(data: (v) => v) ?? 0;
        if (log == null) {
          return const Icon(Icons.circle, color: Colors.grey, size: 16);
        }
        if (failures > 0) {
          return const Icon(Icons.circle, color: Colors.orange, size: 16);
        }
        return const Icon(Icons.circle, color: Colors.green, size: 16);
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => Icon(Icons.circle, color: Colors.red.shade400, size: 16),
    );
  }

  Widget _buildScheduleCard(
    ThemeData theme,
    AsyncValue<BackupScheduleSettings> settings,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupScheduleHeading,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            settings.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.isEnabled
                            ? l10n.backupScheduled(
                                _intervalName(l10n, s.interval),
                              )
                            : l10n.backupNotScheduled,
                      ),
                      if (s.isEnabled)
                        Chip(
                          label: Text(
                            s.isTimerActive
                                ? l10n.backupTimerActive
                                : l10n.backupTimerInactive,
                            style: theme.textTheme.labelSmall,
                          ),
                          backgroundColor: s.isTimerActive
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  if (s.lastRun != null)
                    _buildInfoRow(
                      l10n.backupLastScheduledRun,
                      _formatDateTime(s.lastRun!),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (s.isEnabled)
                        OutlinedButton(
                          onPressed: _disableSchedule,
                          child: Text(l10n.backupDisable),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _isConfiguring = true),
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(l10n.backupConfigure),
                        ),
                      if (s.isEnabled) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              setState(() => _isConfiguring = true),
                          child: Text(l10n.backupChange),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.commonError(e.toString())),
            ),
            if (_isConfiguring) ...[
              const Divider(height: 24),
              _buildScheduleConfig(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleConfig(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.backupConfigureHeading, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedInterval,
          decoration: InputDecoration(
            labelText: l10n.backupIntervalLabel,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'daily',
              child: Text(l10n.backupIntervalDaily),
            ),
            DropdownMenuItem(
              value: 'weekly',
              child: Text(l10n.backupIntervalWeekly),
            ),
            DropdownMenuItem(
              value: 'monthly',
              child: Text(l10n.backupIntervalMonthly),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedInterval = v);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.backupPasswordLabel,
            border: const OutlineInputBorder(),
            helperText: l10n.backupPasswordHelper,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: _saveSchedule,
              child: Text(l10n.commonSave),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _isConfiguring = false),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackupHistory(
    ThemeData theme,
    AsyncValue<List<BackupLog>> recentLogs,
  ) {
    final l10n = AppLocalizations.of(context);
    return recentLogs.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.backupNoHistory,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        return Column(
          children: logs.map((log) => _buildLogTile(theme, log)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(l10n.backupHistoryLoadFailed(e.toString())),
    );
  }

  Widget _buildLogTile(ThemeData theme, BackupLog log) {
    final l10n = AppLocalizations.of(context);
    final isSuccess = log.status == 'success';
    final isFailed = log.status == 'failed';
    final isInProgress = log.status == 'in_progress';

    IconData icon;
    Color iconColor;
    if (isSuccess) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isFailed) {
      icon = Icons.error;
      iconColor = theme.colorScheme.error;
    } else {
      icon = Icons.hourglass_top;
      iconColor = Colors.orange;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        l10n.backupLogTitle(
          _triggerName(l10n, log.trigger),
          _statusName(l10n, log.status),
        ),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDateTime(log.startedAt)),
          if (isSuccess && log.sizeBytes != null)
            Text(
              l10n.backupLogCounts(
                log.entryCount,
                log.attachmentCount,
                _formatBytes(l10n, log.sizeBytes!),
              ),
            ),
          if (isFailed && log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (isInProgress) Text(l10n.backupInProgressNote),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _triggerManualBackup() async {
    final scheduler = ref.read(backupSchedulerProvider);
    final settings = await scheduler.getSettings();

    if (!settings.hasPassword) {
      if (!mounted) return;
      _showPasswordDialog();
      return;
    }

    setState(() => _isBackingUp = true);
    try {
      await scheduler.triggerManualBackup();
      _refreshAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupSucceeded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).backupFailed(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _showPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).backupPasswordTitle),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(ctx).backupPasswordEnter,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isEmpty) return;
              final backupService = ref.read(backupServiceProvider);
              setState(() => _isBackingUp = true);
              try {
                await backupService.createBackup(password: controller.text);
                _refreshAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).backupSucceeded,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).backupFailed(e.toString()),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isBackingUp = false);
              }
            },
            child: Text(AppLocalizations.of(ctx).backupAction),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backupPasswordRequired),
        ),
      );
      return;
    }

    final scheduler = ref.read(backupSchedulerProvider);
    await scheduler.configure(
      interval: _selectedInterval,
      password: _passwordController.text,
    );

    setState(() => _isConfiguring = false);
    _passwordController.clear();
    _refreshAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backupScheduleSaved),
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
          content: Text(AppLocalizations.of(context).backupScheduleDisabled),
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
    if (bytes < 1024) return l10n.backupBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.backupKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    return l10n.backupMegabytes((bytes / (1024 * 1024)).toStringAsFixed(1));
  }

  /// The stored `interval`, `trigger` and `status` values are database codes,
  /// not text for the user. Map each one to a translated label here rather than
  /// capitalising the raw code.
  String _intervalName(AppLocalizations l10n, String interval) {
    switch (interval) {
      case 'daily':
        return l10n.backupIntervalDaily;
      case 'weekly':
        return l10n.backupIntervalWeekly;
      case 'monthly':
        return l10n.backupIntervalMonthly;
      default:
        return interval;
    }
  }

  String _triggerName(AppLocalizations l10n, String trigger) {
    switch (trigger) {
      case 'manual':
        return l10n.backupTriggerManual;
      case 'scheduled':
        return l10n.backupTriggerScheduled;
      default:
        return trigger;
    }
  }

  String _statusName(AppLocalizations l10n, String status) {
    switch (status) {
      case 'success':
        return l10n.backupStatusSuccess;
      case 'failed':
        return l10n.backupStatusFailed;
      case 'in_progress':
        return l10n.backupStatusInProgress;
      default:
        return status;
    }
  }
}
