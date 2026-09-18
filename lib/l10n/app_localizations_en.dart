// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleVaultUnavailable => 'Vault unavailable';

  @override
  String get descVaultUnavailableKeyMissing =>
      'The key that unlocks your journal is no longer on this device. Without it, nothing can read the vault — not even this app.';

  @override
  String get descVaultUnavailableCipherMissing =>
      'This build of the app cannot encrypt the vault, so it has stopped rather than store your journal unprotected.';

  @override
  String get errorVaultUnavailableConversion =>
      'Your journal could not be moved into encrypted storage. It has been left exactly as it was — nothing has been deleted.';

  @override
  String get descVaultUnavailableFileUnreadable =>
      'The vault file cannot be read. It may be damaged, or it may belong to a different installation of the app.';

  @override
  String get descVaultUnavailableDataIntact =>
      'Nothing has been deleted. Your entries and attachments are still on this device.';

  @override
  String get descVaultUnavailableNextSteps =>
      'If you have a backup file, reinstall the app and restore from it. If not, keep this installation as it is and do not clear the app data — that would remove the vault for good.';

  @override
  String get titleApp => 'SreerajP Journal Vault';

  @override
  String get titleAbout => 'About';

  @override
  String get errorAboutLoad => 'Unable to load app metadata';

  @override
  String get errorCommonRetry => 'Retry';

  @override
  String get labelAboutVersionBuild => 'App Version / Build';

  @override
  String get labelAboutLastBuild => 'Last Build Timestamp';

  @override
  String get titlePermissions => 'Permissions';

  @override
  String get titlePermissionsExplicit => 'Explicit permissions';

  @override
  String get titlePermissionsImplicit => 'Implicit permissions';

  @override
  String get labelPermissionStatusAllowed => 'Allowed';

  @override
  String get labelPermissionStatusDenied => 'Denied';

  @override
  String get labelPermissionStatusPermanentlyDenied => 'Permanently denied';

  @override
  String get labelPermissionStatusUserSelected => 'User selected';

  @override
  String get actionPermissionsRequest => 'Request';

  @override
  String get actionPermissionsOpenSettings => 'Open settings';

  @override
  String get actionCommonCancel => 'Cancel';

  @override
  String get actionCommonDelete => 'Delete';

  @override
  String get actionCommonSave => 'Save';

  @override
  String get titleTags => 'Tags';

  @override
  String errorTagsLoad(String error) {
    return 'Could not load tags: $error';
  }

  @override
  String get emptyTags =>
      'No tags yet. Add tags to a journal and they will show up here.';

  @override
  String get descTagsAutomaticColour => 'Automatic colour';

  @override
  String get tooltipTagsActions => 'Tag actions';

  @override
  String get actionTagsRename => 'Rename';

  @override
  String get actionTagsChooseColour => 'Choose colour';

  @override
  String get actionTagsResetColour => 'Reset to automatic';

  @override
  String get errorTagsRename =>
      'That name is empty or already used by another tag.';

  @override
  String bodyTagsDeleted(String name) {
    return 'Deleted #$name.';
  }

  @override
  String get bodyTagsDelete => 'Delete tag?';

  @override
  String bodyTagsDeleteBody(String name) {
    return 'Delete \"#$name\"? It will be removed from every journal and entry that uses it.';
  }

  @override
  String get titleTagsRename => 'Rename tag';

  @override
  String get labelTagsName => 'Tag name';

  @override
  String errorCommon(String message) {
    return 'Error: $message';
  }

  @override
  String get descCommonUntitledEntry => 'Untitled entry';

  @override
  String get descCommonUntitled => 'Untitled';

  @override
  String get titleTimeline => 'Timeline';

  @override
  String get emptyTimelineNoEntriesForDate => 'No entries for this date';

  @override
  String get labelTimelineCalendarFormatMonth => 'Month';

  @override
  String get labelTimelineDayCountOverflow => '9+';

  @override
  String get titleInsights => 'Insights';

  @override
  String get titleInsightsStreak => 'Writing Streak';

  @override
  String get labelInsightsStreakCurrent => 'Current';

  @override
  String get labelInsightsStreakLongest => 'Longest';

  @override
  String get labelInsightsStreakUnitDays => 'days';

  @override
  String labelInsightsStreakStat(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String labelInsightsLastEntry(String date) {
    return 'Last entry: $date';
  }

  @override
  String get titleInsightsMood => 'Mood — 30 days';

  @override
  String get emptyInsightsMood =>
      'No mood data yet.\nRate your mood on entries to see trends.';

  @override
  String descInsightsMood(String date, String mood, int count) {
    return '$date\nMood: $mood\nEntries: $count';
  }

  @override
  String get titleInsightsTagHeatmap => 'Tag Heatmap';

  @override
  String get emptyInsightsTagHeatmap => 'No tags used yet.';

  @override
  String labelInsightsTag(String tag, int count) {
    return '$tag ($count)';
  }

  @override
  String get titleInsightsMemories => 'On This Day';

  @override
  String get emptyInsightsMemories =>
      'No memories for today.\nKeep journaling to build memories!';

  @override
  String labelInsightsYearsAgo(int years) {
    return '${years}y';
  }

  @override
  String get titleInsightsReflection => 'Weekly Reflection';

  @override
  String get labelInsightsReflectionPeriod => 'Period';

  @override
  String get labelInsightsReflectionEntries => 'Entries';

  @override
  String get labelInsightsReflectionWords => 'Words Written';

  @override
  String get labelInsightsReflectionAverageMood => 'Average Mood';

  @override
  String get labelInsightsReflectionTopTags => 'Top Tags';

  @override
  String get labelInsightsReflectionStreak => 'Current Streak';

  @override
  String labelInsightsDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String labelInsightsMoodOutOfFive(String mood) {
    return '$mood / 5';
  }

  @override
  String labelInsightsStreakDays(int count) {
    return '$count days';
  }

  @override
  String get actionCommonClose => 'Close';

  @override
  String get errorCommonUnknown => 'Unknown error';

  @override
  String get titleImport => 'Import Files';

  @override
  String get bodyImportSelecting => 'Importing...';

  @override
  String get actionImportSelectFiles => 'Select files';

  @override
  String get titleImportResults => 'Import Results';

  @override
  String get labelImportFileSucceeded => 'Imported';

  @override
  String descImportCountSucceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files imported successfully',
      one: '1 file imported successfully',
    );
    return '$_temp0';
  }

  @override
  String get emptyAttachmentArchive => 'This archive is empty.';

  @override
  String get descAttachmentOpenWith => 'Open with...';

  @override
  String get titleAttachmentUnsupported => 'Unsupported file';

  @override
  String bodyAttachmentUnsupported(String fileName) {
    return '$fileName cannot be shown inside the app.';
  }

  @override
  String get bodyAttachmentPdfMissing =>
      'The decrypted file is no longer available.';

  @override
  String errorAttachmentPdfOpen(String reason) {
    return 'Could not open PDF: $reason';
  }

  @override
  String get titleAutoLock => 'Auto-Lock Profiles';

  @override
  String get actionAutoLockNewProfile => 'New profile';

  @override
  String get tooltipAutoLockEditProfile => 'Edit profile';

  @override
  String get emptyAutoLock =>
      'No auto-lock profiles yet. Create one to lock the app after a period of inactivity.';

  @override
  String get tooltipAutoLockDeleteProfile => 'Delete profile';

  @override
  String get tooltipAutoLockActivate => 'Activate';

  @override
  String get tooltipAutoLockDeactivate => 'Deactivate';

  @override
  String descAutoLock(String timeout, String lockOnMinimize, String active) {
    return '$timeout$lockOnMinimize$active';
  }

  @override
  String get labelAutoLockSuffixLockOnMinimize => ' • lock on minimize';

  @override
  String get labelAutoLockSuffixActive => ' • active';

  @override
  String labelAutoLockTimeoutSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String labelAutoLockTimeoutMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String labelAutoLockTimeoutHours(String hours) {
    return '${hours}h';
  }

  @override
  String get labelAutoLockName => 'Name';

  @override
  String get labelAutoLockTimeout => 'Timeout (seconds)';

  @override
  String get labelAutoLockLockOnMinimize => 'Lock on minimize';

  @override
  String get errorAutoLockName => 'Name is required.';

  @override
  String get errorAutoLockTimeout => 'Timeout must be a positive integer.';

  @override
  String get titleSecurityEvents => 'Security Events';

  @override
  String get emptySecurityEvents => 'No security events recorded';

  @override
  String get titleSecurityEventDetails => 'Event Details';

  @override
  String get titleSyncConflicts => 'Sync Conflicts';

  @override
  String errorSyncConflictsLoad(String error) {
    return 'Failed to load conflicts:\n$error';
  }

  @override
  String get emptySyncNoConflicts => 'No pending conflicts';

  @override
  String get emptySyncAllInSync => 'All data is in sync.';

  @override
  String labelSyncDetectedAt(String timestamp) {
    return 'Detected: $timestamp';
  }

  @override
  String get titleSyncChangedFields => 'Changed fields:';

  @override
  String get actionSyncCompare => 'Compare';

  @override
  String get actionSyncKeepRemote => 'Keep Remote';

  @override
  String get actionSyncKeepLocal => 'Keep Local';

  @override
  String get bodySyncKeepLocal => 'Keep local version?';

  @override
  String get bodySyncKeepRemote => 'Keep remote version?';

  @override
  String get bodySyncKeepLocalBody =>
      'The remote changes will be discarded. Your local version will be pushed on next sync.';

  @override
  String get bodySyncKeepRemoteBody =>
      'Your local changes will be overwritten with the remote version.';

  @override
  String get bodyCommon => 'Confirm';

  @override
  String get bodySyncConflictResolved => 'Conflict resolved.';

  @override
  String errorSyncResolution(String error) {
    return 'Resolution failed: $error';
  }

  @override
  String get titleSyncConflictDetails => 'Conflict Details';

  @override
  String get titleSyncColumnField => 'Field';

  @override
  String get titleSyncColumnLocal => 'Local';

  @override
  String get titleSyncColumnRemote => 'Remote';

  @override
  String get titleSyncHealth => 'Sync Health';

  @override
  String get labelSyncLastSync => 'Last sync';

  @override
  String get errorSyncFailures7d => 'Failures (7d)';

  @override
  String get labelSyncPendingConflicts => 'Pending conflicts';

  @override
  String get bodyCommonLoading => 'Loading...';

  @override
  String get errorCommonErrorShort => 'Error';

  @override
  String get bodyCommonEllipsis => '...';

  @override
  String get labelSyncNever => 'Never';

  @override
  String actionSyncResolveCount(int count) {
    return 'Resolve ($count)';
  }

  @override
  String get actionSyncNow => 'Sync Now';

  @override
  String get titleSyncRecentActivity => 'Recent Activity';

  @override
  String errorSyncLogsLoad(String error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get emptySyncNoActivity => 'No sync activity yet.';

  @override
  String get labelSyncStatusIdle => 'Idle';

  @override
  String get descSyncStatusSyncing => 'Syncing changes...';

  @override
  String get labelSyncStatusHealthy => 'Healthy';

  @override
  String get errorSyncStatus => 'Failed';

  @override
  String get labelSyncStatusConflicts => 'Conflicts';

  @override
  String get errorSyncLog => 'Sync failed';

  @override
  String labelSyncLogPushed(int count) {
    return '$count pushed';
  }

  @override
  String labelSyncLogPulled(int count) {
    return '$count pulled';
  }

  @override
  String labelSyncLogConflicts(int count) {
    return '$count conflicts';
  }

  @override
  String get labelSyncLogNoChanges => 'No changes';

  @override
  String get tooltipCommonRefresh => 'Refresh';

  @override
  String get titleBackup => 'Backup Health';

  @override
  String get actionBackupNow => 'Backup Now';

  @override
  String get bodyBackupInProgress => 'Backing up...';

  @override
  String get titleBackupHistory => 'Backup History';

  @override
  String get titleBackupStatus => 'Backup Status';

  @override
  String get bodyBackupNoneYet => 'No successful backups yet';

  @override
  String get labelBackupLastBackup => 'Last backup';

  @override
  String get labelBackupEntries => 'Entries';

  @override
  String get labelBackupAttachments => 'Attachments';

  @override
  String get labelBackupSize => 'Size';

  @override
  String errorBackupRecentFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failed backups in the last 7 days',
      one: '1 failed backup in the last 7 days',
    );
    return '$_temp0';
  }

  @override
  String get titleBackupSchedule => 'Auto-Backup Schedule';

  @override
  String labelBackupScheduled(String interval) {
    return 'Scheduled: $interval';
  }

  @override
  String get bodyBackupNotScheduled => 'Not scheduled';

  @override
  String get labelBackupTimerActive => 'Active';

  @override
  String get labelBackupTimerInactive => 'Inactive';

  @override
  String get labelBackupLastScheduledRun => 'Last scheduled run';

  @override
  String get actionBackupDisable => 'Disable';

  @override
  String get actionBackupConfigure => 'Configure';

  @override
  String get actionBackupChange => 'Change';

  @override
  String get titleBackupConfigure => 'Configure Schedule';

  @override
  String get labelBackupInterval => 'Interval';

  @override
  String get labelBackupIntervalDaily => 'Daily';

  @override
  String get labelBackupIntervalWeekly => 'Weekly';

  @override
  String get labelBackupIntervalMonthly => 'Monthly';

  @override
  String get labelBackupPassword => 'Backup password';

  @override
  String get labelBackupPasswordHelper => 'Needed to encrypt';

  @override
  String get emptyBackupNoHistory => 'No backup history';

  @override
  String errorBackupHistoryLoad(String error) {
    return 'Error loading history: $error';
  }

  @override
  String titleBackupLog(String trigger, String status) {
    return '$trigger backup — $status';
  }

  @override
  String get labelBackupTriggerManual => 'Manual';

  @override
  String get labelBackupTriggerScheduled => 'Scheduled';

  @override
  String get labelBackupStatusSuccess => 'Success';

  @override
  String get errorBackupStatus => 'Failed';

  @override
  String get labelBackupStatusInProgress => 'In progress';

  @override
  String descBackupLogCounts(int entries, int attachments, String size) {
    return '$entries entries, $attachments attachments, $size';
  }

  @override
  String get bodyBackupInProgressNote => 'In progress...';

  @override
  String get labelBackupSucceeded => 'Backup complete';

  @override
  String errorBackup(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get titleBackupPassword => 'Backup Password';

  @override
  String get labelBackupPasswordEnter => 'Enter password';

  @override
  String get actionBackup => 'Backup';

  @override
  String get errorBackupPassword => 'Password is required';

  @override
  String get labelBackupScheduleSaved => 'Schedule saved';

  @override
  String get labelBackupScheduleDisabled => 'Schedule turned off';

  @override
  String labelBackupBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String labelBackupKilobytes(String size) {
    return '$size KB';
  }

  @override
  String labelBackupMegabytes(String size) {
    return '$size MB';
  }

  @override
  String get actionCommonRestore => 'Restore';

  @override
  String get actionCommonInsert => 'Insert';

  @override
  String get actionCommonContinue => 'Continue';

  @override
  String get actionCommonOpenSystemSettings => 'Open system settings';

  @override
  String get descEditorCallout => 'Enter callout text...';

  @override
  String get tabEditorInsert => 'Insert tab';

  @override
  String get tooltipEditorInsertTable => 'Insert table';

  @override
  String get tooltipEditorInsertCallout => 'Insert callout';

  @override
  String get tooltipEditorInsertImage => 'Insert image';

  @override
  String get tooltipEditorImageSize => 'Image size';

  @override
  String get labelEditorImageSizeSmall => 'Small';

  @override
  String get labelEditorImageSizeMedium => 'Medium';

  @override
  String get labelEditorImageSizeFull => 'Full width';

  @override
  String get tooltipEditorRemoveImage => 'Remove image';

  @override
  String get labelEditorImageUnavailable => 'Image unavailable';

  @override
  String get bodyEditorMicPermissionDenied => 'Microphone permission denied';

  @override
  String get actionEditorDiscard => 'Discard';

  @override
  String get actionEditorDone => 'Done';

  @override
  String get titleVersionHistory => 'Version history';

  @override
  String errorVersionHistoryLoad(String error) {
    return 'Error loading revisions: $error';
  }

  @override
  String get bodyVersionRestore => 'Restore this version?';

  @override
  String get labelVersionRestored => 'Version restored';

  @override
  String get tooltipVersionPreview => 'Preview';

  @override
  String get tooltipVersionRestore => 'Restore this version';

  @override
  String titleVersionPreview(String title) {
    return 'Preview: $title';
  }

  @override
  String get labelEntrySaved => 'Entry saved';

  @override
  String get bodyEntryDelete => 'Delete entry?';

  @override
  String get bodyEntryDeleteBody => 'This will permanently remove the entry.';

  @override
  String get labelEntryTableRows => 'Rows';

  @override
  String get labelEntryTableColumns => 'Columns';

  @override
  String get labelEntryTableDimensionHelp => '1–20';

  @override
  String get titleEntryCalloutType => 'Callout type';

  @override
  String get labelEntryCalloutInfo => 'Info';

  @override
  String get labelEntryCalloutTip => 'Tip';

  @override
  String get bodyEntryCallout => 'Warning';

  @override
  String get labelEntryCalloutImportant => 'Important';

  @override
  String labelEntryVoiceNoteSaved(String seconds) {
    return 'Voice note saved (${seconds}s)';
  }

  @override
  String get titleEntryEdit => 'Edit entry';

  @override
  String get titleEntryEditTitleDirty => 'Edit entry •';

  @override
  String get tooltipEntryVersionHistory => 'Version history';

  @override
  String get tooltipEntryDelete => 'Delete entry';

  @override
  String get tooltipEntrySave => 'Save';

  @override
  String get tooltipEntryNoUnsavedChanges => 'No unsaved changes';

  @override
  String get labelEntryTitle => 'Title';

  @override
  String get bodyEntryPermission => 'Allow attachment import?';

  @override
  String get bodyEntryPermissionBody =>
      'This app needs permission to access your files.';

  @override
  String get titleEntryPermissionBlocked => 'Access blocked';

  @override
  String get bodyEntryPermissionBlocked =>
      'Permission was permanently denied. Please enable it in system settings.';

  @override
  String get bodyEntryNotAnImage =>
      'That file is not an image. Add it as an attachment instead.';

  @override
  String get errorEntryImageAdd => 'Could not add that image.';

  @override
  String get tooltipEntryAddAttachment => 'Add attachment';

  @override
  String get tooltipEntryRecordVoiceNote => 'Record voice note';

  @override
  String get titleEntryLinkedFrom => 'Linked from';

  @override
  String get tooltipEntryMood => 'Set mood';

  @override
  String get titleEntryMood => 'Mood';

  @override
  String labelEntryMood(String face, int level) {
    return '$face $level';
  }

  @override
  String get errorEntryAuth => 'Authentication required.';

  @override
  String get bodyAttachmentOpenNoApp => 'No compatible app found';

  @override
  String get errorAttachmentOpenDecrypt => 'Could not decrypt attachment';

  @override
  String get bodyAttachmentOpenFileMissing => 'Attachment file is missing';

  @override
  String get bodyAttachmentOpenPermissionDenied =>
      'Permission required to open attachment';

  @override
  String get titleEntryAttachments => 'Attachments';

  @override
  String get tooltipEntryRemoveAttachmentLock => 'Remove lock';

  @override
  String get tooltipEntryLockAttachment => 'Lock attachment';

  @override
  String get tooltipEntryOpenAttachment => 'Open attachment';

  @override
  String get bodyVersionRestoreBody =>
      'Your current content will be saved as a new version before restoring.';

  @override
  String get actionCommonUnlock => 'Unlock';

  @override
  String get labelCommonPassword => 'Password';

  @override
  String get bodyCommonSaving => 'Saving...';

  @override
  String get titleLockSetup => 'Set up app lock';

  @override
  String get bodyLockSetup =>
      'Choose how SreerajP Journal Vault should lock when it is sent to the background.';

  @override
  String get labelLockModePhone => 'Phone Lock';

  @override
  String get descLockModePhone =>
      'Use the device biometric or PIN/pattern/password.';

  @override
  String get labelLockModeApp => 'Separate App Lock';

  @override
  String get descLockModeApp =>
      'Use a dedicated PIN that is verified inside the app.';

  @override
  String get labelLockPin => 'PIN';

  @override
  String get labelLockConfirmPin => 'Confirm PIN';

  @override
  String get bodyLockSettingUp => 'Setting up...';

  @override
  String get errorLockPin => 'PIN must be at least 4 characters.';

  @override
  String get bodyLockPinsDoNotMatch => 'PINs do not match.';

  @override
  String errorLockSetupSave(String error) {
    return 'Could not save lock setup: $error';
  }

  @override
  String errorLockPinSave(String error) {
    return 'Could not save PIN: $error';
  }

  @override
  String get titleLockPinSetup => 'Set app-lock PIN';

  @override
  String get bodyLockPinSetup =>
      'Separate App Lock requires a PIN. Set one to continue.';

  @override
  String get labelLockGateHeadline => 'Journal is locked';

  @override
  String get descLockGate => 'Unlock to open your entries.';

  @override
  String get tooltipLockGateShowPin => 'Show PIN';

  @override
  String get tooltipLockGateHidePin => 'Hide PIN';

  @override
  String get labelLockGateBadge => 'Locked';

  @override
  String get actionLockUnlockWithPhone => 'Use phone lock';

  @override
  String get errorLockAuth => 'Authentication failed. Please try again.';

  @override
  String get bodyLockAuthUnavailable =>
      'Device authentication is not available. Configure a PIN/biometric in system settings.';

  @override
  String get bodyLockEnterPin => 'Enter your PIN.';

  @override
  String get bodyLockIncorrectPin => 'Incorrect PIN.';

  @override
  String get titleLockedAttachments => 'Locked attachments';

  @override
  String get emptyLockedAttachments =>
      'No attachments are locked yet. Open an entry and use the lock button on an attachment to require re-authentication before opening it.';

  @override
  String labelLockedAttachmentSince(String date) {
    return 'Locked $date';
  }

  @override
  String get actionLockedAttachmentRemove => 'Remove lock';

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
  String get bodyJournalDelete => 'Delete journal?';

  @override
  String bodyJournalDeleteBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get tooltipJournalManageTags => 'Manage tags';

  @override
  String get tooltipJournalNew => 'New journal';

  @override
  String get tooltipJournalEdit => 'Edit journal';

  @override
  String get tooltipJournalDelete => 'Delete journal';

  @override
  String get emptyJournal => 'No journals yet';

  @override
  String get emptyJournalEmptyBody => 'Tap “New journal” to start writing.';

  @override
  String get labelJournalTitle => 'Title';

  @override
  String get labelJournalDescription => 'Description';

  @override
  String get labelJournalTags => 'Comma-separated tags';

  @override
  String get labelJournalLockSwitch => 'Lock journal';

  @override
  String get labelJournalConfirmPassword => 'Confirm password';

  @override
  String get actionJournalAddEntry => 'Add entry';

  @override
  String get labelJournalIsLocked => 'Journal is locked';

  @override
  String get labelJournalUnlocked => 'Unlocked';

  @override
  String get bodyJournalIncorrectPassword => 'Incorrect password.';

  @override
  String get titleSettingsSectionSecurity => 'Security';

  @override
  String get descSettingsSectionSecurity =>
      'Lock mode, auto-lock, screenshots and security events';

  @override
  String get titleSettingsSectionAppearance => 'Appearance';

  @override
  String get descSettingsSectionAppearance => 'Theme and how the app looks';

  @override
  String get titleSettingsSectionStorage => 'Storage';

  @override
  String get descSettingsSectionStorage =>
      'Attachment location, usage, backup and import';

  @override
  String get titleSettingsSectionPermissions => 'Permissions';

  @override
  String get descSettingsSectionPermissions => 'What the app is allowed to use';

  @override
  String get titleSettingsSectionAbout => 'About';

  @override
  String get descSettingsSectionAbout => 'Version, licences and app details';

  @override
  String get labelSettingsAppLockMode => 'App Lock Mode';

  @override
  String get labelSettingsAutoLockTimeout => 'Auto-Lock Timeout';

  @override
  String get labelSettingsScreenSecurity => 'Block Screenshots';

  @override
  String get descSettingsScreenSecurity =>
      'Stops screenshots, screen recording and the preview shown in the recent apps list';

  @override
  String get bodySettingsScreenSecurityOff => 'Turn off screenshot blocking?';

  @override
  String get bodySettingsScreenSecurityOffBody =>
      'Anyone taking a screenshot or recording the screen will be able to capture your journal content. The recent apps list will also show your last screen. You can turn this back on at any time.';

  @override
  String get actionSettingsScreenSecurityOff => 'Turn Off';

  @override
  String get bodySettingsScreenSecurityUpdatedOn => 'Screenshot blocking is on';

  @override
  String get bodySettingsScreenSecurityUpdatedOff =>
      'Screenshot blocking is off';

  @override
  String get errorSettingsScreenSecuritySave =>
      'Could not change screenshot blocking';

  @override
  String get labelSettingsTamperAlerts => 'Tamper Alerts';

  @override
  String get labelSettingsSyncConflicts => 'Sync Conflicts';

  @override
  String get labelSettingsSecurityEvents => 'Security Events';

  @override
  String get labelSettingsThemeLight => 'Light';

  @override
  String get labelSettingsThemeDark => 'Dark';

  @override
  String get labelSettingsThemeSystem => 'System';

  @override
  String get bodySettingsSwitchLock => 'Switch lock mode?';

  @override
  String bodySettingsSwitchLockBody(String enabled, String disabled) {
    return 'This will switch app protection to $enabled and disable $disabled. Continue?';
  }

  @override
  String get actionSettingsSwitch => 'Switch';

  @override
  String descSettingsLockModeUpdated(String mode) {
    return 'Lock mode updated: $mode is now active.';
  }

  @override
  String get errorSettingsThemeSave =>
      'Could not save theme setting. Please try again.';

  @override
  String descSettingsThemeUpdated(String mode) {
    return 'Theme updated: $mode mode is now active.';
  }

  @override
  String get bodyStorageMigrate => 'Migrate attachments?';

  @override
  String bodyStorageMigrateBody(String target) {
    return 'All attachments will be moved to $target.';
  }

  @override
  String get actionStorageMigrate => 'Migrate';

  @override
  String get bodyStorageMigrationCancelled => 'Migration cancelled.';

  @override
  String errorStorageMigration(String error) {
    return 'Migration failed: $error';
  }

  @override
  String get bodyStorageMigrationComplete => 'Migration complete.';

  @override
  String get titleStorageLocation => 'Storage location';

  @override
  String get titleStorageLocationDialogTitle => 'Storage location';

  @override
  String get labelStorageAppPrivate => 'App Private';

  @override
  String get labelStorageSdCard => 'SD Card';

  @override
  String labelStorageSdCardNamed(String label) {
    return 'SD Card ($label)';
  }

  @override
  String get labelStorageMigrateRow => 'Migrate Storage';

  @override
  String get labelStorageMigrationIdle => 'Idle';

  @override
  String descStorageMigrationRunning(int processed, int total) {
    return 'Migrating $processed of $total…';
  }

  @override
  String get descStorageMigrationFailedShort => 'Migration failed.';

  @override
  String get labelStorageUsage => 'Storage Usage';

  @override
  String get bodyStorageUnknown => '—';

  @override
  String get labelStorageBackupHealth => 'Backup Health';

  @override
  String get labelStorageImportData => 'Import Data';

  @override
  String get titleStorageSyncHealth => 'Sync Health';

  @override
  String get bodyStorageImportNeedsJournal =>
      'Create a journal first to import into.';

  @override
  String get titleStorageImportChooseJournal => 'Import into journal';

  @override
  String labelStorageBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String labelStorageKilobytes(String size) {
    return '$size KB';
  }

  @override
  String labelStorageMegabytes(String size) {
    return '$size MB';
  }

  @override
  String labelStorageGigabytes(String size) {
    return '$size GB';
  }

  @override
  String get titleMigration => 'Moving attachments';

  @override
  String get bodyMigrationCancelling => 'Cancelling…';

  @override
  String labelMigrationProgress(String processed, String total) {
    return '$processed of $total';
  }

  @override
  String get descMigrationUnknownTotal => '?';

  @override
  String get labelPermissionStatusRow => 'Permission Status';

  @override
  String get labelPermissionsManage => 'Manage Permissions';

  @override
  String get labelPermissionsOpenSystem => 'Open System Settings';

  @override
  String descPermissionsGranted(int granted, int total) {
    return '$granted of $total granted';
  }

  @override
  String get descSearch => 'Search journals & entries...';

  @override
  String get actionSearchTypeToSearch => 'Type to search';

  @override
  String get bodySearchNoFilterMatches => 'No matches found for this filter.';

  @override
  String get emptySearch => 'No results found';

  @override
  String get titleSearchSectionJournals => 'Journals';

  @override
  String get titleSearchSectionEntries => 'Entries';

  @override
  String get titleSearchSavePreset => 'Save search preset';

  @override
  String get labelSearchPresetName => 'Preset name';

  @override
  String get titleRestore => 'Restore from backup';

  @override
  String get actionRestoreOpen => 'Restore from backup';

  @override
  String get titleRestoreLocked => 'Unlock to continue';

  @override
  String get bodyRestoreLocked =>
      'Restoring changes your journal, so it is protected the same way the app is.';

  @override
  String get actionRestoreUnlock => 'Unlock';

  @override
  String get labelRestoreUnlockReason => 'Unlock to restore';

  @override
  String get errorRestoreUnlock => 'Could not unlock. Nothing was changed.';

  @override
  String get labelRestoreEnterPin => 'Enter your app PIN';

  @override
  String get bodyRestorePinWrong => 'That PIN is not right.';

  @override
  String get titleRestorePick => 'Choose a backup';

  @override
  String get actionRestorePickFromDevice => 'Choose a file';

  @override
  String get bodyRestoreNoBackupsFound =>
      'No backups made by this app were found. You can still choose a file.';

  @override
  String labelRestoreSelectedFile(String fileName) {
    return 'Selected: $fileName';
  }

  @override
  String get labelRestorePassword => 'Backup password';

  @override
  String get bodyRestorePasswordHelper =>
      'The password used when this backup was made.';

  @override
  String get actionRestoreOpenBackup => 'Open backup';

  @override
  String get titleRestorePreview => 'Backup contents';

  @override
  String labelRestorePreviewCreated(String date) {
    return 'Made on $date';
  }

  @override
  String bodyRestorePreviewCounts(int journals, int entries, int attachments) {
    return '$journals journals, $entries entries, $attachments attachments';
  }

  @override
  String get bodyRestoreLegacyAttachments =>
      'This is an older backup. Its attachments only open on the device that made it.';

  @override
  String get bodyRestoreMode => 'How should it be restored?';

  @override
  String get actionRestoreModeMerge => 'Merge';

  @override
  String get descRestoreModeMergeDetail =>
      'Add what is missing and keep everything you have now.';

  @override
  String get actionRestoreModeReplace => 'Replace';

  @override
  String get descRestoreModeReplaceDetail =>
      'Delete what is here now and use the backup instead. A safety backup is taken first.';

  @override
  String get actionRestoreDryRun => 'Try it first';

  @override
  String get bodyRestoreDryRunHelper =>
      'Shows what would change without changing anything.';

  @override
  String get actionRestore => 'Restore';

  @override
  String get bodyRestoreConfirmReplace => 'Replace everything?';

  @override
  String get bodyRestoreConfirmReplaceBody =>
      'Every journal, entry and attachment on this device will be deleted and replaced by the backup. A safety backup of what is here now is taken first.';

  @override
  String get bodyRestoreConfirmMerge => 'Merge this backup?';

  @override
  String get bodyRestoreConfirmMergeBody =>
      'Anything the backup holds that is missing here will be added. Nothing is deleted.';

  @override
  String get titleRestoreDryRunResult => 'What would happen';

  @override
  String get titleRestoreResult => 'Restore finished';

  @override
  String labelRestoreResultAdded(int count) {
    return 'Added: $count rows';
  }

  @override
  String labelRestoreResultSkipped(int count) {
    return 'Already here: $count rows';
  }

  @override
  String descRestoreResultFiles(int count) {
    return 'Attachment files restored: $count';
  }

  @override
  String errorRestoreResultFiles(int count) {
    return 'Attachment files that could not be restored: $count';
  }

  @override
  String get descRestoreResultSafetyBackup =>
      'A safety backup of your previous data was saved first.';

  @override
  String get bodyRestoreErrorWrongPassword =>
      'Wrong password, or the backup file is damaged.';

  @override
  String get bodyRestoreErrorDamaged =>
      'This file is not a backup, or it is damaged.';

  @override
  String get bodyRestoreErrorTooNew =>
      'This backup was made by a newer version of the app. Update the app and try again.';

  @override
  String get errorRestoreErrorPassword =>
      'The backup password must be at least 8 characters.';

  @override
  String errorRestoreError(String error) {
    return 'The restore failed and nothing was changed: $error';
  }

  @override
  String get bodyRestoreWorking => 'Working...';

  @override
  String get titleExportProtect => 'Password protect';

  @override
  String get descExportProtect =>
      'The file is encrypted with your password. It can be opened again in this app, on any device.';

  @override
  String get labelExportPassword => 'Password';

  @override
  String get labelExportPasswordConfirm => 'Repeat the password';

  @override
  String errorExportPassword(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get errorExportPasswordMismatch => 'The two passwords do not match.';

  @override
  String get bodyExportEncryptedNotice =>
      'Keep this password somewhere safe. Without it the exported file cannot be opened again, by anyone, including you.';

  @override
  String get titleOpenEncrypted => 'Open encrypted file';

  @override
  String get descOpenEncryptedIntro =>
      'Choose an encrypted export file, enter its password, and save the file inside it.';

  @override
  String get actionOpenEncryptedPickFile => 'Choose file';

  @override
  String labelOpenEncryptedChosenFile(String fileName) {
    return 'Chosen: $fileName';
  }

  @override
  String get labelOpenEncryptedPassword => 'File password';

  @override
  String get actionOpenEncrypted => 'Open and save';

  @override
  String get bodyOpenEncryptedWorking => 'Opening...';

  @override
  String get titleOpenEncryptedSave => 'Save the opened file';

  @override
  String get descOpenEncryptedSaved =>
      'Saved. The file is no longer encrypted, so keep it somewhere safe.';

  @override
  String get bodyOpenEncryptedCancelled => 'Nothing was saved.';

  @override
  String get errorOpenEncryptedErrorWrongPassword =>
      'Wrong password, or the file is damaged.';

  @override
  String get errorOpenEncryptedErrorNotSealed =>
      'This is not an encrypted export made by this app.';

  @override
  String get errorOpenEncryptedErrorTooNew =>
      'This file was made by a newer version of the app. Update the app and try again.';

  @override
  String get errorOpenEncryptedError => 'The file could not be opened.';

  @override
  String get actionSettingsOpenEncryptedExport => 'Open encrypted file';

  @override
  String get titleTemplateChooser => 'Choose a template';

  @override
  String get emptyVersionHistory =>
      'No previous versions yet.\n\nVersions are saved automatically when you edit an entry.';

  @override
  String get labelDrawingStrokeFine => 'Fine (2px)';

  @override
  String get labelDrawingStrokeNormal => 'Normal (3.5px)';

  @override
  String get labelDrawingStrokeThick => 'Thick (7px)';

  @override
  String get labelDrawingStrokeBold => 'Bold (14px)';

  @override
  String get titleDrawingDefault => 'Drawing';

  @override
  String get titleImageDefault => 'Image';

  @override
  String get bodyEditorImageLocked => 'Locked image — tap to unlock';

  @override
  String bodyEditorImageUnavailableWithName(String fileName) {
    return 'Image unavailable — $fileName';
  }

  @override
  String get tooltipAudioPause => 'Pause';

  @override
  String get tooltipAudioPlay => 'Play';

  @override
  String titleImportIntoJournal(String journalTitle) {
    return 'Import into \"$journalTitle\"';
  }

  @override
  String labelImportSupportedFormats(String formats) {
    return 'Supported formats: $formats';
  }

  @override
  String labelImportSupportedExtensions(String extensions) {
    return 'Files: $extensions';
  }

  @override
  String get bodyImportSelectFilesPrompt =>
      'Select files to import as new entries';

  @override
  String get labelFeaturesCategoryJournaling => 'Journaling & Rich Text Editor';

  @override
  String get descFeaturesCategoryJournaling =>
      'Expressive writing, structured templates, OCR, and rich media';

  @override
  String get descFeaturesCategorySecurity =>
      'Privacy, Encryption & Vault Security';

  @override
  String get descFeaturesCategorySecuritySubtitle =>
      'Guaranteed zero-leak encryption and granular security controls';

  @override
  String get labelFeaturesCategoryDiscovery => 'Search, Timeline & Insights';

  @override
  String get descFeaturesCategoryDiscovery =>
      'Blazing fast search, deep calendar navigation, and writing habits';

  @override
  String get descFeaturesCategoryStorage =>
      'Storage, Backups & Multi-Format Export';

  @override
  String get descFeaturesCategoryStorageSubtitle =>
      'Total data sovereignty with local backups and flexible exports';

  @override
  String get titleFeatureQuill => 'Quill Rich Text Editor';

  @override
  String get descFeatureQuill =>
      'Write entries with rich formatting including headings, bulleted & numbered lists, bold, italics, underlines, and inline blockquotes.';

  @override
  String get titleFeatureTemplates => 'Structured Entry Templates';

  @override
  String get descFeatureTemplates =>
      'Jumpstart your writing with 8 customizable templates: Daily Reflection, Gratitude, Dream Journal, Workout Log, Travel Diary, Meeting Notes, Bullet Journal, and Freeform.';

  @override
  String get bodyFeatureMediaOcr => 'Encrypted Media Attachments & OCR';

  @override
  String get descFeatureMediaOcr =>
      'Attach photos, audio recordings, and documents encrypted on device. Extract text directly from images into your journal with offline OCR.';

  @override
  String get titleFeatureTags => 'Color-Coded Tags & Tag Manager';

  @override
  String get descFeatureTags =>
      'Organize entries and journals with vibrant color-coded tags. Rename, color, or bulk-manage tags effortlessly in the Tag Manager.';

  @override
  String get titleFeatureMultiJournal => 'Multiple Distinct Journals';

  @override
  String get descFeatureMultiJournal =>
      'Create multiple separate journals for work, personal diaries, travel adventures, or creative projects, each with custom tags and settings.';

  @override
  String get bodyFeatureSqlcipher => 'SQLCipher AES-256 Database Encryption';

  @override
  String get descFeatureSqlcipher =>
      'All journal data, entries, metadata, and tables are encrypted at rest using SQLCipher with AES-256-GCM. Unencrypted data is never written to disk.';

  @override
  String get titleFeatureBiometrics => 'Biometric & App PIN Lock';

  @override
  String get descFeatureBiometrics =>
      'Secure your vault with your device fingerprint or face unlock, or set a dedicated App PIN. The app re-locks automatically whenever you switch apps.';

  @override
  String get titleFeatureJournalLock => 'Per-Journal Password Locks';

  @override
  String get descFeatureJournalLock =>
      'Lock specific sensitive journals behind individual passwords using PBKDF2 key derivation. Locked journals require password entry each session.';

  @override
  String get bodyFeatureAttachmentLock => 'Attachment-Level Encryption Locks';

  @override
  String get descFeatureAttachmentLock =>
      'Individually lock and hide sensitive attachments and photos with separate encryption keys, keeping them private even when browsing entries.';

  @override
  String get bodyFeatureScreenshotGuard =>
      'Screenshot & Screen-Recording Guard';

  @override
  String get descFeatureScreenshotGuard =>
      'Automatic FLAG_SECURE window defense blocks malicious screenshot capture, screen recording apps, and recents app switcher snapshot leaking.';

  @override
  String get bodyFeatureTamperAudit => 'Tamper-Evident Security Audit Log';

  @override
  String get descFeatureTamperAudit =>
      'Monitors and logs key security events: app unlock attempts, failed biometric/PIN authentications, password changes, and export actions.';

  @override
  String get titleFeatureAutoLock => 'Auto-Lock Inactivity Profiles';

  @override
  String get descFeatureAutoLock =>
      'Configure custom timeout durations (immediate, 30 seconds, 1 min, 5 min) to automatically relock your journal vault when idle.';

  @override
  String get titleFeatureFtsSearch => 'Lightning SQLite FTS Search';

  @override
  String get descFeatureFtsSearch =>
      'Instant full-text search indexing scans every entry body, title, tag, and metadata with SQLite FTS5 for sub-millisecond query results.';

  @override
  String get titleFeatureSearchPresets => 'Saved Search Presets';

  @override
  String get descFeatureSearchPresets =>
      'Save frequent queries with date range and tag filters as one-tap quick filter chips directly accessible from the search bar.';

  @override
  String get bodyFeatureTimeline => 'Interactive Calendar Timeline Explorer';

  @override
  String get descFeatureTimeline =>
      'Navigate your entire journal history with a smooth calendar view, visual daily entry dots, day-by-day browsing, and quick date jumping.';

  @override
  String get titleFeatureInsights => 'Writing Trends & Habit Insights';

  @override
  String get descFeatureInsights =>
      'Track your daily writing streaks, word counts, active writing days per month, and top tag distributions with offline analytical charts.';

  @override
  String get bodyFeatureStorageMigration =>
      'Attachment Storage Migration (SD Card)';

  @override
  String get descFeatureStorageMigration =>
      'Seamlessly migrate all encrypted attachments between internal app storage and removable SD Card memory without interrupting journal access.';

  @override
  String get titleFeatureEncryptedBackups => 'Encrypted Vault Backups (.jvbk)';

  @override
  String get descFeatureEncryptedBackups =>
      'Export and restore complete password-protected .jvbk backup archives containing your database, attachments, tags, and settings.';

  @override
  String get titleFeatureMultiExport => 'Formatted Multi-Format Export';

  @override
  String get descFeatureMultiExport =>
      'Export individual entries or complete journals into clean formatted PDF, Markdown zip archive, or raw JSON data formats.';

  @override
  String get bodyFeatureEncryptedReader => 'Standalone Encrypted Export Reader';

  @override
  String get descFeatureEncryptedReader =>
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
      'Camera & Photos: To take photos or import images/attachments into your entries.\nMicrophone: To record voice notes and to dictate text (recognised on the device).\nStorage/Media: To save encrypted backups and export PDFs.';

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
  String get titleTamperAlerts => 'Tamper Alerts';

  @override
  String get titleTamperAlertsHowItWorks => 'How this works';

  @override
  String get bodyTamperAlertsHowItWorks =>
      'SreerajP Journal Vault continuously verifies structural consistency, chronological timestamps, and AES-256 encrypted records.';

  @override
  String get bodyTamperAlertsNoHistory =>
      'No tamper alerts recorded. Your vault entries are secure.';

  @override
  String get titleTamperAlertsHistory => 'Tamper Alert History';

  @override
  String get bodyTamperAlertsScanCompleteClean =>
      'Vault scan complete: all entries verified clean.';

  @override
  String bodyTamperAlertsScanCompleteIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Integrity check found $count issues.',
      one: 'Integrity check found 1 issue.',
    );
    return '$_temp0';
  }

  @override
  String get bodyTamperAlertsStatusIssues =>
      'Warning — Integrity Issues Detected';

  @override
  String bodyTamperAlertsStatusIssuesDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count data integrity issues were detected in records.',
      one: '1 data integrity issue was detected in records.',
    );
    return '$_temp0';
  }

  @override
  String get bodyTamperAlertsStatusVerified => 'Vault Integrity Verified';

  @override
  String get descTamperAlertsStatusVerifiedDetail =>
      'All database tables and encryption seals verified successfully.';

  @override
  String get actionTamperAlertsVerify => 'Verify vault';

  @override
  String get bodyTamperAlertsVerifying => 'Verifying vault integrity...';

  @override
  String get titleShareQuickCapture => 'Quick Capture';

  @override
  String get descShareQuickCapture =>
      'Save incoming content as a new journal entry';

  @override
  String get bodyShareNoJournalsFound =>
      'No journals found. Create a journal first.';

  @override
  String get labelShareSelectJournal => 'Select Journal';

  @override
  String get labelShareEntryTitle => 'Entry Title';

  @override
  String get descShareEntryTitle => 'Enter title (optional)';

  @override
  String get labelShareContent => 'Content';

  @override
  String get descShareContent => 'Shared note, quote, or link...';

  @override
  String labelShareAttachments(int count) {
    return 'Attachments ($count)';
  }

  @override
  String get actionShareDiscard => 'Discard';

  @override
  String get actionShareOpenInEditor => 'Open in Editor';

  @override
  String get actionShareSaveToJournal => 'Save to Journal';

  @override
  String get errorShareSave => 'Could not save shared note.';

  @override
  String bodyShareSavedSuccess(String journalTitle) {
    return 'Shared note saved to \"$journalTitle\"';
  }

  @override
  String get titleShareSealedFileDetected => 'Encrypted file';

  @override
  String get actionShareOpenEncryptedExport => 'Open Encrypted File';

  @override
  String get labelTemplateCategoryCustom => 'My templates';

  @override
  String get actionTemplateCollapseAll => 'Collapse all';

  @override
  String get actionTemplateExpandAll => 'Expand all';

  @override
  String get actionTemplateCreateNew => 'New Template';

  @override
  String get titleTemplateManager => 'Custom Templates';

  @override
  String get actionTemplateEdit => 'Edit Template';

  @override
  String get actionTemplateDelete => 'Delete Template';

  @override
  String get bodyTemplateDeleteConfirm => 'Delete template?';

  @override
  String bodyTemplateDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get bodyTemplateDeleteSuccess => 'Template deleted';

  @override
  String get emptyTemplate =>
      'No custom templates yet. Create one to reuse your favorite journaling layouts.';

  @override
  String get labelTemplateName => 'Template name';

  @override
  String get descTemplateName => 'e.g., Daily Standup, Workout Note';

  @override
  String get errorTemplateName => 'Please enter a template name.';

  @override
  String get labelTemplateDescription => 'Description';

  @override
  String get descTemplateDescription =>
      'Brief summary of what this template is for';

  @override
  String get labelTemplateDefaultTitle => 'Default entry title';

  @override
  String get descTemplateDefaultTitle => 'e.g., Standup - today';

  @override
  String get labelTemplateContent => 'Starter content';

  @override
  String get descTemplateContent => 'Type your starter prompt or outline...';

  @override
  String get titleTemplateTokens => 'Dynamic Date Tokens';

  @override
  String get descTemplateTokensHelper =>
      'Dynamic date tokens automatically populate when creating a new entry.';

  @override
  String get bodyTemplateSaveSuccess => 'Template saved';

  @override
  String get actionTemplateSaveAsTemplate => 'Save as template';

  @override
  String get titleTemplateSaveAsTemplate => 'New Template';

  @override
  String get descTemplateSaveAsTemplate =>
      'Save this entry\'s layout as a reusable template.';

  @override
  String get titleSettingsSectionHelp => 'Help';

  @override
  String get descSettingsSectionHelp => 'Guides, encryption details & FAQs';

  @override
  String get titleSettingsSectionFeatures => 'Features';

  @override
  String get descSettingsSectionFeatures =>
      'Explore all features and security tools';

  @override
  String get titleFeaturesHeader => 'SreerajP Journal Vault Features';

  @override
  String get descFeaturesHeader =>
      'Zero-leak offline architecture, military-grade encryption, and expressive journaling.';

  @override
  String descEntryWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String descEntryCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chars',
      one: '1 char',
    );
    return '$_temp0';
  }

  @override
  String descEntryStats(String words, String chars) {
    return '$words • $chars';
  }

  @override
  String get actionEntryDistractionFreeEnter => 'Focus mode';

  @override
  String get actionEntryDistractionFreeExit => 'Exit focus mode';

  @override
  String get descEntryFocusParagraphOn => 'Focus paragraph: on';

  @override
  String get descEntryFocusParagraphOff => 'Focus paragraph: off';

  @override
  String get labelEntryAutoSaving => 'Saving…';

  @override
  String labelEntryAutoSaved(String time) {
    return 'Saved at $time';
  }

  @override
  String get labelEntryAutoSavedJustNow => 'Saved just now';

  @override
  String get labelEntryUnsavedChanges => 'Unsaved changes';

  @override
  String get tooltipEntryEditorScanText => 'Scan text from image';

  @override
  String get labelEntryEditorScanSourceCamera => 'Take photo';

  @override
  String get labelEntryEditorScanSourceGallery => 'Choose from gallery';

  @override
  String get descEntryEditorOcrScanning => 'Scanning text from image...';

  @override
  String get descEntryEditorOcrNoTextFound =>
      'No text was detected in the image.';

  @override
  String get errorEntryEditorOcr => 'Failed to scan text from image.';

  @override
  String get titleEntryEditorCropImage => 'Crop Image';

  @override
  String get errorEntryEditorCropImage => 'Could not process image crop.';

  @override
  String get titleAppearanceThemeMode => 'Theme Mode';

  @override
  String get descAppearanceThemeMode =>
      'Choose System, Dark, or Light appearance';

  @override
  String get titleAppearanceAccentColor => 'Accent Color';

  @override
  String get descAppearanceAccentColor => 'Select primary brand color palette';

  @override
  String get titleAppearanceLivePreview => 'Live Preview';

  @override
  String get tabAppearancePresets => 'Presets';

  @override
  String get tabAppearanceCustomWheel => 'Custom Color Wheel';

  @override
  String get labelAppearanceSampleText => 'Sample Journal Entry';

  @override
  String get actionAppearanceResetDefault => 'Reset to Default';

  @override
  String get descAppearanceContrastNote =>
      'Text contrast is adjusted automatically for readability.';

  @override
  String get descAppearanceSystemModeExplainer =>
      'System mode automatically follows your device\'s system-wide dark mode setting.';

  @override
  String get labelSettingsThemeSepia => 'Paper / Sepia';

  @override
  String get labelSettingsThemeOled => 'OLED / True Black';

  @override
  String get descSettingsThemeSepia =>
      'Warm parchment paper tone that is soothing for long writing sessions.';

  @override
  String get descSettingsThemeOled =>
      'Pure pitch black background with crisp contrast for AMOLED battery saving.';

  @override
  String get descSettingsThemeLight =>
      'Clean and bright daylight reading surface.';

  @override
  String get descSettingsThemeDark =>
      'Soft charcoal dark background for low-light writing.';

  @override
  String get descSettingsThemeSystem =>
      'Automatically follows your device system brightness preference.';

  @override
  String get titleAppearanceTypography => 'Reading Typography';

  @override
  String get descAppearanceTypography =>
      'Customize body font family and reading size';

  @override
  String get titleAppearanceFontFamily => 'Body Font Family';

  @override
  String get titleAppearanceFontSize => 'Body Font Size';

  @override
  String get labelAppearanceFontFamilySans => 'Sans-Serif';

  @override
  String get descAppearanceFontFamilySans =>
      'Clean and contemporary modern typeface';

  @override
  String get labelAppearanceFontFamilySerif => 'Book Serif';

  @override
  String get descAppearanceFontFamilySerif =>
      'Classic editorial and literary book feel';

  @override
  String get labelAppearanceFontFamilyMonospace => 'Monospace';

  @override
  String get descAppearanceFontFamilyMonospace =>
      'Fixed-width typewriter and Markdown aesthetic';

  @override
  String get labelAppearanceFontSizeSmall => 'Small';

  @override
  String get labelAppearanceFontSizeDefault => 'Default';

  @override
  String get labelAppearanceFontSizeMedium => 'Medium';

  @override
  String get labelAppearanceFontSizeLarge => 'Large';

  @override
  String get labelAppearanceFontSizeExtraLarge => 'X-Large';

  @override
  String get labelAppearanceSampleHeadline => 'Quiet Reflections';

  @override
  String get bodyAppearanceSample =>
      'The journal is a quiet space to slow down and reflect. Every thought, memory, and sketch is securely preserved in your private vault.';

  @override
  String get bodyAppearanceTypographyReset => 'Typography reset to default.';

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
  String get tooltipEditorInsertDrawing => 'Drawing canvas';

  @override
  String get titleDrawingCanvas => 'Drawing & Sketch';

  @override
  String get titleDrawingCanvasEdit => 'Edit Drawing';

  @override
  String get labelDrawingCanvasPen => 'Pen';

  @override
  String get labelDrawingCanvasHighlighter => 'Highlighter';

  @override
  String get labelDrawingCanvasEraser => 'Eraser';

  @override
  String get actionDrawingCanvasClear => 'Clear canvas';

  @override
  String get bodyDrawingCanvasClear => 'Clear the entire drawing?';

  @override
  String get labelDrawingCanvasStrokeWidth => 'Stroke width';

  @override
  String get labelDrawingCanvasBackground => 'Background';

  @override
  String get labelDrawingCanvasBgBlank => 'Blank';

  @override
  String get labelDrawingCanvasBgRuled => 'Ruled';

  @override
  String get labelDrawingCanvasBgGrid => 'Grid';

  @override
  String get labelDrawingCanvasBgDots => 'Dots';

  @override
  String get actionDrawingCanvasUndo => 'Undo';

  @override
  String get actionDrawingCanvasRedo => 'Redo';

  @override
  String get actionDrawingCanvasSave => 'Save drawing';

  @override
  String get bodyDrawingCanvasDiscard => 'Discard changes?';

  @override
  String get bodyDrawingCanvasDiscardMessage =>
      'Are you sure you want to discard your drawing changes?';

  @override
  String get tooltipDrawingEdit => 'Edit drawing';

  @override
  String get tooltipDrawingSize => 'Resize drawing';

  @override
  String get tooltipDrawingDelete => 'Delete drawing';

  @override
  String get descDrawingUnavailable => 'Drawing unavailable';

  @override
  String get descDrawingLoading => 'Loading drawing…';

  @override
  String get errorDrawingSave => 'Could not save drawing.';

  @override
  String get actionJournalManageTemplates => 'Custom Templates';

  @override
  String get helpTitle => 'Help';

  @override
  String get titleFeatures => 'Features';

  @override
  String get bodyFeatureOffline => '100% Offline & Zero Network Permission';

  @override
  String get descFeatureOffline =>
      'The application contains zero network access code, requests no internet permissions, and keeps all journal data, attachments, and encryption strictly offline.';

  @override
  String get titleRitual => 'Ritual Practice';

  @override
  String get titleRitualDeckBrowser => 'Reflection Deck';

  @override
  String get tooltipRitualResetReviews => 'Reset SRS intervals';

  @override
  String get titleRitualResetReviews => 'Reset reviews';

  @override
  String get bodyRitualResetReviews =>
      'This will reset review levels and next review dates for all cards. Continue?';

  @override
  String get bodyRitualResetReviewsDone => 'Card review intervals reset.';

  @override
  String get labelRitualAllThemes => 'All Themes';

  @override
  String get labelRitualSrsNew => 'New';

  @override
  String get labelRitualSrsDueToday => 'Due Today';

  @override
  String labelRitualSrsInDays(int days) {
    return 'In ${days}d';
  }

  @override
  String get labelRitualStepBreathe => 'Breathe';

  @override
  String get labelRitualStepReflect => 'Reflect';

  @override
  String get labelRitualStepWrite => 'Write';

  @override
  String get titleRitualBreathe => 'Centering Breath';

  @override
  String get actionRitualSkipToPrompt => 'Skip to Prompt';

  @override
  String get actionRitualContinueToCard => 'Continue';

  @override
  String get actionRitualShuffleCard => 'Shuffle';

  @override
  String get bodyRitualSrsRatePrompt =>
      'HOW MEMORABLE / EASY WAS THIS REFLECTION?';

  @override
  String get actionRitualSrsHard => 'Hard';

  @override
  String get descRitualSrsHard => 'Review in 1d';

  @override
  String get actionRitualSrsRevision => 'Revision';

  @override
  String get descRitualSrsRevision => 'Review in 3d';

  @override
  String get actionRitualSrsEasy => 'Easy';

  @override
  String get descRitualSrsEasy => '+7 days';

  @override
  String get actionRitualProceedToJournal => 'Proceed to Journal';

  @override
  String get titleRitualReadyToWrite => 'Ready to Reflect';

  @override
  String descRitualReadyToWrite(String cardTitle) {
    return 'Write your thoughts into today\'s journal entry inspired by \"$cardTitle\".';
  }

  @override
  String get actionRitualBeginWriting => 'Begin Journaling';

  @override
  String get actionRitualCompletePracticeOnly => 'Finish practice';

  @override
  String get titleRitualSettings => 'Ritual Mode Settings';

  @override
  String get titleRitualLaunchOnStartup => 'Open in Ritual Mode';

  @override
  String get descRitualLaunchOnStartup =>
      'Begin every session with a guided breath and reflection prompt';

  @override
  String get labelRitualBreathTechnique => 'Breathing Technique';

  @override
  String labelRitualBreathCycles(int count) {
    return 'Breathing Cycles: $count';
  }

  @override
  String get actionCommonReset => 'Reset';

  @override
  String get titleRitualSettingsTile => 'Ritual mode';

  @override
  String get descRitualSettingsTile =>
      'Guided breath timer, 50-card Sanathana Dharma deck & spaced repetition';

  @override
  String get titleFeatureRitual => 'Ritual Mode & Reflection Cards';

  @override
  String get descFeatureRitual =>
      'A guided daily practice that calms your mind with a breath timer, surfaces rotating prompt cards with Anki-style spaced repetition, and opens directly to today\'s entry.';

  @override
  String get titleSyncLanding => 'Device sync';

  @override
  String get descSyncLanding =>
      'Sync entries and attachments directly over local Wi-Fi with no cloud servers';

  @override
  String get titleSyncSend => 'Send Changes (Host)';

  @override
  String get descSyncSend =>
      'Display a pairing QR code to share journal entries and attachments with another device';

  @override
  String get titleSyncReceive => 'Receive changes';

  @override
  String get descSyncReceive =>
      'Scan a pairing QR code or enter connection details to receive updates';

  @override
  String get titleSyncHost => 'Host Wi-Fi Sync';

  @override
  String get titleSyncClient => 'Receive Wi-Fi Sync';

  @override
  String get tabSyncTabQrScan => 'Scan QR';

  @override
  String get tabSyncTabManualEntry => 'Manual Details';

  @override
  String get labelSyncIp => 'Local IP Address';

  @override
  String get labelSyncPort => 'Port';

  @override
  String get labelSyncPairingCode => 'Pairing Code';

  @override
  String get labelSyncPairingCodeHint => 'XXXX-XXXX-XXXX-XXXX';

  @override
  String get descSyncStatusListening => 'Waiting for incoming connection...';

  @override
  String get labelSyncStatusConnected => 'Device connected';

  @override
  String get descSyncStatusCompleted => 'Sync completed successfully!';

  @override
  String get errorSyncStatusDenied =>
      'Connection rejected: incorrect pairing code';

  @override
  String get labelSyncStatusStopped => 'Sync server stopped';

  @override
  String get errorSyncStatusError => 'Sync server error';

  @override
  String get actionSyncButtonStart => 'Start Server';

  @override
  String get actionSyncButtonStop => 'Stop Server';

  @override
  String get actionSyncButtonConnect => 'Connect & Sync';

  @override
  String get descSyncScanInstructions =>
      'Point your camera at the pairing QR code on the sending device';

  @override
  String get descSyncHostAddress => 'e.g. 192.168.1.5';

  @override
  String get descSyncPort => 'e.g. 54321';

  @override
  String get descSyncCode => '16-character pairing code';

  @override
  String get descSyncNoWifiAlert =>
      'No Wi-Fi / LAN IP detected. Make sure both devices are on the same Wi-Fi network or hotspot.';

  @override
  String get bodySyncPairingCodeCopied => 'Pairing code copied to clipboard';

  @override
  String get titleAirqr => 'AirQR sync';

  @override
  String get descAirqrIntro =>
      'Synchronize settings, small journals, and entries over light using animated QR codes without network connections.';

  @override
  String get titleAirqrSend => 'Send via AirQR';

  @override
  String get titleAirqrReceive => 'Receive via AirQR';

  @override
  String get actionAirqrReceive => 'Receive data';

  @override
  String get descAirqrReceive => 'Scan animated QR frames from another device';

  @override
  String get titleAirqrSyncSettings => 'Sync App Settings';

  @override
  String get descAirqrSyncSettings =>
      'Theme, accent color, security, ritual & templates (< 1 sec)';

  @override
  String get titleAirqrSyncJournal => 'Sync Single Journal';

  @override
  String get descAirqrSyncJournal =>
      'Select and stream a journal with text entries';

  @override
  String get titleAirqrTooLarge => 'Payload Too Large';

  @override
  String get titleAirqrSlow => 'Large transfer';

  @override
  String get actionAirqrSendAnyway => 'Send Anyway';

  @override
  String get titleAirqrSpeedNote => 'Offline and private';

  @override
  String get bodyAirqrSpeedNote =>
      'AirQR works purely via camera and screen. No Wi-Fi, hotspot, Bluetooth, or internet required.';

  @override
  String get actionTimeCapsuleActionSeal => 'Seal as Time Capsule';

  @override
  String get titleTimeCapsuleSeal => 'Seal as Time Capsule';

  @override
  String get descTimeCapsuleSeal =>
      'Cryptographically seals this entry until a future date. The decryption key will not be released until that date arrives.';

  @override
  String get labelTimeCapsuleUnlockDate => 'Unlock Date';

  @override
  String get descTimeCapsuleTeaser => 'Note to future self (optional teaser)';

  @override
  String get actionTimeCapsulePreset1Month => '1 Month';

  @override
  String get actionTimeCapsulePreset6Months => '6 Months';

  @override
  String get actionTimeCapsulePreset1Year => '1 Year';

  @override
  String get actionTimeCapsulePreset3Years => '3 Years';

  @override
  String get actionTimeCapsulePreset5Years => '5 Years';

  @override
  String get actionTimeCapsulePresetCustom => 'Custom Date';

  @override
  String get bodyTimeCapsuleSeal => 'Seal Capsule';

  @override
  String get labelTimeCapsuleSealedBadge => 'Sealed Time Capsule';

  @override
  String labelTimeCapsuleSealedUntil(String date) {
    return 'Sealed until $date';
  }

  @override
  String labelTimeCapsuleOpensInDays(int days) {
    return 'Opens in $days days';
  }

  @override
  String labelTimeCapsuleOpensInHours(int hours) {
    return 'Opens in $hours hours';
  }

  @override
  String get descTimeCapsuleOpensToday => 'Opens today!';

  @override
  String get actionTimeCapsuleReadyToOpen => 'Ready to Open';

  @override
  String get descTimeCapsuleLocked =>
      'This entry is cryptographically sealed under AES-256-GCM. The app\'s date-gated vault engine will not release the decryption key until the unlock date.';

  @override
  String get actionTimeCapsuleUnseal => 'Unseal Time Capsule';

  @override
  String actionTimeCapsuleUnsealLockedPrompt(String date) {
    return 'Locked until $date';
  }

  @override
  String bodyTimeCapsuleSealedSuccess(String date) {
    return 'Entry sealed into a time capsule until $date.';
  }

  @override
  String get bodyTimeCapsuleUnsealedSuccess =>
      'Time capsule successfully unsealed! Welcome back to your words.';

  @override
  String get errorTimeCapsuleClockTamper =>
      'Device clock rollback detected. The capsule cannot be unlocked while the device time is behind the recorded seal timestamp.';

  @override
  String get titleTimeCapsule => 'Time Capsules';

  @override
  String get descTimeCapsule =>
      'Letters and entries sealed for your future self';

  @override
  String get emptyTimeCapsule =>
      'No time capsules yet. Create an entry and seal it for your future self.';

  @override
  String get bodyTimeCapsuleBanner => 'Time Capsule Ready!';

  @override
  String bodyTimeCapsuleBannerBody(int count) {
    return 'You have $count sealed capsule ready to open today.';
  }

  @override
  String descTimeCapsuleBannerBodyPlural(int count) {
    return 'You have $count sealed capsules ready to open today.';
  }

  @override
  String get titleTimeCapsuleCategorySealed => 'Sealed Capsules';

  @override
  String get titleTimeCapsuleCategoryReady => 'Ready to Open';

  @override
  String get titleTimeCapsuleCategoryOpened => 'Opened Capsules';

  @override
  String get titleRitualCreateCard => 'Create Card';

  @override
  String get titleRitualEditCard => 'Edit Card';

  @override
  String get actionRitualCreateCard => 'New Card';

  @override
  String get labelRitualCardTheme => 'Theme';

  @override
  String get labelRitualCardTitle => 'Title';

  @override
  String get descRitualCardTitle => 'e.g. The Light of Self-Knowledge';

  @override
  String get errorRitualCardTitle => 'A title is required.';

  @override
  String get labelRitualCardPrompt => 'Reflection Question';

  @override
  String get descRitualCardPrompt =>
      'A question to reflect upon during practice...';

  @override
  String get errorRitualCardPrompt => 'A reflection question is required.';

  @override
  String get labelRitualCardQuote => 'Teaching or Quote';

  @override
  String get descRitualCardQuote => 'A verse, shloka, or teaching...';

  @override
  String get errorRitualCardQuote => 'A teaching or quote is required.';

  @override
  String get labelRitualCardAuthor => 'Source (optional)';

  @override
  String get descRitualCardAuthor => 'e.g. Bhagavad Gita 2.47';

  @override
  String get labelRitualCardPreview => 'Preview';

  @override
  String get actionRitualSaveCardCreate => 'Create Card';

  @override
  String get actionRitualSaveCardEdit => 'Save Changes';

  @override
  String get bodyRitualCardCreated => 'Card created.';

  @override
  String get bodyRitualCardUpdated => 'Card updated.';

  @override
  String get errorRitualCardSave =>
      'Could not save the card. Please try again.';

  @override
  String get labelRitualUserCardBadge => 'MY CARD';

  @override
  String get actionRitualEditCard => 'Edit';

  @override
  String get actionRitualDeleteCard => 'Delete';

  @override
  String get titleRitualDeleteCard => 'Delete Card';

  @override
  String bodyRitualDeleteCard(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get bodyRitualCardDeleted => 'Card deleted.';

  @override
  String get errorRitualNoJournal => 'Please create a journal first.';

  @override
  String get actionEditorGotoLineStart => '⇤';

  @override
  String get actionEditorGotoLineEnd => '⇥';

  @override
  String get bodyOcrCameraPermissionDenied =>
      'Camera permission is required to photograph documents for text recognition.';

  @override
  String get actionOcrCameraOpenSettings => 'Open Settings';

  @override
  String get bodyOcrCameraNoCameras => 'No camera found on this device.';

  @override
  String get tooltipOcrCameraFlashOff => 'Flash off';

  @override
  String get tooltipOcrCameraFlashAuto => 'Flash auto';

  @override
  String get tooltipOcrCameraFlashOn => 'Flash on';

  @override
  String get tooltipOcrCameraFlashTorch => 'Torch on';

  @override
  String get tooltipOcrCameraGridToggle => 'Framing grid';

  @override
  String get tooltipOcrCameraSwitch => 'Switch camera';

  @override
  String get descOcrCameraCapture => 'Tap to focus • Pinch to zoom';

  @override
  String get actionOcrCameraCapture => 'Take photo';

  @override
  String get actionOcrCameraGallery => 'Choose from gallery';

  @override
  String get labelOcrCameraExposure => 'Exposure';

  @override
  String get labelOcrCameraZoom => 'Zoom';

  @override
  String get tooltipOcrCameraFocusAuto => 'Auto focus';

  @override
  String get tooltipOcrCameraFocusLocked => 'Focus locked';

  @override
  String get tooltipOcrCameraExposureAuto => 'Auto exposure';

  @override
  String get tooltipOcrCameraExposureLocked => 'Exposure locked';

  @override
  String get tooltipOcrCameraControls => 'Camera controls';

  @override
  String get actionOcrCameraReset => 'Reset';

  @override
  String get titleOcrEnhance => 'Enhance & Scan';

  @override
  String get tooltipOcrEnhanceRotateLeft => 'Rotate left';

  @override
  String get tooltipOcrEnhanceRotateRight => 'Rotate right';

  @override
  String get labelOcrEnhanceCrop => 'Crop';

  @override
  String get tabOcrEnhanceFilter => 'Filter';

  @override
  String get actionOcrEnhanceInvert => 'Invert';

  @override
  String get labelOcrEnhanceFilterOriginal => 'Original';

  @override
  String get labelOcrEnhanceFilterDocument => 'Document';

  @override
  String get labelOcrEnhanceFilterGrayscale => 'Grayscale';

  @override
  String get actionOcrEnhanceFilterEnhance => 'High Contrast';

  @override
  String get labelOcrEnhanceBrightness => 'Brightness';

  @override
  String get labelOcrEnhanceContrast => 'Contrast';

  @override
  String get tabOcrEnhanceAdjust => 'Adjust';

  @override
  String get titleOcrEnhanceLiveText => 'Text found';

  @override
  String get bodyOcrEnhanceLiveTextNone =>
      'No text detected yet. Try adjusting contrast, rotating, or cropping closer.';

  @override
  String descOcrEnhanceLiveWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words detected',
      one: '1 word detected',
    );
    return '$_temp0';
  }

  @override
  String get actionOcrEnhanceInsertText => 'Insert into Entry';

  @override
  String get actionOcrEnhanceRetake => 'Retake';

  @override
  String get bodyOcrEnhanceProcessing => 'Enhancing image...';

  @override
  String get bodyOcrEnhanceLiveScanning => 'Scanning text...';

  @override
  String get labelOcrLanguageAll => 'English + മലയാളം';

  @override
  String get labelOcrLanguageMalayalam => 'മലയാളം';

  @override
  String get labelOcrLanguageEnglish => 'English';

  @override
  String get tooltipOcrLanguageSelect => 'Select OCR language';

  @override
  String get titleLanguage => 'Language';

  @override
  String get labelLanguageSystemDefault => 'System default';

  @override
  String get descLanguageSystemDefault =>
      'Follows the phone\'s language, or English if the phone\'s language is not available.';

  @override
  String get labelLanguageEnglish => 'English';

  @override
  String get labelLanguageMalayalam => 'മലയാളം';

  @override
  String get labelLanguageSanskrit => 'संस्कृतम्';

  @override
  String labelLanguageCurrent(String language) {
    return 'Language: $language';
  }

  @override
  String get aboutDetailAuthor => 'Author';

  @override
  String get aboutDetailEmail => 'Email';

  @override
  String get aboutDetailLicense => 'License';

  @override
  String get aboutDetailAiUsed => 'AI used';

  @override
  String get aboutDetailIdeUsed => 'IDE used';

  @override
  String get bodyAboutBuildDateUnavailable => 'Build date unavailable';

  @override
  String madeWithLove(String heart) {
    return 'Made with $heart from India';
  }

  @override
  String get madeWithLoveA11y => 'Made with love from India';

  @override
  String get tooltipFilterEntries => 'Filter entries';

  @override
  String get tooltipSaveSearch => 'Save search';

  @override
  String get tooltipResetScanner => 'Reset scanner';

  @override
  String get tooltipToggleTorch => 'Toggle torch';

  @override
  String get tooltipSwitchCamera => 'Switch camera';

  @override
  String get tooltipCopyPairingCode => 'Copy pairing code';

  @override
  String get tooltipSlower => 'Slower';

  @override
  String get tooltipFaster => 'Faster';

  @override
  String get tooltipRecordVoiceNote => 'Record voice note';

  @override
  String get tooltipStopRecording => 'Stop recording';

  @override
  String get tooltipMoreOptions => 'More options';

  @override
  String get tooltipShowDetails => 'Show details';

  @override
  String get tooltipRemove => 'Remove';

  @override
  String get descRitualCard01Title => 'Your Swadharma';

  @override
  String get descRitualCard01Prompt =>
      'What is the unique duty or calling that only you can fulfil in this season of your life? How are you honouring it today?';

  @override
  String get descRitualCard01Quote =>
      'It is better to perform one\'s own duty imperfectly than to perform another\'s duty perfectly.';

  @override
  String get descRitualCard01Source => 'Bhagavad Gita 3.35';

  @override
  String get descRitualCard02Title => 'Righteousness in the Small';

  @override
  String get descRitualCard02Prompt =>
      'In what small, everyday action today can you choose what is right over what is easy or popular?';

  @override
  String get descRitualCard02Quote =>
      'Dharma exists for the welfare of all beings. Hence, that by which the welfare of all living beings is sustained, that is Dharma.';

  @override
  String get descRitualCard02Source => 'Mahabharata, Shanti Parva 109.10';

  @override
  String get descRitualCard03Title => 'The Wheel of Dharma';

  @override
  String get descRitualCard03Prompt =>
      'Reflect on one relationship or responsibility you hold. Are you nurturing it with integrity, or have you been neglecting its call?';

  @override
  String get descRitualCard03Quote =>
      'When Dharma is protected, Dharma protects.';

  @override
  String get descRitualCard03Source => 'Manusmriti 8.15';

  @override
  String get descRitualCard04Title => 'The Eternal Order';

  @override
  String get descRitualCard04Prompt =>
      'Where in nature — the rising sun, the changing seasons, the flowing river — do you see the rhythm of Rta (cosmic order), and how does it mirror your own life?';

  @override
  String get descRitualCard04Quote =>
      'The rivers flow into the ocean but the ocean never overflows. Likewise, desires flow into the wise one, who remains ever at peace.';

  @override
  String get descRitualCard04Source => 'Bhagavad Gita 2.70';

  @override
  String get descRitualCard05Title => 'Dharma in Adversity';

  @override
  String get descRitualCard05Prompt =>
      'When life tests you, what principle or value do you refuse to compromise? Why does it matter to you?';

  @override
  String get descRitualCard05Quote =>
      'Even in the most difficult of times, one should not abandon Dharma.';

  @override
  String get descRitualCard05Source => 'Ramayana, Ayodhya Kanda';

  @override
  String get descRitualCard06Title => 'Action Without Attachment';

  @override
  String get descRitualCard06Prompt =>
      'What is one task or effort you are doing today where you can let go of the result and focus purely on the quality of your action?';

  @override
  String get descRitualCard06Quote =>
      'You have the right to perform your duty, but you are not entitled to the fruits of your actions.';

  @override
  String get descRitualCard06Source => 'Bhagavad Gita 2.47';

  @override
  String get descRitualCard07Title => 'The Seed You Plant Today';

  @override
  String get descRitualCard07Prompt =>
      'Every action is a seed. What kind of seed — patience, kindness, discipline, or something else — are you planting today?';

  @override
  String get descRitualCard07Quote =>
      'As a man sows, so shall he reap. There is no escape from the fruits of one\'s actions.';

  @override
  String get descRitualCard07Source => 'Mahabharata, Vana Parva';

  @override
  String get descRitualCard08Title => 'Nishkama Karma';

  @override
  String get descRitualCard08Prompt =>
      'Think of something you did purely for its own sake, without wanting praise or reward. How did that feel? Can you bring that spirit to more of your day?';

  @override
  String get descRitualCard08Quote =>
      'The wise, engaged in selfless action, surrender all attachment to results and attain supreme peace.';

  @override
  String get descRitualCard08Source => 'Bhagavad Gita 5.12';

  @override
  String get descRitualCard09Title => 'Breaking the Chain';

  @override
  String get descRitualCard09Prompt =>
      'Is there a pattern of reaction — anger, avoidance, blame — that you keep repeating? What would it look like to consciously choose a different response today?';

  @override
  String get descRitualCard09Quote =>
      'One who restrains the senses and organs of action, but whose mind dwells on sense objects, is deluded and called a hypocrite.';

  @override
  String get descRitualCard09Source => 'Bhagavad Gita 3.6';

  @override
  String get descRitualCard10Title => 'Karma Yoga in Daily Life';

  @override
  String get descRitualCard10Prompt =>
      'How can you transform an ordinary task today — cooking, cleaning, working — into an offering, performing it with full attention and devotion?';

  @override
  String get descRitualCard10Quote =>
      'Whatever you do, whatever you eat, whatever you offer in sacrifice, whatever you give, whatever austerity you practise — do it as an offering to Me.';

  @override
  String get descRitualCard10Source => 'Bhagavad Gita 9.27';

  @override
  String get descRitualCard11Title => 'The Heart of Devotion';

  @override
  String get descRitualCard11Prompt =>
      'What fills your heart with reverence and love — a prayer, a memory, a place, the thought of the Divine? Dwell on it now.';

  @override
  String get descRitualCard11Quote =>
      'Whoever offers Me with devotion a leaf, a flower, a fruit, or water — that offering of love I accept from the pure-hearted.';

  @override
  String get descRitualCard11Source => 'Bhagavad Gita 9.26';

  @override
  String get descRitualCard12Title => 'Surrender and Trust';

  @override
  String get descRitualCard12Prompt =>
      'What worry or burden can you mentally place at the feet of the Divine today, trusting that grace will carry you through?';

  @override
  String get descRitualCard12Quote =>
      'Abandon all varieties of Dharma and simply surrender unto Me. I shall deliver you from all sinful reactions; do not fear.';

  @override
  String get descRitualCard12Source => 'Bhagavad Gita 18.66';

  @override
  String get descRitualCard13Title => 'Seeing God in All';

  @override
  String get descRitualCard13Prompt =>
      'Can you look at every person you meet today as a form of the Divine? How would that change the way you speak and listen?';

  @override
  String get descRitualCard13Quote =>
      'The wise see the same Divine Self equally in a learned Brahmin, a cow, an elephant, a dog, and an outcaste.';

  @override
  String get descRitualCard13Source => 'Bhagavad Gita 5.18';

  @override
  String get descRitualCard14Title => 'The Name that Purifies';

  @override
  String get descRitualCard14Prompt =>
      'When was the last time you sat quietly and repeated a sacred name or mantra? What feelings arose when you did?';

  @override
  String get descRitualCard14Quote =>
      'The name of the Lord is the boat that will take you across the ocean of worldly existence.';

  @override
  String get descRitualCard14Source => 'Tulsidas, Ramcharitmanas';

  @override
  String get descRitualCard15Title => 'Grace in Gratitude';

  @override
  String get descRitualCard15Prompt =>
      'What unexpected blessing or moment of grace have you received recently that you have not yet paused to acknowledge?';

  @override
  String get descRitualCard15Quote =>
      'I am the origin of all. Everything emanates from Me. The wise who know this worship Me with loving devotion.';

  @override
  String get descRitualCard15Source => 'Bhagavad Gita 10.8';

  @override
  String get descRitualCard16Title => 'Who Am I?';

  @override
  String get descRitualCard16Prompt =>
      'Strip away your name, your job, your roles, your body. What remains? Sit with this question: Who am I beyond all labels?';

  @override
  String get descRitualCard16Quote => 'Tat Tvam Asi — Thou art That.';

  @override
  String get descRitualCard16Source => 'Chandogya Upanishad 6.8.7';

  @override
  String get descRitualCard17Title => 'The Eternal Witness';

  @override
  String get descRitualCard17Prompt =>
      'Observe your thoughts passing by without grasping any of them. Who is the one watching? Can that awareness itself ever be harmed?';

  @override
  String get descRitualCard17Quote =>
      'The Self is never born, nor does it die. It is eternal, ever-existing, and primeval. It is not slain when the body is slain.';

  @override
  String get descRitualCard17Source => 'Bhagavad Gita 2.20';

  @override
  String get descRitualCard18Title => 'Knowledge That Frees';

  @override
  String get descRitualCard18Prompt =>
      'What is one truth about yourself or about life that, once you truly accepted it, freed you from suffering?';

  @override
  String get descRitualCard18Quote =>
      'There is nothing as purifying in this world as knowledge. One who has attained purity of mind through prolonged Yoga discovers this knowledge within, in due course of time.';

  @override
  String get descRitualCard18Source => 'Bhagavad Gita 4.38';

  @override
  String get descRitualCard19Title => 'Beyond the Senses';

  @override
  String get descRitualCard19Prompt =>
      'Your senses show you the surface of things. What deeper truth lies beneath the situation you are facing right now?';

  @override
  String get descRitualCard19Quote =>
      'Beyond the senses are the objects; beyond the objects is the mind; beyond the mind is the intellect; beyond the intellect is the Great Self.';

  @override
  String get descRitualCard19Source => 'Katha Upanishad 1.3.10';

  @override
  String get descRitualCard20Title => 'The Light Within';

  @override
  String get descRitualCard20Prompt =>
      'Close your eyes. Imagine a steady flame burning in your heart that no wind can extinguish. What does this light illuminate for you?';

  @override
  String get descRitualCard20Quote =>
      'Asato ma sadgamaya, tamaso ma jyotirgamaya, mrityorma amritam gamaya. Lead me from the unreal to the Real, from darkness to Light, from death to Immortality.';

  @override
  String get descRitualCard20Source => 'Brihadaranyaka Upanishad 1.3.28';

  @override
  String get descRitualCard21Title => 'The Fullness of Being';

  @override
  String get descRitualCard21Prompt =>
      'If you lack nothing at the deepest level, why do you feel incomplete? Reflect on what it means to be already whole.';

  @override
  String get descRitualCard21Quote =>
      'Om Purnamadah Purnamidam — That is Whole, this is Whole. From the Whole, the Whole arises. When the Whole is taken from the Whole, the Whole still remains.';

  @override
  String get descRitualCard21Source => 'Isha Upanishad, Invocation';

  @override
  String get descRitualCard22Title => 'Brahman in Everything';

  @override
  String get descRitualCard22Prompt =>
      'The same consciousness that shines through you shines through every living being. How does this awareness change the way you see the world today?';

  @override
  String get descRitualCard22Quote => 'Aham Brahmasmi — I am Brahman.';

  @override
  String get descRitualCard22Source => 'Brihadaranyaka Upanishad 1.4.10';

  @override
  String get descRitualCard23Title => 'Stilling the Mind';

  @override
  String get descRitualCard23Prompt =>
      'Right now, observe the fluctuations of your mind — planning, worrying, remembering. Can you gently bring all of them to stillness, even for a few breaths?';

  @override
  String get descRitualCard23Quote =>
      'Yogas chitta vritti nirodhah — Yoga is the cessation of the fluctuations of the mind.';

  @override
  String get descRitualCard23Source => 'Yoga Sutras of Patanjali 1.2';

  @override
  String get descRitualCard24Title => 'Steady Practice';

  @override
  String get descRitualCard24Prompt =>
      'What is one positive habit or practice you can commit to with patience and devotion, knowing that consistency matters more than intensity?';

  @override
  String get descRitualCard24Quote =>
      'Abhyasa — practice becomes firmly grounded when it is pursued for a long time, without interruption, and with sincere devotion.';

  @override
  String get descRitualCard24Source => 'Yoga Sutras of Patanjali 1.14';

  @override
  String get descRitualCard25Title => 'Evenness of Mind';

  @override
  String get descRitualCard25Prompt =>
      'Recall a recent moment of success and a moment of failure. Can you hold both with the same steady awareness, without elation or despair?';

  @override
  String get descRitualCard25Quote =>
      'Yoga is equanimity of mind — samatvam yoga uchyate.';

  @override
  String get descRitualCard25Source => 'Bhagavad Gita 2.48';

  @override
  String get descRitualCard26Title => 'The Five Yamas';

  @override
  String get descRitualCard26Prompt =>
      'Non-violence, truthfulness, non-stealing, moderation, non-possessiveness — which of the five Yamas is the hardest for you right now, and why?';

  @override
  String get descRitualCard26Quote =>
      'Ahimsa, Satya, Asteya, Brahmacharya, Aparigraha — these are the great universal vows.';

  @override
  String get descRitualCard26Source => 'Yoga Sutras of Patanjali 2.30';

  @override
  String get descRitualCard27Title => 'Ishvara Pranidhana';

  @override
  String get descRitualCard27Prompt =>
      'What does it feel like to offer your effort completely — not to achieve, but to dedicate? Try offering your next action to something greater than yourself.';

  @override
  String get descRitualCard27Quote =>
      'By total surrender to Ishvara, Samadhi is attained.';

  @override
  String get descRitualCard27Source => 'Yoga Sutras of Patanjali 2.45';

  @override
  String get descRitualCard28Title => 'Non-Violence in Thought';

  @override
  String get descRitualCard28Prompt =>
      'Have you directed harsh, violent thoughts towards yourself or someone else today? What would it mean to replace them with understanding?';

  @override
  String get descRitualCard28Quote =>
      'Ahimsa Paramo Dharma — Non-violence is the highest Dharma.';

  @override
  String get descRitualCard28Source => 'Mahabharata, Anushasana Parva 116.38';

  @override
  String get descRitualCard29Title => 'Compassion for All Beings';

  @override
  String get descRitualCard29Prompt =>
      'Think of a creature — an animal, an insect, a bird — you encountered recently. What would the world be like if you extended the same care to all living beings?';

  @override
  String get descRitualCard29Quote =>
      'One who sees all beings in the Self and the Self in all beings, never turns away from it.';

  @override
  String get descRitualCard29Source => 'Isha Upanishad, Verse 6';

  @override
  String get descRitualCard30Title => 'Gentle Speech';

  @override
  String get descRitualCard30Prompt =>
      'Before you speak today, pause and ask: Is it true? Is it kind? Is it necessary? How does this filter change your conversations?';

  @override
  String get descRitualCard30Quote =>
      'Words that do not cause distress, that are truthful, pleasant, and beneficial — this is called the austerity of speech.';

  @override
  String get descRitualCard30Source => 'Bhagavad Gita 17.15';

  @override
  String get descRitualCard31Title => 'Forgiving the Hurt';

  @override
  String get descRitualCard31Prompt =>
      'Who has caused you pain that you are still carrying? What would it take to forgive — not for them, but to free your own heart?';

  @override
  String get descRitualCard31Quote =>
      'Forgiveness is the ornament of the brave.';

  @override
  String get descRitualCard31Source => 'Mahabharata, Udyoga Parva 33.48';

  @override
  String get descRitualCard32Title => 'Living in Truth';

  @override
  String get descRitualCard32Prompt =>
      'Is there something in your life where you are being less than truthful — with yourself or with others? What would honest alignment look like?';

  @override
  String get descRitualCard32Quote =>
      'Satyameva Jayate — Truth alone triumphs.';

  @override
  String get descRitualCard32Source => 'Mundaka Upanishad 3.1.6';

  @override
  String get descRitualCard33Title => 'The Courage of Honesty';

  @override
  String get descRitualCard33Prompt =>
      'What is one truth you have been avoiding because it is uncomfortable? What would it take to face it with courage today?';

  @override
  String get descRitualCard33Quote =>
      'Speak the truth. Practise Dharma. Do not neglect the study of the scriptures.';

  @override
  String get descRitualCard33Source => 'Taittiriya Upanishad 1.11.1';

  @override
  String get descRitualCard34Title => 'Truth Beyond Words';

  @override
  String get descRitualCard34Prompt =>
      'Truth is not only in what you say, but in what you do. Are your actions today aligned with the truth you hold in your heart?';

  @override
  String get descRitualCard34Quote =>
      'By truthfulness, man reaches the station of God.';

  @override
  String get descRitualCard34Source => 'Chanakya Niti 14.3';

  @override
  String get descRitualCard35Title => 'The Promise You Keep';

  @override
  String get descRitualCard35Prompt =>
      'What is a promise you have made — to yourself, to another, or to the Divine — that you must honour? Recommit to it now.';

  @override
  String get descRitualCard35Quote =>
      'Let your word be your bond. A person who breaks a promise breaks trust, and trust once broken is hard to rebuild.';

  @override
  String get descRitualCard35Source => 'Vidura Niti, Mahabharata';

  @override
  String get descRitualCard36Title => 'Letting Go';

  @override
  String get descRitualCard36Prompt =>
      'What possession, expectation, or desire are you clinging to that no longer serves your growth? Imagine gently releasing it.';

  @override
  String get descRitualCard36Quote =>
      'Vairagya is the mastery of consciousness in which one is free from craving for sense objects, whether experienced directly or described.';

  @override
  String get descRitualCard36Source => 'Yoga Sutras of Patanjali 1.15';

  @override
  String get descRitualCard37Title => 'The Unchanging Self';

  @override
  String get descRitualCard37Prompt =>
      'Everything around you changes — moods, fortunes, relationships. What part of you has remained unchanged through all of life\'s storms?';

  @override
  String get descRitualCard37Quote =>
      'That which is not real never was and never will be. That which is real always was and can never cease to be.';

  @override
  String get descRitualCard37Source => 'Bhagavad Gita 2.16';

  @override
  String get descRitualCard38Title => 'Contentment';

  @override
  String get descRitualCard38Prompt =>
      'What do you already have that is truly enough? Reflect on the difference between want and need in your life right now.';

  @override
  String get descRitualCard38Quote =>
      'From contentment comes unsurpassed happiness.';

  @override
  String get descRitualCard38Source => 'Yoga Sutras of Patanjali 2.42';

  @override
  String get descRitualCard39Title => 'Beyond Pleasure and Pain';

  @override
  String get descRitualCard39Prompt =>
      'Can you sit with discomfort without fleeing, and with pleasure without grasping? What happens when you simply observe both?';

  @override
  String get descRitualCard39Quote =>
      'One who is not disturbed by happiness and distress and is steady in both is certainly eligible for liberation.';

  @override
  String get descRitualCard39Source => 'Bhagavad Gita 2.15';

  @override
  String get descRitualCard40Title => 'The Joy of Giving';

  @override
  String get descRitualCard40Prompt =>
      'What can you give today — time, attention, a kind word, a helping hand — without expecting anything in return?';

  @override
  String get descRitualCard40Quote =>
      'The highest form of charity is helping those who are helpless.';

  @override
  String get descRitualCard40Source => 'Thirukkural 221';

  @override
  String get descRitualCard41Title => 'Serving the Divine in Others';

  @override
  String get descRitualCard41Prompt =>
      'If the person standing in front of you were God in disguise, how would you treat them? Try living this for the next hour.';

  @override
  String get descRitualCard41Quote => 'Service to humanity is service to God.';

  @override
  String get descRitualCard41Source => 'Swami Vivekananda';

  @override
  String get descRitualCard42Title => 'Selfless Work';

  @override
  String get descRitualCard42Prompt =>
      'Recall a time when you helped someone and felt a quiet, deep joy that had nothing to do with recognition. What did that teach you?';

  @override
  String get descRitualCard42Quote =>
      'Arise, awake, and stop not till the goal is reached.';

  @override
  String get descRitualCard42Source =>
      'Katha Upanishad 1.3.14 / Swami Vivekananda';

  @override
  String get descRitualCard43Title => 'Vasudhaiva Kutumbakam';

  @override
  String get descRitualCard43Prompt =>
      'The whole world is one family. What is one step you can take today to live as though every person\'s well-being matters to you?';

  @override
  String get descRitualCard43Quote =>
      'Vasudhaiva Kutumbakam — the entire world is one family.';

  @override
  String get descRitualCard43Source => 'Maha Upanishad 6.71';

  @override
  String get descRitualCard44Title => 'The Wealth of Kindness';

  @override
  String get descRitualCard44Prompt =>
      'What small act of kindness did someone do for you that you still remember? How can you pass that same kindness forward today?';

  @override
  String get descRitualCard44Quote =>
      'Even the poverty of the poor will depart if they give, with compassion, even what little they have.';

  @override
  String get descRitualCard44Source => 'Thirukkural 247';

  @override
  String get descRitualCard45Title => 'The Peace Within';

  @override
  String get descRitualCard45Prompt =>
      'Close your eyes and take three slow breaths. Feel the silence between each breath. That silence is who you truly are. Can you carry it through the day?';

  @override
  String get descRitualCard45Quote =>
      'For one who has conquered the mind, the mind is the best of friends; but for one who has failed to do so, the mind will remain the greatest enemy.';

  @override
  String get descRitualCard45Source => 'Bhagavad Gita 6.6';

  @override
  String get descRitualCard46Title => 'Equanimity in Praise and Blame';

  @override
  String get descRitualCard46Prompt =>
      'Recall a recent praise and a recent criticism you received. Can you hold both with the same calm composure, without clinging to one or rejecting the other?';

  @override
  String get descRitualCard46Quote =>
      'One who is the same to friend and foe, in honour and dishonour, in heat and cold, in pleasure and pain, and is free from attachment — such a person is dear to Me.';

  @override
  String get descRitualCard46Source => 'Bhagavad Gita 12.18–19';

  @override
  String get descRitualCard47Title => 'The Lotus in Mud';

  @override
  String get descRitualCard47Prompt =>
      'A lotus blooms in muddy water yet remains unstained. What is the muddy situation in your life right now, and how can you remain untouched by it while still growing?';

  @override
  String get descRitualCard47Quote =>
      'One who performs actions without attachment, surrendering them to Brahman, is untouched by sin, like a lotus leaf by water.';

  @override
  String get descRitualCard47Source => 'Bhagavad Gita 5.10';

  @override
  String get descRitualCard48Title => 'Om Shanti';

  @override
  String get descRitualCard48Prompt =>
      'Sit still and repeat Om Shanti three times — peace in body, peace in mind, peace in spirit. What disturbance melts away as you do this?';

  @override
  String get descRitualCard48Quote =>
      'Om Shantih Shantih Shantih — Om, Peace, Peace, Peace.';

  @override
  String get descRitualCard48Source => 'Upanishadic Shanti Mantra';

  @override
  String get descRitualCard49Title => 'May All Be Happy';

  @override
  String get descRitualCard49Prompt =>
      'Silently wish well-being for yourself, then for your loved ones, then for strangers, then for all beings. Notice how your heart expands as the circle widens.';

  @override
  String get descRitualCard49Quote =>
      'Sarve bhavantu sukhinah, sarve santu niramayah. Sarve bhadrani pashyantu, ma kashchit duhkhabhag bhavet. — May all be happy, may all be free from disease, may all see auspiciousness, may none suffer.';

  @override
  String get descRitualCard49Source => 'Upanishadic Prayer';

  @override
  String get descRitualCard50Title => 'Strength and Peace Together';

  @override
  String get descRitualCard50Prompt =>
      'True strength does not come from tension; it comes from deep inner peace. Where in your life can you replace force with calm resolve today?';

  @override
  String get descRitualCard50Quote =>
      'Strength is life, weakness is death. Strength is the medicine, strength is the cure. Strength, strength is what the Upanishads preach.';

  @override
  String get descRitualCard50Source => 'Swami Vivekananda';

  @override
  String get labelRitualThemeDharma => 'Dharma';

  @override
  String get labelRitualThemeKarma => 'Karma';

  @override
  String get labelRitualThemeBhakti => 'Bhakti';

  @override
  String get labelRitualThemeJnana => 'Jnana';

  @override
  String get labelRitualThemeYoga => 'Yoga';

  @override
  String get labelRitualThemeAhimsa => 'Ahimsa';

  @override
  String get labelRitualThemeSathya => 'Sathya';

  @override
  String get labelRitualThemeVairagya => 'Vairagya';

  @override
  String get labelRitualThemeSeva => 'Seva';

  @override
  String get labelRitualThemeShanti => 'Shanti';

  @override
  String get labelBreathTechniqueBox => 'Box breathing';

  @override
  String get labelBreathTechniqueRelaxing => 'Relaxing breath';

  @override
  String get labelBreathTechniqueCalm => 'Calm rhythm';

  @override
  String get labelBreathPhaseInhale => 'Inhale';

  @override
  String get labelBreathPhaseHold => 'Hold';

  @override
  String get labelBreathPhaseExhale => 'Exhale';

  @override
  String get labelBreathPhaseRest => 'Hold & rest';

  @override
  String get descBreathGuidanceInhale =>
      'Breathe in slowly through your nose...';

  @override
  String get descBreathGuidanceHold => 'Hold gently at the top...';

  @override
  String get descBreathGuidanceExhale => 'Release slowly and completely...';

  @override
  String get descBreathGuidanceRest => 'Rest in quiet stillness...';

  @override
  String get bodyBreathPracticeCompleted => 'Breathing practice completed';

  @override
  String bodyBreathPhaseRemaining(String phase, int seconds) {
    return '$phase, $seconds seconds remaining';
  }

  @override
  String get titleBreathGrounded => 'Grounded & present';

  @override
  String labelBreathCycle(int current, int total) {
    return 'Cycle $current of $total';
  }

  @override
  String get labelTemplateCategoryGeneral => 'Start fresh';

  @override
  String get labelTemplateCategoryReflective => 'Daily & reflective';

  @override
  String get labelTemplateCategoryThoughts => 'Thoughts & ideas';

  @override
  String get labelTemplateCategoryProjects => 'Projects & work';

  @override
  String get labelTemplateCategoryPeople => 'Relationships';

  @override
  String get labelTemplateCategoryHealth => 'Health & wellbeing';

  @override
  String get labelTemplateCategoryLearning => 'Learning & growth';

  @override
  String get labelTemplateCategoryCreative => 'Creative';

  @override
  String get labelTemplateCategoryPlanning => 'Planning';

  @override
  String get labelTemplateCategorySpecialty => 'Specialty';

  @override
  String get labelTemplateBlank => 'Blank';

  @override
  String get descTemplateBlank => 'Start with an empty entry.';

  @override
  String get labelTemplateDaily => 'Daily Reflection';

  @override
  String get descTemplateDaily =>
      'Highlights, gratitudes, and tomorrow\'s focus.';

  @override
  String get descTemplateDailyEntryTitle => 'Daily Reflection';

  @override
  String get bodyTemplateDaily =>
      'Highlights\n\nLowlights\n\nTomorrow\'s focus\n\n';

  @override
  String get labelTemplateTodayForMe => 'Today for Me';

  @override
  String get descTemplateTodayForMe =>
      'Did, thought, saw, encountered, felt, and learned today.';

  @override
  String get descTemplateTodayForMeEntryTitle => 'Today for Me';

  @override
  String get bodyTemplateTodayForMe =>
      'What I did today\n\nWhat I thought today\n\nWhat I saw today\n\nWhat I encountered today\n\nWhat I felt today\n\nWhat was taught to me today\n\n';

  @override
  String get labelTemplateEveningWindDown => 'Evening Wind-down';

  @override
  String get descTemplateEveningWindDown =>
      'Wins, struggles, one thing to let go of.';

  @override
  String get descTemplateEveningWindDownEntryTitle => 'Evening Wind-down';

  @override
  String get bodyTemplateEveningWindDown =>
      'Wins\n\nStruggles\n\nOne thing to let go of\n\n';

  @override
  String get labelTemplateMorningPages => 'Morning Pages';

  @override
  String get descTemplateMorningPages =>
      'Stream-of-consciousness brain dump to start the day.';

  @override
  String get descTemplateMorningPagesEntryTitle => 'Morning Pages';

  @override
  String get labelTemplateDayHighlight => 'Highlight of the Day';

  @override
  String get descTemplateDayHighlight =>
      'Single most memorable moment and why.';

  @override
  String get descTemplateDayHighlightEntryTitle => 'Highlight of the Day';

  @override
  String get bodyTemplateDayHighlight => 'The moment\n\nWhy it stood out\n\n';

  @override
  String get labelTemplateEnergyCheck => 'Energy Check';

  @override
  String get descTemplateEnergyCheck =>
      'Energy level, what drained it, what restored it.';

  @override
  String get descTemplateEnergyCheckEntryTitle => 'Energy Check';

  @override
  String get bodyTemplateEnergyCheck =>
      'Energy level (1-10): \n\nWhat drained it\n\nWhat restored it\n\n';

  @override
  String get labelTemplateMood => 'Mood Check-in';

  @override
  String get descTemplateMood =>
      'Note your current mood and what is shaping it.';

  @override
  String get descTemplateMoodEntryTitle => 'Mood Check-in';

  @override
  String get bodyTemplateMood =>
      'How I feel right now\n\nWhat is shaping it\n\n';

  @override
  String get labelTemplateThoughts => 'My Thoughts';

  @override
  String get descTemplateThoughts => 'Free-form reflection on a topic.';

  @override
  String get descTemplateThoughtsEntryTitle => 'My Thoughts';

  @override
  String get bodyTemplateThoughts => 'Topic\n\nMy thoughts\n\n';

  @override
  String get labelTemplateIdeaCapture => 'Idea Capture';

  @override
  String get descTemplateIdeaCapture => 'Idea, why it matters, next step.';

  @override
  String get descTemplateIdeaCaptureEntryTitle => 'Idea Capture';

  @override
  String get bodyTemplateIdeaCapture =>
      'The idea\n\nWhy it matters\n\nNext step\n\n';

  @override
  String get labelTemplateOpenQuestion => 'Open Question';

  @override
  String get descTemplateOpenQuestion =>
      'A question I am sitting with and current thinking.';

  @override
  String get descTemplateOpenQuestionEntryTitle => 'Open Question';

  @override
  String get bodyTemplateOpenQuestion =>
      'The question\n\nWhat I think so far\n\nWhat I still don\'t know\n\n';

  @override
  String get labelTemplateOpinion => 'Opinion / Hot Take';

  @override
  String get descTemplateOpinion => 'Belief, evidence for, evidence against.';

  @override
  String get descTemplateOpinionEntryTitle => 'Opinion / Hot Take';

  @override
  String get bodyTemplateOpinion =>
      'My belief\n\nEvidence for\n\nEvidence against\n\n';

  @override
  String get labelTemplateLessonsLearned => 'Lessons Learned';

  @override
  String get descTemplateLessonsLearned =>
      'What happened, what I learned, how I\'ll apply it.';

  @override
  String get descTemplateLessonsLearnedEntryTitle => 'Lessons Learned';

  @override
  String get bodyTemplateLessonsLearned =>
      'What happened\n\nWhat I learned\n\nHow I\'ll apply it\n\n';

  @override
  String get labelTemplateProjects => 'My Projects';

  @override
  String get descTemplateProjects => 'Project, status, blockers, next action.';

  @override
  String get descTemplateProjectsEntryTitle => 'My Projects';

  @override
  String get bodyTemplateProjects =>
      'Project\n\nStatus\n\nBlockers\n\nNext action\n\n';

  @override
  String get labelTemplateProjectUpdate => 'Project Update';

  @override
  String get descTemplateProjectUpdate => 'Progress, risks, decisions made.';

  @override
  String get descTemplateProjectUpdateEntryTitle => 'Project Update';

  @override
  String get bodyTemplateProjectUpdate =>
      'Progress\n\nRisks\n\nDecisions made\n\n';

  @override
  String get labelTemplateWeeklyReview => 'Weekly Review';

  @override
  String get descTemplateWeeklyReview => 'Wins, misses, focus for next week.';

  @override
  String get descTemplateWeeklyReviewEntryTitle => 'Weekly Review';

  @override
  String get bodyTemplateWeeklyReview =>
      'Wins\n\nMisses\n\nFocus for next week\n\n';

  @override
  String get labelTemplateGoalTracker => 'Goal Tracker';

  @override
  String get descTemplateGoalTracker =>
      'Goal, progress, obstacles, adjustments.';

  @override
  String get descTemplateGoalTrackerEntryTitle => 'Goal Tracker';

  @override
  String get bodyTemplateGoalTracker =>
      'Goal\n\nProgress\n\nObstacles\n\nAdjustments\n\n';

  @override
  String get labelTemplateDecisionLog => 'Decision Log';

  @override
  String get descTemplateDecisionLog =>
      'Decision, options considered, why I chose this.';

  @override
  String get descTemplateDecisionLogEntryTitle => 'Decision Log';

  @override
  String get bodyTemplateDecisionLog =>
      'The decision\n\nOptions considered\n\nWhy I chose this\n\n';

  @override
  String get labelTemplateStuckPoint => 'Stuck Point';

  @override
  String get descTemplateStuckPoint =>
      'Where I\'m stuck, what I\'ve tried, what to try next.';

  @override
  String get descTemplateStuckPointEntryTitle => 'Stuck Point';

  @override
  String get bodyTemplateStuckPoint =>
      'Where I\'m stuck\n\nWhat I\'ve tried\n\nWhat to try next\n\n';

  @override
  String get labelTemplateMeeting => 'Meeting Notes';

  @override
  String get descTemplateMeeting =>
      'Attendees, agenda, decisions, action items.';

  @override
  String get descTemplateMeetingEntryTitle => 'Meeting Notes';

  @override
  String get bodyTemplateMeeting =>
      'Attendees: \nAgenda\n\nDecisions\n\nAction items\n\n';

  @override
  String get labelTemplateConversationRecap => 'Conversation Recap';

  @override
  String get descTemplateConversationRecap =>
      'Who, what we discussed, follow-ups.';

  @override
  String get descTemplateConversationRecapEntryTitle => 'Conversation Recap';

  @override
  String get bodyTemplateConversationRecap =>
      'Who\n\nWhat we discussed\n\nFollow-ups\n\n';

  @override
  String get labelTemplateGratefulPeople => 'Grateful for people';

  @override
  String get descTemplateGratefulPeople => 'Person and a specific reason.';

  @override
  String get descTemplateGratefulPeopleEntryTitle => 'People I\'m Grateful For';

  @override
  String get bodyTemplateGratefulPeople => 'Person\n\nSpecific reason\n\n';

  @override
  String get labelTemplateUnsentLetter => 'Letter I Won\'t Send';

  @override
  String get descTemplateUnsentLetter => 'Unsent letter to process feelings.';

  @override
  String get descTemplateUnsentLetterEntryTitle => 'Unsent Letter';

  @override
  String get bodyTemplateUnsentLetter => 'Dear ...,\n\n\n\n— Me\n\n';

  @override
  String get labelTemplateRelationshipCheckin => 'Relationship check';

  @override
  String get descTemplateRelationshipCheckin =>
      'How a key relationship is going.';

  @override
  String get descTemplateRelationshipCheckinEntryTitle =>
      'Relationship Check-in';

  @override
  String get bodyTemplateRelationshipCheckin =>
      'Person\n\nHow it\'s going\n\nWhat needs attention\n\n';

  @override
  String get labelTemplateGratitude => 'Gratitude';

  @override
  String get descTemplateGratitude => 'Three things I am grateful for today.';

  @override
  String get descTemplateGratitudeEntryTitle => 'Gratitude';

  @override
  String get bodyTemplateGratitude =>
      'Three things I\'m grateful for\n\n1. \n2. \n3. \n';

  @override
  String get labelTemplateBodyCheckin => 'Body Check-in';

  @override
  String get descTemplateBodyCheckin =>
      'Sleep, food, movement, pain or tension.';

  @override
  String get descTemplateBodyCheckinEntryTitle => 'Body Check-in';

  @override
  String get bodyTemplateBodyCheckin =>
      'Sleep\n\nFood\n\nMovement\n\nPain or tension\n\n';

  @override
  String get labelTemplateMentalHealth => 'Mental Health Log';

  @override
  String get descTemplateMentalHealth => 'Mood, triggers, coping used.';

  @override
  String get descTemplateMentalHealthEntryTitle => 'Mental Health Log';

  @override
  String get bodyTemplateMentalHealth => 'Mood\n\nTriggers\n\nCoping used\n\n';

  @override
  String get labelTemplateHabitTracker => 'Habit Tracker';

  @override
  String get descTemplateHabitTracker => 'Habits done today and streak notes.';

  @override
  String get descTemplateHabitTrackerEntryTitle => 'Habit Tracker';

  @override
  String get bodyTemplateHabitTracker =>
      'Habits done today\n\nMissed today\n\nStreak notes\n\n';

  @override
  String get labelTemplateSleepLog => 'Sleep Log';

  @override
  String get descTemplateSleepLog => 'Hours, quality, dreams.';

  @override
  String get descTemplateSleepLogEntryTitle => 'Sleep Log';

  @override
  String get bodyTemplateSleepLog => 'Hours\n\nQuality\n\nDreams\n\n';

  @override
  String get labelTemplateTaughtToday => 'Taught to Me Today';

  @override
  String get descTemplateTaughtToday => 'Lesson, source, takeaway.';

  @override
  String get descTemplateTaughtTodayEntryTitle => 'Taught to Me Today';

  @override
  String get bodyTemplateTaughtToday => 'Lesson\n\nSource\n\nTakeaway\n\n';

  @override
  String get labelTemplateBookNotes => 'Book / Article Notes';

  @override
  String get descTemplateBookNotes => 'Title, key ideas, my reaction.';

  @override
  String get descTemplateBookNotesEntryTitle => 'Book / Article Notes';

  @override
  String get bodyTemplateBookNotes =>
      'Title: \nAuthor: \n\nKey ideas\n\nMy reaction\n\n';

  @override
  String get labelTemplateSkillPractice => 'Skill Practice';

  @override
  String get descTemplateSkillPractice =>
      'What I practiced, what improved, next focus.';

  @override
  String get descTemplateSkillPracticeEntryTitle => 'Skill Practice';

  @override
  String get bodyTemplateSkillPractice =>
      'Skill\n\nWhat I practiced\n\nWhat improved\n\nNext focus\n\n';

  @override
  String get labelTemplateMistakeLog => 'Mistake Log';

  @override
  String get descTemplateMistakeLog =>
      'What went wrong, root cause, prevention.';

  @override
  String get descTemplateMistakeLogEntryTitle => 'Mistake Log';

  @override
  String get bodyTemplateMistakeLog =>
      'What went wrong\n\nRoot cause\n\nPrevention\n\n';

  @override
  String get labelTemplateTopicDeepDive => 'Topic Deep Dive';

  @override
  String get descTemplateTopicDeepDive =>
      'Detailed study note on a concept, subject, or domain.';

  @override
  String get descTemplateTopicDeepDiveEntryTitle => 'Topic Deep Dive';

  @override
  String get bodyTemplateTopicDeepDive =>
      'Topic / Core Concept\n\nKey Principles & Overview\n\nDetailed Analysis & Notes\n\nKey Takeaways & References\n\nOpen Questions / Further Exploration\n\n';

  @override
  String get labelTemplateDreamJournal => 'Dream Journal';

  @override
  String get descTemplateDreamJournal =>
      'Dream details, emotions, possible meaning.';

  @override
  String get descTemplateDreamJournalEntryTitle => 'Dream Journal';

  @override
  String get bodyTemplateDreamJournal =>
      'Dream details\n\nEmotions\n\nPossible meaning\n\n';

  @override
  String get labelTemplateObservation => 'Observation Sketch';

  @override
  String get descTemplateObservation => 'Something I noticed in detail.';

  @override
  String get descTemplateObservationEntryTitle => 'Observation Sketch';

  @override
  String get bodyTemplateObservation => 'What I noticed\n\nDetails\n\n';

  @override
  String get labelTemplateQuoteOfDay => 'Quote of the Day';

  @override
  String get descTemplateQuoteOfDay => 'Quote and why it resonates.';

  @override
  String get descTemplateQuoteOfDayEntryTitle => 'Quote of the Day';

  @override
  String get bodyTemplateQuoteOfDay =>
      'Quote\n\nSource\n\nWhy it resonates\n\n';

  @override
  String get labelTemplateStorySeed => 'Story Seed';

  @override
  String get descTemplateStorySeed => 'A tiny story idea or scene.';

  @override
  String get descTemplateStorySeedEntryTitle => 'Story Seed';

  @override
  String get bodyTemplateStorySeed => 'The seed\n\nPossible direction\n\n';

  @override
  String get labelTemplateTravel => 'Travel Log';

  @override
  String get descTemplateTravel =>
      'Place, weather, what happened, who you met.';

  @override
  String get descTemplateTravelEntryTitle => 'Travel Log';

  @override
  String get bodyTemplateTravel =>
      'Place: \nWeather: \nWhat happened\n\nPeople I met\n\n';

  @override
  String get labelTemplateTomorrowFocus => 'Tomorrow\'s Focus';

  @override
  String get descTemplateTomorrowFocus =>
      'Top 3 priorities and the first step.';

  @override
  String get descTemplateTomorrowFocusEntryTitle => 'Tomorrow\'s Focus';

  @override
  String get bodyTemplateTomorrowFocus =>
      'Top 3 priorities\n\n1. \n2. \n3. \n\nFirst step\n\n';

  @override
  String get labelTemplateWeeklyIntentions => 'Weekly Intentions';

  @override
  String get descTemplateWeeklyIntentions =>
      'Theme, priorities, what to avoid.';

  @override
  String get descTemplateWeeklyIntentionsEntryTitle => 'Weekly Intentions';

  @override
  String get bodyTemplateWeeklyIntentions =>
      'Theme\n\nPriorities\n\nWhat to avoid\n\n';

  @override
  String get labelTemplateMonthlyReview => 'Monthly Review';

  @override
  String get descTemplateMonthlyReview =>
      'Wins, lessons, what changes next month.';

  @override
  String get descTemplateMonthlyReviewEntryTitle => 'Monthly Review';

  @override
  String get bodyTemplateMonthlyReview =>
      'Wins\n\nLessons\n\nWhat changes next month\n\n';

  @override
  String get labelTemplateWorkoutLog => 'Workout Log';

  @override
  String get descTemplateWorkoutLog => 'Exercises, sets, reps, how it felt.';

  @override
  String get descTemplateWorkoutLogEntryTitle => 'Workout Log';

  @override
  String get bodyTemplateWorkoutLog =>
      'Workout\n\nSets / reps\n\nHow it felt\n\n';

  @override
  String get labelTemplateReadingLog => 'Reading Log';

  @override
  String get descTemplateReadingLog => 'Book, pages read, favorite passage.';

  @override
  String get descTemplateReadingLogEntryTitle => 'Reading Log';

  @override
  String get bodyTemplateReadingLog =>
      'Book\n\nPages read\n\nFavorite passage\n\n';

  @override
  String get labelTemplateFoodJournal => 'Food Journal';

  @override
  String get descTemplateFoodJournal => 'Meals and how I felt after.';

  @override
  String get descTemplateFoodJournalEntryTitle => 'Food Journal';

  @override
  String get bodyTemplateFoodJournal => 'Meals\n\nHow I felt after\n\n';

  @override
  String get labelTemplateSpendingLog => 'Spending Log';

  @override
  String get descTemplateSpendingLog => 'Purchases — was it worth it?';

  @override
  String get descTemplateSpendingLogEntryTitle => 'Spending Log';

  @override
  String get bodyTemplateSpendingLog =>
      'Purchase\n\nCost\n\nWas it worth it?\n\n';

  @override
  String get labelTemplatePrayerMeditation => 'Prayer / Meditation';

  @override
  String get descTemplatePrayerMeditation => 'Practice, duration, reflections.';

  @override
  String get descTemplatePrayerMeditationEntryTitle => 'Prayer / Meditation';

  @override
  String get bodyTemplatePrayerMeditation =>
      'Practice\n\nDuration\n\nReflections\n\n';

  @override
  String get labelTemplateSysadminRunbook => 'System admin';

  @override
  String get descTemplateSysadminRunbook =>
      'Server / system runbook, commands, and maintenance log.';

  @override
  String get descTemplateSysadminRunbookEntryTitle => 'Sysadmin / Tech Note';

  @override
  String get bodyTemplateSysadminRunbook =>
      'System / Service: \nObjective & Architecture\n\nConfiguration & Commands\n\nVerification & Health Checks\n\nTroubleshooting & Rollback Notes\n\n';

  @override
  String get labelTemplateSanathanaDharmaStudy => 'Dharma study';

  @override
  String get descTemplateSanathanaDharmaStudy =>
      'Scripture, shloka, tatva/meaning, and sadhana reflection.';

  @override
  String get descTemplateSanathanaDharmaStudyEntryTitle =>
      'Sanathana Dharma Study';

  @override
  String get bodyTemplateSanathanaDharmaStudy =>
      'Topic / Scripture: \nShloka / Mantra / Reference\n\nWord Breakdown & Meaning\n\nPhilosophical Insights (Tatva)\n\nDaily Sadhana & Practical Application\n\n';

  @override
  String get labelTemplateDiyProject => 'DIY & Maker Project';

  @override
  String get descTemplateDiyProject =>
      'Materials, tools, step-by-step build, and safety.';

  @override
  String get descTemplateDiyProjectEntryTitle => 'DIY Project';

  @override
  String get bodyTemplateDiyProject =>
      'Project Goal & Scope\n\nTools & Materials Required\n\nStep-by-Step Procedure\n\nSafety & Precautions\n\nTesting & Lessons Learned\n\n';

  @override
  String get labelTemplateHomeMaintenance => 'Home & Maintenance';

  @override
  String get descTemplateHomeMaintenance =>
      'Appliance care, repairs, warranties, and vendor logs.';

  @override
  String get descTemplateHomeMaintenanceEntryTitle => 'Home Maintenance Note';

  @override
  String get bodyTemplateHomeMaintenance =>
      'Area / Item / Appliance: \nIssue / Maintenance Task\n\nService History & Costs\n\nWarranty & Vendor Contacts\n\nNext Scheduled Check: \n\n';

  @override
  String get labelTemplateKitchenRecipe => 'Kitchen & Recipe';

  @override
  String get descTemplateKitchenRecipe =>
      'Dish, ingredients, step-by-step method, and tips.';

  @override
  String get descTemplateKitchenRecipeEntryTitle => 'Recipe & Kitchen Note';

  @override
  String get bodyTemplateKitchenRecipe =>
      'Dish Name: \nCuisine / Prep & Cook Time: \n\nIngredients & Quantities\n\nStep-by-Step Method\n\nChef Notes & Variations\n\n';

  @override
  String get titleExport => 'Export';

  @override
  String get titleExportSectionWhat => 'What to export';

  @override
  String get titleExportSectionFormat => 'Format';

  @override
  String get titleExportSectionOptions => 'Options';

  @override
  String get labelExportScopeThisEntry => 'This entry';

  @override
  String get labelExportScopeWholeJournal => 'The whole journal';

  @override
  String get labelExportScopeDateRange => 'A date range';

  @override
  String get actionExportPickDateRange => 'Choose dates';

  @override
  String get descExportDateRangeNotSet => 'No dates chosen yet';

  @override
  String descExportFromJournal(String journalTitle) {
    return 'From \"$journalTitle\"';
  }

  @override
  String descExportDateRange(String from, String to) {
    return '$from to $to';
  }

  @override
  String get labelExportFormatMarkdown => 'Markdown';

  @override
  String get labelExportFormatHtml => 'Web page (HTML)';

  @override
  String get labelExportFormatPlainText => 'Plain text';

  @override
  String get labelExportFormatPdf => 'PDF';

  @override
  String get descExportFormatMarkdown =>
      'Keeps headings, lists and styling. Opens in any text editor.';

  @override
  String get descExportFormatHtml =>
      'One page that opens in any browser. Nothing is loaded from the internet.';

  @override
  String get descExportFormatPlainText => 'Just the words, no styling.';

  @override
  String get descExportFormatPdf => 'Fixed pages, ready to print or share.';

  @override
  String get bodyExportPdfUnavailable =>
      'PDF export is not available on this device. The other formats still work.';

  @override
  String get labelExportIncludeAttachments => 'Include attachments';

  @override
  String get descExportIncludeAttachments =>
      'Adds a copy of each file and voice note to the export.';

  @override
  String get labelExportIncludeMetadata => 'Date, tags and mood';

  @override
  String get descExportIncludeMetadata =>
      'Adds a short header above each entry.';

  @override
  String get bodyExportNotEncrypted =>
      'The exported file is not encrypted. Anyone who can open the file can read it. Keep it somewhere safe.';

  @override
  String get titleExportConfirm => 'Export unencrypted?';

  @override
  String bodyExportConfirm(int count, String format) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return 'This will write $_temp0 to an unencrypted $format file. Anyone who can open that file can read your journal. Keep it somewhere safe, and delete it when you are done with it.';
  }

  @override
  String get actionExportAnyway => 'Export anyway';

  @override
  String get actionExport => 'Export';

  @override
  String get bodyExportExporting => 'Exporting…';

  @override
  String get titleExportSaveDialog => 'Save export';

  @override
  String bodyExportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count entries.',
      one: 'Exported 1 entry.',
    );
    return '$_temp0';
  }

  @override
  String get bodyExportCancelled => 'Export cancelled.';

  @override
  String get errorExportNothing =>
      'There are no entries to export for that choice.';

  @override
  String get errorExportFailed =>
      'Could not finish the export. Nothing was saved.';

  @override
  String get errorExportPdfTimedOut =>
      'The PDF took too long to build and was stopped. Try a smaller date range.';

  @override
  String get errorExportPdfFailed => 'Could not build the PDF.';

  @override
  String get titleExportSkipped => 'Not included';

  @override
  String bodyExportSkippedLockedAttachment(String fileName) {
    return '$fileName — locked. Unlock it first to include it.';
  }

  @override
  String bodyExportSkippedUnreadableAttachment(String fileName) {
    return '$fileName — the file could not be read.';
  }

  @override
  String bodyExportSkippedUnreadableVoiceNote(String fileName) {
    return '$fileName — the recording could not be read.';
  }

  @override
  String bodyExportSkippedLockedInlineImage(String fileName) {
    return '$fileName — a locked image in the entry body was left out of the page.';
  }

  @override
  String bodyExportSkippedUnreadableInlineImage(String fileName) {
    return '$fileName — an image in the entry body could not be read.';
  }

  @override
  String get descExportFileUntitledEntry => 'Untitled entry';

  @override
  String get descExportFileDate => 'Date';

  @override
  String get descExportFileTags => 'Tags';

  @override
  String get descExportFileMood => 'Mood';

  @override
  String get descExportFileAttachments => 'Attachments';

  @override
  String get descExportFileVoiceNotes => 'Voice notes';

  @override
  String get descExportFileTranscript => 'Transcript';

  @override
  String get descExportFileLockedNotIncluded => 'locked — not included';

  @override
  String get descExportFileImage => 'Image';

  @override
  String get descExportFileDrawing => 'Drawing';

  @override
  String get descExportFileCalloutNote => 'Note';

  @override
  String get descExportFileCalloutTip => 'Tip';

  @override
  String get descExportFileCalloutWarning => 'Warning';

  @override
  String get descExportFileCalloutImportant => 'Important';

  @override
  String descExportFileMoodValue(int mood) {
    return '$mood of 5';
  }

  @override
  String descExportFileRecording(String duration) {
    return 'Recording ($duration)';
  }

  @override
  String bodyExportFileReadme(
    String journalTitle,
    String exportedAt,
    int entryCount,
    String formatName,
  ) {
    return 'Export from SreerajP Journal Vault\n\nJournal:  $journalTitle\nExported: $exportedAt\nEntries:  $entryCount\nFormat:   $formatName\n\nThe \"entries\" folder holds one file per entry.\nThe \"attachments\" folder, if present, holds a copy of the files and voice\nnotes belonging to those entries.\n\nThis export is NOT encrypted. Anyone who can open these files can read them.\n';
  }

  @override
  String get labelExportData => 'Export Data';

  @override
  String get tooltipExportEntry => 'Export this entry';

  @override
  String get tooltipExportJournal => 'Export this journal';

  @override
  String get titleExportChooseJournal => 'Export from journal';

  @override
  String get bodyExportNoJournals =>
      'Create a journal first, then you can export it.';

  @override
  String get bodyExportAllLocked =>
      'Open a locked journal first to export from it.';

  @override
  String descExportFileUnexportableBlock(String type) {
    return '$type block — not exportable as text';
  }

  @override
  String get descExportFileImageNotIncluded => 'image not included';

  @override
  String get descExportFileDrawingNotIncluded => 'drawing not included';

  @override
  String get actionCommonOk => 'OK';

  @override
  String get actionCommonDone => 'Done';

  @override
  String get bodyAirqrSettingsApplied => 'Settings and templates applied.';

  @override
  String get bodyAirqrEntryImported => 'Entry imported into your journal.';

  @override
  String get bodyAirqrJournalImported => 'Journal and entries imported.';

  @override
  String get errorAirqrImport => 'Could not import the data.';

  @override
  String get descAirqrImportedEntryTitle => 'Imported entry';

  @override
  String get descAirqrImportedJournalTitle => 'Imported journal';

  @override
  String get bodyAirqrAssembling => 'Joining the frames and checking them…';

  @override
  String get errorAirqrDecode =>
      'The data could not be read. Check the pairing code and scan again.';

  @override
  String get actionAirqrScanAgain => 'Scan again';

  @override
  String bodyAirqrFramesReceived(int received, int total) {
    return 'Received $received of $total frames';
  }

  @override
  String get bodyAirqrAlignCamera => 'Point the camera at the moving QR code…';

  @override
  String bodyAirqrMissingFrames(String frames) {
    return 'Missing frames: $frames';
  }

  @override
  String get titleAirqrEnterCode => 'Enter pairing code';

  @override
  String get descAirqrEnterCode =>
      'Enter the 16-character code shown on the sending screen.';

  @override
  String get actionAirqrDecrypt => 'Decrypt and verify';

  @override
  String get titleAirqrVerified => 'Data verified';

  @override
  String descAirqrPayloadType(String type) {
    return 'Type: $type';
  }

  @override
  String get labelAirqrKindSettings => 'Settings';

  @override
  String get labelAirqrKindEntry => 'Entry';

  @override
  String get labelAirqrKindJournal => 'Journal';

  @override
  String get labelAirqrKindSnapshot => 'Snapshot';

  @override
  String descAirqrPayloadTheme(String theme) {
    return 'Theme: $theme';
  }

  @override
  String descAirqrPayloadAccent(String color) {
    return 'Accent color: $color';
  }

  @override
  String descAirqrPayloadTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Templates: $count custom templates',
      one: 'Templates: 1 custom template',
    );
    return '$_temp0';
  }

  @override
  String descAirqrPayloadTags(int count) {
    return 'Tags: $count';
  }

  @override
  String get actionAirqrApplySettings => 'Apply settings';

  @override
  String get actionAirqrImport => 'Import to vault';

  @override
  String get bodyAirqrEncoding => 'Preparing the QR frames…';

  @override
  String get errorAirqrEncode => 'Could not prepare the data to send.';

  @override
  String descAirqrPayloadSize(int bytes, int frames) {
    return '$bytes bytes • $frames data frames';
  }

  @override
  String get labelAirqrManifestFrame => 'Header frame';

  @override
  String labelAirqrFrameOf(int index, int total) {
    return 'Frame $index of $total';
  }

  @override
  String labelAirqrSpeed(int fps) {
    return 'Speed: $fps FPS';
  }

  @override
  String bodyAirqrTooLarge(String size, String limit) {
    return '$size is too large to send by QR (limit $limit). Use Wi-Fi Sync instead.';
  }

  @override
  String bodyAirqrSlow(String size, String duration) {
    return 'This transfer is $size and will take about $duration by QR. Wi-Fi Sync is much faster for large transfers.';
  }

  @override
  String descAirqrMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String descAirqrSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get bodyAirqrNoJournals => 'No journals to send.';

  @override
  String get titleAirqrSelectJournal => 'Choose a journal';

  @override
  String get descAirqrNoDescription => 'No description';

  @override
  String get descAirqrOffline => 'Fully offline • Camera only';

  @override
  String get labelAirqrBadgeFast => 'Under 1 sec';

  @override
  String get titleAirqrPayloadSettings => 'Settings';

  @override
  String get titleAirqrPayloadSnapshot => 'Vault text snapshot';

  @override
  String get errorTimeCapsuleSeal => 'Could not seal the time capsule.';

  @override
  String get errorTimeCapsuleNotFound => 'Time capsule not found.';

  @override
  String get errorTimeCapsuleLoad => 'Could not open the time capsule.';

  @override
  String get labelTimeCapsuleDays => 'Days';

  @override
  String get labelTimeCapsuleHours => 'Hours';

  @override
  String get labelTimeCapsuleMinutes => 'Mins';

  @override
  String get labelTimeCapsuleSeconds => 'Secs';

  @override
  String get labelTimeCapsuleSealedOn => 'Sealed on';

  @override
  String get labelTimeCapsuleUnlocksOn => 'Unlocks on';

  @override
  String get labelTimeCapsuleTeaser => 'Note to future self';

  @override
  String get descEditorPlaceholder => 'Write your entry…';

  @override
  String descBiometricReasonFile(String fileName) {
    return 'Unlock \"$fileName\"';
  }

  @override
  String get descBiometricReasonApp => 'Unlock SreerajP Journal Vault';

  @override
  String get bodyEditorDrawingLocked => 'Locked drawing — tap to unlock';

  @override
  String get descEditorImageLoading => 'Loading image…';

  @override
  String get errorTemplateLoad => 'Could not load templates.';

  @override
  String get errorTemplateSave => 'Could not save the template.';

  @override
  String descShareSealedFileSize(String size) {
    return '$size KB • Encrypted vault file';
  }

  @override
  String labelTypographyPoints(int size) {
    return '$size pt';
  }

  @override
  String descTypographyFamilyAndSize(String family, int size) {
    return '$family • $size pt';
  }

  @override
  String get descTemplateTokenToday => 'Today\'s date (YYYY-MM-DD)';

  @override
  String get descTemplateTokenWeekday => 'Day of the week (e.g. Monday)';

  @override
  String get descTemplateTokenDate => 'Full date (e.g. August 23, 2026)';

  @override
  String get descTemplateTokenTime => 'Current time (e.g. 2:30 PM)';

  @override
  String get descTemplateTokenYear => 'Four-digit year (e.g. 2026)';

  @override
  String get descTemplateTokenMonth => 'Month name (e.g. August)';

  @override
  String get descTemplateTokenDay => 'Day of the month (1–31)';

  @override
  String descShareDefaultTitle(String date) {
    return 'Note - $date';
  }

  @override
  String labelTimeCapsuleOpenedOn(String date) {
    return 'Opened on $date';
  }

  @override
  String get errorTimeCapsuleUnseal => 'Could not unseal the time capsule.';

  @override
  String get bodySyncStepConnecting => 'Connecting to the device…';

  @override
  String get bodySyncStepAuthenticating => 'Checking the pairing code…';

  @override
  String get bodySyncStepSyncing => 'Copying entries and attachments…';

  @override
  String get bodySyncStepCompleted => 'Sync finished.';

  @override
  String get errorSyncFailed =>
      'Sync failed. Check both devices and try again.';

  @override
  String get labelSyncNotSynced => 'Not synced';

  @override
  String get labelSyncSynced => 'Synced';

  @override
  String get errorSyncIpRequired => 'Enter the IP address.';

  @override
  String get errorSyncPortInvalid => 'Enter a port between 1 and 65535.';

  @override
  String get errorSyncCodeInvalid => 'Enter the 16-character pairing code.';

  @override
  String get errorSyncHostAddress => 'Could not read this device\'s address.';

  @override
  String get labelSyncNoAddress => 'None';

  @override
  String get bodySyncDetectingWifi => 'Looking for Wi-Fi…';

  @override
  String labelSyncIpList(String addresses) {
    return 'IP: $addresses';
  }

  @override
  String labelSyncUnresolvedConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts',
      one: '1 conflict',
    );
    return '$_temp0';
  }

  @override
  String labelSyncLastSyncAt(String timestamp) {
    return 'Last sync: $timestamp';
  }

  @override
  String get errorOcrNoCameras => 'No camera found on this device.';

  @override
  String get bodyVoiceNoteRecording => 'Recording…';

  @override
  String get titleVoiceNote => 'Voice note';

  @override
  String get errorAttachmentAudioPlay => 'This audio file could not be played.';

  @override
  String get errorAttachmentArchiveRead =>
      'This archive could not be read. It may be damaged or password-protected.';

  @override
  String get labelDateToday => 'Today';

  @override
  String get labelDateYesterday => 'Yesterday';

  @override
  String labelDateDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String labelDateWeeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String labelDateMonthsAgo(int count) {
    return '${count}mo ago';
  }

  @override
  String labelDateYearsAgo(int count) {
    return '${count}y ago';
  }

  @override
  String get titlePermissionAttachmentImport => 'File access';

  @override
  String get descPermissionAttachmentImport =>
      'Lets the app read files from your device storage when you add an attachment.';

  @override
  String get titlePermissionDocumentPicker => 'File picker';

  @override
  String get descPermissionDocumentPicker =>
      'Uses the system file picker to choose attachments. No permission is needed.';

  @override
  String get labelSecurityEventFailedAuth => 'Unlock failed';

  @override
  String get labelSecurityEventAttachmentLocked => 'Attachment locked';

  @override
  String get labelSecurityEventAttachmentUnlocked => 'Attachment unlocked';

  @override
  String get labelSecurityEventExportAttempt => 'Data exported';

  @override
  String get labelSecurityEventLockTriggered => 'App locked';

  @override
  String get labelSecurityEventProfileChanged => 'Profile changed';

  @override
  String get labelSecurityEventProfileCreated => 'Profile created';

  @override
  String get labelSecurityEventScreenSecurityChanged => 'Screenshots changed';

  @override
  String get labelSecurityEventTamperDetected => 'Tampering detected';

  @override
  String get labelSecurityEventOther => 'Security event';

  @override
  String get labelImportFormatWord => 'Word document';

  @override
  String get labelImportFormatMarkdown => 'Markdown';

  @override
  String get labelImportFormatPlainText => 'Plain text';

  @override
  String get titleNotificationTimeCapsules => 'Time Capsules';

  @override
  String get errorStorageMigrationFailed => 'Could not move the attachments.';

  @override
  String get descPermissionSafGranted =>
      'Granted through the system file picker — no separate permission is needed on Android 13 and later.';

  @override
  String labelJournalEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get tooltipEditorDictate => 'Dictate';

  @override
  String get titleDictation => 'Dictation';

  @override
  String get labelDictationListening => 'Listening…';

  @override
  String get labelDictationPaused => 'Paused';

  @override
  String get tooltipDictationPause => 'Pause';

  @override
  String get tooltipDictationResume => 'Resume';

  @override
  String get tooltipDictationLanguage => 'Speech language';

  @override
  String get labelDictationDeviceDefault => 'Device language';

  @override
  String get labelDictationEditHint => 'Edit text';

  @override
  String get actionDictationInsert => 'Insert';

  @override
  String get emptyDictationSpeak =>
      'Start speaking. Your words will appear here.';

  @override
  String get descDictationPrivacy =>
      'Speech is recognised on this device. No audio is saved or sent.';

  @override
  String get errorDictationOfflineUnavailable =>
      'Offline speech recognition is not available on this device. Dictation works only on the device, so it cannot be used here.';

  @override
  String get errorDictationLanguageUnavailable =>
      'The offline speech model for this language is not installed. Install it in your phone\'s speech settings, or pick another language.';

  @override
  String get errorDictationFailed =>
      'Speech recognition stopped unexpectedly. Try again.';

  @override
  String get helpDictationSanskritUnsupported =>
      'Sanskrit speech cannot be recognised offline yet. Speak in English or Malayalam.';

  @override
  String get tooltipOcrPreviewText => 'Preview text';

  @override
  String get actionOcrInAppCamera => 'In-app camera';

  @override
  String get errorOcrPhoneCameraUnavailable =>
      'Could not open the phone\'s camera app. Using the in-app camera instead.';

  @override
  String get helpOcrPhoneCamera =>
      '\"Take photo\" opens your phone\'s own camera app for the clearest photos. A few camera apps also keep their own copy in the gallery. Choose \"In-app camera\" if the photo must never leave this app.';
}
