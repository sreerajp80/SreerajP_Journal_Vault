# Change Log: Add R8 Proguard Rules for ML Kit Text Recognition

**Date:** 2026-08-20
**Plan Reference:** [plans/20260820_215700_r8-mlkit-missing-rules.md](plans/20260820_215700_r8-mlkit-missing-rules.md)

## Summary of Changes
- Added `-dontwarn` ProGuard/R8 rules in `android/app/proguard-rules.pro` for optional ML Kit text recognition script classes (`chinese`, `devanagari`, `japanese`, `korean`) that are not bundled.
- This resolves the R8 minification failure during release APK builds (`flutter build apk --flavor prod --release --split-per-abi`).

## Files Changed
- `android/app/proguard-rules.pro`
- `plans/20260820_215700_r8-mlkit-missing-rules.md`
- `change_log/20260820_220100_r8-mlkit-missing-rules.md`

## Verification
- Ran `flutter build apk --flavor prod --release --split-per-abi` which finished successfully and generated `app-armeabi-v7a-prod-release.apk`, `app-arm64-v8a-prod-release.apk`, and `app-x86_64-prod-release.apk`.
- Ran `flutter analyze` with zero issues found.
