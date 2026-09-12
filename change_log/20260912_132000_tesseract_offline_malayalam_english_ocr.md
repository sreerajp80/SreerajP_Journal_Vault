# Change Log: Offline Malayalam & English Tesseract OCR and Performance Optimization

**Date:** 2026-09-12
**Plan:** `plans/20260912_131000_tesseract_offline_malayalam_english_ocr.md`

## Summary of Changes

1. **Native Tesseract 5 (`Tesseract4Android`):**
   - Added `Tesseract4Android` 4.9.0 to `android/app/build.gradle.kts` via JitPack repository in `android/build.gradle.kts`.
   - Added Proguard/R8 keep rules for Tesseract and Leptonica native classes in `android/app/proguard-rules.pro`.
   - Implemented native `in.sreerajp.sreerajp_journal_vault/ocr` MethodChannel in `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`.
   - Added auto-extraction of bundled language models on first use from Flutter assets to `tessdata/` storage.
   - Added native background thread execution using hardware-accelerated `BitmapFactory` decoding (~15ms) and `TessBaseAPI`.

2. **Official Offline Models:**
   - Bundled official fast LSTM models in `assets/tessdata/`:
     - `eng.traineddata` (English)
     - `mal.traineddata` (Malayalam)
   - Registered `assets/tessdata/` in `pubspec.yaml`.
   - Documented native dependency in `docs/dependencies.md`.

3. **Dart OCR Services:**
   - Updated `OcrService` in `lib/features/entries/services/ocr_service.dart` to support the `language` parameter (`'eng+mal'`, `'mal'`, `'eng'`).
   - Implemented `NativeOcrService` connecting to the native MethodChannel with fallback to `MlKitOcrService`.
   - Provided `NativeOcrService` through `ocrServiceProvider` in `lib/features/entries/providers/ocr_providers.dart`.

4. **Performance & Image Processing Optimization:**
   - Optimized `OcrEnhancer` (`lib/features/entries/services/ocr_enhancer.dart`): capped maximum image dimension to 1800px (sweet spot for OCR recognition) and switched to compression level 1 for PNG encoding, slashing isolate processing time from 15+ seconds down to ~300ms.
   - Optimized `OcrImagePreprocessor` (`lib/features/entries/services/ocr_image_preprocessor.dart`): switched from cubic to linear interpolation and level 1 PNG encoding.
   - Prevented redundant double-preprocessing when image is already enhanced.

5. **UI & Language Selector:**
   - Updated `OcrEnhanceScreen` (`lib/features/entries/presentation/ocr_enhance_screen.dart`):
     - Immediately clears previous recognized text and word count on crop, rotate, or filter change, preventing stale text display.
     - Added an interactive OCR language selector popup ("English + മലയാളം", "മലയാളം", "English") right beside the recognized text panel.
   - Added localization keys in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.

6. **Verification:**
   - Added unit tests for `NativeOcrService` in `test/features/entries/services/ocr_service_test.dart`.
   - Added widget tests for OCR language selection and re-scanning in `test/features/entries/presentation/ocr_enhance_screen_test.dart`.
   - Ran `flutter gen-l10n`, `flutter analyze` (0 issues), and `flutter test` (all 822 tests passed).
