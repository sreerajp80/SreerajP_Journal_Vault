# Plan — Full camera resolution, orientation and rotation for OCR

**Status:** completed
**Status note:** See the matching change log
**Revised:** 2026-09-12 20:55 — ports the proven downscaler from the sibling
todo app instead of writing a new one, and adds the orientation and rotation work.

## Goal

Capture OCR photos at the highest resolution the device offers, let that detail
reach the text recogniser, and make the rotate-then-crop step behave the way a
user expects when they photograph a page in any orientation.

## Part A — Resolution

### The problem: two limits, and fixing one alone changes nothing

1. **Capture is fixed at about 2 megapixels.**
   `lib/features/entries/presentation/ocr_camera_screen.dart` builds the
   controller with `ResolutionPreset.veryHigh`, which on Android means
   1920x1080 stills. A modern sensor is 12 to 50 megapixels.

2. **The pipeline then shrinks the photo to 1800 px.**
   `lib/features/entries/services/ocr_enhancer.dart` caps the longest edge at
   1800 (`maxOcrDimension`). Every camera photo passes through it, so even the
   current 1080p capture is reduced before recognition. Raising the camera
   preset on its own would be undone here.

The same 1800 constant exists in the sibling todo app, where it already cancels
out that app's full-resolution capture. It is the single most important number
in this plan.

A third limit, `kOcrMaxLongEdge = 3000` in
`lib/features/entries/services/ocr_image_preprocessor.dart`, never binds today
because its input is already at most 1800.

### Why it matters

Tesseract needs a minimum number of pixels per character. On a full page at
1800 px, body text has an x-height of roughly 10 to 14 px, near the floor where
thin marks and Malayalam vowel signs stop being reported at all.

### The constraint that shapes the design

A 50 MP photo is about 8160x6120. The `image` package decodes to raw RGBA in the
Dart heap, so one copy is roughly 200 MB, and `bakeOrientation`, `copyRotate` and
`copyResize` each allocate another. A full-size photo cannot be decoded in the
existing isolate. It must be shrunk by the **native** codec first.

### A.1 Port the downscaler from the todo app, do not rewrite it

The sibling project already solves exactly this, and its design is better than a
fresh attempt would be:

- Reads the image **header only** for the stored size, so measuring a 50 MP file
  costs nothing.
- Decodes through `ui.instantiateImageCodec` with `targetWidth`, so the codec
  subsamples while decoding and the huge pixel buffer never exists.
- **Probes** whether the platform codec applies EXIF rotation itself, rather than
  assuming. This is the part that must not be dropped — see Part B.
- PNG-encodes in an isolate, because encoding a 12 MP PNG blocks a frame.

Port it with these adaptations, and no behaviour changes:

| Adaptation | Reason |
|---|---|
| Package imports rewritten for this app | Different app |
| `debugPrint` replaced with `AppLogger` | This app forbids `print` and `debugPrint` |
| Contract and implementation kept in one `services/` file | Matches this app's own `ocr_image_preprocessor.dart`; there is no `entries/domain/` folder to put a contract in |
| Provider added to `lib/features/entries/providers/ocr_providers.dart` | Matches the existing OCR providers |

Only dimensions are logged, never image content.

### A.2 Capture at the maximum the device reports

In `ocr_camera_screen.dart`, request `ResolutionPreset.max`, falling back to
`veryHigh` when initialisation fails or times out. The fallback is not optional:
`max` is unsupported or very slow on some devices. The screen already has a
two-attempt retry loop to hook into.

Honest limit: `max` gives the largest size the camera2 API reports. On many
50 MP phones that is the 12 MP binned output, because the vendor exposes the
full 50 MP mode only to its own camera app. The app will use whatever the device
genuinely offers — on most phones six times today's pixel count.

### A.3 Raise the caps so the detail survives

| Constant | File | Now | Proposed |
|---|---|---|---|
| `kOcrCaptureMaxLongEdge` | new downscaler | — | 4000 |
| `maxOcrDimension` | `ocr_enhancer.dart` | 1800 | 3000 |
| `kOcrMaxLongEdge` | `ocr_image_preprocessor.dart` | 3000 | 3000, unchanged |

3000 px gives a full page an x-height of roughly 20 to 24 px, comfortably above
Tesseract's floor. **This number must be measured on a real mid-range device
before it is settled.** If recognition is too slow, the fallback position is
2400, still a large gain over 1800.

## Part B — Orientation and rotation

### B.1 The crop editor is locked to portrait, and should not be

`android/app/src/main/AndroidManifest.xml` pins the uCrop activity to
`screenOrientation="portrait"`.

So a user who photographs a wide page in landscape, then opens crop to
straighten it, gets a portrait editor with a small letterboxed viewport. That
works against the exact flow this change is for. The todo app deliberately
leaves this unset, with a comment saying the editor should follow the device.

**Change:** remove that one attribute, matching the todo app. The rest of the
app already allows both orientations.

### B.2 Double rotation is the real risk, and the probe is what prevents it

After the port the chain becomes:

