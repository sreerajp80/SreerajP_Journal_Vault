# Plan — OCR accuracy: script detection, image clean-up, blur warning

**Status:** completed
**Change log:** `change_log/20260918_074500_ocr-accuracy-image-cleanup.md`
**Date:** 2026-09-18

## The issue

OCR is still not good enough, even for English. The engine is Tesseract 5.5.1
(inside `tesseract4android` 4.9.0) with the `tessdata_best` models. The model
is not the problem. The problem is what we feed it and how we set it up:

1. **Wrong language mix for English pages.** The default language is `eng+mal`.
   With both models loaded, Tesseract often reads English letters as Malayalam
   shapes. On an English page this causes many wrong words.
2. **Uneven light is not handled.** Tesseract turns the image into pure black
   and white before reading ("binarization"). Its default method (Otsu) uses one
   threshold for the whole page. A phone photo is darker in one corner than in
   another, so parts of the text get lost or turn into blobs.
3. **Tilted text is not straightened.** A tilt of even 2–3 degrees makes
   Tesseract's line finding worse.
4. **Blurry photos are not caught.** A shaky photo cannot be read well by any
   engine, and the user is never told.

## What will change

Four slices. Each can be tested on its own. They follow the suggested order:
the first two are small and should show most of the gain.

### Slice 1 — Better binarization (native, tiny)

In `performTesseractOcr`, set Tesseract's adaptive Sauvola binarization. It
picks a threshold for each small area of the page, not one for the whole page:

```kotlin
tess.setVariable("thresholding_method", "2")       // Sauvola
tess.setVariable("thresholding_window_size", "0.33")
tess.setVariable("thresholding_kfactor", "0.34")
```

The setting is present in the bundled 5.5.1 library (checked in the `.aar`).

### Slice 2 — Automatic English detection (native)

Only when the language is `eng+mal` (the default "English + മലയാളം" choice):

1. Run the first pass with `eng+mal`, as today.
2. Count the readable words that contain Malayalam letters.
3. If fewer than 10% of readable words are Malayalam (`ENGLISH_PAGE_MAX_MALAYALAM_SHARE`),
   read the page again with `eng` only. Keep whichever reading scores better.
4. If the page really is Malayalam or mixed, nothing changes.

To avoid reloading a 15 MB model every time the language switches, keep **two**
cached `TessBaseAPI` objects: one for the chosen language and one for `eng`.
Both are freed in `onDestroy`, as the single one is today.

The choices "English" and "മലയാളം" are not touched. They still run only that
language.

### Slice 3 — Native image clean-up with Leptonica (native)

Leptonica is the image library Tesseract itself uses. It is already bundled in
`tesseract4android` (`com.googlecode.leptonica.android`), so **no new
dependency**. Before `setImage`, one new function `prepareForOcr(bitmap)`:

1. `ReadFile.readBitmap` → `Convert.convertTo8` (grayscale).
2. `AdaptiveMap.backgroundNormMorph` — flattens shadows and uneven light, so
   the paper becomes one even tone.
3. `Skew.deskew` — measures the tilt and straightens it. Only small angles
   (under about 7 degrees) are corrected. Bigger rotation is still the user's
   job with the rotate buttons.
