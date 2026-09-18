import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_camera_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _FakeImagePicker extends Fake implements ImagePicker {
  _FakeImagePicker({this.fileToReturn});

  final XFile? fileToReturn;
  ImageSource? lastSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    return fileToReturn;
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OcrCameraScreen permissions and fallbacks', () {
    testWidgets('shows permission denied UI when camera permission is denied', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall call) async {
              if (call.method == 'requestPermissions') {
                return {
                  1: 0, // Permission.camera = 1, PermissionStatus.denied = 0
                };
              }
              return null;
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('flutter.baseflow.com/permissions/methods'),
              null,
            );
      });

      final fakePicker = _FakeImagePicker(
        fileToReturn: XFile('/path/to/gallery_doc.png'),
      );

      String? returnedPath;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  returnedPath = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => OcrCameraScreen(imagePicker: fakePicker),
                    ),
                  );
                },
                child: const Text('Open Camera'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Camera'));
      await tester.pumpAndSettle();

      // Verify permission denied view
      expect(
        find.text(
          'Camera permission is required to photograph documents for text recognition.',
        ),
        findsOneWidget,
      );
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);

      // Tap gallery fallback
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(fakePicker.lastSource, ImageSource.gallery);
      expect(returnedPath, '/path/to/gallery_doc.png');
    });

    testWidgets('shows error UI when no cameras are available', (tester) async {
      // Mock permission handler channel to return granted (status = 1)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall call) async {
              if (call.method == 'requestPermissions') {
                return {
                  1: 1, // Permission.camera = 1, PermissionStatus.granted = 1
                };
              }
              return null;
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('flutter.baseflow.com/permissions/methods'),
              null,
            );
      });

      final fakePicker = _FakeImagePicker(
        fileToReturn: XFile('/path/to/gallery_doc.png'),
      );

      String? returnedPath;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  returnedPath = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => OcrCameraScreen(
                        cameras: const [], // Empty camera list
                        imagePicker: fakePicker,
                      ),
                    ),
                  );
                },
                child: const Text('Open Camera'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Camera'));
      await tester.pumpAndSettle();

      // Verify error view
      expect(find.text('No camera found on this device.'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);

      // Tap gallery fallback
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(fakePicker.lastSource, ImageSource.gallery);
      expect(returnedPath, '/path/to/gallery_doc.png');
    });
  });

  group('OcrCameraScreen live viewfinder and controls', () {
    testWidgets(
      'renders controls and interacts with flash, zoom, grid, and shutter',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeController = _FakeCameraController();
        String? capturedPath;

        await tester.pumpWidget(
          _TestApp(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    capturedPath = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) =>
                            OcrCameraScreen(initialController: fakeController),
                      ),
                    );
                  },
                  child: const Text('Open Camera'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Camera'));
        await tester.pumpAndSettle();

        // Top bar buttons exist
        expect(find.byKey(const Key('ocr-camera-flash-btn')), findsOneWidget);
        expect(find.byKey(const Key('ocr-camera-grid-btn')), findsOneWidget);

        // Shutter and gallery buttons exist
        expect(find.byKey(const Key('ocr-camera-shutter-btn')), findsOneWidget);
        expect(find.byKey(const Key('ocr-camera-gallery-btn')), findsOneWidget);

        // Quick zoom buttons exist
        expect(find.text('1×'), findsOneWidget);
        expect(find.text('2×'), findsOneWidget);

        // Tap flash toggle
        // Flash starts off, because flash glare hides words on paper, so
        // the first tap moves it to auto.
        await tester.tap(find.byKey(const Key('ocr-camera-flash-btn')));
        await tester.pumpAndSettle();
        expect(fakeController.lastFlashMode, FlashMode.auto);

        // Tap 2x zoom button
        await tester.tap(find.text('2×'));
        await tester.pumpAndSettle();
        expect(fakeController.lastZoom, 2.0);

        // Tap grid toggle button
        await tester.tap(find.byKey(const Key('ocr-camera-grid-btn')));
        await tester.pumpAndSettle();

        // Tap on preview to focus
        await tester.tapAt(const Offset(400, 500));
        await tester.pump();
        expect(fakeController.lastFocusPoint, isNotNull);

        // Tap shutter button
        await tester.tap(find.byKey(const Key('ocr-camera-shutter-btn')));
        await tester.pumpAndSettle();

        expect(fakeController.takePictureCalled, isTrue);
        expect(capturedPath, '/path/to/captured_document.jpg');
      },
    );

    testWidgets(
      'toggles advanced camera controls panel with exposure and focus options',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeController = _FakeCameraController();

        await tester.pumpWidget(
          _TestApp(child: OcrCameraScreen(initialController: fakeController)),
        );
        await tester.pumpAndSettle();

        final controlsBtn = find.byKey(const Key('ocr-camera-controls-btn'));
        expect(controlsBtn, findsOneWidget);

        // Tap controls button to open adjustments panel
        await tester.tap(controlsBtn);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ocr-camera-exposure-slider')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('ocr-camera-zoom-slider')), findsOneWidget);
        expect(
          find.byKey(const Key('ocr-camera-focus-mode-chip')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ocr-camera-exposure-mode-chip')),
          findsOneWidget,
        );

        // Tap focus mode chip to lock focus
        await tester.tap(find.byKey(const Key('ocr-camera-focus-mode-chip')));
        await tester.pumpAndSettle();
        expect(fakeController.lastFocusMode, FocusMode.locked);

        // Tap exposure mode chip to lock exposure
        await tester.tap(
          find.byKey(const Key('ocr-camera-exposure-mode-chip')),
        );
        await tester.pumpAndSettle();
        expect(fakeController.lastExposureMode, ExposureMode.locked);

        // Tap controls button to close panel
        await tester.tap(controlsBtn);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('ocr-camera-exposure-slider')),
          findsNothing,
        );
      },
    );
  });
}

