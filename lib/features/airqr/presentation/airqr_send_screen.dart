import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_payload_text.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_sender.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen that loops an animated stream of QR frames to send data over light.
class AirqrSendScreen extends ConsumerStatefulWidget {
  final AirqrPayload payload;

  const AirqrSendScreen({super.key, required this.payload});

  @override
  ConsumerState<AirqrSendScreen> createState() => _AirqrSendScreenState();
}

class _AirqrSendScreenState extends ConsumerState<AirqrSendScreen> {
  late final AirqrSendController _controller;

  @override
  void initState() {
    super.initState();
    // Protect pairing screen with FLAG_SECURE
    ref.read(screenSecurityProvider.notifier).setEnabled(true);

    _controller = AirqrSendController(payload: widget.payload);
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleAirqrSend)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          // The controller's message is internal detail; the user gets a
          // fixed sentence in their own language.
          if (_controller.errorMessage != null) {
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
                    Text(l10n.errorAirqrEncode, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _controller.start(),
                      child: Text(l10n.errorCommonRetry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.isEncoding) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.bodyAirqrEncoding),
                ],
              ),
            );
          }

          final frame = _controller.currentFrame;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Payload Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _controller.payload.kind == 'settings'
                          ? Icons.settings_suggest_rounded
                          : Icons.auto_stories_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _controller.payload.titleIn(l10n),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.descAirqrPayloadSize(
                              _controller.encoded?.payloadBytes ?? 0,
                              _controller.totalDataFrames,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Animated QR Container
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
                  child: frame == null
                      ? const SizedBox(width: 250, height: 250)
                      : QrImageView(
                          data: frame,
                          size: 250,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Frame Counter Chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _controller.isManifestFrame
                        ? l10n.labelAirqrManifestFrame
                        : l10n.labelAirqrFrameOf(
                            _controller.currentFrameIndex,
                            _controller.totalDataFrames,
                          ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pairing Code Card
              if (_controller.isEncrypted)
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.labelSyncPairingCode,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              AirqrCodec.formatCode(_controller.pairingCode),
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
                          tooltip: l10n.tooltipCopyPairingCode,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: AirqrCodec.formatCode(
                                  _controller.pairingCode,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.bodySyncPairingCodeCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Speed & Frame Rate Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.labelAirqrSpeed(_controller.fps),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton.outlined(
                        icon: const Icon(Icons.remove, size: 16),
                        tooltip: l10n.tooltipSlower,
                        onPressed: _controller.fps > 2
                            ? () => _controller.setFps(_controller.fps - 1)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        icon: const Icon(Icons.add, size: 16),
                        tooltip: l10n.tooltipFaster,
                        onPressed: _controller.fps < 12
                            ? () => _controller.setFps(_controller.fps + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
