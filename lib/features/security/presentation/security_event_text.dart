import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Words a security event for the screen, in the user's language.
///
/// The `description` stored on the row is an audit record written in English
/// when the event happened; it stays as it was written. What the reader sees
/// comes from the event type instead, so an old log still reads correctly
/// after the user switches language.
extension SecurityEventText on SecurityEvent {
  String descriptionIn(AppLocalizations l10n) =>
      securityEventLabel(l10n, eventType);
}

/// The sentence for one `eventType` value.
String securityEventLabel(AppLocalizations l10n, String eventType) {
  switch (eventType) {
    case 'failed_auth':
      return l10n.labelSecurityEventFailedAuth;
    case 'attachment_locked':
      return l10n.labelSecurityEventAttachmentLocked;
    case 'attachment_unlocked':
      return l10n.labelSecurityEventAttachmentUnlocked;
    case 'export_attempt':
      return l10n.labelSecurityEventExportAttempt;
    case 'lock_triggered':
      return l10n.labelSecurityEventLockTriggered;
    case 'profile_changed':
      return l10n.labelSecurityEventProfileChanged;
    case 'profile_created':
      return l10n.labelSecurityEventProfileCreated;
    case 'screen_security_changed':
      return l10n.labelSecurityEventScreenSecurityChanged;
    case 'tamper_detected':
      return l10n.labelSecurityEventTamperDetected;
    default:
      return l10n.labelSecurityEventOther;
  }
}
