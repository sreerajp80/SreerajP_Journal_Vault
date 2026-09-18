// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get titleVaultUnavailable => 'വോൾട്ട് തുറക്കാൻ കഴിയില്ല';

  @override
  String get descVaultUnavailableKeyMissing =>
      'നിങ്ങളുടെ ജേണൽ അൺലോക്ക് ചെയ്യുന്ന കീ ഈ ഉപകരണത്തിൽ ലഭ്യമല്ല. അതില്ലാതെ വോൾട്ട് തുറക്കാൻ കഴിയില്ല.';

  @override
  String get descVaultUnavailableCipherMissing =>
      'ഈ ആപ്പ് ബിൽഡിന് വോൾട്ട് എൻക്രിപ്റ്റ് ചെയ്യാൻ കഴിയില്ല, അതിനാൽ സുരക്ഷിതമല്ലാത്ത ജേണൽ തുറക്കാതിരിക്കാൻ പ്രവർത്തനം നിർത്തിവെച്ചു.';

  @override
  String get errorVaultUnavailableConversion =>
      'നിങ്ങളുടെ ജേണൽ എൻക്രിപ്റ്റ് ചെയ്ത സംഭരണത്തിലേക്ക് മാറ്റാൻ കഴിഞ്ഞില്ല. മാറ്റങ്ങളൊന്നും വരുത്തിയിട്ടില്ല — ഡാറ്റയൊന്നും നഷ്ടപ്പെട്ടിട്ടില്ല.';

  @override
  String get descVaultUnavailableFileUnreadable =>
      'വോൾട്ട് ഫയൽ വായിക്കാൻ കഴിയില്ല. ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചിരിക്കാം അല്ലെങ്കിൽ മറ്റ് ഇൻസ്റ്റാളേഷന്റേതായിരിക്കാം.';

  @override
  String get descVaultUnavailableDataIntact =>
      'ഡാറ്റയൊന്നും നഷ്ടപ്പെട്ടിട്ടില്ല. നിങ്ങളുടെ കുറിപ്പുകളും അറ്റാച്ച്മെന്റുകളും ഉപകരണത്തിൽ സുരക്ഷിതമാണ്.';

  @override
  String get descVaultUnavailableNextSteps =>
      'ബാക്കപ്പ് ഫയൽ ഉണ്ടെങ്കിൽ, ആപ്പ് വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്ത് പുനഃസ്ഥാപിക്കുക. ഡാറ്റ ക്ലിയർ ചെയ്യരുത് — അത് വോൾട്ട് പൂർണ്ണമായി നഷ്ടപ്പെടുത്തും.';

  @override
  String get titleApp => 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്';

  @override
  String get titleAbout => 'വിവരങ്ങൾ';

  @override
  String get errorAboutLoad => 'ആപ്പ് വിവരങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get errorCommonRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get labelAboutVersionBuild => 'ആപ്പ് പതിപ്പ് / ബിൽഡ്';

  @override
  String get labelAboutLastBuild => 'അവസാന ബിൽഡ് സമയം';

  @override
  String get titlePermissions => 'അനുമതികൾ';

  @override
  String get titlePermissionsExplicit => 'പ്രത്യേക അനുമതികൾ';

  @override
  String get titlePermissionsImplicit => 'സാധാരണ അനുമതികൾ';

  @override
  String get labelPermissionStatusAllowed => 'അനുവദിച്ചു';

  @override
  String get labelPermissionStatusDenied => 'നിരസിച്ചു';

  @override
  String get labelPermissionStatusPermanentlyDenied => 'സ്ഥിരമായി നിരസിച്ചു';

  @override
  String get labelPermissionStatusUserSelected => 'ഉപയോക്താവ് തിരഞ്ഞെടുത്തത്';

  @override
  String get actionPermissionsRequest => 'അഭ്യർത്ഥിക്കുക';

  @override
  String get actionPermissionsOpenSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get actionCommonCancel => 'റദ്ദാക്കുക';

  @override
  String get actionCommonDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get actionCommonSave => 'സേവ് ചെയ്യുക';

  @override
  String get titleTags => 'ടാഗുകൾ';

  @override
  String errorTagsLoad(String error) {
    return 'ടാഗുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get emptyTags => 'ടാഗുകളൊന്നും ലഭ്യമല്ല';

  @override
  String get descTagsAutomaticColour => 'സ്വയമേവയുള്ള നിറം';

  @override
  String get tooltipTagsActions => 'ടാഗ് പ്രവർത്തനങ്ങൾ';

  @override
  String get actionTagsRename => 'പേര് മാറ്റുക';

  @override
  String get actionTagsChooseColour => 'നിറം തിരഞ്ഞെടുക്കുക';

  @override
  String get actionTagsResetColour =>
      'സ്വയമേവയുള്ള നിറത്തിലേക്ക് പുനഃക്രമീകരിക്കുക';

  @override
  String get errorTagsRename =>
      'നൽകിയ പേര് ശൂന്യമാണ് അല്ലെങ്കിൽ മറ്റൊരു ടാഗ് നിലവിലുണ്ട്.';

  @override
  String bodyTagsDeleted(String name) {
    return '#$name ഇല്ലാതാക്കി.';
  }

  @override
  String get bodyTagsDelete => 'ടാഗ് ഇല്ലാതാക്കണോ?';

  @override
  String bodyTagsDeleteBody(String name) {
    return '\"#$name\" ഇല്ലാതാക്കണോ? ഇത് ഉപയോഗിക്കുന്ന എല്ലാ ജേണലുകളിൽ നിന്നും കുറിപ്പുകളിൽ നിന്നും നീക്കം ചെയ്യപ്പെടും.';
  }

  @override
  String get titleTagsRename => 'ടാഗ് പേര് മാറ്റുക';

  @override
  String get labelTagsName => 'ടാഗ് പേര്';

  @override
  String errorCommon(String message) {
    return 'പിശക്: $message';
  }

  @override
  String get descCommonUntitledEntry => 'തലക്കെട്ടില്ലാത്ത കുറിപ്പ്';

  @override
  String get descCommonUntitled => 'തലക്കെട്ടില്ലാത്തത്';

  @override
  String get titleTimeline => 'ടൈംലൈൻ';

  @override
  String get emptyTimelineNoEntriesForDate =>
      'തിരഞ്ഞെടുത്ത തീയതിയിൽ കുറിപ്പുകളൊന്നുമില്ല.';

  @override
  String get labelTimelineCalendarFormatMonth => 'മാസം';

  @override
  String get labelTimelineDayCountOverflow => '9+';

  @override
  String get titleInsights => 'സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get titleInsightsStreak => 'എഴുത്ത് തുടർച്ച (Streak)';

  @override
  String get labelInsightsStreakCurrent => 'നിലവിലെ';

  @override
  String get labelInsightsStreakLongest => 'മികച്ച';

  @override
  String get labelInsightsStreakUnitDays => 'ദിവസങ്ങൾ';

  @override
  String labelInsightsStreakStat(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String labelInsightsLastEntry(String date) {
    return 'അവസാന കുറിപ്പ്: $date';
  }

  @override
  String get titleInsightsMood => 'വികാര പ്രവണതകൾ';

  @override
  String get emptyInsightsMood =>
      'വികാര വിവരങ്ങൾ ലഭ്യമല്ല.\nപ്രവണതകൾ കാണാൻ കുറിപ്പുകളിൽ വികാരം രേഖപ്പെടുത്തുക.';

  @override
  String descInsightsMood(String date, String mood, int count) {
    return '$date\nവികാരം: $mood\nകുറിപ്പുകൾ: $count';
  }

  @override
  String get titleInsightsTagHeatmap => 'ടാഗ് ഹീറ്റ്മാപ്പ്';

  @override
  String get emptyInsightsTagHeatmap =>
      'ഇതുവരെ ടാഗുകളൊന്നും ഉപയോഗിച്ചിട്ടില്ല.';

  @override
  String labelInsightsTag(String tag, int count) {
    return '$tag ($count)';
  }

  @override
  String get titleInsightsMemories => 'ഈ ദിവസം ഓർമ്മകളിൽ';

  @override
  String get emptyInsightsMemories =>
      'മുൻ വർഷങ്ങളിൽ ഈ തീയതിയിൽ കുറിപ്പുകളൊന്നുമില്ല.';

  @override
  String labelInsightsYearsAgo(int years) {
    return '${years}y';
  }

  @override
  String get titleInsightsReflection => 'പ്രതിവാര അവലോകനം';

  @override
  String get labelInsightsReflectionPeriod => 'കാലയളവ്';

  @override
  String get labelInsightsReflectionEntries => 'കുറിപ്പുകൾ';

  @override
  String get labelInsightsReflectionWords => 'എഴുതിയ വാക്കുകൾ';

  @override
  String get labelInsightsReflectionAverageMood => 'ശരാശരി വികാരം';

  @override
  String get labelInsightsReflectionTopTags => 'പ്രധാന ടാഗുകൾ';

  @override
  String get labelInsightsReflectionStreak => 'നിലവിലെ സ്ട്രീക്ക്';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസങ്ങൾ',
      one: '1 ദിവസം',
    );
    return '$_temp0';
  }

  @override
  String get actionCommonClose => 'അടയ്ക്കുക';

  @override
  String get errorCommonUnknown => 'അജ്ഞാതമായ പിശക് സംഭവിച്ചു.';

  @override
  String get titleImport => 'ഇംപോർട്ട്';

  @override
  String get bodyImportSelecting => 'ഫയലുകൾ തിരഞ്ഞെടുക്കുന്നു...';

  @override
  String get actionImportSelectFiles => 'ഫയലുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get titleImportResults => 'ഇംപോർട്ട് ഫലങ്ങൾ';

  @override
  String get labelImportFileSucceeded => 'വിജയകരമായി ഇംപോർട്ട് ചെയ്തു';

  @override
  String descImportCountSucceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഫയലുകൾ വിജയകരമായി ഇംപോർട്ട് ചെയ്തു',
      one: '1 ഫയൽ വിജയകരമായി ഇംപോർട്ട് ചെയ്തു',
    );
    return '$_temp0';
  }

  @override
  String get emptyAttachmentArchive => 'ഈ ആർക്കൈവിൽ ഫയലുകളൊന്നുമില്ല.';

  @override
  String get descAttachmentOpenWith => 'മറ്റൊരു ആപ്പിൽ തുറക്കുക...';

  @override
  String get titleAttachmentUnsupported => 'പിന്തുണയ്ക്കാത്ത ഫയൽ തരം';

  @override
  String bodyAttachmentUnsupported(String fileName) {
    return '$fileName ആപ്പിനുള്ളിൽ നേരിട്ട് കാണിക്കാൻ കഴിയില്ല.';
  }

  @override
  String get bodyAttachmentPdfMissing =>
      'ഡീക്രിപ്റ്റ് ചെയ്ത ഫയൽ ഇപ്പോൾ ലഭ്യമല്ല.';

  @override
  String errorAttachmentPdfOpen(String reason) {
    return 'പി.ഡി.എഫ്. തുറക്കാൻ കഴിഞ്ഞില്ല: $reason';
  }

  @override
  String get titleAutoLock => 'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകൾ';

  @override
  String get actionAutoLockNewProfile => 'പുതിയ പ്രൊഫൈൽ';

  @override
  String get tooltipAutoLockEditProfile => 'പ്രൊഫൈൽ തിരുത്തുക';

  @override
  String get emptyAutoLock =>
      'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകളൊന്നും നിലവിലില്ല. നിഷ്ക്രിയമാകുമ്പോൾ ആപ്പ് ലോക്കാകാൻ ഒരെണ്ണം സൃഷ്ടിക്കുക.';

  @override
  String get tooltipAutoLockDeleteProfile => 'പ്രൊഫൈൽ ഇല്ലാതാക്കുക';

  @override
  String get tooltipAutoLockActivate => 'സജീവമാക്കുക';

  @override
  String get tooltipAutoLockDeactivate => 'പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String descAutoLock(String timeout, String lockOnMinimize, String active) {
    return '$timeout$lockOnMinimize$active';
  }

  @override
  String get labelAutoLockSuffixLockOnMinimize =>
      ' • മിനിമൈസ് ചെയ്യുമ്പോൾ ലോക്കാക്കുക';

  @override
  String get labelAutoLockSuffixActive => ' • സജീവം';

  @override
  String labelAutoLockTimeoutSeconds(int seconds) {
    return '$seconds സെക്കൻഡ്';
  }

  @override
  String labelAutoLockTimeoutMinutes(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String labelAutoLockTimeoutHours(String hours) {
    return '$hours മണിക്കൂർ';
  }

  @override
  String get labelAutoLockName => 'പ്രൊഫൈൽ പേര്';

  @override
  String get labelAutoLockTimeout => 'സമയപരിധി';

  @override
  String get labelAutoLockLockOnMinimize =>
      'മിനിമൈസ് ചെയ്യുമ്പോൾ ഉടൻ ലോക്കാക്കുക';

  @override
  String get errorAutoLockName => 'പ്രൊഫൈൽ പേര് നൽകുക.';

  @override
  String get errorAutoLockTimeout => 'സമയപരിധി പോസിറ്റീവ് സംഖ്യയായിരിക്കണം.';

  @override
  String get titleSecurityEvents => 'സുരക്ഷാ ഇവന്റുകൾ';

  @override
  String get emptySecurityEvents =>
      'സുരക്ഷാ ഇവന്റുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.';

  @override
  String get titleSecurityEventDetails => 'സുരക്ഷാ ഇവന്റ് വിവരങ്ങൾ';

  @override
  String get titleSyncConflicts => 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ';

  @override
  String errorSyncConflictsLoad(String error) {
    return 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get emptySyncNoConflicts => 'സിങ്ക് വൈരുദ്ധ്യങ്ങളൊന്നുമില്ല.';

  @override
  String get emptySyncAllInSync => 'എല്ലാ ഡാറ്റയും സമന്വയിപ്പിച്ചിരിക്കുന്നു.';

  @override
  String labelSyncDetectedAt(String timestamp) {
    return 'കണ്ടെത്തിയത്: $timestamp';
  }

  @override
  String get titleSyncChangedFields => 'മാറിയ ഫീൽഡുകൾ:';

  @override
  String get actionSyncCompare => 'താരതമ്യം ചെയ്യുക';

  @override
  String get actionSyncKeepRemote => 'റിമോട്ട് പതിപ്പ് സൂക്ഷിക്കുക';

  @override
  String get actionSyncKeepLocal => 'ലോക്കൽ പതിപ്പ് സൂക്ഷിക്കുക';

  @override
  String get bodySyncKeepLocal => 'ലോക്കൽ പതിപ്പ് നിലനിർത്തണോ?';

  @override
  String get bodySyncKeepRemote => 'റിമോട്ട് പതിപ്പ് നിലനിർത്തണോ?';

  @override
  String get bodySyncKeepLocalBody =>
      'റിമോട്ട് മാറ്റങ്ങൾ ഒഴിവാക്കപ്പെടും. അടുത്ത സിങ്കിൽ ഈ ഉപകരണത്തിലെ പതിപ്പ് കൈമാറും.';

  @override
  String get bodySyncKeepRemoteBody =>
      'ഈ ഉപകരണത്തിലെ മാറ്റങ്ങൾ മാറ്റിസ്ഥാപിക്കപ്പെട്ട് റിമോട്ട് പതിപ്പ് സ്വീകരിക്കും.';

  @override
  String get bodyCommon => 'സ്ഥിരീകരിക്കുക';

  @override
  String get bodySyncConflictResolved => 'വൈരുദ്ധ്യം പരിഹരിച്ചു';

  @override
  String errorSyncResolution(String error) {
    return 'വൈരുദ്ധ്യം പരിഹരിക്കാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get titleSyncConflictDetails => 'വൈരുദ്ധ്യ വിവരങ്ങൾ';

  @override
  String get titleSyncColumnField => 'ഫീൽഡ്';

  @override
  String get titleSyncColumnLocal => 'ലോക്കൽ';

  @override
  String get titleSyncColumnRemote => 'റിമോട്ട്';

  @override
  String get titleSyncHealth => 'സിങ്ക് ആരോഗ്യം';

  @override
  String get labelSyncLastSync => 'അവസാന സിങ്ക്';

  @override
  String get errorSyncFailures7d => 'പരാജയങ്ങൾ (7 ദിവസത്തിൽ)';

  @override
  String get labelSyncPendingConflicts => 'തീർപ്പുകൽപ്പിക്കാത്ത വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get bodyCommonLoading => 'ലോഡ് ചെയ്യുന്നു...';

  @override
  String get errorCommonErrorShort => 'പിശക്';

  @override
  String get bodyCommonEllipsis => '...';

  @override
  String get labelSyncNever => 'ഒരിക്കലുമില്ല';

  @override
  String actionSyncResolveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വൈരുദ്ധ്യങ്ങൾ പരിഹരിച്ചു',
      one: '1 വൈരുദ്ധ്യം പരിഹരിച്ചു',
    );
    return '$_temp0';
  }

  @override
  String get actionSyncNow => 'ഇപ്പോൾ സമന്വയിപ്പിക്കുക';

  @override
  String get titleSyncRecentActivity => 'സമീപകാല പ്രവർത്തനം';

  @override
  String errorSyncLogsLoad(String error) {
    return 'ലോഗുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get emptySyncNoActivity => 'സമന്വയ പ്രവർത്തനങ്ങളൊന്നുമില്ല.';

  @override
  String get labelSyncStatusIdle => 'സമന്വയം സജ്ജമാണ്';

  @override
  String get descSyncStatusSyncing => 'മാറ്റങ്ങൾ കൈമാറുന്നു...';

  @override
  String get labelSyncStatusHealthy => 'ആരോഗ്യം';

  @override
  String get errorSyncStatus => 'പരാജയപ്പെട്ടു';

  @override
  String get labelSyncStatusConflicts => 'വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get errorSyncLog => 'സമന്വയം പരാജയപ്പെട്ടു';

  @override
  String labelSyncLogPushed(int count) {
    return '$count അയച്ചു';
  }

  @override
  String labelSyncLogPulled(int count) {
    return '$count സ്വീകരിച്ചു';
  }

  @override
  String labelSyncLogConflicts(int count) {
    return '$count വൈരുദ്ധ്യങ്ങൾ';
  }

  @override
  String get labelSyncLogNoChanges => 'മാറ്റങ്ങളൊന്നുമില്ല';

  @override
  String get tooltipCommonRefresh => 'പുതുക്കുക';

  @override
  String get titleBackup => 'ബാക്കപ്പും പുനഃസ്ഥാപിക്കലും';

  @override
  String get actionBackupNow => 'ഇപ്പോൾ ബാക്കപ്പ് എടുക്കുക';

  @override
  String get bodyBackupInProgress => 'ബാക്കപ്പ് ഫയൽ തയ്യാറാക്കുന്നു...';

  @override
  String get titleBackupHistory => 'ബാക്കപ്പ് ചരിത്രം';

  @override
  String get titleBackupStatus => 'ബാക്കപ്പ് നില';

  @override
  String get bodyBackupNoneYet => 'ഇതുവരെ ബാക്കപ്പുകളൊന്നും എടുത്തിട്ടില്ല.';

  @override
  String get labelBackupLastBackup => 'അവസാന ബാക്കപ്പ്';

  @override
  String get labelBackupEntries => 'കുറിപ്പുകൾ';

  @override
  String get labelBackupAttachments => 'അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get labelBackupSize => 'വലിപ്പം';

  @override
  String errorBackupRecentFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'കഴിഞ്ഞ 7 ദിവസത്തിൽ $count പരാജയപ്പെട്ട ബാക്കപ്പുകൾ',
      one: 'കഴിഞ്ഞ 7 ദിവസത്തിൽ 1 പരാജയപ്പെട്ട ബാക്കപ്പ്',
    );
    return '$_temp0';
  }

  @override
  String get titleBackupSchedule => 'ഓട്ടോമാറ്റിക് ബാക്കപ്പ് ഓർമ്മപ്പെടുത്തൽ';

  @override
  String labelBackupScheduled(String interval) {
    return 'ഷെഡ്യൂൾ ചെയ്തത്: $interval';
  }

  @override
  String get bodyBackupNotScheduled => 'ഷെഡ്യൂൾ ചെയ്തിട്ടില്ല';

  @override
  String get labelBackupTimerActive => 'സജീവം';

  @override
  String get labelBackupTimerInactive => 'നിഷ്ക്രിയം';

  @override
  String get labelBackupLastScheduledRun => 'അവസാനം പ്രവർത്തിച്ച സമയം';

  @override
  String get actionBackupDisable => 'പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get actionBackupConfigure => 'ക്രമീകരിക്കുക';

  @override
  String get actionBackupChange => 'മാറ്റുക';

  @override
  String get titleBackupConfigure => 'ഷെഡ്യൂൾ ക്രമീകരിക്കുക';

  @override
  String get labelBackupInterval => 'ഇടവേള';

  @override
  String get labelBackupIntervalDaily => 'ദിവസേന';

  @override
  String get labelBackupIntervalWeekly => 'ആഴ്ചയിലൊരിക്കൽ';

  @override
  String get labelBackupIntervalMonthly => 'മാസത്തിലൊരിക്കൽ';

  @override
  String get labelBackupPassword => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get labelBackupPasswordHelper => 'എൻക്രിപ്ഷന് ആവശ്യം';

  @override
  String get emptyBackupNoHistory => 'ബാക്കപ്പ് ചരിത്രമില്ല';

  @override
  String errorBackupHistoryLoad(String error) {
    return 'ചരിത്രം ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String titleBackupLog(String trigger, String status) {
    return '$trigger ബാക്കപ്പ് — $status';
  }

  @override
  String get labelBackupTriggerManual => 'സ്വയം ചെയ്തത്';

  @override
  String get labelBackupTriggerScheduled => 'ഷെഡ്യൂൾ ചെയ്തത്';

  @override
  String get labelBackupStatusSuccess => 'വിജയം';

  @override
  String get errorBackupStatus => 'പരാജയം';

  @override
  String get labelBackupStatusInProgress => 'നടക്കുന്നു';

  @override
  String descBackupLogCounts(int entries, int attachments, String size) {
    return '$entries കുറിപ്പുകൾ, $attachments അറ്റാച്ച്മെന്റുകൾ, $size';
  }

  @override
  String get bodyBackupInProgressNote => 'പ്രക്രിയ നടക്കുന്നു...';

  @override
  String get labelBackupSucceeded => 'ബാക്കപ്പ് വിജയകരമായി പൂർത്തിയായി';

  @override
  String errorBackup(String error) {
    return 'ബാക്കപ്പ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get titleBackupPassword => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get labelBackupPasswordEnter => 'എൻക്രിപ്ഷൻ പാസ്‌വേഡ് നൽകുക';

  @override
  String get actionBackup => 'ബാക്കപ്പ്';

  @override
  String get errorBackupPassword => 'പാസ്‌വേഡ് നൽകേണ്ടത് നിർബന്ധമാണ്';

  @override
  String get labelBackupScheduleSaved => 'ബാക്കപ്പ് ഷെഡ്യൂൾ സേവ് ചെയ്തു';

  @override
  String get labelBackupScheduleDisabled =>
      'ബാക്കപ്പ് ഷെഡ്യൂൾ പ്രവർത്തനരഹിതമാക്കി';

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
  String get actionCommonRestore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get actionCommonInsert => 'ചേർക്കുക';

  @override
  String get actionCommonContinue => 'തുടരുക';

  @override
  String get actionCommonOpenSystemSettings => 'സിസ്റ്റം ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get descEditorCallout => 'കോൾഔട്ട് വിവരണം ഇവിടെ എഴുതുക...';

  @override
  String get tabEditorInsert => 'ടാബ് ചേർക്കുക';

  @override
  String get tooltipEditorInsertTable => 'പട്ടിക ചേർക്കുക';

  @override
  String get tooltipEditorInsertCallout => 'കോൾഔട്ട് ചേർക്കുക';

  @override
  String get tooltipEditorInsertImage => 'ചിത്രം ചേർക്കുക';

  @override
  String get tooltipEditorImageSize => 'ചിത്രത്തിന്റെ വലിപ്പം';

  @override
  String get labelEditorImageSizeSmall => 'ചെറുത്';

  @override
  String get labelEditorImageSizeMedium => 'ഇടത്തരം';

  @override
  String get labelEditorImageSizeFull => 'പൂർണ്ണ വീതി';

  @override
  String get tooltipEditorRemoveImage => 'ചിത്രം നീക്കം ചെയ്യുക';

  @override
  String get labelEditorImageUnavailable => 'ചിത്രം ലഭ്യമല്ല';

  @override
  String get bodyEditorMicPermissionDenied => 'മൈക്രോഫോൺ അനുമതി നിരസിച്ചു.';

  @override
  String get actionEditorDiscard => 'മാറ്റങ്ങൾ ഒഴിവാക്കുക';

  @override
  String get actionEditorDone => 'പൂർത്തിയായി';

  @override
  String get titleVersionHistory => 'പതിപ്പ് ചരിത്രം (റിവിഷനുകൾ)';

  @override
  String errorVersionHistoryLoad(String error) {
    return 'പതിപ്പുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get bodyVersionRestore => 'ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കണോ?';

  @override
  String get labelVersionRestored => 'പതിപ്പ് പുനഃസ്ഥാപിച്ചു';

  @override
  String get tooltipVersionPreview => 'പ്രിവ്യൂ കാണുക';

  @override
  String get tooltipVersionRestore => 'ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കുക';

  @override
  String titleVersionPreview(String title) {
    return 'പ്രിവ്യൂ: $title';
  }

  @override
  String get labelEntrySaved => 'കുറിപ്പ് സേവ് ചെയ്തു';

  @override
  String get bodyEntryDelete => 'കുറിപ്പ് ഇല്ലാതാക്കണോ?';

  @override
  String get bodyEntryDeleteBody => 'ഈ കുറിപ്പ് സ്ഥിരമായി നീക്കം ചെയ്യും.';

  @override
  String get labelEntryTableRows => 'വരികൾ (1-20)';

  @override
  String get labelEntryTableColumns => 'നിരകൾ (1-20)';

  @override
  String get labelEntryTableDimensionHelp => '1-20';

  @override
  String get titleEntryCalloutType => 'കോൾഔട്ട് തരം';

  @override
  String get labelEntryCalloutInfo => 'വിവരം (Info)';

  @override
  String get labelEntryCalloutTip => 'സൂചന (Tip)';

  @override
  String get bodyEntryCallout => 'മുന്നറിയിപ്പ് (Warning)';

  @override
  String get labelEntryCalloutImportant => 'പ്രധാനം (Important)';

  @override
  String labelEntryVoiceNoteSaved(String seconds) {
    return 'വോയ്സ് നോട്ട് സേവ് ചെയ്തു ($seconds സെക്കൻഡ്)';
  }

  @override
  String get titleEntryEdit => 'കുറിപ്പ് തിരുത്തുക';

  @override
  String get titleEntryEditTitleDirty => 'കുറിപ്പ് തിരുത്തുക •';

  @override
  String get tooltipEntryVersionHistory => 'പതിപ്പ് ചരിത്രം';

  @override
  String get tooltipEntryDelete => 'കുറിപ്പ് ഇല്ലാതാക്കുക';

  @override
  String get tooltipEntrySave => 'സേവ് ചെയ്യുക';

  @override
  String get tooltipEntryNoUnsavedChanges => 'സേവ് ചെയ്യാത്ത മാറ്റങ്ങളില്ല';

  @override
  String get labelEntryTitle => 'തലക്കെട്ട്';

  @override
  String get bodyEntryPermission => 'അറ്റാച്ച്മെന്റ് ചേർക്കാൻ അനുമതി നൽകണോ?';

  @override
  String get bodyEntryPermissionBody =>
      'ഫയലുകൾ ചേർക്കുന്നതിന് ഈ ആപ്പിന് അനുമതി ആവശ്യമാണ്.';

  @override
  String get titleEntryPermissionBlocked =>
      'അറ്റാച്ച്മെന്റ് അനുമതി തടഞ്ഞിരിക്കുന്നു';

  @override
  String get bodyEntryPermissionBlocked =>
      'അനുമതി സ്ഥിരമായി നിരസിച്ചിരിക്കുന്നു. സിസ്റ്റം ക്രമീകരണങ്ങളിൽ ഇത് ഓണാക്കുക.';

  @override
  String get bodyEntryNotAnImage =>
      'തിരഞ്ഞെടുത്ത ഫയൽ ഒരു ചിത്രമല്ല. അറ്റാച്ച്മെന്റായി ചേർക്കുക.';

  @override
  String get errorEntryImageAdd => 'ചിത്രം ചേർക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get tooltipEntryAddAttachment => 'അറ്റാച്ച്മെന്റ് ചേർക്കുക';

  @override
  String get tooltipEntryRecordVoiceNote => 'വോയ്സ് നോട്ട് റെക്കോർഡ് ചെയ്യുക';

  @override
  String get titleEntryLinkedFrom => 'ലിങ്ക് ചെയ്ത ഉറവിടം';

  @override
  String get tooltipEntryMood => 'മൂഡ് നിശ്ചയിക്കുക';

  @override
  String get titleEntryMood => 'വികാരം';

  @override
  String labelEntryMood(String face, int level) {
    return '$face $level';
  }

  @override
  String get errorEntryAuth => 'പ്രാമാണീകരണം ആവശ്യമാണ്.';

  @override
  String get bodyAttachmentOpenNoApp =>
      'ഈ ഫയൽ തുറക്കാൻ അനുയോജ്യമായ ആപ്പ് ഫോണിൽ ലഭ്യമല്ല.';

  @override
  String get errorAttachmentOpenDecrypt =>
      'അറ്റാച്ച്മെന്റ് ഡീക്രിപ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get bodyAttachmentOpenFileMissing => 'അറ്റാച്ച്മെന്റ് ഫയൽ ലഭ്യമല്ല.';

  @override
  String get bodyAttachmentOpenPermissionDenied =>
      'ഫയൽ തുറക്കാൻ സംഭരണ അനുമതി ആവശ്യമാണ്.';

  @override
  String get titleEntryAttachments => 'അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get tooltipEntryRemoveAttachmentLock =>
      'അറ്റാച്ച്മെന്റ് ലോക്ക് മാറ്റുക';

  @override
  String get tooltipEntryLockAttachment => 'അറ്റാച്ച്മെന്റ് ലോക്ക് ചെയ്യുക';

  @override
  String get tooltipEntryOpenAttachment => 'അറ്റാച്ച്മെന്റ് തുറക്കുക';

  @override
  String get bodyVersionRestoreBody =>
      'നിലവിലെ കുറിപ്പ് പുതിയൊരു പതിപ്പായി സേവ് ചെയ്ത ശേഷമായിരിക്കും ഈ പതിപ്പ് പുനഃസ്ഥാപിക്കുക.';

  @override
  String get actionCommonUnlock => 'അൺലോക്ക്';

  @override
  String get labelCommonPassword => 'പാസ്‌വേഡ്';

  @override
  String get bodyCommonSaving => 'സേവ് ചെയ്യുന്നു...';

  @override
  String get titleLockSetup => 'ആപ്പ് സുരക്ഷ ക്രമീകരിക്കുക';

  @override
  String get bodyLockSetup =>
      'നിങ്ങളുടെ ജേണൽ വോൾട്ട് എങ്ങനെ സംരക്ഷിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get labelLockModePhone => 'ഫോൺ ലോക്ക്';

  @override
  String get descLockModePhone =>
      'ഫോണിലെ ഫിംഗർപ്രിന്റ്, ഫേസ് അൺലോക്ക് അല്ലെങ്കിൽ പാസ്‌കോഡ് ഉപയോഗിക്കുന്നു.';

  @override
  String get labelLockModeApp => 'പ്രത്യേക ആപ്പ് പിൻ';

  @override
  String get descLockModeApp =>
      'ഫോൺ ലോക്കിൽ നിന്ന് വ്യത്യസ്തമായ പ്രത്യേക 4-6 അക്ക പിൻ സജ്ജീകരിക്കുക.';

  @override
  String get labelLockPin => 'പിൻ';

  @override
  String get labelLockConfirmPin => 'പിൻ സ്ഥിരീകരിക്കുക';

  @override
  String get bodyLockSettingUp => 'ക്രമീകരിക്കുന്നു...';

  @override
  String get errorLockPin => 'പിന്നിൽ കുറഞ്ഞത് 4 അക്കങ്ങൾ വേണം.';

  @override
  String get bodyLockPinsDoNotMatch => 'പിൻ പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String errorLockSetupSave(String error) {
    return 'ലോക്ക് ക്രമീകരണം സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String errorLockPinSave(String error) {
    return 'പിൻ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get titleLockPinSetup => 'ആപ്പ്-ലോക്ക് പിൻ സജ്ജീകരിക്കുക';

  @override
  String get bodyLockPinSetup =>
      'ആപ്പ് ലോക്കിനായി ഒരു പിൻ ആവശ്യമാണ്. തുടരാൻ ഒരെണ്ണം നൽകുക.';

  @override
  String get labelLockGateHeadline => 'നിങ്ങളുടെ ജേണൽ ലോക്ക് ചെയ്തിരിക്കുന്നു';

  @override
  String get descLockGate => 'കുറിപ്പുകൾ കാണാൻ അൺലോക്ക് ചെയ്യുക.';

  @override
  String get tooltipLockGateShowPin => 'പിൻ കാണിക്കുക';

  @override
  String get tooltipLockGateHidePin => 'പിൻ മറയ്ക്കുക';

  @override
  String get labelLockGateBadge => 'ലോക്ക് ചെയ്തത്';

  @override
  String get actionLockUnlockWithPhone =>
      'ഫോൺ ലോക്ക് ഉപയോഗിച്ച് അൺലോക്ക് ചെയ്യുക';

  @override
  String get errorLockAuth => 'പ്രാമാണീകരണം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get bodyLockAuthUnavailable =>
      'ഉപകരണ പ്രാമാണീകരണം ലഭ്യമല്ല. ഫോൺ ക്രമീകരണങ്ങളിൽ പിൻ അല്ലെങ്കിൽ ബയോമെട്രിക്സ് സജ്ജീകരിക്കുക.';

  @override
  String get bodyLockEnterPin => 'നിങ്ങളുടെ ആപ്പ് പിൻ നൽകുക';

  @override
  String get bodyLockIncorrectPin => 'തെറ്റായ പിൻ. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleLockedAttachments => 'ലോക്ക് ചെയ്ത അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get emptyLockedAttachments =>
      'ലോക്ക് ചെയ്ത അറ്റാച്ച്മെന്റുകളൊന്നുമില്ല.';

  @override
  String labelLockedAttachmentSince(String date) {
    return 'ലോക്ക് ചെയ്ത തീയതി: $date';
  }

  @override
  String get actionLockedAttachmentRemove => 'ലോക്ക് നീക്കം ചെയ്യുക';

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
  String get bodyJournalDelete => 'ജേണൽ ഇല്ലാതാക്കണോ?';

  @override
  String bodyJournalDeleteBody(String title) {
    return '\"$title\" ഇല്ലാതാക്കണോ?';
  }

  @override
  String get tooltipJournalManageTags => 'ടാഗുകൾ കൈകാര്യം ചെയ്യുക';

  @override
  String get tooltipJournalNew => 'പുതിയ ജേണൽ';

  @override
  String get tooltipJournalEdit => 'ജേണൽ തിരുത്തുക';

  @override
  String get tooltipJournalDelete => 'ജേണൽ ഇല്ലാതാക്കുക';

  @override
  String get emptyJournal => 'ഇതുവരെ ജേണലുകളൊന്നുമില്ല';

  @override
  String get emptyJournalEmptyBody =>
      'എഴുതിത്തുടങ്ങാൻ \"പുതിയ ജേണൽ\" അമർത്തുക.';

  @override
  String get labelJournalTitle => 'തലക്കെട്ട്';

  @override
  String get labelJournalDescription => 'വിവരണം';

  @override
  String get labelJournalTags => 'ടാഗുകൾ (കോമ ഉപയോഗിച്ച് വേർതിരിക്കുക)';

  @override
  String get labelJournalLockSwitch => 'ജേണൽ ലോക്ക് ചെയ്യുക';

  @override
  String get labelJournalConfirmPassword => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get actionJournalAddEntry => 'കുറിപ്പ് ചേർക്കുക';

  @override
  String get labelJournalIsLocked => 'ജേണൽ ലോക്ക് ചെയ്തിരിക്കുന്നു';

  @override
  String get labelJournalUnlocked => 'അൺലോക്ക് ചെയ്തു';

  @override
  String get bodyJournalIncorrectPassword => 'തെറ്റായ പാസ്‌വേഡ്.';

  @override
  String get titleSettingsSectionSecurity => 'സുരക്ഷ';

  @override
  String get descSettingsSectionSecurity =>
      'ലോക്ക് മോഡ്, ഓട്ടോ-ലോക്ക്, സ്ക്രീൻഷോട്ട് തടയൽ, സുരക്ഷാ ലോഗുകൾ';

  @override
  String get titleSettingsSectionAppearance => 'രൂപഭംഗി';

  @override
  String get descSettingsSectionAppearance => 'തീം, ആപ്പിന്റെ കാഴ്ച രീതികൾ';

  @override
  String get titleSettingsSectionStorage => 'സംഭരണം';

  @override
  String get descSettingsSectionStorage =>
      'അറ്റാച്ച്മെന്റ് സംഭരണം, ബാക്കപ്പ്, പുനഃസ്ഥാപിക്കൽ, ഇംപോർട്ട്';

  @override
  String get titleSettingsSectionPermissions => 'അനുമതികൾ';

  @override
  String get descSettingsSectionPermissions =>
      'ആപ്പ് ഉപയോഗിക്കുന്ന സിസ്റ്റം അനുമതികൾ';

  @override
  String get titleSettingsSectionAbout => 'വിവരങ്ങൾ';

  @override
  String get descSettingsSectionAbout => 'പതിപ്പ്, ലൈസൻസുകൾ, മറ്റ് വിവരങ്ങൾ';

  @override
  String get labelSettingsAppLockMode => 'ആപ്പ് ലോക്ക് മോഡ്';

  @override
  String get labelSettingsAutoLockTimeout => 'ഓട്ടോ-ലോക്ക് സമയം';

  @override
  String get labelSettingsScreenSecurity => 'സ്ക്രീൻഷോട്ട് തടയുക';

  @override
  String get descSettingsScreenSecurity =>
      'സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സമീപകാല ആപ്പ് പ്രിവ്യൂ എന്നിവ തടയുന്നു';

  @override
  String get bodySettingsScreenSecurityOff => 'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കണോ?';

  @override
  String get bodySettingsScreenSecurityOffBody =>
      'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കിയാൽ ആർക്കും നിങ്ങളുടെ ജേണൽ സ്ക്രീൻ പകർത്താൻ കഴിയും. ഇത് എപ്പോൾ വേണമെങ്കിലും വീണ്ടും ഓണാക്കാം.';

  @override
  String get actionSettingsScreenSecurityOff => 'ഓഫാക്കുക';

  @override
  String get bodySettingsScreenSecurityUpdatedOn =>
      'സ്ക്രീൻഷോട്ട് തടയൽ ഓണാക്കി';

  @override
  String get bodySettingsScreenSecurityUpdatedOff =>
      'സ്ക്രീൻഷോട്ട് തടയൽ ഓഫാക്കി';

  @override
  String get errorSettingsScreenSecuritySave =>
      'സ്ക്രീൻഷോട്ട് ക്രമീകരണം മാറ്റാൻ കഴിഞ്ഞില്ല';

  @override
  String get labelSettingsTamperAlerts => 'സുരക്ഷാ മുന്നറിയിപ്പുകൾ';

  @override
  String get labelSettingsSyncConflicts => 'സിങ്ക് വൈരുദ്ധ്യങ്ങൾ';

  @override
  String get labelSettingsSecurityEvents => 'സുരക്ഷാ ലോഗുകൾ';

  @override
  String get labelSettingsThemeLight => 'വെളിച്ചം (Light)';

  @override
  String get labelSettingsThemeDark => 'ഇരുട്ട് (Dark)';

  @override
  String get labelSettingsThemeSystem => 'സിസ്റ്റം (System)';

  @override
  String get bodySettingsSwitchLock => 'ലോക്ക് മോഡ് മാറ്റണോ?';

  @override
  String bodySettingsSwitchLockBody(String enabled, String disabled) {
    return 'ഇത് ആപ്പ് സംരക്ഷണം $enabled എന്നതിലേക്ക് മാറ്റുകയും $disabled പ്രവർത്തനരഹിതമാക്കുകയും ചെയ്യും. തുടരണോ?';
  }

  @override
  String get actionSettingsSwitch => 'മാറ്റുക';

  @override
  String descSettingsLockModeUpdated(String mode) {
    return 'ലോക്ക് മോഡ് മാറ്റി: $mode ഇപ്പോൾ സജീവമാണ്.';
  }

  @override
  String get errorSettingsThemeSave => 'തീം ക്രമീകരണം സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String descSettingsThemeUpdated(String mode) {
    return 'തീം മാറ്റി: $mode മോഡ് സജീവമാക്കി.';
  }

  @override
  String get bodyStorageMigrate => 'സംഭരണം മാറ്റുക (Migrate Storage)';

  @override
  String bodyStorageMigrateBody(String target) {
    return 'എല്ലാ അറ്റാച്ച്മെന്റുകളും $target-ലേക്ക് മാറ്റും.';
  }

  @override
  String get actionStorageMigrate => 'മാറ്റുക';

  @override
  String get bodyStorageMigrationCancelled => 'സംഭരണ മാറ്റം റദ്ദാക്കി.';

  @override
  String errorStorageMigration(String error) {
    return 'സംഭരണ മാറ്റം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get bodyStorageMigrationComplete => 'സംഭരണ മാറ്റം പൂർത്തിയായി.';

  @override
  String get titleStorageLocation => 'അറ്റാച്ച്മെന്റ് സംഭരണ സ്ഥലം';

  @override
  String get titleStorageLocationDialogTitle => 'സംഭരണ സ്ഥലം';

  @override
  String get labelStorageAppPrivate => 'ആപ്പ്-പ്രൈവറ്റ് മെമ്മറി';

  @override
  String get labelStorageSdCard => 'എസ്.ഡി. കാർഡ്';

  @override
  String labelStorageSdCardNamed(String label) {
    return 'എസ്.ഡി. കാർഡ് ($label)';
  }

  @override
  String get labelStorageMigrateRow => 'സംഭരണം മാറ്റുക';

  @override
  String get labelStorageMigrationIdle => 'നിഷ്ക്രിയം';

  @override
  String descStorageMigrationRunning(int processed, int total) {
    return '$total-ൽ $processed ഫയലുകൾ മാറ്റുന്നു…';
  }

  @override
  String get descStorageMigrationFailedShort => 'സംഭരണ മാറ്റം പരാജയപ്പെട്ടു.';

  @override
  String get labelStorageUsage => 'സംഭരണ ഉപയോഗം';

  @override
  String get bodyStorageUnknown => 'ലഭ്യമല്ല';

  @override
  String get labelStorageBackupHealth => 'ബാക്കപ്പ് ആരോഗ്യം';

  @override
  String get labelStorageImportData => 'ഡാറ്റ ഇംപോർട്ട് ചെയ്യുക';

  @override
  String get titleStorageSyncHealth => 'സിങ്ക് ആരോഗ്യം';

  @override
  String get bodyStorageImportNeedsJournal =>
      'ഇംപോർട്ട് ചെയ്യുന്നതിന് മുൻപ് ഒരു ജേണൽ ഉണ്ടാക്കുക.';

  @override
  String get titleStorageImportChooseJournal => 'ജേണലിലേക്ക് ഇംപോർട്ട് ചെയ്യുക';

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
  String get titleMigration => 'ഫയലുകൾ മാറ്റുന്നു';

  @override
  String get bodyMigrationCancelling => 'റദ്ദാക്കുന്നു...';

  @override
  String labelMigrationProgress(String processed, String total) {
    return '$total-ൽ $processed';
  }

  @override
  String get descMigrationUnknownTotal => '?';

  @override
  String get labelPermissionStatusRow => 'അനുമതി നില';

  @override
  String get labelPermissionsManage => 'അനുമതികൾ കൈകാര്യം ചെയ്യുക';

  @override
  String get labelPermissionsOpenSystem => 'സിസ്റ്റം ക്രമീകരണങ്ങൾ';

  @override
  String descPermissionsGranted(int granted, int total) {
    return '$granted / $total അനുമതികൾ അനുവദിച്ചു';
  }

  @override
  String get descSearch => 'കുറിപ്പുകൾ, ടാഗുകൾ, ഉള്ളടക്കം എന്നിവ തിരയുക...';

  @override
  String get actionSearchTypeToSearch => 'തിരയാൻ ഇവിടെ ടൈപ്പ് ചെയ്യുക...';

  @override
  String get bodySearchNoFilterMatches =>
      'ഫിൽട്ടറുമായി പൊരുത്തപ്പെടുന്ന ഫലങ്ങളില്ല.';

  @override
  String get emptySearch => 'ഫലങ്ങളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get titleSearchSectionJournals => 'ജേണലുകൾ';

  @override
  String get titleSearchSectionEntries => 'കുറിപ്പുകൾ';

  @override
  String get titleSearchSavePreset => 'തിരയൽ പ്രീസെറ്റ് സേവ് ചെയ്യുക';

  @override
  String get labelSearchPresetName => 'പ്രീസെറ്റ് പേര്';

  @override
  String get titleRestore => 'ബാക്കപ്പ് പുനഃസ്ഥാപിക്കുക';

  @override
  String get actionRestoreOpen => 'ബാക്കപ്പ് ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get titleRestoreLocked => 'ബാക്കപ്പ് പാസ്‌വേഡ് നൽകുക';

  @override
  String get bodyRestoreLocked =>
      'ഈ ബാക്കപ്പ് ഫയൽ എൻക്രിപ്റ്റ് ചെയ്തിരിക്കുന്നു.';

  @override
  String get actionRestoreUnlock => 'അൺലോക്ക്';

  @override
  String get labelRestoreUnlockReason =>
      'ബാക്കപ്പ് പുനഃസ്ഥാപിക്കാൻ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get errorRestoreUnlock =>
      'തെറ്റായ പാസ്‌വേഡ്. ബാക്കപ്പ് ഡീക്രിപ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get labelRestoreEnterPin => 'നിങ്ങളുടെ ആപ്പ് പിൻ നൽകുക';

  @override
  String get bodyRestorePinWrong => 'നൽകിയ പിൻ തെറ്റാണ്.';

  @override
  String get titleRestorePick => 'ബാക്കപ്പ് തിരഞ്ഞെടുക്കുക';

  @override
  String get actionRestorePickFromDevice => 'ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get bodyRestoreNoBackupsFound =>
      'ഈ ആപ്പ് ഉണ്ടാക്കിയ ബാക്കപ്പുകളൊന്നും കണ്ടെത്തിയില്ല. നിങ്ങൾക്ക് മറ്റൊരു ഫയൽ തിരഞ്ഞെടുക്കാം.';

  @override
  String labelRestoreSelectedFile(String fileName) {
    return 'തിരഞ്ഞെടുത്തത്: $fileName';
  }

  @override
  String get labelRestorePassword => 'ബാക്കപ്പ് പാസ്‌വേഡ്';

  @override
  String get bodyRestorePasswordHelper =>
      'ബാക്കപ്പ് എടുത്തപ്പോൾ നൽകിയ അതേ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get actionRestoreOpenBackup => 'ബാക്കപ്പ് തുറക്കുക';

  @override
  String get titleRestorePreview => 'ബാക്കപ്പിലെ ഉള്ളടക്കം';

  @override
  String labelRestorePreviewCreated(String date) {
    return 'ഉണ്ടാക്കിയ തീയതി: $date';
  }

  @override
  String bodyRestorePreviewCounts(int journals, int entries, int attachments) {
    return '$journals ജേണലുകൾ, $entries കുറിപ്പുകൾ, $attachments അറ്റാച്ച്മെന്റുകൾ';
  }

  @override
  String get bodyRestoreLegacyAttachments =>
      'ഇതൊരു പഴയ ബാക്കപ്പാണ്. ഇതിലെ അറ്റാച്ച്മെന്റുകൾ നിർമ്മിച്ച ഉപകരണത്തിൽ മാത്രമേ തുറക്കൂ.';

  @override
  String get bodyRestoreMode => 'എങ്ങനെ പുനഃസ്ഥാപിക്കണം?';

  @override
  String get actionRestoreModeMerge => 'നിലവിലെ ഡാറ്റയുമായി ലയിപ്പിക്കുക';

  @override
  String get descRestoreModeMergeDetail =>
      'ഇവിടെ ഇല്ലാത്തവ ചേർക്കുക, നിലവിലുള്ളവ നിലനിർത്തുക.';

  @override
  String get actionRestoreModeReplace => 'പൂർണ്ണമായി മാറ്റുക (Replace)';

  @override
  String get descRestoreModeReplaceDetail =>
      'ഇവിടെയുള്ളവ മായ്ച്ച് ബാക്കപ്പ് ഉപയോഗിക്കുക. നിലവിലെ വിവരങ്ങൾ ആദ്യം സുരക്ഷിതമായി ബാക്കപ്പ് ചെയ്യും.';

  @override
  String get actionRestoreDryRun => 'ആദ്യം പരീക്ഷിച്ച് നോക്കുക';

  @override
  String get bodyRestoreDryRunHelper =>
      'യഥാർത്ഥ മാറ്റങ്ങൾ വരുത്താതെ വിവരങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get actionRestore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get bodyRestoreConfirmReplace => 'എല്ലാം മാറ്റിയെഴുതണോ?';

  @override
  String get bodyRestoreConfirmReplaceBody =>
      'ഈ ഫോണിലെ എല്ലാ ജേണലുകളും കുറിപ്പുകളും മാറ്റി ബാക്കപ്പിലെ വിവരങ്ങൾ സ്ഥാപിക്കും. നിലവിലെ വിവരങ്ങൾ ഒരു സുരക്ഷാ ബാക്കപ്പായി സേവ് ചെയ്യും.';

  @override
  String get bodyRestoreConfirmMerge => 'ബാക്കപ്പ് ലയിപ്പിക്കണോ?';

  @override
  String get bodyRestoreConfirmMergeBody =>
      'ബാക്കപ്പിലുള്ളതും ഇവിടെയില്ലാത്തതുമായ വിവരങ്ങൾ ചേർക്കും. ഒന്നും ഇല്ലാതാക്കില്ല.';

  @override
  String get titleRestoreDryRunResult => 'എന്തൊക്കെ മാറ്റങ്ങൾ വരും';

  @override
  String get titleRestoreResult => 'പുനഃസ്ഥാപനം പൂർത്തിയായി';

  @override
  String labelRestoreResultAdded(int count) {
    return 'ചേർത്തവ: $count എണ്ണം';
  }

  @override
  String labelRestoreResultSkipped(int count) {
    return 'നേരത്തെയുള്ളവ: $count എണ്ണം';
  }

  @override
  String descRestoreResultFiles(int count) {
    return 'പുനഃസ്ഥാപിച്ച അറ്റാച്ച്മെന്റുകൾ: $count';
  }

  @override
  String errorRestoreResultFiles(int count) {
    return 'പുനഃസ്ഥാപിക്കാൻ കഴിയാത്ത ഫയലുകൾ: $count';
  }

  @override
  String get descRestoreResultSafetyBackup =>
      'നിലവിലെ ഡാറ്റയുടെ സുരക്ഷാ ബാക്കപ്പ് ആദ്യം സേവ് ചെയ്തു.';

  @override
  String get bodyRestoreErrorWrongPassword =>
      'തെറ്റായ പാസ്‌വേഡ് അല്ലെങ്കിൽ ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചു.';

  @override
  String get bodyRestoreErrorDamaged =>
      'ഈ ഫയൽ ഒരു ബാക്കപ്പ് അല്ല അല്ലെങ്കിൽ തകരാറിലാണ്.';

  @override
  String get bodyRestoreErrorTooNew =>
      'ഈ ബാക്കപ്പ് പുതിയ പതിപ്പ് ആപ്പിൽ ഉണ്ടാക്കിയതാണ്. ആപ്പ് അപ്ഡേറ്റ് ചെയ്ത് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorRestoreErrorPassword =>
      'ബാക്കപ്പ് പാസ്‌വേഡിൽ കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം.';

  @override
  String errorRestoreError(String error) {
    return 'പുനഃസ്ഥാപനം പരാജയപ്പെട്ടു, മാറ്റങ്ങളൊന്നും വരുത്തിയിട്ടില്ല: $error';
  }

  @override
  String get bodyRestoreWorking => 'പ്രവർത്തിക്കുന്നു...';

  @override
  String get titleExportProtect => 'എക്സ്പോർട്ട് സംരക്ഷണം';

  @override
  String get descExportProtect =>
      'എക്സ്പോർട്ട് ഫയൽ പാസ്‌വേഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുക';

  @override
  String get labelExportPassword => 'എക്സ്പോർട്ട് പാസ്‌വേഡ്';

  @override
  String get labelExportPasswordConfirm => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String errorExportPassword(int count) {
    return 'കുറഞ്ഞത് $count അക്ഷരങ്ങൾ ഉപയോഗിക്കുക.';
  }

  @override
  String get errorExportPasswordMismatch => 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String get bodyExportEncryptedNotice =>
      'ഈ പാസ്‌വേഡ് സുരക്ഷിതമായി സൂക്ഷിക്കുക. അതില്ലാതെ എക്സ്പോർട്ട് ചെയ്ത ഫയൽ ആർക്കും വീണ്ടും തുറക്കാൻ കഴിയില്ല.';

  @override
  String get titleOpenEncrypted => 'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് തുറക്കുക';

  @override
  String get descOpenEncryptedIntro =>
      'പാസ്‌വേഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത ജേണൽ എക്സ്പോർട്ട് ഫയലുകൾ (.jvep/.jvbk) വായിക്കുക.';

  @override
  String get actionOpenEncryptedPickFile => 'ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String labelOpenEncryptedChosenFile(String fileName) {
    return 'ഫയൽ: $fileName';
  }

  @override
  String get labelOpenEncryptedPassword => 'ഡീക്രിപ്ഷൻ പാസ്‌വേഡ്';

  @override
  String get actionOpenEncrypted => 'തുറന്ന് സേവ് ചെയ്യുക';

  @override
  String get bodyOpenEncryptedWorking => 'തുറക്കുന്നു...';

  @override
  String get titleOpenEncryptedSave => 'തുറന്ന ഫയൽ സേവ് ചെയ്യുക';

  @override
  String get descOpenEncryptedSaved =>
      'സേവ് ചെയ്തു. ഫയൽ ഇനി എൻക്രിപ്റ്റ് ചെയ്തതല്ല, അതിനാൽ സുരക്ഷിതമായി സൂക്ഷിക്കുക.';

  @override
  String get bodyOpenEncryptedCancelled => 'ഒന്നും സേവ് ചെയ്തിട്ടില്ല.';

  @override
  String get errorOpenEncryptedErrorWrongPassword =>
      'തെറ്റായ പാസ്‌വേഡ് അല്ലെങ്കിൽ ഫയലിന് കേടുപാടുകൾ സംഭവിച്ചു.';

  @override
  String get errorOpenEncryptedErrorNotSealed =>
      'ഇതൊരു എൻക്രിപ്റ്റ് ചെയ്ത ജേണൽ എക്സ്പോർട്ട് ഫയലല്ല.';

  @override
  String get errorOpenEncryptedErrorTooNew =>
      'ഈ ഫയൽ പുതിയ പതിപ്പ് ആപ്പിൽ ഉണ്ടാക്കിയതാണ്. ആപ്പ് അപ്ഡേറ്റ് ചെയ്യുക.';

  @override
  String get errorOpenEncryptedError => 'ഫയൽ തുറക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get actionSettingsOpenEncryptedExport =>
      'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് തുറക്കുക';

  @override
  String get titleTemplateChooser => 'ടെംപ്ലേറ്റ് തിരഞ്ഞെടുക്കുക';

  @override
  String get emptyVersionHistory =>
      'മുൻ പതിപ്പുകളൊന്നും ലഭ്യമല്ല.\n\nകുറിപ്പ് തിരുത്തുമ്പോൾ പതിപ്പുകൾ സ്വയമേവ സേവ് ചെയ്യപ്പെടും.';

  @override
  String get labelDrawingStrokeFine => 'നേർത്തത് (2px)';

  @override
  String get labelDrawingStrokeNormal => 'സാധാരണ (3.5px)';

  @override
  String get labelDrawingStrokeThick => 'കട്ടിയുള്ളത് (7px)';

  @override
  String get labelDrawingStrokeBold => 'വളരെ കട്ടിയുള്ളത് (14px)';

  @override
  String get titleDrawingDefault => 'രേഖാചിത്രം';

  @override
  String get titleImageDefault => 'ചിത്രം';

  @override
  String get bodyEditorImageLocked =>
      'ലോക്ക് ചെയ്ത ചിത്രം — അൺലോക്ക് ചെയ്യാൻ അമർത്തുക';

  @override
  String bodyEditorImageUnavailableWithName(String fileName) {
    return 'ചിത്രം ലഭ്യമല്ല — $fileName';
  }

  @override
  String get tooltipAudioPause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get tooltipAudioPlay => 'പ്ലേ ചെയ്യുക';

  @override
  String titleImportIntoJournal(String journalTitle) {
    return '\"$journalTitle\" എന്നതിലേക്ക് ഇംപോർട്ട് ചെയ്യുക';
  }

  @override
  String labelImportSupportedFormats(String formats) {
    return 'പിന്തുണയ്ക്കുന്ന ഫോർമാറ്റുകൾ: $formats';
  }

  @override
  String labelImportSupportedExtensions(String extensions) {
    return 'ഫയൽ തരങ്ങൾ: $extensions';
  }

  @override
  String get bodyImportSelectFilesPrompt =>
      'പുതിയ കുറിപ്പുകളായി ഇംപോർട്ട് ചെയ്യാൻ ഫയലുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get labelFeaturesCategoryJournaling =>
      'എഴുത്തും റിച്ച് ടെക്സ്റ്റ് എഡിറ്ററും';

  @override
  String get descFeaturesCategoryJournaling =>
      'ആകർഷകമായ എഴുത്ത്, ടെംപ്ലേറ്റുകൾ, ഒ.സി.ആർ., മീഡിയ അറ്റാച്ച്മെന്റുകൾ';

  @override
  String get descFeaturesCategorySecurity =>
      'സ്വകാര്യത, എൻക്രിപ്ഷൻ, വോൾട്ട് സുരക്ഷ';

  @override
  String get descFeaturesCategorySecuritySubtitle =>
      'പൂർണ്ണ ഓഫ്‌ലൈൻ സുരക്ഷയും വിപുലമായ എൻക്രിപ്ഷൻ നിയന്ത്രണങ്ങളും';

  @override
  String get labelFeaturesCategoryDiscovery => 'തിരയൽ, ടൈംലൈൻ, സ്ഥിതിവിവരങ്ങൾ';

  @override
  String get descFeaturesCategoryDiscovery =>
      'വേഗതയേറിയ ഫുൾ-ടെക്സ്റ്റ് തിരയലും കലണ്ടർ നാവിഗേഷനും';

  @override
  String get descFeaturesCategoryStorage => 'സംഭരണം, ബാക്കപ്പ് & എക്സ്പോർട്ട്';

  @override
  String get descFeaturesCategoryStorageSubtitle =>
      'ലോക്കൽ ബാക്കപ്പുകളും വൈവിധ്യമാർന്ന എക്സ്പോർട്ട് രീതികളും';

  @override
  String get titleFeatureQuill => 'ക്വിൽ റിച്ച് ടെക്സ്റ്റ് എഡിറ്റർ';

  @override
  String get descFeatureQuill =>
      'തലക്കെട്ടുകൾ, ലിസ്റ്റുകൾ, ബോൾഡ്, ഇറ്റാലിക്, അടിവര, കോൾഔട്ടുകൾ എന്നിവ ഉപയോഗിച്ച് കുറിപ്പുകൾ മനോഹരമായി എഴുതുക.';

  @override
  String get titleFeatureTemplates => 'ഘടനാപരമായ എൻട്രി ടെംപ്ലേറ്റുകൾ';

  @override
  String get descFeatureTemplates =>
      'പ്രതിദിന ചിന്തകൾ, കൃതജ്ഞത, യാത്രാവിവരണം, മീറ്റിംഗ് കുറിപ്പുകൾ തുടങ്ങിയ മുൻകൂട്ടി തയ്യാറാക്കിയ 8 ടെംപ്ലേറ്റുകൾ.';

  @override
  String get bodyFeatureMediaOcr => 'എൻക്രിപ്റ്റ് ചെയ്ത മീഡിയയും ഒ.സി.ആറും';

  @override
  String get descFeatureMediaOcr =>
      'ഫോട്ടോകളും ഓഡിയോയും സുരക്ഷിതമായി സൂക്ഷിക്കുക. ചിത്രങ്ങളിൽ നിന്ന് നേരിട്ട് ടെക്സ്റ്റ് തിരിച്ചറിയാൻ ഓഫ്‌ലൈൻ ഒ.സി.ആർ.';

  @override
  String get titleFeatureTags => 'വർണ്ണ കോഡുള്ള ടാഗുകൾ & ടാഗ് മാനേജർ';

  @override
  String get descFeatureTags =>
      'വിവിധ നിറങ്ങളിലുള്ള ടാഗുകൾ ഉപയോഗിച്ച് കുറിപ്പുകൾ തരംതിരിക്കുക. ടാഗുകൾ എളുപ്പത്തിൽ കൈകാര്യം ചെയ്യുക.';

  @override
  String get titleFeatureMultiJournal => 'വ്യത്യസ്ത ജേണലുകൾ';

  @override
  String get descFeatureMultiJournal =>
      'വ്യക്തിപരം, ജോലി, യാത്ര തുടങ്ങിയ വിവിധ ആവശ്യങ്ങൾക്കായി പ്രത്യേക ജേണലുകൾ തയ്യാറാക്കുക.';

  @override
  String get bodyFeatureSqlcipher => 'എസ്.ക്യു.എൽ.സൈഫർ AES-256 എൻക്രിപ്ഷൻ';

  @override
  String get descFeatureSqlcipher =>
      'എല്ലാ കുറിപ്പുകളും ഡാറ്റാബേസും AES-256 ഉപയോഗിച്ച് ഉപകരണത്തിൽ തന്നെ എൻക്രിപ്റ്റ് ചെയ്യപ്പെടുന്നു.';

  @override
  String get titleFeatureBiometrics => 'ബയോമെട്രിക്സ് & ആപ്പ് പിൻ ലോക്ക്';

  @override
  String get descFeatureBiometrics =>
      'ഫിംഗർപ്രിന്റ് അല്ലെങ്കിൽ ആപ്പ് പിൻ ഉപയോഗിച്ച് ജേണൽ വോൾട്ട് സുരക്ഷിതമാക്കുക.';

  @override
  String get titleFeatureJournalLock => 'പ്രത്യേക ജേണൽ പാസ്‌വേഡുകൾ';

  @override
  String get descFeatureJournalLock =>
      'കൂടുതൽ സ്വകാര്യമായ ജേണലുകൾക്ക് പ്രത്യേക പാസ്‌വേഡുകൾ സജ്ജീകരിക്കാം.';

  @override
  String get bodyFeatureAttachmentLock =>
      'അറ്റാച്ച്മെന്റ് തലത്തിലുള്ള ലോക്കുകൾ';

  @override
  String get descFeatureAttachmentLock =>
      'പ്രത്യേക ഫോട്ടോകളും രേഖകളും വ്യക്തിഗത പാസ്‌വേഡുകൾ നൽകി മറച്ചുവെക്കാം.';

  @override
  String get bodyFeatureScreenshotGuard => 'സ്ക്രീൻഷോട്ട് തടയൽ സംവിധാനം';

  @override
  String get descFeatureScreenshotGuard =>
      'FLAG_SECURE വഴി സ്ക്രീൻഷോട്ടുകളും സ്ക്രീൻ റെക്കോർഡിംഗും സ്വയമേവ തടയപ്പെടുന്നു.';

  @override
  String get bodyFeatureTamperAudit => 'സുരക്ഷാ ഓഡിറ്റ് ലോഗുകൾ';

  @override
  String get descFeatureTamperAudit =>
      'തെറ്റായ പിൻ ശ്രമങ്ങളും പ്രധാന സുരക്ഷാ മാറ്റങ്ങളും ലോഗ് ചെയ്യപ്പെടുന്നു.';

  @override
  String get titleFeatureAutoLock => 'ഓട്ടോ-ലോക്ക് പ്രൊഫൈലുകൾ';

  @override
  String get descFeatureAutoLock =>
      'ഉപയോഗത്തിലില്ലാത്തപ്പോൾ ആപ്പ് സ്വയമേവ ലോക്കാകുന്നതിനുള്ള സമയപരിധി നിശ്ചയിക്കുക.';

  @override
  String get titleFeatureFtsSearch => 'മിന്നൽ വേഗതയുള്ള FTS തിരയൽ';

  @override
  String get descFeatureFtsSearch =>
      'SQLite FTS5 വഴി ഏത് കുറിപ്പും ഉള്ളടക്കവും ഞൊടിയിടയിൽ തിരഞ്ഞു കണ്ടെത്തുക.';

  @override
  String get titleFeatureSearchPresets => 'സേവ് ചെയ്ത തിരയലുകൾ';

  @override
  String get descFeatureSearchPresets =>
      'പതിവായി തിരയുന്ന ഫിൽട്ടറുകൾ ഒറ്റ ക്ലിക്കിൽ ഉപയോഗിക്കാൻ സേവ് ചെയ്തു വെക്കുക.';

  @override
  String get bodyFeatureTimeline => 'ഇന്ററാക്ടീവ് കലണ്ടർ ടൈംലൈൻ';

  @override
  String get descFeatureTimeline =>
      'കലണ്ടർ നാവിഗേഷൻ വഴി മുൻകാല കുറിപ്പുകൾ എളുപ്പത്തിൽ ബ്രൗസ് ചെയ്യുക.';

  @override
  String get titleFeatureInsights => 'എഴുത്ത് ശീലങ്ങളും സ്ഥിതിവിവരങ്ങളും';

  @override
  String get descFeatureInsights =>
      'തുടർച്ചയായ എഴുത്ത് ദിവസങ്ങൾ, വാക്ക് എണ്ണം, പ്രതിമാസ പുരോഗതി എന്നിവ ചാർട്ടുകളിലൂടെ കാണുക.';

  @override
  String get bodyFeatureStorageMigration => 'എസ്.ഡി. കാർഡ് സംഭരണ മാറ്റം';

  @override
  String get descFeatureStorageMigration =>
      'ഫയലുകൾ ആന്തരിക സംഭരണത്തിനും എസ്.ഡി. കാർഡിനും ഇടയിൽ സുരക്ഷിതമായി മാറ്റുക.';

  @override
  String get titleFeatureEncryptedBackups =>
      'എൻക്രിപ്റ്റ് ചെയ്ത വോൾട്ട് ബാക്കപ്പുകൾ (.jvbk)';

  @override
  String get descFeatureEncryptedBackups =>
      'പാസ്‌വേഡ് ഉപയോഗിച്ച് സുരക്ഷിതമായ .jvbk ബാക്കപ്പ് ഫയലുകൾ എടുക്കുകയും പുനഃസ്ഥാപിക്കുകയും ചെയ്യുക.';

  @override
  String get titleFeatureMultiExport => 'വിവിധ ഫോർമാറ്റുകളിലുള്ള എക്സ്പോർട്ട്';

  @override
  String get descFeatureMultiExport =>
      'പി.ഡി.എഫ്., മാർക്ക്ഡൗൺ സിപ്പ്, ജെസൺ രൂപങ്ങളിൽ കുറിപ്പുകൾ എക്സ്പോർട്ട് ചെയ്യുക.';

  @override
  String get bodyFeatureEncryptedReader =>
      'എൻക്രിപ്റ്റ് ചെയ്ത എക്സ്പോർട്ട് റീഡർ';

  @override
  String get descFeatureEncryptedReader =>
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
      'ക്യാമറ/ഫോട്ടോകൾ: ഫോട്ടോകൾ ചേർക്കാൻ.\nമൈക്രോഫോൺ: വോയ്സ് നോട്ടുകൾ റെക്കോർഡ് ചെയ്യാനും പറഞ്ഞെഴുതാനും (ഉപകരണത്തിൽ തന്നെ തിരിച്ചറിയുന്നു).\nസംഭരണം: ബാക്കപ്പുകൾ സേവ് ചെയ്യാനും എക്സ്പോർട്ട് ചെയ്യാനും.';

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
  String get titleTamperAlerts => 'സുരക്ഷാ മുന്നറിയിപ്പുകൾ';

  @override
  String get titleTamperAlertsHowItWorks =>
      'സുരക്ഷാ പരിശോധന എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get bodyTamperAlertsHowItWorks =>
      'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട് ഘടനാപരമായ കൺസിസ്റ്റൻസിയും ടൈംസ്റ്റാമ്പ് ക്രമവും AES-256 എൻക്രിപ്റ്റ് ചെയ്ത റെക്കോർഡുകളുമായി പരിശോധിച്ച് ഉറപ്പുവരുത്തുന്നു.';

  @override
  String get bodyTamperAlertsNoHistory =>
      'സുരക്ഷാ മുന്നറിയിപ്പുകളൊന്നുമില്ല. നിങ്ങളുടെ വോൾട്ട് സുരക്ഷിതമാണ്.';

  @override
  String get titleTamperAlertsHistory => 'സുരക്ഷാ മുന്നറിയിപ്പ് ചരിത്രം';

  @override
  String get bodyTamperAlertsScanCompleteClean =>
      'വോൾട്ട് സ്കാനിംഗ് പൂർത്തിയായി: എല്ലാ കുറിപ്പുകളും സുരക്ഷിതമാണ്.';

  @override
  String bodyTamperAlertsScanCompleteIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പ്രശ്നങ്ങൾ',
      one: '1 പ്രശ്നം',
    );
    return 'വോൾട്ട് സ്കാനിംഗിൽ $_temp0 കണ്ടെത്തി.';
  }

  @override
  String get bodyTamperAlertsStatusIssues =>
      'മുന്നറിയിപ്പ് — സുരക്ഷാ വ്യതിയാനങ്ങൾ കണ്ടെത്തി';

  @override
  String bodyTamperAlertsStatusIssuesDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'രേഖകളിൽ $count ഡാറ്റാ കൃത്യതാ പ്രശ്നങ്ങൾ കണ്ടെത്തി.',
      one: 'രേഖകളിൽ 1 ഡാറ്റാ കൃത്യതാ പ്രശ്നം കണ്ടെത്തി.',
    );
    return '$_temp0';
  }

  @override
  String get bodyTamperAlertsStatusVerified => 'വോൾട്ട് കൃത്യത പരിശോധിച്ചു';

  @override
  String get descTamperAlertsStatusVerifiedDetail =>
      'എല്ലാ ഡാറ്റാബേസ് ടേബിളുകളും കൺസിസ്റ്റൻസിയും പരിശോധിച്ചു. സിസ്റ്റം ആരോഗ്യകരമാണ്.';

  @override
  String get actionTamperAlertsVerify => 'വോൾട്ട് കൃത്യത പരിശോധിക്കുക';

  @override
  String get bodyTamperAlertsVerifying => 'വോൾട്ട് കൃത്യത പരിശോധിക്കുന്നു...';

  @override
  String get titleShareQuickCapture => 'പെട്ടെന്നുള്ള കുറിപ്പ്';

  @override
  String get descShareQuickCapture =>
      'പങ്കിട്ട വിവരങ്ങൾ ഒരു പുതിയ കുറിപ്പായി സേവ് ചെയ്യുക';

  @override
  String get bodyShareNoJournalsFound =>
      'ജേണലുകളൊന്നും കണ്ടെത്തിയില്ല. ആദ്യം ഒരു ജേണൽ ഉണ്ടാക്കുക.';

  @override
  String get labelShareSelectJournal => 'ജേണൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get labelShareEntryTitle => 'കുറിപ്പ് തലക്കെട്ട്';

  @override
  String get descShareEntryTitle => 'തലക്കെട്ട് നൽകുക (ഓപ്ഷണൽ)';

  @override
  String get labelShareContent => 'ഉള്ളടക്കം';

  @override
  String get descShareContent =>
      'പങ്കിട്ട കുറിപ്പ്, ലിങ്ക് അല്ലെങ്കിൽ ടെക്സ്റ്റ്...';

  @override
  String labelShareAttachments(int count) {
    return 'അറ്റാച്ച്മെന്റുകൾ ($count)';
  }

  @override
  String get actionShareDiscard => 'ഉപേക്ഷിക്കുക';

  @override
  String get actionShareOpenInEditor => 'എഡിറ്ററിൽ തുറക്കുക';

  @override
  String get actionShareSaveToJournal => 'ജേണലിലേക്ക് സേവ് ചെയ്യുക';

  @override
  String get errorShareSave => 'പങ്കിട്ട വിവരങ്ങൾ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String bodyShareSavedSuccess(String journalTitle) {
    return 'പങ്കിട്ട കുറിപ്പ് \"$journalTitle\" എന്നതിലേക്ക് സേവ് ചെയ്തു';
  }

  @override
  String get titleShareSealedFileDetected => 'എൻക്രിപ്റ്റ് ചെയ്ത ഫയൽ കണ്ടെത്തി';

  @override
  String get actionShareOpenEncryptedExport =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ഫയൽ തുറക്കുക';

  @override
  String get labelTemplateCategoryCustom => 'എന്റെ മാതൃകകൾ';

  @override
  String get actionTemplateCollapseAll => 'എല്ലാം ചുരുക്കുക';

  @override
  String get actionTemplateExpandAll => 'എല്ലാം വികസിപ്പിക്കുക';

  @override
  String get actionTemplateCreateNew => 'പുതിയ ടെംപ്ലേറ്റ്';

  @override
  String get titleTemplateManager => 'സ്വന്തം ടെംപ്ലേറ്റുകൾ';

  @override
  String get actionTemplateEdit => 'ടെംപ്ലേറ്റ് തിരുത്തുക';

  @override
  String get actionTemplateDelete => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കുക';

  @override
  String get bodyTemplateDeleteConfirm => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കണോ?';

  @override
  String bodyTemplateDeleteConfirmMessage(String name) {
    return '\"$name\" ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';
  }

  @override
  String get bodyTemplateDeleteSuccess => 'ടെംപ്ലേറ്റ് ഇല്ലാതാക്കി';

  @override
  String get emptyTemplate =>
      'സ്വന്തം ടെംപ്ലേറ്റുകളൊന്നുമില്ല. നിങ്ങളുടെ പ്രിയപ്പെട്ട ലേഔട്ട് സേവ് ചെയ്യാൻ ഒരെണ്ണം സൃഷ്ടിക്കുക.';

  @override
  String get labelTemplateName => 'ടെംപ്ലേറ്റ് പേര്';

  @override
  String get descTemplateName => 'ഉദാ: പ്രതിദിന ചിന്തകൾ, മീറ്റിംഗ് കുറിപ്പുകൾ';

  @override
  String get errorTemplateName => 'ടെംപ്ലേറ്റ് പേര് നൽകുക.';

  @override
  String get labelTemplateDescription => 'വിവരണം';

  @override
  String get descTemplateDescription =>
      'ഈ ടെംപ്ലേറ്റ് എന്തിനാണെന്നുള്ള ലഘു വിവരണം';

  @override
  String get labelTemplateDefaultTitle => 'ഡിഫോൾട്ട് കുറിപ്പ് തലക്കെട്ട്';

  @override
  String get descTemplateDefaultTitle => 'ഉദാ. സ്റ്റാൻഡപ്പ് - ഇന്ന്';

  @override
  String get labelTemplateContent => 'ടെംപ്ലേറ്റ് ഉള്ളടക്കം';

  @override
  String get descTemplateContent =>
      'നിങ്ങളുടെ കുറിപ്പിന്റെ ഉള്ളടക്ക മാതൃക ഇവിടെ എഴുതുക...';

  @override
  String get titleTemplateTokens => 'ഡൈനാമിക് തീയതി ടോക്കണുകൾ';

  @override
  String get descTemplateTokensHelper =>
      'ഡൈനാമിക് തീയതി ടോക്കണുകൾ പുതിയ കുറിപ്പ് തുടങ്ങുമ്പോൾ സ്വയമേവ ചേർക്കപ്പെടും.';

  @override
  String get bodyTemplateSaveSuccess => 'ടെംപ്ലേറ്റ് സേവ് ചെയ്തു';

  @override
  String get actionTemplateSaveAsTemplate => 'ടെംപ്ലേറ്റായി സേവ് ചെയ്യുക';

  @override
  String get titleTemplateSaveAsTemplate => 'പുതിയ ടെംപ്ലേറ്റ്';

  @override
  String get descTemplateSaveAsTemplate =>
      'ഈ കുറിപ്പിന്റെ ഘടന വീണ്ടും ഉപയോഗിക്കാവുന്ന ടെംപ്ലേറ്റായി സേവ് ചെയ്യുക.';

  @override
  String get titleSettingsSectionHelp => 'സഹായം';

  @override
  String get descSettingsSectionHelp =>
      'ഗൈഡുകൾ, എൻക്രിപ്ഷൻ വിവരങ്ങൾ, പതിവ് ചോദ്യങ്ങൾ';

  @override
  String get titleSettingsSectionFeatures => 'സവിശേഷതകൾ';

  @override
  String get descSettingsSectionFeatures => 'ആപ്പിന്റെ പ്രധാന സവിശേഷതകൾ കാണുക';

  @override
  String get titleFeaturesHeader => 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട് സവിശേഷതകൾ';

  @override
  String get descFeaturesHeader =>
      'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ടിന്റെ സമഗ്രമായ ടൂളുകളും സുരക്ഷാ സവിശേഷതകളും പര്യവേക്ഷണം ചെയ്യുക.';

  @override
  String descEntryWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വാക്കുകൾ',
      one: '1 വാക്ക്',
    );
    return '$_temp0';
  }

  @override
  String descEntryCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count അക്ഷരങ്ങൾ',
      one: '1 അക്ഷരം',
    );
    return '$_temp0';
  }

  @override
  String descEntryStats(String words, String chars) {
    return '$words • $chars';
  }

  @override
  String get actionEntryDistractionFreeEnter => 'ഫോക്കസ് മോഡ്';

  @override
  String get actionEntryDistractionFreeExit => 'ഫോക്കസ് മോഡ് വിടുക';

  @override
  String get descEntryFocusParagraphOn => 'ഫോക്കസ് പാരഗ്രാഫ്: ഓൺ';

  @override
  String get descEntryFocusParagraphOff => 'ഫോക്കസ് പാരഗ്രാഫ്: ഓഫ്';

  @override
  String get labelEntryAutoSaving => 'സേവ് ചെയ്യുന്നു…';

  @override
  String labelEntryAutoSaved(String time) {
    return '$time-ൽ സേവ് ചെയ്തു';
  }

  @override
  String get labelEntryAutoSavedJustNow => 'ഇപ്പോൾ സേവ് ചെയ്തു';

  @override
  String get labelEntryUnsavedChanges => 'സേവ് ചെയ്യാത്ത മാറ്റങ്ങൾ';

  @override
  String get tooltipEntryEditorScanText =>
      'ചിത്രത്തിൽ നിന്ന് ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുക';

  @override
  String get labelEntryEditorScanSourceCamera => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get labelEntryEditorScanSourceGallery =>
      'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get descEntryEditorOcrScanning =>
      'ചിത്രത്തിൽ നിന്ന് ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുന്നു...';

  @override
  String get descEntryEditorOcrNoTextFound =>
      'ചിത്രത്തിൽ ടെക്സ്റ്റ് കണ്ടെത്താൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorEntryEditorOcr =>
      'ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുന്നത് പരാജയപ്പെട്ടു.';

  @override
  String get titleEntryEditorCropImage => 'ചിത്രം ക്രോപ്പ് ചെയ്യുക & തിരിക്കുക';

  @override
  String get errorEntryEditorCropImage =>
      'ചിത്രം ക്രോപ്പ് ചെയ്യുന്നത് പരാജയപ്പെട്ടു.';

  @override
  String get titleAppearanceThemeMode => 'തീം മോഡ്';

  @override
  String get descAppearanceThemeMode =>
      'വെളിച്ചം, ഇരുട്ട് അല്ലെങ്കിൽ സിസ്റ്റം ഡിഫോൾട്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get titleAppearanceAccentColor => 'പ്രധാന വർണ്ണ തീം';

  @override
  String get descAppearanceAccentColor =>
      'ആപ്പിന്റെ പ്രധാന ബട്ടണുകളുടെയും ഹൈലൈറ്റുകളുടെയും നിറം മാറ്റുക';

  @override
  String get titleAppearanceLivePreview => 'തത്സമയ പ്രിവ്യൂ';

  @override
  String get tabAppearancePresets => 'വർണ്ണ പ്രീസെറ്റുകൾ';

  @override
  String get tabAppearanceCustomWheel => 'കളർ വീൽ (Custom)';

  @override
  String get labelAppearanceSampleText => 'മാതൃകാ ജേണൽ കുറിപ്പ്';

  @override
  String get actionAppearanceResetDefault =>
      'ഡിഫോൾട്ടിലേക്ക് പുനഃക്രമീകരിക്കുക';

  @override
  String get descAppearanceContrastNote =>
      'വായനാസൗകര്യത്തിനായി ടെക്സ്റ്റ് കോൺട്രാസ്റ്റ് സ്വയമേവ ക്രമീകരിക്കും.';

  @override
  String get descAppearanceSystemModeExplainer =>
      'സിസ്റ്റം മോഡ് ഫോണിലെ ഡാർക്ക് മോഡ് ക്രമീകരണത്തിന് അനുസരിച്ച് സ്വയമേവ മാറും.';

  @override
  String get labelSettingsThemeSepia => 'പേപ്പർ / സെപിയ';

  @override
  String get labelSettingsThemeOled => 'OLED / കറുപ്പ്';

  @override
  String get descSettingsThemeSepia =>
      'ദീർഘനേരത്തെ എഴുത്തിന് അനുയോജ്യമായ മൃദുവായ പേപ്പർ നിറം.';

  @override
  String get descSettingsThemeOled =>
      'AMOLED സ്ക്രീനുകളിൽ ബാറ്ററി ലാഭിക്കാൻ സഹായിക്കുന്ന പൂർണ്ണ കറുപ്പ് പശ്ചാത്തലം.';

  @override
  String get descSettingsThemeLight =>
      'പകൽ വെളിച്ചത്തിൽ വായിക്കാൻ അനുയോജ്യമായ തെളിഞ്ഞ പശ്ചാത്തലം.';

  @override
  String get descSettingsThemeDark =>
      'കുറഞ്ഞ വെളിച്ചത്തിൽ എഴുതാൻ അനുയോജ്യമായ ഡാർക്ക് പശ്ചാത്തലം.';

  @override
  String get descSettingsThemeSystem =>
      'ഉപകരണത്തിന്റെ സിസ്റ്റം തീം സ്വയമേവ പിന്തുടരുന്നു.';

  @override
  String get titleAppearanceTypography => 'വായനാ ടൈപ്പോഗ്രാഫി';

  @override
  String get descAppearanceTypography =>
      'ഫോണ്ട് ശൈലിയും വലിപ്പവും ഇഷ്ടാനുസൃതമാക്കുക';

  @override
  String get titleAppearanceFontFamily => 'ഫോണ്ട് ശൈലി';

  @override
  String get titleAppearanceFontSize => 'ഫോണ്ട് വലിപ്പം';

  @override
  String get labelAppearanceFontFamilySans => 'സാൻസ്-സെരിഫ്';

  @override
  String get descAppearanceFontFamilySans => 'വൃത്തിയുള്ള ആധുനിക ടൈപ്പ്ഫേസ്';

  @override
  String get labelAppearanceFontFamilySerif => 'ബുക്ക് സെരിഫ്';

  @override
  String get descAppearanceFontFamilySerif => 'ക്ലാസിക് പുസ്തക വായനാ ശൈലി';

  @override
  String get labelAppearanceFontFamilyMonospace => 'മോണോസ്പേസ്';

  @override
  String get descAppearanceFontFamilyMonospace =>
      'ടൈപ്പ്റൈറ്റർ ശൈലിയിലുള്ള ഫിക്സഡ് വിഡ്ത്ത് ഫോണ്ട്';

  @override
  String get labelAppearanceFontSizeSmall => 'ചെറുത്';

  @override
  String get labelAppearanceFontSizeDefault => 'സാധാരണ';

  @override
  String get labelAppearanceFontSizeMedium => 'ഇടത്തരം';

  @override
  String get labelAppearanceFontSizeLarge => 'വലുത്';

  @override
  String get labelAppearanceFontSizeExtraLarge => 'വളരെ വലുത്';

  @override
  String get labelAppearanceSampleHeadline => 'ശാന്തമായ ചിന്തകൾ';

  @override
  String get bodyAppearanceSample =>
      'ചിന്തിക്കാനും മനസ്സമാധാനത്തോടെ എഴുതാനുമുള്ള സ്വകാര്യ ഇടമാണിത്. നിങ്ങളുടെ ഓരോ ചിന്തകളും ഓർമ്മകളും ഇതിൽ സുരക്ഷിതമായി സൂക്ഷിക്കപ്പെടുന്നു.';

  @override
  String get bodyAppearanceTypographyReset => 'ടൈപ്പോഗ്രാഫി പഴയപടിയാക്കി.';

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
  String get tooltipEditorInsertDrawing => 'രേഖാചിത്രം ചേർക്കുക';

  @override
  String get titleDrawingCanvas => 'വരയ്ക്കൽ';

  @override
  String get titleDrawingCanvasEdit => 'രേഖാചിത്രം തിരുത്തുക';

  @override
  String get labelDrawingCanvasPen => 'പേന';

  @override
  String get labelDrawingCanvasHighlighter => 'ഹൈലൈറ്റർ';

  @override
  String get labelDrawingCanvasEraser => 'ഇറേസർ';

  @override
  String get actionDrawingCanvasClear => 'ക്യാൻവാസ് മായ്ക്കുക';

  @override
  String get bodyDrawingCanvasClear => 'മുഴുവൻ ഡ്രോയിംഗും മായ്ക്കണോ?';

  @override
  String get labelDrawingCanvasStrokeWidth => 'വരയുടെ വീതി';

  @override
  String get labelDrawingCanvasBackground => 'പശ്ചാത്തലം';

  @override
  String get labelDrawingCanvasBgBlank => 'വെള്ള പേപ്പർ';

  @override
  String get labelDrawingCanvasBgRuled => 'വരയുള്ള പേപ്പർ';

  @override
  String get labelDrawingCanvasBgGrid => 'ഗ്രിഡ് പേപ്പർ';

  @override
  String get labelDrawingCanvasBgDots => 'ഡോട്ട് പേപ്പർ';

  @override
  String get actionDrawingCanvasUndo => 'പഴയപടിയാക്കുക';

  @override
  String get actionDrawingCanvasRedo => 'വീണ്ടും ചെയ്യുക';

  @override
  String get actionDrawingCanvasSave => 'പൂർത്തിയായി';

  @override
  String get bodyDrawingCanvasDiscard => 'രേഖാചിത്രം ഉപേക്ഷിക്കണോ?';

  @override
  String get bodyDrawingCanvasDiscardMessage =>
      'നിങ്ങൾ വരുത്തിയ മാറ്റങ്ങൾ സേവ് ചെയ്യപ്പെടില്ല.';

  @override
  String get tooltipDrawingEdit => 'രേഖാചിത്രം തിരുത്തുക';

  @override
  String get tooltipDrawingSize => 'രേഖാചിത്ര വലിപ്പം';

  @override
  String get tooltipDrawingDelete => 'രേഖാചിത്രം നീക്കം ചെയ്യുക';

  @override
  String get descDrawingUnavailable => 'രേഖാചിത്രം ലഭ്യമല്ല';

  @override
  String get descDrawingLoading => 'രേഖാചിത്രം ലോഡ് ചെയ്യുന്നു...';

  @override
  String get errorDrawingSave => 'ഡ്രോയിംഗ് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get actionJournalManageTemplates => 'സ്വന്തം ടെംപ്ലേറ്റുകൾ';

  @override
  String get helpTitle => 'സഹായം';

  @override
  String get titleFeatures => 'സവിശേഷതകൾ';

  @override
  String get bodyFeatureOffline => '100% ഓഫ്‌ലൈൻ & നെറ്റ്‌വർക്ക് അനുമതികളില്ല';

  @override
  String get descFeatureOffline =>
      'ഈ ആപ്പിൽ ഇന്റർനെറ്റ് അനുമതികളോ കോഡോ ഇല്ല. നിങ്ങളുടെ എല്ലാ വിവരങ്ങളും ഫോണിൽ മാത്രം സുരക്ഷിതമായിരിക്കും.';

  @override
  String get titleRitual => 'പ്രതിദിന ധ്യാനചര്യ';

  @override
  String get titleRitualDeckBrowser => 'ചിന്താ കാർഡുകൾ';

  @override
  String get tooltipRitualResetReviews => 'ഇടവേളകൾ പുനഃക്രമീകരിക്കുക';

  @override
  String get titleRitualResetReviews => 'എല്ലാ കാർഡുകളും പുനഃക്രമീകരിക്കുക';

  @override
  String get bodyRitualResetReviews =>
      'ഇത് എല്ലാ 18 കാർഡുകളുടെയും റിവിഷൻ ലെവലുകൾ റീസെറ്റ് ചെയ്യും. തുടരണോ?';

  @override
  String get bodyRitualResetReviewsDone =>
      'കാർഡുകളുടെ റിവിഷൻ സമയം പുനഃക്രമീകരിച്ചു.';

  @override
  String get labelRitualAllThemes => 'എല്ലാ വിഷയങ്ങളും';

  @override
  String get labelRitualSrsNew => 'പുതിയത്';

  @override
  String get labelRitualSrsDueToday => 'ഇന്ന് ചെയ്യേണ്ടത്';

  @override
  String labelRitualSrsInDays(int days) {
    return '$days ദിവസത്തിൽ';
  }

  @override
  String get labelRitualStepBreathe => 'ശ്വാസം';

  @override
  String get labelRitualStepReflect => 'ചിന്ത';

  @override
  String get labelRitualStepWrite => 'എഴുത്ത്';

  @override
  String get titleRitualBreathe => 'മനസ്സമാധാന ശ്വസനം';

  @override
  String get actionRitualSkipToPrompt => 'നേരെ ചിന്താ കാർഡിലേക്ക്';

  @override
  String get actionRitualContinueToCard => 'തുടരുക';

  @override
  String get actionRitualShuffleCard => 'മറ്റൊരു കാർഡ് എടുക്കുക';

  @override
  String get bodyRitualSrsRatePrompt =>
      'ഈ വിഷയം ചിന്തിക്കാൻ എത്രത്തോളം എളുപ്പമായിരുന്നു?';

  @override
  String get actionRitualSrsHard => 'കഠിനം';

  @override
  String get descRitualSrsHard => 'നാളെ വീണ്ടും കാണുക';

  @override
  String get actionRitualSrsRevision => 'ശ്രദ്ധിക്കുക';

  @override
  String get descRitualSrsRevision => '3 ദിവസത്തിൽ';

  @override
  String get actionRitualSrsEasy => 'ലളിതം';

  @override
  String get descRitualSrsEasy => '+7 ദിവസങ്ങൾ';

  @override
  String get actionRitualProceedToJournal => 'എഴുത്തിലേക്ക് കടക്കുക';

  @override
  String get titleRitualReadyToWrite => 'എഴുതാൻ തയ്യാറാണോ?';

  @override
  String descRitualReadyToWrite(String cardTitle) {
    return '\"$cardTitle\" എന്ന ആശയത്തിൽ നിന്നും നിങ്ങളുടെ ചിന്തകൾ ഇന്നത്തെ ജേണലിൽ കുറിക്കാം.';
  }

  @override
  String get actionRitualBeginWriting => 'എഴുത്ത് ആരംഭിക്കുക';

  @override
  String get actionRitualCompletePracticeOnly => 'ധ്യാനം മാത്രം പൂർത്തിയാക്കുക';

  @override
  String get titleRitualSettings => 'ധ്യാനചര്യ ക്രമീകരണങ്ങൾ';

  @override
  String get titleRitualLaunchOnStartup => 'ആപ്പ് തുറക്കുമ്പോൾ ധ്യാനചര്യ';

  @override
  String get descRitualLaunchOnStartup =>
      'ആപ്പ് തുറക്കുമ്പോൾ തന്നെ ശ്വസന വ്യായാമവും ചിന്താ കാർഡും കാണിക്കുക';

  @override
  String get labelRitualBreathTechnique => 'ശ്വാസ രീതി';

  @override
  String labelRitualBreathCycles(int count) {
    return 'ശ്വാസ ചക്രങ്ങൾ: $count';
  }

  @override
  String get actionCommonReset => 'റീസെറ്റ്';

  @override
  String get titleRitualSettingsTile => 'ധ്യാനചര്യ & ചിന്താ കാർഡുകൾ';

  @override
  String get descRitualSettingsTile =>
      'ശ്വാസ ടൈമർ, 18 ചിന്താ കാർഡുകൾ & ആവർത്തന ഓർമ്മപ്പെടുത്തൽ';

  @override
  String get titleFeatureRitual => 'ധ്യാനചര്യയും ചിന്താ കാർഡുകളും';

  @override
  String get descFeatureRitual =>
      'മനസ്സ് ശാന്തമാക്കാനുള്ള ശ്വാസ ടൈമർ, 18 ചിന്താ കാർഡുകൾ, സ്പേസ്ഡ് റെപ്പറ്റീഷൻ റിവിഷൻ, നേരിട്ട് ജേണലിലേക്ക് കടക്കാനുള്ള സൗകര്യം.';

  @override
  String get titleSyncLanding => 'ഡിവൈസ് സിങ്ക് (Wi-Fi)';

  @override
  String get descSyncLanding =>
      'ക്ലൗഡ് സെർവറുകളുടെ ആവശ്യമില്ലാതെ ലോക്കൽ വൈ-ഫൈ വഴി നേരിട്ട് മാറ്റങ്ങളും അറ്റാച്ച്മെന്റുകളും കൈമാറുക';

  @override
  String get titleSyncSend => 'ഡാറ്റ അയക്കുക (Host)';

  @override
  String get descSyncSend =>
      'ക്യുആർ കോഡ് കാണിച്ച് മറ്റൊരു ഉപകരണത്തിലേക്ക് ജേണൽ വിവരങ്ങൾ സുരക്ഷിതമായി അയക്കുക';

  @override
  String get titleSyncReceive => 'ഡാറ്റ സ്വീകരിക്കുക (Client)';

  @override
  String get descSyncReceive =>
      'മറ്റൊരു ഉപകരണത്തിൽ നിന്നുള്ള ക്യുആർ കോഡ് സ്കാൻ ചെയ്ത് മാറ്റങ്ങൾ ഇവിടെ സമന്വയിപ്പിക്കുക';

  @override
  String get titleSyncHost => 'ഡാറ്റ അയക്കൽ (Host)';

  @override
  String get titleSyncClient => 'ഡാറ്റ സ്വീകരിക്കൽ (Client)';

  @override
  String get tabSyncTabQrScan => 'ക്യുആർ സ്കാൻ';

  @override
  String get tabSyncTabManualEntry => 'വിവരങ്ങൾ നൽകുക';

  @override
  String get labelSyncIp => 'ലോക്കൽ ഐപി അഡ്രസ്സ്';

  @override
  String get labelSyncPort => 'പോർട്ട്';

  @override
  String get labelSyncPairingCode => 'പെയറിംഗ് കോഡ്';

  @override
  String get labelSyncPairingCodeHint => 'XXXX-XXXX-XXXX-XXXX';

  @override
  String get descSyncStatusListening =>
      'മറ്റൊരു ഉപകരണത്തിന്റെ കണക്ഷനായി കാത്തിരിക്കുന്നു...';

  @override
  String get labelSyncStatusConnected => 'ഉപകരണം ബന്ധിപ്പിച്ചു';

  @override
  String get descSyncStatusCompleted => 'സിങ്ക് വിജയകരമായി പൂർത്തിയായി!';

  @override
  String get errorSyncStatusDenied => 'കണക്ഷൻ നിരസിച്ചു: തെറ്റായ പെയറിംഗ് കോഡ്';

  @override
  String get labelSyncStatusStopped => 'സിങ്ക് സെർവർ നിർത്തി';

  @override
  String get errorSyncStatusError => 'സിങ്ക് സെർവറിൽ തകരാർ';

  @override
  String get actionSyncButtonStart => 'സെർവർ ആരംഭിക്കുക';

  @override
  String get actionSyncButtonStop => 'സെർവർ നിർത്തുക';

  @override
  String get actionSyncButtonConnect => 'കണക്റ്റ് ചെയ്ത് സിങ്ക് ചെയ്യുക';

  @override
  String get descSyncScanInstructions =>
      'അയക്കുന്ന ഉപകരണത്തിലെ ക്യുആർ കോഡിന് നേരെ ക്യാമറ പിടിക്കുക';

  @override
  String get descSyncHostAddress => 'ഉദാ: 192.168.1.5';

  @override
  String get descSyncPort => 'ഉദാ: 54321';

  @override
  String get descSyncCode => '16 അക്ഷര പെയറിംഗ് കോഡ്';

  @override
  String get descSyncNoWifiAlert =>
      'ലോക്കൽ വൈ-ഫൈ / ഐപി കണ്ടെത്താനായില്ല. ഇരു ഉപകരണങ്ങളും ഒരേ വൈ-ഫൈയിലോ ഹോട്ട്‌സ്പോട്ടിലോ ആണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get bodySyncPairingCodeCopied => 'പെയറിംഗ് കോഡ് കോപ്പി ചെയ്തു';

  @override
  String get titleAirqr => 'ഓപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് സിങ്ക് (AirQR)';

  @override
  String get descAirqrIntro =>
      'നെറ്റ്‌വർക്ക് കണക്ഷനുകൾ ഇല്ലാതെ ആനിമേഷൻ ക്യുആർ കോഡുകൾ വഴി ക്രമീകരണങ്ങളും ജേണലുകളും നേരിട്ട് കൈമാറുക.';

  @override
  String get titleAirqrSend => 'എയർക്യുആർ വഴി അയക്കുക';

  @override
  String get titleAirqrReceive => 'എയർക്യുആർ വഴി സ്വീകരിക്കുക';

  @override
  String get actionAirqrReceive => 'ഡാറ്റ സ്വീകരിക്കുക (സ്കാനർ)';

  @override
  String get descAirqrReceive =>
      'മറ്റൊരു ഉപകരണത്തിൽ നിന്നുള്ള ആനിമേഷൻ ക്യുആർ സ്കാൻ ചെയ്യുക';

  @override
  String get titleAirqrSyncSettings => 'ക്രമീകരണങ്ങൾ സിങ്ക് ചെയ്യുക';

  @override
  String get descAirqrSyncSettings =>
      'തീം, ആക്സെന്റ് നിറം, സുരക്ഷ, ധ്യാനചര്യ & ടെംപ്ലേറ്റുകൾ (< 1 സെക്കൻഡ്)';

  @override
  String get titleAirqrSyncJournal => 'ഒരു ജേണൽ സിങ്ക് ചെയ്യുക';

  @override
  String get descAirqrSyncJournal =>
      'ഒരു ജേണലിലെ കുറിപ്പുകൾ തിരഞ്ഞെടുത്ത് കൈമാറുക';

  @override
  String get titleAirqrTooLarge => 'ഫയൽ വലുപ്പം വളരെ കൂടുതലാണ്';

  @override
  String get titleAirqrSlow => 'വലിയ തോതിലുള്ള കൈമാറ്റം';

  @override
  String get actionAirqrSendAnyway => 'തുടരുക';

  @override
  String get titleAirqrSpeedNote => '100% ഓഫ്‌ലൈൻ & സുരക്ഷിതം';

  @override
  String get bodyAirqrSpeedNote =>
      'എയർക്യുആർ ക്യാമറയും സ്ക്രീനും വഴി മാത്രമേ പ്രവർത്തിക്കൂ. വൈ-ഫൈ, ബ്ലൂടൂത്ത്, ഇന്റർനെറ്റ് എന്നിവ ആവശ്യമില്ല.';

  @override
  String get actionTimeCapsuleActionSeal => 'ടൈം കാപ്സ്യൂളായി പൂട്ടുക';

  @override
  String get titleTimeCapsuleSeal => 'ടൈം കാപ്സ്യൂളായി പൂട്ടുക';

  @override
  String get descTimeCapsuleSeal =>
      'ഒരു നിശ്ചിത തീയതി വരെ ഈ കുറിപ്പ് എൻക്രിപ്റ്റ് ചെയ്ത് പൂട്ടുന്നു. ആ തീയതി എത്തുന്നതുവരെ ഇത് തുറക്കാൻ കഴിയില്ല.';

  @override
  String get labelTimeCapsuleUnlockDate => 'തുറക്കേണ്ട തീയതി';

  @override
  String get descTimeCapsuleTeaser =>
      'ഭാവിയിലെ നിങ്ങൾക്കായൊരു കുറിപ്പ് (ഓപ്ഷണൽ സൂചന)';

  @override
  String get actionTimeCapsulePreset1Month => '1 മാസം';

  @override
  String get actionTimeCapsulePreset6Months => '6 മാസം';

  @override
  String get actionTimeCapsulePreset1Year => '1 വർഷം';

  @override
  String get actionTimeCapsulePreset3Years => '3 വർഷം';

  @override
  String get actionTimeCapsulePreset5Years => '5 വർഷം';

  @override
  String get actionTimeCapsulePresetCustom => 'മറ്റൊരു തീയതി';

  @override
  String get bodyTimeCapsuleSeal => 'കാപ്സ്യൂൾ പൂട്ടുക';

  @override
  String get labelTimeCapsuleSealedBadge => 'പൂട്ടിയ ടൈം കാപ്സ്യൂൾ';

  @override
  String labelTimeCapsuleSealedUntil(String date) {
    return '$date വരെ പൂട്ടിയിരിക്കുന്നു';
  }

  @override
  String labelTimeCapsuleOpensInDays(int days) {
    return '$days ദിവസത്തിനുള്ളിൽ തുറക്കും';
  }

  @override
  String labelTimeCapsuleOpensInHours(int hours) {
    return '$hours മണിക്കൂറിനുള്ളിൽ തുറക്കും';
  }

  @override
  String get descTimeCapsuleOpensToday => 'ഇന്ന് തുറക്കാം!';

  @override
  String get actionTimeCapsuleReadyToOpen => 'തുറക്കാൻ തയ്യാറാണ്';

  @override
  String get descTimeCapsuleLocked =>
      'ഈ കുറിപ്പ് AES-256-GCM സാങ്കേതികവിദ്യ ഉപയോഗിച്ച് സുരക്ഷിതമായി പൂട്ടിയിരിക്കുന്നു. നിശ്ചിത തീയതി എത്തുന്നതുവരെ ഇത് തുറക്കാനാകില്ല.';

  @override
  String get actionTimeCapsuleUnseal => 'ടൈം കാപ്സ്യൂൾ തുറക്കുക';

  @override
  String actionTimeCapsuleUnsealLockedPrompt(String date) {
    return '$date വരെ പൂട്ടിയിരിക്കുന്നു';
  }

  @override
  String bodyTimeCapsuleSealedSuccess(String date) {
    return '$date വരെ കുറിപ്പ് ടൈം കാപ്സ്യൂളായി പൂട്ടി.';
  }

  @override
  String get bodyTimeCapsuleUnsealedSuccess =>
      'ടൈം കാപ്സ്യൂൾ വിജയകരമായി തുറന്നു! നിങ്ങളുടെ വാക്കുകളിലേക്ക് സ്വാഗതം.';

  @override
  String get errorTimeCapsuleClockTamper =>
      'ഉപകരണത്തിലെ സമയം മാറ്റിയതായി കണ്ടെത്തി. സിസ്റ്റം സമയം ശരിയാക്കാതെ ഈ കാപ്സ്യൂൾ തുറക്കാൻ കഴിയില്ല.';

  @override
  String get titleTimeCapsule => 'ടൈം കാപ്സ്യൂളുകൾ';

  @override
  String get descTimeCapsule =>
      'നിങ്ങളുടെ ഭാവികാലത്തിനായി പൂട്ടി സൂക്ഷിച്ച കുറിപ്പുകൾ';

  @override
  String get emptyTimeCapsule =>
      'ടൈം കാപ്സ്യൂളുകളൊന്നും ഇതുവരെയില്ല. ഒരു പുതിയ കുറിപ്പെഴുതി ഭാവിയിലേക്ക് സൂക്ഷിക്കൂ.';

  @override
  String get bodyTimeCapsuleBanner => 'ടൈം കാപ്സ്യൂൾ തയ്യാറാണ്!';

  @override
  String bodyTimeCapsuleBannerBody(int count) {
    return 'ഇന്ന് തുറക്കാനായി $count ടൈം കാപ്സ്യൂൾ തയ്യാറാണ്.';
  }

  @override
  String descTimeCapsuleBannerBodyPlural(int count) {
    return 'ഇന്ന് തുറക്കാനായി $count ടൈം കാപ്സ്യൂളുകൾ തയ്യാറാണ്.';
  }

  @override
  String get titleTimeCapsuleCategorySealed => 'പൂട്ടിയിരിക്കുന്നവ';

  @override
  String get titleTimeCapsuleCategoryReady => 'തുറക്കാവുന്നവ';

  @override
  String get titleTimeCapsuleCategoryOpened => 'തുറന്നവ';

  @override
  String get titleRitualCreateCard => 'കാർഡ് നിർമ്മിക്കുക';

  @override
  String get titleRitualEditCard => 'കാർഡ് എഡിറ്റ് ചെയ്യുക';

  @override
  String get actionRitualCreateCard => 'പുതിയ കാർഡ്';

  @override
  String get labelRitualCardTheme => 'തീം';

  @override
  String get labelRitualCardTitle => 'തലക്കെട്ട്';

  @override
  String get descRitualCardTitle => 'ഉദാ: ആത്മജ്ഞാനത്തിന്റെ വെളിച്ചം';

  @override
  String get errorRitualCardTitle => 'തലക്കെട്ട് നൽകേണ്ടതുണ്ട്.';

  @override
  String get labelRitualCardPrompt => 'ചിന്താ വിഷയം';

  @override
  String get descRitualCardPrompt =>
      'ധ്യാനവേളയിൽ ചിന്തിക്കാനുള്ള ഒരു ചോദ്യം...';

  @override
  String get errorRitualCardPrompt => 'ചിന്താ വിഷയം നൽകേണ്ടതുണ്ട്.';

  @override
  String get labelRitualCardQuote => 'ഉദ്ധരണി അല്ലെങ്കിൽ തത്വം';

  @override
  String get descRitualCardQuote => 'ഒരു വരി, ശ്ലോകം അല്ലെങ്കിൽ വചനം...';

  @override
  String get errorRitualCardQuote => 'ഉദ്ധരണി നൽകേണ്ടതുണ്ട്.';

  @override
  String get labelRitualCardAuthor => 'ഉറവിടം (ഓപ്ഷണൽ)';

  @override
  String get descRitualCardAuthor => 'ഉദാ: ഭഗവദ്ഗീത 2.47';

  @override
  String get labelRitualCardPreview => 'പ്രിവ്യൂ';

  @override
  String get actionRitualSaveCardCreate => 'കാർഡ് നിർമ്മിക്കുക';

  @override
  String get actionRitualSaveCardEdit => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get bodyRitualCardCreated => 'കാർഡ് നിർമ്മിച്ചു.';

  @override
  String get bodyRitualCardUpdated => 'കാർഡ് പുതുക്കി.';

  @override
  String get errorRitualCardSave =>
      'കാർഡ് സേവ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get labelRitualUserCardBadge => 'എന്റെ കാർഡ്';

  @override
  String get actionRitualEditCard => 'തിരുത്തുക';

  @override
  String get actionRitualDeleteCard => 'ഡിലീറ്റ് ചെയ്യുക';

  @override
  String get titleRitualDeleteCard => 'കാർഡ് ഡിലീറ്റ് ചെയ്യുക';

  @override
  String bodyRitualDeleteCard(String title) {
    return '\"$title\" ഡിലീറ്റ് ചെയ്യണമെന്ന് ഉറപ്പാണോ? ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';
  }

  @override
  String get bodyRitualCardDeleted => 'കാർഡ് ഡിലീറ്റ് ചെയ്തു.';

  @override
  String get errorRitualNoJournal => 'ദയവായി ആദ്യം ഒരു ജേണൽ നിർമ്മിക്കുക.';

  @override
  String get actionEditorGotoLineStart => '⇤';

  @override
  String get actionEditorGotoLineEnd => '⇥';

  @override
  String get bodyOcrCameraPermissionDenied =>
      'ടെക്സ്റ്റ് തിരിച്ചറിയുന്നതിനായി ഫോട്ടോ എടുക്കാൻ ക്യാമറ അനുമതി ആവശ്യമാണ്.';

  @override
  String get actionOcrCameraOpenSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get bodyOcrCameraNoCameras => 'ഈ ഉപകരണത്തിൽ ക്യാമറ ലഭ്യമല്ല.';

  @override
  String get tooltipOcrCameraFlashOff => 'ഫ്ലാഷ് ഓഫ്';

  @override
  String get tooltipOcrCameraFlashAuto => 'ഫ്ലാഷ് ഓട്ടോ';

  @override
  String get tooltipOcrCameraFlashOn => 'ഫ്ലാഷ് ഓൺ';

  @override
  String get tooltipOcrCameraFlashTorch => 'ടോർച്ച് ഓൺ';

  @override
  String get tooltipOcrCameraGridToggle => 'ഫ്രെയിമിംഗ് ഗ്രിഡ്';

  @override
  String get tooltipOcrCameraSwitch => 'ക്യാമറ മാറ്റുക';

  @override
  String get descOcrCameraCapture =>
      'ഫോക്കസ് ചെയ്യാൻ ടാപ്പ് ചെയ്യുക • സൂം ചെയ്യാൻ പിഞ്ച് ചെയ്യുക';

  @override
  String get actionOcrCameraCapture => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get actionOcrCameraGallery => 'ഗ്യാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get labelOcrCameraExposure => 'എക്സ്പോഷർ';

  @override
  String get labelOcrCameraZoom => 'സൂം';

  @override
  String get tooltipOcrCameraFocusAuto => 'ഓട്ടോ ഫോക്കസ്';

  @override
  String get tooltipOcrCameraFocusLocked => 'ഫോക്കസ് ലോക്ക് ചെയ്തു';

  @override
  String get tooltipOcrCameraExposureAuto => 'ഓട്ടോ എക്സ്പോഷർ';

  @override
  String get tooltipOcrCameraExposureLocked => 'എക്സ്പോഷർ ലോക്ക് ചെയ്തു';

  @override
  String get tooltipOcrCameraControls => 'ക്യാമറ ക്രമീകരണങ്ങൾ';

  @override
  String get actionOcrCameraReset => 'റീസെറ്റ്';

  @override
  String get titleOcrEnhance => 'മെച്ചപ്പെടുത്തുക & സ്കാൻ ചെയ്യുക';

  @override
  String get tooltipOcrEnhanceRotateLeft => 'ഇടത്തോട്ട് തിരിക്കുക';

  @override
  String get tooltipOcrEnhanceRotateRight => 'വലത്തോട്ട് തിരിക്കുക';

  @override
  String get labelOcrEnhanceCrop => 'ക്രോപ്പ് ചെയ്യുക';

  @override
  String get tabOcrEnhanceFilter => 'ഫിൽട്ടർ';

  @override
  String get actionOcrEnhanceInvert => 'നിറം മറിക്കുക';

  @override
  String get labelOcrEnhanceFilterOriginal => 'യഥാർത്ഥം';

  @override
  String get labelOcrEnhanceFilterDocument => 'ഡോക്യുമെന്റ്';

  @override
  String get labelOcrEnhanceFilterGrayscale => 'ഗ്രേസ്കെയിൽ';

  @override
  String get actionOcrEnhanceFilterEnhance => 'ഹൈ കോൺട്രാസ്റ്റ്';

  @override
  String get labelOcrEnhanceBrightness => 'തെളിച്ചം';

  @override
  String get labelOcrEnhanceContrast => 'കോൺട്രാസ്റ്റ്';

  @override
  String get tabOcrEnhanceAdjust => 'ക്രമീകരിക്കുക';

  @override
  String get titleOcrEnhanceLiveText => 'തിരിച്ചറിഞ്ഞ ടെക്സ്റ്റ്';

  @override
  String get bodyOcrEnhanceLiveTextNone =>
      'ടെക്സ്റ്റ് കണ്ടെത്തിയില്ല. കോൺട്രാസ്റ്റ് ക്രമീകരിക്കുകയോ ചിത്രം തിരിക്കുകയോ ചെയ്യുക.';

  @override
  String descOcrEnhanceLiveWordCount(int count) {
    return '$count വാക്കുകൾ കണ്ടെത്തി';
  }

  @override
  String get actionOcrEnhanceInsertText => 'എൻട്രിയിലേക്ക് ചേർക്കുക';

  @override
  String get actionOcrEnhanceRetake => 'വീണ്ടും എടുക്കുക';

  @override
  String get bodyOcrEnhanceProcessing => 'ചിത്രം മെച്ചപ്പെടുത്തുന്നു...';

  @override
  String get bodyOcrEnhanceLiveScanning => 'ടെക്സ്റ്റ് സ്കാൻ ചെയ്യുന്നു...';

  @override
  String get labelOcrLanguageAll => 'ഇംഗ്ലീഷ് + മലയാളം';

  @override
  String get labelOcrLanguageMalayalam => 'മലയാളം';

  @override
  String get labelOcrLanguageEnglish => 'ഇംഗ്ലീഷ്';

  @override
  String get tooltipOcrLanguageSelect => 'OCR ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get titleLanguage => 'ഭാഷ';

  @override
  String get labelLanguageSystemDefault => 'സിസ്റ്റം സ്വതവേ';

  @override
  String get descLanguageSystemDefault =>
      'ഫോണിന്റെ ഭാഷ പിന്തുടരുന്നു. ആ ഭാഷ ലഭ്യമല്ലെങ്കിൽ ഇംഗ്ലീഷ് ഉപയോഗിക്കുന്നു.';

  @override
  String get labelLanguageEnglish => 'English';

  @override
  String get labelLanguageMalayalam => 'മലയാളം';

  @override
  String get labelLanguageSanskrit => 'संस्कृतम्';

  @override
  String labelLanguageCurrent(String language) {
    return 'ഭാഷ: $language';
  }

  @override
  String get aboutDetailAuthor => 'രചയിതാവ്';

  @override
  String get aboutDetailEmail => 'ഇമെയിൽ';

  @override
  String get aboutDetailLicense => 'ലൈസൻസ്';

  @override
  String get aboutDetailAiUsed => 'ഉപയോഗിച്ച AI';

  @override
  String get aboutDetailIdeUsed => 'ഉപയോഗിച്ച IDE';

  @override
  String get bodyAboutBuildDateUnavailable => 'നിർമ്മിച്ച തീയതി ലഭ്യമല്ല';

  @override
  String madeWithLove(String heart) {
    return 'സ്നേഹത്തോടെ $heart ഇന്ത്യയിൽ നിന്ന്';
  }

  @override
  String get madeWithLoveA11y => 'സ്നേഹത്തോടെ ഇന്ത്യയിൽ നിന്ന്';

  @override
  String get tooltipFilterEntries => 'കുറിപ്പുകൾ അരിക്കുക';

  @override
  String get tooltipSaveSearch => 'തിരയൽ സൂക്ഷിക്കുക';

  @override
  String get tooltipResetScanner => 'സ്കാനർ പുനഃസജ്ജമാക്കുക';

  @override
  String get tooltipToggleTorch => 'ടോർച്ച് മാറ്റുക';

  @override
  String get tooltipSwitchCamera => 'ക്യാമറ മാറ്റുക';

  @override
  String get tooltipCopyPairingCode => 'ജോടിക്കോഡ് പകർത്തുക';

  @override
  String get tooltipSlower => 'വേഗം കുറയ്ക്കുക';

  @override
  String get tooltipFaster => 'വേഗം കൂട്ടുക';

  @override
  String get tooltipRecordVoiceNote => 'ശബ്ദക്കുറിപ്പ് രേഖപ്പെടുത്തുക';

  @override
  String get tooltipStopRecording => 'രേഖപ്പെടുത്തൽ നിർത്തുക';

  @override
  String get tooltipMoreOptions => 'കൂടുതൽ';

  @override
  String get tooltipShowDetails => 'വിശദാംശങ്ങൾ കാണുക';

  @override
  String get tooltipRemove => 'നീക്കുക';

  @override
  String get descRitualCard01Title => 'സ്വധർമ്മം';

  @override
  String get descRitualCard01Prompt =>
      'നിങ്ങളുടെ ജീവിതത്തിന്റെ ഈ ഘട്ടത്തിൽ നിങ്ങൾക്ക് മാത്രം നിറവേറ്റാൻ കഴിയുന്ന സവിശേഷമായ കടമ എന്താണ്? ഇന്ന് നിങ്ങളത് എങ്ങനെ നിർവഹിക്കുന്നു?';

  @override
  String get descRitualCard01Quote =>
      'മറ്റൊരാളുടെ ധർമ്മം ഭംഗിയായി ചെയ്യുന്നതിനേക്കാൾ ശ്രേഷ്ഠമാണ് സ്വന്തം ധർമ്മം അപൂർണ്ണമായെങ്കിലും അനുഷ്ഠിക്കുന്നത്.';

  @override
  String get descRitualCard01Source => 'ഭഗവദ്ഗീത 3.35';

  @override
  String get descRitualCard02Title => 'ചെറിയ കാര്യങ്ങളിലെ ധർമ്മം';

  @override
  String get descRitualCard02Prompt =>
      'ഇന്നത്തെ നിങ്ങളുടെ നിത്യജീവിതത്തിലെ ഏത് ചെറിയ കാര്യത്തിലാണ് എളുപ്പമുള്ളതിനേക്കാൾ ശരിയായ വഴി തിരഞ്ഞെടുക്കാൻ സാധിക്കുക?';

  @override
  String get descRitualCard02Quote =>
      'സർവ്വ ജീവികളുടെയും ക്ഷേമത്തിനായാണ് ധർമ്മം നിലകൊള്ളുന്നത്. എന്തിലൂടെയാണോ സർവ്വ ജീവജാലങ്ങളും നിലനിൽക്കുന്നത്, അതാണ് ധർമ്മം.';

  @override
  String get descRitualCard02Source => 'മഹാഭാരതം, ശാന്തിപർവ്വം 109.10';

  @override
  String get descRitualCard03Title => 'ധർമ്മചക്രം';

  @override
  String get descRitualCard03Prompt =>
      'നിങ്ങൾക്കുള്ള ഒരു ബന്ധത്തെയോ ഉത്തരവാദിത്തത്തെയോ കുറിച്ച് ചിന്തിക്കുക. സത്യസന്ധതയോടെയാണോ നിങ്ങൾ അതിനെ പരിപാലിക്കുന്നത്, അതോ അവഗണിക്കുകയാണോ?';

  @override
  String get descRitualCard03Quote =>
      'ധർമ്മോ രക്ഷതി രക്ഷിതഃ — സംരക്ഷിക്കപ്പെടുന്ന ധർമ്മം നമ്മെ സംരക്ഷിക്കുന്നു.';

  @override
  String get descRitualCard03Source => 'മനുസ്മൃതി 8.15';

  @override
  String get descRitualCard04Title => 'ശാശ്വത ക്രമം';

  @override
  String get descRitualCard04Prompt =>
      'പ്രകൃതിയിൽ — ഉദയസൂര്യനിലും ഋതുഭേദങ്ങളിലും ഒഴുകുന്ന നദിയിലും — ഋതത്തിന്റെ (പ്രപഞ്ച ക്രമം) താളം എവിടെയാണ് കാണുന്നത്? അത് നിങ്ങളുടെ ജീവിതത്തെ എങ്ങനെ പ്രതിഫലിപ്പിക്കുന്നു?';

  @override
  String get descRitualCard04Quote =>
      'സമുദ്രത്തിലേക്ക് നദികൾ ഒഴുകിയെത്തിയാലും സമുദ്രം കരകവിയാത്തതുപോലെ, ആഗ്രഹങ്ങൾ ഉള്ളിലൊഴുകിയെത്തുമ്പോഴും ജ്ഞാനി സദാ ശാന്തനായിരിക്കുന്നു.';

  @override
  String get descRitualCard04Source => 'ഭഗവദ്ഗീത 2.70';

  @override
  String get descRitualCard05Title => 'പ്രതിസന്ധിയിലെ ധർമ്മം';

  @override
  String get descRitualCard05Prompt =>
      'ജീവിതം പരീക്ഷണങ്ങൾ നേരിടുമ്പോൾ, വിട്ടുവീഴ്ച ചെയ്യാൻ നിങ്ങൾ വിസമ്മതിക്കുന്ന മൂല്യം ഏതാണ്? എന്തുകൊണ്ടാണ് അത് നിങ്ങൾക്ക് അത്ര പ്രധാനമാകുന്നത്?';

  @override
  String get descRitualCard05Quote =>
      'ഏറ്റവും കഠിനമായ പ്രതിസന്ധികളിലും ഒരാൾ ധർമ്മം ഉപേക്ഷിക്കാൻ പാടില്ല.';

  @override
  String get descRitualCard05Source => 'രാമായണം, അയോദ്ധ്യാകാണ്ഡം';

  @override
  String get descRitualCard06Title => 'നിഷ്കാമ കർമ്മം';

  @override
  String get descRitualCard06Prompt =>
      'ഫലത്തെക്കുറിച്ചുള്ള ആശങ്ക ഉപേക്ഷിച്ച്, പ്രവൃത്തിയുടെ ഗുണമേന്മയിൽ മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിക്കാൻ നിങ്ങൾക്ക് കഴിയുന്ന ഒരു കാര്യം എന്താണ്?';

  @override
  String get descRitualCard06Quote =>
      'കർമ്മണ്യേവാധികാരസ്തേ മാ ഫലേഷു കദാചന — കർമ്മം ചെയ്യാൻ മാത്രമേ നിങ്ങൾക്ക് അധികാരമുള്ളൂ, ഫലങ്ങളിൽ ഒരിക്കലുമില്ല.';

  @override
  String get descRitualCard06Source => 'ഭഗവദ്ഗീത 2.47';

  @override
  String get descRitualCard07Title => 'ഇന്ന് നടുന്ന വിത്ത്';

  @override
  String get descRitualCard07Prompt =>
      'ഓരോ പ്രവൃത്തിയും ഒരു വിത്താണ്. ക്ഷമ, ദയ, അച്ചടക്കം — ഇതിൽ ഏതുതരം വിത്താണ് നിങ്ങൾ ഇന്ന് നടുന്നത്?';

  @override
  String get descRitualCard07Quote =>
      'ഒരുവൻ എന്താണോ വിതയ്ക്കുന്നത്, അത് അവൻ കൊയ്യും. സ്വന്തം കർമ്മഫലങ്ങളിൽ നിന്ന് ആർക്കും ഒഴിഞ്ഞുമാറാനാവില്ല.';

  @override
  String get descRitualCard07Source => 'മഹാഭാരതം, വനപർവ്വം';

  @override
  String get descRitualCard08Title => 'നിസ്വാർത്ഥ സേവനം';

  @override
  String get descRitualCard08Prompt =>
      'പ്രശംസയോ പ്രതിഫലമോ ആഗ്രഹിക്കാതെ ചെയ്ത ഒരു കാര്യത്തെക്കുറിച്ച് ചിന്തിക്കുക. അപ്പോൾ എന്ത് തോന്നി? ആ മനോഭാവം ഇന്നത്തെ കൂടുതൽ കാര്യങ്ങളിലേക്ക് കൊണ്ടുവരാനാകുമോ?';

  @override
  String get descRitualCard08Quote =>
      'നിസ്വാർത്ഥ കർമ്മങ്ങളിൽ മുഴുകുന്ന ജ്ഞാനികൾ ഫലത്തിലുള്ള ആസക്തി വെടിഞ്ഞ് പരമശാന്തി പ്രാപിക്കുന്നു.';

  @override
  String get descRitualCard08Source => 'ഭഗവദ്ഗീത 5.12';

  @override
  String get descRitualCard09Title => 'ശീലങ്ങളുടെ ചങ്ങല പൊട്ടിക്കുക';

  @override
  String get descRitualCard09Prompt =>
      'ദേഷ്യം, ഒളിച്ചോട്ടം, പഴിചാരൽ തുടങ്ങി നിങ്ങൾ ആവർത്തിക്കുന്ന എന്തെങ്കിലും പ്രതികരണ രീതിയുണ്ടോ? ഇന്ന് ബോധപൂർവ്വം മറ്റൊരു പ്രതികരണം തിരഞ്ഞെടുത്താൽ എങ്ങനെയിരിക്കും?';

  @override
  String get descRitualCard09Quote =>
      'കർമ്മേന്ദ്രിയങ്ങളെ അടക്കി നിർത്തുമ്പോഴും മനസ്സ് വിഷയങ്ങളിൽ വ്യാപരിക്കുന്നവൻ വ്യാജനാണ്.';

  @override
  String get descRitualCard09Source => 'ഭഗവദ്ഗീത 3.6';

  @override
  String get descRitualCard10Title => 'നിത്യജീവിതത്തിലെ കർമ്മയോഗം';

  @override
  String get descRitualCard10Prompt =>
      'പാചകം, ജോലി തുടങ്ങിയ ദൈനംദിന കാര്യങ്ങളെ പൂർണ്ണ ശ്രദ്ധയോടും സമർപ്പണത്തോടും കൂടി ഒരു വഴിപാടായി മാറ്റാൻ എങ്ങനെ സാധിക്കും?';

  @override
  String get descRitualCard10Quote =>
      'നീ എന്തു ചെയ്യുന്നുവോ, എന്ത് ഭക്ഷിക്കുന്നുവോ, എന്ത് ഹോമിക്കുന്നുവോ, എന്ത് ദാനം ചെയ്യുന്നുവോ, അതെല്ലാം എനിക്കുള്ള സമർപ്പണമായി ചെയ്യുക.';

  @override
  String get descRitualCard10Source => 'ഭഗവദ്ഗീത 9.27';

  @override
  String get descRitualCard11Title => 'ഭക്തിയുടെ ഹൃദയം';

  @override
  String get descRitualCard11Prompt =>
      'ഒരു പ്രാർത്ഥന, ഒരു ഓർമ്മ, ഒരു പുണ്യസ്ഥലം, ദൈവചിന്ത — നിങ്ങളുടെ ഹൃദയത്തിൽ ആദരവും സ്നേഹവും നിറയ്ക്കുന്നത് എന്താണ്? അതിൽ മനസ്സ് ഏകാഗ്രമാക്കുക.';

  @override
  String get descRitualCard11Quote =>
      'ഭക്തിയോടെ ഒരു ഇലയോ പൂവോ ഫലമോ ജലമോ എനിക്ക് സമർപ്പിച്ചാൽ, ശുദ്ധമനസ്സോടെയുള്ള ആ സ്നേഹസമർപ്പണം ഞാൻ സ്വീകരിക്കുന്നു.';

  @override
  String get descRitualCard11Source => 'ഭഗവദ്ഗീത 9.26';

  @override
  String get descRitualCard12Title => 'ആത്മസമർപ്പണവും വിശ്വാസവും';

  @override
  String get descRitualCard12Prompt =>
      'ഈശ്വരകൃപ നിങ്ങളെ നയിക്കുമെന്ന പൂർണ്ണവിശ്വാസത്തോടെ ഇന്ന് ഏത് ഭാരമാണ് ഈശ്വരപാദങ്ങളിൽ സമർപ്പിക്കാൻ കഴിയുക?';

  @override
  String get descRitualCard12Quote =>
      'സർവ്വധർമ്മാൻ പരിത്യജ്യ മാമേകം ശരണം വ്രജ — സർവ്വ ധർമ്മങ്ങളും ഉപേക്ഷിച്ച് എന്നെ മാത്രം ശരണം പ്രാപിക്കുക. ഞാൻ നിന്നെ സർവ്വ പാപങ്ങളിൽ നിന്നും മോചിപ്പിക്കാം; ഭയപ്പെടേണ്ട.';

  @override
  String get descRitualCard12Source => 'ഭഗവദ്ഗീത 18.66';

  @override
  String get descRitualCard13Title => 'സർവ്വത്തിലും ഈശ്വരദർശനം';

  @override
  String get descRitualCard13Prompt =>
      'ഇന്ന് നിങ്ങൾ കണ്ടുമുട്ടുന്ന ഓരോ വ്യക്തിയെയും ഈശ്വരസ്വരൂപമായി കാണാൻ കഴിയുമോ? അത് നിങ്ങളുടെ സംസാരത്തെയും കേൾവിയെയും എങ്ങനെ മാറ്റും?';

  @override
  String get descRitualCard13Quote =>
      'വിദ്യാസമ്പന്നനായ ബ്രാഹ്മണനിലും പശുവിലും ആനയിലും നായയിലും ചണ്ഡാളനിലും ജ്ഞാനികൾ ഒരേ ആത്മാവിനെ തുല്യമായി ദർശിക്കുന്നു.';

  @override
  String get descRitualCard13Source => 'ഭഗവദ്ഗീത 5.18';

  @override
  String get descRitualCard14Title => 'വിശുദ്ധമാക്കുന്ന നാമം';

  @override
  String get descRitualCard14Prompt =>
      'ശാന്തമായിരുന്ന് ഒരു പുണ്യനാമമോ മന്ത്രമോ ഉരുവിട്ടത് എപ്പോഴായിരുന്നു? അത് നിങ്ങളുടെ മനസ്സിൽ എന്ത് മാറ്റമാണുണ്ടാക്കിയത്?';

  @override
  String get descRitualCard14Quote =>
      'ഭവസമുദ്രം കടക്കാൻ ഭഗവാന്റെ നാമമെന്ന തോണിയല്ലാതെ മറ്റൊന്നുമില്ല.';

  @override
  String get descRitualCard14Source => 'തുളസീദാസ്, രാമചരിതമാനസം';

  @override
  String get descRitualCard15Title => 'കൃതജ്ഞതയിലെ കൃപ';

  @override
  String get descRitualCard15Prompt =>
      'നിങ്ങൾക്ക് ലഭിച്ച അപ്രതീക്ഷിതമായ അനുഗ്രഹങ്ങളിൽ ഇതുവരെ കൃതജ്ഞതയോടെ ഓർക്കാത്ത ഒന്ന് ഏതാണ്?';

  @override
  String get descRitualCard15Quote =>
      'ഞാൻ സർവ്വത്തിന്റെയും ഉത്ഭവസ്ഥാനമാണ്. എല്ലാം എന്നിൽ നിന്നാണ് ഉണ്ടാകുന്നത്. ഇതറിയുന്ന ജ്ഞാനികൾ ഭക്തിയോടെ എന്നെ ഭജിക്കുന്നു.';

  @override
  String get descRitualCard15Source => 'ഭഗവദ്ഗീത 10.8';

  @override
  String get descRitualCard16Title => 'ഞാൻ ആര്?';

  @override
  String get descRitualCard16Prompt =>
      'പേര്, ജോലി, സ്ഥാനമാനങ്ങൾ, ശരീരം എന്നിവയെല്ലാം മാറ്റിവെച്ചാൽ എന്താണ് ബാക്കിയുള്ളത്? ഈ ചോദ്യവുമായി അല്പനേരം ഇരിക്കുക: എല്ലാ ലേബലുകൾക്കും അപ്പുറം ഞാൻ ആരാണ്?';

  @override
  String get descRitualCard16Quote => 'തത്ത്വമസി — അത് നീയാകുന്നു.';

  @override
  String get descRitualCard16Source => 'ഛാന്ദോഗ്യോപനിഷത്ത് 6.8.7';

  @override
  String get descRitualCard17Title => 'സാക്ഷിചൈതന്യം';

  @override
  String get descRitualCard17Prompt =>
      'ചിന്തകളെ പിടിച്ചുവെക്കാതെ കടന്നുപോകുന്നത് നിരീക്ഷിക്കുക. അതിനെ വീക്ഷിക്കുന്ന സാക്ഷി ആരാണ്? ആ ബോധത്തിന് എപ്പോഴെങ്കിലും മുറിവേൽക്കാൻ കഴിയുമോ?';

  @override
  String get descRitualCard17Quote =>
      'ആത്മാവ് ജനിക്കുന്നില്ല, മരിക്കുന്നതുമില്ല. അത് നിത്യവും ശാശ്വതവുമാണ്. ശരീരം നശിക്കുമ്പോഴും അത് നശിക്കുന്നില്ല.';

  @override
  String get descRitualCard17Source => 'ഭഗവദ്ഗീത 2.20';

  @override
  String get descRitualCard18Title => 'മുക്തിയേകുന്ന ജ്ഞാനം';

  @override
  String get descRitualCard18Prompt =>
      'ജീവിതത്തെക്കുറിച്ചോ നിങ്ങളെക്കുറിച്ചോ ഉള്ള ഏത് സത്യമാണ് പൂർണ്ണമായി ഉൾക്കൊണ്ടപ്പോൾ നിങ്ങളെ ദുഃഖങ്ങളിൽ നിന്ന് മോചിപ്പിച്ചത്?';

  @override
  String get descRitualCard18Quote =>
      'ജ്ഞാനത്തിന് തുല്യമായി പവിത്രമായത് ഈ ലോകത്തിൽ മറ്റൊന്നുമില്ല. യോഗനിഷ്ഠയിലൂടെ മനസ്സ് ശുദ്ധമായവൻ ഈ ജ്ഞാനം തന്നിൽത്തന്നെ കണ്ടെത്തുന്നു.';

  @override
  String get descRitualCard18Source => 'ഭഗവദ്ഗീത 4.38';

  @override
  String get descRitualCard19Title => 'ഇന്ദ്രിയങ്ങൾക്കപ്പുറം';

  @override
  String get descRitualCard19Prompt =>
      'ഇന്ദ്രിയങ്ങൾ ബാഹ്യമായ കാഴ്ചകൾ മാത്രമാണ് കാണിക്കുന്നത്. നിങ്ങൾ ഇപ്പോൾ അഭിമുഖീകരിക്കുന്ന സാഹചര്യത്തിന് പിന്നിലുള്ള ആഴമേറിയ സത്യം എന്താണ്?';

  @override
  String get descRitualCard19Quote =>
      'ഇന്ദ്രിയങ്ങൾക്ക് അപ്പുറം വിഷയങ്ങളും, വിഷയങ്ങൾക്ക് അപ്പുറം മനസ്സും, മനസ്സിന് അപ്പുറം ബുദ്ധിയും, ബുദ്ധിക്ക് അപ്പുറം ആത്മാവും സ്ഥിതിചെയ്യുന്നു.';

  @override
  String get descRitualCard19Source => 'കഠോപനിഷത്ത് 1.3.10';

  @override
  String get descRitualCard20Title => 'ഉള്ളിലെ പ്രകാശം';

  @override
  String get descRitualCard20Prompt =>
      'കണ്ണുകളടച്ച് ഹൃദയത്തിൽ കെടാതെ കത്തുന്ന ഒരു തിരിനാളം സങ്കൽപ്പിക്കുക. ആ പ്രകാശം നിങ്ങളുടെ ഉള്ളിൽ എന്തിനെയാണ് വെളിച്ചത്തു കൊണ്ടുവരുന്നത്?';

  @override
  String get descRitualCard20Quote =>
      'അസതോ മാ സദ്ഗമയ, തമസോ മാ ജ്യോതിർഗമയ, മൃത്യോർ മാ അമൃതം ഗമയ — അസത്യത്തിൽ നിന്ന് സത്യത്തിലേക്കും, ഇരുളിൽ നിന്ന് വെളിച്ചത്തിലേക്കും, മരണത്തിൽ നിന്ന് അമരത്വത്തിലേക്കും നയിച്ചാലും.';

  @override
  String get descRitualCard20Source => 'ബൃഹദാരണ്യകോപനിഷത്ത് 1.3.28';

  @override
  String get descRitualCard21Title => 'പൂർണ്ണത';

  @override
  String get descRitualCard21Prompt =>
      'ആന്തരിക തലത്തിൽ നിങ്ങൾക്ക് ഒന്നിനും കുറവില്ലെങ്കിൽ, എന്തുകൊണ്ടാണ് അപൂർണ്ണത തോന്നുന്നത്? നിങ്ങൾ ഇതിനകം പൂർണ്ണനാണെന്ന സത്യത്തെക്കുറിച്ച് ചിന്തിക്കുക.';

  @override
  String get descRitualCard21Quote =>
      'ഓം പൂർണ്ണമദഃ പൂർണ്ണമിദം — അതും പൂർണ്ണം, ഇതും പൂർണ്ണം. പൂർണ്ണത്തിൽ നിന്ന് പൂർണ്ണമുണ്ടാകുന്നു. പൂർണ്ണത്തിൽ നിന്ന് പൂർണ്ണമെടുത്താലും പൂർണ്ണം അവശേഷിക്കുന്നു.';

  @override
  String get descRitualCard21Source => 'ഈശാവാസ്യോപനിഷത്ത്, ശാന്തിപാഠം';

  @override
  String get descRitualCard22Title => 'സർവ്വവ്യാപിയായ ബ്രഹ്മം';

  @override
  String get descRitualCard22Prompt =>
      'നിങ്ങളിൽ പ്രകാശിക്കുന്ന അതേ ചൈതന്യമാണ് സർവ്വ ജീവജാലങ്ങളിലും പ്രകാശിക്കുന്നത്. ഈ അറിവ് ഇന്ന് ലോകത്തെ നോക്കിക്കാണുന്ന രീതിയെ എങ്ങനെ മാറ്റുന്നു?';

  @override
  String get descRitualCard22Quote => 'അഹം ബ്രഹ്മാസ്മി — ഞാൻ ബ്രഹ്മമാകുന്നു.';

  @override
  String get descRitualCard22Source => 'ബൃഹദാരണ്യകോപനിഷത്ത് 1.4.10';

  @override
  String get descRitualCard23Title => 'മനസ്സിനെ അടക്കൽ';

  @override
  String get descRitualCard23Prompt =>
      'ചിന്തകൾ, ആകുലതകൾ, ഓർമ്മകൾ — മനസ്സിന്റെ ചാഞ്ചാട്ടങ്ങൾ ഇപ്പോൾ നിരീക്ഷിക്കുക. ഏതാനും ശ്വാസനേരത്തേക്ക് അവയെ ശാന്തമാക്കാൻ കഴിയുമോ?';

  @override
  String get descRitualCard23Quote =>
      'യോഗശ്ചിത്തവൃത്തിനിരോധഃ — മനസ്സിന്റെ വൃത്തികളെ അടക്കുന്നതാണ് യോഗം.';

  @override
  String get descRitualCard23Source => 'പതഞ്ജലി യോഗസൂത്രം 1.2';

  @override
  String get descRitualCard24Title => 'നിരന്തര അഭ്യാസം';

  @override
  String get descRitualCard24Prompt =>
      'തീവ്രതയേക്കാൾ പ്രധാനം സ്ഥിരതയാണെന്നറിഞ്ഞ്, ക്ഷമയോടും ഭക്തിയോടും കൂടി നിങ്ങൾക്ക് തുടരാൻ കഴിയുന്ന നല്ലൊരു ശീലം ഏതാണ്?';

  @override
  String get descRitualCard24Quote =>
      'ദീർഘകാലം, ഇടവേളകളില്ലാതെ, ആത്മാർത്ഥതയോടെ ശീലിക്കുമ്പോൾ അഭ്യാസം ദൃഢമായിത്തീരുന്നു.';

  @override
  String get descRitualCard24Source => 'പതഞ്ജലി യോഗസൂത്രം 1.14';

  @override
  String get descRitualCard25Title => 'സമചിത്തത';

  @override
  String get descRitualCard25Prompt =>
      'അടുത്തിടെയുണ്ടായ ഒരു വിജയവും പരാജയവും ഓർക്കുക. അമിതാഹ്ലാദമോ നിരാശയോ ഇല്ലാതെ രണ്ടിനെയും സമചിത്തതയോടെ കാണാൻ കഴിയുമോ?';

  @override
  String get descRitualCard25Quote => 'സമത്വം യോഗ ഉച്യതേ — സമചിത്തതയാണ് യോഗം.';

  @override
  String get descRitualCard25Source => 'ഭഗവദ്ഗീത 2.48';

  @override
  String get descRitualCard26Title => 'പഞ്ചയമങ്ങൾ';

  @override
  String get descRitualCard26Prompt =>
      'അഹിംസ, സത്യം, അസ്തേയം, ബ്രഹ്മചര്യം, അപരിഗ്രഹം — ഈ അഞ്ചിൽ ഇപ്പോൾ നിങ്ങൾക്ക് ഏറ്റവും വെല്ലുവിളിയാകുന്നത് ഏതാണ്, എന്തുകൊണ്ട്?';

  @override
  String get descRitualCard26Quote =>
      'അഹിംസ, സത്യം, അസ്തേയം, ബ്രഹ്മചര്യം, അപരിഗ്രഹം — ഇവ സാർവ്വലൗകികമായ മഹാവ്രതങ്ങളാണ്.';

  @override
  String get descRitualCard26Source => 'പതഞ്ജലി യോഗസൂത്രം 2.30';

  @override
  String get descRitualCard27Title => 'ഈശ്വരപ്രണിധാനം';

  @override
  String get descRitualCard27Prompt =>
      'സ്വന്തം നേട്ടത്തിനല്ലാതെ, പൂർണ്ണ സമർപ്പണമായി പ്രവൃത്തി ചെയ്യുമ്പോൾ എന്ത് അനുഭവപ്പെടുന്നു? നിങ്ങളുടെ അടുത്ത പ്രവൃത്തി മഹത്തായ ഒന്നിനായി സമർപ്പിക്കുക.';

  @override
  String get descRitualCard27Quote =>
      'ഈശ്വരനിലുള്ള പൂർണ്ണ സമർപ്പണത്തിലൂടെ സമാധി സിദ്ധിക്കുന്നു.';

  @override
  String get descRitualCard27Source => 'പതഞ്ജലി യോഗസൂത്രം 2.45';

  @override
  String get descRitualCard28Title => 'മനസ്സിലെ അഹിംസ';

  @override
  String get descRitualCard28Prompt =>
      'ഇന്ന് നിങ്ങളോടോ മറ്റുള്ളവരോടോ പരുഷമായ ചിന്തകൾ പുലർത്തിയിട്ടുണ്ടോ? അവയ്ക്ക് പകരം സ്നേഹവും കാരുണ്യവും പകരുന്നത് എങ്ങനെയുണ്ടാകും?';

  @override
  String get descRitualCard28Quote =>
      'അഹിംസാ പരമോ ധർമ്മഃ — അഹിംസയാണ് പരമമായ ധർമ്മം.';

  @override
  String get descRitualCard28Source => 'മഹാഭാരതം, അനുശാസനപർവ്വം 116.38';

  @override
  String get descRitualCard29Title => 'സർവ്വഭൂതദയ';

  @override
  String get descRitualCard29Prompt =>
      'അടുത്തിടെ കണ്ട ഒരു പക്ഷിയെക്കുറിച്ചോ മൃഗത്തെക്കുറിച്ചോ ചിന്തിക്കുക. സർവ്വ ജീവജാലങ്ങളോടും ആ കാരുണ്യം കാണിച്ചാൽ ഈ ലോകം എത്ര സുന്ദരമാകും?';

  @override
  String get descRitualCard29Quote =>
      'സർവ്വ ജീവികളിലും ആത്മാവിനെയും ആത്മാവിൽ സർവ്വ ജീവികളെയും ദർശിക്കുന്നവൻ ആരെയും വെറുക്കുന്നില്ല.';

  @override
  String get descRitualCard29Source => 'ഈശാവാസ്യോപനിഷത്ത്, മന്ത്രം 6';

  @override
  String get descRitualCard30Title => 'മൃദുവായ വാക്ക്';

  @override
  String get descRitualCard30Prompt =>
      'സംസാരിക്കുന്നതിന് മുൻപ് സ്വയം ചോദിക്കുക: ഇത് സത്യമാണോ? പ്രിയമുള്ളതാണോ? ആവശ്യമാണോ? ഈ ചിന്ത നിങ്ങളുടെ സംഭാഷണങ്ങളെ എങ്ങനെ മാറ്റുന്നു?';

  @override
  String get descRitualCard30Quote =>
      'ഉദ്വേഗമുണ്ടാക്കാത്തതും സത്യവും പ്രിയവും ഹിതവുമായ സംസാരമാണ് വാങ്മയ തപസ്സ്.';

  @override
  String get descRitualCard30Source => 'ഭഗവദ്ഗീത 17.15';

  @override
  String get descRitualCard31Title => 'ക്ഷമയുടെ മഹത്വം';

  @override
  String get descRitualCard31Prompt =>
      'നിങ്ങളെ വേദനിപ്പിച്ച ആരുടെ ഓർമ്മയാണ് ഇപ്പോഴും ചുമക്കുന്നത്? സ്വന്തം മനസ്സിന്റെ സ്വാതന്ത്ര്യത്തിനായി അവരോട് ക്ഷമിക്കാൻ എന്ത് മാറ്റമാണ് വേണ്ടത്?';

  @override
  String get descRitualCard31Quote => 'ക്ഷമ വീരന്മാരുടെ ഭൂഷണമാണ്.';

  @override
  String get descRitualCard31Source => 'മഹാഭാരതം, ഉദ്യോഗപർവ്വം 33.48';

  @override
  String get descRitualCard32Title => 'സത്യത്തിൽ ജീവിക്കുക';

  @override
  String get descRitualCard32Prompt =>
      'നിങ്ങളോടോ മറ്റുള്ളവരോടോ സത്യസന്ധതയില്ലാതെ പെരുമാറുന്ന എന്തെങ്കിലും ഉണ്ടോ? പൂർണ്ണമായ സത്യസന്ധത പുലർത്തിയാൽ അത് എങ്ങനെയുണ്ടാകും?';

  @override
  String get descRitualCard32Quote =>
      'സത്യമേവ ജയതേ — സത്യം മാത്രം ജയിക്കുന്നു.';

  @override
  String get descRitualCard32Source => 'മുണ്ഡകോപനിഷത്ത് 3.1.6';

  @override
  String get descRitualCard33Title => 'നേരിന്റെ ധൈര്യം';

  @override
  String get descRitualCard33Prompt =>
      'അസ്വസ്ഥത തോന്നുമെന്നതിനാൽ നിങ്ങൾ അഭിമുഖീകരിക്കാൻ മടിക്കുന്ന ഒരു സത്യം എന്താണ്? ധൈര്യത്തോടെ അതിനെ നേരിടാൻ എന്ത് വേണം?';

  @override
  String get descRitualCard33Quote =>
      'സത്യം വദ, ധർമ്മം ചര — സത്യം പറയുക, ധർമ്മം അനുഷ്ഠിക്കുക.';

  @override
  String get descRitualCard33Source => 'തൈത്തിരീയോപനിഷത്ത് 1.11.1';

  @override
  String get descRitualCard34Title => 'വാക്കുകൾക്കപ്പുറമുള്ള സത്യം';

  @override
  String get descRitualCard34Prompt =>
      'സത്യം വാക്കുകളിൽ മാത്രമല്ല, പ്രവൃത്തിയിലുമാണ്. നിങ്ങളുടെ ഇന്നത്തെ പ്രവൃത്തികൾ ഹൃദയത്തിലെ സത്യവുമായി പൊരുത്തപ്പെടുന്നുണ്ടോ?';

  @override
  String get descRitualCard34Quote =>
      'സത്യനിഷ്ഠയിലൂടെ മനുഷ്യൻ ദൈവികതയെ പ്രാപിക്കുന്നു.';

  @override
  String get descRitualCard34Source => 'ചാണക്യനീതി 14.3';

  @override
  String get descRitualCard35Title => 'വാഗ്ദാനപാലനം';

  @override
  String get descRitualCard35Prompt =>
      'നിങ്ങളോടോ മറ്റുള്ളവരോടോ ഈശ്വരനോടോ ചെയ്ത പാലിക്കേണ്ട ഒരു വാഗ്ദാനം എന്താണ്? അത് വീണ്ടും ഓർമ്മിച്ച് ഉറപ്പിക്കുക.';

  @override
  String get descRitualCard35Quote =>
      'വാക്ക് പാലിക്കുക. വാക്ക് തെറ്റിക്കുന്നവൻ വിശ്വാസം തകർക്കുന്നു; തകർന്ന വിശ്വാസം തിരിച്ചുപിടിക്കാൻ പ്രയാസമാണ്.';

  @override
  String get descRitualCard35Source => 'വിദുരനീതി, മഹാഭാരതം';

  @override
  String get descRitualCard36Title => 'ത്യജിക്കൽ';

  @override
  String get descRitualCard36Prompt =>
      'നിങ്ങളുടെ വളർച്ചയെ തടയുന്ന ഏത് ആഗ്രഹത്തെയും വസ്തുവിനെയുമാണ് നിങ്ങൾ മുറുകെ പിടിച്ചിരിക്കുന്നത്? അതിനെ ശാന്തമായി മനസ്സിൽ നിന്ന് വിട്ടൊഴിയുക.';

  @override
  String get descRitualCard36Quote =>
      'കണ്ടതോ കേട്ടതോ ആയ വിഷയങ്ങളിലുള്ള ആഗ്രഹങ്ങളിൽ നിന്നുള്ള പൂർണ്ണമായ വിടുതലാണ് വൈരാഗ്യം.';

  @override
  String get descRitualCard36Source => 'പതഞ്ജലി യോഗസൂത്രം 1.15';

  @override
  String get descRitualCard37Title => 'മാറ്റമില്ലാത്ത ആത്മാവ്';

  @override
  String get descRitualCard37Prompt =>
      'വികാരങ്ങൾ, സാഹചര്യങ്ങൾ, ബന്ധങ്ങൾ — ചുറ്റുമുള്ളതെല്ലാം മാറുന്നു. ജീവിതത്തിലെ പ്രതിസന്ധികളിലും നിങ്ങളിൽ മാറ്റമില്ലാതെ തുടരുന്ന ഭാഗം ഏതാണ്?';

  @override
  String get descRitualCard37Quote =>
      'അസത്യമായതിന് നിലനിൽപ്പില്ല. സത്യമായതിന് നാശവുമില്ല.';

  @override
  String get descRitualCard37Source => 'ഭഗവദ്ഗീത 2.16';

  @override
  String get descRitualCard38Title => 'സന്തോഷവും സംതൃപ്തിയും';

  @override
  String get descRitualCard38Prompt =>
      'ജീവിതത്തിൽ ഇപ്പോൾത്തന്നെ മതിയായതായി എന്തെല്ലാമുണ്ട്? ആഗ്രഹങ്ങളും യഥാർത്ഥ ആവശ്യങ്ങളും തമ്മിലുള്ള വ്യത്യാസത്തെക്കുറിച്ച് ചിന്തിക്കുക.';

  @override
  String get descRitualCard38Quote =>
      'സന്തോഷാദനുത്തമഃ സുഖലാഭഃ — സംതൃപ്തിയിൽ നിന്നാണ് ഉത്തമമായ ആനന്ദമുണ്ടാകുന്നത്.';

  @override
  String get descRitualCard38Source => 'പതഞ്ജലി യോഗസൂത്രം 2.42';

  @override
  String get descRitualCard39Title => 'സുഖദുഃഖങ്ങൾക്കപ്പുറം';

  @override
  String get descRitualCard39Prompt =>
      'അസ്വസ്ഥതകളിൽ നിന്ന് ഒളിച്ചോടാതെയും സുഖങ്ങളിൽ ഭ്രമിക്കാതെയും ഇരിക്കാൻ കഴിയുമോ? രണ്ടിനെയും വെറുതെ നിരീക്ഷിക്കുമ്പോൾ എന്താണ് സംഭവിക്കുന്നത്?';

  @override
  String get descRitualCard39Quote =>
      'സുഖത്തിലും ദുഃഖത്തിലും ഇളകാതെ സമചിത്തത പാലിക്കുന്നവൻ മോക്ഷത്തിന് അർഹനായിത്തീരുന്നു.';

  @override
  String get descRitualCard39Source => 'ഭഗവദ്ഗീത 2.15';

  @override
  String get descRitualCard40Title => 'ദാനത്തിന്റെ ആനന്ദം';

  @override
  String get descRitualCard40Prompt =>
      'പ്രതിഫലം ഇച്ഛിക്കാതെ സമയം, ശ്രദ്ധ, നല്ലൊരു വാക്ക്, ഒരു സഹായഹസ്തം — ഇന്ന് നിങ്ങൾക്ക് എന്ത് നൽകാൻ കഴിയും?';

  @override
  String get descRitualCard40Quote =>
      'നിസ്സഹായരായവരെ സഹായിക്കുന്നതാണ് ഏറ്റവും ശ്രേഷ്ഠമായ ദാനം.';

  @override
  String get descRitualCard40Source => 'തിരുക്കുറൾ 221';

  @override
  String get descRitualCard41Title => 'മനുഷ്യനിലെ ഈശ്വരനെ സേവിക്കുക';

  @override
  String get descRitualCard41Prompt =>
      'നിങ്ങളുടെ മുന്നിൽ നിൽക്കുന്ന വ്യക്തി ഈശ്വരനാണെങ്കിൽ നിങ്ങളവരോട് എങ്ങനെ പെരുമാറും? അടുത്ത ഒരു മണിക്കൂർ ഈ ഭാവത്തോടെ ജീവിച്ചുനോക്കൂ.';

  @override
  String get descRitualCard41Quote => 'മാനവ സേവയാണ് മാധവ സേവ.';

  @override
  String get descRitualCard41Source => 'സ്വാമി വിവേകാനന്ദൻ';

  @override
  String get descRitualCard42Title => 'നിസ്വാർത്ഥ പ്രവർത്തനം';

  @override
  String get descRitualCard42Prompt =>
      'അംഗീകാരങ്ങൾ ആഗ്രഹിക്കാതെ ആരെയെങ്കിലും സഹായിച്ചപ്പോൾ തോന്നിയ ആത്മനിർവൃതി ഓർക്കുക. അത് നിങ്ങളെ എന്ത് പഠിപ്പിച്ചു?';

  @override
  String get descRitualCard42Quote =>
      'ഉത്തിഷ്ഠത ജാഗ്രത പ്രാപ്യ വരാൻ നിബോധത — എഴുന്നേൽക്കുക, ഉണരുക, ലക്ഷ്യത്തിലെത്തും വരെ മുന്നേറുക.';

  @override
  String get descRitualCard42Source =>
      'കഠോപനിഷത്ത് 1.3.14 / സ്വാമി വിവേകാനന്ദൻ';

  @override
  String get descRitualCard43Title => 'വസുധൈവ കുടുംബകം';

  @override
  String get descRitualCard43Prompt =>
      'ലോകം മുഴുവൻ ഒരു കുടുംബമാണ്. എല്ലാവരുടെയും ക്ഷേമം പ്രധാനമാണെന്ന ചിന്തയോടെ ഇന്ന് നിങ്ങൾക്ക് ചെയ്യാൻ കഴിയുന്ന ഒരു കാര്യം എന്താണ്?';

  @override
  String get descRitualCard43Quote =>
      'വസുധൈവ കുടുംബകം — ഈ ലോകം മുഴുവൻ ഒരു കുടുംബമാകുന്നു.';

  @override
  String get descRitualCard43Source => 'മഹോപനിഷത്ത് 6.71';

  @override
  String get descRitualCard44Title => 'കാരുണ്യത്തിന്റെ സമ്പത്ത്';

  @override
  String get descRitualCard44Prompt =>
      'നിങ്ങളോട് മറ്റൊരാൾ കാട്ടിയ എളിമയുള്ള കാരുണ്യം ഓർക്കുക. അതേ ദയ ഇന്ന് മറ്റൊരാളിലേക്ക് എങ്ങനെ പകരാം?';

  @override
  String get descRitualCard44Quote =>
      'ഉള്ളതിൽ നിന്ന് കാരുണ്യത്തോടെ ദാനം ചെയ്താൽ ദരിദ്രന്റെ ദാരിദ്ര്യം പോലും ഇല്ലാതാകും.';

  @override
  String get descRitualCard44Source => 'തിരുക്കുറൾ 247';

  @override
  String get descRitualCard45Title => 'ആന്തരിക ശാന്തി';

  @override
  String get descRitualCard45Prompt =>
      'കണ്ണുകളടച്ച് പതുക്കെ മൂന്ന് തവണ ശ്വാസമെടുക്കുക. ഓരോ ശ്വാസത്തിനും ഇടയിലുള്ള നിശബ്ദത അറിയുക. ആ നിശബ്ദതയാണ് നിങ്ങളുടെ സത്യം. അത് ദിവസം മുഴുവൻ കൊണ്ടുനടക്കാമോ?';

  @override
  String get descRitualCard45Quote =>
      'മനസ്സിനെ കീഴടക്കിയവന് മനസ്സ് ഉത്തമ മിത്രമാണ്; കീഴടക്കാൻ കഴിയാത്തവന് മനസ്സ് പരമശത്രുവായിത്തീരുന്നു.';

  @override
  String get descRitualCard45Source => 'ഭഗവദ്ഗീത 6.6';

  @override
  String get descRitualCard46Title => 'സ്തുതിനിന്ദകളിൽ സമഭാവം';

  @override
  String get descRitualCard46Prompt =>
      'അടുത്തിടെ കേട്ട ഒരു പ്രശംസയും വിമർശനവും ഓർക്കുക. ഒന്നിൽ അഭിരമിക്കാതെയും മറ്റൊന്നിനെ വെറുക്കാതെയും രണ്ടിനെയും ശാന്തതയോടെ കാണാൻ കഴിയുമോ?';

  @override
  String get descRitualCard46Quote =>
      'ശത്രുവിനോടും മിത്രത്തോടും മാനാപമാനങ്ങളിലും ശീതോഷ്ണങ്ങളിലും സുഖദുഃഖങ്ങളിലും സമഭാവം പുലർത്തുന്നവൻ എനിക്ക് പ്രിയപ്പെട്ടവനാണ്.';

  @override
  String get descRitualCard46Source => 'ഭഗവദ്ഗീത 12.18–19';

  @override
  String get descRitualCard47Title => 'ചെളിയിലെ താമര';

  @override
  String get descRitualCard47Prompt =>
      'ചെളിയിലാണ് വിരിയുന്നതെങ്കിലും താമരപ്പൂവിൽ ചെളി പറ്റുന്നില്ല. നിങ്ങളുടെ ജീവിതത്തിലെ പ്രയാസകരമായ സാഹചര്യം എന്താണ്? അതിൽ കളങ്കപ്പെടാതെ വളരാൻ എങ്ങനെ കഴിയും?';

  @override
  String get descRitualCard47Quote =>
      'ആസക്തികളില്ലാതെ കർമ്മങ്ങളെ ബ്രഹ്മത്തിൽ സമർപ്പിച്ച് പ്രവർത്തിക്കുന്നവനെ പാപങ്ങൾ സ്പർശിക്കുന്നില്ല; താമരയിലയിലെ വെള്ളത്തുള്ളിപോലെ.';

  @override
  String get descRitualCard47Source => 'ഭഗവദ്ഗീത 5.10';

  @override
  String get descRitualCard48Title => 'ഓം ശാന്തി';

  @override
  String get descRitualCard48Prompt =>
      'നിശ്ചലമായിരുന്ന് മൂന്ന് തവണ \"ഓം ശാന്തി\" ജപിക്കുക — ശരീരത്തിലും മനസ്സിലും ആത്മാവിലും ശാന്തി. അങ്ങനെ ചെയ്യുമ്പോൾ ഉള്ളിൽ നിന്ന് അലിഞ്ഞുപോകുന്ന അസ്വസ്ഥതകൾ എന്തൊക്കെയാണ്?';

  @override
  String get descRitualCard48Quote =>
      'ഓം ശാന്തിഃ ശാന്തിഃ ശാന്തിഃ — ശാന്തി, ശാന്തി, ശാന്തി.';

  @override
  String get descRitualCard48Source => 'ഉപനിഷത് ശാന്തിമന്ത്രം';

  @override
  String get descRitualCard49Title => 'സർവ്വർക്കും ക്ഷേമം';

  @override
  String get descRitualCard49Prompt =>
      'നിങ്ങൾക്കും പ്രിയപ്പെട്ടവർക്കും അപരിചിതർക്കും സർവ്വ ജീവജാലങ്ങൾക്കും മനസ്സാൽ മംഗളങ്ങൾ നേരുക. കാരുണ്യത്തിന്റെ വൃത്തം വികസിക്കുമ്പോൾ ഹൃദയം നിറയുന്നത് അനുഭവിക്കുക.';

  @override
  String get descRitualCard49Quote =>
      'സർവേ ഭവന്തു സുഖിനഃ സർവേ സന്തു നിരാമയാഃ, സർവേ ഭദ്രാണി പശ്യന്തു മാ കശ്ചിദ്ദുഃഖഭാഗ് ഭവേത് — എല്ലാവരും സുഖമായിരിക്കട്ടെ, എല്ലാവരും രോഗവിമുക്തരാകട്ടെ, എല്ലാവരും മംഗളങ്ങൾ കാണട്ടെ, ആർക്കും ദുഃഖമുണ്ടാകാതിരിക്കട്ടെ.';

  @override
  String get descRitualCard49Source => 'ഉപനിഷത് പ്രാർത്ഥന';

  @override
  String get descRitualCard50Title => 'ശക്തിയും ശാന്തിയും';

  @override
  String get descRitualCard50Prompt =>
      'യഥാർത്ഥ കരുത്ത് കഠിനമായ സമ്മർദ്ദത്തിൽ നിന്നല്ല, ആഴത്തിലുള്ള ആന്തരിക ശാന്തിയിൽ നിന്നാണ് വരുന്നത്. ശാന്തമായ ദൃഢനിശ്ചയത്തോടെ ചെയ്യാൻ കഴിയുന്ന കാര്യം എന്താണ്?';

  @override
  String get descRitualCard50Quote =>
      'ശക്തിയാണ് ജീവിതം, ബലഹീനതയാണ് മരണം. ശക്തിയാണ് മരുന്ന്, ശക്തിയാണ് പരിഹാരം. ശക്തിയാണ് ഉപനിഷത്തുകൾ പഠിപ്പിക്കുന്നത്.';

  @override
  String get descRitualCard50Source => 'സ്വാമി വിവേകാനന്ദൻ';

  @override
  String get labelRitualThemeDharma => 'ധർമ്മം';

  @override
  String get labelRitualThemeKarma => 'കർമ്മം';

  @override
  String get labelRitualThemeBhakti => 'ഭക്തി';

  @override
  String get labelRitualThemeJnana => 'ജ്ഞാനം';

  @override
  String get labelRitualThemeYoga => 'യോഗം';

  @override
  String get labelRitualThemeAhimsa => 'അഹിംസ';

  @override
  String get labelRitualThemeSathya => 'സത്യം';

  @override
  String get labelRitualThemeVairagya => 'വൈരാഗ്യം';

  @override
  String get labelRitualThemeSeva => 'സേവനം';

  @override
  String get labelRitualThemeShanti => 'ശാന്തി';

  @override
  String get labelBreathTechniqueBox => 'ചതുരശ്വസനം';

  @override
  String get labelBreathTechniqueRelaxing => 'വിശ്രാന്തി ശ്വസനം';

  @override
  String get labelBreathTechniqueCalm => 'ശാന്ത താളം';

  @override
  String get labelBreathPhaseInhale => 'ശ്വാസമെടുക്കുക';

  @override
  String get labelBreathPhaseHold => 'പിടിച്ചുനിർത്തുക';

  @override
  String get labelBreathPhaseExhale => 'ശ്വാസം വിടുക';

  @override
  String get labelBreathPhaseRest => 'വിശ്രമിക്കുക';

  @override
  String get descBreathGuidanceInhale =>
      'മൂക്കിലൂടെ പതുക്കെ ശ്വാസം ഉള്ളിലേക്കെടുക്കുക...';

  @override
  String get descBreathGuidanceHold =>
      'മുകളിൽ ശാന്തമായി ശ്വാസം പിടിച്ചുനിർത്തുക...';

  @override
  String get descBreathGuidanceExhale => 'പതുക്കെ പൂർണ്ണമായി ശ്വാസം വിടുക...';

  @override
  String get descBreathGuidanceRest => 'ശാന്തമായ നിശ്ചലതയിൽ വിശ്രമിക്കുക...';

  @override
  String get bodyBreathPracticeCompleted => 'ശ്വസനപരിശീലനം പൂർത്തിയായി';

  @override
  String bodyBreathPhaseRemaining(String phase, int seconds) {
    return '$phase, $seconds സെക്കൻഡ് ബാക്കി';
  }

  @override
  String get titleBreathGrounded => 'ശാന്തവും ജാഗരൂകവും';

  @override
  String labelBreathCycle(int current, int total) {
    return 'ചക്രം $current / $total';
  }

  @override
  String get labelTemplateCategoryGeneral => 'പുതുതായി തുടങ്ങുക';

  @override
  String get labelTemplateCategoryReflective => 'ദൈനംദിന ചിന്തകൾ';

  @override
  String get labelTemplateCategoryThoughts => 'ചിന്തകളും ആശയങ്ങളും';

  @override
  String get labelTemplateCategoryProjects => 'പദ്ധതികളും ജോലിയും';

  @override
  String get labelTemplateCategoryPeople => 'ബന്ധങ്ങൾ';

  @override
  String get labelTemplateCategoryHealth => 'ആരോഗ്യവും ക്ഷേമവും';

  @override
  String get labelTemplateCategoryLearning => 'പഠനവും വളർച്ചയും';

  @override
  String get labelTemplateCategoryCreative => 'സർഗ്ഗാത്മകം';

  @override
  String get labelTemplateCategoryPlanning => 'ആസൂത്രണം';

  @override
  String get labelTemplateCategorySpecialty => 'പ്രത്യേക വിഷയങ്ങൾ';

  @override
  String get labelTemplateBlank => 'ശൂന്യം';

  @override
  String get descTemplateBlank => 'ഒഴിഞ്ഞ ഒരു കുറിപ്പിൽ നിന്ന് തുടങ്ങുക.';

  @override
  String get labelTemplateDaily => 'ദൈനംദിന ചിന്തനം';

  @override
  String get descTemplateDaily => 'നല്ല നിമിഷങ്ങൾ, നന്ദി, നാളത്തെ ലക്ഷ്യം.';

  @override
  String get descTemplateDailyEntryTitle => 'ദൈനംദിന ചിന്തനം';

  @override
  String get bodyTemplateDaily =>
      'നല്ല നിമിഷങ്ങൾ\n\nമോശം നിമിഷങ്ങൾ\n\nനാളത്തെ ലക്ഷ്യം\n\n';

  @override
  String get labelTemplateTodayForMe => 'ഇന്ന് എനിക്ക്';

  @override
  String get descTemplateTodayForMe =>
      'ഇന്ന് ചെയ്തത്, ചിന്തിച്ചത്, കണ്ടത്, നേരിട്ടത്, അനുഭവിച്ചത്, പഠിച്ചത്.';

  @override
  String get descTemplateTodayForMeEntryTitle => 'ഇന്ന് എനിക്ക്';

  @override
  String get bodyTemplateTodayForMe =>
      'ഇന്ന് ഞാൻ ചെയ്തത്\n\nഇന്ന് ഞാൻ ചിന്തിച്ചത്\n\nഇന്ന് ഞാൻ കണ്ടത്\n\nഇന്ന് ഞാൻ നേരിട്ടത്\n\nഇന്ന് ഞാൻ അനുഭവിച്ചത്\n\nഇന്ന് ഞാൻ പഠിച്ചത്\n\n';

  @override
  String get labelTemplateEveningWindDown => 'സന്ധ്യാവിശ്രമം';

  @override
  String get descTemplateEveningWindDown =>
      'വിജയങ്ങൾ, പ്രയാസങ്ങൾ, ഉപേക്ഷിക്കേണ്ട ഒരു കാര്യം.';

  @override
  String get descTemplateEveningWindDownEntryTitle => 'സന്ധ്യാവിശ്രമം';

  @override
  String get bodyTemplateEveningWindDown =>
      'വിജയങ്ങൾ\n\nപ്രയാസങ്ങൾ\n\nഉപേക്ഷിക്കേണ്ട ഒരു കാര്യം\n\n';

  @override
  String get labelTemplateMorningPages => 'പ്രഭാതതാളുകൾ';

  @override
  String get descTemplateMorningPages =>
      'ദിവസം തുടങ്ങാൻ മനസ്സിലുള്ളതെല്ലാം തടസ്സമില്ലാതെ എഴുതുക.';

  @override
  String get descTemplateMorningPagesEntryTitle => 'പ്രഭാതതാളുകൾ';

  @override
  String get labelTemplateDayHighlight => 'ദിനത്തിലെ മികവ്';

  @override
  String get descTemplateDayHighlight =>
      'ഏറ്റവും ഓർമ്മയിൽ നിൽക്കുന്ന നിമിഷവും അതിന്റെ കാരണവും.';

  @override
  String get descTemplateDayHighlightEntryTitle => 'ദിനത്തിലെ മികവ്';

  @override
  String get bodyTemplateDayHighlight =>
      'ആ നിമിഷം\n\nഅത് പ്രത്യേകമായതിന്റെ കാരണം\n\n';

  @override
  String get labelTemplateEnergyCheck => 'ഊർജ്ജ പരിശോധന';

  @override
  String get descTemplateEnergyCheck =>
      'ഊർജ്ജനില, അത് കുറച്ചത്, അത് വീണ്ടെടുത്തത്.';

  @override
  String get descTemplateEnergyCheckEntryTitle => 'ഊർജ്ജ പരിശോധന';

  @override
  String get bodyTemplateEnergyCheck =>
      'ഊർജ്ജനില (1-10): \n\nഊർജ്ജം കുറച്ചത്\n\nഊർജ്ജം വീണ്ടെടുത്തത്\n\n';

  @override
  String get labelTemplateMood => 'മാനസികാവസ്ഥ';

  @override
  String get descTemplateMood =>
      'ഇപ്പോഴത്തെ മാനസികാവസ്ഥയും അതിന് കാരണമാകുന്നവയും കുറിക്കുക.';

  @override
  String get descTemplateMoodEntryTitle => 'മാനസികാവസ്ഥ';

  @override
  String get bodyTemplateMood =>
      'ഇപ്പോൾ എനിക്ക് എങ്ങനെ തോന്നുന്നു\n\nഅതിന് കാരണമാകുന്നത്\n\n';

  @override
  String get labelTemplateThoughts => 'എന്റെ ചിന്തകൾ';

  @override
  String get descTemplateThoughts =>
      'ഒരു വിഷയത്തെക്കുറിച്ചുള്ള സ്വതന്ത്ര ചിന്തകൾ.';

  @override
  String get descTemplateThoughtsEntryTitle => 'എന്റെ ചിന്തകൾ';

  @override
  String get bodyTemplateThoughts => 'വിഷയം\n\nഎന്റെ ചിന്തകൾ\n\n';

  @override
  String get labelTemplateIdeaCapture => 'ആശയക്കുറിപ്പ്';

  @override
  String get descTemplateIdeaCapture => 'ആശയം, അതിന്റെ പ്രാധാന്യം, അടുത്ത പടി.';

  @override
  String get descTemplateIdeaCaptureEntryTitle => 'ആശയക്കുറിപ്പ്';

  @override
  String get bodyTemplateIdeaCapture =>
      'ആശയം\n\nഅതിന്റെ പ്രാധാന്യം\n\nഅടുത്ത പടി\n\n';

  @override
  String get labelTemplateOpenQuestion => 'തുറന്ന ചോദ്യം';

  @override
  String get descTemplateOpenQuestion =>
      'മനസ്സിൽ കൊണ്ടുനടക്കുന്ന ഒരു ചോദ്യവും ഇപ്പോഴത്തെ ചിന്തയും.';

  @override
  String get descTemplateOpenQuestionEntryTitle => 'തുറന്ന ചോദ്യം';

  @override
  String get bodyTemplateOpenQuestion =>
      'ചോദ്യം\n\nഇതുവരെയുള്ള എന്റെ ചിന്ത\n\nഇനിയും അറിയാത്തത്\n\n';

  @override
  String get labelTemplateOpinion => 'അഭിപ്രായം';

  @override
  String get descTemplateOpinion =>
      'വിശ്വാസം, അനുകൂല തെളിവുകൾ, പ്രതികൂല തെളിവുകൾ.';

  @override
  String get descTemplateOpinionEntryTitle => 'അഭിപ്രായം';

  @override
  String get bodyTemplateOpinion =>
      'എന്റെ വിശ്വാസം\n\nഅനുകൂല തെളിവുകൾ\n\nപ്രതികൂല തെളിവുകൾ\n\n';

  @override
  String get labelTemplateLessonsLearned => 'പഠിച്ച പാഠങ്ങൾ';

  @override
  String get descTemplateLessonsLearned =>
      'എന്ത് സംഭവിച്ചു, എന്ത് പഠിച്ചു, എങ്ങനെ പ്രയോഗിക്കും.';

  @override
  String get descTemplateLessonsLearnedEntryTitle => 'പഠിച്ച പാഠങ്ങൾ';

  @override
  String get bodyTemplateLessonsLearned =>
      'എന്ത് സംഭവിച്ചു\n\nഞാൻ പഠിച്ചത്\n\nഎങ്ങനെ പ്രയോഗിക്കും\n\n';

  @override
  String get labelTemplateProjects => 'എന്റെ പദ്ധതികൾ';

  @override
  String get descTemplateProjects => 'പദ്ധതി, നില, തടസ്സങ്ങൾ, അടുത്ത നടപടി.';

  @override
  String get descTemplateProjectsEntryTitle => 'എന്റെ പദ്ധതികൾ';

  @override
  String get bodyTemplateProjects =>
      'പദ്ധതി\n\nനില\n\nതടസ്സങ്ങൾ\n\nഅടുത്ത നടപടി\n\n';

  @override
  String get labelTemplateProjectUpdate => 'പദ്ധതി പുരോഗതി';

  @override
  String get descTemplateProjectUpdate =>
      'പുരോഗതി, അപകടസാധ്യതകൾ, എടുത്ത തീരുമാനങ്ങൾ.';

  @override
  String get descTemplateProjectUpdateEntryTitle => 'പദ്ധതി പുരോഗതി';

  @override
  String get bodyTemplateProjectUpdate =>
      'പുരോഗതി\n\nഅപകടസാധ്യതകൾ\n\nഎടുത്ത തീരുമാനങ്ങൾ\n\n';

  @override
  String get labelTemplateWeeklyReview => 'ആഴ്ചയുടെ അവലോകനം';

  @override
  String get descTemplateWeeklyReview =>
      'വിജയങ്ങൾ, നഷ്ടങ്ങൾ, അടുത്ത ആഴ്ചയിലെ ലക്ഷ്യം.';

  @override
  String get descTemplateWeeklyReviewEntryTitle => 'ആഴ്ചയുടെ അവലോകനം';

  @override
  String get bodyTemplateWeeklyReview =>
      'വിജയങ്ങൾ\n\nനഷ്ടങ്ങൾ\n\nഅടുത്ത ആഴ്ചയിലെ ലക്ഷ്യം\n\n';

  @override
  String get labelTemplateGoalTracker => 'ലക്ഷ്യ നിരീക്ഷണം';

  @override
  String get descTemplateGoalTracker =>
      'ലക്ഷ്യം, പുരോഗതി, തടസ്സങ്ങൾ, മാറ്റങ്ങൾ.';

  @override
  String get descTemplateGoalTrackerEntryTitle => 'ലക്ഷ്യ നിരീക്ഷണം';

  @override
  String get bodyTemplateGoalTracker =>
      'ലക്ഷ്യം\n\nപുരോഗതി\n\nതടസ്സങ്ങൾ\n\nമാറ്റങ്ങൾ\n\n';

  @override
  String get labelTemplateDecisionLog => 'തീരുമാനക്കുറിപ്പ്';

  @override
  String get descTemplateDecisionLog =>
      'തീരുമാനം, പരിഗണിച്ച വഴികൾ, ഇത് തിരഞ്ഞെടുത്തതിന്റെ കാരണം.';

  @override
  String get descTemplateDecisionLogEntryTitle => 'തീരുമാനക്കുറിപ്പ്';

  @override
  String get bodyTemplateDecisionLog =>
      'തീരുമാനം\n\nപരിഗണിച്ച വഴികൾ\n\nഇത് തിരഞ്ഞെടുത്തതിന്റെ കാരണം\n\n';

  @override
  String get labelTemplateStuckPoint => 'കുടുങ്ങിയ ഇടം';

  @override
  String get descTemplateStuckPoint =>
      'എവിടെ കുടുങ്ങി, എന്ത് ശ്രമിച്ചു, ഇനി എന്ത് ശ്രമിക്കണം.';

  @override
  String get descTemplateStuckPointEntryTitle => 'കുടുങ്ങിയ ഇടം';

  @override
  String get bodyTemplateStuckPoint =>
      'എവിടെയാണ് കുടുങ്ങിയത്\n\nഇതുവരെ ശ്രമിച്ചത്\n\nഇനി ശ്രമിക്കേണ്ടത്\n\n';

  @override
  String get labelTemplateMeeting => 'യോഗക്കുറിപ്പുകൾ';

  @override
  String get descTemplateMeeting =>
      'പങ്കെടുത്തവർ, കാര്യപരിപാടി, തീരുമാനങ്ങൾ, ചെയ്യേണ്ട കാര്യങ്ങൾ.';

  @override
  String get descTemplateMeetingEntryTitle => 'യോഗക്കുറിപ്പുകൾ';

  @override
  String get bodyTemplateMeeting =>
      'പങ്കെടുത്തവർ: \nകാര്യപരിപാടി\n\nതീരുമാനങ്ങൾ\n\nചെയ്യേണ്ട കാര്യങ്ങൾ\n\n';

  @override
  String get labelTemplateConversationRecap => 'സംഭാഷണ സംഗ്രഹം';

  @override
  String get descTemplateConversationRecap =>
      'ആരുമായി, എന്ത് ചർച്ച ചെയ്തു, തുടർനടപടികൾ.';

  @override
  String get descTemplateConversationRecapEntryTitle => 'സംഭാഷണ സംഗ്രഹം';

  @override
  String get bodyTemplateConversationRecap =>
      'ആരുമായി\n\nചർച്ച ചെയ്തത്\n\nതുടർനടപടികൾ\n\n';

  @override
  String get labelTemplateGratefulPeople => 'നന്ദിയുള്ളവർ';

  @override
  String get descTemplateGratefulPeople =>
      'ഒരു വ്യക്തിയും വ്യക്തമായ ഒരു കാരണവും.';

  @override
  String get descTemplateGratefulPeopleEntryTitle => 'എനിക്ക് നന്ദിയുള്ളവർ';

  @override
  String get bodyTemplateGratefulPeople => 'വ്യക്തി\n\nപ്രത്യേക കാരണം\n\n';

  @override
  String get labelTemplateUnsentLetter => 'അയയ്ക്കാത്ത കത്ത്';

  @override
  String get descTemplateUnsentLetter =>
      'വികാരങ്ങളെ മനസ്സിലാക്കാൻ അയയ്ക്കാത്ത ഒരു കത്ത്.';

  @override
  String get descTemplateUnsentLetterEntryTitle => 'അയയ്ക്കാത്ത കത്ത്';

  @override
  String get bodyTemplateUnsentLetter => 'പ്രിയപ്പെട്ട ...,\n\n\n\n— ഞാൻ\n\n';

  @override
  String get labelTemplateRelationshipCheckin => 'ബന്ധ പരിശോധന';

  @override
  String get descTemplateRelationshipCheckin =>
      'ഒരു പ്രധാന ബന്ധം എങ്ങനെ പോകുന്നു.';

  @override
  String get descTemplateRelationshipCheckinEntryTitle => 'ബന്ധ പരിശോധന';

  @override
  String get bodyTemplateRelationshipCheckin =>
      'വ്യക്തി\n\nഎങ്ങനെ പോകുന്നു\n\nശ്രദ്ധ വേണ്ടത്\n\n';

  @override
  String get labelTemplateGratitude => 'നന്ദി';

  @override
  String get descTemplateGratitude => 'ഇന്ന് നന്ദി തോന്നുന്ന മൂന്ന് കാര്യങ്ങൾ.';

  @override
  String get descTemplateGratitudeEntryTitle => 'നന്ദി';

  @override
  String get bodyTemplateGratitude =>
      'നന്ദി തോന്നുന്ന മൂന്ന് കാര്യങ്ങൾ\n\n1. \n2. \n3. \n';

  @override
  String get labelTemplateBodyCheckin => 'ശരീര പരിശോധന';

  @override
  String get descTemplateBodyCheckin =>
      'ഉറക്കം, ഭക്ഷണം, ചലനം, വേദനയോ പിരിമുറുക്കമോ.';

  @override
  String get descTemplateBodyCheckinEntryTitle => 'ശരീര പരിശോധന';

  @override
  String get bodyTemplateBodyCheckin =>
      'ഉറക്കം\n\nഭക്ഷണം\n\nചലനം\n\nവേദനയോ പിരിമുറുക്കമോ\n\n';

  @override
  String get labelTemplateMentalHealth => 'മാനസികാരോഗ്യം';

  @override
  String get descTemplateMentalHealth =>
      'മാനസികാവസ്ഥ, പ്രകോപനങ്ങൾ, സ്വീകരിച്ച പ്രതിവിധികൾ.';

  @override
  String get descTemplateMentalHealthEntryTitle => 'മാനസികാരോഗ്യം';

  @override
  String get bodyTemplateMentalHealth =>
      'മാനസികാവസ്ഥ\n\nപ്രകോപനങ്ങൾ\n\nസ്വീകരിച്ച പ്രതിവിധികൾ\n\n';

  @override
  String get labelTemplateHabitTracker => 'ശീല നിരീക്ഷണം';

  @override
  String get descTemplateHabitTracker =>
      'ഇന്ന് ചെയ്ത ശീലങ്ങളും തുടർച്ചയുടെ കുറിപ്പുകളും.';

  @override
  String get descTemplateHabitTrackerEntryTitle => 'ശീല നിരീക്ഷണം';

  @override
  String get bodyTemplateHabitTracker =>
      'ഇന്ന് ചെയ്ത ശീലങ്ങൾ\n\nഇന്ന് വിട്ടുപോയവ\n\nതുടർച്ചയുടെ കുറിപ്പുകൾ\n\n';

  @override
  String get labelTemplateSleepLog => 'ഉറക്കക്കുറിപ്പ്';

  @override
  String get descTemplateSleepLog => 'മണിക്കൂറുകൾ, ഗുണനിലവാരം, സ്വപ്നങ്ങൾ.';

  @override
  String get descTemplateSleepLogEntryTitle => 'ഉറക്കക്കുറിപ്പ്';

  @override
  String get bodyTemplateSleepLog =>
      'മണിക്കൂറുകൾ\n\nഗുണനിലവാരം\n\nസ്വപ്നങ്ങൾ\n\n';

  @override
  String get labelTemplateTaughtToday => 'ഇന്ന് പഠിച്ചത്';

  @override
  String get descTemplateTaughtToday => 'പാഠം, ഉറവിടം, പ്രധാന ഉൾക്കാഴ്ച.';

  @override
  String get descTemplateTaughtTodayEntryTitle => 'ഇന്ന് പഠിച്ചത്';

  @override
  String get bodyTemplateTaughtToday =>
      'പാഠം\n\nഉറവിടം\n\nപ്രധാന ഉൾക്കാഴ്ച\n\n';

  @override
  String get labelTemplateBookNotes => 'പുസ്തകക്കുറിപ്പുകൾ';

  @override
  String get descTemplateBookNotes => 'പേര്, പ്രധാന ആശയങ്ങൾ, എന്റെ പ്രതികരണം.';

  @override
  String get descTemplateBookNotesEntryTitle => 'പുസ്തകക്കുറിപ്പുകൾ';

  @override
  String get bodyTemplateBookNotes =>
      'പേര്: \nരചയിതാവ്: \n\nപ്രധാന ആശയങ്ങൾ\n\nഎന്റെ പ്രതികരണം\n\n';

  @override
  String get labelTemplateSkillPractice => 'നൈപുണ്യ പരിശീലനം';

  @override
  String get descTemplateSkillPractice =>
      'പരിശീലിച്ചത്, മെച്ചപ്പെട്ടത്, അടുത്ത ശ്രദ്ധ.';

  @override
  String get descTemplateSkillPracticeEntryTitle => 'നൈപുണ്യ പരിശീലനം';

  @override
  String get bodyTemplateSkillPractice =>
      'നൈപുണ്യം\n\nപരിശീലിച്ചത്\n\nമെച്ചപ്പെട്ടത്\n\nഅടുത്ത ശ്രദ്ധ\n\n';

  @override
  String get labelTemplateMistakeLog => 'പിഴവുകളുടെ കുറിപ്പ്';

  @override
  String get descTemplateMistakeLog => 'എന്ത് തെറ്റി, മൂലകാരണം, തടയാനുള്ള വഴി.';

  @override
  String get descTemplateMistakeLogEntryTitle => 'പിഴവുകളുടെ കുറിപ്പ്';

  @override
  String get bodyTemplateMistakeLog =>
      'എന്ത് തെറ്റി\n\nമൂലകാരണം\n\nതടയാനുള്ള വഴി\n\n';

  @override
  String get labelTemplateTopicDeepDive => 'വിഷയപഠനം';

  @override
  String get descTemplateTopicDeepDive =>
      'ഒരു ആശയത്തെയോ വിഷയത്തെയോ കുറിച്ചുള്ള വിശദമായ പഠനക്കുറിപ്പ്.';

  @override
  String get descTemplateTopicDeepDiveEntryTitle => 'വിഷയപഠനം';

  @override
  String get bodyTemplateTopicDeepDive =>
      'വിഷയം / അടിസ്ഥാന ആശയം\n\nപ്രധാന തത്വങ്ങളും അവലോകനവും\n\nവിശദമായ വിശകലനവും കുറിപ്പുകളും\n\nപ്രധാന പാഠങ്ങളും അവലംബങ്ങളും\n\nതുറന്ന ചോദ്യങ്ങൾ / തുടർപഠനം\n\n';

  @override
  String get labelTemplateDreamJournal => 'സ്വപ്നക്കുറിപ്പുകൾ';

  @override
  String get descTemplateDreamJournal =>
      'സ്വപ്നത്തിന്റെ വിശദാംശങ്ങൾ, വികാരങ്ങൾ, സാധ്യമായ അർത്ഥം.';

  @override
  String get descTemplateDreamJournalEntryTitle => 'സ്വപ്നക്കുറിപ്പുകൾ';

  @override
  String get bodyTemplateDreamJournal =>
      'സ്വപ്നത്തിന്റെ വിശദാംശങ്ങൾ\n\nവികാരങ്ങൾ\n\nസാധ്യമായ അർത്ഥം\n\n';

  @override
  String get labelTemplateObservation => 'നിരീക്ഷണക്കുറിപ്പ്';

  @override
  String get descTemplateObservation => 'ശ്രദ്ധിച്ച ഒരു കാര്യം വിശദമായി.';

  @override
  String get descTemplateObservationEntryTitle => 'നിരീക്ഷണക്കുറിപ്പ്';

  @override
  String get bodyTemplateObservation => 'ഞാൻ ശ്രദ്ധിച്ചത്\n\nവിശദാംശങ്ങൾ\n\n';

  @override
  String get labelTemplateQuoteOfDay => 'ഇന്നത്തെ ഉദ്ധരണി';

  @override
  String get descTemplateQuoteOfDay =>
      'ഉദ്ധരണിയും അത് മനസ്സിൽ തൊടുന്നതിന്റെ കാരണവും.';

  @override
  String get descTemplateQuoteOfDayEntryTitle => 'ഇന്നത്തെ ഉദ്ധരണി';

  @override
  String get bodyTemplateQuoteOfDay =>
      'ഉദ്ധരണി\n\nഉറവിടം\n\nമനസ്സിൽ തൊടുന്നതിന്റെ കാരണം\n\n';

  @override
  String get labelTemplateStorySeed => 'കഥാബീജം';

  @override
  String get descTemplateStorySeed => 'ചെറിയൊരു കഥാസങ്കൽപ്പമോ രംഗമോ.';

  @override
  String get descTemplateStorySeedEntryTitle => 'കഥാബീജം';

  @override
  String get bodyTemplateStorySeed => 'ബീജം\n\nസാധ്യമായ ദിശ\n\n';

  @override
  String get labelTemplateTravel => 'യാത്രാക്കുറിപ്പ്';

  @override
  String get descTemplateTravel =>
      'സ്ഥലം, കാലാവസ്ഥ, സംഭവിച്ചത്, കണ്ടുമുട്ടിയവർ.';

  @override
  String get descTemplateTravelEntryTitle => 'യാത്രാക്കുറിപ്പ്';

  @override
  String get bodyTemplateTravel =>
      'സ്ഥലം: \nകാലാവസ്ഥ: \nസംഭവിച്ചത്\n\nകണ്ടുമുട്ടിയവർ\n\n';

  @override
  String get labelTemplateTomorrowFocus => 'നാളത്തെ ലക്ഷ്യം';

  @override
  String get descTemplateTomorrowFocus =>
      'പ്രധാനപ്പെട്ട 3 കാര്യങ്ങളും ആദ്യപടിയും.';

  @override
  String get descTemplateTomorrowFocusEntryTitle => 'നാളത്തെ ലക്ഷ്യം';

  @override
  String get bodyTemplateTomorrowFocus =>
      'പ്രധാനപ്പെട്ട 3 കാര്യങ്ങൾ\n\n1. \n2. \n3. \n\nആദ്യപടി\n\n';

  @override
  String get labelTemplateWeeklyIntentions => 'ആഴ്ചയിലെ ഉദ്ദേശ്യങ്ങൾ';

  @override
  String get descTemplateWeeklyIntentions => 'വിഷയം, മുൻഗണനകൾ, ഒഴിവാക്കേണ്ടവ.';

  @override
  String get descTemplateWeeklyIntentionsEntryTitle => 'ആഴ്ചയിലെ ഉദ്ദേശ്യങ്ങൾ';

  @override
  String get bodyTemplateWeeklyIntentions =>
      'വിഷയം\n\nമുൻഗണനകൾ\n\nഒഴിവാക്കേണ്ടവ\n\n';

  @override
  String get labelTemplateMonthlyReview => 'മാസാവലോകനം';

  @override
  String get descTemplateMonthlyReview =>
      'വിജയങ്ങൾ, പാഠങ്ങൾ, അടുത്ത മാസത്തെ മാറ്റങ്ങൾ.';

  @override
  String get descTemplateMonthlyReviewEntryTitle => 'മാസാവലോകനം';

  @override
  String get bodyTemplateMonthlyReview =>
      'വിജയങ്ങൾ\n\nപാഠങ്ങൾ\n\nഅടുത്ത മാസത്തെ മാറ്റങ്ങൾ\n\n';

  @override
  String get labelTemplateWorkoutLog => 'വ്യായാമക്കുറിപ്പ്';

  @override
  String get descTemplateWorkoutLog =>
      'വ്യായാമങ്ങൾ, സെറ്റുകൾ, ആവർത്തനങ്ങൾ, അനുഭവം.';

  @override
  String get descTemplateWorkoutLogEntryTitle => 'വ്യായാമക്കുറിപ്പ്';

  @override
  String get bodyTemplateWorkoutLog =>
      'വ്യായാമം\n\nസെറ്റുകൾ / ആവർത്തനങ്ങൾ\n\nഅനുഭവം\n\n';

  @override
  String get labelTemplateReadingLog => 'വായനക്കുറിപ്പ്';

  @override
  String get descTemplateReadingLog =>
      'പുസ്തകം, വായിച്ച താളുകൾ, ഇഷ്ടപ്പെട്ട ഭാഗം.';

  @override
  String get descTemplateReadingLogEntryTitle => 'വായനക്കുറിപ്പ്';

  @override
  String get bodyTemplateReadingLog =>
      'പുസ്തകം\n\nവായിച്ച താളുകൾ\n\nഇഷ്ടപ്പെട്ട ഭാഗം\n\n';

  @override
  String get labelTemplateFoodJournal => 'ഭക്ഷണക്കുറിപ്പ്';

  @override
  String get descTemplateFoodJournal => 'ഭക്ഷണങ്ങളും അതിനുശേഷമുള്ള അനുഭവവും.';

  @override
  String get descTemplateFoodJournalEntryTitle => 'ഭക്ഷണക്കുറിപ്പ്';

  @override
  String get bodyTemplateFoodJournal => 'ഭക്ഷണങ്ങൾ\n\nഅതിനുശേഷമുള്ള അനുഭവം\n\n';

  @override
  String get labelTemplateSpendingLog => 'ചെലവുകുറിപ്പ്';

  @override
  String get descTemplateSpendingLog => 'വാങ്ങലുകൾ — അത് മൂല്യമുള്ളതായിരുന്നോ?';

  @override
  String get descTemplateSpendingLogEntryTitle => 'ചെലവുകുറിപ്പ്';

  @override
  String get bodyTemplateSpendingLog =>
      'വാങ്ങിയത്\n\nവില\n\nമൂല്യമുള്ളതായിരുന്നോ?\n\n';

  @override
  String get labelTemplatePrayerMeditation => 'പ്രാർത്ഥന / ധ്യാനം';

  @override
  String get descTemplatePrayerMeditation => 'സാധന, ദൈർഘ്യം, ചിന്തകൾ.';

  @override
  String get descTemplatePrayerMeditationEntryTitle => 'പ്രാർത്ഥന / ധ്യാനം';

  @override
  String get bodyTemplatePrayerMeditation => 'സാധന\n\nദൈർഘ്യം\n\nചിന്തകൾ\n\n';

  @override
  String get labelTemplateSysadminRunbook => 'സിസ്റ്റം ഭരണം';

  @override
  String get descTemplateSysadminRunbook =>
      'സെർവർ / സിസ്റ്റം പ്രവർത്തനക്കുറിപ്പ്, കമാൻഡുകൾ, പരിപാലന രേഖ.';

  @override
  String get descTemplateSysadminRunbookEntryTitle => 'സാങ്കേതിക കുറിപ്പ്';

  @override
  String get bodyTemplateSysadminRunbook =>
      'സിസ്റ്റം / സേവനം: \nലക്ഷ്യവും ഘടനയും\n\nക്രമീകരണവും കമാൻഡുകളും\n\nപരിശോധനയും ആരോഗ്യനിലയും\n\nപ്രശ്നപരിഹാരവും പിൻവലിക്കൽ കുറിപ്പുകളും\n\n';

  @override
  String get labelTemplateSanathanaDharmaStudy => 'ധർമ്മപഠനം';

  @override
  String get descTemplateSanathanaDharmaStudy =>
      'ശാസ്ത്രം, ശ്ലോകം, തത്വം/അർത്ഥം, സാധനാചിന്ത.';

  @override
  String get descTemplateSanathanaDharmaStudyEntryTitle => 'സനാതനധർമ്മ പഠനം';

  @override
  String get bodyTemplateSanathanaDharmaStudy =>
      'വിഷയം / ശാസ്ത്രം: \nശ്ലോകം / മന്ത്രം / അവലംബം\n\nപദവിഭജനവും അർത്ഥവും\n\nതാത്വിക ഉൾക്കാഴ്ചകൾ (തത്വം)\n\nനിത്യസാധനയും പ്രായോഗിക പ്രയോഗവും\n\n';

  @override
  String get labelTemplateDiyProject => 'സ്വയംനിർമ്മാണ പദ്ധതി';

  @override
  String get descTemplateDiyProject =>
      'സാമഗ്രികൾ, ഉപകരണങ്ങൾ, ഘട്ടം ഘട്ടമായുള്ള നിർമ്മാണം, സുരക്ഷ.';

  @override
  String get descTemplateDiyProjectEntryTitle => 'സ്വയംനിർമ്മാണം';

  @override
  String get bodyTemplateDiyProject =>
      'പദ്ധതിയുടെ ലക്ഷ്യവും വ്യാപ്തിയും\n\nആവശ്യമായ ഉപകരണങ്ങളും സാമഗ്രികളും\n\nഘട്ടം ഘട്ടമായുള്ള നടപടിക്രമം\n\nസുരക്ഷയും മുൻകരുതലുകളും\n\nപരീക്ഷണവും പഠിച്ച പാഠങ്ങളും\n\n';

  @override
  String get labelTemplateHomeMaintenance => 'വീട്ടുപരിപാലനം';

  @override
  String get descTemplateHomeMaintenance =>
      'ഉപകരണപരിപാലനം, അറ്റകുറ്റപ്പണികൾ, വാറന്റികൾ, വിതരണക്കാരുടെ രേഖകൾ.';

  @override
  String get descTemplateHomeMaintenanceEntryTitle => 'വീട്ടുപരിപാലനക്കുറിപ്പ്';

  @override
  String get bodyTemplateHomeMaintenance =>
      'ഇടം / വസ്തു / ഉപകരണം: \nപ്രശ്നം / പരിപാലന ജോലി\n\nസേവനചരിത്രവും ചെലവുകളും\n\nവാറന്റിയും വിതരണക്കാരുടെ ബന്ധങ്ങളും\n\nഅടുത്ത പരിശോധന: \n\n';

  @override
  String get labelTemplateKitchenRecipe => 'അടുക്കളയും പാചകവും';

  @override
  String get descTemplateKitchenRecipe =>
      'വിഭവം, ചേരുവകൾ, ഘട്ടം ഘട്ടമായുള്ള രീതി, നുറുങ്ങുകൾ.';

  @override
  String get descTemplateKitchenRecipeEntryTitle => 'പാചകക്കുറിപ്പ്';

  @override
  String get bodyTemplateKitchenRecipe =>
      'വിഭവത്തിന്റെ പേര്: \nപാചകരീതി / തയ്യാറെടുപ്പ്, പാചക സമയം: \n\nചേരുവകളും അളവുകളും\n\nഘട്ടം ഘട്ടമായുള്ള രീതി\n\nപാചകക്കുറിപ്പുകളും വകഭേദങ്ങളും\n\n';

  @override
  String get titleExport => 'കയറ്റുമതി';

  @override
  String get titleExportSectionWhat => 'കയറ്റുമതി ചെയ്യേണ്ടത്';

  @override
  String get titleExportSectionFormat => 'രൂപഘടന';

  @override
  String get titleExportSectionOptions => 'ഐച്ഛികങ്ങൾ';

  @override
  String get labelExportScopeThisEntry => 'ഈ കുറിപ്പ്';

  @override
  String get labelExportScopeWholeJournal => 'ജേണൽ മുഴുവൻ';

  @override
  String get labelExportScopeDateRange => 'ഒരു തീയതി പരിധി';

  @override
  String get actionExportPickDateRange => 'തീയതികൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get descExportDateRangeNotSet => 'തീയതികൾ ഇതുവരെ തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String descExportFromJournal(String journalTitle) {
    return '\"$journalTitle\" ൽ നിന്ന്';
  }

  @override
  String descExportDateRange(String from, String to) {
    return '$from മുതൽ $to വരെ';
  }

  @override
  String get labelExportFormatMarkdown => 'Markdown';

  @override
  String get labelExportFormatHtml => 'വെബ് താൾ (HTML)';

  @override
  String get labelExportFormatPlainText => 'ലളിതമായ പാഠം';

  @override
  String get labelExportFormatPdf => 'PDF';

  @override
  String get descExportFormatMarkdown =>
      'തലക്കെട്ടുകളും പട്ടികകളും ശൈലിയും നിലനിർത്തുന്നു. ഏത് ടെക്സ്റ്റ് എഡിറ്ററിലും തുറക്കാം.';

  @override
  String get descExportFormatHtml =>
      'ഏത് ബ്രൗസറിലും തുറക്കുന്ന ഒരു താൾ. ഇന്റർനെറ്റിൽ നിന്ന് ഒന്നും ലോഡ് ചെയ്യുന്നില്ല.';

  @override
  String get descExportFormatPlainText => 'ശൈലിയില്ലാതെ വാക്കുകൾ മാത്രം.';

  @override
  String get descExportFormatPdf =>
      'അച്ചടിക്കാനോ പങ്കിടാനോ തയ്യാറായ സ്ഥിരമായ താളുകൾ.';

  @override
  String get bodyExportPdfUnavailable =>
      'ഈ ഉപകരണത്തിൽ PDF കയറ്റുമതി ലഭ്യമല്ല. മറ്റ് രൂപങ്ങൾ പ്രവർത്തിക്കും.';

  @override
  String get labelExportIncludeAttachments => 'അനുബന്ധങ്ങൾ ഉൾപ്പെടുത്തുക';

  @override
  String get descExportIncludeAttachments =>
      'ഓരോ ഫയലിന്റെയും ശബ്ദക്കുറിപ്പിന്റെയും പകർപ്പ് ചേർക്കുന്നു.';

  @override
  String get labelExportIncludeMetadata => 'തീയതി, ടാഗ്, വികാരം';

  @override
  String get descExportIncludeMetadata =>
      'ഓരോ കുറിപ്പിനും മുകളിൽ ഒരു ചെറിയ തലക്കെട്ട് ചേർക്കുന്നു.';

  @override
  String get bodyExportNotEncrypted =>
      'കയറ്റുമതി ചെയ്ത ഫയൽ എൻക്രിപ്റ്റ് ചെയ്തിട്ടില്ല. ഫയൽ തുറക്കാൻ കഴിയുന്ന ആർക്കും ഇത് വായിക്കാം. സുരക്ഷിതമായ ഇടത്ത് സൂക്ഷിക്കുക.';

  @override
  String get titleExportConfirm => 'എൻക്രിപ്റ്റ് ചെയ്യാതെ കയറ്റുമതി?';

  @override
  String bodyExportConfirm(int count, String format) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count കുറിപ്പുകൾ',
      one: '1 കുറിപ്പ്',
    );
    return 'ഇത് $_temp0 എൻക്രിപ്റ്റ് ചെയ്യാത്ത ഒരു $format ഫയലിലേക്ക് എഴുതും. ആ ഫയൽ തുറക്കാൻ കഴിയുന്ന ആർക്കും നിങ്ങളുടെ ജേണൽ വായിക്കാം. സുരക്ഷിതമായ ഇടത്ത് സൂക്ഷിക്കുക, ആവശ്യം കഴിഞ്ഞാൽ ഇല്ലാതാക്കുക.';
  }

  @override
  String get actionExportAnyway => 'എന്നാലും കയറ്റുമതി ചെയ്യുക';

  @override
  String get actionExport => 'കയറ്റുമതി ചെയ്യുക';

  @override
  String get bodyExportExporting => 'കയറ്റുമതി ചെയ്യുന്നു…';

  @override
  String get titleExportSaveDialog => 'കയറ്റുമതി സൂക്ഷിക്കുക';

  @override
  String bodyExportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count കുറിപ്പുകൾ കയറ്റുമതി ചെയ്തു.',
      one: '1 കുറിപ്പ് കയറ്റുമതി ചെയ്തു.',
    );
    return '$_temp0';
  }

  @override
  String get bodyExportCancelled => 'കയറ്റുമതി റദ്ദാക്കി.';

  @override
  String get errorExportNothing =>
      'ആ തിരഞ്ഞെടുപ്പിന് കയറ്റുമതി ചെയ്യാൻ കുറിപ്പുകളൊന്നുമില്ല.';

  @override
  String get errorExportFailed =>
      'കയറ്റുമതി പൂർത്തിയാക്കാനായില്ല. ഒന്നും സൂക്ഷിച്ചിട്ടില്ല.';

  @override
  String get errorExportPdfTimedOut =>
      'PDF നിർമ്മിക്കാൻ വളരെ സമയമെടുത്തതിനാൽ നിർത്തി. ചെറിയ തീയതി പരിധി ശ്രമിക്കുക.';

  @override
  String get errorExportPdfFailed => 'PDF നിർമ്മിക്കാനായില്ല.';

  @override
  String get titleExportSkipped => 'ഉൾപ്പെടുത്താത്തവ';

  @override
  String bodyExportSkippedLockedAttachment(String fileName) {
    return '$fileName — പൂട്ടിയിരിക്കുന്നു. ഉൾപ്പെടുത്താൻ ആദ്യം തുറക്കുക.';
  }

  @override
  String bodyExportSkippedUnreadableAttachment(String fileName) {
    return '$fileName — ഫയൽ വായിക്കാനായില്ല.';
  }

  @override
  String bodyExportSkippedUnreadableVoiceNote(String fileName) {
    return '$fileName — ശബ്ദരേഖ വായിക്കാനായില്ല.';
  }

  @override
  String bodyExportSkippedLockedInlineImage(String fileName) {
    return '$fileName — കുറിപ്പിലെ പൂട്ടിയ ചിത്രം താളിൽ നിന്ന് ഒഴിവാക്കി.';
  }

  @override
  String bodyExportSkippedUnreadableInlineImage(String fileName) {
    return '$fileName — കുറിപ്പിലെ ഒരു ചിത്രം വായിക്കാനായില്ല.';
  }

  @override
  String get descExportFileUntitledEntry => 'പേരില്ലാത്ത കുറിപ്പ്';

  @override
  String get descExportFileDate => 'തീയതി';

  @override
  String get descExportFileTags => 'ടാഗുകൾ';

  @override
  String get descExportFileMood => 'വികാരം';

  @override
  String get descExportFileAttachments => 'അനുബന്ധങ്ങൾ';

  @override
  String get descExportFileVoiceNotes => 'ശബ്ദക്കുറിപ്പുകൾ';

  @override
  String get descExportFileTranscript => 'പകർത്തിയെഴുത്ത്';

  @override
  String get descExportFileLockedNotIncluded =>
      'പൂട്ടിയത് — ഉൾപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get descExportFileImage => 'ചിത്രം';

  @override
  String get descExportFileDrawing => 'രേഖാചിത്രം';

  @override
  String get descExportFileCalloutNote => 'കുറിപ്പ്';

  @override
  String get descExportFileCalloutTip => 'നുറുങ്ങ്';

  @override
  String get descExportFileCalloutWarning => 'മുന്നറിയിപ്പ്';

  @override
  String get descExportFileCalloutImportant => 'പ്രധാനം';

  @override
  String descExportFileMoodValue(int mood) {
    return 'അഞ്ചിൽ $mood';
  }

  @override
  String descExportFileRecording(String duration) {
    return 'ശബ്ദരേഖ ($duration)';
  }

  @override
  String bodyExportFileReadme(
    String journalTitle,
    String exportedAt,
    int entryCount,
    String formatName,
  ) {
    return 'SreerajP Journal Vault-ൽ നിന്നുള്ള കയറ്റുമതി\n\nജേണൽ:  $journalTitle\nകയറ്റുമതി ചെയ്തത്: $exportedAt\nകുറിപ്പുകൾ:  $entryCount\nരൂപഘടന:   $formatName\n\n\"entries\" ഫോൾഡറിൽ ഓരോ കുറിപ്പിനും ഓരോ ഫയൽ ഉണ്ട്.\n\"attachments\" ഫോൾഡർ ഉണ്ടെങ്കിൽ, ആ കുറിപ്പുകളുടെ ഫയലുകളുടെയും\nശബ്ദക്കുറിപ്പുകളുടെയും പകർപ്പ് അതിലുണ്ട്.\n\nഈ കയറ്റുമതി എൻക്രിപ്റ്റ് ചെയ്തിട്ടില്ല. ഈ ഫയലുകൾ തുറക്കാൻ കഴിയുന്ന ആർക്കും അവ വായിക്കാം.\n';
  }

  @override
  String get labelExportData => 'വിവര കയറ്റുമതി';

  @override
  String get tooltipExportEntry => 'ഈ കുറിപ്പ് കയറ്റുമതി ചെയ്യുക';

  @override
  String get tooltipExportJournal => 'ഈ ജേണൽ കയറ്റുമതി ചെയ്യുക';

  @override
  String get titleExportChooseJournal => 'ജേണലിൽ നിന്ന് കയറ്റുമതി';

  @override
  String get bodyExportNoJournals =>
      'ആദ്യം ഒരു ജേണൽ സൃഷ്ടിക്കുക, തുടർന്ന് കയറ്റുമതി ചെയ്യാം.';

  @override
  String get bodyExportAllLocked =>
      'കയറ്റുമതി ചെയ്യാൻ ആദ്യം പൂട്ടിയ ജേണൽ തുറക്കുക.';

  @override
  String descExportFileUnexportableBlock(String type) {
    return '$type ഭാഗം — പാഠമായി കയറ്റുമതി ചെയ്യാനാകില്ല';
  }

  @override
  String get descExportFileImageNotIncluded => 'ചിത്രം ഉൾപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get descExportFileDrawingNotIncluded =>
      'രേഖാചിത്രം ഉൾപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get actionCommonOk => 'ശരി';

  @override
  String get actionCommonDone => 'പൂർത്തിയായി';

  @override
  String get bodyAirqrSettingsApplied =>
      'ക്രമീകരണങ്ങളും ടെംപ്ലേറ്റുകളും പ്രയോഗിച്ചു.';

  @override
  String get bodyAirqrEntryImported => 'കുറിപ്പ് ജേണലിലേക്ക് ഇറക്കുമതി ചെയ്തു.';

  @override
  String get bodyAirqrJournalImported =>
      'ജേണലും കുറിപ്പുകളും ഇറക്കുമതി ചെയ്തു.';

  @override
  String get errorAirqrImport => 'ഡാറ്റ ഇറക്കുമതി ചെയ്യാനായില്ല.';

  @override
  String get descAirqrImportedEntryTitle => 'ഇറക്കുമതി ചെയ്ത കുറിപ്പ്';

  @override
  String get descAirqrImportedJournalTitle => 'ഇറക്കുമതി ചെയ്ത ജേണൽ';

  @override
  String get bodyAirqrAssembling => 'ഫ്രെയിമുകൾ ചേർത്ത് പരിശോധിക്കുന്നു…';

  @override
  String get errorAirqrDecode =>
      'ഡാറ്റ വായിക്കാനായില്ല. ജോടിയാക്കൽ കോഡ് പരിശോധിച്ച് വീണ്ടും സ്കാൻ ചെയ്യുക.';

  @override
  String get actionAirqrScanAgain => 'വീണ്ടും സ്കാൻ';

  @override
  String bodyAirqrFramesReceived(int received, int total) {
    return '$total-ൽ $received ഫ്രെയിമുകൾ ലഭിച്ചു';
  }

  @override
  String get bodyAirqrAlignCamera =>
      'ചലിക്കുന്ന QR കോഡിലേക്ക് ക്യാമറ തിരിക്കുക…';

  @override
  String bodyAirqrMissingFrames(String frames) {
    return 'ലഭിക്കാത്ത ഫ്രെയിമുകൾ: $frames';
  }

  @override
  String get titleAirqrEnterCode => 'ജോടിയാക്കൽ കോഡ് നൽകുക';

  @override
  String get descAirqrEnterCode =>
      'അയയ്ക്കുന്ന സ്ക്രീനിൽ കാണുന്ന 16 അക്ഷര കോഡ് നൽകുക.';

  @override
  String get actionAirqrDecrypt => 'തുറന്ന് പരിശോധിക്കുക';

  @override
  String get titleAirqrVerified => 'ഡാറ്റ സ്ഥിരീകരിച്ചു';

  @override
  String descAirqrPayloadType(String type) {
    return 'തരം: $type';
  }

  @override
  String get labelAirqrKindSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get labelAirqrKindEntry => 'കുറിപ്പ്';

  @override
  String get labelAirqrKindJournal => 'ജേണൽ';

  @override
  String get labelAirqrKindSnapshot => 'സ്നാപ്ഷോട്ട്';

  @override
  String descAirqrPayloadTheme(String theme) {
    return 'തീം: $theme';
  }

  @override
  String descAirqrPayloadAccent(String color) {
    return 'പ്രധാന നിറം: $color';
  }

  @override
  String descAirqrPayloadTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ടെംപ്ലേറ്റുകൾ: $count',
      one: 'ടെംപ്ലേറ്റുകൾ: 1',
    );
    return '$_temp0';
  }

  @override
  String descAirqrPayloadTags(int count) {
    return 'ടാഗുകൾ: $count';
  }

  @override
  String get actionAirqrApplySettings => 'ക്രമീകരണം പ്രയോഗിക്കുക';

  @override
  String get actionAirqrImport => 'വോൾട്ടിലേക്ക് ചേർക്കുക';

  @override
  String get bodyAirqrEncoding => 'QR ഫ്രെയിമുകൾ തയ്യാറാക്കുന്നു…';

  @override
  String get errorAirqrEncode => 'അയയ്ക്കാനുള്ള ഡാറ്റ തയ്യാറാക്കാനായില്ല.';

  @override
  String descAirqrPayloadSize(int bytes, int frames) {
    return '$bytes ബൈറ്റ് • $frames ഫ്രെയിമുകൾ';
  }

  @override
  String get labelAirqrManifestFrame => 'ശീർഷക ഫ്രെയിം';

  @override
  String labelAirqrFrameOf(int index, int total) {
    return 'ഫ്രെയിം $index/$total';
  }

  @override
  String labelAirqrSpeed(int fps) {
    return 'വേഗം: $fps FPS';
  }

  @override
  String bodyAirqrTooLarge(String size, String limit) {
    return '$size QR വഴി അയയ്ക്കാൻ വളരെ വലുതാണ് (പരിധി $limit). പകരം Wi-Fi സമന്വയം ഉപയോഗിക്കുക.';
  }

  @override
  String bodyAirqrSlow(String size, String duration) {
    return 'ഈ കൈമാറ്റം $size ആണ്, QR വഴി ഏകദേശം $duration എടുക്കും. വലിയ കൈമാറ്റങ്ങൾക്ക് Wi-Fi സമന്വയം വളരെ വേഗമേറിയതാണ്.';
  }

  @override
  String descAirqrMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count മിനിറ്റ്',
      one: '1 മിനിറ്റ്',
    );
    return '$_temp0';
  }

  @override
  String descAirqrSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count സെക്കൻഡ്',
      one: '1 സെക്കൻഡ്',
    );
    return '$_temp0';
  }

  @override
  String get bodyAirqrNoJournals => 'അയയ്ക്കാൻ ജേണലുകളൊന്നുമില്ല.';

  @override
  String get titleAirqrSelectJournal => 'ജേണൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get descAirqrNoDescription => 'വിവരണമില്ല';

  @override
  String get descAirqrOffline => 'പൂർണ്ണമായും ഓഫ്‌ലൈൻ • ക്യാമറ മാത്രം';

  @override
  String get labelAirqrBadgeFast => '1 സെക്കൻഡിൽ താഴെ';

  @override
  String get titleAirqrPayloadSettings => 'ക്രമീകരണങ്ങളും ടെംപ്ലേറ്റുകളും';

  @override
  String get titleAirqrPayloadSnapshot => 'വോൾട്ട് പാഠ സ്നാപ്ഷോട്ട്';

  @override
  String get errorTimeCapsuleSeal => 'ടൈം കാപ്സ്യൂൾ പൂട്ടാനായില്ല.';

  @override
  String get errorTimeCapsuleNotFound => 'ടൈം കാപ്സ്യൂൾ കണ്ടെത്തിയില്ല.';

  @override
  String get errorTimeCapsuleLoad => 'ടൈം കാപ്സ്യൂൾ തുറക്കാനായില്ല.';

  @override
  String get labelTimeCapsuleDays => 'ദിവസം';

  @override
  String get labelTimeCapsuleHours => 'മണിക്കൂർ';

  @override
  String get labelTimeCapsuleMinutes => 'മിനിറ്റ്';

  @override
  String get labelTimeCapsuleSeconds => 'സെക്കൻഡ്';

  @override
  String get labelTimeCapsuleSealedOn => 'പൂട്ടിയത്';

  @override
  String get labelTimeCapsuleUnlocksOn => 'തുറക്കുന്നത്';

  @override
  String get labelTimeCapsuleTeaser => 'ഭാവിക്കുള്ള കുറിപ്പ്';

  @override
  String get descEditorPlaceholder => 'നിങ്ങളുടെ കുറിപ്പ് എഴുതുക…';

  @override
  String descBiometricReasonFile(String fileName) {
    return '\"$fileName\" തുറക്കുക';
  }

  @override
  String get descBiometricReasonApp => 'SreerajP Journal Vault തുറക്കുക';

  @override
  String get bodyEditorDrawingLocked =>
      'ലോക്ക് ചെയ്ത രേഖാചിത്രം — അൺലോക്ക് ചെയ്യാൻ അമർത്തുക';

  @override
  String get descEditorImageLoading => 'ചിത്രം ലോഡ് ചെയ്യുന്നു…';

  @override
  String get errorTemplateLoad => 'ടെംപ്ലേറ്റുകൾ ലോഡ് ചെയ്യാനായില്ല.';

  @override
  String get errorTemplateSave => 'ടെംപ്ലേറ്റ് സംരക്ഷിക്കാനായില്ല.';

  @override
  String descShareSealedFileSize(String size) {
    return '$size KB • എൻക്രിപ്റ്റ് ചെയ്ത വോൾട്ട് ഫയൽ';
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
  String get descTemplateTokenToday => 'ഇന്നത്തെ തീയതി (YYYY-MM-DD)';

  @override
  String get descTemplateTokenWeekday => 'ആഴ്ചയിലെ ദിവസം (ഉദാ. തിങ്കൾ)';

  @override
  String get descTemplateTokenDate => 'പൂർണ്ണ തീയതി (ഉദാ. 2026 ഓഗസ്റ്റ് 23)';

  @override
  String get descTemplateTokenTime => 'ഇപ്പോഴത്തെ സമയം (ഉദാ. 2:30 PM)';

  @override
  String get descTemplateTokenYear => 'നാലക്ക വർഷം (ഉദാ. 2026)';

  @override
  String get descTemplateTokenMonth => 'മാസത്തിന്റെ പേര് (ഉദാ. ഓഗസ്റ്റ്)';

  @override
  String get descTemplateTokenDay => 'മാസത്തിലെ ദിവസം (1–31)';

  @override
  String descShareDefaultTitle(String date) {
    return 'കുറിപ്പ് - $date';
  }

  @override
  String labelTimeCapsuleOpenedOn(String date) {
    return '$date-ന് തുറന്നു';
  }

  @override
  String get errorTimeCapsuleUnseal => 'ടൈം കാപ്സ്യൂൾ തുറക്കാനായില്ല.';

  @override
  String get bodySyncStepConnecting => 'ഉപകരണവുമായി ബന്ധിപ്പിക്കുന്നു…';

  @override
  String get bodySyncStepAuthenticating => 'ജോടിയാക്കൽ കോഡ് പരിശോധിക്കുന്നു…';

  @override
  String get bodySyncStepSyncing =>
      'കുറിപ്പുകളും അറ്റാച്ച്മെന്റുകളും പകർത്തുന്നു…';

  @override
  String get bodySyncStepCompleted => 'സമന്വയം പൂർത്തിയായി.';

  @override
  String get errorSyncFailed =>
      'സമന്വയം പരാജയപ്പെട്ടു. രണ്ട് ഉപകരണങ്ങളും പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get labelSyncNotSynced => 'സമന്വയിച്ചിട്ടില്ല';

  @override
  String get labelSyncSynced => 'സമന്വയിച്ചു';

  @override
  String get errorSyncIpRequired => 'IP വിലാസം നൽകുക.';

  @override
  String get errorSyncPortInvalid => '1 മുതൽ 65535 വരെയുള്ള പോർട്ട് നൽകുക.';

  @override
  String get errorSyncCodeInvalid => '16 അക്ഷര ജോടിയാക്കൽ കോഡ് നൽകുക.';

  @override
  String get errorSyncHostAddress => 'ഈ ഉപകരണത്തിന്റെ വിലാസം വായിക്കാനായില്ല.';

  @override
  String get labelSyncNoAddress => 'ഒന്നുമില്ല';

  @override
  String get bodySyncDetectingWifi => 'Wi-Fi തിരയുന്നു…';

  @override
  String labelSyncIpList(String addresses) {
    return 'IP വിലാസം: $addresses';
  }

  @override
  String labelSyncUnresolvedConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പരിഹരിക്കാത്ത വൈരുദ്ധ്യങ്ങൾ',
      one: '1 പരിഹരിക്കാത്ത വൈരുദ്ധ്യം',
    );
    return '$_temp0';
  }

  @override
  String labelSyncLastSyncAt(String timestamp) {
    return 'അവസാന സമന്വയം: $timestamp';
  }

  @override
  String get errorOcrNoCameras => 'ഈ ഉപകരണത്തിൽ ക്യാമറ കണ്ടെത്തിയില്ല.';

  @override
  String get bodyVoiceNoteRecording => 'റെക്കോർഡ് ചെയ്യുന്നു…';

  @override
  String get titleVoiceNote => 'ശബ്ദക്കുറിപ്പ്';

  @override
  String get errorAttachmentAudioPlay => 'ഈ ഓഡിയോ ഫയൽ പ്ലേ ചെയ്യാനായില്ല.';

  @override
  String get errorAttachmentArchiveRead =>
      'ഈ ആർക്കൈവ് വായിക്കാനായില്ല. അത് കേടായതോ പാസ്‌വേഡ് ഉള്ളതോ ആകാം.';

  @override
  String get labelDateToday => 'ഇന്ന്';

  @override
  String get labelDateYesterday => 'ഇന്നലെ';

  @override
  String labelDateDaysAgo(int count) {
    return '$count ദിവസം മുമ്പ്';
  }

  @override
  String labelDateWeeksAgo(int count) {
    return '$count ആഴ്ച മുമ്പ്';
  }

  @override
  String labelDateMonthsAgo(int count) {
    return '$count മാസം മുമ്പ്';
  }

  @override
  String labelDateYearsAgo(int count) {
    return '$count വർഷം മുമ്പ്';
  }

  @override
  String get titlePermissionAttachmentImport =>
      'അറ്റാച്ച്മെന്റ് ലൈബ്രറി ആക്സസ്';

  @override
  String get descPermissionAttachmentImport =>
      'അറ്റാച്ച്മെന്റ് ചേർക്കുമ്പോൾ ഉപകരണത്തിലെ ഫയലുകൾ വായിക്കാൻ ആപ്പിനെ അനുവദിക്കുന്നു.';

  @override
  String get titlePermissionDocumentPicker => 'സിസ്റ്റം ഡോക്യുമെന്റ് പിക്കർ';

  @override
  String get descPermissionDocumentPicker =>
      'അറ്റാച്ച്മെന്റുകൾ തിരഞ്ഞെടുക്കാൻ സിസ്റ്റം ഫയൽ പിക്കർ ഉപയോഗിക്കുന്നു. അനുമതി ആവശ്യമില്ല.';

  @override
  String get labelSecurityEventFailedAuth => 'പ്രാമാണീകരണം പരാജയപ്പെട്ടു';

  @override
  String get labelSecurityEventAttachmentLocked =>
      'അറ്റാച്ച്മെന്റ് ലോക്ക് ചെയ്തു';

  @override
  String get labelSecurityEventAttachmentUnlocked =>
      'അറ്റാച്ച്മെന്റ് അൺലോക്ക് ചെയ്തു';

  @override
  String get labelSecurityEventExportAttempt => 'ജേണൽ ഡാറ്റ കയറ്റുമതി ചെയ്തു';

  @override
  String get labelSecurityEventLockTriggered => 'ആപ്പ് ലോക്ക് ചെയ്തു';

  @override
  String get labelSecurityEventProfileChanged => 'ഓട്ടോ-ലോക്ക് പ്രൊഫൈൽ മാറ്റി';

  @override
  String get labelSecurityEventProfileCreated =>
      'ഓട്ടോ-ലോക്ക് പ്രൊഫൈൽ സൃഷ്ടിച്ചു';

  @override
  String get labelSecurityEventScreenSecurityChanged =>
      'സ്ക്രീൻഷോട്ട് തടയൽ മാറ്റി';

  @override
  String get labelSecurityEventTamperDetected => 'കൃത്രിമം കണ്ടെത്തി';

  @override
  String get labelSecurityEventOther => 'സുരക്ഷാ സംഭവം';

  @override
  String get labelImportFormatWord => 'വേഡ് ഡോക്യുമെന്റ്';

  @override
  String get labelImportFormatMarkdown => 'മാർക്ക്ഡൗൺ';

  @override
  String get labelImportFormatPlainText => 'ലളിത പാഠം';

  @override
  String get titleNotificationTimeCapsules => 'ടൈം കാപ്സ്യൂളുകൾ';

  @override
  String get errorStorageMigrationFailed => 'അറ്റാച്ച്മെന്റുകൾ മാറ്റാനായില്ല.';

  @override
  String get descPermissionSafGranted =>
      'സിസ്റ്റം ഫയൽ പിക്കർ വഴി അനുവദിച്ചു — Android 13 മുതൽ പ്രത്യേക അനുമതി ആവശ്യമില്ല.';

  @override
  String labelJournalEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count കുറിപ്പുകൾ',
      one: '1 കുറിപ്പ്',
    );
    return '$_temp0';
  }

  @override
  String get tooltipEditorDictate => 'പറഞ്ഞെഴുതുക';

  @override
  String get titleDictation => 'പറഞ്ഞെഴുത്ത്';

  @override
  String get labelDictationListening => 'കേൾക്കുന്നു…';

  @override
  String get labelDictationPaused => 'നിർത്തിവെച്ചു';

  @override
  String get tooltipDictationPause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get tooltipDictationResume => 'തുടരുക';

  @override
  String get tooltipDictationLanguage => 'സംസാര ഭാഷ';

  @override
  String get labelDictationDeviceDefault => 'ഉപകരണ ഭാഷ';

  @override
  String get labelDictationEditHint => 'ടെക്സ്റ്റ് തിരുത്തുക';

  @override
  String get actionDictationInsert => 'ചേർക്കുക';

  @override
  String get emptyDictationSpeak =>
      'സംസാരിച്ചു തുടങ്ങുക. നിങ്ങളുടെ വാക്കുകൾ ഇവിടെ കാണാം.';

  @override
  String get descDictationPrivacy =>
      'സംസാരം ഈ ഉപകരണത്തിൽ തന്നെ തിരിച്ചറിയുന്നു. ശബ്ദം സേവ് ചെയ്യുകയോ അയയ്ക്കുകയോ ഇല്ല.';

  @override
  String get errorDictationOfflineUnavailable =>
      'ഈ ഉപകരണത്തിൽ ഓഫ്‌ലൈൻ സംസാര തിരിച്ചറിയൽ ലഭ്യമല്ല. പറഞ്ഞെഴുത്ത് ഉപകരണത്തിനുള്ളിൽ മാത്രം പ്രവർത്തിക്കുന്നതിനാൽ ഇവിടെ ഉപയോഗിക്കാനാവില്ല.';

  @override
  String get errorDictationLanguageUnavailable =>
      'ഈ ഭാഷയുടെ ഓഫ്‌ലൈൻ സംസാര മോഡൽ ഇൻസ്റ്റാൾ ചെയ്തിട്ടില്ല. ഫോണിന്റെ സംസാര ക്രമീകരണങ്ങളിൽ ഇൻസ്റ്റാൾ ചെയ്യുക, അല്ലെങ്കിൽ മറ്റൊരു ഭാഷ തിരഞ്ഞെടുക്കുക.';

  @override
  String get errorDictationFailed =>
      'സംസാര തിരിച്ചറിയൽ അപ്രതീക്ഷിതമായി നിന്നു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get helpDictationSanskritUnsupported =>
      'സംസ്കൃത സംസാരം ഇപ്പോൾ ഓഫ്‌ലൈനായി തിരിച്ചറിയാനാവില്ല. ഇംഗ്ലീഷിലോ മലയാളത്തിലോ സംസാരിക്കുക.';

  @override
  String get tooltipOcrPreviewText => 'ടെക്സ്റ്റ് കാണുക';

  @override
  String get actionOcrInAppCamera => 'ആപ്പിലെ ക്യാമറ';

  @override
  String get errorOcrPhoneCameraUnavailable =>
      'ഫോണിലെ ക്യാമറ ആപ്പ് തുറക്കാനായില്ല. പകരം ആപ്പിലെ ക്യാമറ ഉപയോഗിക്കുന്നു.';

  @override
  String get helpOcrPhoneCamera =>
      '\"ഫോട്ടോ എടുക്കുക\" ഏറ്റവും വ്യക്തമായ ഫോട്ടോകൾക്കായി ഫോണിലെ സ്വന്തം ക്യാമറ ആപ്പ് തുറക്കുന്നു. ചില ക്യാമറ ആപ്പുകൾ ഫോട്ടോയുടെ ഒരു പകർപ്പ് ഗാലറിയിലും സൂക്ഷിക്കും. ഫോട്ടോ ഈ ആപ്പിന് പുറത്ത് പോകരുതെങ്കിൽ \"ആപ്പിലെ ക്യാമറ\" തിരഞ്ഞെടുക്കുക.';
}
