import 'package:sreerajp_journal_vault/features/sync/providers/wifi_sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Words a sync step for the screen.
///
/// The provider tracks the step as a value, not a sentence, so the words can
/// change with the user's language without the sync logic knowing about it.
extension ClientSyncStepText on ClientSyncStep {
  String textIn(AppLocalizations l10n) {
    switch (this) {
      case ClientSyncStep.connecting:
        return l10n.bodySyncStepConnecting;
      case ClientSyncStep.authenticating:
        return l10n.bodySyncStepAuthenticating;
      case ClientSyncStep.completed:
        return l10n.bodySyncStepCompleted;
      case ClientSyncStep.error:
        return l10n.errorSyncFailed;
      case ClientSyncStep.idle:
      case ClientSyncStep.syncing:
        return l10n.bodySyncStepSyncing;
    }
  }
}

/// Words the overall sync state for the small status indicator.
extension SyncStatusText on SyncStatus {
  String textIn(AppLocalizations l10n) {
    switch (this) {
      case SyncStatus.idle:
        return l10n.labelSyncNotSynced;
      case SyncStatus.syncing:
        return l10n.descSyncStatusSyncing;
      case SyncStatus.success:
        return l10n.labelSyncSynced;
      case SyncStatus.failed:
        return l10n.errorSyncLog;
      case SyncStatus.conflict:
        return l10n.labelSyncStatusConflicts;
    }
  }
}
