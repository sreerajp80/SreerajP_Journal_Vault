import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_camera_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

const CameraDescription _backCamera = CameraDescription(
  name: '0',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

/// Stand-in camera controller that reports itself as ready straight away.
class _FakeCameraController extends ValueNotifier<CameraValue>
    implements CameraController {
  _FakeCameraController()
    : super(
        const CameraValue.uninitialized(_backCamera).copyWith(
          isInitialized: true,
          previewSize: const Size(1080, 1920),
          flashMode: FlashMode.auto,
        ),
      );

  bool initializeCalled = false;
  bool disposeCalled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> dispose() async {
    disposeCalled = true;
    super.dispose();
  }

  @override
  Future<double> getMinExposureOffset() async => -2.0;

  @override
  Future<double> getMaxExposureOffset() async => 2.0;

  @override
  Future<double> getExposureOffsetStepSize() async => 0.5;

  @override
  Future<double> getMinZoomLevel() async => 1.0;

  @override
  Future<double> getMaxZoomLevel() async => 4.0;

  @override
  Future<void> setFlashMode(FlashMode mode) async {}

  @override
  Widget buildPreview() =>
      const SizedBox(key: Key('mock-camera-preview'), width: 300, height: 400);
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.navigatorKey});

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

  group('OcrCameraScreen camera lifecycle', () {
    testWidgets(
      'keeps the camera off while another screen is on top, and brings it '
      'back when that screen closes',
      (tester) async {
        final created = <_FakeCameraController>[];
        final navigatorKey = GlobalKey<NavigatorState>();
        final initialController = _FakeCameraController();

        await tester.pumpWidget(
          _TestApp(
            navigatorKey: navigatorKey,
            child: OcrCameraScreen(
              cameras: const [_backCamera],
              initialController: initialController,
              controllerFactory: (_) {
                final controller = _FakeCameraController();
                created.add(controller);
                return controller;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The viewfinder is live, so no loading spinner.
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // A second screen (the enhance screen in the real app) covers it.
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('enhance')),
          ),
        );
        await tester.pumpAndSettle();

        // The crop tool is a separate Android screen, so the app is paused
        // and then resumed while the camera screen is hidden.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        expect(initialController.disposeCalled, isTrue);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        // A spinner animates forever, so pump a fixed number of frames rather
        // than waiting for the tree to go still.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Nothing is rebuilt while the camera screen is out of sight, so the
        // screen the user is on keeps the whole device to itself.
        expect(created, isEmpty);

        // Coming back to the camera screen rebuilds the camera.
        navigatorKey.currentState!.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 100));

        expect(created, hasLength(1));
        expect(created.single.initializeCalled, isTrue);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('rebuilds the camera on resume when it is the visible screen', (
      tester,
    ) async {
      final created = <_FakeCameraController>[];
      final initialController = _FakeCameraController();

      await tester.pumpWidget(
        _TestApp(
          child: OcrCameraScreen(
            cameras: const [_backCamera],
            initialController: initialController,
            controllerFactory: (_) {
              final controller = _FakeCameraController();
              created.add(controller);
              return controller;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(created, hasLength(1));
      expect(created.single.initializeCalled, isTrue);
    });
  });
}
