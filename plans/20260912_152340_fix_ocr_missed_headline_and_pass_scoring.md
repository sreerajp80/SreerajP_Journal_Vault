# Plan — Fix OCR missing the headline (inverted text) and stop first-pass-wins

**Status:** completed

## The issue

In the OCR preview the recognizer returned only the small print line
(`ആഗസ്റ്റ് 2026 വാല്യം 42 ... വില 12 രൂപ`, 12 words) plus a stray `|`.
The large masthead word at the top was not read at all.

Three separate causes:

1. **Light text on a dark band is never read.** Tesseract and its Leptonica
   binarizer assume dark ink on light paper. The masthead is light letters on a
   dark band, so after binarization it becomes background and is dropped. The
   app never tries the inverted image.
2. **The first pass always wins.** In
   `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`
   (`performTesseractOcr`) the PSM fallback chain only runs when the previous
   pass returned an *empty* string. `PSM_AUTO` returned the small line, so the
   better modes (`SINGLE_BLOCK`, `SPARSE_TEXT`) were never tried. A partial
   result is never improved on.
3. **No DPI hint and no spacing variable.** Tesseract guesses resolution from
   the bitmap. For a resized PNG that guess is wrong and the LSTM line model
   loses accuracy — this is what turns ligature marks into stray `ല`, `ര`, `|`.

A stylised logo/display font may still not be readable even after this. That is
a limit of `mal.traineddata`, not a bug. The fix below is what makes the app try
properly instead of giving up after one pass.

## Files to change

| File | Change |
|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Replace the empty-only fallback chain with scored multi-pass recognition; add an inverted-bitmap pass; set `user_defined_dpi` and `preserve_interword_spaces`. |
| `lib/features/entries/services/ocr_enhancer.dart` | Make `documentBw` normalise levels before the contrast lift, so ink goes to true black and paper to true white instead of mid-grey. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | One new string for an "Invert (light text on dark)" switch on the enhance screen, with `@key` descriptions. |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Add the invert toggle so the user can force it when auto-detection is wrong. |
| `test/features/entries/services/ocr_enhancer_test.dart` | Cover the invert and normalise behaviour. |

## The fix, in detail

### 1. Score the passes instead of taking the first non-empty one

In `performTesseractOcr`, run a small list of candidates and keep the best:

- `PSM_AUTO` on the bitmap
- `PSM_SINGLE_BLOCK` on the bitmap
- `PSM_SPARSE_TEXT` on the bitmap
- the same three on the **inverted** bitmap, but only when the image is
  dark-dominant (mean luminance below ~110) — this keeps the normal, light-page
  case at the current speed.

Score each candidate as `meanConfidence() * (number of recognised words)`.
`TessBaseAPI.meanConfidence()` is already available in Tesseract4Android. Keep
the highest-scoring text. Stop early when a pass scores above a clear threshold,
so a clean page still finishes in one pass.

### 2. Inverted pass

Invert with a `ColorMatrixColorFilter` on a canvas (cheap, no per-pixel Dart
loop). Compute mean luminance by sampling a downscaled copy of the bitmap, not
every pixel.

### 3. Tesseract variables

Before recognition:

- `tess.setVariable("user_defined_dpi", "300")` — stops the wrong resolution
  guess on our resized PNGs.
- `tess.setVariable(TessBaseAPI.VAR_USE_CJK_FP_MODEL, ...)` not needed; instead
  `tess.setVariable("preserve_interword_spaces", "1")` so word gaps survive.

### 4. Cleaner binarisation in the enhancer

`OcrEnhanceFilter.documentBw` currently does `grayscale` then `contrast: 130`,
which leaves a grey background. Add a luminance normalise step (stretch the
5th–95th percentile to full range) before the contrast lift, so the page becomes
white and the ink black. This is what the "Document" filter is expected to do
and it helps every later pass.

### 5. Manual invert toggle

Auto-detection can be wrong on a mixed page (dark masthead, light body). Add an
"Invert" switch to the enhance screen so the user can force the polarity, using
new ARB keys in both `app_en.arb` and `app_ml.arb`.

## Out of scope

- Swapping in `tessdata_best` for `mal.traineddata`. It would raise Malayalam
  accuracy but adds app size and is a separate decision. Noted here as a
  follow-up.
- Any change to the camera screen or the crop flow.

## Checks after implementing

- `flutter analyze` clean
- `flutter test`
- `flutter gen-l10n` after the ARB edit
- Manual: run the same masthead photo through the enhance screen and confirm the
  large word is attempted and the stray `|` is gone.
