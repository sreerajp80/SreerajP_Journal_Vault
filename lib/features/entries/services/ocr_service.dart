import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Contract for optical character recognition (OCR) text extraction.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class OcrService {
  /// Extracts plain text from the image located at [imagePath].
  ///
  /// Returns an empty string if no text was found.
  Future<String> extractTextFromImage(String imagePath);
}

/// On-device OCR implementation backed by Google ML Kit Text Recognition.
class MlKitOcrService implements OcrService {
  const MlKitOcrService({this.recognizer});

  final TextRecognizer? recognizer;

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    final activeRecognizer = recognizer ?? TextRecognizer();
    final isCustomRecognizer = recognizer != null;

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await activeRecognizer.processImage(
        inputImage,
      );

      final extracted = recognizedText.text.trim();
      AppLogger.info(
        'MlKitOcrService: text recognition complete, length=${extracted.length}',
      );
      return extracted;
    } catch (e, stackTrace) {
      AppLogger.error(
        'MlKitOcrService: recognition failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (!isCustomRecognizer) {
        await activeRecognizer.close();
      }
    }
  }
}
