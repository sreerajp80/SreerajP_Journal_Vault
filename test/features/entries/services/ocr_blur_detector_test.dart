import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_blur_detector.dart';

/// A white page with rows of thin black strokes, like lines of small print.
img.Image _printedPage() {
  final page = img.Image(width: 600, height: 800);
  img.fill(page, color: img.ColorRgb8(255, 255, 255));
  for (var top = 40; top < 760; top += 30) {
    for (var left = 30; left < 570; left += 9) {
      // Letters of varying height, two or three pixels wide.
      final height = 8 + (left % 5) * 2;
      img.fillRect(
        page,
        x1: left,
        y1: top + (18 - height),
        x2: left + 2 + (left % 2),
        y2: top + 18,
        color: img.ColorRgb8(0, 0, 0),
      );
    }
  }
  return page;
}

OcrBlurArgs _argsFor(img.Image image) {
  final rgba = image
      .convert(numChannels: 4)
      .getBytes(order: img.ChannelOrder.rgba);
  return OcrBlurArgs(
    rgba: Uint8List.fromList(rgba),
    width: image.width,
    height: image.height,
  );
}

OcrBlurSample _sampleFor(img.Image image) {
  final args = _argsFor(image);
  return OcrBlurSample(
    gray: ocrRgbaToGray(args.rgba),
    width: args.width,
    height: args.height,
  );
}

void main() {
  test('sharp print scores above the blur threshold', () {
    final score = ocrSharpnessScore(_sampleFor(_printedPage()));

    expect(score, isNotNull);
    expect(score, greaterThan(kOcrBlurThreshold));
    expect(ocrIsBlurryIsolate(_argsFor(_printedPage())), isFalse);
  });

  test('the same print blurred scores below the threshold', () {
    final blurred = img.gaussianBlur(_printedPage(), radius: 4);
    final score = ocrSharpnessScore(_sampleFor(blurred));

    expect(score, isNotNull);
    expect(score, lessThan(kOcrBlurThreshold));
    expect(ocrIsBlurryIsolate(_argsFor(blurred)), isTrue);
  });

  test('blurring always lowers the score', () {
    final sharp = ocrSharpnessScore(_sampleFor(_printedPage()))!;
    final soft = ocrSharpnessScore(
      _sampleFor(img.gaussianBlur(_printedPage(), radius: 2)),
    )!;

    expect(soft, lessThan(sharp));
  });

  test('a blank page is never called blurry', () {
    final blank = img.Image(width: 400, height: 400);
    img.fill(blank, color: img.ColorRgb8(240, 240, 240));

    expect(ocrSharpnessScore(_sampleFor(blank)), isNull);
    expect(ocrIsBlurryIsolate(_argsFor(blank)), isFalse);
  });

  test('a mostly blank page with a little sharp text is not called blurry', () {
    final page = img.Image(width: 800, height: 800);
    img.fill(page, color: img.ColorRgb8(255, 255, 255));
    // One short line of print in a corner of an otherwise empty page.
    for (var left = 40; left < 300; left += 9) {
      img.fillRect(
        page,
        x1: left,
        y1: 40,
        x2: left + 2,
        y2: 56,
        color: img.ColorRgb8(0, 0, 0),
      );
    }

    expect(ocrIsBlurryIsolate(_argsFor(page)), isFalse);
  });

  test('gray conversion weights green highest', () {
    final gray = ocrRgbaToGray(
      Uint8List.fromList(<int>[255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255]),
    );

    expect(gray, <int>[76, 149, 29]);
  });
}
