// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get vaultUnavailableTitle => 'The vault cannot be opened';

  @override
  String get vaultUnavailableKeyMissing =>
      'The key that unlocks your journal is no longer on this device. Without it, nothing can read the vault — not even this app.';

  @override
  String get vaultUnavailableCipherMissing =>
      'This build of the app cannot encrypt the vault, so it has stopped rather than store your journal unprotected.';

  @override
  String get vaultUnavailableConversionFailed =>
      'Your journal could not be moved into encrypted storage. It has been left exactly as it was — nothing has been deleted.';

  @override
  String get vaultUnavailableFileUnreadable =>
      'The vault file cannot be read. It may be damaged, or it may belong to a different installation of the app.';

  @override
  String get vaultUnavailableDataIntact =>
      'Nothing has been deleted. Your entries and attachments are still on this device.';

  @override
  String get vaultUnavailableNextSteps =>
      'If you have a backup file, reinstall the app and restore from it. If not, keep this installation as it is and do not clear the app data — that would remove the vault for good.';

  @override
  String get appTitle => 'SreerajP Journal Vault';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutLoadError => 'Unable to load app metadata';

  @override
  String get commonRetry => 'Retry';

  @override
  String get aboutVersionBuildLabel => 'App Version / Build';

  @override
  String get aboutLastBuildLabel => 'Last Build Timestamp';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsExplicitHeader => 'Explicit permissions';

  @override
  String get permissionsImplicitHeader => 'Implicit permissions';

  @override
  String get permissionStatusAllowed => 'Allowed';

  @override
  String get permissionStatusDenied => 'Denied';

  @override
  String get permissionStatusPermanentlyDenied => 'Permanently denied';

  @override
  String get permissionStatusUserSelected => 'User selected';

  @override
  String get permissionsRequest => 'Request';

  @override
  String get permissionsOpenSettings => 'Open settings';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get tagsTitle => 'Tags';

  @override
  String tagsLoadError(String error) {
    return 'Could not load tags: $error';
  }

  @override
  String get tagsEmpty =>
      'No tags yet. Add tags to a journal and they will show up here.';

  @override
  String get tagsAutomaticColour => 'Automatic colour';

  @override
  String get tagsActionsTooltip => 'Tag actions';

  @override
  String get tagsRename => 'Rename';

  @override
  String get tagsChooseColour => 'Choose colour';

  @override
  String get tagsResetColour => 'Reset to automatic';

  @override
  String get tagsRenameFailed =>
      'That name is empty or already used by another tag.';

  @override
  String tagsDeleted(String name) {
    return 'Deleted #$name.';
  }

  @override
  String get tagsDeleteTitle => 'Delete tag?';

  @override
  String tagsDeleteBody(String name) {
    return 'Delete \"#$name\"? It will be removed from every journal and entry that uses it.';
  }

  @override
  String get tagsRenameTitle => 'Rename tag';

  @override
  String get tagsNameLabel => 'Tag name';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get commonUntitledEntry => 'Untitled entry';

  @override
  String get commonUntitled => 'Untitled';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineNoEntriesForDate => 'No entries for this date';

  @override
  String get timelineCalendarFormatMonth => 'Month';

  @override
  String get timelineDayCountOverflow => '9+';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsStreakHeading => 'Writing Streak';

  @override
  String get insightsStreakCurrent => 'Current';

  @override
  String get insightsStreakLongest => 'Longest';

  @override
  String get insightsStreakUnitDays => 'days';

  @override
  String insightsStreakStat(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String insightsLastEntry(String date) {
    return 'Last entry: $date';
  }

  @override
  String get insightsMoodHeading => 'Mood Trends (30 days)';

  @override
  String get insightsMoodEmpty =>
      'No mood data yet.\nRate your mood on entries to see trends.';

  @override
  String insightsMoodTooltip(String date, String mood, int count) {
    return '$date\nMood: $mood\nEntries: $count';
  }

  @override
  String get insightsTagHeatmapHeading => 'Tag Heatmap';

  @override
  String get insightsTagHeatmapEmpty => 'No tags used yet.';

  @override
  String insightsTagChip(String tag, int count) {
    return '$tag ($count)';
  }

  @override
  String get insightsMemoriesHeading => 'On This Day';

  @override
  String get insightsMemoriesEmpty =>
      'No memories for today.\nKeep journaling to build memories!';

  @override
  String insightsYearsAgo(int years) {
    return '${years}y';
  }

  @override
  String get insightsReflectionHeading => 'Weekly Reflection';

  @override
  String get insightsReflectionPeriod => 'Period';

  @override
  String get insightsReflectionEntries => 'Entries';

  @override
  String get insightsReflectionWords => 'Words Written';

  @override
  String get insightsReflectionAverageMood => 'Average Mood';

  @override
  String get insightsReflectionTopTags => 'Top Tags';

  @override
  String get insightsReflectionStreak => 'Current Streak';

  @override
  String insightsDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String insightsMoodOutOfFive(String mood) {
    return '$mood / 5';
  }

  @override
  String insightsStreakDays(int count) {
    return '$count days';
  }

  @override
  String get commonClose => 'Close';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get importTitle => 'Import Files';

  @override
  String get importSelecting => 'Importing...';

  @override
  String get importSelectFiles => 'Select Files to Import';

  @override
  String get importResultsHeading => 'Import Results';

  @override
  String get importFileSucceeded => 'Imported successfully';

  @override
  String importCountSucceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files imported successfully',
      one: '1 file imported successfully',
    );
    return '$_temp0';
  }

  @override
  String get attachmentArchiveEmpty => 'This archive is empty.';

  @override
  String get attachmentOpenWith => 'Open with...';

  @override
  String get attachmentUnsupportedTitle => 'Unsupported file type';

  @override
  String attachmentUnsupportedBody(String fileName) {
    return '$fileName cannot be shown inside the app.';
  }

  @override
  String get attachmentPdfMissing =>
      'The decrypted file is no longer available.';

  @override
  String attachmentPdfOpenFailed(String reason) {
    return 'Could not open PDF: $reason';
  }

  @override
  String get autoLockTitle => 'Auto-Lock Profiles';

  @override
  String get autoLockNewProfile => 'New profile';

  @override
  String get autoLockEditProfile => 'Edit profile';

  @override
  String get autoLockEmpty =>
      'No auto-lock profiles yet. Create one to lock the app after a period of inactivity.';

  @override
  String get autoLockDeleteProfile => 'Delete profile';

  @override
  String get autoLockActivate => 'Activate';

  @override
  String get autoLockDeactivate => 'Deactivate';

  @override
  String autoLockSummary(String timeout, String lockOnMinimize, String active) {
    return '$timeout$lockOnMinimize$active';
  }

  @override
  String get autoLockSuffixLockOnMinimize => ' • lock on minimize';

  @override
  String get autoLockSuffixActive => ' • active';

  @override
  String autoLockTimeoutSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String autoLockTimeoutMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String autoLockTimeoutHours(String hours) {
    return '${hours}h';
  }

  @override
  String get autoLockNameLabel => 'Name';

  @override
  String get autoLockTimeoutLabel => 'Timeout (seconds)';

  @override
  String get autoLockLockOnMinimize => 'Lock on minimize';

  @override
  String get autoLockNameRequired => 'Name is required.';

  @override
  String get autoLockTimeoutInvalid => 'Timeout must be a positive integer.';

  @override
  String get securityEventsTitle => 'Security Events';

  @override
  String get securityEventsEmpty => 'No security events recorded';

  @override
  String get securityEventDetailsTitle => 'Event Details';

  @override
  String get syncConflictsTitle => 'Sync Conflicts';

  @override
  String syncConflictsLoadFailed(String error) {
    return 'Failed to load conflicts:\n$error';
  }

  @override
  String get syncNoConflicts => 'No pending conflicts';

  @override
  String get syncAllInSync => 'All data is in sync.';

  @override
  String syncDetectedAt(String timestamp) {
    return 'Detected: $timestamp';
  }

  @override
  String get syncChangedFields => 'Changed fields:';

  @override
  String get syncCompare => 'Compare';

  @override
  String get syncKeepRemote => 'Keep Remote';

  @override
  String get syncKeepLocal => 'Keep Local';

  @override
  String get syncKeepLocalTitle => 'Keep local version?';

  @override
  String get syncKeepRemoteTitle => 'Keep remote version?';

  @override
  String get syncKeepLocalBody =>
      'The remote changes will be discarded. Your local version will be pushed on next sync.';

  @override
  String get syncKeepRemoteBody =>
      'Your local changes will be overwritten with the remote version.';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get syncConflictResolved => 'Conflict resolved.';

  @override
  String syncResolutionFailed(String error) {
    return 'Resolution failed: $error';
  }

  @override
  String get syncConflictDetailsTitle => 'Conflict Details';

  @override
  String get syncColumnField => 'Field';

  @override
  String get syncColumnLocal => 'Local';

  @override
  String get syncColumnRemote => 'Remote';

  @override
  String get syncHealthHeading => 'Sync Health';

  @override
  String get syncLastSync => 'Last sync';

  @override
  String get syncFailures7d => 'Failures (7d)';

  @override
  String get syncPendingConflicts => 'Pending conflicts';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonErrorShort => 'Error';

  @override
  String get commonEllipsis => '...';

  @override
  String get syncNever => 'Never';

  @override
  String syncResolveCount(int count) {
    return 'Resolve ($count)';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncRecentActivity => 'Recent Activity';

  @override
  String syncLogsLoadFailed(String error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get syncNoActivity => 'No sync activity yet.';

  @override
  String get syncStatusIdle => 'Idle';

  @override
  String get syncStatusSyncing => 'Syncing';

  @override
  String get syncStatusHealthy => 'Healthy';

  @override
  String get syncStatusFailed => 'Failed';

  @override
  String get syncStatusConflicts => 'Conflicts';

  @override
  String get syncLogFailed => 'Sync failed';

  @override
  String syncLogPushed(int count) {
    return '$count pushed';
  }

  @override
  String syncLogPulled(int count) {
    return '$count pulled';
  }

  @override
  String syncLogConflicts(int count) {
    return '$count conflicts';
  }

  @override
  String get syncLogNoChanges => 'No changes';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get backupTitle => 'Backup Health';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get backupInProgressLabel => 'Backing up...';

  @override
  String get backupHistoryHeading => 'Backup History';

  @override
  String get backupStatusHeading => 'Backup Status';

  @override
  String get backupNoneYet => 'No successful backups yet';

  @override
  String get backupLastBackup => 'Last backup';

  @override
  String get backupEntries => 'Entries';

  @override
  String get backupAttachments => 'Attachments';

  @override
  String get backupSize => 'Size';

  @override
  String backupRecentFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failed backups in the last 7 days',
      one: '1 failed backup in the last 7 days',
    );
    return '$_temp0';
  }

  @override
  String get backupScheduleHeading => 'Auto-Backup Schedule';

  @override
  String backupScheduled(String interval) {
    return 'Scheduled: $interval';
  }

  @override
  String get backupNotScheduled => 'Not scheduled';

  @override
  String get backupTimerActive => 'Active';

  @override
  String get backupTimerInactive => 'Inactive';

  @override
  String get backupLastScheduledRun => 'Last scheduled run';

  @override
  String get backupDisable => 'Disable';

  @override
  String get backupConfigure => 'Configure';

  @override
  String get backupChange => 'Change';

  @override
  String get backupConfigureHeading => 'Configure Schedule';

  @override
  String get backupIntervalLabel => 'Interval';

  @override
  String get backupIntervalDaily => 'Daily';

  @override
  String get backupIntervalWeekly => 'Weekly';

  @override
  String get backupIntervalMonthly => 'Monthly';

  @override
  String get backupPasswordLabel => 'Backup encryption password';

  @override
  String get backupPasswordHelper => 'Required for encrypted backups';

  @override
  String get backupNoHistory => 'No backup history';

  @override
  String backupHistoryLoadFailed(String error) {
    return 'Error loading history: $error';
  }

  @override
  String backupLogTitle(String trigger, String status) {
    return '$trigger backup — $status';
  }

  @override
  String get backupTriggerManual => 'Manual';

  @override
  String get backupTriggerScheduled => 'Scheduled';

  @override
  String get backupStatusSuccess => 'Success';

  @override
  String get backupStatusFailed => 'Failed';

  @override
  String get backupStatusInProgress => 'In progress';

  @override
  String backupLogCounts(int entries, int attachments, String size) {
    return '$entries entries, $attachments attachments, $size';
  }

  @override
  String get backupInProgressNote => 'In progress...';

  @override
  String get backupSucceeded => 'Backup completed successfully';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupPasswordTitle => 'Backup Password';

  @override
  String get backupPasswordEnter => 'Enter encryption password';

  @override
  String get backupAction => 'Backup';

  @override
  String get backupPasswordRequired => 'Password is required';

  @override
  String get backupScheduleSaved => 'Backup schedule saved';

  @override
  String get backupScheduleDisabled => 'Backup schedule disabled';

  @override
  String backupBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String backupKilobytes(String size) {
    return '$size KB';
  }

  @override
  String backupMegabytes(String size) {
    return '$size MB';
  }

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonInsert => 'Insert';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonOpenSystemSettings => 'Open system settings';

  @override
  String get editorCalloutHint => 'Enter callout text...';

  @override
  String get editorInsertTable => 'Insert table';

  @override
  String get editorInsertCallout => 'Insert callout';

  @override
  String get editorInsertImage => 'Insert image';

  @override
  String get editorImageSize => 'Image size';

  @override
  String get editorImageSizeSmall => 'Small';

  @override
  String get editorImageSizeMedium => 'Medium';

  @override
  String get editorImageSizeFull => 'Full width';

  @override
  String get editorRemoveImage => 'Remove image from the entry';

  @override
  String get editorImageUnavailable => 'Image unavailable';

  @override
  String get editorMicPermissionDenied => 'Microphone permission denied';

  @override
  String get editorDiscard => 'Discard';

  @override
  String get editorDone => 'Done';

  @override
  String get versionHistoryTitle => 'Version history';

  @override
  String versionHistoryLoadFailed(String error) {
    return 'Error loading revisions: $error';
  }

  @override
  String get versionRestoreTitle => 'Restore this version?';

  @override
  String get versionRestored => 'Version restored';

  @override
  String get versionPreview => 'Preview';

  @override
  String get versionRestoreTooltip => 'Restore this version';

  @override
  String versionPreviewTitle(String title) {
    return 'Preview: $title';
  }

  @override
  String get entrySaved => 'Entry saved';

  @override
  String get entryDeleteTitle => 'Delete entry?';

  @override
  String get entryDeleteBody => 'This will permanently remove the entry.';

  @override
  String get entryTableRows => 'Rows';

  @override
  String get entryTableColumns => 'Columns';

  @override
  String get entryTableDimensionHelp => '1–20';

  @override
  String get entryCalloutTypeTitle => 'Callout type';

  @override
  String get entryCalloutInfo => 'Info';

  @override
  String get entryCalloutTip => 'Tip';

  @override
  String get entryCalloutWarning => 'Warning';

  @override
  String get entryCalloutImportant => 'Important';

  @override
  String entryVoiceNoteSaved(String seconds) {
    return 'Voice note saved (${seconds}s)';
  }

  @override
  String get entryEditTitle => 'Edit entry';

  @override
  String get entryEditTitleDirty => 'Edit entry •';

  @override
  String get entryVersionHistoryTooltip => 'Version history';

  @override
  String get entryDeleteTooltip => 'Delete entry';

  @override
  String get entrySaveTooltip => 'Save';

  @override
  String get entryNoUnsavedChanges => 'No unsaved changes';

  @override
  String get entryTitleLabel => 'Title';

  @override
  String get entryPermissionTitle => 'Allow attachment import?';

  @override
  String get entryPermissionBody =>
      'This app needs permission to access your files.';

  @override
  String get entryPermissionBlockedTitle => 'Attachment access blocked';

  @override
  String get entryPermissionBlockedBody =>
      'Permission was permanently denied. Please enable it in system settings.';

  @override
  String get entryNotAnImage =>
      'That file is not an image. Add it as an attachment instead.';

  @override
  String get entryImageAddFailed => 'Could not add that image.';

  @override
  String get entryAddAttachment => 'Add attachment';

  @override
  String get entryRecordVoiceNote => 'Record voice note';

  @override
  String get entryLinkedFrom => 'Linked from';

  @override
  String get entryMood => 'Mood';

  @override
  String entryMoodChip(String face, int level) {
    return '$face $level';
  }

  @override
  String get entryAuthRequired => 'Authentication required.';

  @override
  String get attachmentOpenNoApp => 'No compatible app found';

  @override
  String get attachmentOpenDecryptFailed => 'Could not decrypt attachment';

  @override
  String get attachmentOpenFileMissing => 'Attachment file is missing';

  @override
  String get attachmentOpenPermissionDenied =>
      'Permission required to open attachment';

  @override
  String get entryAttachments => 'Attachments';

  @override
  String get entryRemoveAttachmentLock => 'Remove attachment lock';

  @override
  String get entryLockAttachment => 'Lock attachment';

  @override
  String get entryOpenAttachment => 'Open attachment';

  @override
  String get versionRestoreBody =>
      'Your current content will be saved as a new version before restoring.';

  @override
  String get commonUnlock => 'Unlock';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get lockSetupTitle => 'Set up app lock';

  @override
  String get lockSetupBody =>
      'Choose how SreerajP Journal Vault should lock when it is sent to the background.';

  @override
  String get lockModePhone => 'Phone Lock';

  @override
  String get lockModePhoneHint =>
      'Use the device biometric or PIN/pattern/password.';

  @override
  String get lockModeApp => 'Separate App Lock';

  @override
  String get lockModeAppHint =>
      'Use a dedicated PIN that is verified inside the app.';

  @override
  String get lockPinLabel => 'PIN';

  @override
  String get lockConfirmPinLabel => 'Confirm PIN';

  @override
  String get lockSettingUp => 'Setting up...';

  @override
  String get lockPinTooShort => 'PIN must be at least 4 characters.';

  @override
  String get lockPinsDoNotMatch => 'PINs do not match.';

  @override
  String lockSetupSaveFailed(String error) {
    return 'Could not save lock setup: $error';
  }

  @override
  String lockPinSaveFailed(String error) {
    return 'Could not save PIN: $error';
  }

  @override
  String get lockPinSetupTitle => 'Set app-lock PIN';

  @override
  String get lockPinSetupBody =>
      'Separate App Lock requires a PIN. Set one to continue.';

  @override
  String get lockGateTitle => 'App Lock Gate';

  @override
  String get lockUnlockWithPhone => 'Unlock with Phone Lock';

  @override
  String get lockAuthFailed => 'Authentication failed. Please try again.';

  @override
  String get lockAuthUnavailable =>
      'Device authentication is not available. Configure a PIN/biometric in system settings.';

  @override
  String get lockEnterPin => 'Enter your PIN.';

  @override
  String get lockIncorrectPin => 'Incorrect PIN.';

  @override
  String get lockedAttachmentsTitle => 'Attachment-Level Lock';

  @override
  String get lockedAttachmentsEmpty =>
      'No attachments are locked yet. Open an entry and use the lock button on an attachment to require re-authentication before opening it.';

  @override
  String lockedAttachmentSince(String date) {
    return 'Locked $date';
  }

  @override
  String get lockedAttachmentRemove => 'Remove lock';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Settings';

  @override
  String get journalDeleteTitle => 'Delete journal?';

  @override
  String journalDeleteBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get journalManageTags => 'Manage tags';

  @override
  String get journalNew => 'New journal';

  @override
  String get journalEdit => 'Edit journal';

  @override
  String get journalDelete => 'Delete journal';

  @override
  String get journalEmptyTitle => 'No journals yet';

  @override
  String get journalEmptyBody => 'Tap “New journal” to start writing.';

  @override
  String get journalTitleLabel => 'Title';

  @override
  String get journalDescriptionLabel => 'Description';

  @override
  String get journalTagsLabel => 'Tags (comma separated)';

  @override
  String get journalLockSwitch => 'Lock journal';

  @override
  String get journalConfirmPasswordLabel => 'Confirm password';

  @override
  String get journalAddEntry => 'Add entry';

  @override
  String get journalIsLocked => 'Journal is locked';

  @override
  String get journalUnlocked => 'Unlocked';

  @override
  String get journalIncorrectPassword => 'Incorrect password.';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionStorage => 'Storage';

  @override
  String get settingsSectionPermissions => 'Permissions';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAppLockMode => 'App Lock Mode';

  @override
  String get settingsAutoLockTimeout => 'Auto-Lock Timeout';

  @override
  String get settingsTamperAlerts => 'Tamper Alerts';

  @override
  String get settingsSyncConflicts => 'Sync Conflicts';

  @override
  String get settingsSecurityEvents => 'Security Events';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle =>
      'Choose how SreerajP_Journal_Vault looks.';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsAbout => 'About this app';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get settingsSwitchLockTitle => 'Switch lock mode?';

  @override
  String settingsSwitchLockBody(String enabled, String disabled) {
    return 'This will switch app protection to $enabled and disable $disabled. Continue?';
  }

  @override
  String get settingsSwitchAction => 'Switch';

  @override
  String settingsLockModeUpdated(String mode) {
    return 'Lock mode updated: $mode is now active.';
  }

  @override
  String get settingsThemeSaveFailed =>
      'Could not save theme setting. Please try again.';

  @override
  String settingsThemeUpdated(String mode) {
    return 'Theme updated: $mode mode is now active.';
  }

  @override
  String get storageMigrateTitle => 'Migrate attachments?';

  @override
  String storageMigrateBody(String target) {
    return 'All attachments will be moved to $target.';
  }

  @override
  String get storageMigrateAction => 'Migrate';

  @override
  String get storageMigrationCancelled => 'Migration cancelled.';

  @override
  String storageMigrationFailed(String error) {
    return 'Migration failed: $error';
  }

  @override
  String get storageMigrationComplete => 'Migration complete.';

  @override
  String get storageLocationTitle => 'Attachment Storage Location';

  @override
  String get storageLocationDialogTitle => 'Storage location';

  @override
  String get storageAppPrivate => 'App Private';

  @override
  String get storageSdCard => 'SD Card';

  @override
  String storageSdCardNamed(String label) {
    return 'SD Card ($label)';
  }

  @override
  String get storageMigrateRow => 'Migrate Storage';

  @override
  String get storageMigrationIdle => 'Idle';

  @override
  String storageMigrationRunning(int processed, int total) {
    return 'Migrating $processed of $total…';
  }

  @override
  String get storageMigrationFailedShort => 'Migration failed.';

  @override
  String get storageUsage => 'Storage Usage';

  @override
  String get storageUnknown => '—';

  @override
  String get storageBackupHealth => 'Backup Health';

  @override
  String get storageImportData => 'Import Data';

  @override
  String get storageSyncHealth => 'Sync Health';

  @override
  String get storageImportNeedsJournal =>
      'Create a journal first to import into.';

  @override
  String get storageImportChooseJournal => 'Import into journal';

  @override
  String storageBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String storageKilobytes(String size) {
    return '$size KB';
  }

  @override
  String storageMegabytes(String size) {
    return '$size MB';
  }

  @override
  String storageGigabytes(String size) {
    return '$size GB';
  }

  @override
  String get migrationDialogTitle => 'Migrating attachments';

  @override
  String get migrationCancelling => 'Cancelling…';

  @override
  String migrationProgress(String processed, String total) {
    return '$processed of $total';
  }

  @override
  String get migrationUnknownTotal => '?';

  @override
  String get permissionStatusRow => 'Permission Status';

  @override
  String get permissionsManage => 'Manage Permissions';

  @override
  String get permissionsOpenSystem => 'Open System Settings';

  @override
  String permissionsGrantedSummary(int granted, int total) {
    return '$granted of $total granted';
  }

  @override
  String get searchHint => 'Search journals & entries...';

  @override
  String get searchTypeToSearch => 'Type to search';

  @override
  String get searchNoFilterMatches => 'No matches found for this filter.';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchSectionJournals => 'Journals';

  @override
  String get searchSectionEntries => 'Entries';

  @override
  String get searchSavePresetTitle => 'Save search preset';

  @override
  String get searchPresetNameLabel => 'Preset name';

  @override
  String get restoreTitle => 'Restore from backup';

  @override
  String get restoreOpenAction => 'Restore from backup';

  @override
  String get restoreLockedTitle => 'Unlock to continue';

  @override
  String get restoreLockedBody =>
      'Restoring changes your journal, so it is protected the same way the app is.';

  @override
  String get restoreUnlockAction => 'Unlock';

  @override
  String get restoreUnlockReason => 'Unlock to restore a backup';

  @override
  String get restoreUnlockFailed => 'Could not unlock. Nothing was changed.';

  @override
  String get restoreEnterPin => 'Enter your app PIN';

  @override
  String get restorePinWrong => 'That PIN is not right.';

  @override
  String get restorePickHeading => 'Choose a backup';

  @override
  String get restorePickFromDevice => 'Choose a file';

  @override
  String get restoreNoBackupsFound =>
      'No backups made by this app were found. You can still choose a file.';

  @override
  String restoreSelectedFile(String fileName) {
    return 'Selected: $fileName';
  }

  @override
  String get restorePasswordLabel => 'Backup password';

  @override
  String get restorePasswordHelper =>
      'The password used when this backup was made.';

  @override
  String get restoreOpenBackupAction => 'Open backup';

  @override
  String get restorePreviewHeading => 'What this backup holds';

  @override
  String restorePreviewCreated(String date) {
    return 'Made on $date';
  }

  @override
  String restorePreviewCounts(int journals, int entries, int attachments) {
    return '$journals journals, $entries entries, $attachments attachments';
  }

  @override
  String get restoreLegacyAttachmentsWarning =>
      'This is an older backup. Its attachments only open on the device that made it.';

  @override
  String get restoreModeHeading => 'How should it be restored?';

  @override
  String get restoreModeMerge => 'Merge';

  @override
  String get restoreModeMergeDetail =>
      'Add what is missing and keep everything you have now.';

  @override
  String get restoreModeReplace => 'Replace';

  @override
  String get restoreModeReplaceDetail =>
      'Delete what is here now and use the backup instead. A safety backup is taken first.';

  @override
  String get restoreDryRunAction => 'Try it first';

  @override
  String get restoreDryRunHelper =>
      'Shows what would change without changing anything.';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreConfirmReplaceTitle => 'Replace everything?';

  @override
  String get restoreConfirmReplaceBody =>
      'Every journal, entry and attachment on this device will be deleted and replaced by the backup. A safety backup of what is here now is taken first.';

  @override
  String get restoreConfirmMergeTitle => 'Merge this backup?';

  @override
  String get restoreConfirmMergeBody =>
      'Anything the backup holds that is missing here will be added. Nothing is deleted.';

  @override
  String get restoreDryRunResultTitle => 'What would happen';

  @override
  String get restoreResultTitle => 'Restore finished';

  @override
  String restoreResultAdded(int count) {
    return 'Added: $count rows';
  }

  @override
  String restoreResultSkipped(int count) {
    return 'Already here: $count rows';
  }

  @override
  String restoreResultFiles(int count) {
    return 'Attachment files restored: $count';
  }

  @override
  String restoreResultFilesFailed(int count) {
    return 'Attachment files that could not be restored: $count';
  }

  @override
  String get restoreResultSafetyBackup =>
      'A safety backup of your previous data was saved first.';

  @override
  String get restoreErrorWrongPassword =>
      'Wrong password, or the backup file is damaged.';

  @override
  String get restoreErrorDamaged =>
      'This file is not a backup, or it is damaged.';

  @override
  String get restoreErrorTooNew =>
      'This backup was made by a newer version of the app. Update the app and try again.';

  @override
  String get restoreErrorPasswordTooShort =>
      'The backup password must be at least 8 characters.';

  @override
  String restoreErrorFailed(String error) {
    return 'The restore failed and nothing was changed: $error';
  }

  @override
  String get restoreWorking => 'Working...';

  @override
  String get exportProtectTitle => 'Protect with a password';

  @override
  String get exportProtectHint =>
      'The file is encrypted with your password. It can be opened again in this app, on any device.';

  @override
  String get exportPasswordLabel => 'Password';

  @override
  String get exportPasswordConfirmLabel => 'Repeat the password';

  @override
  String exportPasswordTooShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get exportPasswordMismatch => 'The two passwords do not match.';

  @override
  String get exportEncryptedNotice =>
      'Keep this password somewhere safe. Without it the exported file cannot be opened again, by anyone, including you.';

  @override
  String get openEncryptedTitle => 'Open an encrypted export';

  @override
  String get openEncryptedIntro =>
      'Choose an encrypted export file, enter its password, and save the file inside it.';

  @override
  String get openEncryptedPickFile => 'Choose file';

  @override
  String openEncryptedChosenFile(String fileName) {
    return 'Chosen: $fileName';
  }

  @override
  String get openEncryptedPasswordLabel => 'File password';

  @override
  String get openEncryptedAction => 'Open and save';

  @override
  String get openEncryptedWorking => 'Opening...';

  @override
  String get openEncryptedSaveDialogTitle => 'Save the opened file';

  @override
  String get openEncryptedSaved =>
      'Saved. The file is no longer encrypted, so keep it somewhere safe.';

  @override
  String get openEncryptedCancelled => 'Nothing was saved.';

  @override
  String get openEncryptedErrorWrongPassword =>
      'Wrong password, or the file is damaged.';

  @override
  String get openEncryptedErrorNotSealed =>
      'This is not an encrypted export made by this app.';

  @override
  String get openEncryptedErrorTooNew =>
      'This file was made by a newer version of the app. Update the app and try again.';

  @override
  String get openEncryptedErrorFailed => 'The file could not be opened.';

  @override
  String get settingsOpenEncryptedExport => 'Open an encrypted export';

  @override
  String get templateChooserTitle => 'Choose a template';
}
