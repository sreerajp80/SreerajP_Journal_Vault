import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

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

/// Remembers the OCR language the user last picked.
final ocrLanguageStoreProvider = Provider<OcrLanguageStore>((ref) {
  return const SharedPreferencesOcrLanguageStore();
});
