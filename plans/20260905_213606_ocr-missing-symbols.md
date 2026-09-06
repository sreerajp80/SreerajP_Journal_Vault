# Enhance OCR — missing `=`, `.` and other small signs

**Status:** completed

## The issue

When a photo is scanned with "Scan text from photo", small marks are often lost or
misplaced. Reported: the `=` sign and the `.` sign go missing. The same happens with
other thin, low-ink characters — `,` `:` `;` `-` `_` `+` `*` `/` `%` `(` `)` and
similar.

There are two separate causes, and both are in our control:

1. **The image we hand to ML Kit is not prepared for OCR.**
   Today the flow is: pick photo → crop/rotate → send that file straight to
   `TextRecognizer`. A `.` or `=` in a normal phone photo of a page is only a few
   pixels tall. ML Kit's Latin model needs roughly 24 px of glyph height to detect a
   character at all, so the thinnest marks fall below the detection floor and are
   simply not reported. Bigger letters around them still read fine, which is why the
   text "looks right but the signs are gone". The cropper also re-encodes to JPEG at
   quality 90, and JPEG blur eats exactly these one- or two-pixel strokes.

2. **We flatten the result with `recognizedText.text`.**
   ML Kit groups what it finds into blocks. A lone symbol such as `=` between two
   words is very often returned as its **own block**. `recognizedText.text` joins
   blocks with a newline, so `x = 5` comes back as three lines — the `=` is not
   missing, but it is on a line of its own and reads as lost or wrong. The same
   flattening puts side-by-side columns in the wrong order.

## The fix

### 1. Prepare the image before recognition (new service)

Add `lib/features/entries/services/ocr_image_preprocessor.dart` — an
`OcrImagePreprocessor` contract plus an implementation that, fully on-device:

- decodes the file and bakes in the EXIF rotation,
- **upscales** with cubic interpolation so the short edge is at least 1200 px
  (this is the step that lifts `.` and `=` above the detection floor), while
  capping the long edge at 3000 px so memory stays sane,
- converts to **grayscale** and applies a mild **contrast/normalise** pass so thin
  strokes separate from the paper,
- writes the result as **PNG** (lossless — no JPEG smearing of thin marks) into the
  app's temp directory and returns the path.

All of it is pure computation, no network. The heavy decode/resize runs in an
isolate via `compute` so the UI does not jank.

If anything fails, it returns the original path and logs a warning — preprocessing
must never break a scan.

### 2. Recognise twice and keep the better result

In `MlKitOcrService`:

- run recognition on the preprocessed image first,
- if that returns nothing, retry once on the original file,
- keep whichever pass produced more text.

This is the safety net for the rare photo that preprocessing does not suit.

### 3. Rebuild the text from lines, not blocks

Replace the `recognizedText.text` shortcut with a small assembler:

- collect every `TextLine` from every block,
- sort them top-to-bottom, then left-to-right,
- **merge lines that sit on the same visual row** (their vertical centres overlap
  by more than half a line height) into one line, joined with a space.

That puts `x`, `=` and `5` back on one line, and fixes column ordering as a bonus.

### 4. Keep the cropper lossless

In `image_edit_service.dart`, ask `image_cropper` for PNG output at full quality so
the crop step stops degrading the thin marks before OCR ever sees them.

### 5. New dependency

`image` (pub.dev, `brendan-duncan/image`, MIT). Pure Dart, decode/resize/filters
only. It has **no** networking dependency, so it stays inside the app's no-cloud
rule. Needed for step 1 — Flutter has no built-in resize/grayscale for files.

## Files to change

| File | Change |
|---|---|
| `pubspec.yaml` | add `image` |
| `lib/features/entries/services/ocr_image_preprocessor.dart` | **new** — contract + implementation |
| `lib/features/entries/services/ocr_service.dart` | preprocess, two-pass, line-based text assembly |
| `lib/features/entries/providers/ocr_providers.dart` | provide the preprocessor and wire it into `MlKitOcrService` |
| `lib/features/entries/services/image_edit_service.dart` | PNG / full-quality crop output |
| `lib/features/entries/presentation/entry_editor_screen.dart` | delete the preprocessed temp file in the existing cleanup block |
| `test/features/entries/services/ocr_service_test.dart` | tests for the line assembler and the two-pass fallback |
| `test/features/entries/services/ocr_image_preprocessor_test.dart` | **new** — upscale, grayscale, failure falls back to the original path |
| `docs/dependencies.md` | record why `image` was added |

## What this does not do

ML Kit's Latin model is fixed; we cannot teach it new glyphs. If a sign is missing
because the handwriting is unclear, or because the model has no confident reading,
it will still be missing. This change removes the causes we control — resolution,
compression and block flattening — which is where the reported `=` and `.` losses
come from.

## Checks after implementing

- `flutter analyze` clean
- `flutter test` green
- manual: scan a photo containing `x = 5`, `3.14`, `a, b; c` and confirm the signs
  arrive on one line
