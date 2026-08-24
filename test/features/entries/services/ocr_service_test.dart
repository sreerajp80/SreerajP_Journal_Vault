import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

class _FakeOcrService implements OcrService {
  _FakeOcrService({this.textToReturn = '', this.shouldThrow = false});

  final String textToReturn;
  final bool shouldThrow;
  String? lastProcessedPath;

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    lastProcessedPath = imagePath;
    if (shouldThrow) {
      throw Exception('OCR extraction failed');
    }
    return textToReturn;
  }
}

void main() {
  group('OcrService', () {
    test('extracts text from image correctly', () async {
      final service = _FakeOcrService(textToReturn: 'Recognized journal text');
      final result = await service.extractTextFromImage('/tmp/test_image.jpg');

      expect(result, 'Recognized journal text');
      expect(service.lastProcessedPath, '/tmp/test_image.jpg');
    });

    test('returns empty string when no text found', () async {
      final service = _FakeOcrService();
      final result = await service.extractTextFromImage('/tmp/blank_image.jpg');

      expect(result, isEmpty);
    });

    test('throws when extraction fails', () async {
      final service = _FakeOcrService(shouldThrow: true);

      expect(
        () => service.extractTextFromImage('/tmp/corrupted.jpg'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
