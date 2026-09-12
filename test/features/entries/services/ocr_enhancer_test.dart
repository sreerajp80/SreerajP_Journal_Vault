import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhancer_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  String writeTestImage({required int width, required int height}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(240, 240, 240));
    img.fillRect(
      image,
      x1: 10,
      y1: 10,
      x2: width - 10,
      y2: height - 10,
      color: img.ColorRgb8(20, 20, 20),
    );
    final path = '${tempDir.path}/test_source.png';
    File(path).writeAsBytesSync(img.encodePng(image));
    return path;
  }

  group('OcrEnhancer isolate worker', () {
    test('rotates image 90 degrees and swaps dimensions', () {
      final sourcePath = writeTestImage(width: 400, height: 200);
      final targetPath = '${tempDir.path}/rotated.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          rotationAngle: 90,
        ),
      );

      expect(result.width, 200);
      expect(result.height, 400);
      expect(File(targetPath).existsSync(), isTrue);
      expect(result.previewBytes, isNotNull);

      // Verify PNG file integrity
      final decoded = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(decoded.width, 200);
      expect(decoded.height, 400);
    });

    test('applies document B&W and contrast enhancement', () {
      final sourcePath = writeTestImage(width: 300, height: 300);
      final targetPath = '${tempDir.path}/doc_bw.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          filter: OcrEnhanceFilter.documentBw,
          contrast: 20,
          brightness: 10,
        ),
      );

      expect(result.width, 300);
      expect(result.height, 300);
      expect(File(targetPath).existsSync(), isTrue);

      final decoded = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(decoded.numChannels, greaterThanOrEqualTo(1));
    });

    test('applies grayscale and high-contrast filters', () {
      final sourcePath = writeTestImage(width: 200, height: 200);
      final grayPath = '${tempDir.path}/gray.png';
      final sharpPath = '${tempDir.path}/sharp.png';

      final grayResult = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: grayPath,
          filter: OcrEnhanceFilter.grayscale,
        ),
      );
      expect(File(grayResult.targetPath).existsSync(), isTrue);

      final sharpResult = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: sharpPath,
          filter: OcrEnhanceFilter.enhance,
        ),
      );
      expect(File(sharpResult.targetPath).existsSync(), isTrue);
    });

    test('invert flips light and dark', () {
      final sourcePath = writeTestImage(width: 100, height: 100);
      final targetPath = '${tempDir.path}/inverted.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          invert: true,
        ),
      );

      final decoded = img.decodeImage(
        File(result.targetPath).readAsBytesSync(),
      )!;
      // The source is a dark block (20) on a light border (240). After inverting,
      // the corner must be dark and the middle light.
      expect(decoded.getPixel(2, 2).r, lessThan(60));
      expect(decoded.getPixel(50, 50).r, greaterThan(200));
    });

    test('documentBw pushes a grey-cast page towards black and white', () {
      // A low-contrast page: mid-grey ink on light-grey paper, the way a photo
      // of a real page comes back.
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(200, 200, 200));
      img.fillRect(
        image,
        x1: 20,
        y1: 20,
        x2: 80,
        y2: 80,
        color: img.ColorRgb8(120, 120, 120),
      );
      final sourcePath = '${tempDir.path}/grey_page.png';
      File(sourcePath).writeAsBytesSync(img.encodePng(image));

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: '${tempDir.path}/doc.png',
          filter: OcrEnhanceFilter.documentBw,
        ),
      );

      final decoded = img.decodeImage(
        File(result.targetPath).readAsBytesSync(),
      )!;
      final paper = decoded.getPixel(5, 5).r;
      final ink = decoded.getPixel(50, 50).r;
      // Both tones were within 80 levels of each other. They must now be far
      // apart, with paper near white and ink near black.
      expect(paper - ink, greaterThan(180));
      expect(paper, greaterThan(230));
      expect(ink, lessThan(40));
    });

    group('normalizeOcrLevels', () {
      test('stretches a narrow tone range to the full scale', () {
        final image = img.Image(width: 100, height: 100);
        img.fill(image, color: img.ColorRgb8(180, 180, 180));
        img.fillRect(
          image,
          x1: 0,
          y1: 0,
          x2: 99,
          y2: 49,
          color: img.ColorRgb8(100, 100, 100),
        );

        final result = normalizeOcrLevels(img.grayscale(image));

        expect(result.getPixel(50, 75).r, greaterThan(230));
        expect(result.getPixel(50, 25).r, lessThan(25));
      });

      test('leaves a nearly flat image untouched', () {
        final image = img.grayscale(
          img.Image(width: 50, height: 50)..clear(img.ColorRgb8(128, 128, 128)),
        );

        final result = normalizeOcrLevels(image);

        // Amplifying a blank page would turn sensor noise into fake ink.
        expect(result.getPixel(25, 25).r, closeTo(128, 2));
      });
    });

    test('throws FileSystemException when source file is missing', () {
      expect(
        () => processOcrImageIsolate(
          OcrEnhanceParams(
            sourcePath: '${tempDir.path}/nonexistent.png',
            targetPath: '${tempDir.path}/out.png',
          ),
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