4. `Enhance.unsharpMasking` with gentle settings — sharpens soft letter edges.
5. Pass the result to `tess.setImage(pix)` as a `Pix` (Leptonica's image type),
   not a `Bitmap`.

Every `Pix` is `recycle()`d in a `finally` block, so a failure cannot leak
native memory. If any step fails, the code logs a message with no content and
falls back to today's path, so a scan never gets worse than it is now.

The dark-image (inverted) pass keeps working: the inverted bitmap goes through
the same `prepareForOcr`.

### Slice 4 — Blur warning (Dart)

- **New service** `lib/features/entries/services/ocr_blur_detector.dart`
  (service layer). It shrinks the working copy to about 1000 px, then measures
  sharpness with the variance of the Laplacian (a standard blur score: a sharp
  photo has strong edges and a high score). It runs in a background isolate.
  The file path is never logged.
- **Provider** `ocrBlurDetectorProvider` in `ocr_providers.dart`.
- **Enhance screen:** after `_prepareMaster()` finishes, run the check once. If
  the photo looks blurry, show a short `SnackBar`: *"Photo looks blurry. Retake
  it for better text."* It is only a warning. The user can still continue.
- The threshold is a named constant (`kOcrBlurThreshold`), tuned on a device.

## Files to change

| File | Layer | Change |
|---|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Platform (native) | Slices 1–3: Sauvola settings, English detection with a second cached `TessBaseAPI`, `prepareForOcr` with Leptonica, new constants |
| `lib/features/entries/services/ocr_blur_detector.dart` | Service | **New.** Blur score |
| `lib/features/entries/providers/ocr_providers.dart` | Provider | `ocrBlurDetectorProvider` |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Presentation | Run the blur check after the image is ready, show the warning |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | l10n | New key `errorOcrPhotoBlurry` (with its `@` description in the English file) |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | Presentation | One help bullet: hold still, good light, and "English + മലയാളം" now detects English pages |
| `lib/l10n/*.arb` | l10n | New key `helpOcrAutoEnglish` |
| `test/features/entries/services/ocr_blur_detector_test.dart` | Test | **New.** A sharp synthetic image scores above the threshold; the same image blurred scores below |
| `test/features/entries/presentation/ocr_enhance_screen_test.dart` | Test | Blurry photo shows the warning; sharp photo does not; the check never blocks insert |
| `docs/architecture.md` | Docs | OCR pipeline section: new native steps and the blur check |

Proposed translations (need native-reader review):

- `errorOcrPhotoBlurry` — ml: "ഫോട്ടോ മങ്ങിയതാണ്. നല്ല വായനയ്ക്ക് വീണ്ടും എടുക്കുക." —
  sa: "छायाचित्रम् अस्पष्टम्। शुद्धपठनाय पुनः गृहाण।"
- `helpOcrAutoEnglish` — written in all three languages during implementation,
  checked with `tool/check_sanskrit_markers.sh`.

## What does NOT change

- No new dependency, no permission, no network use. Hard rules 1–3 hold.
- No database or schema change.
- The model files and `TESSDATA_VERSION` stay as they are.
- The Dart pre-processing and enhance filters stay as they are. The native
  clean-up works on whatever image they produce.
- The ML Kit fallback path is unchanged.
- Nothing about the image or text is logged. Only lengths, scores and timings.

## Out of scope (possible later work)

- Text-height normalization (rescale so letters are about 30 px tall). Worth
  doing after this plan, once we see how much slices 1–3 help.
- Automatic page-edge crop and perspective correction. Needs OpenCV or a Google
  scanner library, which is a bigger decision.
- Using ML Kit for English. Needs a separate privacy decision about Google's
  `datatransport` component.

## Acceptance criteria

1. An English page photographed with "English + മലയാളം" selected gives the
   same or better text than with "English" selected, and clearly better than
   today.
2. A Malayalam page and a mixed page are read at least as well as today.
3. A page with a shadow across it, or tilted by a few degrees, reads better
   than today.
4. A shaky photo shows the blur warning; a sharp one does not.
5. Reading time on a normal page goes up by no more than about 1 second.
6. `flutter analyze` is clean, `flutter test` passes, `dart format` is clean,
   `sh tool/check_sanskrit_markers.sh` passes, and Kotlin compiles
   (`:app:compileDevDebugKotlin`).

## Testing on a device (cannot be automated here)

The native steps have no Kotlin unit tests, as today. Please check with the
same photos before and after: an English page, a Malayalam page, a mixed page,
a shadowed page, a tilted page, and a close-up of two or three lines.

## Order of work

Slice 1 → build and test on a device → Slice 2 → test → Slice 3 → test →
Slice 4. If slices 1–2 already solve the English problem, we can stop and
review before going on.
