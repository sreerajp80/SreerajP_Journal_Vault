import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Available document filter presets for image enhancement.
enum OcrEnhanceFilter {
  /// Unmodified original colors.
  original,

  /// High-contrast document mode that separates ink from paper background.
  documentBw,

  /// Clean monochrome grayscale.
  grayscale,

  /// Enhanced contrast and clarity for faint or washed-out documents.
  enhance,

  /// Photo of a monitor or phone screen: evens out glare and dark corners,
  /// turns light-on-dark text into dark-on-light, and softens the pixel grid.
  screen,
}

/// Parameters for document image enhancement.
@immutable
class OcrEnhanceParams {
  const OcrEnhanceParams({
    required this.sourcePath,
    required this.targetPath,
    this.rotationAngle = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.filter = OcrEnhanceFilter.original,
    this.invert = false,
    this.enlargeFactor = 1,
    this.sharpen = 0,
    this.generatePreview = true,
    this.previewMaxDimension = kOcrPreviewMaxDimension,
    this.fitToOcrSize = true,
  });

  /// Path to the source image file.
  final String sourcePath;

  /// Path where the lossless full-resolution processed image will be written.
  final String targetPath;

  /// Rotation in degrees (0, 90, 180, 270).
  final int rotationAngle;

  /// Brightness adjustment from -100 to 100 (0 = default).
  final int brightness;

  /// Contrast adjustment from -100 to 100 (0 = default).
  final int contrast;

  /// Active filter preset.
  final OcrEnhanceFilter filter;

  /// Whether to flip the image's light and dark values.
  ///
  /// Text recognition reads dark ink on light paper. Light lettering on a dark
  /// ground — a masthead, a titled banner, a slide — is treated as background
  /// and dropped. Inverting such an image is what makes that text readable.
  final bool invert;

  /// How much to scale the image up before recognition: 1, 2 or 3.
  ///
  /// Small text reads badly because each letter gets too few pixels. Scaling
  /// up gives them more, up to a long edge of [kOcrEnlargedMaxLongEdge]. At 1
  /// the output keeps the normal size limit of [kOcrMaxOutputLongEdge].
  final int enlargeFactor;

  /// Unsharp-mask strength from 0 (off) to 100.
  final int sharpen;

  /// Whether to generate fast preview thumbnail bytes for the UI.
  final bool generatePreview;

  /// Maximum edge dimension for the preview thumbnail.
  final int previewMaxDimension;

  /// Whether to apply the OCR size rules (shrink to [kOcrMaxOutputLongEdge],
  /// or enlarge by [enlargeFactor]).
  ///
  /// `false` keeps the image at its own size. Used for the rotated copy handed
  /// to the crop tool, which must stay untouched apart from the rotation.
  final bool fitToOcrSize;

  OcrEnhanceParams copyWith({
    String? sourcePath,
    String? targetPath,
    int? rotationAngle,
    int? brightness,
    int? contrast,
    OcrEnhanceFilter? filter,
    bool? invert,
    int? enlargeFactor,
    int? sharpen,
    bool? generatePreview,
    int? previewMaxDimension,
    bool? fitToOcrSize,
  }) {
    return OcrEnhanceParams(
      sourcePath: sourcePath ?? this.sourcePath,
      targetPath: targetPath ?? this.targetPath,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      filter: filter ?? this.filter,
      invert: invert ?? this.invert,
      enlargeFactor: enlargeFactor ?? this.enlargeFactor,
      sharpen: sharpen ?? this.sharpen,
      generatePreview: generatePreview ?? this.generatePreview,
      previewMaxDimension: previewMaxDimension ?? this.previewMaxDimension,
      fitToOcrSize: fitToOcrSize ?? this.fitToOcrSize,
    );
  }
}

/// Result of document image enhancement.
@immutable
class OcrEnhanceResult {
  const OcrEnhanceResult({
    required this.targetPath,
    required this.width,
    required this.height,
    this.previewBytes,
  });

  /// Path to the full-resolution lossless PNG file on disk.
  final String targetPath;

  /// Width of the processed image in pixels.
  final int width;

  /// Height of the processed image in pixels.
  final int height;

