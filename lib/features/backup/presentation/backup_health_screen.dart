import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/restore_backup_screen.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_scheduler.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'backup_health_sections.dart';
part 'backup_health_sections_2.dart';

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
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

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
        title: Text(l10n.titleBackup),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: l10n.tooltipCommonRefresh,
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
              _isBackingUp ? l10n.bodyBackupInProgress : l10n.actionBackupNow,
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
            label: Text(l10n.actionRestoreOpen),
          ),
          const SizedBox(height: 24),

          // Backup history
          Text(l10n.titleBackupHistory, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildBackupHistory(theme, recentLogs),
        ],
      ),
    );
  }
}
