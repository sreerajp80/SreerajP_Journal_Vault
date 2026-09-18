import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Words an [AirqrPayload] for the screen, in the user's language.
///
/// The payload's own `title` is wire data: it travels inside the QR frames and
/// may have been written on another device in another language. Only a journal
/// or entry title is the user's own text; the rest is worded here.
extension AirqrPayloadText on AirqrPayload {
  String titleIn(AppLocalizations l10n) {
    switch (kind) {
      case AirqrConstants.kindSettings:
        return l10n.titleAirqrPayloadSettings;
      case AirqrConstants.kindSnapshot:
        return l10n.titleAirqrPayloadSnapshot;
      case AirqrConstants.kindEntry:
        final entryTitle = (data['title'] as String?)?.trim() ?? '';
        return entryTitle.isEmpty ? l10n.labelAirqrKindEntry : entryTitle;
      default:
        return title;
    }
  }

  String kindLabelIn(AppLocalizations l10n) {
    switch (kind) {
      case AirqrConstants.kindSettings:
        return l10n.labelAirqrKindSettings;
      case AirqrConstants.kindEntry:
        return l10n.labelAirqrKindEntry;
      case AirqrConstants.kindJournal:
        return l10n.labelAirqrKindJournal;
      default:
        return l10n.labelAirqrKindSnapshot;
    }
  }
}

/// A byte count in the largest unit that keeps it readable.
String airqrSizeText(AppLocalizations l10n, int bytes) {
  if (bytes >= 1024 * 1024) {
    return l10n.labelStorageMegabytes(
      (bytes / (1024 * 1024)).toStringAsFixed(1),
    );
  }
  if (bytes >= 1024) {
    return l10n.labelStorageKilobytes((bytes / 1024).round().toString());
  }
  return l10n.labelStorageBytes(bytes);
}
