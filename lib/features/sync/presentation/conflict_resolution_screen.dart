import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/conflict_resolution_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen that lists all pending sync conflicts and lets the user resolve each
/// one by choosing Keep Local, Keep Remote, or viewing a side-by-side diff.
class ConflictResolutionScreen extends ConsumerWidget {
  const ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conflictsAsync = ref.watch(conflictDetailsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSyncConflicts)),
      body: conflictsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.errorSyncConflictsLoad(error.toString()),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(conflictDetailsProvider),
                child: Text(l10n.errorCommonRetry),
              ),
            ],
          ),
        ),
        data: (conflicts) {
          if (conflicts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptySyncNoConflicts,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.emptySyncAllInSync,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _ConflictCard(conflict: conflict);
            },
          );
        },
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  final ConflictDetail conflict;

  const _ConflictCard({required this.conflict});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tableDisplayName(conflict.recordTable),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'v${conflict.localVersion} vs v${conflict.remoteVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Detected timestamp
            Text(
              l10n.labelSyncDetectedAt(_formatDateTime(conflict.detectedAt)),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Field diffs
            if (conflict.diffs.isNotEmpty) ...[
              Text(
                l10n.titleSyncChangedFields,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              ...conflict.diffs.map((diff) => _FieldDiffRow(diff: diff)),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showDetailDialog(context, ref),
                  icon: const Icon(Icons.compare_arrows, size: 18),
                  label: Text(l10n.actionSyncCompare),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () =>
                      _resolve(ref, ConflictResolution.keepRemote, context),
                  child: Text(l10n.actionSyncKeepRemote),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      _resolve(ref, ConflictResolution.keepLocal, context),
                  child: Text(l10n.actionSyncKeepLocal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(
    WidgetRef ref,
    ConflictResolution resolution,
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final keepLocal = resolution == ConflictResolution.keepLocal;
        return AlertDialog(
          title: Text(
            keepLocal ? l10n.bodySyncKeepLocal : l10n.bodySyncKeepRemote,
          ),
          content: Text(
            keepLocal
                ? l10n.bodySyncKeepLocalBody
                : l10n.bodySyncKeepRemoteBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCommonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.bodyCommon),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(conflictResolutionServiceProvider);
      await service.resolveConflict(
        conflictId: conflict.conflictId,
        resolution: resolution,
      );
      ref.invalidate(conflictDetailsProvider);
      ref.invalidate(pendingConflictsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).bodySyncConflictResolved,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorSyncResolution(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _ConflictDetailDialog(conflict: conflict),
    );
  }

  String _tableDisplayName(String table) {
    return table
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _FieldDiffRow extends StatelessWidget {
  final FieldDiff diff;

  const _FieldDiffRow({required this.diff});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              _formatFieldName(diff.fieldName),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${_truncate(diff.localValue)} → ${_truncate(diff.remoteValue)}',
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _truncate(dynamic value) {
    final str = value?.toString() ?? 'null';
    return str.length > 60 ? '${str.substring(0, 57)}...' : str;
  }
}

/// Full side-by-side comparison dialog for a single conflict.
class _ConflictDetailDialog extends StatelessWidget {
  final ConflictDetail conflict;

  const _ConflictDetailDialog({required this.conflict});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.titleSyncConflictDetails,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(
                      color: theme.dividerColor,
                      width: 0.5,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        children: [
                          _TableHeader(l10n.titleSyncColumnField),
                          _TableHeader(l10n.titleSyncColumnLocal),
                          _TableHeader(l10n.titleSyncColumnRemote),
                        ],
                      ),
                      ...conflict.diffs.map(
                        (diff) => TableRow(
                          children: [
                            _TableCell(diff.fieldName, bold: true),
                            _TableCell(diff.localValue?.toString() ?? 'null'),
                            _TableCell(diff.remoteValue?.toString() ?? 'null'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.actionCommonClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  const _TableCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text.length > 200 ? '${text.substring(0, 197)}...' : text,
        style: bold
            ? Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
            : Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
