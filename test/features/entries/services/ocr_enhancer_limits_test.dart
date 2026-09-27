import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';

/// CRC-32 as PNG uses it, so a test can rewrite a PNG header and keep it valid.
int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}

/// A small real PNG whose header claims [width] x [height], so the size guard
/// can be tested without building a giant image.
Uint8List _pngClaimingSize(int width, int height) {
  final bytes = Uint8List.fromList(
    img.encodePng(img.Image(width: 8, height: 8)),
  );
  final data = ByteData.sublistView(bytes);
  // Signature (8) + chunk length (4) + "IHDR" (4), then width and height.
  data.setUint32(16, width);
  data.setUint32(20, height);
  // The CRC covers the chunk type and its 13 data bytes.
  data.setUint32(29, _crc32(bytes.sublist(12, 29)));
  return bytes;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhancer_limits_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String writeImage(img.Image image, String name) {
    final path = '${tempDir.path}/$name';
    File(path).writeAsBytesSync(img.encodePng(image));
    return path;
  }

  test('refuses an image too large to decode safely', () {
    final path = '${tempDir.path}/giant.png';
    File(path).writeAsBytesSync(_pngClaimingSize(6000, 6000));

    expect(
      () => processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: path,
          targetPath: '${tempDir.path}/out.png',
          generatePreview: false,
        ),
      ),
      throwsA(isA<OcrImageTooLargeException>()),
    );
    expect(File('${tempDir.path}/out.png').existsSync(), isFalse);
  });

  test('a file that is not an image is a FormatException', () {
    final path = '${tempDir.path}/not_an_image.png';
    File(path).writeAsStringSync('plain text, not pixels');

    expect(
      () => processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: path,
          targetPath: '${tempDir.path}/out.png',
          generatePreview: false,
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'without OCR sizing the image keeps its own size and is only turned',
    () {
      final source = img.Image(width: 4800, height: 600);
      img.fill(source, color: img.ColorRgb8(200, 30, 30));
      final path = writeImage(source, 'wide.png');

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: path,
          targetPath: '${tempDir.path}/turned.png',
          rotationAngle: 90,
          generatePreview: false,
          fitToOcrSize: false,
        ),
      );

      // Turned a quarter, not shrunk to kOcrMaxOutputLongEdge.
      expect(result.width, 600);
      expect(result.height, 4800);
      // No filter ran: the colour is untouched.
      final out = img.decodePng(File(result.targetPath).readAsBytesSync())!;
      final pixel = out.getPixel(300, 2400);
      expect(pixel.r, 200);
      expect(pixel.g, 30);
    },
  );

  test('the default output limit matches the working copy size', () {
    expect(kOcrMaxOutputLongEdge, 4000);
    expect(
      kOcrEnlargedMaxLongEdge,
      greaterThanOrEqualTo(kOcrMaxOutputLongEdge),
    );
  });
}
