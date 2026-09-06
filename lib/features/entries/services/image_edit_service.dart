import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Contract for image editing operations (crop, rotate) before OCR.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class ImageEditService {
  /// Opens a crop-and-rotate editor for the image at [sourcePath].
  ///
  /// [toolbarTitle] is shown in the editor's app bar.
  /// [toolbarColor], [toolbarWidgetColor], and [statusBarBrightness] style the
  /// native editor UI to match the app's current theme.
  ///
  /// Returns the path to the edited image, or `null` if the user cancelled.
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required Color toolbarColor,
    required Color toolbarWidgetColor,
    required Brightness statusBarBrightness,
    required Color activeControlColor,
  });
}

/// On-device image editing backed by [ImageCropper] (uCrop on Android).
class CropperImageEditService implements ImageEditService {
  const CropperImageEditService({this.imageCropper});

  /// Allows injection for testing. When `null`, a fresh instance is created.
  final ImageCropper? imageCropper;

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required Color toolbarColor,
    required Color toolbarWidgetColor,
    required Brightness statusBarBrightness,
    required Color activeControlColor,
  }) async {
    final cropper = imageCropper ?? ImageCropper();

    try {
      final croppedFile = await cropper.cropImage(
        sourcePath: sourcePath,
        // Lossless PNG, not the default JPEG at quality 90. JPEG blur eats the
        // one-pixel strokes of `.`, `=`, `,` and `:`, so the crop step must not
        // degrade the image before OCR ever sees it.
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            toolbarColor: toolbarColor,
            toolbarWidgetColor: toolbarWidgetColor,
            // statusBarLight: true = light status bar (dark icons).
            statusBarLight: statusBarBrightness == Brightness.light,
            activeControlsWidgetColor: activeControlColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) {
        AppLogger.info('ImageEditService: crop cancelled by user');
        return null;
      }

      AppLogger.info('ImageEditService: crop complete');
      return croppedFile.path;
    } catch (e, stackTrace) {
      AppLogger.error(
        'ImageEditService: crop failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
