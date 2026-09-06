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
  String get syncStatusSyncing => 'Syncing changes...';

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
  String get editorInsertTab => 'Insert tab';

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
  String get entryMoodTooltip => 'Set mood';

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
  String get lockGateHeadline => 'Your journal is locked';

  @override
  String get lockGateSubtitle => 'Unlock to open your entries.';

  @override
  String get lockGateShowPin => 'Show PIN';

  @override
  String get lockGateHidePin => 'Hide PIN';

  @override
  String get lockGateBadgeSemantics => 'Locked';

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
  String get settingsSectionSecuritySubtitle =>
      'Lock mode, auto-lock, screenshots and security events';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAppearanceSubtitle => 'Theme and how the app looks';

  @override
  String get settingsSectionStorage => 'Storage';

  @override
  String get settingsSectionStorageSubtitle =>
      'Attachment location, usage, backup and import';

  @override
  String get settingsSectionPermissions => 'Permissions';

  @override
  String get settingsSectionPermissionsSubtitle =>
      'What the app is allowed to use';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionAboutSubtitle =>
      'Version, licences and app details';

  @override
  String get settingsAppLockMode => 'App Lock Mode';

  @override
  String get settingsAutoLockTimeout => 'Auto-Lock Timeout';

  @override
  String get settingsScreenSecurity => 'Block Screenshots';

  @override
  String get settingsScreenSecuritySubtitle =>
      'Stops screenshots, screen recording and the preview shown in the recent apps list';

  @override
  String get settingsScreenSecurityOffTitle => 'Turn off screenshot blocking?';

  @override
  String get settingsScreenSecurityOffBody =>
      'Anyone taking a screenshot or recording the screen will be able to capture your journal content. The recent apps list will also show your last screen. You can turn this back on at any time.';

  @override
  String get settingsScreenSecurityOffAction => 'Turn Off';

  @override
  String get settingsScreenSecurityUpdatedOn => 'Screenshot blocking is on';

  @override
  String get settingsScreenSecurityUpdatedOff => 'Screenshot blocking is off';

  @override
  String get settingsScreenSecuritySaveFailed =>
      'Could not change screenshot blocking';

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

  @override
  String get versionHistoryEmpty =>
      'No previous versions yet.\n\nVersions are saved automatically when you edit an entry.';

  @override
  String get drawingStrokeFine => 'Fine (2px)';

  @override
  String get drawingStrokeNormal => 'Normal (3.5px)';

  @override
  String get drawingStrokeThick => 'Thick (7px)';

  @override
  String get drawingStrokeBold => 'Bold (14px)';

  @override
  String get drawingDefaultTitle => 'Drawing';

  @override
  String get imageDefaultTitle => 'Image';

  @override
  String get editorImageLocked => 'Locked image — tap to unlock';

  @override
  String editorImageUnavailableWithName(String fileName) {
    return 'Image unavailable — $fileName';
  }

  @override
  String get audioPauseTooltip => 'Pause';

  @override
  String get audioPlayTooltip => 'Play';

  @override
  String importIntoJournal(String journalTitle) {
    return 'Import into \"$journalTitle\"';
  }

  @override
  String importSupportedFormats(String formats) {
    return 'Supported formats: $formats';
  }

  @override
  String importSupportedExtensions(String extensions) {
    return 'Files: $extensions';
  }

  @override
  String get importSelectFilesPrompt => 'Select files to import as new entries';

  @override
  String get featuresCategoryJournaling => 'Journaling & Rich Text Editor';

  @override
  String get featuresCategoryJournalingSubtitle =>
      'Expressive writing, structured templates, OCR, and rich media';

  @override
  String get featuresCategorySecurity => 'Privacy, Encryption & Vault Security';

  @override
  String get featuresCategorySecuritySubtitle =>
      'Guaranteed zero-leak encryption and granular security controls';

  @override
  String get featuresCategoryDiscovery => 'Search, Timeline & Insights';

  @override
  String get featuresCategoryDiscoverySubtitle =>
      'Blazing fast search, deep calendar navigation, and writing habits';

  @override
  String get featuresCategoryStorage =>
      'Storage, Backups & Multi-Format Export';

  @override
  String get featuresCategoryStorageSubtitle =>
      'Total data sovereignty with local backups and flexible exports';

  @override
  String get featureQuillTitle => 'Quill Rich Text Editor';

  @override
  String get featureQuillDesc =>
      'Write entries with rich formatting including headings, bulleted & numbered lists, bold, italics, underlines, and inline blockquotes.';

  @override
  String get featureTemplatesTitle => 'Structured Entry Templates';

  @override
  String get featureTemplatesDesc =>
      'Jumpstart your writing with 8 customizable templates: Daily Reflection, Gratitude, Dream Journal, Workout Log, Travel Diary, Meeting Notes, Bullet Journal, and Freeform.';

  @override
  String get featureMediaOcrTitle => 'Encrypted Media Attachments & OCR';

  @override
  String get featureMediaOcrDesc =>
      'Attach photos, audio recordings, and documents encrypted on device. Extract text directly from images into your journal with offline OCR.';

  @override
  String get featureTagsTitle => 'Color-Coded Tags & Tag Manager';

  @override
  String get featureTagsDesc =>
      'Organize entries and journals with vibrant color-coded tags. Rename, color, or bulk-manage tags effortlessly in the Tag Manager.';

  @override
  String get featureMultiJournalTitle => 'Multiple Distinct Journals';

  @override
  String get featureMultiJournalDesc =>
      'Create multiple separate journals for work, personal diaries, travel adventures, or creative projects, each with custom tags and settings.';

  @override
  String get featureSqlcipherTitle => 'SQLCipher AES-256 Database Encryption';

  @override
  String get featureSqlcipherDesc =>
      'All journal data, entries, metadata, and tables are encrypted at rest using SQLCipher with AES-256-GCM. Unencrypted data is never written to disk.';

  @override
  String get featureBiometricsTitle => 'Biometric & App PIN Lock';

  @override
  String get featureBiometricsDesc =>
      'Secure your vault with your device fingerprint or face unlock, or set a dedicated App PIN. The app re-locks automatically whenever you switch apps.';

  @override
  String get featureJournalLockTitle => 'Per-Journal Password Locks';

  @override
  String get featureJournalLockDesc =>
      'Lock specific sensitive journals behind individual passwords using PBKDF2 key derivation. Locked journals require password entry each session.';

  @override
  String get featureAttachmentLockTitle => 'Attachment-Level Encryption Locks';

  @override
  String get featureAttachmentLockDesc =>
      'Individually lock and hide sensitive attachments and photos with separate encryption keys, keeping them private even when browsing entries.';

  @override
  String get featureScreenshotGuardTitle =>
      'Screenshot & Screen-Recording Guard';

  @override
  String get featureScreenshotGuardDesc =>
      'Automatic FLAG_SECURE window defense blocks malicious screenshot capture, screen recording apps, and recents app switcher snapshot leaking.';

  @override
  String get featureTamperAuditTitle => 'Tamper-Evident Security Audit Log';

  @override
  String get featureTamperAuditDesc =>
      'Monitors and logs key security events: app unlock attempts, failed biometric/PIN authentications, password changes, and export actions.';

  @override
  String get featureAutoLockTitle => 'Auto-Lock Inactivity Profiles';

  @override
  String get featureAutoLockDesc =>
      'Configure custom timeout durations (immediate, 30 seconds, 1 min, 5 min) to automatically relock your journal vault when idle.';

  @override
  String get featureFtsSearchTitle => 'Lightning SQLite FTS Search';

  @override
  String get featureFtsSearchDesc =>
      'Instant full-text search indexing scans every entry body, title, tag, and metadata with SQLite FTS5 for sub-millisecond query results.';

  @override
  String get featureSearchPresetsTitle => 'Saved Search Presets';

  @override
  String get featureSearchPresetsDesc =>
      'Save frequent queries with date range and tag filters as one-tap quick filter chips directly accessible from the search bar.';

  @override
  String get featureTimelineTitle => 'Interactive Calendar Timeline Explorer';

  @override
  String get featureTimelineDesc =>
      'Navigate your entire journal history with a smooth calendar view, visual daily entry dots, day-by-day browsing, and quick date jumping.';

  @override
  String get featureInsightsTitle => 'Writing Trends & Habit Insights';

  @override
  String get featureInsightsDesc =>
      'Track your daily writing streaks, word counts, active writing days per month, and top tag distributions with offline analytical charts.';

  @override
  String get featureStorageMigrationTitle =>
      'Attachment Storage Migration (SD Card)';

  @override
  String get featureStorageMigrationDesc =>
      'Seamlessly migrate all encrypted attachments between internal app storage and removable SD Card memory without interrupting journal access.';

  @override
  String get featureEncryptedBackupsTitle => 'Encrypted Vault Backups (.jvbk)';

  @override
  String get featureEncryptedBackupsDesc =>
      'Export and restore complete password-protected .jvbk backup archives containing your database, attachments, tags, and settings.';

  @override
  String get featureMultiExportTitle => 'Formatted Multi-Format Export';

  @override
  String get featureMultiExportDesc =>
      'Export individual entries or complete journals into clean formatted PDF, Markdown zip archive, or raw JSON data formats.';

  @override
  String get featureEncryptedReaderTitle =>
      'Standalone Encrypted Export Reader';

  @override
  String get featureEncryptedReaderDesc =>
      'Read password-protected encrypted journal exports independently inside the app without needing to restore the full backup database.';

  @override
  String get helpTopicJournalOrg => 'Journal Organization & Templates';

  @override
  String get helpTopicJournalOrgSubtitle =>
      'How multiple journals, starter prompts, and Quill rich text formatting work.';

  @override
  String get helpTopicAttachmentsOcr => 'Attachments & OCR Scanner';

  @override
  String get helpTopicAttachmentsOcrSubtitle =>
      'On-device offline OCR text recognition from images and encrypted media storage.';

  @override
  String get helpTopicTags => 'Tags & Color Coding';

  @override
  String get helpTopicTagsSubtitle =>
      'Categorizing entries, custom tag color palettes, and global tag management.';

  @override
  String get helpTopicEncryption => 'Encryption & Keystore Security';

  @override
  String get helpTopicEncryptionSubtitle =>
      'SQLCipher database encryption at rest, Android Keystore keys, and offline guarantees.';

  @override
  String get helpTopicBiometrics => 'App Lock, Biometrics & PIN';

  @override
  String get helpTopicBiometricsSubtitle =>
      'Fingerprint and face unlock, custom App PIN setup, and auto-lock timeouts.';

  @override
  String get helpTopicJournalLocks => 'Per-Journal & Attachment Locks';

  @override
  String get helpTopicJournalLocksSubtitle =>
      'Individual journal password locks, session unlocking, and attachment-level locks.';

  @override
  String get helpTopicScreenshotAudit => 'Screenshot Guard & Audit Trail';

  @override
  String get helpTopicScreenshotAuditSubtitle =>
      'FLAG_SECURE window defense, task switcher masking, and local security audit events.';

  @override
  String get helpTopicSearchTimeline => 'Full-Text Search & Timeline';

  @override
  String get helpTopicSearchTimelineSubtitle =>
      'SQLite FTS keyword search, saved search presets, and interactive calendar navigation.';

  @override
  String get helpTopicInsights => 'Writing Insights & Trends';

  @override
  String get helpTopicInsightsSubtitle =>
      'Habit streaks, word count statistics, monthly activity graphs, and tag analytics.';

  @override
  String get helpTopicStorageMigration => 'Storage Locations & SD Card';

  @override
  String get helpTopicStorageMigrationSubtitle =>
      'Moving encrypted media attachments between internal app storage and SD Card memory.';

  @override
  String get helpTopicBackupRestore => 'Encrypted Backups & Restore';

  @override
  String get helpTopicBackupRestoreSubtitle =>
      'Creating password-protected .jvbk backup files, health checks, and restoring on a new device.';

  @override
  String get helpTopicExportFormats => 'Export Formats & Reader';

  @override
  String get helpTopicExportFormatsSubtitle =>
      'Exporting to formatted PDF, Markdown zip, JSON, and using the built-in encrypted reader.';

  @override
  String get helpTopicFaq => 'FAQs & Troubleshooting';

  @override
  String get helpTopicFaqSubtitle =>
      'Answers about offline privacy, permissions, passcode recovery policies, and device transfers.';

  @override
  String get helpAttachmentsIntro =>
      'Enrich your journal entries with photos, audio notes, and documents. Extract printed or handwritten text directly using offline OCR text recognition.';

  @override
  String get helpAttachmentsSectionOcr => 'On-Device OCR Text Extraction';

  @override
  String get helpAttachmentsOcrBullet1 =>
      'Tap the camera/scanner icon in the editor to capture a photo of a book, document, or written note.';

  @override
  String get helpAttachmentsOcrBullet2 =>
      'The built-in on-device OCR engine detects and parses text in seconds without sending a single byte to external servers.';

  @override
  String get helpAttachmentsOcrBullet3 =>
      'Extracted text is automatically formatted and inserted right at your current cursor position.';

  @override
  String get helpAttachmentsSectionEncryption =>
      'AES-256-GCM Attachment Encryption';

  @override
  String get helpAttachmentsEncryptionBullet1 =>
      'All media attachments are encrypted using AES-256-GCM before writing to storage. Stored files cannot be opened by gallery apps or file managers without the app.';

  @override
  String get helpAttachmentsFooter =>
      'Privacy Guarantee: All OCR text extraction runs entirely offline on your device with 100% privacy.';

  @override
  String get helpBackupIntro =>
      'Keep your journal safe across device upgrades or system resets with encrypted .jvbk backup archives.';

  @override
  String get helpBackupSectionCreate => 'Creating an Encrypted Backup (.jvbk)';

  @override
  String get helpBackupCreateBullet1 =>
      'Go to Settings → Storage → Backup & Restore → Create Backup.';

  @override
  String get helpBackupCreateBullet2 =>
      'Choose a strong password. This password encrypts both the database and all media attachments.';

  @override
  String get helpBackupCreateBullet3 =>
      'Save the resulting .jvbk file to your desired folder, cloud storage, or external USB drive.';

  @override
  String get helpBackupSectionRestore => 'Restoring on a New Device';

  @override
  String get helpBackupRestoreBullet1 =>
      'Install SreerajP Journal Vault on your new device and open Settings → Storage → Restore Backup.';

  @override
  String get helpBackupRestoreBullet2 =>
      'Select your .jvbk file and enter the exact password used when the backup was created.';

  @override
  String get helpBackupRestoreBullet3 =>
      'All journals, entries, images, audio recordings, and tags will be fully restored into your new vault.';

  @override
  String get helpBackupFooter =>
      'Important: Backups cannot be decrypted or recovered if you forget your backup password.';

  @override
  String get helpBiometricsIntro =>
      'Protect your private thoughts with instant biometric verification or a dedicated 4-6 digit App PIN.';

  @override
  String get helpBiometricsSectionPhoneLock => 'Phone Lock Mode (Biometrics)';

  @override
  String get helpBiometricsPhoneLockBullet1 =>
      'Uses your device\'s biometric authentication (fingerprint or face unlock) or system lock pattern.';

  @override
  String get helpBiometricsPhoneLockBullet2 =>
      'Seamless and fast — unlocks instantly whenever you open the app.';

  @override
  String get helpBiometricsSectionAppPin => 'Separate App PIN Mode';

  @override
  String get helpBiometricsAppPinBullet1 =>
      'Set a dedicated numeric PIN that is distinct from your device lock screen.';

  @override
  String get helpBiometricsAppPinBullet2 =>
      'Keeps your journal private even if someone else knows your phone\'s lock screen passcode.';

  @override
  String get helpBiometricsSectionAutoLock => 'Auto-Lock Timeout Profiles';

  @override
  String get helpBiometricsAutoLockBullet1 =>
      'Configure auto-lock timeout in Settings → Security → Auto-Lock Timeout (Immediate, 30s, 1m, 5m).';

  @override
  String get helpBiometricsAutoLockBullet2 =>
      'When the app moves to background and the timeout expires, the vault locks automatically.';

  @override
  String get helpEncryptionIntro =>
      'SreerajP Journal Vault is architected from the ground up for total privacy and zero-knowledge data security.';

  @override
  String get helpEncryptionSectionSqlcipher => 'SQLCipher Database Encryption';

  @override
  String get helpEncryptionSqlcipherBullet1 =>
      'The underlying SQLite database is encrypted with SQLCipher using AES-256 in CBC/GCM mode.';

  @override
  String get helpEncryptionSqlcipherBullet2 =>
      'Every single byte written to disk is encrypted, including entry text, titles, tags, and timestamps.';

  @override
  String get helpEncryptionSectionKeystore =>
      'Android Keystore Hardware Integration';

  @override
  String get helpEncryptionKeystoreBullet1 =>
      'Master encryption keys are generated and stored inside the Android hardware-backed Keystore / Secure Enclave.';

  @override
  String get helpEncryptionKeystoreBullet2 =>
      'Keys never leave the hardware module and cannot be extracted by root or other apps.';

  @override
  String get helpEncryptionSectionOffline => 'Complete Offline Isolation';

  @override
  String get helpEncryptionOfflineBullet1 =>
      'The app has zero internet permissions declared in its Android manifest.';

  @override
  String get helpEncryptionOfflineBullet2 =>
      'No tracking, no analytics, no ads, and no external API requests ever happen.';

  @override
  String get helpExportIntro =>
      'Export your entries anytime in standard formats so your memories always belong to you.';

  @override
  String get helpExportSectionPdf => 'Formatted PDF Export';

  @override
  String get helpExportPdfBullet1 =>
      'Export single entries or entire journals as beautifully formatted, printable PDF documents with embedded images.';

  @override
  String get helpExportSectionMarkdown => 'Markdown ZIP & JSON Data';

  @override
  String get helpExportMarkdownBullet1 =>
      'Export as Markdown text files with images bundled into a zip archive for Obsidian, Notion, or personal archives.';

  @override
  String get helpExportMarkdownBullet2 =>
      'Export raw JSON data for automated parsing and complete data portability.';

  @override
  String get helpExportSectionReader => 'Standalone Encrypted Reader';

  @override
  String get helpExportReaderBullet1 =>
      'Export encrypted journal packages and view them anywhere using the built-in encrypted reader tool in Settings.';

  @override
  String get helpFaqIntro =>
      'Find quick answers to commonly asked questions about security, backups, and journal management.';

  @override
  String get helpFaqQ1 => 'Is my data ever sent over the internet?';

  @override
  String get helpFaqA1 =>
      'Never. SreerajP Journal Vault does not declare the INTERNET permission. Everything stays 100% on your device.';

  @override
  String get helpFaqQ2 => 'What if I forget my App PIN or Journal Password?';

  @override
  String get helpFaqA2 =>
      'Because encryption is zero-knowledge and on-device, lost passwords cannot be reset by anyone. We strongly recommend writing down your passwords in a secure place.';

  @override
  String get helpFaqQ3 => 'Why are specific permissions requested?';

  @override
  String get helpFaqA3 =>
      'Camera & Photos: To take photos or import images/attachments into your entries.\nMicrophone: To record voice notes.\nStorage/Media: To save encrypted backups and export PDFs.';

  @override
  String get helpFaqQ4 => 'Can I transfer my journal to a new phone?';

  @override
  String get helpFaqA4 =>
      'Yes! Create an encrypted backup (.jvbk) in Settings, transfer the file to your new phone, install SreerajP Journal Vault, and choose Restore Backup.';

  @override
  String get helpInsightsIntro =>
      'Gain deep perspective on your journaling habits, emotional trends, and writing consistency.';

  @override
  String get helpInsightsSectionHabits => 'Habit & Streak Tracking';

  @override
  String get helpInsightsHabitsBullet1 =>
      'View current streak and best historical writing streaks to stay motivated.';

  @override
  String get helpInsightsHabitsBullet2 =>
      'Monthly calendar activity heatmap highlights active writing days.';

  @override
  String get helpInsightsSectionStats => 'Word Count & Activity Analytics';

  @override
  String get helpInsightsStatsBullet1 =>
      'Analyze total words written, average entry length, and reading time across journals.';

  @override
  String get helpInsightsSectionTags => 'Tag & Topic Distribution';

  @override
  String get helpInsightsTagsBullet1 =>
      'Visualize your most frequent tags and topics to understand your primary focus areas over time.';

  @override
  String get helpJournalLocksIntro =>
      'Add secondary security barriers to specific journals or sensitive attachment files.';

  @override
  String get helpJournalLocksSectionJournal => 'Per-Journal Password Locks';

  @override
  String get helpJournalLocksJournalBullet1 =>
      'Assign unique passwords to sensitive journals. Even when the app is unlocked, locked journals stay encrypted until password entry.';

  @override
  String get helpJournalLocksJournalBullet2 =>
      'Session unlock keeps the journal open while using the app, and automatically re-locks upon closing or auto-lock timeout.';

  @override
  String get helpJournalLocksSectionAttachment => 'Attachment-Level Locks';

  @override
  String get helpJournalLocksAttachmentBullet1 =>
      'Hide and lock private photo or document attachments behind independent passwords.';

  @override
  String get helpJournalOrgIntro =>
      'Organize your life into dedicated journals, use structured prompts, and write expressive rich text.';

  @override
  String get helpJournalOrgSectionMultiple => 'Multiple Separate Journals';

  @override
  String get helpJournalOrgMultipleBullet1 =>
      'Create distinct journals for Personal, Work, Travel, Ideas, or Health.';

  @override
  String get helpJournalOrgMultipleBullet2 =>
      'Switch between journals seamlessly with the top journal selector.';

  @override
  String get helpJournalOrgSectionTemplates => 'Using Starter Templates';

  @override
  String get helpJournalOrgTemplatesBullet1 =>
      'Choose from 8 built-in templates (Daily Reflection, Gratitude, Dream, etc.) when creating a new entry.';

  @override
  String get helpJournalOrgTemplatesBullet2 =>
      'Customize templates or create new ones in Settings → Templates.';

  @override
  String get helpJournalOrgSectionRichText => 'Rich Text Formatting';

  @override
  String get helpJournalOrgRichTextBullet1 =>
      'Format text with bold, italic, headings, lists, tables, drawings, and inline callouts using the editor toolbar.';

  @override
  String get helpScreenshotAuditIntro =>
      'Learn how SreerajP Journal Vault protects your screens from snooping and logs critical security operations.';

  @override
  String get helpScreenshotAuditSectionGuard =>
      'Screenshot Guard (FLAG_SECURE)';

  @override
  String get helpScreenshotAuditGuardBullet1 =>
      'By default, the app blocks screenshots, screen recording, and masks recent task switcher previews.';

  @override
  String get helpScreenshotAuditGuardBullet2 =>
      'You can toggle screenshot blocking in Settings → Security if you need to capture screenshots.';

  @override
  String get helpScreenshotAuditSectionLog =>
      'Tamper-Evident Security Events Log';

  @override
  String get helpScreenshotAuditLogBullet1 =>
      'The app records a local tamper-evident audit log of PIN attempts, lock switches, and exports in Settings → Security → Security Events.';

  @override
  String get helpSearchTimelineIntro =>
      'Locate past memories in milliseconds with SQLite Full-Text Search and an interactive calendar timeline.';

  @override
  String get helpSearchTimelineSectionFts => 'SQLite Full-Text Search (FTS)';

  @override
  String get helpSearchTimelineFtsBullet1 =>
      'Search across all entries, titles, and tags with instant matching as you type.';

  @override
  String get helpSearchTimelineSectionPresets => 'Saved Search Presets';

  @override
  String get helpSearchTimelinePresetsBullet1 =>
      'Save frequent search filter combinations for one-tap quick access.';

  @override
  String get helpSearchTimelineSectionTimeline =>
      'Calendar & Timeline Explorer';

  @override
  String get helpSearchTimelineTimelineBullet1 =>
      'Browse entries by calendar date, navigate months, and view day-by-day chronological lists.';

  @override
  String get helpStorageMigrationIntro =>
      'Manage where encrypted attachments are stored and migrate between internal memory and SD Card storage.';

  @override
  String get helpStorageMigrationSectionInternal =>
      'Internal App-Private Storage';

  @override
  String get helpStorageMigrationInternalBullet1 =>
      'By default, encrypted attachments reside in app-private internal storage, protected by Android OS sandbox permissions.';

  @override
  String get helpStorageMigrationSectionSd =>
      'SD Card Storage & Live Migration';

  @override
  String get helpStorageMigrationSdBullet1 =>
      'Move media files to SD card in Settings → Storage → Migrate Storage to free up internal phone storage.';

  @override
  String get helpStorageMigrationSdBullet2 =>
      'All files remain fully AES-256-GCM encrypted on the SD card.';

  @override
  String get helpTagsIntro =>
      'Categorize and organize your entries across all journals with custom color-coded tags.';

  @override
  String get helpTagsSectionTagging => 'Tagging Entries & Journals';

  @override
  String get helpTagsTaggingBullet1 =>
      'Add tags to any entry from the top tag bar in the editor.';

  @override
  String get helpTagsSectionColors => 'Custom Color Coding';

  @override
  String get helpTagsColorsBullet1 =>
      'Assign unique palette colors to tags to easily distinguish topics visually.';

  @override
  String get helpTagsSectionCleanup => 'Tag Management & Cleanup';

  @override
  String get helpTagsCleanupBullet1 =>
      'Rename, recolor, or delete unused tags globally from Settings → Tag Manager.';

  @override
  String get syncHealthTitle => 'Sync Health';

  @override
  String get syncHealthSubtitle =>
      'Real-time P2P sync diagnostics & connection status';

  @override
  String syncConnectedPeers(int count) {
    return 'Connected Peers: $count';
  }

  @override
  String syncBytesSent(String bytes) {
    return 'Bytes Sent: $bytes';
  }

  @override
  String syncBytesReceived(String bytes) {
    return 'Bytes Received: $bytes';
  }

  @override
  String get tamperAlertsTitle => 'Tamper Alerts';

  @override
  String get tamperAlertsHowItWorksTitle => 'How Tamper Detection Works';

  @override
  String get tamperAlertsHowItWorksBody =>
      'SreerajP Journal Vault continuously verifies structural consistency, chronological timestamps, and AES-256 encrypted records.';

  @override
  String get tamperAlertsNoHistory =>
      'No tamper alerts recorded. Your vault entries are secure.';

  @override
  String get tamperAlertsHistoryHeader => 'Tamper Alert History';

  @override
  String get tamperAlertsScanCompleteClean =>
      'Vault scan complete: all entries verified clean.';

  @override
  String tamperAlertsScanCompleteIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Integrity check found $count issues.',
      one: 'Integrity check found 1 issue.',
    );
    return '$_temp0';
  }

  @override
  String get tamperAlertsStatusIssues => 'Warning — Integrity Issues Detected';

  @override
  String tamperAlertsStatusIssuesDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count data integrity issues were detected in records.',
      one: '1 data integrity issue was detected in records.',
    );
    return '$_temp0';
  }

  @override
  String get tamperAlertsStatusVerified => 'Vault Integrity Verified';

  @override
  String get tamperAlertsStatusVerifiedDetail =>
      'All database tables and encryption seals verified successfully.';

  @override
  String get tamperAlertsVerifyButton => 'Verify Vault Integrity';

  @override
  String get tamperAlertsVerifying => 'Verifying vault integrity...';

  @override
  String get shareQuickCaptureTitle => 'Quick Capture';

  @override
  String get shareQuickCaptureSubtitle =>
      'Save incoming content as a new journal entry';

  @override
  String get shareNoJournalsFound =>
      'No journals found. Create a journal first.';

  @override
  String get shareSelectJournal => 'Select Journal';

  @override
  String get shareEntryTitleLabel => 'Entry Title';

  @override
  String get shareEntryTitleHint => 'Enter title (optional)';

  @override
  String get shareContentLabel => 'Content';

  @override
  String get shareContentHint => 'Shared note, quote, or link...';

  @override
  String shareAttachmentsLabel(int count) {
    return 'Attachments ($count)';
  }

  @override
  String get shareDiscard => 'Discard';

  @override
  String get shareOpenInEditor => 'Open in Editor';

  @override
  String get shareSaveToJournal => 'Save to Journal';

  @override
  String get shareSaveFailed => 'Could not save shared note.';

  @override
  String shareSavedSuccess(String journalTitle) {
    return 'Shared note saved to \"$journalTitle\"';
  }

  @override
  String get shareSealedFileDetected => 'Encrypted file detected';

  @override
  String get shareOpenEncryptedExport => 'Open Encrypted File';

  @override
  String get templateCategoryCustom => 'Custom Templates';

  @override
  String get templateChooserManage => 'Manage';

  @override
  String get templateChooserNew => 'New Template';

  @override
  String get templateCollapseAll => 'Collapse all';

  @override
  String get templateExpandAll => 'Expand all';

  @override
  String get templateCreateNew => 'New Template';

  @override
  String get templateManagerTitle => 'Custom Templates';

  @override
  String get templateEdit => 'Edit Template';

  @override
  String get templateDelete => 'Delete Template';

  @override
  String get templateDeleteConfirmTitle => 'Delete template?';

  @override
  String templateDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get templateDeleteSuccess => 'Template deleted';

  @override
  String get templateEmpty =>
      'No custom templates yet. Create one to reuse your favorite journaling layouts.';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateNameHint => 'e.g., Daily Standup, Workout Note';

  @override
  String get templateNameRequired => 'Please enter a template name.';

  @override
  String get templateDescriptionLabel => 'Description';

  @override
  String get templateDescriptionHint =>
      'Brief summary of what this template is for';

  @override
  String get templateDefaultTitleLabel => 'Default entry title';

  @override
  String get templateDefaultTitleHint => 'e.g., Standup - today';

  @override
  String get templateContentLabel => 'Starter content';

  @override
  String get templateContentHint => 'Type your starter prompt or outline...';

  @override
  String get templateInsertTokenTooltip => 'Insert dynamic date token';

  @override
  String get templateTokensHeading => 'Dynamic Date Tokens';

  @override
  String get templateTokensHelper =>
      'Dynamic date tokens automatically populate when creating a new entry.';

  @override
  String get templateSaveSuccess => 'Template saved';

  @override
  String get templateSaveAsTemplate => 'Save as template';

  @override
  String get templateSaveAsTemplateTitle => 'New Template';

  @override
  String get templateSaveAsTemplateDesc =>
      'Save this entry\'s layout as a reusable template.';

  @override
  String get settingsSectionHelp => 'Help';

  @override
  String get settingsSectionHelpSubtitle => 'Guides, encryption details & FAQs';

  @override
  String get settingsSectionFeatures => 'Features';

  @override
  String get settingsSectionFeaturesSubtitle =>
      'Explore all features and security tools';

  @override
  String get featuresHeaderTitle => 'SreerajP Journal Vault Features';

  @override
  String get featuresHeaderSubtitle =>
      'Zero-leak offline architecture, military-grade encryption, and expressive journaling.';

  @override
  String entryWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String entryCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chars',
      one: '1 char',
    );
    return '$_temp0';
  }

  @override
  String entryStatsSummary(String words, String chars) {
    return '$words • $chars';
  }

  @override
  String get entryDistractionFreeEnter => 'Distraction-free mode';

  @override
  String get entryDistractionFreeExit => 'Exit distraction-free mode';

  @override
  String get entryFocusParagraphOn => 'Focus paragraph: on';

  @override
  String get entryFocusParagraphOff => 'Focus paragraph: off';

  @override
  String get entryAutoSaving => 'Saving…';

  @override
  String entryAutoSaved(String time) {
    return 'Saved at $time';
  }

  @override
  String get entryAutoSavedJustNow => 'Saved just now';

  @override
  String get entryUnsavedChanges => 'Unsaved changes';

  @override
  String get entryEditorScanText => 'Scan text from image';

  @override
  String get entryEditorOcrSourceTitle => 'Scan text from';

  @override
  String get entryEditorScanSourceCamera => 'Take photo';

  @override
  String get entryEditorScanSourceGallery => 'Choose from gallery';

  @override
  String get entryEditorOcrScanning => 'Scanning text from image...';

  @override
  String get entryEditorOcrNoTextFound => 'No text was detected in the image.';

  @override
  String get entryEditorOcrError => 'Failed to scan text from image.';

  @override
  String get entryEditorCropImageTitle => 'Crop Image';

  @override
  String get entryEditorCropImageError => 'Could not process image crop.';

  @override
  String get appearanceThemeModeTitle => 'Theme Mode';

  @override
  String get appearanceThemeModeSubtitle =>
      'Choose System, Dark, or Light appearance';

  @override
  String get appearanceAccentColorTitle => 'Accent Color';

  @override
  String get appearanceAccentColorSubtitle =>
      'Select primary brand color palette';

  @override
  String get appearanceLivePreview => 'Live Preview';

  @override
  String get appearancePresets => 'Presets';

  @override
  String get appearanceCustomWheel => 'Custom Color Wheel';

  @override
  String get appearanceSampleText => 'Sample Journal Entry';

  @override
  String get appearanceResetDefault => 'Reset to Default';

  @override
  String get appearanceContrastNote =>
      'Text contrast is adjusted automatically for readability.';

  @override
  String get appearanceSystemModeExplainer =>
      'System mode automatically follows your device\'s system-wide dark mode setting.';

  @override
  String get settingsThemeSepia => 'Paper / Sepia';

  @override
  String get settingsThemeOled => 'OLED / True Black';

  @override
  String get settingsThemeSepiaDesc =>
      'Warm parchment paper tone that is soothing for long writing sessions.';

  @override
  String get settingsThemeOledDesc =>
      'Pure pitch black background with crisp contrast for AMOLED battery saving.';

  @override
  String get settingsThemeLightDesc =>
      'Clean and bright daylight reading surface.';

  @override
  String get settingsThemeDarkDesc =>
      'Soft charcoal dark background for low-light writing.';

  @override
  String get settingsThemeSystemDesc =>
      'Automatically follows your device system brightness preference.';

  @override
  String get appearanceTypographyTitle => 'Reading Typography';

  @override
  String get appearanceTypographySubtitle =>
      'Customize body font family and reading size';

  @override
  String get appearanceFontFamily => 'Body Font Family';

  @override
  String get appearanceFontSize => 'Body Font Size';

  @override
  String get appearanceFontFamilySans => 'Sans-Serif';

  @override
  String get appearanceFontFamilySansDesc =>
      'Clean and contemporary modern typeface';

  @override
  String get appearanceFontFamilySerif => 'Book Serif';

  @override
  String get appearanceFontFamilySerifDesc =>
      'Classic editorial and literary book feel';

  @override
  String get appearanceFontFamilyMonospace => 'Monospace';

  @override
  String get appearanceFontFamilyMonospaceDesc =>
      'Fixed-width typewriter and Markdown aesthetic';

  @override
  String get appearanceFontSizeSmall => 'Small';

  @override
  String get appearanceFontSizeDefault => 'Default';

  @override
  String get appearanceFontSizeMedium => 'Medium';

  @override
  String get appearanceFontSizeLarge => 'Large';

  @override
  String get appearanceFontSizeExtraLarge => 'X-Large';

  @override
  String get appearanceSampleHeadline => 'Quiet Reflections';

  @override
  String get appearanceSampleBody =>
      'The journal is a quiet space to slow down and reflect. Every thought, memory, and sketch is securely preserved in your private vault.';

  @override
  String get appearanceTypographyUpdated => 'Typography settings updated.';

  @override
  String get appearanceTypographyReset => 'Typography reset to default.';

  @override
  String get featuresCatJournaling => 'Journaling & Rich Text Editor';

  @override
  String get featuresCatJournalingSub =>
      'Expressive writing, structured templates, OCR, and rich media';

  @override
  String get featuresCatSecurity => 'Privacy, Encryption & Vault Security';

  @override
  String get featuresCatSecuritySub =>
      'Guaranteed zero-leak encryption and granular security controls';

  @override
  String get featuresCatSearch => 'Search, Timeline & Insights';

  @override
  String get featuresCatSearchSub =>
      'Instant full-text discovery, visual calendar, and habit analytics';

  @override
  String get featuresCatStorage => 'Storage, Backups & Export';

  @override
  String get featuresCatStorageSub =>
      'Full offline autonomy, storage migration, and multi-format exports';

  @override
  String get helpHeaderTitle => 'Help Center & Knowledge Base';

  @override
  String get helpHeaderSubtitle =>
      'Complete offline documentation, encryption details, and quick answers.';

  @override
  String get helpSectionWriting => 'Writing & Journal Management';

  @override
  String get helpSectionSecurity => 'Security, Lock & Encryption';

  @override
  String get helpSectionSearch => 'Search, Timeline & Insights';

  @override
  String get helpSectionStorage => 'Storage, Backups & Export';

  @override
  String get helpSectionFaq => 'Frequently Asked Questions';

  @override
  String get editorInsertDrawing => 'Drawing canvas';

  @override
  String get drawingCanvasTitle => 'Drawing & Sketch';

  @override
  String get drawingCanvasEditTitle => 'Edit Drawing';

  @override
  String get drawingCanvasPen => 'Pen';

  @override
  String get drawingCanvasHighlighter => 'Highlighter';

  @override
  String get drawingCanvasEraser => 'Eraser';

  @override
  String get drawingCanvasClear => 'Clear canvas';

  @override
  String get drawingCanvasClearConfirm => 'Clear the entire drawing?';

  @override
  String get drawingCanvasStrokeWidth => 'Stroke width';

  @override
  String get drawingCanvasColor => 'Stroke color';

  @override
  String get drawingCanvasBackground => 'Background';

  @override
  String get drawingCanvasBgBlank => 'Blank';

  @override
  String get drawingCanvasBgRuled => 'Ruled';

  @override
  String get drawingCanvasBgGrid => 'Grid';

  @override
  String get drawingCanvasBgDots => 'Dots';

  @override
  String get drawingCanvasUndo => 'Undo';

  @override
  String get drawingCanvasRedo => 'Redo';

  @override
  String get drawingCanvasSave => 'Save drawing';

  @override
  String get drawingCanvasDiscardTitle => 'Discard changes?';

  @override
  String get drawingCanvasDiscardMessage =>
      'Are you sure you want to discard your drawing changes?';

  @override
  String get drawingEditTooltip => 'Edit drawing';

  @override
  String get drawingSizeTooltip => 'Resize drawing';

  @override
  String get drawingDeleteTooltip => 'Delete drawing';

  @override
  String get drawingUnavailable => 'Drawing unavailable';

  @override
  String get drawingLoading => 'Loading drawing…';

  @override
  String get drawingSaveError => 'Could not save drawing.';

  @override
  String get journalManageTemplates => 'Custom Templates';

  @override
  String get helpTitle => 'Help';

  @override
  String get featuresTitle => 'Features';

  @override
  String get featureOfflineTitle => '100% Offline & Zero Network Permission';

  @override
  String get featureOfflineDesc =>
      'The application contains zero network access code, requests no internet permissions, and keeps all journal data, attachments, and encryption strictly offline.';

  @override
  String get ritualScreenTitle => 'Ritual Practice';

  @override
  String get ritualDeckBrowserTitle => 'Reflection Deck';

  @override
  String get ritualResetReviewsTooltip => 'Reset SRS intervals';

  @override
  String get ritualResetReviewsTitle => 'Reset All Card Reviews';

  @override
  String get ritualResetReviewsConfirm =>
      'This will reset review levels and next review dates for all cards. Continue?';

  @override
  String get ritualResetReviewsDone => 'Card review intervals reset.';

  @override
  String get ritualAllThemes => 'All Themes';

  @override
  String get ritualSrsNew => 'New';

  @override
  String get ritualSrsDueToday => 'Due Today';

  @override
  String ritualSrsInDays(int days) {
    return 'In ${days}d';
  }

  @override
  String get ritualStepBreathe => 'Breathe';

  @override
  String get ritualStepReflect => 'Reflect';

  @override
  String get ritualStepWrite => 'Write';

  @override
  String get ritualBreatheHeading => 'Centering Breath';

  @override
  String get ritualSkipToPrompt => 'Skip to Prompt';

  @override
  String get ritualContinueToCard => 'Continue';

  @override
  String get ritualShuffleCard => 'Shuffle';

  @override
  String get ritualSrsRatePrompt => 'HOW MEMORABLE / EASY WAS THIS REFLECTION?';

  @override
  String get ritualSrsHard => 'Hard';

  @override
  String get ritualSrsHardSubtitle => 'Review in 1d';

  @override
  String get ritualSrsRevision => 'Revision';

  @override
  String get ritualSrsRevisionSubtitle => 'Review in 3d';

  @override
  String get ritualSrsEasy => 'Easy';

  @override
  String get ritualSrsEasySubtitle => '+7 days';

  @override
  String get ritualProceedToJournal => 'Proceed to Journal';

  @override
  String get ritualReadyToWriteTitle => 'Ready to Reflect';

  @override
  String ritualReadyToWriteDesc(String cardTitle) {
    return 'Write your thoughts into today\'s journal entry inspired by \"$cardTitle\".';
  }

  @override
  String get ritualBeginWritingButton => 'Begin Journaling';

  @override
  String get ritualCompletePracticeOnly => 'Complete Practice Only';

  @override
  String get ritualSettingsTitle => 'Ritual Mode Settings';

  @override
  String get ritualLaunchOnStartupTitle => 'Open in Ritual Mode';

  @override
  String get ritualLaunchOnStartupSubtitle =>
      'Begin every session with a guided breath and reflection prompt';

  @override
  String get ritualBreathTechniqueLabel => 'Breathing Technique';

  @override
  String ritualBreathCyclesLabel(int count) {
    return 'Breathing Cycles: $count';
  }

  @override
  String get commonReset => 'Reset';

  @override
  String get ritualHomeCardTitle => 'Daily Ritual Practice';

  @override
  String get ritualHomeCardSubtitle =>
      'Center your mind with a guided breath and today\'s reflection card';

  @override
  String get ritualHomeCardAction => 'Begin Practice';

  @override
  String get ritualSettingsTileTitle => 'Ritual Mode & Reflection';

  @override
  String get ritualSettingsTileSubtitle =>
      'Guided breath timer, 50-card Sanathana Dharma deck & spaced repetition';

  @override
  String get featureRitualTitle => 'Ritual Mode & Reflection Cards';

  @override
  String get featureRitualDesc =>
      'A guided daily practice that calms your mind with a breath timer, surfaces rotating prompt cards with Anki-style spaced repetition, and opens directly to today\'s entry.';

  @override
  String get syncLandingTitle => 'Device-to-Device Sync';

  @override
  String get syncLandingSubtitle =>
      'Sync entries and attachments directly over local Wi-Fi with no cloud servers';

  @override
  String get syncSendTitle => 'Send Changes (Host)';

  @override
  String get syncSendSubtitle =>
      'Display a pairing QR code to share journal entries and attachments with another device';

  @override
  String get syncReceiveTitle => 'Receive Changes (Client)';

  @override
  String get syncReceiveSubtitle =>
      'Scan a pairing QR code or enter connection details to receive updates';

  @override
  String get syncHostTitle => 'Host Wi-Fi Sync';

  @override
  String get syncClientTitle => 'Receive Wi-Fi Sync';

  @override
  String get syncTabQrScan => 'Scan QR';

  @override
  String get syncTabManualEntry => 'Manual Details';

  @override
  String get syncTabConnection => 'Connection';

  @override
  String get syncIpLabel => 'Local IP Address';

  @override
  String get syncPortLabel => 'Port';

  @override
  String get syncPairingCodeLabel => 'Pairing Code';

  @override
  String get syncStatusListening => 'Waiting for incoming connection...';

  @override
  String get syncStatusConnected => 'Device connected & authenticated';

  @override
  String get syncStatusCompleted => 'Sync completed successfully!';

  @override
  String get syncStatusDenied => 'Connection rejected: incorrect pairing code';

  @override
  String get syncStatusStopped => 'Sync server stopped';

  @override
  String get syncStatusError => 'Sync server error';

  @override
  String get syncButtonStart => 'Start Server';

  @override
  String get syncButtonStop => 'Stop Server';

  @override
  String get syncButtonConnect => 'Connect & Sync';

  @override
  String get syncScanInstructions =>
      'Point your camera at the pairing QR code on the sending device';

  @override
  String get syncHostAddressHint => 'e.g. 192.168.1.5';

  @override
  String get syncPortHint => 'e.g. 54321';

  @override
  String get syncCodeHint => '16-character pairing code';

  @override
  String get syncNoWifiAlert =>
      'No Wi-Fi / LAN IP detected. Make sure both devices are on the same Wi-Fi network or hotspot.';

  @override
  String get syncPairingCodeCopied => 'Pairing code copied to clipboard';

  @override
  String get airqrTitle => 'Optical Air-Gap Sync (AirQR)';

  @override
  String get airqrIntro =>
      'Synchronize settings, small journals, and entries over light using animated QR codes without network connections.';

  @override
  String get airqrSendTitle => 'Send via AirQR';

  @override
  String get airqrReceiveTitle => 'Receive via AirQR';

  @override
  String get airqrReceive => 'Receive Data (Scanner)';

  @override
  String get airqrReceiveSubtitle =>
      'Scan animated QR frames from another device';

  @override
  String get airqrSyncSettingsTitle => 'Sync App Settings';

  @override
  String get airqrSyncSettingsSubtitle =>
      'Theme, accent color, security, ritual & templates (< 1 sec)';

  @override
  String get airqrSyncJournalTitle => 'Sync Single Journal';

  @override
  String get airqrSyncJournalSubtitle =>
      'Select and stream a journal with text entries';

  @override
  String get airqrTooLargeTitle => 'Payload Too Large';

  @override
  String get airqrSlowTitle => 'Large Optical Transfer';

  @override
  String get airqrSendAnyway => 'Send Anyway';

  @override
  String get airqrSpeedNoteTitle => '100% Offline & Private';

  @override
  String get airqrSpeedNoteBody =>
      'AirQR works purely via camera and screen. No Wi-Fi, hotspot, Bluetooth, or internet required.';

  @override
  String get timeCapsuleActionSeal => 'Seal as Time Capsule';

  @override
  String get timeCapsuleSealTitle => 'Seal as Time Capsule';

  @override
  String get timeCapsuleSealDescription =>
      'Cryptographically seals this entry until a future date. The decryption key will not be released until that date arrives.';

  @override
  String get timeCapsuleUnlockDateLabel => 'Unlock Date';

  @override
  String get timeCapsuleTeaserHint => 'Note to future self (optional teaser)';

  @override
  String get timeCapsulePreset1Month => '1 Month';

  @override
  String get timeCapsulePreset6Months => '6 Months';

  @override
  String get timeCapsulePreset1Year => '1 Year';

  @override
  String get timeCapsulePreset3Years => '3 Years';

  @override
  String get timeCapsulePreset5Years => '5 Years';

  @override
  String get timeCapsulePresetCustom => 'Custom Date';

  @override
  String get timeCapsuleSealConfirm => 'Seal Capsule';

  @override
  String get timeCapsuleSealedBadge => 'Sealed Time Capsule';

  @override
  String timeCapsuleSealedUntil(String date) {
    return 'Sealed until $date';
  }

  @override
  String timeCapsuleOpensInDays(int days) {
    return 'Opens in $days days';
  }

  @override
  String timeCapsuleOpensInHours(int hours) {
    return 'Opens in $hours hours';
  }

  @override
  String get timeCapsuleOpensToday => 'Opens today!';

  @override
  String get timeCapsuleReadyToOpen => 'Ready to Open';

  @override
  String get timeCapsuleLockedExplanation =>
      'This entry is cryptographically sealed under AES-256-GCM. The app\'s date-gated vault engine will not release the decryption key until the unlock date.';

  @override
  String get timeCapsuleUnsealButton => 'Unseal Time Capsule';

  @override
  String timeCapsuleUnsealLockedPrompt(String date) {
    return 'Locked until $date';
  }

  @override
  String timeCapsuleSealedSuccess(String date) {
    return 'Entry sealed into a time capsule until $date.';
  }

  @override
  String get timeCapsuleUnsealedSuccess =>
      'Time capsule successfully unsealed! Welcome back to your words.';

  @override
  String get timeCapsuleClockTamperError =>
      'Device clock rollback detected. The capsule cannot be unlocked while the device time is behind the recorded seal timestamp.';

  @override
  String get timeCapsuleTitle => 'Time Capsules';

  @override
  String get timeCapsuleSubtitle =>
      'Letters and entries sealed for your future self';

  @override
  String get timeCapsuleEmptyState =>
      'No time capsules yet. Create an entry and seal it for your future self.';

  @override
  String get timeCapsuleBannerTitle => 'Time Capsule Ready!';

  @override
  String timeCapsuleBannerBody(int count) {
    return 'You have $count sealed capsule ready to open today.';
  }

  @override
  String timeCapsuleBannerBodyPlural(int count) {
    return 'You have $count sealed capsules ready to open today.';
  }

  @override
  String get timeCapsuleCategorySealed => 'Sealed Capsules';

  @override
  String get timeCapsuleCategoryReady => 'Ready to Open';

  @override
  String get timeCapsuleCategoryOpened => 'Opened Capsules';

  @override
  String get ritualCreateCardTitle => 'Create Card';

  @override
  String get ritualEditCardTitle => 'Edit Card';

  @override
  String get ritualCreateCardButton => 'New Card';

  @override
  String get ritualCardThemeLabel => 'Theme';

  @override
  String get ritualCardTitleLabel => 'Title';

  @override
  String get ritualCardTitleHint => 'e.g. The Light of Self-Knowledge';

  @override
  String get ritualCardTitleRequired => 'A title is required.';

  @override
  String get ritualCardPromptLabel => 'Reflection Question';

  @override
  String get ritualCardPromptHint =>
      'A question to reflect upon during practice...';

  @override
  String get ritualCardPromptRequired => 'A reflection question is required.';

  @override
  String get ritualCardQuoteLabel => 'Teaching or Quote';

  @override
  String get ritualCardQuoteHint => 'A verse, shloka, or teaching...';

  @override
  String get ritualCardQuoteRequired => 'A teaching or quote is required.';

  @override
  String get ritualCardAuthorLabel => 'Source (optional)';

  @override
  String get ritualCardAuthorHint => 'e.g. Bhagavad Gita 2.47';

  @override
  String get ritualCardPreviewLabel => 'Preview';

  @override
  String get ritualSaveCardCreate => 'Create Card';

  @override
  String get ritualSaveCardEdit => 'Save Changes';

  @override
  String get ritualCardCreatedMessage => 'Card created.';

  @override
  String get ritualCardUpdatedMessage => 'Card updated.';

  @override
  String get ritualCardSaveError =>
      'Could not save the card. Please try again.';

  @override
  String get ritualUserCardBadge => 'MY CARD';

  @override
  String get ritualEditCardAction => 'Edit';

  @override
  String get ritualDeleteCardAction => 'Delete';

  @override
  String get ritualDeleteCardTitle => 'Delete Card';

  @override
  String ritualDeleteCardConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get ritualCardDeletedMessage => 'Card deleted.';

  @override
  String get ritualNoJournalError => 'Please create a journal first.';

  @override
  String get editorGotoLineStart => '⇤';

  @override
  String get editorGotoLineEnd => '⇥';
}
