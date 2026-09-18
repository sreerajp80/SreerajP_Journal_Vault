import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'ocr_camera_overlays.dart';
part 'ocr_camera_controls.dart';
part 'ocr_camera_controls_2.dart';
part 'ocr_camera_controls_3.dart';

/// In-app camera screen designed specifically for OCR document scanning.
///
/// Provides manual camera controls:
/// - Exposure compensation / brightness adjustment slider with EV readout
/// - Continuous zoom slider and quick-zoom buttons (1x, 2x, etc.)
/// - Auto vs Locked Focus and Exposure modes
/// - Flash & Torch modes (`FlashMode.off`, `FlashMode.auto`, `FlashMode.always`, `FlashMode.torch`)
/// - Tap to focus and exposure metering with an animated reticle
/// - Document framing alignment grid
/// - Camera switching (back/front)
/// - Shortcut to device photo gallery
class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({
    super.key,
    this.cameras,
    this.initialController,
    this.imagePicker,
    this.controllerFactory,
  });

  /// Injected camera list (used for testing or pre-enumerated cameras).
  final List<CameraDescription>? cameras;

  /// Injected camera controller (used for testing).
  final CameraController? initialController;

  /// Injected image picker (used for testing gallery fallback).
  final ImagePicker? imagePicker;

  /// Builds the camera controller (used for testing). Defaults to a real
  /// [CameraController] on the chosen camera.
  final CameraController Function(CameraDescription camera)? controllerFactory;

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

  List<CameraDescription> _availableCameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;

  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _permissionDenied = false;
  String? _errorMessage;

  /// Starts off: flash on paper leaves a bright glare spot that hides the
  /// words under it.
  FlashMode _flashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0;
  bool _showGrid = true;

  double _minExposureOffset = -2.0;
  double _maxExposureOffset = 2.0;
  double _exposureStepSize = 0.25;
  double _currentExposureOffset = 0.0;
  bool _showControlsPanel = false;
  FocusMode _focusMode = FocusMode.auto;
  ExposureMode _exposureMode = ExposureMode.auto;

  /// True while a screen pushed by this one (the enhance screen or the gallery
  /// picker) is on top, so this screen is not the one the user is looking at.
  bool _childRouteOpen = false;

  /// Set when the camera was released while this screen was hidden. The camera
  /// is then rebuilt only once this screen is visible again, which keeps the
  /// slow start-up out of the way of the work the visible screen is doing.
  bool _needsReinit = false;

  /// Incremented on every [_initCamera] call so a slow or timed-out attempt can
  /// never overwrite the state of a newer one.
  int _initGeneration = 0;

  Offset? _focusScreenPosition;

  /// Where the user last tapped to focus, in preview coordinates (0..1).
  /// Focus is set here again just before each shot.
  Offset? _lastFocusPoint;

  /// How long focus is given to settle before the shutter fires.
  static const Duration _focusSettleDelay = Duration(milliseconds: 350);
  Timer? _focusResetTimer;
  late final AnimationController _focusAnimController;
  late final Animation<double> _focusScaleAnim;
  late final Animation<double> _focusFadeAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _focusScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
    ]).animate(_focusAnimController);

    _focusFadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 55),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_focusAnimController);

    if (widget.initialController != null) {
      _controller = widget.initialController;
      _availableCameras = widget.cameras ?? const [];
      _isInitializing = false;
      _initZoomLevels();
      _initExposureLevels();
    } else {
      _requestPermissionAndInit();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusResetTimer?.cancel();
    _focusAnimController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final CameraController? cameraController = _controller;
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }
      // Release the camera whenever the app leaves the foreground, including
      // when a separate screen such as the crop tool takes over.
      _initGeneration++;
      cameraController.dispose();
      _controller = null;
      _needsReinit = true;
      if (mounted && _isScreenVisible) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      if (!_needsReinit) return;
      // While another screen sits on top of this one, rebuilding the camera
      // would only steal time from the screen the user is actually using. The
      // rebuild waits until this screen is visible again.
      if (!_isScreenVisible) return;
      _needsReinit = false;
      _initCamera(_selectedCameraIndex);
    }
  }

  /// How long to wait for the camera to start before giving up on one attempt.
  static const Duration _initTimeout = Duration(seconds: 8);

  /// Resolution asked for on each start-up attempt, in order.
  ///
  /// `max` is the full size the camera reports, which is what OCR wants — a
  /// page photographed at 1080p leaves body text with too few pixels per
  /// character for the recogniser. It is not supported everywhere, so the last
  /// attempt falls back to a preset every device can start.
  static const List<ResolutionPreset> _resolutionAttempts = <ResolutionPreset>[
    ResolutionPreset.max,
    ResolutionPreset.max,
    ResolutionPreset.veryHigh,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // The camera is released whenever this screen is hidden or the app leaves
    // the foreground. Once it is on top again, bring the camera back.
    if (_needsReinit && _isScreenVisible && !_permissionDenied) {
      _needsReinit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initCamera(_selectedCameraIndex);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(l10n)),
    );
  }
}
