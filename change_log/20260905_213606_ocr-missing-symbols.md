# OCR — recover the missing `=`, `.` and other small signs

Implements `plans/20260905_213606_ocr-missing-symbols.md`.

## Why

Scanned photos came back with the `=` sign, the `.` sign and other thin marks
missing. Two causes, both on our side:

1. The photo went to the recognizer exactly as taken. A `.` or `=` in a normal
   phone photo of a page is only a few pixels tall — below the height at which
   the recognizer will report a character at all. The crop step also re-encoded
   to JPEG at quality 90, and JPEG blur eats those one-pixel strokes.
2. We flattened the result with `recognizedText.text`, which joins the
   recognizer's *blocks* with newlines. A lone symbol such as `=` almost always
   comes back as its own block, so `x = 5` arrived as three separate lines.

## What changed

**New — `lib/features/entries/services/ocr_image_preprocessor.dart`**
`OcrImagePreprocessor` and its `ImagePackageOcrPreprocessor` implementation.
Before recognition the photo is decoded, its EXIF rotation baked in, enlarged
with cubic interpolation until the short edge reaches 1200 px (capped so the
long edge never grows past 3000 px), converted to grayscale, given a mild
contrast lift, and written as lossless PNG to a temp file. The enlargement is
what lifts `.` and `=` above the detection floor. The work runs in a background
isolate through `compute`, so the UI does not stutter. If anything fails it
returns `null` and logs — preparation is an optimisation, never a requirement.

**`lib/features/entries/services/ocr_service.dart`**
- `MlKitOcrService` now takes an `OcrImagePreprocessor` and runs two passes:
  the prepared image first, and the untouched photo as a fallback when the
  prepared one reads blank. The longer result wins.
- New `assembleRecognizedText()` replaces `recognizedText.text`. It walks every
  `TextLine`, sorts them top to bottom then left to right, and merges lines that
  overlap vertically by more than half a line height into one visual row. `x`,
  `=` and `5` land back on a single line, and side-by-side columns keep their
  reading order.
- The service deletes its own prepared temp file in a `finally` block. (The plan
  had put this cleanup in the editor screen; doing it where the file is created
  is simpler and leaves the screen untouched.)

**`lib/features/entries/providers/ocr_providers.dart`**
New `ocrImagePreprocessorProvider`, wired into `ocrServiceProvider`.

**`lib/features/entries/services/image_edit_service.dart`**
The crop step now asks for `ImageCompressFormat.png` at quality 100 instead of
the default JPEG at 90, so it stops degrading thin strokes before OCR sees them.

**`pubspec.yaml` and `docs/dependencies.md`**
Added `image: ^4.5.4` (resolved 4.8.0) — pure Dart, decode/resize/filters only,
no networking dependency, so it stays inside the no-cloud rule.

## Tests

- **New** `test/features/entries/services/ocr_image_preprocessor_test.dart` —
  small photos are enlarged past the minimum short edge, the long-edge cap is
  respected, an oversized photo is never shrunk, output is grayscale, and a file
  that is not an image reports failure without writing anything.
- `test/features/entries/services/ocr_service_test.dart` — new cases for the
  line assembler (a lone `=` stays on its row, row and column ordering, real
  line breaks are kept, blanks dropped) and for the two-pass flow, driven
  through a mocked ML Kit method channel.

`flutter analyze` clean. Full `flutter test` suite green (809 tests).

## Limits

The recognition model itself is unchanged. If a sign is missing because the
handwriting is unclear or the model has no confident reading, it will still be
missing. What is fixed is the part we control: resolution, compression and block
flattening.

## Still worth doing by hand

Scan a real photo containing `x = 5`, `3.14` and `a, b; c` on a device and check
the signs arrive intact and on one line.
