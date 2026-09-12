# OCR Camera — Full Camera Controls (Flash, Focus, Zoom)

Implements `plans/20260911_071500_ocr-camera-controls.md`.

## Why

When scanning text from physical documents into the journal editor, taking a photo previously launched the device's default system camera intent. On many devices, this provided no manual control over camera settings:
- Users could not control or keep the flash/torch on, causing dark scans and unwanted phone shadows across the document.
- Users could not tap on specific paragraphs or fine print to focus, resulting in blurry captures that failed OCR recognition.
- Users could not zoom into distant text or adjust framing.

## What changed

**New — `lib/features/entries/presentation/ocr_camera_screen.dart`**
A dedicated in-app camera viewfinder for document text scanning:
- **Live camera preview** with high resolution (`ResolutionPreset.veryHigh`) for clear text.
- **Flash & Torch modes**: toggle button cycling through Auto, On, Torch, and Off. The continuous Torch mode is especially helpful to eliminate shadows cast by the device when held over a book or paper.
- **Tap-to-focus & metering**: tap anywhere on the preview to focus and meter at that point. Displays an animated, fading focus reticle at the tap position.
- **Pinch-to-zoom & Zoom presets**: smooth pinch-to-zoom gesture on the viewfinder, plus quick-zoom pills (`1×`, `2×`) and real-time zoom level indicator.
- **Document framing grid**: toggleable overlay showing 3x3 alignment guidelines and central document corner brackets to help align text horizontally.
- **Camera switching**: toggle between back and front cameras (back camera default).
- **Gallery shortcut**: quick button to select an image from the photo gallery directly from the camera screen.
- **Hardware lifecycle**: releases camera hardware when backgrounded and re-initializes on resume.
- **Permissions & error handling**: clear guidance when camera permission is denied or no camera hardware is available, with direct links to system settings or gallery fallback.

**`lib/features/entries/presentation/entry_editor_screen.dart`**
Updated `_scanTextFromPhoto()`:
- When "Take photo" is chosen, opens `OcrCameraScreen`.
- Returns the captured photo path and forwards it to the existing crop & rotate step (`imageEditService.cropAndRotate`), followed by OCR text recognition.
- Preserves `widget.imagePicker` injection for testing environments.

**`pubspec.yaml` and `docs/dependencies.md`**
Added `camera: ^0.12.1` — Flutter's official camera plugin (BSD-3-Clause). Open source with zero network reach, keeping the app completely offline.

**`lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`**
Added English strings and Malayalam translations for all camera controls, tooltips, hints, and permission states.

## Tests

- **New** `test/features/entries/presentation/ocr_camera_screen_test.dart`:
  - Verifies permission-denied view with gallery fallback.
  - Verifies no-cameras error view with gallery fallback.
  - Verifies live camera viewfinder with controls: flash mode toggling, quick-zoom pills, grid toggle, tap-to-focus position metering, and shutter capture returning the photo path.
- `test/features/entries/presentation/entry_editor_ocr_test.dart`:
  - Verified existing OCR editor integration tests continue to pass.
- All 160 entry feature tests pass.
- `flutter analyze` clean with 0 issues.
