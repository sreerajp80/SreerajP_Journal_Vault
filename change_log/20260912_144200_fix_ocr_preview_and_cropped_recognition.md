# Change Log: Fix OCR Preview Disappearing After Image Processing and Improve Cropped Text Recognition

**Date:** 2026-09-12 14:49:00 IST  
**Plan:** `plans/20260912_144200_fix_ocr_preview_and_cropped_recognition.md`

---

## 1. Summary of Changes

Fixed the issue where OCR text preview disappeared and reported "No text was detected in the image" after cropping or applying image filters, while working on the initial uncropped photo.

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`
- Added `addQuietZonePadding(src: Bitmap, paddingPx: Int = 32)`: draws a clean white margin around the cropped bitmap before OCR. This ensures Tesseract's Leptonica binarizer and connected-component analysis do not treat dark edges or boundary-touching characters as page frames or borders.
- Updated `performTesseractOcr` to execute sequential multi-mode Page Segmentation Mode (PSM) fallback:
  1. `PSM_AUTO` (Mode 3): for full-page documents.
  2. `PSM_SINGLE_BLOCK` (Mode 6): if `PSM_AUTO` returns empty text, automatically retries as a single uniform text block (ideal for cropped snippets, receipts, and columns).
  3. `PSM_SPARSE_TEXT` (Mode 11): if still empty, retries with sparse text mode (ideal for single-line banners and headers).
  4. `PSM_SINGLE_LINE` (Mode 7): final single line fallback.
- Ensured intermediate bitmaps and recycled allocations are properly managed.

### `lib/features/entries/services/ocr_enhancer.dart`
- Tuned filter contrast curves:
  - `OcrEnhanceFilter.documentBw`: adjusted contrast from 165 to 130 to prevent over-thresholding and eroding thin Malayalam vowel signs and digits.
  - `OcrEnhanceFilter.enhance`: adjusted contrast from 135 to 118 for crisp monochrome legibility without clipping.
- Added resolution scaling for very short cropped snippets (e.g. single-line crops with height < 220px) up to 2x (capped at 1800px max dimension), ensuring individual characters have sufficient x-height (>= 28px) for accurate LSTM neural network character classification.

---

## 2. Verification

1. **Static Analysis:**
   - `flutter analyze` completed with 0 warnings and 0 errors.
2. **Code Formatting:**
   - `dart format lib test` verified clean across all 330 project files.
3. **Unit & Widget Tests:**
   - `flutter test test/features/entries/services/ocr_service_test.dart test/features/entries/presentation/ocr_enhance_screen_test.dart test/features/entries/services/ocr_enhancer_test.dart` passed (19/19 tests).
   - `flutter test test/features/sync/sync_engine_wifi_test.dart` passed.
4. **Build & Deployment:**
   - Successfully built split production release APKs with R8 and symbol stripping:
     - `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk`
     - `build/app/outputs/flutter-apk/app-armeabi-v7a-prod-release.apk`
     - `build/app/outputs/flutter-apk/app-x86_64-prod-release.apk`
   - Installed `app-arm64-v8a-prod-release.apk` directly to the connected device via adb.
