import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_blur_detector.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_temp_file_sweeper.dart';

// Test doubles for ocr_enhance_screen_test.dart, kept apart so that file stays
// under the size limit.

/// Stands in for the native capture downscaler, which needs a real platform
/// codec and temp directory. Hands the photo straight back, the way the real
/// one does for an image that is already small enough.
class PassThroughCaptureDownscaler implements OcrCaptureDownscaler {
  final List<String> received = <String>[];

  @override
  Future<String> downscale(String imagePath) async {
    received.add(imagePath);
    return imagePath;
  }
}

/// Stands in for the native blur detector, which needs a real platform codec.
class FakeOcrBlurDetector implements OcrBlurDetector {
  FakeOcrBlurDetector({this.blurry = false});

  final bool blurry;
  final List<String> received = <String>[];

  @override
  Future<bool> isBlurry(String imagePath) async {
    received.add(imagePath);
    return blurry;
  }
}

/// Hands back a different path, the way the real downscaler does when it has
/// written a shrunk working copy.
class ShrinkingCaptureDownscaler implements OcrCaptureDownscaler {
  ShrinkingCaptureDownscaler(this.workingCopyPath);

  final String workingCopyPath;
  final List<String> received = <String>[];

  @override
  Future<String> downscale(String imagePath) async {
    received.add(imagePath);
    return workingCopyPath;
  }
}

class FakeOcrService implements OcrService {
  FakeOcrService({this.textToReturn = 'Recognized sample invoice text'});

  final String textToReturn;
  int callCount = 0;
  String? lastLanguage;
  final List<int> cancelledRequestIds = <int>[];

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  }) async {
    callCount++;
    lastLanguage = language;
    return textToReturn;
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {
    cancelledRequestIds.addAll(requestIds);
  }
}

/// OCR service whose recognition never finishes, so a request is still in
/// flight when the screen closes.
class SlowOcrService implements OcrService {
  final List<int> cancelledRequestIds = <int>[];
  final List<int?> requestIds = <int?>[];

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  }) {
    requestIds.add(requestId);
    return Completer<String>().future;
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {
    cancelledRequestIds.addAll(requestIds);
  }
}

class FakeOcrEnhancer implements OcrEnhancer {
  FakeOcrEnhancer({this.previewBytes});

  final Uint8List? previewBytes;
  int enhanceCallCount = 0;
  OcrEnhanceParams? lastParams;

  @override
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params) async {
    enhanceCallCount++;
    lastParams = params;
    File(params.targetPath).writeAsStringSync('enhanced_dummy_content');
    return OcrEnhanceResult(
      targetPath: params.targetPath,
      width: 200,
      height: 200,
      previewBytes: previewBytes,
    );
  }
}

class FakeImageEditService implements ImageEditService {
  int cropCallCount = 0;

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required Color toolbarColor,
    required Color toolbarWidgetColor,
    required Brightness statusBarBrightness,
    required Color activeControlColor,
  }) async {
    cropCallCount++;
    return sourcePath;
  }
}

/// Hands out a fixed temp folder instead of asking the platform for one.
class FakeOcrTempFileSweeper implements OcrTempFileSweeper {
  FakeOcrTempFileSweeper(this.directory);

  final Directory directory;
  final List<String?> deleted = <String?>[];
  int sweepCount = 0;

  @override
  Future<Directory> tempDirectory() async => directory;

  @override
  Future<void> deleteNow(String? path) async => deleted.add(path);

  @override
  Future<int> sweepStale() async {
    sweepCount++;
    return 0;
  }
}

/// Records every image it is given and hands back a new "cropped" file.
class RecordingImageEditService implements ImageEditService {
  RecordingImageEditService(this.croppedPath);

  final String croppedPath;
  final List<String> sources = <String>[];

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required Color toolbarColor,
    required Color toolbarWidgetColor,
    required Brightness statusBarBrightness,
    required Color activeControlColor,
  }) async {
    sources.add(sourcePath);
    File(croppedPath).writeAsStringSync('cropped');
    return croppedPath;
  }
}

/// Enhancer that records every call and fails with [error] once [failFrom]
/// calls have succeeded.
class RecordingOcrEnhancer implements OcrEnhancer {
  RecordingOcrEnhancer({this.previewBytes, this.error, this.failFrom = 0});

  final Uint8List? previewBytes;
  final Object? error;
  final int failFrom;
  final List<OcrEnhanceParams> calls = <OcrEnhanceParams>[];

  @override
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params) async {
    calls.add(params);
    if (error != null && calls.length > failFrom) throw error!;
    File(params.targetPath).writeAsStringSync('enhanced');
    return OcrEnhanceResult(
      targetPath: params.targetPath,
      width: 200,
      height: 200,
      previewBytes: previewBytes,
    );
  }
}

/// OCR service whose every read runs past its time limit.
class TimingOutOcrService implements OcrService {
  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  }) async {
    throw const OcrTimeoutException();
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {}
}
