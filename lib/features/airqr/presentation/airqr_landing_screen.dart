import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_receive_screen.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_send_screen.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_size_warning.dart';
import 'package:sreerajp_journal_vault/features/airqr/providers/airqr_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Landing hub for Optical Air-Gap Sync (AirQR).
class AirqrLandingScreen extends ConsumerWidget {
  const AirqrLandingScreen({super.key});

  Future<void> _sendSettings(BuildContext context, WidgetRef ref) async {
    final payload = await ref
        .read(airqrSettingsServiceProvider)
        .exportCurrentSettings();
    final bytes = payload.toBytes().length;

    if (!context.mounted) return;
    final proceed = await AirqrSizeWarning.confirm(
      context: context,
      byteCount: bytes,
    );

    if (proceed && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AirqrSendScreen(payload: payload),
        ),
      );
    }
  }

  Future<void> _sendJournal(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();

    if (!context.mounted) return;
    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).bodyAirqrNoJournals),
        ),
      );
      return;
    }

    final selectedJournal = await showModalBottomSheet<(int, String)?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  AppLocalizations.of(
                    bottomSheetContext,
                  ).titleAirqrSelectJournal,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(),
              ...journals.map(
                (j) => ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(j.title),
                  subtitle: Text(
                    j.description ??
                        AppLocalizations.of(
                          bottomSheetContext,
                        ).descAirqrNoDescription,
                  ),
                  onTap: () =>
                      Navigator.pop(bottomSheetContext, (j.id, j.title)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedJournal == null || !context.mounted) return;

    final (journalId, journalTitle) = selectedJournal;
    final entries = await db.entriesDao.getEntriesForJournal(journalId);
    final entryMaps = entries
        .map(
          (e) => {
            'title': e.title,
            'contentJson': e.contentJson,
            'plainText': e.plainText,
            'createdAt': e.createdAt.toIso8601String(),
          },
        )
        .toList();

    final payload = AirqrPayload.journal(
      title: journalTitle,
      entries: entryMaps,
      tags: const [],
    );

    final bytes = payload.toBytes().length;
    if (!context.mounted) return;
    final proceed = await AirqrSizeWarning.confirm(
      context: context,
      byteCount: bytes,
    );

    if (proceed && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AirqrSendScreen(payload: payload),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleAirqr)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Card
          Card(
            elevation: 0,
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: theme.colorScheme.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.titleAirqr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.descAirqrOffline,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.descAirqrIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action 1: Sync Settings (First-class feature)
          _AirqrActionCard(
            icon: Icons.settings_suggest_rounded,
            title: l10n.titleAirqrSyncSettings,
            subtitle: l10n.descAirqrSyncSettings,
            color: theme.colorScheme.primary,
            badgeText: l10n.labelAirqrBadgeFast,
            onTap: () => _sendSettings(context, ref),
          ),
          const SizedBox(height: 12),

          // Action 2: Sync Journal
          _AirqrActionCard(
            icon: Icons.menu_book_rounded,
            title: l10n.titleAirqrSyncJournal,
            subtitle: l10n.descAirqrSyncJournal,
            color: theme.colorScheme.tertiary,
            onTap: () => _sendJournal(context, ref),
          ),
          const SizedBox(height: 12),

          // Action 3: Receive Data via Camera
          _AirqrActionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: l10n.actionAirqrReceive,
            subtitle: l10n.descAirqrReceive,
            color: theme.colorScheme.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AirqrReceiveScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Speed & Air-Gap Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.titleAirqrSpeedNote,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bodyAirqrSpeedNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AirqrActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badgeText;
  final VoidCallback onTap;

  const _AirqrActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
