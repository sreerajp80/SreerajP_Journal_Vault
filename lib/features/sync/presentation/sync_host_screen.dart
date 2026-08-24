import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/wifi_sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Host Screen (Send Mode)
///
/// Starts a local socket server, derives a one-time session pairing code,
/// displays the pairing QR code and connection details, and pushes updates
/// to an authenticated peer. Protected with FLAG_SECURE.
class SyncHostScreen extends ConsumerStatefulWidget {
  const SyncHostScreen({super.key});

  @override
  ConsumerState<SyncHostScreen> createState() => _SyncHostScreenState();
}

class _SyncHostScreenState extends ConsumerState<SyncHostScreen> {
  bool _isSyncing = false;
  String? _syncFeedback;

  @override
  void initState() {
    super.initState();
    // Protect pairing code screen with FLAG_SECURE
    ref.read(screenSecurityProvider.notifier).setEnabled(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wifiSyncHostProvider.notifier).startHost();
    });
  }

  @override
  void dispose() {
    ref.read(wifiSyncHostProvider.notifier).stopHost();
    super.dispose();
  }

  Future<void> _performHostPush(
    BuildContext context,
    WifiSyncHost host,
    String pairingCode,
  ) async {
    setState(() {
      _isSyncing = true;
      _syncFeedback = null;
    });

    try {
      final protocol = WifiSyncProtocol.forHost(host);
      final db = ref.read(appDatabaseProvider);
      final encryption = ref.read(syncEncryptionServiceProvider);
      final deviceId = await ref.read(syncDeviceIdProvider.future);
      final cipher = ref.read(backupAttachmentCipherProvider);

      final engine = SyncEngine(
        db: db,
        protocol: protocol,
        encryption: encryption,
        deviceId: deviceId,
        attachmentCipher: cipher,
      );

      final status = await engine.performSync(syncPassword: pairingCode);

      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _syncFeedback =
            status == SyncStatus.success || status == SyncStatus.conflict
            ? AppLocalizations.of(context).syncStatusCompleted
            : AppLocalizations.of(context).syncStatusError;
      });

      ref.invalidate(recentSyncLogsProvider);
      ref.invalidate(latestSuccessfulSyncProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _syncFeedback = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hostState = ref.watch(wifiSyncHostProvider);
    final ipListAsync = ref.watch(localIpv4ListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncHostTitle),
        actions: [
          IconButton(
            icon: Icon(
              hostState.phase == HostPhase.stopped
                  ? Icons.play_arrow_rounded
                  : Icons.refresh_rounded,
            ),
            tooltip: hostState.phase == HostPhase.stopped
                ? l10n.syncButtonStart
                : l10n.syncButtonStop,
            onPressed: () {
              if (hostState.phase == HostPhase.stopped) {
                ref.read(wifiSyncHostProvider.notifier).startHost();
              } else {
                ref.read(wifiSyncHostProvider.notifier).startHost();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Phase status badge
          _HostPhaseStatusBadge(phase: hostState.phase),
          const SizedBox(height: 20),

          // Main QR Code Container
          if (hostState.pairingCode != null && hostState.port != null)
            ipListAsync.when(
              data: (ips) {
                final hostIp = ips.isNotEmpty ? ips.first : '127.0.0.1';
                final qrUri = WifiSyncCrypto.buildQrUri(
                  QrPairing(
                    host: hostIp,
                    port: hostState.port!,
                    code: hostState.pairingCode!,
                  ),
                );

                return Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrUri,
                          size: 220.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.syncScanInstructions,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

          const SizedBox(height: 24),

          // Connection Details Card
          if (hostState.pairingCode != null && hostState.port != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pairing Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.syncPairingCodeLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              WifiSyncCrypto.formatCode(hostState.pairingCode!),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: l10n.syncPairingCodeCopied,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: WifiSyncCrypto.formatCode(
                                  hostState.pairingCode!,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.syncPairingCodeCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // IP Address & Port
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.syncIpLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              ipListAsync.when(
                                data: (ips) => SelectableText(
                                  ips.isNotEmpty ? ips.join(', ') : 'None',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                loading: () => const Text('...'),
                                error: (_, _) => const Text('Error'),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.syncPortLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SelectableText(
                              '${hostState.port}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Sync Action Button (Enabled once a client is connected)
          if (hostState.host != null && hostState.host!.hasClient)
            FilledButton.icon(
              onPressed: _isSyncing
                  ? null
                  : () => _performHostPush(
                      context,
                      hostState.host!,
                      hostState.pairingCode!,
                    ),
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(
                _isSyncing ? l10n.syncStatusSyncing : l10n.syncButtonConnect,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          if (_syncFeedback != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _syncFeedback!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _syncFeedback!.contains('Error')
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostPhaseStatusBadge extends StatelessWidget {
  final HostPhase phase;

  const _HostPhaseStatusBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (color, icon, label) = switch (phase) {
      HostPhase.listening => (
        theme.colorScheme.primary,
        Icons.radar_rounded,
        l10n.syncStatusListening,
      ),
      HostPhase.connected => (
        Colors.green,
        Icons.check_circle_outline_rounded,
        l10n.syncStatusConnected,
      ),
      HostPhase.syncing => (
        Colors.orange,
        Icons.sync_rounded,
        l10n.syncStatusSyncing,
      ),
      HostPhase.completed => (
        Colors.green,
        Icons.task_alt_rounded,
        l10n.syncStatusCompleted,
      ),
      HostPhase.denied => (
        theme.colorScheme.error,
        Icons.block_rounded,
        l10n.syncStatusDenied,
      ),
      HostPhase.stopped => (
        theme.colorScheme.onSurfaceVariant,
        Icons.stop_circle_outlined,
        l10n.syncStatusStopped,
      ),
      HostPhase.error => (
        theme.colorScheme.error,
        Icons.error_outline_rounded,
        l10n.syncStatusError,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
