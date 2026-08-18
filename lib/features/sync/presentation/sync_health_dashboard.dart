import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Dashboard widget for the Settings screen showing sync health metrics:
/// last sync time, recent failure count, pending conflicts, and sync log.
class SyncHealthDashboard extends ConsumerWidget {
  final VoidCallback? onViewConflicts;
  final VoidCallback? onSyncNow;

  const SyncHealthDashboard({super.key, this.onViewConflicts, this.onSyncNow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncStatusProvider);
    final lastSyncAsync = ref.watch(latestSuccessfulSyncProvider);
    final failureCountAsync = ref.watch(recentSyncFailureCountProvider);
    final conflictCount =
        ref.watch(pendingConflictCountProvider).asData?.value ?? 0;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.sync, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.syncHealthHeading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusChip(status: status),
              ],
            ),
            const Divider(height: 24),

            // Last sync
            lastSyncAsync.when(
              loading: () => _MetricRow(
                label: l10n.syncLastSync,
                value: l10n.commonLoading,
              ),
              error: (_, _) => _MetricRow(
                label: l10n.syncLastSync,
                value: l10n.commonErrorShort,
              ),
              data: (log) => _MetricRow(
                label: l10n.syncLastSync,
                value: log != null
                    ? _formatDateTime(log.completedAt!)
                    : l10n.syncNever,
              ),
            ),
            const SizedBox(height: 8),

            // Failures
            failureCountAsync.when(
              loading: () => _MetricRow(
                label: l10n.syncFailures7d,
                value: l10n.commonEllipsis,
              ),
              error: (_, _) => _MetricRow(
                label: l10n.syncFailures7d,
                value: l10n.commonErrorShort,
              ),
              data: (count) => _MetricRow(
                label: l10n.syncFailures7d,
                value: '$count',
                valueColor: count > 0 ? theme.colorScheme.error : Colors.green,
              ),
            ),
            const SizedBox(height: 8),

            // Conflicts
            _MetricRow(
              label: l10n.syncPendingConflicts,
              value: '$conflictCount',
              valueColor: conflictCount > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (conflictCount > 0)
                  OutlinedButton.icon(
                    onPressed: onViewConflicts,
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: Text(l10n.syncResolveCount(conflictCount)),
                  ),
                if (conflictCount > 0) const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: status == SyncStatus.syncing ? null : onSyncNow,
                  icon: const Icon(Icons.sync, size: 18),
                  label: Text(l10n.syncNow),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent log
            Text(l10n.syncRecentActivity, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            _SyncLogList(),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final SyncStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      SyncStatus.idle => (l10n.syncStatusIdle, Colors.grey),
      SyncStatus.syncing => (l10n.syncStatusSyncing, Colors.blue),
      SyncStatus.success => (l10n.syncStatusHealthy, Colors.green),
      SyncStatus.failed => (l10n.syncStatusFailed, Colors.red),
      SyncStatus.conflict => (l10n.syncStatusConflicts, Colors.orange),
    };

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _SyncLogList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logsAsync = ref.watch(recentSyncLogsProvider);
    final theme = Theme.of(context);

    return logsAsync.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Text(
        l10n.syncLogsLoadFailed(error.toString()),
        style: theme.textTheme.bodySmall,
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Text(
            l10n.syncNoActivity,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          );
        }

        return Column(
          children: logs.take(5).map((log) => _SyncLogRow(log: log)).toList(),
        );
      },
    );
  }
}

class _SyncLogRow extends StatelessWidget {
  final SyncLog log;
  const _SyncLogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (log.status) {
      'success' => (Icons.check_circle, Colors.green),
      'failed' => (Icons.cancel, Colors.red),
      'partial' => (Icons.warning, Colors.orange),
      _ => (Icons.hourglass_bottom, Colors.grey),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _logSummary(AppLocalizations.of(context), log),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(log.startedAt),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _logSummary(AppLocalizations l10n, SyncLog log) {
    if (log.status == 'failed') {
      return log.errorMessage ?? l10n.syncLogFailed;
    }
    final parts = <String>[];
    if (log.recordsPushed > 0) {
      parts.add(l10n.syncLogPushed(log.recordsPushed));
    }
    if (log.recordsPulled > 0) {
      parts.add(l10n.syncLogPulled(log.recordsPulled));
    }
    if (log.conflictsDetected > 0) {
      parts.add(l10n.syncLogConflicts(log.conflictsDetected));
    }
    return parts.isEmpty ? l10n.syncLogNoChanges : parts.join(', ');
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
