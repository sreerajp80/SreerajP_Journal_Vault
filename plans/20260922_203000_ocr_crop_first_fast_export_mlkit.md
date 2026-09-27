# OCR Performance & Accuracy: Crop-First Flow, Fast Export, and ML Kit Integration

**Status:** completed
**Change log:** `change_log/20260922_204500_ocr-crop-first-fast-export-mlkit.md`

## Issue

1. **Slow Cropping & "Correcting image..." Delay:**
   When cropping an image, tapping the checkmark causes uCrop to show a "Please wait, correcting image..." spinner for 4 to 8 seconds. This is because `image_edit_service.dart` specifies `ImageCompressFormat.png` at `compressQuality: 100`. Android's native PNG compressor is single-threaded CPU-based and extremely slow on high-resolution camera images.

2. **Unintuitive & Inefficient Capture Flow:**
   After taking a photo in `OcrCameraScreen`, the full 12–50 MP image is sent directly to `OcrEnhanceScreen`, where downscaling, filters, and full-resolution isolate passes execute on the entire frame. The user must then hunt for the "Crop" button in the bottom toolbar to isolate their text, which then re-runs all enhancement passes a second time on the cropped output.

3. **Garbled Computer Screen & Table OCR:**
   When scanning English text from computer screens (such as terminal tables or code snippets), Tesseract in bilingual `eng+mal` mode produces noisy and distorted results (e.g. `?` becomes `2`, `j / k` becomes `jis kil`, and `200g` becomes `20009`). Screen pixel moiré, LCD subpixel grids, and bilingual ambiguity confuse Tesseract's LSTM neural network. Furthermore, side-by-side table columns are intermingled when read horizontally across columns.

## Proposed Changes

### Part 1 — Fast Crop Export (Fix "Correcting image..." Delay)

**File:** `lib/features/entries/services/image_edit_service.dart`

- In `CropperImageEditService.cropAndRotate`:
  - Change `compressFormat: ImageCompressFormat.png` to `ImageCompressFormat.jpg`.
  - Set `compressQuality: 98`.
  - High-quality JPEG at 98% preserves sharp character strokes with zero visual distortion, while leveraging Android's hardware-accelerated JPEG encoding. This drops export time from 4–8 seconds to under 150 milliseconds.

### Part 2 — Crop-First Flow in Camera and Gallery Capture

**Files:**
- `lib/features/entries/presentation/ocr_camera_screen.dart`
- `lib/features/entries/presentation/ocr_camera_controls.dart`

- Add an optional `imageEditService` parameter to `OcrCameraScreen` (defaulting to `CropperImageEditService()`) for dependency injection and testing.
- In `_capturePhoto()`:
  - Take the photo with the camera controller.
  - Immediately invoke `imageEditService.cropAndRotate(...)` so the user frames the wanted text area right after pressing the shutter.
  - If the user cancels the crop, stay on the camera viewfinder so they can retake.
  - If the user confirms the crop, push `OcrEnhanceScreen` with the cropped image path.
- In `_pickFromGallery()`:
  - Pick the image.
  - Immediately invoke `imageEditService.cropAndRotate(...)`.
  - If confirmed, push `OcrEnhanceScreen` with the cropped image path.
- Benefit: `OcrEnhanceScreen` now receives a lightweight (typically 0.5–1.5 MP) cropped image. Downscaling, contrast filtering, and screen cleanup execute in under 100 milliseconds instead of several seconds.

### Part 3 — Dedicated Language Selector in Enhance Screen AppBar

**Files:**
- `lib/features/entries/presentation/ocr_enhance_screen.dart`
- `lib/features/entries/presentation/ocr_enhance_tools.dart`

- In `OcrEnhanceScreen` AppBar `actions`:
  - Add a visible language selection chip/menu button (`[🌐 EN / മലയാളം / All]`) before the preview and insert buttons.
  - Tapping it shows a menu to switch between English (`eng`), Malayalam (`mal`), and Bilingual (`eng+mal`).
  - Switching language updates `_selectedLanguage`, invalidates `_keptText`, and persists the user's choice to `OcrLanguageStore` (SharedPreferences) so subsequent scans remember their preference.

### Part 4 — Google ML Kit Integration for English/Latin Recognition

**File:** `lib/features/entries/services/ocr_service.dart`

- In `NativeOcrService.extractTextFromImage(...)`:
  - When `language == 'eng'`: Route to `fallbackService.extractTextFromImage(...)` (which runs `MlKitOcrService` backed by Google ML Kit on-device text recognition).
  - When `language == 'mal'` or `language == 'eng+mal'`: Invoke native Tesseract via the platform channel.
  - If ML Kit fails or is unavailable, smoothly fall back to native Tesseract.
- In `assembleRecognizedText(...)`:
  - When lines are determined to sit side-by-side in the same visual row (such as table columns), separate them with two spaces (`'  '`) rather than collapsing single spaces, preserving column delineation for tables.

## Files to Change

| File | Change |
|---|---|
| `lib/features/entries/services/image_edit_service.dart` | Switch uCrop export to fast JPEG (quality 98) |
| `lib/features/entries/presentation/ocr_camera_screen.dart` | Add optional `imageEditService` to constructor |
| `lib/features/entries/presentation/ocr_camera_controls.dart` | Implement crop-first flow in capture and gallery |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Add language picker button to AppBar |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Helper for AppBar language selection |
| `lib/features/entries/services/ocr_service.dart` | Route English OCR to Google ML Kit and format column gaps |
| `test/features/entries/presentation/ocr_camera_screen_test.dart` | Add tests for crop-first capture and cancellation |
| `test/features/entries/services/ocr_service_test.dart` | Add test verifying English routing to ML Kit |

## Verification Plan

### Automated Tests
- Run all OCR tests:
  ```bash
  flutter test test/features/entries/presentation/ocr_camera_screen_test.dart
  flutter test test/features/entries/presentation/ocr_enhance_screen_test.dart
  flutter test test/features/entries/services/ocr_service_test.dart
  ```
- Run static analysis:
  ```bash
  flutter analyze
  ```
- Run code formatting:
  ```bash
  dart format lib test
  ```

### Manual Verification
1. Open camera scanner, capture a photo -> uCrop opens immediately.
2. Select crop box, tap checkmark -> uCrop saves instantly without "correcting image..." delay.
3. Arrive at `OcrEnhanceScreen` -> image is already cropped and sharp; filters apply in milliseconds.
4. Select English in the AppBar -> tap "Insert into entry" -> text reads cleanly with ML Kit.
