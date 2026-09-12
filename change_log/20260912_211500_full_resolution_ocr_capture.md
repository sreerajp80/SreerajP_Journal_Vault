# Change log — Full camera resolution, orientation and rotation for OCR

**Plan:** `plans/20260912_191251_full_resolution_ocr_capture.md`
**Date:** 2026-09-12

## Why

OCR was reading a much smaller image than the camera could give it, in two
separate places:

1. The camera captured at `ResolutionPreset.veryHigh` — 1920x1080 on Android,
   about 2 megapixels from a sensor that is usually 12 MP or more.
2. The enhance pipeline then shrank the longest edge to 1800 px before
   recognition, so even that 1080p capture was reduced again.

Because of the second limit, raising the camera resolution alone would have
changed nothing at all. Both had to move together.

Fewer pixels per character is the main reason thin marks and Malayalam vowel
signs go missing, so this is the largest single lever on recognition accuracy.

## What changed

### Capture at full sensor resolution

`lib/features/entries/presentation/ocr_camera_screen.dart` now asks for
`ResolutionPreset.max`. The existing start-up retry loop was turned into a list
of attempts: `max`, `max`, then `veryHigh`. The first two cover the case where
the camera hardware is still held by the screen the user just came back from,
which is worth one more try before giving up resolution. The third is the
fallback for devices where `max` is unsupported or too slow to start. The failure
log now names the preset that was tried.

Note on what this actually yields: `max` is the largest size the camera2 API
reports. On many phones sold as 50 MP, that is the 12 MP binned output, because
the vendor exposes the full mode only to its own camera app. The app uses
whatever the device genuinely offers.

### New service: shrink the capture natively, once

Added `lib/features/entries/services/ocr_capture_downscaler.dart`, ported from
the sibling todo app rather than written fresh. It:

- reads the image **header only** to get the stored size, so measuring a large
  file costs nothing;
- decodes through `ui.instantiateImageCodec` with `targetWidth`, so the platform
  codec subsamples while decoding and the full pixel buffer never exists in the
  Dart heap;
- probes whether the platform codec applies EXIF rotation itself, instead of
  assuming;
- applies any remaining rotation and writes a lossless PNG in a background
  isolate;
- returns the original path untouched whenever the photo is already small and
  upright, or anything fails.

This matters for memory. A 50 MP photo is about 8160x6120, which the `image`
package would decode to roughly 200 MB of raw RGBA, and the enhance pipeline
makes several copies. Handing a full-size photo to the existing isolate would
have crashed the app.

Adaptations from the source: package imports, and `AppLogger` in place of
`debugPrint`, which this app forbids. Only image dimensions are logged, never
content. **Behaviour is otherwise unchanged from the ported original.**

### Wiring

- `lib/features/entries/providers/ocr_providers.dart` gained
  `ocrCaptureDownscalerProvider`.
- `lib/features/entries/presentation/ocr_enhance_screen.dart` now prepares a
  working copy once, in a new `_prepareMaster()`, before the first enhancement.
  Everything downstream reads that copy. The screen starts in its busy state,
  because preparing the copy is an async step that now happens before the first
  enhancement. A new `captureDownscaler` parameter allows injection in tests.

### Raised the cap that was undoing everything

`maxOcrDimension` in `lib/features/entries/services/ocr_enhancer.dart` went from
1800 to 3000. `kOcrMaxLongEdge` in `ocr_image_preprocessor.dart` was already
3000 and is unchanged, so the two now agree.

### Crop editor no longer forced into portrait

`android/app/src/main/AndroidManifest.xml` had
`android:screenOrientation="portrait"` on the uCrop activity. Removed, with a
comment saying why. Forcing portrait letterboxed a landscape photo of a wide page
into a small viewport — the one crop that most needs room, and the exact flow
this change is for. The editor now follows the device, like the rest of the app.

## Orientation and rotation, end to end

The chain is now:

- capture, with the EXIF tag written by the camera
- downscaler: native decode, EXIF applied **exactly once**, written as PNG
- enhancer: `bakeOrientation` on a PNG is a no-op, then the user's 90° steps
- OCR

This is only safe because of the codec probe. Some Android codecs apply EXIF
rotation during decode and some do not; assuming either way turns the photo
twice on half of devices, which the user then has to undo by hand.

`lockCaptureOrientation` is deliberately still not called. The EXIF path already
delivers a sideways photo upright, and locking capture orientation would break
that.

## Tests

Added `test/features/entries/services/ocr_capture_downscaler_test.dart`:

- the rotation step leaves an image alone when there is nothing to apply, and
  swaps the sides when a quarter turn is asked for — this is where a double turn
  would show up, so it is tested directly rather than through the platform codec;
- output is PNG, not JPEG;
- a small upright photo is passed through untouched;
- a photo over the long-edge cap comes back shrunk;
- an unreadable header and a missing file both fall back to the original path.

Updated `test/features/entries/presentation/ocr_enhance_screen_test.dart`: the
three existing tests now inject a pass-through downscaler, and a new test proves
enhancement reads the shrunk working copy rather than the original capture.

`flutter analyze` is clean. All 840 tests pass. `dart format` run over `lib`,
`test` and `integration_test`.

## Deviations from the plan

1. **The downscaler is one file in `services/`, not a `domain/` contract plus a
   `services/` implementation.** This app has no `lib/features/entries/domain/`
   folder, and `ocr_image_preprocessor.dart` and `image_edit_service.dart` both
   already keep a contract and its implementation in one file. Creating a folder
   for a single file would have been the restructuring the rules forbid.

2. **Item B.4, rotating the camera controls in landscape, was dropped.** Its
   premise was wrong. The app is not orientation-locked anywhere — `MainActivity`
   has no `screenOrientation` and no Dart code calls `setPreferredOrientations` —
   so the whole UI already turns with the device and the controls are upright in
   landscape on their own. Adding a rotation would have turned them a second time
   and caused the very bug the item meant to fix.

## Still open

- **The 3000 px cap is a starting point, not a settled number.** It needs
  measuring on a real mid-range device: too slow, and 2400 is the fallback, still
  a large gain over 1800. This cannot be judged from tests.
- The camera controls panel sits at a fixed `bottom: 180`, which may crowd the
  bottom bar on a short landscape screen. Needs a device to judge.
- The sibling todo app has the same 1800 cap cancelling out its own
  full-resolution capture. Fixing it needs its own plan, in its own repository.

## Rules

No new dependency. No schema change, so no migration. Nothing logged but image
dimensions. Changes stayed inside the OCR feature and one manifest attribute.
