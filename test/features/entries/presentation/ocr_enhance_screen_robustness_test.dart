import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

import 'ocr_enhance_test_fakes.dart';

// Crop-once, visible failures, the time limit, and where working files go.

void main() {
  late Directory tempDir;
  late Directory workDir;
  late String photoPath;
  late Uint8List photoBytes;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhance_robust_');
    workDir = Directory(p.join(tempDir.path, 'cache'))..createSync();
    final image = img.Image(width: 50, height: 50);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    photoBytes = Uint8List.fromList(img.encodePng(image));
    photoPath = p.join(tempDir.path, 'photo.png');
    File(photoPath).writeAsBytesSync(photoBytes);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> openScreen(
    WidgetTester tester, {
    required OcrEnhancer enhancer,
    OcrService? ocrService,
    ImageEditService? cropper,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => OcrEnhanceScreen(
                    imagePath: photoPath,
                    ocrService: ocrService ?? FakeOcrService(),
                    ocrEnhancer: enhancer,
                    imageEditService: cropper,
                    captureDownscaler: PassThroughCaptureDownscaler(),
                    languageStore: InMemoryOcrLanguageStore(),
                    blurDetector: FakeOcrBlurDetector(),
                    tempFileSweeper: FakeOcrTempFileSweeper(workDir),
                  ),
                ),
              ),
              child: const Text('Open Enhance'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open Enhance'));
    await tester.pumpAndSettle();
  }

  Future<void> pickDocumentFilter(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('ocr-filter-tab-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'crop starts from the unfiltered turned image; filters run once',
    (tester) async {
      final enhancer = RecordingOcrEnhancer(previewBytes: photoBytes);
      final croppedPath = p.join(workDir.path, 'image_cropper_1.png');
      final cropper = RecordingImageEditService(croppedPath);
      await openScreen(tester, enhancer: enhancer, cropper: cropper);

      await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
      await tester.pumpAndSettle();
      await pickDocumentFilter(tester);

      await tester.tap(find.byKey(const Key('ocr-crop-btn')));
      await tester.pumpAndSettle();

      // The crop tool got a copy that is turned and nothing else.
      final cropInput = enhancer.calls.singleWhere(
        (c) => c.targetPath == cropper.sources.single,
      );
      expect(cropInput.sourcePath, photoPath);
      expect(cropInput.rotationAngle, 90);
      expect(cropInput.filter, OcrEnhanceFilter.original);
      expect(cropInput.fitToOcrSize, isFalse);
      expect(cropInput.generatePreview, isFalse);

      // After the crop, the filter is applied once, to the cropped image, which
      // already carries the turn.
      final last = enhancer.calls.last;
      expect(last.sourcePath, croppedPath);
      expect(last.rotationAngle, 0);
      expect(last.filter, OcrEnhanceFilter.documentBw);
      expect(last.fitToOcrSize, isTrue);
    },
  );

  testWidgets('crop with no turn crops the photo itself', (tester) async {
    final enhancer = RecordingOcrEnhancer(previewBytes: photoBytes);
    final cropper = RecordingImageEditService(
      p.join(workDir.path, 'image_cropper_2.png'),
    );
    await openScreen(tester, enhancer: enhancer, cropper: cropper);

    await pickDocumentFilter(tester);
    await tester.tap(find.byKey(const Key('ocr-crop-btn')));
    await tester.pumpAndSettle();

    expect(cropper.sources.single, photoPath);
  });

  testWidgets('working files go into the scan temp folder', (tester) async {
    final enhancer = RecordingOcrEnhancer(previewBytes: photoBytes);
    await openScreen(tester, enhancer: enhancer);

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();

    expect(enhancer.calls, isNotEmpty);
    for (final call in enhancer.calls) {
      expect(p.isWithin(workDir.path, call.targetPath), isTrue);
      expect(p.basename(call.targetPath), startsWith('ocr_enh_'));
    }
  });

  testWidgets('a change that cannot be applied is shown to the user', (
    tester,
  ) async {
    final enhancer = RecordingOcrEnhancer(
      previewBytes: photoBytes,
      error: StateError('out of memory'),
      failFrom: 1,
    );
    await openScreen(tester, enhancer: enhancer);

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not apply this change. Try again.'),
      findsOneWidget,
    );
  });

  testWidgets('a photo that cannot be opened says so', (tester) async {
    final enhancer = RecordingOcrEnhancer(
      error: const OcrImageTooLargeException(),
    );
    await openScreen(tester, enhancer: enhancer);

    expect(
      find.text('Could not open this photo. Try another one.'),
      findsOneWidget,
    );
  });

  const timedOutText =
      'Reading the text took too long. Crop to just the text and try again.';

  testWidgets('insert shows the time-limit message and stays open', (
    tester,
  ) async {
    await openScreen(
      tester,
      enhancer: RecordingOcrEnhancer(previewBytes: photoBytes),
      ocrService: TimingOutOcrService(),
    );

    await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
    await tester.pumpAndSettle();

    expect(find.text(timedOutText), findsOneWidget);
    expect(find.byType(OcrEnhanceScreen), findsOneWidget);
  });

  testWidgets('the text preview shows the time-limit message', (tester) async {
    await openScreen(
      tester,
      enhancer: RecordingOcrEnhancer(previewBytes: photoBytes),
      ocrService: TimingOutOcrService(),
    );

    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pumpAndSettle();

    expect(find.text(timedOutText), findsOneWidget);
  });
}
