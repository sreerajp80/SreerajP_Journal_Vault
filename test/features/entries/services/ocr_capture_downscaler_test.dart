import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    NativeOcrCaptureDownscaler.resetExifProbeForTest();
    tempDir = Directory.systemTemp.createTempSync('ocr_downscaler_test');

    // path_provider has no implementation in a unit test, so point
    // getTemporaryDirectory at a real folder this test owns.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async =>
              call.method == 'getTemporaryDirectory' ? tempDir.path : null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String writeJpg(img.Image image, String name) {
    final path = p.join(tempDir.path, name);
    File(path).writeAsBytesSync(img.encodeJpg(image));
    return path;
  }

  group('bakeAndEncodeCaptureIsolate', () {
    // The rotation decision is where a double turn would show up, so it is
    // tested directly rather than through the platform codec.
    test('leaves the image alone when there is nothing to apply', () {
      final target = p.join(tempDir.path, 'out_none.png');
      final written = bakeAndEncodeCaptureIsolate(
        OcrDownscaleArgs(
          rgbaBytes: Uint8List(16 * 8 * 4),
          width: 16,
          height: 8,
          exifOrientation: 1,
          targetPath: target,
        ),
      );

      expect(written, isTrue);
      final decoded = img.decodePng(File(target).readAsBytesSync())!;
      expect(decoded.width, 16);
      expect(decoded.height, 8);
    });

    test('applies a quarter turn, swapping the sides, when asked to', () {
      final target = p.join(tempDir.path, 'out_90.png');
      final written = bakeAndEncodeCaptureIsolate(
        OcrDownscaleArgs(
          rgbaBytes: Uint8List(16 * 8 * 4),
          width: 16,
          height: 8,
          exifOrientation: 6, // 90° clockwise.
          targetPath: target,
        ),
      );

      expect(written, isTrue);
      final decoded = img.decodePng(File(target).readAsBytesSync())!;
      expect(decoded.width, 8);
      expect(decoded.height, 16);
    });

    test('writes a PNG, so the crop never passes through JPEG blur', () {
      final target = p.join(tempDir.path, 'out_png.png');
      bakeAndEncodeCaptureIsolate(
        OcrDownscaleArgs(
          rgbaBytes: Uint8List(4 * 4 * 4),
          width: 4,
          height: 4,
          exifOrientation: 1,
          targetPath: target,
        ),
      );

      // PNG magic number.
      final header = File(target).readAsBytesSync().sublist(0, 4);
      expect(header, <int>[0x89, 0x50, 0x4E, 0x47]);
    });
  });

  group('NativeOcrCaptureDownscaler.downscale', () {
    test('passes a small upright photo through untouched', () async {
      final source = writeJpg(img.Image(width: 800, height: 600), 'small.jpg');

      final result = await const NativeOcrCaptureDownscaler().downscale(source);

      // The original is the sharpest thing available — rewriting it would only
      // lose detail.
      expect(result, source);
    });

    test('shrinks a photo whose long edge is over the cap', () async {
      // Deliberately few pixels overall, so the test stays fast while still
      // crossing the long-edge limit.
      final source = writeJpg(
        img.Image(width: kOcrCaptureMaxLongEdge + 200, height: 100),
        'wide.jpg',
      );

      final result = await const NativeOcrCaptureDownscaler().downscale(source);

      expect(result, isNot(source));
      final decoded = img.decodePng(File(result).readAsBytesSync())!;
      final longEdge = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      expect(longEdge, lessThanOrEqualTo(kOcrCaptureMaxLongEdge));
    });

    test('falls back to the original when the header cannot be read', () async {
      final source = p.join(tempDir.path, 'broken.jpg');
      File(source).writeAsBytesSync(Uint8List.fromList(<int>[1, 2, 3, 4, 5]));

      final result = await const NativeOcrCaptureDownscaler().downscale(source);

      // Preparation is an optimisation, never a hard requirement.
      expect(result, source);
    });

    test('falls back to the original when the file is missing', () async {
      final missing = p.join(tempDir.path, 'nope.jpg');

      final result = await const NativeOcrCaptureDownscaler().downscale(
        missing,
      );

      expect(result, missing);
    });
  });
}