  /// Fast display preview bytes (PNG encoded).
  final Uint8List? previewBytes;
}

/// Longest edge of the enhanced image when no enlargement is chosen.
///
/// Matches the working copy made from the camera photo
/// (`kOcrCaptureMaxLongEdge`), so the detail the camera captured reaches the
/// reader instead of being shrunk away here. A full page at this size is about
/// 340 dpi.
const int kOcrMaxOutputLongEdge = 4000;

/// Largest image, in pixels, the enhancer will decode.
///
/// The Dart image library holds about 4 bytes per pixel, and the pipeline makes
/// several copies, so a full-size 50 MP photo would run the phone out of
/// memory. Real inputs are the shrunk working copy (at most 4000 px on the long
/// edge, 12 to 16 MP), so this only stops an unexpected giant file.
const int kOcrMaxDecodePixels = 25000000;

/// Thrown when an image is larger than [kOcrMaxDecodePixels].
class OcrImageTooLargeException implements Exception {
  const OcrImageTooLargeException();

  @override
  String toString() => 'OcrImageTooLargeException';
}

/// Longest edge an enlarged image may reach. At this size a page is about
/// 15 megapixels, which the phone can still hold and read.
const int kOcrEnlargedMaxLongEdge = 4500;

/// Longest edge of the on-screen preview. Large enough that pinch-zoom shows
/// real letter detail instead of blur.
const int kOcrPreviewMaxDimension = 2400;

/// The enlarge factors the user can pick.
const List<int> kOcrEnlargeFactors = [1, 2, 3];

/// Fraction of the darkest and lightest pixels ignored when choosing the black
/// and white points, so a few specks of dust or a glare highlight cannot decide
/// the whole page's levels.
///
/// Kept well below the share of the page that ink covers. Text often covers
/// less than 5% of a photo; at 5% the black point then landed in the paper
/// grain or a screen's moiré texture, and the stretch blew that texture up into
/// fake ink that no recognizer could read past.
const double kOcrLevelClipFraction = 0.005;

/// Stretches a grayscale image's tones so the darkest 0.5% of pixels become
/// black and the lightest 0.5% become white.
///
/// A photographed page is never true black on true white — it comes back as
/// dark grey ink on light grey paper. Recognition binarizes the image, and the
/// closer the ink and paper already are to black and white, the less the
/// binarizer has to guess. Call this before any contrast lift.
img.Image normalizeOcrLevels(img.Image image) {
  final histogram = List<int>.filled(256, 0);
  for (final pixel in image) {
    histogram[pixel.r.round().clamp(0, 255)]++;
  }

  final total = image.width * image.height;
  if (total == 0) return image;

  final clip = (total * kOcrLevelClipFraction).round();

  var low = 0;
  var counted = 0;
  for (var value = 0; value < 256; value++) {
    counted += histogram[value];
    if (counted > clip) {
      low = value;
      break;
    }
  }

  var high = 255;
  counted = 0;
  for (var value = 255; value >= 0; value--) {
    counted += histogram[value];
    if (counted > clip) {
      high = value;
      break;
    }
  }

  // Too flat to stretch safely — a nearly blank or single-tone image. Leave it
  // alone rather than amplifying its noise into fake ink.
  if (high - low < 16) return image;

  final span = (high - low).toDouble();
  final lookup = List<int>.generate(
    256,
    (value) => (((value - low) / span) * 255).round().clamp(0, 255),
  );

  for (final pixel in image) {
    final value = lookup[pixel.r.round().clamp(0, 255)];
    pixel.setRgb(value, value, value);
  }
  return image;
}

/// Median grey level (0-255) of a grayscale image.
int _medianLevel(img.Image image) {
  final histogram = List<int>.filled(256, 0);
  for (final pixel in image) {
    histogram[pixel.r.round().clamp(0, 255)]++;
  }
  final half = (image.width * image.height) ~/ 2;
  var counted = 0;
  for (var value = 0; value < 256; value++) {
    counted += histogram[value];
    if (counted > half) return value;
  }
  return 255;
}

