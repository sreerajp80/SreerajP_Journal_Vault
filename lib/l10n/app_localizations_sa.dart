// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get titleVaultUnavailable => 'कोशः उद्घाटयितुं न शक्यते';

  @override
  String get descVaultUnavailableKeyMissing =>
      'या कुञ्जिका तव दैनन्दिनीम् उद्घाटयति सा अस्मिन् उपकरणे नास्ति। तया विना कोशः केनापि पठितुं न शक्यते — अनेन अनुप्रयोगेण अपि न।';

  @override
  String get descVaultUnavailableCipherMissing =>
      'एषः अनुप्रयोगनिर्माणः कोशं कूटलिखितुं न शक्नोति, अतः तव दैनन्दिनीम् अरक्षितां स्थापयित्वा न प्रवृत्तः, अपि तु स्थगितः।';

  @override
  String get errorVaultUnavailableConversion =>
      'तव दैनन्दिनी कूटलिखितकोशे स्थापयितुं न शक्ता। सा यथापूर्वं तथैव स्थिता — किमपि न लोपितम्।';

  @override
  String get descVaultUnavailableFileUnreadable =>
      'कोशसञ्चिका पठितुं न शक्यते। सा दूषिता भवेत्, अथवा अनुप्रयोगस्य अन्यस्मिन् संस्थापने रचिता भवेत्।';

  @override
  String get descVaultUnavailableDataIntact =>
      'किमपि न लोपितम्। तव प्रविष्टयः संलग्नानि च अद्यापि अस्मिन् उपकरणे सन्ति।';

  @override
  String get descVaultUnavailableNextSteps =>
      'यदि तव प्रतिलिपिसञ्चिका अस्ति, तर्हि अनुप्रयोगं पुनः संस्थापय तस्याः च पुनःस्थापनं कुरु। नो चेत् इदं संस्थापनं यथास्थितं स्थापय, अनुप्रयोगदत्तांशं च मा मार्जय — तेन कोशः सर्वथा नश्येत्।';

  @override
  String get titleApp => 'श्रीराज्पी दैनन्दिनीकोषः';

  @override
  String get titleAbout => 'परिचयः';

  @override
  String get errorAboutLoad => 'अनुप्रयोगविवरणम् आरोपयितुं न शक्तम्';

  @override
  String get errorCommonRetry => 'पुनः यततु';

  @override
  String get labelAboutVersionBuild => 'अनुप्रयोगसंस्करणम् / निर्माणम्';

  @override
  String get labelAboutLastBuild => 'अन्तिमनिर्माणसमयः';

  @override
  String get titlePermissions => 'अनुमतयः';

  @override
  String get titlePermissionsExplicit => 'स्पष्टाः अनुमतयः';

  @override
  String get titlePermissionsImplicit => 'अन्तर्निहिताः अनुमतयः';

  @override
  String get labelPermissionStatusAllowed => 'अनुमतम्';

  @override
  String get labelPermissionStatusDenied => 'निषिद्धम्';

  @override
  String get labelPermissionStatusPermanentlyDenied => 'स्थायिरूपेण निषिद्धम्';

  @override
  String get labelPermissionStatusUserSelected => 'उपयोक्त्रा चितम्';

  @override
  String get actionPermissionsRequest => 'प्रार्थय';

  @override
  String get actionPermissionsOpenSettings => 'विन्यासान् उद्घाटय';

  @override
  String get actionCommonCancel => 'निवर्त्यताम्';

  @override
  String get actionCommonDelete => 'लोपय';

  @override
  String get actionCommonSave => 'रक्ष';

  @override
  String get titleTags => 'चिह्नानि';

  @override
  String errorTagsLoad(String error) {
    return 'चिह्नानि आरोपयितुं न शक्तानि: $error';
  }

  @override
  String get emptyTags =>
      'अद्यापि चिह्नानि न सन्ति। दैनन्दिन्यां चिह्नानि योजय, तानि अत्र दृश्यन्ते।';

  @override
  String get descTagsAutomaticColour => 'स्वयंचालितः वर्णः';

  @override
  String get tooltipTagsActions => 'चिह्नक्रियाः';

  @override
  String get actionTagsRename => 'नाम परिवर्तय';

  @override
  String get actionTagsChooseColour => 'वर्णं वृणु';

  @override
  String get actionTagsResetColour => 'स्वयंचालितं पुनः स्थापय';

  @override
  String get errorTagsRename =>
      'एतत् नाम रिक्तम् अस्ति अथवा अन्येन चिह्नेन प्रयुक्तम्।';

  @override
  String bodyTagsDeleted(String name) {
    return '#$name लोपितम्।';
  }

  @override
  String get bodyTagsDelete => 'चिह्नं लोपयितव्यम् किम्?';

  @override
  String bodyTagsDeleteBody(String name) {
    return '\"#$name\" इति लोपयितव्यम् किम्? यत्र यत्र प्रयुक्तं तत्र सर्वत्र अपनीयते।';
  }

  @override
  String get titleTagsRename => 'चिह्नस्य नाम परिवर्तय';

  @override
  String get labelTagsName => 'चिह्ननाम';

  @override
  String errorCommon(String message) {
    return 'दोषः: $message';
  }

  @override
  String get descCommonUntitledEntry => 'अनामिका प्रविष्टिः';

  @override
  String get descCommonUntitled => 'अनामिकम्';

  @override
  String get titleTimeline => 'कालरेखा';

  @override
  String get emptyTimelineNoEntriesForDate => 'अस्मिन् दिने प्रविष्टयः न सन्ति';

  @override
  String get labelTimelineCalendarFormatMonth => 'मासः';

  @override
  String get labelTimelineDayCountOverflow => '9+';

  @override
  String get titleInsights => 'अवलोकनानि';

  @override
  String get titleInsightsStreak => 'लेखनपरम्परा';

  @override
  String get labelInsightsStreakCurrent => 'वर्तमाना';

  @override
  String get labelInsightsStreakLongest => 'दीर्घतमा';

  @override
  String get labelInsightsStreakUnitDays => 'दिनानि';

  @override
  String labelInsightsStreakStat(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String labelInsightsLastEntry(String date) {
    return 'अन्तिमा प्रविष्टिः: $date';
  }

  @override
  String get titleInsightsMood => 'भावप्रवृत्तयः (30 दिनानि)';

  @override
  String get emptyInsightsMood =>
      'अद्यापि भावदत्तांशः नास्ति।\nप्रविष्टिषु स्वभावं निर्दिश्य प्रवृत्तीः पश्य।';

  @override
  String descInsightsMood(String date, String mood, int count) {
    return '$date\nभावः: $mood\nप्रविष्टयः: $count';
  }

  @override
  String get titleInsightsTagHeatmap => 'चिह्नघनतामानचित्रम्';

  @override
  String get emptyInsightsTagHeatmap => 'अद्यापि चिह्नानि न प्रयुक्तानि।';

  @override
  String labelInsightsTag(String tag, int count) {
    return '$tag ($count)';
  }

  @override
  String get titleInsightsMemories => 'अस्मिन् दिने';

  @override
  String get emptyInsightsMemories =>
      'अद्य स्मृतयः न सन्ति।\nलेखनं कुरु, स्मृतयः सञ्चीयन्ते!';

  @override
  String labelInsightsYearsAgo(int years) {
    return '$yearsव';
  }

  @override
  String get titleInsightsReflection => 'साप्ताहिकं चिन्तनम्';

  @override
  String get labelInsightsReflectionPeriod => 'कालः';

  @override
  String get labelInsightsReflectionEntries => 'प्रविष्टयः';

  @override
  String get labelInsightsReflectionWords => 'लिखितानि पदानि';

  @override
  String get labelInsightsReflectionAverageMood => 'माध्यमः भावः';

  @override
  String get labelInsightsReflectionTopTags => 'मुख्यानि चिह्नानि';

  @override
  String get labelInsightsReflectionStreak => 'वर्तमाना परम्परा';

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
    return '$count दिनानि';
  }

  @override
  String get actionCommonClose => 'पिधेहि';

  @override
  String get errorCommonUnknown => 'अज्ञातः दोषः';

  @override
  String get titleImport => 'सञ्चिकाः आनय';

  @override
  String get bodyImportSelecting => 'आनीयते...';

  @override
  String get actionImportSelectFiles => 'आनेतुं सञ्चिकाः वृणु';

  @override
  String get titleImportResults => 'आनयनफलम्';

  @override
  String get labelImportFileSucceeded => 'सफलतया आनीतम्';

  @override
  String descImportCountSucceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सञ्चिकाः सफलतया आनीताः',
      one: '1 सञ्चिका सफलतया आनीता',
    );
    return '$_temp0';
  }

  @override
  String get emptyAttachmentArchive => 'इदं सङ्ग्रहपत्रं रिक्तम्।';

  @override
  String get descAttachmentOpenWith => 'अनेन उद्घाटय...';

  @override
  String get titleAttachmentUnsupported => 'असमर्थितः सञ्चिकाप्रकारः';

  @override
  String bodyAttachmentUnsupported(String fileName) {
    return '$fileName अनुप्रयोगस्य अन्तः दर्शयितुं न शक्यते।';
  }

  @override
  String get bodyAttachmentPdfMissing => 'उद्घाटिता सञ्चिका इदानीं न लभ्यते।';

  @override
  String errorAttachmentPdfOpen(String reason) {
    return 'PDF उद्घाटयितुं न शक्तम्: $reason';
  }

  @override
  String get titleAutoLock => 'स्वयंरोधविन्यासाः';

  @override
  String get actionAutoLockNewProfile => 'नूतनः विन्यासः';

  @override
  String get tooltipAutoLockEditProfile => 'विन्यासं सम्पादय';

  @override
  String get emptyAutoLock =>
      'अद्यापि स्वयंरोधविन्यासाः न सन्ति। निष्क्रियतायाः अनन्तरम् अनुप्रयोगं रोद्धुम् एकं रचय।';

  @override
  String get tooltipAutoLockDeleteProfile => 'विन्यासं लोपय';

  @override
  String get tooltipAutoLockActivate => 'सक्रियं कुरु';

  @override
  String get tooltipAutoLockDeactivate => 'निष्क्रियं कुरु';

  @override
  String descAutoLock(String timeout, String lockOnMinimize, String active) {
    return '$timeout$lockOnMinimize$active';
  }

  @override
  String get labelAutoLockSuffixLockOnMinimize => ' • लघूकरणे रोधः';

  @override
  String get labelAutoLockSuffixActive => ' • सक्रियः';

  @override
  String labelAutoLockTimeoutSeconds(int seconds) {
    return '$seconds क्ष';
  }

  @override
  String labelAutoLockTimeoutMinutes(int minutes) {
    return '$minutes नि';
  }

  @override
  String labelAutoLockTimeoutHours(String hours) {
    return '$hours होरा';
  }

  @override
  String get labelAutoLockName => 'नाम';

  @override
  String get labelAutoLockTimeout => 'कालः (क्षणेषु)';

  @override
  String get labelAutoLockLockOnMinimize => 'लघूकरणे रुन्धि';

  @override
  String get errorAutoLockName => 'नाम आवश्यकम्।';

  @override
  String get errorAutoLockTimeout => 'कालः धनपूर्णाङ्कः भवेत्।';

  @override
  String get titleSecurityEvents => 'सुरक्षाघटनाः';

  @override
  String get emptySecurityEvents => 'सुरक्षाघटनाः न अभिलिखिताः';

  @override
  String get titleSecurityEventDetails => 'घटनाविवरणम्';

  @override
  String get titleSyncConflicts => 'समन्वयविरोधाः';

  @override
  String errorSyncConflictsLoad(String error) {
    return 'विरोधाः आरोपयितुं न शक्ताः:\n$error';
  }

  @override
  String get emptySyncNoConflicts => 'अवशिष्टाः विरोधाः न सन्ति';

  @override
  String get emptySyncAllInSync => 'सर्वः दत्तांशः समन्वितः।';

  @override
  String labelSyncDetectedAt(String timestamp) {
    return 'ज्ञातम्: $timestamp';
  }

  @override
  String get titleSyncChangedFields => 'परिवर्तितानि क्षेत्राणि:';

  @override
  String get actionSyncCompare => 'तुलय';

  @override
  String get actionSyncKeepRemote => 'दूरस्थं स्थापय';

  @override
  String get actionSyncKeepLocal => 'स्थानीयं स्थापय';

  @override
  String get bodySyncKeepLocal => 'स्थानीयं संस्करणं स्थापयितव्यम् किम्?';

  @override
  String get bodySyncKeepRemote => 'दूरस्थं संस्करणं स्थापयितव्यम् किम्?';

  @override
  String get bodySyncKeepLocalBody =>
      'दूरस्थपरिवर्तनानि त्यज्यन्ते। तव स्थानीयं संस्करणम् अग्रिमे समन्वये प्रेष्यते।';

  @override
  String get bodySyncKeepRemoteBody =>
      'तव स्थानीयपरिवर्तनानि दूरस्थसंस्करणेन प्रतिस्थाप्यन्ते।';

  @override
  String get bodyCommon => 'दृढीकुरु';

  @override
  String get bodySyncConflictResolved => 'विरोधः निराकृतः।';

  @override
  String errorSyncResolution(String error) {
    return 'निराकरणं विफलम्: $error';
  }

  @override
  String get titleSyncConflictDetails => 'विरोधविवरणम्';

  @override
  String get titleSyncColumnField => 'क्षेत्रम्';

  @override
  String get titleSyncColumnLocal => 'स्थानीयम्';

  @override
  String get titleSyncColumnRemote => 'दूरस्थम्';

  @override
  String get titleSyncHealth => 'समन्वयस्वास्थ्यम्';

  @override
  String get labelSyncLastSync => 'अन्तिमः समन्वयः';

  @override
  String get errorSyncFailures7d => 'विफलतानि (7 दिनानि)';

  @override
  String get labelSyncPendingConflicts => 'अवशिष्टाः विरोधाः';

  @override
  String get bodyCommonLoading => 'आरोप्यते...';

  @override
  String get errorCommonErrorShort => 'दोषः';

  @override
  String get bodyCommonEllipsis => '...';

  @override
  String get labelSyncNever => 'कदापि न';

  @override
  String actionSyncResolveCount(int count) {
    return 'निराकुरु ($count)';
  }

  @override
  String get actionSyncNow => 'इदानीं समन्वय';

  @override
  String get titleSyncRecentActivity => 'अद्यतनक्रियाः';

  @override
  String errorSyncLogsLoad(String error) {
    return 'अभिलेखाः आरोपयितुं न शक्ताः: $error';
  }

  @override
  String get emptySyncNoActivity => 'अद्यापि समन्वयक्रिया नास्ति।';

  @override
  String get labelSyncStatusIdle => 'निष्क्रियम्';

  @override
  String get descSyncStatusSyncing => 'परिवर्तनानि समन्वीयन्ते...';

  @override
  String get labelSyncStatusHealthy => 'स्वस्थम्';

  @override
  String get errorSyncStatus => 'विफलम्';

  @override
  String get labelSyncStatusConflicts => 'विरोधाः';

  @override
  String get errorSyncLog => 'समन्वयः विफलः';

  @override
  String labelSyncLogPushed(int count) {
    return '$count प्रेषिताः';
  }

  @override
  String labelSyncLogPulled(int count) {
    return '$count आनीताः';
  }

  @override
  String labelSyncLogConflicts(int count) {
    return '$count विरोधाः';
  }

  @override
  String get labelSyncLogNoChanges => 'परिवर्तनानि न सन्ति';

  @override
  String get tooltipCommonRefresh => 'पुनः आनय';

  @override
  String get titleBackup => 'प्रतिलिपिस्वास्थ्यम्';

  @override
  String get actionBackupNow => 'इदानीं प्रतिलिपिं कुरु';

  @override
  String get bodyBackupInProgress => 'प्रतिलिपिः क्रियते...';

  @override
  String get titleBackupHistory => 'प्रतिलिपीतिहासः';

  @override
  String get titleBackupStatus => 'प्रतिलिपिस्थितिः';

  @override
  String get bodyBackupNoneYet => 'अद्यापि सफला प्रतिलिपिः नास्ति';

  @override
  String get labelBackupLastBackup => 'अन्तिमा प्रतिलिपिः';

  @override
  String get labelBackupEntries => 'प्रविष्टयः';

  @override
  String get labelBackupAttachments => 'संलग्नानि';

  @override
  String get labelBackupSize => 'परिमाणम्';

  @override
  String errorBackupRecentFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'गते सप्ताहे $count विफलाः प्रतिलिपयः',
      one: 'गते सप्ताहे 1 विफला प्रतिलिपिः',
    );
    return '$_temp0';
  }

  @override
  String get titleBackupSchedule => 'स्वयंप्रतिलिपिसमयसूची';

  @override
  String labelBackupScheduled(String interval) {
    return 'नियोजिता: $interval';
  }

  @override
  String get bodyBackupNotScheduled => 'न नियोजिता';

  @override
  String get labelBackupTimerActive => 'सक्रियम्';

  @override
  String get labelBackupTimerInactive => 'निष्क्रियम्';

  @override
  String get labelBackupLastScheduledRun => 'अन्तिमं नियोजितं कार्यम्';

  @override
  String get actionBackupDisable => 'निष्क्रियं कुरु';

  @override
  String get actionBackupConfigure => 'विन्यासं कुरु';

  @override
  String get actionBackupChange => 'परिवर्तय';

  @override
  String get titleBackupConfigure => 'समयसूचीविन्यासः';

  @override
  String get labelBackupInterval => 'अन्तरालः';

  @override
  String get labelBackupIntervalDaily => 'प्रतिदिनम्';

  @override
  String get labelBackupIntervalWeekly => 'प्रतिसप्ताहम्';

  @override
  String get labelBackupIntervalMonthly => 'प्रतिमासम्';

  @override
  String get labelBackupPassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get labelBackupPasswordHelper => 'कूटलिखितप्रतिलिपये आवश्यकः';

  @override
  String get emptyBackupNoHistory => 'प्रतिलिपीतिहासः नास्ति';

  @override
  String errorBackupHistoryLoad(String error) {
    return 'इतिहासम् आरोपयितुं न शक्तम्: $error';
  }

  @override
  String titleBackupLog(String trigger, String status) {
    return '$trigger प्रतिलिपिः — $status';
  }

  @override
  String get labelBackupTriggerManual => 'हस्तेन';

  @override
  String get labelBackupTriggerScheduled => 'नियोजिता';

  @override
  String get labelBackupStatusSuccess => 'सफलम्';

  @override
  String get errorBackupStatus => 'विफलम्';

  @override
  String get labelBackupStatusInProgress => 'प्रचलति';

  @override
  String descBackupLogCounts(int entries, int attachments, String size) {
    return '$entries प्रविष्टयः, $attachments संलग्नानि, $size';
  }

  @override
  String get bodyBackupInProgressNote => 'प्रचलति...';

  @override
  String get labelBackupSucceeded => 'प्रतिलिपिः सफलतया सम्पन्ना';

  @override
  String errorBackup(String error) {
    return 'प्रतिलिपिः विफला: $error';
  }

  @override
  String get titleBackupPassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get labelBackupPasswordEnter => 'कूटलेखनगुप्तशब्दं लिख';

  @override
  String get actionBackup => 'प्रतिलिपिः';

  @override
  String get errorBackupPassword => 'गुप्तशब्दः आवश्यकः';

  @override
  String get labelBackupScheduleSaved => 'प्रतिलिपिसमयसूची रक्षिता';

  @override
  String get labelBackupScheduleDisabled => 'प्रतिलिपिसमयसूची निष्क्रिया कृता';

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
  String get actionCommonRestore => 'पुनःस्थापय';

  @override
  String get actionCommonInsert => 'निवेशय';

  @override
  String get actionCommonContinue => 'अनुवर्तय';

  @override
  String get actionCommonOpenSystemSettings => 'प्रणालीविन्यासान् उद्घाटय';

  @override
  String get descEditorCallout => 'सूचनापाठं लिख...';

  @override
  String get tabEditorInsert => 'निवेशपटलम्';

  @override
  String get tooltipEditorInsertTable => 'सारणीं निवेशय';

  @override
  String get tooltipEditorInsertCallout => 'सूचनां निवेशय';

  @override
  String get tooltipEditorInsertImage => 'चित्रं निवेशय';

  @override
  String get tooltipEditorImageSize => 'चित्रपरिमाणम्';

  @override
  String get labelEditorImageSizeSmall => 'लघु';

  @override
  String get labelEditorImageSizeMedium => 'मध्यम';

  @override
  String get labelEditorImageSizeFull => 'पूर्णविस्तारः';

  @override
  String get tooltipEditorRemoveImage => 'प्रविष्टेः चित्रम् अपनय';

  @override
  String get labelEditorImageUnavailable => 'चित्रं न लभ्यते';

  @override
  String get bodyEditorMicPermissionDenied => 'ध्वनिग्राहकानुमतिः निषिद्धा';

  @override
  String get actionEditorDiscard => 'त्यज';

  @override
  String get actionEditorDone => 'सम्पन्नम्';

  @override
  String get titleVersionHistory => 'संस्करणेतिहासः';

  @override
  String errorVersionHistoryLoad(String error) {
    return 'संस्करणानि आरोपयितुं न शक्तानि: $error';
  }

  @override
  String get bodyVersionRestore => 'इदं संस्करणं पुनःस्थापयितव्यम् किम्?';

  @override
  String get labelVersionRestored => 'संस्करणं पुनःस्थापितम्';

  @override
  String get tooltipVersionPreview => 'पूर्वावलोकनम्';

  @override
  String get tooltipVersionRestore => 'इदं संस्करणं पुनःस्थापय';

  @override
  String titleVersionPreview(String title) {
    return 'पूर्वावलोकनम्: $title';
  }

  @override
  String get labelEntrySaved => 'प्रविष्टिः रक्षिता';

  @override
  String get bodyEntryDelete => 'प्रविष्टिं लोपयितव्यम् किम्?';

  @override
  String get bodyEntryDeleteBody => 'इयं प्रविष्टिः स्थायिरूपेण अपनीयते।';

  @override
  String get labelEntryTableRows => 'पङ्क्तयः';

  @override
  String get labelEntryTableColumns => 'स्तम्भाः';

  @override
  String get labelEntryTableDimensionHelp => '1–20';

  @override
  String get titleEntryCalloutType => 'सूचनाप्रकारः';

  @override
  String get labelEntryCalloutInfo => 'सूचना';

  @override
  String get labelEntryCalloutTip => 'सङ्केतः';

  @override
  String get bodyEntryCallout => 'सावधानम्';

  @override
  String get labelEntryCalloutImportant => 'महत्त्वपूर्णम्';

  @override
  String labelEntryVoiceNoteSaved(String seconds) {
    return 'ध्वनिटिप्पणी रक्षिता (${seconds}s)';
  }

  @override
  String get titleEntryEdit => 'प्रविष्टिं सम्पादय';

  @override
  String get titleEntryEditTitleDirty => 'प्रविष्टिं सम्पादय •';

  @override
  String get tooltipEntryVersionHistory => 'संस्करणेतिहासः';

  @override
  String get tooltipEntryDelete => 'प्रविष्टिं लोपय';

  @override
  String get tooltipEntrySave => 'रक्ष';

  @override
  String get tooltipEntryNoUnsavedChanges => 'अरक्षितानि परिवर्तनानि न सन्ति';

  @override
  String get labelEntryTitle => 'शीर्षकम्';

  @override
  String get bodyEntryPermission => 'संलग्नानयनम् अनुमन्यताम् किम्?';

  @override
  String get bodyEntryPermissionBody =>
      'अयम् अनुप्रयोगः तव सञ्चिकाः द्रष्टुम् अनुमतिम् अपेक्षते।';

  @override
  String get titleEntryPermissionBlocked => 'संलग्नप्रवेशः निरुद्धः';

  @override
  String get bodyEntryPermissionBlocked =>
      'अनुमतिः स्थायिरूपेण निषिद्धा। प्रणालीविन्यासेषु ताम् अनुमन्यताम्।';

  @override
  String get bodyEntryNotAnImage =>
      'एषा सञ्चिका चित्रं नास्ति। तस्याः स्थाने संलग्नरूपेण योजय।';

  @override
  String get errorEntryImageAdd => 'तत् चित्रं योजयितुं न शक्तम्।';

  @override
  String get tooltipEntryAddAttachment => 'संलग्नं योजय';

  @override
  String get tooltipEntryRecordVoiceNote => 'ध्वनिटिप्पणीं मुद्रय';

  @override
  String get titleEntryLinkedFrom => 'अत्रतः संयोजितम्';

  @override
  String get tooltipEntryMood => 'भावं निर्दिश';

  @override
  String get titleEntryMood => 'भावः';

  @override
  String labelEntryMood(String face, int level) {
    return '$face $level';
  }

  @override
  String get errorEntryAuth => 'प्रमाणीकरणम् आवश्यकम्।';

  @override
  String get bodyAttachmentOpenNoApp => 'अनुरूपः अनुप्रयोगः न लब्धः';

  @override
  String get errorAttachmentOpenDecrypt => 'संलग्नम् उद्घाटयितुं न शक्तम्';

  @override
  String get bodyAttachmentOpenFileMissing => 'संलग्नसञ्चिका न लभ्यते';

  @override
  String get bodyAttachmentOpenPermissionDenied =>
      'संलग्नम् उद्घाटयितुम् अनुमतिः आवश्यका';

  @override
  String get titleEntryAttachments => 'संलग्नानि';

  @override
  String get tooltipEntryRemoveAttachmentLock => 'संलग्नरोधम् अपनय';

  @override
  String get tooltipEntryLockAttachment => 'संलग्नं रुन्धि';

  @override
  String get tooltipEntryOpenAttachment => 'संलग्नम् उद्घाटय';

  @override
  String get bodyVersionRestoreBody =>
      'पुनःस्थापनात् पूर्वं तव वर्तमानविषयः नूतनसंस्करणरूपेण रक्ष्यते।';

  @override
  String get actionCommonUnlock => 'उद्घाटय';

  @override
  String get labelCommonPassword => 'गुप्तशब्दः';

  @override
  String get bodyCommonSaving => 'रक्ष्यते...';

  @override
  String get titleLockSetup => 'अनुप्रयोगरोधस्य विन्यासः';

  @override
  String get bodyLockSetup =>
      'पृष्ठभूमिं गते SreerajP Journal Vault कथं रुध्यताम् इति वृणु।';

  @override
  String get labelLockModePhone => 'उपकरणरोधः';

  @override
  String get descLockModePhone =>
      'उपकरणस्य अङ्गुलिचिह्नं PIN आकृतिः गुप्तशब्दः वा प्रयुज्यताम्।';

  @override
  String get labelLockModeApp => 'पृथक् अनुप्रयोगरोधः';

  @override
  String get descLockModeApp =>
      'अनुप्रयोगस्य अन्तः परीक्ष्यमाणः पृथक् PIN प्रयुज्यताम्।';

  @override
  String get labelLockPin => 'PIN';

  @override
  String get labelLockConfirmPin => 'PIN दृढीकुरु';

  @override
  String get bodyLockSettingUp => 'विन्यासः क्रियते...';

  @override
  String get errorLockPin => 'PIN न्यूनातिन्यूनं चत्वारि अक्षराणि भवेत्।';

  @override
  String get bodyLockPinsDoNotMatch => 'उभौ PIN न समानौ।';

  @override
  String errorLockSetupSave(String error) {
    return 'रोधविन्यासः रक्षितुं न शक्तः: $error';
  }

  @override
  String errorLockPinSave(String error) {
    return 'PIN रक्षितुं न शक्तः: $error';
  }

  @override
  String get titleLockPinSetup => 'अनुप्रयोगरोधस्य PIN स्थापय';

  @override
  String get bodyLockPinSetup =>
      'पृथक् अनुप्रयोगरोधाय PIN आवश्यकः। अग्रे गन्तुं तं स्थापय।';

  @override
  String get labelLockGateHeadline => 'तव दैनन्दिनी रुद्धा';

  @override
  String get descLockGate => 'प्रविष्टीः द्रष्टुम् उद्घाटय।';

  @override
  String get tooltipLockGateShowPin => 'PIN दर्शय';

  @override
  String get tooltipLockGateHidePin => 'PIN गोपय';

  @override
  String get labelLockGateBadge => 'रुद्धम्';

  @override
  String get actionLockUnlockWithPhone => 'उपकरणरोधेन उद्घाटय';

  @override
  String get errorLockAuth => 'प्रमाणीकरणं विफलम्। पुनः यततु।';

  @override
  String get bodyLockAuthUnavailable =>
      'उपकरणप्रमाणीकरणं न लभ्यते। प्रणालीविन्यासेषु PIN अङ्गुलिचिह्नं वा स्थापय।';

  @override
  String get bodyLockEnterPin => 'तव PIN लिख।';

  @override
  String get bodyLockIncorrectPin => 'PIN अशुद्धः।';

  @override
  String get titleLockedAttachments => 'संलग्नस्तरीयः रोधः';

  @override
  String get emptyLockedAttachments =>
      'अद्यापि किमपि संलग्नं न रुद्धम्। प्रविष्टिम् उद्घाट्य संलग्नस्य रोधकुञ्जिकां प्रयुज्य उद्घाटनात् पूर्वं पुनःप्रमाणीकरणम् आवश्यकं कुरु।';

  @override
  String labelLockedAttachmentSince(String date) {
    return '$date रुद्धम्';
  }

  @override
  String get actionLockedAttachmentRemove => 'रोधम् अपनय';

  @override
  String get navHome => 'गृहम्';

  @override
  String get navSearch => 'अन्वेषणम्';

  @override
  String get navTimeline => 'कालरेखा';

  @override
  String get navInsights => 'अवलोकनानि';

  @override
  String get navSettings => 'विन्यासाः';

  @override
  String get bodyJournalDelete => 'दैनन्दिनीं लोपयितव्यम् किम्?';

  @override
  String bodyJournalDeleteBody(String title) {
    return '\"$title\" इति लोपयितव्यम् किम्?';
  }

  @override
  String get tooltipJournalManageTags => 'चिह्नानि प्रबन्धय';

  @override
  String get tooltipJournalNew => 'नूतना दैनन्दिनी';

  @override
  String get tooltipJournalEdit => 'दैनन्दिनीं सम्पादय';

  @override
  String get tooltipJournalDelete => 'दैनन्दिनीं लोपय';

  @override
  String get emptyJournal => 'अद्यापि दैनन्दिन्यः न सन्ति';

  @override
  String get emptyJournalEmptyBody =>
      'लेखनम् आरब्धुं “नूतना दैनन्दिनी” इति स्पृश।';

  @override
  String get labelJournalTitle => 'शीर्षकम्';

  @override
  String get labelJournalDescription => 'विवरणम्';

  @override
  String get labelJournalTags => 'चिह्नानि (अल्पविरामेन पृथक्)';

  @override
  String get labelJournalLockSwitch => 'दैनन्दिनीं रुन्धि';

  @override
  String get labelJournalConfirmPassword => 'गुप्तशब्दं दृढीकुरु';

  @override
  String get actionJournalAddEntry => 'प्रविष्टिं योजय';

  @override
  String get labelJournalIsLocked => 'दैनन्दिनी रुद्धा';

  @override
  String get labelJournalUnlocked => 'उद्घाटिता';

  @override
  String get bodyJournalIncorrectPassword => 'गुप्तशब्दः अशुद्धः।';

  @override
  String get titleSettingsSectionSecurity => 'सुरक्षा';

  @override
  String get descSettingsSectionSecurity =>
      'रोधप्रकारः, स्वयंरोधः, पटलचित्राणि, सुरक्षाघटनाः';

  @override
  String get titleSettingsSectionAppearance => 'रूपम्';

  @override
  String get descSettingsSectionAppearance =>
      'वर्णविन्यासः अनुप्रयोगस्य दर्शनं च';

  @override
  String get titleSettingsSectionStorage => 'संग्रहः';

  @override
  String get descSettingsSectionStorage =>
      'संलग्नस्थानम्, उपयोगः, प्रतिलिपिः, आनयनम्';

  @override
  String get titleSettingsSectionPermissions => 'अनुमतयः';

  @override
  String get descSettingsSectionPermissions =>
      'अनुप्रयोगः किं प्रयोक्तुं शक्नोति';

  @override
  String get titleSettingsSectionAbout => 'परिचयः';

  @override
  String get descSettingsSectionAbout =>
      'संस्करणम्, अनुज्ञापत्राणि, अनुप्रयोगविवरणम्';

  @override
  String get labelSettingsAppLockMode => 'अनुप्रयोगरोधप्रकारः';

  @override
  String get labelSettingsAutoLockTimeout => 'स्वयंरोधकालः';

  @override
  String get labelSettingsScreenSecurity => 'पटलचित्राणि निरुन्धि';

  @override
  String get descSettingsScreenSecurity =>
      'पटलचित्राणि, पटलमुद्रणम्, अद्यतनानुप्रयोगसूच्यां दृश्यमानं पूर्वदर्शनं च निरुणद्धि';

  @override
  String get bodySettingsScreenSecurityOff =>
      'पटलचित्ररोधं निष्क्रियं कर्तव्यम् किम्?';

  @override
  String get bodySettingsScreenSecurityOffBody =>
      'यः कोऽपि पटलचित्रम् आदातुं पटलं मुद्रयितुं वा शक्नोति सः तव दैनन्दिनीविषयम् आदातुं शक्नोति। अद्यतनानुप्रयोगसूची अपि तव अन्तिमं पटलं दर्शयति। एतत् कदापि पुनः सक्रियं कर्तुं शक्यते।';

  @override
  String get actionSettingsScreenSecurityOff => 'निष्क्रियं कुरु';

  @override
  String get bodySettingsScreenSecurityUpdatedOn => 'पटलचित्ररोधः सक्रियः';

  @override
  String get bodySettingsScreenSecurityUpdatedOff => 'पटलचित्ररोधः निष्क्रियः';

  @override
  String get errorSettingsScreenSecuritySave =>
      'पटलचित्ररोधः परिवर्तयितुं न शक्तः';

  @override
  String get labelSettingsTamperAlerts => 'विकृतिसूचनाः';

  @override
  String get labelSettingsSyncConflicts => 'समन्वयविरोधाः';

  @override
  String get labelSettingsSecurityEvents => 'सुरक्षाघटनाः';

  @override
  String get labelSettingsThemeLight => 'प्रकाशः';

  @override
  String get labelSettingsThemeDark => 'अन्धकारः';

  @override
  String get labelSettingsThemeSystem => 'प्रणाली';

  @override
  String get bodySettingsSwitchLock => 'रोधप्रकारः परिवर्तयितव्यः किम्?';

  @override
  String bodySettingsSwitchLockBody(String enabled, String disabled) {
    return 'अनेन अनुप्रयोगरक्षा $enabled इत्यत्र परिवर्तते, $disabled च निष्क्रियं भवति। अनुवर्तताम् किम्?';
  }

  @override
  String get actionSettingsSwitch => 'परिवर्तय';

  @override
  String descSettingsLockModeUpdated(String mode) {
    return 'रोधप्रकारः परिवर्तितः: $mode इदानीं सक्रियः।';
  }

  @override
  String get errorSettingsThemeSave =>
      'वर्णविन्यासः रक्षितुं न शक्तः। पुनः यततु।';

  @override
  String descSettingsThemeUpdated(String mode) {
    return 'वर्णविन्यासः परिवर्तितः: $mode इदानीं सक्रियः।';
  }

  @override
  String get bodyStorageMigrate => 'संलग्नानि स्थानान्तरयितव्यानि किम्?';

  @override
  String bodyStorageMigrateBody(String target) {
    return 'सर्वाणि संलग्नानि $target इत्यत्र स्थानान्तर्यन्ते।';
  }

  @override
  String get actionStorageMigrate => 'स्थानान्तरय';

  @override
  String get bodyStorageMigrationCancelled => 'स्थानान्तरणं निवर्तितम्।';

  @override
  String errorStorageMigration(String error) {
    return 'स्थानान्तरणं विफलम्: $error';
  }

  @override
  String get bodyStorageMigrationComplete => 'स्थानान्तरणं सम्पन्नम्।';

  @override
  String get titleStorageLocation => 'संलग्नसंग्रहस्थानम्';

  @override
  String get titleStorageLocationDialogTitle => 'संग्रहस्थानम्';

  @override
  String get labelStorageAppPrivate => 'अनुप्रयोगस्य स्वकीयः';

  @override
  String get labelStorageSdCard => 'SD-पत्रम्';

  @override
  String labelStorageSdCardNamed(String label) {
    return 'SD-पत्रम् ($label)';
  }

  @override
  String get labelStorageMigrateRow => 'संग्रहं स्थानान्तरय';

  @override
  String get labelStorageMigrationIdle => 'निष्क्रियम्';

  @override
  String descStorageMigrationRunning(int processed, int total) {
    return '$total मध्ये $processed स्थानान्तर्यते…';
  }

  @override
  String get descStorageMigrationFailedShort => 'स्थानान्तरणं विफलम्।';

  @override
  String get labelStorageUsage => 'संग्रहोपयोगः';

  @override
  String get bodyStorageUnknown => '—';

  @override
  String get labelStorageBackupHealth => 'प्रतिलिपिस्वास्थ्यम्';

  @override
  String get labelStorageImportData => 'दत्तांशम् आनय';

  @override
  String get titleStorageSyncHealth => 'समन्वयस्वास्थ्यम्';

  @override
  String get bodyStorageImportNeedsJournal =>
      'आनयनार्थं प्रथमं दैनन्दिनीं रचय।';

  @override
  String get titleStorageImportChooseJournal => 'दैनन्दिन्याम् आनय';

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
  String get titleMigration => 'संलग्नानि स्थानान्तर्यन्ते';

  @override
  String get bodyMigrationCancelling => 'निवर्त्यते…';

  @override
  String labelMigrationProgress(String processed, String total) {
    return '$total मध्ये $processed';
  }

  @override
  String get descMigrationUnknownTotal => '?';

  @override
  String get labelPermissionStatusRow => 'अनुमतिस्थितिः';

  @override
  String get labelPermissionsManage => 'अनुमतीः प्रबन्धय';

  @override
  String get labelPermissionsOpenSystem => 'प्रणालीविन्यासान् उद्घाटय';

  @override
  String descPermissionsGranted(int granted, int total) {
    return '$total मध्ये $granted अनुमताः';
  }

  @override
  String get descSearch => 'दैनन्दिनीषु प्रविष्टिषु च अन्विष्य...';

  @override
  String get actionSearchTypeToSearch => 'अन्वेषणाय लिख';

  @override
  String get bodySearchNoFilterMatches => 'अस्मै छाननाय किमपि न लब्धम्।';

  @override
  String get emptySearch => 'किमपि न लब्धम्';

  @override
  String get titleSearchSectionJournals => 'दैनन्दिन्यः';

  @override
  String get titleSearchSectionEntries => 'प्रविष्टयः';

  @override
  String get titleSearchSavePreset => 'अन्वेषणविन्यासं रक्ष';

  @override
  String get labelSearchPresetName => 'विन्यासनाम';

  @override
  String get titleRestore => 'प्रतिलिपेः पुनःस्थापनम्';

  @override
  String get actionRestoreOpen => 'प्रतिलिपेः पुनःस्थापय';

  @override
  String get titleRestoreLocked => 'अनुवर्तितुम् उद्घाटय';

  @override
  String get bodyRestoreLocked =>
      'पुनःस्थापनं तव दैनन्दिनीं परिवर्तयति, अतः सा अनुप्रयोगवत् एव रक्ष्यते।';

  @override
  String get actionRestoreUnlock => 'उद्घाटय';

  @override
  String get labelRestoreUnlockReason => 'प्रतिलिपेः पुनःस्थापनाय उद्घाटय';

  @override
  String get errorRestoreUnlock => 'उद्घाटयितुं न शक्तम्। किमपि न परिवर्तितम्।';

  @override
  String get labelRestoreEnterPin => 'तव अनुप्रयोग-PIN लिख';

  @override
  String get bodyRestorePinWrong => 'सः PIN अशुद्धः।';

  @override
  String get titleRestorePick => 'प्रतिलिपिं वृणु';

  @override
  String get actionRestorePickFromDevice => 'सञ्चिकां वृणु';

  @override
  String get bodyRestoreNoBackupsFound =>
      'अनेन अनुप्रयोगेण कृताः प्रतिलिपयः न लब्धाः। तथापि सञ्चिकां वरीतुं शक्यते।';

  @override
  String labelRestoreSelectedFile(String fileName) {
    return 'चितम्: $fileName';
  }

  @override
  String get labelRestorePassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get bodyRestorePasswordHelper =>
      'इयं प्रतिलिपिः यदा कृता तदा प्रयुक्तः गुप्तशब्दः।';

  @override
  String get actionRestoreOpenBackup => 'प्रतिलिपिम् उद्घाटय';

  @override
  String get titleRestorePreview => 'अस्यां प्रतिलिपौ किम् अस्ति';

  @override
  String labelRestorePreviewCreated(String date) {
    return '$date दिने कृता';
  }

  @override
  String bodyRestorePreviewCounts(int journals, int entries, int attachments) {
    return '$journals दैनन्दिन्यः, $entries प्रविष्टयः, $attachments संलग्नानि';
  }

  @override
  String get bodyRestoreLegacyAttachments =>
      'इयं प्राचीना प्रतिलिपिः। तस्याः संलग्नानि तस्मिन् एव उपकरणे उद्घाट्यन्ते यत्र सा कृता।';

  @override
  String get bodyRestoreMode => 'कथं पुनःस्थापयितव्यम्?';

  @override
  String get actionRestoreModeMerge => 'संयोजय';

  @override
  String get descRestoreModeMergeDetail =>
      'यत् नास्ति तत् योजय, यत् अस्ति तत् च रक्ष।';

  @override
  String get actionRestoreModeReplace => 'प्रतिस्थापय';

  @override
  String get descRestoreModeReplaceDetail =>
      'अत्र यत् अस्ति तत् लोपय, प्रतिलिपिं च प्रयुङ्क्ष्व। प्रथमं सुरक्षाप्रतिलिपिः क्रियते।';

  @override
  String get actionRestoreDryRun => 'प्रथमं परीक्षय';

  @override
  String get bodyRestoreDryRunHelper =>
      'किमपि न परिवर्त्य किं परिवर्तेत इति दर्शयति।';

  @override
  String get actionRestore => 'पुनःस्थापय';

  @override
  String get bodyRestoreConfirmReplace => 'सर्वं प्रतिस्थापयितव्यम् किम्?';

  @override
  String get bodyRestoreConfirmReplaceBody =>
      'अस्मिन् उपकरणे प्रत्येका दैनन्दिनी प्रविष्टिः संलग्नं च लोप्यते, प्रतिलिप्या च प्रतिस्थाप्यते। अत्र यत् अस्ति तस्य सुरक्षाप्रतिलिपिः प्रथमं क्रियते।';

  @override
  String get bodyRestoreConfirmMerge => 'इयं प्रतिलिपिः संयोजयितव्या किम्?';

  @override
  String get bodyRestoreConfirmMergeBody =>
      'प्रतिलिपौ यत् अस्ति किन्तु अत्र नास्ति तत् योज्यते। किमपि न लोप्यते।';

  @override
  String get titleRestoreDryRunResult => 'किं भवेत्';

  @override
  String get titleRestoreResult => 'पुनःस्थापनं सम्पन्नम्';

  @override
  String labelRestoreResultAdded(int count) {
    return 'योजिताः: $count पङ्क्तयः';
  }

  @override
  String labelRestoreResultSkipped(int count) {
    return 'पूर्वमेव अत्र: $count पङ्क्तयः';
  }

  @override
  String descRestoreResultFiles(int count) {
    return 'पुनःस्थापितानि संलग्नपत्राणि: $count';
  }

  @override
  String errorRestoreResultFiles(int count) {
    return 'पुनःस्थापयितुं न शक्तानि संलग्नपत्राणि: $count';
  }

  @override
  String get descRestoreResultSafetyBackup =>
      'तव पूर्वदत्तांशस्य सुरक्षाप्रतिलिपिः प्रथमं रक्षिता।';

  @override
  String get bodyRestoreErrorWrongPassword =>
      'गुप्तशब्दः अशुद्धः, अथवा प्रतिलिपिसञ्चिका दूषिता।';

  @override
  String get bodyRestoreErrorDamaged =>
      'एषा सञ्चिका प्रतिलिपिः नास्ति, अथवा सा दूषिता।';

  @override
  String get bodyRestoreErrorTooNew =>
      'इयं प्रतिलिपिः अनुप्रयोगस्य नवीनेन संस्करणेन कृता। अनुप्रयोगं नवीकृत्य पुनः यततु।';

  @override
  String get errorRestoreErrorPassword =>
      'प्रतिलिपिगुप्तशब्दः न्यूनातिन्यूनम् अष्ट अक्षराणि भवेत्।';

  @override
  String errorRestoreError(String error) {
    return 'पुनःस्थापनं विफलम्, किमपि न परिवर्तितम्: $error';
  }

  @override
  String get bodyRestoreWorking => 'कार्यं चलति...';

  @override
  String get titleExportProtect => 'गुप्तशब्देन रक्ष';

  @override
  String get descExportProtect =>
      'सञ्चिका तव गुप्तशब्देन कूटलिख्यते। सा अस्मिन् अनुप्रयोगे कस्मिन्नपि उपकरणे पुनः उद्घाट्यते।';

  @override
  String get labelExportPassword => 'गुप्तशब्दः';

  @override
  String get labelExportPasswordConfirm => 'गुप्तशब्दं पुनः लिख';

  @override
  String errorExportPassword(int count) {
    return 'न्यूनातिन्यूनं $count अक्षराणि प्रयुङ्क्ष्व।';
  }

  @override
  String get errorExportPasswordMismatch => 'उभौ गुप्तशब्दौ न समानौ।';

  @override
  String get bodyExportEncryptedNotice =>
      'इमं गुप्तशब्दं सुरक्षिते स्थाने स्थापय। तेन विना निर्यापिता सञ्चिका केनापि पुनः उद्घाटयितुं न शक्यते — त्वया अपि न।';

  @override
  String get titleOpenEncrypted => 'कूटलिखितं निर्यापणम् उद्घाटय';

  @override
  String get descOpenEncryptedIntro =>
      'कूटलिखितनिर्यापणसञ्चिकां वृणु, तस्याः गुप्तशब्दं लिख, अन्तःस्थां सञ्चिकां च रक्ष।';

  @override
  String get actionOpenEncryptedPickFile => 'सञ्चिकां वृणु';

  @override
  String labelOpenEncryptedChosenFile(String fileName) {
    return 'चितम्: $fileName';
  }

  @override
  String get labelOpenEncryptedPassword => 'सञ्चिकागुप्तशब्दः';

  @override
  String get actionOpenEncrypted => 'उद्घाट्य रक्ष';

  @override
  String get bodyOpenEncryptedWorking => 'उद्घाट्यते...';

  @override
  String get titleOpenEncryptedSave => 'उद्घाटितां सञ्चिकां रक्ष';

  @override
  String get descOpenEncryptedSaved =>
      'रक्षिता। सञ्चिका इदानीं कूटलिखिता नास्ति, अतः तां सुरक्षिते स्थाने स्थापय।';

  @override
  String get bodyOpenEncryptedCancelled => 'किमपि न रक्षितम्।';

  @override
  String get errorOpenEncryptedErrorWrongPassword =>
      'गुप्तशब्दः अशुद्धः, अथवा सञ्चिका दूषिता।';

  @override
  String get errorOpenEncryptedErrorNotSealed =>
      'इदम् अनेन अनुप्रयोगेण कृतं कूटलिखितनिर्यापणं नास्ति।';

  @override
  String get errorOpenEncryptedErrorTooNew =>
      'इयं सञ्चिका अनुप्रयोगस्य नवीनेन संस्करणेन कृता। अनुप्रयोगं नवीकृत्य पुनः यततु।';

  @override
  String get errorOpenEncryptedError => 'सञ्चिका उद्घाटयितुं न शक्ता।';

  @override
  String get actionSettingsOpenEncryptedExport =>
      'कूटलिखितं निर्यापणम् उद्घाटय';

  @override
  String get titleTemplateChooser => 'प्रतिरूपं वृणु';

  @override
  String get emptyVersionHistory =>
      'अद्यापि पूर्वसंस्करणानि न सन्ति।\n\nप्रविष्टेः सम्पादनकाले संस्करणानि स्वयमेव रक्ष्यन्ते।';

  @override
  String get labelDrawingStrokeFine => 'सूक्ष्मा (2px)';

  @override
  String get labelDrawingStrokeNormal => 'सामान्या (3.5px)';

  @override
  String get labelDrawingStrokeThick => 'स्थूला (7px)';

  @override
  String get labelDrawingStrokeBold => 'अतिस्थूला (14px)';

  @override
  String get titleDrawingDefault => 'रेखाचित्रम्';

  @override
  String get titleImageDefault => 'चित्रम्';

  @override
  String get bodyEditorImageLocked => 'रुद्धं चित्रम् — उद्घाटनाय स्पृश';

  @override
  String bodyEditorImageUnavailableWithName(String fileName) {
    return 'चित्रं न लभ्यते — $fileName';
  }

  @override
  String get tooltipAudioPause => 'विरमय';

  @override
  String get tooltipAudioPlay => 'श्रावय';

  @override
  String titleImportIntoJournal(String journalTitle) {
    return '\"$journalTitle\" इत्यस्याम् आनय';
  }

  @override
  String labelImportSupportedFormats(String formats) {
    return 'स्वीकृतानि स्वरूपाणि: $formats';
  }

  @override
  String labelImportSupportedExtensions(String extensions) {
    return 'सञ्चिकाः: $extensions';
  }

  @override
  String get bodyImportSelectFilesPrompt =>
      'नूतनप्रविष्टिरूपेण आनेतुं सञ्चिकाः वृणु';

  @override
  String get labelFeaturesCategoryJournaling => 'लेखनं समृद्धपाठसम्पादकः च';

  @override
  String get descFeaturesCategoryJournaling =>
      'भावपूर्णं लेखनम्, प्रतिरूपाणि, OCR, समृद्धमाध्यमानि च';

  @override
  String get descFeaturesCategorySecurity => 'गोपनीयता, कूटलेखनं, कोशसुरक्षा च';

  @override
  String get descFeaturesCategorySecuritySubtitle =>
      'निःस्रावकूटलेखनं सूक्ष्मसुरक्षानियन्त्रणानि च';

  @override
  String get labelFeaturesCategoryDiscovery => 'अन्वेषणम्, कालरेखा, अवलोकनानि';

  @override
  String get descFeaturesCategoryDiscovery =>
      'शीघ्रम् अन्वेषणम्, गभीरा पञ्चाङ्गसञ्चारः, लेखनाभ्यासाः च';

  @override
  String get descFeaturesCategoryStorage =>
      'संग्रहः, प्रतिलिपयः, बहुस्वरूपनिर्यापणं च';

  @override
  String get descFeaturesCategoryStorageSubtitle =>
      'स्थानीयप्रतिलिपिभिः लचीलनिर्यापणैः च पूर्णं दत्तांशस्वामित्वम्';

  @override
  String get titleFeatureQuill => 'Quill समृद्धपाठसम्पादकः';

  @override
  String get descFeatureQuill =>
      'शीर्षकैः, बिन्दुसूचीभिः, अङ्कितसूचीभिः, स्थूलाक्षरैः, तिर्यगक्षरैः, अधोरेखाभिः, उद्धरणैः च सह प्रविष्टीः लिख।';

  @override
  String get titleFeatureTemplates => 'संरचितानि प्रविष्टिप्रतिरूपाणि';

  @override
  String get descFeatureTemplates =>
      'अष्टभिः परिवर्तनीयैः प्रतिरूपैः लेखनम् आरभस्व: दैनिकं चिन्तनम्, कृतज्ञता, स्वप्नदैनन्दिनी, व्यायामाभिलेखः, यात्राविवरणम्, सभाटिप्पण्यः, बिन्दुदैनन्दिनी, मुक्तलेखनं च।';

  @override
  String get bodyFeatureMediaOcr => 'कूटलिखितमाध्यमसंलग्नानि OCR च';

  @override
  String get descFeatureMediaOcr =>
      'उपकरणे एव कूटलिखितानि छायाचित्राणि, ध्वनिमुद्रणानि, लेखपत्राणि च योजय। जालरहितेन OCR-साधनेन चित्रेभ्यः पाठं साक्षात् दैनन्दिन्याम् आनय।';

  @override
  String get titleFeatureTags => 'वर्णयुक्तानि चिह्नानि चिह्नप्रबन्धकः च';

  @override
  String get descFeatureTags =>
      'वर्णयुक्तैः चिह्नैः प्रविष्टीः दैनन्दिन्यः च व्यवस्थापय। चिह्नप्रबन्धके नाम वर्णं वा सुखेन परिवर्तय।';

  @override
  String get titleFeatureMultiJournal => 'अनेकाः पृथक् दैनन्दिन्यः';

  @override
  String get descFeatureMultiJournal =>
      'कार्याय, व्यक्तिगतलेखनाय, यात्रायै, सृजनात्मककार्याय च पृथक् दैनन्दिन्यः रचय, प्रत्येकस्याः स्वकीयैः चिह्नैः विन्यासैः च।';

  @override
  String get bodyFeatureSqlcipher => 'SQLCipher AES-256 दत्तकोशकूटलेखनम्';

  @override
  String get descFeatureSqlcipher =>
      'सर्वः दैनन्दिनीदत्तांशः AES-256-GCM सहितेन SQLCipher-माध्यमेन कूटलिखितः तिष्ठति। अकूटलिखितः दत्तांशः कदापि न लिख्यते।';

  @override
  String get titleFeatureBiometrics => 'अङ्गुलिचिह्नम् अनुप्रयोग-PIN च';

  @override
  String get descFeatureBiometrics =>
      'उपकरणस्य अङ्गुलिचिह्नेन मुखचिह्नेन वा, अथवा पृथक् अनुप्रयोग-PIN द्वारा कोशं रक्ष। अनुप्रयोगपरिवर्तने सः स्वयमेव पुनः रुध्यते।';

  @override
  String get titleFeatureJournalLock => 'प्रतिदैनन्दिनीगुप्तशब्दरोधाः';

  @override
  String get descFeatureJournalLock =>
      'PBKDF2-कुञ्जिकानिष्पादनेन संवेदनशीलाः दैनन्दिन्यः पृथग्गुप्तशब्दैः रुन्धि। रुद्धा दैनन्दिनी प्रतिसत्रं गुप्तशब्दम् अपेक्षते।';

  @override
  String get bodyFeatureAttachmentLock => 'संलग्नस्तरीयाः कूटलेखनरोधाः';

  @override
  String get descFeatureAttachmentLock =>
      'पृथक्कुञ्जिकाभिः संवेदनशीलानि संलग्नानि छायाचित्राणि च रुन्धि गोपय च, येन प्रविष्टिदर्शनकाले अपि तानि गुप्तानि तिष्ठन्ति।';

  @override
  String get bodyFeatureScreenshotGuard => 'पटलचित्रपटलमुद्रणरक्षा';

  @override
  String get descFeatureScreenshotGuard =>
      'FLAG_SECURE इति स्वयंचालिता रक्षा पटलचित्रग्रहणं पटलमुद्रणम् अद्यतनानुप्रयोगसूच्याः स्रावं च निरुणद्धि।';

  @override
  String get bodyFeatureTamperAudit => 'विकृतिसूचकः सुरक्षाभिलेखः';

  @override
  String get descFeatureTamperAudit =>
      'मुख्याः सुरक्षाघटनाः अभिलिख्यन्ते: उद्घाटनप्रयत्नाः, विफलानि प्रमाणीकरणानि, गुप्तशब्दपरिवर्तनानि, निर्यापणक्रियाः च।';

  @override
  String get titleFeatureAutoLock => 'स्वयंरोधस्य निष्क्रियताविन्यासाः';

  @override
  String get descFeatureAutoLock =>
      'निष्क्रियतायां कोशः स्वयमेव पुनः रुध्यताम् इति कालः निश्चीयताम् (तत्क्षणम्, 30 क्षणाः, 1 निमेषः, 5 निमेषाः)।';

  @override
  String get titleFeatureFtsSearch => 'शीघ्रम् SQLite FTS अन्वेषणम्';

  @override
  String get descFeatureFtsSearch =>
      'SQLite FTS5-माध्यमेन प्रत्येकस्याः प्रविष्टेः विषयः शीर्षकं चिह्नं विवरणं च तत्क्षणम् अन्विष्यते।';

  @override
  String get titleFeatureSearchPresets => 'रक्षिताः अन्वेषणविन्यासाः';

  @override
  String get descFeatureSearchPresets =>
      'कालपरिधिचिह्नछाननैः सह पुनःपुनः प्रयुक्तानि अन्वेषणानि एकस्पर्शयोग्यरूपेण रक्ष।';

  @override
  String get bodyFeatureTimeline => 'सक्रिया पञ्चाङ्गकालरेखा';

  @override
  String get descFeatureTimeline =>
      'सरलया पञ्चाङ्गदृष्ट्या, दैनिकबिन्दुभिः, दिनशः सञ्चारेण च समग्रं दैनन्दिनीतिहासं पश्य।';

  @override
  String get titleFeatureInsights => 'लेखनप्रवृत्तयः अभ्यासावलोकनानि च';

  @override
  String get descFeatureInsights =>
      'दैनिकलेखनपरम्पराः, पदसङ्ख्याः, मासे सक्रियदिनानि, मुख्यचिह्नविभागाः च जालरहितैः चित्रैः पश्य।';

  @override
  String get bodyFeatureStorageMigration =>
      'संलग्नसंग्रहस्थानान्तरणम् (SD-पत्रम्)';

  @override
  String get descFeatureStorageMigration =>
      'दैनन्दिनीप्रवेशम् अबाधयित्वा सर्वाणि कूटलिखितानि संलग्नानि आन्तरिककोशात् SD-पत्रं प्रति तस्माद् वा स्थानान्तरय।';

  @override
  String get titleFeatureEncryptedBackups => 'कूटलिखिताः कोशप्रतिलिपयः (.jvbk)';

  @override
  String get descFeatureEncryptedBackups =>
      'दत्तकोशं संलग्नानि चिह्नानि विन्यासांश्च धारयन्तीः गुप्तशब्दरक्षिताः .jvbk प्रतिलिपीः रचय पुनःस्थापय च।';

  @override
  String get titleFeatureMultiExport => 'बहुस्वरूपनिर्यापणम्';

  @override
  String get descFeatureMultiExport =>
      'एकैकां प्रविष्टिं समग्रां दैनन्दिनीं वा PDF, Markdown-सङ्ग्रहः, JSON इति स्वरूपेषु निर्यापय।';

  @override
  String get bodyFeatureEncryptedReader => 'स्वतन्त्रः कूटलिखितनिर्यापणपाठकः';

  @override
  String get descFeatureEncryptedReader =>
      'पूर्णप्रतिलिपेः पुनःस्थापनं विना एव अनुप्रयोगस्य अन्तः गुप्तशब्दरक्षितानि निर्यापणानि पठ।';

  @override
  String get helpTopicJournalOrg => 'दैनन्दिनीव्यवस्था प्रतिरूपाणि च';

  @override
  String get helpTopicJournalOrgSubtitle =>
      'अनेकाः दैनन्दिन्यः, आरम्भप्रश्नाः, Quill-पाठसंरचना च कथं कार्यं कुर्वन्ति।';

  @override
  String get helpTopicAttachmentsOcr => 'संलग्नानि OCR-लेखकश्च';

  @override
  String get helpTopicAttachmentsOcrSubtitle =>
      'उपकरणे एव जालरहितं चित्रेभ्यः पाठग्रहणं कूटलिखितमाध्यमसंग्रहश्च।';

  @override
  String get helpTopicTags => 'चिह्नानि वर्णसङ्केताश्च';

  @override
  String get helpTopicTagsSubtitle =>
      'प्रविष्टिवर्गीकरणम्, चिह्नवर्णाः, सर्वत्र चिह्नप्रबन्धनं च।';

  @override
  String get helpTopicEncryption => 'कूटलेखनं कुञ्जिकाकोशसुरक्षा च';

  @override
  String get helpTopicEncryptionSubtitle =>
      'SQLCipher-कूटलेखनम्, Android-कुञ्जिकाकोशः, जालरहितनिश्चयाः च।';

  @override
  String get helpTopicBiometrics => 'अनुप्रयोगरोधः, अङ्गुलिचिह्नम्, PIN';

  @override
  String get helpTopicBiometricsSubtitle =>
      'अङ्गुलिचिह्नमुखोद्घाटनम्, अनुप्रयोग-PIN स्थापनम्, स्वयंरोधकालाः च।';

  @override
  String get helpTopicJournalLocks => 'दैनन्दिनीरोधाः संलग्नरोधाश्च';

  @override
  String get helpTopicJournalLocksSubtitle =>
      'पृथग्दैनन्दिनीगुप्तशब्दाः, सत्रोद्घाटनम्, संलग्नस्तरीयरोधाः च।';

  @override
  String get helpTopicScreenshotAudit => 'पटलचित्ररक्षा अभिलेखश्च';

  @override
  String get helpTopicScreenshotAuditSubtitle =>
      'FLAG_SECURE रक्षा, कार्यसूचीगोपनम्, स्थानीयसुरक्षाघटनाः च।';

  @override
  String get helpTopicSearchTimeline => 'पूर्णपाठान्वेषणं कालरेखा च';

  @override
  String get helpTopicSearchTimelineSubtitle =>
      'SQLite FTS अन्वेषणम्, रक्षिताः विन्यासाः, पञ्चाङ्गसञ्चारश्च।';

  @override
  String get helpTopicInsights => 'लेखनावलोकनानि प्रवृत्तयश्च';

  @override
  String get helpTopicInsightsSubtitle =>
      'अभ्यासपरम्पराः, पदसङ्ख्याः, मासिकक्रियाचित्राणि, चिह्नविश्लेषणं च।';

  @override
  String get helpTopicStorageMigration => 'संग्रहस्थानानि SD-पत्रं च';

  @override
  String get helpTopicStorageMigrationSubtitle =>
      'कूटलिखितसंलग्नानाम् आन्तरिककोशात् SD-पत्रं प्रति स्थानान्तरणम्।';

  @override
  String get helpTopicBackupRestore => 'कूटलिखिताः प्रतिलिपयः पुनःस्थापनं च';

  @override
  String get helpTopicBackupRestoreSubtitle =>
      'गुप्तशब्दरक्षितानां .jvbk सञ्चिकानां रचनम्, स्वास्थ्यपरीक्षा, नूतने उपकरणे पुनःस्थापनं च।';

  @override
  String get helpTopicExportFormats => 'निर्यापणस्वरूपाणि पाठकश्च';

  @override
  String get helpTopicExportFormatsSubtitle =>
      'PDF, Markdown-सङ्ग्रहः, JSON इति निर्यापणम्, अन्तर्निहितः कूटलिखितपाठकश्च।';

  @override
  String get helpTopicFaq => 'प्रश्नाः समाधानानि च';

  @override
  String get helpTopicFaqSubtitle =>
      'जालरहितगोपनीयता, अनुमतयः, गुप्तशब्दपुनःप्राप्तिनीतिः, उपकरणपरिवर्तनं च।';

  @override
  String get helpAttachmentsIntro =>
      'छायाचित्रैः ध्वनिटिप्पणीभिः लेखपत्रैश्च प्रविष्टीः समृद्धाः कुरु। जालरहितेन OCR-साधनेन मुद्रितं हस्तलिखितं वा पाठं साक्षात् गृहाण।';

  @override
  String get helpAttachmentsSectionOcr => 'उपकरणे एव OCR-पाठग्रहणम्';

  @override
  String get helpAttachmentsOcrBullet1 =>
      'सम्पादके छायायन्त्रचिह्नं स्पृष्ट्वा पुस्तकस्य लेखपत्रस्य हस्तलेखस्य वा चित्रं गृहाण।';

  @override
  String get helpAttachmentsOcrBullet2 =>
      'अन्तर्निहितं OCR-साधनं क्षणेषु पाठं ज्ञात्वा विभजति, बाह्यसेवकेभ्यः किमपि न प्रेषयति।';

  @override
  String get helpAttachmentsOcrBullet3 =>
      'गृहीतः पाठः स्वयमेव संरच्य तव वर्तमानस्थाने निवेश्यते।';

  @override
  String get helpAttachmentsSectionEncryption => 'AES-256-GCM संलग्नकूटलेखनम्';

  @override
  String get helpAttachmentsEncryptionBullet1 =>
      'सर्वाणि माध्यमसंलग्नानि कोशे लेखनात् पूर्वम् AES-256-GCM द्वारा कूटलिख्यन्ते। संगृहीताः सञ्चिकाः अनुप्रयोगं विना चित्रशालया सञ्चिकाप्रबन्धकेन वा न उद्घाट्यन्ते।';

  @override
  String get helpAttachmentsFooter =>
      'गोपनीयतानिश्चयः: सर्वं OCR-पाठग्रहणं तव उपकरणे एव जालरहितं चलति।';

  @override
  String get helpBackupIntro =>
      'उपकरणपरिवर्तने प्रणालीपुनःस्थापने वा कूटलिखितैः .jvbk सङ्ग्रहैः तव दैनन्दिनीं सुरक्षितां स्थापय।';

  @override
  String get helpBackupSectionCreate => 'कूटलिखितप्रतिलिपेः (.jvbk) रचनम्';

  @override
  String get helpBackupCreateBullet1 =>
      'विन्यासाः → संग्रहः → प्रतिलिपिः च पुनःस्थापनम् → प्रतिलिपिं रचय इति गच्छ।';

  @override
  String get helpBackupCreateBullet2 =>
      'दृढं गुप्तशब्दं वृणु। सः दत्तकोशं सर्वाणि माध्यमसंलग्नानि च कूटलिखति।';

  @override
  String get helpBackupCreateBullet3 =>
      'जातां .jvbk सञ्चिकाम् इष्टे पुटके, मेघकोशे, बाह्ये USB-साधने वा रक्ष।';

  @override
  String get helpBackupSectionRestore => 'नूतने उपकरणे पुनःस्थापनम्';

  @override
  String get helpBackupRestoreBullet1 =>
      'नूतने उपकरणे SreerajP Journal Vault संस्थाप्य विन्यासाः → संग्रहः → प्रतिलिपेः पुनःस्थापनम् इति उद्घाटय।';

  @override
  String get helpBackupRestoreBullet2 =>
      'तव .jvbk सञ्चिकां वृणु, प्रतिलिपिरचनाकाले प्रयुक्तं तमेव गुप्तशब्दं च लिख।';

  @override
  String get helpBackupRestoreBullet3 =>
      'सर्वाः दैनन्दिन्यः, प्रविष्टयः, चित्राणि, ध्वनिमुद्रणानि, चिह्नानि च नूतने कोशे पूर्णतया पुनःस्थाप्यन्ते।';

  @override
  String get helpBackupFooter =>
      'महत्त्वपूर्णम्: प्रतिलिपिगुप्तशब्दे विस्मृते प्रतिलिपिः केनापि उद्घाटयितुं न शक्यते।';

  @override
  String get helpBiometricsIntro =>
      'तत्क्षणप्रमाणीकरणेन अथवा पृथक् चतुःषडङ्कयुक्तेन अनुप्रयोग-PIN द्वारा तव गुप्तचिन्तनानि रक्ष।';

  @override
  String get helpBiometricsSectionPhoneLock =>
      'उपकरणरोधप्रकारः (अङ्गुलिचिह्नम्)';

  @override
  String get helpBiometricsPhoneLockBullet1 =>
      'उपकरणस्य अङ्गुलिचिह्नं मुखोद्घाटनं प्रणालीरोधाकृतिं वा प्रयुङ्क्ते।';

  @override
  String get helpBiometricsPhoneLockBullet2 =>
      'सरलं शीघ्रं च — अनुप्रयोगोद्घाटने तत्क्षणम् उद्घाट्यते।';

  @override
  String get helpBiometricsSectionAppPin => 'पृथक् अनुप्रयोग-PIN प्रकारः';

  @override
  String get helpBiometricsAppPinBullet1 =>
      'उपकरणरोधात् भिन्नं पृथक् अङ्कात्मकं PIN स्थापय।';

  @override
  String get helpBiometricsAppPinBullet2 =>
      'अन्यः कोऽपि तव उपकरणरोधसङ्केतं जानाति चेदपि तव दैनन्दिनी गुप्ता तिष्ठति।';

  @override
  String get helpBiometricsSectionAutoLock => 'स्वयंरोधकालविन्यासाः';

  @override
  String get helpBiometricsAutoLockBullet1 =>
      'विन्यासाः → सुरक्षा → स्वयंरोधकालः इत्यत्र कालं निश्चिनु (तत्क्षणम्, 30 क्षणाः, 1 निमेषः, 5 निमेषाः)।';

  @override
  String get helpBiometricsAutoLockBullet2 =>
      'अनुप्रयोगे पृष्ठभूमिं गते कालावसाने कोशः स्वयमेव रुध्यते।';

  @override
  String get helpEncryptionIntro =>
      'SreerajP Journal Vault पूर्णगोपनीयतायै ज्ञानरहितसुरक्षायै च मूलतः एव रचितः।';

  @override
  String get helpEncryptionSectionSqlcipher => 'SQLCipher दत्तकोशकूटलेखनम्';

  @override
  String get helpEncryptionSqlcipherBullet1 =>
      'अन्तर्गतः SQLite-दत्तकोशः AES-256 (CBC/GCM) सहितेन SQLCipher-माध्यमेन कूटलिख्यते।';

  @override
  String get helpEncryptionSqlcipherBullet2 =>
      'प्रविष्टिपाठः, शीर्षकाणि, चिह्नानि, समयाङ्काः — पटले लिखितः प्रत्येकः अंशः कूटलिखितः।';

  @override
  String get helpEncryptionSectionKeystore =>
      'Android-कुञ्जिकाकोशस्य यन्त्रसंयोगः';

  @override
  String get helpEncryptionKeystoreBullet1 =>
      'मुख्यकुञ्जिकाः Android-यन्त्राश्रितकुञ्जिकाकोशे एव रच्यन्ते संगृह्यन्ते च।';

  @override
  String get helpEncryptionKeystoreBullet2 =>
      'कुञ्जिकाः यन्त्रखण्डात् कदापि न निर्गच्छन्ति, मूलाधिकारेण अन्यानुप्रयोगैः वा न गृह्यन्ते।';

  @override
  String get helpEncryptionSectionOffline => 'पूर्णं जालरहितम् एकान्तम्';

  @override
  String get helpEncryptionOfflineBullet1 =>
      'अनुप्रयोगस्य Android-घोषणापत्रे अन्तर्जालानुमतिः न घोषिता।';

  @override
  String get helpEncryptionOfflineBullet2 =>
      'अनुसरणं न, विश्लेषणं न, विज्ञापनानि न, बाह्यसेवकप्रार्थनाः च कदापि न भवन्ति।';

  @override
  String get helpExportIntro =>
      'तव स्मृतयः सर्वदा तवैव सन्तु इति मानकस्वरूपेषु कदापि प्रविष्टीः निर्यापय।';

  @override
  String get helpExportSectionPdf => 'संरचितं PDF-निर्यापणम्';

  @override
  String get helpExportPdfBullet1 =>
      'एकैकां प्रविष्टिं समग्रां दैनन्दिनीं वा चित्रैः सह सुसंरचिते मुद्रणयोग्ये PDF-लेखपत्रे निर्यापय।';

  @override
  String get helpExportSectionMarkdown => 'Markdown-सङ्ग्रहः JSON-दत्तांशश्च';

  @override
  String get helpExportMarkdownBullet1 =>
      'Obsidian, Notion, व्यक्तिगतकोशाय वा चित्रैः सह Markdown-सञ्चिकाः सङ्ग्रहरूपेण निर्यापय।';

  @override
  String get helpExportMarkdownBullet2 =>
      'स्वयंचालितविश्लेषणाय पूर्णदत्तांशवहनाय च शुद्धं JSON निर्यापय।';

  @override
  String get helpExportSectionReader => 'स्वतन्त्रः कूटलिखितपाठकः';

  @override
  String get helpExportReaderBullet1 =>
      'कूटलिखितानि दैनन्दिनीपुटानि निर्यापय, विन्यासेषु स्थितेन अन्तर्निहितेन पाठकेन च तानि कुत्रापि पश्य।';

  @override
  String get helpFaqIntro =>
      'सुरक्षा, प्रतिलिपयः, दैनन्दिनीप्रबन्धनं च इति विषये सामान्यप्रश्नानां शीघ्राणि उत्तराणि।';

  @override
  String get helpFaqQ1 => 'किं मम दत्तांशः कदापि अन्तर्जालेन प्रेष्यते?';

  @override
  String get helpFaqA1 =>
      'कदापि न। SreerajP Journal Vault INTERNET-अनुमतिं न घोषयति। सर्वं तव उपकरणे एव तिष्ठति।';

  @override
  String get helpFaqQ2 =>
      'यदि अनुप्रयोग-PIN दैनन्दिनीगुप्तशब्दं वा विस्मरामि तर्हि किम्?';

  @override
  String get helpFaqA2 =>
      'कूटलेखनं ज्ञानरहितम् उपकरणे एव च भवति, अतः नष्टाः गुप्तशब्दाः केनापि पुनः स्थापयितुं न शक्यन्ते। गुप्तशब्दान् सुरक्षिते स्थाने लिखितान् स्थापयितुं दृढम् अनुरुध्यते।';

  @override
  String get helpFaqQ3 => 'किमर्थं विशिष्टाः अनुमतयः प्रार्थ्यन्ते?';

  @override
  String get helpFaqA3 =>
      'छायायन्त्रं चित्राणि च: प्रविष्टिषु चित्राणि आदातुम् आनेतुं वा।\nध्वनिग्राहकः: ध्वनिटिप्पणीमुद्रणाय वाग्लेखनाय च (यन्त्रे एव परिचीयते)।\nकोशः: कूटलिखिताः प्रतिलिपयः रक्षितुं PDF निर्यापयितुं च।';

  @override
  String get helpFaqQ4 =>
      'किं मम दैनन्दिनी नूतनं दूरवाणीयन्त्रं प्रति नेतुं शक्यते?';

  @override
  String get helpFaqA4 =>
      'आम्! विन्यासेषु कूटलिखितां प्रतिलिपिं (.jvbk) रचय, तां सञ्चिकां नूतनं यन्त्रं प्रति नय, SreerajP Journal Vault संस्थापय, प्रतिलिपेः पुनःस्थापनं च वृणु।';

  @override
  String get helpInsightsIntro =>
      'तव लेखनाभ्यासेषु, भावप्रवृत्तिषु, लेखनसातत्ये च गभीरां दृष्टिं लभस्व।';

  @override
  String get helpInsightsSectionHabits => 'अभ्यासपरम्परायाः अनुसरणम्';

  @override
  String get helpInsightsHabitsBullet1 =>
      'उत्साहाय वर्तमानां श्रेष्ठां च लेखनपरम्परां पश्य।';

  @override
  String get helpInsightsHabitsBullet2 =>
      'मासिकं पञ्चाङ्गघनतामानचित्रं सक्रियलेखनदिनानि दर्शयति।';

  @override
  String get helpInsightsSectionStats => 'पदसङ्ख्या क्रियाविश्लेषणं च';

  @override
  String get helpInsightsStatsBullet1 =>
      'समग्रपदसङ्ख्याम्, प्रविष्टेः माध्यमदैर्घ्यम्, पठनकालं च दैनन्दिनीषु विश्लेषय।';

  @override
  String get helpInsightsSectionTags => 'चिह्नविषयविभागः';

  @override
  String get helpInsightsTagsBullet1 =>
      'कालेन सह तव मुख्यविषयान् ज्ञातुं बहुप्रयुक्तानि चिह्नानि विषयांश्च पश्य।';

  @override
  String get helpJournalLocksIntro =>
      'विशिष्टासु दैनन्दिनीषु संवेदनशीलेषु संलग्नेषु च द्वितीयं सुरक्षास्तरं योजय।';

  @override
  String get helpJournalLocksSectionJournal => 'प्रतिदैनन्दिनीगुप्तशब्दरोधाः';

  @override
  String get helpJournalLocksJournalBullet1 =>
      'संवेदनशीलाभ्यः दैनन्दिनीभ्यः पृथग्गुप्तशब्दान् देहि। अनुप्रयोगे उद्घाटिते अपि रुद्धा दैनन्दिनी गुप्तशब्दं यावत् कूटलिखिता तिष्ठति।';

  @override
  String get helpJournalLocksJournalBullet2 =>
      'सत्रोद्घाटनेन अनुप्रयोगप्रयोगकाले दैनन्दिनी उद्घाटिता तिष्ठति, पिधाने स्वयंरोधकालावसाने वा सा पुनः रुध्यते।';

  @override
  String get helpJournalLocksSectionAttachment => 'संलग्नस्तरीयाः रोधाः';

  @override
  String get helpJournalLocksAttachmentBullet1 =>
      'गुप्तानि छायाचित्राणि लेखपत्राणि च पृथग्गुप्तशब्दैः गोपय रुन्धि च।';

  @override
  String get helpJournalOrgIntro =>
      'तव जीवनं पृथक् दैनन्दिनीषु व्यवस्थापय, संरचितान् प्रश्नान् प्रयुङ्क्ष्व, भावपूर्णं समृद्धपाठं च लिख।';

  @override
  String get helpJournalOrgSectionMultiple => 'अनेकाः पृथक् दैनन्दिन्यः';

  @override
  String get helpJournalOrgMultipleBullet1 =>
      'व्यक्तिगतम्, कार्यम्, यात्रा, कल्पनाः, स्वास्थ्यम् इति पृथक् दैनन्दिन्यः रचय।';

  @override
  String get helpJournalOrgMultipleBullet2 =>
      'उपरितनेन दैनन्दिनीचयनेन सुखेन दैनन्दिनीः परिवर्तय।';

  @override
  String get helpJournalOrgSectionTemplates => 'आरम्भप्रतिरूपाणां प्रयोगः';

  @override
  String get helpJournalOrgTemplatesBullet1 =>
      'नूतनप्रविष्टिरचनाकाले अष्टभ्यः अन्तर्निहितेभ्यः प्रतिरूपेभ्यः वृणु (दैनिकं चिन्तनम्, कृतज्ञता, स्वप्नः, इत्यादि)।';

  @override
  String get helpJournalOrgTemplatesBullet2 =>
      'विन्यासाः → प्रतिरूपाणि इत्यत्र प्रतिरूपाणि परिवर्तय नूतनानि वा रचय।';

  @override
  String get helpJournalOrgSectionRichText => 'समृद्धपाठसंरचना';

  @override
  String get helpJournalOrgRichTextBullet1 =>
      'सम्पादकस्य साधनपट्ट्या स्थूलाक्षरैः, तिर्यगक्षरैः, शीर्षकैः, सूचीभिः, सारणीभिः, रेखाचित्रैः, सूचनाखण्डैश्च पाठं संरचय।';

  @override
  String get helpScreenshotAuditIntro =>
      'SreerajP Journal Vault कथं तव पटलानि गुप्तदृष्टितः रक्षति मुख्यसुरक्षाक्रियाः च अभिलिखति इति ज्ञातव्यम्।';

  @override
  String get helpScreenshotAuditSectionGuard => 'पटलचित्ररक्षा (FLAG_SECURE)';

  @override
  String get helpScreenshotAuditGuardBullet1 =>
      'सामान्यतः अनुप्रयोगः पटलचित्राणि पटलमुद्रणं च निरुणद्धि, अद्यतनकार्यसूच्याः पूर्वदर्शनं च गोपयति।';

  @override
  String get helpScreenshotAuditGuardBullet2 =>
      'पटलचित्रम् आदातुम् इच्छसि चेत् विन्यासाः → सुरक्षा इत्यत्र पटलचित्ररोधं परिवर्तय।';

  @override
  String get helpScreenshotAuditSectionLog => 'विकृतिसूचकः सुरक्षाघटनाभिलेखः';

  @override
  String get helpScreenshotAuditLogBullet1 =>
      'विन्यासाः → सुरक्षा → सुरक्षाघटनाः इत्यत्र PIN-प्रयत्नानां, रोधपरिवर्तनानां, निर्यापणानां च स्थानीयः अभिलेखः तिष्ठति।';

  @override
  String get helpSearchTimelineIntro =>
      'SQLite पूर्णपाठान्वेषणेन सक्रियया पञ्चाङ्गकालरेखया च क्षणेषु पूर्वस्मृतीः प्राप्नुहि।';

  @override
  String get helpSearchTimelineSectionFts => 'SQLite पूर्णपाठान्वेषणम् (FTS)';

  @override
  String get helpSearchTimelineFtsBullet1 =>
      'लेखनसमये एव सर्वासु प्रविष्टिषु शीर्षकेषु चिह्नेषु च तत्क्षणम् अन्विष्य।';

  @override
  String get helpSearchTimelineSectionPresets => 'रक्षिताः अन्वेषणविन्यासाः';

  @override
  String get helpSearchTimelinePresetsBullet1 =>
      'बहुप्रयुक्तानि छाननसंयोजनानि एकस्पर्शयोग्यरूपेण रक्ष।';

  @override
  String get helpSearchTimelineSectionTimeline => 'पञ्चाङ्गं कालरेखा च';

  @override
  String get helpSearchTimelineTimelineBullet1 =>
      'पञ्चाङ्गदिनानुसारं प्रविष्टीः पश्य, मासान् सञ्चर, दिनशः क्रमसूचीः च पश्य।';

  @override
  String get helpStorageMigrationIntro =>
      'कूटलिखितानि संलग्नानि कुत्र तिष्ठन्ति इति प्रबन्धय, आन्तरिकस्मृतेः SD-पत्रं प्रति च स्थानान्तरय।';

  @override
  String get helpStorageMigrationSectionInternal =>
      'आन्तरिकः अनुप्रयोगस्वकीयः संग्रहः';

  @override
  String get helpStorageMigrationInternalBullet1 =>
      'सामान्यतः कूटलिखितानि संलग्नानि अनुप्रयोगस्वकीये आन्तरिककोशे तिष्ठन्ति, Android-प्रणाल्याः रक्षया च रक्ष्यन्ते।';

  @override
  String get helpStorageMigrationSectionSd =>
      'SD-पत्रसंग्रहः सक्रियस्थानान्तरणं च';

  @override
  String get helpStorageMigrationSdBullet1 =>
      'आन्तरिकस्मृतिं मुक्तां कर्तुं विन्यासाः → संग्रहः → संग्रहं स्थानान्तरय इत्यत्र माध्यमसञ्चिकाः SD-पत्रं प्रति नय।';

  @override
  String get helpStorageMigrationSdBullet2 =>
      'SD-पत्रे अपि सर्वाः सञ्चिकाः पूर्णतया AES-256-GCM कूटलिखिताः तिष्ठन्ति।';

  @override
  String get helpTagsIntro =>
      'स्वकीयैः वर्णयुक्तैः चिह्नैः सर्वासु दैनन्दिनीषु प्रविष्टीः वर्गीकुरु व्यवस्थापय च।';

  @override
  String get helpTagsSectionTagging => 'प्रविष्टिषु दैनन्दिनीषु च चिह्नयोजनम्';

  @override
  String get helpTagsTaggingBullet1 =>
      'सम्पादकस्य उपरितनचिह्नपट्ट्या कस्यामपि प्रविष्टौ चिह्नानि योजय।';

  @override
  String get helpTagsSectionColors => 'स्वकीयः वर्णसङ्केतः';

  @override
  String get helpTagsColorsBullet1 =>
      'विषयान् सुखेन भेदयितुं चिह्नेभ्यः पृथग्वर्णान् देहि।';

  @override
  String get helpTagsSectionCleanup => 'चिह्नप्रबन्धनं मार्जनं च';

  @override
  String get helpTagsCleanupBullet1 =>
      'विन्यासाः → चिह्नप्रबन्धकः इत्यत्र चिह्नानां नाम वर्णं वा परिवर्तय, अप्रयुक्तानि वा लोपय।';

  @override
  String get titleTamperAlerts => 'विकृतिसूचनाः';

  @override
  String get titleTamperAlertsHowItWorks => 'विकृतिज्ञानं कथं भवति';

  @override
  String get bodyTamperAlertsHowItWorks =>
      'SreerajP Journal Vault संरचनासामञ्जस्यं, कालक्रमाङ्कान्, AES-256 कूटलिखितान् अभिलेखांश्च निरन्तरं परीक्षते।';

  @override
  String get bodyTamperAlertsNoHistory =>
      'विकृतिसूचनाः न अभिलिखिताः। तव कोशप्रविष्टयः सुरक्षिताः।';

  @override
  String get titleTamperAlertsHistory => 'विकृतिसूचनेतिहासः';

  @override
  String get bodyTamperAlertsScanCompleteClean =>
      'कोशपरीक्षा सम्पन्ना: सर्वाः प्रविष्टयः शुद्धाः।';

  @override
  String bodyTamperAlertsScanCompleteIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'परीक्षया $count त्रुटयः लब्धाः।',
      one: 'परीक्षया एका त्रुटिः लब्धा।',
    );
    return '$_temp0';
  }

  @override
  String get bodyTamperAlertsStatusIssues =>
      'सावधानम् — सामञ्जस्यत्रुटयः ज्ञाताः';

  @override
  String bodyTamperAlertsStatusIssuesDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अभिलेखेषु $count दत्तांशत्रुटयः ज्ञाताः।',
      one: 'अभिलेखेषु एका दत्तांशत्रुटिः ज्ञाता।',
    );
    return '$_temp0';
  }

  @override
  String get bodyTamperAlertsStatusVerified => 'कोशसामञ्जस्यं सत्यापितम्';

  @override
  String get descTamperAlertsStatusVerifiedDetail =>
      'सर्वाः दत्तकोशसारण्यः कूटलेखनमुद्राश्च सफलतया सत्यापिताः।';

  @override
  String get actionTamperAlertsVerify => 'कोशसामञ्जस्यं सत्यापय';

  @override
  String get bodyTamperAlertsVerifying => 'कोशसामञ्जस्यं सत्याप्यते...';

  @override
  String get titleShareQuickCapture => 'शीघ्रग्रहणम्';

  @override
  String get descShareQuickCapture => 'आगतं विषयं नूतनप्रविष्टिरूपेण रक्ष';

  @override
  String get bodyShareNoJournalsFound =>
      'दैनन्दिन्यः न लब्धाः। प्रथमं दैनन्दिनीं रचय।';

  @override
  String get labelShareSelectJournal => 'दैनन्दिनीं वृणु';

  @override
  String get labelShareEntryTitle => 'प्रविष्टिशीर्षकम्';

  @override
  String get descShareEntryTitle => 'शीर्षकं लिख (ऐच्छिकम्)';

  @override
  String get labelShareContent => 'विषयः';

  @override
  String get descShareContent => 'सामायिता टिप्पणी, उद्धरणम्, संयोजकं वा...';

  @override
  String labelShareAttachments(int count) {
    return 'संलग्नानि ($count)';
  }

  @override
  String get actionShareDiscard => 'त्यज';

  @override
  String get actionShareOpenInEditor => 'सम्पादके उद्घाटय';

  @override
  String get actionShareSaveToJournal => 'दैनन्दिन्यां रक्ष';

  @override
  String get errorShareSave => 'सामायिता टिप्पणी रक्षितुं न शक्ता।';

  @override
  String bodyShareSavedSuccess(String journalTitle) {
    return 'सामायिता टिप्पणी \"$journalTitle\" इत्यत्र रक्षिता';
  }

  @override
  String get titleShareSealedFileDetected => 'कूटलिखिता सञ्चिका ज्ञाता';

  @override
  String get actionShareOpenEncryptedExport => 'कूटलिखितां सञ्चिकाम् उद्घाटय';

  @override
  String get labelTemplateCategoryCustom => 'मम प्रारूपाणि';

  @override
  String get actionTemplateCollapseAll => 'सर्वं संकोचय';

  @override
  String get actionTemplateExpandAll => 'सर्वं विस्तारय';

  @override
  String get actionTemplateCreateNew => 'नूतनं प्रतिरूपम्';

  @override
  String get titleTemplateManager => 'स्वकीयानि प्रतिरूपाणि';

  @override
  String get actionTemplateEdit => 'प्रतिरूपं सम्पादय';

  @override
  String get actionTemplateDelete => 'प्रतिरूपं लोपय';

  @override
  String get bodyTemplateDeleteConfirm => 'प्रतिरूपं लोपयितव्यम् किम्?';

  @override
  String bodyTemplateDeleteConfirmMessage(String name) {
    return '\"$name\" इति लोपयितव्यम् किम्? एषा क्रिया न प्रत्यावर्तते।';
  }

  @override
  String get bodyTemplateDeleteSuccess => 'प्रतिरूपं लोपितम्';

  @override
  String get emptyTemplate =>
      'अद्यापि स्वकीयानि प्रतिरूपाणि न सन्ति। प्रियां लेखनसंरचनां पुनःप्रयोक्तुम् एकं रचय।';

  @override
  String get labelTemplateName => 'प्रतिरूपनाम';

  @override
  String get descTemplateName => 'यथा: दैनिकसभा, व्यायामटिप्पणी';

  @override
  String get errorTemplateName => 'प्रतिरूपस्य नाम लिख।';

  @override
  String get labelTemplateDescription => 'विवरणम्';

  @override
  String get descTemplateDescription => 'इदं प्रतिरूपं किमर्थम् इति संक्षेपः';

  @override
  String get labelTemplateDefaultTitle => 'प्रविष्टेः मूलशीर्षकम्';

  @override
  String get descTemplateDefaultTitle => 'यथा: दैनिकसभा - अद्य';

  @override
  String get labelTemplateContent => 'आरम्भविषयः';

  @override
  String get descTemplateContent => 'तव आरम्भप्रश्नं रूपरेखां वा लिख...';

  @override
  String get titleTemplateTokens => 'गतिशीलदिनाङ्कसङ्केताः';

  @override
  String get descTemplateTokensHelper =>
      'नूतनप्रविष्टिरचनाकाले गतिशीलदिनाङ्कसङ्केताः स्वयमेव पूर्यन्ते।';

  @override
  String get bodyTemplateSaveSuccess => 'प्रतिरूपं रक्षितम्';

  @override
  String get actionTemplateSaveAsTemplate => 'प्रतिरूपरूपेण रक्ष';

  @override
  String get titleTemplateSaveAsTemplate => 'नूतनं प्रतिरूपम्';

  @override
  String get descTemplateSaveAsTemplate =>
      'अस्याः प्रविष्टेः संरचनां पुनःप्रयोज्यप्रतिरूपरूपेण रक्ष।';

  @override
  String get titleSettingsSectionHelp => 'साहाय्यम्';

  @override
  String get descSettingsSectionHelp =>
      'मार्गदर्शिकाः, कूटलेखनविवरणम्, प्रश्नाः';

  @override
  String get titleSettingsSectionFeatures => 'विशेषताः';

  @override
  String get descSettingsSectionFeatures =>
      'सर्वाः विशेषताः सुरक्षासाधनानि च पश्य';

  @override
  String get titleFeaturesHeader => 'SreerajP Journal Vault विशेषताः';

  @override
  String get descFeaturesHeader =>
      'निःस्रावा जालरहिता संरचना, दृढं कूटलेखनम्, भावपूर्णं लेखनं च।';

  @override
  String descEntryWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पदानि',
      one: '1 पदम्',
    );
    return '$_temp0';
  }

  @override
  String descEntryCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अक्षराणि',
      one: '1 अक्षरम्',
    );
    return '$_temp0';
  }

  @override
  String descEntryStats(String words, String chars) {
    return '$words • $chars';
  }

  @override
  String get actionEntryDistractionFreeEnter => 'एकाग्रलेखनप्रकारः';

  @override
  String get actionEntryDistractionFreeExit => 'एकाग्रलेखनप्रकारात् निर्गम';

  @override
  String get descEntryFocusParagraphOn => 'अनुच्छेदैकाग्र्यम्: सक्रियम्';

  @override
  String get descEntryFocusParagraphOff => 'अनुच्छेदैकाग्र्यम्: निष्क्रियम्';

  @override
  String get labelEntryAutoSaving => 'रक्ष्यते…';

  @override
  String labelEntryAutoSaved(String time) {
    return '$time वादने रक्षितम्';
  }

  @override
  String get labelEntryAutoSavedJustNow => 'इदानीमेव रक्षितम्';

  @override
  String get labelEntryUnsavedChanges => 'अरक्षितानि परिवर्तनानि';

  @override
  String get tooltipEntryEditorScanText => 'चित्रात् पाठं गृहाण';

  @override
  String get labelEntryEditorScanSourceCamera => 'चित्रं गृहाण';

  @override
  String get labelEntryEditorScanSourceGallery => 'चित्रशालातः वृणु';

  @override
  String get descEntryEditorOcrScanning => 'चित्रात् पाठः गृह्यते...';

  @override
  String get descEntryEditorOcrNoTextFound => 'चित्रे कोऽपि पाठः न लब्धः।';

  @override
  String get errorEntryEditorOcr => 'चित्रात् पाठम् आदातुं न शक्तम्।';

  @override
  String get titleEntryEditorCropImage => 'चित्रं कर्तय';

  @override
  String get errorEntryEditorCropImage => 'चित्रकर्तनं कर्तुं न शक्तम्।';

  @override
  String get titleAppearanceThemeMode => 'वर्णविन्यासप्रकारः';

  @override
  String get descAppearanceThemeMode => 'प्रणाली, अन्धकारः, प्रकाशः इति वृणु';

  @override
  String get titleAppearanceAccentColor => 'मुख्यवर्णः';

  @override
  String get descAppearanceAccentColor => 'मुख्यवर्णसमूहं वृणु';

  @override
  String get titleAppearanceLivePreview => 'सजीवं पूर्वावलोकनम्';

  @override
  String get tabAppearancePresets => 'सिद्धविन्यासाः';

  @override
  String get tabAppearanceCustomWheel => 'स्वकीयवर्णचक्रम्';

  @override
  String get labelAppearanceSampleText => 'उदाहरणप्रविष्टिः';

  @override
  String get actionAppearanceResetDefault => 'मूलरूपं पुनः स्थापय';

  @override
  String get descAppearanceContrastNote =>
      'पठनसौकर्याय पाठवैषम्यं स्वयमेव समायोज्यते।';

  @override
  String get descAppearanceSystemModeExplainer =>
      'प्रणालीप्रकारः तव उपकरणस्य अन्धकारविन्यासम् अनुसरति।';

  @override
  String get labelSettingsThemeSepia => 'पत्रवर्णः';

  @override
  String get labelSettingsThemeOled => 'OLED / शुद्धकृष्णः';

  @override
  String get descSettingsThemeSepia => 'दीर्घलेखनाय सुखदः उष्णपत्रवर्णः।';

  @override
  String get descSettingsThemeOled =>
      'AMOLED-शक्तिरक्षणाय शुद्धकृष्णपृष्ठं तीक्ष्णवैषम्यं च।';

  @override
  String get descSettingsThemeLight => 'स्वच्छं दीप्तं दिवसपठनपृष्ठम्।';

  @override
  String get descSettingsThemeDark => 'अल्पप्रकाशे लेखनाय मृदुः कृष्णपृष्ठः।';

  @override
  String get descSettingsThemeSystem =>
      'तव उपकरणस्य प्रकाशविन्यासं स्वयमेव अनुसरति।';

  @override
  String get titleAppearanceTypography => 'पठनाक्षरविन्यासः';

  @override
  String get descAppearanceTypography => 'मुख्यपाठस्य अक्षरकुलं परिमाणं च वृणु';

  @override
  String get titleAppearanceFontFamily => 'मुख्यपाठाक्षरकुलम्';

  @override
  String get titleAppearanceFontSize => 'मुख्यपाठपरिमाणम्';

  @override
  String get labelAppearanceFontFamilySans => 'Sans-Serif';

  @override
  String get descAppearanceFontFamilySans => 'स्वच्छम् आधुनिकम् अक्षररूपम्';

  @override
  String get labelAppearanceFontFamilySerif => 'ग्रन्थाक्षराणि';

  @override
  String get descAppearanceFontFamilySerif => 'शास्त्रीयं ग्रन्थसदृशं रूपम्';

  @override
  String get labelAppearanceFontFamilyMonospace => 'समानविस्तारम्';

  @override
  String get descAppearanceFontFamilyMonospace =>
      'समानविस्तारं टङ्कयन्त्रसदृशं Markdown-रूपम्';

  @override
  String get labelAppearanceFontSizeSmall => 'लघु';

  @override
  String get labelAppearanceFontSizeDefault => 'मूलम्';

  @override
  String get labelAppearanceFontSizeMedium => 'मध्यम';

  @override
  String get labelAppearanceFontSizeLarge => 'बृहत्';

  @override
  String get labelAppearanceFontSizeExtraLarge => 'अतिबृहत्';

  @override
  String get labelAppearanceSampleHeadline => 'शान्तचिन्तनानि';

  @override
  String get bodyAppearanceSample =>
      'दैनन्दिनी शान्तं स्थानम्, यत्र मन्दं गत्वा चिन्तनं शक्यते। प्रत्येकं चिन्तनं स्मृतिः रेखाचित्रं च तव गुप्तकोशे सुरक्षितं तिष्ठति।';

  @override
  String get bodyAppearanceTypographyReset =>
      'अक्षरविन्यासः मूलरूपं प्रति स्थापितः।';

  @override
  String get helpHeaderTitle => 'साहाय्यकेन्द्रं ज्ञानकोशश्च';

  @override
  String get helpHeaderSubtitle =>
      'पूर्णं जालरहितं लेखनम्, कूटलेखनविवरणम्, शीघ्रोत्तराणि च।';

  @override
  String get helpSectionWriting => 'लेखनं दैनन्दिनीप्रबन्धनं च';

  @override
  String get helpSectionSecurity => 'सुरक्षा, रोधः, कूटलेखनम्';

  @override
  String get helpSectionSearch => 'अन्वेषणम्, कालरेखा, अवलोकनानि';

  @override
  String get helpSectionStorage => 'संग्रहः, प्रतिलिपयः, निर्यापणम्';

  @override
  String get helpSectionFaq => 'बहुपृष्टाः प्रश्नाः';

  @override
  String get tooltipEditorInsertDrawing => 'रेखाचित्रपटलम्';

  @override
  String get titleDrawingCanvas => 'रेखाचित्रम्';

  @override
  String get titleDrawingCanvasEdit => 'रेखाचित्रं सम्पादय';

  @override
  String get labelDrawingCanvasPen => 'लेखनी';

  @override
  String get labelDrawingCanvasHighlighter => 'उद्दीपिका';

  @override
  String get labelDrawingCanvasEraser => 'मार्जनी';

  @override
  String get actionDrawingCanvasClear => 'पटलं मार्जय';

  @override
  String get bodyDrawingCanvasClear => 'समग्रं रेखाचित्रं मार्जयितव्यम् किम्?';

  @override
  String get labelDrawingCanvasStrokeWidth => 'रेखास्थौल्यम्';

  @override
  String get labelDrawingCanvasBackground => 'पृष्ठभूमिः';

  @override
  String get labelDrawingCanvasBgBlank => 'रिक्ता';

  @override
  String get labelDrawingCanvasBgRuled => 'रेखायुक्ता';

  @override
  String get labelDrawingCanvasBgGrid => 'जालिका';

  @override
  String get labelDrawingCanvasBgDots => 'बिन्दवः';

  @override
  String get actionDrawingCanvasUndo => 'प्रत्यावर्तय';

  @override
  String get actionDrawingCanvasRedo => 'पुनः कुरु';

  @override
  String get actionDrawingCanvasSave => 'रेखाचित्रं रक्ष';

  @override
  String get bodyDrawingCanvasDiscard => 'परिवर्तनानि त्यक्तव्यानि किम्?';

  @override
  String get bodyDrawingCanvasDiscardMessage =>
      'रेखाचित्रस्य परिवर्तनानि त्यक्तव्यानि किम्?';

  @override
  String get tooltipDrawingEdit => 'रेखाचित्रं सम्पादय';

  @override
  String get tooltipDrawingSize => 'रेखाचित्रपरिमाणं परिवर्तय';

  @override
  String get tooltipDrawingDelete => 'रेखाचित्रं लोपय';

  @override
  String get descDrawingUnavailable => 'रेखाचित्रं न लभ्यते';

  @override
  String get descDrawingLoading => 'रेखाचित्रम् आरोप्यते…';

  @override
  String get errorDrawingSave => 'रेखाचित्रं रक्षितुं न शक्तम्।';

  @override
  String get actionJournalManageTemplates => 'स्वकीयानि प्रतिरूपाणि';

  @override
  String get helpTitle => 'साहाय्यम्';

  @override
  String get titleFeatures => 'विशेषताः';

  @override
  String get bodyFeatureOffline => 'पूर्णं जालरहितम्, जालानुमतिः न';

  @override
  String get descFeatureOffline =>
      'अनुप्रयोगे जालप्रवेशसङ्केतः नास्ति, अन्तर्जालानुमतिः न प्रार्थ्यते, सर्वः दैनन्दिनीदत्तांशः संलग्नानि कूटलेखनं च जालरहितं तिष्ठति।';

  @override
  String get titleRitual => 'अनुष्ठानाभ्यासः';

  @override
  String get titleRitualDeckBrowser => 'चिन्तनपत्रसमूहः';

  @override
  String get tooltipRitualResetReviews => 'पुनरावृत्तिक्रमं पुनः स्थापय';

  @override
  String get titleRitualResetReviews => 'सर्वपत्राणां पुनरावलोकनं पुनः स्थापय';

  @override
  String get bodyRitualResetReviews =>
      'एतेन सर्वेषां पत्राणां पुनरावलोकनस्तराः दिनाङ्काश्च पुनः स्थाप्यन्ते। अनुवर्तताम् किम्?';

  @override
  String get bodyRitualResetReviewsDone => 'पत्रपुनरावलोकनक्रमः पुनः स्थापितः।';

  @override
  String get labelRitualAllThemes => 'सर्वे विषयाः';

  @override
  String get labelRitualSrsNew => 'नूतनम्';

  @override
  String get labelRitualSrsDueToday => 'अद्य देयम्';

  @override
  String labelRitualSrsInDays(int days) {
    return '$days दिनेषु';
  }

  @override
  String get labelRitualStepBreathe => 'श्वसनम्';

  @override
  String get labelRitualStepReflect => 'चिन्तनम्';

  @override
  String get labelRitualStepWrite => 'लेखनम्';

  @override
  String get titleRitualBreathe => 'केन्द्रीकरणश्वासः';

  @override
  String get actionRitualSkipToPrompt => 'प्रश्नं प्रति गच्छ';

  @override
  String get actionRitualContinueToCard => 'अनुवर्तय';

  @override
  String get actionRitualShuffleCard => 'मिश्रय';

  @override
  String get bodyRitualSrsRatePrompt =>
      'इदं चिन्तनं कियत् सुलभं स्मरणीयं च आसीत्?';

  @override
  String get actionRitualSrsHard => 'कठिनम्';

  @override
  String get descRitualSrsHard => '1 दिने पुनः';

  @override
  String get actionRitualSrsRevision => 'पुनरावृत्तिः';

  @override
  String get descRitualSrsRevision => '3 दिनेषु पुनः';

  @override
  String get actionRitualSrsEasy => 'सुलभम्';

  @override
  String get descRitualSrsEasy => '+7 दिनानि';

  @override
  String get actionRitualProceedToJournal => 'दैनन्दिनीं प्रति गच्छ';

  @override
  String get titleRitualReadyToWrite => 'चिन्तनाय सज्जः';

  @override
  String descRitualReadyToWrite(String cardTitle) {
    return '\"$cardTitle\" इत्यनेन प्रेरितः अद्यतनप्रविष्टौ तव चिन्तनानि लिख।';
  }

  @override
  String get actionRitualBeginWriting => 'लेखनम् आरभस्व';

  @override
  String get actionRitualCompletePracticeOnly => 'अभ्यासमेव समापय';

  @override
  String get titleRitualSettings => 'अनुष्ठानप्रकारविन्यासाः';

  @override
  String get titleRitualLaunchOnStartup => 'अनुष्ठानप्रकारे उद्घाटय';

  @override
  String get descRitualLaunchOnStartup =>
      'प्रतिसत्रं मार्गदर्शितेन श्वासेन चिन्तनप्रश्नेन च आरभस्व';

  @override
  String get labelRitualBreathTechnique => 'श्वसनरीतिः';

  @override
  String labelRitualBreathCycles(int count) {
    return 'श्वसनचक्राणि: $count';
  }

  @override
  String get actionCommonReset => 'पुनः स्थापय';

  @override
  String get titleRitualSettingsTile => 'अनुष्ठानप्रकारः चिन्तनं च';

  @override
  String get descRitualSettingsTile =>
      'मार्गदर्शितः श्वासकालः, 50-पत्राणि सनातनधर्मपत्राणि, अन्तरालपुनरावृत्तिः च';

  @override
  String get titleFeatureRitual => 'अनुष्ठानप्रकारः चिन्तनपत्राणि च';

  @override
  String get descFeatureRitual =>
      'श्वासकालेन मनः शान्तं कुर्वन्, अन्तरालपुनरावृत्त्या चिन्तनपत्राणि दर्शयन्, अद्यतनप्रविष्टिं च साक्षात् उद्घाटयन् दैनिकः मार्गदर्शितः अभ्यासः।';

  @override
  String get titleSyncLanding => 'उपकरणद्वययोः समन्वयः';

  @override
  String get descSyncLanding =>
      'मेघसेवकान् विना स्थानीयेन Wi-Fi-माध्यमेन प्रविष्टीः संलग्नानि च साक्षात् समन्वय';

  @override
  String get titleSyncSend => 'परिवर्तनानि प्रेषय (आतिथेयः)';

  @override
  String get descSyncSend =>
      'अन्येन उपकरणेन सह प्रविष्टीः संलग्नानि च वितरितुं युग्मन-QR दर्शय';

  @override
  String get titleSyncReceive => 'परिवर्तनानि गृहाण (ग्राहकः)';

  @override
  String get descSyncReceive =>
      'नवीकरणानि आदातुं युग्मन-QR अवलोकय अथवा संयोगविवरणं लिख';

  @override
  String get titleSyncHost => 'Wi-Fi समन्वयस्य आतिथ्यम्';

  @override
  String get titleSyncClient => 'Wi-Fi समन्वयं गृहाण';

  @override
  String get tabSyncTabQrScan => 'QR अवलोकय';

  @override
  String get tabSyncTabManualEntry => 'हस्तेन विवरणम्';

  @override
  String get labelSyncIp => 'स्थानीयः IP-सङ्केतः';

  @override
  String get labelSyncPort => 'द्वारसङ्ख्या';

  @override
  String get labelSyncPairingCode => 'युग्मसङ्केतः';

  @override
  String get labelSyncPairingCodeHint => 'XXXX-XXXX-XXXX-XXXX';

  @override
  String get descSyncStatusListening => 'आगमिष्यतः संयोगस्य प्रतीक्षा...';

  @override
  String get labelSyncStatusConnected => 'उपकरणं संयुक्तं प्रमाणीकृतं च';

  @override
  String get descSyncStatusCompleted => 'समन्वयः सफलतया सम्पन्नः!';

  @override
  String get errorSyncStatusDenied => 'संयोगः निषिद्धः: युग्मसङ्केतः अशुद्धः';

  @override
  String get labelSyncStatusStopped => 'समन्वयसेवकः स्थगितः';

  @override
  String get errorSyncStatusError => 'समन्वयसेवकदोषः';

  @override
  String get actionSyncButtonStart => 'सेवकम् आरभ';

  @override
  String get actionSyncButtonStop => 'सेवकं स्थगय';

  @override
  String get actionSyncButtonConnect => 'संयोज्य समन्वय';

  @override
  String get descSyncScanInstructions =>
      'प्रेषकोपकरणे स्थितं युग्मन-QR प्रति छायायन्त्रं नय';

  @override
  String get descSyncHostAddress => 'यथा 192.168.1.5';

  @override
  String get descSyncPort => 'यथा 54321';

  @override
  String get descSyncCode => 'षोडशाक्षरः युग्मसङ्केतः';

  @override
  String get descSyncNoWifiAlert =>
      'Wi-Fi / LAN सङ्केतः न लब्धः। उभे अपि उपकरणे एकस्मिन् एव Wi-Fi-जाले भवेताम् इति सुनिश्चिनु।';

  @override
  String get bodySyncPairingCodeCopied =>
      'युग्मसङ्केतः प्रतिलिपिपट्टे स्थापितः';

  @override
  String get titleAirqr => 'प्रकाशमाध्यमेन समन्वयः (AirQR)';

  @override
  String get descAirqrIntro =>
      'जालसंयोगं विना चलत्-QR-सङ्केतैः प्रकाशद्वारा विन्यासान्, लघुदैनन्दिनीः, प्रविष्टीश्च समन्वय।';

  @override
  String get titleAirqrSend => 'AirQR-द्वारा प्रेषय';

  @override
  String get titleAirqrReceive => 'AirQR-द्वारा गृहाण';

  @override
  String get actionAirqrReceive => 'दत्तांशं गृहाण (अवलोककः)';

  @override
  String get descAirqrReceive => 'अन्यस्मात् उपकरणात् चलत्-QR-खण्डान् अवलोकय';

  @override
  String get titleAirqrSyncSettings => 'अनुप्रयोगविन्यासान् समन्वय';

  @override
  String get descAirqrSyncSettings =>
      'वर्णविन्यासः, मुख्यवर्णः, सुरक्षा, अनुष्ठानं प्रतिरूपाणि च (क्षणात् न्यूनम्)';

  @override
  String get titleAirqrSyncJournal => 'एकां दैनन्दिनीं समन्वय';

  @override
  String get descAirqrSyncJournal =>
      'पाठप्रविष्टिसहितां दैनन्दिनीं वृत्वा प्रेषय';

  @override
  String get titleAirqrTooLarge => 'दत्तांशः अतिबृहत्';

  @override
  String get titleAirqrSlow => 'बृहत् प्रकाशप्रेषणम्';

  @override
  String get actionAirqrSendAnyway => 'तथापि प्रेषय';

  @override
  String get titleAirqrSpeedNote => 'पूर्णं जालरहितं गुप्तं च';

  @override
  String get bodyAirqrSpeedNote =>
      'AirQR केवलं छायायन्त्रेण पटलेन च कार्यं करोति। Wi-Fi, Bluetooth, अन्तर्जालं वा न अपेक्ष्यते।';

  @override
  String get actionTimeCapsuleActionSeal => 'कालपेटिकारूपेण मुद्रय';

  @override
  String get titleTimeCapsuleSeal => 'कालपेटिकारूपेण मुद्रय';

  @override
  String get descTimeCapsuleSeal =>
      'एषा प्रविष्टिः भाविदिनं यावत् कूटलेखनेन मुद्र्यते। तस्मिन् दिने प्राप्ते एव उद्घाटनकुञ्जिका मुच्यते।';

  @override
  String get labelTimeCapsuleUnlockDate => 'उद्घाटनदिनाङ्कः';

  @override
  String get descTimeCapsuleTeaser => 'भाविने स्वस्मै टिप्पणी (ऐच्छिकी)';

  @override
  String get actionTimeCapsulePreset1Month => '1 मासः';

  @override
  String get actionTimeCapsulePreset6Months => '6 मासाः';

  @override
  String get actionTimeCapsulePreset1Year => '1 वर्षम्';

  @override
  String get actionTimeCapsulePreset3Years => '3 वर्षाणि';

  @override
  String get actionTimeCapsulePreset5Years => '5 वर्षाणि';

  @override
  String get actionTimeCapsulePresetCustom => 'स्वकीयः दिनाङ्कः';

  @override
  String get bodyTimeCapsuleSeal => 'पेटिकां मुद्रय';

  @override
  String get labelTimeCapsuleSealedBadge => 'मुद्रिता कालपेटिका';

  @override
  String labelTimeCapsuleSealedUntil(String date) {
    return '$date यावत् मुद्रिता';
  }

  @override
  String labelTimeCapsuleOpensInDays(int days) {
    return '$days दिनेषु उद्घाट्यते';
  }

  @override
  String labelTimeCapsuleOpensInHours(int hours) {
    return '$hours होरासु उद्घाट्यते';
  }

  @override
  String get descTimeCapsuleOpensToday => 'अद्य उद्घाट्यते!';

  @override
  String get actionTimeCapsuleReadyToOpen => 'उद्घाटनाय सज्जा';

  @override
  String get descTimeCapsuleLocked =>
      'इयं प्रविष्टिः AES-256-GCM द्वारा मुद्रिता। उद्घाटनदिनं यावत् अनुप्रयोगः उद्घाटनकुञ्जिकां न मुञ्चति।';

  @override
  String get actionTimeCapsuleUnseal => 'कालपेटिकाम् उद्घाटय';

  @override
  String actionTimeCapsuleUnsealLockedPrompt(String date) {
    return '$date यावत् रुद्धा';
  }

  @override
  String bodyTimeCapsuleSealedSuccess(String date) {
    return 'प्रविष्टिः $date यावत् कालपेटिकायां मुद्रिता।';
  }

  @override
  String get bodyTimeCapsuleUnsealedSuccess =>
      'कालपेटिका उद्घाटिता! स्वकीयेषु पदेषु पुनः स्वागतम्।';

  @override
  String get errorTimeCapsuleClockTamper =>
      'उपकरणस्य कालः पश्चात् नीतः इति ज्ञातम्। मुद्रणसमयात् पूर्वं उपकरणकाले सति पेटिका उद्घाटयितुं न शक्यते।';

  @override
  String get titleTimeCapsule => 'कालपेटिकाः';

  @override
  String get descTimeCapsule =>
      'भाविने स्वस्मै मुद्रितानि पत्राणि प्रविष्टयश्च';

  @override
  String get emptyTimeCapsule =>
      'अद्यापि कालपेटिकाः न सन्ति। प्रविष्टिं रचयित्वा भाविने स्वस्मै मुद्रय।';

  @override
  String get bodyTimeCapsuleBanner => 'कालपेटिका सज्जा!';

  @override
  String bodyTimeCapsuleBannerBody(int count) {
    return 'अद्य उद्घाटनाय $count मुद्रिता पेटिका सज्जा।';
  }

  @override
  String descTimeCapsuleBannerBodyPlural(int count) {
    return 'अद्य उद्घाटनाय $count मुद्रिताः पेटिकाः सज्जाः।';
  }

  @override
  String get titleTimeCapsuleCategorySealed => 'मुद्रिताः पेटिकाः';

  @override
  String get titleTimeCapsuleCategoryReady => 'उद्घाटनाय सज्जाः';

  @override
  String get titleTimeCapsuleCategoryOpened => 'उद्घाटिताः पेटिकाः';

  @override
  String get titleRitualCreateCard => 'पत्रं रचय';

  @override
  String get titleRitualEditCard => 'पत्रं सम्पादय';

  @override
  String get actionRitualCreateCard => 'नूतनं पत्रम्';

  @override
  String get labelRitualCardTheme => 'विषयः';

  @override
  String get labelRitualCardTitle => 'शीर्षकम्';

  @override
  String get descRitualCardTitle => 'यथा: आत्मज्ञानस्य प्रकाशः';

  @override
  String get errorRitualCardTitle => 'शीर्षकम् आवश्यकम्।';

  @override
  String get labelRitualCardPrompt => 'चिन्तनप्रश्नः';

  @override
  String get descRitualCardPrompt => 'अभ्यासकाले चिन्तनीयः प्रश्नः...';

  @override
  String get errorRitualCardPrompt => 'चिन्तनप्रश्नः आवश्यकः।';

  @override
  String get labelRitualCardQuote => 'उपदेशः उद्धरणं वा';

  @override
  String get descRitualCardQuote => 'श्लोकः, सुभाषितम्, उपदेशः वा...';

  @override
  String get errorRitualCardQuote => 'उपदेशः उद्धरणं वा आवश्यकम्।';

  @override
  String get labelRitualCardAuthor => 'स्रोतः (ऐच्छिकः)';

  @override
  String get descRitualCardAuthor => 'यथा: भगवद्गीता 2.47';

  @override
  String get labelRitualCardPreview => 'पूर्वावलोकनम्';

  @override
  String get actionRitualSaveCardCreate => 'पत्रं रचय';

  @override
  String get actionRitualSaveCardEdit => 'परिवर्तनानि रक्ष';

  @override
  String get bodyRitualCardCreated => 'पत्रं रचितम्।';

  @override
  String get bodyRitualCardUpdated => 'पत्रं नवीकृतम्।';

  @override
  String get errorRitualCardSave => 'पत्रं रक्षितुं न शक्तम्। पुनः यततु।';

  @override
  String get labelRitualUserCardBadge => 'मम पत्रम्';

  @override
  String get actionRitualEditCard => 'सम्पादय';

  @override
  String get actionRitualDeleteCard => 'लोपय';

  @override
  String get titleRitualDeleteCard => 'पत्रं लोपय';

  @override
  String bodyRitualDeleteCard(String title) {
    return '\"$title\" इति लोपयितव्यम् किम्? एतत् न प्रत्यावर्तते।';
  }

  @override
  String get bodyRitualCardDeleted => 'पत्रं लोपितम्।';

  @override
  String get errorRitualNoJournal => 'प्रथमं दैनन्दिनीं रचय।';

  @override
  String get actionEditorGotoLineStart => '⇤';

  @override
  String get actionEditorGotoLineEnd => '⇥';

  @override
  String get bodyOcrCameraPermissionDenied =>
      'पाठज्ञानाय लेखपत्राणां चित्रग्रहणे छायायन्त्रानुमतिः आवश्यका।';

  @override
  String get actionOcrCameraOpenSettings => 'विन्यासान् उद्घाटय';

  @override
  String get bodyOcrCameraNoCameras => 'अस्मिन् उपकरणे छायायन्त्रं न लब्धम्।';

  @override
  String get tooltipOcrCameraFlashOff => 'दीपः निष्क्रियः';

  @override
  String get tooltipOcrCameraFlashAuto => 'दीपः स्वयंचालितः';

  @override
  String get tooltipOcrCameraFlashOn => 'दीपः सक्रियः';

  @override
  String get tooltipOcrCameraFlashTorch => 'प्रदीपः सक्रियः';

  @override
  String get tooltipOcrCameraGridToggle => 'रचनाजालिका';

  @override
  String get tooltipOcrCameraSwitch => 'छायायन्त्रं परिवर्तय';

  @override
  String get descOcrCameraCapture =>
      'केन्द्रीकरणाय स्पृश • आवर्धनाय अङ्गुलिभ्यां कर्षय';

  @override
  String get actionOcrCameraCapture => 'चित्रं गृहाण';

  @override
  String get actionOcrCameraGallery => 'चित्रशालातः वृणु';

  @override
  String get labelOcrCameraExposure => 'प्रकाशमात्रा';

  @override
  String get labelOcrCameraZoom => 'आवर्धनम्';

  @override
  String get tooltipOcrCameraFocusAuto => 'स्वयंकेन्द्रीकरणम्';

  @override
  String get tooltipOcrCameraFocusLocked => 'केन्द्रीकरणं रुद्धम्';

  @override
  String get tooltipOcrCameraExposureAuto => 'स्वयंप्रकाशमात्रा';

  @override
  String get tooltipOcrCameraExposureLocked => 'प्रकाशमात्रा रुद्धा';

  @override
  String get tooltipOcrCameraControls => 'छायायन्त्रनियन्त्रणानि';

  @override
  String get actionOcrCameraReset => 'पुनः स्थापय';

  @override
  String get titleOcrEnhance => 'सुधारः अवलोकनं च';

  @override
  String get tooltipOcrEnhanceRotateLeft => 'वामतः भ्रामय';

  @override
  String get tooltipOcrEnhanceRotateRight => 'दक्षिणतः भ्रामय';

  @override
  String get labelOcrEnhanceCrop => 'कर्तनम्';

  @override
  String get tabOcrEnhanceFilter => 'छाननम्';

  @override
  String get actionOcrEnhanceInvert => 'विपर्यय';

  @override
  String get labelOcrEnhanceFilterOriginal => 'मूलम्';

  @override
  String get labelOcrEnhanceFilterDocument => 'लेखपत्रम्';

  @override
  String get labelOcrEnhanceFilterGrayscale => 'धूसरम्';

  @override
  String get actionOcrEnhanceFilterEnhance => 'उच्चवैषम्यम्';

  @override
  String get labelOcrEnhanceBrightness => 'दीप्तिः';

  @override
  String get labelOcrEnhanceContrast => 'वैषम्यम्';

  @override
  String get tabOcrEnhanceAdjust => 'समायोजनम्';

  @override
  String get titleOcrEnhanceLiveText => 'ज्ञातपाठस्य पूर्वावलोकनम्';

  @override
  String get bodyOcrEnhanceLiveTextNone =>
      'अद्यापि पाठः न ज्ञातः। वैषम्यं समायोजय, भ्रामय, निकटं कर्तय वा।';

  @override
  String descOcrEnhanceLiveWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पदानि ज्ञातानि',
      one: '1 पदं ज्ञातम्',
    );
    return '$_temp0';
  }

  @override
  String get actionOcrEnhanceInsertText => 'प्रविष्टौ निवेशय';

  @override
  String get actionOcrEnhanceRetake => 'पुनः गृहाण';

  @override
  String get bodyOcrEnhanceProcessing => 'चित्रं सुधार्यते...';

  @override
  String get bodyOcrEnhanceLiveScanning => 'पाठः ज्ञायते...';

  @override
  String get labelOcrLanguageAll => 'English + മലയാളം';

  @override
  String get labelOcrLanguageMalayalam => 'മലയാളം';

  @override
  String get labelOcrLanguageEnglish => 'English';

  @override
  String get tooltipOcrLanguageSelect => 'OCR-भाषां वृणु';

  @override
  String get titleLanguage => 'भाषा';

  @override
  String get labelLanguageSystemDefault => 'तन्त्रसिद्धम्';

  @override
  String get descLanguageSystemDefault =>
      'दूरवाण्याः भाषाम् अनुसरति। सा भाषा यदि न लभ्यते तर्हि आङ्ग्लभाषा प्रयुज्यते।';

  @override
  String get labelLanguageEnglish => 'English';

  @override
  String get labelLanguageMalayalam => 'മലയാളം';

  @override
  String get labelLanguageSanskrit => 'संस्कृतम्';

  @override
  String labelLanguageCurrent(String language) {
    return 'भाषा: $language';
  }

  @override
  String get aboutDetailAuthor => 'लेखकः';

  @override
  String get aboutDetailEmail => 'विद्युत्पत्रम्';

  @override
  String get aboutDetailLicense => 'अनुज्ञापत्रम्';

  @override
  String get aboutDetailAiUsed => 'प्रयुक्ता कृत्रिमबुद्धिः';

  @override
  String get aboutDetailIdeUsed => 'प्रयुक्तं विकाससाधनम्';

  @override
  String get bodyAboutBuildDateUnavailable => 'निर्माणदिनाङ्कः न लभ्यते';

  @override
  String madeWithLove(String heart) {
    return 'सस्नेहं निर्मितम् $heart भारततः';
  }

  @override
  String get madeWithLoveA11y => 'सस्नेहं निर्मितम् भारततः';

  @override
  String get tooltipFilterEntries => 'टिप्पण्यः परिशोध्यन्ताम्';

  @override
  String get tooltipSaveSearch => 'अन्वेषणं रक्ष्यताम्';

  @override
  String get tooltipResetScanner => 'पुनःसज्जीक्रियताम्';

  @override
  String get tooltipToggleTorch => 'दीपिका परिवर्त्यताम्';

  @override
  String get tooltipSwitchCamera => 'छायाग्राहकं परिवर्त्यताम्';

  @override
  String get tooltipCopyPairingCode => 'युग्मसङ्केतः प्रतिलिख्यताम्';

  @override
  String get tooltipSlower => 'वेगः ह्रास्यताम्';

  @override
  String get tooltipFaster => 'वेगः वर्ध्यताम्';

  @override
  String get tooltipRecordVoiceNote => 'ध्वनिटिप्पणी अभिलिख्यताम्';

  @override
  String get tooltipStopRecording => 'अभिलेखनात् विरम्यताम्';

  @override
  String get tooltipMoreOptions => 'अधिकम्';

  @override
  String get tooltipShowDetails => 'विवरणं दृश्यताम्';

  @override
  String get tooltipRemove => 'अपनीयताम्';

  @override
  String get descRitualCard01Title => 'स्वधर्मः';

  @override
  String get descRitualCard01Prompt =>
      'जीवनस्य अस्मिन् काले त्वया एव पालनीयं विशिष्टं कर्तव्यं किम्? अद्य तत् कथं सम्मानयसि?';

  @override
  String get descRitualCard01Quote =>
      'श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्। स्वधर्मे निधनं श्रेयः परधर्मो भयावहः॥';

  @override
  String get descRitualCard01Source => 'श्रीमद्भगवद्गीता ३.३५';

  @override
  String get descRitualCard02Title => 'अल्पेषु कार्येषु धर्मः';

  @override
  String get descRitualCard02Prompt =>
      'अद्य कस्मिन् लघुनि दैनन्दिनकर्मणि सुकरात् लोकप्रियात् वा उचितं वरीतुं शक्नोषि?';

  @override
  String get descRitualCard02Quote =>
      'सर्वभूतानां हिताय धर्मः प्रवर्तते। येन सर्वप्राणिनां हितं धार्यते, स एव धर्मः।';

  @override
  String get descRitualCard02Source => 'महाभारतम्, शान्तिपर्व १०९.१०';

  @override
  String get descRitualCard03Title => 'धर्मचक्रम्';

  @override
  String get descRitualCard03Prompt =>
      'तव एकं सम्बन्धम् उत्तरदायित्वं वा चिन्तय। किं तत् सत्यनिष्ठया पोषयसि, उत तस्य आह्वानम् उपेक्षसे?';

  @override
  String get descRitualCard03Quote => 'धर्म एव हतो हन्ति धर्मो रक्षति रक्षितः।';

  @override
  String get descRitualCard03Source => 'मनुस्मृतिः ८.१५';

  @override
  String get descRitualCard04Title => 'सनातनः क्रमः';

  @override
  String get descRitualCard04Prompt =>
      'प्रकृतौ — उदयति सूर्ये, परिवर्तमानेषु ऋतुषु, प्रवहन्त्यां नद्याम् — ऋतस्य (विश्वक्रमस्य) लयं कुत्र पश्यसि? स तव जीवनं कथं प्रतिबिम्बयति?';

  @override
  String get descRitualCard04Quote =>
      'आपूर्यमाणमचलप्रतिष्ठं समुद्रमापः प्रविशन्ति यद्वत्। तद्वत्कामा यं प्रविशन्ति सर्वे स शान्तिमाप्नोति न कामकामी॥';

  @override
  String get descRitualCard04Source => 'श्रीमद्भगवद्गीता २.७०';

  @override
  String get descRitualCard05Title => 'विपत्सु धर्मः';

  @override
  String get descRitualCard05Prompt =>
      'यदा जीवनं त्वां परीक्षते, तदा कं सिद्धान्तं मूल्यं वा न त्यजसि? तत् तव कृते किमर्थं महत्त्वपूर्णम्?';

  @override
  String get descRitualCard05Quote => 'अतिकष्टेषु कालेषु अपि धर्मः न त्याज्यः।';

  @override
  String get descRitualCard05Source => 'रामायणम्, अयोध्याकाण्डम्';

  @override
  String get descRitualCard06Title => 'अनासक्तं कर्म';

  @override
  String get descRitualCard06Prompt =>
      'अद्य किं कार्यं यत्र फलं त्यक्त्वा केवलं कर्मणः गुणे मनः निवेशयितुं शक्नोषि?';

  @override
  String get descRitualCard06Quote =>
      'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥';

  @override
  String get descRitualCard06Source => 'श्रीमद्भगवद्गीता २.४७';

  @override
  String get descRitualCard07Title => 'अद्य उप्तं बीजम्';

  @override
  String get descRitualCard07Prompt =>
      'प्रत्येकं कर्म बीजम्। क्षमा, दया, संयमः, अन्यत् वा — अद्य कीदृशं बीजं वपसि?';

  @override
  String get descRitualCard07Quote =>
      'यादृशं वपते बीजं तादृशं लभते फलम्। स्वकर्मफलात् कोऽपि न मुच्यते।';

  @override
  String get descRitualCard07Source => 'महाभारतम्, वनपर्व';

  @override
  String get descRitualCard08Title => 'निष्कामकर्म';

  @override
  String get descRitualCard08Prompt =>
      'प्रशंसां पुरस्कारं वा विना केवलं स्वार्थरहितं यत् कृतं तत् स्मर। कथम् अनुभूतम्? तं भावं दिनस्य अधिकेषु कार्येषु आनेतुं शक्नोषि?';

  @override
  String get descRitualCard08Quote =>
      'युक्तः कर्मफलं त्यक्त्वा शान्तिमाप्नोति नैष्ठिकीम्। अयुक्तः कामकारेण फले सक्तो निबध्यते॥';

  @override
  String get descRitualCard08Source => 'श्रीमद्भगवद्गीता ५.१२';

  @override
  String get descRitualCard09Title => 'शृङ्खलाभङ्गः';

  @override
  String get descRitualCard09Prompt =>
      'क्रोधः, पलायनम्, दोषारोपणम् — किं कश्चित् प्रतिक्रियाक्रमः पुनः पुनः आवर्तते? अद्य सचेतनं भिन्नायाः प्रतिक्रियायाः वरणं कीदृशं स्यात्?';

  @override
  String get descRitualCard09Quote =>
      'कर्मेन्द्रियाणि संयम्य य आस्ते मनसा स्मरन्। इन्द्रियार्थान्विमूढात्मा मिथ्याचारः स उच्यते॥';

  @override
  String get descRitualCard09Source => 'श्रीमद्भगवद्गीता ३.६';

  @override
  String get descRitualCard10Title => 'दैनन्दिने जीवने कर्मयोगः';

  @override
  String get descRitualCard10Prompt =>
      'पाकः, स्वच्छता, कार्यम् — अद्य किमपि सामान्यं कार्यं पूर्णावधानेन भक्त्या च अर्पणरूपेण कथं परिणमयितुं शक्नोषि?';

  @override
  String get descRitualCard10Quote =>
      'यत्करोषि यदश्नासि यज्जुहोषि ददासि यत्। यत्तपस्यसि कौन्तेय तत्कुरुष्व मदर्पणम्॥';

  @override
  String get descRitualCard10Source => 'श्रीमद्भगवद्गीता ९.२७';

  @override
  String get descRitualCard11Title => 'भक्तेः हृदयम्';

  @override
  String get descRitualCard11Prompt =>
      'प्रार्थना, स्मृतिः, स्थानम्, ईश्वरचिन्तनम् — किं तव हृदयं श्रद्धया प्रेम्णा च पूरयति? इदानीं तत्र मनः स्थापय।';

  @override
  String get descRitualCard11Quote =>
      'पत्रं पुष्पं फलं तोयं यो मे भक्त्या प्रयच्छति। तदहं भक्त्युपहृतमश्नामि प्रयतात्मनः॥';

  @override
  String get descRitualCard11Source => 'श्रीमद्भगवद्गीता ९.२६';

  @override
  String get descRitualCard12Title => 'शरणागतिः विश्वासः च';

  @override
  String get descRitualCard12Prompt =>
      'अनुग्रहः त्वां पारं नेष्यति इति विश्वस्य, अद्य कां चिन्तां भारं वा ईश्वरपादयोः मनसा अर्पयितुं शक्नोषि?';

  @override
  String get descRitualCard12Quote =>
      'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज। अहं त्वा सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥';

  @override
  String get descRitualCard12Source => 'श्रीमद्भगवद्गीता १८.६६';

  @override
  String get descRitualCard13Title => 'सर्वत्र ईश्वरदर्शनम्';

  @override
  String get descRitualCard13Prompt =>
      'अद्य यान् जनान् पश्यसि, तान् सर्वान् ईश्वरस्य रूपम् इति द्रष्टुं शक्नोषि? तेन तव भाषणं श्रवणं च कथं परिवर्तेत?';

  @override
  String get descRitualCard13Quote =>
      'विद्याविनयसम्पन्ने ब्राह्मणे गवि हस्तिनि। शुनि चैव श्वपाके च पण्डिताः समदर्शिनः॥';

  @override
  String get descRitualCard13Source => 'श्रीमद्भगवद्गीता ५.१८';

  @override
  String get descRitualCard14Title => 'पावनं नाम';

  @override
  String get descRitualCard14Prompt =>
      'शान्तम् उपविश्य पवित्रस्य नाम्नः मन्त्रस्य वा जपः अन्तिमवारं कदा कृतः? तदा के भावाः उदिताः?';

  @override
  String get descRitualCard14Quote => 'भगवतः नाम भवसागरं तारयन्ती नौका।';

  @override
  String get descRitualCard14Source => 'तुलसीदासः, रामचरितमानसम्';

  @override
  String get descRitualCard15Title => 'कृतज्ञतायां कृपा';

  @override
  String get descRitualCard15Prompt =>
      'अधुना लब्धः कः अप्रत्याशितः आशीर्वादः अनुग्रहक्षणः वा, यस्य कृते कृतज्ञतया क्षणम् अपि अद्यापि न दत्तम्?';

  @override
  String get descRitualCard15Quote =>
      'अहं सर्वस्य प्रभवो मत्तः सर्वं प्रवर्तते। इति मत्वा भजन्ते मां बुधा भावसमन्विताः॥';

  @override
  String get descRitualCard15Source => 'श्रीमद्भगवद्गीता १०.८';

  @override
  String get descRitualCard16Title => 'कोऽहम्?';

  @override
  String get descRitualCard16Prompt =>
      'नाम, वृत्तिम्, भूमिकाः, शरीरं च अपसारय। किम् अवशिष्यते? अनेन प्रश्नेन सह उपविश — सर्वसंज्ञाभ्यः परः कोऽहम्?';

  @override
  String get descRitualCard16Quote => 'तत्त्वमसि।';

  @override
  String get descRitualCard16Source => 'छान्दोग्योपनिषत् ६.८.७';

  @override
  String get descRitualCard17Title => 'नित्यः साक्षी';

  @override
  String get descRitualCard17Prompt =>
      'विचारान् अगृहीत्वा गच्छतः निरीक्षस्व। कः पश्यति? किं सा चेतना कदापि आहन्तुं शक्यते?';

  @override
  String get descRitualCard17Quote =>
      'न जायते म्रियते वा कदाचिन्नायं भूत्वा भविता वा न भूयः। अजो नित्यः शाश्वतोऽयं पुराणो न हन्यते हन्यमाने शरीरे॥';

  @override
  String get descRitualCard17Source => 'श्रीमद्भगवद्गीता २.२०';

  @override
  String get descRitualCard18Title => 'मोचकं ज्ञानम्';

  @override
  String get descRitualCard18Prompt =>
      'स्वविषये जीवनविषये वा किं सत्यं यत् हृदा स्वीकृतं सत् त्वां दुःखात् अमोचयत्?';

  @override
  String get descRitualCard18Quote =>
      'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते। तत्स्वयं योगसंसिद्धः कालेनात्मनि विन्दति॥';

  @override
  String get descRitualCard18Source => 'श्रीमद्भगवद्गीता ४.३८';

  @override
  String get descRitualCard19Title => 'इन्द्रियेभ्यः परम्';

  @override
  String get descRitualCard19Prompt =>
      'इन्द्रियाणि वस्तूनां बाह्यरूपं दर्शयन्ति। यां स्थितिम् इदानीं सम्मुखीकरोषि, तस्याः अधः किं गभीरतरं सत्यम्?';

  @override
  String get descRitualCard19Quote =>
      'इन्द्रियेभ्यः परा ह्यर्था अर्थेभ्यश्च परं मनः। मनसस्तु परा बुद्धिर्बुद्धेरात्मा महान्परः॥';

  @override
  String get descRitualCard19Source => 'कठोपनिषत् १.३.१०';

  @override
  String get descRitualCard20Title => 'अन्तर्ज्योतिः';

  @override
  String get descRitualCard20Prompt =>
      'नेत्रे निमीलय। हृदये स्थिरां दीपशिखां कल्पय, यां कोऽपि वायुः न निर्वापयति। एषा ज्योतिः तुभ्यं किं प्रकाशयति?';

  @override
  String get descRitualCard20Quote =>
      'असतो मा सद्गमय। तमसो मा ज्योतिर्गमय। मृत्योर्मामृतं गमय॥';

  @override
  String get descRitualCard20Source => 'बृहदारण्यकोपनिषत् १.३.२८';

  @override
  String get descRitualCard21Title => 'पूर्णता';

  @override
  String get descRitualCard21Prompt =>
      'गभीरतमे स्तरे यदि किमपि न न्यूनम्, तर्हि किमर्थम् अपूर्णताम् अनुभवसि? पूर्वमेव पूर्णत्वस्य अर्थं चिन्तय।';

  @override
  String get descRitualCard21Quote =>
      'ॐ पूर्णमदः पूर्णमिदं पूर्णात्पूर्णमुदच्यते। पूर्णस्य पूर्णमादाय पूर्णमेवावशिष्यते॥';

  @override
  String get descRitualCard21Source => 'ईशोपनिषत्, शान्तिपाठः';

  @override
  String get descRitualCard22Title => 'सर्वत्र ब्रह्म';

  @override
  String get descRitualCard22Prompt =>
      'या चेतना त्वयि प्रकाशते, सा एव सर्वेषु प्राणिषु प्रकाशते। अयं बोधः अद्य तव लोकदर्शनं कथं परिवर्तयति?';

  @override
  String get descRitualCard22Quote => 'अहं ब्रह्मास्मि।';

  @override
  String get descRitualCard22Source => 'बृहदारण्यकोपनिषत् १.४.१०';

  @override
  String get descRitualCard23Title => 'मनसः शमनम्';

  @override
  String get descRitualCard23Prompt =>
      'इदानीं मनसः वृत्तीः — योजनाम्, चिन्ताम्, स्मृतिम् — निरीक्षस्व। कतिपयश्वासपर्यन्तम् अपि ताः सर्वाः शनैः शान्तीकर्तुं शक्नोषि?';

  @override
  String get descRitualCard23Quote => 'योगश्चित्तवृत्तिनिरोधः।';

  @override
  String get descRitualCard23Source => 'पातञ्जलयोगसूत्रम् १.२';

  @override
  String get descRitualCard24Title => 'दृढः अभ्यासः';

  @override
  String get descRitualCard24Prompt =>
      'तीव्रतायाः अपेक्षया नैरन्तर्यं महत्तरम्। धैर्येण भक्त्या च कं शुभम् अभ्यासं प्रतिज्ञातुं शक्नोषि?';

  @override
  String get descRitualCard24Quote =>
      'स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः।';

  @override
  String get descRitualCard24Source => 'पातञ्जलयोगसूत्रम् १.१४';

  @override
  String get descRitualCard25Title => 'समचित्तता';

  @override
  String get descRitualCard25Prompt =>
      'अधुनातनं साफल्यक्षणम् असाफल्यक्षणं च स्मर। हर्षविषादौ विना उभौ समया स्थिरया चेतनया धारयितुं शक्नोषि?';

  @override
  String get descRitualCard25Quote =>
      'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय। सिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥';

  @override
  String get descRitualCard25Source => 'श्रीमद्भगवद्गीता २.४८';

  @override
  String get descRitualCard26Title => 'पञ्च यमाः';

  @override
  String get descRitualCard26Prompt =>
      'अहिंसा, सत्यम्, अस्तेयम्, ब्रह्मचर्यम्, अपरिग्रहः — एषु पञ्चसु यमेषु कः इदानीं तव कृते कठिनतमः, किमर्थं च?';

  @override
  String get descRitualCard26Quote =>
      'अहिंसा, सत्यम्, अस्तेयम्, ब्रह्मचर्यम्, अपरिग्रहः — एते यमाः।';

  @override
  String get descRitualCard26Source => 'पातञ्जलयोगसूत्रम् २.३०';

  @override
  String get descRitualCard27Title => 'ईश्वरप्रणिधानम्';

  @override
  String get descRitualCard27Prompt =>
      'प्राप्त्यर्थं न, अर्पणार्थं कृतः पूर्णः प्रयत्नः कीदृशः अनुभूयते? अग्रिमं कर्म स्वस्मात् महत्तराय अर्पय।';

  @override
  String get descRitualCard27Quote => 'समाधिसिद्धिरीश्वरप्रणिधानात्।';

  @override
  String get descRitualCard27Source => 'पातञ्जलयोगसूत्रम् २.४५';

  @override
  String get descRitualCard28Title => 'विचारे अहिंसा';

  @override
  String get descRitualCard28Prompt =>
      'किम् अद्य स्वं प्रति अन्यं प्रति वा कठोराः हिंस्राः विचाराः प्रवर्तिताः? तेषां स्थाने अवबोधस्य स्थापनं किं सूचयेत्?';

  @override
  String get descRitualCard28Quote => 'अहिंसा परमो धर्मः।';

  @override
  String get descRitualCard28Source => 'महाभारतम्, अनुशासनपर्व ११६.३८';

  @override
  String get descRitualCard29Title => 'सर्वभूतदया';

  @override
  String get descRitualCard29Prompt =>
      'अधुना दृष्टं प्राणिनं — पशुं, कीटं, पक्षिणं वा — स्मर। सर्वेषु प्राणिषु तादृशः एव स्नेहः यदि विस्तार्यते, तर्हि लोकः कीदृशः स्यात्?';

  @override
  String get descRitualCard29Quote =>
      'यस्तु सर्वाणि भूतान्यात्मन्येवानुपश्यति। सर्वभूतेषु चात्मानं ततो न विजुगुप्सते॥';

  @override
  String get descRitualCard29Source => 'ईशोपनिषत्, मन्त्रः ६';

  @override
  String get descRitualCard30Title => 'मृदु वचनम्';

  @override
  String get descRitualCard30Prompt =>
      'अद्य वक्तुं पूर्वं विरम्य पृच्छ — किम् इदं सत्यम्? किं प्रियम्? किम् आवश्यकम्? अयं निकषः तव संवादान् कथं परिवर्तयति?';

  @override
  String get descRitualCard30Quote =>
      'अनुद्वेगकरं वाक्यं सत्यं प्रियहितं च यत्। स्वाध्यायाभ्यसनं चैव वाङ्मयं तप उच्यते॥';

  @override
  String get descRitualCard30Source => 'श्रीमद्भगवद्गीता १७.१५';

  @override
  String get descRitualCard31Title => 'आघातस्य क्षमा';

  @override
  String get descRitualCard31Prompt =>
      'केन दत्तं दुःखम् अद्यापि वहसि? क्षमितुं किम् अपेक्षितम् — तेषां कृते न, स्वहृदयस्य मुक्त्यै?';

  @override
  String get descRitualCard31Quote => 'क्षमा वीरस्य भूषणम्।';

  @override
  String get descRitualCard31Source => 'महाभारतम्, उद्योगपर्व ३३.४८';

  @override
  String get descRitualCard32Title => 'सत्ये जीवनम्';

  @override
  String get descRitualCard32Prompt =>
      'किं तव जीवने किमपि अस्ति यत्र स्वेन अन्यैः वा सह पूर्णा सत्यता न वर्तते? सत्यानुरूपं जीवनं कीदृशं स्यात्?';

  @override
  String get descRitualCard32Quote => 'सत्यमेव जयते।';

  @override
  String get descRitualCard32Source => 'मुण्डकोपनिषत् ३.१.६';

  @override
  String get descRitualCard33Title => 'सत्यस्य साहसम्';

  @override
  String get descRitualCard33Prompt =>
      'असुखकरम् इति कारणेन यत् सत्यं परिहरसि, तत् किम्? अद्य साहसेन तत् सम्मुखीकर्तुं किम् आवश्यकम्?';

  @override
  String get descRitualCard33Quote =>
      'सत्यं वद। धर्मं चर। स्वाध्यायान्मा प्रमदः।';

  @override
  String get descRitualCard33Source => 'तैत्तिरीयोपनिषत् १.११.१';

  @override
  String get descRitualCard34Title => 'वचनात् परं सत्यम्';

  @override
  String get descRitualCard34Prompt =>
      'सत्यं न केवलं वचने, अपि तु कर्मणि अपि वर्तते। अद्य तव कर्माणि हृदये स्थितेन सत्येन सङ्गतानि वा?';

  @override
  String get descRitualCard34Quote => 'सत्येन मानवः देवत्वं प्राप्नोति।';

  @override
  String get descRitualCard34Source => 'चाणक्यनीतिः १४.३';

  @override
  String get descRitualCard35Title => 'प्रतिज्ञापालनम्';

  @override
  String get descRitualCard35Prompt =>
      'स्वस्मै, अन्यस्मै, ईश्वराय वा कृता का प्रतिज्ञा पालनीया? इदानीं तां पुनः दृढीकुरु।';

  @override
  String get descRitualCard35Quote =>
      'वचनं प्रतिज्ञावत् पालनीयम्। यः प्रतिज्ञां भिनत्ति सः विश्वासं भिनत्ति; भग्नः विश्वासः दुःखेन पुनः सन्धीयते।';

  @override
  String get descRitualCard35Source => 'विदुरनीतिः, महाभारतम्';

  @override
  String get descRitualCard36Title => 'त्यागः';

  @override
  String get descRitualCard36Prompt =>
      'यत् वस्तु, अपेक्षा, कामना वा तव वृद्ध्यै न उपकरोति, तत् दृढं गृह्णासि किम्? तस्य शनैः विसर्जनं कल्पय।';

  @override
  String get descRitualCard36Quote =>
      'दृष्टानुश्रविकविषयवितृष्णस्य वशीकारसंज्ञा वैराग्यम्।';

  @override
  String get descRitualCard36Source => 'पातञ्जलयोगसूत्रम् १.१५';

  @override
  String get descRitualCard37Title => 'अविकारी आत्मा';

  @override
  String get descRitualCard37Prompt =>
      'परितः सर्वं परिवर्तते — भावाः, भाग्यम्, सम्बन्धाः। जीवनस्य सर्वेषु झञ्झावातेषु तव कः अंशः अपरिवर्तितः स्थितः?';

  @override
  String get descRitualCard37Quote =>
      'नासतो विद्यते भावो नाभावो विद्यते सतः। उभयोरपि दृष्टोऽन्तस्त्वनयोस्तत्त्वदर्शिभिः॥';

  @override
  String get descRitualCard37Source => 'श्रीमद्भगवद्गीता २.१६';

  @override
  String get descRitualCard38Title => 'सन्तोषः';

  @override
  String get descRitualCard38Prompt =>
      'तव पार्श्वे पूर्वमेव यत् पर्याप्तम् अस्ति, तत् किम्? इदानीं तव जीवने इच्छायाः आवश्यकतायाः च भेदं चिन्तय।';

  @override
  String get descRitualCard38Quote => 'सन्तोषादनुत्तमः सुखलाभः।';

  @override
  String get descRitualCard38Source => 'पातञ्जलयोगसूत्रम् २.४२';

  @override
  String get descRitualCard39Title => 'सुखदुःखातीतम्';

  @override
  String get descRitualCard39Prompt =>
      'अपलाय्य असुखेन सह, अगृहीत्वा सुखेन सह उपवेष्टुं शक्नोषि? उभयोः केवलं निरीक्षणे कृते किं भवति?';

  @override
  String get descRitualCard39Quote =>
      'यं हि न व्यथयन्त्येते पुरुषं पुरुषर्षभ। समदुःखसुखं धीरं सोऽमृतत्वाय कल्पते॥';

  @override
  String get descRitualCard39Source => 'श्रीमद्भगवद्गीता २.१५';

  @override
  String get descRitualCard40Title => 'दानस्य आनन्दः';

  @override
  String get descRitualCard40Prompt =>
      'प्रतिफलम् अनपेक्ष्य अद्य किं दातुं शक्नोषि — समयम्, अवधानम्, मधुरं वचनम्, साहाय्यहस्तम्?';

  @override
  String get descRitualCard40Quote => 'असहायानां साहाय्यम् एव श्रेष्ठं दानम्।';

  @override
  String get descRitualCard40Source => 'तिरुक्कुरल् २२१';

  @override
  String get descRitualCard41Title => 'परेषु ईश्वरसेवा';

  @override
  String get descRitualCard41Prompt =>
      'पुरतः स्थितः जनः यदि छद्मवेषेण ईश्वरः स्यात्, तर्हि तेन सह कथं व्यवहरेः? अग्रिमां होराम् एवं जीवितुं प्रयतस्व।';

  @override
  String get descRitualCard41Quote => 'मानवसेवा एव माधवसेवा।';

  @override
  String get descRitualCard41Source => 'स्वामी विवेकानन्दः';

  @override
  String get descRitualCard42Title => 'निःस्वार्थं कर्म';

  @override
  String get descRitualCard42Prompt =>
      'कस्मैचित् साहाय्यं कृत्वा प्रतिष्ठां विना शान्तः गभीरः च आनन्दः यदा अनुभूतः, तं क्षणं स्मर। तेन किं शिक्षितम्?';

  @override
  String get descRitualCard42Quote => 'उत्तिष्ठत जाग्रत प्राप्य वरान्निबोधत।';

  @override
  String get descRitualCard42Source => 'कठोपनिषत् १.३.१४ / स्वामी विवेकानन्दः';

  @override
  String get descRitualCard43Title => 'वसुधैव कुटुम्बकम्';

  @override
  String get descRitualCard43Prompt =>
      'समस्तं जगत् एकं कुटुम्बम्। प्रत्येकस्य जनस्य कल्याणं महत्त्वपूर्णम् इति मत्वा अद्य किम् एकं पदं स्थापयितुं शक्नोषि?';

  @override
  String get descRitualCard43Quote =>
      'अयं निजः परो वेति गणना लघुचेतसाम्। उदारचरितानां तु वसुधैव कुटुम्बकम्॥';

  @override
  String get descRitualCard43Source => 'महोपनिषत् ६.७१';

  @override
  String get descRitualCard44Title => 'करुणायाः सम्पत्';

  @override
  String get descRitualCard44Prompt =>
      'केनचित् तुभ्यं कृतं किम् अल्पं दयाकर्म अद्यापि स्मरसि? ताम् एव दयाम् अद्य अन्यस्मै कथं प्रसारयेः?';

  @override
  String get descRitualCard44Quote =>
      'दरिद्रः अपि करुणया स्वल्पम् अपि ददाति चेत्, तस्य दारिद्र्यम् अपगच्छति।';

  @override
  String get descRitualCard44Source => 'तिरुक्कुरल् २४७';

  @override
  String get descRitualCard45Title => 'अन्तःशान्तिः';

  @override
  String get descRitualCard45Prompt =>
      'नेत्रे निमील्य त्रीन् मन्दश्वासान् गृहाण। श्वासयोः अन्तरे मौनम् अनुभव। तत् मौनम् एव तव सत्यं स्वरूपम्। दिनं यावत् तत् धारयितुं शक्नोषि?';

  @override
  String get descRitualCard45Quote =>
      'बन्धुरात्मात्मनस्तस्य येनात्मैवात्मना जितः। अनात्मनस्तु शत्रुत्वे वर्तेतात्मैव शत्रुवत्॥';

  @override
  String get descRitualCard45Source => 'श्रीमद्भगवद्गीता ६.६';

  @override
  String get descRitualCard46Title => 'स्तुतिनिन्दयोः समता';

  @override
  String get descRitualCard46Prompt =>
      'अधुना लब्धां प्रशंसां निन्दां च स्मर। एकाम् अनालिङ्ग्य अन्याम् अतिरस्कृत्य उभे समया शान्त्या धारयितुं शक्नोषि?';

  @override
  String get descRitualCard46Quote =>
      'समः शत्रौ च मित्रे च तथा मानापमानयोः। शीतोष्णसुखदुःखेषु समः सङ्गविवर्जितः॥ तुल्यनिन्दास्तुतिर्मौनी सन्तुष्टो येन केनचित्। अनिकेतः स्थिरमतिर्भक्तिमान्मे प्रियो नरः॥';

  @override
  String get descRitualCard46Source => 'श्रीमद्भगवद्गीता १२.१८–१९';

  @override
  String get descRitualCard47Title => 'पङ्के पद्मम्';

  @override
  String get descRitualCard47Prompt =>
      'पङ्किले जले पद्मं विकसति, तथापि निर्लेपं तिष्ठति। इदानीं तव जीवने पङ्किला स्थितिः का? तस्याः लेपं विना वर्धितुं कथं शक्यते?';

  @override
  String get descRitualCard47Quote =>
      'ब्रह्मण्याधाय कर्माणि सङ्गं त्यक्त्वा करोति यः। लिप्यते न स पापेन पद्मपत्रमिवाम्भसा॥';

  @override
  String get descRitualCard47Source => 'श्रीमद्भगवद्गीता ५.१०';

  @override
  String get descRitualCard48Title => 'ॐ शान्तिः';

  @override
  String get descRitualCard48Prompt =>
      'निश्चलम् उपविश्य त्रिवारम् \"ॐ शान्तिः\" इति जप — देहे शान्तिः, मनसि शान्तिः, आत्मनि शान्तिः। एवं कृते कः क्षोभः विलीयते?';

  @override
  String get descRitualCard48Quote => 'ॐ शान्तिः शान्तिः शान्तिः॥';

  @override
  String get descRitualCard48Source => 'उपनिषच्छान्तिमन्त्रः';

  @override
  String get descRitualCard49Title => 'सर्वे सुखिनः सन्तु';

  @override
  String get descRitualCard49Prompt =>
      'मौनेन प्रथमं स्वस्य, ततः प्रियजनानाम्, ततः अपरिचितानाम्, ततः सर्वभूतानां कल्याणम् इच्छ। वृत्ते विस्तीर्यमाणे हृदयं कथं विकसति इति पश्य।';

  @override
  String get descRitualCard49Quote =>
      'सर्वे भवन्तु सुखिनः सर्वे सन्तु निरामयाः। सर्वे भद्राणि पश्यन्तु मा कश्चिद्दुःखभाग्भवेत्॥';

  @override
  String get descRitualCard49Source => 'औपनिषदी प्रार्थना';

  @override
  String get descRitualCard50Title => 'बलं शान्तिश्च';

  @override
  String get descRitualCard50Prompt =>
      'यथार्थं बलम् आयासात् न जायते, गभीरायाः आन्तरिकशान्तेः जायते। अद्य जीवने कुत्र बलप्रयोगस्य स्थाने शान्तं दृढनिश्चयं स्थापयितुं शक्नोषि?';

  @override
  String get descRitualCard50Quote =>
      'बलं जीवनम्, दौर्बल्यं मृत्युः। बलम् एव भेषजम्, बलम् एव निवारणम्। \"बलं बलम्\" इति उपनिषदः उपदिशन्ति।';

  @override
  String get descRitualCard50Source => 'स्वामी विवेकानन्दः';

  @override
  String get labelRitualThemeDharma => 'धर्मः';

  @override
  String get labelRitualThemeKarma => 'कर्म';

  @override
  String get labelRitualThemeBhakti => 'भक्तिः';

  @override
  String get labelRitualThemeJnana => 'ज्ञानम्';

  @override
  String get labelRitualThemeYoga => 'योगः';

  @override
  String get labelRitualThemeAhimsa => 'अहिंसा';

  @override
  String get labelRitualThemeSathya => 'सत्यम्';

  @override
  String get labelRitualThemeVairagya => 'वैराग्यम्';

  @override
  String get labelRitualThemeSeva => 'सेवा';

  @override
  String get labelRitualThemeShanti => 'शान्तिः';

  @override
  String get labelBreathTechniqueBox => 'समवृत्तिश्वासः';

  @override
  String get labelBreathTechniqueRelaxing => 'विश्रान्तिश्वासः';

  @override
  String get labelBreathTechniqueCalm => 'शान्तलयः';

  @override
  String get labelBreathPhaseInhale => 'पूरकः';

  @override
  String get labelBreathPhaseHold => 'कुम्भकः';

  @override
  String get labelBreathPhaseExhale => 'रेचकः';

  @override
  String get labelBreathPhaseRest => 'बाह्यकुम्भकः';

  @override
  String get descBreathGuidanceInhale => 'नासिकया शनैः श्वासं गृहाण...';

  @override
  String get descBreathGuidanceHold => 'शिखरे मृदु धारय...';

  @override
  String get descBreathGuidanceExhale => 'शनैः पूर्णतया त्यज...';

  @override
  String get descBreathGuidanceRest => 'शान्ते स्थैर्ये विश्राम्य...';

  @override
  String get bodyBreathPracticeCompleted => 'श्वासाभ्यासः समाप्तः';

  @override
  String bodyBreathPhaseRemaining(String phase, int seconds) {
    return '$phase, $seconds विकलाः अवशिष्टाः';
  }

  @override
  String get titleBreathGrounded => 'स्थिरं जागरूकं च मनः';

  @override
  String labelBreathCycle(int current, int total) {
    return 'आवर्तनम् $current / $total';
  }

  @override
  String get labelTemplateCategoryGeneral => 'नूतनारम्भः';

  @override
  String get labelTemplateCategoryReflective => 'दैनिकं चिन्तनम्';

  @override
  String get labelTemplateCategoryThoughts => 'विचाराः कल्पनाश्च';

  @override
  String get labelTemplateCategoryProjects => 'योजनाः कार्यं च';

  @override
  String get labelTemplateCategoryPeople => 'सम्बन्धाः';

  @override
  String get labelTemplateCategoryHealth => 'आरोग्यं कल्याणं च';

  @override
  String get labelTemplateCategoryLearning => 'अध्ययनं विकासश्च';

  @override
  String get labelTemplateCategoryCreative => 'सर्जनात्मकम्';

  @override
  String get labelTemplateCategoryPlanning => 'आयोजनम्';

  @override
  String get labelTemplateCategorySpecialty => 'विशेषविषयाः';

  @override
  String get labelTemplateBlank => 'रिक्तम्';

  @override
  String get descTemplateBlank => 'रिक्तया टिप्पण्या आरभस्व।';

  @override
  String get labelTemplateDaily => 'दैनिकं चिन्तनम्';

  @override
  String get descTemplateDaily => 'शुभक्षणाः, कृतज्ञता, श्वः लक्ष्यं च।';

  @override
  String get descTemplateDailyEntryTitle => 'दैनिकं चिन्तनम्';

  @override
  String get bodyTemplateDaily =>
      'शुभक्षणाः\n\nकठिनक्षणाः\n\nश्वः लक्ष्यम्\n\n';

  @override
  String get labelTemplateTodayForMe => 'अद्य मम';

  @override
  String get descTemplateTodayForMe =>
      'अद्य कृतं, चिन्तितं, दृष्टं, सम्मुखीकृतम्, अनुभूतं, शिक्षितं च।';

  @override
  String get descTemplateTodayForMeEntryTitle => 'अद्य मम';

  @override
  String get bodyTemplateTodayForMe =>
      'अद्य मया कृतम्\n\nअद्य मया चिन्तितम्\n\nअद्य मया दृष्टम्\n\nअद्य मया सम्मुखीकृतम्\n\nअद्य मया अनुभूतम्\n\nअद्य मया शिक्षितम्\n\n';

  @override
  String get labelTemplateEveningWindDown => 'सायंविश्रान्तिः';

  @override
  String get descTemplateEveningWindDown =>
      'विजयाः, संघर्षाः, त्याज्यः एकः विषयः च।';

  @override
  String get descTemplateEveningWindDownEntryTitle => 'सायंविश्रान्तिः';

  @override
  String get bodyTemplateEveningWindDown =>
      'विजयाः\n\nसंघर्षाः\n\nत्याज्यः एकः विषयः\n\n';

  @override
  String get labelTemplateMorningPages => 'प्रातःपृष्ठानि';

  @override
  String get descTemplateMorningPages =>
      'दिनारम्भे मनसि यत् अस्ति तत् सर्वम् अविरतं लिख।';

  @override
  String get descTemplateMorningPagesEntryTitle => 'प्रातःपृष्ठानि';

  @override
  String get labelTemplateDayHighlight => 'दिनस्य विशिष्टक्षणः';

  @override
  String get descTemplateDayHighlight =>
      'सर्वाधिकं स्मरणीयः क्षणः तस्य कारणं च।';

  @override
  String get descTemplateDayHighlightEntryTitle => 'दिनस्य विशिष्टक्षणः';

  @override
  String get bodyTemplateDayHighlight => 'सः क्षणः\n\nकिमर्थं विशिष्टः\n\n';

  @override
  String get labelTemplateEnergyCheck => 'ऊर्जापरीक्षा';

  @override
  String get descTemplateEnergyCheck =>
      'ऊर्जास्तरः, केन क्षीणा, केन पुनः प्राप्ता।';

  @override
  String get descTemplateEnergyCheckEntryTitle => 'ऊर्जापरीक्षा';

  @override
  String get bodyTemplateEnergyCheck =>
      'ऊर्जास्तरः (1-10): \n\nकेन क्षीणा\n\nकेन पुनः प्राप्ता\n\n';

  @override
  String get labelTemplateMood => 'मनोदशा';

  @override
  String get descTemplateMood => 'सम्प्रति मनोदशां तस्याः कारणानि च लिख।';

  @override
  String get descTemplateMoodEntryTitle => 'मनोदशा';

  @override
  String get bodyTemplateMood => 'इदानीं कथम् अनुभवामि\n\nतस्याः कारणम्\n\n';

  @override
  String get labelTemplateThoughts => 'मम विचाराः';

  @override
  String get descTemplateThoughts => 'कस्मिंश्चित् विषये स्वतन्त्रं चिन्तनम्।';

  @override
  String get descTemplateThoughtsEntryTitle => 'मम विचाराः';

  @override
  String get bodyTemplateThoughts => 'विषयः\n\nमम विचाराः\n\n';

  @override
  String get labelTemplateIdeaCapture => 'कल्पनाग्रहणम्';

  @override
  String get descTemplateIdeaCapture =>
      'कल्पना, तस्याः महत्त्वम्, अग्रिमं पदं च।';

  @override
  String get descTemplateIdeaCaptureEntryTitle => 'कल्पनाग्रहणम्';

  @override
  String get bodyTemplateIdeaCapture =>
      'कल्पना\n\nमहत्त्वं किमर्थम्\n\nअग्रिमं पदम्\n\n';

  @override
  String get labelTemplateOpenQuestion => 'मुक्तः प्रश्नः';

  @override
  String get descTemplateOpenQuestion =>
      'मनसि स्थितः प्रश्नः सम्प्रति चिन्तनं च।';

  @override
  String get descTemplateOpenQuestionEntryTitle => 'मुक्तः प्रश्नः';

  @override
  String get bodyTemplateOpenQuestion =>
      'प्रश्नः\n\nइदानीं यावत् मम मतम्\n\nअद्यापि अज्ञातम्\n\n';

  @override
  String get labelTemplateOpinion => 'अभिप्रायः';

  @override
  String get descTemplateOpinion =>
      'मतम्, पक्षे प्रमाणानि, विपक्षे प्रमाणानि च।';

  @override
  String get descTemplateOpinionEntryTitle => 'अभिप्रायः';

  @override
  String get bodyTemplateOpinion =>
      'मम मतम्\n\nपक्षे प्रमाणानि\n\nविपक्षे प्रमाणानि\n\n';

  @override
  String get labelTemplateLessonsLearned => 'प्राप्ताः पाठाः';

  @override
  String get descTemplateLessonsLearned =>
      'किं घटितं, किं शिक्षितं, कथं प्रयोक्ष्ये।';

  @override
  String get descTemplateLessonsLearnedEntryTitle => 'प्राप्ताः पाठाः';

  @override
  String get bodyTemplateLessonsLearned =>
      'किं घटितम्\n\nकिं शिक्षितम्\n\nकथं प्रयोक्ष्ये\n\n';

  @override
  String get labelTemplateProjects => 'मम योजनाः';

  @override
  String get descTemplateProjects => 'योजना, स्थितिः, बाधाः, अग्रिमं कार्यं च।';

  @override
  String get descTemplateProjectsEntryTitle => 'मम योजनाः';

  @override
  String get bodyTemplateProjects =>
      'योजना\n\nस्थितिः\n\nबाधाः\n\nअग्रिमं कार्यम्\n\n';

  @override
  String get labelTemplateProjectUpdate => 'योजनाप्रगतिः';

  @override
  String get descTemplateProjectUpdate =>
      'प्रगतिः, सङ्कटानि, कृताः निर्णयाः च।';

  @override
  String get descTemplateProjectUpdateEntryTitle => 'योजनाप्रगतिः';

  @override
  String get bodyTemplateProjectUpdate =>
      'प्रगतिः\n\nसङ्कटानि\n\nकृताः निर्णयाः\n\n';

  @override
  String get labelTemplateWeeklyReview => 'साप्ताहिकसमीक्षा';

  @override
  String get descTemplateWeeklyReview =>
      'विजयाः, न्यूनताः, अग्रिमसप्ताहस्य लक्ष्यं च।';

  @override
  String get descTemplateWeeklyReviewEntryTitle => 'साप्ताहिकसमीक्षा';

  @override
  String get bodyTemplateWeeklyReview =>
      'विजयाः\n\nन्यूनताः\n\nअग्रिमसप्ताहस्य लक्ष्यम्\n\n';

  @override
  String get labelTemplateGoalTracker => 'लक्ष्यानुसरणम्';

  @override
  String get descTemplateGoalTracker =>
      'लक्ष्यम्, प्रगतिः, विघ्नाः, परिवर्तनानि च।';

  @override
  String get descTemplateGoalTrackerEntryTitle => 'लक्ष्यानुसरणम्';

  @override
  String get bodyTemplateGoalTracker =>
      'लक्ष्यम्\n\nप्रगतिः\n\nविघ्नाः\n\nपरिवर्तनानि\n\n';

  @override
  String get labelTemplateDecisionLog => 'निर्णयपञ्जी';

  @override
  String get descTemplateDecisionLog =>
      'निर्णयः, विचारिताः विकल्पाः, एतस्य वरणस्य कारणं च।';

  @override
  String get descTemplateDecisionLogEntryTitle => 'निर्णयपञ्जी';

  @override
  String get bodyTemplateDecisionLog =>
      'निर्णयः\n\nविचारिताः विकल्पाः\n\nएतस्य वरणस्य कारणम्\n\n';

  @override
  String get labelTemplateStuckPoint => 'अवरोधबिन्दुः';

  @override
  String get descTemplateStuckPoint =>
      'अवरोधः कुत्र, किं प्रयतितं, किम् अग्रे प्रयतितव्यम्।';

  @override
  String get descTemplateStuckPointEntryTitle => 'अवरोधबिन्दुः';

  @override
  String get bodyTemplateStuckPoint =>
      'अवरोधः कुत्र\n\nकिं प्रयतितम्\n\nअग्रे किं प्रयतितव्यम्\n\n';

  @override
  String get labelTemplateMeeting => 'सभाटिप्पण्यः';

  @override
  String get descTemplateMeeting => 'सदस्याः, कार्यसूची, निर्णयाः, करणीयानि च।';

  @override
  String get descTemplateMeetingEntryTitle => 'सभाटिप्पण्यः';

  @override
  String get bodyTemplateMeeting =>
      'सदस्याः: \nकार्यसूची\n\nनिर्णयाः\n\nकरणीयानि\n\n';

  @override
  String get labelTemplateConversationRecap => 'संवादसारः';

  @override
  String get descTemplateConversationRecap =>
      'केन सह, किं चर्चितम्, अनुवर्तीनि कार्याणि च।';

  @override
  String get descTemplateConversationRecapEntryTitle => 'संवादसारः';

  @override
  String get bodyTemplateConversationRecap =>
      'केन सह\n\nकिं चर्चितम्\n\nअनुवर्तीनि कार्याणि\n\n';

  @override
  String get labelTemplateGratefulPeople => 'उपकारिणः जनाः';

  @override
  String get descTemplateGratefulPeople => 'एकः जनः विशिष्टं कारणं च।';

  @override
  String get descTemplateGratefulPeopleEntryTitle => 'कृतज्ञतायाः पात्राणि';

  @override
  String get bodyTemplateGratefulPeople => 'जनः\n\nविशिष्टं कारणम्\n\n';

  @override
  String get labelTemplateUnsentLetter => 'अप्रेषितं पत्रम्';

  @override
  String get descTemplateUnsentLetter =>
      'भावान् अवगन्तुं लिखितम् अप्रेषितं पत्रम्।';

  @override
  String get descTemplateUnsentLetterEntryTitle => 'अप्रेषितं पत्रम्';

  @override
  String get bodyTemplateUnsentLetter => 'प्रिय ...,\n\n\n\n— अहम्\n\n';

  @override
  String get labelTemplateRelationshipCheckin => 'सम्बन्धपरीक्षा';

  @override
  String get descTemplateRelationshipCheckin =>
      'प्रमुखः सम्बन्धः कथं प्रवर्तते।';

  @override
  String get descTemplateRelationshipCheckinEntryTitle => 'सम्बन्धपरीक्षा';

  @override
  String get bodyTemplateRelationshipCheckin =>
      'जनः\n\nकथं प्रवर्तते\n\nअवधानम् अपेक्षमाणम्\n\n';

  @override
  String get labelTemplateGratitude => 'कृतज्ञता';

  @override
  String get descTemplateGratitude => 'अद्य कृतज्ञतायाः त्रयः विषयाः।';

  @override
  String get descTemplateGratitudeEntryTitle => 'कृतज्ञता';

  @override
  String get bodyTemplateGratitude =>
      'कृतज्ञतायाः त्रयः विषयाः\n\n1. \n2. \n3. \n';

  @override
  String get labelTemplateBodyCheckin => 'शरीरपरीक्षा';

  @override
  String get descTemplateBodyCheckin =>
      'निद्रा, आहारः, व्यायामः, वेदना आयासः वा।';

  @override
  String get descTemplateBodyCheckinEntryTitle => 'शरीरपरीक्षा';

  @override
  String get bodyTemplateBodyCheckin =>
      'निद्रा\n\nआहारः\n\nव्यायामः\n\nवेदना आयासः वा\n\n';

  @override
  String get labelTemplateMentalHealth => 'मनःस्वास्थ्यम्';

  @override
  String get descTemplateMentalHealth =>
      'मनोदशा, उत्तेजकाः, प्रयुक्ताः उपायाः च।';

  @override
  String get descTemplateMentalHealthEntryTitle => 'मनःस्वास्थ्यम्';

  @override
  String get bodyTemplateMentalHealth =>
      'मनोदशा\n\nउत्तेजकाः\n\nप्रयुक्ताः उपायाः\n\n';

  @override
  String get labelTemplateHabitTracker => 'अभ्यासानुसरणम्';

  @override
  String get descTemplateHabitTracker =>
      'अद्य कृताः अभ्यासाः नैरन्तर्यटिप्पण्यः च।';

  @override
  String get descTemplateHabitTrackerEntryTitle => 'अभ्यासानुसरणम्';

  @override
  String get bodyTemplateHabitTracker =>
      'अद्य कृताः अभ्यासाः\n\nअद्य त्यक्ताः\n\nनैरन्तर्यटिप्पण्यः\n\n';

  @override
  String get labelTemplateSleepLog => 'निद्रापञ्जी';

  @override
  String get descTemplateSleepLog => 'होराः, गुणवत्ता, स्वप्नाः च।';

  @override
  String get descTemplateSleepLogEntryTitle => 'निद्रापञ्जी';

  @override
  String get bodyTemplateSleepLog => 'होराः\n\nगुणवत्ता\n\nस्वप्नाः\n\n';

  @override
  String get labelTemplateTaughtToday => 'अद्य शिक्षितम्';

  @override
  String get descTemplateTaughtToday => 'पाठः, स्रोतः, सारः च।';

  @override
  String get descTemplateTaughtTodayEntryTitle => 'अद्य शिक्षितम्';

  @override
  String get bodyTemplateTaughtToday => 'पाठः\n\nस्रोतः\n\nसारः\n\n';

  @override
  String get labelTemplateBookNotes => 'पुस्तकटिप्पण्यः';

  @override
  String get descTemplateBookNotes =>
      'शीर्षकम्, मुख्यविचाराः, मम प्रतिक्रिया च।';

  @override
  String get descTemplateBookNotesEntryTitle => 'पुस्तकटिप्पण्यः';

  @override
  String get bodyTemplateBookNotes =>
      'शीर्षकम्: \nलेखकः: \n\nमुख्यविचाराः\n\nमम प्रतिक्रिया\n\n';

  @override
  String get labelTemplateSkillPractice => 'कौशलाभ्यासः';

  @override
  String get descTemplateSkillPractice =>
      'किम् अभ्यस्तं, किं समुन्नतम्, अग्रिमं लक्ष्यं च।';

  @override
  String get descTemplateSkillPracticeEntryTitle => 'कौशलाभ्यासः';

  @override
  String get bodyTemplateSkillPractice =>
      'कौशलम्\n\nकिम् अभ्यस्तम्\n\nकिं समुन्नतम्\n\nअग्रिमं लक्ष्यम्\n\n';

  @override
  String get labelTemplateMistakeLog => 'दोषपञ्जी';

  @override
  String get descTemplateMistakeLog => 'किं विपरीतं जातं, मूलकारणं, निवारणं च।';

  @override
  String get descTemplateMistakeLogEntryTitle => 'दोषपञ्जी';

  @override
  String get bodyTemplateMistakeLog =>
      'किं विपरीतं जातम्\n\nमूलकारणम्\n\nनिवारणम्\n\n';

  @override
  String get labelTemplateTopicDeepDive => 'विषयाध्ययनम्';

  @override
  String get descTemplateTopicDeepDive =>
      'कस्यचित् तत्त्वस्य विषयस्य वा विस्तृता अध्ययनटिप्पणी।';

  @override
  String get descTemplateTopicDeepDiveEntryTitle => 'विषयाध्ययनम्';

  @override
  String get bodyTemplateTopicDeepDive =>
      'विषयः / मूलतत्त्वम्\n\nमुख्यसिद्धान्ताः अवलोकनं च\n\nविस्तृतं विश्लेषणं टिप्पण्यः च\n\nमुख्यसाराः सन्दर्भाः च\n\nमुक्ताः प्रश्नाः / अधिकम् अन्वेषणम्\n\n';

  @override
  String get labelTemplateDreamJournal => 'स्वप्नपञ्जी';

  @override
  String get descTemplateDreamJournal =>
      'स्वप्नविवरणम्, भावाः, सम्भाव्यः अर्थः च।';

  @override
  String get descTemplateDreamJournalEntryTitle => 'स्वप्नपञ्जी';

  @override
  String get bodyTemplateDreamJournal =>
      'स्वप्नविवरणम्\n\nभावाः\n\nसम्भाव्यः अर्थः\n\n';

  @override
  String get labelTemplateObservation => 'निरीक्षणचित्रम्';

  @override
  String get descTemplateObservation => 'सूक्ष्मतया दृष्टः कश्चित् विषयः।';

  @override
  String get descTemplateObservationEntryTitle => 'निरीक्षणचित्रम्';

  @override
  String get bodyTemplateObservation => 'मया यत् दृष्टम्\n\nविवरणम्\n\n';

  @override
  String get labelTemplateQuoteOfDay => 'अद्यतनं सूक्तम्';

  @override
  String get descTemplateQuoteOfDay => 'सूक्तं तत् किमर्थं हृदयं स्पृशति च।';

  @override
  String get descTemplateQuoteOfDayEntryTitle => 'अद्यतनं सूक्तम्';

  @override
  String get bodyTemplateQuoteOfDay =>
      'सूक्तम्\n\nस्रोतः\n\nकिमर्थं हृदयं स्पृशति\n\n';

  @override
  String get labelTemplateStorySeed => 'कथाबीजम्';

  @override
  String get descTemplateStorySeed => 'लघु कथाकल्पना दृश्यं वा।';

  @override
  String get descTemplateStorySeedEntryTitle => 'कथाबीजम्';

  @override
  String get bodyTemplateStorySeed => 'बीजम्\n\nसम्भाव्या दिशा\n\n';

  @override
  String get labelTemplateTravel => 'यात्रापञ्जी';

  @override
  String get descTemplateTravel => 'स्थानम्, वातावरणम्, घटनाः, दृष्टाः जनाः च।';

  @override
  String get descTemplateTravelEntryTitle => 'यात्रापञ्जी';

  @override
  String get bodyTemplateTravel =>
      'स्थानम्: \nवातावरणम्: \nघटनाः\n\nदृष्टाः जनाः\n\n';

  @override
  String get labelTemplateTomorrowFocus => 'श्वः लक्ष्यम्';

  @override
  String get descTemplateTomorrowFocus => 'त्रीणि मुख्यकार्याणि प्रथमं पदं च।';

  @override
  String get descTemplateTomorrowFocusEntryTitle => 'श्वः लक्ष्यम्';

  @override
  String get bodyTemplateTomorrowFocus =>
      'त्रीणि मुख्यकार्याणि\n\n1. \n2. \n3. \n\nप्रथमं पदम्\n\n';

  @override
  String get labelTemplateWeeklyIntentions => 'साप्ताहिकसङ्कल्पाः';

  @override
  String get descTemplateWeeklyIntentions =>
      'विषयः, प्राथमिकताः, वर्जनीयानि च।';

  @override
  String get descTemplateWeeklyIntentionsEntryTitle => 'साप्ताहिकसङ्कल्पाः';

  @override
  String get bodyTemplateWeeklyIntentions =>
      'विषयः\n\nप्राथमिकताः\n\nवर्जनीयानि\n\n';

  @override
  String get labelTemplateMonthlyReview => 'मासिकसमीक्षा';

  @override
  String get descTemplateMonthlyReview =>
      'विजयाः, पाठाः, अग्रिममासे परिवर्तनानि च।';

  @override
  String get descTemplateMonthlyReviewEntryTitle => 'मासिकसमीक्षा';

  @override
  String get bodyTemplateMonthlyReview =>
      'विजयाः\n\nपाठाः\n\nअग्रिममासे परिवर्तनानि\n\n';

  @override
  String get labelTemplateWorkoutLog => 'व्यायामपञ्जी';

  @override
  String get descTemplateWorkoutLog => 'व्यायामाः, समूहाः, आवृत्तयः, अनुभवः च।';

  @override
  String get descTemplateWorkoutLogEntryTitle => 'व्यायामपञ्जी';

  @override
  String get bodyTemplateWorkoutLog =>
      'व्यायामः\n\nसमूहाः / आवृत्तयः\n\nअनुभवः\n\n';

  @override
  String get labelTemplateReadingLog => 'पठनपञ्जी';

  @override
  String get descTemplateReadingLog =>
      'पुस्तकम्, पठितानि पृष्ठानि, प्रियः अंशः च।';

  @override
  String get descTemplateReadingLogEntryTitle => 'पठनपञ्जी';

  @override
  String get bodyTemplateReadingLog =>
      'पुस्तकम्\n\nपठितानि पृष्ठानि\n\nप्रियः अंशः\n\n';

  @override
  String get labelTemplateFoodJournal => 'आहारपञ्जी';

  @override
  String get descTemplateFoodJournal => 'भोजनानि तदनन्तरम् अनुभवः च।';

  @override
  String get descTemplateFoodJournalEntryTitle => 'आहारपञ्जी';

  @override
  String get bodyTemplateFoodJournal => 'भोजनानि\n\nतदनन्तरम् अनुभवः\n\n';

  @override
  String get labelTemplateSpendingLog => 'व्ययपञ्जी';

  @override
  String get descTemplateSpendingLog => 'क्रीतानि — किं तत् योग्यम् आसीत्?';

  @override
  String get descTemplateSpendingLogEntryTitle => 'व्ययपञ्जी';

  @override
  String get bodyTemplateSpendingLog =>
      'क्रीतम्\n\nमूल्यम्\n\nकिं योग्यम् आसीत्?\n\n';

  @override
  String get labelTemplatePrayerMeditation => 'प्रार्थना / ध्यानम्';

  @override
  String get descTemplatePrayerMeditation => 'साधना, कालावधिः, चिन्तनानि च।';

  @override
  String get descTemplatePrayerMeditationEntryTitle => 'प्रार्थना / ध्यानम्';

  @override
  String get bodyTemplatePrayerMeditation =>
      'साधना\n\nकालावधिः\n\nचिन्तनानि\n\n';

  @override
  String get labelTemplateSysadminRunbook => 'तन्त्रप्रशासनम्';

  @override
  String get descTemplateSysadminRunbook =>
      'सेवकयन्त्रस्य तन्त्रस्य वा सञ्चालनपुस्तिका, आदेशाः, अनुरक्षणपञ्जी च।';

  @override
  String get descTemplateSysadminRunbookEntryTitle => 'तान्त्रिकटिप्पणी';

  @override
  String get bodyTemplateSysadminRunbook =>
      'तन्त्रम् / सेवा: \nउद्देश्यं संरचना च\n\nविन्यासः आदेशाः च\n\nसत्यापनं स्वास्थ्यपरीक्षा च\n\nसमस्यानिवारणं प्रत्यावर्तनटिप्पण्यः च\n\n';

  @override
  String get labelTemplateSanathanaDharmaStudy => 'धर्माध्ययनम्';

  @override
  String get descTemplateSanathanaDharmaStudy =>
      'शास्त्रम्, श्लोकः, तत्त्वम्/अर्थः, साधनाचिन्तनं च।';

  @override
  String get descTemplateSanathanaDharmaStudyEntryTitle => 'सनातनधर्माध्ययनम्';

  @override
  String get bodyTemplateSanathanaDharmaStudy =>
      'विषयः / शास्त्रम्: \nश्लोकः / मन्त्रः / सन्दर्भः\n\nपदच्छेदः अर्थः च\n\nदार्शनिकाः अन्तर्दृष्टयः (तत्त्वम्)\n\nनित्यसाधना व्यावहारिकः प्रयोगः च\n\n';

  @override
  String get labelTemplateDiyProject => 'स्वनिर्माणयोजना';

  @override
  String get descTemplateDiyProject =>
      'सामग्री, उपकरणानि, क्रमशः निर्माणं, सुरक्षा च।';

  @override
  String get descTemplateDiyProjectEntryTitle => 'स्वनिर्माणम्';

  @override
  String get bodyTemplateDiyProject =>
      'योजनायाः लक्ष्यं व्याप्तिः च\n\nआवश्यकानि उपकरणानि सामग्री च\n\nक्रमशः प्रक्रिया\n\nसुरक्षा सावधानता च\n\nपरीक्षणं प्राप्ताः पाठाः च\n\n';

  @override
  String get labelTemplateHomeMaintenance => 'गृहानुरक्षणम्';

  @override
  String get descTemplateHomeMaintenance =>
      'उपकरणरक्षणम्, संस्काराः, प्रत्याभूतयः, विक्रेतृपञ्जी च।';

  @override
  String get descTemplateHomeMaintenanceEntryTitle => 'गृहानुरक्षणटिप्पणी';

  @override
  String get bodyTemplateHomeMaintenance =>
      'स्थानम् / वस्तु / उपकरणम्: \nसमस्या / अनुरक्षणकार्यम्\n\nसेवेतिहासः व्ययाः च\n\nप्रत्याभूतिः विक्रेतृसम्पर्काः च\n\nअग्रिमा निर्धारिता परीक्षा: \n\n';

  @override
  String get labelTemplateKitchenRecipe => 'पाकविधिः';

  @override
  String get descTemplateKitchenRecipe =>
      'व्यञ्जनम्, घटकाः, क्रमशः विधिः, सूचनाः च।';

  @override
  String get descTemplateKitchenRecipeEntryTitle => 'पाकविधिटिप्पणी';

  @override
  String get bodyTemplateKitchenRecipe =>
      'व्यञ्जनस्य नाम: \nपाकशैली / सज्जता पाककालः च: \n\nघटकाः परिमाणानि च\n\nक्रमशः विधिः\n\nपाचकटिप्पण्यः भेदाः च\n\n';

  @override
  String get titleExport => 'निर्यापणम्';

  @override
  String get titleExportSectionWhat => 'निर्यापणीयम्';

  @override
  String get titleExportSectionFormat => 'स्वरूपम्';

  @override
  String get titleExportSectionOptions => 'विकल्पाः';

  @override
  String get labelExportScopeThisEntry => 'इयं टिप्पणी';

  @override
  String get labelExportScopeWholeJournal => 'सम्पूर्णा दैनन्दिनी';

  @override
  String get labelExportScopeDateRange => 'दिनाङ्कपरिधिः';

  @override
  String get actionExportPickDateRange => 'दिनाङ्काः चीयन्ताम्';

  @override
  String get descExportDateRangeNotSet => 'दिनाङ्काः अद्यापि न चिताः';

  @override
  String descExportFromJournal(String journalTitle) {
    return '\"$journalTitle\" इत्यस्मात्';
  }

  @override
  String descExportDateRange(String from, String to) {
    return '$from तः $to पर्यन्तम्';
  }

  @override
  String get labelExportFormatMarkdown => 'Markdown';

  @override
  String get labelExportFormatHtml => 'जालपृष्ठम् (HTML)';

  @override
  String get labelExportFormatPlainText => 'सरलः पाठः';

  @override
  String get labelExportFormatPdf => 'PDF';

  @override
  String get descExportFormatMarkdown =>
      'शीर्षकाणि, सूचीः, शैलीं च रक्षति। कस्मिन्नपि पाठसम्पादके उद्घाटयितुं शक्यते।';

  @override
  String get descExportFormatHtml =>
      'कस्मिन्नपि जालदर्शके उद्घाट्यमानम् एकं पृष्ठम्। अन्तर्जालात् किमपि न आनीयते।';

  @override
  String get descExportFormatPlainText => 'शैलीं विना केवलं शब्दाः।';

  @override
  String get descExportFormatPdf =>
      'मुद्रणाय वितरणाय वा सज्जानि स्थिराणि पृष्ठानि।';

  @override
  String get bodyExportPdfUnavailable =>
      'अस्मिन् उपकरणे PDF-निर्यापणं न लभ्यते। अन्ये प्रकाराः कार्यं कुर्वन्ति।';

  @override
  String get labelExportIncludeAttachments => 'अनुबन्धाः योज्यन्ताम्';

  @override
  String get descExportIncludeAttachments =>
      'प्रत्येकस्याः सञ्चिकायाः ध्वनिटिप्पण्याः च प्रतिलिपिं योजयति।';

  @override
  String get labelExportIncludeMetadata => 'दिनाङ्कः, चिह्नानि, मनोदशा';

  @override
  String get descExportIncludeMetadata =>
      'प्रत्येकस्याः टिप्पण्याः उपरि लघुं शीर्षभागं योजयति।';

  @override
  String get bodyExportNotEncrypted =>
      'निर्यापिता सञ्चिका कूटलिखिता नास्ति। यः कोऽपि ताम् उद्घाटयितुं शक्नोति सः तां पठितुं शक्नोति। सुरक्षिते स्थाने रक्ष्यताम्।';

  @override
  String get titleExportConfirm => 'कूटलेखनं विना निर्यापणम्?';

  @override
  String bodyExportConfirm(int count, String format) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टिप्पण्यः',
      one: 'एका टिप्पणी',
    );
    return '$_temp0 — एतत् सर्वम् अकूटलिखितायां $format-सञ्चिकायां लेखिष्यते। यः कोऽपि तां सञ्चिकाम् उद्घाटयितुं शक्नोति सः तव दैनन्दिनीं पठितुं शक्नोति। सुरक्षिते स्थाने रक्ष, कार्यसमाप्तौ च ताम् अपनय।';
  }

  @override
  String get actionExportAnyway => 'तथापि निर्याप्यताम्';

  @override
  String get actionExport => 'निर्याप्यताम्';

  @override
  String get bodyExportExporting => 'निर्याप्यते…';

  @override
  String get titleExportSaveDialog => 'निर्यापणं रक्ष्यताम्';

  @override
  String bodyExportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टिप्पण्यः निर्यापिताः।',
      one: 'एका टिप्पणी निर्यापिता।',
    );
    return '$_temp0';
  }

  @override
  String get bodyExportCancelled => 'निर्यापणं निरस्तम्।';

  @override
  String get errorExportNothing =>
      'तस्य चयनस्य निर्यापणाय काऽपि टिप्पणी नास्ति।';

  @override
  String get errorExportFailed =>
      'निर्यापणं समापयितुं न शक्तम्। किमपि न रक्षितम्।';

  @override
  String get errorExportPdfTimedOut =>
      'PDF-निर्माणे अतिकालः अभवत्, अतः स्थगितम्। लघुतरां दिनाङ्कपरिधिं प्रयतस्व।';

  @override
  String get errorExportPdfFailed => 'PDF निर्मातुं न शक्तम्।';

  @override
  String get titleExportSkipped => 'अयोजितानि';

  @override
  String bodyExportSkippedLockedAttachment(String fileName) {
    return '$fileName — पिहितम्। योजयितुं प्रथमम् उद्घाटय।';
  }

  @override
  String bodyExportSkippedUnreadableAttachment(String fileName) {
    return '$fileName — सञ्चिका पठितुं न शक्ता।';
  }

  @override
  String bodyExportSkippedUnreadableVoiceNote(String fileName) {
    return '$fileName — ध्वनिमुद्रणं पठितुं न शक्तम्।';
  }

  @override
  String bodyExportSkippedLockedInlineImage(String fileName) {
    return '$fileName — टिप्पण्यां स्थितं पिहितं चित्रं पृष्ठात् त्यक्तम्।';
  }

  @override
  String bodyExportSkippedUnreadableInlineImage(String fileName) {
    return '$fileName — टिप्पण्यां स्थितं चित्रं पठितुं न शक्तम्।';
  }

  @override
  String get descExportFileUntitledEntry => 'अनामिका टिप्पणी';

  @override
  String get descExportFileDate => 'दिनाङ्कः';

  @override
  String get descExportFileTags => 'चिह्नानि';

  @override
  String get descExportFileMood => 'मनोदशा';

  @override
  String get descExportFileAttachments => 'अनुबन्धाः';

  @override
  String get descExportFileVoiceNotes => 'ध्वनिटिप्पण्यः';

  @override
  String get descExportFileTranscript => 'प्रतिलेखः';

  @override
  String get descExportFileLockedNotIncluded => 'पिहितम् — न योजितम्';

  @override
  String get descExportFileImage => 'चित्रम्';

  @override
  String get descExportFileDrawing => 'रेखाचित्रम्';

  @override
  String get descExportFileCalloutNote => 'टिप्पणी';

  @override
  String get descExportFileCalloutTip => 'उपायः';

  @override
  String get descExportFileCalloutWarning => 'पूर्वसूचना';

  @override
  String get descExportFileCalloutImportant => 'महत्त्वपूर्णम्';

  @override
  String descExportFileMoodValue(int mood) {
    return 'पञ्चसु $mood';
  }

  @override
  String descExportFileRecording(String duration) {
    return 'ध्वनिमुद्रणम् ($duration)';
  }

  @override
  String bodyExportFileReadme(
    String journalTitle,
    String exportedAt,
    int entryCount,
    String formatName,
  ) {
    return 'SreerajP Journal Vault इत्यस्मात् निर्यापणम्\n\nदैनन्दिनी:  $journalTitle\nनिर्यापितम्: $exportedAt\nटिप्पण्यः:  $entryCount\nस्वरूपम्:   $formatName\n\n\"entries\" इति पुटके प्रतिटिप्पणि एका सञ्चिका अस्ति।\n\"attachments\" इति पुटकं यदि अस्ति, तर्हि तत्र तासां टिप्पणीनां सञ्चिकानां\nध्वनिटिप्पणीनां च प्रतिलिपिः अस्ति।\n\nइदं निर्यापणं कूटलिखितं नास्ति। एताः सञ्चिकाः यः कोऽपि उद्घाटयितुं शक्नोति सः ताः पठितुं शक्नोति।\n';
  }

  @override
  String get labelExportData => 'दत्तांशनिर्यापणम्';

  @override
  String get tooltipExportEntry => 'इयं टिप्पणी निर्याप्यताम्';

  @override
  String get tooltipExportJournal => 'इयं दैनन्दिनी निर्याप्यताम्';

  @override
  String get titleExportChooseJournal => 'दैनन्दिन्याः निर्यापणम्';

  @override
  String get bodyExportNoJournals =>
      'प्रथमं दैनन्दिनीं सृज, ततः निर्यापयितुं शक्नोषि।';

  @override
  String get bodyExportAllLocked =>
      'निर्यापणाय प्रथमं पिहितां दैनन्दिनीम् उद्घाटय।';

  @override
  String descExportFileUnexportableBlock(String type) {
    return '$type खण्डः — पाठरूपेण निर्यापयितुं न शक्यः';
  }

  @override
  String get descExportFileImageNotIncluded => 'चित्रं न योजितम्';

  @override
  String get descExportFileDrawingNotIncluded => 'रेखाचित्रं न योजितम्';

  @override
  String get actionCommonOk => 'अस्तु';

  @override
  String get actionCommonDone => 'सम्पन्नम्';

  @override
  String get bodyAirqrSettingsApplied => 'विन्यासाः प्रतिरूपाणि च प्रयुक्तानि।';

  @override
  String get bodyAirqrEntryImported => 'प्रविष्टिः दैनन्दिन्याम् आनीता।';

  @override
  String get bodyAirqrJournalImported => 'दैनन्दिनी प्रविष्टयः च आनीताः।';

  @override
  String get errorAirqrImport => 'दत्तांशः आनेतुं न शक्तः।';

  @override
  String get descAirqrImportedEntryTitle => 'आनीता प्रविष्टिः';

  @override
  String get descAirqrImportedJournalTitle => 'आनीता दैनन्दिनी';

  @override
  String get bodyAirqrAssembling => 'चित्रखण्डाः संयोज्य परीक्ष्यन्ते…';

  @override
  String get errorAirqrDecode =>
      'दत्तांशः पठितुं न शक्तः। युग्मसङ्केतं परीक्ष्य पुनः अवलोकयतु।';

  @override
  String get actionAirqrScanAgain => 'पुनः अवलोकय';

  @override
  String bodyAirqrFramesReceived(int received, int total) {
    return '$total मध्ये $received चित्रखण्डाः प्राप्ताः';
  }

  @override
  String get bodyAirqrAlignCamera => 'चलत् QR-सङ्केतं प्रति छायायन्त्रं नयतु…';

  @override
  String bodyAirqrMissingFrames(String frames) {
    return 'अप्राप्ताः चित्रखण्डाः: $frames';
  }

  @override
  String get titleAirqrEnterCode => 'युग्मसङ्केतं लिखतु';

  @override
  String get descAirqrEnterCode =>
      'प्रेषकपटले दृश्यमानं षोडशाक्षरं सङ्केतं लिखतु।';

  @override
  String get actionAirqrDecrypt => 'उद्घाट्य परीक्षय';

  @override
  String get titleAirqrVerified => 'दत्तांशः सत्यापितः';

  @override
  String descAirqrPayloadType(String type) {
    return 'प्रकारः: $type';
  }

  @override
  String get labelAirqrKindSettings => 'विन्यासाः';

  @override
  String get labelAirqrKindEntry => 'प्रविष्टिः';

  @override
  String get labelAirqrKindJournal => 'दैनन्दिनी';

  @override
  String get labelAirqrKindSnapshot => 'प्रतिच्छाया';

  @override
  String descAirqrPayloadTheme(String theme) {
    return 'वर्णविन्यासः: $theme';
  }

  @override
  String descAirqrPayloadAccent(String color) {
    return 'मुख्यवर्णः: $color';
  }

  @override
  String descAirqrPayloadTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'प्रतिरूपाणि: $count',
      one: 'प्रतिरूपाणि: 1',
    );
    return '$_temp0';
  }

  @override
  String descAirqrPayloadTags(int count) {
    return 'चिह्नानि: $count';
  }

  @override
  String get actionAirqrApplySettings => 'विन्यासान् प्रयुङ्क्ष्व';

  @override
  String get actionAirqrImport => 'कोशे आनय';

  @override
  String get bodyAirqrEncoding => 'QR-चित्रखण्डाः सज्जीक्रियन्ते…';

  @override
  String get errorAirqrEncode => 'प्रेषणाय दत्तांशः सज्जीकर्तुं न शक्तः।';

  @override
  String descAirqrPayloadSize(int bytes, int frames) {
    return '$bytes बाइट् • $frames चित्रखण्डाः';
  }

  @override
  String get labelAirqrManifestFrame => 'शीर्षखण्डः';

  @override
  String labelAirqrFrameOf(int index, int total) {
    return 'खण्डः $index/$total';
  }

  @override
  String labelAirqrSpeed(int fps) {
    return 'वेगः: $fps FPS';
  }

  @override
  String bodyAirqrTooLarge(String size, String limit) {
    return '$size QR-द्वारा प्रेषणाय अतिबृहत् (सीमा $limit)। तस्य स्थाने Wi-Fi-समन्वयं प्रयुङ्क्ष्व।';
  }

  @override
  String bodyAirqrSlow(String size, String duration) {
    return 'इदं प्रेषणं $size परिमितम्, QR-द्वारा प्रायः $duration कालं स्वीकरोति। बृहत्प्रेषणाय Wi-Fi-समन्वयः शीघ्रतरः।';
  }

  @override
  String descAirqrMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निमेषाः',
      one: '1 निमेषः',
    );
    return '$_temp0';
  }

  @override
  String descAirqrSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्षणाः',
      one: '1 क्षणः',
    );
    return '$_temp0';
  }

  @override
  String get bodyAirqrNoJournals => 'प्रेषणाय दैनन्दिन्यः न सन्ति।';

  @override
  String get titleAirqrSelectJournal => 'दैनन्दिनीं वृणु';

  @override
  String get descAirqrNoDescription => 'विवरणं नास्ति';

  @override
  String get descAirqrOffline => 'पूर्णतः जालरहितम् • केवलं छायायन्त्रम्';

  @override
  String get labelAirqrBadgeFast => 'क्षणात् न्यूनम्';

  @override
  String get titleAirqrPayloadSettings => 'विन्यासाः प्रतिरूपाणि च';

  @override
  String get titleAirqrPayloadSnapshot => 'कोशपाठप्रतिच्छाया';

  @override
  String get errorTimeCapsuleSeal => 'कालपेटिका मुद्रयितुं न शक्ता।';

  @override
  String get errorTimeCapsuleNotFound => 'कालपेटिका न लब्धा।';

  @override
  String get errorTimeCapsuleLoad => 'कालपेटिका उद्घाटयितुं न शक्ता।';

  @override
  String get labelTimeCapsuleDays => 'दिनानि';

  @override
  String get labelTimeCapsuleHours => 'होराः';

  @override
  String get labelTimeCapsuleMinutes => 'निमेषाः';

  @override
  String get labelTimeCapsuleSeconds => 'क्षणाः';

  @override
  String get labelTimeCapsuleSealedOn => 'मुद्रणदिनम्';

  @override
  String get labelTimeCapsuleUnlocksOn => 'उद्घाटनदिनम्';

  @override
  String get labelTimeCapsuleTeaser => 'भाविने टिप्पणी';

  @override
  String get descEditorPlaceholder => 'प्रविष्टिं लिखतु…';

  @override
  String descBiometricReasonFile(String fileName) {
    return '\"$fileName\" उद्घाटय';
  }

  @override
  String get descBiometricReasonApp => 'SreerajP Journal Vault उद्घाटय';

  @override
  String get bodyEditorDrawingLocked => 'रुद्धं रेखाचित्रम् — उद्घाटनाय स्पृश';

  @override
  String get descEditorImageLoading => 'चित्रम् आरोप्यते…';

  @override
  String get errorTemplateLoad => 'प्रतिरूपाणि आरोपयितुं न शक्तानि।';

  @override
  String get errorTemplateSave => 'प्रतिरूपं रक्षितुं न शक्तम्।';

  @override
  String descShareSealedFileSize(String size) {
    return '$size KB • गूढं कोशपत्रम्';
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
  String get descTemplateTokenToday => 'अद्यतनदिनाङ्कः (YYYY-MM-DD)';

  @override
  String get descTemplateTokenWeekday => 'वासरः (यथा सोमवासरः)';

  @override
  String get descTemplateTokenDate => 'पूर्णदिनाङ्कः (यथा 2026 अगस्त 23)';

  @override
  String get descTemplateTokenTime => 'वर्तमानसमयः (यथा 2:30 PM)';

  @override
  String get descTemplateTokenYear => 'चतुरङ्कवर्षम् (यथा 2026)';

  @override
  String get descTemplateTokenMonth => 'मासनाम (यथा भाद्रपदः)';

  @override
  String get descTemplateTokenDay => 'मासस्य दिनम् (1–31)';

  @override
  String descShareDefaultTitle(String date) {
    return 'टिप्पणी - $date';
  }

  @override
  String labelTimeCapsuleOpenedOn(String date) {
    return '$date दिने उद्घाटिता';
  }

  @override
  String get errorTimeCapsuleUnseal => 'कालपेटिका उद्घाटयितुं न शक्ता।';

  @override
  String get bodySyncStepConnecting => 'उपकरणेन संयोजनं क्रियते…';

  @override
  String get bodySyncStepAuthenticating => 'युग्मसङ्केतः परीक्ष्यते…';

  @override
  String get bodySyncStepSyncing => 'प्रविष्टयः संलग्नानि च प्रतिलिप्यन्ते…';

  @override
  String get bodySyncStepCompleted => 'समन्वयः सम्पन्नः।';

  @override
  String get errorSyncFailed =>
      'समन्वयः विफलः। उभयोः उपकरणयोः परीक्ष्य पुनः यततु।';

  @override
  String get labelSyncNotSynced => 'असमन्वितम्';

  @override
  String get labelSyncSynced => 'समन्वितम्';

  @override
  String get errorSyncIpRequired => 'IP-सङ्केतं लिखतु।';

  @override
  String get errorSyncPortInvalid => '1 तः 65535 पर्यन्तं द्वारसङ्ख्यां लिखतु।';

  @override
  String get errorSyncCodeInvalid => 'षोडशाक्षरं युग्मसङ्केतं लिखतु।';

  @override
  String get errorSyncHostAddress => 'अस्य उपकरणस्य सङ्केतः पठितुं न शक्तः।';

  @override
  String get labelSyncNoAddress => 'न किमपि';

  @override
  String get bodySyncDetectingWifi => 'Wi-Fi अन्विष्यते…';

  @override
  String labelSyncIpList(String addresses) {
    return 'IP-सङ्केतः: $addresses';
  }

  @override
  String labelSyncUnresolvedConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अनिराकृताः विरोधाः',
      one: '1 अनिराकृतः विरोधः',
    );
    return '$_temp0';
  }

  @override
  String labelSyncLastSyncAt(String timestamp) {
    return 'अन्तिमः समन्वयः: $timestamp';
  }

  @override
  String get errorOcrNoCameras => 'अस्मिन् उपकरणे छायायन्त्रं न लब्धम्।';

  @override
  String get bodyVoiceNoteRecording => 'ध्वनिमुद्रणं चलति…';

  @override
  String get titleVoiceNote => 'ध्वनिटिप्पणी';

  @override
  String get errorAttachmentAudioPlay => 'इदं ध्वनिपत्रं श्रावयितुं न शक्तम्।';

  @override
  String get errorAttachmentArchiveRead =>
      'इदं सङ्ग्रहपत्रं पठितुं न शक्तम्। तत् दूषितं गुप्तशब्दरक्षितं वा भवेत्।';

  @override
  String get labelDateToday => 'अद्य';

  @override
  String get labelDateYesterday => 'ह्यः';

  @override
  String labelDateDaysAgo(int count) {
    return '$count दिनेभ्यः पूर्वम्';
  }

  @override
  String labelDateWeeksAgo(int count) {
    return '$count सप्ताहेभ्यः पूर्वम्';
  }

  @override
  String labelDateMonthsAgo(int count) {
    return '$count मासेभ्यः पूर्वम्';
  }

  @override
  String labelDateYearsAgo(int count) {
    return '$count वर्षेभ्यः पूर्वम्';
  }

  @override
  String get titlePermissionAttachmentImport => 'संलग्नकोशप्रवेशः';

  @override
  String get descPermissionAttachmentImport =>
      'संलग्नं योजयतः सतः उपकरणस्य सञ्चिकाः पठितुम् अनुमतिं ददाति।';

  @override
  String get titlePermissionDocumentPicker => 'प्रणाल्याः सञ्चिकाचयनम्';

  @override
  String get descPermissionDocumentPicker =>
      'संलग्नानां चयनाय प्रणाल्याः सञ्चिकाचयनं प्रयुज्यते। अनुमतिः न आवश्यका।';

  @override
  String get labelSecurityEventFailedAuth => 'प्रमाणीकरणं विफलम्';

  @override
  String get labelSecurityEventAttachmentLocked => 'संलग्नं रुद्धम्';

  @override
  String get labelSecurityEventAttachmentUnlocked => 'संलग्नम् उद्घाटितम्';

  @override
  String get labelSecurityEventExportAttempt => 'दैनन्दिनीदत्तांशः निर्यापितः';

  @override
  String get labelSecurityEventLockTriggered => 'अनुप्रयोगः रुद्धः';

  @override
  String get labelSecurityEventProfileChanged => 'स्वयंरोधविन्यासः परिवर्तितः';

  @override
  String get labelSecurityEventProfileCreated => 'स्वयंरोधविन्यासः सृष्टः';

  @override
  String get labelSecurityEventScreenSecurityChanged =>
      'पटलचित्रणरोधः परिवर्तितः';

  @override
  String get labelSecurityEventTamperDetected => 'विकृतिः ज्ञाता';

  @override
  String get labelSecurityEventOther => 'सुरक्षाघटना';

  @override
  String get labelImportFormatWord => 'Word-लेखपत्रम्';

  @override
  String get labelImportFormatMarkdown => 'Markdown';

  @override
  String get labelImportFormatPlainText => 'सरलपाठः';

  @override
  String get titleNotificationTimeCapsules => 'कालपेटिकाः';

  @override
  String get errorStorageMigrationFailed =>
      'संलग्नानि स्थानान्तरयितुं न शक्तानि।';

  @override
  String get descPermissionSafGranted =>
      'प्रणाल्याः सञ्चिकाचयनेन अनुमतिः प्राप्ता — Android 13 तः परं पृथक् अनुमतिः न आवश्यका।';

  @override
  String labelJournalEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टयः',
      one: '1 प्रविष्टिः',
    );
    return '$_temp0';
  }

  @override
  String get tooltipEditorDictate => 'वाचा लिख';

  @override
  String get titleDictation => 'वाग्लेखनम्';

  @override
  String get labelDictationListening => 'शृणोति…';

  @override
  String get labelDictationPaused => 'विरतम्';

  @override
  String get tooltipDictationPause => 'विरम';

  @override
  String get tooltipDictationResume => 'पुनः आरभस्व';

  @override
  String get tooltipDictationLanguage => 'वाग्भाषा';

  @override
  String get labelDictationDeviceDefault => 'यन्त्रभाषा';

  @override
  String get labelDictationEditHint => 'पाठं संशोधय';

  @override
  String get actionDictationInsert => 'योजय';

  @override
  String get emptyDictationSpeak => 'वक्तुम् आरभस्व। तव शब्दाः अत्र दृश्यन्ते।';

  @override
  String get descDictationPrivacy =>
      'वाणी अस्मिन् यन्त्रे एव परिचीयते। ध्वनिः न रक्ष्यते न च प्रेष्यते।';

  @override
  String get errorDictationOfflineUnavailable =>
      'अस्मिन् यन्त्रे जालं विना वाक्परिचयः न लभ्यते। वाग्लेखनं यन्त्रे एव प्रवर्तते, अतः अत्र उपयोक्तुं न शक्यते।';

  @override
  String get errorDictationLanguageUnavailable =>
      'अस्याः भाषायाः जालरहितं वाक्प्रतिरूपं न स्थापितम्। दूरवाण्याः वाग्विन्यासेषु तत् स्थापय, अथवा अन्यां भाषां चिनु।';

  @override
  String get errorDictationFailed =>
      'वाक्परिचयः अकस्मात् स्थगितः। पुनः प्रयतस्व।';

  @override
  String get helpDictationSanskritUnsupported =>
      'संस्कृतवाणी इदानीं जालं विना परिचेतुं न शक्यते। आङ्ग्लभाषया मलयाळभाषया वा वद।';

  @override
  String get tooltipOcrPreviewText => 'पाठं पश्य';

  @override
  String get actionOcrInAppCamera => 'अन्तःस्थं छायायन्त्रम्';

  @override
  String get errorOcrPhoneCameraUnavailable =>
      'दूरवाण्याः छायायन्त्र-अनुप्रयोगः उद्घाटयितुं न शक्तः। तस्य स्थाने अन्तःस्थं छायायन्त्रं प्रयुज्यते।';

  @override
  String get helpOcrPhoneCamera =>
      '\"चित्रं गृहाण\" स्पष्टतमचित्रार्थं दूरवाण्याः स्वकीयं छायायन्त्र-अनुप्रयोगम् उद्घाटयति। केचन छायायन्त्र-अनुप्रयोगाः चित्रस्य प्रतिलिपिं चित्रशालायाम् अपि रक्षन्ति। यदि चित्रम् अस्मात् अनुप्रयोगात् बहिः न गन्तव्यम्, तर्हि \"अन्तःस्थं छायायन्त्रम्\" वृणु।';
}
