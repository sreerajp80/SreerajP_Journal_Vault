# Change log — OCR accuracy: script detection, image clean-up, blur warning

**Plan:** `plans/20260918_070527_ocr-accuracy-image-cleanup.md`
**Date:** 2026-09-18

## Summary

OCR was still weak, even on English pages. The engine (Tesseract 5.5.1, with
`tessdata_best` models) was not the cause. The cause was how photos were fed to
it. Four changes, all in one pass, as approved:

1. **Sauvola thresholding.** Tesseract now picks a black/white threshold for
   each small area of the page, not one for the whole photo. Shadowed corners
   no longer turn into blobs or vanish.
2. **Automatic English detection.** With "English + മലയാളം" chosen, a page
   where fewer than 10% of words are Malayalam is read again with the English
   model alone. The English reading wins unless its score is below 90% of the
   bilingual one. The "English" and "മലയാളം" choices are unchanged.
3. **Image clean-up with Leptonica** (the image library bundled inside
   Tesseract). Before reading: grayscale → background normalisation (flattens
   shadows and uneven light) → deskew up to 7° → gentle unsharp mask. Each step
   is skipped if it fails. If the cleaned image gives no text at all, the
   untouched photo is read as before, so no scan can end up worse than today.
4. **Blur warning.** When the scan screen opens, the photo's sharpness is
   measured. A blurry photo shows "Photo looks blurry. Retake it for better
   text." It is advice only. The user can still continue.

## Files

| File | Layer | Change |
|---|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Platform (native) | `configureTess` (DPI, spaces, Sauvola); `prepareForOcr` (Leptonica clean-up, every `Pix` recycled); `runPasses` (the old pass loop, now over `Pix`); `malayalamWordShare`; English re-read with a second cached `TessBaseAPI` (`englishTessApi`, freed in `onDestroy`); untouched-photo fallback; new named constants. The unused `OcrPass` class is gone |
| `lib/features/entries/services/ocr_blur_detector.dart` | Service | **New.** `OcrBlurDetector` contract and `NativeOcrBlurDetector`. Shrinks the photo to 1000 px with the platform codec, then in an isolate scores the Laplacian variance of 64 px tiles that have content, taking the top 10% tile. Blank pages are never flagged. Logs only the yes/no result |
| `lib/features/entries/providers/ocr_providers.dart` | Provider | `ocrBlurDetectorProvider` |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Presentation | Optional injected `blurDetector` for tests |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Presentation | `_warnIfBlurry` runs once after the working copy is ready and shows a `SnackBar` |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | Presentation | New help bullet |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ generated `app_localizations*.dart`) | l10n | New keys `errorOcrPhotoBlurry`, `helpOcrAutoEnglish` |
| `docs/architecture.md` | Docs | Section 14: the OCR native pipeline and the blur check |
| `docs/dependencies.md` | Docs | `tesseract4android` 4.9.0 bundles Tesseract 5.5.1 and Leptonica, now also used for clean-up |

No new dependency, permission, network use or schema change. The model files
and `TESSDATA_VERSION` are unchanged.

## Localization

**Needs native-reader review:**

- `errorOcrPhotoBlurry` — ml "ഫോട്ടോ മങ്ങിയതാണ്. നന്നായി വായിക്കാൻ വീണ്ടും എടുക്കുക." —
  sa "चित्रम् अस्पष्टम्। शुद्धपठनाय पुनः गृहाण।"
- `helpOcrAutoEnglish` — the whole Malayalam and Sanskrit sentences. In
  Sanskrit, especially `वृतम्` for "chosen", `अधिकशुद्ध्यै` and `उपयुङ्क्ष्व`.

## Tests

- `test/features/entries/services/ocr_blur_detector_test.dart` — **new**. Sharp
  synthetic print scores above the threshold. The same print blurred scores
  below it. Blurring always lowers the score. A blank page and a mostly blank
  page with a little sharp text are not called blurry. Gray conversion weights.
- `test/features/entries/presentation/ocr_enhance_screen_test.dart` — a blurry
  photo shows the warning and insert stays available; a sharp photo shows none.
- `test/features/entries/presentation/ocr_enhance_test_fakes.dart` —
  `FakeOcrBlurDetector`.

## Checks run

- `flutter analyze` — no issues.
- `flutter test` — all 934 tests passed.
- `dart format lib test integration_test` — clean.
- `sh tool/check_sanskrit_markers.sh` — passed.
- `sh tool/check_absolute_paths.sh --all` — passed.
- Kotlin compiles (`:app:compileDevDebugKotlin`).

## Not tested here — needs a real device

The native changes have no Kotlin unit tests, as before. Please compare the
same photos before and after:

- an English page with "English + മലയാളം" and with "English";
- a Malayalam page and a mixed page (must be no worse than before);
- a page with a shadow across it, and a page tilted a few degrees;
- a close-up of two or three lines;
- a dark banner or slide (the inverted pass still works);
- a shaky photo (warning shows) and a sharp one (no warning). The blur
  threshold `kOcrBlurThreshold` (120) may need tuning on real photos;
- reading time on a normal page: an English page read with
  "English + മലയാളം" now takes a second recognizer run, and the first scan
  after app start also loads the English model once.
