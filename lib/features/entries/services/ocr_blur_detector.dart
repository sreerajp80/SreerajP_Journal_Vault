// Layer: service. Tells whether a photo is too blurry to read well, so the
// scan screen can suggest taking it again. Knows nothing about widgets or UI
// strings, and never logs the image path or its pixels.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Longest edge the photo is shrunk to before its sharpness is measured.
///
/// Small enough to measure fast. Shrinking also hides the slight softness a
/// phone photo always has, so only blur that really hurts reading is flagged.
const int kOcrBlurSampleLongEdge = 1000;

/// Edge length, in pixels of the shrunk photo, of each tile scored on its own.
const int kOcrBlurTileSize = 64;

/// Sharpness score below which a photo counts as blurry.
///
/// The score is the Laplacian variance of one of the sharpest tiles (see
/// [ocrSharpnessScore]). Sharp printed text scores in the hundreds or more; a
/// shaken or out-of-focus photo scores well under this.
const double kOcrBlurThreshold = 120;

/// Share (0..1) of tiles, counted from the sharpest, whose lowest score is used
/// as the photo's score. One lucky sharp tile cannot make a blurry photo pass,
/// and blank paper cannot make a sharp one fail.
const double kOcrSharpTileShare = 0.1;

/// Standard deviation of brightness (0..255) a tile needs before it counts as
/// having any content. Blank paper has none and says nothing about focus.
const double kOcrContentTileMinStdDev = 20;

/// Contract for checking whether a photo is too blurry for text recognition.
///
/// Implementations must run 100% offline on-device.
abstract class OcrBlurDetector {
  /// True when the image at [imagePath] looks too blurry to read well.
  ///
  /// Returns `false` when the image cannot be checked, so a failed check never
  /// shows a warning.
  Future<bool> isBlurry(String imagePath);
}

/// Grayscale pixels of a shrunk photo, one byte per pixel.
@immutable
class OcrBlurSample {
  const OcrBlurSample({
    required this.gray,
    required this.width,
    required this.height,
  });

  final Uint8List gray;
  final int width;
  final int height;
}

/// Scores how sharp [sample] is. Higher is sharper.
///
/// The photo is split into tiles. For each tile that has content, the variance
/// of the Laplacian is measured — the Laplacian is large where brightness
/// changes suddenly, so sharp letter edges give a high variance and soft,
/// smeared edges a low one. The score is the value at the top
/// [kOcrSharpTileShare] of those tiles.
///
/// Returns `null` when no tile has content (a blank or nearly blank image),
/// because such an image says nothing about focus.
///
/// Top-level on purpose: it is run through [compute] in a background isolate.
double? ocrSharpnessScore(OcrBlurSample sample) {
  final width = sample.width;
  final height = sample.height;
  final gray = sample.gray;
  final scores = <double>[];

  for (var tileTop = 1; tileTop < height - 1; tileTop += kOcrBlurTileSize) {
    for (var tileLeft = 1; tileLeft < width - 1; tileLeft += kOcrBlurTileSize) {
      final bottom = math.min(tileTop + kOcrBlurTileSize, height - 1);
      final right = math.min(tileLeft + kOcrBlurTileSize, width - 1);

      var count = 0;
      var sum = 0.0;
      var sumSquares = 0.0;
      var lapSum = 0.0;
      var lapSumSquares = 0.0;
      for (var y = tileTop; y < bottom; y++) {
        final row = y * width;
        for (var x = tileLeft; x < right; x++) {
          final i = row + x;
          final value = gray[i].toDouble();
          final laplacian =
              gray[i - 1] +
              gray[i + 1] +
              gray[i - width] +
              gray[i + width] -
              4 * gray[i];
          count++;
          sum += value;
          sumSquares += value * value;
          lapSum += laplacian;
          lapSumSquares += laplacian * laplacian;
        }
      }
      if (count == 0) continue;

      final mean = sum / count;
      final stdDev = math.sqrt(math.max(0, sumSquares / count - mean * mean));
      if (stdDev < kOcrContentTileMinStdDev) continue;

      final lapMean = lapSum / count;
      scores.add(lapSumSquares / count - lapMean * lapMean);
    }
  }

  if (scores.isEmpty) return null;
  scores.sort((a, b) => b.compareTo(a));
  final index = ((scores.length - 1) * kOcrSharpTileShare).floor();
  return scores[index];
}

/// Turns straight RGBA pixels into one gray byte per pixel.
Uint8List ocrRgbaToGray(Uint8List rgba) {
  final gray = Uint8List(rgba.length ~/ 4);
  for (var i = 0, j = 0; j < gray.length; i += 4, j++) {
    gray[j] = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
  }
  return gray;
}

/// Arguments for [ocrIsBlurryIsolate].
@immutable
class OcrBlurArgs {
  const OcrBlurArgs({
    required this.rgba,
    required this.width,
    required this.height,
  });

  final Uint8List rgba;
  final int width;
  final int height;
}

/// Converts to gray and scores sharpness, off the UI thread.
bool ocrIsBlurryIsolate(OcrBlurArgs args) {
  final score = ocrSharpnessScore(
    OcrBlurSample(
      gray: ocrRgbaToGray(args.rgba),
      width: args.width,
      height: args.height,
    ),
  );
  return score != null && score < kOcrBlurThreshold;
}

/// [OcrBlurDetector] that shrinks the photo with the platform's native image
/// codec, so even a large photo is never fully decoded in Dart.
class NativeOcrBlurDetector implements OcrBlurDetector {
  const NativeOcrBlurDetector();

  @override
  Future<bool> isBlurry(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      // Header only: reads the stored size without decoding any pixels.
      final info = img.findDecoderForData(bytes)?.startDecode(bytes);
      if (info == null || info.width <= 0 || info.height <= 0) return false;

      final longEdge = math.max(info.width, info.height);
      final scale = longEdge > kOcrBlurSampleLongEdge
          ? kOcrBlurSampleLongEdge / longEdge
          : 1.0;

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: (info.width * scale).round().clamp(1, 1 << 20),
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final rgba = await uiImage.toByteData();
      final width = uiImage.width;
      final height = uiImage.height;
      uiImage.dispose();
      codec.dispose();
      if (rgba == null) return false;

      final blurry = await compute(
        ocrIsBlurryIsolate,
        OcrBlurArgs(
          rgba: rgba.buffer.asUint8List(),
          width: width,
          height: height,
        ),
      );
      AppLogger.info('OcrBlurDetector: check complete, blurry=$blurry');
      return blurry;
    } catch (e, stackTrace) {
      // The check is advice only. A failure must never block the scan.
      AppLogger.error(
        'OcrBlurDetector: check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
