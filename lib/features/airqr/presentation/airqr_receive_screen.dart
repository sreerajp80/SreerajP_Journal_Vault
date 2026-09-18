import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_payload_text.dart';
import 'package:sreerajp_journal_vault/features/airqr/providers/airqr_providers.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_receiver.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'airqr_receive_views.dart';

/// Screen that scans an animated QR frame stream and applies or imports the result.
class AirqrReceiveScreen extends ConsumerStatefulWidget {
  const AirqrReceiveScreen({super.key});

  @override
  ConsumerState<AirqrReceiveScreen> createState() => _AirqrReceiveScreenState();
}

class _AirqrReceiveScreenState extends ConsumerState<AirqrReceiveScreen> {
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleAirqrReceive),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.tooltipResetScanner,
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
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.bodyAirqrAssembling),
                  ],
                ),
              );
            case AirqrReceivePhase.done:
              return _buildResultView(_receiveController.result!, theme, l10n);
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
                      // The controller's message is internal detail; the
                      // user gets a fixed sentence in their own language.
                      Text(
                        l10n.errorAirqrDecode,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.actionAirqrScanAgain),
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
}
