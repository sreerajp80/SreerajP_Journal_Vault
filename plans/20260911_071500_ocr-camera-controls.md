# Enhance OCR Camera — Full Camera Controls (Flash, Focus, Zoom)

**Status:** completed

## The issue

When scanning text from a photo in the journal editor, selecting "Take photo" currently launches the standard external camera intent via `ImagePicker`.
This causes several issues:
1. Users have no control over the camera from within the app.
2. Many Android devices launch a bare-bones system camera intent without flash/torch controls, manual tap-to-focus, or pinch-to-zoom.
3. Users cannot illuminate dark pages or cast-off shadows with a continuous torch.
4. Users cannot focus on specific fine-print text or zoom into distant text, leading to blurry photos and failed OCR text recognition.

## The fix

### 1. Dedicated in-app OCR Camera screen (`OcrCameraScreen`)

Create `lib/features/entries/presentation/ocr_camera_screen.dart` using Flutter's official `camera` plugin:

- **Live Camera Viewfinder:** High-resolution camera preview (`ResolutionPreset.high` / `veryHigh`) optimized for document and text recognition.
- **Flash / Torch Controls:**
  - Cycle or toggle between: Auto, On, Torch, and Off.
  - Torch mode is essential for document capture, preventing the phone's shadow from darkening the text when shooting from above.
- **Tap to Focus & Exposure:**
  - Tapping anywhere on the viewfinder sets focus and exposure at that coordinate (`setFocusPoint` and `setExposurePoint`).
  - Shows an animated focus reticle at the tap position that smoothly scales down and fades out.
- **Zoom Controls (Pinch-to-zoom & Presets):**
  - Smooth pinch-to-zoom gesture on the preview.
  - Quick-zoom buttons (e.g. 1x, 2x) and an on-screen zoom level indicator.
- **Document Framing Guide / Grid:**
  - Toggleable framing guide overlay to help users align pages horizontally and avoid tilted or skewed text.
- **Camera Switching & Gallery Option:**
  - Switch between rear and front cameras (rear default).
  - Quick button to switch to the photo gallery if the user prefers an existing image.
- **Lifecycle Management:**
  - Listens to app lifecycle states to cleanly release and reacquire camera hardware when the app is paused or resumed.

### 2. Connect into the OCR Pipeline

In `lib/features/entries/presentation/entry_editor_screen.dart`:
- When "Take photo" is tapped, open `OcrCameraScreen`.
- When a photo is captured, pass the file into the existing image cropping and rotation step (`imageEditService.cropAndRotate`), which then forwards to preprocessing and ML Kit OCR.
- If `widget.imagePicker` is injected (e.g. in automated tests), preserve testability.

### 3. Add Dependency

Add `camera: ^0.12.1` to `pubspec.yaml` and record its purpose in `docs/dependencies.md`. The package is Flutter's official open-source camera plugin (BSD-3-Clause) with zero cloud/network access, fully adhering to the app's privacy and offline architecture.

### 4. Localization

Add all user-facing strings to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`, then run `flutter gen-l10n`.

## Files to change

| File | Change |
|---|---|
| `pubspec.yaml` | Add `camera: ^0.12.1` |
| `docs/dependencies.md` | Document `camera` package under editor & media dependencies |
| `lib/features/entries/presentation/ocr_camera_screen.dart` | **New** — Dedicated camera screen with flash, torch, tap-to-focus, pinch-to-zoom, grid guide, and capture |
| `lib/features/entries/presentation/entry_editor_screen.dart` | Route "Take photo" to `OcrCameraScreen` while preserving testing injection |
| `lib/l10n/app_en.arb` | Add English strings for OCR camera controls and permissions |
| `lib/l10n/app_ml.arb` | Add Malayalam translations for OCR camera controls |
| `test/features/entries/presentation/entry_editor_ocr_test.dart` | Update and add widget tests for the OCR camera flow |
| `test/features/entries/presentation/ocr_camera_screen_test.dart` | **New** — Unit/widget tests for camera UI controls |

## What this does not do

- It does not modify ML Kit text recognition logic or image preprocessing filters (those are already handled by `ocr_service.dart` and `ocr_image_preprocessor.dart`).
- It does not send any images off-device. All camera capture, cropping, and OCR run 100% locally on the device.

## Verification plan

- Run `flutter analyze` to ensure zero static analysis issues.
- Run `flutter test` to ensure all existing and new tests pass.
- Verify camera controls: flash/torch toggle, tap-to-focus reticle, pinch zoom, framing grid overlay, capture button, and cancellation.
