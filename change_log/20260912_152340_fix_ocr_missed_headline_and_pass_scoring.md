# Change log — Fix OCR missing the headline (inverted text) and stop first-pass-wins

**Plan:** `plans/20260912_152340_fix_ocr_missed_headline_and_pass_scoring.md`
**Date:** 2026-09-12

## What was wrong

Scanning a page with a large title band returned only the small print line and
missed the title completely. Three causes:

1. Light lettering on a dark band was never read. Tesseract's binarizer assumes
   dark ink on light paper, so a dark band becomes background and its text is
   thrown away.
2. The page segmentation fallback chain only ran when the previous pass returned
   an **empty** string. The first mode found the small line, so the better modes
   were never tried. A partial reading could never be improved on.
3. No DPI was declared, so Tesseract guessed the resolution of our resized PNGs
   wrongly and the line model lost accuracy on vowel signs and ligatures.

## What changed

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

- `performTesseractOcr` now **scores** every pass instead of taking the first
  non-empty one. Each of `PSM_AUTO`, `PSM_SINGLE_BLOCK` and `PSM_SPARSE_TEXT`
  runs, is scored as `meanConfidence() x word count`, and the best reading wins.
  A pass scoring above `CONFIDENT_SCORE` stops the loop, so a clean page still
  finishes in one pass and is no slower than before.
- New `invertBitmap` and `meanLuminance` helpers. When the image is
  dark-dominant (mean luminance below `DARK_IMAGE_LUMINANCE`), the three modes
  are run against an inverted copy as well and scored alongside the rest. This
  is what recovers light-on-dark titles. Luminance is measured on a 32x32
  sampled copy, not pixel by pixel. Inversion uses a `ColorMatrixColorFilter` on
  a canvas. A normal light page skips all of this.
- Sets `user_defined_dpi=300` and `preserve_interword_spaces=1` after init.
- New private helpers `scoreRecognition` and the `OcrPass` data class; new file
  level constants `SAMPLE_EDGE`, `DARK_IMAGE_LUMINANCE`, `CONFIDENT_SCORE` and
  `PAGE_SEG_MODES`.
- Both bitmaps are recycled in the `finally` block.

### `lib/features/entries/services/ocr_enhancer.dart`

- New `normalizeOcrLevels` top-level function. It stretches a grayscale image's
  tones so the darkest 5% go to black and the lightest 5% to white, ignoring
  outliers via `kOcrLevelClipFraction`. An image whose tone range is under 16
  levels is left alone, so a blank page is not amplified into fake ink.
- `OcrEnhanceFilter.documentBw` now calls `normalizeOcrLevels` before its
  contrast lift. Previously a photographed page kept a grey cast and the
  contrast lift darkened paper and ink together.
- New `OcrEnhanceParams.invert` flag (default `false`), included in `copyWith`.
  It is applied after rotation and before the filter, so the filter always sees
  dark ink on light paper.

### `lib/features/entries/presentation/ocr_enhance_screen.dart`

- New `_invert` state field, passed to `OcrEnhanceParams`.
- New "Invert" toolbar toggle (`Key('ocr-invert-btn')`, `Icons.invert_colors`)
  next to the filter tab. It re-runs enhancement immediately. This lets the user
  force the polarity when the automatic detection is wrong, such as a page with
  a dark title band over a light body.

### `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`

- New `ocrEnhanceInvert` key with its `@ocrEnhanceInvert` description, plus the
  Malayalam translation. `flutter gen-l10n` re-run.

### `test/features/entries/services/ocr_enhancer_test.dart`

Four new tests:

- `invert` flips light and dark.
- `documentBw` pulls a grey-cast page apart to near black and near white.
- `normalizeOcrLevels` stretches a narrow tone range to the full scale.
- `normalizeOcrLevels` leaves a nearly flat image untouched.

## Checks run

- `flutter analyze` — no issues found
- `flutter test` — 826 tests, all passed
- `dart format lib test integration_test` — clean
- `flutter gen-l10n` — re-run after the ARB edit
- `./gradlew :app:compileProdDebugKotlin` — compiled with no errors

## Known limit

A stylised logo or display typeface may still not be recognised. `mal.traineddata`
is trained on normal printed text, not display lettering. This change makes the
app try properly rather than give up after one pass; it cannot teach the model a
font it has never seen.

## Follow-up not done

Switching `mal.traineddata` to the `tessdata_best` build would raise Malayalam
accuracy further, at the cost of app size. Left as a separate decision.
