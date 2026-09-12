# Plan: Fix OCR Disappearing After Image Processing and Improve Cropped Text Recognition

**Status:** Completed

## Problem

1. **OCR text disappears after processing/cropping:**
   When the user takes a photo, the initial uncropped photo shows recognized text in the OCR preview. However, after the user "processes" the image (crops it to a specific snippet, adjusts contrast, or applies a document filter), the live OCR preview displays: *"No text was detected in the image" (ചിത്രത്തിൽ ടെക്സ്റ്റ് കണ്ടെത്താൻ കഴിഞ്ഞില്ല)*.
   
2. **Root Cause Analysis:**
   - **Page Segmentation Mode (`PSM_AUTO`):** In `MainActivity.kt`, the native Tesseract engine is hardcoded to `PSM_AUTO` (Mode 3). `PSM_AUTO` assumes a full document page with multiple paragraphs and standard page margins. When an image is cropped down into a single horizontal strip, snippet, or banner, `PSM_AUTO` fails to detect document structure and returns an empty string (`""`).
   - **Lack of quiet zone / margin on crops:** UCrop produces tight crops where characters or dark edges touch the image border directly. Tesseract's binarizer treats border-connected blobs as page borders or image frames, suppressing text recognition.
   - **Loss of fine strokes under high contrast:** In `ocr_enhancer.dart`, the `documentBw` filter applied `contrast: 165` which can over-threshold thin Malayalam vowel signs and digits on small cropped text.
   - **Stylized / outline fonts:** Giant decorative titles with hollow interiors are treated as illustrations rather than characters, and when combined in a crop with small text, they drown out the small text.

## Proposed Fix

1. **Native Tesseract Multi-Mode Fallback (`MainActivity.kt`):**
   - Automatically add a clean white quiet-zone padding (e.g., 20–30px) around the input bitmap before passing to Tesseract. This allows Tesseract's binarizer and connected component analysis to properly identify characters without border collision.
   - Implement automatic segmentation fallback:
     1. Try `PSM_AUTO` (Mode 3) for full pages.
     2. If `PSM_AUTO` yields no text (empty string), immediately retry with `PSM_SINGLE_BLOCK` (Mode 6) — the standard mode for cropped snippets, columns, and receipts.
     3. If still empty, retry with `PSM_SPARSE_TEXT` (Mode 11) for sparse or single-line text banners.
   - All retries run on the existing background thread (`ocrExecutor`), taking only ~15–30 ms, without freezing the UI or slowing down the phone.

2. **Image Enhancer & Filter Calibration (`ocr_enhancer.dart`):**
   - Calibrate the `documentBw` and `enhance` filter contrast curves so that fine character strokes on cropped text are preserved rather than washed out.
   - When processing an already small cropped image, avoid downscaling so small text resolution (x-height) is preserved.

3. **Fallback to ML Kit if Native Tesseract returns empty on Latin/Numeric receipts:**
   - In `ocr_service.dart`, ensure that if native Tesseract produces an empty result on a crop, it gracefully evaluates fallback if appropriate.

## Files to Change

### Modified Files
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`:
  - Add bitmap white-border padding helper.
  - Implement sequential PSM fallback (`PSM_AUTO` -> `PSM_SINGLE_BLOCK` -> `PSM_SPARSE_TEXT`).
- `lib/features/entries/services/ocr_enhancer.dart`:
  - Tune filter contrast curves to preserve character legibility on cropped snippets.
- `test/features/entries/services/ocr_service_test.dart`:
  - Add test cases covering cropped snippet recognition and fallback.

## Verification Plan

1. **Automated Tests:**
   - Run `flutter analyze` (must be 0 issues).
   - Run `dart format lib test` (must remain clean).
   - Run `flutter test test/features/entries/services/ocr_service_test.dart`.
   - Run `flutter test test/features/entries/presentation/ocr_enhance_screen_test.dart`.
   - Run full test suite `flutter test`.

2. **Manual Verification on Device:**
   - Verify on the connected device that taking a photo and cropping a single line or snippet keeps recognized text visible in the OCR preview.
   - Test both "English + മലയാളം" and "മലയാളം" modes on cropped document snippets.
