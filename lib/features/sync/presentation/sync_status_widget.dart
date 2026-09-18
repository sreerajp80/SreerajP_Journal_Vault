import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/sync/presentation/sync_text.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Compact sync status indicator for use in app bars or settings.
///
/// Shows the current sync state with an icon and optional label,
/// plus a badge for unresolved conflict count.
class SyncStatusWidget extends ConsumerWidget {
  final bool showLabel;
  final VoidCallback? onTap;

  const SyncStatusWidget({super.key, this.showLabel = true, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final conflictCount =
        ref.watch(pendingConflictCountProvider).asData?.value ?? 0;
    final theme = Theme.of(context);

    final (icon, color) = _statusDisplay(status, theme);
    final label = status.textIn(AppLocalizations.of(context));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: conflictCount > 0,
              label: Text('$conflictCount'),
              child: status == SyncStatus.syncing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(icon, size: 20, color: color),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, Color) _statusDisplay(SyncStatus status, ThemeData theme) {
    return switch (status) {
      SyncStatus.idle => (
        Icons.cloud_outlined,
        theme.colorScheme.onSurfaceVariant,
      ),
      SyncStatus.syncing => (Icons.sync, theme.colorScheme.primary),
      SyncStatus.success => (Icons.cloud_done_outlined, Colors.green),
      SyncStatus.failed => (Icons.cloud_off_outlined, theme.colorScheme.error),
      SyncStatus.conflict => (Icons.warning_amber_rounded, Colors.orange),
    };
  }
}