/// Cleans up a photo of a monitor or phone screen for recognition.
///
/// 1. Grayscale.
/// 2. If most of the picture is dark (light text on a dark screen), invert it,
///    since the recognizer reads dark ink on light paper.
/// 3. Even out the lighting: estimate the background with a heavy blur of a
///    small copy and divide the image by it. Glare patches and dark corners
///    then become one even white.
/// 4. A very light blur to soften the screen's pixel grid (moire).
/// 5. Stretch the levels to full black and white.
img.Image flattenScreenPhoto(img.Image source) {
  var image = img.grayscale(source);
  if (_medianLevel(image) < 128) image = img.invert(image);

  final longEdge = math.max(image.width, image.height);
  if (longEdge >= 64) {
    // Work on a copy about 256 px long so the heavy blur stays cheap.
    final shrink = 256 / longEdge;
    final small = img.copyResize(
      image,
      width: math.max(1, (image.width * shrink).round()),
      height: math.max(1, (image.height * shrink).round()),
      interpolation: img.Interpolation.average,
    );
    // A radius wider than a letter, so the text itself is blurred away and
    // only the lighting remains.
    final blurred = img.gaussianBlur(small, radius: 12);
    final background = img.copyResize(
      blurred,
      width: image.width,
      height: image.height,
      interpolation: img.Interpolation.linear,
    );
    final bgPixels = background.iterator;
    for (final pixel in image) {
      bgPixels.moveNext();
      final bg = math.max(1.0, bgPixels.current.r.toDouble());
      final value = (pixel.r / bg * 255).round().clamp(0, 255);
      pixel.setRgb(value, value, value);
    }
  }

  image = img.gaussianBlur(image, radius: 1);
  return normalizeOcrLevels(image);
}

/// Scales [image] up by [factor] (1, 2 or 3), capped so the long edge never
/// passes [kOcrEnlargedMaxLongEdge]. An image already past the cap is shrunk
/// to it.
img.Image enlargeForOcr(img.Image image, int factor) {
  final longEdge = math.max(image.width, image.height);
  if (longEdge == 0) return image;
  final scale = math.min(factor.toDouble(), kOcrEnlargedMaxLongEdge / longEdge);
  if ((scale - 1.0).abs() < 0.01) return image;
  return img.copyResize(
    image,
    width: math.max(1, (image.width * scale).round()),
    height: math.max(1, (image.height * scale).round()),
    interpolation: img.Interpolation.cubic,
  );
}

