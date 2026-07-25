import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';

/// Dashboard widget for the Settings screen showing sync health metrics:
/// last sync time, recent failure count, pending conflicts, and sync log.
class SyncHealthDashboard extends ConsumerWidget {
  final VoidCallback? onViewConflicts;
  final VoidCallback? onSyncNow;

  const SyncHealthDashboard({
    super.key,
    this.onViewConflicts,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text('Sync Health',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                _StatusChip(status: status),
              ],
            ),
            const Divider(height: 24),

            // Last sync
            lastSyncAsync.when(
              loading: () => const _MetricRow(
                  label: 'Last sync', value: 'Loading...'),
              error: (_, _) =>
                  const _MetricRow(label: 'Last sync', value: 'Error'),
              data: (log) => _MetricRow(
                label: 'Last sync',
                value: log != null
                    ? _formatDateTime(log.completedAt!)
                    : 'Never',
              ),
            ),
            const SizedBox(height: 8),

            // Failures
            failureCountAsync.when(
              loading: () => const _MetricRow(
                  label: 'Failures (7d)', value: '...'),
              error: (_, _) =>
                  const _MetricRow(label: 'Failures (7d)', value: 'Error'),
              data: (count) => _MetricRow(
                label: 'Failures (7d)',
                value: '$count',
                valueColor:
                    count > 0 ? theme.colorScheme.error : Colors.green,
              ),
            ),
            const SizedBox(height: 8),

            // Conflicts
            _MetricRow(
              label: 'Pending conflicts',
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
                    label: Text('Resolve ($conflictCount)'),
                  ),
                if (conflictCount > 0) const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed:
                      status == SyncStatus.syncing ? null : onSyncNow,
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync Now'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent log
            Text('Recent Activity',
                style: theme.textTheme.labelMedium),
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
    final (label, color) = switch (status) {
      SyncStatus.idle => ('Idle', Colors.grey),
      SyncStatus.syncing => ('Syncing', Colors.blue),
      SyncStatus.success => ('Healthy', Colors.green),
      SyncStatus.failed => ('Failed', Colors.red),
      SyncStatus.conflict => ('Conflicts', Colors.orange),
    };

    return Chip(
      label: Text(label,
          style: TextStyle(color: color, fontSize: 12)),
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

  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            )),
      ],
    );
  }
}

class _SyncLogList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(recentSyncLogsProvider);
    final theme = Theme.of(context);

    return logsAsync.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Text('Failed to load logs: $error',
          style: theme.textTheme.bodySmall),
      data: (logs) {
        if (logs.isEmpty) {
          return Text('No sync activity yet.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey));
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
              _logSummary(log),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(log.startedAt),
            style:
                theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _logSummary(SyncLog log) {
    if (log.status == 'failed') {
      return log.errorMessage ?? 'Sync failed';
    }
    final parts = <String>[];
    if (log.recordsPushed > 0) parts.add('${log.recordsPushed} pushed');
    if (log.recordsPulled > 0) parts.add('${log.recordsPulled} pulled');
    if (log.conflictsDetected > 0) {
      parts.add('${log.conflictsDetected} conflicts');
    }
    return parts.isEmpty ? 'No changes' : parts.join(', ');
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
