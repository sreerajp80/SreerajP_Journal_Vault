import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_landing_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/conflict_resolution_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_client_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_health_dashboard.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_host_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/wifi_sync_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Main Landing Hub for Peer-to-Peer Wi-Fi Sync.
class SyncLandingScreen extends ConsumerWidget {
  const SyncLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ipListAsync = ref.watch(localIpv4ListProvider);
    final pendingConflictsAsync = ref.watch(pendingConflictCountProvider);
    final latestSyncAsync = ref.watch(latestSuccessfulSyncProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncLandingTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header card
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_tethering_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.syncLandingTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            ipListAsync.when(
                              data: (ips) => Text(
                                ips.isNotEmpty
                                    ? 'IP: ${ips.join(', ')}'
                                    : l10n.syncNoWifiAlert,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: ips.isNotEmpty
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.error,
                                ),
                              ),
                              loading: () => const Text('Detecting Wi-Fi...'),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.syncLandingSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Send Changes (Host)
          _SyncModeCard(
            icon: Icons.upload_rounded,
            title: l10n.syncSendTitle,
            subtitle: l10n.syncSendSubtitle,
            color: theme.colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SyncHostScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Receive Changes (Client)
          _SyncModeCard(
            icon: Icons.download_rounded,
            title: l10n.syncReceiveTitle,
            subtitle: l10n.syncReceiveSubtitle,
            color: theme.colorScheme.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SyncClientScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Option 3: Optical Air-Gap Sync (AirQR)
          _SyncModeCard(
            icon: Icons.qr_code_2_rounded,
            title: l10n.airqrTitle,
            subtitle: l10n.airqrIntro,
            color: theme.colorScheme.tertiary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AirqrLandingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Health & History Section
          Text(
            l10n.storageSyncHealth,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.monitor_heart_outlined),
                  title: Text(l10n.storageSyncHealth),
                  subtitle: latestSyncAsync.when(
                    data: (log) => Text(
                      log != null && log.completedAt != null
                          ? '${l10n.syncLastSync}: ${log.completedAt}'
                          : l10n.syncNever,
                    ),
                    loading: () => const Text('...'),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text(l10n.storageSyncHealth)),
                          body: const SyncHealthDashboard(),
                        ),
                      ),
                    );
                  },
                ),
                pendingConflictsAsync.when(
                  data: (count) => count > 0
                      ? Column(
                          children: [
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.error,
                              ),
                              title: Text(l10n.syncConflictsTitle),
                              subtitle: Text('$count unresolved conflicts'),
                              trailing: Badge(
                                label: Text('$count'),
                                child: const Icon(Icons.chevron_right),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ConflictResolutionScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SyncModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
