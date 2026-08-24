import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

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
  ];

  /// Title of the screen shown when the encrypted database cannot be opened at startup
  ///
  /// In en, this message translates to:
  /// **'The vault cannot be opened'**
  String get vaultUnavailableTitle;

  /// Reason line when the Android Keystore no longer holds the database key
  ///
  /// In en, this message translates to:
  /// **'The key that unlocks your journal is no longer on this device. Without it, nothing can read the vault — not even this app.'**
  String get vaultUnavailableKeyMissing;

  /// Reason line when the SQLCipher library was not the one loaded, which is a build fault
  ///
  /// In en, this message translates to:
  /// **'This build of the app cannot encrypt the vault, so it has stopped rather than store your journal unprotected.'**
  String get vaultUnavailableCipherMissing;

  /// Reason line when the one-time plain to encrypted conversion failed
  ///
  /// In en, this message translates to:
  /// **'Your journal could not be moved into encrypted storage. It has been left exactly as it was — nothing has been deleted.'**
  String get vaultUnavailableConversionFailed;

  /// Reason line when the database file exists but will not open
  ///
  /// In en, this message translates to:
  /// **'The vault file cannot be read. It may be damaged, or it may belong to a different installation of the app.'**
  String get vaultUnavailableFileUnreadable;

  /// Reassurance line telling the user no data was destroyed
  ///
  /// In en, this message translates to:
  /// **'Nothing has been deleted. Your entries and attachments are still on this device.'**
  String get vaultUnavailableDataIntact;

  /// Advice on what the user can do next when the vault cannot be opened
  ///
  /// In en, this message translates to:
  /// **'If you have a backup file, reinstall the app and restore from it. If not, keep this installation as it is and do not clear the app data — that would remove the vault for good.'**
  String get vaultUnavailableNextSteps;

  /// The application title, shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault'**
  String get appTitle;

  /// Title of the About screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Shown when the About screen cannot read the app config
  ///
  /// In en, this message translates to:
  /// **'Unable to load app metadata'**
  String get aboutLoadError;

  /// Button that tries the failed action again
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Row label for the app version and build number on the About screen
  ///
  /// In en, this message translates to:
  /// **'App Version / Build'**
  String get aboutVersionBuildLabel;

  /// Row label for when the app was last built, on the About screen
  ///
  /// In en, this message translates to:
  /// **'Last Build Timestamp'**
  String get aboutLastBuildLabel;

  /// Title of the Permissions screen
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// Section header for permissions the user is asked for directly
  ///
  /// In en, this message translates to:
  /// **'Explicit permissions'**
  String get permissionsExplicitHeader;

  /// Section header for permissions granted without a prompt
  ///
  /// In en, this message translates to:
  /// **'Implicit permissions'**
  String get permissionsImplicitHeader;

  /// Permission state: the user granted it
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionStatusAllowed;

  /// Permission state: the user refused it
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionStatusDenied;

  /// Permission state: refused and the system will not ask again
  ///
  /// In en, this message translates to:
  /// **'Permanently denied'**
  String get permissionStatusPermanentlyDenied;

  /// Permission state: the user granted access to specific items only
  ///
  /// In en, this message translates to:
  /// **'User selected'**
  String get permissionStatusUserSelected;

  /// Button that asks the system for a permission
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get permissionsRequest;

  /// Button that opens the system settings page for this app
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionsOpenSettings;

  /// Button that closes a dialog without doing anything
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Button that deletes the item being discussed
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Button that saves the current edit
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Title of the tag manager screen
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// Shown when the list of tags cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not load tags: {error}'**
  String tagsLoadError(String error);

  /// Empty state on the tag manager screen
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add tags to a journal and they will show up here.'**
  String get tagsEmpty;

  /// Subtitle on a tag that has no colour chosen by the user
  ///
  /// In en, this message translates to:
  /// **'Automatic colour'**
  String get tagsAutomaticColour;

  /// Tooltip on the menu button that opens tag actions
  ///
  /// In en, this message translates to:
  /// **'Tag actions'**
  String get tagsActionsTooltip;

  /// Menu item that renames a tag
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tagsRename;

  /// Menu item, and dialog title, for picking a tag colour
  ///
  /// In en, this message translates to:
  /// **'Choose colour'**
  String get tagsChooseColour;

  /// Menu item that clears a tag colour so it is chosen automatically
  ///
  /// In en, this message translates to:
  /// **'Reset to automatic'**
  String get tagsResetColour;

  /// Message shown when a tag rename is rejected
  ///
  /// In en, this message translates to:
  /// **'That name is empty or already used by another tag.'**
  String get tagsRenameFailed;

  /// Confirmation shown after a tag is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted #{name}.'**
  String tagsDeleted(String name);

  /// Title of the confirm-delete dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get tagsDeleteTitle;

  /// Body of the confirm-delete dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Delete \"#{name}\"? It will be removed from every journal and entry that uses it.'**
  String tagsDeleteBody(String name);

  /// Title of the rename dialog for a tag
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get tagsRenameTitle;

  /// Label of the text field where a new tag name is typed
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagsNameLabel;

  /// Generic inline error text, followed by the reason
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// Placeholder title for an entry that has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled entry'**
  String get commonUntitledEntry;

  /// Short placeholder title for an item that has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get commonUntitled;

  /// Title of the timeline screen
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTitle;

  /// Empty state under the calendar when the chosen day has no entries
  ///
  /// In en, this message translates to:
  /// **'No entries for this date'**
  String get timelineNoEntriesForDate;

  /// Name of the month view of the calendar
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get timelineCalendarFormatMonth;

  /// Marker on a calendar day that has more than nine entries
  ///
  /// In en, this message translates to:
  /// **'9+'**
  String get timelineDayCountOverflow;

  /// Title of the insights screen
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// Heading of the card showing how many days in a row the user wrote
  ///
  /// In en, this message translates to:
  /// **'Writing Streak'**
  String get insightsStreakHeading;

  /// Label for the streak running right now
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get insightsStreakCurrent;

  /// Label for the longest streak ever reached
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get insightsStreakLongest;

  /// Unit shown under a streak number
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get insightsStreakUnitDays;

  /// Pairs a streak label with its unit, for example "Current (days)"
  ///
  /// In en, this message translates to:
  /// **'{label} ({unit})'**
  String insightsStreakStat(String label, String unit);

  /// Date of the most recent entry, on the streak card
  ///
  /// In en, this message translates to:
  /// **'Last entry: {date}'**
  String insightsLastEntry(String date);

  /// Heading of the mood chart card
  ///
  /// In en, this message translates to:
  /// **'Mood Trends (30 days)'**
  String get insightsMoodHeading;

  /// Empty state of the mood chart card
  ///
  /// In en, this message translates to:
  /// **'No mood data yet.\nRate your mood on entries to see trends.'**
  String get insightsMoodEmpty;

  /// Tooltip on one bar of the mood chart
  ///
  /// In en, this message translates to:
  /// **'{date}\nMood: {mood}\nEntries: {count}'**
  String insightsMoodTooltip(String date, String mood, int count);

  /// Heading of the card showing which tags are used most
  ///
  /// In en, this message translates to:
  /// **'Tag Heatmap'**
  String get insightsTagHeatmapHeading;

  /// Empty state of the tag heatmap card
  ///
  /// In en, this message translates to:
  /// **'No tags used yet.'**
  String get insightsTagHeatmapEmpty;

  /// One tag and how many times it was used
  ///
  /// In en, this message translates to:
  /// **'{tag} ({count})'**
  String insightsTagChip(String tag, int count);

  /// Heading of the card showing entries from the same date in past years
  ///
  /// In en, this message translates to:
  /// **'On This Day'**
  String get insightsMemoriesHeading;

  /// Empty state of the memories card
  ///
  /// In en, this message translates to:
  /// **'No memories for today.\nKeep journaling to build memories!'**
  String get insightsMemoriesEmpty;

  /// Short label on a memory, meaning that many years ago
  ///
  /// In en, this message translates to:
  /// **'{years}y'**
  String insightsYearsAgo(int years);

  /// Heading of the weekly summary card
  ///
  /// In en, this message translates to:
  /// **'Weekly Reflection'**
  String get insightsReflectionHeading;

  /// Row label for the dates the weekly summary covers
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get insightsReflectionPeriod;

  /// Row label for how many entries were written this week
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get insightsReflectionEntries;

  /// Row label for how many words were written this week
  ///
  /// In en, this message translates to:
  /// **'Words Written'**
  String get insightsReflectionWords;

  /// Row label for the average mood this week
  ///
  /// In en, this message translates to:
  /// **'Average Mood'**
  String get insightsReflectionAverageMood;

  /// Row label for the most used tags this week
  ///
  /// In en, this message translates to:
  /// **'Top Tags'**
  String get insightsReflectionTopTags;

  /// Row label for the streak running right now
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get insightsReflectionStreak;

  /// A start and end date, shown as one range
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String insightsDateRange(String start, String end);

  /// An average mood score out of five
  ///
  /// In en, this message translates to:
  /// **'{mood} / 5'**
  String insightsMoodOutOfFive(String mood);

  /// A number of days in a row
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String insightsStreakDays(int count);

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Placeholder shown when a failure gives no reason
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// Title of the import screen
  ///
  /// In en, this message translates to:
  /// **'Import Files'**
  String get importTitle;

  /// Button label while an import is running
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importSelecting;

  /// Button that opens the file picker to choose files to import
  ///
  /// In en, this message translates to:
  /// **'Select Files to Import'**
  String get importSelectFiles;

  /// Heading above the list of imported files
  ///
  /// In en, this message translates to:
  /// **'Import Results'**
  String get importResultsHeading;

  /// Shown under a file that imported without a problem
  ///
  /// In en, this message translates to:
  /// **'Imported successfully'**
  String get importFileSucceeded;

  /// Confirmation after an import finishes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file imported successfully} other{{count} files imported successfully}}'**
  String importCountSucceeded(int count);

  /// Shown when a ZIP attachment has no files inside
  ///
  /// In en, this message translates to:
  /// **'This archive is empty.'**
  String get attachmentArchiveEmpty;

  /// Button and tooltip that hands the attachment to another app
  ///
  /// In en, this message translates to:
  /// **'Open with...'**
  String get attachmentOpenWith;

  /// Heading when an attachment cannot be shown inside the app
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type'**
  String get attachmentUnsupportedTitle;

  /// Explains which attachment cannot be shown in the app
  ///
  /// In en, this message translates to:
  /// **'{fileName} cannot be shown inside the app.'**
  String attachmentUnsupportedBody(String fileName);

  /// Shown when the temporary decrypted PDF has already been deleted
  ///
  /// In en, this message translates to:
  /// **'The decrypted file is no longer available.'**
  String get attachmentPdfMissing;

  /// Shown when the PDF viewer fails to load a file
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF: {reason}'**
  String attachmentPdfOpenFailed(String reason);

  /// Title of the auto-lock profiles screen
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Profiles'**
  String get autoLockTitle;

  /// Button, and dialog title, for creating an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get autoLockNewProfile;

  /// Dialog title, and tooltip, for changing an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get autoLockEditProfile;

  /// Empty state of the auto-lock profiles screen
  ///
  /// In en, this message translates to:
  /// **'No auto-lock profiles yet. Create one to lock the app after a period of inactivity.'**
  String get autoLockEmpty;

  /// Tooltip on the button that removes an auto-lock profile
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get autoLockDeleteProfile;

  /// Tooltip on the button that turns an auto-lock profile on
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get autoLockActivate;

  /// Tooltip on the button that turns an auto-lock profile off
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get autoLockDeactivate;

  /// Joins the parts of an auto-lock profile summary line
  ///
  /// In en, this message translates to:
  /// **'{timeout}{lockOnMinimize}{active}'**
  String autoLockSummary(String timeout, String lockOnMinimize, String active);

  /// Part of the summary line saying the app locks when minimized
  ///
  /// In en, this message translates to:
  /// **' • lock on minimize'**
  String get autoLockSuffixLockOnMinimize;

  /// Part of the summary line saying this profile is the one in use
  ///
  /// In en, this message translates to:
  /// **' • active'**
  String get autoLockSuffixActive;

  /// A timeout of under a minute, in seconds
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String autoLockTimeoutSeconds(int seconds);

  /// A timeout of under an hour, in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String autoLockTimeoutMinutes(int minutes);

  /// A timeout of an hour or more, in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String autoLockTimeoutHours(String hours);

  /// Label of the field for an auto-lock profile name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get autoLockNameLabel;

  /// Label of the field for how long before the app locks
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get autoLockTimeoutLabel;

  /// Switch that locks the app as soon as it is minimized
  ///
  /// In en, this message translates to:
  /// **'Lock on minimize'**
  String get autoLockLockOnMinimize;

  /// Validation message when the profile name is left blank
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get autoLockNameRequired;

  /// Validation message when the timeout is not a whole number above zero
  ///
  /// In en, this message translates to:
  /// **'Timeout must be a positive integer.'**
  String get autoLockTimeoutInvalid;

  /// Title of the security events screen
  ///
  /// In en, this message translates to:
  /// **'Security Events'**
  String get securityEventsTitle;

  /// Empty state of the security events screen
  ///
  /// In en, this message translates to:
  /// **'No security events recorded'**
  String get securityEventsEmpty;

  /// Title of the dialog showing the raw detail of one security event
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get securityEventDetailsTitle;

  /// Title of the screen listing sync conflicts
  ///
  /// In en, this message translates to:
  /// **'Sync Conflicts'**
  String get syncConflictsTitle;

  /// Shown when the list of conflicts cannot be read
  ///
  /// In en, this message translates to:
  /// **'Failed to load conflicts:\n{error}'**
  String syncConflictsLoadFailed(String error);

  /// Heading of the empty state when nothing is in conflict
  ///
  /// In en, this message translates to:
  /// **'No pending conflicts'**
  String get syncNoConflicts;

  /// Subtitle of the empty state when nothing is in conflict
  ///
  /// In en, this message translates to:
  /// **'All data is in sync.'**
  String get syncAllInSync;

  /// When a conflict was first noticed
  ///
  /// In en, this message translates to:
  /// **'Detected: {timestamp}'**
  String syncDetectedAt(String timestamp);

  /// Heading above the list of fields that differ
  ///
  /// In en, this message translates to:
  /// **'Changed fields:'**
  String get syncChangedFields;

  /// Button that opens a side-by-side view of the two versions
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get syncCompare;

  /// Button that keeps the version from the other device
  ///
  /// In en, this message translates to:
  /// **'Keep Remote'**
  String get syncKeepRemote;

  /// Button that keeps the version on this device
  ///
  /// In en, this message translates to:
  /// **'Keep Local'**
  String get syncKeepLocal;

  /// Title of the dialog confirming that the local version wins
  ///
  /// In en, this message translates to:
  /// **'Keep local version?'**
  String get syncKeepLocalTitle;

  /// Title of the dialog confirming that the remote version wins
  ///
  /// In en, this message translates to:
  /// **'Keep remote version?'**
  String get syncKeepRemoteTitle;

  /// Explains what happens when the local version is kept
  ///
  /// In en, this message translates to:
  /// **'The remote changes will be discarded. Your local version will be pushed on next sync.'**
  String get syncKeepLocalBody;

  /// Explains what happens when the remote version is kept
  ///
  /// In en, this message translates to:
  /// **'Your local changes will be overwritten with the remote version.'**
  String get syncKeepRemoteBody;

  /// Button that agrees to the action described in a dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Confirmation shown after a conflict is settled
  ///
  /// In en, this message translates to:
  /// **'Conflict resolved.'**
  String get syncConflictResolved;

  /// Shown when settling a conflict does not work
  ///
  /// In en, this message translates to:
  /// **'Resolution failed: {error}'**
  String syncResolutionFailed(String error);

  /// Title of the dialog comparing the local and remote values
  ///
  /// In en, this message translates to:
  /// **'Conflict Details'**
  String get syncConflictDetailsTitle;

  /// Column heading for the name of the field that differs
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get syncColumnField;

  /// Column heading for the value on this device
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get syncColumnLocal;

  /// Column heading for the value on the other device
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get syncColumnRemote;

  /// Heading of the sync health card
  ///
  /// In en, this message translates to:
  /// **'Sync Health'**
  String get syncHealthHeading;

  /// Row label for when sync last ran
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get syncLastSync;

  /// Row label for how many syncs failed in the last seven days
  ///
  /// In en, this message translates to:
  /// **'Failures (7d)'**
  String get syncFailures7d;

  /// Row label for how many conflicts are waiting
  ///
  /// In en, this message translates to:
  /// **'Pending conflicts'**
  String get syncPendingConflicts;

  /// Placeholder shown while a value is being read
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Short placeholder shown in place of a value that could not be read
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonErrorShort;

  /// Short placeholder shown while a number is being counted
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get commonEllipsis;

  /// Shown in place of a date when sync has never run
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get syncNever;

  /// Button that opens the conflict list, with how many are waiting
  ///
  /// In en, this message translates to:
  /// **'Resolve ({count})'**
  String syncResolveCount(int count);

  /// Button that starts a sync straight away
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Heading above the list of recent sync runs
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get syncRecentActivity;

  /// Shown when the sync history cannot be read
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String syncLogsLoadFailed(String error);

  /// Empty state of the sync history list
  ///
  /// In en, this message translates to:
  /// **'No sync activity yet.'**
  String get syncNoActivity;

  /// Sync state: nothing happening
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get syncStatusIdle;

  /// Status when sync is in progress
  ///
  /// In en, this message translates to:
  /// **'Syncing changes...'**
  String get syncStatusSyncing;

  /// Sync state: the last sync worked
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get syncStatusHealthy;

  /// Sync state: the last sync did not work
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get syncStatusFailed;

  /// Sync state: some records disagree and need a choice
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get syncStatusConflicts;

  /// Fallback summary for a sync run that failed with no reason given
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncLogFailed;

  /// How many records were sent to the other device
  ///
  /// In en, this message translates to:
  /// **'{count} pushed'**
  String syncLogPushed(int count);

  /// How many records were received from the other device
  ///
  /// In en, this message translates to:
  /// **'{count} pulled'**
  String syncLogPulled(int count);

  /// How many conflicts one sync run found
  ///
  /// In en, this message translates to:
  /// **'{count} conflicts'**
  String syncLogConflicts(int count);

  /// Summary for a sync run that moved nothing
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get syncLogNoChanges;

  /// Tooltip on the button that reloads the screen
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// Title of the backup health screen
  ///
  /// In en, this message translates to:
  /// **'Backup Health'**
  String get backupTitle;

  /// Button that starts a backup straight away
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// Button label while a backup is running
  ///
  /// In en, this message translates to:
  /// **'Backing up...'**
  String get backupInProgressLabel;

  /// Heading above the list of past backups
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get backupHistoryHeading;

  /// Heading of the card showing how healthy backups are
  ///
  /// In en, this message translates to:
  /// **'Backup Status'**
  String get backupStatusHeading;

  /// Shown when no backup has ever finished
  ///
  /// In en, this message translates to:
  /// **'No successful backups yet'**
  String get backupNoneYet;

  /// Row label for when the last backup finished
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backupLastBackup;

  /// Row label for how many entries a backup holds
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get backupEntries;

  /// Row label for how many attachments a backup holds
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get backupAttachments;

  /// Row label for how large a backup file is
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get backupSize;

  /// Warning about recent backup failures
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 failed backup in the last 7 days} other{{count} failed backups in the last 7 days}}'**
  String backupRecentFailures(int count);

  /// Heading of the card that controls automatic backups
  ///
  /// In en, this message translates to:
  /// **'Auto-Backup Schedule'**
  String get backupScheduleHeading;

  /// Shows how often automatic backups run
  ///
  /// In en, this message translates to:
  /// **'Scheduled: {interval}'**
  String backupScheduled(String interval);

  /// Shown when automatic backups are off
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get backupNotScheduled;

  /// Chip meaning the backup timer is running
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get backupTimerActive;

  /// Chip meaning the backup timer is not running
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get backupTimerInactive;

  /// Row label for when the last automatic backup ran
  ///
  /// In en, this message translates to:
  /// **'Last scheduled run'**
  String get backupLastScheduledRun;

  /// Button that turns automatic backups off
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get backupDisable;

  /// Button that opens the automatic backup settings
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get backupConfigure;

  /// Button that changes the existing backup schedule
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get backupChange;

  /// Heading of the schedule settings form
  ///
  /// In en, this message translates to:
  /// **'Configure Schedule'**
  String get backupConfigureHeading;

  /// Label of the field choosing how often to back up
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get backupIntervalLabel;

  /// Backup interval: once a day
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backupIntervalDaily;

  /// Backup interval: once a week
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backupIntervalWeekly;

  /// Backup interval: once a month
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backupIntervalMonthly;

  /// Label of the field for the password that encrypts a backup
  ///
  /// In en, this message translates to:
  /// **'Backup encryption password'**
  String get backupPasswordLabel;

  /// Helper text under the backup password field
  ///
  /// In en, this message translates to:
  /// **'Required for encrypted backups'**
  String get backupPasswordHelper;

  /// Empty state of the backup history list
  ///
  /// In en, this message translates to:
  /// **'No backup history'**
  String get backupNoHistory;

  /// Shown when the backup history cannot be read
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String backupHistoryLoadFailed(String error);

  /// Title of one row in the backup history
  ///
  /// In en, this message translates to:
  /// **'{trigger} backup — {status}'**
  String backupLogTitle(String trigger, String status);

  /// A backup the user started by hand
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get backupTriggerManual;

  /// A backup the app started on a timer
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get backupTriggerScheduled;

  /// A backup that finished
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get backupStatusSuccess;

  /// A backup that did not finish
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get backupStatusFailed;

  /// A backup that is still running
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get backupStatusInProgress;

  /// Summary of what one backup holds
  ///
  /// In en, this message translates to:
  /// **'{entries} entries, {attachments} attachments, {size}'**
  String backupLogCounts(int entries, int attachments, String size);

  /// Shown under a backup row that has not finished
  ///
  /// In en, this message translates to:
  /// **'In progress...'**
  String get backupInProgressNote;

  /// Confirmation after a backup finishes
  ///
  /// In en, this message translates to:
  /// **'Backup completed successfully'**
  String get backupSucceeded;

  /// Shown when a backup does not finish
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// Title of the dialog asking for the backup password
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get backupPasswordTitle;

  /// Label of the password field in the backup dialog
  ///
  /// In en, this message translates to:
  /// **'Enter encryption password'**
  String get backupPasswordEnter;

  /// Button that starts the backup after the password is typed
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupAction;

  /// Shown when the backup password is left blank
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get backupPasswordRequired;

  /// Confirmation after the backup schedule is saved
  ///
  /// In en, this message translates to:
  /// **'Backup schedule saved'**
  String get backupScheduleSaved;

  /// Confirmation after automatic backups are turned off
  ///
  /// In en, this message translates to:
  /// **'Backup schedule disabled'**
  String get backupScheduleDisabled;

  /// A file size in bytes
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String backupBytes(int bytes);

  /// A file size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String backupKilobytes(String size);

  /// A file size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String backupMegabytes(String size);

  /// Button that brings back an earlier version
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// Button that adds the thing just described into the entry
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get commonInsert;

  /// Button that goes on to the next step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Button that opens the phone settings page for this app
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get commonOpenSystemSettings;

  /// Placeholder inside an empty callout block
  ///
  /// In en, this message translates to:
  /// **'Enter callout text...'**
  String get editorCalloutHint;

  /// Tooltip, and dialog title, for adding a table
  ///
  /// In en, this message translates to:
  /// **'Insert table'**
  String get editorInsertTable;

  /// Tooltip for adding a callout block
  ///
  /// In en, this message translates to:
  /// **'Insert callout'**
  String get editorInsertCallout;

  /// Tooltip for adding a picture
  ///
  /// In en, this message translates to:
  /// **'Insert image'**
  String get editorInsertImage;

  /// Tooltip on the menu that changes how wide a picture is
  ///
  /// In en, this message translates to:
  /// **'Image size'**
  String get editorImageSize;

  /// Picture size: small
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get editorImageSizeSmall;

  /// Picture size: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get editorImageSizeMedium;

  /// Picture size: as wide as the page
  ///
  /// In en, this message translates to:
  /// **'Full width'**
  String get editorImageSizeFull;

  /// Tooltip on the button that deletes a picture
  ///
  /// In en, this message translates to:
  /// **'Remove image from the entry'**
  String get editorRemoveImage;

  /// Shown in place of a picture that cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get editorImageUnavailable;

  /// Shown when recording is refused because the microphone is blocked
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get editorMicPermissionDenied;

  /// Button that throws away the recording just made
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editorDiscard;

  /// Button that keeps the recording just made
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editorDone;

  /// Title of the version history screen
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get versionHistoryTitle;

  /// Shown when the list of earlier versions cannot be read
  ///
  /// In en, this message translates to:
  /// **'Error loading revisions: {error}'**
  String versionHistoryLoadFailed(String error);

  /// Title of the dialog confirming a restore
  ///
  /// In en, this message translates to:
  /// **'Restore this version?'**
  String get versionRestoreTitle;

  /// Confirmation after an earlier version is brought back
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get versionRestored;

  /// Tooltip on the button that shows an earlier version without restoring it
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get versionPreview;

  /// Tooltip on the button that brings back an earlier version
  ///
  /// In en, this message translates to:
  /// **'Restore this version'**
  String get versionRestoreTooltip;

  /// Title of the screen previewing an earlier version
  ///
  /// In en, this message translates to:
  /// **'Preview: {title}'**
  String versionPreviewTitle(String title);

  /// Confirmation after an entry is saved
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get entrySaved;

  /// Title of the dialog confirming an entry is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get entryDeleteTitle;

  /// Body of the dialog confirming an entry is deleted
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the entry.'**
  String get entryDeleteBody;

  /// Label of the field for how many rows a new table has
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get entryTableRows;

  /// Label of the field for how many columns a new table has
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get entryTableColumns;

  /// Helper text saying the allowed range for table rows and columns
  ///
  /// In en, this message translates to:
  /// **'1–20'**
  String get entryTableDimensionHelp;

  /// Title of the dialog choosing which kind of callout to add
  ///
  /// In en, this message translates to:
  /// **'Callout type'**
  String get entryCalloutTypeTitle;

  /// Callout kind: a neutral note
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get entryCalloutInfo;

  /// Callout kind: a helpful suggestion
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get entryCalloutTip;

  /// Callout kind: something to be careful about
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get entryCalloutWarning;

  /// Callout kind: something that must not be missed
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get entryCalloutImportant;

  /// Confirmation after a voice note is stored, with its length
  ///
  /// In en, this message translates to:
  /// **'Voice note saved ({seconds}s)'**
  String entryVoiceNoteSaved(String seconds);

  /// Title of the entry editor
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get entryEditTitle;

  /// Title of the entry editor when there are unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Edit entry •'**
  String get entryEditTitleDirty;

  /// Tooltip on the button that opens earlier versions of the entry
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get entryVersionHistoryTooltip;

  /// Tooltip on the button that deletes the entry
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get entryDeleteTooltip;

  /// Tooltip on the save button when there is something to save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get entrySaveTooltip;

  /// Tooltip on the save button when nothing has changed
  ///
  /// In en, this message translates to:
  /// **'No unsaved changes'**
  String get entryNoUnsavedChanges;

  /// Label of the entry title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get entryTitleLabel;

  /// Title of the dialog asking for file access
  ///
  /// In en, this message translates to:
  /// **'Allow attachment import?'**
  String get entryPermissionTitle;

  /// Body of the dialog asking for file access
  ///
  /// In en, this message translates to:
  /// **'This app needs permission to access your files.'**
  String get entryPermissionBody;

  /// Title shown when file access was refused for good
  ///
  /// In en, this message translates to:
  /// **'Attachment access blocked'**
  String get entryPermissionBlockedTitle;

  /// Body shown when file access was refused for good
  ///
  /// In en, this message translates to:
  /// **'Permission was permanently denied. Please enable it in system settings.'**
  String get entryPermissionBlockedBody;

  /// Shown when a non-image file is chosen for an inline picture
  ///
  /// In en, this message translates to:
  /// **'That file is not an image. Add it as an attachment instead.'**
  String get entryNotAnImage;

  /// Shown when adding an inline picture does not work
  ///
  /// In en, this message translates to:
  /// **'Could not add that image.'**
  String get entryImageAddFailed;

  /// Tooltip on the button that attaches a file
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get entryAddAttachment;

  /// Tooltip on the button that records a voice note
  ///
  /// In en, this message translates to:
  /// **'Record voice note'**
  String get entryRecordVoiceNote;

  /// Heading above the entries that link to this one
  ///
  /// In en, this message translates to:
  /// **'Linked from'**
  String get entryLinkedFrom;

  /// Heading of the mood picker
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get entryMood;

  /// One mood choice: a face and its number
  ///
  /// In en, this message translates to:
  /// **'{face} {level}'**
  String entryMoodChip(String face, int level);

  /// Shown when an action needs the user to unlock first
  ///
  /// In en, this message translates to:
  /// **'Authentication required.'**
  String get entryAuthRequired;

  /// Shown when no installed app can open the attachment
  ///
  /// In en, this message translates to:
  /// **'No compatible app found'**
  String get attachmentOpenNoApp;

  /// Shown when the attachment cannot be decrypted
  ///
  /// In en, this message translates to:
  /// **'Could not decrypt attachment'**
  String get attachmentOpenDecryptFailed;

  /// Shown when the stored attachment file cannot be found
  ///
  /// In en, this message translates to:
  /// **'Attachment file is missing'**
  String get attachmentOpenFileMissing;

  /// Shown when opening the attachment needs a permission that was refused
  ///
  /// In en, this message translates to:
  /// **'Permission required to open attachment'**
  String get attachmentOpenPermissionDenied;

  /// Heading above the entry attachment list
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get entryAttachments;

  /// Tooltip on the button that unlocks one attachment
  ///
  /// In en, this message translates to:
  /// **'Remove attachment lock'**
  String get entryRemoveAttachmentLock;

  /// Tooltip on the button that locks one attachment
  ///
  /// In en, this message translates to:
  /// **'Lock attachment'**
  String get entryLockAttachment;

  /// Tooltip on the button that opens one attachment
  ///
  /// In en, this message translates to:
  /// **'Open attachment'**
  String get entryOpenAttachment;

  /// Body of the dialog confirming a restore
  ///
  /// In en, this message translates to:
  /// **'Your current content will be saved as a new version before restoring.'**
  String get versionRestoreBody;

  /// Button that unlocks something after the secret is entered
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get commonUnlock;

  /// Label of a password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// Button label while a save is running
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get commonSaving;

  /// Title of the first-launch lock setup screen
  ///
  /// In en, this message translates to:
  /// **'Set up app lock'**
  String get lockSetupTitle;

  /// Explains the lock choice on first launch
  ///
  /// In en, this message translates to:
  /// **'Choose how SreerajP Journal Vault should lock when it is sent to the background.'**
  String get lockSetupBody;

  /// Lock mode that reuses the device unlock
  ///
  /// In en, this message translates to:
  /// **'Phone Lock'**
  String get lockModePhone;

  /// Explains the phone lock mode
  ///
  /// In en, this message translates to:
  /// **'Use the device biometric or PIN/pattern/password.'**
  String get lockModePhoneHint;

  /// Lock mode with its own PIN inside the app
  ///
  /// In en, this message translates to:
  /// **'Separate App Lock'**
  String get lockModeApp;

  /// Explains the separate app lock mode
  ///
  /// In en, this message translates to:
  /// **'Use a dedicated PIN that is verified inside the app.'**
  String get lockModeAppHint;

  /// Label of the PIN field
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get lockPinLabel;

  /// Label of the field where the PIN is typed a second time
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get lockConfirmPinLabel;

  /// Button label while the lock is being set up
  ///
  /// In en, this message translates to:
  /// **'Setting up...'**
  String get lockSettingUp;

  /// Validation message for a PIN that is too short
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 characters.'**
  String get lockPinTooShort;

  /// Validation message when the two PIN fields differ
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get lockPinsDoNotMatch;

  /// Shown when the lock setup cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save lock setup: {error}'**
  String lockSetupSaveFailed(String error);

  /// Shown when the PIN cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save PIN: {error}'**
  String lockPinSaveFailed(String error);

  /// Title of the screen and dialog that set the app-lock PIN
  ///
  /// In en, this message translates to:
  /// **'Set app-lock PIN'**
  String get lockPinSetupTitle;

  /// Explains why a PIN is needed
  ///
  /// In en, this message translates to:
  /// **'Separate App Lock requires a PIN. Set one to continue.'**
  String get lockPinSetupBody;

  /// Title of the screen shown while the app is locked
  ///
  /// In en, this message translates to:
  /// **'App Lock Gate'**
  String get lockGateTitle;

  /// Headline on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Your journal is locked'**
  String get lockGateHeadline;

  /// Line under the headline on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Unlock to open your entries.'**
  String get lockGateSubtitle;

  /// Tooltip on the button that reveals the typed PIN
  ///
  /// In en, this message translates to:
  /// **'Show PIN'**
  String get lockGateShowPin;

  /// Tooltip on the button that hides the typed PIN
  ///
  /// In en, this message translates to:
  /// **'Hide PIN'**
  String get lockGateHidePin;

  /// Screen reader label for the lock icon on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockGateBadgeSemantics;

  /// Button that unlocks using the device credential
  ///
  /// In en, this message translates to:
  /// **'Unlock with Phone Lock'**
  String get lockUnlockWithPhone;

  /// Shown when the device unlock did not succeed
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get lockAuthFailed;

  /// Shown when the device has no unlock method set up
  ///
  /// In en, this message translates to:
  /// **'Device authentication is not available. Configure a PIN/biometric in system settings.'**
  String get lockAuthUnavailable;

  /// Shown when the PIN field is left blank
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN.'**
  String get lockEnterPin;

  /// Shown when the typed PIN is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get lockIncorrectPin;

  /// Title of the screen listing locked attachments
  ///
  /// In en, this message translates to:
  /// **'Attachment-Level Lock'**
  String get lockedAttachmentsTitle;

  /// Empty state of the locked attachments screen
  ///
  /// In en, this message translates to:
  /// **'No attachments are locked yet. Open an entry and use the lock button on an attachment to require re-authentication before opening it.'**
  String get lockedAttachmentsEmpty;

  /// Says when an attachment was locked
  ///
  /// In en, this message translates to:
  /// **'Locked {date}'**
  String lockedAttachmentSince(String date);

  /// Button that unlocks one attachment
  ///
  /// In en, this message translates to:
  /// **'Remove lock'**
  String get lockedAttachmentRemove;

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
  String get journalDeleteTitle;

  /// Body of the dialog confirming a journal is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String journalDeleteBody(String title);

  /// Tooltip on the button that opens the tag manager
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get journalManageTags;

  /// Button, tooltip, and dialog title for creating a journal
  ///
  /// In en, this message translates to:
  /// **'New journal'**
  String get journalNew;

  /// Dialog title, and tooltip, for changing a journal
  ///
  /// In en, this message translates to:
  /// **'Edit journal'**
  String get journalEdit;

  /// Tooltip on the button that deletes a journal
  ///
  /// In en, this message translates to:
  /// **'Delete journal'**
  String get journalDelete;

  /// Heading of the empty state on the home screen
  ///
  /// In en, this message translates to:
  /// **'No journals yet'**
  String get journalEmptyTitle;

  /// Body of the empty state on the home screen
  ///
  /// In en, this message translates to:
  /// **'Tap “New journal” to start writing.'**
  String get journalEmptyBody;

  /// Label of the journal title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalTitleLabel;

  /// Label of the journal description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get journalDescriptionLabel;

  /// Label of the journal tags field
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get journalTagsLabel;

  /// Switch that puts a password on a new journal
  ///
  /// In en, this message translates to:
  /// **'Lock journal'**
  String get journalLockSwitch;

  /// Label of the field where the journal password is typed again
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get journalConfirmPasswordLabel;

  /// Button that creates a new entry in this journal
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get journalAddEntry;

  /// Shown in place of the entries of a locked journal
  ///
  /// In en, this message translates to:
  /// **'Journal is locked'**
  String get journalIsLocked;

  /// Shown above the entries of a journal that has just been unlocked
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get journalUnlocked;

  /// Shown when the journal password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get journalIncorrectPassword;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// One-line description under the security card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Lock mode, auto-lock, screenshots and security events'**
  String get settingsSectionSecuritySubtitle;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// One-line description under the appearance card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Theme and how the app looks'**
  String get settingsSectionAppearanceSubtitle;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsSectionStorage;

  /// One-line description under the storage card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Attachment location, usage, backup and import'**
  String get settingsSectionStorageSubtitle;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsSectionPermissions;

  /// One-line description under the permissions card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'What the app is allowed to use'**
  String get settingsSectionPermissionsSubtitle;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// One-line description under the about card on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Version, licences and app details'**
  String get settingsSectionAboutSubtitle;

  /// Settings row introducing the two lock modes
  ///
  /// In en, this message translates to:
  /// **'App Lock Mode'**
  String get settingsAppLockMode;

  /// Settings row that opens the auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Timeout'**
  String get settingsAutoLockTimeout;

  /// Settings switch that blocks screenshots and screen recording
  ///
  /// In en, this message translates to:
  /// **'Block Screenshots'**
  String get settingsScreenSecurity;

  /// Explains what the screenshot blocking switch covers
  ///
  /// In en, this message translates to:
  /// **'Stops screenshots, screen recording and the preview shown in the recent apps list'**
  String get settingsScreenSecuritySubtitle;

  /// Title of the dialog shown before screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Turn off screenshot blocking?'**
  String get settingsScreenSecurityOffTitle;

  /// Warning text shown before screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Anyone taking a screenshot or recording the screen will be able to capture your journal content. The recent apps list will also show your last screen. You can turn this back on at any time.'**
  String get settingsScreenSecurityOffBody;

  /// Confirm button that turns screenshot blocking off
  ///
  /// In en, this message translates to:
  /// **'Turn Off'**
  String get settingsScreenSecurityOffAction;

  /// Message shown after screenshot blocking is turned on
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking is on'**
  String get settingsScreenSecurityUpdatedOn;

  /// Message shown after screenshot blocking is turned off
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking is off'**
  String get settingsScreenSecurityUpdatedOff;

  /// Message shown when the screenshot blocking choice could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not change screenshot blocking'**
  String get settingsScreenSecuritySaveFailed;

  /// Settings row for tamper alerts, not built yet
  ///
  /// In en, this message translates to:
  /// **'Tamper Alerts'**
  String get settingsTamperAlerts;

  /// Settings row that opens the sync conflict list
  ///
  /// In en, this message translates to:
  /// **'Sync Conflicts'**
  String get settingsSyncConflicts;

  /// Settings row that opens the security event log
  ///
  /// In en, this message translates to:
  /// **'Security Events'**
  String get settingsSecurityEvents;

  /// Settings row introducing the theme choice
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Explains the theme choice
  ///
  /// In en, this message translates to:
  /// **'Choose how SreerajP_Journal_Vault looks.'**
  String get settingsThemeSubtitle;

  /// Theme choice: light colours
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme choice: dark colours
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Theme choice: follow the device setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Settings row that opens the About screen
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get settingsAbout;

  /// Marker on a settings row that is not built yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsComingSoon;

  /// Title of the dialog confirming a lock mode change
  ///
  /// In en, this message translates to:
  /// **'Switch lock mode?'**
  String get settingsSwitchLockTitle;

  /// Explains what changing the lock mode does
  ///
  /// In en, this message translates to:
  /// **'This will switch app protection to {enabled} and disable {disabled}. Continue?'**
  String settingsSwitchLockBody(String enabled, String disabled);

  /// Button that confirms the lock mode change
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get settingsSwitchAction;

  /// Confirmation after the lock mode changes
  ///
  /// In en, this message translates to:
  /// **'Lock mode updated: {mode} is now active.'**
  String settingsLockModeUpdated(String mode);

  /// Shown when the theme choice cannot be stored
  ///
  /// In en, this message translates to:
  /// **'Could not save theme setting. Please try again.'**
  String get settingsThemeSaveFailed;

  /// Confirmation after the theme changes
  ///
  /// In en, this message translates to:
  /// **'Theme updated: {mode} mode is now active.'**
  String settingsThemeUpdated(String mode);

  /// Title of the dialog confirming an attachment move
  ///
  /// In en, this message translates to:
  /// **'Migrate attachments?'**
  String get storageMigrateTitle;

  /// Explains where attachments will be moved to
  ///
  /// In en, this message translates to:
  /// **'All attachments will be moved to {target}.'**
  String storageMigrateBody(String target);

  /// Button that starts moving the attachments
  ///
  /// In en, this message translates to:
  /// **'Migrate'**
  String get storageMigrateAction;

  /// Shown when the user stops the move
  ///
  /// In en, this message translates to:
  /// **'Migration cancelled.'**
  String get storageMigrationCancelled;

  /// Shown when the move does not finish
  ///
  /// In en, this message translates to:
  /// **'Migration failed: {error}'**
  String storageMigrationFailed(String error);

  /// Shown when the move finishes
  ///
  /// In en, this message translates to:
  /// **'Migration complete.'**
  String get storageMigrationComplete;

  /// Settings row showing where attachments are kept
  ///
  /// In en, this message translates to:
  /// **'Attachment Storage Location'**
  String get storageLocationTitle;

  /// Title of the dialog choosing where attachments are kept
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get storageLocationDialogTitle;

  /// Storage choice: the app private folder
  ///
  /// In en, this message translates to:
  /// **'App Private'**
  String get storageAppPrivate;

  /// Storage choice: the SD card
  ///
  /// In en, this message translates to:
  /// **'SD Card'**
  String get storageSdCard;

  /// The SD card choice, with the chosen folder name
  ///
  /// In en, this message translates to:
  /// **'SD Card ({label})'**
  String storageSdCardNamed(String label);

  /// Settings row that moves attachments between locations
  ///
  /// In en, this message translates to:
  /// **'Migrate Storage'**
  String get storageMigrateRow;

  /// Migration state: nothing is happening
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get storageMigrationIdle;

  /// Migration state: how far it has got
  ///
  /// In en, this message translates to:
  /// **'Migrating {processed} of {total}…'**
  String storageMigrationRunning(int processed, int total);

  /// Migration state: the last attempt did not finish
  ///
  /// In en, this message translates to:
  /// **'Migration failed.'**
  String get storageMigrationFailedShort;

  /// Settings row showing how much space attachments use
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// Placeholder shown when a value is not known yet
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get storageUnknown;

  /// Settings row that opens the backup health screen
  ///
  /// In en, this message translates to:
  /// **'Backup Health'**
  String get storageBackupHealth;

  /// Settings row that opens the import screen
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get storageImportData;

  /// Settings row, and screen title, for the sync health dashboard
  ///
  /// In en, this message translates to:
  /// **'Sync Health'**
  String get storageSyncHealth;

  /// Shown when there is nothing to import into
  ///
  /// In en, this message translates to:
  /// **'Create a journal first to import into.'**
  String get storageImportNeedsJournal;

  /// Title of the dialog choosing where to import
  ///
  /// In en, this message translates to:
  /// **'Import into journal'**
  String get storageImportChooseJournal;

  /// A size in bytes
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String storageBytes(int bytes);

  /// A size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String storageKilobytes(String size);

  /// A size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String storageMegabytes(String size);

  /// A size in gigabytes
  ///
  /// In en, this message translates to:
  /// **'{size} GB'**
  String storageGigabytes(String size);

  /// Title of the dialog shown while attachments are being moved
  ///
  /// In en, this message translates to:
  /// **'Migrating attachments'**
  String get migrationDialogTitle;

  /// Shown while the move is being stopped
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get migrationCancelling;

  /// How many attachments have been moved so far
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total}'**
  String migrationProgress(String processed, String total);

  /// Placeholder used when the total is not known yet
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get migrationUnknownTotal;

  /// Settings row summarising the permissions
  ///
  /// In en, this message translates to:
  /// **'Permission Status'**
  String get permissionStatusRow;

  /// Settings row that opens the permissions screen
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get permissionsManage;

  /// Settings row that opens the phone settings page
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get permissionsOpenSystem;

  /// How many permissions are granted
  ///
  /// In en, this message translates to:
  /// **'{granted} of {total} granted'**
  String permissionsGrantedSummary(int granted, int total);

  /// Placeholder in the search field
  ///
  /// In en, this message translates to:
  /// **'Search journals & entries...'**
  String get searchHint;

  /// Shown before anything has been typed
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get searchTypeToSearch;

  /// Shown when the entry filter finds nothing
  ///
  /// In en, this message translates to:
  /// **'No matches found for this filter.'**
  String get searchNoFilterMatches;

  /// Shown when the search finds nothing
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// Heading above matching journals
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get searchSectionJournals;

  /// Heading above matching entries
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get searchSectionEntries;

  /// Title of the dialog that names a saved search
  ///
  /// In en, this message translates to:
  /// **'Save search preset'**
  String get searchSavePresetTitle;

  /// Label of the field naming a saved search
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get searchPresetNameLabel;

  /// Title of the restore screen
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreTitle;

  /// Row in Backup Health that opens the restore screen
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreOpenAction;

  /// Heading shown while the restore screen is locked
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get restoreLockedTitle;

  /// Explains why the restore screen asks to unlock first
  ///
  /// In en, this message translates to:
  /// **'Restoring changes your journal, so it is protected the same way the app is.'**
  String get restoreLockedBody;

  /// Button that starts the unlock check on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get restoreUnlockAction;

  /// Reason shown in the system fingerprint or PIN prompt
  ///
  /// In en, this message translates to:
  /// **'Unlock to restore a backup'**
  String get restoreUnlockReason;

  /// Message after a failed unlock on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Could not unlock. Nothing was changed.'**
  String get restoreUnlockFailed;

  /// Label of the PIN field on the restore screen
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN'**
  String get restoreEnterPin;

  /// Message shown when the entered PIN does not match
  ///
  /// In en, this message translates to:
  /// **'That PIN is not right.'**
  String get restorePinWrong;

  /// Heading above the list of backup files
  ///
  /// In en, this message translates to:
  /// **'Choose a backup'**
  String get restorePickHeading;

  /// Button that opens the file picker to find a backup
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get restorePickFromDevice;

  /// Shown when the app has no backup files of its own
  ///
  /// In en, this message translates to:
  /// **'No backups made by this app were found. You can still choose a file.'**
  String get restoreNoBackupsFound;

  /// Shows which backup file the user picked
  ///
  /// In en, this message translates to:
  /// **'Selected: {fileName}'**
  String restoreSelectedFile(String fileName);

  /// Label of the field asking for the backup password
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get restorePasswordLabel;

  /// Helper text under the backup password field
  ///
  /// In en, this message translates to:
  /// **'The password used when this backup was made.'**
  String get restorePasswordHelper;

  /// Button that decrypts the chosen backup and shows a preview
  ///
  /// In en, this message translates to:
  /// **'Open backup'**
  String get restoreOpenBackupAction;

  /// Heading of the preview card
  ///
  /// In en, this message translates to:
  /// **'What this backup holds'**
  String get restorePreviewHeading;

  /// When the backup was created
  ///
  /// In en, this message translates to:
  /// **'Made on {date}'**
  String restorePreviewCreated(String date);

  /// Row counts held in the backup
  ///
  /// In en, this message translates to:
  /// **'{journals} journals, {entries} entries, {attachments} attachments'**
  String restorePreviewCounts(int journals, int entries, int attachments);

  /// Warning shown for a format version 1 backup
  ///
  /// In en, this message translates to:
  /// **'This is an older backup. Its attachments only open on the device that made it.'**
  String get restoreLegacyAttachmentsWarning;

  /// Heading above the replace and merge choice
  ///
  /// In en, this message translates to:
  /// **'How should it be restored?'**
  String get restoreModeHeading;

  /// Name of the merge restore mode
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get restoreModeMerge;

  /// Explains the merge restore mode
  ///
  /// In en, this message translates to:
  /// **'Add what is missing and keep everything you have now.'**
  String get restoreModeMergeDetail;

  /// Name of the replace restore mode
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreModeReplace;

  /// Explains the replace restore mode
  ///
  /// In en, this message translates to:
  /// **'Delete what is here now and use the backup instead. A safety backup is taken first.'**
  String get restoreModeReplaceDetail;

  /// Button that runs the restore without writing anything
  ///
  /// In en, this message translates to:
  /// **'Try it first'**
  String get restoreDryRunAction;

  /// Helper text under the dry run button
  ///
  /// In en, this message translates to:
  /// **'Shows what would change without changing anything.'**
  String get restoreDryRunHelper;

  /// Button that performs the restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// Title of the dialog confirming a replace
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get restoreConfirmReplaceTitle;

  /// Body of the dialog confirming a replace
  ///
  /// In en, this message translates to:
  /// **'Every journal, entry and attachment on this device will be deleted and replaced by the backup. A safety backup of what is here now is taken first.'**
  String get restoreConfirmReplaceBody;

  /// Title of the dialog confirming a merge
  ///
  /// In en, this message translates to:
  /// **'Merge this backup?'**
  String get restoreConfirmMergeTitle;

  /// Body of the dialog confirming a merge
  ///
  /// In en, this message translates to:
  /// **'Anything the backup holds that is missing here will be added. Nothing is deleted.'**
  String get restoreConfirmMergeBody;

  /// Title of the dialog reporting a dry run
  ///
  /// In en, this message translates to:
  /// **'What would happen'**
  String get restoreDryRunResultTitle;

  /// Title of the dialog reporting a finished restore
  ///
  /// In en, this message translates to:
  /// **'Restore finished'**
  String get restoreResultTitle;

  /// How many rows were added
  ///
  /// In en, this message translates to:
  /// **'Added: {count} rows'**
  String restoreResultAdded(int count);

  /// How many rows were skipped as already present
  ///
  /// In en, this message translates to:
  /// **'Already here: {count} rows'**
  String restoreResultSkipped(int count);

  /// How many attachment files were restored
  ///
  /// In en, this message translates to:
  /// **'Attachment files restored: {count}'**
  String restoreResultFiles(int count);

  /// How many attachment files failed
  ///
  /// In en, this message translates to:
  /// **'Attachment files that could not be restored: {count}'**
  String restoreResultFilesFailed(int count);

  /// Tells the user a pre-restore backup exists
  ///
  /// In en, this message translates to:
  /// **'A safety backup of your previous data was saved first.'**
  String get restoreResultSafetyBackup;

  /// Message when the backup cannot be decrypted
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the backup file is damaged.'**
  String get restoreErrorWrongPassword;

  /// Message when the archive cannot be read
  ///
  /// In en, this message translates to:
  /// **'This file is not a backup, or it is damaged.'**
  String get restoreErrorDamaged;

  /// Message when the backup comes from a newer build
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of the app. Update the app and try again.'**
  String get restoreErrorTooNew;

  /// Message when the entered password is too short
  ///
  /// In en, this message translates to:
  /// **'The backup password must be at least 8 characters.'**
  String get restoreErrorPasswordTooShort;

  /// Message when a restore fails and rolls back
  ///
  /// In en, this message translates to:
  /// **'The restore failed and nothing was changed: {error}'**
  String restoreErrorFailed(String error);

  /// Shown while a restore or preview is running
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get restoreWorking;

  /// Switch that encrypts the exported file
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get exportProtectTitle;

  /// Explains what the export password switch does
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted with your password. It can be opened again in this app, on any device.'**
  String get exportProtectHint;

  /// Label of the export password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get exportPasswordLabel;

  /// Label of the second export password field
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get exportPasswordConfirmLabel;

  /// Error when the export password is too short
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String exportPasswordTooShort(int count);

  /// Error when the two export password fields differ
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match.'**
  String get exportPasswordMismatch;

  /// Warning shown when an export will be encrypted
  ///
  /// In en, this message translates to:
  /// **'Keep this password somewhere safe. Without it the exported file cannot be opened again, by anyone, including you.'**
  String get exportEncryptedNotice;

  /// Title of the screen that decrypts an exported file
  ///
  /// In en, this message translates to:
  /// **'Open an encrypted export'**
  String get openEncryptedTitle;

  /// Explains what the open-encrypted-export screen does
  ///
  /// In en, this message translates to:
  /// **'Choose an encrypted export file, enter its password, and save the file inside it.'**
  String get openEncryptedIntro;

  /// Button that opens the file picker
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get openEncryptedPickFile;

  /// Shows which file was chosen
  ///
  /// In en, this message translates to:
  /// **'Chosen: {fileName}'**
  String openEncryptedChosenFile(String fileName);

  /// Label of the password field on the open-encrypted screen
  ///
  /// In en, this message translates to:
  /// **'File password'**
  String get openEncryptedPasswordLabel;

  /// Button that decrypts the file and saves the result
  ///
  /// In en, this message translates to:
  /// **'Open and save'**
  String get openEncryptedAction;

  /// Shown while the file is being decrypted
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get openEncryptedWorking;

  /// Title of the system save dialog for a decrypted export
  ///
  /// In en, this message translates to:
  /// **'Save the opened file'**
  String get openEncryptedSaveDialogTitle;

  /// Confirmation after a decrypted export is written out
  ///
  /// In en, this message translates to:
  /// **'Saved. The file is no longer encrypted, so keep it somewhere safe.'**
  String get openEncryptedSaved;

  /// Shown when the user backs out of the save dialog
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved.'**
  String get openEncryptedCancelled;

  /// Error when the password does not open the file
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the file is damaged.'**
  String get openEncryptedErrorWrongPassword;

  /// Error when the chosen file has no envelope
  ///
  /// In en, this message translates to:
  /// **'This is not an encrypted export made by this app.'**
  String get openEncryptedErrorNotSealed;

  /// Error when the file uses a newer envelope
  ///
  /// In en, this message translates to:
  /// **'This file was made by a newer version of the app. Update the app and try again.'**
  String get openEncryptedErrorTooNew;

  /// Error when decrypting fails for any other reason
  ///
  /// In en, this message translates to:
  /// **'The file could not be opened.'**
  String get openEncryptedErrorFailed;

  /// Settings tile that opens the decrypt screen
  ///
  /// In en, this message translates to:
  /// **'Open an encrypted export'**
  String get settingsOpenEncryptedExport;

  /// Title of the dialog that picks a starter template
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get templateChooserTitle;

  /// Shown when an entry has no recorded revision history
  ///
  /// In en, this message translates to:
  /// **'No previous versions yet.\n\nVersions are saved automatically when you edit an entry.'**
  String get versionHistoryEmpty;

  /// Stroke width option: 2px
  ///
  /// In en, this message translates to:
  /// **'Fine (2px)'**
  String get drawingStrokeFine;

  /// Stroke width option: 3.5px
  ///
  /// In en, this message translates to:
  /// **'Normal (3.5px)'**
  String get drawingStrokeNormal;

  /// Stroke width option: 7px
  ///
  /// In en, this message translates to:
  /// **'Thick (7px)'**
  String get drawingStrokeThick;

  /// Stroke width option: 14px
  ///
  /// In en, this message translates to:
  /// **'Bold (14px)'**
  String get drawingStrokeBold;

  /// Default fallback title for full screen drawing viewer
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get drawingDefaultTitle;

  /// Default fallback title for full screen image viewer
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageDefaultTitle;

  /// Placeholder message for locked image embed
  ///
  /// In en, this message translates to:
  /// **'Locked image — tap to unlock'**
  String get editorImageLocked;

  /// Placeholder message for missing image with file name
  ///
  /// In en, this message translates to:
  /// **'Image unavailable — {fileName}'**
  String editorImageUnavailableWithName(String fileName);

  /// Tooltip to pause audio playback
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get audioPauseTooltip;

  /// Tooltip to play audio playback
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get audioPlayTooltip;

  /// Header indicating destination journal for import
  ///
  /// In en, this message translates to:
  /// **'Import into \"{journalTitle}\"'**
  String importIntoJournal(String journalTitle);

  /// Supported import file formats description
  ///
  /// In en, this message translates to:
  /// **'Supported formats: {formats}'**
  String importSupportedFormats(String formats);

  /// Supported import file extensions label
  ///
  /// In en, this message translates to:
  /// **'Files: {extensions}'**
  String importSupportedExtensions(String extensions);

  /// Placeholder message prompting user to select files for import
  ///
  /// In en, this message translates to:
  /// **'Select files to import as new entries'**
  String get importSelectFilesPrompt;

  /// Category name for journaling features
  ///
  /// In en, this message translates to:
  /// **'Journaling & Rich Text Editor'**
  String get featuresCategoryJournaling;

  /// Category subtitle for journaling features
  ///
  /// In en, this message translates to:
  /// **'Expressive writing, structured templates, OCR, and rich media'**
  String get featuresCategoryJournalingSubtitle;

  /// Category name for security features
  ///
  /// In en, this message translates to:
  /// **'Privacy, Encryption & Vault Security'**
  String get featuresCategorySecurity;

  /// Category subtitle for security features
  ///
  /// In en, this message translates to:
  /// **'Guaranteed zero-leak encryption and granular security controls'**
  String get featuresCategorySecuritySubtitle;

  /// Category name for search and timeline features
  ///
  /// In en, this message translates to:
  /// **'Search, Timeline & Insights'**
  String get featuresCategoryDiscovery;

  /// Category subtitle for search and timeline features
  ///
  /// In en, this message translates to:
  /// **'Blazing fast search, deep calendar navigation, and writing habits'**
  String get featuresCategoryDiscoverySubtitle;

  /// Category name for storage and backup features
  ///
  /// In en, this message translates to:
  /// **'Storage, Backups & Multi-Format Export'**
  String get featuresCategoryStorage;

  /// Category subtitle for storage and backup features
  ///
  /// In en, this message translates to:
  /// **'Total data sovereignty with local backups and flexible exports'**
  String get featuresCategoryStorageSubtitle;

  /// Feature title: Quill rich text editor
  ///
  /// In en, this message translates to:
  /// **'Quill Rich Text Editor'**
  String get featureQuillTitle;

  /// Feature description: Quill rich text editor
  ///
  /// In en, this message translates to:
  /// **'Write entries with rich formatting including headings, bulleted & numbered lists, bold, italics, underlines, and inline blockquotes.'**
  String get featureQuillDesc;

  /// Feature title: Structured entry templates
  ///
  /// In en, this message translates to:
  /// **'Structured Entry Templates'**
  String get featureTemplatesTitle;

  /// Feature description: Structured entry templates
  ///
  /// In en, this message translates to:
  /// **'Jumpstart your writing with 8 customizable templates: Daily Reflection, Gratitude, Dream Journal, Workout Log, Travel Diary, Meeting Notes, Bullet Journal, and Freeform.'**
  String get featureTemplatesDesc;

  /// Feature title: Encrypted media attachments and OCR
  ///
  /// In en, this message translates to:
  /// **'Encrypted Media Attachments & OCR'**
  String get featureMediaOcrTitle;

  /// Feature description: Encrypted media attachments and OCR
  ///
  /// In en, this message translates to:
  /// **'Attach photos, audio recordings, and documents encrypted on device. Extract text directly from images into your journal with offline OCR.'**
  String get featureMediaOcrDesc;

  /// Feature title: Color-coded tags and tag manager
  ///
  /// In en, this message translates to:
  /// **'Color-Coded Tags & Tag Manager'**
  String get featureTagsTitle;

  /// Feature description: Color-coded tags and tag manager
  ///
  /// In en, this message translates to:
  /// **'Organize entries and journals with vibrant color-coded tags. Rename, color, or bulk-manage tags effortlessly in the Tag Manager.'**
  String get featureTagsDesc;

  /// Feature title: Multiple distinct journals
  ///
  /// In en, this message translates to:
  /// **'Multiple Distinct Journals'**
  String get featureMultiJournalTitle;

  /// Feature description: Multiple distinct journals
  ///
  /// In en, this message translates to:
  /// **'Create multiple separate journals for work, personal diaries, travel adventures, or creative projects, each with custom tags and settings.'**
  String get featureMultiJournalDesc;

  /// Feature title: SQLCipher database encryption
  ///
  /// In en, this message translates to:
  /// **'SQLCipher AES-256 Database Encryption'**
  String get featureSqlcipherTitle;

  /// Feature description: SQLCipher database encryption
  ///
  /// In en, this message translates to:
  /// **'All journal data, entries, metadata, and tables are encrypted at rest using SQLCipher with AES-256-GCM. Unencrypted data is never written to disk.'**
  String get featureSqlcipherDesc;

  /// Feature title: Biometrics and App PIN
  ///
  /// In en, this message translates to:
  /// **'Biometric & App PIN Lock'**
  String get featureBiometricsTitle;

  /// Feature description: Biometrics and App PIN
  ///
  /// In en, this message translates to:
  /// **'Secure your vault with your device fingerprint or face unlock, or set a dedicated App PIN. The app re-locks automatically whenever you switch apps.'**
  String get featureBiometricsDesc;

  /// Feature title: Per-journal password locks
  ///
  /// In en, this message translates to:
  /// **'Per-Journal Password Locks'**
  String get featureJournalLockTitle;

  /// Feature description: Per-journal password locks
  ///
  /// In en, this message translates to:
  /// **'Lock specific sensitive journals behind individual passwords using PBKDF2 key derivation. Locked journals require password entry each session.'**
  String get featureJournalLockDesc;

  /// Feature title: Attachment encryption locks
  ///
  /// In en, this message translates to:
  /// **'Attachment-Level Encryption Locks'**
  String get featureAttachmentLockTitle;

  /// Feature description: Attachment encryption locks
  ///
  /// In en, this message translates to:
  /// **'Individually lock and hide sensitive attachments and photos with separate encryption keys, keeping them private even when browsing entries.'**
  String get featureAttachmentLockDesc;

  /// Feature title: Screenshot guard
  ///
  /// In en, this message translates to:
  /// **'Screenshot & Screen-Recording Guard'**
  String get featureScreenshotGuardTitle;

  /// Feature description: Screenshot guard
  ///
  /// In en, this message translates to:
  /// **'Automatic FLAG_SECURE window defense blocks malicious screenshot capture, screen recording apps, and recents app switcher snapshot leaking.'**
  String get featureScreenshotGuardDesc;

  /// Feature title: Tamper audit log
  ///
  /// In en, this message translates to:
  /// **'Tamper-Evident Security Audit Log'**
  String get featureTamperAuditTitle;

  /// Feature description: Tamper audit log
  ///
  /// In en, this message translates to:
  /// **'Monitors and logs key security events: app unlock attempts, failed biometric/PIN authentications, password changes, and export actions.'**
  String get featureTamperAuditDesc;

  /// Feature title: Auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Inactivity Profiles'**
  String get featureAutoLockTitle;

  /// Feature description: Auto-lock profiles
  ///
  /// In en, this message translates to:
  /// **'Configure custom timeout durations (immediate, 30 seconds, 1 min, 5 min) to automatically relock your journal vault when idle.'**
  String get featureAutoLockDesc;

  /// Feature title: SQLite FTS search
  ///
  /// In en, this message translates to:
  /// **'Lightning SQLite FTS Search'**
  String get featureFtsSearchTitle;

  /// Feature description: SQLite FTS search
  ///
  /// In en, this message translates to:
  /// **'Instant full-text search indexing scans every entry body, title, tag, and metadata with SQLite FTS5 for sub-millisecond query results.'**
  String get featureFtsSearchDesc;

  /// Feature title: Saved search presets
  ///
  /// In en, this message translates to:
  /// **'Saved Search Presets'**
  String get featureSearchPresetsTitle;

  /// Feature description: Saved search presets
  ///
  /// In en, this message translates to:
  /// **'Save frequent queries with date range and tag filters as one-tap quick filter chips directly accessible from the search bar.'**
  String get featureSearchPresetsDesc;

  /// Feature title: Calendar timeline explorer
  ///
  /// In en, this message translates to:
  /// **'Interactive Calendar Timeline Explorer'**
  String get featureTimelineTitle;

  /// Feature description: Calendar timeline explorer
  ///
  /// In en, this message translates to:
  /// **'Navigate your entire journal history with a smooth calendar view, visual daily entry dots, day-by-day browsing, and quick date jumping.'**
  String get featureTimelineDesc;

  /// Feature title: Writing trends and insights
  ///
  /// In en, this message translates to:
  /// **'Writing Trends & Habit Insights'**
  String get featureInsightsTitle;

  /// Feature description: Writing trends and insights
  ///
  /// In en, this message translates to:
  /// **'Track your daily writing streaks, word counts, active writing days per month, and top tag distributions with offline analytical charts.'**
  String get featureInsightsDesc;

  /// Feature title: Attachment storage migration
  ///
  /// In en, this message translates to:
  /// **'Attachment Storage Migration (SD Card)'**
  String get featureStorageMigrationTitle;

  /// Feature description: Attachment storage migration
  ///
  /// In en, this message translates to:
  /// **'Seamlessly migrate all encrypted attachments between internal app storage and removable SD Card memory without interrupting journal access.'**
  String get featureStorageMigrationDesc;

  /// Feature title: Encrypted vault backups
  ///
  /// In en, this message translates to:
  /// **'Encrypted Vault Backups (.jvbk)'**
  String get featureEncryptedBackupsTitle;

  /// Feature description: Encrypted vault backups
  ///
  /// In en, this message translates to:
  /// **'Export and restore complete password-protected .jvbk backup archives containing your database, attachments, tags, and settings.'**
  String get featureEncryptedBackupsDesc;

  /// Feature title: Formatted multi-format export
  ///
  /// In en, this message translates to:
  /// **'Formatted Multi-Format Export'**
  String get featureMultiExportTitle;

  /// Feature description: Formatted multi-format export
  ///
  /// In en, this message translates to:
  /// **'Export individual entries or complete journals into clean formatted PDF, Markdown zip archive, or raw JSON data formats.'**
  String get featureMultiExportDesc;

  /// Feature title: Standalone encrypted reader
  ///
  /// In en, this message translates to:
  /// **'Standalone Encrypted Export Reader'**
  String get featureEncryptedReaderTitle;

  /// Feature description: Standalone encrypted reader
  ///
  /// In en, this message translates to:
  /// **'Read password-protected encrypted journal exports independently inside the app without needing to restore the full backup database.'**
  String get featureEncryptedReaderDesc;

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
  /// **'Camera & Photos: To take photos or import images/attachments into your entries.\nMicrophone: To record voice notes.\nStorage/Media: To save encrypted backups and export PDFs.'**
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

  /// Title for sync health dashboard
  ///
  /// In en, this message translates to:
  /// **'Sync Health'**
  String get syncHealthTitle;

  /// Subtitle for sync health dashboard
  ///
  /// In en, this message translates to:
  /// **'Real-time P2P sync diagnostics & connection status'**
  String get syncHealthSubtitle;

  /// Number of connected peer devices
  ///
  /// In en, this message translates to:
  /// **'Connected Peers: {count}'**
  String syncConnectedPeers(int count);

  /// Total bytes sent over sync
  ///
  /// In en, this message translates to:
  /// **'Bytes Sent: {bytes}'**
  String syncBytesSent(String bytes);

  /// Total bytes received over sync
  ///
  /// In en, this message translates to:
  /// **'Bytes Received: {bytes}'**
  String syncBytesReceived(String bytes);

  /// Title for tamper alerts screen
  ///
  /// In en, this message translates to:
  /// **'Tamper Alerts'**
  String get tamperAlertsTitle;

  /// Section title explaining vault integrity
  ///
  /// In en, this message translates to:
  /// **'How Tamper Detection Works'**
  String get tamperAlertsHowItWorksTitle;

  /// Body explaining vault integrity
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault continuously verifies structural consistency, chronological timestamps, and AES-256 encrypted records.'**
  String get tamperAlertsHowItWorksBody;

  /// Message when no alerts exist
  ///
  /// In en, this message translates to:
  /// **'No tamper alerts recorded. Your vault entries are secure.'**
  String get tamperAlertsNoHistory;

  /// Header for alert history list
  ///
  /// In en, this message translates to:
  /// **'Tamper Alert History'**
  String get tamperAlertsHistoryHeader;

  /// Message when integrity check is clean
  ///
  /// In en, this message translates to:
  /// **'Vault scan complete: all entries verified clean.'**
  String get tamperAlertsScanCompleteClean;

  /// Message when integrity check found issues
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Integrity check found 1 issue.} other{Integrity check found {count} issues.}}'**
  String tamperAlertsScanCompleteIssues(int count);

  /// Status text for issues
  ///
  /// In en, this message translates to:
  /// **'Warning — Integrity Issues Detected'**
  String get tamperAlertsStatusIssues;

  /// Detail message when tamper issues are found
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 data integrity issue was detected in records.} other{{count} data integrity issues were detected in records.}}'**
  String tamperAlertsStatusIssuesDetail(int count);

  /// Status text for verified
  ///
  /// In en, this message translates to:
  /// **'Vault Integrity Verified'**
  String get tamperAlertsStatusVerified;

  /// Detail text for verified
  ///
  /// In en, this message translates to:
  /// **'All database tables and encryption seals verified successfully.'**
  String get tamperAlertsStatusVerifiedDetail;

  /// Button to verify integrity
  ///
  /// In en, this message translates to:
  /// **'Verify Vault Integrity'**
  String get tamperAlertsVerifyButton;

  /// Progress message during verification
  ///
  /// In en, this message translates to:
  /// **'Verifying vault integrity...'**
  String get tamperAlertsVerifying;

  /// Title for quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Quick Capture'**
  String get shareQuickCaptureTitle;

  /// Subtitle for quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Save incoming content as a new journal entry'**
  String get shareQuickCaptureSubtitle;

  /// Shown when no journal exists for share target
  ///
  /// In en, this message translates to:
  /// **'No journals found. Create a journal first.'**
  String get shareNoJournalsFound;

  /// Label for selecting destination journal
  ///
  /// In en, this message translates to:
  /// **'Select Journal'**
  String get shareSelectJournal;

  /// Label for entry title input in quick capture
  ///
  /// In en, this message translates to:
  /// **'Entry Title'**
  String get shareEntryTitleLabel;

  /// Hint for entry title input in quick capture
  ///
  /// In en, this message translates to:
  /// **'Enter title (optional)'**
  String get shareEntryTitleHint;

  /// Label for share content
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get shareContentLabel;

  /// Hint for share content
  ///
  /// In en, this message translates to:
  /// **'Shared note, quote, or link...'**
  String get shareContentHint;

  /// Label for shared attachments count
  ///
  /// In en, this message translates to:
  /// **'Attachments ({count})'**
  String shareAttachmentsLabel(int count);

  /// Discard button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get shareDiscard;

  /// Open in editor button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Open in Editor'**
  String get shareOpenInEditor;

  /// Save to journal button in share dialog
  ///
  /// In en, this message translates to:
  /// **'Save to Journal'**
  String get shareSaveToJournal;

  /// Error message when saving shared content fails
  ///
  /// In en, this message translates to:
  /// **'Could not save shared note.'**
  String get shareSaveFailed;

  /// Success message after saving shared note
  ///
  /// In en, this message translates to:
  /// **'Shared note saved to \"{journalTitle}\"'**
  String shareSavedSuccess(String journalTitle);

  /// Dialog title when encrypted export is received
  ///
  /// In en, this message translates to:
  /// **'Encrypted file detected'**
  String get shareSealedFileDetected;

  /// Button to open encrypted export
  ///
  /// In en, this message translates to:
  /// **'Open Encrypted File'**
  String get shareOpenEncryptedExport;

  /// Category for user-defined templates
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get templateCategoryCustom;

  /// Manage templates button
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get templateChooserManage;

  /// Create new template button
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get templateChooserNew;

  /// Collapse all button in template manager
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get templateCollapseAll;

  /// Expand all button in template manager
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get templateExpandAll;

  /// Create template button
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get templateCreateNew;

  /// Title for template manager screen
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get templateManagerTitle;

  /// Edit template title/action
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get templateEdit;

  /// Delete template title/action
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get templateDelete;

  /// Dialog title confirming template deletion
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get templateDeleteConfirmTitle;

  /// Dialog message confirming template deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String templateDeleteConfirmMessage(String name);

  /// Snackbar notification after template deletion
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleteSuccess;

  /// Empty state in template manager
  ///
  /// In en, this message translates to:
  /// **'No custom templates yet. Create one to reuse your favorite journaling layouts.'**
  String get templateEmpty;

  /// Label for template name field
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateNameLabel;

  /// Hint for template name field
  ///
  /// In en, this message translates to:
  /// **'e.g., Daily Standup, Workout Note'**
  String get templateNameHint;

  /// Validation error when template name is missing
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name.'**
  String get templateNameRequired;

  /// Label for template description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get templateDescriptionLabel;

  /// Hint for template description field
  ///
  /// In en, this message translates to:
  /// **'Brief summary of what this template is for'**
  String get templateDescriptionHint;

  /// Label for default entry title field
  ///
  /// In en, this message translates to:
  /// **'Default entry title'**
  String get templateDefaultTitleLabel;

  /// Hint for default entry title field
  ///
  /// In en, this message translates to:
  /// **'e.g., Standup - today'**
  String get templateDefaultTitleHint;

  /// Label for template starter content
  ///
  /// In en, this message translates to:
  /// **'Starter content'**
  String get templateContentLabel;

  /// Hint for template starter content
  ///
  /// In en, this message translates to:
  /// **'Type your starter prompt or outline...'**
  String get templateContentHint;

  /// Tooltip for inserting dynamic date token
  ///
  /// In en, this message translates to:
  /// **'Insert dynamic date token'**
  String get templateInsertTokenTooltip;

  /// Heading for dynamic date tokens list
  ///
  /// In en, this message translates to:
  /// **'Dynamic Date Tokens'**
  String get templateTokensHeading;

  /// Help text for dynamic date tokens
  ///
  /// In en, this message translates to:
  /// **'Dynamic date tokens automatically populate when creating a new entry.'**
  String get templateTokensHelper;

  /// Snackbar notification after template save
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaveSuccess;

  /// Action to save current entry as template
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get templateSaveAsTemplate;

  /// Title for save entry as template dialog
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get templateSaveAsTemplateTitle;

  /// Description for save entry as template dialog
  ///
  /// In en, this message translates to:
  /// **'Save this entry\'s layout as a reusable template.'**
  String get templateSaveAsTemplateDesc;

  /// Title for help section in settings
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSectionHelp;

  /// Subtitle for help section in settings
  ///
  /// In en, this message translates to:
  /// **'Guides, encryption details & FAQs'**
  String get settingsSectionHelpSubtitle;

  /// Title for features catalog in settings
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get settingsSectionFeatures;

  /// Subtitle for features catalog in settings
  ///
  /// In en, this message translates to:
  /// **'Explore all features and security tools'**
  String get settingsSectionFeaturesSubtitle;

  /// Header title in features catalog
  ///
  /// In en, this message translates to:
  /// **'SreerajP Journal Vault Features'**
  String get featuresHeaderTitle;

  /// Header subtitle in features catalog
  ///
  /// In en, this message translates to:
  /// **'Zero-leak offline architecture, military-grade encryption, and expressive journaling.'**
  String get featuresHeaderSubtitle;

  /// Word count format
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String entryWordCount(int count);

  /// Character count format
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 char} other{{count} chars}}'**
  String entryCharCount(int count);

  /// Stats summary combining word and char counts
  ///
  /// In en, this message translates to:
  /// **'{words} • {chars}'**
  String entryStatsSummary(String words, String chars);

  /// Enter distraction-free mode action
  ///
  /// In en, this message translates to:
  /// **'Distraction-free mode'**
  String get entryDistractionFreeEnter;

  /// Exit distraction-free mode action
  ///
  /// In en, this message translates to:
  /// **'Exit distraction-free mode'**
  String get entryDistractionFreeExit;

  /// Toggle focus paragraph on
  ///
  /// In en, this message translates to:
  /// **'Focus paragraph: on'**
  String get entryFocusParagraphOn;

  /// Toggle focus paragraph off
  ///
  /// In en, this message translates to:
  /// **'Focus paragraph: off'**
  String get entryFocusParagraphOff;

  /// Autosaving status
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get entryAutoSaving;

  /// Autosaved with timestamp
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String entryAutoSaved(String time);

  /// Autosaved just now status
  ///
  /// In en, this message translates to:
  /// **'Saved just now'**
  String get entryAutoSavedJustNow;

  /// Unsaved changes warning
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get entryUnsavedChanges;

  /// Scan text button tooltip
  ///
  /// In en, this message translates to:
  /// **'Scan text from image'**
  String get entryEditorScanText;

  /// Scan source dialog title
  ///
  /// In en, this message translates to:
  /// **'Scan text from'**
  String get entryEditorOcrSourceTitle;

  /// Camera source option
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get entryEditorScanSourceCamera;

  /// Gallery source option
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get entryEditorScanSourceGallery;

  /// OCR scanning in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning text from image...'**
  String get entryEditorOcrScanning;

  /// OCR no text found notice
  ///
  /// In en, this message translates to:
  /// **'No text was detected in the image.'**
  String get entryEditorOcrNoTextFound;

  /// OCR error message
  ///
  /// In en, this message translates to:
  /// **'Failed to scan text from image.'**
  String get entryEditorOcrError;

  /// Crop image screen title
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get entryEditorCropImageTitle;

  /// Crop image error
  ///
  /// In en, this message translates to:
  /// **'Could not process image crop.'**
  String get entryEditorCropImageError;

  /// Theme mode title in appearance settings
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get appearanceThemeModeTitle;

  /// Theme mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose System, Dark, or Light appearance'**
  String get appearanceThemeModeSubtitle;

  /// Accent color title in appearance settings
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get appearanceAccentColorTitle;

  /// Accent color subtitle
  ///
  /// In en, this message translates to:
  /// **'Select primary brand color palette'**
  String get appearanceAccentColorSubtitle;

  /// Theme live preview header
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get appearanceLivePreview;

  /// Theme color presets tab
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get appearancePresets;

  /// Custom color picker tab
  ///
  /// In en, this message translates to:
  /// **'Custom Color Wheel'**
  String get appearanceCustomWheel;

  /// Sample text preview
  ///
  /// In en, this message translates to:
  /// **'Sample Journal Entry'**
  String get appearanceSampleText;

  /// Reset appearance to default button
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get appearanceResetDefault;

  /// Contrast explanation note
  ///
  /// In en, this message translates to:
  /// **'Text contrast is adjusted automatically for readability.'**
  String get appearanceContrastNote;

  /// System mode explanation
  ///
  /// In en, this message translates to:
  /// **'System mode automatically follows your device\'s system-wide dark mode setting.'**
  String get appearanceSystemModeExplainer;

  /// Theme choice: warm parchment paper/sepia tones
  ///
  /// In en, this message translates to:
  /// **'Paper / Sepia'**
  String get settingsThemeSepia;

  /// Theme choice: pitch black for OLED/AMOLED displays
  ///
  /// In en, this message translates to:
  /// **'OLED / True Black'**
  String get settingsThemeOled;

  /// Description of the sepia/paper theme
  ///
  /// In en, this message translates to:
  /// **'Warm parchment paper tone that is soothing for long writing sessions.'**
  String get settingsThemeSepiaDesc;

  /// Description of the OLED/True Black theme
  ///
  /// In en, this message translates to:
  /// **'Pure pitch black background with crisp contrast for AMOLED battery saving.'**
  String get settingsThemeOledDesc;

  /// Description of the Light theme
  ///
  /// In en, this message translates to:
  /// **'Clean and bright daylight reading surface.'**
  String get settingsThemeLightDesc;

  /// Description of the Dark theme
  ///
  /// In en, this message translates to:
  /// **'Soft charcoal dark background for low-light writing.'**
  String get settingsThemeDarkDesc;

  /// Description of the System theme
  ///
  /// In en, this message translates to:
  /// **'Automatically follows your device system brightness preference.'**
  String get settingsThemeSystemDesc;

  /// Title of the reading typography settings screen
  ///
  /// In en, this message translates to:
  /// **'Reading Typography'**
  String get appearanceTypographyTitle;

  /// Subtitle of typography settings
  ///
  /// In en, this message translates to:
  /// **'Customize body font family and reading size'**
  String get appearanceTypographySubtitle;

  /// Header for font family section
  ///
  /// In en, this message translates to:
  /// **'Body Font Family'**
  String get appearanceFontFamily;

  /// Header for font size section
  ///
  /// In en, this message translates to:
  /// **'Body Font Size'**
  String get appearanceFontSize;

  /// Sans-serif font family label
  ///
  /// In en, this message translates to:
  /// **'Sans-Serif'**
  String get appearanceFontFamilySans;

  /// Sans-serif font family description
  ///
  /// In en, this message translates to:
  /// **'Clean and contemporary modern typeface'**
  String get appearanceFontFamilySansDesc;

  /// Serif font family label
  ///
  /// In en, this message translates to:
  /// **'Book Serif'**
  String get appearanceFontFamilySerif;

  /// Serif font family description
  ///
  /// In en, this message translates to:
  /// **'Classic editorial and literary book feel'**
  String get appearanceFontFamilySerifDesc;

  /// Monospace font family label
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get appearanceFontFamilyMonospace;

  /// Monospace font family description
  ///
  /// In en, this message translates to:
  /// **'Fixed-width typewriter and Markdown aesthetic'**
  String get appearanceFontFamilyMonospaceDesc;

  /// Small font size preset label
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get appearanceFontSizeSmall;

  /// Default font size preset label
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appearanceFontSizeDefault;

  /// Medium font size preset label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get appearanceFontSizeMedium;

  /// Large font size preset label
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get appearanceFontSizeLarge;

  /// Extra large font size preset label
  ///
  /// In en, this message translates to:
  /// **'X-Large'**
  String get appearanceFontSizeExtraLarge;

  /// Headline for sample journal preview card
  ///
  /// In en, this message translates to:
  /// **'Quiet Reflections'**
  String get appearanceSampleHeadline;

  /// Body paragraph for sample journal preview card
  ///
  /// In en, this message translates to:
  /// **'The journal is a quiet space to slow down and reflect. Every thought, memory, and sketch is securely preserved in your private vault.'**
  String get appearanceSampleBody;

  /// Confirmation message after updating typography
  ///
  /// In en, this message translates to:
  /// **'Typography settings updated.'**
  String get appearanceTypographyUpdated;

  /// Confirmation message after resetting typography
  ///
  /// In en, this message translates to:
  /// **'Typography reset to default.'**
  String get appearanceTypographyReset;

  /// Features category: journaling
  ///
  /// In en, this message translates to:
  /// **'Journaling & Rich Text Editor'**
  String get featuresCatJournaling;

  /// Features category subtitle: journaling
  ///
  /// In en, this message translates to:
  /// **'Expressive writing, structured templates, OCR, and rich media'**
  String get featuresCatJournalingSub;

  /// Features category: security
  ///
  /// In en, this message translates to:
  /// **'Privacy, Encryption & Vault Security'**
  String get featuresCatSecurity;

  /// Features category subtitle: security
  ///
  /// In en, this message translates to:
  /// **'Guaranteed zero-leak encryption and granular security controls'**
  String get featuresCatSecuritySub;

  /// Features category: search
  ///
  /// In en, this message translates to:
  /// **'Search, Timeline & Insights'**
  String get featuresCatSearch;

  /// Features category subtitle: search
  ///
  /// In en, this message translates to:
  /// **'Instant full-text discovery, visual calendar, and habit analytics'**
  String get featuresCatSearchSub;

  /// Features category: storage
  ///
  /// In en, this message translates to:
  /// **'Storage, Backups & Export'**
  String get featuresCatStorage;

  /// Features category subtitle: storage
  ///
  /// In en, this message translates to:
  /// **'Full offline autonomy, storage migration, and multi-format exports'**
  String get featuresCatStorageSub;

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
  String get editorInsertDrawing;

  /// Drawing canvas screen title
  ///
  /// In en, this message translates to:
  /// **'Drawing & Sketch'**
  String get drawingCanvasTitle;

  /// Drawing canvas edit title
  ///
  /// In en, this message translates to:
  /// **'Edit Drawing'**
  String get drawingCanvasEditTitle;

  /// Drawing canvas pen tool
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get drawingCanvasPen;

  /// Drawing canvas highlighter tool
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get drawingCanvasHighlighter;

  /// Drawing canvas eraser tool
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get drawingCanvasEraser;

  /// Clear drawing canvas action
  ///
  /// In en, this message translates to:
  /// **'Clear canvas'**
  String get drawingCanvasClear;

  /// Confirm clear canvas dialog message
  ///
  /// In en, this message translates to:
  /// **'Clear the entire drawing?'**
  String get drawingCanvasClearConfirm;

  /// Drawing stroke width selector
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get drawingCanvasStrokeWidth;

  /// Drawing stroke color selector
  ///
  /// In en, this message translates to:
  /// **'Stroke color'**
  String get drawingCanvasColor;

  /// Drawing background selector
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get drawingCanvasBackground;

  /// Blank background style
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get drawingCanvasBgBlank;

  /// Ruled lines background style
  ///
  /// In en, this message translates to:
  /// **'Ruled'**
  String get drawingCanvasBgRuled;

  /// Grid background style
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get drawingCanvasBgGrid;

  /// Dots background style
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get drawingCanvasBgDots;

  /// Drawing canvas undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get drawingCanvasUndo;

  /// Drawing canvas redo
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get drawingCanvasRedo;

  /// Save drawing button
  ///
  /// In en, this message translates to:
  /// **'Save drawing'**
  String get drawingCanvasSave;

  /// Discard drawing dialog title
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get drawingCanvasDiscardTitle;

  /// Discard drawing dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your drawing changes?'**
  String get drawingCanvasDiscardMessage;

  /// Edit inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit drawing'**
  String get drawingEditTooltip;

  /// Resize inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Resize drawing'**
  String get drawingSizeTooltip;

  /// Delete inline drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete drawing'**
  String get drawingDeleteTooltip;

  /// Drawing unavailable placeholder
  ///
  /// In en, this message translates to:
  /// **'Drawing unavailable'**
  String get drawingUnavailable;

  /// Drawing loading placeholder
  ///
  /// In en, this message translates to:
  /// **'Loading drawing…'**
  String get drawingLoading;

  /// Error message when saving a drawing fails
  ///
  /// In en, this message translates to:
  /// **'Could not save drawing.'**
  String get drawingSaveError;

  /// Custom templates action
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get journalManageTemplates;

  /// Help center title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// Features catalog title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresTitle;

  /// Feature title: 100% offline & zero network permission
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Zero Network Permission'**
  String get featureOfflineTitle;

  /// Feature description: 100% offline & zero network permission
  ///
  /// In en, this message translates to:
  /// **'The application contains zero network access code, requests no internet permissions, and keeps all journal data, attachments, and encryption strictly offline.'**
  String get featureOfflineDesc;

  /// Title of the Ritual Practice screen
  ///
  /// In en, this message translates to:
  /// **'Ritual Practice'**
  String get ritualScreenTitle;

  /// Title of the Ritual Deck Browser screen
  ///
  /// In en, this message translates to:
  /// **'Reflection Deck'**
  String get ritualDeckBrowserTitle;

  /// Tooltip for resetting spaced repetition intervals
  ///
  /// In en, this message translates to:
  /// **'Reset SRS intervals'**
  String get ritualResetReviewsTooltip;

  /// Title of dialog confirming resetting all card reviews
  ///
  /// In en, this message translates to:
  /// **'Reset All Card Reviews'**
  String get ritualResetReviewsTitle;

  /// Confirmation message when resetting spaced repetition reviews
  ///
  /// In en, this message translates to:
  /// **'This will reset review levels and next review dates for all cards. Continue?'**
  String get ritualResetReviewsConfirm;

  /// Snackbar shown after resetting card reviews
  ///
  /// In en, this message translates to:
  /// **'Card review intervals reset.'**
  String get ritualResetReviewsDone;

  /// Filter chip for all themes in reflection deck
  ///
  /// In en, this message translates to:
  /// **'All Themes'**
  String get ritualAllThemes;

  /// Badge for cards that have never been reviewed
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ritualSrsNew;

  /// Badge for cards due for review today
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get ritualSrsDueToday;

  /// Badge showing days until next review
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String ritualSrsInDays(int days);

  /// Step label for breathing in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get ritualStepBreathe;

  /// Step label for reflection card in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get ritualStepReflect;

  /// Step label for writing in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get ritualStepWrite;

  /// Heading for the breathing exercise in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Centering Breath'**
  String get ritualBreatheHeading;

  /// Button to skip breathing and go to reflection prompt
  ///
  /// In en, this message translates to:
  /// **'Skip to Prompt'**
  String get ritualSkipToPrompt;

  /// Button to continue to reflection card
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ritualContinueToCard;

  /// Button to draw another reflection card
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get ritualShuffleCard;

  /// Label for spaced repetition rating buttons
  ///
  /// In en, this message translates to:
  /// **'HOW MEMORABLE / EASY WAS THIS REFLECTION?'**
  String get ritualSrsRatePrompt;

  /// Rating button: Hard (review in 1 day)
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ritualSrsHard;

  /// Subtitle for Hard rating button
  ///
  /// In en, this message translates to:
  /// **'Review in 1d'**
  String get ritualSrsHardSubtitle;

  /// Rating button: Revision (review in 3 days)
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get ritualSrsRevision;

  /// Subtitle for Revision rating button
  ///
  /// In en, this message translates to:
  /// **'Review in 3d'**
  String get ritualSrsRevisionSubtitle;

  /// Rating button: Easy (+7 days)
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ritualSrsEasy;

  /// Subtitle for Easy rating button
  ///
  /// In en, this message translates to:
  /// **'+7 days'**
  String get ritualSrsEasySubtitle;

  /// Button to advance to journal writing step
  ///
  /// In en, this message translates to:
  /// **'Proceed to Journal'**
  String get ritualProceedToJournal;

  /// Heading when ready to write in ritual mode
  ///
  /// In en, this message translates to:
  /// **'Ready to Reflect'**
  String get ritualReadyToWriteTitle;

  /// Description explaining journal entry creation from prompt card
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts into today\'s journal entry inspired by \"{cardTitle}\".'**
  String ritualReadyToWriteDesc(String cardTitle);

  /// Button to open journal editor with prompt seeded
  ///
  /// In en, this message translates to:
  /// **'Begin Journaling'**
  String get ritualBeginWritingButton;

  /// Button to finish ritual without creating a journal entry
  ///
  /// In en, this message translates to:
  /// **'Complete Practice Only'**
  String get ritualCompletePracticeOnly;

  /// Title of Ritual Mode settings dialog
  ///
  /// In en, this message translates to:
  /// **'Ritual Mode Settings'**
  String get ritualSettingsTitle;

  /// Setting toggle to launch directly into ritual mode
  ///
  /// In en, this message translates to:
  /// **'Open in Ritual Mode'**
  String get ritualLaunchOnStartupTitle;

  /// Subtitle for launch in ritual mode setting
  ///
  /// In en, this message translates to:
  /// **'Begin every session with a guided breath and reflection prompt'**
  String get ritualLaunchOnStartupSubtitle;

  /// Label for selecting breathing technique
  ///
  /// In en, this message translates to:
  /// **'Breathing Technique'**
  String get ritualBreathTechniqueLabel;

  /// Label and value for breath cycle count slider
  ///
  /// In en, this message translates to:
  /// **'Breathing Cycles: {count}'**
  String ritualBreathCyclesLabel(int count);

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// Title of daily ritual card on Home tab
  ///
  /// In en, this message translates to:
  /// **'Daily Ritual Practice'**
  String get ritualHomeCardTitle;

  /// Subtitle of daily ritual card on Home tab
  ///
  /// In en, this message translates to:
  /// **'Center your mind with a guided breath and today\'s reflection card'**
  String get ritualHomeCardSubtitle;

  /// Button text on daily ritual card on Home tab
  ///
  /// In en, this message translates to:
  /// **'Begin Practice'**
  String get ritualHomeCardAction;

  /// Settings tile title for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Ritual Mode & Reflection'**
  String get ritualSettingsTileTitle;

  /// Settings tile subtitle for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Guided breath timer, 50-card Sanathana Dharma deck & spaced repetition'**
  String get ritualSettingsTileSubtitle;

  /// Feature catalog title for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'Ritual Mode & Reflection Cards'**
  String get featureRitualTitle;

  /// Feature catalog description for Ritual Mode
  ///
  /// In en, this message translates to:
  /// **'A guided daily practice that calms your mind with a breath timer, surfaces rotating prompt cards with Anki-style spaced repetition, and opens directly to today\'s entry.'**
  String get featureRitualDesc;

  /// Title of P2P sync landing screen
  ///
  /// In en, this message translates to:
  /// **'Device-to-Device Sync'**
  String get syncLandingTitle;

  /// Subtitle of P2P sync landing screen
  ///
  /// In en, this message translates to:
  /// **'Sync entries and attachments directly over local Wi-Fi with no cloud servers'**
  String get syncLandingSubtitle;

  /// Host mode card title
  ///
  /// In en, this message translates to:
  /// **'Send Changes (Host)'**
  String get syncSendTitle;

  /// Host mode card subtitle
  ///
  /// In en, this message translates to:
  /// **'Display a pairing QR code to share journal entries and attachments with another device'**
  String get syncSendSubtitle;

  /// Client mode card title
  ///
  /// In en, this message translates to:
  /// **'Receive Changes (Client)'**
  String get syncReceiveTitle;

  /// Client mode card subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan a pairing QR code or enter connection details to receive updates'**
  String get syncReceiveSubtitle;

  /// Host screen title
  ///
  /// In en, this message translates to:
  /// **'Host Wi-Fi Sync'**
  String get syncHostTitle;

  /// Client screen title
  ///
  /// In en, this message translates to:
  /// **'Receive Wi-Fi Sync'**
  String get syncClientTitle;

  /// Tab label for camera QR scanner
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get syncTabQrScan;

  /// Tab label for manual connection entry
  ///
  /// In en, this message translates to:
  /// **'Manual Details'**
  String get syncTabManualEntry;

  /// Tab label for host connection details
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get syncTabConnection;

  /// Label for host IP address
  ///
  /// In en, this message translates to:
  /// **'Local IP Address'**
  String get syncIpLabel;

  /// Label for host TCP port
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get syncPortLabel;

  /// Label for one-time pairing code
  ///
  /// In en, this message translates to:
  /// **'Pairing Code'**
  String get syncPairingCodeLabel;

  /// Status when host is listening
  ///
  /// In en, this message translates to:
  /// **'Waiting for incoming connection...'**
  String get syncStatusListening;

  /// Status when peer is authenticated
  ///
  /// In en, this message translates to:
  /// **'Device connected & authenticated'**
  String get syncStatusConnected;

  /// Status when sync succeeds
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully!'**
  String get syncStatusCompleted;

  /// Status when authentication fails
  ///
  /// In en, this message translates to:
  /// **'Connection rejected: incorrect pairing code'**
  String get syncStatusDenied;

  /// Status when host is stopped
  ///
  /// In en, this message translates to:
  /// **'Sync server stopped'**
  String get syncStatusStopped;

  /// Status when sync hits an error
  ///
  /// In en, this message translates to:
  /// **'Sync server error'**
  String get syncStatusError;

  /// Button to start sync host
  ///
  /// In en, this message translates to:
  /// **'Start Server'**
  String get syncButtonStart;

  /// Button to stop sync host
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get syncButtonStop;

  /// Button to start client sync
  ///
  /// In en, this message translates to:
  /// **'Connect & Sync'**
  String get syncButtonConnect;

  /// Instructions shown above camera viewfinder
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the pairing QR code on the sending device'**
  String get syncScanInstructions;

  /// Hint text for IP input field
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.5'**
  String get syncHostAddressHint;

  /// Hint text for port input field
  ///
  /// In en, this message translates to:
  /// **'e.g. 54321'**
  String get syncPortHint;

  /// Hint text for pairing code input field
  ///
  /// In en, this message translates to:
  /// **'16-character pairing code'**
  String get syncCodeHint;

  /// Warning when no local IP is available
  ///
  /// In en, this message translates to:
  /// **'No Wi-Fi / LAN IP detected. Make sure both devices are on the same Wi-Fi network or hotspot.'**
  String get syncNoWifiAlert;

  /// Snackbar message when pairing code is copied
  ///
  /// In en, this message translates to:
  /// **'Pairing code copied to clipboard'**
  String get syncPairingCodeCopied;

  /// Title for optical air-gap sync
  ///
  /// In en, this message translates to:
  /// **'Optical Air-Gap Sync (AirQR)'**
  String get airqrTitle;

  /// Intro description for AirQR optical sync
  ///
  /// In en, this message translates to:
  /// **'Synchronize settings, small journals, and entries over light using animated QR codes without network connections.'**
  String get airqrIntro;

  /// Title for AirQR send screen
  ///
  /// In en, this message translates to:
  /// **'Send via AirQR'**
  String get airqrSendTitle;

  /// Title for AirQR receive screen
  ///
  /// In en, this message translates to:
  /// **'Receive via AirQR'**
  String get airqrReceiveTitle;

  /// Title for receive action card
  ///
  /// In en, this message translates to:
  /// **'Receive Data (Scanner)'**
  String get airqrReceive;

  /// Subtitle for receive action card
  ///
  /// In en, this message translates to:
  /// **'Scan animated QR frames from another device'**
  String get airqrReceiveSubtitle;

  /// Title for sync settings action
  ///
  /// In en, this message translates to:
  /// **'Sync App Settings'**
  String get airqrSyncSettingsTitle;

  /// Subtitle for sync settings action
  ///
  /// In en, this message translates to:
  /// **'Theme, accent color, security, ritual & templates (< 1 sec)'**
  String get airqrSyncSettingsSubtitle;

  /// Title for sync journal action
  ///
  /// In en, this message translates to:
  /// **'Sync Single Journal'**
  String get airqrSyncJournalTitle;

  /// Subtitle for sync journal action
  ///
  /// In en, this message translates to:
  /// **'Select and stream a journal with text entries'**
  String get airqrSyncJournalSubtitle;

  /// Title for too large dialog
  ///
  /// In en, this message translates to:
  /// **'Payload Too Large'**
  String get airqrTooLargeTitle;

  /// Title for warning dialog on large optical transfer
  ///
  /// In en, this message translates to:
  /// **'Large Optical Transfer'**
  String get airqrSlowTitle;

  /// Button to proceed with optical transfer
  ///
  /// In en, this message translates to:
  /// **'Send Anyway'**
  String get airqrSendAnyway;

  /// Title for AirQR speed note
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private'**
  String get airqrSpeedNoteTitle;

  /// Body for AirQR speed note
  ///
  /// In en, this message translates to:
  /// **'AirQR works purely via camera and screen. No Wi-Fi, hotspot, Bluetooth, or internet required.'**
  String get airqrSpeedNoteBody;

  /// Action menu item to seal an entry as a time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal as Time Capsule'**
  String get timeCapsuleActionSeal;

  /// Title of dialog to seal an entry as a time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal as Time Capsule'**
  String get timeCapsuleSealTitle;

  /// Description of cryptographic time capsule seal
  ///
  /// In en, this message translates to:
  /// **'Cryptographically seals this entry until a future date. The decryption key will not be released until that date arrives.'**
  String get timeCapsuleSealDescription;

  /// Label for the unlock date field
  ///
  /// In en, this message translates to:
  /// **'Unlock Date'**
  String get timeCapsuleUnlockDateLabel;

  /// Hint text for optional teaser note to future self
  ///
  /// In en, this message translates to:
  /// **'Note to future self (optional teaser)'**
  String get timeCapsuleTeaserHint;

  /// Preset button for 1 month in the future
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get timeCapsulePreset1Month;

  /// Preset button for 6 months in the future
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get timeCapsulePreset6Months;

  /// Preset button for 1 year in the future
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get timeCapsulePreset1Year;

  /// Preset button for 3 years in the future
  ///
  /// In en, this message translates to:
  /// **'3 Years'**
  String get timeCapsulePreset3Years;

  /// Preset button for 5 years in the future
  ///
  /// In en, this message translates to:
  /// **'5 Years'**
  String get timeCapsulePreset5Years;

  /// Preset button for custom date
  ///
  /// In en, this message translates to:
  /// **'Custom Date'**
  String get timeCapsulePresetCustom;

  /// Button to confirm sealing the time capsule
  ///
  /// In en, this message translates to:
  /// **'Seal Capsule'**
  String get timeCapsuleSealConfirm;

  /// Badge label indicating a sealed time capsule
  ///
  /// In en, this message translates to:
  /// **'Sealed Time Capsule'**
  String get timeCapsuleSealedBadge;

  /// Status showing the unlock date
  ///
  /// In en, this message translates to:
  /// **'Sealed until {date}'**
  String timeCapsuleSealedUntil(String date);

  /// Status showing days remaining until unlock
  ///
  /// In en, this message translates to:
  /// **'Opens in {days} days'**
  String timeCapsuleOpensInDays(int days);

  /// Status showing hours remaining until unlock
  ///
  /// In en, this message translates to:
  /// **'Opens in {hours} hours'**
  String timeCapsuleOpensInHours(int hours);

  /// Status when capsule unlock date is today
  ///
  /// In en, this message translates to:
  /// **'Opens today!'**
  String get timeCapsuleOpensToday;

  /// Status badge when a time capsule has arrived at its unlock date
  ///
  /// In en, this message translates to:
  /// **'Ready to Open'**
  String get timeCapsuleReadyToOpen;

  /// Detailed explanation of cryptographic seal
  ///
  /// In en, this message translates to:
  /// **'This entry is cryptographically sealed under AES-256-GCM. The app\'s date-gated vault engine will not release the decryption key until the unlock date.'**
  String get timeCapsuleLockedExplanation;

  /// Button to unseal and restore the time capsule
  ///
  /// In en, this message translates to:
  /// **'Unseal Time Capsule'**
  String get timeCapsuleUnsealButton;

  /// Button text when unseal is locked
  ///
  /// In en, this message translates to:
  /// **'Locked until {date}'**
  String timeCapsuleUnsealLockedPrompt(String date);

  /// Snackbar notification after sealing entry
  ///
  /// In en, this message translates to:
  /// **'Entry sealed into a time capsule until {date}.'**
  String timeCapsuleSealedSuccess(String date);

  /// Snackbar notification after unsealing entry
  ///
  /// In en, this message translates to:
  /// **'Time capsule successfully unsealed! Welcome back to your words.'**
  String get timeCapsuleUnsealedSuccess;

  /// Error message when device clock was rolled backwards
  ///
  /// In en, this message translates to:
  /// **'Device clock rollback detected. The capsule cannot be unlocked while the device time is behind the recorded seal timestamp.'**
  String get timeCapsuleClockTamperError;

  /// Screen title for Time Capsules
  ///
  /// In en, this message translates to:
  /// **'Time Capsules'**
  String get timeCapsuleTitle;

  /// Subtitle describing Time Capsules
  ///
  /// In en, this message translates to:
  /// **'Letters and entries sealed for your future self'**
  String get timeCapsuleSubtitle;

  /// Empty state message when no time capsules exist
  ///
  /// In en, this message translates to:
  /// **'No time capsules yet. Create an entry and seal it for your future self.'**
  String get timeCapsuleEmptyState;

  /// Banner title when time capsules are ready to open
  ///
  /// In en, this message translates to:
  /// **'Time Capsule Ready!'**
  String get timeCapsuleBannerTitle;

  /// Banner body for 1 ready capsule
  ///
  /// In en, this message translates to:
  /// **'You have {count} sealed capsule ready to open today.'**
  String timeCapsuleBannerBody(int count);

  /// Banner body for multiple ready capsules
  ///
  /// In en, this message translates to:
  /// **'You have {count} sealed capsules ready to open today.'**
  String timeCapsuleBannerBodyPlural(int count);

  /// Header for sealed capsules
  ///
  /// In en, this message translates to:
  /// **'Sealed Capsules'**
  String get timeCapsuleCategorySealed;

  /// Header for ready capsules
  ///
  /// In en, this message translates to:
  /// **'Ready to Open'**
  String get timeCapsuleCategoryReady;

  /// Header for opened capsules
  ///
  /// In en, this message translates to:
  /// **'Opened Capsules'**
  String get timeCapsuleCategoryOpened;

  /// Title of the create ritual card screen
  ///
  /// In en, this message translates to:
  /// **'Create Card'**
  String get ritualCreateCardTitle;

  /// Title of the edit ritual card screen
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get ritualEditCardTitle;

  /// FAB label on deck screen to create a new card
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get ritualCreateCardButton;

  /// Label for the theme picker in card creation
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get ritualCardThemeLabel;

  /// Label for the card title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ritualCardTitleLabel;

  /// Hint text for card title
  ///
  /// In en, this message translates to:
  /// **'e.g. The Light of Self-Knowledge'**
  String get ritualCardTitleHint;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'A title is required.'**
  String get ritualCardTitleRequired;

  /// Label for the card prompt or reflection question
  ///
  /// In en, this message translates to:
  /// **'Reflection Question'**
  String get ritualCardPromptLabel;

  /// Hint text for card prompt
  ///
  /// In en, this message translates to:
  /// **'A question to reflect upon during practice...'**
  String get ritualCardPromptHint;

  /// Validation message when prompt is empty
  ///
  /// In en, this message translates to:
  /// **'A reflection question is required.'**
  String get ritualCardPromptRequired;

  /// Label for the card quote or teaching
  ///
  /// In en, this message translates to:
  /// **'Teaching or Quote'**
  String get ritualCardQuoteLabel;

  /// Hint text for card quote
  ///
  /// In en, this message translates to:
  /// **'A verse, shloka, or teaching...'**
  String get ritualCardQuoteHint;

  /// Validation message when quote is empty
  ///
  /// In en, this message translates to:
  /// **'A teaching or quote is required.'**
  String get ritualCardQuoteRequired;

  /// Label for the card author or source field
  ///
  /// In en, this message translates to:
  /// **'Source (optional)'**
  String get ritualCardAuthorLabel;

  /// Hint text for card author or source
  ///
  /// In en, this message translates to:
  /// **'e.g. Bhagavad Gita 2.47'**
  String get ritualCardAuthorHint;

  /// Label above the card preview in create or edit screen
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get ritualCardPreviewLabel;

  /// Button text to save a new card
  ///
  /// In en, this message translates to:
  /// **'Create Card'**
  String get ritualSaveCardCreate;

  /// Button text to save edits to an existing card
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get ritualSaveCardEdit;

  /// Snackbar after creating a card
  ///
  /// In en, this message translates to:
  /// **'Card created.'**
  String get ritualCardCreatedMessage;

  /// Snackbar after editing a card
  ///
  /// In en, this message translates to:
  /// **'Card updated.'**
  String get ritualCardUpdatedMessage;

  /// Snackbar when card save fails
  ///
  /// In en, this message translates to:
  /// **'Could not save the card. Please try again.'**
  String get ritualCardSaveError;

  /// Badge text on user-created cards in the deck
  ///
  /// In en, this message translates to:
  /// **'MY CARD'**
  String get ritualUserCardBadge;

  /// Menu item to edit a user card
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get ritualEditCardAction;

  /// Menu item or button to delete a user card
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ritualDeleteCardAction;

  /// Title of the delete card confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get ritualDeleteCardTitle;

  /// Body of the delete card confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String ritualDeleteCardConfirm(String title);

  /// Snackbar after deleting a card
  ///
  /// In en, this message translates to:
  /// **'Card deleted.'**
  String get ritualCardDeletedMessage;

  /// Error shown when no journal exists to write a ritual entry into
  ///
  /// In en, this message translates to:
  /// **'Please create a journal first.'**
  String get ritualNoJournalError;
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
      <String>['en', 'ml'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
