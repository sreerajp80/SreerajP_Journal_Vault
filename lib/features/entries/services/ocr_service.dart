import 'dart:io';
import 'dart:ui' show Rect;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';

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

/// Rebuilds readable text from the lines the recognizer found.
///
/// Text recognition returns its result grouped into blocks, and a lone symbol
/// such as `=` between two words very often comes back as a block of its own.
/// Joining blocks with newlines therefore breaks `x = 5` across three lines and
/// makes the `=` look lost. This walks every line instead, puts lines that sit
/// on the same visual row back together, and orders them the way a reader would
/// see them: top to bottom, then left to right.
String assembleRecognizedText(RecognizedText recognizedText) {
  final lines = <TextLine>[
    for (final block in recognizedText.blocks)
      for (final line in block.lines)
        if (line.text.trim().isNotEmpty) line,
  ];

  if (lines.isEmpty) return '';

  lines.sort((a, b) {
    final byTop = a.boundingBox.top.compareTo(b.boundingBox.top);
    return byTop != 0
        ? byTop
        : a.boundingBox.left.compareTo(b.boundingBox.left);
  });

  // Group into visual rows. A line joins the current row when it overlaps the
  // row's first line vertically by more than half the shorter of the two
  // heights — i.e. they are side by side, not stacked.
  final rows = <List<TextLine>>[];
  for (final line in lines) {
    if (rows.isNotEmpty &&
        _sharesRow(rows.last.first.boundingBox, line.boundingBox)) {
      rows.last.add(line);
    } else {
      rows.add(<TextLine>[line]);
    }
  }

  final buffer = StringBuffer();
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i]
      ..sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    if (i > 0) buffer.write('\n');
    buffer.write(row.map((line) => line.text.trim()).join(' '));
  }

  return buffer.toString().trim();
}

/// True when [a] and [b] sit on the same visual row.
bool _sharesRow(Rect a, Rect b) {
  final overlap =
      (a.bottom < b.bottom ? a.bottom : b.bottom) -
      (a.top > b.top ? a.top : b.top);
  if (overlap <= 0) return false;
  final shorter = a.height < b.height ? a.height : b.height;
  if (shorter <= 0) return false;
  return overlap > shorter / 2;
}

/// On-device OCR implementation backed by Google ML Kit Text Recognition.
class MlKitOcrService implements OcrService {
  const MlKitOcrService({
    this.recognizer,
    this.preprocessor = const ImagePackageOcrPreprocessor(),
  });

  final TextRecognizer? recognizer;

  /// Prepares the photo (enlarge, grayscale, contrast) before recognition, so
  /// thin marks such as `.` and `=` are large enough to be detected.
  final OcrImagePreprocessor preprocessor;

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    final activeRecognizer = recognizer ?? TextRecognizer();
    final isCustomRecognizer = recognizer != null;

    String? preparedPath;
    try {
      preparedPath = await preprocessor.prepare(imagePath);

      // First pass on the prepared image, which is where the small signs
      // survive. If it finds nothing, fall back to the untouched photo, and
      // keep whichever pass read more.
      var extracted = '';
      if (preparedPath != null) {
        extracted = await _recognize(activeRecognizer, preparedPath);
      }
      if (preparedPath == null || extracted.isEmpty) {
        final original = await _recognize(activeRecognizer, imagePath);
        if (original.length > extracted.length) extracted = original;
      }

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
      if (preparedPath != null) {
        try {
          final file = File(preparedPath);
          if (file.existsSync()) file.deleteSync();
        } catch (_) {
          // A leftover file in the temp directory is harmless.
        }
      }
      if (!isCustomRecognizer) {
        await activeRecognizer.close();
      }
    }
  }

  Future<String> _recognize(TextRecognizer recognizer, String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final RecognizedText recognizedText = await recognizer.processImage(
      inputImage,
    );
    return assembleRecognizedText(recognizedText);
  }
}
