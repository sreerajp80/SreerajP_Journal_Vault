import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_payload_text.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Pre-flight size gating modal dialog before initiating optical air-gap sync.
class AirqrSizeWarning {
  AirqrSizeWarning._();

  /// Confirms whether an optical transfer should proceed given [byteCount].
  static Future<bool> confirm({
    required BuildContext context,
    required int byteCount,
  }) async {
    final l10n = AppLocalizations.of(context);

    // 1. Hard cap (> 4 MB)
    if (byteCount > AirqrConstants.hardCapBytes) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.block_rounded, color: Colors.red, size: 36),
          title: Text(l10n.titleAirqrTooLarge),
          content: Text(
            l10n.bodyAirqrTooLarge(
              airqrSizeText(l10n, byteCount),
              airqrSizeText(l10n, AirqrConstants.hardCapBytes),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCommonOk),
            ),
          ],
        ),
      );
      return false;
    }

    // 2. Soft/Warn cap (<= 1 MB)
    if (byteCount <= AirqrConstants.warnCapBytes) {
      return true;
    }

    // 3. Medium-large payload warning (1 MB - 4 MB)
    final estimateSecs = (byteCount / AirqrConstants.estimatedBytesPerSecond)
        .ceil();
    final estimateText = estimateSecs >= 60
        ? l10n.descAirqrMinutes((estimateSecs / 60).ceil())
        : l10n.descAirqrSeconds(estimateSecs);

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.hourglass_top_rounded,
          color: Colors.orange,
          size: 36,
        ),
        title: Text(l10n.titleAirqrSlow),
        content: Text(
          l10n.bodyAirqrSlow(airqrSizeText(l10n, byteCount), estimateText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionAirqrSendAnyway),
          ),
        ],
      ),
    );

    return proceed ?? false;
  }
}
