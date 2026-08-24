import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/providers/airqr_providers.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_receiver.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen that scans an animated QR frame stream and applies or imports the result.
class AirqrReceiveScreen extends ConsumerStatefulWidget {
  const AirqrReceiveScreen({super.key});

  @override
  ConsumerState<AirqrReceiveScreen> createState() => _AirqrReceiveScreenState();
}

class _AirqrReceiveScreenState extends ConsumerState<AirqrReceiveScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final AirqrReceiveController _receiveController = AirqrReceiveController();
  final _codeTextController = TextEditingController();
  bool _isImporting = false;
  String? _importSuccessMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    _receiveController.dispose();
    _codeTextController.dispose();
    super.dispose();
  }

  Future<void> _applyPayload(AirqrPayload payload) async {
    setState(() {
      _isImporting = true;
    });

    try {
      if (payload.kind == 'settings') {
        await ref.read(airqrSettingsServiceProvider).applySettings(payload);
        if (!mounted) return;
        setState(() {
          _isImporting = false;
          _importSuccessMessage =
              'Settings and templates applied successfully!';
        });
      } else if (payload.kind == 'entry') {
        final db = ref.read(appDatabaseProvider);
        final journals = await db.journalsDao.getAllJournals();
        final journalId = journals.isNotEmpty ? journals.first.id : 1;
        final title = payload.data['title'] as String? ?? 'Imported Entry';
        final contentJson = payload.data['contentJson'] as String? ?? '';
        final plainText = payload.data['plainText'] as String? ?? '';
        final mood = payload.data['mood'] as String?;

        final entryId = await db.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journalId,
            title: Value(title),
            contentJson: Value(contentJson),
            plainText: Value(plainText),
          ),
        );

        if (mood != null && mood.isNotEmpty) {
          final moodInt = int.tryParse(mood);
          if (moodInt != null && moodInt >= 1 && moodInt <= 5) {
            await db.entryMoodsDao.upsertMood(
              EntryMoodsCompanion.insert(entryId: entryId, mood: moodInt),
            );
          }
        }

        if (!mounted) return;
        setState(() {
          _isImporting = false;
          _importSuccessMessage = 'Entry imported successfully into journal!';
        });
      } else if (payload.kind == 'journal') {
        final db = ref.read(appDatabaseProvider);
        final title = payload.data['title'] as String? ?? 'Imported Journal';
        final desc = payload.data['description'] as String?;
        final journalId = await db.journalsDao.createJournal(
          JournalsCompanion.insert(title: title, description: Value(desc)),
        );

        final entries = payload.data['entries'] as List<dynamic>? ?? [];
        for (final e in entries) {
          if (e is Map<String, dynamic>) {
            await db.entriesDao.createEntry(
              EntriesCompanion.insert(
                journalId: journalId,
                title: Value(e['title'] as String? ?? 'Entry'),
                contentJson: Value(e['contentJson'] as String? ?? ''),
                plainText: Value(e['plainText'] as String? ?? ''),
              ),
            );
          }
        }

        if (!mounted) return;
        setState(() {
          _isImporting = false;
          _importSuccessMessage = 'Journal and entries imported successfully!';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.airqrReceiveTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Scanner',
            onPressed: () {
              _receiveController.reset();
              setState(() {
                _importSuccessMessage = null;
              });
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _receiveController,
        builder: (context, _) {
          switch (_receiveController.phase) {
            case AirqrReceivePhase.scanning:
              return _buildScanningView(_receiveController, theme, l10n);
            case AirqrReceivePhase.needCode:
              return _buildNeedCodeView(_receiveController, theme, l10n);
            case AirqrReceivePhase.assembling:
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Reassembling & verifying integrity...'),
                  ],
                ),
              );
            case AirqrReceivePhase.done:
              return _buildResultView(_receiveController.result!, theme);
            case AirqrReceivePhase.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _receiveController.errorMessage ?? 'Decoding error',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Scan Again'),
                        onPressed: () => _receiveController.reset(),
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildScanningView(
    AirqrReceiveController controller,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Camera scanner
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final raw = barcode.rawValue;
                    if (raw != null && raw.isNotEmpty) {
                      controller.onScan(raw);
                    }
                  }
                },
              ),
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
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.flash_on_rounded),
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.cameraswitch_rounded),
                      onPressed: () => _scannerController.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live Frame Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.totalFrames != null
                        ? 'Received ${controller.receivedCount} of ${controller.totalFrames} frames'
                        : 'Align camera with animated QR...',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(controller.progress * 100).toInt()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 8,
                ),
              ),
              if (controller.missingFrames.isNotEmpty &&
                  controller.missingFrames.length <= 10) ...[
                const SizedBox(height: 8),
                Text(
                  'Missing frames: ${controller.missingFrames.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeedCodeView(
    AirqrReceiveController controller,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.key_rounded,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter Pairing Code',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 16-character code shown on the sending screen to decrypt.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeTextController,
              decoration: InputDecoration(
                labelText: l10n.syncPairingCodeLabel,
                hintText: 'XXXX-XXXX-XXXX-XXXX',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                final text = _codeTextController.text.trim();
                if (text.isNotEmpty) {
                  controller.submitCode(AirqrCodec.normalizeCode(text));
                }
              },
              child: const Text('Decrypt & Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(AirqrPayload payload, ThemeData theme) {
    if (_importSuccessMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                _importSuccessMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.green,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AirQR Payload Verified',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Payload Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payload.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Type: ${payload.kind.toUpperCase()}'),
                if (payload.kind == 'settings') ...[
                  const Divider(height: 16),
                  Text('Theme: ${payload.data['themeMode']}'),
                  if (payload.data['accentColorArgb'] != null)
                    Text(
                      'Accent Color: #${(payload.data['accentColorArgb'] as int).toRadixString(16).padLeft(8, '0').toUpperCase()}',
                    ),
                  Text(
                    'Templates: ${(payload.data['templates'] as List?)?.length ?? 0} custom templates',
                  ),
                  Text(
                    'Tags: ${(payload.data['tags'] as List?)?.length ?? 0} tags',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: _isImporting ? null : () => _applyPayload(payload),
          icon: _isImporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_done_rounded),
          label: Text(
            payload.kind == 'settings' ? 'Apply Settings' : 'Import to Vault',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
