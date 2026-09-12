import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Stands in for the native capture downscaler, which needs a real platform
/// codec and temp directory. Hands the photo straight back, the way the real
/// one does for an image that is already small enough.
class _PassThroughCaptureDownscaler implements OcrCaptureDownscaler {
  final List<String> received = <String>[];

  @override
  Future<String> downscale(String imagePath) async {
    received.add(imagePath);
    return imagePath;
  }
}

/// Hands back a different path, the way the real downscaler does when it has
/// written a shrunk working copy.
class _ShrinkingCaptureDownscaler implements OcrCaptureDownscaler {
  _ShrinkingCaptureDownscaler(this.workingCopyPath);

  final String workingCopyPath;
  final List<String> received = <String>[];

  @override
  Future<String> downscale(String imagePath) async {
    received.add(imagePath);
    return workingCopyPath;
  }
}

class _FakeOcrService implements OcrService {
  _FakeOcrService({this.textToReturn = 'Recognized sample invoice text'});

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
class _SlowOcrService implements OcrService {
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

class _FakeOcrEnhancer implements OcrEnhancer {
  _FakeOcrEnhancer({this.previewBytes});

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

class _FakeImageEditService implements ImageEditService {
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

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    );
  }
}

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

  testWidgets(
    'OcrEnhanceScreen renders tools and displays live recognized text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeOcr = _FakeOcrService(textToReturn: 'Sample text detection');
      final fakeEnhancer = _FakeOcrEnhancer(previewBytes: dummyImageBytes);
      final fakeCropper = _FakeImageEditService();
      final fakeDownscaler = _PassThroughCaptureDownscaler();

      String? returnedText;

      await tester.pumpWidget(
        ProviderScope(
          child: _TestApp(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    returnedText = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => OcrEnhanceScreen(
                          imagePath: dummyImagePath,
                          ocrService: fakeOcr,
                          ocrEnhancer: fakeEnhancer,
                          imageEditService: fakeCropper,
                          captureDownscaler: fakeDownscaler,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Enhance'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Enhance'));
      await tester.pumpAndSettle();

      // Tool buttons are present
      expect(find.byKey(const Key('ocr-rotate-left-btn')), findsOneWidget);
      expect(find.byKey(const Key('ocr-rotate-right-btn')), findsOneWidget);
      expect(find.byKey(const Key('ocr-crop-btn')), findsOneWidget);
      expect(find.byKey(const Key('ocr-filter-tab-btn')), findsOneWidget);
      expect(find.byKey(const Key('ocr-adjust-tab-btn')), findsOneWidget);

      // Live OCR recognized text is displayed
      expect(find.text('Sample text detection'), findsOneWidget);
      expect(find.text('3 words detected'), findsOneWidget);

      // Tap rotate right
      await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
      await tester.pumpAndSettle();
      expect(fakeEnhancer.lastParams?.rotationAngle, 90);

      // Tap filter tab
      await tester.tap(find.byKey(const Key('ocr-filter-tab-btn')));
      await tester.pumpAndSettle();
      expect(find.text('Document'), findsOneWidget);
      expect(find.text('Grayscale'), findsOneWidget);

      // Select Document filter
      await tester.tap(find.text('Document'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(fakeEnhancer.lastParams?.filter, OcrEnhanceFilter.documentBw);

      // Tap adjust tab
      await tester.tap(find.byKey(const Key('ocr-adjust-tab-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ocr-brightness-slider')), findsOneWidget);
      expect(find.byKey(const Key('ocr-contrast-slider')), findsOneWidget);

      // Tap crop tool
      await tester.tap(find.byKey(const Key('ocr-crop-btn')));
      await tester.pumpAndSettle();
      expect(fakeCropper.cropCallCount, 1);

      // Tap Insert into Entry button
      await tester.tap(find.byKey(const Key('ocr-enhance-insert-btn')));
      await tester.pumpAndSettle();

      expect(returnedText, 'Sample text detection');
    },
  );

  testWidgets(
    'allows switching OCR language and re-scans with selected language',
    (tester) async {
      final tempDir = Directory.systemTemp.createTempSync('ocr_lang_test_');
      final imagePath = p.join(tempDir.path, 'source.jpg');
      File(imagePath).writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

      final fakeOcr = _FakeOcrService(textToReturn: 'മലയാളം ടെക്സ്റ്റ്');
      final fakeEnhancer = _FakeOcrEnhancer();
      final fakeDownscaler = _PassThroughCaptureDownscaler();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OcrEnhanceScreen(
              imagePath: imagePath,
              ocrService: fakeOcr,
              ocrEnhancer: fakeEnhancer,
              captureDownscaler: fakeDownscaler,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify default language selector is displayed
      final langSelector = find.byKey(const Key('ocr-language-selector'));
      expect(langSelector, findsOneWidget);
      expect(find.text('English + മലയാളം'), findsOneWidget);
      expect(fakeOcr.lastLanguage, 'eng+mal');

      // Tap language selector to open menu
      await tester.tap(langSelector);
      await tester.pumpAndSettle();

      // Select Malayalam option
      expect(find.text('മലയാളം'), findsWidgets);
      await tester.tap(find.text('മലയാളം').last);
      await tester.pumpAndSettle();

      // Verify OCR service was called with 'mal'
      expect(fakeOcr.lastLanguage, 'mal');

      tempDir.deleteSync(recursive: true);
    },
  );

  testWidgets('cancels recognition still running when the screen closes', (
    tester,
  ) async {
    final slowOcr = _SlowOcrService();
    final fakeEnhancer = _FakeOcrEnhancer(previewBytes: dummyImageBytes);
    final fakeDownscaler = _PassThroughCaptureDownscaler();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('behind')),
        ),
      ),
    );

    unawaited(
      navigatorKey.currentState!.push(
        MaterialPageRoute<String>(
          builder: (_) => OcrEnhanceScreen(
            imagePath: dummyImagePath,
            ocrService: slowOcr,
            ocrEnhancer: fakeEnhancer,
            captureDownscaler: fakeDownscaler,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(slowOcr.requestIds, isNotEmpty);
    expect(slowOcr.cancelledRequestIds, isEmpty);

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

    final fakeOcr = _FakeOcrService();
    final fakeEnhancer = _FakeOcrEnhancer();
    final fakeDownscaler = _ShrinkingCaptureDownscaler(workingCopyPath);

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
