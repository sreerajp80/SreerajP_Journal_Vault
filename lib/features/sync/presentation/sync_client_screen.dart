import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:sreerajp_journal_vault/features/sync/presentation/sync_text.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/wifi_sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Client Screen (Receive Mode)
///
/// Connects to a Host device via Camera QR scan or manual IP/port/code entry,
/// completes the cryptographic handshake, pulls & decrypts entries and attachments.
class SyncClientScreen extends ConsumerStatefulWidget {
  const SyncClientScreen({super.key});

  @override
  ConsumerState<SyncClientScreen> createState() => _SyncClientScreenState();
}

class _SyncClientScreenState extends ConsumerState<SyncClientScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();

  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessingScan) return;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        final parseResult = WifiSyncCrypto.parseQrUri(rawValue);
        if (parseResult.isOk && parseResult.pairing != null) {
          _isProcessingScan = true;
          _connectAndSync(
            host: parseResult.pairing!.host,
            port: parseResult.pairing!.port,
            code: parseResult.pairing!.code,
          );
          break;
        }
      }
    }
  }

  Future<void> _connectAndSync({
    required String host,
    required int port,
    required String code,
  }) async {
    final result = await ref
        .read(wifiSyncClientProvider.notifier)
        .connectAndSync(host: host, port: port, code: code);

    if (mounted &&
        result != SyncStatus.success &&
        result != SyncStatus.conflict) {
      // Allow re-scanning after error
      setState(() {
        _isProcessingScan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final clientState = ref.watch(wifiSyncClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleSyncClient),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              text: l10n.tabSyncTabQrScan,
            ),
            Tab(
              icon: const Icon(Icons.edit_note_rounded),
              text: l10n.tabSyncTabManualEntry,
            ),
          ],
        ),
      ),
      body:
          clientState.step != ClientSyncStep.idle &&
              clientState.step != ClientSyncStep.error
          ? _SyncProgressView(state: clientState)
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Camera QR Scanner
                Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                    // Scanner Viewfinder Overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    // Top instructions banner
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.descSyncScanInstructions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Bottom controls (Flash & Camera switch)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.flash_on_rounded),
                            tooltip: AppLocalizations.of(
                              context,
                            ).tooltipToggleTorch,
                            onPressed: () => _scannerController.toggleTorch(),
                          ),
                          const SizedBox(width: 20),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.cameraswitch_rounded),
                            tooltip: AppLocalizations.of(
                              context,
                            ).tooltipSwitchCamera,
                            onPressed: () => _scannerController.switchCamera(),
                          ),
                        ],
                      ),
                    ),
                    if (clientState.step == ClientSyncStep.error)
                      Positioned(
                        bottom: 90,
                        left: 20,
                        right: 20,
                        child: _ErrorBanner(
                          error: l10n.errorSyncFailed,
                          onRetry: () =>
                              ref.read(wifiSyncClientProvider.notifier).reset(),
                        ),
                      ),
                  ],
                ),

                // Tab 2: Manual Details Entry
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _hostController,
                          decoration: InputDecoration(
                            labelText: l10n.labelSyncIp,
                            hintText: l10n.descSyncHostAddress,
                            prefixIcon: const Icon(Icons.lan_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.errorSyncIpRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _portController,
                          decoration: InputDecoration(
                            labelText: l10n.labelSyncPort,
                            hintText: l10n.descSyncPort,
                            prefixIcon: const Icon(Icons.numbers_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final p = int.tryParse(v ?? '');
                            if (p == null || p < 1 || p > 65535) {
                              return l10n.errorSyncPortInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: l10n.labelSyncPairingCode,
                            hintText: l10n.descSyncCode,
                            prefixIcon: const Icon(Icons.key_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v == null || !WifiSyncCrypto.isValidCode(v)) {
                              return l10n.errorSyncCodeInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _connectAndSync(
                                host: _hostController.text.trim(),
                                port: int.parse(_portController.text.trim()),
                                code: _codeController.text.trim(),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync_rounded),
                          label: Text(l10n.actionSyncButtonConnect),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (clientState.step == ClientSyncStep.error) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(
                            error: l10n.errorSyncFailed,
                            onRetry: () => ref
                                .read(wifiSyncClientProvider.notifier)
                                .reset(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SyncProgressView extends StatelessWidget {
  final ClientSyncState state;

  const _SyncProgressView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCompleted = state.step == ClientSyncStep.completed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.12)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 56,
                    )
                  : const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(strokeWidth: 4),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              state.step.textIn(l10n),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (isCompleted)
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCommonDone),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.of(context).errorCommonRetry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
