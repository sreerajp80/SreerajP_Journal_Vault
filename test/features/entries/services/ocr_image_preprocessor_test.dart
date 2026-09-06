import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_prep_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Writes a small JPEG so the preprocessor has something real to work on.
  String writeSourceImage({required int width, required int height}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    // A dark mark, standing in for a thin punctuation stroke.
    img.fillRect(
      image,
      x1: 2,
      y1: 2,
      x2: 6,
      y2: 4,
      color: img.ColorRgb8(20, 20, 20),
    );
    final path = '${tempDir.path}/source.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(image));
    return path;
  }

  group('prepareOcrImageIsolate', () {
    test('enlarges a small photo so the short edge clears the minimum', () {
      final sourcePath = writeSourceImage(width: 400, height: 300);
      final targetPath = '${tempDir.path}/out.png';

      final ok = prepareOcrImageIsolate(
        OcrPreprocessArgs(sourcePath: sourcePath, targetPath: targetPath),
      );

      expect(ok, isTrue);
      final result = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(result.height, greaterThanOrEqualTo(kOcrMinShortEdge));
      // Aspect ratio is kept.
      expect(result.width / result.height, closeTo(400 / 300, 0.01));
    });

    test('never enlarges the long edge past its cap', () {
      // A wide strip: lifting the short edge (200) to the minimum would need a
      // 6x scale and make the long edge 6000, so the cap must win at 3000.
      final sourcePath = writeSourceImage(width: 1000, height: 200);
      final targetPath = '${tempDir.path}/wide.png';

      expect(
        prepareOcrImageIsolate(
          OcrPreprocessArgs(sourcePath: sourcePath, targetPath: targetPath),
        ),
        isTrue,
      );

      final result = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(result.width, kOcrMaxLongEdge);
      expect(result.height, lessThan(kOcrMinShortEdge));
    });

    test('never shrinks a photo that is already past the cap', () {
      // Shrinking would throw detail away, so an oversized photo is left as is.
      final sourcePath = writeSourceImage(width: 4000, height: 100);
      final targetPath = '${tempDir.path}/oversized.png';

      prepareOcrImageIsolate(
        OcrPreprocessArgs(sourcePath: sourcePath, targetPath: targetPath),
      );

      final result = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(result.width, 4000);
      expect(result.height, 100);
    });

    test('leaves an already large photo at its own size', () {
      final sourcePath = writeSourceImage(width: 2000, height: 1600);
      final targetPath = '${tempDir.path}/large.png';

      prepareOcrImageIsolate(
        OcrPreprocessArgs(sourcePath: sourcePath, targetPath: targetPath),
      );

      final result = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(result.width, 2000);
      expect(result.height, 1600);
    });

    test('writes a grayscale image', () {
      final sourcePath = writeSourceImage(width: 400, height: 300);
      final targetPath = '${tempDir.path}/gray.png';

      prepareOcrImageIsolate(
        OcrPreprocessArgs(sourcePath: sourcePath, targetPath: targetPath),
      );

      final result = img.decodeImage(File(targetPath).readAsBytesSync())!;
      final pixel = result.getPixel(result.width ~/ 2, result.height ~/ 2);
      expect(pixel.r, pixel.g);
      expect(pixel.g, pixel.b);
    });

    test('reports failure for a file that is not an image', () {
      final path = '${tempDir.path}/not_an_image.jpg';
      File(path).writeAsStringSync('this is not image data');

      expect(
        prepareOcrImageIsolate(
          OcrPreprocessArgs(
            sourcePath: path,
            targetPath: '${tempDir.path}/never.png',
          ),
        ),
        isFalse,
      );
      expect(File('${tempDir.path}/never.png').existsSync(), isFalse);
    });
  });
}
