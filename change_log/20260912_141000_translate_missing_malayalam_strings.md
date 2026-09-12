# Change Log: Translate 91 Missing Messages in Malayalam (ml)

**Plan reference:** `plans/20260912_141000_translate_missing_malayalam_strings.md`

## Summary of Changes
- Added Malayalam translations for all 91 missing keys in `lib/l10n/app_ml.arb`.
- Regenerated Flutter localization classes using `flutter gen-l10n`, updating `lib/l10n/app_localizations_ml.dart` and `lib/l10n/app_localizations.dart`.
- Eliminated the untranslated messages warning from `flutter gen-l10n`.

## Translated Keys
1. **Editor shortcuts & mood**: `editorInsertTab`, `entryMoodTooltip`, `editorGotoLineStart`, `editorGotoLineEnd`
2. **Themes & descriptions**: `settingsThemeSepia`, `settingsThemeOled`, `settingsThemeSepiaDesc`, `settingsThemeOledDesc`, `settingsThemeLightDesc`, `settingsThemeDarkDesc`, `settingsThemeSystemDesc`
3. **Typography settings & previews**: `appearanceTypographyTitle`, `appearanceTypographySubtitle`, `appearanceFontFamily`, `appearanceFontSize`, `appearanceFontFamilySans`, `appearanceFontFamilySansDesc`, `appearanceFontFamilySerif`, `appearanceFontFamilySerifDesc`, `appearanceFontFamilyMonospace`, `appearanceFontFamilyMonospaceDesc`, `appearanceFontSizeSmall`, `appearanceFontSizeDefault`, `appearanceFontSizeMedium`, `appearanceFontSizeLarge`, `appearanceFontSizeExtraLarge`, `appearanceSampleHeadline`, `appearanceSampleBody`, `appearanceTypographyUpdated`, `appearanceTypographyReset`
4. **Time Capsule**: `timeCapsuleActionSeal`, `timeCapsuleSealTitle`, `timeCapsuleSealDescription`, `timeCapsuleUnlockDateLabel`, `timeCapsuleTeaserHint`, `timeCapsulePreset1Month`, `timeCapsulePreset6Months`, `timeCapsulePreset1Year`, `timeCapsulePreset3Years`, `timeCapsulePreset5Years`, `timeCapsulePresetCustom`, `timeCapsuleSealConfirm`, `timeCapsuleSealedBadge`, `timeCapsuleSealedUntil`, `timeCapsuleOpensInDays`, `timeCapsuleOpensInHours`, `timeCapsuleOpensToday`, `timeCapsuleReadyToOpen`, `timeCapsuleLockedExplanation`, `timeCapsuleUnsealButton`, `timeCapsuleUnsealLockedPrompt`, `timeCapsuleSealedSuccess`, `timeCapsuleUnsealedSuccess`, `timeCapsuleClockTamperError`, `timeCapsuleTitle`, `timeCapsuleSubtitle`, `timeCapsuleEmptyState`, `timeCapsuleBannerTitle`, `timeCapsuleBannerBody`, `timeCapsuleBannerBodyPlural`, `timeCapsuleCategorySealed`, `timeCapsuleCategoryReady`, `timeCapsuleCategoryOpened`
5. **Ritual Cards**: `ritualCreateCardTitle`, `ritualEditCardTitle`, `ritualCreateCardButton`, `ritualCardThemeLabel`, `ritualCardTitleLabel`, `ritualCardTitleHint`, `ritualCardTitleRequired`, `ritualCardPromptLabel`, `ritualCardPromptHint`, `ritualCardPromptRequired`, `ritualCardQuoteLabel`, `ritualCardQuoteHint`, `ritualCardQuoteRequired`, `ritualCardAuthorLabel`, `ritualCardAuthorHint`, `ritualCardPreviewLabel`, `ritualSaveCardCreate`, `ritualSaveCardEdit`, `ritualCardCreatedMessage`, `ritualCardUpdatedMessage`, `ritualCardSaveError`, `ritualUserCardBadge`, `ritualEditCardAction`, `ritualDeleteCardAction`, `ritualDeleteCardTitle`, `ritualDeleteCardConfirm`, `ritualCardDeletedMessage`, `ritualNoJournalError`

## Verification
- Ran `flutter gen-l10n`: Completed with 0 untranslated warnings.
- Ran `flutter analyze`: Passed with 0 issues.
- Ran `flutter test test/features/entries/services/ocr_service_test.dart`: All 13 tests passed.
