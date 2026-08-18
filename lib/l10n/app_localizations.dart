import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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

  /// Button that closes a dialog or panel
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

  /// Sync state: a sync is running now
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
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

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsSectionStorage;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsSectionPermissions;

  /// Settings section heading
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
