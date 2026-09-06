// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get vaultUnavailableTitle => 'വോൾട്ട് തുറക്കാൻ കഴിയില്ല';

  @override
  String get vaultUnavailableKeyMissing =>
      'നിങ്ങളുടെ ജേണൽ അൺലോക്ക് ചെയ്യുന്ന കീ ഈ ഉപകരണത്തിൽ ലഭ്യമല്ല. അതില്ലാതെ വോൾട്ട് തുറക്കാൻ കഴിയില്ല.';

  @override
  String get vaultUnavailableCipherMissing =>
      'ഈ ആപ്പ് ബിൽഡിന് വോൾട്ട് എൻക്രിപ്റ്റ് ചെയ്യാൻ കഴിയില്ല, അതിനാൽ സുരക്ഷിതമല്ലാത്ത ജേണൽ തുറക്കാതിരിക്കാൻ പ്രവർത്തനം നിർത്തിവെച്ചു.';

  @override
  String get vaultUnavailableConversionFailed =>
      'നിങ്ങളുടെ ജേണൽ എൻക്രിപ്റ്റ് ചെയ്ത സംഭരണത്തിലേക്ക് മാറ്റാൻ കഴിഞ്ഞില്ല. മാറ്റങ്ങളൊന്നും വരുത്തിയിട്ടില്ല — ഡാറ്റയൊന്നും നഷ്ടപ്പെട്ടിട്ടില്ല.';

  @override
  String get vaultUnavailableFileUnreadable =>
      'വോൾട്ട് ഫയൽ വായിക്കാൻ കഴിയില്ല. ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചിരിക്കാം അല്ലെങ്കിൽ മറ്റ് ഇൻസ്റ്റാളേഷന്റേതായിരിക്കാം.';

  @override
  String get vaultUnavailableDataIntact =>
      'ഡാറ്റയൊന്നും നഷ്ടപ്പെട്ടിട്ടില്ല. നിങ്ങളുടെ കുറിപ്പുകളും അറ്റാച്ച്മെന്റുകളും ഉപകരണത്തിൽ സുരക്ഷിതമാണ്.';

  @override
  String get vaultUnavailableNextSteps =>
      'ബാക്കപ്പ് ഫയൽ ഉണ്ടെങ്കിൽ, ആപ്പ് വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്ത് പുനഃസ്ഥാപിക്കുക. ഡാറ്റ ക്ലിയർ ചെയ്യരുത് — അത് വോൾട്ട് പൂർണ്ണമായി നഷ്ടപ്പെടുത്തും.';

  @override
  String get appTitle => 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്';

  @override
  String get aboutTitle => 'വിവരങ്ങൾ';

  @override
  String get aboutLoadError => 'ആപ്പ് വിവരങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get commonRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get aboutVersionBuildLabel => 'ആപ്പ് പതിപ്പ് / ബിൽഡ്';

  @override
  String get aboutLastBuildLabel => 'അവസാന ബിൽഡ് സമയം';

  @override
  String get permissionsTitle => 'അനുമതികൾ';

  @override
  String get permissionsExplicitHeader => 'പ്രത്യേക അനുമതികൾ';

  @override
  String get permissionsImplicitHeader => 'സാധാരണ അനുമതികൾ';

  @override
  String get permissionStatusAllowed => 'അനുവദിച്ചു';

  @override
  String get permissionStatusDenied => 'നിരസിച്ചു';

  @override
  String get permissionStatusPermanentlyDenied => 'സ്ഥിരമായി നിരസിച്ചു';

  @override
  String get permissionStatusUserSelected => 'ഉപയോക്താവ് തിരഞ്ഞെടുത്തത്';

  @override
  String get permissionsRequest => 'അഭ്യർത്ഥിക്കുക';

  @override
  String get permissionsOpenSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get commonCancel => 'റദ്ദാക്കുക';

  @override
  String get commonDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get commonSave => 'സേവ് ചെയ്യുക';

  @override
  String get tagsTitle => 'ടാഗുകൾ';

  @override
  String tagsLoadError(String error) {
    return 'ടാഗുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get tagsEmpty => 'ടാഗുകളൊന്നും ലഭ്യമല്ല';

  @override
  String get tagsAutomaticColour => 'സ്വയമേവയുള്ള നിറം';

  @override
  String get tagsActionsTooltip => 'ടാഗ് പ്രവർത്തനങ്ങൾ';

  @override
  String get tagsRename => 'പേര് മാറ്റുക';

  @override
  String get tagsChooseColour => 'നിറം തിരഞ്ഞെടുക്കുക';

  @override
  String get tagsResetColour => 'സ്വയമേവയുള്ള നിറത്തിലേക്ക് പുനഃക്രമീകരിക്കുക';

  @override
  String get tagsRenameFailed =>
      'നൽകിയ പേര് ശൂന്യമാണ് അല്ലെങ്കിൽ മറ്റൊരു ടാഗ് നിലവിലുണ്ട്.';

  @override
  String tagsDeleted(String name) {
    return '#$name ഇല്ലാതാക്കി.';
  }

  @override
  String get tagsDeleteTitle => 'ടാഗ് ഇല്ലാതാക്കണോ?';

  @override
  String tagsDeleteBody(String name) {
    return '\"#$name\" ഇല്ലാതാക്കണോ? ഇത് ഉപയോഗിക്കുന്ന എല്ലാ ജേണലുകളിൽ നിന്നും കുറിപ്പുകളിൽ നിന്നും നീക്കം ചെയ്യപ്പെടും.';
  }

  @override
  String get tagsRenameTitle => 'ടാഗ് പേര് മാറ്റുക';

  @override
  String get tagsNameLabel => 'ടാഗ് പേര്';

  @override
  String commonError(String message) {
    return 'പിശക്: $message';
  }

  @override
  String get commonUntitledEntry => 'തലക്കെട്ടില്ലാത്ത കുറിപ്പ്';

  @override
  String get commonUntitled => 'തലക്കെട്ടില്ലാത്തത്';

  @override
  String get timelineTitle => 'ടൈംലൈൻ';

  @override
  String get timelineNoEntriesForDate =>
      'തിരഞ്ഞെടുത്ത തീയതിയിൽ കുറിപ്പുകളൊന്നുമില്ല.';

  @override
  String get timelineCalendarFormatMonth => 'മാസം';

  @override
  String get timelineDayCountOverflow => '9+';

  @override
  String get insightsTitle => 'സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get insightsStreakHeading => 'എഴുത്ത് തുടർച്ച (Streak)';

  @override
  String get insightsStreakCurrent => 'നിലവിലെ';

  @override
  String get insightsStreakLongest => 'മികച്ച';

  @override
  String get insightsStreakUnitDays => 'ദിവസങ്ങൾ';

  @override
  String insightsStreakStat(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String insightsLastEntry(String date) {
    return 'അവസാന കുറിപ്പ്: $date';
  }

  @override
  String get insightsMoodHeading => 'വികാര പ്രവണതകൾ (കഴിഞ്ഞ 30 ദിവസം)';

  @override
  String get insightsMoodEmpty =>
      'വികാര വിവരങ്ങൾ ലഭ്യമല്ല.\nപ്രവണതകൾ കാണാൻ കുറിപ്പുകളിൽ വികാരം രേഖപ്പെടുത്തുക.';

  @override
  String insightsMoodTooltip(String date, String mood, int count) {
    return '$date\nവികാരം: $mood\nകുറിപ്പുകൾ: $count';
  }

  @override
  String get insightsTagHeatmapHeading => 'ടാഗ് ഹീറ്റ്മാപ്പ്';

  @override
  String get insightsTagHeatmapEmpty =>
      'ഇതുവരെ ടാഗുകളൊന്നും ഉപയോഗിച്ചിട്ടില്ല.';

  @override
  String insightsTagChip(String tag, int count) {
    return '$tag ($count)';
  }

  @override
  String get insightsMemoriesHeading => 'ഈ ദിവസം ഓർമ്മകളിൽ';

  @override
  String get insightsMemoriesEmpty =>
      'മുൻ വർഷങ്ങളിൽ ഈ തീയതിയിൽ കുറിപ്പുകളൊന്നുമില്ല.';

  @override
  String insightsYearsAgo(int years) {
    return '${years}y';
  }

  @override
  String get insightsReflectionHeading => 'പ്രതിവാര അവലോകനം';

  @override
  String get insightsReflectionPeriod => 'കാലയളവ്';

  @override
  String get insightsReflectionEntries => 'കുറിപ്പുകൾ';

  @override
  String get insightsReflectionWords => 'എഴുതിയ വാക്കുകൾ';

  @override
  String get insightsReflectionAverageMood => 'ശരാശരി വികാരം';

  @override
  String get insightsReflectionTopTags => 'പ്രധാന ടാഗുകൾ';

  @override
  String get insightsReflectionStreak => 'നിലവിലെ സ്ട്രീക്ക്';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസങ്ങൾ',
      one: '1 ദിവസം',
    );
    return '$_temp0';
  }

  @override
  String get commonClose => 'അടയ്ക്കുക';

  @override
  String get commonUnknownError => 'അജ്ഞാതമായ പിശക് സംഭവിച്ചു.';

  @override
  String get importTitle => 'ഇംപോർട്ട്';

  @override
  String get importSelecting => 'ഫയലുകൾ തിരഞ്ഞെടുക്കുന്നു...';

  @override
  String get importSelectFiles => 'ഫയലുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get importResultsHeading => 'ഇംപോർട്ട് ഫലങ്ങൾ';

  @override
  String get importFileSucceeded => 'വിജയകരമായി ഇംപോർട്ട് ചെയ്തു';

  @override
  String importCountSucceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഫയലുകൾ വിജയകരമായി ഇംപോർട്ട് ചെയ്തു',
      one: '1 ഫയൽ വിജയകരമായി ഇംപോർട്ട് ചെയ്തു',
    );
    return '$_temp0';
  }

  @override
  String get attachmentArchiveEmpty => 'ഈ ആർക്കൈവിൽ ഫയലുകളൊന്നുമില്ല.';

  @override
  String get attachmentOpenWith => 'മറ്റൊരു ആപ്പിൽ തുറക്കുക...';

  @override
  String get attachmentUnsupportedTitle => 'പിന്തുണയ്ക്കാത്ത ഫയൽ തരം';

  @override
  String attachmentUnsupportedBody(String fileName) {
    return '$fileName ആപ്പിനുള്ളിൽ നേരിട്ട് കാണിക്കാൻ കഴിയില്ല.';
  }

  @override
  String get attachmentPdfMissing => 'ഡീക്രിപ്റ്റ് ചെയ്ത ഫയൽ ഇപ്പോൾ ലഭ്യമല്ല.';

  @override
  String attachmentPdfOpenFailed(String reason) {
    return 'പി.ഡി.എഫ്. തുറക്കാൻ കഴിഞ്ഞില്ല: $reason';
  }

  @override
  String get autoLockTitle => 'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകൾ';

  @override
  String get autoLockNewProfile => 'പുതിയ പ്രൊഫൈൽ';

  @override
  String get autoLockEditProfile => 'പ്രൊഫൈൽ തിരുത്തുക';

  @override
  String get autoLockEmpty =>
      'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകളൊന്നും നിലവിലില്ല. നിഷ്ക്രിയമാകുമ്പോൾ ആപ്പ് ലോക്കാകാൻ ഒരെണ്ണം സൃഷ്ടിക്കുക.';

  @override
  String get autoLockDeleteProfile => 'പ്രൊഫൈൽ ഇല്ലാതാക്കുക';

  @override
  String get autoLockActivate => 'സജീവമാക്കുക';

  @override
  String get autoLockDeactivate => 'പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String autoLockSummary(String timeout, String lockOnMinimize, String active) {
    return '$timeout$lockOnMinimize$active';
  }

  @override
  String get autoLockSuffixLockOnMinimize =>
      ' • മിനിമൈസ് ചെയ്യുമ്പോൾ ലോക്കാക്കുക';

  @override
  String get autoLockSuffixActive => ' • സജീവം';

  @override
  String autoLockTimeoutSeconds(int seconds) {
    return '$seconds സെക്കൻഡ്';
  }

  @override
  String autoLockTimeoutMinutes(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String autoLockTimeoutHours(String hours) {
    return '$hours മണിക്കൂർ';
  }

  @override
  String get autoLockNameLabel => 'പ്രൊഫൈൽ പേര്';

  @override
  String get autoLockTimeoutLabel => 'സമയപരിധി';

  @override
  String get autoLockLockOnMinimize => 'മിനിമൈസ് ചെയ്യുമ്പോൾ ഉടൻ ലോക്കാക്കുക';

  @override
  String get autoLockNameRequired => 'പ്രൊഫൈൽ പേര് നൽകുക.';

  @override
  String get autoLockTimeoutInvalid => 'സമയപരിധി പോസിറ്റീവ് സംഖ്യയായിരിക്കണം.';

  @override
  String get securityEventsTitle => 'സുരക്ഷാ ഇവന്റുകൾ';

  @override
  String get securityEventsEmpty =>
      'സുരക്ഷാ ഇവന്റുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.';

  @override
  String get securityEventDetailsTitle => 'സുരക്ഷാ ഇവന്റ് വിവരങ്ങൾ';

  @override
  String get syncConflictsTitle => 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ';

  @override
  String syncConflictsLoadFailed(String error) {
    return 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get syncNoConflicts => 'സിങ്ക് വൈരുദ്ധ്യങ്ങളൊന്നുമില്ല.';

  @override
  String get syncAllInSync => 'എല്ലാ ഡാറ്റയും സമന്വയിപ്പിച്ചിരിക്കുന്നു.';

  @override
  String syncDetectedAt(String timestamp) {
    return 'Detected: $timestamp';
  }

  @override
  String get syncChangedFields => 'Changed fields:';

  @override
  String get syncCompare => 'താരതമ്യം ചെയ്യുക';

  @override
  String get syncKeepRemote => 'റിമോട്ട് പതിപ്പ് സൂക്ഷിക്കുക';

  @override
  String get syncKeepLocal => 'ലോക്കൽ പതിപ്പ് സൂക്ഷിക്കുക';

  @override
  String get syncKeepLocalTitle => 'ലോക്കൽ പതിപ്പ് നിലനിർത്തണോ?';

  @override
  String get syncKeepRemoteTitle => 'റിമോട്ട് പതിപ്പ് നിലനിർത്തണോ?';

  @override
  String get syncKeepLocalBody =>
      'റിമോട്ട് മാറ്റങ്ങൾ ഒഴിവാക്കപ്പെടും. അടുത്ത സിങ്കിൽ ഈ ഉപകരണത്തിലെ പതിപ്പ് കൈമാറും.';

  @override
  String get syncKeepRemoteBody =>
      'ഈ ഉപകരണത്തിലെ മാറ്റങ്ങൾ മാറ്റിസ്ഥാപിക്കപ്പെട്ട് റിമോട്ട് പതിപ്പ് സ്വീകരിക്കും.';

  @override
  String get commonConfirm => 'സ്ഥിരീകരിക്കുക';

  @override
  String get syncConflictResolved => 'വൈരുദ്ധ്യം പരിഹരിച്ചു';

  @override
  String syncResolutionFailed(String error) {
    return 'വൈരുദ്ധ്യം പരിഹരിക്കാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get syncConflictDetailsTitle => 'വൈരുദ്ധ്യ വിവരങ്ങൾ';

  @override
  String get syncColumnField => 'ഫീൽഡ്';

  @override
  String get syncColumnLocal => 'ലോക്കൽ';

  @override
  String get syncColumnRemote => 'റിമോട്ട്';

  @override
  String get syncHealthHeading => 'സിങ്ക് ആരോഗ്യം';

  @override
  String get syncLastSync => 'അവസാന സിങ്ക്';

  @override
  String get syncFailures7d => 'പരാജയങ്ങൾ (7 ദിവസത്തിൽ)';

  @override
  String get syncPendingConflicts => 'തീർപ്പുകൽപ്പിക്കാത്ത വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get commonLoading => 'ലോഡ് ചെയ്യുന്നു...';

  @override
  String get commonErrorShort => 'പിശക്';

  @override
  String get commonEllipsis => '...';

  @override
  String get syncNever => 'ഒരിക്കലുമില്ല';

  @override
  String syncResolveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വൈരുദ്ധ്യങ്ങൾ പരിഹരിച്ചു',
      one: '1 വൈരുദ്ധ്യം പരിഹരിച്ചു',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'ഇപ്പോൾ സമന്വയിപ്പിക്കുക';

  @override
  String get syncRecentActivity => 'സമീപകാല പ്രവർത്തനം';

  @override
  String syncLogsLoadFailed(String error) {
    return 'ലോഗുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get syncNoActivity => 'സമന്വയ പ്രവർത്തനങ്ങളൊന്നുമില്ല.';

  @override
  String get syncStatusIdle => 'സമന്വയം സജ്ജമാണ്';

  @override
  String get syncStatusSyncing => 'മാറ്റങ്ങൾ കൈമാറുന്നു...';

  @override
  String get syncStatusHealthy => 'ആരോഗ്യം';

  @override
  String get syncStatusFailed => 'Failed';

  @override
  String get syncStatusConflicts => 'വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get syncLogFailed => 'സമന്വയം പരാജയപ്പെട്ടു';

  @override
  String syncLogPushed(int count) {
    return '$count അയച്ചു';
  }

  @override
  String syncLogPulled(int count) {
    return '$count സ്വീകരിച്ചു';
  }

  @override
  String syncLogConflicts(int count) {
    return '$count വൈരുദ്ധ്യങ്ങൾ';
  }

  @override
  String get syncLogNoChanges => 'മാറ്റങ്ങളൊന്നുമില്ല';

  @override
  String get commonRefresh => 'പുതുക്കുക';

  @override
  String get backupTitle => 'ബാക്കപ്പും പുനഃസ്ഥാപിക്കലും';

  @override
  String get backupNow => 'ഇപ്പോൾ ബാക്കപ്പ് എടുക്കുക';

  @override
  String get backupInProgressLabel => 'ബാക്കപ്പ് ഫയൽ തയ്യാറാക്കുന്നു...';

  @override
  String get backupHistoryHeading => 'ബാക്കപ്പ് ചരിത്രം';

  @override
  String get backupStatusHeading => 'ബാക്കപ്പ് നില';

  @override
  String get backupNoneYet => 'ഇതുവരെ ബാക്കപ്പുകളൊന്നും എടുത്തിട്ടില്ല.';

  @override
  String get backupLastBackup => 'അവസാന ബാക്കപ്പ്';

  @override
  String get backupEntries => 'കുറിപ്പുകൾ';

  @override
  String get backupAttachments => 'അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get backupSize => 'വലിപ്പം';

  @override
  String backupRecentFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'കഴിഞ്ഞ 7 ദിവസത്തിൽ $count പരാജയപ്പെട്ട ബാക്കപ്പുകൾ',
      one: 'കഴിഞ്ഞ 7 ദിവസത്തിൽ 1 പരാജയപ്പെട്ട ബാക്കപ്പ്',
    );
    return '$_temp0';
  }

  @override
  String get backupScheduleHeading => 'ഓട്ടോമാറ്റിക് ബാക്കപ്പ് ഓർമ്മപ്പെടുത്തൽ';

  @override
  String backupScheduled(String interval) {
    return 'ഷെഡ്യൂൾ ചെയ്തത്: $interval';
  }

  @override
  String get backupNotScheduled => 'ഷെഡ്യൂൾ ചെയ്തിട്ടില്ല';

  @override
  String get backupTimerActive => 'സജീവം';

  @override
  String get backupTimerInactive => 'നിഷ്ക്രിയം';

  @override
  String get backupLastScheduledRun => 'അവസാനം പ്രവർത്തിച്ച സമയം';

  @override
  String get backupDisable => 'പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get backupConfigure => 'ക്രമീകരിക്കുക';

  @override
  String get backupChange => 'മാറ്റുക';

  @override
  String get backupConfigureHeading => 'ഷെഡ്യൂൾ ക്രമീകരിക്കുക';

  @override
  String get backupIntervalLabel => 'ഇടവേള';

  @override
  String get backupIntervalDaily => 'ദിവസേന';

  @override
  String get backupIntervalWeekly => 'ആഴ്ചയിലൊരിക്കൽ';

  @override
  String get backupIntervalMonthly => 'മാസത്തിലൊരിക്കൽ';

  @override
  String get backupPasswordLabel => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get backupPasswordHelper =>
      'ബാക്കപ്പ് എൻക്രിപ്റ്റ് ചെയ്യാൻ ശക്തമായ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get backupNoHistory => 'ബാക്കപ്പ് ചരിത്രമില്ല';

  @override
  String backupHistoryLoadFailed(String error) {
    return 'ചരിത്രം ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String backupLogTitle(String trigger, String status) {
    return '$trigger ബാക്കപ്പ് — $status';
  }

  @override
  String get backupTriggerManual => 'സ്വയം ചെയ്തത്';

  @override
  String get backupTriggerScheduled => 'ഷെഡ്യൂൾ ചെയ്തത്';

  @override
  String get backupStatusSuccess => 'വിജയം';

  @override
  String get backupStatusFailed => 'പരാജയം';

  @override
  String get backupStatusInProgress => 'നടക്കുന്നു';

  @override
  String backupLogCounts(int entries, int attachments, String size) {
    return '$entries കുറിപ്പുകൾ, $attachments അറ്റാച്ച്മെന്റുകൾ, $size';
  }

  @override
  String get backupInProgressNote => 'പ്രക്രിയ നടക്കുന്നു...';

  @override
  String get backupSucceeded => 'ബാക്കപ്പ് വിജയകരമായി പൂർത്തിയായി';

  @override
  String backupFailed(String error) {
    return 'ബാക്കപ്പ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get backupPasswordTitle => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get backupPasswordEnter => 'എൻക്രിപ്ഷൻ പാസ്‌വേഡ് നൽകുക';

  @override
  String get backupAction => 'ബാക്കപ്പ്';

  @override
  String get backupPasswordRequired => 'പാസ്‌വേഡ് നൽകേണ്ടത് നിർബന്ധമാണ്';

  @override
  String get backupScheduleSaved => 'ബാക്കപ്പ് ഷെഡ്യൂൾ സേവ് ചെയ്തു';

  @override
  String get backupScheduleDisabled => 'ബാക്കപ്പ് ഷെഡ്യൂൾ പ്രവർത്തനരഹിതമാക്കി';

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
  String get commonRestore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get commonInsert => 'ചേർക്കുക';

  @override
  String get commonContinue => 'തുടരുക';

  @override
  String get commonOpenSystemSettings => 'സിസ്റ്റം ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get editorCalloutHint => 'കോൾഔട്ട് വിവരണം ഇവിടെ എഴുതുക...';

  @override
  String get editorInsertTab => 'Insert tab';

  @override
  String get editorInsertTable => 'പട്ടിക ചേർക്കുക';

  @override
  String get editorInsertCallout => 'കോൾഔട്ട് ചേർക്കുക';

  @override
  String get editorInsertImage => 'ചിത്രം ചേർക്കുക';

  @override
  String get editorImageSize => 'ചിത്രത്തിന്റെ വലിപ്പം';

  @override
  String get editorImageSizeSmall => 'ചെറുത്';

  @override
  String get editorImageSizeMedium => 'ഇടത്തരം';

  @override
  String get editorImageSizeFull => 'പൂർണ്ണ വീതി';

  @override
  String get editorRemoveImage => 'ചിത്രം നീക്കം ചെയ്യുക';

  @override
  String get editorImageUnavailable => 'ചിത്രം ലഭ്യമല്ല';

  @override
  String get editorMicPermissionDenied => 'മൈക്രോഫോൺ അനുമതി നിരസിച്ചു.';

  @override
  String get editorDiscard => 'മാറ്റങ്ങൾ ഒഴിവാക്കുക';

  @override
  String get editorDone => 'പൂർത്തിയായി';

  @override
  String get versionHistoryTitle => 'പതിപ്പ് ചരിത്രം (റിവിഷനുകൾ)';

  @override
  String versionHistoryLoadFailed(String error) {
    return 'പതിപ്പുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get versionRestoreTitle => 'ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കണോ?';

  @override
  String get versionRestored => 'പതിപ്പ് പുനഃസ്ഥാപിച്ചു';

  @override
  String get versionPreview => 'പ്രിവ്യൂ കാണുക';

  @override
  String get versionRestoreTooltip => 'ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കുക';

  @override
  String versionPreviewTitle(String title) {
    return 'പ്രിവ്യൂ: $title';
  }

  @override
  String get entrySaved => 'കുറിപ്പ് സേവ് ചെയ്തു';

  @override
  String get entryDeleteTitle => 'കുറിപ്പ് ഇല്ലാതാക്കണോ?';

  @override
  String get entryDeleteBody => 'This will permanently remove the entry.';

  @override
  String get entryTableRows => 'വരികൾ (1-20)';

  @override
  String get entryTableColumns => 'നിരകൾ (1-20)';

  @override
  String get entryTableDimensionHelp => '1-20';

  @override
  String get entryCalloutTypeTitle => 'കോൾഔട്ട് തരം';

  @override
  String get entryCalloutInfo => 'വിവരം (Info)';

  @override
  String get entryCalloutTip => 'സൂചന (Tip)';

  @override
  String get entryCalloutWarning => 'മുന്നറിയിപ്പ് (Warning)';

  @override
  String get entryCalloutImportant => 'പ്രധാനം (Important)';

  @override
  String entryVoiceNoteSaved(String seconds) {
    return 'വോയ്സ് നോട്ട് സേവ് ചെയ്തു ($seconds സെക്കൻഡ്)';
  }

  @override
  String get entryEditTitle => 'കുറിപ്പ് തിരുത്തുക';

  @override
  String get entryEditTitleDirty => 'കുറിപ്പ് തിരുത്തുക •';

  @override
  String get entryVersionHistoryTooltip => 'പതിപ്പ് ചരിത്രം';

  @override
  String get entryDeleteTooltip => 'കുറിപ്പ് ഇല്ലാതാക്കുക';

  @override
  String get entrySaveTooltip => 'സേവ് ചെയ്യുക';

  @override
  String get entryNoUnsavedChanges => 'സേവ് ചെയ്യാത്ത മാറ്റങ്ങളില്ല';

  @override
  String get entryTitleLabel => 'തലക്കെട്ട്';

  @override
  String get entryPermissionTitle => 'അറ്റാച്ച്മെന്റ് ചേർക്കാൻ അനുമതി നൽകണോ?';

  @override
  String get entryPermissionBody =>
      'ഫയലുകൾ ചേർക്കുന്നതിന് ഈ ആപ്പിന് അനുമതി ആവശ്യമാണ്.';

  @override
  String get entryPermissionBlockedTitle =>
      'അറ്റാച്ച്മെന്റ് അനുമതി തടഞ്ഞിരിക്കുന്നു';

  @override
  String get entryPermissionBlockedBody =>
      'അനുമതി സ്ഥിരമായി നിരസിച്ചിരിക്കുന്നു. സിസ്റ്റം ക്രമീകരണങ്ങളിൽ ഇത് ഓണാക്കുക.';

  @override
  String get entryNotAnImage =>
      'തിരഞ്ഞെടുത്ത ഫയൽ ഒരു ചിത്രമല്ല. അറ്റാച്ച്മെന്റായി ചേർക്കുക.';

  @override
  String get entryImageAddFailed => 'ചിത്രം ചേർക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get entryAddAttachment => 'അറ്റാച്ച്മെന്റ് ചേർക്കുക';

  @override
  String get entryRecordVoiceNote => 'വോയ്സ് നോട്ട് റെക്കോർഡ് ചെയ്യുക';

  @override
  String get entryLinkedFrom => 'ലിങ്ക് ചെയ്ത ഉറവിടം';

  @override
  String get entryMoodTooltip => 'Set mood';

  @override
  String get entryMood => 'വികാരം';

  @override
  String entryMoodChip(String face, int level) {
    return '$face $level';
  }

  @override
  String get entryAuthRequired => 'പ്രാമാണീകരണം ആവശ്യമാണ്.';

  @override
  String get attachmentOpenNoApp =>
      'ഈ ഫയൽ തുറക്കാൻ അനുയോജ്യമായ ആപ്പ് ഫോണിൽ ലഭ്യമല്ല.';

  @override
  String get attachmentOpenDecryptFailed =>
      'അറ്റാച്ച്മെന്റ് ഡീക്രിപ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get attachmentOpenFileMissing => 'അറ്റാച്ച്മെന്റ് ഫയൽ ലഭ്യമല്ല.';

  @override
  String get attachmentOpenPermissionDenied =>
      'ഫയൽ തുറക്കാൻ സംഭരണ അനുമതി ആവശ്യമാണ്.';

  @override
  String get entryAttachments => 'അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get entryRemoveAttachmentLock => 'അറ്റാച്ച്മെന്റ് ലോക്ക് മാറ്റുക';

  @override
  String get entryLockAttachment => 'അറ്റാച്ച്മെന്റ് ലോക്ക് ചെയ്യുക';

  @override
  String get entryOpenAttachment => 'അറ്റാച്ച്മെന്റ് തുറക്കുക';

  @override
  String get versionRestoreBody =>
      'നിലവിലെ കുറിപ്പ് പുതിയൊരു പതിപ്പായി സേവ് ചെയ്ത ശേഷമായിരിക്കും ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കുക.';

  @override
  String get commonUnlock => 'അൺലോക്ക്';

  @override
  String get commonPassword => 'പാസ്‌വേഡ്';

  @override
  String get commonSaving => 'സേവ് ചെയ്യുന്നു...';

  @override
  String get lockSetupTitle => 'ആപ്പ് സുരക്ഷ ക്രമീകരിക്കുക';

  @override
  String get lockSetupBody =>
      'നിങ്ങളുടെ ജേണൽ വോൾട്ട് എങ്ങനെ സംരക്ഷിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get lockModePhone => 'ഫോൺ ലോക്ക് (ബയോമെട്രിക്സ് / സിസ്റ്റം പാസ്‌വേഡ്)';

  @override
  String get lockModePhoneHint =>
      'ഫോണിലെ ഫിംഗർപ്രിന്റ്, ഫേസ് അൺലോക്ക് അല്ലെങ്കിൽ പാസ്‌കോഡ് ഉപയോഗിക്കുന്നു.';

  @override
  String get lockModeApp => 'പ്രത്യേക ആപ്പ് പിൻ';

  @override
  String get lockModeAppHint =>
      'ഫോൺ ലോക്കിൽ നിന്ന് വ്യത്യസ്തമായ പ്രത്യേക 4-6 അക്ക പിൻ സജ്ജീകരിക്കുക.';

  @override
  String get lockPinLabel => 'പിൻ';

  @override
  String get lockConfirmPinLabel => 'പിൻ സ്ഥിരീകരിക്കുക';

  @override
  String get lockSettingUp => 'ക്രമീകരിക്കുന്നു...';

  @override
  String get lockPinTooShort => 'പിന്നിൽ കുറഞ്ഞത് 4 അക്കങ്ങൾ വേണം.';

  @override
  String get lockPinsDoNotMatch => 'പിൻ പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String lockSetupSaveFailed(String error) {
    return 'ലോക്ക് ക്രമീകരണം സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String lockPinSaveFailed(String error) {
    return 'പിൻ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get lockPinSetupTitle => 'ആപ്പ്-ലോക്ക് പിൻ സജ്ജീകരിക്കുക';

  @override
  String get lockPinSetupBody =>
      'ആപ്പ് ലോക്കിനായി ഒരു പിൻ ആവശ്യമാണ്. തുടരാൻ ഒരെണ്ണം നൽകുക.';

  @override
  String get lockGateTitle => 'ആപ്പ് ലോക്ക് ഗേറ്റ്';

  @override
  String get lockGateHeadline => 'നിങ്ങളുടെ ജേണൽ ലോക്ക് ചെയ്തിരിക്കുന്നു';

  @override
  String get lockGateSubtitle => 'കുറിപ്പുകൾ കാണാൻ അൺലോക്ക് ചെയ്യുക.';

  @override
  String get lockGateShowPin => 'പിൻ കാണിക്കുക';

  @override
  String get lockGateHidePin => 'പിൻ മറയ്ക്കുക';

  @override
  String get lockGateBadgeSemantics => 'ലോക്ക് ചെയ്തത്';

  @override
  String get lockUnlockWithPhone => 'ഫോൺ ലോക്ക് ഉപയോഗിച്ച് അൺലോക്ക് ചെയ്യുക';

  @override
  String get lockAuthFailed =>
      'പ്രാമാണീകരണം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get lockAuthUnavailable =>
      'ഉപകരണ പ്രാമാണീകരണം ലഭ്യമല്ല. ഫോൺ ക്രമീകരണങ്ങളിൽ പിൻ അല്ലെങ്കിൽ ബയോമെട്രിക്സ് സജ്ജീകരിക്കുക.';

  @override
  String get lockEnterPin => 'നിങ്ങളുടെ ആപ്പ് പിൻ നൽകുക';

  @override
  String get lockIncorrectPin => 'തെറ്റായ പിൻ. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get lockedAttachmentsTitle => 'ലോക്ക് ചെയ്ത അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get lockedAttachmentsEmpty =>
      'ലോക്ക് ചെയ്ത അറ്റാച്ച്മെന്റുകളൊന്നുമില്ല.';

  @override
  String lockedAttachmentSince(String date) {
    return 'ലോക്ക് ചെയ്ത തീയതി: $date';
  }

  @override
  String get lockedAttachmentRemove => 'ലോക്ക് നീക്കം ചെയ്യുക';

  @override
  String get navHome => 'ഹോം';

  @override
  String get navSearch => 'തിരയുക';

  @override
  String get navTimeline => 'ടൈംലൈൻ';

  @override
  String get navInsights => 'സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get journalDeleteTitle => 'ജേണൽ ഇല്ലാതാക്കണോ?';

  @override
  String journalDeleteBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get journalManageTags => 'ടാഗുകൾ കൈകാര്യം ചെയ്യുക';

  @override
  String get journalNew => 'പുതിയ ജേണൽ';

  @override
  String get journalEdit => 'ജേണൽ തിരുത്തുക';

  @override
  String get journalDelete => 'ജേണൽ ഇല്ലാതാക്കുക';

  @override
  String get journalEmptyTitle => 'ഇതുവരെ ജേണലുകളൊന്നുമില്ല';

  @override
  String get journalEmptyBody => 'എഴുതിത്തുടങ്ങാൻ \"പുതിയ ജേണൽ\" അമർത്തുക.';

  @override
  String get journalTitleLabel => 'തലക്കെട്ട്';

  @override
  String get journalDescriptionLabel => 'വിവരണം';

  @override
  String get journalTagsLabel => 'ടാഗുകൾ (കോമ ഉപയോഗിച്ച് വേർതിരിക്കുക)';

  @override
  String get journalLockSwitch => 'ജേണൽ ലോക്ക് ചെയ്യുക';

  @override
  String get journalConfirmPasswordLabel => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get journalAddEntry => 'കുറിപ്പ് ചേർക്കുക';

  @override
  String get journalIsLocked => 'ജേണൽ ലോക്ക് ചെയ്തിരിക്കുന്നു';

  @override
  String get journalUnlocked => 'അൺലോക്ക് ചെയ്തു';

  @override
  String get journalIncorrectPassword => 'തെറ്റായ പാസ്‌വേഡ്.';

  @override
  String get settingsSectionSecurity => 'സുരക്ഷ';

  @override
  String get settingsSectionSecuritySubtitle =>
      'ലോക്ക് മോഡ്, ഓട്ടോ-ലോക്ക്, സ്ക്രീൻഷോട്ട് തടയൽ, സുരക്ഷാ ലോഗുകൾ';

  @override
  String get settingsSectionAppearance => 'രൂപഭംഗി';

  @override
  String get settingsSectionAppearanceSubtitle => 'തീം, ആപ്പിന്റെ കാഴ്ച രീതികൾ';

  @override
  String get settingsSectionStorage => 'സംഭരണം';

  @override
  String get settingsSectionStorageSubtitle =>
      'അറ്റാച്ച്മെന്റ് സംഭരണം, ബാക്കപ്പ്, പുനഃസ്ഥാപിക്കൽ, ഇംപോർട്ട്';

  @override
  String get settingsSectionPermissions => 'അനുമതികൾ';

  @override
  String get settingsSectionPermissionsSubtitle =>
      'ആപ്പ് ഉപയോഗിക്കുന്ന സിസ്റ്റം അനുമതികൾ';

  @override
  String get settingsSectionAbout => 'വിവരങ്ങൾ';

  @override
  String get settingsSectionAboutSubtitle =>
      'പതിപ്പ്, ലൈസൻസുകൾ, മറ്റ് വിവരങ്ങൾ';

  @override
  String get settingsAppLockMode => 'ആപ്പ് ലോക്ക് മോഡ്';

  @override
  String get settingsAutoLockTimeout => 'ഓട്ടോ-ലോക്ക് സമയം';

  @override
  String get settingsScreenSecurity => 'സ്ക്രീൻഷോട്ട് തടയുക';

  @override
  String get settingsScreenSecuritySubtitle =>
      'സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സമീപകാല ആപ്പ് പ്രിവ്യൂ എന്നിവ തടയുന്നു';

  @override
  String get settingsScreenSecurityOffTitle => 'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കണോ?';

  @override
  String get settingsScreenSecurityOffBody =>
      'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കിയാൽ ആർക്കും നിങ്ങളുടെ ജേണൽ സ്ക്രീൻ പകർത്താൻ കഴിയും. ഇത് എപ്പോൾ വേണമെങ്കിലും വീണ്ടും ഓണാക്കാം.';

  @override
  String get settingsScreenSecurityOffAction => 'ഓഫാക്കുക';

  @override
  String get settingsScreenSecurityUpdatedOn => 'സ്ക്രീൻഷോട്ട് തടയൽ ഓണാക്കി';

  @override
  String get settingsScreenSecurityUpdatedOff => 'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കി';

  @override
  String get settingsScreenSecuritySaveFailed =>
      'സ്ക്രീൻഷോട്ട് ക്രമീകരണം മാറ്റാൻ കഴിഞ്ഞില്ല';

  @override
  String get settingsTamperAlerts => 'സുരക്ഷാ മുന്നറിയിപ്പുകൾ';

  @override
  String get settingsSyncConflicts => 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get settingsSecurityEvents => 'സുരക്ഷാ ലോഗുകൾ';

  @override
  String get settingsTheme => 'തീം';

  @override
  String get settingsThemeSubtitle => 'ആപ്പിന്റെ കാഴ്ച രീതി തിരഞ്ഞെടുക്കുക.';

  @override
  String get settingsThemeLight => 'വെളിച്ചം (Light)';

  @override
  String get settingsThemeDark => 'ഇരുട്ട് (Dark)';

  @override
  String get settingsThemeSystem => 'സിസ്റ്റം (System)';

  @override
  String get settingsAbout => 'ആപ്പിനെക്കുറിച്ച്';

  @override
  String get settingsComingSoon => 'ഉടൻ വരുന്നു';

  @override
  String get settingsSwitchLockTitle => 'ലോക്ക് മോഡ് മാറ്റണോ?';

  @override
  String settingsSwitchLockBody(String enabled, String disabled) {
    return 'ഇത് ആപ്പ് സംരക്ഷണം $enabled എന്നതിലേക്ക് മാറ്റുകയും $disabled പ്രവർത്തനരഹിതമാക്കുകയും ചെയ്യും. തുടരണോ?';
  }

  @override
  String get settingsSwitchAction => 'മാറ്റുക';

  @override
  String settingsLockModeUpdated(String mode) {
    return 'ലോക്ക് മോഡ് മാറ്റി: $mode ഇപ്പോൾ സജീവമാണ്.';
  }

  @override
  String get settingsThemeSaveFailed =>
      'തീം ക്രമീകരണം സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String settingsThemeUpdated(String mode) {
    return 'തീം മാറ്റി: $mode മോഡ് സജീവമാക്കി.';
  }

  @override
  String get storageMigrateTitle => 'സംഭരണം മാറ്റുക (Migrate Storage)';

  @override
  String storageMigrateBody(String target) {
    return 'All attachments will be moved to $target.';
  }

  @override
  String get storageMigrateAction => 'മാറ്റുക';

  @override
  String get storageMigrationCancelled => 'സംഭരണ മാറ്റം റദ്ദാക്കി.';

  @override
  String storageMigrationFailed(String error) {
    return 'സംഭരണ മാറ്റം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get storageMigrationComplete => 'സംഭരണ മാറ്റം പൂർത്തിയായി.';

  @override
  String get storageLocationTitle => 'അറ്റാച്ച്മെന്റ് സംഭരണ സ്ഥലം';

  @override
  String get storageLocationDialogTitle => 'സംഭരണ സ്ഥലം';

  @override
  String get storageAppPrivate => 'ആപ്പ്-പ്രൈവറ്റ് മെമ്മറി';

  @override
  String get storageSdCard => 'എസ്.ഡി. കാർഡ്';

  @override
  String storageSdCardNamed(String label) {
    return 'എസ്.ഡി. കാർഡ് ($label)';
  }

  @override
  String get storageMigrateRow => 'സംഭരണം മാറ്റുക (Migrate Storage)';

  @override
  String get storageMigrationIdle => 'നിഷ്ക്രിയം';

  @override
  String storageMigrationRunning(int processed, int total) {
    return '$total-ൽ $processed ഫയലുകൾ മാറ്റുന്നു…';
  }

  @override
  String get storageMigrationFailedShort => 'സംഭരണ മാറ്റം പരാജയപ്പെട്ടു.';

  @override
  String get storageUsage => 'സംഭരണ ഉപയോഗം';

  @override
  String get storageUnknown => 'ലഭ്യമല്ല';

  @override
  String get storageBackupHealth => 'ബാക്കപ്പ് ആരോഗ്യം';

  @override
  String get storageImportData => 'ഡാറ്റ ഇംപോർട്ട് ചെയ്യുക';

  @override
  String get storageSyncHealth => 'സിങ്ക് ആരോഗ്യം';

  @override
  String get storageImportNeedsJournal =>
      'ഇംപോർട്ട് ചെയ്യുന്നതിന് മുൻപ് ഒരു ജേണൽ ഉണ്ടാക്കുക.';

  @override
  String get storageImportChooseJournal => 'ജേണലിലേക്ക് ഇംപോർട്ട് ചെയ്യുക';

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
  String get migrationDialogTitle => 'ഫയലുകൾ മാറ്റുന്നു';

  @override
  String get migrationCancelling => 'റദ്ദാക്കുന്നു...';

  @override
  String migrationProgress(String processed, String total) {
    return '$processed of $total';
  }

  @override
  String get migrationUnknownTotal => '?';

  @override
  String get permissionStatusRow => 'Permission Status';

  @override
  String get permissionsManage => 'അനുമതികൾ കൈകാര്യം ചെയ്യുക';

  @override
  String get permissionsOpenSystem => 'സിസ്റ്റം ക്രമീകരണങ്ങൾ';

  @override
  String permissionsGrantedSummary(int granted, int total) {
    return '$granted / $total അനുമതികൾ അനുവദിച്ചു';
  }

  @override
  String get searchHint => 'കുറിപ്പുകൾ, ടാഗുകൾ, ഉള്ളടക്കം എന്നിവ തിരയുക...';

  @override
  String get searchTypeToSearch => 'തിരയാൻ ഇവിടെ ടൈപ്പ് ചെയ്യുക...';

  @override
  String get searchNoFilterMatches =>
      'ഫിൽട്ടറുമായി പൊരുത്തപ്പെടുന്ന ഫലങ്ങളില്ല.';

  @override
  String get searchNoResults => 'ഫലങ്ങളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get searchSectionJournals => 'ജേണലുകൾ';

  @override
  String get searchSectionEntries => 'കുറിപ്പുകൾ';

  @override
  String get searchSavePresetTitle => 'തിരയൽ പ്രീസെറ്റ് സേവ് ചെയ്യുക';

  @override
  String get searchPresetNameLabel => 'പ്രീസെറ്റ് പേര്';

  @override
  String get restoreTitle => 'ബാക്കപ്പ് പുനഃസ്ഥാപിക്കുക';

  @override
  String get restoreOpenAction => 'ബാക്കപ്പ് ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get restoreLockedTitle => 'ബാക്കപ്പ് പാസ്‌വേഡ് നൽകുക';

  @override
  String get restoreLockedBody =>
      'ഈ ബാക്കപ്പ് ഫയൽ എൻക്രിപ്റ്റ് ചെയ്തിരിക്കുന്നു.';

  @override
  String get restoreUnlockAction => 'അൺലോക്ക്';

  @override
  String get restoreUnlockReason =>
      'ബാക്കപ്പ് പുനഃസ്ഥാപിക്കാൻ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get restoreUnlockFailed =>
      'തെറ്റായ പാസ്‌വേഡ്. ബാക്കപ്പ് ഡീക്രിപ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get restoreEnterPin => 'നിങ്ങളുടെ ആപ്പ് പിൻ നൽകുക';

  @override
  String get restorePinWrong => 'നൽകിയ പിൻ തെറ്റാണ്.';

  @override
  String get restorePickHeading => 'ബാക്കപ്പ് തിരഞ്ഞെടുക്കുക';

  @override
  String get restorePickFromDevice => 'ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get restoreNoBackupsFound =>
      'ഈ ആപ്പ് ഉണ്ടാക്കിയ ബാക്കപ്പുകളൊന്നും കണ്ടെത്തിയില്ല. നിങ്ങൾക്ക് മറ്റൊരു ഫയൽ തിരഞ്ഞെടുക്കാം.';

  @override
  String restoreSelectedFile(String fileName) {
    return 'തിരഞ്ഞെടുത്തത്: $fileName';
  }

  @override
  String get restorePasswordLabel => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get restorePasswordHelper =>
      'ബാക്കപ്പ് എടുത്തപ്പോൾ നൽകിയ അതേ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get restoreOpenBackupAction => 'ബാക്കപ്പ് തുറക്കുക';

  @override
  String get restorePreviewHeading => 'ബാക്കപ്പിലെ ഉള്ളടക്കം';

  @override
  String restorePreviewCreated(String date) {
    return 'ഉണ്ടാക്കിയ തീയതി: $date';
  }

  @override
  String restorePreviewCounts(int journals, int entries, int attachments) {
    return '$journals ജേണലുകൾ, $entries കുറിപ്പുകൾ, $attachments അറ്റാച്ച്മെന്റുകൾ';
  }

  @override
  String get restoreLegacyAttachmentsWarning =>
      'ഇതൊരു പഴയ ബാക്കപ്പാണ്. ഇതിലെ അറ്റാച്ച്മെന്റുകൾ നിർമ്മിച്ച ഉപകരണത്തിൽ മാത്രമേ തുറക്കൂ.';

  @override
  String get restoreModeHeading => 'എങ്ങനെ പുനഃസ്ഥാപിക്കണം?';

  @override
  String get restoreModeMerge => 'നിലവിലെ ഡാറ്റയുമായി ലയിപ്പിക്കുക';

  @override
  String get restoreModeMergeDetail =>
      'ഇവിടെ ഇല്ലാത്തവ ചേർക്കുക, നിലവിലുള്ളവ നിലനിർത്തുക.';

  @override
  String get restoreModeReplace => 'പൂർണ്ണമായി മാറ്റുക (Replace)';

  @override
  String get restoreModeReplaceDetail =>
      'ഇവിടെയുള്ളവ മായ്ച്ച് ബാക്കപ്പ് ഉപയോഗിക്കുക. നിലവിലെ വിവരങ്ങൾ ആദ്യം സുരക്ഷിതമായി ബാക്കപ്പ് ചെയ്യും.';

  @override
  String get restoreDryRunAction => 'ആദ്യം പരീക്ഷിച്ച് നോക്കുക';

  @override
  String get restoreDryRunHelper =>
      'യഥാർത്ഥ മാറ്റങ്ങൾ വരുത്താതെ വിവരങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get restoreAction => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get restoreConfirmReplaceTitle => 'എല്ലാം മാറ്റിയെഴുതണോ?';

  @override
  String get restoreConfirmReplaceBody =>
      'ഈ ഫോണിലെ എല്ലാ ജേണലുകളും കുറിപ്പുകളും മാറ്റി ബാക്കപ്പിലെ വിവരങ്ങൾ സ്ഥാപിക്കും. നിലവിലെ വിവരങ്ങൾ ഒരു സുരക്ഷാ ബാക്കപ്പായി സേവ് ചെയ്യും.';

  @override
  String get restoreConfirmMergeTitle => 'ബാക്കപ്പ് ലയിപ്പിക്കണോ?';

  @override
  String get restoreConfirmMergeBody =>
      'ബാക്കപ്പിലുള്ളതും ഇവിടെയില്ലാത്തതുമായ വിവരങ്ങൾ ചേർക്കും. ഒന്നും ഇല്ലാതാക്കില്ല.';

  @override
  String get restoreDryRunResultTitle => 'എന്തൊക്കെ മാറ്റങ്ങൾ വരും';

  @override
  String get restoreResultTitle => 'പുനഃസ്ഥാപനം പൂർത്തിയായി';

  @override
  String restoreResultAdded(int count) {
    return 'ചേർത്തവ: $count എണ്ണം';
  }

  @override
  String restoreResultSkipped(int count) {
    return 'നേരത്തെയുള്ളവ: $count എണ്ണം';
  }

  @override
  String restoreResultFiles(int count) {
    return 'പുനഃസ്ഥാപിച്ച അറ്റാച്ച്മെന്റുകൾ: $count';
  }

  @override
  String restoreResultFilesFailed(int count) {
    return 'പുനഃസ്ഥാപിക്കാൻ കഴിയാത്ത ഫയലുകൾ: $count';
  }

  @override
  String get restoreResultSafetyBackup =>
      'നിലവിലെ ഡാറ്റയുടെ സുരക്ഷാ ബാക്കപ്പ് ആദ്യം സേവ് ചെയ്തു.';

  @override
  String get restoreErrorWrongPassword =>
      'തെറ്റായ പാസ്‌വേഡ് അല്ലെങ്കിൽ ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചു.';

  @override
  String get restoreErrorDamaged =>
      'ഈ ഫയൽ ഒരു ബാക്കപ്പ് അല്ല അല്ലെങ്കിൽ തകരാറിലാണ്.';

  @override
  String get restoreErrorTooNew =>
      'ഈ ബാക്കപ്പ് പുതിയ പതിപ്പ് ആപ്പിൽ ഉണ്ടാക്കിയതാണ്. ആപ്പ് അപ്ഡേറ്റ് ചെയ്ത് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get restoreErrorPasswordTooShort =>
      'ബാക്കപ്പ് പാസ്‌വേഡിൽ കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം.';

  @override
  String restoreErrorFailed(String error) {
    return 'പുനഃസ്ഥാപനം പരാജയപ്പെട്ടു, മാറ്റങ്ങളൊന്നും വരുത്തിയിട്ടില്ല: $error';
  }

  @override
  String get restoreWorking => 'പ്രവർത്തിക്കുന്നു...';

  @override
  String get exportProtectTitle => 'എക്സ്പോർട്ട് സംരക്ഷണം';

  @override
  String get exportProtectHint =>
      'എക്സ്പോർട്ട് ഫയൽ പാസ്‌വേഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുക';

  @override
  String get exportPasswordLabel => 'എക്സ്പോർട്ട് പാസ്‌വേഡ്';

  @override
  String get exportPasswordConfirmLabel => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String exportPasswordTooShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get exportPasswordMismatch => 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String get exportEncryptedNotice =>
      'ഈ പാസ്‌വേഡ് സുരക്ഷിതമായി സൂക്ഷിക്കുക. അതില്ലാതെ എക്സ്പോർട്ട് ചെയ്ത ഫയൽ ആർക്കും വീണ്ടും തുറക്കാൻ കഴിയില്ല.';

  @override
  String get openEncryptedTitle => 'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് തുറക്കുക';

  @override
  String get openEncryptedIntro =>
      'പാസ്‌വേഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത ജേണൽ എക്സ്പോർട്ട് ഫയലുകൾ (.jvep/.jvbk) വായിക്കുക.';

  @override
  String get openEncryptedPickFile => 'ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String openEncryptedChosenFile(String fileName) {
    return 'ഫയൽ: $fileName';
  }

  @override
  String get openEncryptedPasswordLabel => 'ഡീക്രിപ്ഷൻ പാസ്‌വേഡ്';

  @override
  String get openEncryptedAction => 'തുറന്ന് സേവ് ചെയ്യുക';

  @override
  String get openEncryptedWorking => 'തുറക്കുന്നു...';

  @override
  String get openEncryptedSaveDialogTitle => 'തുറന്ന ഫയൽ സേവ് ചെയ്യുക';

  @override
  String get openEncryptedSaved =>
      'സേവ് ചെയ്തു. ഫയൽ ഇനി എൻക്രിപ്റ്റ് ചെയ്തതല്ല, അതിനാൽ സുരക്ഷിതമായി സൂക്ഷിക്കുക.';

  @override
  String get openEncryptedCancelled => 'ഒന്നും സേവ് ചെയ്തിട്ടില്ല.';

  @override
  String get openEncryptedErrorWrongPassword =>
      'തെറ്റായ പാസ്‌വേഡ് അല്ലെങ്കിൽ ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചു.';

  @override
  String get openEncryptedErrorNotSealed =>
      'ഇതൊരു എൻക്രിപ്റ്റ് ചെയ്ത ജേണൽ എക്സ്പോർട്ട് ഫയലല്ല.';

  @override
  String get openEncryptedErrorTooNew =>
      'ഈ ഫയൽ പുതിയ പതിപ്പ് ആപ്പിൽ ഉണ്ടാക്കിയതാണ്. ആപ്പ് അപ്ഡേറ്റ് ചെയ്യുക.';

  @override
  String get openEncryptedErrorFailed => 'ഫയൽ തുറക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get settingsOpenEncryptedExport =>
      'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് തുറക്കുക';

  @override
  String get templateChooserTitle => 'ടെംപ്ലേറ്റ് തിരഞ്ഞെടുക്കുക';

  @override
  String get versionHistoryEmpty =>
      'മുൻ പതിപ്പുകളൊന്നും ലഭ്യമല്ല.\n\nകുറിപ്പ് തിരുത്തുമ്പോൾ പതിപ്പുകൾ സ്വയമേവ സേവ് ചെയ്യപ്പെടും.';

  @override
  String get drawingStrokeFine => 'നേർത്തത് (2px)';

  @override
  String get drawingStrokeNormal => 'സാധാരണ (3.5px)';

  @override
  String get drawingStrokeThick => 'കട്ടിയുള്ളത് (7px)';

  @override
  String get drawingStrokeBold => 'വളരെ കട്ടിയുള്ളത് (14px)';

  @override
  String get drawingDefaultTitle => 'രേഖാചിത്രം';

  @override
  String get imageDefaultTitle => 'ചിത്രം';

  @override
  String get editorImageLocked =>
      'ലോക്ക് ചെയ്ത ചിത്രം — അൺലോക്ക് ചെയ്യാൻ അമർത്തുക';

  @override
  String editorImageUnavailableWithName(String fileName) {
    return 'ചിത്രം ലഭ്യമല്ല — $fileName';
  }

  @override
  String get audioPauseTooltip => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get audioPlayTooltip => 'പ്ലേ ചെയ്യുക';

  @override
  String importIntoJournal(String journalTitle) {
    return '\"$journalTitle\" എന്നതിലേക്ക് ഇംപോർട്ട് ചെയ്യുക';
  }

  @override
  String importSupportedFormats(String formats) {
    return 'പിന്തുണയ്ക്കുന്ന ഫോർമാറ്റുകൾ: $formats';
  }

  @override
  String importSupportedExtensions(String extensions) {
    return 'ഫയൽ തരങ്ങൾ: $extensions';
  }

  @override
  String get importSelectFilesPrompt =>
      'പുതിയ കുറിപ്പുകളായി ഇംപോർട്ട് ചെയ്യാൻ ഫയലുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get featuresCategoryJournaling =>
      'എഴുത്തും റിച്ച് ടെക്സ്റ്റ് എഡിറ്ററും';

  @override
  String get featuresCategoryJournalingSubtitle =>
      'ആകർഷകമായ എഴുത്ത്, ടെംപ്ലേറ്റുകൾ, ഒ.സി.ആർ., മീഡിയ അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get featuresCategorySecurity =>
      'സ്വകാര്യത, എൻക്രിപ്ഷൻ, വോൾട്ട് സുരക്ഷ';

  @override
  String get featuresCategorySecuritySubtitle =>
      'പൂർണ്ണ ഓഫ്‌ലൈൻ സുരക്ഷയും വിപുലമായ എൻക്രിപ്ഷൻ നിയന്ത്രണങ്ങളും';

  @override
  String get featuresCategoryDiscovery => 'തിരയൽ, ടൈംലൈൻ, സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get featuresCategoryDiscoverySubtitle =>
      'വേഗതയേറിയ ഫുൾ-ടെക്സ്റ്റ് തിരയലും കലണ്ടർ നാവിഗേഷനും';

  @override
  String get featuresCategoryStorage => 'സംഭരണം, ബാക്കപ്പ് & എക്സ്പോർട്ട്';

  @override
  String get featuresCategoryStorageSubtitle =>
      'ലോക്കൽ ബാക്കപ്പുകളും വൈവിധ്യമാർന്ന എക്സ്പോർട്ട് രീതികളും';

  @override
  String get featureQuillTitle => 'ക്വിൽ റിച്ച് ടെക്സ്റ്റ് എഡിറ്റർ';

  @override
  String get featureQuillDesc =>
      'തലക്കെട്ടുകൾ, ലിസ്റ്റുകൾ, ബോൾഡ്, ഇറ്റാലിക്, അടിവര, കോൾഔട്ടുകൾ എന്നിവ ഉപയോഗിച്ച് കുറിപ്പുകൾ മനോഹരമായി എഴുതുക.';

  @override
  String get featureTemplatesTitle => 'ഘടനാപരമായ എൻട്രി ടെംപ്ലേറ്റുകൾ';

  @override
  String get featureTemplatesDesc =>
      'പ്രതിദിന ചിന്തകൾ, കൃതജ്ഞത, യാത്രാവിവരണം, മീറ്റിംഗ് കുറിപ്പുകൾ തുടങ്ങിയ മുൻകൂട്ടി തയ്യാറാക്കിയ 8 ടെംപ്ലേറ്റുകൾ.';

  @override
  String get featureMediaOcrTitle => 'എൻക്രിപ്റ്റ് ചെയ്ത മീഡിയയും ഒ.സി.ആറും';

  @override
  String get featureMediaOcrDesc =>
      'ഫോട്ടോകളും ഓഡിയോയും സുരക്ഷിതമായി സൂക്ഷിക്കുക. ചിത്രങ്ങളിൽ നിന്ന് നേരിട്ട് ടെക്സ്റ്റ് തിരിച്ചറിയാൻ ഓഫ്‌ലൈൻ ഒ.സി.ആർ.';

  @override
  String get featureTagsTitle => 'വർണ്ണ കോഡുള്ള ടാഗുകൾ & ടാഗ് മാനേജർ';

  @override
  String get featureTagsDesc =>
      'വിവിധ നിറങ്ങളിലുള്ള ടാഗുകൾ ഉപയോഗിച്ച് കുറിപ്പുകൾ തരംതിരിക്കുക. ടാഗുകൾ എളുപ്പത്തിൽ കൈകാര്യം ചെയ്യുക.';

  @override
  String get featureMultiJournalTitle => 'വ്യത്യസ്ത ജേണലുകൾ';

  @override
  String get featureMultiJournalDesc =>
      'വ്യക്തിപരം, ജോലി, യാത്ര തുടങ്ങിയ വിവിധ ആവശ്യങ്ങൾക്കായി പ്രത്യേക ജേണലുകൾ തയ്യാറാക്കുക.';

  @override
  String get featureSqlcipherTitle => 'എസ്.ക്യു.എൽ.സൈഫർ AES-256 എൻക്രിപ്ഷൻ';

  @override
  String get featureSqlcipherDesc =>
      'എല്ലാ കുറിപ്പുകളും ഡാറ്റാബേസും AES-256 ഉപയോഗിച്ച് ഉപകരണത്തിൽ തന്നെ എൻക്രിപ്റ്റ് ചെയ്യപ്പെടുന്നു.';

  @override
  String get featureBiometricsTitle => 'ബയോമെട്രിക്സ് & ആപ്പ് പിൻ ലോക്ക്';

  @override
  String get featureBiometricsDesc =>
      'ഫിംഗർപ്രിന്റ് അല്ലെങ്കിൽ ആപ്പ് പിൻ ഉപയോഗിച്ച് ജേണൽ വോൾട്ട് സുരക്ഷിതമാക്കുക.';

  @override
  String get featureJournalLockTitle => 'പ്രത്യേക ജേണൽ പാസ്‌വേഡുകൾ';

  @override
  String get featureJournalLockDesc =>
      'കൂടുതൽ സ്വകാര്യമായ ജേണലുകൾക്ക് പ്രത്യേക പാസ്‌വേഡുകൾ സജ്ജീകരിക്കാം.';

  @override
  String get featureAttachmentLockTitle =>
      'അറ്റാച്ച്മെന്റ് തലത്തിലുള്ള ലോക്കുകൾ';

  @override
  String get featureAttachmentLockDesc =>
      'പ്രത്യേക ഫോട്ടോകളും രേഖകളും വ്യക്തിഗത പാസ്‌വേഡുകൾ നൽകി മറച്ചുവെക്കാം.';

  @override
  String get featureScreenshotGuardTitle => 'സ്ക്രീൻഷോട്ട് തടയൽ സംവിധാനം';

  @override
  String get featureScreenshotGuardDesc =>
      'FLAG_SECURE വഴി സ്ക്രീൻഷോട്ടുകളും സ്ക്രീൻ റെക്കോർഡിംഗും സ്വയമേവ തടയപ്പെടുന്നു.';

  @override
  String get featureTamperAuditTitle => 'സുരക്ഷാ ഓഡിറ്റ് ലോഗുകൾ';

  @override
  String get featureTamperAuditDesc =>
      'തെറ്റായ പിൻ ശ്രമങ്ങളും പ്രധാന സുരക്ഷാ മാറ്റങ്ങളും ലോഗ് ചെയ്യപ്പെടുന്നു.';

  @override
  String get featureAutoLockTitle => 'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകൾ';

  @override
  String get featureAutoLockDesc =>
      'ഉപയോഗത്തിലില്ലാത്തപ്പോൾ ആപ്പ് സ്വയമേവ ലോക്കാകുന്നതിനുള്ള സമയപരിധി നിശ്ചയിക്കുക.';

  @override
  String get featureFtsSearchTitle => 'മിന്നൽ വേഗതയുള്ള FTS തിരയൽ';

  @override
  String get featureFtsSearchDesc =>
      'SQLite FTS5 വഴി ഏത് കുറിപ്പും ഉള്ളടക്കവും ഞൊടിയിടയിൽ തിരഞ്ഞു കണ്ടെത്തുക.';

  @override
  String get featureSearchPresetsTitle => 'സേവ് ചെയ്ത തിരയലുകൾ';

  @override
  String get featureSearchPresetsDesc =>
      'പതിവായി തിരയുന്ന ഫിൽട്ടറുകൾ ഒറ്റ ക്ലിക്കിൽ ഉപയോഗിക്കാൻ സേവ് ചെയ്തു വെക്കുക.';

  @override
  String get featureTimelineTitle => 'ഇന്ററാക്ടീവ് കലണ്ടർ ടൈംലൈൻ';

  @override
  String get featureTimelineDesc =>
      'കലണ്ടർ നാവിഗേഷൻ വഴി മുൻകാല കുറിപ്പുകൾ എളുപ്പത്തിൽ ബ്രൗസ് ചെയ്യുക.';

  @override
  String get featureInsightsTitle => 'എഴുത്ത് ശീലങ്ങളും സ്ഥിതിവിവരങ്ങളും';

  @override
  String get featureInsightsDesc =>
      'തുടർച്ചയായ എഴുത്ത് ദിവസങ്ങൾ, വാക്ക് എണ്ണം, പ്രതിമാസ പുരോഗതി എന്നിവ ചാർട്ടുകളിലൂടെ കാണുക.';

  @override
  String get featureStorageMigrationTitle => 'എസ്.ഡി. കാർഡ് സംഭരണ മാറ്റം';

  @override
  String get featureStorageMigrationDesc =>
      'ഫയലുകൾ ആന്തരിക സംഭരണത്തിനും എസ്.ഡി. കാർഡിനും ഇടയിൽ സുരക്ഷിതമായി മാറ്റുക.';

  @override
  String get featureEncryptedBackupsTitle =>
      'എൻക്രിപ്റ്റ് ചെയ്ത വോൾട്ട് ബാക്കപ്പുകൾ (.jvbk)';

  @override
  String get featureEncryptedBackupsDesc =>
      'പാസ്‌വേഡ് ഉപയോഗിച്ച് സുരക്ഷിതമായ .jvbk ബാക്കപ്പ് ഫയലുകൾ എടുക്കുകയും പുനഃസ്ഥാപിക്കുകയും ചെയ്യുക.';

  @override
  String get featureMultiExportTitle => 'വിവിധ ഫോർമാറ്റുകളിലുള്ള എക്സ്പോർട്ട്';

  @override
  String get featureMultiExportDesc =>
      'പി.ഡി.എഫ്., മാർക്ക്ഡൗൺ സിപ്പ്, ജെസൺ രൂപങ്ങളിൽ കുറിപ്പുകൾ എക്സ്പോർട്ട് ചെയ്യുക.';

  @override
  String get featureEncryptedReaderTitle =>
      'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് റീഡർ';

  @override
  String get featureEncryptedReaderDesc =>
      'ബാക്കപ്പ് മൊത്തമായി പുനഃസ്ഥാപിക്കാതെ തന്നെ എൻക്രിപ്റ്റ് ചെയ്ത ഫയലുകൾ ആപ്പിൽ വായിക്കുക.';

  @override
  String get helpTopicJournalOrg => 'ജേണൽ ക്രമീകരണവും ടെംപ്ലേറ്റുകളും';

  @override
  String get helpTopicJournalOrgSubtitle =>
      'വ്യത്യസ്ത ജേണലുകൾ, ടെംപ്ലേറ്റുകൾ, ക്വിൽ ഫോർമാറ്റിംഗ് എന്നിവ എങ്ങനെ ഉപയോഗിക്കാം.';

  @override
  String get helpTopicAttachmentsOcr => 'അറ്റാച്ച്മെന്റുകളും ഒ.സി.ആർ. സ്കാനറും';

  @override
  String get helpTopicAttachmentsOcrSubtitle =>
      'ഓഫ്‌ലൈൻ ഒ.സി.ആർ. വഴി ടെക്സ്റ്റ് തിരിച്ചറിയലും എൻക്രിപ്റ്റ് ചെയ്ത മീഡിയ സംഭരണവും.';

  @override
  String get helpTopicTags => 'ടാഗുകളും വർണ്ണ കോഡിംഗും';

  @override
  String get helpTopicTagsSubtitle =>
      'കുറിപ്പുകൾ തരംതിരിക്കലും ഇഷ്ടാനുസൃത ടാഗ് നിറങ്ങളും.';

  @override
  String get helpTopicEncryption => 'എൻക്രിപ്ഷനും കീസ്റ്റോർ സുരക്ഷയും';

  @override
  String get helpTopicEncryptionSubtitle =>
      'SQLCipher ഡാറ്റാബേസ് എൻക്രിപ്ഷനും ആൻഡ്രോയിഡ് കീസ്റ്റോർ സുരക്ഷയും.';

  @override
  String get helpTopicBiometrics => 'ആപ്പ് ലോക്ക്, ബയോമെട്രിക്സ് & പിൻ';

  @override
  String get helpTopicBiometricsSubtitle =>
      'ഫിംഗർപ്രിന്റ്, ഫേസ് അൺലോക്ക്, ആപ്പ് പിൻ, ഓട്ടോ-ലോക്ക് ക്രമീകരണങ്ങൾ.';

  @override
  String get helpTopicJournalLocks =>
      'പ്രത്യേക ജേണൽ & അറ്റാച്ച്മെന്റ് ലോക്കുകൾ';

  @override
  String get helpTopicJournalLocksSubtitle =>
      'വ്യക്തിഗത പാസ്‌വേഡ് ലോക്കുകളും അറ്റാച്ച്മെന്റ് സുരക്ഷയും.';

  @override
  String get helpTopicScreenshotAudit =>
      'സ്ക്രീൻഷോട്ട് ഗാർഡും സുരക്ഷാ ലോഗുകളും';

  @override
  String get helpTopicScreenshotAuditSubtitle =>
      'FLAG_SECURE വിൻഡോ സുരക്ഷയും സുരക്ഷാ ഓഡിറ്റ് ലോഗുകളും.';

  @override
  String get helpTopicSearchTimeline => 'ഫുൾ-ടെക്സ്റ്റ് തിരയലും ടൈംലൈനും';

  @override
  String get helpTopicSearchTimelineSubtitle =>
      'SQLite FTS തിരയൽ, പ്രീസെറ്റുകൾ, കലണ്ടർ നാവിഗേഷൻ.';

  @override
  String get helpTopicInsights => 'എഴുത്ത് സ്ഥിതിവിവരങ്ങളും ട്രെൻഡുകളും';

  @override
  String get helpTopicInsightsSubtitle =>
      'സ്ട്രീക്കുകൾ, വാക്ക് എണ്ണ വിശകലനം, ടാഗ് സ്ഥിതിവിവരങ്ങൾ.';

  @override
  String get helpTopicStorageMigration => 'സംഭരണ സ്ഥാനങ്ങളും എസ്.ഡി. കാർഡും';

  @override
  String get helpTopicStorageMigrationSubtitle =>
      'മീഡിയ ഫയലുകൾ എസ്.ഡി. കാർഡിലേക്ക് സുരക്ഷിതമായി മാറ്റൽ.';

  @override
  String get helpTopicBackupRestore =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ബാക്കപ്പും പുനഃസ്ഥാപിക്കലും';

  @override
  String get helpTopicBackupRestoreSubtitle =>
      'പാസ്‌വേഡ് സംരക്ഷിത .jvbk ബാക്കപ്പ് ഫയലുകളും പുനഃസ്ഥാപനവും.';

  @override
  String get helpTopicExportFormats => 'എക്സ്പോർട്ട് ഫോർമാറ്റുകളും റീഡറും';

  @override
  String get helpTopicExportFormatsSubtitle =>
      'പി.ഡി.എഫ്., മാർക്ക്ഡൗൺ, ജെസൺ എക്സ്പോർട്ടുകളും റീഡറും.';

  @override
  String get helpTopicFaq => 'പതിവ് ചോദ്യങ്ങളും പരിഹാരങ്ങളും';

  @override
  String get helpTopicFaqSubtitle =>
      'സ്വകാര്യത, അനുമതികൾ, പാസ്‌വേഡ് നയങ്ങൾ എന്നിവയെക്കുറിച്ചുള്ള ഉത്തരങ്ങൾ.';

  @override
  String get helpAttachmentsIntro =>
      'ഫോട്ടോകൾ, വോയ്സ് നോട്ടുകൾ, രേഖകൾ എന്നിവ ഉപയോഗിച്ച് കുറിപ്പുകൾ സമ്പന്നമാക്കുക. ഓഫ്‌ലൈൻ ഒ.സി.ആർ. വഴി ടെക്സ്റ്റ് നേരിട്ട് പകർത്താം.';

  @override
  String get helpAttachmentsSectionOcr =>
      'ഉപകരണത്തിലെ ഒ.സി.ആർ. ടെക്സ്റ്റ് തിരിച്ചറിയൽ';

  @override
  String get helpAttachmentsOcrBullet1 =>
      'പുസ്തകങ്ങളിൽ നിന്നോ കുറിപ്പുകളിൽ നിന്നോ ഫോട്ടോ എടുക്കാൻ എഡിറ്ററിലെ ക്യാമറ ഐക്കൺ അമർത്തുക.';

  @override
  String get helpAttachmentsOcrBullet2 =>
      'നിമിഷങ്ങൾക്കകം ബാഹ്യ സെർവറുകളിലേക്ക് ഡാറ്റ അയക്കാതെ തന്നെ ഒ.സി.ആർ. ടെക്സ്റ്റ് തിരിച്ചറിയുന്നു.';

  @override
  String get helpAttachmentsOcrBullet3 =>
      'തിരിച്ചറിഞ്ഞ ടെക്സ്റ്റ് എഡിറ്ററിലേക്ക് നേരിട്ട് ചേർക്കപ്പെടുന്നു.';

  @override
  String get helpAttachmentsSectionEncryption =>
      'AES-256-GCM അറ്റാച്ച്മെന്റ് എൻക്രിപ്ഷൻ';

  @override
  String get helpAttachmentsEncryptionBullet1 =>
      'എല്ലാ മീഡിയ ഫയലുകളും AES-256-GCM ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്താണ് സൂക്ഷിക്കുന്നത്. ആപ്പ് ഇല്ലാതെ ഗാലറി ആപ്പുകൾക്ക് ഇത് തുറക്കാൻ കഴിയില്ല.';

  @override
  String get helpAttachmentsFooter =>
      'സ്വകാര്യതാ ഉറപ്പ്: ഒ.സി.ആർ. പൂർണ്ണമായും നിങ്ങളുടെ ഉപകരണത്തിൽ 100% ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു.';

  @override
  String get helpBackupIntro =>
      'എൻക്രിപ്റ്റ് ചെയ്ത .jvbk ബാക്കപ്പുകൾ വഴി ഫോൺ മാറുമ്പോഴും നിങ്ങളുടെ ജേണൽ സുരക്ഷിതമായി നിലനിർത്തുക.';

  @override
  String get helpBackupSectionCreate =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ബാക്കപ്പ് എടുക്കൽ (.jvbk)';

  @override
  String get helpBackupCreateBullet1 =>
      'ക്രമീകരണങ്ങൾ → സംഭരണം → ബാക്കപ്പ് & പുനഃസ്ഥാപിക്കൽ → ബാക്കപ്പ് എടുക്കുക തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpBackupCreateBullet2 =>
      'ശക്തമായ ഒരു പാസ്‌വേഡ് നൽകുക. ഇത് ഡാറ്റാബേസും അറ്റാച്ച്മെന്റുകളും എൻക്രിപ്റ്റ് ചെയ്യും.';

  @override
  String get helpBackupCreateBullet3 =>
      'ലഭിക്കുന്ന .jvbk ഫയൽ ആവശ്യമുള്ള ഫോൾഡറിലോ യു.എസ്.ബി. ഡ്രൈവിലോ സൂക്ഷിക്കുക.';

  @override
  String get helpBackupSectionRestore => 'പുതിയ ഉപകരണത്തിൽ പുനഃസ്ഥാപിക്കൽ';

  @override
  String get helpBackupRestoreBullet1 =>
      'പുതിയ ഫോണിൽ ആപ്പ് ഇൻസ്റ്റാൾ ചെയ്ത് ക്രമീകരണങ്ങൾ → സംഭരണം → ബാക്കപ്പ് പുനഃസ്ഥാപിക്കുക തുറക്കുക.';

  @override
  String get helpBackupRestoreBullet2 =>
      '.jvbk ഫയൽ തിരഞ്ഞെടുത്ത് ബാക്കപ്പ് പാസ്‌വേഡ് നൽകുക.';

  @override
  String get helpBackupRestoreBullet3 =>
      'എല്ലാ ജേണലുകളും കുറിപ്പുകളും ഫയലുകളും പുതിയ ഉപകരണത്തിലേക്ക് പുനഃസ്ഥാപിക്കപ്പെടും.';

  @override
  String get helpBackupFooter =>
      'പ്രധാനം: ബാക്കപ്പ് പാസ്‌വേഡ് മറന്നുപോയാൽ ഡാറ്റ വീണ്ടെടുക്കാൻ കഴിയില്ല.';

  @override
  String get helpBiometricsIntro =>
      'ബയോമെട്രിക്സ് അല്ലെങ്കിൽ ആപ്പ് പിൻ ഉപയോഗിച്ച് നിങ്ങളുടെ സ്വകാര്യ ചിന്തകൾ സുരക്ഷിതമായി സൂക്ഷിക്കുക.';

  @override
  String get helpBiometricsSectionPhoneLock =>
      'ഫോൺ ലോക്ക് മോഡ് (ബയോമെട്രിക്സ്)';

  @override
  String get helpBiometricsPhoneLockBullet1 =>
      'ഫോണിലെ ഫിംഗർപ്രിന്റ്, ഫേസ് അൺലോക്ക് അല്ലെങ്കിൽ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുന്നു.';

  @override
  String get helpBiometricsPhoneLockBullet2 =>
      'വേഗതയേറിയതും എളുപ്പമുള്ളതുമായ അൺലോക്കിംഗ്.';

  @override
  String get helpBiometricsSectionAppPin => 'പ്രത്യേക ആപ്പ് പിൻ മോഡ്';

  @override
  String get helpBiometricsAppPinBullet1 =>
      'ഫോൺ ലോക്കിൽ നിന്ന് വ്യത്യസ്തമായ പ്രത്യേക 4-6 അക്ക പിൻ സജ്ജീകരിക്കുക.';

  @override
  String get helpBiometricsAppPinBullet2 =>
      'മറ്റുള്ളവർക്ക് ഫോൺ പാസ്‌വേഡ് അറിയാമെങ്കിലും ജേണൽ സുരക്ഷിതമായിരിക്കും.';

  @override
  String get helpBiometricsSectionAutoLock => 'ഓട്ടോ-ലോക്ക് സമയ ക്രമീകരണം';

  @override
  String get helpBiometricsAutoLockBullet1 =>
      'ക്രമീകരണങ്ങൾ → സുരക്ഷ → ഓട്ടോ-ലോക്ക് വഴി സമയം നിശ്ചയിക്കുക (ഉടൻ, 30 സെക്കൻഡ്, 1 മിനിറ്റ്, 5 മിനിറ്റ്).';

  @override
  String get helpBiometricsAutoLockBullet2 =>
      'ആപ്പ് പശ്ചാത്തലത്തിലേക്ക് പോയി നിശ്ചിത സമയം കഴിയുമ്പോൾ വോൾട്ട് സ്വയമേവ ലോക്കാകും.';

  @override
  String get helpEncryptionIntro =>
      'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട് പൂർണ്ണ സ്വകാര്യതയും ഡാറ്റാ സുരക്ഷയും മുൻനിർത്തിയാണ് നിർമ്മിച്ചിരിക്കുന്നത്.';

  @override
  String get helpEncryptionSectionSqlcipher =>
      'എസ്.ക്യു.എൽ.സൈഫർ ഡാറ്റാബേസ് എൻക്രിപ്ഷൻ';

  @override
  String get helpEncryptionSqlcipherBullet1 =>
      'SQLite ഡാറ്റാബേസ് AES-256 ഉപയോഗിച്ച് പൂർണ്ണമായി എൻക്രിപ്റ്റ് ചെയ്യപ്പെടുന്നു.';

  @override
  String get helpEncryptionSqlcipherBullet2 =>
      'കുറിപ്പുകൾ, തലക്കെട്ടുകൾ, ടാഗുകൾ എന്നിവയെല്ലാം എൻക്രിപ്റ്റ് ചെയ്ത രൂപത്തിലാണ് സംഭരിക്കപ്പെടുന്നത്.';

  @override
  String get helpEncryptionSectionKeystore =>
      'ആൻഡ്രോയിഡ് കീസ്റ്റോർ ഹാർഡ്‌വെയർ സംയോജനം';

  @override
  String get helpEncryptionKeystoreBullet1 =>
      'പ്രധാന എൻക്രിപ്ഷൻ കീകൾ ആൻഡ്രോയിഡ് കീസ്റ്റോർ ഹാർഡ്‌വെയറിലാണ് സൂക്ഷിക്കുന്നത്.';

  @override
  String get helpEncryptionKeystoreBullet2 =>
      'കീകൾ ഹാർഡ്‌വെയറിൽ നിന്ന് പുറത്തെടുക്കാൻ മറ്റ് ആപ്പുകൾക്കോ റൂട്ട് ഉപയോക്താക്കൾക്കോ കഴിയില്ല.';

  @override
  String get helpEncryptionSectionOffline => 'പൂർണ്ണ ഓഫ്‌ലൈൻ സുരക്ഷ';

  @override
  String get helpEncryptionOfflineBullet1 =>
      'ഈ ആപ്പിന് ഇൻറർനെറ്റ് അനുമതി ആവശ്യമില്ല.';

  @override
  String get helpEncryptionOfflineBullet2 =>
      'ട്രാക്കിംഗ്, പരസ്യങ്ങൾ അല്ലെങ്കിൽ ബാഹ്യ സെർവർ ആശയവിനിമയങ്ങൾ ഒന്നും തന്നെ നടക്കുന്നില്ല.';

  @override
  String get helpExportIntro =>
      'നിങ്ങളുടെ കുറിപ്പുകൾ ഏത് സമയത്തും വിവിധ ഫോർമാറ്റുകളിൽ എക്സ്പോർട്ട് ചെയ്യാം.';

  @override
  String get helpExportSectionPdf => 'പി.ഡി.എഫ്. എക്സ്പോർട്ട്';

  @override
  String get helpExportPdfBullet1 =>
      'ചിത്രങ്ങൾ ഉൾപ്പെടെ മനോഹരമായി ഫോർമാറ്റ് ചെയ്ത പി.ഡി.എഫ്. ഫയലുകൾ നിർമ്മിക്കാം.';

  @override
  String get helpExportSectionMarkdown => 'മാർക്ക്ഡൗൺ സിപ്പ് & ജെസൺ';

  @override
  String get helpExportMarkdownBullet1 =>
      'ഒബ്സിഡിയൻ, നോഷൻ എന്നിവയിൽ ഉപയോഗിക്കാൻ മാർക്ക്ഡൗൺ സിപ്പ് രൂപത്തിൽ എക്സ്പോർട്ട് ചെയ്യാം.';

  @override
  String get helpExportMarkdownBullet2 =>
      'പൂർണ്ണ ഡാറ്റാ കൈമാറ്റത്തിനായി റോ ജെസൺ (JSON) രൂപത്തിലും എക്സ്പോർട്ട് ചെയ്യാം.';

  @override
  String get helpExportSectionReader => 'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് റീഡർ';

  @override
  String get helpExportReaderBullet1 =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ജേണൽ പാക്കേജുകൾ ആപ്പിലെ റീഡർ ടൂൾ ഉപയോഗിച്ച് എവിടെയും വായിക്കാം.';

  @override
  String get helpFaqIntro =>
      'സുരക്ഷ, ബാക്കപ്പ്, ജേണൽ മാനേജ്‌മെന്റ് എന്നിവയെക്കുറിച്ചുള്ള സംശയങ്ങൾക്കുള്ള പെട്ടെന്നുള്ള ഉത്തരങ്ങൾ.';

  @override
  String get helpFaqQ1 =>
      'എന്റെ ഡാറ്റ ഇൻറർനെറ്റിലൂടെ കൈമാറ്റം ചെയ്യപ്പെടുന്നുണ്ടോ?';

  @override
  String get helpFaqA1 =>
      'ഒരിക്കലുമില്ല. ഈ ആപ്പിന് INTERNET അനുമതിയില്ല. എല്ലാ വിവരങ്ങളും 100% നിങ്ങളുടെ ഫോണിൽ മാത്രം നിലനിൽക്കുന്നു.';

  @override
  String get helpFaqQ2 =>
      'പിൻ അല്ലെങ്കിൽ ജേണൽ പാസ്‌വേഡ് മറന്നുപോയാൽ എന്ത് ചെയ്യും?';

  @override
  String get helpFaqA2 =>
      'എൻക്രിപ്ഷൻ പൂർണ്ണമായും ഓഫ്‌ലൈനായതിനാൽ നഷ്ടപ്പെട്ട പാസ്‌വേഡ് വീണ്ടെടുക്കാൻ ആർക്കും കഴിയില്ല. പാസ്‌വേഡുകൾ സുരക്ഷിതമായി എവിടെയെങ്കിലും കുറിച്ചുവെക്കുക.';

  @override
  String get helpFaqQ3 => 'എന്തിനാണ് പ്രത്യേക അനുമതികൾ ചോദിക്കുന്നത്?';

  @override
  String get helpFaqA3 =>
      'ക്യാമറ/ഫോട്ടോകൾ: ഫോട്ടോകൾ ചേർക്കാൻ.\nമൈക്രോഫോൺ: വോയ്സ് നോട്ടുകൾ റെക്കോർഡ് ചെയ്യാൻ.\nസംഭരണം: ബാക്കപ്പുകൾ സേവ് ചെയ്യാനും എക്സ്പോർട്ട് ചെയ്യാനും.';

  @override
  String get helpFaqQ4 => 'ജേണൽ പുതിയ ഫോണിലേക്ക് മാറ്റാൻ കഴിയുമോ?';

  @override
  String get helpFaqA4 =>
      'തീർച്ചയായും! ക്രമീകരണങ്ങളിൽ നിന്ന് എൻക്രിപ്റ്റ് ചെയ്ത ബാക്കപ്പ് (.jvbk) എടുത്ത് പുതിയ ഫോണിലേക്ക് മാറ്റി പുനഃസ്ഥാപിക്കുക.';

  @override
  String get helpInsightsIntro =>
      'നിങ്ങളുടെ എഴുത്ത് ശീലങ്ങളും സ്ഥിതിവിവരങ്ങളും മനസ്സിലാക്കുക.';

  @override
  String get helpInsightsSectionHabits =>
      'എഴുത്ത് തുടർച്ച (Streak) ട്രാക്കിംഗ്';

  @override
  String get helpInsightsHabitsBullet1 =>
      'നിലവിലെ സ്ട്രീക്കും മികച്ച സ്ട്രീക്കും കണ്ട് ഉത്സാഹത്തോടെ എഴുത്ത് തുടരുക.';

  @override
  String get helpInsightsHabitsBullet2 =>
      'പ്രതിമാസ കലണ്ടർ ഹീറ്റ്മാപ്പ് സജീവ ദിവസങ്ങളെ എടുത്തുകാണിക്കുന്നു.';

  @override
  String get helpInsightsSectionStats => 'വാക്ക് എണ്ണ വിശകലനം';

  @override
  String get helpInsightsStatsBullet1 =>
      'ആകെ എഴുതിയ വാക്കുകൾ, ശരാശരി കുറിപ്പ് ദൈർഘ്യം, വായനാ സമയം എന്നിവ പരിശോധിക്കുക.';

  @override
  String get helpInsightsSectionTags => 'ടാഗ് വിതരണം';

  @override
  String get helpInsightsTagsBullet1 =>
      'കൂടുതലായി ഉപയോഗിച്ച ടാഗുകൾ കണ്ട് നിങ്ങളുടെ പ്രധാന വിഷയങ്ങൾ മനസ്സിലാക്കുക.';

  @override
  String get helpJournalLocksIntro =>
      'പ്രധാനപ്പെട്ട ജേണലുകൾക്കോ അറ്റാച്ച്മെന്റുകൾക്കോ കൂടുതൽ സുരക്ഷ നൽകുക.';

  @override
  String get helpJournalLocksSectionJournal =>
      'പ്രത്യേക ജേണൽ പാസ്‌വേഡ് ലോക്കുകൾ';

  @override
  String get helpJournalLocksJournalBullet1 =>
      'പ്രത്യേക ജേണലുകൾക്ക് പാസ്‌വേഡ് നൽകാം. ആപ്പ് തുറന്നാലും പാസ്‌വേഡ് നൽകാതെ ഇവ തുറക്കാൻ കഴിയില്ല.';

  @override
  String get helpJournalLocksJournalBullet2 =>
      'സെഷൻ അൺലോക്ക് വഴി ഉപയോഗിക്കുമ്പോൾ തുറന്നിരിക്കുകയും പിന്നീട് സ്വയമേവ ലോക്കാവുകയും ചെയ്യും.';

  @override
  String get helpJournalLocksSectionAttachment =>
      'അറ്റാച്ച്മെന്റ് തലത്തിലുള്ള ലോക്കുകൾ';

  @override
  String get helpJournalLocksAttachmentBullet1 =>
      'പ്രത്യേക ഫോട്ടോകളും രേഖകളും വ്യക്തിഗത പാസ്‌വേഡുകൾ നൽകി മറച്ചുവെക്കാം.';

  @override
  String get helpJournalOrgIntro =>
      'ജീവിതത്തിലെ വിവിധ ഭാഗങ്ങൾ പ്രത്യേക ജേണലുകളായി സൂക്ഷിക്കുകയും റിച്ച് ടെക്സ്റ്റിൽ മനോഹരമായി എഴുതുകയും ചെയ്യുക.';

  @override
  String get helpJournalOrgSectionMultiple => 'വ്യത്യസ്ത ജേണലുകൾ';

  @override
  String get helpJournalOrgMultipleBullet1 =>
      'വ്യക്തിപരം, ജോലി, യാത്ര, ആശയങ്ങൾ എന്നിവയ്ക്കായി പ്രത്യേക ജേണലുകൾ സൃഷ്ടിക്കുക.';

  @override
  String get helpJournalOrgMultipleBullet2 =>
      'മുകളിലുള്ള ജേണൽ സെലക്ടർ വഴി എളുപ്പത്തിൽ ജേണലുകൾ മാറ്റാം.';

  @override
  String get helpJournalOrgSectionTemplates => 'ടെംപ്ലേറ്റുകൾ ഉപയോഗിക്കൽ';

  @override
  String get helpJournalOrgTemplatesBullet1 =>
      'പുതിയ കുറിപ്പ് തുടങ്ങുമ്പോൾ 8 റെഡിമെയ്ഡ് ടെംപ്ലേറ്റുകളിൽ നിന്ന് തിരഞ്ഞെടുക്കാം.';

  @override
  String get helpJournalOrgTemplatesBullet2 =>
      'ക്രമീകരണങ്ങൾ → ടെംപ്ലേറ്റുകൾ വഴി പുതിയവ നിർമ്മിക്കുകയോ മാറ്റങ്ങൾ വരുത്തുകയോ ചെയ്യാം.';

  @override
  String get helpJournalOrgSectionRichText => 'റിച്ച് ടെക്സ്റ്റ് ഫോർമാറ്റിംഗ്';

  @override
  String get helpJournalOrgRichTextBullet1 =>
      'ബോൾഡ്, ഇറ്റാലിക്, ഹെഡിംഗുകൾ, ലിസ്റ്റുകൾ, ടേബിളുകൾ, ഡ്രോയിംഗുകൾ എന്നിവ ഉപയോഗിച്ച് എഴുതുക.';

  @override
  String get helpScreenshotAuditIntro =>
      'സ്ക്രീൻ വിവരങ്ങൾ ചോരുന്നത് തടയുന്നതിനെക്കുറിച്ചും സുരക്ഷാ ലോഗുകളെക്കുറിച്ചും അറിയുക.';

  @override
  String get helpScreenshotAuditSectionGuard =>
      'സ്ക്രീൻഷോട്ട് ഗാർഡ് (FLAG_SECURE)';

  @override
  String get helpScreenshotAuditGuardBullet1 =>
      'ആപ്പ് സ്ക്രീൻഷോട്ടുകൾ, റെക്കോർഡിംഗുകൾ, സമീപകാല ആപ്പ് പ്രിവ്യൂ എന്നിവ തടയുന്നു.';

  @override
  String get helpScreenshotAuditGuardBullet2 =>
      'ആവശ്യമെങ്കിൽ ക്രമീകരണങ്ങൾ → സുരക്ഷ വഴി ഇത് മാറ്റാം.';

  @override
  String get helpScreenshotAuditSectionLog => 'സുരക്ഷാ ഓഡിറ്റ് ലോഗുകൾ';

  @override
  String get helpScreenshotAuditLogBullet1 =>
      'പിൻ ശ്രമങ്ങളും എക്സ്പോർട്ടുകളും ക്രമീകരണങ്ങൾ → സുരക്ഷ → സുരക്ഷാ ലോഗുകളിൽ രേഖപ്പെടുത്തുന്നു.';

  @override
  String get helpSearchTimelineIntro =>
      'ഫുൾ-ടെക്സ്റ്റ് തിരയലും കലണ്ടർ ടൈംലൈനും വഴി മുൻകാല കുറിപ്പുകൾ കണ്ടെത്തുക.';

  @override
  String get helpSearchTimelineSectionFts =>
      'SQLite ഫുൾ-ടെക്സ്റ്റ് തിരയൽ (FTS)';

  @override
  String get helpSearchTimelineFtsBullet1 =>
      'കുറിപ്പുകളിലെ എല്ലാ വാക്കുകളിലും ഉടനടി തിരയൽ നടത്താം.';

  @override
  String get helpSearchTimelineSectionPresets => 'സേവ് ചെയ്ത തിരയലുകൾ';

  @override
  String get helpSearchTimelinePresetsBullet1 =>
      'പതിവ് തിരയൽ ഫിൽട്ടറുകൾ ഒറ്റ ക്ലിക്കിൽ ഉപയോഗിക്കാൻ സേവ് ചെയ്യാം.';

  @override
  String get helpSearchTimelineSectionTimeline => 'കലണ്ടർ & ടൈംലൈൻ';

  @override
  String get helpSearchTimelineTimelineBullet1 =>
      'തീയതി അടിസ്ഥാനത്തിൽ മുൻകാല കുറിപ്പുകൾ ബ്രൗസ് ചെയ്യാം.';

  @override
  String get helpStorageMigrationIntro =>
      'അറ്റാച്ച്മെന്റുകൾ സൂക്ഷിക്കുന്ന സ്ഥലം നിയന്ത്രിക്കുകയും എസ്.ഡി. കാർഡിലേക്ക് മാറ്റുകയും ചെയ്യുക.';

  @override
  String get helpStorageMigrationSectionInternal => 'ആന്തരിക സംഭരണം';

  @override
  String get helpStorageMigrationInternalBullet1 =>
      'സാധാരണയായി അറ്റാച്ച്മെന്റുകൾ ആപ്പ്-പ്രൈവറ്റ് ആന്തരിക സംഭരണത്തിലാണ് സൂക്ഷിക്കുന്നത്.';

  @override
  String get helpStorageMigrationSectionSd => 'എസ്.ഡി. കാർഡ് സംഭരണ മാറ്റം';

  @override
  String get helpStorageMigrationSdBullet1 =>
      'ഫോൺ മെമ്മറി ലാഭിക്കാൻ ഫയലുകൾ ക്രമീകരണങ്ങൾ → സംഭരണം → സംഭരണം മാറ്റുക വഴി എസ്.ഡി. കാർഡിലേക്ക് മാറ്റാം.';

  @override
  String get helpStorageMigrationSdBullet2 =>
      'എസ്.ഡി. കാർഡിലും ഫയലുകൾ പൂർണ്ണമായും എൻക്രിപ്റ്റ് ചെയ്ത നിലയിലായിരിക്കും.';

  @override
  String get helpTagsIntro =>
      'വർണ്ണ ടാഗുകൾ ഉപയോഗിച്ച് എല്ലാ ജേണലുകളിലെയും കുറിപ്പുകൾ തരംതിരിക്കുക.';

  @override
  String get helpTagsSectionTagging => 'കുറിപ്പുകൾക്ക് ടാഗ് നൽകൽ';

  @override
  String get helpTagsTaggingBullet1 =>
      'എഡിറ്ററിലെ ടാഗ് ബാർ വഴി കുറിപ്പുകളിൽ ടാഗുകൾ ചേർക്കാം.';

  @override
  String get helpTagsSectionColors => 'ഇഷ്ടാനുസൃത വർണ്ണ കോഡിംഗ്';

  @override
  String get helpTagsColorsBullet1 =>
      'വിഷയങ്ങൾ എളുപ്പത്തിൽ തിരിച്ചറിയാൻ ടാഗുകൾക്ക് വ്യത്യസ്ത നിറങ്ങൾ നൽകാം.';

  @override
  String get helpTagsSectionCleanup => 'ടാഗ് മാനേജ്‌മെന്റ്';

  @override
  String get helpTagsCleanupBullet1 =>
      'ക്രമീകരണങ്ങൾ → ടാഗ് മാനേജർ വഴി ടാഗുകൾ പുനർനാമകരണം ചെയ്യുകയോ ഇല്ലാതാക്കുകയോ ചെയ്യാം.';

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
  String get tamperAlertsTitle => 'സുരക്ഷാ മുന്നറിയിപ്പുകൾ';

  @override
  String get tamperAlertsHowItWorksTitle =>
      'സുരക്ഷാ പരിശോധന എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get tamperAlertsHowItWorksBody =>
      'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട് ഘടനാപരമായ കൺസിസ്റ്റൻസിയും ടൈംസ്റ്റാമ്പ് ക്രമവും AES-256 എൻക്രിപ്റ്റ് ചെയ്ത റെക്കോർഡുകളുമായി പരിശോധിച്ച് ഉറപ്പുവരുത്തുന്നു.';

  @override
  String get tamperAlertsNoHistory =>
      'സുരക്ഷാ മുന്നറിയിപ്പുകളൊന്നുമില്ല. നിങ്ങളുടെ വോൾട്ട് സുരക്ഷിതമാണ്.';

  @override
  String get tamperAlertsHistoryHeader => 'സുരക്ഷാ മുന്നറിയിപ്പ് ചരിത്രം';

  @override
  String get tamperAlertsScanCompleteClean =>
      'വോൾട്ട് സ്കാനിംഗ് പൂർത്തിയായി: എല്ലാ കുറിപ്പുകളും സുരക്ഷിതമാണ്.';

  @override
  String tamperAlertsScanCompleteIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പ്രശ്നങ്ങൾ',
      one: '1 പ്രശ്നം',
    );
    return 'വോൾട്ട് സ്കാനിംഗിൽ $_temp0 കണ്ടെത്തി.';
  }

  @override
  String get tamperAlertsStatusIssues =>
      'മുന്നറിയിപ്പ് — സുരക്ഷാ വ്യതിയാനങ്ങൾ കണ്ടെത്തി';

  @override
  String tamperAlertsStatusIssuesDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'രേഖകളിൽ $count ഡാറ്റാ കൃത്യതാ പ്രശ്നങ്ങൾ കണ്ടെത്തി.',
      one: 'രേഖകളിൽ 1 ഡാറ്റാ കൃത്യതാ പ്രശ്നം കണ്ടെത്തി.',
    );
    return '$_temp0';
  }

  @override
  String get tamperAlertsStatusVerified => 'വോൾട്ട് കൃത്യത പരിശോധിച്ചു';

  @override
  String get tamperAlertsStatusVerifiedDetail =>
      'എല്ലാ ഡാറ്റാബേസ് ടേബിളുകളും കൺസിസ്റ്റൻസിയും പരിശോധിച്ചു. സിസ്റ്റം ആരോഗ്യകരമാണ്.';

  @override
  String get tamperAlertsVerifyButton => 'വോൾട്ട് കൃത്യത പരിശോധിക്കുക';

  @override
  String get tamperAlertsVerifying => 'വോൾട്ട് കൃത്യത പരിശോധിക്കുന്നു...';

  @override
  String get shareQuickCaptureTitle => 'പെട്ടെന്നുള്ള കുറിപ്പ് (Quick Capture)';

  @override
  String get shareQuickCaptureSubtitle =>
      'പങ്കിട്ട വിവരങ്ങൾ ഒരു പുതിയ കുറിപ്പായി സേവ് ചെയ്യുക';

  @override
  String get shareNoJournalsFound =>
      'ജേണലുകളൊന്നും കണ്ടെത്തിയില്ല. ആദ്യം ഒരു ജേണൽ ഉണ്ടാക്കുക.';

  @override
  String get shareSelectJournal => 'ജേണൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get shareEntryTitleLabel => 'കുറിപ്പ് തലക്കെട്ട്';

  @override
  String get shareEntryTitleHint => 'തലക്കെട്ട് നൽകുക (ഓപ്ഷണൽ)';

  @override
  String get shareContentLabel => 'ഉള്ളടക്കം';

  @override
  String get shareContentHint =>
      'പങ്കിട്ട കുറിപ്പ്, ലിങ്ക് അല്ലെങ്കിൽ ടെക്സ്റ്റ്...';

  @override
  String shareAttachmentsLabel(int count) {
    return 'അറ്റാച്ച്മെന്റുകൾ ($count)';
  }

  @override
  String get shareDiscard => 'ഉപേക്ഷിക്കുക';

  @override
  String get shareOpenInEditor => 'എഡിറ്ററിൽ തുറക്കുക';

  @override
  String get shareSaveToJournal => 'ജേണലിലേക്ക് സേവ് ചെയ്യുക';

  @override
  String get shareSaveFailed => 'പങ്കിട്ട വിവരങ്ങൾ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String shareSavedSuccess(String journalTitle) {
    return 'പങ്കിട്ട കുറിപ്പ് \"$journalTitle\" എന്നതിലേക്ക് സേവ് ചെയ്തു';
  }

  @override
  String get shareSealedFileDetected => 'എൻക്രിപ്റ്റ് ചെയ്ത ഫയൽ കണ്ടെത്തി';

  @override
  String get shareOpenEncryptedExport => 'എൻക്രിപ്റ്റ് ചെയ്ത ഫയൽ തുറക്കുക';

  @override
  String get templateCategoryCustom => 'സ്വന്തം ടെംപ്ലേറ്റുകൾ (Custom)';

  @override
  String get templateChooserManage => 'കൈകാര്യം ചെയ്യുക';

  @override
  String get templateChooserNew => 'പുതിയ ടെംപ്ലേറ്റ്';

  @override
  String get templateCollapseAll => 'എല്ലാം ചുരുക്കുക';

  @override
  String get templateExpandAll => 'എല്ലാം വികസിപ്പിക്കുക';

  @override
  String get templateCreateNew => 'പുതിയ ടെംപ്ലേറ്റ്';

  @override
  String get templateManagerTitle => 'സ്വന്തം ടെംപ്ലേറ്റുകൾ (Custom Templates)';

  @override
  String get templateEdit => 'ടെംപ്ലേറ്റ് തിരുത്തുക';

  @override
  String get templateDelete => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കുക';

  @override
  String get templateDeleteConfirmTitle => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കണോ?';

  @override
  String templateDeleteConfirmMessage(String name) {
    return '\"$name\" ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';
  }

  @override
  String get templateDeleteSuccess => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കി';

  @override
  String get templateEmpty =>
      'സ്വന്തം ടെംപ്ലേറ്റുകളൊന്നുമില്ല. നിങ്ങളുടെ പ്രിയപ്പെട്ട ലേഔട്ട് സേവ് ചെയ്യാൻ ഒരെണ്ണം സൃഷ്ടിക്കുക.';

  @override
  String get templateNameLabel => 'ടെംപ്ലേറ്റ് പേര്';

  @override
  String get templateNameHint => 'ഉദാ: പ്രതിദിന ചിന്തകൾ, മീറ്റിംഗ് കുറിപ്പുകൾ';

  @override
  String get templateNameRequired => 'ടെംപ്ലേറ്റ് പേര് നൽകുക.';

  @override
  String get templateDescriptionLabel => 'വിവരണം';

  @override
  String get templateDescriptionHint =>
      'ഈ ടെംപ്ലേറ്റ് എന്തിനാണെന്നുള്ള ലഘു വിവരണം';

  @override
  String get templateDefaultTitleLabel => 'ഡിഫോൾട്ട് കുറിപ്പ് തലക്കെട്ട്';

  @override
  String get templateDefaultTitleHint => 'e.g., Standup - today';

  @override
  String get templateContentLabel => 'ടെംപ്ലേറ്റ് ഉള്ളടക്കം';

  @override
  String get templateContentHint =>
      'നിങ്ങളുടെ കുറിപ്പിന്റെ ഉള്ളടക്ക മാതൃക ഇവിടെ എഴുതുക...';

  @override
  String get templateInsertTokenTooltip => 'ഡൈനാമിക് തീയതി ടോക്കൺ ചേർക്കുക';

  @override
  String get templateTokensHeading => 'ഡൈനാമിക് തീയതി ടോക്കണുകൾ';

  @override
  String get templateTokensHelper =>
      'ഡൈനാമിക് തീയതി ടോക്കണുകൾ പുതിയ കുറിപ്പ് തുടങ്ങുമ്പോൾ സ്വയമേവ ചേർക്കപ്പെടും.';

  @override
  String get templateSaveSuccess => 'ടെംപ്ലേറ്റ് സേവ് ചെയ്തു';

  @override
  String get templateSaveAsTemplate => 'ടെംപ്ലേറ്റായി സേവ് ചെയ്യുക';

  @override
  String get templateSaveAsTemplateTitle => 'പുതിയ ടെംപ്ലേറ്റ്';

  @override
  String get templateSaveAsTemplateDesc =>
      'ഈ കുറിപ്പിന്റെ ഘടന വീണ്ടും ഉപയോഗിക്കാവുന്ന ടെംപ്ലേറ്റായി സേവ് ചെയ്യുക.';

  @override
  String get settingsSectionHelp => 'സഹായം';

  @override
  String get settingsSectionHelpSubtitle =>
      'ഗൈഡുകൾ, എൻക്രിപ്ഷൻ വിവരങ്ങൾ, പതിവ് ചോദ്യങ്ങൾ';

  @override
  String get settingsSectionFeatures => 'സവിശേഷതകൾ';

  @override
  String get settingsSectionFeaturesSubtitle =>
      'ആപ്പിന്റെ പ്രധാന സവിശേഷതകൾ കാണുക';

  @override
  String get featuresHeaderTitle => 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട് സവിശേഷതകൾ';

  @override
  String get featuresHeaderSubtitle =>
      'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ടിന്റെ സമഗ്രമായ ടൂളുകളും സുരക്ഷാ സവിശേഷതകളും പര്യവേക്ഷണം ചെയ്യുക.';

  @override
  String entryWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വാക്കുകൾ',
      one: '1 വാക്ക്',
    );
    return '$_temp0';
  }

  @override
  String entryCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count അക്ഷരങ്ങൾ',
      one: '1 അക്ഷരം',
    );
    return '$_temp0';
  }

  @override
  String entryStatsSummary(String words, String chars) {
    return '$words • $chars';
  }

  @override
  String get entryDistractionFreeEnter =>
      'ശ്രദ്ധ തിരിയാത്ത മോഡ് (Distraction-free)';

  @override
  String get entryDistractionFreeExit => 'ശ്രദ്ധ തിരിയാത്ത മോഡ് ഒഴിവാക്കുക';

  @override
  String get entryFocusParagraphOn => 'ഫോക്കസ് പാരഗ്രാഫ്: ഓൺ';

  @override
  String get entryFocusParagraphOff => 'ഫോക്കസ് പാരഗ്രാഫ്: ഓഫ്';

  @override
  String get entryAutoSaving => 'സേവ് ചെയ്യുന്നു…';

  @override
  String entryAutoSaved(String time) {
    return '$time-ൽ സേവ് ചെയ്തു';
  }

  @override
  String get entryAutoSavedJustNow => 'ഇപ്പോൾ സേവ് ചെയ്തു';

  @override
  String get entryUnsavedChanges => 'സേവ് ചെയ്യാത്ത മാറ്റങ്ങൾ';

  @override
  String get entryEditorScanText =>
      'ചിത്രത്തിൽ നിന്ന് ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുക';

  @override
  String get entryEditorOcrSourceTitle => 'ടെക്സ്റ്റ് സ്കാൻ ചെയ്യേണ്ട ഉറവിടം';

  @override
  String get entryEditorScanSourceCamera => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get entryEditorScanSourceGallery => 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get entryEditorOcrScanning =>
      'ചിത്രത്തിൽ നിന്ന് ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുന്നു...';

  @override
  String get entryEditorOcrNoTextFound =>
      'ചിത്രത്തിൽ ടെക്സ്റ്റ് കണ്ടെത്താൻ കഴിഞ്ഞില്ല.';

  @override
  String get entryEditorOcrError =>
      'ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുന്നത് പരാജയപ്പെട്ടു.';

  @override
  String get entryEditorCropImageTitle => 'ചിത്രം ക്രോപ്പ് ചെയ്യുക & തിരിക്കുക';

  @override
  String get entryEditorCropImageError =>
      'ചിത്രം ക്രോപ്പ് ചെയ്യുന്നത് പരാജയപ്പെട്ടു.';

  @override
  String get appearanceThemeModeTitle => 'തീം മോഡ്';

  @override
  String get appearanceThemeModeSubtitle =>
      'വെളിച്ചം, ഇരുട്ട് അല്ലെങ്കിൽ സിസ്റ്റം ഡിഫോൾട്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get appearanceAccentColorTitle => 'പ്രധാന വർണ്ണ തീം';

  @override
  String get appearanceAccentColorSubtitle =>
      'ആപ്പിന്റെ പ്രധാന ബട്ടണുകളുടെയും ഹൈലൈറ്റുകളുടെയും നിറം മാറ്റുക';

  @override
  String get appearanceLivePreview => 'തത്സമയ പ്രിവ്യൂ';

  @override
  String get appearancePresets => 'വർണ്ണ പ്രീസെറ്റുകൾ';

  @override
  String get appearanceCustomWheel => 'കളർ വീൽ (Custom)';

  @override
  String get appearanceSampleText => 'മാതൃകാ ജേണൽ കുറിപ്പ്';

  @override
  String get appearanceResetDefault => 'ഡിഫോൾട്ടിലേക്ക് പുനഃക്രമീകരിക്കുക';

  @override
  String get appearanceContrastNote =>
      'വായനാസൗകര്യത്തിനായി ടെക്സ്റ്റ് കോൺട്രാസ്റ്റ് സ്വയമേവ ക്രമീകരിക്കും.';

  @override
  String get appearanceSystemModeExplainer =>
      'സിസ്റ്റം മോഡ് ഫോണിലെ ഡാർക്ക് മോഡ് ക്രമീകരണത്തിന് അനുസരിച്ച് സ്വയമേവ മാറും.';

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
  String get featuresCatJournaling => 'എഴുത്തും എഡിറ്ററും';

  @override
  String get featuresCatJournalingSub =>
      'റിച്ച് ടെക്സ്റ്റ്, ടെംപ്ലേറ്റുകൾ, ഒ.സി.ആർ., മീഡിയ';

  @override
  String get featuresCatSecurity => 'സുരക്ഷ & എൻക്രിപ്ഷൻ';

  @override
  String get featuresCatSecuritySub => 'പൂർണ്ണ ഓഫ്‌ലൈൻ സുരക്ഷയും എൻക്രിപ്ഷനും';

  @override
  String get featuresCatSearch => 'തിരയൽ, ടൈംലൈൻ & സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get featuresCatSearchSub =>
      'ഫുൾ-ടെക്സ്റ്റ് തിരയൽ, കലണ്ടർ, സ്ഥിതിവിവരക്കണക്കുകൾ';

  @override
  String get featuresCatStorage => 'സംഭരണം, ബാക്കപ്പ് & എക്സ്പോർട്ട്';

  @override
  String get featuresCatStorageSub =>
      'പൂർണ്ണ ഓഫ്‌ലൈൻ സുരക്ഷ, സംഭരണ മാറ്റം, എക്സ്പോർട്ട്';

  @override
  String get helpHeaderTitle => 'സഹായ കേന്ദ്രവും അറിവുകളും';

  @override
  String get helpHeaderSubtitle =>
      'ആപ്പിന്റെ എല്ലാ സവിശേഷതകളെയും കുറിച്ചുള്ള സമഗ്രമായ ഗൈഡുകളും പതിവ് ചോദ്യങ്ങളും.';

  @override
  String get helpSectionWriting => 'എഴുത്തും ജേണൽ ക്രമീകരണവും';

  @override
  String get helpSectionSecurity => 'സുരക്ഷ, ലോക്ക് & എൻക്രിപ്ഷൻ';

  @override
  String get helpSectionSearch => 'തിരയൽ, ടൈംലൈൻ & സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get helpSectionStorage => 'സംഭരണം, ബാക്കപ്പ് & എക്സ്പോർട്ട്';

  @override
  String get helpSectionFaq => 'പതിവ് ചോദ്യങ്ങൾ (FAQ)';

  @override
  String get editorInsertDrawing => 'രേഖാചിത്രം ചേർക്കുക';

  @override
  String get drawingCanvasTitle => 'വരയ്ക്കലും സ്കെച്ചും (Drawing & Sketch)';

  @override
  String get drawingCanvasEditTitle => 'രേഖാചിത്രം തിരുത്തുക';

  @override
  String get drawingCanvasPen => 'പേന';

  @override
  String get drawingCanvasHighlighter => 'ഹൈലൈറ്റർ';

  @override
  String get drawingCanvasEraser => 'ഇറേസർ';

  @override
  String get drawingCanvasClear => 'ക്യാൻവാസ് മായ്ക്കുക';

  @override
  String get drawingCanvasClearConfirm => 'മുഴുവൻ ഡ്രോയിംഗും മായ്ക്കണോ?';

  @override
  String get drawingCanvasStrokeWidth => 'വരയുടെ വീതി';

  @override
  String get drawingCanvasColor => 'നിറം';

  @override
  String get drawingCanvasBackground => 'പശ്ചാത്തലം';

  @override
  String get drawingCanvasBgBlank => 'വെള്ള പേപ്പർ';

  @override
  String get drawingCanvasBgRuled => 'വരയുള്ള പേപ്പർ';

  @override
  String get drawingCanvasBgGrid => 'ഗ്രിഡ് പേപ്പർ';

  @override
  String get drawingCanvasBgDots => 'ഡോട്ട് പേപ്പർ';

  @override
  String get drawingCanvasUndo => 'പഴയപടിയാക്കുക';

  @override
  String get drawingCanvasRedo => 'വീണ്ടും ചെയ്യുക';

  @override
  String get drawingCanvasSave => 'പൂർത്തിയായി';

  @override
  String get drawingCanvasDiscardTitle => 'രേഖാചിത്രം ഉപേക്ഷിക്കണോ?';

  @override
  String get drawingCanvasDiscardMessage =>
      'നിങ്ങൾ വരുത്തിയ മാറ്റങ്ങൾ സേവ് ചെയ്യപ്പെടില്ല.';

  @override
  String get drawingEditTooltip => 'രേഖാചിത്രം തിരുത്തുക';

  @override
  String get drawingSizeTooltip => 'രേഖാചിത്ര വലിപ്പം';

  @override
  String get drawingDeleteTooltip => 'രേഖാചിത്രം നീക്കം ചെയ്യുക';

  @override
  String get drawingUnavailable => 'രേഖാചിത്രം ലഭ്യമല്ല';

  @override
  String get drawingLoading => 'രേഖാചിത്രം ലോഡ് ചെയ്യുന്നു...';

  @override
  String get drawingSaveError => 'ഡ്രോയിംഗ് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get journalManageTemplates => 'സ്വന്തം ടെംപ്ലേറ്റുകൾ';

  @override
  String get helpTitle => 'സഹായം';

  @override
  String get featuresTitle => 'സവിശേഷതകൾ';

  @override
  String get featureOfflineTitle => '100% ഓഫ്‌ലൈൻ & നെറ്റ്‌വർക്ക് അനുമതികളില്ല';

  @override
  String get featureOfflineDesc =>
      'ഈ ആപ്പിൽ ഇന്റർനെറ്റ് അനുമതികളോ കോഡോ ഇല്ല. നിങ്ങളുടെ എല്ലാ വിവരങ്ങളും ഫോണിൽ മാത്രം സുരക്ഷിതമായിരിക്കും.';

  @override
  String get ritualScreenTitle => 'പ്രതിദിന ധ്യാനചര്യ';

  @override
  String get ritualDeckBrowserTitle => 'ചിന്താ കാർഡുകൾ';

  @override
  String get ritualResetReviewsTooltip => 'ഇടവേളകൾ പുനഃക്രമീകരിക്കുക';

  @override
  String get ritualResetReviewsTitle => 'എല്ലാ കാർഡുകളും പുനഃക്രമീകരിക്കുക';

  @override
  String get ritualResetReviewsConfirm =>
      'ഇത് എല്ലാ 18 കാർഡുകളുടെയും റിവിഷൻ ലെവലുകൾ റീസെറ്റ് ചെയ്യും. തുടരണോ?';

  @override
  String get ritualResetReviewsDone =>
      'കാർഡുകളുടെ റിവിഷൻ സമയം പുനഃക്രമീകരിച്ചു.';

  @override
  String get ritualAllThemes => 'എല്ലാ വിഷയങ്ങളും';

  @override
  String get ritualSrsNew => 'പുതിയത്';

  @override
  String get ritualSrsDueToday => 'ഇന്ന് ചെയ്യേണ്ടത്';

  @override
  String ritualSrsInDays(int days) {
    return '$days ദിവസത്തിൽ';
  }

  @override
  String get ritualStepBreathe => 'ശ്വാസം';

  @override
  String get ritualStepReflect => 'ചിന്ത';

  @override
  String get ritualStepWrite => 'എഴുത്ത്';

  @override
  String get ritualBreatheHeading => 'മനസ്സമാധാന ശ്വസനം';

  @override
  String get ritualSkipToPrompt => 'നേരെ ചിന്താ കാർഡിലേക്ക്';

  @override
  String get ritualContinueToCard => 'തുടരുക';

  @override
  String get ritualShuffleCard => 'മറ്റൊരു കാർഡ് എടുക്കുക';

  @override
  String get ritualSrsRatePrompt =>
      'ഈ വിഷയം ചിന്തിക്കാൻ എത്രത്തോളം എളുപ്പമായിരുന്നു?';

  @override
  String get ritualSrsHard => 'കഠിനം';

  @override
  String get ritualSrsHardSubtitle => 'നാളെ വീണ്ടും കാണുക';

  @override
  String get ritualSrsRevision => 'ശ്രദ്ധിക്കുക';

  @override
  String get ritualSrsRevisionSubtitle => '3 ദിവസത്തിൽ';

  @override
  String get ritualSrsEasy => 'ലളിതം';

  @override
  String get ritualSrsEasySubtitle => '+7 ദിവസങ്ങൾ';

  @override
  String get ritualProceedToJournal => 'എഴുത്തിലേക്ക് കടക്കുക';

  @override
  String get ritualReadyToWriteTitle => 'എഴുതാൻ തയ്യാറാണോ?';

  @override
  String ritualReadyToWriteDesc(String cardTitle) {
    return '\"$cardTitle\" എന്ന ആശയത്തിൽ നിന്നും നിങ്ങളുടെ ചിന്തകൾ ഇന്നത്തെ ജേണലിൽ കുറിക്കാം.';
  }

  @override
  String get ritualBeginWritingButton => 'എഴുത്ത് ആരംഭിക്കുക';

  @override
  String get ritualCompletePracticeOnly => 'ധ്യാനം മാത്രം പൂർത്തിയാക്കുക';

  @override
  String get ritualSettingsTitle => 'ധ്യാനചര്യ ക്രമീകരണങ്ങൾ';

  @override
  String get ritualLaunchOnStartupTitle => 'ആപ്പ് തുറക്കുമ്പോൾ ധ്യാനചര്യ';

  @override
  String get ritualLaunchOnStartupSubtitle =>
      'ആപ്പ് തുറക്കുമ്പോൾ തന്നെ ശ്വസന വ്യായാമവും ചിന്താ കാർഡും കാണിക്കുക';

  @override
  String get ritualBreathTechniqueLabel => 'ശ്വാസ രീതി';

  @override
  String ritualBreathCyclesLabel(int count) {
    return 'ശ്വാസ ചക്രങ്ങൾ: $count';
  }

  @override
  String get commonReset => 'റീസെറ്റ്';

  @override
  String get ritualHomeCardTitle => 'പ്രതിദിന ധ്യാനചര്യ';

  @override
  String get ritualHomeCardSubtitle =>
      'ലളിതമായ ശ്വസന വ്യായാമത്തോടും ചിന്താ കാർഡിനോടും കൂടി ദിവസം ആരംഭിക്കുക';

  @override
  String get ritualHomeCardAction => 'ആരംഭിക്കുക';

  @override
  String get ritualSettingsTileTitle => 'ധ്യാനചര്യ & ചിന്താ കാർഡുകൾ';

  @override
  String get ritualSettingsTileSubtitle =>
      'ശ്വാസ ടൈമർ, 18 ചിന്താ കാർഡുകൾ & ആവർത്തന ഓർമ്മപ്പെടുത്തൽ';

  @override
  String get featureRitualTitle => 'ധ്യാനചര്യയും ചിന്താ കാർഡുകളും';

  @override
  String get featureRitualDesc =>
      'മനസ്സ് ശാന്തമാക്കാനുള്ള ശ്വാസ ടൈമർ, 18 ചിന്താ കാർഡുകൾ, സ്പേസ്ഡ് റെപ്പറ്റീഷൻ റിവിഷൻ, നേരിട്ട് ജേണലിലേക്ക് കടക്കാനുള്ള സൗകര്യം.';

  @override
  String get syncLandingTitle => 'ഡിവൈസ് സിങ്ക് (Wi-Fi)';

  @override
  String get syncLandingSubtitle =>
      'ക്ലൗഡ് സെർവറുകളുടെ ആവശ്യമില്ലാതെ ലോക്കൽ വൈ-ഫൈ വഴി നേരിട്ട് മാറ്റങ്ങളും അറ്റാച്ച്മെന്റുകളും കൈമാറുക';

  @override
  String get syncSendTitle => 'ഡാറ്റ അയക്കുക (Host)';

  @override
  String get syncSendSubtitle =>
      'ക്യുആർ കോഡ് കാണിച്ച് മറ്റൊരു ഉപകരണത്തിലേക്ക് ജേണൽ വിവരങ്ങൾ സുരക്ഷിതമായി അയക്കുക';

  @override
  String get syncReceiveTitle => 'ഡാറ്റ സ്വീകരിക്കുക (Client)';

  @override
  String get syncReceiveSubtitle =>
      'മറ്റൊരു ഉപകരണത്തിൽ നിന്നുള്ള ക്യുആർ കോഡ് സ്കാൻ ചെയ്ത് മാറ്റങ്ങൾ ഇവിടെ സമന്വയിപ്പിക്കുക';

  @override
  String get syncHostTitle => 'ഡാറ്റ അയക്കൽ (Host)';

  @override
  String get syncClientTitle => 'ഡാറ്റ സ്വീകരിക്കൽ (Client)';

  @override
  String get syncTabQrScan => 'ക്യുആർ സ്കാൻ';

  @override
  String get syncTabManualEntry => 'വിവരങ്ങൾ നൽകുക';

  @override
  String get syncTabConnection => 'കണക്ഷൻ';

  @override
  String get syncIpLabel => 'ലോക്കൽ ഐപി അഡ്രസ്സ്';

  @override
  String get syncPortLabel => 'പോർട്ട്';

  @override
  String get syncPairingCodeLabel => 'പെയറിംഗ് കോഡ്';

  @override
  String get syncStatusListening =>
      'മറ്റൊരു ഉപകരണത്തിന്റെ കണക്ഷനായി കാത്തിരിക്കുന്നു...';

  @override
  String get syncStatusConnected =>
      'ഉപകരണം ബന്ധിപ്പിച്ചു, സുരക്ഷിതമായി സ്ഥിരീകരിച്ചു';

  @override
  String get syncStatusCompleted => 'സിങ്ക് വിജയകരമായി പൂർത്തിയായി!';

  @override
  String get syncStatusDenied => 'കണക്ഷൻ നിരസിച്ചു: തെറ്റായ പെയറിംഗ് കോഡ്';

  @override
  String get syncStatusStopped => 'സിങ്ക് സെർവർ നിർത്തി';

  @override
  String get syncStatusError => 'സിങ്ക് സെർവറിൽ തകരാർ';

  @override
  String get syncButtonStart => 'സെർവർ ആരംഭിക്കുക';

  @override
  String get syncButtonStop => 'സെർവർ നിർത്തുക';

  @override
  String get syncButtonConnect => 'കണക്റ്റ് ചെയ്ത് സിങ്ക് ചെയ്യുക';

  @override
  String get syncScanInstructions =>
      'അയക്കുന്ന ഉപകരണത്തിലെ ക്യുആർ കോഡിന് നേരെ ക്യാമറ പിടിക്കുക';

  @override
  String get syncHostAddressHint => 'ഉദാ: 192.168.1.5';

  @override
  String get syncPortHint => 'ഉദാ: 54321';

  @override
  String get syncCodeHint => '16 അക്ഷര പെയറിംഗ് കോഡ്';

  @override
  String get syncNoWifiAlert =>
      'ലോക്കൽ വൈ-ഫൈ / ഐപി കണ്ടെത്താനായില്ല. ഇരു ഉപകരണങ്ങളും ഒരേ വൈ-ഫൈയിലോ ഹോട്ട്‌സ്പോട്ടിലോ ആണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get syncPairingCodeCopied => 'പെയറിംഗ് കോഡ് കോപ്പി ചെയ്തു';

  @override
  String get airqrTitle => 'ഓപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് സിങ്ക് (AirQR)';

  @override
  String get airqrIntro =>
      'നെറ്റ്‌വർക്ക് കണക്ഷനുകൾ ഇല്ലാതെ ആനിമേഷൻ ക്യുആർ കോഡുകൾ വഴി ക്രമീകരണങ്ങളും ജേണലുകളും നേരിട്ട് കൈമാറുക.';

  @override
  String get airqrSendTitle => 'എയർക്യുആർ വഴി അയക്കുക';

  @override
  String get airqrReceiveTitle => 'എയർക്യുആർ വഴി സ്വീകരിക്കുക';

  @override
  String get airqrReceive => 'ഡാറ്റ സ്വീകരിക്കുക (സ്കാനർ)';

  @override
  String get airqrReceiveSubtitle =>
      'മറ്റൊരു ഉപകരണത്തിൽ നിന്നുള്ള ആനിമേഷൻ ക്യുആർ സ്കാൻ ചെയ്യുക';

  @override
  String get airqrSyncSettingsTitle => 'ക്രമീകരണങ്ങൾ സിങ്ക് ചെയ്യുക';

  @override
  String get airqrSyncSettingsSubtitle =>
      'തീം, ആക്സെന്റ് നിറം, സുരക്ഷ, ധ്യാനചര്യ & ടെംപ്ലേറ്റുകൾ (< 1 സെക്കൻഡ്)';

  @override
  String get airqrSyncJournalTitle => 'ഒരു ജേണൽ സിങ്ക് ചെയ്യുക';

  @override
  String get airqrSyncJournalSubtitle =>
      'ഒരു ജേണലിലെ കുറിപ്പുകൾ തിരഞ്ഞെടുത്ത് കൈമാറുക';

  @override
  String get airqrTooLargeTitle => 'ഫയൽ വലുപ്പം വളരെ കൂടുതലാണ്';

  @override
  String get airqrSlowTitle => 'വലിയ തോതിലുള്ള കൈമാറ്റം';

  @override
  String get airqrSendAnyway => 'തുടരുക';

  @override
  String get airqrSpeedNoteTitle => '100% ഓഫ്‌ലൈൻ & സുരക്ഷിതം';

  @override
  String get airqrSpeedNoteBody =>
      'എയർക്യുആർ ക്യാമറയും സ്ക്രീനും വഴി മാത്രമേ പ്രവർത്തിക്കൂ. വൈ-ഫൈ, ബ്ലൂടൂത്ത്, ഇന്റർനെറ്റ് എന്നിവ ആവശ്യമില്ല.';

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
