import 'package:flutter/material.dart';
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
          title: Text(l10n.airqrTooLargeTitle),
          content: Text(
            '${_formatSize(byteCount)} is too large for optical QR sync (Limit: ${_formatSize(AirqrConstants.hardCapBytes)}). Please use local Wi-Fi Sync instead.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
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
        ? '${(estimateSecs / 60).ceil()} minutes'
        : '$estimateSecs seconds';

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.hourglass_top_rounded,
          color: Colors.orange,
          size: 36,
        ),
        title: Text(l10n.airqrSlowTitle),
        content: Text(
          'This transfer is ${_formatSize(byteCount)} and will take approximately $estimateText over optical QR. Wi-Fi Sync is much faster for larger transfers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.airqrSendAnyway),
          ),
        ],
      ),
    );

    return proceed ?? false;
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).round()} KB';
    }
    return '$bytes B';
  }
}