- capture, with the EXIF tag set by the camera
- downscaler: native decode, EXIF applied exactly once, written as PNG
- enhancer: `bakeOrientation` on a PNG is a no-op, then the user's 90° steps
- OCR

This is safe **only** because the downscaler probes the codec. Some Android
codecs apply EXIF rotation during decode and some do not. Assuming either way
turns a photo twice on half the devices, and the user must then undo it by hand.
The probe must be ported intact, including its test.

The enhancer's own `bakeOrientation` call stays. It becomes a no-op on PNG
input, and it still protects the gallery-pick path.

### B.3 Keep capture orientation unlocked

`lockCaptureOrientation` is deliberately **not** called. The camera plugin writes
the correct EXIF orientation from the device sensor, and B.2 applies it exactly
once, so a photo shot sideways arrives upright without the user doing anything.
Locking capture orientation would break that. Recording the decision here so it
is not "fixed" later.

### B.4 Rotate the camera controls in landscape — dropped, premise was wrong

**Not implemented. The problem this described does not exist.**

Checked before writing any code: the app is not orientation-locked anywhere.
`MainActivity` has no `screenOrientation`, and no Dart code calls
`setPreferredOrientations`. So the whole Flutter UI already turns with the
device, and the camera controls are upright in landscape on their own.

Adding a rotation would have turned them a second time and put the labels on
their side — creating exactly the bug this item meant to fix. Recorded here so
it is not attempted again.

One landscape concern remains, and needs a device to judge rather than a guess:
the controls panel sits at a fixed `bottom: 180`, which may crowd the bottom bar
on a short landscape screen. Left alone for now.

### B.5 What already works and must not regress

- 90° rotate left and right in the enhance screen.
- Free-angle straightening through uCrop's own rotate wheel, for a slightly
  tilted photo. `hideBottomControls` is not set, so the wheel is available.
- The rotation angle resets to 0 after a crop, because the cropper bakes its own
  rotation. Re-applying it would turn the image twice.
- The crop is written as lossless PNG, not JPEG. JPEG blur eats the one-pixel
  strokes of `.` `,` `:` before OCR sees them.

Each of these gets a test so the change cannot quietly break them.

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/services/ocr_capture_downscaler.dart` (new) | Contract, `kOcrCaptureMaxLongEdge` and `NativeOcrCaptureDownscaler`, ported, `AppLogger` instead of `debugPrint`. Kept in **one** services file: this app has no `entries/domain/` folder, and `ocr_image_preprocessor.dart` and `image_edit_service.dart` both already pair a contract with its implementation in one file. Adding a folder for a single file would have been the restructuring the rules forbid |
| `lib/features/entries/providers/ocr_providers.dart` | Provider for the downscaler |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Run the downscaler once on the incoming photo, before enhancement |
| `lib/features/entries/presentation/ocr_camera_screen.dart` | `ResolutionPreset.max` with fallback |
| `lib/features/entries/services/ocr_enhancer.dart` | `maxOcrDimension` 1800 to 3000 |
| `android/app/src/main/AndroidManifest.xml` | Drop `screenOrientation="portrait"` from the uCrop activity |

Layer note: the downscaler is a **service**. It touches files and the image
codec, so no widget may call it directly — the enhance screen reaches it through
a provider, as the other OCR services already do.

## Tests

| Test | Covers |
|---|---|
| `test/features/entries/services/ocr_capture_downscaler_test.dart` (new) | Large image reduced to the target long edge; small upright image passed through untouched; unreadable header falls back to the original path; **the EXIF probe, both branches, so double rotation is caught** |
| `test/features/entries/services/ocr_enhancer_test.dart` | Any assertion pinned to 1800; a 3000 px input survives at 3000; 90° steps still apply once |
| `test/features/entries/presentation/ocr_enhance_screen_test.dart` | Downscaler runs before enhancement; the rotation angle resets to 0 after a crop |
| `test/features/entries/presentation/entry_editor_ocr_test.dart` | Existing OCR flow unchanged from the editor's side |

Camera resolution cannot be unit tested directly — the controller is injected.
The `max`-to-`veryHigh` fallback will be covered by making the injected factory
fail the first attempt.

Widget tests must use the `...Sync` file variants, since `testWidgets` runs in a
fake-async zone where real file I/O never completes.

## Risks

| Risk | Handling |
|---|---|
| `ResolutionPreset.max` unsupported or slow on some devices | Fall back to `veryHigh` |
| Slower capture and recognition at full size | The capture overlay already shows progress; the 3000 cap is the dial to turn |
| Double rotation on codecs that apply EXIF themselves | The ported probe, plus a test on both branches |
| Memory on a 50 MP file | Native subsampled decode; the full buffer never exists in the Dart heap |

## Rules honoured

No new dependency, so the no-cloud and dependency rules are untouched. Nothing
is logged but image dimensions — never content. No schema change, so no
migration. Changes stay inside the OCR feature and one manifest attribute.

## Out of scope

The sibling todo app has the same 1800 cap cancelling out its own
full-resolution capture, and weaker camera controls than this app. Fixing it
needs its own plan, in its own repository.
