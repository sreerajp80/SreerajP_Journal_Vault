import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_blur_detector.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_camera_source_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_temp_file_sweeper.dart';

/// Prepares a photo for recognition — enlarge, grayscale, contrast — so thin
/// marks such as `.` and `=` are big enough for the recognizer to see.
final ocrImagePreprocessorProvider = Provider<OcrImagePreprocessor>((ref) {
  return const ImagePackageOcrPreprocessor();
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return NativeOcrService(
    fallbackService: MlKitOcrService(
      preprocessor: ref.watch(ocrImagePreprocessorProvider),
    ),
  );
});

/// Background isolate image enhancer for rotation, filters, brightness, and contrast.
final ocrEnhancerProvider = Provider<OcrEnhancer>((ref) {
  return const OcrEnhancer();
});

/// Shrinks a full-resolution capture, using the native codec, to a size the
/// Dart image pipeline can afford. Also applies EXIF rotation exactly once.
final ocrCaptureDownscalerProvider = Provider<OcrCaptureDownscaler>((ref) {
  return const NativeOcrCaptureDownscaler();
});

/// Tells whether a photo is too blurry to read well.
final ocrBlurDetectorProvider = Provider<OcrBlurDetector>((ref) {
  return const NativeOcrBlurDetector();
});

/// Deletes the temporary photos a scan leaves in the cache folder.
final ocrTempFileSweeperProvider = Provider<OcrTempFileSweeper>((ref) {
  return const CacheOcrTempFileSweeper();
});

/// Remembers the OCR language the user last picked.
final ocrLanguageStoreProvider = Provider<OcrLanguageStore>((ref) {
  return const SharedPreferencesOcrLanguageStore();
});

/// Remembers which camera the "Take photo" scan option uses.
final ocrCameraSourceStoreProvider = Provider<OcrCameraSourceStore>((ref) {
  return const SharedPreferencesOcrCameraSourceStore();
});

/// Holds whether scans use the camera built into this app, and changes it.
///
/// Knows nothing about `BuildContext` or UI strings — the Settings screen owns
/// the wording.
class OcrInAppCameraController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(ocrCameraSourceStoreProvider).read();

  /// Applies [useInAppCamera] and saves it.
  Future<void> setUseInAppCamera(bool useInAppCamera) async {
    if (state.value == useInAppCamera) return;
    state = AsyncData(useInAppCamera);
    await ref.read(ocrCameraSourceStoreProvider).save(useInAppCamera);
  }
}

final ocrInAppCameraProvider =
    AsyncNotifierProvider<OcrInAppCameraController, bool>(
      OcrInAppCameraController.new,
    );