/// The size rule used when no enlargement is chosen: shrink to
/// [kOcrMaxOutputLongEdge], or enlarge a very short strip of one or two lines.
img.Image _fitDefaultOcrSize(img.Image image) {
  const int maxOcrDimension = kOcrMaxOutputLongEdge;
  final longestDimension = math.max(image.width, image.height);
  if (longestDimension > maxOcrDimension) {
    final scale = maxOcrDimension / longestDimension;
    return img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  } else if (image.height < 220 && longestDimension * 2 <= maxOcrDimension) {
    // If a crop is short in height (e.g. a 1 or 2 line snippet), scale it up
    // so individual characters have enough pixel resolution (x-height >= 28px) for
    // Tesseract's neural network to detect complex vowel marks, numbers, and ligatures.
    final scale = math.min(2.0, maxOcrDimension / longestDimension);
    if (scale > 1.2) {
      return img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
  }
  return image;
}

/// Unsharp mask: image + k * (image - blurred), where k grows with [amount]
/// (0-100). 0 returns the image untouched.
img.Image sharpenForOcr(img.Image image, int amount) {
  if (amount <= 0) return image;
  final k = amount.clamp(0, 100) / 100 * 1.5;
  final blurred = img.gaussianBlur(image.clone(), radius: 2);
  final blurPixels = blurred.iterator;
  for (final pixel in image) {
    blurPixels.moveNext();
    final b = blurPixels.current;
    pixel.setRgb(
      (pixel.r + k * (pixel.r - b.r)).round().clamp(0, 255),
      (pixel.g + k * (pixel.g - b.g)).round().clamp(0, 255),
      (pixel.b + k * (pixel.b - b.b)).round().clamp(0, 255),
    );
  }
  return image;
}

/// Background isolate worker for lossless document image processing.
OcrEnhanceResult processOcrImageIsolate(OcrEnhanceParams params) {
  final file = File(params.sourcePath);
  if (!file.existsSync()) {
    throw FileSystemException('Source image does not exist', params.sourcePath);
  }

  final bytes = file.readAsBytesSync();

  // Header only: the stored size, without decoding a single pixel. Refuse an
  // image too large to decode safely rather than run out of memory.
  final info = img.findDecoderForData(bytes)?.startDecode(bytes);
  if (info == null) {
    throw const FormatException('Unknown image format');
  }
  if (info.width * info.height > kOcrMaxDecodePixels) {
    throw const OcrImageTooLargeException();
  }

  final img.Image? raw = img.decodeImage(bytes);
  if (raw == null) {
    throw const FormatException('Failed to decode source image');
  }

  // 1. Normalize EXIF orientation first so coordinates are upright.
  var image = img.bakeOrientation(raw);

  // 2. Apply manual rotation in 90-degree steps.
  final normalizedAngle = (params.rotationAngle % 360 + 360) % 360;
  if (normalizedAngle != 0) {
    image = img.copyRotate(image, angle: normalizedAngle.toDouble());
  }

  // 3. Flip light and dark, before the filter runs, so the filter works on
  // dark-ink-on-light-paper the way it expects.
  if (params.invert) {
    image = img.invert(image);
  }

  // 4. Apply Filter Preset.
  switch (params.filter) {
    case OcrEnhanceFilter.original:
      break;
    case OcrEnhanceFilter.grayscale:
      image = img.grayscale(image);
      break;
    case OcrEnhanceFilter.documentBw:
      image = img.grayscale(image);
      // Stretch the levels first. Without this a photographed page keeps a grey
      // cast, so a plain contrast lift darkens the paper along with the ink and
      // the recognizer's binarizer still has to guess where the ink ends.
      image = normalizeOcrLevels(image);
      // Clean contrast boost to separate ink from paper without eroding thin vowel signs.
      image = img.contrast(image, contrast: 130);
      break;
    case OcrEnhanceFilter.enhance:
      // Mild contrast boost + grayscale for crisp legibility.
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 118);
      break;
    case OcrEnhanceFilter.screen:
      image = flattenScreenPhoto(image);
      break;
  }

  // 5. Apply Brightness adjustment (-100 to 100).
  if (params.brightness != 0) {
    final factor = 1.0 + (params.brightness / 100.0);
    image = img.adjustColor(image, brightness: factor);
  }

  // 6. Apply Contrast adjustment (-100 to 100).
  if (params.contrast != 0) {
    final factor = 1.0 + (params.contrast / 100.0);
    image = img.adjustColor(image, contrast: factor);
  }

  // 7. Optimal dimension scaling for OCR accuracy and memory safety.
  if (!params.fitToOcrSize) {
    // Keep the image at its own size.
  } else if (params.enlargeFactor > 1) {
    image = enlargeForOcr(image, params.enlargeFactor);
  } else {
    image = _fitDefaultOcrSize(image);
  }

  // 8. Sharpen after any resize, since enlarging softens the edges.
  image = sharpenForOcr(image, params.sharpen);

  // 9. Fast lossless PNG output for OCR recognition (compression level 1 for max speed).
  final pngBytes = Uint8List.fromList(img.encodePng(image, level: 1));
  File(params.targetPath).writeAsBytesSync(pngBytes);

  // 10. Generate fast UI preview thumbnail if requested.
  Uint8List? previewBytes;
  if (params.generatePreview) {
    final longestEdge = math.max(image.width, image.height);
    if (longestEdge > params.previewMaxDimension) {
      final scale = params.previewMaxDimension / longestEdge;
      final previewImg = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
      previewBytes = Uint8List.fromList(img.encodePng(previewImg, level: 1));
    } else {
      previewBytes = pngBytes;
    }
  }

  return OcrEnhanceResult(
    targetPath: params.targetPath,
    width: image.width,
    height: image.height,
    previewBytes: previewBytes,
  );
}

/// Service class for document image enhancement.
class OcrEnhancer {
  const OcrEnhancer();

  /// Runs document image enhancement in a background isolate to keep the UI smooth.
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params) async {
    try {
      return await compute(processOcrImageIsolate, params);
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhancer: image enhancement failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
