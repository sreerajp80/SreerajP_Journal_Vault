import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_scheduler.dart';

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
    final theme = Theme.of(context);
    final settings = ref.watch(backupScheduleSettingsProvider);
    final latestSuccess = ref.watch(latestSuccessfulBackupProvider);
    final failureCount = ref.watch(recentFailureCountProvider);
    final recentLogs = ref.watch(recentBackupLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: 'Refresh',
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
            label: Text(_isBackingUp ? 'Backing up...' : 'Backup Now'),
          ),
          const SizedBox(height: 24),

          // Backup history
          Text('Backup History', style: theme.textTheme.titleSmall),
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
                Text('Backup Status', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            latestSuccess.when(
              data: (log) {
                if (log == null) {
                  return Text(
                    'No successful backups yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Last backup',
                        _formatDateTime(log.completedAt ?? log.startedAt)),
                    _buildInfoRow('Entries', '${log.entryCount}'),
                    _buildInfoRow('Attachments', '${log.attachmentCount}'),
                    if (log.sizeBytes != null)
                      _buildInfoRow('Size', _formatBytes(log.sizeBytes!)),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
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
                      Icon(Icons.warning_amber,
                          color: theme.colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$count failed backup(s) in the last 7 days',
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
      error: (_, _) =>
          Icon(Icons.circle, color: Colors.red.shade400, size: 16),
    );
  }

  Widget _buildScheduleCard(
    ThemeData theme,
    AsyncValue<BackupScheduleSettings> settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auto-Backup Schedule', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            settings.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.isEnabled
                          ? 'Scheduled: ${s.intervalDisplayName}'
                          : 'Not scheduled'),
                      if (s.isEnabled)
                        Chip(
                          label: Text(
                            s.isTimerActive ? 'Active' : 'Inactive',
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
                        'Last scheduled run', _formatDateTime(s.lastRun!)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (s.isEnabled)
                        OutlinedButton(
                          onPressed: _disableSchedule,
                          child: const Text('Disable'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _isConfiguring = true),
                          icon: const Icon(Icons.schedule, size: 18),
                          label: const Text('Configure'),
                        ),
                      if (s.isEnabled) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => setState(() => _isConfiguring = true),
                          child: const Text('Change'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configure Schedule', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedInterval,
          decoration: const InputDecoration(
            labelText: 'Interval',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('Daily')),
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedInterval = v);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Backup encryption password',
            border: OutlineInputBorder(),
            helperText: 'Required for encrypted backups',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: _saveSchedule,
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _isConfiguring = false),
              child: const Text('Cancel'),
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
    return recentLogs.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No backup history',
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
      error: (e, _) => Text('Error loading history: $e'),
    );
  }

  Widget _buildLogTile(ThemeData theme, BackupLog log) {
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
        '${_capitalize(log.trigger)} backup — ${_capitalize(log.status)}',
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDateTime(log.startedAt)),
          if (isSuccess && log.sizeBytes != null)
            Text(
                '${log.entryCount} entries, ${log.attachmentCount} attachments, ${_formatBytes(log.sizeBytes!)}'),
          if (isFailed && log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (isInProgress) const Text('In progress...'),
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
          const SnackBar(content: Text('Backup completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
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
        title: const Text('Backup Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter encryption password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
                    const SnackBar(
                        content: Text('Backup completed successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isBackingUp = false);
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required')),
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
        const SnackBar(content: Text('Backup schedule saved')),
      );
    }
  }

  Future<void> _disableSchedule() async {
    final scheduler = ref.read(backupSchedulerProvider);
    await scheduler.disable();
    _refreshAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup schedule disabled')),
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
