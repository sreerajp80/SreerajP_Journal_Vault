import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

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