class _FakeCameraController extends ValueNotifier<CameraValue>
    implements CameraController {
  _FakeCameraController({CameraValue? value})
    : minZoom = 1.0,
      maxZoom = 4.0,
      super(
        value ??
            const CameraValue.uninitialized(
              CameraDescription(
                name: '0',
                lensDirection: CameraLensDirection.back,
                sensorOrientation: 90,
              ),
            ).copyWith(
              isInitialized: true,
              previewSize: const Size(1080, 1920),
              flashMode: FlashMode.auto,
              focusPointSupported: true,
              exposurePointSupported: true,
            ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  final double minZoom;
  final double maxZoom;
  FlashMode? lastFlashMode;
  double? lastZoom;
  Offset? lastFocusPoint;
  Offset? lastExposurePoint;
  double? lastExposureOffset;
  FocusMode? lastFocusMode;
  ExposureMode? lastExposureMode;
  bool takePictureCalled = false;

  @override
  Future<double> getMinExposureOffset() async => -2.0;

  @override
  Future<double> getMaxExposureOffset() async => 2.0;

  @override
  Future<double> getExposureOffsetStepSize() async => 0.5;

  @override
  Future<double> setExposureOffset(double offset) async {
    lastExposureOffset = offset;
    return offset;
  }

  @override
  Future<void> setFocusMode(FocusMode mode) async {
    lastFocusMode = mode;
  }

  @override
  Future<void> setExposureMode(ExposureMode mode) async {
    lastExposureMode = mode;
  }

  @override
  Future<double> getMinZoomLevel() async => minZoom;

  @override
  Future<double> getMaxZoomLevel() async => maxZoom;

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    lastFlashMode = mode;
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    lastZoom = zoom;
  }

  @override
  Future<void> setFocusPoint(Offset? point) async {
    lastFocusPoint = point;
  }

  @override
  Future<void> setExposurePoint(Offset? point) async {
    lastExposurePoint = point;
  }

  @override
  Future<XFile> takePicture() async {
    takePictureCalled = true;
    return XFile('/path/to/captured_document.jpg');
  }

  @override
  Widget buildPreview() =>
      const SizedBox(key: Key('mock-camera-preview'), width: 300, height: 400);

  // ignore: unnecessary_overrides
  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
