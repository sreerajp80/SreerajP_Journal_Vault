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
    this.generatePreview = true,
    this.previewMaxDimension = 1200,
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

  /// Whether to generate fast preview thumbnail bytes for the UI.
  final bool generatePreview;

  /// Maximum edge dimension for the preview thumbnail.
  final int previewMaxDimension;

  OcrEnhanceParams copyWith({
    String? sourcePath,
    String? targetPath,
    int? rotationAngle,
    int? brightness,
    int? contrast,
    OcrEnhanceFilter? filter,
    bool? invert,
    bool? generatePreview,
    int? previewMaxDimension,
  }) {
    return OcrEnhanceParams(
      sourcePath: sourcePath ?? this.sourcePath,
      targetPath: targetPath ?? this.targetPath,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      filter: filter ?? this.filter,
      invert: invert ?? this.invert,
      generatePreview: generatePreview ?? this.generatePreview,
      previewMaxDimension: previewMaxDimension ?? this.previewMaxDimension,
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

/// Fraction of the darkest and lightest pixels ignored when choosing the black
/// and white points, so a few specks of dust or a glare highlight cannot decide
/// the whole page's levels.
const double kOcrLevelClipFraction = 0.05;

/// Stretches a grayscale image's tones so the darkest 5% of pixels become black
/// and the lightest 5% become white.
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

/// Background isolate worker for lossless document image processing.
OcrEnhanceResult processOcrImageIsolate(OcrEnhanceParams params) {
  final file = File(params.sourcePath);
  if (!file.existsSync()) {
    throw FileSystemException('Source image does not exist', params.sourcePath);
  }

  final bytes = file.readAsBytesSync();
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
  const int maxOcrDimension = 3000;
  final longestDimension = math.max(image.width, image.height);
  if (longestDimension > maxOcrDimension) {
    final scale = maxOcrDimension / longestDimension;
    image = img.copyResize(
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
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
  }

  // 8. Fast lossless PNG output for OCR recognition (compression level 1 for max speed).
  final pngBytes = Uint8List.fromList(img.encodePng(image, level: 1));
  File(params.targetPath).writeAsBytesSync(pngBytes);

  // 9. Generate fast UI preview thumbnail if requested.
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
