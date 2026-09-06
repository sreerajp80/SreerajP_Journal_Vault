import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Contract for preparing a photo before it is handed to OCR.
///
/// A `.`, `=`, `,` or `:` in a normal phone photo of a page is only a few
/// pixels tall. Text recognition has a minimum glyph height below which a
/// character is never reported at all, so these thin marks are the first thing
/// lost. Enlarging the image and lifting its contrast puts them back above that
/// floor.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class OcrImagePreprocessor {
  /// Writes an OCR-friendly copy of the image at [imagePath] to a temporary
  /// file and returns its path.
  ///
  /// Returns `null` when no copy was made — either the image already suits OCR
  /// or preparation failed. Callers must fall back to [imagePath] in that case.
  /// The caller owns the returned file and must delete it when done.
  Future<String?> prepare(String imagePath);
}

/// The shortest edge we want the image to have before recognition. Below this,
/// thin punctuation is too small for the recognizer to see.
const int kOcrMinShortEdge = 1200;

/// Upper bound on the longest edge, so a very large photo does not blow up
/// memory while being enlarged.
const int kOcrMaxLongEdge = 3000;

/// Contrast boost applied after grayscale. 100 means "no change"; a mild lift
/// separates thin strokes from the paper without crushing faint ink.
const num kOcrContrastLevel = 125;

/// Arguments for [prepareOcrImageIsolate], which runs off the UI thread.
@immutable
class OcrPreprocessArgs {
  const OcrPreprocessArgs({required this.sourcePath, required this.targetPath});

  final String sourcePath;
  final String targetPath;
}

/// Decodes, enlarges, grayscales and contrast-boosts the image, then writes it
/// as lossless PNG. Returns `true` when [OcrPreprocessArgs.targetPath] was
/// written, `false` when the image could not be used.
///
/// Top-level on purpose: it is run through [compute] in a background isolate.
bool prepareOcrImageIsolate(OcrPreprocessArgs args) {
  final Uint8List bytes = File(args.sourcePath).readAsBytesSync();
  final img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) return false;

  // Apply any EXIF rotation, so the recognizer sees upright text.
  var image = img.bakeOrientation(decoded);

  final int shortEdge = image.width < image.height ? image.width : image.height;
  final int longEdge = image.width > image.height ? image.width : image.height;

  // Scale so the short edge reaches the minimum, but never push the long edge
  // past its cap.
  var scale = kOcrMinShortEdge / shortEdge;
  final maxScale = kOcrMaxLongEdge / longEdge;
  if (scale > maxScale) scale = maxScale;

  if (scale > 1.0) {
    image = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.cubic,
    );
  }

  image = img.grayscale(image);
  image = img.contrast(image, contrast: kOcrContrastLevel);

  // PNG, not JPEG: JPEG blur eats the one-pixel strokes we are trying to save.
  File(args.targetPath).writeAsBytesSync(img.encodePng(image));
  return true;
}

/// [OcrImagePreprocessor] backed by the pure-Dart `image` package.
class ImagePackageOcrPreprocessor implements OcrImagePreprocessor {
  const ImagePackageOcrPreprocessor();

  @override
  Future<String?> prepare(String imagePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'ocr_prep_${DateTime.now().microsecondsSinceEpoch}.png',
      );

      final prepared = await compute(
        prepareOcrImageIsolate,
        OcrPreprocessArgs(sourcePath: imagePath, targetPath: targetPath),
      );

      if (!prepared) {
        AppLogger.warning('OcrImagePreprocessor: image could not be decoded');
        return null;
      }

      AppLogger.info('OcrImagePreprocessor: prepared image for recognition');
      return targetPath;
    } catch (e, stackTrace) {
      // Preparation is an optimisation, never a hard requirement — the caller
      // falls back to the original photo.
      AppLogger.error(
        'OcrImagePreprocessor: preparation failed, using original image',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
