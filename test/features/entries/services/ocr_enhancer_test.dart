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

      test('keeps grainy paper light when ink covers little of the page', () {
        // Paper with grain from 190 to 210, and ink over only 2% of the page —
        // the usual case for a photo with a few lines of text. Choosing the
        // black point from the darkest 5% would put it inside the paper grain
        // and turn the paper into fake ink.
        final image = img.Image(width: 100, height: 100);
        for (final pixel in image) {
          final value = pixel.y < 2 ? 40 : 190 + (pixel.x % 21);
          pixel.setRgb(value, value, value);
        }

        final result = normalizeOcrLevels(image);

        var darkestPaper = 255;
        for (final pixel in result) {
          if (pixel.y >= 2 && pixel.r < darkestPaper) {
            darkestPaper = pixel.r.toInt();
          }
        }
        expect(darkestPaper, greaterThan(180));
        expect(result.getPixel(50, 0).r, lessThan(25));
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

  group('enlargeForOcr', () {
    test('2x doubles both edges', () {
      final out = enlargeForOcr(img.Image(width: 1000, height: 800), 2);
      expect(out.width, 2000);
      expect(out.height, 1600);
    });

    test('3x stops at the long-edge cap', () {
      final out = enlargeForOcr(img.Image(width: 2000, height: 1600), 3);
      expect(out.width, kOcrEnlargedMaxLongEdge);
      expect(out.height, 3600);
    });

    test('an image already past the cap is shrunk to it', () {
      final out = enlargeForOcr(img.Image(width: 6000, height: 3000), 2);
      expect(out.width, kOcrEnlargedMaxLongEdge);
    });
  });

  group('enlarge through the isolate worker', () {
    test('1x keeps the normal 4000 px limit', () {
      final sourcePath = writeTestImage(width: 4800, height: 2400);
      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: '${tempDir.path}/one_x.png',
          generatePreview: false,
        ),
      );
      expect(result.width, kOcrMaxOutputLongEdge);
    });

    test('2x scales the output up', () {
      final sourcePath = writeTestImage(width: 600, height: 400);
      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: '${tempDir.path}/two_x.png',
          enlargeFactor: 2,
          generatePreview: false,
        ),
      );
      expect(result.width, 1200);
      expect(result.height, 800);
    });
  });

  group('sharpenForOcr', () {
    img.Image edge() {
      final image = img.Image(width: 40, height: 20);
      img.fill(image, color: img.ColorRgb8(90, 90, 90));
      img.fillRect(
        image,
        x1: 20,
        y1: 0,
        x2: 39,
        y2: 19,
        color: img.ColorRgb8(170, 170, 170),
      );
      return image;
    }

    test('0 leaves every pixel unchanged', () {
      final image = edge();
      final before = image.getBytes();
      final out = sharpenForOcr(image, 0);
      expect(out.getBytes(), before);
    });

    test('100 widens the step across an edge', () {
      final out = sharpenForOcr(edge(), 100);
      // Just left of the edge gets darker, just right gets lighter.
      expect(out.getPixel(18, 10).r, lessThan(90));
      expect(out.getPixel(21, 10).r, greaterThan(170));
    });
  });

  group('flattenScreenPhoto', () {
    test('light text on a dark screen comes out dark on light', () {
      final image = img.Image(width: 200, height: 120);
      img.fill(image, color: img.ColorRgb8(25, 25, 25));
      img.fillRect(
        image,
        x1: 40,
        y1: 50,
        x2: 160,
        y2: 58,
        color: img.ColorRgb8(230, 230, 230),
      );
      final out = flattenScreenPhoto(image);
      expect(out.getPixel(10, 10).r, greaterThan(200)); // background
      expect(out.getPixel(100, 54).r, lessThan(80)); // text stroke
    });

    test('evens out a glare gradient across the background', () {
      final image = img.Image(width: 300, height: 120);
      for (final pixel in image) {
        // Background brightens from 150 on the left to 250 on the right.
        final v = 150 + (100 * pixel.x / 299).round();
        pixel.setRgb(v, v, v);
      }
      img.fillRect(
        image,
        x1: 30,
        y1: 55,
        x2: 270,
        y2: 60,
        color: img.ColorRgb8(20, 20, 20),
      );
      final out = flattenScreenPhoto(image);
      final left = out.getPixel(10, 10).r;
      final right = out.getPixel(290, 10).r;
      expect((left - right).abs(), lessThan(30));
      expect(out.getPixel(150, 57).r, lessThan(left - 100));
    });
  });
}
