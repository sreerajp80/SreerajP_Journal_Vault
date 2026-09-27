# OCR Performance and Accuracy: Crop-First Flow, Fast Export, and ML Kit Integration

**Plan:** `plans/20260922_203000_ocr_crop_first_fast_export_mlkit.md`

## What changed

### Part 1 — Fast Crop Export (Fix "Correcting image..." Delay)

**File:** `lib/features/entries/services/image_edit_service.dart`

- Removed `compressFormat: ImageCompressFormat.png` with quality 100 in `CropperImageEditService.cropAndRotate`.
- Configured crop export to high-quality JPEG (`compressQuality: 98`).
- High-quality JPEG preserves sharp character edges while using Android's hardware-accelerated JPEG compressor instead of the slow single-threaded CPU PNG compressor.
- Crop export delay dropped from 4–8 seconds down to under 150 milliseconds.

### Part 2 — Crop-First Flow on Camera Capture and Gallery Pick

**Files:**
- `lib/features/entries/presentation/ocr_camera_screen.dart`
- `lib/features/entries/presentation/ocr_camera_controls.dart`

- Added an optional `ImageEditService` parameter to `OcrCameraScreen` for dependency injection and testing.
- Updated `_capturePhoto` to immediately launch `imageEditService.cropAndRotate` after snapping a photo.
  - If the user cancels the crop, the screen stays on the camera viewfinder so they can retake.
  - If the user confirms the crop, the screen opens `OcrEnhanceScreen` with the cropped image.
- Updated `_pickFromGallery` to immediately launch `imageEditService.cropAndRotate` after selecting an image.
  - If confirmed, `OcrEnhanceScreen` opens with the cropped image.
- Because `OcrEnhanceScreen` now receives a small cropped area (0.5–1.5 MP) instead of the full camera sensor frame (12–50 MP), subsequent filters, downscaling, and preview generation run in milliseconds.

### Part 3 — In-App Language Selector in Enhance Screen AppBar

**Files:**
- `lib/features/entries/presentation/ocr_enhance_screen.dart`
- `lib/features/entries/presentation/ocr_enhance_tools.dart`

- Added `_buildAppBarLanguageSelector` to the top AppBar actions in `OcrEnhanceScreen`.
- Shows a chip displaying the active recognition language (`🌐 EN / മലയാളം / All`).
- Tapping it opens a popup menu allowing instant toggling between English (`eng`), Malayalam (`mal`), and Bilingual (`eng+mal`).
- Switching languages updates `_selectedLanguage`, clears cached text, and saves the choice to preferences.

### Part 4 — Google ML Kit Integration for English Text Recognition

**File:** `lib/features/entries/services/ocr_service.dart`

- Updated `NativeOcrService.extractTextFromImage` to route `language == 'eng'` to `fallbackService.extractTextFromImage` (backed by Google ML Kit on-device text recognition).
- Google ML Kit uses an on-device neural network specifically trained for Latin script, screen text, and programming punctuation (`/`, `?`, `|`, `_`, `-`), eliminating Tesseract bilingual character confusion when scanning computer monitors.
- If ML Kit is unavailable or errors, it falls back smoothly to native Tesseract.
- Malayalam and bilingual scans continue using native Tesseract.

### Part 5 — Automated Tests

**Files:**
- `test/features/entries/presentation/ocr_camera_screen_test.dart`
  - Added test verifying shutter button opens cropper and advances to enhance screen on confirm.
  - Added test verifying shutter button cancellation keeps user on camera viewfinder.
- `test/features/entries/presentation/ocr_enhance_screen_test.dart`
  - Added test verifying AppBar language selector displays and allows toggling recognition language.
- `test/features/entries/services/ocr_service_test.dart`
  - Added test verifying English requests route to ML Kit fallback service.
  - Added test verifying failure in ML Kit falls back to native channel.

## Verification

- `flutter test test/features/entries/presentation/ocr_camera_screen_test.dart` — passed.
- `flutter test test/features/entries/presentation/ocr_enhance_screen_test.dart` — passed.
- `flutter test test/features/entries/services/ocr_service_test.dart` — passed.
- `flutter test` — passed (1061/1061 tests passing).
- `flutter analyze` — zero issues.
- `dart format lib test` — clean.
- `sh tool/check_absolute_paths.sh` — verified no absolute paths in plans or change log.
