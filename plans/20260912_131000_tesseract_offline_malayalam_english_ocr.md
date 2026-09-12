# Plan: Offline Malayalam & English Tesseract OCR and Performance Optimization

**Status:** Completed

## Problem
1. **Malayalam OCR produces junk:** Google ML Kit Text Recognition has no Malayalam model. It runs Malayalam script through its Latin classifier, returning nonsense Latin letters (e.g. `GHUT 2026 JIo 42...` for `മാതൃവാണി ആഗസ്റ്റ് 2026...`).
2. **Extreme OCR latency (15–30+ seconds):** The app performs multiple pure-Dart full-resolution PNG encodings in `OcrEnhancer` and `OcrImagePreprocessor` on high-megapixel camera photos before OCR runs. Additionally, the OCR screen displays stale text while processing a new crop.

## Proposed Fix
1. **Integrate Native Tesseract 5 (`Tesseract4Android`):**
   - 100% offline, on-device OCR in native C++ via MethodChannel.
   - Bundle lightweight official `mal.traineddata` (~2.7 MB) and `eng.traineddata` (~4.1 MB) in `assets/tessdata/`.
   - Support English, Malayalam, and mixed Bilingual (`eng+mal`) recognition.
2. **Speed Optimization:**
   - Optimize `OcrEnhancer` and `OcrImagePreprocessor` by capping processing resolution to 1800px max edge (optimal for OCR) and eliminating redundant duplicate pure-Dart PNG encodings.
   - Immediately clear stale recognized text when a new crop or adjustment begins.
3. **UI Language Selector:**
   - Add a clean OCR language selector (English + മലയാളം / മലയാളം / English) in `OcrEnhanceScreen`.

## Files to Change and Create

### New Files
- `assets/tessdata/mal.traineddata`: Official fast LSTM model for Malayalam.
- `assets/tessdata/eng.traineddata`: Official fast LSTM model for English.

### Modified Files
- `android/build.gradle.kts`: Add JitPack repository for Tesseract4Android.
- `android/app/build.gradle.kts`: Add `cz.adaptech.tesseract4android:tesseract4android` dependency.
- `android/app/proguard-rules.pro`: Add keep rules for Tesseract and Leptonica.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`: Implement native OCR MethodChannel handler (`in.sreerajp.sreerajp_journal_vault/ocr`).
- `pubspec.yaml`: Declare `assets/tessdata/` under assets.
- `docs/dependencies.md`: Document `tesseract4android`.
- `lib/features/entries/services/ocr_service.dart`: Add `NativeOcrService` with language parameter support.
- `lib/features/entries/services/ocr_enhancer.dart`: Optimize image isolate processing and compression latency.
- `lib/features/entries/services/ocr_image_preprocessor.dart`: Prevent redundant re-processing.
- `lib/features/entries/providers/ocr_providers.dart`: Provide `NativeOcrService`.
- `lib/features/entries/presentation/ocr_enhance_screen.dart`: Add language selector and clear stale text on crop.
- `lib/l10n/app_en.arb`: Add English labels for OCR languages.
- `lib/l10n/app_ml.arb`: Add Malayalam translations for OCR languages.
- `test/features/entries/services/ocr_service_test.dart`: Test native OCR service and language parameter.
- `test/features/entries/presentation/ocr_enhance_screen_test.dart`: Test OCR enhance screen with language switching.

## Verification Plan
1. Run `flutter gen-l10n`.
2. Run `flutter analyze` (must be 0 issues).
3. Run `dart format lib test`.
4. Run `flutter test` across the test suite.
5. Verify Malayalam and single-line detection accuracy.
