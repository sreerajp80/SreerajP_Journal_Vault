import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

/// Prepares a photo for recognition — enlarge, grayscale, contrast — so thin
/// marks such as `.` and `=` are big enough for the recognizer to see.
final ocrImagePreprocessorProvider = Provider<OcrImagePreprocessor>((ref) {
  return const ImagePackageOcrPreprocessor();
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return MlKitOcrService(preprocessor: ref.watch(ocrImagePreprocessorProvider));
});
