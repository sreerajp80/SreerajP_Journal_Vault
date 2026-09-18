import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

import 'ocr_enhance_test_fakes.dart';

void main() {
  late Directory tempDir;
  late String dummyImagePath;
  late Uint8List dummyImageBytes;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhance_ui_test_');
    final image = img.Image(width: 50, height: 50);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    dummyImageBytes = Uint8List.fromList(img.encodePng(image));
    dummyImagePath = '${tempDir.path}/test_doc.png';
    File(dummyImagePath).writeAsBytesSync(dummyImageBytes);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildLauncher({
    required OcrService ocrService,
    required OcrEnhancer enhancer,
    required OcrCaptureDownscaler downscaler,
    ImageEditService? cropper,
    OcrLanguageStore? languageStore,
    required void Function(String? text) onResult,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                onResult(
                  await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => OcrEnhanceScreen(
                        imagePath: dummyImagePath,
                        ocrService: ocrService,
                        ocrEnhancer: enhancer,
                        imageEditService: cropper,
                        captureDownscaler: downscaler,
                        languageStore:
                            languageStore ?? InMemoryOcrLanguageStore(),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open Enhance'),
            );
          },
        ),
      ),
    );
  }

  Future<void> openScreen(WidgetTester tester) async {
    await tester.tap(find.text('Open Enhance'));
    await tester.pumpAndSettle();
  }

  testWidgets('image tools never start text recognition on their own', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService(textToReturn: 'Sample text detection');
    final fakeEnhancer = FakeOcrEnhancer(previewBytes: dummyImageBytes);
    final fakeCropper = FakeImageEditService();

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: fakeEnhancer,
        downscaler: PassThroughCaptureDownscaler(),
        cropper: fakeCropper,
        onResult: (_) {},
      ),
    );
    await openScreen(tester);

    // Tool buttons and the text preview icon are present.
    expect(find.byKey(const Key('ocr-rotate-left-btn')), findsOneWidget);
    expect(find.byKey(const Key('ocr-rotate-right-btn')), findsOneWidget);
    expect(find.byKey(const Key('ocr-crop-btn')), findsOneWidget);
    expect(find.byKey(const Key('ocr-filter-tab-btn')), findsOneWidget);
    expect(find.byKey(const Key('ocr-adjust-tab-btn')), findsOneWidget);
    expect(find.byKey(const Key('ocr-text-preview-btn')), findsOneWidget);
    expect(find.byTooltip('Preview text'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();
    expect(fakeEnhancer.lastParams?.rotationAngle, 90);

    await tester.tap(find.byKey(const Key('ocr-filter-tab-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(fakeEnhancer.lastParams?.filter, OcrEnhanceFilter.documentBw);

    await tester.tap(find.byKey(const Key('ocr-adjust-tab-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ocr-brightness-slider')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ocr-crop-btn')));
    await tester.pumpAndSettle();
    expect(fakeCropper.cropCallCount, 1);

    // Nothing above asked for text, so nothing was read.
    expect(fakeOcr.callCount, 0);
    expect(find.text('Sample text detection'), findsNothing);
  });

  testWidgets('preview icon reads the text once and keeps it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService(textToReturn: 'Sample text detection');
    String? returnedText;

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: FakeOcrEnhancer(previewBytes: dummyImageBytes),
        downscaler: PassThroughCaptureDownscaler(),
        onResult: (text) => returnedText = text,
      ),
    );
    await openScreen(tester);

    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Sample text detection'), findsOneWidget);
    expect(find.text('3 words detected'), findsOneWidget);
    expect(fakeOcr.callCount, 1);

    // Close and open again: the kept text is shown without a new read.
    await tester.tap(find.byKey(const Key('ocr-preview-close-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Sample text detection'), findsOneWidget);
    expect(fakeOcr.callCount, 1);

    // Insert from the sheet returns the text to the caller.
    await tester.tap(find.byKey(const Key('ocr-preview-insert-btn')));
    await tester.pumpAndSettle();
    expect(returnedText, 'Sample text detection');
    expect(fakeOcr.callCount, 1);
  });

  testWidgets('changing the image clears the kept text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService(textToReturn: 'Sample text detection');
    String? returnedText;

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: FakeOcrEnhancer(previewBytes: dummyImageBytes),
        downscaler: PassThroughCaptureDownscaler(),
        onResult: (text) => returnedText = text,
      ),
    );
    await openScreen(tester);

    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pumpAndSettle();
    expect(fakeOcr.callCount, 1);
    await tester.tap(find.byKey(const Key('ocr-preview-close-btn')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();
    expect(fakeOcr.callCount, 1);

    // Insert must read the rotated image, not reuse the old text.
    await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
    await tester.pumpAndSettle();
    expect(fakeOcr.callCount, 2);
    expect(returnedText, 'Sample text detection');
  });

  testWidgets('insert reads the text when it has not been read yet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService(textToReturn: 'Inserted directly');
    String? returnedText;

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: FakeOcrEnhancer(previewBytes: dummyImageBytes),
        downscaler: PassThroughCaptureDownscaler(),
        onResult: (text) => returnedText = text,
      ),
    );
    await openScreen(tester);
    expect(fakeOcr.callCount, 0);

    await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
    await tester.pumpAndSettle();

    expect(fakeOcr.callCount, 1);
    expect(returnedText, 'Inserted directly');
  });

  testWidgets('language change in the preview re-reads once and is saved', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService(textToReturn: 'മലയാളം ടെക്സ്റ്റ്');
    final store = InMemoryOcrLanguageStore();

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: FakeOcrEnhancer(),
        downscaler: PassThroughCaptureDownscaler(),
        languageStore: store,
        onResult: (_) {},
      ),
    );
    await openScreen(tester);

    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pumpAndSettle();

    final langSelector = find.byKey(const Key('ocr-language-selector'));
    expect(langSelector, findsOneWidget);
    expect(find.text('English + മലയാളം'), findsOneWidget);
    expect(fakeOcr.lastLanguage, 'eng+mal');
    expect(fakeOcr.callCount, 1);

    await tester.tap(langSelector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('മലയാളം').last);
    await tester.pumpAndSettle();

    expect(fakeOcr.lastLanguage, 'mal');
    expect(fakeOcr.callCount, 2);
    expect(await store.read(), 'mal');
  });

  testWidgets('uses the language saved from an earlier scan', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeOcr = FakeOcrService();

    await tester.pumpWidget(
      buildLauncher(
        ocrService: fakeOcr,
        enhancer: FakeOcrEnhancer(),
        downscaler: PassThroughCaptureDownscaler(),
        languageStore: InMemoryOcrLanguageStore('eng'),
        onResult: (_) {},
      ),
    );
    await openScreen(tester);

    await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
    await tester.pumpAndSettle();

    expect(fakeOcr.lastLanguage, 'eng');
  });

  testWidgets('closing the preview while reading cancels the read', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final slowOcr = SlowOcrService();

    await tester.pumpWidget(
      buildLauncher(
        ocrService: slowOcr,
        enhancer: FakeOcrEnhancer(previewBytes: dummyImageBytes),
        downscaler: PassThroughCaptureDownscaler(),
        onResult: (_) {},
      ),
    );
    await openScreen(tester);

    await tester.tap(find.byKey(const Key('ocr-text-preview-btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(slowOcr.requestIds, hasLength(1));
    expect(slowOcr.cancelledRequestIds, isEmpty);

    await tester.tap(find.byKey(const Key('ocr-preview-close-btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(slowOcr.cancelledRequestIds, <int?>[slowOcr.requestIds.first]);
  });

  testWidgets('cancels recognition still running when the screen closes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final slowOcr = SlowOcrService();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      buildLauncher(
        ocrService: slowOcr,
        enhancer: FakeOcrEnhancer(previewBytes: dummyImageBytes),
        downscaler: PassThroughCaptureDownscaler(),
        navigatorKey: navigatorKey,
        onResult: (_) {},
      ),
    );
    await openScreen(tester);

    // Insert starts a read that never finishes.
    await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(slowOcr.requestIds, hasLength(1));

    // The user presses back while recognition is still running.
    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(slowOcr.cancelledRequestIds, <int?>[slowOcr.requestIds.first]);
  });

  testWidgets('shrinks the capture before it is enhanced', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('ocr_master_test_');
    addTearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // A leftover temp file is harmless.
      }
    });

    final capturePath = p.join(tempDir.path, 'capture.jpg');
    File(capturePath).writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

    // The working copy the downscaler hands back, standing in for a shrunk
    // full-resolution photo.
    final workingCopyPath = p.join(tempDir.path, 'working_copy.png');
    File(workingCopyPath).writeAsBytesSync(Uint8List.fromList([4, 5, 6]));

    final fakeOcr = FakeOcrService();
    final fakeEnhancer = FakeOcrEnhancer();
    final fakeDownscaler = ShrinkingCaptureDownscaler(workingCopyPath);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OcrEnhanceScreen(
            imagePath: capturePath,
            ocrService: fakeOcr,
            ocrEnhancer: fakeEnhancer,
            captureDownscaler: fakeDownscaler,
            languageStore: InMemoryOcrLanguageStore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeDownscaler.received, <String>[capturePath]);
    // Enhancement must read the shrunk copy, not the full-size capture. Reading
    // the original here would decode a 50 MP photo in Dart and run out of
    // memory on a real device.
    expect(fakeEnhancer.lastParams?.sourcePath, workingCopyPath);
  });
}
