# Plan: OCR Camera Controls & Post-Capture Image Enhancement with Live Text Preview

**Status:** Completed

## Overview
This plan enhances the document OCR experience in SreerajP Journal Vault to meet user requirements:
1. **Advanced OCR Camera Controls**: Add real-time brightness/exposure compensation slider, continuous zoom slider, focus mode switching (auto/locked), and exposure mode switching (auto/locked) to `OcrCameraScreen`.
2. **Post-Capture Enhancement Screen (`OcrEnhanceScreen`)**: After capturing or selecting a document image, users can rotate it (90° steps), crop it (via lossless `ImageCropper`), adjust contrast and brightness (-100 to +100), and apply document-tailored filters (Original, Document B&W, Grayscale, High-Contrast Sharpen).
3. **Live OCR Text Preview**: As the user adjusts contrast, brightness, rotation, filters, or crops, ML Kit Text Recognition runs in the background with debouncing, updating a live preview of the recognized text and word count in real time.
4. **Lossless Quality Preservation**: All image transformations operate on high-resolution source data and encode to lossless PNG to ensure no pixel degradation, compression blur, or punctuation loss (`.`, `,`, `:`, `=`).

## Files to Change and Create

### New Files
- `lib/features/entries/services/ocr_enhancer.dart`: Background isolate-powered image enhancement engine handling lossless rotation, brightness, contrast, and document filter algorithms.
- `lib/features/entries/presentation/ocr_enhance_screen.dart`: Interactive enhancement screen with pan/zoom preview, crop/rotate actions, filter chips, brightness/contrast sliders, and live recognized text preview card.
- `test/features/entries/services/ocr_enhancer_test.dart`: Unit tests for image rotation, brightness, contrast, filter algorithms, and lossless output.
- `test/features/entries/presentation/ocr_enhance_screen_test.dart`: Widget tests for the enhancement screen controls, live OCR preview, and text insertion flow.

### Modified Files
- `lib/features/entries/presentation/ocr_camera_screen.dart`: Add exposure compensation slider, continuous zoom slider, focus and exposure mode toggles, and seamless transition to `OcrEnhanceScreen`.
- `lib/features/entries/presentation/entry_editor_screen.dart`: Integrate `OcrEnhanceScreen` for both camera and gallery flows while preserving test fake injection.
- `lib/l10n/app_en.arb`: Add English localization strings and `@key` metadata for all camera and enhancement controls.
- `lib/l10n/app_ml.arb`: Add Malayalam translations for all new OCR camera and enhancement strings.
- `test/features/entries/presentation/ocr_camera_screen_test.dart`: Add widget test cases verifying exposure slider, zoom slider, and advanced camera options.

## Implementation Details

### 1. Advanced Camera Controls (`OcrCameraScreen`)
- Query camera capabilities on initialization: `getMinExposureOffset()`, `getMaxExposureOffset()`, `getExposureOffsetStepSize()`.
- Add an Exposure/Brightness tuning control with EV indicator (e.g., `+0.5 EV`) and reset button.
- Add continuous zoom slider alongside the existing 1x/2x quick buttons.
- Add an expandable "Tune / Controls" panel with:
  - Exposure offset slider
  - Continuous zoom slider
  - Focus Mode toggle (`FocusMode.auto` vs `FocusMode.locked`)
  - Exposure Mode toggle (`ExposureMode.auto` vs `ExposureMode.locked`)
  - Flash & Torch modes and Document Framing Grid (already present, polished).

### 2. Lossless Image Enhancement Engine (`ocr_enhancer.dart`)
- Define `OcrEnhanceFilter`:
  - `original`: Passthrough.
  - `documentBw`: Grayscale + high-contrast document binarization (crisp dark text on light background).
  - `grayscale`: Pure monochrome.
  - `sharpenBw`: Grayscale + contrast boost + sharpen kernel.
- Background isolate execution via `compute`:
  - Decodes original bytes.
  - Applies 90-degree rotations (`img.copyRotate`).
  - Applies brightness and contrast adjustments (`img.adjustColor`).
  - Encodes to lossless PNG (`img.encodePng`).
  - Generates both full-resolution file for ML Kit recognition and memory bytes for UI preview.

### 3. Interactive Enhancement & Live Text Preview Screen (`OcrEnhanceScreen`)
- Large interactive image preview with zoom and pan (`InteractiveViewer`).
- Bottom controls bar with 4 tool tabs/sections:
  - **Rotate**: 90° clockwise and counter-clockwise buttons.
  - **Crop**: Tapping opens `ImageEditService.cropAndRotate` (lossless PNG uCrop) and returns the cropped image back into the active editing session.
  - **Filters**: Chips for Original, Document B&W, Grayscale, High-Contrast.
  - **Adjust**: Sliders for Brightness (-100 to +100) and Contrast (-100 to +100) with a Reset button.
- **Live Text Recognition Panel**:
  - Live collapsible card displaying extracted text.
  - 300ms debounce: as user moves sliders or changes filters, ML Kit recognizes text on the enhanced image.
  - Displays word count badge (e.g. "36 words detected") and loading spinner while scanning.
  - Shows helpful status if text is faint or unreadable.
- Confirmation:
  - "Insert into Entry" button returns the extracted text to `EntryEditorScreen`.
  - "Retake / Back" button allows returning to camera or discarding.

### 4. Zero Quality Degradation
- All operations operate on full-resolution bitmaps.
- Compression uses lossless PNG format (`compressFormat: ImageCompressFormat.png`, `compressQuality: 100`).
- No downsampling or lossy JPEG compression at any point in the pipeline.

### 5. Localization
- Full English and Malayalam translations for every button, tooltip, slider label, and hint text.

## Verification Plan
1. `flutter gen-l10n` to regenerate localizations.
2. `flutter analyze` to ensure zero static analysis warnings.
3. `dart format lib test` to ensure clean formatting.
4. `flutter test` to verify all 812 existing tests continue to pass and all new tests pass.
5. Manual and widget testing of camera controls, image filters, contrast/brightness adjustments, rotation, cropping, and live OCR text recognition.
