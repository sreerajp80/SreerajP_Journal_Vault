import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_sa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
    Locale('sa'),
  ];

  /// Title of the screen shown when the encrypted database cannot be opened at startup
  ///
  /// In en, this message translates to:
  /// **'Vault unavailable'**
  String get titleVaultUnavailable;

  /// Reason line when the Android Keystore no longer holds the database key
  ///
  /// In en, this message translates to:
  /// **'The key that unlocks your journal is no longer on this device. Without it, nothing can read the vault — not even this app.'**
  String get descVaultUnavailableKeyMissing;

  /// Reason line when the SQLCipher library was not the one loaded, which is a build fault
  ///
  /// In en, this message translates to:
  /// **'This build of the app cannot encrypt the vault, so it has stopped rather than store your journal unprotected.'**
  String get descVaultUnavailableCipherMissing;

  /// Reason line when the one-time plain to encrypted conversion failed
  ///
  /// In en, this message translates to:
  /// **'Your journal could not be moved into encrypted storage. It has been left exactly as it was — nothing has been deleted.'**
  String get errorVaultUnavailableConversion;

  /// Reason line when the database file exists but will not open
  ///
  /// In en, this message translates to:
  /// **'The vault file cannot be read. It may be damaged, or it may belong to a different installation of the app.'**
  String get descVaultUnavailableFileUnreadable;

  /// Reassurance line telling the user no data was destroyed
  ///
  /// In en, this message translates to:
  /// **'Nothing has been deleted. Your entries and attachments are still on this device.'**
  String get descVaultUnavailableDataIntact;

  /// Advice on what the user can do next when the vault cannot be opened
  ///
  /// In en, this message translates to:
  /// **'If you have a backup file, reinstall the app and restore from it. If not, keep this installation as it is and do not clear the app data — that would remove the vault for good.'**
  String get descVaultUnavailableNextSteps;

  /// The application title, shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault'**
  String get titleApp;

  /// Title of the About screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleAbout;

  /// Shown when the About screen cannot read the app config
  ///
  /// In en, this message translates to:
  /// **'Unable to load app metadata'**
  String get errorAboutLoad;

  /// Button that tries the failed action again
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorCommonRetry;

  /// Row label for the app version and build number on the About screen
  ///
  /// In en, this message translates to:
  /// **'App Version / Build'**
  String get labelAboutVersionBuild;

  /// Row label for when the app was last built, on the About screen
  ///
  /// In en, this message translates to:
  /// **'Last Build Timestamp'**
  String get labelAboutLastBuild;

  /// Title of the Permissions screen
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get titlePermissions;

  /// Section header for permissions the user is asked for directly
  ///
  /// In en, this message translates to:
  /// **'Explicit permissions'**
  String get titlePermissionsExplicit;

  /// Section header for permissions granted without a prompt
  ///
  /// In en, this message translates to:
  /// **'Implicit permissions'**
  String get titlePermissionsImplicit;

  /// Permission state: the user granted it
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get labelPermissionStatusAllowed;

  /// Permission state: the user refused it
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get labelPermissionStatusDenied;

  /// Permission state: refused and the system will not ask again
  ///
  /// In en, this message translates to:
  /// **'Permanently denied'**
  String get labelPermissionStatusPermanentlyDenied;

  /// Permission state: the user granted access to specific items only
  ///
  /// In en, this message translates to:
  /// **'User selected'**
  String get labelPermissionStatusUserSelected;

  /// Button that asks the system for a permission
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get actionPermissionsRequest;

  /// Button that opens the system settings page for this app
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionPermissionsOpenSettings;

  /// Button that closes a dialog without doing anything
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCommonCancel;

  /// Button that deletes the item being discussed
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionCommonDelete;

  /// Button that saves the current edit
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionCommonSave;

  /// Title of the tag manager screen
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get titleTags;

  /// Shown when the list of tags cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not load tags: {error}'**
  String errorTagsLoad(String error);

  /// Empty state on the tag manager screen
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add tags to a journal and they will show up here.'**
  String get emptyTags;

  /// Subtitle on a tag that has no colour chosen by the user
  ///
  /// In en, this message translates to:
  /// **'Automatic colour'**
  String get descTagsAutomaticColour;

  /// Tooltip on the menu button that opens tag actions
  ///
  /// In en, this message translates to:
  /// **'Tag actions'**
  String get tooltipTagsActions;

  /// Menu item that renames a tag
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionTagsRename;

  /// Menu item, and dialog title, for picking a tag colour
  ///
  /// In en, this message translates to:
  /// **'Choose colour'**
  String get actionTagsChooseColour;

  /// Menu item that clears a tag colour so it is chosen automatically
  ///
  /// In en, this message translates to:
  /// **'Reset to automatic'**
  String get actionTagsResetColour;

  /// Message shown when a tag rename is rejected
  ///
  /// In en, this message translates to:
  /// **'That name is empty or already used by another tag.'**
  String get errorTagsRename;

  /// Confirmation shown after a tag is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted #{name}.'**
  String bodyTagsDeleted(String name);

  /// Title of the confirm-delete dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get bodyTagsDelete;

  /// Body of the confirm-delete dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Delete \"#{name}\"? It will be removed from every journal and entry that uses it.'**
  String bodyTagsDeleteBody(String name);

  /// Title of the rename dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get titleTagsRename;

  /// Label of the text field where a new tag name is typed
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get labelTagsName;

  /// Generic inline error text, followed by the reason
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorCommon(String message);

  /// Placeholder title for an entry that has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled entry'**
  String get descCommonUntitledEntry;

  /// Short placeholder title for an item that has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get descCommonUntitled;

  /// Title of the timeline screen
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get titleTimeline;

  /// Empty state under the calendar when the chosen day has no entries
  ///
  /// In en, this message translates to:
  /// **'No entries for this date'**
  String get emptyTimelineNoEntriesForDate;

  /// Name of the month view of the calendar
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get labelTimelineCalendarFormatMonth;

  /// Marker on a calendar day that has more than nine entries
  ///
  /// In en, this message translates to:
  /// **'9+'**
  String get labelTimelineDayCountOverflow;

  /// Title of the insights screen
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get titleInsights;

  /// Heading of the card showing how many days in a row the user wrote
  ///
  /// In en, this message translates to:
  /// **'Writing Streak'**
  String get titleInsightsStreak;

  /// Label for the streak running right now
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get labelInsightsStreakCurrent;

  /// Label for the longest streak ever reached
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get labelInsightsStreakLongest;

  /// Unit shown under a streak number
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get labelInsightsStreakUnitDays;

  /// Pairs a streak label with its unit, for example "Current (days)"
  ///
  /// In en, this message translates to:
  /// **'{label} ({unit})'**
  String labelInsightsStreakStat(String label, String unit);

  /// Date of the most recent entry, on the streak card
  ///
  /// In en, this message translates to:
  /// **'Last entry: {date}'**
  String labelInsightsLastEntry(String date);

  /// Heading of the mood chart card
  ///
  /// In en, this message translates to:
  /// **'Mood — 30 days'**
  String get titleInsightsMood;

  /// Empty state of the mood chart card
  ///
  /// In en, this message translates to:
  /// **'No mood data yet.\nRate your mood on entries to see trends.'**
  String get emptyInsightsMood;

  /// Tooltip on one bar of the mood chart
  ///
  /// In en, this message translates to:
  /// **'{date}\nMood: {mood}\nEntries: {count}'**
  String descInsightsMood(String date, String mood, int count);

  /// Heading of the card showing which tags are used most
  ///
  /// In en, this message translates to:
  /// **'Tag Heatmap'**
  String get titleInsightsTagHeatmap;

  /// Empty state of the tag heatmap card
  ///
  /// In en, this message translates to:
  /// **'No tags used yet.'**
  String get emptyInsightsTagHeatmap;

  /// One tag and how many times it was used
  ///
  /// In en, this message translates to:
  /// **'{tag} ({count})'**
  String labelInsightsTag(String tag, int count);

  /// Heading of the card showing entries from the same date in past years
  ///
  /// In en, this message translates to:
  /// **'On This Day'**
  String get titleInsightsMemories;

  /// Empty state of the memories card
  ///
  /// In en, this message translates to:
  /// **'No memories for today.\nKeep journaling to build memories!'**
  String get emptyInsightsMemories;

  /// Short label on a memory, meaning that many years ago
  ///
  /// In en, this message translates to:
  /// **'{years}y'**
  String labelInsightsYearsAgo(int years);

  /// Heading of the weekly summary card
  ///
  /// In en, this message translates to:
  /// **'Weekly Reflection'**
  String get titleInsightsReflection;

  /// Row label for the dates the weekly summary covers
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get labelInsightsReflectionPeriod;

  /// Row label for how many entries were written this week
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get labelInsightsReflectionEntries;

  /// Row label for how many words were written this week
  ///
  /// In en, this message translates to:
  /// **'Words Written'**
  String get labelInsightsReflectionWords;

  /// Row label for the average mood this week
  ///
  /// In en, this message translates to:
  /// **'Average Mood'**
  String get labelInsightsReflectionAverageMood;

  /// Row label for the most used tags this week
  ///
  /// In en, this message translates to:
  /// **'Top Tags'**
  String get labelInsightsReflectionTopTags;

  /// Row label for the streak running right now
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get labelInsightsReflectionStreak;

  /// A start and end date, shown as one range
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String labelInsightsDateRange(String start, String end);

  /// An average mood score out of five
  ///
  /// In en, this message translates to:
  /// **'{mood} / 5'**
  String labelInsightsMoodOutOfFive(String mood);

  /// A number of days in a row
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String labelInsightsStreakDays(int count);

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionCommonClose;

  /// Placeholder shown when a failure gives no reason
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorCommonUnknown;

  /// Title of the import screen
  ///
  /// In en, this message translates to:
  /// **'Import Files'**
  String get titleImport;

  /// Button label while an import is running
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get bodyImportSelecting;

  /// Button that opens the file picker to choose files to import
  ///
  /// In en, this message translates to:
  /// **'Select files'**
  String get actionImportSelectFiles;

  /// Heading above the list of imported files
  ///
  /// In en, this message translates to:
  /// **'Import Results'**
  String get titleImportResults;

  /// Shown under a file that imported without a problem
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get labelImportFileSucceeded;

  /// Confirmation after an import finishes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file imported successfully} other{{count} files imported successfully}}'**
  String descImportCountSucceeded(int count);

  /// Shown when a ZIP attachment has no files inside
  ///
  /// In en, this message translates to:
  /// **'This archive is empty.'**
  String get emptyAttachmentArchive;

  /// Button and tooltip that hands the attachment to another app
  ///
  /// In en, this message translates to:
  /// **'Open with...'**
  String get descAttachmentOpenWith;

  /// Heading when an attachment cannot be shown inside the app
  ///
  /// In en, this message translates to:
  /// **'Unsupported file'**
  String get titleAttachmentUnsupported;

  /// Explains which attachment cannot be shown in the app
  ///
  /// In en, this message translates to:
  /// **'{fileName} cannot be shown inside the app.'**
  String bodyAttachmentUnsupported(String fileName);

  /// Shown when the temporary decrypted PDF has already been deleted
  ///
  /// In en, this message translates to:
  /// **'The decrypted file is no longer available.'**
  String get bodyAttachmentPdfMissing;

  /// Shown when the PDF viewer fails to load a file
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF: {reason}'**
  String errorAttachmentPdfOpen(String reason);

  /// Title of the auto-lock profiles screen
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Profiles'**
  String get titleAutoLock;

  /// Button, and dialog title, for creating an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get actionAutoLockNewProfile;

  /// Dialog title, and tooltip, for changing an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get tooltipAutoLockEditProfile;

  /// Empty state of the auto-lock profiles screen
  ///
  /// In en, this message translates to:
  /// **'No auto-lock profiles yet. Create one to lock the app after a period of inactivity.'**
  String get emptyAutoLock;

  /// Tooltip on the button that removes an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get tooltipAutoLockDeleteProfile;

  /// Tooltip on the button that turns an auto-lock profile on
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get tooltipAutoLockActivate;

  /// Tooltip on the button that turns an auto-lock profile off
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get tooltipAutoLockDeactivate;

  /// Joins the parts of an auto-lock profile summary line
  ///
  /// In en, this message translates to:
  /// **'{timeout}{lockOnMinimize}{active}'**
  String descAutoLock(String timeout, String lockOnMinimize, String active);

  /// Part of the summary line saying the app locks when minimized
  ///
  /// In en, this message translates to:
  /// **' • lock on minimize'**
  String get labelAutoLockSuffixLockOnMinimize;

  /// Part of the summary line saying this profile is the one in use
  ///
  /// In en, this message translates to:
  /// **' • active'**
  String get labelAutoLockSuffixActive;

  /// A timeout of under a minute, in seconds
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String labelAutoLockTimeoutSeconds(int seconds);

  /// A timeout of under an hour, in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String labelAutoLockTimeoutMinutes(int minutes);

  /// A timeout of an hour or more, in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String labelAutoLockTimeoutHours(String hours);

  /// Label of the field for an auto-lock profile name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelAutoLockName;

  /// Label of the field for how long before the app locks
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get labelAutoLockTimeout;

  /// Switch that locks the app as soon as it is minimized
  ///
  /// In en, this message translates to:
  /// **'Lock on minimize'**
  String get labelAutoLockLockOnMinimize;

  /// Validation message when the profile name is left blank
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get errorAutoLockName;

  /// Validation message when the timeout is not a whole number above zero
  ///
  /// In en, this message translates to:
  /// **'Timeout must be a positive integer.'**
  String get errorAutoLockTimeout;

  /// Title of the security events screen
  ///
  /// In en, this message translates to:
  /// **'Security Events'**
  String get titleSecurityEvents;

  /// Empty state of the security events screen
  ///
  /// In en, this message translates to:
  /// **'No security events recorded'**
  String get emptySecurityEvents;

  /// Title of the dialog showing the raw detail of one security event
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get titleSecurityEventDetails;

  /// Title of the screen listing sync conflicts
  ///
  /// In en, this message translates to:
  /// **'Sync Conflicts'**
  String get titleSyncConflicts;

  /// Shown when the list of conflicts cannot be read
  ///
  /// In en, this message translates to:
  /// **'Failed to load conflicts:\n{error}'**
  String errorSyncConflictsLoad(String error);

  /// Heading of the empty state when nothing is in conflict
  ///
  /// In en, this message translates to:
  /// **'No pending conflicts'**
  String get emptySyncNoConflicts;

  /// Subtitle of the empty state when nothing is in conflict
  ///
  /// In en, this message translates to:
  /// **'All data is in sync.'**
  String get emptySyncAllInSync;

  /// When a sync conflict was first noticed.
  ///
  /// In en, this message translates to:
  /// **'Detected: {timestamp}'**
  String labelSyncDetectedAt(String timestamp);

  /// Heading above the list of fields that differ between two versions.
  ///
  /// In en, this message translates to:
  /// **'Changed fields:'**
  String get titleSyncChangedFields;

  /// Button that opens a side-by-side view of the two versions
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get actionSyncCompare;

  /// Button that keeps the version from the other device
  ///
  /// In en, this message translates to:
  /// **'Keep Remote'**
  String get actionSyncKeepRemote;

  /// Button that keeps the version on this device
  ///
  /// In en, this message translates to:
  /// **'Keep Local'**
  String get actionSyncKeepLocal;

  /// Title of the dialog confirming that the local version wins
  ///
  /// In en, this message translates to:
  /// **'Keep local version?'**
  String get bodySyncKeepLocal;

  /// Title of the dialog confirming that the remote version wins
  ///
  /// In en, this message translates to:
  /// **'Keep remote version?'**
  String get bodySyncKeepRemote;

  /// Explains what happens when the local version is kept
  ///
  /// In en, this message translates to:
  /// **'The remote changes will be discarded. Your local version will be pushed on next sync.'**
  String get bodySyncKeepLocalBody;

  /// Explains what happens when the remote version is kept
  ///
  /// In en, this message translates to:
  /// **'Your local changes will be overwritten with the remote version.'**
  String get bodySyncKeepRemoteBody;

  /// Button that agrees to the action described in a dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get bodyCommon;

  /// Confirmation shown after a conflict is settled
  ///
  /// In en, this message translates to:
  /// **'Conflict resolved.'**
  String get bodySyncConflictResolved;

  /// Shown when settling a conflict does not work
  ///
  /// In en, this message translates to:
  /// **'Resolution failed: {error}'**
  String errorSyncResolution(String error);

  /// Title of the dialog comparing the local and remote values
  ///
  /// In en, this message translates to:
  /// **'Conflict Details'**
  String get titleSyncConflictDetails;

  /// Column heading for the name of the field that differs
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get titleSyncColumnField;

  /// Column heading for the value on this device
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get titleSyncColumnLocal;

  /// Column heading for the value on the other device
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get titleSyncColumnRemote;

  /// Heading of the sync health card
  ///
  /// In en, this message translates to:
  /// **'Sync Health'**
  String get titleSyncHealth;

  /// Row label for when sync last ran
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get labelSyncLastSync;

  /// Row label for how many syncs failed in the last seven days
  ///
  /// In en, this message translates to:
  /// **'Failures (7d)'**
  String get errorSyncFailures7d;

  /// Row label for how many conflicts are waiting
  ///
  /// In en, this message translates to:
  /// **'Pending conflicts'**
  String get labelSyncPendingConflicts;

  /// Placeholder shown while a value is being read
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get bodyCommonLoading;

  /// Short placeholder shown in place of a value that could not be read
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorCommonErrorShort;

  /// Short placeholder shown while a number is being counted
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get bodyCommonEllipsis;

  /// Shown in place of a date when sync has never run
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get labelSyncNever;

  /// Button that opens the conflict list, with how many are waiting
  ///
  /// In en, this message translates to:
  /// **'Resolve ({count})'**
  String actionSyncResolveCount(int count);

  /// Button that starts a sync straight away
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get actionSyncNow;

  /// Heading above the list of recent sync runs
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get titleSyncRecentActivity;

  /// Shown when the sync history cannot be read
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String errorSyncLogsLoad(String error);

  /// Empty state of the sync history list
  ///
  /// In en, this message translates to:
  /// **'No sync activity yet.'**
  String get emptySyncNoActivity;

  /// Sync state: nothing happening
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get labelSyncStatusIdle;

  /// Status when sync is in progress
  ///
  /// In en, this message translates to:
  /// **'Syncing changes...'**
  String get descSyncStatusSyncing;

  /// Sync state: the last sync worked
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get labelSyncStatusHealthy;

  /// Sync health status: the last sync did not finish.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get errorSyncStatus;

  /// Sync state: some records disagree and need a choice
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get labelSyncStatusConflicts;

  /// Fallback summary for a sync run that failed with no reason given
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get errorSyncLog;

  /// How many records were sent to the other device
  ///
  /// In en, this message translates to:
  /// **'{count} pushed'**
  String labelSyncLogPushed(int count);

  /// How many records were received from the other device
  ///
  /// In en, this message translates to:
  /// **'{count} pulled'**
  String labelSyncLogPulled(int count);

  /// How many conflicts one sync run found
  ///
  /// In en, this message translates to:
  /// **'{count} conflicts'**
  String labelSyncLogConflicts(int count);

  /// Summary for a sync run that moved nothing
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get labelSyncLogNoChanges;

  /// Tooltip on the button that reloads the screen
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get tooltipCommonRefresh;

  /// Title of the backup health screen
  ///
  /// In en, this message translates to:
  /// **'Backup Health'**
  String get titleBackup;

  /// Button that starts a backup straight away
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get actionBackupNow;

  /// Button label while a backup is running
  ///
  /// In en, this message translates to:
  /// **'Backing up...'**
  String get bodyBackupInProgress;

  /// Heading above the list of past backups
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get titleBackupHistory;

  /// Heading of the card showing how healthy backups are
  ///
  /// In en, this message translates to:
  /// **'Backup Status'**
  String get titleBackupStatus;

  /// Shown when no backup has ever finished
  ///
  /// In en, this message translates to:
  /// **'No successful backups yet'**
  String get bodyBackupNoneYet;

  /// Row label for when the last backup finished
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get labelBackupLastBackup;

  /// Row label for how many entries a backup holds
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get labelBackupEntries;

  /// Row label for how many attachments a backup holds
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get labelBackupAttachments;

  /// Row label for how large a backup file is
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get labelBackupSize;

  /// Warning about recent backup failures
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 failed backup in the last 7 days} other{{count} failed backups in the last 7 days}}'**
  String errorBackupRecentFailures(int count);

  /// Heading of the card that controls automatic backups
  ///
  /// In en, this message translates to:
  /// **'Auto-Backup Schedule'**
  String get titleBackupSchedule;

  /// Shows how often automatic backups run
  ///
  /// In en, this message translates to:
  /// **'Scheduled: {interval}'**
  String labelBackupScheduled(String interval);

  /// Shown when automatic backups are off
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get bodyBackupNotScheduled;

  /// Chip meaning the backup timer is running
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labelBackupTimerActive;

  /// Chip meaning the backup timer is not running
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get labelBackupTimerInactive;

  /// Row label for when the last automatic backup ran
  ///
  /// In en, this message translates to:
  /// **'Last scheduled run'**
  String get labelBackupLastScheduledRun;

  /// Button that turns automatic backups off
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get actionBackupDisable;

  /// Button that opens the automatic backup settings
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get actionBackupConfigure;

  /// Button that changes the existing backup schedule
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionBackupChange;

  /// Heading of the schedule settings form
  ///
  /// In en, this message translates to:
  /// **'Configure Schedule'**
  String get titleBackupConfigure;

  /// Label of the field choosing how often to back up
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get labelBackupInterval;

  /// Backup interval: once a day
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get labelBackupIntervalDaily;

  /// Backup interval: once a week
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get labelBackupIntervalWeekly;

  /// Backup interval: once a month
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get labelBackupIntervalMonthly;

  /// Label of the field for the password that encrypts a backup
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get labelBackupPassword;

  /// Helper text under the backup password field
  ///
  /// In en, this message translates to:
  /// **'Needed to encrypt'**
  String get labelBackupPasswordHelper;

  /// Empty state of the backup history list
  ///
  /// In en, this message translates to:
  /// **'No backup history'**
  String get emptyBackupNoHistory;

  /// Shown when the backup history cannot be read
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorBackupHistoryLoad(String error);

  /// Title of one row in the backup history
  ///
  /// In en, this message translates to:
  /// **'{trigger} backup — {status}'**
  String titleBackupLog(String trigger, String status);

  /// A backup the user started by hand
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get labelBackupTriggerManual;

  /// A backup the app started on a timer
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get labelBackupTriggerScheduled;

  /// A backup that finished
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get labelBackupStatusSuccess;

  /// A backup that did not finish
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get errorBackupStatus;

  /// A backup that is still running
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get labelBackupStatusInProgress;

  /// Summary of what one backup holds
  ///
  /// In en, this message translates to:
  /// **'{entries} entries, {attachments} attachments, {size}'**
  String descBackupLogCounts(int entries, int attachments, String size);

  /// Shown under a backup row that has not finished
  ///
  /// In en, this message translates to:
  /// **'In progress...'**
  String get bodyBackupInProgressNote;

  /// Confirmation after a backup finishes
  ///
  /// In en, this message translates to:
  /// **'Backup complete'**
  String get labelBackupSucceeded;

  /// Shown when a backup does not finish
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String errorBackup(String error);

  /// Title of the dialog asking for the backup password
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get titleBackupPassword;

  /// Label of the password field in the backup dialog
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get labelBackupPasswordEnter;

  /// Button that starts the backup after the password is typed
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get actionBackup;

  /// Shown when the backup password is left blank
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorBackupPassword;

  /// Confirmation after the backup schedule is saved
  ///
  /// In en, this message translates to:
  /// **'Schedule saved'**
  String get labelBackupScheduleSaved;

  /// Confirmation after automatic backups are turned off
  ///
  /// In en, this message translates to:
  /// **'Schedule turned off'**
  String get labelBackupScheduleDisabled;

  /// A file size in bytes
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String labelBackupBytes(int bytes);

  /// A file size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String labelBackupKilobytes(String size);

  /// A file size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String labelBackupMegabytes(String size);

  /// Button that brings back an earlier version
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionCommonRestore;

  /// Button that adds the thing just described into the entry
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get actionCommonInsert;

  /// Button that goes on to the next step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionCommonContinue;

  /// Button that opens the phone settings page for this app
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get actionCommonOpenSystemSettings;

  /// Placeholder inside an empty callout block
  ///
  /// In en, this message translates to:
  /// **'Enter callout text...'**
  String get descEditorCallout;

  /// Tooltip for the editor toolbar button that types a tab character
  ///
  /// In en, this message translates to:
  /// **'Insert tab'**
  String get tabEditorInsert;

  /// Tooltip, and dialog title, for adding a table
  ///
  /// In en, this message translates to:
  /// **'Insert table'**
  String get tooltipEditorInsertTable;

  /// Tooltip for adding a callout block
  ///
  /// In en, this message translates to:
  /// **'Insert callout'**
  String get tooltipEditorInsertCallout;

  /// Tooltip for adding a picture
  ///
  /// In en, this message translates to:
  /// **'Insert image'**
  String get tooltipEditorInsertImage;

  /// Tooltip on the menu that changes how wide a picture is
  ///
  /// In en, this message translates to:
  /// **'Image size'**
  String get tooltipEditorImageSize;

  /// Picture size: small
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get labelEditorImageSizeSmall;

  /// Picture size: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get labelEditorImageSizeMedium;

  /// Picture size: as wide as the page
  ///
  /// In en, this message translates to:
  /// **'Full width'**
  String get labelEditorImageSizeFull;

  /// Tooltip on the button that deletes a picture
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get tooltipEditorRemoveImage;

  /// Shown in place of a picture that cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get labelEditorImageUnavailable;

  /// Shown when recording is refused because the microphone is blocked
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get bodyEditorMicPermissionDenied;

  /// Button that throws away the recording just made
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionEditorDiscard;

  /// Button that keeps the recording just made
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionEditorDone;

  /// Title of the version history screen
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get titleVersionHistory;

  /// Shown when the list of earlier versions cannot be read
  ///
  /// In en, this message translates to:
  /// **'Error loading revisions: {error}'**
  String errorVersionHistoryLoad(String error);

  /// Title of the dialog confirming a restore
  ///
  /// In en, this message translates to:
  /// **'Restore this version?'**
  String get bodyVersionRestore;

  /// Confirmation after an earlier version is brought back
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get labelVersionRestored;

  /// Tooltip on the button that shows an earlier version without restoring it
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tooltipVersionPreview;

  /// Tooltip on the button that brings back an earlier version
  ///
  /// In en, this message translates to:
  /// **'Restore this version'**
  String get tooltipVersionRestore;

  /// Title of the screen previewing an earlier version
  ///
  /// In en, this message translates to:
  /// **'Preview: {title}'**
  String titleVersionPreview(String title);

  /// Confirmation after an entry is saved
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get labelEntrySaved;

  /// Title of the dialog confirming an entry is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get bodyEntryDelete;

  /// Warning in the delete-entry dialog.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the entry.'**
  String get bodyEntryDeleteBody;

  /// Label of the field for how many rows a new table has
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get labelEntryTableRows;

  /// Label of the field for how many columns a new table has
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get labelEntryTableColumns;

  /// Helper text saying the allowed range for table rows and columns
  ///
  /// In en, this message translates to:
  /// **'1–20'**
  String get labelEntryTableDimensionHelp;

  /// Title of the dialog choosing which kind of callout to add
  ///
  /// In en, this message translates to:
  /// **'Callout type'**
  String get titleEntryCalloutType;

  /// Callout kind: a neutral note
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get labelEntryCalloutInfo;

  /// Callout kind: a helpful suggestion
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get labelEntryCalloutTip;

  /// Callout kind: something to be careful about
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get bodyEntryCallout;

  /// Callout kind: something that must not be missed
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get labelEntryCalloutImportant;

  /// Confirmation after a voice note is stored, with its length
  ///
  /// In en, this message translates to:
  /// **'Voice note saved ({seconds}s)'**
  String labelEntryVoiceNoteSaved(String seconds);

  /// Title of the entry editor
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get titleEntryEdit;

  /// Title of the entry editor when there are unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Edit entry •'**
  String get titleEntryEditTitleDirty;

  /// Tooltip on the button that opens earlier versions of the entry
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get tooltipEntryVersionHistory;

  /// Tooltip on the button that deletes the entry
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get tooltipEntryDelete;

  /// Tooltip on the save button when there is something to save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipEntrySave;

  /// Tooltip on the save button when nothing has changed
  ///
  /// In en, this message translates to:
  /// **'No unsaved changes'**
  String get tooltipEntryNoUnsavedChanges;

  /// Label of the entry title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelEntryTitle;

  /// Title of the dialog asking for file access
  ///
  /// In en, this message translates to:
  /// **'Allow attachment import?'**
  String get bodyEntryPermission;

  /// Body of the dialog asking for file access
  ///
  /// In en, this message translates to:
  /// **'This app needs permission to access your files.'**
  String get bodyEntryPermissionBody;

  /// Title shown when file access was refused for good
  ///
  /// In en, this message translates to:
  /// **'Access blocked'**
  String get titleEntryPermissionBlocked;

  /// Body shown when file access was refused for good
  ///
  /// In en, this message translates to:
  /// **'Permission was permanently denied. Please enable it in system settings.'**
  String get bodyEntryPermissionBlocked;

  /// Shown when a non-image file is chosen for an inline picture
  ///
  /// In en, this message translates to:
  /// **'That file is not an image. Add it as an attachment instead.'**
  String get bodyEntryNotAnImage;

  /// Shown when adding an inline picture does not work
  ///
  /// In en, this message translates to:
  /// **'Could not add that image.'**
  String get errorEntryImageAdd;

  /// Tooltip on the button that attaches a file
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get tooltipEntryAddAttachment;

  /// Tooltip on the button that records a voice note
  ///
  /// In en, this message translates to:
  /// **'Record voice note'**
  String get tooltipEntryRecordVoiceNote;

  /// Heading above the entries that link to this one
  ///
  /// In en, this message translates to:
  /// **'Linked from'**
  String get titleEntryLinkedFrom;

  /// Tooltip for the button that opens the mood picker sheet
  ///
  /// In en, this message translates to:
  /// **'Set mood'**
  String get tooltipEntryMood;

  /// Heading of the mood picker
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get titleEntryMood;

  /// One mood choice: a face and its number
  ///
  /// In en, this message translates to:
  /// **'{face} {level}'**
  String labelEntryMood(String face, int level);

  /// Shown when an action needs the user to unlock first
  ///
  /// In en, this message translates to:
  /// **'Authentication required.'**
  String get errorEntryAuth;

  /// Shown when no installed app can open the attachment
  ///
  /// In en, this message translates to:
  /// **'No compatible app found'**
  String get bodyAttachmentOpenNoApp;

  /// Shown when the attachment cannot be decrypted
  ///
  /// In en, this message translates to:
  /// **'Could not decrypt attachment'**
  String get errorAttachmentOpenDecrypt;

  /// Shown when the stored attachment file cannot be found
  ///
  /// In en, this message translates to:
  /// **'Attachment file is missing'**
  String get bodyAttachmentOpenFileMissing;

  /// Shown when opening the attachment needs a permission that was refused
  ///
  /// In en, this message translates to:
  /// **'Permission required to open attachment'**
  String get bodyAttachmentOpenPermissionDenied;

  /// Heading above the entry attachment list
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get titleEntryAttachments;

  /// Tooltip on the button that unlocks one attachment
  ///
  /// In en, this message translates to:
  /// **'Remove lock'**
  String get tooltipEntryRemoveAttachmentLock;

  /// Tooltip on the button that locks one attachment
  ///
  /// In en, this message translates to:
  /// **'Lock attachment'**
  String get tooltipEntryLockAttachment;

  /// Tooltip on the button that opens one attachment
  ///
  /// In en, this message translates to:
  /// **'Open attachment'**
  String get tooltipEntryOpenAttachment;

  /// Body of the dialog confirming a restore
  ///
  /// In en, this message translates to:
  /// **'Your current content will be saved as a new version before restoring.'**
  String get bodyVersionRestoreBody;

  /// Button that unlocks something after the secret is entered
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get actionCommonUnlock;

  /// Label of a password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelCommonPassword;

  /// Button label while a save is running
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get bodyCommonSaving;

  /// Title of the first-launch lock setup screen
  ///
  /// In en, this message translates to:
  /// **'Set up app lock'**
  String get titleLockSetup;

  /// Explains the lock choice on first launch
  ///
  /// In en, this message translates to:
  /// **'Choose how SreerajP Journal Vault should lock when it is sent to the background.'**
  String get bodyLockSetup;

  /// Lock mode that reuses the device unlock
  ///
  /// In en, this message translates to:
  /// **'Phone Lock'**
  String get labelLockModePhone;

  /// Explains the phone lock mode
  ///
  /// In en, this message translates to:
  /// **'Use the device biometric or PIN/pattern/password.'**
  String get descLockModePhone;

  /// Lock mode with its own PIN inside the app
  ///
  /// In en, this message translates to:
  /// **'Separate App Lock'**
  String get labelLockModeApp;

  /// Explains the separate app lock mode
  ///
  /// In en, this message translates to:
  /// **'Use a dedicated PIN that is verified inside the app.'**
  String get descLockModeApp;

  /// Label of the PIN field
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get labelLockPin;

  /// Label of the field where the PIN is typed a second time
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get labelLockConfirmPin;

  /// Button label while the lock is being set up
  ///
  /// In en, this message translates to:
  /// **'Setting up...'**
  String get bodyLockSettingUp;

  /// Validation message for a PIN that is too short
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 characters.'**
  String get errorLockPin;

  /// Validation message when the two PIN fields differ
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get bodyLockPinsDoNotMatch;

  /// Shown when the lock setup cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save lock setup: {error}'**
  String errorLockSetupSave(String error);

  /// Shown when the PIN cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save PIN: {error}'**
  String errorLockPinSave(String error);

  /// Title of the screen and dialog that set the app-lock PIN
  ///
  /// In en, this message translates to:
  /// **'Set app-lock PIN'**
  String get titleLockPinSetup;

  /// Explains why a PIN is needed
  ///
  /// In en, this message translates to:
  /// **'Separate App Lock requires a PIN. Set one to continue.'**
  String get bodyLockPinSetup;

  /// Headline on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Journal is locked'**
  String get labelLockGateHeadline;

  /// Line under the headline on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Unlock to open your entries.'**
  String get descLockGate;

  /// Tooltip on the button that reveals the typed PIN
  ///
  /// In en, this message translates to:
  /// **'Show PIN'**
  String get tooltipLockGateShowPin;

  /// Tooltip on the button that hides the typed PIN
  ///
  /// In en, this message translates to:
  /// **'Hide PIN'**
  String get tooltipLockGateHidePin;

  /// Screen reader label for the lock icon on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get labelLockGateBadge;

  /// Button that unlocks using the device credential
  ///
  /// In en, this message translates to:
  /// **'Use phone lock'**
  String get actionLockUnlockWithPhone;

  /// Shown when the device unlock did not succeed
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get errorLockAuth;

  /// Shown when the device has no unlock method set up
  ///
  /// In en, this message translates to:
  /// **'Device authentication is not available. Configure a PIN/biometric in system settings.'**
  String get bodyLockAuthUnavailable;

  /// Shown when the PIN field is left blank
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN.'**
  String get bodyLockEnterPin;

  /// Shown when the typed PIN is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get bodyLockIncorrectPin;

  /// Title of the screen listing locked attachments
  ///
  /// In en, this message translates to:
  /// **'Locked attachments'**
  String get titleLockedAttachments;

  /// Empty state of the locked attachments screen
  ///
  /// In en, this message translates to:
  /// **'No attachments are locked yet. Open an entry and use the lock button on an attachment to require re-authentication before opening it.'**
  String get emptyLockedAttachments;

  /// Says when an attachment was locked
  ///
  /// In en, this message translates to:
  /// **'Locked {date}'**
  String labelLockedAttachmentSince(String date);

  /// Button that unlocks one attachment
  ///
  /// In en, this message translates to:
  /// **'Remove lock'**
  String get actionLockedAttachmentRemove;

  /// Navigation label, and title, for the home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Navigation label for the search tab
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Navigation label for the timeline tab
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// Navigation label for the insights tab
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// Navigation label, and title, for the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title of the dialog confirming a journal is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete journal?'**
  String get bodyJournalDelete;

  /// Confirmation question in the delete-journal dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String bodyJournalDeleteBody(String title);

  /// Tooltip on the button that opens the tag manager
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get tooltipJournalManageTags;

  /// Button, tooltip, and dialog title for creating a journal
  ///
  /// In en, this message translates to:
  /// **'New journal'**
  String get tooltipJournalNew;

  /// Dialog title, and tooltip, for changing a journal
  ///
  /// In en, this message translates to:
  /// **'Edit journal'**
  String get tooltipJournalEdit;

  /// Tooltip on the button that deletes a journal
  ///
  /// In en, this message translates to:
  /// **'Delete journal'**
  String get tooltipJournalDelete;

  /// Heading of the empty state on the home screen
  ///
  /// In en, this message translates to:
  /// **'No journals yet'**
  String get emptyJournal;

  /// Body of the empty state on the home screen
  ///
  /// In en, this message translates to:
  /// **'Tap “New journal” to start writing.'**
  String get emptyJournalEmptyBody;

  /// Label of the journal title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelJournalTitle;

  /// Label of the journal description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelJournalDescription;

  /// Label of the journal tags field
  ///
  /// In en, this message translates to:
  /// **'Comma-separated tags'**
  String get labelJournalTags;

  /// Switch that puts a password on a new journal
  ///
  /// In en, this message translates to:
  /// **'Lock journal'**
  String get labelJournalLockSwitch;

  /// Label of the field where the journal password is typed again
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelJournalConfirmPassword;

  /// Button that creates a new entry in this journal
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get actionJournalAddEntry;

  /// Shown in place of the entries of a locked journal
  ///
  /// In en, this message translates to:
  /// **'Journal is locked'**
  String get labelJournalIsLocked;

  /// Shown above the entries of a journal that has just been unlocked
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get labelJournalUnlocked;

  /// Shown when the journal password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get bodyJournalIncorrectPassword;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get titleSettingsSectionSecurity;

  /// One-line description under the security card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Lock mode, auto-lock, screenshots and security events'**
  String get descSettingsSectionSecurity;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get titleSettingsSectionAppearance;

  /// One-line description under the appearance card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Theme and how the app looks'**
  String get descSettingsSectionAppearance;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get titleSettingsSectionStorage;

  /// One-line description under the storage card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Attachment location, usage, backup and import'**
  String get descSettingsSectionStorage;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get titleSettingsSectionPermissions;

  /// One-line description under the permissions card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'What the app is allowed to use'**
  String get descSettingsSectionPermissions;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleSettingsSectionAbout;

  /// One-line description under the about card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Version, licences and app details'**
  String get descSettingsSectionAbout;

  /// Settings row introducing the two lock modes
  ///
  /// In en, this message translates to:
  /// **'App Lock Mode'**
  String get labelSettingsAppLockMode;

  /// Settings row that opens the auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Timeout'**
  String get labelSettingsAutoLockTimeout;

  /// Settings switch that blocks screenshots and screen recording
  ///
  /// In en, this message translates to:
  /// **'Block Screenshots'**
  String get labelSettingsScreenSecurity;

  /// Explains what the screenshot blocking switch covers
  ///
  /// In en, this message translates to:
  /// **'Stops screenshots, screen recording and the preview shown in the recent apps list'**
  String get descSettingsScreenSecurity;

  /// Title of the dialog shown before screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Turn off screenshot blocking?'**
  String get bodySettingsScreenSecurityOff;

  /// Warning text shown before screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Anyone taking a screenshot or recording the screen will be able to capture your journal content. The recent apps list will also show your last screen. You can turn this back on at any time.'**
  String get bodySettingsScreenSecurityOffBody;

  /// Confirm button that turns screenshot blocking off
  ///
  /// In en, this message translates to:
  /// **'Turn Off'**
  String get actionSettingsScreenSecurityOff;

  /// Message shown after screenshot blocking is turned on
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking is on'**
  String get bodySettingsScreenSecurityUpdatedOn;

  /// Message shown after screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking is off'**
  String get bodySettingsScreenSecurityUpdatedOff;

  /// Message shown when the screenshot blocking choice could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not change screenshot blocking'**
  String get errorSettingsScreenSecuritySave;

  /// Settings row for tamper alerts, not built yet
  ///
  /// In en, this message translates to:
  /// **'Tamper Alerts'**
  String get labelSettingsTamperAlerts;

  /// Settings row that opens the sync conflict list
  ///
  /// In en, this message translates to:
  /// **'Sync Conflicts'**
  String get labelSettingsSyncConflicts;

  /// Settings row that opens the security event log
  ///
  /// In en, this message translates to:
  /// **'Security Events'**
  String get labelSettingsSecurityEvents;

  /// Theme choice: light colours
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get labelSettingsThemeLight;

  /// Theme choice: dark colours
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get labelSettingsThemeDark;

  /// Theme choice: follow the device setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get labelSettingsThemeSystem;

  /// Title of the dialog confirming a lock mode change
  ///
  /// In en, this message translates to:
  /// **'Switch lock mode?'**
  String get bodySettingsSwitchLock;

  /// Explains what changing the lock mode does
  ///
  /// In en, this message translates to:
  /// **'This will switch app protection to {enabled} and disable {disabled}. Continue?'**
  String bodySettingsSwitchLockBody(String enabled, String disabled);

  /// Button that confirms the lock mode change
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get actionSettingsSwitch;

  /// Confirmation after the lock mode changes
  ///
  /// In en, this message translates to:
  /// **'Lock mode updated: {mode} is now active.'**
  String descSettingsLockModeUpdated(String mode);

  /// Shown when the theme choice cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save theme setting. Please try again.'**
  String get errorSettingsThemeSave;

  /// Confirmation after the theme changes
  ///
  /// In en, this message translates to:
  /// **'Theme updated: {mode} mode is now active.'**
  String descSettingsThemeUpdated(String mode);

  /// Title of the dialog confirming an attachment move
  ///
  /// In en, this message translates to:
  /// **'Migrate attachments?'**
  String get bodyStorageMigrate;

  /// Explains where attachments will be moved.
  ///
  /// In en, this message translates to:
  /// **'All attachments will be moved to {target}.'**
  String bodyStorageMigrateBody(String target);

  /// Button that starts moving the attachments
  ///
  /// In en, this message translates to:
  /// **'Migrate'**
  String get actionStorageMigrate;

  /// Shown when the user stops the move
  ///
  /// In en, this message translates to:
  /// **'Migration cancelled.'**
  String get bodyStorageMigrationCancelled;

  /// Shown when the move does not finish
  ///
  /// In en, this message translates to:
  /// **'Migration failed: {error}'**
  String errorStorageMigration(String error);

  /// Shown when the move finishes
  ///
  /// In en, this message translates to:
  /// **'Migration complete.'**
  String get bodyStorageMigrationComplete;

  /// Settings row showing where attachments are kept
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get titleStorageLocation;

  /// Title of the dialog choosing where attachments are kept
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get titleStorageLocationDialogTitle;

  /// Storage choice: the app private folder
  ///
  /// In en, this message translates to:
  /// **'App Private'**
  String get labelStorageAppPrivate;

  /// Storage choice: the SD card
  ///
  /// In en, this message translates to:
  /// **'SD Card'**
  String get labelStorageSdCard;

  /// The SD card choice, with the chosen folder name
  ///
  /// In en, this message translates to:
  /// **'SD Card ({label})'**
  String labelStorageSdCardNamed(String label);

  /// Settings row that moves attachments between locations
  ///
  /// In en, this message translates to:
  /// **'Migrate Storage'**
  String get labelStorageMigrateRow;

  /// Migration state: nothing is happening
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get labelStorageMigrationIdle;

  /// Migration state: how far it has got
  ///
  /// In en, this message translates to:
  /// **'Migrating {processed} of {total}…'**
  String descStorageMigrationRunning(int processed, int total);

  /// Migration state: the last attempt did not finish
  ///
  /// In en, this message translates to:
  /// **'Migration failed.'**
  String get descStorageMigrationFailedShort;

  /// Settings row showing how much space attachments use
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get labelStorageUsage;

  /// Placeholder shown when a value is not known yet
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get bodyStorageUnknown;

  /// Settings row that opens the backup health screen
  ///
  /// In en, this message translates to:
  /// **'Backup Health'**
  String get labelStorageBackupHealth;

  /// Settings row that opens the import screen
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get labelStorageImportData;

  /// Settings row, and screen title, for the sync health dashboard
  ///
  /// In en, this message translates to:
  /// **'Sync Health'**
  String get titleStorageSyncHealth;

  /// Shown when there is nothing to import into
  ///
  /// In en, this message translates to:
  /// **'Create a journal first to import into.'**
  String get bodyStorageImportNeedsJournal;

  /// Title of the dialog choosing where to import
  ///
  /// In en, this message translates to:
  /// **'Import into journal'**
  String get titleStorageImportChooseJournal;

  /// A size in bytes
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String labelStorageBytes(int bytes);

  /// A size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String labelStorageKilobytes(String size);

  /// A size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String labelStorageMegabytes(String size);

  /// A size in gigabytes
  ///
  /// In en, this message translates to:
  /// **'{size} GB'**
  String labelStorageGigabytes(String size);

  /// Title of the dialog shown while attachments are being moved
  ///
  /// In en, this message translates to:
  /// **'Moving attachments'**
  String get titleMigration;

  /// Shown while the move is being stopped
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get bodyMigrationCancelling;

  /// How many attachments have been moved so far. Both values are passed as text because the total is shown as '?' while it is still unknown.
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total}'**
  String labelMigrationProgress(String processed, String total);

  /// Placeholder used when the total is not known yet
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get descMigrationUnknownTotal;

  /// Row label showing whether a permission is granted.
  ///
  /// In en, this message translates to:
  /// **'Permission Status'**
  String get labelPermissionStatusRow;

  /// Settings row that opens the permissions screen
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get labelPermissionsManage;

  /// Settings row that opens the phone settings page
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get labelPermissionsOpenSystem;

  /// How many permissions are granted
  ///
  /// In en, this message translates to:
  /// **'{granted} of {total} granted'**
  String descPermissionsGranted(int granted, int total);

  /// Placeholder in the search field
  ///
  /// In en, this message translates to:
  /// **'Search journals & entries...'**
  String get descSearch;

  /// Shown before anything has been typed
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get actionSearchTypeToSearch;

  /// Shown when the entry filter finds nothing
  ///
  /// In en, this message translates to:
  /// **'No matches found for this filter.'**
  String get bodySearchNoFilterMatches;

  /// Shown when the search finds nothing
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptySearch;

  /// Heading above matching journals
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get titleSearchSectionJournals;

  /// Heading above matching entries
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get titleSearchSectionEntries;

  /// Title of the dialog that names a saved search
  ///
  /// In en, this message translates to:
  /// **'Save search preset'**
  String get titleSearchSavePreset;

  /// Label of the field naming a saved search
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get labelSearchPresetName;

  /// Title of the restore screen
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get titleRestore;

  /// Row in Backup Health that opens the restore screen
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get actionRestoreOpen;

  /// Heading shown while the restore screen is locked
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get titleRestoreLocked;

  /// Explains why the restore screen asks to unlock first
  ///
  /// In en, this message translates to:
  /// **'Restoring changes your journal, so it is protected the same way the app is.'**
  String get bodyRestoreLocked;

  /// Button that starts the unlock check on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get actionRestoreUnlock;

  /// Reason shown in the system fingerprint or PIN prompt
  ///
  /// In en, this message translates to:
  /// **'Unlock to restore'**
  String get labelRestoreUnlockReason;

  /// Message after a failed unlock on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Could not unlock. Nothing was changed.'**
  String get errorRestoreUnlock;

  /// Label of the PIN field on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN'**
  String get labelRestoreEnterPin;

  /// Message shown when the entered PIN does not match
  ///
  /// In en, this message translates to:
  /// **'That PIN is not right.'**
  String get bodyRestorePinWrong;

  /// Heading above the list of backup files
  ///
  /// In en, this message translates to:
  /// **'Choose a backup'**
  String get titleRestorePick;

  /// Button that opens the file picker to find a backup
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get actionRestorePickFromDevice;

  /// Shown when the app has no backup files of its own
  ///
  /// In en, this message translates to:
  /// **'No backups made by this app were found. You can still choose a file.'**
  String get bodyRestoreNoBackupsFound;

  /// Shows which backup file the user picked
  ///
  /// In en, this message translates to:
  /// **'Selected: {fileName}'**
  String labelRestoreSelectedFile(String fileName);

  /// Label of the field asking for the backup password
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get labelRestorePassword;

  /// Helper text under the backup password field
  ///
  /// In en, this message translates to:
  /// **'The password used when this backup was made.'**
  String get bodyRestorePasswordHelper;

  /// Button that decrypts the chosen backup and shows a preview
  ///
  /// In en, this message translates to:
  /// **'Open backup'**
  String get actionRestoreOpenBackup;

  /// Heading of the preview card
  ///
  /// In en, this message translates to:
  /// **'Backup contents'**
  String get titleRestorePreview;

  /// When the backup was created
  ///
  /// In en, this message translates to:
  /// **'Made on {date}'**
  String labelRestorePreviewCreated(String date);

  /// Row counts held in the backup
  ///
  /// In en, this message translates to:
  /// **'{journals} journals, {entries} entries, {attachments} attachments'**
  String bodyRestorePreviewCounts(int journals, int entries, int attachments);

  /// Warning shown for a format version 1 backup
  ///
  /// In en, this message translates to:
  /// **'This is an older backup. Its attachments only open on the device that made it.'**
  String get bodyRestoreLegacyAttachments;

  /// Heading above the replace and merge choice
  ///
  /// In en, this message translates to:
  /// **'How should it be restored?'**
  String get bodyRestoreMode;

  /// Name of the merge restore mode
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get actionRestoreModeMerge;

  /// Explains the merge restore mode
  ///
  /// In en, this message translates to:
  /// **'Add what is missing and keep everything you have now.'**
  String get descRestoreModeMergeDetail;

  /// Name of the replace restore mode
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get actionRestoreModeReplace;

  /// Explains the replace restore mode
  ///
  /// In en, this message translates to:
  /// **'Delete what is here now and use the backup instead. A safety backup is taken first.'**
  String get descRestoreModeReplaceDetail;

  /// Button that runs the restore without writing anything
  ///
  /// In en, this message translates to:
  /// **'Try it first'**
  String get actionRestoreDryRun;

  /// Helper text under the dry run button
  ///
  /// In en, this message translates to:
  /// **'Shows what would change without changing anything.'**
  String get bodyRestoreDryRunHelper;

  /// Button that performs the restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// Title of the dialog confirming a replace
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get bodyRestoreConfirmReplace;

  /// Body of the dialog confirming a replace
  ///
  /// In en, this message translates to:
  /// **'Every journal, entry and attachment on this device will be deleted and replaced by the backup. A safety backup of what is here now is taken first.'**
  String get bodyRestoreConfirmReplaceBody;

  /// Title of the dialog confirming a merge
  ///
  /// In en, this message translates to:
  /// **'Merge this backup?'**
  String get bodyRestoreConfirmMerge;

  /// Body of the dialog confirming a merge
  ///
  /// In en, this message translates to:
  /// **'Anything the backup holds that is missing here will be added. Nothing is deleted.'**
  String get bodyRestoreConfirmMergeBody;

  /// Title of the dialog reporting a dry run
  ///
  /// In en, this message translates to:
  /// **'What would happen'**
  String get titleRestoreDryRunResult;

  /// Title of the dialog reporting a finished restore
  ///
  /// In en, this message translates to:
  /// **'Restore finished'**
  String get titleRestoreResult;

  /// How many rows were added
  ///
  /// In en, this message translates to:
  /// **'Added: {count} rows'**
  String labelRestoreResultAdded(int count);

  /// How many rows were skipped as already present
  ///
  /// In en, this message translates to:
  /// **'Already here: {count} rows'**
  String labelRestoreResultSkipped(int count);

  /// How many attachment files were restored
  ///
  /// In en, this message translates to:
  /// **'Attachment files restored: {count}'**
  String descRestoreResultFiles(int count);

  /// How many attachment files failed
  ///
  /// In en, this message translates to:
  /// **'Attachment files that could not be restored: {count}'**
  String errorRestoreResultFiles(int count);

  /// Tells the user a pre-restore backup exists
  ///
  /// In en, this message translates to:
  /// **'A safety backup of your previous data was saved first.'**
  String get descRestoreResultSafetyBackup;

  /// Message when the backup cannot be decrypted
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the backup file is damaged.'**
  String get bodyRestoreErrorWrongPassword;

  /// Message when the archive cannot be read
  ///
  /// In en, this message translates to:
  /// **'This file is not a backup, or it is damaged.'**
  String get bodyRestoreErrorDamaged;

  /// Message when the backup comes from a newer build
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of the app. Update the app and try again.'**
  String get bodyRestoreErrorTooNew;

  /// Message when the entered password is too short
  ///
  /// In en, this message translates to:
  /// **'The backup password must be at least 8 characters.'**
  String get errorRestoreErrorPassword;

  /// Message when a restore fails and rolls back
  ///
  /// In en, this message translates to:
  /// **'The restore failed and nothing was changed: {error}'**
  String errorRestoreError(String error);

  /// Shown while a restore or preview is running
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get bodyRestoreWorking;

  /// Switch that encrypts the exported file
  ///
  /// In en, this message translates to:
  /// **'Password protect'**
  String get titleExportProtect;

  /// Explains what the export password switch does
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted with your password. It can be opened again in this app, on any device.'**
  String get descExportProtect;

  /// Label of the export password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelExportPassword;

  /// Label of the second export password field
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get labelExportPasswordConfirm;

  /// Error when the export password is too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String errorExportPassword(int count);

  /// Error when the two export password fields differ
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match.'**
  String get errorExportPasswordMismatch;

  /// Warning shown when an export will be encrypted
  ///
  /// In en, this message translates to:
  /// **'Keep this password somewhere safe. Without it the exported file cannot be opened again, by anyone, including you.'**
  String get bodyExportEncryptedNotice;

  /// Title of the screen that decrypts an exported file
  ///
  /// In en, this message translates to:
  /// **'Open encrypted file'**
  String get titleOpenEncrypted;

  /// Explains what the open-encrypted-export screen does
  ///
  /// In en, this message translates to:
  /// **'Choose an encrypted export file, enter its password, and save the file inside it.'**
  String get descOpenEncryptedIntro;

  /// Button that opens the file picker
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get actionOpenEncryptedPickFile;

  /// Shows which file was chosen
  ///
  /// In en, this message translates to:
  /// **'Chosen: {fileName}'**
  String labelOpenEncryptedChosenFile(String fileName);

  /// Label of the password field on the open-encrypted screen
  ///
  /// In en, this message translates to:
  /// **'File password'**
  String get labelOpenEncryptedPassword;

  /// Button that decrypts the file and saves the result
  ///
  /// In en, this message translates to:
  /// **'Open and save'**
  String get actionOpenEncrypted;

  /// Shown while the file is being decrypted
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get bodyOpenEncryptedWorking;

  /// Title of the system save dialog for a decrypted export
  ///
  /// In en, this message translates to:
  /// **'Save the opened file'**
  String get titleOpenEncryptedSave;

  /// Confirmation after a decrypted export is written out
  ///
  /// In en, this message translates to:
  /// **'Saved. The file is no longer encrypted, so keep it somewhere safe.'**
  String get descOpenEncryptedSaved;

  /// Shown when the user backs out of the save dialog
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved.'**
  String get bodyOpenEncryptedCancelled;

  /// Error when the password does not open the file
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the file is damaged.'**
  String get errorOpenEncryptedErrorWrongPassword;

  /// Error when the chosen file has no envelope
  ///
  /// In en, this message translates to:
  /// **'This is not an encrypted export made by this app.'**
  String get errorOpenEncryptedErrorNotSealed;

  /// Error when the file uses a newer envelope
  ///
  /// In en, this message translates to:
  /// **'This file was made by a newer version of the app. Update the app and try again.'**
  String get errorOpenEncryptedErrorTooNew;

  /// Error when decrypting fails for any other reason
  ///
  /// In en, this message translates to:
  /// **'The file could not be opened.'**
  String get errorOpenEncryptedError;

  /// Settings tile that opens the decrypt screen
  ///
  /// In en, this message translates to:
  /// **'Open encrypted file'**
  String get actionSettingsOpenEncryptedExport;

  /// Title of the dialog that picks a starter template
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get titleTemplateChooser;

  /// Shown when an entry has no recorded revision history
  ///
  /// In en, this message translates to:
  /// **'No previous versions yet.\n\nVersions are saved automatically when you edit an entry.'**
  String get emptyVersionHistory;

  /// Stroke width option: 2px
  ///
  /// In en, this message translates to:
  /// **'Fine (2px)'**
  String get labelDrawingStrokeFine;

  /// Stroke width option: 3.5px
  ///
  /// In en, this message translates to:
  /// **'Normal (3.5px)'**
  String get labelDrawingStrokeNormal;

  /// Stroke width option: 7px
  ///
  /// In en, this message translates to:
  /// **'Thick (7px)'**
  String get labelDrawingStrokeThick;

  /// Stroke width option: 14px
  ///
  /// In en, this message translates to:
  /// **'Bold (14px)'**
  String get labelDrawingStrokeBold;

  /// Default fallback title for full screen drawing viewer
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get titleDrawingDefault;

  /// Default fallback title for full screen image viewer
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get titleImageDefault;

  /// Placeholder message for locked image embed
  ///
  /// In en, this message translates to:
  /// **'Locked image — tap to unlock'**
  String get bodyEditorImageLocked;

  /// Placeholder message for missing image with file name
  ///
  /// In en, this message translates to:
  /// **'Image unavailable — {fileName}'**
  String bodyEditorImageUnavailableWithName(String fileName);

  /// Tooltip to pause audio playback
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get tooltipAudioPause;

  /// Tooltip to play audio playback
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get tooltipAudioPlay;

  /// Header indicating destination journal for import
  ///
  /// In en, this message translates to:
  /// **'Import into \"{journalTitle}\"'**
  String titleImportIntoJournal(String journalTitle);

  /// Supported import file formats description
  ///
  /// In en, this message translates to:
  /// **'Supported formats: {formats}'**
  String labelImportSupportedFormats(String formats);

  /// Supported import file extensions label
  ///
  /// In en, this message translates to:
  /// **'Files: {extensions}'**
  String labelImportSupportedExtensions(String extensions);

  /// Placeholder message prompting user to select files for import
  ///
  /// In en, this message translates to:
  /// **'Select files to import as new entries'**
  String get bodyImportSelectFilesPrompt;

  /// Category name for journaling features
  ///
  /// In en, this message translates to:
  /// **'Journaling & Rich Text Editor'**
  String get labelFeaturesCategoryJournaling;

  /// Category subtitle for journaling features
  ///
  /// In en, this message translates to:
  /// **'Expressive writing, structured templates, OCR, and rich media'**
  String get descFeaturesCategoryJournaling;

  /// Category name for security features
  ///
  /// In en, this message translates to:
  /// **'Privacy, Encryption & Vault Security'**
  String get descFeaturesCategorySecurity;

  /// Category subtitle for security features
  ///
  /// In en, this message translates to:
  /// **'Guaranteed zero-leak encryption and granular security controls'**
  String get descFeaturesCategorySecuritySubtitle;

  /// Category name for search and timeline features
  ///
  /// In en, this message translates to:
  /// **'Search, Timeline & Insights'**
  String get labelFeaturesCategoryDiscovery;

  /// Category subtitle for search and timeline features
  ///
  /// In en, this message translates to:
  /// **'Blazing fast search, deep calendar navigation, and writing habits'**
  String get descFeaturesCategoryDiscovery;

  /// Category name for storage and backup features
  ///
  /// In en, this message translates to:
  /// **'Storage, Backups & Multi-Format Export'**
  String get descFeaturesCategoryStorage;

  /// Category subtitle for storage and backup features
  ///
  /// In en, this message translates to:
  /// **'Total data sovereignty with local backups and flexible exports'**
  String get descFeaturesCategoryStorageSubtitle;

  /// Feature title: Quill rich text editor
  ///
  /// In en, this message translates to:
  /// **'Quill Rich Text Editor'**
  String get titleFeatureQuill;

  /// Feature description: Quill rich text editor
  ///
  /// In en, this message translates to:
  /// **'Write entries with rich formatting including headings, bulleted & numbered lists, bold, italics, underlines, and inline blockquotes.'**
  String get descFeatureQuill;

  /// Feature title: Structured entry templates
  ///
  /// In en, this message translates to:
  /// **'Structured Entry Templates'**
  String get titleFeatureTemplates;

  /// Feature description: Structured entry templates
  ///
  /// In en, this message translates to:
  /// **'Jumpstart your writing with 8 customizable templates: Daily Reflection, Gratitude, Dream Journal, Workout Log, Travel Diary, Meeting Notes, Bullet Journal, and Freeform.'**
  String get descFeatureTemplates;

  /// Feature title: Encrypted media attachments and OCR
  ///
  /// In en, this message translates to:
  /// **'Encrypted Media Attachments & OCR'**
  String get bodyFeatureMediaOcr;

  /// Feature description: Encrypted media attachments and OCR
  ///
  /// In en, this message translates to:
  /// **'Attach photos, audio recordings, and documents encrypted on device. Extract text directly from images into your journal with offline OCR.'**
  String get descFeatureMediaOcr;

  /// Feature title: Color-coded tags and tag manager
  ///
  /// In en, this message translates to:
  /// **'Color-Coded Tags & Tag Manager'**
  String get titleFeatureTags;

  /// Feature description: Color-coded tags and tag manager
  ///
  /// In en, this message translates to:
  /// **'Organize entries and journals with vibrant color-coded tags. Rename, color, or bulk-manage tags effortlessly in the Tag Manager.'**
  String get descFeatureTags;

  /// Feature title: Multiple distinct journals
  ///
  /// In en, this message translates to:
  /// **'Multiple Distinct Journals'**
  String get titleFeatureMultiJournal;

  /// Feature description: Multiple distinct journals
  ///
  /// In en, this message translates to:
  /// **'Create multiple separate journals for work, personal diaries, travel adventures, or creative projects, each with custom tags and settings.'**
  String get descFeatureMultiJournal;

  /// Feature title: SQLCipher database encryption
  ///
  /// In en, this message translates to:
  /// **'SQLCipher AES-256 Database Encryption'**
  String get bodyFeatureSqlcipher;

  /// Feature description: SQLCipher database encryption
  ///
  /// In en, this message translates to:
  /// **'All journal data, entries, metadata, and tables are encrypted at rest using SQLCipher with AES-256-GCM. Unencrypted data is never written to disk.'**
  String get descFeatureSqlcipher;

  /// Feature title: Biometrics and App PIN
  ///
  /// In en, this message translates to:
  /// **'Biometric & App PIN Lock'**
  String get titleFeatureBiometrics;

  /// Feature description: Biometrics and App PIN
  ///
  /// In en, this message translates to:
  /// **'Secure your vault with your device fingerprint or face unlock, or set a dedicated App PIN. The app re-locks automatically whenever you switch apps.'**
  String get descFeatureBiometrics;

  /// Feature title: Per-journal password locks
  ///
  /// In en, this message translates to:
  /// **'Per-Journal Password Locks'**
  String get titleFeatureJournalLock;

  /// Feature description: Per-journal password locks
  ///
  /// In en, this message translates to:
  /// **'Lock specific sensitive journals behind individual passwords using PBKDF2 key derivation. Locked journals require password entry each session.'**
  String get descFeatureJournalLock;

  /// Feature title: Attachment encryption locks
  ///
  /// In en, this message translates to:
  /// **'Attachment-Level Encryption Locks'**
  String get bodyFeatureAttachmentLock;

  /// Feature description: Attachment encryption locks
  ///
  /// In en, this message translates to:
  /// **'Individually lock and hide sensitive attachments and photos with separate encryption keys, keeping them private even when browsing entries.'**
  String get descFeatureAttachmentLock;

  /// Feature title: Screenshot guard
  ///
  /// In en, this message translates to:
  /// **'Screenshot & Screen-Recording Guard'**
  String get bodyFeatureScreenshotGuard;

  /// Feature description: Screenshot guard
  ///
  /// In en, this message translates to:
  /// **'Automatic FLAG_SECURE window defense blocks malicious screenshot capture, screen recording apps, and recents app switcher snapshot leaking.'**
  String get descFeatureScreenshotGuard;

  /// Feature title: Tamper audit log
  ///
  /// In en, this message translates to:
  /// **'Tamper-Evident Security Audit Log'**
  String get bodyFeatureTamperAudit;

  /// Feature description: Tamper audit log
  ///
  /// In en, this message translates to:
  /// **'Monitors and logs key security events: app unlock attempts, failed biometric/PIN authentications, password changes, and export actions.'**
  String get descFeatureTamperAudit;

  /// Feature title: Auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Inactivity Profiles'**
  String get titleFeatureAutoLock;

  /// Feature description: Auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Configure custom timeout durations (immediate, 30 seconds, 1 min, 5 min) to automatically relock your journal vault when idle.'**
  String get descFeatureAutoLock;

  /// Feature title: SQLite FTS search
  ///
  /// In en, this message translates to:
  /// **'Lightning SQLite FTS Search'**
  String get titleFeatureFtsSearch;

  /// Feature description: SQLite FTS search
  ///
  /// In en, this message translates to:
  /// **'Instant full-text search indexing scans every entry body, title, tag, and metadata with SQLite FTS5 for sub-millisecond query results.'**
  String get descFeatureFtsSearch;

  /// Feature title: Saved search presets
  ///
  /// In en, this message translates to:
  /// **'Saved Search Presets'**
  String get titleFeatureSearchPresets;

  /// Feature description: Saved search presets
  ///
  /// In en, this message translates to:
  /// **'Save frequent queries with date range and tag filters as one-tap quick filter chips directly accessible from the search bar.'**
  String get descFeatureSearchPresets;

  /// Feature title: Calendar timeline explorer
  ///
  /// In en, this message translates to:
  /// **'Interactive Calendar Timeline Explorer'**
  String get bodyFeatureTimeline;

  /// Feature description: Calendar timeline explorer
  ///
  /// In en, this message translates to:
  /// **'Navigate your entire journal history with a smooth calendar view, visual daily entry dots, day-by-day browsing, and quick date jumping.'**
  String get descFeatureTimeline;

  /// Feature title: Writing trends and insights
  ///
  /// In en, this message translates to:
  /// **'Writing Trends & Habit Insights'**
  String get titleFeatureInsights;

  /// Feature description: Writing trends and insights
  ///
  /// In en, this message translates to:
  /// **'Track your daily writing streaks, word counts, active writing days per month, and top tag distributions with offline analytical charts.'**
  String get descFeatureInsights;

  /// Feature title: Attachment storage migration
  ///
  /// In en, this message translates to:
  /// **'Attachment Storage Migration (SD Card)'**
  String get bodyFeatureStorageMigration;

  /// Feature description: Attachment storage migration
  ///
  /// In en, this message translates to:
  /// **'Seamlessly migrate all encrypted attachments between internal app storage and removable SD Card memory without interrupting journal access.'**
  String get descFeatureStorageMigration;

  /// Feature title: Encrypted vault backups
  ///
  /// In en, this message translates to:
  /// **'Encrypted Vault Backups (.jvbk)'**
  String get titleFeatureEncryptedBackups;

  /// Feature description: Encrypted vault backups
  ///
  /// In en, this message translates to:
  /// **'Export and restore complete password-protected .jvbk backup archives containing your database, attachments, tags, and settings.'**
  String get descFeatureEncryptedBackups;

  /// Feature title: Formatted multi-format export
  ///
  /// In en, this message translates to:
  /// **'Formatted Multi-Format Export'**
  String get titleFeatureMultiExport;

  /// Feature description: Formatted multi-format export
  ///
  /// In en, this message translates to:
  /// **'Export individual entries or complete journals into clean formatted PDF, Markdown zip archive, or raw JSON data formats.'**
  String get descFeatureMultiExport;

  /// Feature title: Standalone encrypted reader
  ///
  /// In en, this message translates to:
  /// **'Standalone Encrypted Export Reader'**
  String get bodyFeatureEncryptedReader;

  /// Feature description: Standalone encrypted reader
  ///
  /// In en, this message translates to:
  /// **'Read password-protected encrypted journal exports independently inside the app without needing to restore the full backup database.'**
  String get descFeatureEncryptedReader;

  /// Help topic title: Journal organization & templates
  ///
  /// In en, this message translates to:
  /// **'Journal Organization & Templates'**
  String get helpTopicJournalOrg;

  /// Help topic subtitle: Journal organization & templates
  ///
  /// In en, this message translates to:
  /// **'How multiple journals, starter prompts, and Quill rich text formatting work.'**
  String get helpTopicJournalOrgSubtitle;

  /// Help topic title: Attachments & OCR scanner
  ///
  /// In en, this message translates to:
  /// **'Attachments & OCR Scanner'**
  String get helpTopicAttachmentsOcr;

  /// Help topic subtitle: Attachments & OCR scanner
  ///
  /// In en, this message translates to:
  /// **'On-device offline OCR text recognition from images and encrypted media storage.'**
  String get helpTopicAttachmentsOcrSubtitle;

  /// Help topic title: Tags & color coding
  ///
  /// In en, this message translates to:
  /// **'Tags & Color Coding'**
  String get helpTopicTags;

  /// Help topic subtitle: Tags & color coding
  ///
  /// In en, this message translates to:
  /// **'Categorizing entries, custom tag color palettes, and global tag management.'**
  String get helpTopicTagsSubtitle;

  /// Help topic title: Encryption & keystore security
  ///
  /// In en, this message translates to:
  /// **'Encryption & Keystore Security'**
  String get helpTopicEncryption;

  /// Help topic subtitle: Encryption & keystore security
  ///
  /// In en, this message translates to:
  /// **'SQLCipher database encryption at rest, Android Keystore keys, and offline guarantees.'**
  String get helpTopicEncryptionSubtitle;

  /// Help topic title: App lock, biometrics & PIN
  ///
  /// In en, this message translates to:
  /// **'App Lock, Biometrics & PIN'**
  String get helpTopicBiometrics;

  /// Help topic subtitle: App lock, biometrics & PIN
  ///
  /// In en, this message translates to:
  /// **'Fingerprint and face unlock, custom App PIN setup, and auto-lock timeouts.'**
  String get helpTopicBiometricsSubtitle;

  /// Help topic title: Per-journal & attachment locks
  ///
  /// In en, this message translates to:
  /// **'Per-Journal & Attachment Locks'**
  String get helpTopicJournalLocks;

  /// Help topic subtitle: Per-journal & attachment locks
  ///
  /// In en, this message translates to:
  /// **'Individual journal password locks, session unlocking, and attachment-level locks.'**
  String get helpTopicJournalLocksSubtitle;

  /// Help topic title: Screenshot guard & audit trail
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard & Audit Trail'**
  String get helpTopicScreenshotAudit;

  /// Help topic subtitle: Screenshot guard & audit trail
  ///
  /// In en, this message translates to:
  /// **'FLAG_SECURE window defense, task switcher masking, and local security audit events.'**
  String get helpTopicScreenshotAuditSubtitle;

  /// Help topic title: Full-text search & timeline
  ///
  /// In en, this message translates to:
  /// **'Full-Text Search & Timeline'**
  String get helpTopicSearchTimeline;

  /// Help topic subtitle: Full-text search & timeline
  ///
  /// In en, this message translates to:
  /// **'SQLite FTS keyword search, saved search presets, and interactive calendar navigation.'**
  String get helpTopicSearchTimelineSubtitle;

  /// Help topic title: Writing insights & trends
  ///
  /// In en, this message translates to:
  /// **'Writing Insights & Trends'**
  String get helpTopicInsights;

  /// Help topic subtitle: Writing insights & trends
  ///
  /// In en, this message translates to:
  /// **'Habit streaks, word count statistics, monthly activity graphs, and tag analytics.'**
  String get helpTopicInsightsSubtitle;

  /// Help topic title: Storage locations & SD card
  ///
  /// In en, this message translates to:
  /// **'Storage Locations & SD Card'**
  String get helpTopicStorageMigration;

  /// Help topic subtitle: Storage locations & SD card
  ///
  /// In en, this message translates to:
  /// **'Moving encrypted media attachments between internal app storage and SD Card memory.'**
  String get helpTopicStorageMigrationSubtitle;

  /// Help topic title: Encrypted backups & restore
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backups & Restore'**
  String get helpTopicBackupRestore;

  /// Help topic subtitle: Encrypted backups & restore
  ///
  /// In en, this message translates to:
  /// **'Creating password-protected .jvbk backup files, health checks, and restoring on a new device.'**
  String get helpTopicBackupRestoreSubtitle;

  /// Help topic title: Export formats & reader
  ///
  /// In en, this message translates to:
  /// **'Export Formats & Reader'**
  String get helpTopicExportFormats;

  /// Help topic subtitle: Export formats & reader
  ///
  /// In en, this message translates to:
  /// **'Exporting to formatted PDF, Markdown zip, JSON, and using the built-in encrypted reader.'**
  String get helpTopicExportFormatsSubtitle;

  /// Help topic title: FAQs & troubleshooting
  ///
  /// In en, this message translates to:
  /// **'FAQs & Troubleshooting'**
  String get helpTopicFaq;

  /// Help topic subtitle: FAQs & troubleshooting
  ///
  /// In en, this message translates to:
  /// **'Answers about offline privacy, permissions, passcode recovery policies, and device transfers.'**
  String get helpTopicFaqSubtitle;

  /// Introduction for attachments and OCR help
  ///
  /// In en, this message translates to:
  /// **'Enrich your journal entries with photos, audio notes, and documents. Extract printed or handwritten text directly using offline OCR text recognition.'**
  String get helpAttachmentsIntro;

  /// Section header for on-device OCR
  ///
  /// In en, this message translates to:
  /// **'On-Device OCR Text Extraction'**
  String get helpAttachmentsSectionOcr;

  /// Help bullet for OCR camera
  ///
  /// In en, this message translates to:
  /// **'Tap the camera/scanner icon in the editor to capture a photo of a book, document, or written note.'**
  String get helpAttachmentsOcrBullet1;

  /// Help bullet for OCR privacy and speed
  ///
  /// In en, this message translates to:
  /// **'The built-in on-device OCR engine detects and parses text in seconds without sending a single byte to external servers.'**
  String get helpAttachmentsOcrBullet2;

  /// Help bullet for OCR insertion
  ///
  /// In en, this message translates to:
  /// **'Extracted text is automatically formatted and inserted right at your current cursor position.'**
  String get helpAttachmentsOcrBullet3;

  /// Section header for attachment encryption
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM Attachment Encryption'**
  String get helpAttachmentsSectionEncryption;

  /// Help bullet for attachment encryption
  ///
  /// In en, this message translates to:
  /// **'All media attachments are encrypted using AES-256-GCM before writing to storage. Stored files cannot be opened by gallery apps or file managers without the app.'**
  String get helpAttachmentsEncryptionBullet1;

  /// Footer note for OCR privacy
  ///
  /// In en, this message translates to:
  /// **'Privacy Guarantee: All OCR text extraction runs entirely offline on your device with 100% privacy.'**
  String get helpAttachmentsFooter;

  /// Introduction for backup and restore help
  ///
  /// In en, this message translates to:
  /// **'Keep your journal safe across device upgrades or system resets with encrypted .jvbk backup archives.'**
  String get helpBackupIntro;

  /// Section header for creating backup
  ///
  /// In en, this message translates to:
  /// **'Creating an Encrypted Backup (.jvbk)'**
  String get helpBackupSectionCreate;

  /// Help bullet for creating backup step 1
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Storage → Backup & Restore → Create Backup.'**
  String get helpBackupCreateBullet1;

  /// Help bullet for backup password
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password. This password encrypts both the database and all media attachments.'**
  String get helpBackupCreateBullet2;

  /// Help bullet for saving backup file
  ///
  /// In en, this message translates to:
  /// **'Save the resulting .jvbk file to your desired folder, cloud storage, or external USB drive.'**
  String get helpBackupCreateBullet3;

  /// Section header for restoring backup
  ///
  /// In en, this message translates to:
  /// **'Restoring on a New Device'**
  String get helpBackupSectionRestore;

  /// Help bullet for restore step 1
  ///
  /// In en, this message translates to:
  /// **'Install SreerajP Journal Vault on your new device and open Settings → Storage → Restore Backup.'**
  String get helpBackupRestoreBullet1;

  /// Help bullet for restore step 2
  ///
  /// In en, this message translates to:
  /// **'Select your .jvbk file and enter the exact password used when the backup was created.'**
  String get helpBackupRestoreBullet2;

  /// Help bullet for restore step 3
  ///
  /// In en, this message translates to:
  /// **'All journals, entries, images, audio recordings, and tags will be fully restored into your new vault.'**
  String get helpBackupRestoreBullet3;

  /// Footer note for backup safety
  ///
  /// In en, this message translates to:
  /// **'Important: Backups cannot be decrypted or recovered if you forget your backup password.'**
  String get helpBackupFooter;

  /// Introduction for biometrics and PIN help
  ///
  /// In en, this message translates to:
  /// **'Protect your private thoughts with instant biometric verification or a dedicated 4-6 digit App PIN.'**
  String get helpBiometricsIntro;

  /// Section header for phone lock mode
  ///
  /// In en, this message translates to:
  /// **'Phone Lock Mode (Biometrics)'**
  String get helpBiometricsSectionPhoneLock;

  /// Help bullet for phone lock mode
  ///
  /// In en, this message translates to:
  /// **'Uses your device\'s biometric authentication (fingerprint or face unlock) or system lock pattern.'**
  String get helpBiometricsPhoneLockBullet1;

  /// Help bullet for biometrics convenience
  ///
  /// In en, this message translates to:
  /// **'Seamless and fast — unlocks instantly whenever you open the app.'**
  String get helpBiometricsPhoneLockBullet2;

  /// Section header for separate App PIN mode
  ///
  /// In en, this message translates to:
  /// **'Separate App PIN Mode'**
  String get helpBiometricsSectionAppPin;

  /// Help bullet for App PIN
  ///
  /// In en, this message translates to:
  /// **'Set a dedicated numeric PIN that is distinct from your device lock screen.'**
  String get helpBiometricsAppPinBullet1;

  /// Help bullet for App PIN privacy
  ///
  /// In en, this message translates to:
  /// **'Keeps your journal private even if someone else knows your phone\'s lock screen passcode.'**
  String get helpBiometricsAppPinBullet2;

  /// Section header for auto-lock timeout
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Timeout Profiles'**
  String get helpBiometricsSectionAutoLock;

  /// Help bullet for auto lock configuration
  ///
  /// In en, this message translates to:
  /// **'Configure auto-lock timeout in Settings → Security → Auto-Lock Timeout (Immediate, 30s, 1m, 5m).'**
  String get helpBiometricsAutoLockBullet1;

  /// Help bullet for auto lock behavior
  ///
  /// In en, this message translates to:
  /// **'When the app moves to background and the timeout expires, the vault locks automatically.'**
  String get helpBiometricsAutoLockBullet2;

  /// Introduction for encryption and security help
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault is architected from the ground up for total privacy and zero-knowledge data security.'**
  String get helpEncryptionIntro;

  /// Section header for SQLCipher database encryption
  ///
  /// In en, this message translates to:
  /// **'SQLCipher Database Encryption'**
  String get helpEncryptionSectionSqlcipher;

  /// Help bullet for SQLCipher
  ///
  /// In en, this message translates to:
  /// **'The underlying SQLite database is encrypted with SQLCipher using AES-256 in CBC/GCM mode.'**
  String get helpEncryptionSqlcipherBullet1;

  /// Help bullet for disk encryption
  ///
  /// In en, this message translates to:
  /// **'Every single byte written to disk is encrypted, including entry text, titles, tags, and timestamps.'**
  String get helpEncryptionSqlcipherBullet2;

  /// Section header for Android Keystore
  ///
  /// In en, this message translates to:
  /// **'Android Keystore Hardware Integration'**
  String get helpEncryptionSectionKeystore;

  /// Help bullet for Keystore security
  ///
  /// In en, this message translates to:
  /// **'Master encryption keys are generated and stored inside the Android hardware-backed Keystore / Secure Enclave.'**
  String get helpEncryptionKeystoreBullet1;

  /// Help bullet for Keystore extraction protection
  ///
  /// In en, this message translates to:
  /// **'Keys never leave the hardware module and cannot be extracted by root or other apps.'**
  String get helpEncryptionKeystoreBullet2;

  /// Section header for offline isolation
  ///
  /// In en, this message translates to:
  /// **'Complete Offline Isolation'**
  String get helpEncryptionSectionOffline;

  /// Help bullet for no internet permission
  ///
  /// In en, this message translates to:
  /// **'The app has zero internet permissions declared in its Android manifest.'**
  String get helpEncryptionOfflineBullet1;

  /// Help bullet for no analytics or tracking
  ///
  /// In en, this message translates to:
  /// **'No tracking, no analytics, no ads, and no external API requests ever happen.'**
  String get helpEncryptionOfflineBullet2;

  /// Introduction for export formats help
  ///
  /// In en, this message translates to:
  /// **'Export your entries anytime in standard formats so your memories always belong to you.'**
  String get helpExportIntro;

  /// Section header for PDF export
  ///
  /// In en, this message translates to:
  /// **'Formatted PDF Export'**
  String get helpExportSectionPdf;

  /// Help bullet for PDF export
  ///
  /// In en, this message translates to:
  /// **'Export single entries or entire journals as beautifully formatted, printable PDF documents with embedded images.'**
  String get helpExportPdfBullet1;

  /// Section header for Markdown and JSON export
  ///
  /// In en, this message translates to:
  /// **'Markdown ZIP & JSON Data'**
  String get helpExportSectionMarkdown;

  /// Help bullet for Markdown zip export
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown text files with images bundled into a zip archive for Obsidian, Notion, or personal archives.'**
  String get helpExportMarkdownBullet1;

  /// Help bullet for JSON export
  ///
  /// In en, this message translates to:
  /// **'Export raw JSON data for automated parsing and complete data portability.'**
  String get helpExportMarkdownBullet2;

  /// Section header for encrypted export reader
  ///
  /// In en, this message translates to:
  /// **'Standalone Encrypted Reader'**
  String get helpExportSectionReader;

  /// Help bullet for encrypted reader
  ///
  /// In en, this message translates to:
  /// **'Export encrypted journal packages and view them anywhere using the built-in encrypted reader tool in Settings.'**
  String get helpExportReaderBullet1;

  /// Introduction for FAQ help
  ///
  /// In en, this message translates to:
  /// **'Find quick answers to commonly asked questions about security, backups, and journal management.'**
  String get helpFaqIntro;

  /// FAQ Question 1: internet data
  ///
  /// In en, this message translates to:
  /// **'Is my data ever sent over the internet?'**
  String get helpFaqQ1;

  /// FAQ Answer 1: internet data
  ///
  /// In en, this message translates to:
  /// **'Never. SreerajP Journal Vault does not declare the INTERNET permission. Everything stays 100% on your device.'**
  String get helpFaqA1;

  /// FAQ Question 2: forgotten password
  ///
  /// In en, this message translates to:
  /// **'What if I forget my App PIN or Journal Password?'**
  String get helpFaqQ2;

  /// FAQ Answer 2: forgotten password
  ///
  /// In en, this message translates to:
  /// **'Because encryption is zero-knowledge and on-device, lost passwords cannot be reset by anyone. We strongly recommend writing down your passwords in a secure place.'**
  String get helpFaqA2;

  /// FAQ Question 3: permissions requested
  ///
  /// In en, this message translates to:
  /// **'Why are specific permissions requested?'**
  String get helpFaqQ3;

  /// FAQ Answer 3: permissions requested
  ///
  /// In en, this message translates to:
  /// **'Camera & Photos: To take photos or import images/attachments into your entries.\nMicrophone: To record voice notes and to dictate text (recognised on the device).\nStorage/Media: To save encrypted backups and export PDFs.'**
  String get helpFaqA3;

  /// FAQ Question 4: transfer to new phone
  ///
  /// In en, this message translates to:
  /// **'Can I transfer my journal to a new phone?'**
  String get helpFaqQ4;

  /// FAQ Answer 4: transfer to new phone
  ///
  /// In en, this message translates to:
  /// **'Yes! Create an encrypted backup (.jvbk) in Settings, transfer the file to your new phone, install SreerajP Journal Vault, and choose Restore Backup.'**
  String get helpFaqA4;

  /// Introduction for insights help
  ///
  /// In en, this message translates to:
  /// **'Gain deep perspective on your journaling habits, emotional trends, and writing consistency.'**
  String get helpInsightsIntro;

  /// Section header for habit tracking
  ///
  /// In en, this message translates to:
  /// **'Habit & Streak Tracking'**
  String get helpInsightsSectionHabits;

  /// Help bullet for streaks
  ///
  /// In en, this message translates to:
  /// **'View current streak and best historical writing streaks to stay motivated.'**
  String get helpInsightsHabitsBullet1;

  /// Help bullet for activity heatmap
  ///
  /// In en, this message translates to:
  /// **'Monthly calendar activity heatmap highlights active writing days.'**
  String get helpInsightsHabitsBullet2;

  /// Section header for word count and stats
  ///
  /// In en, this message translates to:
  /// **'Word Count & Activity Analytics'**
  String get helpInsightsSectionStats;

  /// Help bullet for word count analysis
  ///
  /// In en, this message translates to:
  /// **'Analyze total words written, average entry length, and reading time across journals.'**
  String get helpInsightsStatsBullet1;

  /// Section header for tag distribution
  ///
  /// In en, this message translates to:
  /// **'Tag & Topic Distribution'**
  String get helpInsightsSectionTags;

  /// Help bullet for tag analysis
  ///
  /// In en, this message translates to:
  /// **'Visualize your most frequent tags and topics to understand your primary focus areas over time.'**
  String get helpInsightsTagsBullet1;

  /// Introduction for journal locks help
  ///
  /// In en, this message translates to:
  /// **'Add secondary security barriers to specific journals or sensitive attachment files.'**
  String get helpJournalLocksIntro;

  /// Section header for per-journal password locks
  ///
  /// In en, this message translates to:
  /// **'Per-Journal Password Locks'**
  String get helpJournalLocksSectionJournal;

  /// Help bullet for journal locks
  ///
  /// In en, this message translates to:
  /// **'Assign unique passwords to sensitive journals. Even when the app is unlocked, locked journals stay encrypted until password entry.'**
  String get helpJournalLocksJournalBullet1;

  /// Help bullet for session unlock
  ///
  /// In en, this message translates to:
  /// **'Session unlock keeps the journal open while using the app, and automatically re-locks upon closing or auto-lock timeout.'**
  String get helpJournalLocksJournalBullet2;

  /// Section header for attachment-level locks
  ///
  /// In en, this message translates to:
  /// **'Attachment-Level Locks'**
  String get helpJournalLocksSectionAttachment;

  /// Help bullet for attachment locks
  ///
  /// In en, this message translates to:
  /// **'Hide and lock private photo or document attachments behind independent passwords.'**
  String get helpJournalLocksAttachmentBullet1;

  /// Introduction for journal organization help
  ///
  /// In en, this message translates to:
  /// **'Organize your life into dedicated journals, use structured prompts, and write expressive rich text.'**
  String get helpJournalOrgIntro;

  /// Section header for multiple journals
  ///
  /// In en, this message translates to:
  /// **'Multiple Separate Journals'**
  String get helpJournalOrgSectionMultiple;

  /// Help bullet for distinct journals
  ///
  /// In en, this message translates to:
  /// **'Create distinct journals for Personal, Work, Travel, Ideas, or Health.'**
  String get helpJournalOrgMultipleBullet1;

  /// Help bullet for switching journals
  ///
  /// In en, this message translates to:
  /// **'Switch between journals seamlessly with the top journal selector.'**
  String get helpJournalOrgMultipleBullet2;

  /// Section header for starter templates
  ///
  /// In en, this message translates to:
  /// **'Using Starter Templates'**
  String get helpJournalOrgSectionTemplates;

  /// Help bullet for templates
  ///
  /// In en, this message translates to:
  /// **'Choose from 8 built-in templates (Daily Reflection, Gratitude, Dream, etc.) when creating a new entry.'**
  String get helpJournalOrgTemplatesBullet1;

  /// Help bullet for custom templates
  ///
  /// In en, this message translates to:
  /// **'Customize templates or create new ones in Settings → Templates.'**
  String get helpJournalOrgTemplatesBullet2;

  /// Section header for rich text formatting
  ///
  /// In en, this message translates to:
  /// **'Rich Text Formatting'**
  String get helpJournalOrgSectionRichText;

  /// Help bullet for rich text toolbar
  ///
  /// In en, this message translates to:
  /// **'Format text with bold, italic, headings, lists, tables, drawings, and inline callouts using the editor toolbar.'**
  String get helpJournalOrgRichTextBullet1;

  /// Introduction for screenshot audit help
  ///
  /// In en, this message translates to:
  /// **'Learn how SreerajP Journal Vault protects your screens from snooping and logs critical security operations.'**
  String get helpScreenshotAuditIntro;

  /// Section header for screenshot guard
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard (FLAG_SECURE)'**
  String get helpScreenshotAuditSectionGuard;

  /// Help bullet for screenshot blocking
  ///
  /// In en, this message translates to:
  /// **'By default, the app blocks screenshots, screen recording, and masks recent task switcher previews.'**
  String get helpScreenshotAuditGuardBullet1;

  /// Help bullet for toggling screenshot guard
  ///
  /// In en, this message translates to:
  /// **'You can toggle screenshot blocking in Settings → Security if you need to capture screenshots.'**
  String get helpScreenshotAuditGuardBullet2;

  /// Section header for security log
  ///
  /// In en, this message translates to:
  /// **'Tamper-Evident Security Events Log'**
  String get helpScreenshotAuditSectionLog;

  /// Help bullet for security audit log
  ///
  /// In en, this message translates to:
  /// **'The app records a local tamper-evident audit log of PIN attempts, lock switches, and exports in Settings → Security → Security Events.'**
  String get helpScreenshotAuditLogBullet1;

  /// Introduction for search and timeline help
  ///
  /// In en, this message translates to:
  /// **'Locate past memories in milliseconds with SQLite Full-Text Search and an interactive calendar timeline.'**
  String get helpSearchTimelineIntro;

  /// Section header for FTS search
  ///
  /// In en, this message translates to:
  /// **'SQLite Full-Text Search (FTS)'**
  String get helpSearchTimelineSectionFts;

  /// Help bullet for search indexing
  ///
  /// In en, this message translates to:
  /// **'Search across all entries, titles, and tags with instant matching as you type.'**
  String get helpSearchTimelineFtsBullet1;

  /// Section header for saved search presets
  ///
  /// In en, this message translates to:
  /// **'Saved Search Presets'**
  String get helpSearchTimelineSectionPresets;

  /// Help bullet for search presets
  ///
  /// In en, this message translates to:
  /// **'Save frequent search filter combinations for one-tap quick access.'**
  String get helpSearchTimelinePresetsBullet1;

  /// Section header for calendar timeline
  ///
  /// In en, this message translates to:
  /// **'Calendar & Timeline Explorer'**
  String get helpSearchTimelineSectionTimeline;

  /// Help bullet for calendar navigation
  ///
  /// In en, this message translates to:
  /// **'Browse entries by calendar date, navigate months, and view day-by-day chronological lists.'**
  String get helpSearchTimelineTimelineBullet1;

  /// Introduction for storage migration help
  ///
  /// In en, this message translates to:
  /// **'Manage where encrypted attachments are stored and migrate between internal memory and SD Card storage.'**
  String get helpStorageMigrationIntro;

  /// Section header for internal storage
  ///
  /// In en, this message translates to:
  /// **'Internal App-Private Storage'**
  String get helpStorageMigrationSectionInternal;

  /// Help bullet for internal storage
  ///
  /// In en, this message translates to:
  /// **'By default, encrypted attachments reside in app-private internal storage, protected by Android OS sandbox permissions.'**
  String get helpStorageMigrationInternalBullet1;

  /// Section header for SD card storage
  ///
  /// In en, this message translates to:
  /// **'SD Card Storage & Live Migration'**
  String get helpStorageMigrationSectionSd;

  /// Help bullet for SD card migration
  ///
  /// In en, this message translates to:
  /// **'Move media files to SD card in Settings → Storage → Migrate Storage to free up internal phone storage.'**
  String get helpStorageMigrationSdBullet1;

  /// Help bullet for SD card encryption
  ///
  /// In en, this message translates to:
  /// **'All files remain fully AES-256-GCM encrypted on the SD card.'**
  String get helpStorageMigrationSdBullet2;

  /// Introduction for tags help
  ///
  /// In en, this message translates to:
  /// **'Categorize and organize your entries across all journals with custom color-coded tags.'**
  String get helpTagsIntro;

  /// Section header for tagging entries
  ///
  /// In en, this message translates to:
  /// **'Tagging Entries & Journals'**
  String get helpTagsSectionTagging;

  /// Help bullet for adding tags
  ///
  /// In en, this message translates to:
  /// **'Add tags to any entry from the top tag bar in the editor.'**
  String get helpTagsTaggingBullet1;

  /// Section header for tag colors
  ///
  /// In en, this message translates to:
  /// **'Custom Color Coding'**
  String get helpTagsSectionColors;

  /// Help bullet for tag colors
  ///
  /// In en, this message translates to:
  /// **'Assign unique palette colors to tags to easily distinguish topics visually.'**
  String get helpTagsColorsBullet1;

  /// Section header for tag cleanup
  ///
  /// In en, this message translates to:
  /// **'Tag Management & Cleanup'**
  String get helpTagsSectionCleanup;

  /// Help bullet for tag manager
  ///
  /// In en, this message translates to:
  /// **'Rename, recolor, or delete unused tags globally from Settings → Tag Manager.'**
  String get helpTagsCleanupBullet1;

  /// Title for tamper alerts screen
  ///
  /// In en, this message translates to:
  /// **'Tamper Alerts'**
  String get titleTamperAlerts;

  /// Section title explaining vault integrity
  ///
  /// In en, this message translates to:
  /// **'How this works'**
  String get titleTamperAlertsHowItWorks;

  /// Body explaining vault integrity
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault continuously verifies structural consistency, chronological timestamps, and AES-256 encrypted records.'**
  String get bodyTamperAlertsHowItWorks;

  /// Message when no alerts exist
  ///
  /// In en, this message translates to:
  /// **'No tamper alerts recorded. Your vault entries are secure.'**
  String get bodyTamperAlertsNoHistory;

  /// Header for alert history list
  ///
  /// In en, this message translates to:
  /// **'Tamper Alert History'**
  String get titleTamperAlertsHistory;

  /// Message when integrity check is clean
  ///
  /// In en, this message translates to:
  /// **'Vault scan complete: all entries verified clean.'**
  String get bodyTamperAlertsScanCompleteClean;

  /// Message when integrity check found issues
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Integrity check found 1 issue.} other{Integrity check found {count} issues.}}'**
  String bodyTamperAlertsScanCompleteIssues(int count);

  /// Status text for issues
  ///
  /// In en, this message translates to:
  /// **'Warning — Integrity Issues Detected'**
  String get bodyTamperAlertsStatusIssues;

  /// Detail message when tamper issues are found
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 data integrity issue was detected in records.} other{{count} data integrity issues were detected in records.}}'**
  String bodyTamperAlertsStatusIssuesDetail(int count);

  /// Status text for verified
  ///
  /// In en, this message translates to:
  /// **'Vault Integrity Verified'**
  String get bodyTamperAlertsStatusVerified;

  /// Detail text for verified
  ///
  /// In en, this message translates to:
  /// **'All database tables and encryption seals verified successfully.'**
  String get descTamperAlertsStatusVerifiedDetail;

  /// Button to verify integrity
  ///
  /// In en, this message translates to:
  /// **'Verify vault'**
  String get actionTamperAlertsVerify;

  /// Progress message during verification
  ///
  /// In en, this message translates to:
  /// **'Verifying vault integrity...'**
  String get bodyTamperAlertsVerifying;

  /// Title for quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Quick Capture'**
  String get titleShareQuickCapture;

  /// Subtitle for quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Save incoming content as a new journal entry'**
  String get descShareQuickCapture;

  /// Shown when no journal exists for share target
  ///
  /// In en, this message translates to:
  /// **'No journals found. Create a journal first.'**
  String get bodyShareNoJournalsFound;

  /// Label for selecting destination journal
  ///
  /// In en, this message translates to:
  /// **'Select Journal'**
  String get labelShareSelectJournal;

  /// Label for entry title input in quick capture
  ///
  /// In en, this message translates to:
  /// **'Entry Title'**
  String get labelShareEntryTitle;

  /// Hint for entry title input in quick capture
  ///
  /// In en, this message translates to:
  /// **'Enter title (optional)'**
  String get descShareEntryTitle;

  /// Label for share content
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get labelShareContent;

  /// Hint for share content
  ///
  /// In en, this message translates to:
  /// **'Shared note, quote, or link...'**
  String get descShareContent;

  /// Label for shared attachments count
  ///
  /// In en, this message translates to:
  /// **'Attachments ({count})'**
  String labelShareAttachments(int count);

  /// Discard button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionShareDiscard;

  /// Open in editor button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Open in Editor'**
  String get actionShareOpenInEditor;

  /// Save to journal button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Save to Journal'**
  String get actionShareSaveToJournal;

  /// Error message when saving shared content fails
  ///
  /// In en, this message translates to:
  /// **'Could not save shared note.'**
  String get errorShareSave;

  /// Success message after saving shared note
  ///
  /// In en, this message translates to:
  /// **'Shared note saved to \"{journalTitle}\"'**
  String bodyShareSavedSuccess(String journalTitle);

  /// Dialog title when encrypted export is received
  ///
  /// In en, this message translates to:
  /// **'Encrypted file'**
  String get titleShareSealedFileDetected;

  /// Button to open encrypted export
  ///
  /// In en, this message translates to:
  /// **'Open Encrypted File'**
  String get actionShareOpenEncryptedExport;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'My templates'**
  String get labelTemplateCategoryCustom;

  /// Collapse all button in template manager
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get actionTemplateCollapseAll;

  /// Expand all button in template manager
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get actionTemplateExpandAll;

  /// Create template button
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get actionTemplateCreateNew;

  /// Title for template manager screen
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get titleTemplateManager;

  /// Edit template title/action
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get actionTemplateEdit;

  /// Delete template title/action
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get actionTemplateDelete;

  /// Dialog title confirming template deletion
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get bodyTemplateDeleteConfirm;

  /// Dialog message confirming template deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String bodyTemplateDeleteConfirmMessage(String name);

  /// Snackbar notification after template deletion
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get bodyTemplateDeleteSuccess;

  /// Empty state in template manager
  ///
  /// In en, this message translates to:
  /// **'No custom templates yet. Create one to reuse your favorite journaling layouts.'**
  String get emptyTemplate;

  /// Label for template name field
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get labelTemplateName;

  /// Hint for template name field
  ///
  /// In en, this message translates to:
  /// **'e.g., Daily Standup, Workout Note'**
  String get descTemplateName;

  /// Validation error when template name is missing
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name.'**
  String get errorTemplateName;

  /// Label for template description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelTemplateDescription;

  /// Hint for template description field
  ///
  /// In en, this message translates to:
  /// **'Brief summary of what this template is for'**
  String get descTemplateDescription;

  /// Label for default entry title field
  ///
  /// In en, this message translates to:
  /// **'Default entry title'**
  String get labelTemplateDefaultTitle;

  /// Hint under the template's default entry title field.
  ///
  /// In en, this message translates to:
  /// **'e.g., Standup - today'**
  String get descTemplateDefaultTitle;

  /// Label for template starter content
  ///
  /// In en, this message translates to:
  /// **'Starter content'**
  String get labelTemplateContent;

  /// Hint for template starter content
  ///
  /// In en, this message translates to:
  /// **'Type your starter prompt or outline...'**
  String get descTemplateContent;

  /// Heading for dynamic date tokens list
  ///
  /// In en, this message translates to:
  /// **'Dynamic Date Tokens'**
  String get titleTemplateTokens;

  /// Help text for dynamic date tokens
  ///
  /// In en, this message translates to:
  /// **'Dynamic date tokens automatically populate when creating a new entry.'**
  String get descTemplateTokensHelper;

  /// Snackbar notification after template save
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get bodyTemplateSaveSuccess;

  /// Action to save current entry as template
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get actionTemplateSaveAsTemplate;

  /// Title for save entry as template dialog
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get titleTemplateSaveAsTemplate;

  /// Description for save entry as template dialog
  ///
  /// In en, this message translates to:
  /// **'Save this entry\'s layout as a reusable template.'**
  String get descTemplateSaveAsTemplate;

  /// Title for help section in settings
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get titleSettingsSectionHelp;

  /// Subtitle for help section in settings
  ///
  /// In en, this message translates to:
  /// **'Guides, encryption details & FAQs'**
  String get descSettingsSectionHelp;

  /// Title for features catalog in settings
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get titleSettingsSectionFeatures;

  /// Subtitle for features catalog in settings
  ///
  /// In en, this message translates to:
  /// **'Explore all features and security tools'**
  String get descSettingsSectionFeatures;

  /// Header title in features catalog
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault Features'**
  String get titleFeaturesHeader;

  /// Header subtitle in features catalog
  ///
  /// In en, this message translates to:
  /// **'Zero-leak offline architecture, military-grade encryption, and expressive journaling.'**
  String get descFeaturesHeader;

  /// Word count format
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String descEntryWordCount(int count);

  /// Character count format
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 char} other{{count} chars}}'**
  String descEntryCharCount(int count);

  /// Stats summary combining word and char counts
  ///
  /// In en, this message translates to:
  /// **'{words} • {chars}'**
  String descEntryStats(String words, String chars);

  /// Enter distraction-free mode action
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get actionEntryDistractionFreeEnter;

  /// Exit distraction-free mode action
  ///
  /// In en, this message translates to:
  /// **'Exit focus mode'**
  String get actionEntryDistractionFreeExit;

  /// Toggle focus paragraph on
  ///
  /// In en, this message translates to:
  /// **'Focus paragraph: on'**
  String get descEntryFocusParagraphOn;

  /// Toggle focus paragraph off
  ///
  /// In en, this message translates to:
  /// **'Focus paragraph: off'**
  String get descEntryFocusParagraphOff;

  /// Autosaving status
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get labelEntryAutoSaving;

  /// Autosaved with timestamp
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String labelEntryAutoSaved(String time);

  /// Autosaved just now status
  ///
  /// In en, this message translates to:
  /// **'Saved just now'**
  String get labelEntryAutoSavedJustNow;

  /// Unsaved changes warning
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get labelEntryUnsavedChanges;

  /// Scan text button tooltip
  ///
  /// In en, this message translates to:
  /// **'Scan text from image'**
  String get tooltipEntryEditorScanText;

  /// Camera source option
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get labelEntryEditorScanSourceCamera;

  /// Gallery source option
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get labelEntryEditorScanSourceGallery;

  /// OCR scanning in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning text from image...'**
  String get descEntryEditorOcrScanning;

  /// OCR no text found notice
  ///
  /// In en, this message translates to:
  /// **'No text was detected in the image.'**
  String get descEntryEditorOcrNoTextFound;

  /// OCR error message
  ///
  /// In en, this message translates to:
  /// **'Failed to scan text from image.'**
  String get errorEntryEditorOcr;

  /// Crop image screen title
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get titleEntryEditorCropImage;

  /// Crop image error
  ///
  /// In en, this message translates to:
  /// **'Could not process image crop.'**
  String get errorEntryEditorCropImage;

  /// Theme mode title in appearance settings
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get titleAppearanceThemeMode;

  /// Theme mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose System, Dark, or Light appearance'**
  String get descAppearanceThemeMode;

  /// Accent color title in appearance settings
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get titleAppearanceAccentColor;

  /// Accent color subtitle
  ///
  /// In en, this message translates to:
  /// **'Select primary brand color palette'**
  String get descAppearanceAccentColor;

  /// Theme live preview header
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get titleAppearanceLivePreview;

  /// Theme color presets tab
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get tabAppearancePresets;

  /// Custom color picker tab
  ///
  /// In en, this message translates to:
  /// **'Custom Color Wheel'**
  String get tabAppearanceCustomWheel;

  /// Sample text preview
  ///
  /// In en, this message translates to:
  /// **'Sample Journal Entry'**
  String get labelAppearanceSampleText;

  /// Reset appearance to default button
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get actionAppearanceResetDefault;

  /// Contrast explanation note
  ///
  /// In en, this message translates to:
  /// **'Text contrast is adjusted automatically for readability.'**
  String get descAppearanceContrastNote;

  /// System mode explanation
  ///
  /// In en, this message translates to:
  /// **'System mode automatically follows your device\'s system-wide dark mode setting.'**
  String get descAppearanceSystemModeExplainer;

  /// Theme choice: warm parchment paper/sepia tones
  ///
  /// In en, this message translates to:
  /// **'Paper / Sepia'**
  String get labelSettingsThemeSepia;

  /// Theme choice: pitch black for OLED/AMOLED displays
  ///
  /// In en, this message translates to:
  /// **'OLED / True Black'**
  String get labelSettingsThemeOled;

  /// Description of the sepia/paper theme
  ///
  /// In en, this message translates to:
  /// **'Warm parchment paper tone that is soothing for long writing sessions.'**
  String get descSettingsThemeSepia;

  /// Description of the OLED/True Black theme
  ///
  /// In en, this message translates to:
  /// **'Pure pitch black background with crisp contrast for AMOLED battery saving.'**
  String get descSettingsThemeOled;

  /// Description of the Light theme
  ///
  /// In en, this message translates to:
  /// **'Clean and bright daylight reading surface.'**
  String get descSettingsThemeLight;

  /// Description of the Dark theme
  ///
  /// In en, this message translates to:
  /// **'Soft charcoal dark background for low-light writing.'**
  String get descSettingsThemeDark;

  /// Description of the System theme
  ///
  /// In en, this message translates to:
  /// **'Automatically follows your device system brightness preference.'**
  String get descSettingsThemeSystem;

  /// Title of the reading typography settings screen
  ///
  /// In en, this message translates to:
  /// **'Reading Typography'**
  String get titleAppearanceTypography;

  /// Subtitle of typography settings
  ///
  /// In en, this message translates to:
  /// **'Customize body font family and reading size'**
  String get descAppearanceTypography;

  /// Header for font family section
  ///
  /// In en, this message translates to:
  /// **'Body Font Family'**
  String get titleAppearanceFontFamily;

  /// Header for font size section
  ///
  /// In en, this message translates to:
  /// **'Body Font Size'**
  String get titleAppearanceFontSize;

  /// Sans-serif font family label
  ///
  /// In en, this message translates to:
  /// **'Sans-Serif'**
  String get labelAppearanceFontFamilySans;

  /// Sans-serif font family description
  ///
  /// In en, this message translates to:
  /// **'Clean and contemporary modern typeface'**
  String get descAppearanceFontFamilySans;

  /// Serif font family label
  ///
  /// In en, this message translates to:
  /// **'Book Serif'**
  String get labelAppearanceFontFamilySerif;

  /// Serif font family description
  ///
  /// In en, this message translates to:
  /// **'Classic editorial and literary book feel'**
  String get descAppearanceFontFamilySerif;

  /// Monospace font family label
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get labelAppearanceFontFamilyMonospace;

  /// Monospace font family description
  ///
  /// In en, this message translates to:
  /// **'Fixed-width typewriter and Markdown aesthetic'**
  String get descAppearanceFontFamilyMonospace;

  /// Small font size preset label
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get labelAppearanceFontSizeSmall;

  /// Default font size preset label
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get labelAppearanceFontSizeDefault;

  /// Medium font size preset label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get labelAppearanceFontSizeMedium;

  /// Large font size preset label
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get labelAppearanceFontSizeLarge;

  /// Extra large font size preset label
  ///
  /// In en, this message translates to:
  /// **'X-Large'**
  String get labelAppearanceFontSizeExtraLarge;

  /// Headline for sample journal preview card
  ///
  /// In en, this message translates to:
  /// **'Quiet Reflections'**
  String get labelAppearanceSampleHeadline;

  /// Body paragraph for sample journal preview card
  ///
  /// In en, this message translates to:
  /// **'The journal is a quiet space to slow down and reflect. Every thought, memory, and sketch is securely preserved in your private vault.'**
  String get bodyAppearanceSample;

  /// Confirmation message after resetting typography
  ///
  /// In en, this message translates to:
  /// **'Typography reset to default.'**
  String get bodyAppearanceTypographyReset;

  /// Help center header title
  ///
  /// In en, this message translates to:
  /// **'Help Center & Knowledge Base'**
  String get helpHeaderTitle;

  /// Help center header subtitle
  ///
  /// In en, this message translates to:
  /// **'Complete offline documentation, encryption details, and quick answers.'**
  String get helpHeaderSubtitle;

  /// Help center writing section
  ///
  /// In en, this message translates to:
  /// **'Writing & Journal Management'**
  String get helpSectionWriting;

  /// Help center security section
  ///
  /// In en, this message translates to:
  /// **'Security, Lock & Encryption'**
  String get helpSectionSecurity;

  /// Help center search section
  ///
  /// In en, this message translates to:
  /// **'Search, Timeline & Insights'**
  String get helpSectionSearch;

  /// Help center storage section
  ///
  /// In en, this message translates to:
  /// **'Storage, Backups & Export'**
  String get helpSectionStorage;

  /// Help center FAQ section
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpSectionFaq;

  /// Toolbar insert drawing button tooltip
  ///
  /// In en, this message translates to:
  /// **'Drawing canvas'**
  String get tooltipEditorInsertDrawing;

  /// Drawing canvas screen title
  ///
  /// In en, this message translates to:
  /// **'Drawing & Sketch'**
  String get titleDrawingCanvas;

  /// Drawing canvas edit title
  ///
  /// In en, this message translates to:
  /// **'Edit Drawing'**
  String get titleDrawingCanvasEdit;

  /// Drawing canvas pen tool
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get labelDrawingCanvasPen;

  /// Drawing canvas highlighter tool
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get labelDrawingCanvasHighlighter;

  /// Drawing canvas eraser tool
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get labelDrawingCanvasEraser;

  /// Clear drawing canvas action
  ///
  /// In en, this message translates to:
  /// **'Clear canvas'**
  String get actionDrawingCanvasClear;

  /// Confirm clear canvas dialog message
  ///
  /// In en, this message translates to:
  /// **'Clear the entire drawing?'**
  String get bodyDrawingCanvasClear;

  /// Drawing stroke width selector
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get labelDrawingCanvasStrokeWidth;

  /// Drawing background selector
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get labelDrawingCanvasBackground;

  /// Blank background style
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get labelDrawingCanvasBgBlank;

  /// Ruled lines background style
  ///
  /// In en, this message translates to:
  /// **'Ruled'**
  String get labelDrawingCanvasBgRuled;

  /// Grid background style
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get labelDrawingCanvasBgGrid;

  /// Dots background style
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get labelDrawingCanvasBgDots;

  /// Drawing canvas undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionDrawingCanvasUndo;

  /// Drawing canvas redo
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get actionDrawingCanvasRedo;

  /// Save drawing button
  ///
  /// In en, this message translates to:
  /// **'Save drawing'**
  String get actionDrawingCanvasSave;

  /// Discard drawing dialog title
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get bodyDrawingCanvasDiscard;

  /// Discard drawing dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your drawing changes?'**
  String get bodyDrawingCanvasDiscardMessage;

  /// Edit inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit drawing'**
  String get tooltipDrawingEdit;

  /// Resize inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Resize drawing'**
  String get tooltipDrawingSize;

  /// Delete inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete drawing'**
  String get tooltipDrawingDelete;

  /// Drawing unavailable placeholder
  ///
  /// In en, this message translates to:
  /// **'Drawing unavailable'**
  String get descDrawingUnavailable;

  /// Drawing loading placeholder
  ///
  /// In en, this message translates to:
  /// **'Loading drawing…'**
  String get descDrawingLoading;

  /// Error message when saving a drawing fails
  ///
  /// In en, this message translates to:
  /// **'Could not save drawing.'**
  String get errorDrawingSave;

  /// Custom templates action
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get actionJournalManageTemplates;

  /// Help center title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// Features catalog title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get titleFeatures;

  /// Feature title: 100% offline & zero network permission
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Zero Network Permission'**
  String get bodyFeatureOffline;

  /// Feature description: 100% offline & zero network permission
  ///
  /// In en, this message translates to:
  /// **'The application contains zero network access code, requests no internet permissions, and keeps all journal data, attachments, and encryption strictly offline.'**
  String get descFeatureOffline;

  /// Title of the Ritual Practice screen
  ///
  /// In en, this message translates to:
  /// **'Ritual Practice'**
  String get titleRitual;

  /// Title of the Ritual Deck Browser screen
  ///
  /// In en, this message translates to:
  /// **'Reflection Deck'**
  String get titleRitualDeckBrowser;

  /// Tooltip for resetting spaced repetition intervals
  ///
  /// In en, this message translates to:
  /// **'Reset SRS intervals'**
  String get tooltipRitualResetReviews;

  /// Title of dialog confirming resetting all card reviews
  ///
  /// In en, this message translates to:
  /// **'Reset reviews'**
  String get titleRitualResetReviews;

  /// Confirmation message when resetting spaced repetition reviews
  ///
  /// In en, this message translates to:
  /// **'This will reset review levels and next review dates for all cards. Continue?'**
  String get bodyRitualResetReviews;

  /// Snackbar shown after resetting card reviews
  ///
  /// In en, this message translates to:
  /// **'Card review intervals reset.'**
  String get bodyRitualResetReviewsDone;

  /// Filter chip for all themes in reflection deck
  ///
  /// In en, this message translates to:
  /// **'All Themes'**
  String get labelRitualAllThemes;

  /// Badge for cards that have never been reviewed
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get labelRitualSrsNew;

  /// Badge for cards due for review today
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get labelRitualSrsDueToday;

  /// Badge showing days until next review
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String labelRitualSrsInDays(int days);

  /// Step label for breathing in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get labelRitualStepBreathe;

  /// Step label for reflection card in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get labelRitualStepReflect;

  /// Step label for writing in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get labelRitualStepWrite;

  /// Heading for the breathing exercise in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Centering Breath'**
  String get titleRitualBreathe;

  /// Button to skip breathing and go to reflection prompt
  ///
  /// In en, this message translates to:
  /// **'Skip to Prompt'**
  String get actionRitualSkipToPrompt;

  /// Button to continue to reflection card
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionRitualContinueToCard;

  /// Button to draw another reflection card
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get actionRitualShuffleCard;

  /// Label for spaced repetition rating buttons
  ///
  /// In en, this message translates to:
  /// **'HOW MEMORABLE / EASY WAS THIS REFLECTION?'**
  String get bodyRitualSrsRatePrompt;

  /// Rating button: Hard (review in 1 day)
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get actionRitualSrsHard;

  /// Subtitle for Hard rating button
  ///
  /// In en, this message translates to:
  /// **'Review in 1d'**
  String get descRitualSrsHard;

  /// Rating button: Revision (review in 3 days)
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get actionRitualSrsRevision;

  /// Subtitle for Revision rating button
  ///
  /// In en, this message translates to:
  /// **'Review in 3d'**
  String get descRitualSrsRevision;

  /// Rating button: Easy (+7 days)
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get actionRitualSrsEasy;

  /// Subtitle for Easy rating button
  ///
  /// In en, this message translates to:
  /// **'+7 days'**
  String get descRitualSrsEasy;

  /// Button to advance to journal writing step
  ///
  /// In en, this message translates to:
  /// **'Proceed to Journal'**
  String get actionRitualProceedToJournal;

  /// Heading when ready to write in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Ready to Reflect'**
  String get titleRitualReadyToWrite;

  /// Description explaining journal entry creation from prompt card
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts into today\'s journal entry inspired by \"{cardTitle}\".'**
  String descRitualReadyToWrite(String cardTitle);

  /// Button to open journal editor with prompt seeded
  ///
  /// In en, this message translates to:
  /// **'Begin Journaling'**
  String get actionRitualBeginWriting;

  /// Button to finish ritual without creating a journal entry
  ///
  /// In en, this message translates to:
  /// **'Finish practice'**
  String get actionRitualCompletePracticeOnly;

  /// Title of Ritual Mode settings dialog
  ///
  /// In en, this message translates to:
  /// **'Ritual Mode Settings'**
  String get titleRitualSettings;

  /// Setting toggle to launch directly into ritual mode
  ///
  /// In en, this message translates to:
  /// **'Open in Ritual Mode'**
  String get titleRitualLaunchOnStartup;

  /// Subtitle for launch in ritual mode setting
  ///
  /// In en, this message translates to:
  /// **'Begin every session with a guided breath and reflection prompt'**
  String get descRitualLaunchOnStartup;

  /// Label for selecting breathing technique
  ///
  /// In en, this message translates to:
  /// **'Breathing Technique'**
  String get labelRitualBreathTechnique;

  /// Label and value for breath cycle count slider
  ///
  /// In en, this message translates to:
  /// **'Breathing Cycles: {count}'**
  String labelRitualBreathCycles(int count);

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionCommonReset;

  /// Settings tile title for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Ritual mode'**
  String get titleRitualSettingsTile;

  /// Settings tile subtitle for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Guided breath timer, 50-card Sanathana Dharma deck & spaced repetition'**
  String get descRitualSettingsTile;

  /// Feature catalog title for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Ritual Mode & Reflection Cards'**
  String get titleFeatureRitual;

  /// Feature catalog description for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'A guided daily practice that calms your mind with a breath timer, surfaces rotating prompt cards with Anki-style spaced repetition, and opens directly to today\'s entry.'**
  String get descFeatureRitual;

  /// Title of P2P sync landing screen
  ///
  /// In en, this message translates to:
  /// **'Device sync'**
  String get titleSyncLanding;

  /// Subtitle of P2P sync landing screen
  ///
  /// In en, this message translates to:
  /// **'Sync entries and attachments directly over local Wi-Fi with no cloud servers'**
  String get descSyncLanding;

  /// Host mode card title
  ///
  /// In en, this message translates to:
  /// **'Send Changes (Host)'**
  String get titleSyncSend;

  /// Host mode card subtitle
  ///
  /// In en, this message translates to:
  /// **'Display a pairing QR code to share journal entries and attachments with another device'**
  String get descSyncSend;

  /// Client mode card title
  ///
  /// In en, this message translates to:
  /// **'Receive changes'**
  String get titleSyncReceive;

  /// Client mode card subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan a pairing QR code or enter connection details to receive updates'**
  String get descSyncReceive;

  /// Host screen title
  ///
  /// In en, this message translates to:
  /// **'Host Wi-Fi Sync'**
  String get titleSyncHost;

  /// Client screen title
  ///
  /// In en, this message translates to:
  /// **'Receive Wi-Fi Sync'**
  String get titleSyncClient;

  /// Tab label for camera QR scanner
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get tabSyncTabQrScan;

  /// Tab label for manual connection entry
  ///
  /// In en, this message translates to:
  /// **'Manual Details'**
  String get tabSyncTabManualEntry;

  /// Label for host IP address
  ///
  /// In en, this message translates to:
  /// **'Local IP Address'**
  String get labelSyncIp;

  /// Label for host TCP port
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get labelSyncPort;

  /// Label for one-time pairing code
  ///
  /// In en, this message translates to:
  /// **'Pairing Code'**
  String get labelSyncPairingCode;

  /// Hint inside the pairing code field showing its shape: four groups of four characters. Keep the X letters and dashes; it is a format mask, not words
  ///
  /// In en, this message translates to:
  /// **'XXXX-XXXX-XXXX-XXXX'**
  String get labelSyncPairingCodeHint;

  /// Status when host is listening
  ///
  /// In en, this message translates to:
  /// **'Waiting for incoming connection...'**
  String get descSyncStatusListening;

  /// Status when peer is authenticated
  ///
  /// In en, this message translates to:
  /// **'Device connected'**
  String get labelSyncStatusConnected;

  /// Status when sync succeeds
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully!'**
  String get descSyncStatusCompleted;

  /// Status when authentication fails
  ///
  /// In en, this message translates to:
  /// **'Connection rejected: incorrect pairing code'**
  String get errorSyncStatusDenied;

  /// Status when host is stopped
  ///
  /// In en, this message translates to:
  /// **'Sync server stopped'**
  String get labelSyncStatusStopped;

  /// Status when sync hits an error
  ///
  /// In en, this message translates to:
  /// **'Sync server error'**
  String get errorSyncStatusError;

  /// Button to start sync host
  ///
  /// In en, this message translates to:
  /// **'Start Server'**
  String get actionSyncButtonStart;

  /// Button to stop sync host
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get actionSyncButtonStop;

  /// Button to start client sync
  ///
  /// In en, this message translates to:
  /// **'Connect & Sync'**
  String get actionSyncButtonConnect;

  /// Instructions shown above camera viewfinder
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the pairing QR code on the sending device'**
  String get descSyncScanInstructions;

  /// Hint text for IP input field
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.5'**
  String get descSyncHostAddress;

  /// Hint text for port input field
  ///
  /// In en, this message translates to:
  /// **'e.g. 54321'**
  String get descSyncPort;

  /// Hint text for pairing code input field
  ///
  /// In en, this message translates to:
  /// **'16-character pairing code'**
  String get descSyncCode;

  /// Warning when no local IP is available
  ///
  /// In en, this message translates to:
  /// **'No Wi-Fi / LAN IP detected. Make sure both devices are on the same Wi-Fi network or hotspot.'**
  String get descSyncNoWifiAlert;

  /// Snackbar message when pairing code is copied
  ///
  /// In en, this message translates to:
  /// **'Pairing code copied to clipboard'**
  String get bodySyncPairingCodeCopied;

  /// Title for optical air-gap sync
  ///
  /// In en, this message translates to:
  /// **'AirQR sync'**
  String get titleAirqr;

  /// Intro description for AirQR optical sync
  ///
  /// In en, this message translates to:
  /// **'Synchronize settings, small journals, and entries over light using animated QR codes without network connections.'**
  String get descAirqrIntro;

  /// Title for AirQR send screen
  ///
  /// In en, this message translates to:
  /// **'Send via AirQR'**
  String get titleAirqrSend;

  /// Title for AirQR receive screen
  ///
  /// In en, this message translates to:
  /// **'Receive via AirQR'**
  String get titleAirqrReceive;

  /// Title for receive action card
  ///
  /// In en, this message translates to:
  /// **'Receive data'**
  String get actionAirqrReceive;

  /// Subtitle for receive action card
  ///
  /// In en, this message translates to:
  /// **'Scan animated QR frames from another device'**
  String get descAirqrReceive;

  /// Title for sync settings action
  ///
  /// In en, this message translates to:
  /// **'Sync App Settings'**
  String get titleAirqrSyncSettings;

  /// Subtitle for sync settings action
  ///
  /// In en, this message translates to:
  /// **'Theme, accent color, security, ritual & templates (< 1 sec)'**
  String get descAirqrSyncSettings;

  /// Title for sync journal action
  ///
  /// In en, this message translates to:
  /// **'Sync Single Journal'**
  String get titleAirqrSyncJournal;

  /// Subtitle for sync journal action
  ///
  /// In en, this message translates to:
  /// **'Select and stream a journal with text entries'**
  String get descAirqrSyncJournal;

  /// Title for too large dialog
  ///
  /// In en, this message translates to:
  /// **'Payload Too Large'**
  String get titleAirqrTooLarge;

  /// Title for warning dialog on large optical transfer
  ///
  /// In en, this message translates to:
  /// **'Large transfer'**
  String get titleAirqrSlow;

  /// Button to proceed with optical transfer
  ///
  /// In en, this message translates to:
  /// **'Send Anyway'**
  String get actionAirqrSendAnyway;

  /// Title for AirQR speed note
  ///
  /// In en, this message translates to:
  /// **'Offline and private'**
  String get titleAirqrSpeedNote;

  /// Body for AirQR speed note
  ///
  /// In en, this message translates to:
  /// **'AirQR works purely via camera and screen. No Wi-Fi, hotspot, Bluetooth, or internet required.'**
  String get bodyAirqrSpeedNote;

  /// Action menu item to seal an entry as a time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal as Time Capsule'**
  String get actionTimeCapsuleActionSeal;

  /// Title of dialog to seal an entry as a time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal as Time Capsule'**
  String get titleTimeCapsuleSeal;

  /// Description of cryptographic time capsule seal
  ///
  /// In en, this message translates to:
  /// **'Cryptographically seals this entry until a future date. The decryption key will not be released until that date arrives.'**
  String get descTimeCapsuleSeal;

  /// Label for the unlock date field
  ///
  /// In en, this message translates to:
  /// **'Unlock Date'**
  String get labelTimeCapsuleUnlockDate;

  /// Hint text for optional teaser note to future self
  ///
  /// In en, this message translates to:
  /// **'Note to future self (optional teaser)'**
  String get descTimeCapsuleTeaser;

  /// Preset button for 1 month in the future
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get actionTimeCapsulePreset1Month;

  /// Preset button for 6 months in the future
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get actionTimeCapsulePreset6Months;

  /// Preset button for 1 year in the future
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get actionTimeCapsulePreset1Year;

  /// Preset button for 3 years in the future
  ///
  /// In en, this message translates to:
  /// **'3 Years'**
  String get actionTimeCapsulePreset3Years;

  /// Preset button for 5 years in the future
  ///
  /// In en, this message translates to:
  /// **'5 Years'**
  String get actionTimeCapsulePreset5Years;

  /// Preset button for custom date
  ///
  /// In en, this message translates to:
  /// **'Custom Date'**
  String get actionTimeCapsulePresetCustom;

  /// Button to confirm sealing the time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal Capsule'**
  String get bodyTimeCapsuleSeal;

  /// Badge label indicating a sealed time capsule
  ///
  /// In en, this message translates to:
  /// **'Sealed Time Capsule'**
  String get labelTimeCapsuleSealedBadge;

  /// Status showing the unlock date
  ///
  /// In en, this message translates to:
  /// **'Sealed until {date}'**
  String labelTimeCapsuleSealedUntil(String date);

  /// Status showing days remaining until unlock
  ///
  /// In en, this message translates to:
  /// **'Opens in {days} days'**
  String labelTimeCapsuleOpensInDays(int days);

  /// Status showing hours remaining until unlock
  ///
  /// In en, this message translates to:
  /// **'Opens in {hours} hours'**
  String labelTimeCapsuleOpensInHours(int hours);

  /// Status when capsule unlock date is today
  ///
  /// In en, this message translates to:
  /// **'Opens today!'**
  String get descTimeCapsuleOpensToday;

  /// Status badge when a time capsule has arrived at its unlock date
  ///
  /// In en, this message translates to:
  /// **'Ready to Open'**
  String get actionTimeCapsuleReadyToOpen;

  /// Detailed explanation of cryptographic seal
  ///
  /// In en, this message translates to:
  /// **'This entry is cryptographically sealed under AES-256-GCM. The app\'s date-gated vault engine will not release the decryption key until the unlock date.'**
  String get descTimeCapsuleLocked;

  /// Button to unseal and restore the time capsule
  ///
  /// In en, this message translates to:
  /// **'Unseal Time Capsule'**
  String get actionTimeCapsuleUnseal;

  /// Button text when unseal is locked
  ///
  /// In en, this message translates to:
  /// **'Locked until {date}'**
  String actionTimeCapsuleUnsealLockedPrompt(String date);

  /// Snackbar notification after sealing entry
  ///
  /// In en, this message translates to:
  /// **'Entry sealed into a time capsule until {date}.'**
  String bodyTimeCapsuleSealedSuccess(String date);

  /// Snackbar notification after unsealing entry
  ///
  /// In en, this message translates to:
  /// **'Time capsule successfully unsealed! Welcome back to your words.'**
  String get bodyTimeCapsuleUnsealedSuccess;

  /// Error message when device clock was rolled backwards
  ///
  /// In en, this message translates to:
  /// **'Device clock rollback detected. The capsule cannot be unlocked while the device time is behind the recorded seal timestamp.'**
  String get errorTimeCapsuleClockTamper;

  /// Screen title for Time Capsules
  ///
  /// In en, this message translates to:
  /// **'Time Capsules'**
  String get titleTimeCapsule;

  /// Subtitle describing Time Capsules
  ///
  /// In en, this message translates to:
  /// **'Letters and entries sealed for your future self'**
  String get descTimeCapsule;

  /// Empty state message when no time capsules exist
  ///
  /// In en, this message translates to:
  /// **'No time capsules yet. Create an entry and seal it for your future self.'**
  String get emptyTimeCapsule;

  /// Banner title when time capsules are ready to open
  ///
  /// In en, this message translates to:
  /// **'Time Capsule Ready!'**
  String get bodyTimeCapsuleBanner;

  /// Banner body for 1 ready capsule
  ///
  /// In en, this message translates to:
  /// **'You have {count} sealed capsule ready to open today.'**
  String bodyTimeCapsuleBannerBody(int count);

  /// Banner body for multiple ready capsules
  ///
  /// In en, this message translates to:
  /// **'You have {count} sealed capsules ready to open today.'**
  String descTimeCapsuleBannerBodyPlural(int count);

  /// Header for sealed capsules
  ///
  /// In en, this message translates to:
  /// **'Sealed Capsules'**
  String get titleTimeCapsuleCategorySealed;

  /// Header for ready capsules
  ///
  /// In en, this message translates to:
  /// **'Ready to Open'**
  String get titleTimeCapsuleCategoryReady;

  /// Header for opened capsules
  ///
  /// In en, this message translates to:
  /// **'Opened Capsules'**
  String get titleTimeCapsuleCategoryOpened;

  /// Title of the create ritual card screen
  ///
  /// In en, this message translates to:
  /// **'Create Card'**
  String get titleRitualCreateCard;

  /// Title of the edit ritual card screen
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get titleRitualEditCard;

  /// FAB label on deck screen to create a new card
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get actionRitualCreateCard;

  /// Label for the theme picker in card creation
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get labelRitualCardTheme;

  /// Label for the card title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelRitualCardTitle;

  /// Hint text for card title
  ///
  /// In en, this message translates to:
  /// **'e.g. The Light of Self-Knowledge'**
  String get descRitualCardTitle;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'A title is required.'**
  String get errorRitualCardTitle;

  /// Label for the card prompt or reflection question
  ///
  /// In en, this message translates to:
  /// **'Reflection Question'**
  String get labelRitualCardPrompt;

  /// Hint text for card prompt
  ///
  /// In en, this message translates to:
  /// **'A question to reflect upon during practice...'**
  String get descRitualCardPrompt;

  /// Validation message when prompt is empty
  ///
  /// In en, this message translates to:
  /// **'A reflection question is required.'**
  String get errorRitualCardPrompt;

  /// Label for the card quote or teaching
  ///
  /// In en, this message translates to:
  /// **'Teaching or Quote'**
  String get labelRitualCardQuote;

  /// Hint text for card quote
  ///
  /// In en, this message translates to:
  /// **'A verse, shloka, or teaching...'**
  String get descRitualCardQuote;

  /// Validation message when quote is empty
  ///
  /// In en, this message translates to:
  /// **'A teaching or quote is required.'**
  String get errorRitualCardQuote;

  /// Label for the card author or source field
  ///
  /// In en, this message translates to:
  /// **'Source (optional)'**
  String get labelRitualCardAuthor;

  /// Hint text for card author or source
  ///
  /// In en, this message translates to:
  /// **'e.g. Bhagavad Gita 2.47'**
  String get descRitualCardAuthor;

  /// Label above the card preview in create or edit screen
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get labelRitualCardPreview;

  /// Button text to save a new card
  ///
  /// In en, this message translates to:
  /// **'Create Card'**
  String get actionRitualSaveCardCreate;

  /// Button text to save edits to an existing card
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get actionRitualSaveCardEdit;

  /// Snackbar after creating a card
  ///
  /// In en, this message translates to:
  /// **'Card created.'**
  String get bodyRitualCardCreated;

  /// Snackbar after editing a card
  ///
  /// In en, this message translates to:
  /// **'Card updated.'**
  String get bodyRitualCardUpdated;

  /// Snackbar when card save fails
  ///
  /// In en, this message translates to:
  /// **'Could not save the card. Please try again.'**
  String get errorRitualCardSave;

  /// Badge text on user-created cards in the deck
  ///
  /// In en, this message translates to:
  /// **'MY CARD'**
  String get labelRitualUserCardBadge;

  /// Menu item to edit a user card
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionRitualEditCard;

  /// Menu item or button to delete a user card
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionRitualDeleteCard;

  /// Title of the delete card confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get titleRitualDeleteCard;

  /// Body of the delete card confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String bodyRitualDeleteCard(String title);

  /// Snackbar after deleting a card
  ///
  /// In en, this message translates to:
  /// **'Card deleted.'**
  String get bodyRitualCardDeleted;

  /// Error shown when no journal exists to write a ritual entry into
  ///
  /// In en, this message translates to:
  /// **'Please create a journal first.'**
  String get errorRitualNoJournal;

  /// Selection menu item that moves the caret to the start of the current line. Shown as a left arrow-to-bar glyph.
  ///
  /// In en, this message translates to:
  /// **'⇤'**
  String get actionEditorGotoLineStart;

  /// Selection menu item that moves the caret to the end of the current line. Shown as a right arrow-to-bar glyph.
  ///
  /// In en, this message translates to:
  /// **'⇥'**
  String get actionEditorGotoLineEnd;

  /// Message displayed when camera permission is not granted
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to photograph documents for text recognition.'**
  String get bodyOcrCameraPermissionDenied;

  /// Button to open application settings for granting camera permission
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get actionOcrCameraOpenSettings;

  /// Message displayed when no camera hardware is available
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get bodyOcrCameraNoCameras;

  /// Tooltip/semantics for flash off mode
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get tooltipOcrCameraFlashOff;

  /// Tooltip/semantics for flash auto mode
  ///
  /// In en, this message translates to:
  /// **'Flash auto'**
  String get tooltipOcrCameraFlashAuto;

  /// Tooltip/semantics for flash on mode
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get tooltipOcrCameraFlashOn;

  /// Tooltip/semantics for torch/flashlight mode
  ///
  /// In en, this message translates to:
  /// **'Torch on'**
  String get tooltipOcrCameraFlashTorch;

  /// Tooltip for toggling the document alignment grid
  ///
  /// In en, this message translates to:
  /// **'Framing grid'**
  String get tooltipOcrCameraGridToggle;

  /// Tooltip for switching between back and front cameras
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get tooltipOcrCameraSwitch;

  /// Hint banner reminding user they can tap to focus and pinch to zoom
  ///
  /// In en, this message translates to:
  /// **'Tap to focus • Pinch to zoom'**
  String get descOcrCameraCapture;

  /// Shutter button semantics label in OCR camera
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get actionOcrCameraCapture;

  /// Button to select a photo from the device gallery directly from the camera screen
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get actionOcrCameraGallery;

  /// Label for camera exposure compensation control
  ///
  /// In en, this message translates to:
  /// **'Exposure'**
  String get labelOcrCameraExposure;

  /// Label for camera continuous zoom control
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get labelOcrCameraZoom;

  /// Tooltip/label when camera focus mode is set to auto
  ///
  /// In en, this message translates to:
  /// **'Auto focus'**
  String get tooltipOcrCameraFocusAuto;

  /// Tooltip/label when camera focus mode is locked
  ///
  /// In en, this message translates to:
  /// **'Focus locked'**
  String get tooltipOcrCameraFocusLocked;

  /// Tooltip/label when camera exposure mode is set to auto
  ///
  /// In en, this message translates to:
  /// **'Auto exposure'**
  String get tooltipOcrCameraExposureAuto;

  /// Tooltip/label when camera exposure mode is locked
  ///
  /// In en, this message translates to:
  /// **'Exposure locked'**
  String get tooltipOcrCameraExposureLocked;

  /// Tooltip/button label to open camera adjustment sliders
  ///
  /// In en, this message translates to:
  /// **'Camera controls'**
  String get tooltipOcrCameraControls;

  /// Button to reset camera exposure or zoom adjustments back to default
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionOcrCameraReset;

  /// App bar title for the image enhancement and live OCR screen
  ///
  /// In en, this message translates to:
  /// **'Enhance & Scan'**
  String get titleOcrEnhance;

  /// Tooltip for 90 degrees counter-clockwise rotation
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get tooltipOcrEnhanceRotateLeft;

  /// Tooltip for 90 degrees clockwise rotation
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get tooltipOcrEnhanceRotateRight;

  /// Label for image cropping tool
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get labelOcrEnhanceCrop;

  /// Label for image filter selection tab
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get tabOcrEnhanceFilter;

  /// Label for the toolbar button that flips light and dark, so light text on a dark background can be read
  ///
  /// In en, this message translates to:
  /// **'Invert'**
  String get actionOcrEnhanceInvert;

  /// Preset filter showing original image without modification
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get labelOcrEnhanceFilterOriginal;

  /// Document binarization filter maximizing contrast between text and background
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get labelOcrEnhanceFilterDocument;

  /// Grayscale monochrome filter
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get labelOcrEnhanceFilterGrayscale;

  /// High-contrast enhancement filter for faint text
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get actionOcrEnhanceFilterEnhance;

  /// Label for image brightness adjustment slider
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get labelOcrEnhanceBrightness;

  /// Label for image contrast adjustment slider
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get labelOcrEnhanceContrast;

  /// Tab label for brightness and contrast sliders
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get tabOcrEnhanceAdjust;

  /// Header for live OCR text preview card
  ///
  /// In en, this message translates to:
  /// **'Text found'**
  String get titleOcrEnhanceLiveText;

  /// Message shown when OCR has not detected any text in the current image
  ///
  /// In en, this message translates to:
  /// **'No text detected yet. Try adjusting contrast, rotating, or cropping closer.'**
  String get bodyOcrEnhanceLiveTextNone;

  /// Badge showing number of words recognized in the live preview
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word detected} other{{count} words detected}}'**
  String descOcrEnhanceLiveWordCount(int count);

  /// Primary button action to confirm and insert recognized text into the editor
  ///
  /// In en, this message translates to:
  /// **'Insert into Entry'**
  String get actionOcrEnhanceInsertText;

  /// Button to discard current photo and return to camera
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get actionOcrEnhanceRetake;

  /// Status text while image adjustments are being rendered
  ///
  /// In en, this message translates to:
  /// **'Enhancing image...'**
  String get bodyOcrEnhanceProcessing;

  /// Status text while live OCR recognition is running in the background
  ///
  /// In en, this message translates to:
  /// **'Scanning text...'**
  String get bodyOcrEnhanceLiveScanning;

  /// OCR language option for mixed English and Malayalam text
  ///
  /// In en, this message translates to:
  /// **'English + മലയാളം'**
  String get labelOcrLanguageAll;

  /// OCR language option for Malayalam text only
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get labelOcrLanguageMalayalam;

  /// OCR language option for English text only
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get labelOcrLanguageEnglish;

  /// Tooltip for the OCR language selector
  ///
  /// In en, this message translates to:
  /// **'Select OCR language'**
  String get tooltipOcrLanguageSelect;

  /// Title of the language picker screen and its Appearance card. Short.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get titleLanguage;

  /// Language picker option that follows the phone's language. Short. Glossary term.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelLanguageSystemDefault;

  /// Explains the System default language option. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Follows the phone\'s language, or English if the phone\'s language is not available.'**
  String get descLanguageSystemDefault;

  /// The English option in the language picker, written in its own script (endonym). Not translated.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get labelLanguageEnglish;

  /// The Malayalam option in the language picker, written in its own script (endonym). Not translated.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get labelLanguageMalayalam;

  /// The Sanskrit option in the language picker, written in its own script (endonym). Not translated.
  ///
  /// In en, this message translates to:
  /// **'संस्कृतम्'**
  String get labelLanguageSanskrit;

  /// Screen-reader label for the Language card, naming the current choice.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String labelLanguageCurrent(String language);

  /// About screen row label for the config key 'author'. Glossary term.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutDetailAuthor;

  /// About screen row label for the config key 'email'. Glossary term.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutDetailEmail;

  /// About screen row label for the config key 'license'. Glossary term.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutDetailLicense;

  /// About screen row label for the config key 'aiUsed'. Glossary term. May wrap to two lines.
  ///
  /// In en, this message translates to:
  /// **'AI used'**
  String get aboutDetailAiUsed;

  /// About screen row label for the config key 'ideUsed'. Glossary term. May wrap to two lines.
  ///
  /// In en, this message translates to:
  /// **'IDE used'**
  String get aboutDetailIdeUsed;

  /// About screen value shown when the build date is not known.
  ///
  /// In en, this message translates to:
  /// **'Build date unavailable'**
  String get bodyAboutBuildDateUnavailable;

  /// About-screen signature badge. {heart} is a red heart glyph. Fixed wording from guideline.md section 1.7 — do not reword.
  ///
  /// In en, this message translates to:
  /// **'Made with {heart} from India'**
  String madeWithLove(String heart);

  /// Screen-reader text for the About badge. Fixed wording from guideline.md section 1.7.
  ///
  /// In en, this message translates to:
  /// **'Made with love from India'**
  String get madeWithLoveA11y;

  /// Tooltip on the search app-bar button that shows only entries. Short.
  ///
  /// In en, this message translates to:
  /// **'Filter entries'**
  String get tooltipFilterEntries;

  /// Tooltip on the search app-bar button that saves the search as a preset. Short.
  ///
  /// In en, this message translates to:
  /// **'Save search'**
  String get tooltipSaveSearch;

  /// Tooltip on the AirQR receive screen button that restarts scanning. Short.
  ///
  /// In en, this message translates to:
  /// **'Reset scanner'**
  String get tooltipResetScanner;

  /// Tooltip on the QR scanner button that turns the camera torch on or off. Short.
  ///
  /// In en, this message translates to:
  /// **'Toggle torch'**
  String get tooltipToggleTorch;

  /// Tooltip on the QR scanner button that switches between front and back camera. Short.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get tooltipSwitchCamera;

  /// Tooltip on the AirQR send screen button that copies the pairing code. Short.
  ///
  /// In en, this message translates to:
  /// **'Copy pairing code'**
  String get tooltipCopyPairingCode;

  /// Tooltip on the AirQR send screen button that lowers the frame rate. Short.
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get tooltipSlower;

  /// Tooltip on the AirQR send screen button that raises the frame rate. Short.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get tooltipFaster;

  /// Tooltip on the voice note record button. Short.
  ///
  /// In en, this message translates to:
  /// **'Record voice note'**
  String get tooltipRecordVoiceNote;

  /// Tooltip on the voice note button while recording. Short.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get tooltipStopRecording;

  /// Tooltip on a three-dot menu button. Short. Glossary term 'More'.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tooltipMoreOptions;

  /// Tooltip on the info button of a security event row. Short.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get tooltipShowDetails;

  /// Tooltip on the small close button that removes a callout block from the editor. Short. Glossary term.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tooltipRemove;

  /// Ritual deck card 1: title.
  ///
  /// In en, this message translates to:
  /// **'Your Swadharma'**
  String get descRitualCard01Title;

  /// Ritual deck card 1: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is the unique duty or calling that only you can fulfil in this season of your life? How are you honouring it today?'**
  String get descRitualCard01Prompt;

  /// Ritual deck card 1: quote.
  ///
  /// In en, this message translates to:
  /// **'It is better to perform one\'s own duty imperfectly than to perform another\'s duty perfectly.'**
  String get descRitualCard01Quote;

  /// Ritual deck card 1: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 3.35'**
  String get descRitualCard01Source;

  /// Ritual deck card 2: title.
  ///
  /// In en, this message translates to:
  /// **'Righteousness in the Small'**
  String get descRitualCard02Title;

  /// Ritual deck card 2: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'In what small, everyday action today can you choose what is right over what is easy or popular?'**
  String get descRitualCard02Prompt;

  /// Ritual deck card 2: quote.
  ///
  /// In en, this message translates to:
  /// **'Dharma exists for the welfare of all beings. Hence, that by which the welfare of all living beings is sustained, that is Dharma.'**
  String get descRitualCard02Quote;

  /// Ritual deck card 2: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Mahabharata, Shanti Parva 109.10'**
  String get descRitualCard02Source;

  /// Ritual deck card 3: title.
  ///
  /// In en, this message translates to:
  /// **'The Wheel of Dharma'**
  String get descRitualCard03Title;

  /// Ritual deck card 3: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Reflect on one relationship or responsibility you hold. Are you nurturing it with integrity, or have you been neglecting its call?'**
  String get descRitualCard03Prompt;

  /// Ritual deck card 3: quote.
  ///
  /// In en, this message translates to:
  /// **'When Dharma is protected, Dharma protects.'**
  String get descRitualCard03Quote;

  /// Ritual deck card 3: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Manusmriti 8.15'**
  String get descRitualCard03Source;

  /// Ritual deck card 4: title.
  ///
  /// In en, this message translates to:
  /// **'The Eternal Order'**
  String get descRitualCard04Title;

  /// Ritual deck card 4: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Where in nature — the rising sun, the changing seasons, the flowing river — do you see the rhythm of Rta (cosmic order), and how does it mirror your own life?'**
  String get descRitualCard04Prompt;

  /// Ritual deck card 4: quote.
  ///
  /// In en, this message translates to:
  /// **'The rivers flow into the ocean but the ocean never overflows. Likewise, desires flow into the wise one, who remains ever at peace.'**
  String get descRitualCard04Quote;

  /// Ritual deck card 4: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.70'**
  String get descRitualCard04Source;

  /// Ritual deck card 5: title.
  ///
  /// In en, this message translates to:
  /// **'Dharma in Adversity'**
  String get descRitualCard05Title;

  /// Ritual deck card 5: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'When life tests you, what principle or value do you refuse to compromise? Why does it matter to you?'**
  String get descRitualCard05Prompt;

  /// Ritual deck card 5: quote.
  ///
  /// In en, this message translates to:
  /// **'Even in the most difficult of times, one should not abandon Dharma.'**
  String get descRitualCard05Quote;

  /// Ritual deck card 5: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Ramayana, Ayodhya Kanda'**
  String get descRitualCard05Source;

  /// Ritual deck card 6: title.
  ///
  /// In en, this message translates to:
  /// **'Action Without Attachment'**
  String get descRitualCard06Title;

  /// Ritual deck card 6: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is one task or effort you are doing today where you can let go of the result and focus purely on the quality of your action?'**
  String get descRitualCard06Prompt;

  /// Ritual deck card 6: quote.
  ///
  /// In en, this message translates to:
  /// **'You have the right to perform your duty, but you are not entitled to the fruits of your actions.'**
  String get descRitualCard06Quote;

  /// Ritual deck card 6: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.47'**
  String get descRitualCard06Source;

  /// Ritual deck card 7: title.
  ///
  /// In en, this message translates to:
  /// **'The Seed You Plant Today'**
  String get descRitualCard07Title;

  /// Ritual deck card 7: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Every action is a seed. What kind of seed — patience, kindness, discipline, or something else — are you planting today?'**
  String get descRitualCard07Prompt;

  /// Ritual deck card 7: quote.
  ///
  /// In en, this message translates to:
  /// **'As a man sows, so shall he reap. There is no escape from the fruits of one\'s actions.'**
  String get descRitualCard07Quote;

  /// Ritual deck card 7: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Mahabharata, Vana Parva'**
  String get descRitualCard07Source;

  /// Ritual deck card 8: title.
  ///
  /// In en, this message translates to:
  /// **'Nishkama Karma'**
  String get descRitualCard08Title;

  /// Ritual deck card 8: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Think of something you did purely for its own sake, without wanting praise or reward. How did that feel? Can you bring that spirit to more of your day?'**
  String get descRitualCard08Prompt;

  /// Ritual deck card 8: quote.
  ///
  /// In en, this message translates to:
  /// **'The wise, engaged in selfless action, surrender all attachment to results and attain supreme peace.'**
  String get descRitualCard08Quote;

  /// Ritual deck card 8: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 5.12'**
  String get descRitualCard08Source;

  /// Ritual deck card 9: title.
  ///
  /// In en, this message translates to:
  /// **'Breaking the Chain'**
  String get descRitualCard09Title;

  /// Ritual deck card 9: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Is there a pattern of reaction — anger, avoidance, blame — that you keep repeating? What would it look like to consciously choose a different response today?'**
  String get descRitualCard09Prompt;

  /// Ritual deck card 9: quote.
  ///
  /// In en, this message translates to:
  /// **'One who restrains the senses and organs of action, but whose mind dwells on sense objects, is deluded and called a hypocrite.'**
  String get descRitualCard09Quote;

  /// Ritual deck card 9: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 3.6'**
  String get descRitualCard09Source;

  /// Ritual deck card 10: title.
  ///
  /// In en, this message translates to:
  /// **'Karma Yoga in Daily Life'**
  String get descRitualCard10Title;

  /// Ritual deck card 10: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'How can you transform an ordinary task today — cooking, cleaning, working — into an offering, performing it with full attention and devotion?'**
  String get descRitualCard10Prompt;

  /// Ritual deck card 10: quote.
  ///
  /// In en, this message translates to:
  /// **'Whatever you do, whatever you eat, whatever you offer in sacrifice, whatever you give, whatever austerity you practise — do it as an offering to Me.'**
  String get descRitualCard10Quote;

  /// Ritual deck card 10: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 9.27'**
  String get descRitualCard10Source;

  /// Ritual deck card 11: title.
  ///
  /// In en, this message translates to:
  /// **'The Heart of Devotion'**
  String get descRitualCard11Title;

  /// Ritual deck card 11: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What fills your heart with reverence and love — a prayer, a memory, a place, the thought of the Divine? Dwell on it now.'**
  String get descRitualCard11Prompt;

  /// Ritual deck card 11: quote.
  ///
  /// In en, this message translates to:
  /// **'Whoever offers Me with devotion a leaf, a flower, a fruit, or water — that offering of love I accept from the pure-hearted.'**
  String get descRitualCard11Quote;

  /// Ritual deck card 11: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 9.26'**
  String get descRitualCard11Source;

  /// Ritual deck card 12: title.
  ///
  /// In en, this message translates to:
  /// **'Surrender and Trust'**
  String get descRitualCard12Title;

  /// Ritual deck card 12: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What worry or burden can you mentally place at the feet of the Divine today, trusting that grace will carry you through?'**
  String get descRitualCard12Prompt;

  /// Ritual deck card 12: quote.
  ///
  /// In en, this message translates to:
  /// **'Abandon all varieties of Dharma and simply surrender unto Me. I shall deliver you from all sinful reactions; do not fear.'**
  String get descRitualCard12Quote;

  /// Ritual deck card 12: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 18.66'**
  String get descRitualCard12Source;

  /// Ritual deck card 13: title.
  ///
  /// In en, this message translates to:
  /// **'Seeing God in All'**
  String get descRitualCard13Title;

  /// Ritual deck card 13: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Can you look at every person you meet today as a form of the Divine? How would that change the way you speak and listen?'**
  String get descRitualCard13Prompt;

  /// Ritual deck card 13: quote.
  ///
  /// In en, this message translates to:
  /// **'The wise see the same Divine Self equally in a learned Brahmin, a cow, an elephant, a dog, and an outcaste.'**
  String get descRitualCard13Quote;

  /// Ritual deck card 13: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 5.18'**
  String get descRitualCard13Source;

  /// Ritual deck card 14: title.
  ///
  /// In en, this message translates to:
  /// **'The Name that Purifies'**
  String get descRitualCard14Title;

  /// Ritual deck card 14: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'When was the last time you sat quietly and repeated a sacred name or mantra? What feelings arose when you did?'**
  String get descRitualCard14Prompt;

  /// Ritual deck card 14: quote.
  ///
  /// In en, this message translates to:
  /// **'The name of the Lord is the boat that will take you across the ocean of worldly existence.'**
  String get descRitualCard14Quote;

  /// Ritual deck card 14: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Tulsidas, Ramcharitmanas'**
  String get descRitualCard14Source;

  /// Ritual deck card 15: title.
  ///
  /// In en, this message translates to:
  /// **'Grace in Gratitude'**
  String get descRitualCard15Title;

  /// Ritual deck card 15: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What unexpected blessing or moment of grace have you received recently that you have not yet paused to acknowledge?'**
  String get descRitualCard15Prompt;

  /// Ritual deck card 15: quote.
  ///
  /// In en, this message translates to:
  /// **'I am the origin of all. Everything emanates from Me. The wise who know this worship Me with loving devotion.'**
  String get descRitualCard15Quote;

  /// Ritual deck card 15: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 10.8'**
  String get descRitualCard15Source;

  /// Ritual deck card 16: title.
  ///
  /// In en, this message translates to:
  /// **'Who Am I?'**
  String get descRitualCard16Title;

  /// Ritual deck card 16: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Strip away your name, your job, your roles, your body. What remains? Sit with this question: Who am I beyond all labels?'**
  String get descRitualCard16Prompt;

  /// Ritual deck card 16: quote.
  ///
  /// In en, this message translates to:
  /// **'Tat Tvam Asi — Thou art That.'**
  String get descRitualCard16Quote;

  /// Ritual deck card 16: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Chandogya Upanishad 6.8.7'**
  String get descRitualCard16Source;

  /// Ritual deck card 17: title.
  ///
  /// In en, this message translates to:
  /// **'The Eternal Witness'**
  String get descRitualCard17Title;

  /// Ritual deck card 17: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Observe your thoughts passing by without grasping any of them. Who is the one watching? Can that awareness itself ever be harmed?'**
  String get descRitualCard17Prompt;

  /// Ritual deck card 17: quote.
  ///
  /// In en, this message translates to:
  /// **'The Self is never born, nor does it die. It is eternal, ever-existing, and primeval. It is not slain when the body is slain.'**
  String get descRitualCard17Quote;

  /// Ritual deck card 17: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.20'**
  String get descRitualCard17Source;

  /// Ritual deck card 18: title.
  ///
  /// In en, this message translates to:
  /// **'Knowledge That Frees'**
  String get descRitualCard18Title;

  /// Ritual deck card 18: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is one truth about yourself or about life that, once you truly accepted it, freed you from suffering?'**
  String get descRitualCard18Prompt;

  /// Ritual deck card 18: quote.
  ///
  /// In en, this message translates to:
  /// **'There is nothing as purifying in this world as knowledge. One who has attained purity of mind through prolonged Yoga discovers this knowledge within, in due course of time.'**
  String get descRitualCard18Quote;

  /// Ritual deck card 18: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 4.38'**
  String get descRitualCard18Source;

  /// Ritual deck card 19: title.
  ///
  /// In en, this message translates to:
  /// **'Beyond the Senses'**
  String get descRitualCard19Title;

  /// Ritual deck card 19: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Your senses show you the surface of things. What deeper truth lies beneath the situation you are facing right now?'**
  String get descRitualCard19Prompt;

  /// Ritual deck card 19: quote.
  ///
  /// In en, this message translates to:
  /// **'Beyond the senses are the objects; beyond the objects is the mind; beyond the mind is the intellect; beyond the intellect is the Great Self.'**
  String get descRitualCard19Quote;

  /// Ritual deck card 19: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Katha Upanishad 1.3.10'**
  String get descRitualCard19Source;

  /// Ritual deck card 20: title.
  ///
  /// In en, this message translates to:
  /// **'The Light Within'**
  String get descRitualCard20Title;

  /// Ritual deck card 20: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes. Imagine a steady flame burning in your heart that no wind can extinguish. What does this light illuminate for you?'**
  String get descRitualCard20Prompt;

  /// Ritual deck card 20: quote.
  ///
  /// In en, this message translates to:
  /// **'Asato ma sadgamaya, tamaso ma jyotirgamaya, mrityorma amritam gamaya. Lead me from the unreal to the Real, from darkness to Light, from death to Immortality.'**
  String get descRitualCard20Quote;

  /// Ritual deck card 20: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Brihadaranyaka Upanishad 1.3.28'**
  String get descRitualCard20Source;

  /// Ritual deck card 21: title.
  ///
  /// In en, this message translates to:
  /// **'The Fullness of Being'**
  String get descRitualCard21Title;

  /// Ritual deck card 21: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'If you lack nothing at the deepest level, why do you feel incomplete? Reflect on what it means to be already whole.'**
  String get descRitualCard21Prompt;

  /// Ritual deck card 21: quote.
  ///
  /// In en, this message translates to:
  /// **'Om Purnamadah Purnamidam — That is Whole, this is Whole. From the Whole, the Whole arises. When the Whole is taken from the Whole, the Whole still remains.'**
  String get descRitualCard21Quote;

  /// Ritual deck card 21: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Isha Upanishad, Invocation'**
  String get descRitualCard21Source;

  /// Ritual deck card 22: title.
  ///
  /// In en, this message translates to:
  /// **'Brahman in Everything'**
  String get descRitualCard22Title;

  /// Ritual deck card 22: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'The same consciousness that shines through you shines through every living being. How does this awareness change the way you see the world today?'**
  String get descRitualCard22Prompt;

  /// Ritual deck card 22: quote.
  ///
  /// In en, this message translates to:
  /// **'Aham Brahmasmi — I am Brahman.'**
  String get descRitualCard22Quote;

  /// Ritual deck card 22: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Brihadaranyaka Upanishad 1.4.10'**
  String get descRitualCard22Source;

  /// Ritual deck card 23: title.
  ///
  /// In en, this message translates to:
  /// **'Stilling the Mind'**
  String get descRitualCard23Title;

  /// Ritual deck card 23: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Right now, observe the fluctuations of your mind — planning, worrying, remembering. Can you gently bring all of them to stillness, even for a few breaths?'**
  String get descRitualCard23Prompt;

  /// Ritual deck card 23: quote.
  ///
  /// In en, this message translates to:
  /// **'Yogas chitta vritti nirodhah — Yoga is the cessation of the fluctuations of the mind.'**
  String get descRitualCard23Quote;

  /// Ritual deck card 23: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 1.2'**
  String get descRitualCard23Source;

  /// Ritual deck card 24: title.
  ///
  /// In en, this message translates to:
  /// **'Steady Practice'**
  String get descRitualCard24Title;

  /// Ritual deck card 24: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is one positive habit or practice you can commit to with patience and devotion, knowing that consistency matters more than intensity?'**
  String get descRitualCard24Prompt;

  /// Ritual deck card 24: quote.
  ///
  /// In en, this message translates to:
  /// **'Abhyasa — practice becomes firmly grounded when it is pursued for a long time, without interruption, and with sincere devotion.'**
  String get descRitualCard24Quote;

  /// Ritual deck card 24: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 1.14'**
  String get descRitualCard24Source;

  /// Ritual deck card 25: title.
  ///
  /// In en, this message translates to:
  /// **'Evenness of Mind'**
  String get descRitualCard25Title;

  /// Ritual deck card 25: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Recall a recent moment of success and a moment of failure. Can you hold both with the same steady awareness, without elation or despair?'**
  String get descRitualCard25Prompt;

  /// Ritual deck card 25: quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga is equanimity of mind — samatvam yoga uchyate.'**
  String get descRitualCard25Quote;

  /// Ritual deck card 25: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.48'**
  String get descRitualCard25Source;

  /// Ritual deck card 26: title.
  ///
  /// In en, this message translates to:
  /// **'The Five Yamas'**
  String get descRitualCard26Title;

  /// Ritual deck card 26: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Non-violence, truthfulness, non-stealing, moderation, non-possessiveness — which of the five Yamas is the hardest for you right now, and why?'**
  String get descRitualCard26Prompt;

  /// Ritual deck card 26: quote.
  ///
  /// In en, this message translates to:
  /// **'Ahimsa, Satya, Asteya, Brahmacharya, Aparigraha — these are the great universal vows.'**
  String get descRitualCard26Quote;

  /// Ritual deck card 26: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 2.30'**
  String get descRitualCard26Source;

  /// Ritual deck card 27: title.
  ///
  /// In en, this message translates to:
  /// **'Ishvara Pranidhana'**
  String get descRitualCard27Title;

  /// Ritual deck card 27: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What does it feel like to offer your effort completely — not to achieve, but to dedicate? Try offering your next action to something greater than yourself.'**
  String get descRitualCard27Prompt;

  /// Ritual deck card 27: quote.
  ///
  /// In en, this message translates to:
  /// **'By total surrender to Ishvara, Samadhi is attained.'**
  String get descRitualCard27Quote;

  /// Ritual deck card 27: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 2.45'**
  String get descRitualCard27Source;

  /// Ritual deck card 28: title.
  ///
  /// In en, this message translates to:
  /// **'Non-Violence in Thought'**
  String get descRitualCard28Title;

  /// Ritual deck card 28: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Have you directed harsh, violent thoughts towards yourself or someone else today? What would it mean to replace them with understanding?'**
  String get descRitualCard28Prompt;

  /// Ritual deck card 28: quote.
  ///
  /// In en, this message translates to:
  /// **'Ahimsa Paramo Dharma — Non-violence is the highest Dharma.'**
  String get descRitualCard28Quote;

  /// Ritual deck card 28: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Mahabharata, Anushasana Parva 116.38'**
  String get descRitualCard28Source;

  /// Ritual deck card 29: title.
  ///
  /// In en, this message translates to:
  /// **'Compassion for All Beings'**
  String get descRitualCard29Title;

  /// Ritual deck card 29: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Think of a creature — an animal, an insect, a bird — you encountered recently. What would the world be like if you extended the same care to all living beings?'**
  String get descRitualCard29Prompt;

  /// Ritual deck card 29: quote.
  ///
  /// In en, this message translates to:
  /// **'One who sees all beings in the Self and the Self in all beings, never turns away from it.'**
  String get descRitualCard29Quote;

  /// Ritual deck card 29: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Isha Upanishad, Verse 6'**
  String get descRitualCard29Source;

  /// Ritual deck card 30: title.
  ///
  /// In en, this message translates to:
  /// **'Gentle Speech'**
  String get descRitualCard30Title;

  /// Ritual deck card 30: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Before you speak today, pause and ask: Is it true? Is it kind? Is it necessary? How does this filter change your conversations?'**
  String get descRitualCard30Prompt;

  /// Ritual deck card 30: quote.
  ///
  /// In en, this message translates to:
  /// **'Words that do not cause distress, that are truthful, pleasant, and beneficial — this is called the austerity of speech.'**
  String get descRitualCard30Quote;

  /// Ritual deck card 30: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 17.15'**
  String get descRitualCard30Source;

  /// Ritual deck card 31: title.
  ///
  /// In en, this message translates to:
  /// **'Forgiving the Hurt'**
  String get descRitualCard31Title;

  /// Ritual deck card 31: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Who has caused you pain that you are still carrying? What would it take to forgive — not for them, but to free your own heart?'**
  String get descRitualCard31Prompt;

  /// Ritual deck card 31: quote.
  ///
  /// In en, this message translates to:
  /// **'Forgiveness is the ornament of the brave.'**
  String get descRitualCard31Quote;

  /// Ritual deck card 31: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Mahabharata, Udyoga Parva 33.48'**
  String get descRitualCard31Source;

  /// Ritual deck card 32: title.
  ///
  /// In en, this message translates to:
  /// **'Living in Truth'**
  String get descRitualCard32Title;

  /// Ritual deck card 32: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Is there something in your life where you are being less than truthful — with yourself or with others? What would honest alignment look like?'**
  String get descRitualCard32Prompt;

  /// Ritual deck card 32: quote.
  ///
  /// In en, this message translates to:
  /// **'Satyameva Jayate — Truth alone triumphs.'**
  String get descRitualCard32Quote;

  /// Ritual deck card 32: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Mundaka Upanishad 3.1.6'**
  String get descRitualCard32Source;

  /// Ritual deck card 33: title.
  ///
  /// In en, this message translates to:
  /// **'The Courage of Honesty'**
  String get descRitualCard33Title;

  /// Ritual deck card 33: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is one truth you have been avoiding because it is uncomfortable? What would it take to face it with courage today?'**
  String get descRitualCard33Prompt;

  /// Ritual deck card 33: quote.
  ///
  /// In en, this message translates to:
  /// **'Speak the truth. Practise Dharma. Do not neglect the study of the scriptures.'**
  String get descRitualCard33Quote;

  /// Ritual deck card 33: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Taittiriya Upanishad 1.11.1'**
  String get descRitualCard33Source;

  /// Ritual deck card 34: title.
  ///
  /// In en, this message translates to:
  /// **'Truth Beyond Words'**
  String get descRitualCard34Title;

  /// Ritual deck card 34: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Truth is not only in what you say, but in what you do. Are your actions today aligned with the truth you hold in your heart?'**
  String get descRitualCard34Prompt;

  /// Ritual deck card 34: quote.
  ///
  /// In en, this message translates to:
  /// **'By truthfulness, man reaches the station of God.'**
  String get descRitualCard34Quote;

  /// Ritual deck card 34: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Chanakya Niti 14.3'**
  String get descRitualCard34Source;

  /// Ritual deck card 35: title.
  ///
  /// In en, this message translates to:
  /// **'The Promise You Keep'**
  String get descRitualCard35Title;

  /// Ritual deck card 35: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What is a promise you have made — to yourself, to another, or to the Divine — that you must honour? Recommit to it now.'**
  String get descRitualCard35Prompt;

  /// Ritual deck card 35: quote.
  ///
  /// In en, this message translates to:
  /// **'Let your word be your bond. A person who breaks a promise breaks trust, and trust once broken is hard to rebuild.'**
  String get descRitualCard35Quote;

  /// Ritual deck card 35: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Vidura Niti, Mahabharata'**
  String get descRitualCard35Source;

  /// Ritual deck card 36: title.
  ///
  /// In en, this message translates to:
  /// **'Letting Go'**
  String get descRitualCard36Title;

  /// Ritual deck card 36: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What possession, expectation, or desire are you clinging to that no longer serves your growth? Imagine gently releasing it.'**
  String get descRitualCard36Prompt;

  /// Ritual deck card 36: quote.
  ///
  /// In en, this message translates to:
  /// **'Vairagya is the mastery of consciousness in which one is free from craving for sense objects, whether experienced directly or described.'**
  String get descRitualCard36Quote;

  /// Ritual deck card 36: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 1.15'**
  String get descRitualCard36Source;

  /// Ritual deck card 37: title.
  ///
  /// In en, this message translates to:
  /// **'The Unchanging Self'**
  String get descRitualCard37Title;

  /// Ritual deck card 37: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Everything around you changes — moods, fortunes, relationships. What part of you has remained unchanged through all of life\'s storms?'**
  String get descRitualCard37Prompt;

  /// Ritual deck card 37: quote.
  ///
  /// In en, this message translates to:
  /// **'That which is not real never was and never will be. That which is real always was and can never cease to be.'**
  String get descRitualCard37Quote;

  /// Ritual deck card 37: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.16'**
  String get descRitualCard37Source;

  /// Ritual deck card 38: title.
  ///
  /// In en, this message translates to:
  /// **'Contentment'**
  String get descRitualCard38Title;

  /// Ritual deck card 38: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What do you already have that is truly enough? Reflect on the difference between want and need in your life right now.'**
  String get descRitualCard38Prompt;

  /// Ritual deck card 38: quote.
  ///
  /// In en, this message translates to:
  /// **'From contentment comes unsurpassed happiness.'**
  String get descRitualCard38Quote;

  /// Ritual deck card 38: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Yoga Sutras of Patanjali 2.42'**
  String get descRitualCard38Source;

  /// Ritual deck card 39: title.
  ///
  /// In en, this message translates to:
  /// **'Beyond Pleasure and Pain'**
  String get descRitualCard39Title;

  /// Ritual deck card 39: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Can you sit with discomfort without fleeing, and with pleasure without grasping? What happens when you simply observe both?'**
  String get descRitualCard39Prompt;

  /// Ritual deck card 39: quote.
  ///
  /// In en, this message translates to:
  /// **'One who is not disturbed by happiness and distress and is steady in both is certainly eligible for liberation.'**
  String get descRitualCard39Quote;

  /// Ritual deck card 39: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 2.15'**
  String get descRitualCard39Source;

  /// Ritual deck card 40: title.
  ///
  /// In en, this message translates to:
  /// **'The Joy of Giving'**
  String get descRitualCard40Title;

  /// Ritual deck card 40: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What can you give today — time, attention, a kind word, a helping hand — without expecting anything in return?'**
  String get descRitualCard40Prompt;

  /// Ritual deck card 40: quote.
  ///
  /// In en, this message translates to:
  /// **'The highest form of charity is helping those who are helpless.'**
  String get descRitualCard40Quote;

  /// Ritual deck card 40: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Thirukkural 221'**
  String get descRitualCard40Source;

  /// Ritual deck card 41: title.
  ///
  /// In en, this message translates to:
  /// **'Serving the Divine in Others'**
  String get descRitualCard41Title;

  /// Ritual deck card 41: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'If the person standing in front of you were God in disguise, how would you treat them? Try living this for the next hour.'**
  String get descRitualCard41Prompt;

  /// Ritual deck card 41: quote.
  ///
  /// In en, this message translates to:
  /// **'Service to humanity is service to God.'**
  String get descRitualCard41Quote;

  /// Ritual deck card 41: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Swami Vivekananda'**
  String get descRitualCard41Source;

  /// Ritual deck card 42: title.
  ///
  /// In en, this message translates to:
  /// **'Selfless Work'**
  String get descRitualCard42Title;

  /// Ritual deck card 42: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Recall a time when you helped someone and felt a quiet, deep joy that had nothing to do with recognition. What did that teach you?'**
  String get descRitualCard42Prompt;

  /// Ritual deck card 42: quote.
  ///
  /// In en, this message translates to:
  /// **'Arise, awake, and stop not till the goal is reached.'**
  String get descRitualCard42Quote;

  /// Ritual deck card 42: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Katha Upanishad 1.3.14 / Swami Vivekananda'**
  String get descRitualCard42Source;

  /// Ritual deck card 43: title.
  ///
  /// In en, this message translates to:
  /// **'Vasudhaiva Kutumbakam'**
  String get descRitualCard43Title;

  /// Ritual deck card 43: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'The whole world is one family. What is one step you can take today to live as though every person\'s well-being matters to you?'**
  String get descRitualCard43Prompt;

  /// Ritual deck card 43: quote.
  ///
  /// In en, this message translates to:
  /// **'Vasudhaiva Kutumbakam — the entire world is one family.'**
  String get descRitualCard43Quote;

  /// Ritual deck card 43: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Maha Upanishad 6.71'**
  String get descRitualCard43Source;

  /// Ritual deck card 44: title.
  ///
  /// In en, this message translates to:
  /// **'The Wealth of Kindness'**
  String get descRitualCard44Title;

  /// Ritual deck card 44: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What small act of kindness did someone do for you that you still remember? How can you pass that same kindness forward today?'**
  String get descRitualCard44Prompt;

  /// Ritual deck card 44: quote.
  ///
  /// In en, this message translates to:
  /// **'Even the poverty of the poor will depart if they give, with compassion, even what little they have.'**
  String get descRitualCard44Quote;

  /// Ritual deck card 44: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Thirukkural 247'**
  String get descRitualCard44Source;

  /// Ritual deck card 45: title.
  ///
  /// In en, this message translates to:
  /// **'The Peace Within'**
  String get descRitualCard45Title;

  /// Ritual deck card 45: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes and take three slow breaths. Feel the silence between each breath. That silence is who you truly are. Can you carry it through the day?'**
  String get descRitualCard45Prompt;

  /// Ritual deck card 45: quote.
  ///
  /// In en, this message translates to:
  /// **'For one who has conquered the mind, the mind is the best of friends; but for one who has failed to do so, the mind will remain the greatest enemy.'**
  String get descRitualCard45Quote;

  /// Ritual deck card 45: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 6.6'**
  String get descRitualCard45Source;

  /// Ritual deck card 46: title.
  ///
  /// In en, this message translates to:
  /// **'Equanimity in Praise and Blame'**
  String get descRitualCard46Title;

  /// Ritual deck card 46: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Recall a recent praise and a recent criticism you received. Can you hold both with the same calm composure, without clinging to one or rejecting the other?'**
  String get descRitualCard46Prompt;

  /// Ritual deck card 46: quote.
  ///
  /// In en, this message translates to:
  /// **'One who is the same to friend and foe, in honour and dishonour, in heat and cold, in pleasure and pain, and is free from attachment — such a person is dear to Me.'**
  String get descRitualCard46Quote;

  /// Ritual deck card 46: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 12.18–19'**
  String get descRitualCard46Source;

  /// Ritual deck card 47: title.
  ///
  /// In en, this message translates to:
  /// **'The Lotus in Mud'**
  String get descRitualCard47Title;

  /// Ritual deck card 47: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'A lotus blooms in muddy water yet remains unstained. What is the muddy situation in your life right now, and how can you remain untouched by it while still growing?'**
  String get descRitualCard47Prompt;

  /// Ritual deck card 47: quote.
  ///
  /// In en, this message translates to:
  /// **'One who performs actions without attachment, surrendering them to Brahman, is untouched by sin, like a lotus leaf by water.'**
  String get descRitualCard47Quote;

  /// Ritual deck card 47: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita 5.10'**
  String get descRitualCard47Source;

  /// Ritual deck card 48: title.
  ///
  /// In en, this message translates to:
  /// **'Om Shanti'**
  String get descRitualCard48Title;

  /// Ritual deck card 48: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Sit still and repeat Om Shanti three times — peace in body, peace in mind, peace in spirit. What disturbance melts away as you do this?'**
  String get descRitualCard48Prompt;

  /// Ritual deck card 48: quote.
  ///
  /// In en, this message translates to:
  /// **'Om Shantih Shantih Shantih — Om, Peace, Peace, Peace.'**
  String get descRitualCard48Quote;

  /// Ritual deck card 48: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Upanishadic Shanti Mantra'**
  String get descRitualCard48Source;

  /// Ritual deck card 49: title.
  ///
  /// In en, this message translates to:
  /// **'May All Be Happy'**
  String get descRitualCard49Title;

  /// Ritual deck card 49: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Silently wish well-being for yourself, then for your loved ones, then for strangers, then for all beings. Notice how your heart expands as the circle widens.'**
  String get descRitualCard49Prompt;

  /// Ritual deck card 49: quote.
  ///
  /// In en, this message translates to:
  /// **'Sarve bhavantu sukhinah, sarve santu niramayah. Sarve bhadrani pashyantu, ma kashchit duhkhabhag bhavet. — May all be happy, may all be free from disease, may all see auspiciousness, may none suffer.'**
  String get descRitualCard49Quote;

  /// Ritual deck card 49: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Upanishadic Prayer'**
  String get descRitualCard49Source;

  /// Ritual deck card 50: title.
  ///
  /// In en, this message translates to:
  /// **'Strength and Peace Together'**
  String get descRitualCard50Title;

  /// Ritual deck card 50: reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'True strength does not come from tension; it comes from deep inner peace. Where in your life can you replace force with calm resolve today?'**
  String get descRitualCard50Prompt;

  /// Ritual deck card 50: quote.
  ///
  /// In en, this message translates to:
  /// **'Strength is life, weakness is death. Strength is the medicine, strength is the cure. Strength, strength is what the Upanishads preach.'**
  String get descRitualCard50Quote;

  /// Ritual deck card 50: source of the quote.
  ///
  /// In en, this message translates to:
  /// **'Swami Vivekananda'**
  String get descRitualCard50Source;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Dharma'**
  String get labelRitualThemeDharma;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Karma'**
  String get labelRitualThemeKarma;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Bhakti'**
  String get labelRitualThemeBhakti;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Jnana'**
  String get labelRitualThemeJnana;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get labelRitualThemeYoga;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Ahimsa'**
  String get labelRitualThemeAhimsa;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Sathya'**
  String get labelRitualThemeSathya;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Vairagya'**
  String get labelRitualThemeVairagya;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Seva'**
  String get labelRitualThemeSeva;

  /// Ritual deck theme name. Short.
  ///
  /// In en, this message translates to:
  /// **'Shanti'**
  String get labelRitualThemeShanti;

  /// Breathing technique name: equal inhale, hold, exhale, hold. The rhythm digits are shown beside it separately. Short.
  ///
  /// In en, this message translates to:
  /// **'Box breathing'**
  String get labelBreathTechniqueBox;

  /// Breathing technique name: the 4-7-8 relaxing breath. Short.
  ///
  /// In en, this message translates to:
  /// **'Relaxing breath'**
  String get labelBreathTechniqueRelaxing;

  /// Breathing technique name: simple equal inhale and exhale. Short.
  ///
  /// In en, this message translates to:
  /// **'Calm rhythm'**
  String get labelBreathTechniqueCalm;

  /// Breathing phase label shown in the breathing circle. Short.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get labelBreathPhaseInhale;

  /// Breathing phase label: hold after inhaling. Short.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get labelBreathPhaseHold;

  /// Breathing phase label shown in the breathing circle. Short.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get labelBreathPhaseExhale;

  /// Breathing phase label: rest after exhaling. Short.
  ///
  /// In en, this message translates to:
  /// **'Hold & rest'**
  String get labelBreathPhaseRest;

  /// Guidance line under the breathing circle during the inhale phase.
  ///
  /// In en, this message translates to:
  /// **'Breathe in slowly through your nose...'**
  String get descBreathGuidanceInhale;

  /// Guidance line under the breathing circle while holding after inhaling.
  ///
  /// In en, this message translates to:
  /// **'Hold gently at the top...'**
  String get descBreathGuidanceHold;

  /// Guidance line under the breathing circle during the exhale phase.
  ///
  /// In en, this message translates to:
  /// **'Release slowly and completely...'**
  String get descBreathGuidanceExhale;

  /// Guidance line under the breathing circle while resting after exhaling.
  ///
  /// In en, this message translates to:
  /// **'Rest in quiet stillness...'**
  String get descBreathGuidanceRest;

  /// Screen-reader message when the breathing practice ends.
  ///
  /// In en, this message translates to:
  /// **'Breathing practice completed'**
  String get bodyBreathPracticeCompleted;

  /// Screen-reader label for the breathing circle: the current phase and the seconds left in it.
  ///
  /// In en, this message translates to:
  /// **'{phase}, {seconds} seconds remaining'**
  String bodyBreathPhaseRemaining(String phase, int seconds);

  /// Shown in the breathing circle when the breathing practice is finished. Short.
  ///
  /// In en, this message translates to:
  /// **'Grounded & present'**
  String get titleBreathGrounded;

  /// Counter above the breathing circle. Short.
  ///
  /// In en, this message translates to:
  /// **'Cycle {current} of {total}'**
  String labelBreathCycle(int current, int total);

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get labelTemplateCategoryGeneral;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Daily & reflective'**
  String get labelTemplateCategoryReflective;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Thoughts & ideas'**
  String get labelTemplateCategoryThoughts;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Projects & work'**
  String get labelTemplateCategoryProjects;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get labelTemplateCategoryPeople;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Health & wellbeing'**
  String get labelTemplateCategoryHealth;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Learning & growth'**
  String get labelTemplateCategoryLearning;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get labelTemplateCategoryCreative;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get labelTemplateCategoryPlanning;

  /// Template chooser category heading. Short.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get labelTemplateCategorySpecialty;

  /// Name of the 'Blank' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get labelTemplateBlank;

  /// One-line description of the 'Blank' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Start with an empty entry.'**
  String get descTemplateBlank;

  /// Name of the 'Daily' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get labelTemplateDaily;

  /// One-line description of the 'Daily' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Highlights, gratitudes, and tomorrow\'s focus.'**
  String get descTemplateDaily;

  /// Title a new entry starts with when created from the 'Daily' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get descTemplateDailyEntryTitle;

  /// Starting text of a new entry created from the 'Daily' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Highlights\n\nLowlights\n\nTomorrow\'s focus\n\n'**
  String get bodyTemplateDaily;

  /// Name of the 'TodayForMe' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Today for Me'**
  String get labelTemplateTodayForMe;

  /// One-line description of the 'TodayForMe' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Did, thought, saw, encountered, felt, and learned today.'**
  String get descTemplateTodayForMe;

  /// Title a new entry starts with when created from the 'TodayForMe' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Today for Me'**
  String get descTemplateTodayForMeEntryTitle;

  /// Starting text of a new entry created from the 'TodayForMe' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'What I did today\n\nWhat I thought today\n\nWhat I saw today\n\nWhat I encountered today\n\nWhat I felt today\n\nWhat was taught to me today\n\n'**
  String get bodyTemplateTodayForMe;

  /// Name of the 'EveningWindDown' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Evening Wind-down'**
  String get labelTemplateEveningWindDown;

  /// One-line description of the 'EveningWindDown' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Wins, struggles, one thing to let go of.'**
  String get descTemplateEveningWindDown;

  /// Title a new entry starts with when created from the 'EveningWindDown' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Evening Wind-down'**
  String get descTemplateEveningWindDownEntryTitle;

  /// Starting text of a new entry created from the 'EveningWindDown' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Wins\n\nStruggles\n\nOne thing to let go of\n\n'**
  String get bodyTemplateEveningWindDown;

  /// Name of the 'MorningPages' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Morning Pages'**
  String get labelTemplateMorningPages;

  /// One-line description of the 'MorningPages' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Stream-of-consciousness brain dump to start the day.'**
  String get descTemplateMorningPages;

  /// Title a new entry starts with when created from the 'MorningPages' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Morning Pages'**
  String get descTemplateMorningPagesEntryTitle;

  /// Name of the 'DayHighlight' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Highlight of the Day'**
  String get labelTemplateDayHighlight;

  /// One-line description of the 'DayHighlight' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Single most memorable moment and why.'**
  String get descTemplateDayHighlight;

  /// Title a new entry starts with when created from the 'DayHighlight' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Highlight of the Day'**
  String get descTemplateDayHighlightEntryTitle;

  /// Starting text of a new entry created from the 'DayHighlight' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'The moment\n\nWhy it stood out\n\n'**
  String get bodyTemplateDayHighlight;

  /// Name of the 'EnergyCheck' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Energy Check'**
  String get labelTemplateEnergyCheck;

  /// One-line description of the 'EnergyCheck' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Energy level, what drained it, what restored it.'**
  String get descTemplateEnergyCheck;

  /// Title a new entry starts with when created from the 'EnergyCheck' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Energy Check'**
  String get descTemplateEnergyCheckEntryTitle;

  /// Starting text of a new entry created from the 'EnergyCheck' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Energy level (1-10): \n\nWhat drained it\n\nWhat restored it\n\n'**
  String get bodyTemplateEnergyCheck;

  /// Name of the 'Mood' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Mood Check-in'**
  String get labelTemplateMood;

  /// One-line description of the 'Mood' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Note your current mood and what is shaping it.'**
  String get descTemplateMood;

  /// Title a new entry starts with when created from the 'Mood' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Mood Check-in'**
  String get descTemplateMoodEntryTitle;

  /// Starting text of a new entry created from the 'Mood' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'How I feel right now\n\nWhat is shaping it\n\n'**
  String get bodyTemplateMood;

  /// Name of the 'Thoughts' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'My Thoughts'**
  String get labelTemplateThoughts;

  /// One-line description of the 'Thoughts' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Free-form reflection on a topic.'**
  String get descTemplateThoughts;

  /// Title a new entry starts with when created from the 'Thoughts' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'My Thoughts'**
  String get descTemplateThoughtsEntryTitle;

  /// Starting text of a new entry created from the 'Thoughts' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Topic\n\nMy thoughts\n\n'**
  String get bodyTemplateThoughts;

  /// Name of the 'IdeaCapture' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Idea Capture'**
  String get labelTemplateIdeaCapture;

  /// One-line description of the 'IdeaCapture' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Idea, why it matters, next step.'**
  String get descTemplateIdeaCapture;

  /// Title a new entry starts with when created from the 'IdeaCapture' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Idea Capture'**
  String get descTemplateIdeaCaptureEntryTitle;

  /// Starting text of a new entry created from the 'IdeaCapture' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'The idea\n\nWhy it matters\n\nNext step\n\n'**
  String get bodyTemplateIdeaCapture;

  /// Name of the 'OpenQuestion' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Open Question'**
  String get labelTemplateOpenQuestion;

  /// One-line description of the 'OpenQuestion' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'A question I am sitting with and current thinking.'**
  String get descTemplateOpenQuestion;

  /// Title a new entry starts with when created from the 'OpenQuestion' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Open Question'**
  String get descTemplateOpenQuestionEntryTitle;

  /// Starting text of a new entry created from the 'OpenQuestion' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'The question\n\nWhat I think so far\n\nWhat I still don\'t know\n\n'**
  String get bodyTemplateOpenQuestion;

  /// Name of the 'Opinion' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Opinion / Hot Take'**
  String get labelTemplateOpinion;

  /// One-line description of the 'Opinion' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Belief, evidence for, evidence against.'**
  String get descTemplateOpinion;

  /// Title a new entry starts with when created from the 'Opinion' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Opinion / Hot Take'**
  String get descTemplateOpinionEntryTitle;

  /// Starting text of a new entry created from the 'Opinion' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'My belief\n\nEvidence for\n\nEvidence against\n\n'**
  String get bodyTemplateOpinion;

  /// Name of the 'LessonsLearned' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Lessons Learned'**
  String get labelTemplateLessonsLearned;

  /// One-line description of the 'LessonsLearned' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'What happened, what I learned, how I\'ll apply it.'**
  String get descTemplateLessonsLearned;

  /// Title a new entry starts with when created from the 'LessonsLearned' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Lessons Learned'**
  String get descTemplateLessonsLearnedEntryTitle;

  /// Starting text of a new entry created from the 'LessonsLearned' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'What happened\n\nWhat I learned\n\nHow I\'ll apply it\n\n'**
  String get bodyTemplateLessonsLearned;

  /// Name of the 'Projects' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get labelTemplateProjects;

  /// One-line description of the 'Projects' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Project, status, blockers, next action.'**
  String get descTemplateProjects;

  /// Title a new entry starts with when created from the 'Projects' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get descTemplateProjectsEntryTitle;

  /// Starting text of a new entry created from the 'Projects' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Project\n\nStatus\n\nBlockers\n\nNext action\n\n'**
  String get bodyTemplateProjects;

  /// Name of the 'ProjectUpdate' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Project Update'**
  String get labelTemplateProjectUpdate;

  /// One-line description of the 'ProjectUpdate' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Progress, risks, decisions made.'**
  String get descTemplateProjectUpdate;

  /// Title a new entry starts with when created from the 'ProjectUpdate' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Project Update'**
  String get descTemplateProjectUpdateEntryTitle;

  /// Starting text of a new entry created from the 'ProjectUpdate' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Progress\n\nRisks\n\nDecisions made\n\n'**
  String get bodyTemplateProjectUpdate;

  /// Name of the 'WeeklyReview' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get labelTemplateWeeklyReview;

  /// One-line description of the 'WeeklyReview' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Wins, misses, focus for next week.'**
  String get descTemplateWeeklyReview;

  /// Title a new entry starts with when created from the 'WeeklyReview' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get descTemplateWeeklyReviewEntryTitle;

  /// Starting text of a new entry created from the 'WeeklyReview' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Wins\n\nMisses\n\nFocus for next week\n\n'**
  String get bodyTemplateWeeklyReview;

  /// Name of the 'GoalTracker' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Goal Tracker'**
  String get labelTemplateGoalTracker;

  /// One-line description of the 'GoalTracker' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Goal, progress, obstacles, adjustments.'**
  String get descTemplateGoalTracker;

  /// Title a new entry starts with when created from the 'GoalTracker' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Goal Tracker'**
  String get descTemplateGoalTrackerEntryTitle;

  /// Starting text of a new entry created from the 'GoalTracker' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Goal\n\nProgress\n\nObstacles\n\nAdjustments\n\n'**
  String get bodyTemplateGoalTracker;

  /// Name of the 'DecisionLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Decision Log'**
  String get labelTemplateDecisionLog;

  /// One-line description of the 'DecisionLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Decision, options considered, why I chose this.'**
  String get descTemplateDecisionLog;

  /// Title a new entry starts with when created from the 'DecisionLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Decision Log'**
  String get descTemplateDecisionLogEntryTitle;

  /// Starting text of a new entry created from the 'DecisionLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'The decision\n\nOptions considered\n\nWhy I chose this\n\n'**
  String get bodyTemplateDecisionLog;

  /// Name of the 'StuckPoint' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Stuck Point'**
  String get labelTemplateStuckPoint;

  /// One-line description of the 'StuckPoint' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Where I\'m stuck, what I\'ve tried, what to try next.'**
  String get descTemplateStuckPoint;

  /// Title a new entry starts with when created from the 'StuckPoint' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Stuck Point'**
  String get descTemplateStuckPointEntryTitle;

  /// Starting text of a new entry created from the 'StuckPoint' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Where I\'m stuck\n\nWhat I\'ve tried\n\nWhat to try next\n\n'**
  String get bodyTemplateStuckPoint;

  /// Name of the 'Meeting' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Meeting Notes'**
  String get labelTemplateMeeting;

  /// One-line description of the 'Meeting' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Attendees, agenda, decisions, action items.'**
  String get descTemplateMeeting;

  /// Title a new entry starts with when created from the 'Meeting' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Meeting Notes'**
  String get descTemplateMeetingEntryTitle;

  /// Starting text of a new entry created from the 'Meeting' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Attendees: \nAgenda\n\nDecisions\n\nAction items\n\n'**
  String get bodyTemplateMeeting;

  /// Name of the 'ConversationRecap' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Conversation Recap'**
  String get labelTemplateConversationRecap;

  /// One-line description of the 'ConversationRecap' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Who, what we discussed, follow-ups.'**
  String get descTemplateConversationRecap;

  /// Title a new entry starts with when created from the 'ConversationRecap' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Conversation Recap'**
  String get descTemplateConversationRecapEntryTitle;

  /// Starting text of a new entry created from the 'ConversationRecap' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Who\n\nWhat we discussed\n\nFollow-ups\n\n'**
  String get bodyTemplateConversationRecap;

  /// Name of the 'GratefulPeople' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Grateful for people'**
  String get labelTemplateGratefulPeople;

  /// One-line description of the 'GratefulPeople' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Person and a specific reason.'**
  String get descTemplateGratefulPeople;

  /// Title a new entry starts with when created from the 'GratefulPeople' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'People I\'m Grateful For'**
  String get descTemplateGratefulPeopleEntryTitle;

  /// Starting text of a new entry created from the 'GratefulPeople' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Person\n\nSpecific reason\n\n'**
  String get bodyTemplateGratefulPeople;

  /// Name of the 'UnsentLetter' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Letter I Won\'t Send'**
  String get labelTemplateUnsentLetter;

  /// One-line description of the 'UnsentLetter' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Unsent letter to process feelings.'**
  String get descTemplateUnsentLetter;

  /// Title a new entry starts with when created from the 'UnsentLetter' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Unsent Letter'**
  String get descTemplateUnsentLetterEntryTitle;

  /// Starting text of a new entry created from the 'UnsentLetter' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Dear ...,\n\n\n\n— Me\n\n'**
  String get bodyTemplateUnsentLetter;

  /// Name of the 'RelationshipCheckin' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Relationship check'**
  String get labelTemplateRelationshipCheckin;

  /// One-line description of the 'RelationshipCheckin' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'How a key relationship is going.'**
  String get descTemplateRelationshipCheckin;

  /// Title a new entry starts with when created from the 'RelationshipCheckin' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Relationship Check-in'**
  String get descTemplateRelationshipCheckinEntryTitle;

  /// Starting text of a new entry created from the 'RelationshipCheckin' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Person\n\nHow it\'s going\n\nWhat needs attention\n\n'**
  String get bodyTemplateRelationshipCheckin;

  /// Name of the 'Gratitude' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get labelTemplateGratitude;

  /// One-line description of the 'Gratitude' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Three things I am grateful for today.'**
  String get descTemplateGratitude;

  /// Title a new entry starts with when created from the 'Gratitude' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get descTemplateGratitudeEntryTitle;

  /// Starting text of a new entry created from the 'Gratitude' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Three things I\'m grateful for\n\n1. \n2. \n3. \n'**
  String get bodyTemplateGratitude;

  /// Name of the 'BodyCheckin' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Body Check-in'**
  String get labelTemplateBodyCheckin;

  /// One-line description of the 'BodyCheckin' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Sleep, food, movement, pain or tension.'**
  String get descTemplateBodyCheckin;

  /// Title a new entry starts with when created from the 'BodyCheckin' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Body Check-in'**
  String get descTemplateBodyCheckinEntryTitle;

  /// Starting text of a new entry created from the 'BodyCheckin' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Sleep\n\nFood\n\nMovement\n\nPain or tension\n\n'**
  String get bodyTemplateBodyCheckin;

  /// Name of the 'MentalHealth' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Log'**
  String get labelTemplateMentalHealth;

  /// One-line description of the 'MentalHealth' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Mood, triggers, coping used.'**
  String get descTemplateMentalHealth;

  /// Title a new entry starts with when created from the 'MentalHealth' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Log'**
  String get descTemplateMentalHealthEntryTitle;

  /// Starting text of a new entry created from the 'MentalHealth' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Mood\n\nTriggers\n\nCoping used\n\n'**
  String get bodyTemplateMentalHealth;

  /// Name of the 'HabitTracker' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get labelTemplateHabitTracker;

  /// One-line description of the 'HabitTracker' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Habits done today and streak notes.'**
  String get descTemplateHabitTracker;

  /// Title a new entry starts with when created from the 'HabitTracker' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get descTemplateHabitTrackerEntryTitle;

  /// Starting text of a new entry created from the 'HabitTracker' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Habits done today\n\nMissed today\n\nStreak notes\n\n'**
  String get bodyTemplateHabitTracker;

  /// Name of the 'SleepLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Sleep Log'**
  String get labelTemplateSleepLog;

  /// One-line description of the 'SleepLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Hours, quality, dreams.'**
  String get descTemplateSleepLog;

  /// Title a new entry starts with when created from the 'SleepLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Sleep Log'**
  String get descTemplateSleepLogEntryTitle;

  /// Starting text of a new entry created from the 'SleepLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Hours\n\nQuality\n\nDreams\n\n'**
  String get bodyTemplateSleepLog;

  /// Name of the 'TaughtToday' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Taught to Me Today'**
  String get labelTemplateTaughtToday;

  /// One-line description of the 'TaughtToday' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Lesson, source, takeaway.'**
  String get descTemplateTaughtToday;

  /// Title a new entry starts with when created from the 'TaughtToday' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Taught to Me Today'**
  String get descTemplateTaughtTodayEntryTitle;

  /// Starting text of a new entry created from the 'TaughtToday' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Lesson\n\nSource\n\nTakeaway\n\n'**
  String get bodyTemplateTaughtToday;

  /// Name of the 'BookNotes' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Book / Article Notes'**
  String get labelTemplateBookNotes;

  /// One-line description of the 'BookNotes' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Title, key ideas, my reaction.'**
  String get descTemplateBookNotes;

  /// Title a new entry starts with when created from the 'BookNotes' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Book / Article Notes'**
  String get descTemplateBookNotesEntryTitle;

  /// Starting text of a new entry created from the 'BookNotes' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Title: \nAuthor: \n\nKey ideas\n\nMy reaction\n\n'**
  String get bodyTemplateBookNotes;

  /// Name of the 'SkillPractice' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Skill Practice'**
  String get labelTemplateSkillPractice;

  /// One-line description of the 'SkillPractice' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'What I practiced, what improved, next focus.'**
  String get descTemplateSkillPractice;

  /// Title a new entry starts with when created from the 'SkillPractice' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Skill Practice'**
  String get descTemplateSkillPracticeEntryTitle;

  /// Starting text of a new entry created from the 'SkillPractice' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Skill\n\nWhat I practiced\n\nWhat improved\n\nNext focus\n\n'**
  String get bodyTemplateSkillPractice;

  /// Name of the 'MistakeLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Mistake Log'**
  String get labelTemplateMistakeLog;

  /// One-line description of the 'MistakeLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'What went wrong, root cause, prevention.'**
  String get descTemplateMistakeLog;

  /// Title a new entry starts with when created from the 'MistakeLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Mistake Log'**
  String get descTemplateMistakeLogEntryTitle;

  /// Starting text of a new entry created from the 'MistakeLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'What went wrong\n\nRoot cause\n\nPrevention\n\n'**
  String get bodyTemplateMistakeLog;

  /// Name of the 'TopicDeepDive' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Topic Deep Dive'**
  String get labelTemplateTopicDeepDive;

  /// One-line description of the 'TopicDeepDive' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Detailed study note on a concept, subject, or domain.'**
  String get descTemplateTopicDeepDive;

  /// Title a new entry starts with when created from the 'TopicDeepDive' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Topic Deep Dive'**
  String get descTemplateTopicDeepDiveEntryTitle;

  /// Starting text of a new entry created from the 'TopicDeepDive' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Topic / Core Concept\n\nKey Principles & Overview\n\nDetailed Analysis & Notes\n\nKey Takeaways & References\n\nOpen Questions / Further Exploration\n\n'**
  String get bodyTemplateTopicDeepDive;

  /// Name of the 'DreamJournal' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Dream Journal'**
  String get labelTemplateDreamJournal;

  /// One-line description of the 'DreamJournal' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Dream details, emotions, possible meaning.'**
  String get descTemplateDreamJournal;

  /// Title a new entry starts with when created from the 'DreamJournal' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Dream Journal'**
  String get descTemplateDreamJournalEntryTitle;

  /// Starting text of a new entry created from the 'DreamJournal' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Dream details\n\nEmotions\n\nPossible meaning\n\n'**
  String get bodyTemplateDreamJournal;

  /// Name of the 'Observation' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Observation Sketch'**
  String get labelTemplateObservation;

  /// One-line description of the 'Observation' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Something I noticed in detail.'**
  String get descTemplateObservation;

  /// Title a new entry starts with when created from the 'Observation' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Observation Sketch'**
  String get descTemplateObservationEntryTitle;

  /// Starting text of a new entry created from the 'Observation' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'What I noticed\n\nDetails\n\n'**
  String get bodyTemplateObservation;

  /// Name of the 'QuoteOfDay' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get labelTemplateQuoteOfDay;

  /// One-line description of the 'QuoteOfDay' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Quote and why it resonates.'**
  String get descTemplateQuoteOfDay;

  /// Title a new entry starts with when created from the 'QuoteOfDay' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get descTemplateQuoteOfDayEntryTitle;

  /// Starting text of a new entry created from the 'QuoteOfDay' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Quote\n\nSource\n\nWhy it resonates\n\n'**
  String get bodyTemplateQuoteOfDay;

  /// Name of the 'StorySeed' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Story Seed'**
  String get labelTemplateStorySeed;

  /// One-line description of the 'StorySeed' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'A tiny story idea or scene.'**
  String get descTemplateStorySeed;

  /// Title a new entry starts with when created from the 'StorySeed' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Story Seed'**
  String get descTemplateStorySeedEntryTitle;

  /// Starting text of a new entry created from the 'StorySeed' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'The seed\n\nPossible direction\n\n'**
  String get bodyTemplateStorySeed;

  /// Name of the 'Travel' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Travel Log'**
  String get labelTemplateTravel;

  /// One-line description of the 'Travel' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Place, weather, what happened, who you met.'**
  String get descTemplateTravel;

  /// Title a new entry starts with when created from the 'Travel' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Travel Log'**
  String get descTemplateTravelEntryTitle;

  /// Starting text of a new entry created from the 'Travel' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Place: \nWeather: \nWhat happened\n\nPeople I met\n\n'**
  String get bodyTemplateTravel;

  /// Name of the 'TomorrowFocus' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s Focus'**
  String get labelTemplateTomorrowFocus;

  /// One-line description of the 'TomorrowFocus' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Top 3 priorities and the first step.'**
  String get descTemplateTomorrowFocus;

  /// Title a new entry starts with when created from the 'TomorrowFocus' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s Focus'**
  String get descTemplateTomorrowFocusEntryTitle;

  /// Starting text of a new entry created from the 'TomorrowFocus' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Top 3 priorities\n\n1. \n2. \n3. \n\nFirst step\n\n'**
  String get bodyTemplateTomorrowFocus;

  /// Name of the 'WeeklyIntentions' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Weekly Intentions'**
  String get labelTemplateWeeklyIntentions;

  /// One-line description of the 'WeeklyIntentions' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Theme, priorities, what to avoid.'**
  String get descTemplateWeeklyIntentions;

  /// Title a new entry starts with when created from the 'WeeklyIntentions' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Weekly Intentions'**
  String get descTemplateWeeklyIntentionsEntryTitle;

  /// Starting text of a new entry created from the 'WeeklyIntentions' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Theme\n\nPriorities\n\nWhat to avoid\n\n'**
  String get bodyTemplateWeeklyIntentions;

  /// Name of the 'MonthlyReview' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Monthly Review'**
  String get labelTemplateMonthlyReview;

  /// One-line description of the 'MonthlyReview' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Wins, lessons, what changes next month.'**
  String get descTemplateMonthlyReview;

  /// Title a new entry starts with when created from the 'MonthlyReview' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Monthly Review'**
  String get descTemplateMonthlyReviewEntryTitle;

  /// Starting text of a new entry created from the 'MonthlyReview' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Wins\n\nLessons\n\nWhat changes next month\n\n'**
  String get bodyTemplateMonthlyReview;

  /// Name of the 'WorkoutLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Workout Log'**
  String get labelTemplateWorkoutLog;

  /// One-line description of the 'WorkoutLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Exercises, sets, reps, how it felt.'**
  String get descTemplateWorkoutLog;

  /// Title a new entry starts with when created from the 'WorkoutLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Workout Log'**
  String get descTemplateWorkoutLogEntryTitle;

  /// Starting text of a new entry created from the 'WorkoutLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Workout\n\nSets / reps\n\nHow it felt\n\n'**
  String get bodyTemplateWorkoutLog;

  /// Name of the 'ReadingLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Reading Log'**
  String get labelTemplateReadingLog;

  /// One-line description of the 'ReadingLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Book, pages read, favorite passage.'**
  String get descTemplateReadingLog;

  /// Title a new entry starts with when created from the 'ReadingLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Reading Log'**
  String get descTemplateReadingLogEntryTitle;

  /// Starting text of a new entry created from the 'ReadingLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Book\n\nPages read\n\nFavorite passage\n\n'**
  String get bodyTemplateReadingLog;

  /// Name of the 'FoodJournal' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Food Journal'**
  String get labelTemplateFoodJournal;

  /// One-line description of the 'FoodJournal' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Meals and how I felt after.'**
  String get descTemplateFoodJournal;

  /// Title a new entry starts with when created from the 'FoodJournal' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Food Journal'**
  String get descTemplateFoodJournalEntryTitle;

  /// Starting text of a new entry created from the 'FoodJournal' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Meals\n\nHow I felt after\n\n'**
  String get bodyTemplateFoodJournal;

  /// Name of the 'SpendingLog' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Spending Log'**
  String get labelTemplateSpendingLog;

  /// One-line description of the 'SpendingLog' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Purchases — was it worth it?'**
  String get descTemplateSpendingLog;

  /// Title a new entry starts with when created from the 'SpendingLog' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Spending Log'**
  String get descTemplateSpendingLogEntryTitle;

  /// Starting text of a new entry created from the 'SpendingLog' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Purchase\n\nCost\n\nWas it worth it?\n\n'**
  String get bodyTemplateSpendingLog;

  /// Name of the 'PrayerMeditation' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Prayer / Meditation'**
  String get labelTemplatePrayerMeditation;

  /// One-line description of the 'PrayerMeditation' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Practice, duration, reflections.'**
  String get descTemplatePrayerMeditation;

  /// Title a new entry starts with when created from the 'PrayerMeditation' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Prayer / Meditation'**
  String get descTemplatePrayerMeditationEntryTitle;

  /// Starting text of a new entry created from the 'PrayerMeditation' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Practice\n\nDuration\n\nReflections\n\n'**
  String get bodyTemplatePrayerMeditation;

  /// Name of the 'SysadminRunbook' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'System admin'**
  String get labelTemplateSysadminRunbook;

  /// One-line description of the 'SysadminRunbook' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Server / system runbook, commands, and maintenance log.'**
  String get descTemplateSysadminRunbook;

  /// Title a new entry starts with when created from the 'SysadminRunbook' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Sysadmin / Tech Note'**
  String get descTemplateSysadminRunbookEntryTitle;

  /// Starting text of a new entry created from the 'SysadminRunbook' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'System / Service: \nObjective & Architecture\n\nConfiguration & Commands\n\nVerification & Health Checks\n\nTroubleshooting & Rollback Notes\n\n'**
  String get bodyTemplateSysadminRunbook;

  /// Name of the 'SanathanaDharmaStudy' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Dharma study'**
  String get labelTemplateSanathanaDharmaStudy;

  /// One-line description of the 'SanathanaDharmaStudy' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Scripture, shloka, tatva/meaning, and sadhana reflection.'**
  String get descTemplateSanathanaDharmaStudy;

  /// Title a new entry starts with when created from the 'SanathanaDharmaStudy' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Sanathana Dharma Study'**
  String get descTemplateSanathanaDharmaStudyEntryTitle;

  /// Starting text of a new entry created from the 'SanathanaDharmaStudy' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Topic / Scripture: \nShloka / Mantra / Reference\n\nWord Breakdown & Meaning\n\nPhilosophical Insights (Tatva)\n\nDaily Sadhana & Practical Application\n\n'**
  String get bodyTemplateSanathanaDharmaStudy;

  /// Name of the 'DiyProject' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'DIY & Maker Project'**
  String get labelTemplateDiyProject;

  /// One-line description of the 'DiyProject' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Materials, tools, step-by-step build, and safety.'**
  String get descTemplateDiyProject;

  /// Title a new entry starts with when created from the 'DiyProject' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'DIY Project'**
  String get descTemplateDiyProjectEntryTitle;

  /// Starting text of a new entry created from the 'DiyProject' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Project Goal & Scope\n\nTools & Materials Required\n\nStep-by-Step Procedure\n\nSafety & Precautions\n\nTesting & Lessons Learned\n\n'**
  String get bodyTemplateDiyProject;

  /// Name of the 'HomeMaintenance' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Home & Maintenance'**
  String get labelTemplateHomeMaintenance;

  /// One-line description of the 'HomeMaintenance' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Appliance care, repairs, warranties, and vendor logs.'**
  String get descTemplateHomeMaintenance;

  /// Title a new entry starts with when created from the 'HomeMaintenance' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Home Maintenance Note'**
  String get descTemplateHomeMaintenanceEntryTitle;

  /// Starting text of a new entry created from the 'HomeMaintenance' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Area / Item / Appliance: \nIssue / Maintenance Task\n\nService History & Costs\n\nWarranty & Vendor Contacts\n\nNext Scheduled Check: \n\n'**
  String get bodyTemplateHomeMaintenance;

  /// Name of the 'KitchenRecipe' entry template in the template chooser. Short.
  ///
  /// In en, this message translates to:
  /// **'Kitchen & Recipe'**
  String get labelTemplateKitchenRecipe;

  /// One-line description of the 'KitchenRecipe' entry template in the template chooser.
  ///
  /// In en, this message translates to:
  /// **'Dish, ingredients, step-by-step method, and tips.'**
  String get descTemplateKitchenRecipe;

  /// Title a new entry starts with when created from the 'KitchenRecipe' template. The user can edit it.
  ///
  /// In en, this message translates to:
  /// **'Recipe & Kitchen Note'**
  String get descTemplateKitchenRecipeEntryTitle;

  /// Starting text of a new entry created from the 'KitchenRecipe' template. Each line is a heading the user writes under; keep every line break.
  ///
  /// In en, this message translates to:
  /// **'Dish Name: \nCuisine / Prep & Cook Time: \n\nIngredients & Quantities\n\nStep-by-Step Method\n\nChef Notes & Variations\n\n'**
  String get bodyTemplateKitchenRecipe;

  /// Export screen app-bar title. Short.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get titleExport;

  /// Export screen section heading above the scope choices. Short.
  ///
  /// In en, this message translates to:
  /// **'What to export'**
  String get titleExportSectionWhat;

  /// Export screen section heading above the file formats. Short.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get titleExportSectionFormat;

  /// Export screen section heading above the switches. Short.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get titleExportSectionOptions;

  /// Export scope option: only the entry the screen was opened from. Short.
  ///
  /// In en, this message translates to:
  /// **'This entry'**
  String get labelExportScopeThisEntry;

  /// Export scope option: every entry in the journal. Short.
  ///
  /// In en, this message translates to:
  /// **'The whole journal'**
  String get labelExportScopeWholeJournal;

  /// Export scope option: entries between two dates. Short.
  ///
  /// In en, this message translates to:
  /// **'A date range'**
  String get labelExportScopeDateRange;

  /// Button that opens the date range picker on the export screen. Short.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get actionExportPickDateRange;

  /// Subtitle of the date range option before dates are picked.
  ///
  /// In en, this message translates to:
  /// **'No dates chosen yet'**
  String get descExportDateRangeNotSet;

  /// Line at the top of the export screen naming the journal being exported.
  ///
  /// In en, this message translates to:
  /// **'From \"{journalTitle}\"'**
  String descExportFromJournal(String journalTitle);

  /// Subtitle of the date range option once two dates are picked.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String descExportDateRange(String from, String to);

  /// Name of the Markdown export format. A product name, the same in every language. Short.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get labelExportFormatMarkdown;

  /// Name of the HTML export format. Short.
  ///
  /// In en, this message translates to:
  /// **'Web page (HTML)'**
  String get labelExportFormatHtml;

  /// Name of the plain text export format. Short.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get labelExportFormatPlainText;

  /// Name of the PDF export format. A product name, the same in every language. Short.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get labelExportFormatPdf;

  /// One line explaining the Markdown export format.
  ///
  /// In en, this message translates to:
  /// **'Keeps headings, lists and styling. Opens in any text editor.'**
  String get descExportFormatMarkdown;

  /// One line explaining the HTML export format.
  ///
  /// In en, this message translates to:
  /// **'One page that opens in any browser. Nothing is loaded from the internet.'**
  String get descExportFormatHtml;

  /// One line explaining the plain text export format.
  ///
  /// In en, this message translates to:
  /// **'Just the words, no styling.'**
  String get descExportFormatPlainText;

  /// One line explaining the PDF export format.
  ///
  /// In en, this message translates to:
  /// **'Fixed pages, ready to print or share.'**
  String get descExportFormatPdf;

  /// Shown under the PDF format when the device cannot render a PDF.
  ///
  /// In en, this message translates to:
  /// **'PDF export is not available on this device. The other formats still work.'**
  String get bodyExportPdfUnavailable;

  /// Switch label on the export screen. Short.
  ///
  /// In en, this message translates to:
  /// **'Include attachments'**
  String get labelExportIncludeAttachments;

  /// Explains the include-attachments switch.
  ///
  /// In en, this message translates to:
  /// **'Adds a copy of each file and voice note to the export.'**
  String get descExportIncludeAttachments;

  /// Switch label on the export screen: add a date, tags and mood header. Short.
  ///
  /// In en, this message translates to:
  /// **'Date, tags and mood'**
  String get labelExportIncludeMetadata;

  /// Explains the date, tags and mood switch.
  ///
  /// In en, this message translates to:
  /// **'Adds a short header above each entry.'**
  String get descExportIncludeMetadata;

  /// Warning card on the export screen when the export is not password-protected. Required by the security policy.
  ///
  /// In en, this message translates to:
  /// **'The exported file is not encrypted. Anyone who can open the file can read it. Keep it somewhere safe.'**
  String get bodyExportNotEncrypted;

  /// Title of the dialog confirming an unencrypted export. Short.
  ///
  /// In en, this message translates to:
  /// **'Export unencrypted?'**
  String get titleExportConfirm;

  /// Body of the unencrypted export confirmation, naming how many entries and which format.
  ///
  /// In en, this message translates to:
  /// **'This will write {count, plural, =1{1 entry} other{{count} entries}} to an unencrypted {format} file. Anyone who can open that file can read your journal. Keep it somewhere safe, and delete it when you are done with it.'**
  String bodyExportConfirm(int count, String format);

  /// Button that accepts the unencrypted export confirmation. Short.
  ///
  /// In en, this message translates to:
  /// **'Export anyway'**
  String get actionExportAnyway;

  /// Button that runs the export. Short.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// Label of the export button while an export is running.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get bodyExportExporting;

  /// Title of the system save dialog for an export. Short.
  ///
  /// In en, this message translates to:
  /// **'Save export'**
  String get titleExportSaveDialog;

  /// Snackbar after a successful export.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 entry.} other{Exported {count} entries.}}'**
  String bodyExportDone(int count);

  /// Snackbar when the user backs out of an export.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get bodyExportCancelled;

  /// Snackbar when the chosen export scope contains no entries.
  ///
  /// In en, this message translates to:
  /// **'There are no entries to export for that choice.'**
  String get errorExportNothing;

  /// Snackbar when an export fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Could not finish the export. Nothing was saved.'**
  String get errorExportFailed;

  /// Snackbar when PDF rendering times out.
  ///
  /// In en, this message translates to:
  /// **'The PDF took too long to build and was stopped. Try a smaller date range.'**
  String get errorExportPdfTimedOut;

  /// Snackbar when PDF rendering fails.
  ///
  /// In en, this message translates to:
  /// **'Could not build the PDF.'**
  String get errorExportPdfFailed;

  /// Heading above the list of files an export had to leave out. Short.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get titleExportSkipped;

  /// Left-out row: a locked attachment.
  ///
  /// In en, this message translates to:
  /// **'{fileName} — locked. Unlock it first to include it.'**
  String bodyExportSkippedLockedAttachment(String fileName);

  /// Left-out row: an attachment that could not be decrypted or read.
  ///
  /// In en, this message translates to:
  /// **'{fileName} — the file could not be read.'**
  String bodyExportSkippedUnreadableAttachment(String fileName);

  /// Left-out row: a voice note that could not be read.
  ///
  /// In en, this message translates to:
  /// **'{fileName} — the recording could not be read.'**
  String bodyExportSkippedUnreadableVoiceNote(String fileName);

  /// Left-out row: a locked image inside the entry text.
  ///
  /// In en, this message translates to:
  /// **'{fileName} — a locked image in the entry body was left out of the page.'**
  String bodyExportSkippedLockedInlineImage(String fileName);

  /// Left-out row: an image inside the entry text that could not be read.
  ///
  /// In en, this message translates to:
  /// **'{fileName} — an image in the entry body could not be read.'**
  String bodyExportSkippedUnreadableInlineImage(String fileName);

  /// Written into an exported file as the title of an entry that has none.
  ///
  /// In en, this message translates to:
  /// **'Untitled entry'**
  String get descExportFileUntitledEntry;

  /// Written into an exported file: header label for the entry date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get descExportFileDate;

  /// Written into an exported file: header label for the entry tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get descExportFileTags;

  /// Written into an exported file: header label for the entry mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get descExportFileMood;

  /// Written into an exported file: heading above the attachment list.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get descExportFileAttachments;

  /// Written into an exported file: heading above the voice note list.
  ///
  /// In en, this message translates to:
  /// **'Voice notes'**
  String get descExportFileVoiceNotes;

  /// Written into an exported file: label above a voice note transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get descExportFileTranscript;

  /// Written into an exported file after the name of a locked attachment, in brackets.
  ///
  /// In en, this message translates to:
  /// **'locked — not included'**
  String get descExportFileLockedNotIncluded;

  /// Written into an exported file in place of an inline image that is not embedded.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get descExportFileImage;

  /// Written into an exported file in place of an inline drawing that is not embedded.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get descExportFileDrawing;

  /// Written into an exported file: label of an info callout block.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get descExportFileCalloutNote;

  /// Written into an exported file: label of a tip callout block.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get descExportFileCalloutTip;

  /// Written into an exported file: label of a warning callout block.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get descExportFileCalloutWarning;

  /// Written into an exported file: label of an important callout block.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get descExportFileCalloutImportant;

  /// Written into an exported file: the mood score out of five.
  ///
  /// In en, this message translates to:
  /// **'{mood} of 5'**
  String descExportFileMoodValue(int mood);

  /// Written into an exported file: a voice note line with its length.
  ///
  /// In en, this message translates to:
  /// **'Recording ({duration})'**
  String descExportFileRecording(String duration);

  /// README.txt written into a zip export. The folder names entries and attachments are real folder names and must stay in English.
  ///
  /// In en, this message translates to:
  /// **'Export from SreerajP Journal Vault\n\nJournal:  {journalTitle}\nExported: {exportedAt}\nEntries:  {entryCount}\nFormat:   {formatName}\n\nThe \"entries\" folder holds one file per entry.\nThe \"attachments\" folder, if present, holds a copy of the files and voice\nnotes belonging to those entries.\n\nThis export is NOT encrypted. Anyone who can open these files can read them.\n'**
  String bodyExportFileReadme(
    String journalTitle,
    String exportedAt,
    int entryCount,
    String formatName,
  );

  /// Settings tile that opens the export flow. Short.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get labelExportData;

  /// Tooltip on the entry editor export button. Short.
  ///
  /// In en, this message translates to:
  /// **'Export this entry'**
  String get tooltipExportEntry;

  /// Tooltip on the journal screen export button. Short.
  ///
  /// In en, this message translates to:
  /// **'Export this journal'**
  String get tooltipExportJournal;

  /// Title of the journal picker opened from the settings export tile. Short.
  ///
  /// In en, this message translates to:
  /// **'Export from journal'**
  String get titleExportChooseJournal;

  /// Snackbar when export is opened with no journals.
  ///
  /// In en, this message translates to:
  /// **'Create a journal first, then you can export it.'**
  String get bodyExportNoJournals;

  /// Snackbar when every journal is locked and none can be exported.
  ///
  /// In en, this message translates to:
  /// **'Open a locked journal first to export from it.'**
  String get bodyExportAllLocked;

  /// Written into an exported file in place of an editor block this build cannot export. {type} is the block's internal name.
  ///
  /// In en, this message translates to:
  /// **'{type} block — not exportable as text'**
  String descExportFileUnexportableBlock(String type);

  /// Written into an exported web page after the name of an inline image that could not be embedded.
  ///
  /// In en, this message translates to:
  /// **'image not included'**
  String get descExportFileImageNotIncluded;

  /// Written into an exported web page after the name of an inline drawing that could not be embedded.
  ///
  /// In en, this message translates to:
  /// **'drawing not included'**
  String get descExportFileDrawingNotIncluded;

  /// Button that closes an information dialog.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionCommonOk;

  /// Button that closes a finished flow.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionCommonDone;

  /// Shown after settings received by QR were applied.
  ///
  /// In en, this message translates to:
  /// **'Settings and templates applied.'**
  String get bodyAirqrSettingsApplied;

  /// Shown after an entry received by QR was saved.
  ///
  /// In en, this message translates to:
  /// **'Entry imported into your journal.'**
  String get bodyAirqrEntryImported;

  /// Shown after a journal received by QR was saved.
  ///
  /// In en, this message translates to:
  /// **'Journal and entries imported.'**
  String get bodyAirqrJournalImported;

  /// Snackbar when saving data received by QR fails.
  ///
  /// In en, this message translates to:
  /// **'Could not import the data.'**
  String get errorAirqrImport;

  /// Title given to an entry received by QR that had no title.
  ///
  /// In en, this message translates to:
  /// **'Imported entry'**
  String get descAirqrImportedEntryTitle;

  /// Title given to a journal received by QR that had no title.
  ///
  /// In en, this message translates to:
  /// **'Imported journal'**
  String get descAirqrImportedJournalTitle;

  /// Progress text while received QR frames are joined and verified.
  ///
  /// In en, this message translates to:
  /// **'Joining the frames and checking them…'**
  String get bodyAirqrAssembling;

  /// Shown when received QR data cannot be decrypted or decoded.
  ///
  /// In en, this message translates to:
  /// **'The data could not be read. Check the pairing code and scan again.'**
  String get errorAirqrDecode;

  /// Button that restarts QR scanning after an error.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get actionAirqrScanAgain;

  /// Scan progress. A frame is one QR image in the moving sequence.
  ///
  /// In en, this message translates to:
  /// **'Received {received} of {total} frames'**
  String bodyAirqrFramesReceived(int received, int total);

  /// Hint shown before the first QR frame is seen.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the moving QR code…'**
  String get bodyAirqrAlignCamera;

  /// Lists the frame numbers not yet received.
  ///
  /// In en, this message translates to:
  /// **'Missing frames: {frames}'**
  String bodyAirqrMissingFrames(String frames);

  /// Heading above the pairing code field on the QR receive screen.
  ///
  /// In en, this message translates to:
  /// **'Enter pairing code'**
  String get titleAirqrEnterCode;

  /// Explains where to find the pairing code.
  ///
  /// In en, this message translates to:
  /// **'Enter the 16-character code shown on the sending screen.'**
  String get descAirqrEnterCode;

  /// Button that decrypts received QR data with the pairing code.
  ///
  /// In en, this message translates to:
  /// **'Decrypt and verify'**
  String get actionAirqrDecrypt;

  /// Heading shown when received QR data passed its integrity check.
  ///
  /// In en, this message translates to:
  /// **'Data verified'**
  String get titleAirqrVerified;

  /// Kind of data received by QR.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String descAirqrPayloadType(String type);

  /// Kind of QR data: app settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get labelAirqrKindSettings;

  /// Kind of QR data: one journal entry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get labelAirqrKindEntry;

  /// Kind of QR data: a whole journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get labelAirqrKindJournal;

  /// Kind of QR data: a text snapshot of the vault.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get labelAirqrKindSnapshot;

  /// Theme setting inside received QR data.
  ///
  /// In en, this message translates to:
  /// **'Theme: {theme}'**
  String descAirqrPayloadTheme(String theme);

  /// Accent color inside received QR data, as a hex code.
  ///
  /// In en, this message translates to:
  /// **'Accent color: {color}'**
  String descAirqrPayloadAccent(String color);

  /// Number of custom templates inside received QR data.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Templates: 1 custom template} other{Templates: {count} custom templates}}'**
  String descAirqrPayloadTemplates(int count);

  /// Number of tags inside received QR data.
  ///
  /// In en, this message translates to:
  /// **'Tags: {count}'**
  String descAirqrPayloadTags(int count);

  /// Button that applies settings received by QR.
  ///
  /// In en, this message translates to:
  /// **'Apply settings'**
  String get actionAirqrApplySettings;

  /// Button that saves an entry or journal received by QR.
  ///
  /// In en, this message translates to:
  /// **'Import to vault'**
  String get actionAirqrImport;

  /// Progress text while data is turned into QR frames.
  ///
  /// In en, this message translates to:
  /// **'Preparing the QR frames…'**
  String get bodyAirqrEncoding;

  /// Shown when data cannot be turned into QR frames.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the data to send.'**
  String get errorAirqrEncode;

  /// Size of the data being sent by QR.
  ///
  /// In en, this message translates to:
  /// **'{bytes} bytes • {frames} data frames'**
  String descAirqrPayloadSize(int bytes, int frames);

  /// Shown while the first QR frame, which describes the transfer, is on screen.
  ///
  /// In en, this message translates to:
  /// **'Header frame'**
  String get labelAirqrManifestFrame;

  /// Which QR frame is on screen.
  ///
  /// In en, this message translates to:
  /// **'Frame {index} of {total}'**
  String labelAirqrFrameOf(int index, int total);

  /// QR frames shown per second.
  ///
  /// In en, this message translates to:
  /// **'Speed: {fps} FPS'**
  String labelAirqrSpeed(int fps);

  /// Dialog body when data is over the QR size limit.
  ///
  /// In en, this message translates to:
  /// **'{size} is too large to send by QR (limit {limit}). Use Wi-Fi Sync instead.'**
  String bodyAirqrTooLarge(String size, String limit);

  /// Dialog body warning that a large QR transfer will be slow.
  ///
  /// In en, this message translates to:
  /// **'This transfer is {size} and will take about {duration} by QR. Wi-Fi Sync is much faster for large transfers.'**
  String bodyAirqrSlow(String size, String duration);

  /// A duration in minutes, used inside the slow-transfer warning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String descAirqrMinutes(int count);

  /// A duration in seconds, used inside the slow-transfer warning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String descAirqrSeconds(int count);

  /// Snackbar when there is no journal to send by QR.
  ///
  /// In en, this message translates to:
  /// **'No journals to send.'**
  String get bodyAirqrNoJournals;

  /// Heading of the sheet that picks a journal to send by QR.
  ///
  /// In en, this message translates to:
  /// **'Choose a journal'**
  String get titleAirqrSelectJournal;

  /// Shown under a journal that has no description.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get descAirqrNoDescription;

  /// Subtitle on the QR transfer header card.
  ///
  /// In en, this message translates to:
  /// **'Fully offline • Camera only'**
  String get descAirqrOffline;

  /// Badge on the settings transfer card: it takes less than a second.
  ///
  /// In en, this message translates to:
  /// **'Under 1 sec'**
  String get labelAirqrBadgeFast;

  /// Name of a QR transfer that carries app settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleAirqrPayloadSettings;

  /// Name of a QR transfer that carries a text snapshot of the vault.
  ///
  /// In en, this message translates to:
  /// **'Vault text snapshot'**
  String get titleAirqrPayloadSnapshot;

  /// Snackbar when sealing an entry as a time capsule fails.
  ///
  /// In en, this message translates to:
  /// **'Could not seal the time capsule.'**
  String get errorTimeCapsuleSeal;

  /// Shown when a sealed entry has no time capsule record.
  ///
  /// In en, this message translates to:
  /// **'Time capsule not found.'**
  String get errorTimeCapsuleNotFound;

  /// Shown when the time capsule record cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not open the time capsule.'**
  String get errorTimeCapsuleLoad;

  /// Unit under the days number in the time capsule countdown.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get labelTimeCapsuleDays;

  /// Unit under the hours number in the time capsule countdown.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get labelTimeCapsuleHours;

  /// Unit under the minutes number in the time capsule countdown. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get labelTimeCapsuleMinutes;

  /// Unit under the seconds number in the time capsule countdown. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Secs'**
  String get labelTimeCapsuleSeconds;

  /// Label for the date a time capsule was sealed.
  ///
  /// In en, this message translates to:
  /// **'Sealed on'**
  String get labelTimeCapsuleSealedOn;

  /// Label for the date a time capsule can be opened.
  ///
  /// In en, this message translates to:
  /// **'Unlocks on'**
  String get labelTimeCapsuleUnlocksOn;

  /// Heading above the note the writer left for their future self.
  ///
  /// In en, this message translates to:
  /// **'Note to future self'**
  String get labelTimeCapsuleTeaser;

  /// Hint shown in the empty entry editor.
  ///
  /// In en, this message translates to:
  /// **'Write your entry…'**
  String get descEditorPlaceholder;

  /// Reason shown in the system fingerprint or PIN prompt when opening a locked attachment.
  ///
  /// In en, this message translates to:
  /// **'Unlock \"{fileName}\"'**
  String descBiometricReasonFile(String fileName);

  /// Reason shown in the system fingerprint or PIN prompt when unlocking the app. The app name stays in English.
  ///
  /// In en, this message translates to:
  /// **'Unlock SreerajP Journal Vault'**
  String get descBiometricReasonApp;

  /// Placeholder for a locked drawing inside an entry.
  ///
  /// In en, this message translates to:
  /// **'Locked drawing — tap to unlock'**
  String get bodyEditorDrawingLocked;

  /// Placeholder while an image inside an entry is being decrypted.
  ///
  /// In en, this message translates to:
  /// **'Loading image…'**
  String get descEditorImageLoading;

  /// Shown when the list of custom templates cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load templates.'**
  String get errorTemplateLoad;

  /// Snackbar when saving a custom template fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save the template.'**
  String get errorTemplateSave;

  /// Size and type of an encrypted file shared into the app.
  ///
  /// In en, this message translates to:
  /// **'{size} KB • Encrypted vault file'**
  String descShareSealedFileSize(String size);

  /// Font size in points. 'pt' is the standard unit symbol and stays the same in every language.
  ///
  /// In en, this message translates to:
  /// **'{size} pt'**
  String labelTypographyPoints(int size);

  /// Font name and size in points. 'pt' is the standard unit symbol.
  ///
  /// In en, this message translates to:
  /// **'{family} • {size} pt'**
  String descTypographyFamilyAndSize(String family, int size);

  /// Explains the {{today}} template token. Keep YYYY-MM-DD as is.
  ///
  /// In en, this message translates to:
  /// **'Today\'s date (YYYY-MM-DD)'**
  String get descTemplateTokenToday;

  /// Explains the {{weekday}} template token.
  ///
  /// In en, this message translates to:
  /// **'Day of the week (e.g. Monday)'**
  String get descTemplateTokenWeekday;

  /// Explains the {{date}} template token.
  ///
  /// In en, this message translates to:
  /// **'Full date (e.g. August 23, 2026)'**
  String get descTemplateTokenDate;

  /// Explains the {{time}} template token.
  ///
  /// In en, this message translates to:
  /// **'Current time (e.g. 2:30 PM)'**
  String get descTemplateTokenTime;

  /// Explains the {{year}} template token.
  ///
  /// In en, this message translates to:
  /// **'Four-digit year (e.g. 2026)'**
  String get descTemplateTokenYear;

  /// Explains the {{month}} template token.
  ///
  /// In en, this message translates to:
  /// **'Month name (e.g. August)'**
  String get descTemplateTokenMonth;

  /// Explains the {{day}} template token.
  ///
  /// In en, this message translates to:
  /// **'Day of the month (1–31)'**
  String get descTemplateTokenDay;

  /// Default title for an entry made from shared content that had no subject.
  ///
  /// In en, this message translates to:
  /// **'Note - {date}'**
  String descShareDefaultTitle(String date);

  /// Subtitle under a time capsule that has already been opened.
  ///
  /// In en, this message translates to:
  /// **'Opened on {date}'**
  String labelTimeCapsuleOpenedOn(String date);

  /// Shown when opening a sealed time capsule fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Could not unseal the time capsule.'**
  String get errorTimeCapsuleUnseal;

  /// Progress text while the app opens a connection to the other device.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the device…'**
  String get bodySyncStepConnecting;

  /// Progress text while the pairing code is verified.
  ///
  /// In en, this message translates to:
  /// **'Checking the pairing code…'**
  String get bodySyncStepAuthenticating;

  /// Progress text while data is copied between the two devices.
  ///
  /// In en, this message translates to:
  /// **'Copying entries and attachments…'**
  String get bodySyncStepSyncing;

  /// Shown when a device-to-device sync has finished.
  ///
  /// In en, this message translates to:
  /// **'Sync finished.'**
  String get bodySyncStepCompleted;

  /// Shown when a device-to-device sync could not finish.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Check both devices and try again.'**
  String get errorSyncFailed;

  /// Sync indicator when no sync has run yet.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get labelSyncNotSynced;

  /// Sync indicator when the last sync succeeded.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get labelSyncSynced;

  /// Form error when the host address field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter the IP address.'**
  String get errorSyncIpRequired;

  /// Form error when the port number is missing or out of range.
  ///
  /// In en, this message translates to:
  /// **'Enter a port between 1 and 65535.'**
  String get errorSyncPortInvalid;

  /// Form error when the pairing code is missing or malformed.
  ///
  /// In en, this message translates to:
  /// **'Enter the 16-character pairing code.'**
  String get errorSyncCodeInvalid;

  /// Shown when the local network address of this device cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Could not read this device\'s address.'**
  String get errorSyncHostAddress;

  /// Shown in place of the IP address when this device has none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get labelSyncNoAddress;

  /// Shown while the app looks for a local Wi-Fi address.
  ///
  /// In en, this message translates to:
  /// **'Looking for Wi-Fi…'**
  String get bodySyncDetectingWifi;

  /// This device's local network addresses.
  ///
  /// In en, this message translates to:
  /// **'IP: {addresses}'**
  String labelSyncIpList(String addresses);

  /// Number of sync conflicts still waiting to be resolved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict} other{{count} conflicts}}'**
  String labelSyncUnresolvedConflicts(int count);

  /// When the last successful sync finished.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {timestamp}'**
  String labelSyncLastSyncAt(String timestamp);

  /// Shown when the text-capture screen finds no usable camera.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get errorOcrNoCameras;

  /// Heading of the voice note sheet while recording is running.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get bodyVoiceNoteRecording;

  /// Heading of the voice note sheet before recording starts.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get titleVoiceNote;

  /// Shown when an audio attachment cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'This audio file could not be played.'**
  String get errorAttachmentAudioPlay;

  /// Shown when a zip attachment cannot be listed.
  ///
  /// In en, this message translates to:
  /// **'This archive could not be read. It may be damaged or password-protected.'**
  String get errorAttachmentArchiveRead;

  /// Relative date for the current day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get labelDateToday;

  /// Relative date for the previous day.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get labelDateYesterday;

  /// Relative date in days. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String labelDateDaysAgo(int count);

  /// Relative date in weeks. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String labelDateWeeksAgo(int count);

  /// Relative date in months. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String labelDateMonthsAgo(int count);

  /// Relative date in years. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String labelDateYearsAgo(int count);

  /// Name of the permission that lets the app read files to attach.
  ///
  /// In en, this message translates to:
  /// **'File access'**
  String get titlePermissionAttachmentImport;

  /// Explains the attachment library permission.
  ///
  /// In en, this message translates to:
  /// **'Lets the app read files from your device storage when you add an attachment.'**
  String get descPermissionAttachmentImport;

  /// Name of the implicit permission for the system file picker.
  ///
  /// In en, this message translates to:
  /// **'File picker'**
  String get titlePermissionDocumentPicker;

  /// Explains that the system file picker needs no permission.
  ///
  /// In en, this message translates to:
  /// **'Uses the system file picker to choose attachments. No permission is needed.'**
  String get descPermissionDocumentPicker;

  /// Security log line: an unlock attempt failed.
  ///
  /// In en, this message translates to:
  /// **'Unlock failed'**
  String get labelSecurityEventFailedAuth;

  /// Security log line: an attachment was locked.
  ///
  /// In en, this message translates to:
  /// **'Attachment locked'**
  String get labelSecurityEventAttachmentLocked;

  /// Security log line: an attachment was unlocked.
  ///
  /// In en, this message translates to:
  /// **'Attachment unlocked'**
  String get labelSecurityEventAttachmentUnlocked;

  /// Security log line: an export was made.
  ///
  /// In en, this message translates to:
  /// **'Data exported'**
  String get labelSecurityEventExportAttempt;

  /// Security log line: the app lock closed the vault.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get labelSecurityEventLockTriggered;

  /// Security log line: an auto-lock profile was changed.
  ///
  /// In en, this message translates to:
  /// **'Profile changed'**
  String get labelSecurityEventProfileChanged;

  /// Security log line: an auto-lock profile was created.
  ///
  /// In en, this message translates to:
  /// **'Profile created'**
  String get labelSecurityEventProfileCreated;

  /// Security log line: the screenshot blocking switch was changed.
  ///
  /// In en, this message translates to:
  /// **'Screenshots changed'**
  String get labelSecurityEventScreenSecurityChanged;

  /// Security log line: stored data did not match its checksum.
  ///
  /// In en, this message translates to:
  /// **'Tampering detected'**
  String get labelSecurityEventTamperDetected;

  /// Security log line for an event type this build does not name.
  ///
  /// In en, this message translates to:
  /// **'Security event'**
  String get labelSecurityEventOther;

  /// Import file type: a .docx word processor file.
  ///
  /// In en, this message translates to:
  /// **'Word document'**
  String get labelImportFormatWord;

  /// Import file type: a Markdown text file. The format name is the same in every language.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get labelImportFormatMarkdown;

  /// Import file type: a plain .txt file.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get labelImportFormatPlainText;

  /// Name of the Android notification channel used for time capsule alerts.
  ///
  /// In en, this message translates to:
  /// **'Time Capsules'**
  String get titleNotificationTimeCapsules;

  /// Shown when moving attachments to another storage location fails.
  ///
  /// In en, this message translates to:
  /// **'Could not move the attachments.'**
  String get errorStorageMigrationFailed;

  /// Extra note under the attachment permission on newer Android versions.
  ///
  /// In en, this message translates to:
  /// **'Granted through the system file picker — no separate permission is needed on Android 13 and later.'**
  String get descPermissionSafGranted;

  /// How many entries a journal holds, shown on the journal card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String labelJournalEntryCount(int count);

  /// Toolbar button that opens on-device dictation
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get tooltipEditorDictate;

  /// Title of the dictation sheet
  ///
  /// In en, this message translates to:
  /// **'Dictation'**
  String get titleDictation;

  /// Accessibility label while the microphone is open
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get labelDictationListening;

  /// Accessibility label while dictation is paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get labelDictationPaused;

  /// Tooltip of the button that pauses dictation
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get tooltipDictationPause;

  /// Tooltip of the button that resumes dictation
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get tooltipDictationResume;

  /// Tooltip of the dictation language picker
  ///
  /// In en, this message translates to:
  /// **'Speech language'**
  String get tooltipDictationLanguage;

  /// Language chip when the device does not list its offline languages
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get labelDictationDeviceDefault;

  /// Label of the field where dictated text can be corrected before inserting
  ///
  /// In en, this message translates to:
  /// **'Edit text'**
  String get labelDictationEditHint;

  /// Button that inserts dictated text into the entry
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get actionDictationInsert;

  /// Placeholder in the dictation sheet before anything is heard
  ///
  /// In en, this message translates to:
  /// **'Start speaking. Your words will appear here.'**
  String get emptyDictationSpeak;

  /// Privacy note under the dictation title
  ///
  /// In en, this message translates to:
  /// **'Speech is recognised on this device. No audio is saved or sent.'**
  String get descDictationPrivacy;

  /// Shown when the device has no on-device speech recogniser
  ///
  /// In en, this message translates to:
  /// **'Offline speech recognition is not available on this device. Dictation works only on the device, so it cannot be used here.'**
  String get errorDictationOfflineUnavailable;

  /// Shown when the chosen dictation language has no offline model
  ///
  /// In en, this message translates to:
  /// **'The offline speech model for this language is not installed. Install it in your phone\'s speech settings, or pick another language.'**
  String get errorDictationLanguageUnavailable;

  /// Shown when the speech recogniser fails
  ///
  /// In en, this message translates to:
  /// **'Speech recognition stopped unexpectedly. Try again.'**
  String get errorDictationFailed;

  /// Hint shown in the Sanskrit UI, because no offline Sanskrit recogniser exists
  ///
  /// In en, this message translates to:
  /// **'Sanskrit speech cannot be recognised offline yet. Speak in English or Malayalam.'**
  String get helpDictationSanskritUnsupported;

  /// Tooltip for the icon on the OCR enhance screen that reads the text of the photo and shows it
  ///
  /// In en, this message translates to:
  /// **'Preview text'**
  String get tooltipOcrPreviewText;

  /// Scan-text source option that opens the camera built into this app instead of the phone camera app
  ///
  /// In en, this message translates to:
  /// **'In-app camera'**
  String get actionOcrInAppCamera;

  /// Shown when the phone camera app cannot be opened for scanning text, so the in-app camera opens instead
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone\'s camera app. Using the in-app camera instead.'**
  String get errorOcrPhoneCameraUnavailable;

  /// Help bullet explaining the phone camera app option, its gallery-copy privacy note, and the in-app camera alternative
  ///
  /// In en, this message translates to:
  /// **'\"Take photo\" opens your phone\'s own camera app for the clearest photos. A few camera apps also keep their own copy in the gallery. Choose \"In-app camera\" if the photo must never leave this app.'**
  String get helpOcrPhoneCamera;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml', 'sa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
    case 'sa':
      return AppLocalizationsSa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
